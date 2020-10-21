*** Settings ***
Documentation    Patient Profile Workflow    This suite contains tescases to verify patient profile workflow
Resource         ../../keywords/all_keywords.robot
Variables        ../../keywords/config.yaml

Suite Setup      Patient Signin and Set Patient UUID
Suite Teardown   Reset Patient Details On Suite Completion
Force Tags       PatientProfile

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

Get Medication ID By Name
    [Arguments]    ${medication_name}
    create session  GetMedication  ${Base_URL}
    ${uri} =  Compose URL  /patient  ${patient_uuid}  medications
    ${response} =  get request  GetMedication  ${uri}  headers=${HEADER}
    Verify the Response  ${response}  200
    FOR  ${item}  IN   @{response.json()}
    run keyword if   '${item['name']}'=='${medication_name}'   Exit For Loop
    END
    ${med_id}=  evaluate  ${item}.get("id")
    return from keyword  ${med_id}

Reset Patient Communication Preference
    create session  UpdateCommunication  ${Base_URL}
    ${uri} =  Compose URL  /patient  ${patient_uuid}  communicationpreference
    ${input_data}=  Get Data from file  ${json_path}communication_details.json
    ${response} =  put request  UpdateCommunication  ${uri}  data=${input_data}  headers=${HEADER}
    Verify the Response  ${response}  200

Reset Patient Password
    create session  UpdatePassword  ${Base_URL}
    ${uri} =  Compose URL  updatepassword
    ${current_password}=  set variable  ${credentials['patient']['password']}
    ${input_data}=  create dictionary  currentPassword  Test@1234!  newPassword  ${current_password}
    ${response} =  post request  UpdatePassword  ${uri}   data=${input_data}   headers=${HEADER}
    Verify the Response  ${response}  200

Reset Patient Details On Suite Completion
    create session  UpdatePatientDetail  ${Base_URL}
    ${uri} =  Compose URL  /patient  ${patient_uuid}
    ${patient_data}=  Get Patient details   ${patient_uuid}
    set to dictionary  ${patient_data}   gender=female
    ${response} =  put request  UpdatePatientDetail  ${uri}  data=${patient_data}   headers=${HEADER}
    Verify the Response  ${response}  200
    Reset Patient Communication Preference
    Reset Patient Password
    User Should be able to Signout   ${Base_URL}  ${HEADER}

*** Test Cases ***

TC_001 : [PUT] Update Patient details and check patient's data
    [Tags]  sanity
    create session  UpdatePatientDetail  ${Base_URL}
    ${uri} =  Compose URL  /patient  ${patient_uuid}
    ${patient_data}=  Get Patient details   ${patient_uuid}
    set to dictionary  ${patient_data}   gender=male
    ${response} =  put request  UpdatePatientDetail  ${uri}  data=${patient_data}   headers=${HEADER}
    Verify the Response  ${response}  200

TC_002 : [POST] Create a new medication.
    [Tags]  sanity
    create session  CreateNewMedication  ${Base_URL}
    ${uri} =  Compose URL  /patient  ${patient_uuid}  medication
    ${input_data}=  Get Data from file  ${json_path}medication.json
    ${response} =  post request  CreateNewMedication  ${uri}  data=${input_data}   headers=${HEADER}
    Verify the Response  ${response}  200

TC_003 : [GET] A New Medication is created.
    [Tags]  sanity
    create session  GetNewMedication  ${Base_URL}
    ${input_data}=  Get Data from file  ${json_path}medication.json
    ${uri} =  Compose URL  /patient  ${patient_uuid}  medications
    ${response} =  get request  GetNewMedication  ${uri}  headers=${HEADER}
    Verify the Response  ${response}  200
    Verify the data present in response    ${response}    ${input_data}.get("name")   name

TC_004 : [DELETE] Delete the newly created medication.
    [Tags]  sanity
    create session  DelNewMedication  ${Base_URL}
    ${input_data}=  Get Data from file  ${json_path}medication.json
    ${med_id}=  Get Medication ID By Name  ${input_data["name"]}
    ${uri} =  Compose URL  /patient  ${patient_uuid}  medication  ${med_id}
    ${response} =  delete request  DelNewMedication  ${uri}  headers=${HEADER}
    Verify the Response  ${response}  204

TC_005 : [GET] Get Communication Preference for Patient
    [Tags]  sanity
    create session  GetCommunication  ${Base_URL}
    ${input_data}=  Get Data from file  ${json_path}communication_details.json
    ${uri} =  Compose URL  /patient  ${patient_uuid}  communicationpreference
    ${response} =  get request  GetCommunication  ${uri}  headers=${HEADER}
    Verify the Response  ${response}  200
    ${status}=  compare dicts   ${input_data}  ${response.json()["body"]}
    should be true  ${status}

TC_006 : [PUT] Update Communication Preference for Patient
    [Tags]  sanity
    create session  UpdateCommunication  ${Base_URL}
    ${uri} =  Compose URL  /patient  ${patient_uuid}  communicationpreference
    ${input_data}=  Get Data from file  ${json_path}communication_update.json
    ${response} =  put request  UpdateCommunication  ${uri}  data=${input_data}   headers=${HEADER}
    Verify the Response  ${response}  200
    ${updated_body}=  evaluate  $response.json()
    ${status}=  compare dicts   ${input_data}   ${updated_body}
    should be true  ${status}

TC_007 : [POST] Update Patient password
    [Tags]  sanity
    create session  UpdatePassword  ${Base_URL}
    ${uri} =  Compose URL  updatepassword
    ${current_password}=  set variable  ${credentials['patient']['password']}
    ${current_username}=  set variable  ${credentials['patient']['username']}
    ${input_data}=  create dictionary  currentPassword  ${current_password}  newPassword  Test@1234!
    ${response} =  post request  UpdatePassword  ${uri}   data=${input_data}   headers=${HEADER}
    Verify the Response  ${response}  200
    ${updated_pwd_body}=  evaluate  $response.json()
    log to console  ${updated_pwd_body}
    ${new_credentials}=  create dictionary  username  ${current_username}  password  Test@1234!
    ${status}=  User Should be able to Signin  ${Base_URL}  ${new_credentials}

