*** Settings ***
Documentation    Suite description    This suite will contain keywords for Rx
Library          RequestsLibrary
Library          JSONLibrary
Library          Collections
Library          OperatingSystem
Library          ../lib/HelperModule.py
Resource         ../Resources/common_keywords.robot

Variables        ../Resources/config.yaml

*** Keywords ***
Get MD ID By Name
    [Arguments]    ${input_md_name}
    create session  GetMD  ${Base_URL}
    ${uri} =  Compose URL  /mds
    ${response} =  get request  GetMD  ${uri}  headers=${NEW_PATIENT_HEADER}
    Verify the Response  ${response}  200
    FOR  ${item}  IN   @{response.json()}
    run keyword if   '${item['name']}'=='${input_md_name}'   Exit For Loop
    END
    ${md_id}=  evaluate  ${item}.get("id")
    return from keyword  ${md_id}

Create a Payment Card
    create session  CreateCard  ${Base_URL}
    ${uri} =  Compose URL  /patient  ${new_patient_uuid}  cc
    ${file_data} =  Get File  ${json_path}new_CC.json
    ${payload}=  Evaluate  json.loads('''${file_data}''')   json
    ${billing_id}=  random billing id
    set to dictionary  ${payload}  billingId=${billing_id}
    ${response} =  post request  CreateCard  ${uri}  data=${payload}   headers=${NEW_PATIENT_HEADER}
    Verify the Response  ${response}  200
    ${cc_id}=  Get Resource ID    ${response}
    return from keyword  ${cc_id}

Get Payment Card Id
    create session  GetcardId  ${Base_URL}
    ${uri} =  Compose URL  /patient  ${new_patient_uuid}  cc
    ${response} =  get request  GetcardId  ${uri}  headers=${NEW_PATIENT_HEADER}
    Verify the Response  ${response}  200
    ${cc_id}=  Get First Resource ID from List  ${response}
    return from keyword  ${cc_id}

Add Valid CC Id
    [Arguments]    ${filename}
    ${file_data} =  Get File  ${json_path}${filename}
    ${payload_object}=  Evaluate  json.loads('''${file_data}''')   json
    ${cc_id}=  Get Payment Card Id
    set to dictionary  ${payload_object}  ccId=${cc_id}
    return from keyword  ${payload_object}

Set New Patient Login Details
    [Arguments]    ${NEW_PATIENT_HEADER}
    set global variable  ${NEW_PATIENT_HEADER}  ${NEW_PATIENT_HEADER}
    create session  GetPatient  ${Base_URL}
    ${response} =  get request  GetPatient  /profile  headers=${NEW_PATIENT_HEADER}
    Verify the Response  ${response}  200
    ${new_patient_uuid} =    evaluate    $response.json().get("id")
    set global variable  ${new_patient_uuid}  ${new_patient_uuid}
