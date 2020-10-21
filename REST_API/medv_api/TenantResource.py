from REST_API.base_classes.APIInterface import *


class TenantResource(APIInterface):
    """Create New Tenant

    POST {{login_base_url}}/iapi/v1.0/tenant
    """

    def __init__(self, request_url, auth_token, name=None, store_id=None, enabled=True):
        self.resource = 'tenant'
        self.request_url = request_url
        self.auth_token = auth_token
        self.name = name
        self.store_id = store_id
        self.enabled = enabled
        self.api = APIInterface(self.request_url)

    def get_all_tenants(self):
        get_url = self.api.compose_url(level='iapi', uri=[self.resource + 's'])
        self.api.perform_api_request(method='GET', url=get_url, auth_token=self.auth_token)
        get_response = self.api.get_content()
        return get_response

    def get_tenant_by_name(self, name=None):
        all_tenant = self.get_all_tenants()
        for tenant in all_tenant:
            if tenant['name'] == name:
                return tenant
        return False


if __name__ == '__main__':
    ''' Unit Test '''
    creds = {'username': 'default-superuser@medvantx.com', 'password': 'devAdminEw11o##@'}
    URL = "https://api-dev.medvantxos.com"
    api = APIInterface(URL)
    post_url = api.compose_url(uri=['signin'])
    post_response = api.perform_api_request(method='POST', url=post_url, payload=creds)

    Authtoken = api.get_content()['access_token']
    tenant_o = TenantResource(request_url=URL, auth_token=Authtoken)
    print(tenant_o.get_all_tenant())
    print(tenant_o.get_tenant_by_name(name='AbhishekTenant'))