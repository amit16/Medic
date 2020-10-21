from REST_API.base_classes.APIInterface import *


class SiteResource(APIInterface):
    """Tenant API Resource
        POST {{login_base_url}}/iapi/v1.0/tenant/{tenant_id}/site
        """

    def __init__(self, request_url, auth_token, grx_pat_type_id=1, name=None, domain=None,  enabled=None,
                 tenant_id=None):
        self.resource = 'site'
        self.request_url = request_url
        self.auth_token = auth_token

        self.name = name
        self.domain = domain
        self.grx_pat_type_id = grx_pat_type_id
        self.enabled = enabled
        self.tenant_id = tenant_id
        self.api = APIInterface(self.request_url)

    def get_all_sites(self):
        site_uri = ['tenant', self.tenant_id, self.resource + 's']
        get_url = self.api.compose_url(level='iapi', uri=site_uri)
        self.api.perform_api_request(method='GET', url=get_url, auth_token=self.auth_token)
        get_response = self.api.get_content()
        return get_response

    def get_site_by_name(self, name=None):
        all_site = self.get_all_sites()
        for site in all_site:
            if site['name'] == name:
                return site
        return False

    def get_site_by_domain(self, domain=None):
        all_site = self.get_all_sites()
        for site in all_site:
            if site['domain'] == domain:
                return site
        return False

    def create_site(self, payload_data=None):
        site_uri = ['tenant', self.tenant_id, self.resource]
        post_data = parse_data(payload_data)

        post_url = self.api.compose_url(level='iapi', uri=site_uri)
        self.api.perform_api_request(method='POST', url=post_url, payload=post_data, auth_token=self.auth_token)
        post_response = self.api.get_content()
        return post_response

    def update_site(self, site_name=None, site_id=None, payload_data=None):
        if not site_id:
            site_d = self.get_site_by_name(site_name)
            site_id = site_d["id"]
        site_uri = ['tenant', self.tenant_id, self.resource, site_id]
        put_data = parse_data(payload_data)

        put_url = self.api.compose_url(level='iapi', uri=site_uri)
        self.api.perform_api_request(method='PUT', url=put_url, payload=put_data, auth_token=self.auth_token)
        put_response = self.api.get_content()
        return put_response

    def delete_site(self, site_name=None, site_id=None):
        if not site_id:
            site_d = self.get_site_by_name(site_name)
            site_id = site_d["id"]
        site_uri = ['tenant', self.tenant_id, self.resource, site_id]
        del_url = self.api.compose_url(level='iapi', uri=site_uri)
        self.api.perform_api_request(method='DELETE', url=del_url, auth_token=self.auth_token)
        del_response = self.api.get_content()
        return del_response


def parse_data(payload_data):
    data = dict()
    update_keys = ['id', 'dateCreated', 'dateModified', 'tenantId']
    for key_param in payload_data.keys():
        if payload_data[key_param] and key_param not in update_keys:
            data[key_param] = payload_data[key_param]

    payload = json.dumps(data)
    return payload


if __name__ == '__main__':
    ''' Unit Test '''
    creds = {'username': 'default-superuser@medvantx.com', 'password': 'devAdminEw11o##@'}
    URL = "https://api-dev.medvantxos.com"
    api = APIInterface(URL)
    post_url = api.compose_url(uri=['signin'])
    post_response = api.perform_api_request(method='POST', url=post_url, payload=creds)

    Authtoken = api.get_content()['access_token']
    from REST_API.medv_api.TenantResource import *

    tenant_o = TenantResource(request_url=URL, auth_token=Authtoken)
    print(tenant_o.get_all_tenants())
    tenant_details = tenant_o.get_tenant_by_name(name='pfizer')
    print("Tenant : {}".format(tenant_details))
    tenant_id = tenant_details['id']

    site_o = SiteResource(request_url=URL, auth_token=Authtoken, tenant_id=tenant_id)
    print(site_o.get_all_sites())

    site_details = site_o.get_site_by_domain(domain='testme')
    site_id = site_details['id']
    print(site_o.delete_site(site_id=site_id))
