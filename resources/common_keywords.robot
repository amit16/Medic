*** Settings ***
Documentation    Suite description    This suite will contain my keywords
Library          RequestsLibrary
Library          JSONLibrary
Library          Collections
Library          OperatingSystem
Library          ../lib/HelperModule.py

Variables        ../Resources/config.yaml

*** Keywords ***
Patient Should be able to Signin
    create session  GetToken  ${Base_URL}
    ${body} =  create dictionary  username=${USER}  password=${PASSWORD}
    ${headers} =  create dictionary   Content-Type=application/json
    ${response} =  post request  GetToken  /signin  data=${body}  headers=${headers}
    Should be equal as strings  ${response.status_code}  200
    ${accessToken} =    evaluate    $response.json().get("access_token")
    should not be empty  ${accessToken}
    set global variable  ${accessToken}  ${accessToken}
    ${HEADER} =  create dictionary  Authorization=Bearer ${accessToken}  Content-Type=application/json
    set global variable  ${HEADER}  ${HEADER}
    run keyword  Patient Should have a valid patient uuid

SuperUser Should be able to Signin
    create session  GetToken  ${Base_URL}
    ${body} =  create dictionary  username=${SUPERUSER}  password=${SUPERUSER_PASSWORD}
    ${headers} =  create dictionary   Content-Type=application/json
    ${response} =  post request  GetToken  /signin  data=${body}  headers=${headers}
    Should be equal as strings  ${response.status_code}  200
    ${accessToken} =    evaluate    $response.json().get("access_token")
    should not be empty  ${accessToken}
    set global variable  ${accessToken}  ${accessToken}
    ${SUPER_HEADER} =  create dictionary  Authorization=Bearer ${accessToken}  Content-Type=application/json
    set global variable  ${SUPER_HEADER}  ${SUPER_HEADER}

Patient Should have a valid patient uuid
    create session  GetPatient  ${Base_URL}
    ${response} =  get request  GetPatient  /profile  headers=${HEADER}
    Verify the Response  ${response}  200
    ${patient_uuid} =    evaluate    $response.json().get("id")
    set global variable  ${patient_uuid}  ${patient_uuid}

Get Tenant ID
    create session  GetTenant  ${Base_URL}
    ${response} =  get request  GetTenant  /profile  headers=${HEADER}
    Verify the Response  ${response}  200
    ${tenant_uuid} =    evaluate    $response.json().get("tenantId")
    return from keyword  ${tenant_uuid}

Get Data from file
    [Arguments]    ${filename}
    ${file_data} =  Get File  ${json_path}${filename}
    ${file_object}=  Evaluate  json.loads('''${file_data}''')   json
    return from keyword  ${file_object}

Compose URL
    [Arguments]    @{args}
    ${uri}=        Catenate    SEPARATOR=/        @{args}
    return from keyword  ${uri}

Verify the Response
    [Arguments]    ${response}    ${resp_status}
    Log    Response code is : ${response.status_code}
    Should Be Equal As Strings    ${response.status_code}    ${resp_status}
    Log    Response body is : ${response.text}

Get Payment Card Id
    create session  GetcardId  ${Base_URL}
    ${uri} =  Compose URL  /patient  ${patient_uuid}  cc
    ${response} =  get request  GetcardId  ${uri}  headers=${HEADER}
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

Verify the data present in response
    [Arguments]    ${response}    ${resp_data}   ${key}
    FOR  ${item}  IN   @{response.json()}
    ${status}=  run keyword and return status  should be equal  ${item[${key}]}  ${resp_data}
    exit for loop if  ${status}
    END

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

Reset Patient Details On Suite Completion
    create session  UpdatePatientDetail  ${Base_URL}
    ${uri} =  Compose URL  /patient  ${patient_uuid}
    ${file_data} =  Get File  ${json_path}patient_details.json
    ${file_object}=  Evaluate  json.loads('''${file_data}''')   json
    ${response} =  put request  UpdatePatientDetail  ${uri}  data=${file_object}   headers=${HEADER}
    Verify the Response  ${response}  200
    Reset Patient Communication Preference

Reset Patient Communication Preference
    create session  UpdateCommunication  ${Base_URL}
    ${uri} =  Compose URL  /patient  ${patient_uuid}  communicationpreference
    ${file_data} =  Get File  ${json_path}communication_details.json
    ${file_object}=  Evaluate  json.loads('''${file_data}''')   json
    ${response} =  put request  UpdateCommunication  ${uri}  data=${file_object}   headers=${HEADER}
    Verify the Response  ${response}  200

Get Resource ID
    [Arguments]    ${response}
    ${resource_details}=    evaluate    $response.json()
    ${resource_id}=  set variable  ${resource_details["id"]}
    return from keyword  ${resource_id}

Get First Resource ID from List
    [Arguments]    ${list_response}
    ${resource_details}=    evaluate    $list_response.json()
    ${resource_id}=  set variable  ${resource_details[0]["id"]}
    return from keyword  ${resource_id}

Verify the Response is a List
    [Arguments]    ${response}
    ${response_list}=    evaluate    $response.json()
    ${status}=  check response type  ${response_list}  list
    should be true  ${status}
