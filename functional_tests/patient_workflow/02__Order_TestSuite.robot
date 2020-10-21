*** Settings ***
Documentation    Patient Order Workflow    This suite contains tescases to verify patient order workflow
Resource         ../../keywords/all_keywords.robot
Variables        ../../keywords/config.yaml

Suite Setup      Patient Signin and Set Patient UUID
Suite Teardown   User Should be able to Signout   ${Base_URL}  ${HEADER}
Force Tags       PatientOrder

*** Keywords ***
Patient Signin and Set Patient UUID
    ${patient_credentials}=  get from dictionary  ${credentials}  patient
    ${Base_URL}=   get from dictionary  ${base}  url
    ${HEADER}=  User Should be able to Signin  ${Base_URL}  ${patient_credentials}
    set suite variable  ${HEADER}  ${HEADER}
    set suite variable  ${Base_URL}  ${Base_URL}
    create session  GetPatient  ${Base_URL}
    ${response} =  get request  GetPatient  /profile  headers=${HEADER}
    Verify the Response  ${response}  200
    ${patient_uuid} =    evaluate    $response.json().get("id")
    set suite variable  ${patient_uuid}  ${patient_uuid}

Get Patient details
    [Arguments]    ${patient_uuid}
    create session  GetPatientDetail  ${Base_URL}
    ${uri} =  Compose URL  /patient  ${patient_uuid}
    ${response} =  get request  GetPatientDetail  ${uri}  headers=${HEADER}
    ${input_data}=  Get Data from file  ${json_path}patient_details.json
    Verify the Response  ${response}  200
    return from keyword  ${response.json()}

Build Request Paylod for Order
    [Arguments]    ${filename}
    ${payload_object} =  Get Data from file  ${json_path}${filename}
    ${orderLine}=  create list
    ${orderLine_item}=  create dictionary  prescriptionId  ${prescription_id}  shippingMethodId  ${shipping_id}  qtyOrdered  ${2}
    append to list  ${orderLine}  ${orderLine_item}
    set to dictionary  ${payload_object}  orderLine=${orderLine}
    ${patient_details}=  Get Patient details  ${patient_uuid}
    ${payload}=  Update Patient Address  ${patient_details}  ${payload_object}
    return from keyword  ${payload}

Get Prescription ID By Drug NDC
    [Arguments]    ${prescription_list_response}
    ${prescription_list}=  set variable   @{prescription_list_response.json()}
    ${pres_details}=  get prescription from list  ${prescription_list}  ${drug["ndc_rxrequest"]}  valid
    set suite variable  ${pres_details}
    return from keyword  ${pres_details["id"]}

Verify Precription Details in Order
    [Arguments]    ${response}   ${pres_input_data}
    ${order_details}=    evaluate    $response.json()
    ${status}=  compare dicts  ${order_details["prescriptions"][0]}  ${pres_details}  False
    should be true  ${status}

Verify Shipment Amount
    [Arguments]    ${response}   ${input_data}
    ${resource_details}=    evaluate    $response.json()
    ${drug_price}=  Get Drug Price   ${Base_URL}   ${drug["ndc_rxrequest"]}   ${site}
    ${quantity_ordered}=  set variable  ${input_data["orderLine"][0]["qtyOrdered"]}
    ${expected_shipAmount}=  Evaluate  ${quantity_ordered}*${drug_price}
    set suite variable  ${expected_shipAmount}  ${expected_shipAmount}
    should be equal  ${resource_details["shipAmount"]}  ${expected_shipAmount}

Get Payment Card Id
    create session  GetcardId  ${Base_URL}
    ${uri} =  Compose URL  /patient  ${patient_uuid}  cc
    ${response} =  get request  GetcardId  ${uri}  headers=${HEADER}
    Verify the Response  ${response}  200
    ${cc_id}=  Get First Resource ID from List  ${response}
    return from keyword  ${cc_id}

Add Valid CC Id and Drug Price
    [Arguments]    ${filename}
    ${payload_object} =  Get Data from file  ${json_path}${filename}
    ${cc_id}=  Get Payment Card Id
    set to dictionary  ${payload_object}  ccId=${cc_id}
    set to dictionary  ${payload_object}  transAmount=${expected_shipAmount}
    return from keyword  ${payload_object}

*** Test Cases ***
TC_001 : [GET] Verify Prescription list exist for the Patient
    [Tags]  sanity
    create session  GetPrescription  ${Base_URL}
    ${uri} =  Compose URL  /patient  ${patient_uuid}  prescriptions
    ${response} =  get request  GetPrescription  ${uri}  headers=${HEADER}
    Verify the Response  ${response}  200
    ${prescription_id}=  Get Prescription ID By Drug NDC  ${response}
    set suite variable  ${prescription_id}

TC_002 : [GET] Verify Specific Prescription exist for the Patient
    [Tags]  sanity
    create session  GetSpecificPrescription  ${Base_URL}
    ${uri} =  Compose URL  /patient  ${patient_uuid}  prescription  ${prescription_id}
    ${response} =  get request  GetSpecificPrescription  ${uri}  headers=${HEADER}
    Verify the Response  ${response}  200
    ${prescription_specific_id}=  Get Resource ID  ${response}
    should be equal  ${prescription_id}   ${prescription_specific_id}

TC_003 : [GET] Verify Shipping Id list exist(No Auth)
    [Tags]  sanity
    create session  GetShipping  ${Base_URL}
    ${uri} =  Compose URL  /shippingmethod
    ${response} =  get request  GetShipping  ${uri}
    Verify the Response  ${response}  200
    ${shipping_id}=  Get First Resource ID from List   ${response}
    set suite variable  ${shipping_id}

TC_004 : [POST] Create a New Order for a Patient
    [Tags]  sanity
    create session  NewOrder  ${Base_URL}
    #${uri} =  Compose URL  /patient  ${patient_uuid}  order
    ${uri} =  Compose URL  /patient  ${patient_uuid}  order  f0ea2533-b599-4fc8-b303-f3ca0e4f8ae6
    ${input_data}=  Build Request Paylod for Order  create_order.json
    #${response} =  post request  NewOrder  ${uri}  data=${input_data}   headers=${HEADER}
    ${response} =  get request  NewOrder  ${uri}  headers=${HEADER}
    Verify the Response  ${response}  200
    Verify Precription Details in Order  ${response}   ${input_data}
    Verify Shipment Amount  ${response}  ${input_data}
    ${order_id}=  Get Resource ID    ${response}
    set suite variable  ${order_id}

TC_005 : [GET] Verify Order list exist for the Patient
    [Tags]  sanity
    create session  GetOrder   ${Base_URL}
    ${uri} =  Compose URL  /patient  ${patient_uuid}  orders
    ${response} =  get request  GetOrder  ${uri}  headers=${HEADER}
    Verify the Response  ${response}  200
    ${order_list} =    evaluate    $response.json().get("orderList")
    should not be empty  ${order_list}

TC_006 : [POST] Create a New Order Transaction for a Patient
    [Tags]  sanity
    create session  NewOrderTrans  ${Base_URL}
    ${uri} =  Compose URL  /patient  ${patient_uuid}  order  ${order_id}  transaction
    ${input_data}=  Add Valid CC Id and Drug Price  order_transaction.json
    ${response} =  post request  NewOrderTrans  ${uri}  data=${input_data}   headers=${HEADER}
    Verify the Response  ${response}  200
    ${order_tran_id}=  Get Resource ID    ${response}
    should not be empty  ${order_tran_id}
    set suite variable  ${order_tran_id}

TC_007 : [GET] Get Specific Order Transactions
    [Tags]  sanity
    create session  GetOrderTrans   ${Base_URL}
    ${uri} =  Compose URL  /patient  ${patient_uuid}  order  ${order_id}  transaction  ${order_tran_id}
    ${response} =  get request  GetOrderTrans  ${uri}  headers=${HEADER}
    Verify the Response  ${response}  200
    ${trans_status}=    evaluate    $response.json()

TC_008 : [GET] Get All Order Transactions
    [Tags]  sanity
    create session  GetAllOrderTransactions  ${Base_URL}
    ${uri} =  Compose URL  /patient  ${patient_uuid}  order  ${order_id}   transactions
    ${response} =  get request  GetAllOrderTransactions  ${uri}  headers=${HEADER}
    Verify the Response  ${response}  200
    Verify the Response is a List  ${response}

TC_009 : [POST] Submit a New Order for a Patient
    [Tags]  sanity
    create session  NewOrderSubmit  ${Base_URL}
    ${uri} =  Compose URL  /patient  ${patient_uuid}  order  ${order_id}  submit
    ${input_data} =  create dictionary  transUuid  ${order_tran_id}
    ${response} =  post request  NewOrderSubmit  ${uri}  data=${input_data}   headers=${HEADER}
    Verify the Response  ${response}  200
    Verify Shipment Amount  ${response}  ${input_data}
    ${order_sucess}=    evaluate    $response.json()
    should be equal as strings  ${order_sucess["paymentStatus"]}  payment_successful



