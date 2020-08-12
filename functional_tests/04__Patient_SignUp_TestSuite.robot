*** Settings ***
Documentation    Patient SignUp Workflow    This suite contains tescases to verify patient signup and email verificatiom workflow
Resource         ../Resources/common_keywords.robot
Resource         ../Resources/rx_keywords.robot

Library           ../lib/Mailosaur.py        Cw0bnKbM9HcGDOA

*** Variables ***
${SERVER_ID}                    rc2y5mmp
#${RANDOM_EMAIL}                 IH3EKVYPEZ.rc2y5mmp@mailosaur.io
#${new_patient_name}             AutoQAHZ

*** Keywords ***
Build Patient Signup Request
    [Arguments]    ${filename}
    ${file_object} =  Get File  ${json_path}${filename}
    ${file_data}=  Evaluate  json.loads('''${file_object}''')   json
    ${RANDOM_EMAIL}=   Generate Email Address  ${SERVER ID}
    set suite variable  ${RANDOM_EMAIL}
    ${new_patient_name}=  random patient name
    set suite variable  ${new_patient_name}
    ${date_of_birth}=  random birth date
    set to dictionary   ${file_data}  firstName=${new_patient_name}  email=${RANDOM_EMAIL}  dateOfBirth=${date_of_birth}
    return from keyword  ${file_data}

New Patient Should be Signed In
    create session  GetToken  ${Base_URL}
    ${body} =  create dictionary  username=${RANDOM_EMAIL}  password=Test1234
    ${headers} =  create dictionary   Content-Type=application/json
    ${response} =  post request  GetToken  /signin  data=${body}  headers=${headers}
    Should be equal as strings  ${response.status_code}  200
    ${accessToken} =    evaluate    $response.json().get("access_token")
    should not be empty  ${accessToken}
    ${HEADER} =  create dictionary  Authorization=Bearer ${accessToken}  Content-Type=application/json
    set suite variable  ${HEADER}  ${HEADER}
    Set New Patient Login Details  ${HEADER}

*** Test Cases ***
TC_001 : [POST] Verify New Patient SignUp
    [Tags]  sanity
    create session  NewPatientSignup  ${Base_URL}
    ${uri} =  Compose URL  /signup
    ${input_data}=  Build Patient Signup Request  new_patient_signup.json
    ${headers} =  create dictionary   Content-Type=application/json   origin=https://api-qa.medvantxos.com
    ${response} =  post request  NewPatientSignup  ${uri}  data=${input_data}  headers=${headers}
    Verify the Response  ${response}  200
    sleep  30s
    ${welcome_email}=  Check Welcome Email  ${SERVER ID}    ${RANDOM_EMAIL}  ${new_patient_name}
    should be true  ${welcome_email}
    ${verify_email}=  Check Verify Email  ${SERVER ID}    ${RANDOM_EMAIL}  ${new_patient_name}
    should be true  ${verify_email}

TC_002 : [GET] Verify email for newly Signed Up Patient
    [Tags]  sanity
    ${token}=  Get Verification Token  ${SERVER ID}    ${RANDOM_EMAIL}
    create session  VerifyEmail  ${Base_URL}
    ${uri} =  Compose URL  /email  verify?otc=${token}
    ${response}=  get request  VerifyEmail  ${uri}
    Verify the Response  ${response}  200

TC_003 : [POST] Re-Sent Verify email for newly Signed Up Patient
    [Tags]  sanity
    New Patient Should be Signed In
    create session  ReSentVerifyEmail  ${Base_URL}
    ${uri} =  Compose URL  /email  resend-verify-token
    ${response}=  post request  ReSentVerifyEmail  ${uri}  headers=${HEADER}
    Verify the Response  ${response}  202
    log to console  ${response}
    sleep  30s
    ${verify_email}=  Check Verify Email  ${SERVER ID}    ${RANDOM_EMAIL}  ${new_patient_name}
    should be true  ${verify_email}

