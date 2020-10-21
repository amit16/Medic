*** Settings ***
Documentation    Suite description    This suite will contain my keywords
Library          ../lib/HelperModule.py
Resource         ../keywords/all_keywords.robot

*** Keywords ***

Get Tenant Id
    [Arguments]    ${Base_URL}   ${site_domain}
    create session  GetTenantNoAuth  ${Base_URL}
    ${response} =  get request  GetTenantNoAuth  /site?domainName=${site_domain}
    Verify the Response  ${response}  200
    ${tenant_uuid} =    evaluate    $response.json().get("tenantId")
    return from keyword  ${tenant_uuid}


Get Site Id
    [Arguments]    ${Base_URL}   ${site_domain}
    create session  GetSiteNoAuth  ${Base_URL}
    ${response} =  get request  GetSiteNoAuth  /site?domainName=${site_domain}
    Verify the Response  ${response}  200
    ${site_uuid} =    evaluate    $response.json().get("siteId")
    ${tenant_uuid}=  Get Tenant ID  ${Base_URL}    ${site_domain}

    ${site_uri_no_auth}=  Compose URL   /tenant  ${tenant_uuid}   site   ${site_uuid}
    create session  GetSiteDetailsNoAuth  ${Base_URL}
    ${response} =  get request  GetSiteDetailsNoAuth  ${site_uri_no_auth}
    ${site_details}=    evaluate    $response.json()
    return from keyword  ${site_details['id']}


Get Drug Price
    [Arguments]    ${Base_URL}   ${drug_ndc}  ${site_domain}
    ${site_uuid}=  Get Site ID  ${Base_URL}    ${site_domain}
    ${tenant_uuid}=  Get Tenant ID  ${Base_URL}    ${site_domain}
    create session  GetDrugDetails  ${Base_URL}
    ${uri} =  Compose URL   /tenant  ${tenant_uuid}   site   ${site_uuid}  drugs
    ${response} =  get request  GetDrugDetails   ${uri}
    Verify the Response  ${response}  200
    ${response_list}=    evaluate    $response.json()
    ${drug_details}=  Get Drug Price from ndc   ${response_list}   ${drug_ndc}
    should not be empty  ${drug_details}
    return from keyword  ${drug_details['price']}

