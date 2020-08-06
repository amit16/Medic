*** Settings ***
Documentation    Patient SignUp Workflow    This suite contains tescases to verify patient signup and email verificatiom workflow
Resource         ../Resources/common_keywords.robot

*** Keywords ***
Get Data from file
    [Arguments]    ${filename}
    ${file_data} =  Get File  ${json_path}${filename}
    ${file_object}=  Evaluate  json.loads('''${file_data}''')   json
    return from keyword  ${file_object}

*** Test Cases ***
TC_001 : [GET] Verify Patient exist and check patient's uuid
    [Tags]  sanity
    Patient Should be able to Signin

TC_002 : [GET] Verify Patient details and check patient's details
    [Tags]  sanity
    create session  GetPatientDetail  ${Base_URL}
    ${uri} =  Compose URL  /patient  ${patient_uuid}
    ${response} =  get request  GetPatientDetail  ${uri}  headers=${HEADER}
    ${input_data}=  Get Data from file  patient_details.json
    Verify the Response  ${response}  200
    ${status}=  compare dicts   ${input_data}  ${response.json()}
    should be true  ${status}

TC_003 : [PUT] Update Patient details and check patient's data
    [Tags]  sanity
    create session  UpdatePatientDetail  ${Base_URL}
    ${uri} =  Compose URL  /patient  ${patient_uuid}
    ${input_data}=  Get Data from file  patient_update.json
    ${response} =  put request  UpdatePatientDetail  ${uri}  data=${input_data}   headers=${HEADER}
    Verify the Response  ${response}  200
    ${status}=  compare dicts   ${input_data}  ${response.json()}
    should be true  ${status}

TC_004 : [POST] Create a new medication.
    [Tags]  sanity
    create session  CreateNewMedication  ${Base_URL}
    ${uri} =  Compose URL  /patient  ${patient_uuid}  medication
    ${input_data}=  Get Data from file  medication.json
    ${response} =  post request  CreateNewMedication  ${uri}  data=${input_data}   headers=${HEADER}
    Verify the Response  ${response}  200

TC_005 : [GET] A New Medication is created.
    [Tags]  sanity
    create session  GetNewMedication  ${Base_URL}
    ${input_data}=  Get Data from file  medication.json
    ${uri} =  Compose URL  /patient  ${patient_uuid}  medications
    ${response} =  get request  GetNewMedication  ${uri}  headers=${HEADER}
    Verify the Response  ${response}  200
    Verify the data present in response    ${response}    ${input_data}.get("name")   name

TC_006 : [DELETE] Delete the newly created medication.
    [Tags]  sanity
    create session  DelNewMedication  ${Base_URL}
    ${input_data}=  Get Data from file  medication.json
    ${med_id}=  Get Medication ID By Name  ${input_data["name"]}
    ${uri} =  Compose URL  /patient  ${patient_uuid}  medication  ${med_id}
    ${response} =  delete request  DelNewMedication  ${uri}  headers=${HEADER}
    Verify the Response  ${response}  204

TC_007 : [GET] Get Communication Preference for Patient
    [Tags]  sanity
    create session  GetCommunication  ${Base_URL}
    ${input_data}=  Get Data from file  communication_details.json
    ${uri} =  Compose URL  /patient  ${patient_uuid}  communicationpreference
    ${response} =  get request  GetCommunication  ${uri}  headers=${HEADER}
    Verify the Response  ${response}  200
    ${status}=  compare dicts   ${input_data}  ${response.json()["body"]}
    should be true  ${status}

TC_008 : [PUT] Update Communication Preference for Patient
    [Tags]  sanity
    create session  UpdateCommunication  ${Base_URL}
    ${uri} =  Compose URL  /patient  ${patient_uuid}  communicationpreference
    ${input_data}=  Get Data from file  communication_update.json
    ${response} =  put request  UpdateCommunication  ${uri}  data=${input_data}   headers=${HEADER}
    Verify the Response  ${response}  200
    ${updated_body}=  evaluate  $response.json()
    ${status}=  compare dicts   ${input_data}   ${updated_body}
    should be true  ${status}
