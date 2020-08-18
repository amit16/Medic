*** Settings ***
Documentation    Allergies and Medical Condition Workflow    This suite contains tescases to verify allergies and medical conditions workflow
Library          RequestsLibrary
Library          OperatingSystem
Resource         ../Resources/common_keywords.robot
Suite Setup      SuperUser Should be able to Signin
Force Tags       Allergy_MedicalCondition_PatientHealth

*** Keywords ***
Get Data from file
    [Arguments]    ${filename}
    ${file_data} =  Get File  ${json_path}${filename}
    ${file_object}=  Evaluate  json.loads('''${file_data}''')   json
    return from keyword  ${file_object}

*** Test Cases ***
TC_001 : [POST] Create a new allergy.
    [Tags]  sanity
    create session  CreateNewAllergy  ${iBase_URL}
    ${uri} =  Compose URL  /allergy
    ${input_data}=  Get Data from file  new_allergy.json
    ${response} =  post request  CreateNewAllergy  ${uri}  data=${input_data}  headers=${SUPER_HEADER}
    Verify the Response  ${response}  200
    ${allergy_id}=  Get Resource ID  ${response}
    set suite variable  ${allergy_id}

TC_002 : [GET] Get the New Allergy from list of all alergies
    [Tags]  sanity
    create session  GetNewAllergy  ${iBase_URL}
    ${input_data}=  Get Data from file  new_allergy.json
    ${uri} =  Compose URL  /allergies
    ${response} =  get request  GetNewAllergy  ${uri}  headers=${SUPER_HEADER}
    Verify the Response  ${response}  200
    Verify the data present in response    ${response}    ${input_data}.get("name")   name

TC_003 : [GET] Get a specific Allergy
    [Tags]  sanity
    create session  GetSpecficAllergy  ${iBase_URL}
    ${uri} =  Compose URL  /allergy  ${allergy_id}
    ${response} =  get request  GetSpecficAllergy  ${uri}  headers=${SUPER_HEADER}
    Verify the Response  ${response}  200

TC_004 : [DELETE] Delete the newly created Allergy.
    [Tags]  sanity
    create session  DelNewAllergy  ${iBase_URL}
    ${uri} =  Compose URL  /allergy  ${allergy_id}
    ${response} =  delete request  DelNewAllergy  ${uri}  headers=${SUPER_HEADER}
    Verify the Response  ${response}  204

TC_005 : [POST] Create a new Medical Consitions.
    [Tags]  sanity
    create session  CreateNewMedicalCondition  ${iBase_URL}
    ${uri} =  Compose URL  /medicalcondition
    ${input_data}=  Get Data from file  new_medical_condition.json
    ${response} =  post request  CreateNewMedicalCondition  ${uri}  data=${input_data}  headers=${SUPER_HEADER}
    Verify the Response  ${response}  200
    ${mC_id}=  Get Resource ID  ${response}
    set suite variable  ${mC_id}

TC_006 : [GET] Get the New Medical Condition from list of all medical conditions
    [Tags]  sanity
    create session  GetNewMedicalCondition  ${iBase_URL}
    ${input_data}=  Get Data from file  new_medical_condition.json
    ${uri} =  Compose URL  /medicalconditions
    ${response} =  get request  GetNewMedicalCondition   ${uri}  headers=${SUPER_HEADER}
    Verify the Response  ${response}  200
    Verify the data present in response    ${response}    ${input_data}.get("name")   name

TC_007 : [GET] Get a specific Medical Condition
    [Tags]  sanity
    create session  GetSpecficMedicalCondition  ${iBase_URL}
    ${uri} =  Compose URL  /medicalcondition  ${mC_id}
    ${response} =  get request  GetSpecficMedicalCondition  ${uri}  headers=${SUPER_HEADER}
    Verify the Response  ${response}  200

TC_008 : [DELETE] Delete the newly created Medical Condition
    [Tags]  sanity
    create session  DelNewMedicalCondition  ${iBase_URL}
    ${uri} =  Compose URL  /medicalcondition  ${mC_id}
    ${response} =  delete request  DelNewMedicalCondition  ${uri}  headers=${SUPER_HEADER}
    Verify the Response  ${response}  204