*** Settings ***
Documentation    Patient RxRequest Workflow    This suite contains tescases to verify patient rxrequest workflow
Resource         ../Resources/common_keywords.robot
Suite Setup      Patient Should be able to Signin

*** Keywords ***
Get Shipping Method Id
    create session  GetShipping  ${Base_URL}
    ${uri} =  Compose URL  /shippingmethod
    ${response} =  get request  GetShipping  ${uri}
    Verify the Response  ${response}  200
    ${shipping_id}=  Get First Resource ID from List   ${response}
    return from keyword  ${shipping_id}

Build Request Paylod for RxRequest
    [Arguments]    ${filename}
    ${file_data} =  Get File  ${json_path}${filename}
    ${payload_object}=  Evaluate  json.loads('''${file_data}''')   json
    ${requestedDrugs}=  create list
    ${shipping_id}=  Get Shipping Method Id
    ${md_id}=  Get MD ID By Name  ${MD_NAME}
    ${requestedDrugs_item}=  create dictionary  ndc  ${drug_ndc}  shippingMethodId  ${shipping_id}  quantity  ${2}
    append to list  ${requestedDrugs}  ${requestedDrugs_item}
    set to dictionary  ${payload_object}  requestedDrugs=${requestedDrugs}
    set to dictionary  ${payload_object}  mdId=${md_id}
    return from keyword  ${payload_object}

Add Order Amount
    [Arguments]    ${trans_data}
    set to dictionary  ${trans_data}  transAmount=${bill_amount}
    return from keyword  ${trans_data}

Verify Order Amount
    [Arguments]    ${response}
    ${resource_details}=    evaluate    $response.json()
    ${calculated_OrderAmount} =    set variable    ${110.0}
    should be equal  ${resource_details["orderAmount"]}  ${calculated_OrderAmount}

*** Test Cases ***
TC_001 : [POST] Create a New RxRequest for a Patient
    [Tags]  sanity
    create session  NewRx  ${Base_URL}
    ${uri} =  Compose URL  /patient  ${patient_uuid}  rxrequest
    ${input_data}=  Build Request Paylod for RxRequest  new_rxrequest.json
    ${response} =  post request  NewRx  ${uri}  data=${input_data}   headers=${HEADER}
    Verify the Response  ${response}  200
    Verify Order Amount  ${response}
    ${rxrequest_id}=  Get Resource ID    ${response}
    set suite variable  ${rxrequest_id}
    ${payment_status}=    evaluate    $response.json()
    should be equal as strings  ${payment_status["paymentStatus"]}  payment_pending


TC_002 : [GET] Get Specific RxRequest
    [Tags]  sanity
    create session  GetRx   ${Base_URL}
    ${uri} =  Compose URL  /patient  ${patient_uuid}  rxrequest  ${rxrequest_id}
    ${response} =  get request  GetRx  ${uri}  headers=${HEADER}
    Verify the Response  ${response}  200
    ${requestedDrugs_list} =    evaluate    $response.json().get("requestedDrugs")
    should not be empty  ${requestedDrugs_list}
    ${payment_status}=    evaluate    $response.json()
    ${bill_amount}=   set variable  ${payment_status["orderAmount"]}
    set suite variable  ${bill_amount}
    should be equal as strings  ${payment_status["paymentStatus"]}  payment_pending

TC_003 : [GET] Get All RxRequest
    [Tags]  sanity
    create session  GetAllRx   ${Base_URL}
    ${uri} =  Compose URL  /patient  ${patient_uuid}  rxrequests
    ${response} =  get request  GetAllRx  ${uri}  headers=${HEADER}
    Verify the Response  ${response}  200
    Verify the Response is a List  ${response}

TC_004 : [POST] Create a New Pre-Order Transaction for a Patient
    [Tags]  sanity
    create session  NewPreOrderTrans  ${Base_URL}
    ${uri} =  Compose URL  /patient  ${patient_uuid}  rxrequest  ${rxrequest_id}  transaction
    ${input_data}=  Add Valid CC Id   preorder_transaction.json
    ${response_data}=  Add Order Amount  ${input_data}
    ${response} =  post request  NewPreOrderTrans  ${uri}  data=${response_data}   headers=${HEADER}
    Verify the Response  ${response}  200
    ${preorder_tran_id}=  Get Resource ID    ${response}
    should not be empty  ${preorder_tran_id}
    set suite variable  ${preorder_tran_id}

TC_005 : [GET] Get Specific Pre-Order Transactions
    [Tags]  sanity
    create session  GetRxPreOrderTrans   ${Base_URL}
    ${uri} =  Compose URL  /patient  ${patient_uuid}  rxrequest  ${rxrequest_id}  transaction  ${preorder_tran_id}
    ${response} =  get request  GetRxPreOrderTrans  ${uri}  headers=${HEADER}
    Verify the Response  ${response}  200
    ${trans_status}=    evaluate    $response.json()
    should be equal as strings  ${trans_status["orderType"]}   RX_REQUEST

TC_006 : [GET] Get All Pre-Order Transactions
    [Tags]  sanity
    create session  GetAllRxPreOrderTrans  ${Base_URL}
    ${uri} =  Compose URL  /patient  ${patient_uuid}  rxrequest  ${rxrequest_id}  transactions
    ${response} =  get request  GetAllRxPreOrderTrans  ${uri}  headers=${HEADER}
    Verify the Response  ${response}  200
    Verify the Response is a List  ${response}

TC_007 : [POST] Submit a New RxRequest for a Patient
    [Tags]  sanity
    create session  NewRxSubmit  ${Base_URL}
    ${uri} =  Compose URL  /patient  ${patient_uuid}  rxrequest  ${rxrequest_id}  submit
    ${input_data} =  create dictionary  transUuid  ${preorder_tran_id}
    ${response} =  post request  NewRxSubmit  ${uri}  data=${input_data}   headers=${HEADER}
    Verify the Response  ${response}  200
    Verify Order Amount  ${response}
    ${rxrequest_sucess}=    evaluate    $response.json()
    should be equal as strings  ${rxrequest_sucess["paymentStatus"]}  payment_successful
