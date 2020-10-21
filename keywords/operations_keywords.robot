*** Settings ***
Documentation    Ops Keyword   This has the collection of common opearions keyword keywords
Library          RequestsLibrary
Library          JSONLibrary
Library          Collections
Library          OperatingSystem
Library          ../lib/HelperModule.py

*** Keywords ***

Get Data from file
    [Arguments]    ${filepath}
    ${file_data} =  Get File  ${filepath}
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

Verify the data present in response
    [Arguments]    ${response}    ${resp_data}   ${key}
    FOR  ${item}  IN   @{response.json()}
    ${status}=  run keyword and return status  should be equal  ${item[${key}]}  ${resp_data}
    exit for loop if  ${status}
    END

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
