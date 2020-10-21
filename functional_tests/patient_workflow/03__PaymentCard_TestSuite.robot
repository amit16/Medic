*** Settings ***
Documentation    Payment Card Workflow    This suite contains tescases to verify payment card workflow
Resource         ../../keywords/all_keywords.robot
Variables        ../../keywords/config.yaml

Suite Setup      Patient Signin and Set Patient UUID
Suite Teardown   User Should be able to Signout   ${Base_URL}  ${HEADER}
Force Tags       PatientPaymentCard

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

Build Request Paylod for CC
    [Arguments]    ${filename}
    ${file_data} =  Get Data from file  ${json_path}${filename}
    ${billing_id}=  random billing id
    set to dictionary  ${file_data}  billingId=${billing_id}
    return from keyword  ${file_data}

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