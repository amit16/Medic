*** Settings ***
Documentation    Payment Card Workflow    This suite contains tescases to verify payment card workflow
Resource         ../Resources/common_keywords.robot
Suite Setup      Patient Should be able to Signin

*** Keywords ***
Build Request Paylod for CC
    [Arguments]    ${filename}
    ${file_data} =  Get File  ${json_path}${filename}
    ${payload}=  Evaluate  json.loads('''${file_data}''')   json
    ${billing_id}=  random billing id
    set to dictionary  ${payload}  billingId=${billing_id}
    return from keyword  ${payload}

*** Test Cases ***
TC_001 : [POST] Create a Payment Card for a Patient
    [Tags]  sanity
    create session  CreateCard  ${Base_URL}
    ${uri} =  Compose URL  /patient  ${patient_uuid}  cc
    ${input_data}=  Build Request Paylod for CC  new_CC.json
    ${response} =  post request  CreateCard  ${uri}  data=${input_data}   headers=${HEADER}
    Verify the Response  ${response}  200
    ${cc_id}=  Get Resource ID    ${response}
    set suite variable  ${cc_id}

TC_002 : [GET] Verify Payment Card list exist
    [Tags]  sanity
    create session  GetAllcards  ${Base_URL}
    ${uri} =  Compose URL  /patient  ${patient_uuid}  cc
    ${response} =  get request  GetAllcards  ${uri}  headers=${HEADER}
    Verify the Response  ${response}  200
    Verify the Response is a List  ${response}

TC_003 : [GET] Verify Specific Payment Card exist
    [Tags]  sanity
    create session  GetCard  ${Base_URL}
    ${uri} =  Compose URL  /patient  ${patient_uuid}  cc  ${cc_id}
    ${response} =  get request  GetCard  ${uri}  headers=${HEADER}
    Verify the Response  ${response}  200

TC_004 : [POST] Make a Payment Card as default
    [Tags]  sanity
    create session  MakeCardDefault  ${Base_URL}
    ${uri} =  Compose URL  /patient  ${patient_uuid}  cc  ${cc_id}  default
    ${response} =  post request  MakeCardDefault  ${uri}  headers=${HEADER}
    Verify the Response  ${response}  200
    ${card_details}=  evaluate  $response.json()
    should be true  ${card_details["defaultCC"]}

TC_005 : [POST] DeActivate a Payment Card
    [Tags]  sanity
    create session  DeActivateCard  ${Base_URL}
    ${uri} =  Compose URL  /patient  ${patient_uuid}  cc  ${cc_id}  deactivate
    ${response} =  post request  DeActivateCard  ${uri}  headers=${HEADER}
    Verify the Response  ${response}  200