*** Settings ***
Documentation    Patient SignUp Workflow    This suite contains tescases to verify patient signup and email verificatiom workflow

Resource         ../../keywords/all_keywords.robot
Variables        ../../keywords/config.yaml


Library          ../lib/Mail.py
Library          ImapLibrary
Force Tags       PatientSignUp

*** Variables ***
#${SERVER_ID}                    rc2y5mmp
${RANDOM_EMAIL}                 marklous643@gmail.com
#${new_patient_name}             AutoQAKS

*** Keywords ***
Build Patient Signup Request
    [Arguments]    ${filename}
    ${file_object} =  Get File  ${json_path}${filename}
    ${file_data}=  Evaluate  json.loads('''${file_object}''')   json
    #${RANDOM_EMAIL}=   generate random emails
    set suite variable  ${RANDOM_EMAIL}
    ${new_patient_name}=  random patient name
    set suite variable  ${new_patient_name}
    ${date_of_birth}=  random birth date
    set to dictionary   ${file_data}  firstName=${new_patient_name}  email=${RANDOM_EMAIL}  dateOfBirth=${date_of_birth}
    return from keyword  ${file_data}

New Patient Should be Signed In
    ${Base_URL}=   get from dictionary  ${base}  url
    set suite variable  ${Base_URL}  ${Base_URL}
    create session  GetToken  ${Base_URL}
    ${body} =  create dictionary  username=${RANDOM_EMAIL}  password=Test@123!
    ${headers} =  create dictionary   Content-Type=application/json
    ${response} =  post request  GetToken  /signin  data=${body}  headers=${headers}
    Should be equal as strings  ${response.status_code}  200
    ${accessToken} =    evaluate    $response.json().get("access_token")
    should not be empty  ${accessToken}
    ${HEADER} =  create dictionary  Authorization=Bearer ${accessToken}  Content-Type=application/json
    set suite variable  ${HEADER}  ${HEADER}
#    Set New Patient Login Details  ${HEADER}

Multipart Email Verification
    Open Mailbox    host=imap.gmail.com   user=marklous643@gmail.com   password=Test@1234
    ${LATEST} =    Wait For Email    sender=do-not-reply@medvantxfetch.com    timeout=300
    ${parts} =    Walk Multipart Email    ${LATEST}
    :FOR    ${i}    IN RANGE    ${parts}
    \\    Walk Multipart Email    ${LATEST}
    \\    ${content-type} =    Get Multipart Content Type
    \\    Continue For Loop If    '${content-type}' != 'text/html'
    \\    ${payload} =    Get Multipart Field    Subject
    \\    Should Contain    ${payload}    Verify your email address
    \\    ${HTML} =    Open Link From Email    ${LATEST}
    \\    Should Contain    ${HTML}    otc=
    \\    ${payload2} =    Get Multipart Payload    decode=True
    \\    Should Contain    ${payload2}    your email
    Close Mailbox


*** Test Cases ***
#TC_001 : [POST] Verify New Patient SignUp
#    [Tags]  sanity
#    create session  NewPatientSignup  ${Base_URL}
#    ${uri} =  Compose URL  /signup
#    ${input_data}=  Build Patient Signup Request  new_patient_signup.json
#    ${headers} =  create dictionary   Content-Type=application/json   origin=https://api-qa.medvantxos.com
#    ${response} =  post request  NewPatientSignup  ${uri}  data=${input_data}  headers=${headers}
#    Verify the Response  ${response}  200
#    ${welcome_email}=  Check Welcome Email  ${SERVER ID}    ${RANDOM_EMAIL}  ${new_patient_name}
#    should be true  ${welcome_email}
#    ${verify_email}=  Check Verify Email  ${SERVER ID}    ${RANDOM_EMAIL}  ${new_patient_name}
#    should be true  ${verify_email}
#    New Patient Should be Signed In

#TC_002 : [GET] Verify email for newly Signed Up Patient
#    [Tags]  sanity
#    ${token}=  Get Verification Token  ${SERVER ID}    ${RANDOM_EMAIL}
#    create session  VerifyEmail  ${Base_URL}
#    ${uri} =  Compose URL  /email  verify?otc=${token}
#    ${response}=  get request  VerifyEmail  ${uri}
#    Verify the Response  ${response}  200
#
#TC_003 : [POST] Re-Sent Verify email for newly Signed Up Patient
#    [Tags]  sanity
#    New Patient Should be Signed In
#    create session  ReSentVerifyEmail  ${Base_URL}
#    ${uri} =  Compose URL  /email  resend-verify-token
#    ${response}=  post request  ReSentVerifyEmail  ${uri}  headers=${HEADER}
#    Verify the Response  ${response}  202
#    log to console  ${response}
#    ${verify_email}=  Check Verify Email  ${SERVER ID}    ${RANDOM_EMAIL}  ${new_patient_name}
#    should be true  ${verify_email}

TC_001 : [New] Test Robot Imap Library
    [Tags]  sanity
#    New Patient Should be Signed In
#    create session  ReSentVerifyEmail  ${Base_URL}
#    ${uri} =  Compose URL  /email  resend-verify-token
#    ${response}=  post request  ReSentVerifyEmail  ${uri}  headers=${HEADER}
#    Verify the Response  ${response}  202
#    log to console  ${response}
    ${verify_email}=  Multipart Email Verification
    should be true  ${verify_email}



