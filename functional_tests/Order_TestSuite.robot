*** Settings ***
Documentation    Patient Order Workflow    This suite contains tescases to verify patient order workflow
Resource         ../Resources/common_keywords.robot
Suite Setup      Patient Should be able to Signin

*** Keywords ***
Build Request Paylod for Order
    [Arguments]    ${filename}
    ${file_data} =  Get File  ${json_path}${filename}
    ${payload_object}=  Evaluate  json.loads('''${file_data}''')   json
    ${orderLine}=  create list
    ${orderLine_item}=  create dictionary  prescriptionId  ${prescription_id}  shippingMethodId  ${shipping_id}  qtyOrdered  ${2}
    append to list  ${orderLine}  ${orderLine_item}
    set to dictionary  ${payload_object}  orderLine=${orderLine}
    return from keyword  ${payload_object}

Verify Precription Details
    [Arguments]    ${filename}  ${response}
    ${order_details}=    evaluate    $response.json()
    #${file_data} =  Get File  ${json_path}${filename}
    #${file_prescription}=  Evaluate  json.loads('''${file_data}''')   json
    ${status}=  compare dicts  ${order_details["prescriptions"][0]}  ${file_prescription}  False
    should be true  ${status}

Get Prescription ID By Drug NDC
    [Arguments]    ${prescription_list_response}
    FOR  ${file_prescription}  IN   @{prescription_list_response.json()}
    run keyword if   '${file_prescription['drugNdc']}'=='${drug_ndc}'   Exit For Loop
    END
    set suite variable  ${file_prescription}
    ${pres_id}=  evaluate  ${file_prescription}.get("id")
    return from keyword  ${pres_id}

Verify Shipment Amount
    [Arguments]    ${response}
    ${resource_details}=    evaluate    $response.json()
    ${calculated_shipAmount} =    set variable    ${110.0}
    should be equal  ${resource_details["shipAmount"]}  ${calculated_shipAmount}

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
    ${uri} =  Compose URL  /patient  ${patient_uuid}  order
    ${input_data}=  Build Request Paylod for Order  create_order.json
    ${response} =  post request  NewOrder  ${uri}  data=${input_data}   headers=${HEADER}
    Verify the Response  ${response}  200
    Verify Precription Details  prescription_details.json  ${response}
    Verify Shipment Amount  ${response}
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
    ${input_data}=  Add Valid CC Id  order_transaction.json
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
    #should be equal as strings  ${trans_status["orderType"]}   RX_TRANSFER

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
    Verify Precription Details  prescription_details.json  ${response}
    Verify Shipment Amount  ${response}
    ${order_sucess}=    evaluate    $response.json()
    should be equal as strings  ${order_sucess["paymentStatus"]}  payment_successful





