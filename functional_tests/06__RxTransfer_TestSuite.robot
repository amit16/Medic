*** Settings ***
Documentation    Patient RxTransfer Workflow    This suite contains tescases to verify patient rxtransfer workflow
Resource         ../Resources/common_keywords.robot

*** Keywords ***
Get Shipping Method Id
    create session  GetShipping  ${Base_URL}
    ${uri} =  Compose URL  /shippingmethod
    ${response} =  get request  GetShipping  ${uri}
    Verify the Response  ${response}  200
    ${shipping_id}=  Get First Resource ID from List   ${response}
    return from keyword  ${shipping_id}

Build Request Paylod for RxTransferRequest
    [Arguments]    ${filename}
    ${file_data} =  Get File  ${json_path}${filename}
    ${payload_object}=  Evaluate  json.loads('''${file_data}''')   json
    ${requestedDrugs}=  create list
    ${shipping_id}=  Get Shipping Method Id
    ${requestedDrugs_item}=  create dictionary  ndc  ${drug_ndc_rxtransfer}  shippingMethodId  ${shipping_id}  quantity  ${2}
    append to list  ${requestedDrugs}  ${requestedDrugs_item}
    set to dictionary  ${payload_object}  requestedDrugs=${requestedDrugs}
    return from keyword  ${payload_object}

Verify Order Amount
    [Arguments]    ${response}
    ${resource_details}=    evaluate    $response.json()
    ${calculated_OrderAmount} =    set variable    ${90.0}
    should be equal  ${resource_details["orderAmount"]}  ${calculated_OrderAmount}

*** Test Cases ***
TC_001 : [POST] Create a New RxTransfer Request for a Patient
    [Tags]  sanity
    create session  NewRxTransfer  ${Base_URL}
    ${uri} =  Compose URL  /patient  ${new_patient_uuid}  rxtransfer
    ${input_data}=  Build Request Paylod for RxTransferRequest  new_rxtransfer.json
    ${response} =  post request  NewRxTransfer  ${uri}  data=${input_data}   headers=${NEW_PATIENT_HEADER}
    Verify the Response  ${response}  200
    Verify Order Amount  ${response}
    ${rxtransfer_id}=  Get Resource ID    ${response}
    set suite variable  ${rxtransfer_id}
    ${payment_status}=    evaluate    $response.json()
    should be equal as strings  ${payment_status["paymentStatus"]}  payment_pending

TC_002 : [GET] Get Specific RxTranfer Request
    [Tags]  sanity
    create session  GetRxTransfer   ${Base_URL}
    ${uri} =  Compose URL  /patient  ${new_patient_uuid}  rxtransfer  ${rxtransfer_id}
    ${response} =  get request  GetRxTransfer  ${uri}  headers=${NEW_PATIENT_HEADER}
    Verify the Response  ${response}  200
    ${requestedDrugs_list} =    evaluate    $response.json().get("requestedDrugs")
    should not be empty  ${requestedDrugs_list}
    ${payment_status}=    evaluate    $response.json()
    should be equal as strings  ${payment_status["paymentStatus"]}  payment_pending

TC_003 : [GET] Get All RxTranfer Request
    [Tags]  sanity
    create session  GetAllRxTransfer   ${Base_URL}
    ${uri} =  Compose URL  /patient  ${new_patient_uuid}  rxtransfers
    ${response} =  get request  GetAllRxTransfer  ${uri}  headers=${NEW_PATIENT_HEADER}
    Verify the Response  ${response}  200
    Verify the Response is a List  ${response}

TC_004 : [POST] Create a New RxTransfer Transaction for a Patient
    [Tags]  sanity
    create session  NewRxTransferTrans  ${Base_URL}
    ${uri} =  Compose URL  /patient  ${new_patient_uuid}  rxtransfer  ${rxtransfer_id}  transaction
    ${input_data}=  Add Valid CC Id   rxtransfer_transaction.json
    ${response} =  post request  NewRxTransferTrans  ${uri}  data=${input_data}   headers=${NEW_PATIENT_HEADER}
    Verify the Response  ${response}  200
    ${rxtransfer_tran_id}=  Get Resource ID    ${response}
    should not be empty  ${rxtransfer_tran_id}
    set suite variable  ${rxtransfer_tran_id}

TC_005 : [GET] Get Specific RxTranfer Transactions
    [Tags]  sanity
    create session  GetRxTransferTrans   ${Base_URL}
    ${uri} =  Compose URL  /patient  ${new_patient_uuid}  rxtransfer  ${rxtransfer_id}  transaction  ${rxtransfer_tran_id}
    ${response} =  get request  GetRxTransferTrans  ${uri}  headers=${NEW_PATIENT_HEADER}
    Verify the Response  ${response}  200
    ${trans_status}=    evaluate    $response.json()
    should be equal as strings  ${trans_status["orderType"]}   RX_TRANSFER

TC_006 : [GET] Get All RxTranfer Transactions
    [Tags]  sanity
    create session  GetAllRxTransferTrans  ${Base_URL}
    ${uri} =  Compose URL  /patient  ${new_patient_uuid}  rxtransfer  ${rxtransfer_id}  transactions
    ${response} =  get request  GetAllRxTransferTrans  ${uri}  headers=${NEW_PATIENT_HEADER}
    Verify the Response  ${response}  200
    Verify the Response is a List  ${response}

TC_007 : [POST] Submit a New RxTransfer for a Patient
    [Tags]  sanity
    create session  NewRxTransferSubmit  ${Base_URL}
    ${uri} =  Compose URL  /patient  ${new_patient_uuid}  rxtransfer  ${rxtransfer_id}  submit
    ${input_data} =  create dictionary  transUuid  ${rxtransfer_tran_id}
    ${response} =  post request  NewRxTransferSubmit  ${uri}  data=${input_data}   headers=${NEW_PATIENT_HEADER}
    Verify the Response  ${response}  200
    Verify Order Amount  ${response}
    ${rxtransfer_sucess}=    evaluate    $response.json()
    should be equal as strings  ${rxtransfer_sucess["paymentStatus"]}  payment_successful
