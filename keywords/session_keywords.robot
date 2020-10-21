*** Settings ***
Documentation    Suite description    This suite will contain my keywords
Library          RequestsLibrary
Library          JSONLibrary
Library          Collections
Library          OperatingSystem
Library          ../lib/HelperModule.py

*** Keywords ***
User Should be able to Signin
    [Arguments]    ${URL}  ${credentials}
    create session  GetToken  ${URL}
    ${username}=  get from dictionary  ${credentials}  username
    ${password}=  get from dictionary  ${credentials}  password
    ${body} =  create dictionary  username=${username}  password=${password}
    ${headers} =  create dictionary   Content-Type=application/json
    ${response} =  post request  GetToken  /signin  data=${body}  headers=${headers}
    Should be equal as strings  ${response.status_code}  200
    ${accessToken} =    evaluate    $response.json().get("access_token")
    ${refreshToken} =    evaluate    $response.json().get("refresh_token")
    should not be empty  ${accessToken}
    should not be empty  ${refreshToken}
    set suite variable  ${refreshToken}
    ${HEADER} =  create dictionary  Authorization=Bearer ${accessToken}  Content-Type=application/json
    return from keyword  ${HEADER}


User Should be able to Signout
    [Arguments]    ${URL}  ${headers}
    create session  UserSignout  ${URL}
    ${body} =  create dictionary  refresh_token=${refreshToken}
    ${response} =  post request  UserSignout  /signout  data=${body}  headers=${headers}
    Should be equal as strings  ${response.status_code}  200