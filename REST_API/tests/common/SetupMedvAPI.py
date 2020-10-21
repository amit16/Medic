from REST_API.utils.TestBed import *
from REST_API.base_classes.APIInterface import *


class SetupMedvAPI:

    def __init__(self):
        self.testbed_o = TestBed()
        self.url = self.testbed_o.get_base_url()
        self.api_interface_o = APIInterface(self.url)
        self.auth_token = None
        self.tenant_id = None

    def get_api_url(self):
        return self.url

    def get_auth_token(self, user):
        creds = self.testbed_o.get_credentials(user)
        login_url = self.api_interface_o.compose_url(uri=['signin'])
        self.api_interface_o.perform_api_request(method='POST', url=login_url, payload=creds)
        self.auth_token = self.api_interface_o.get_content()['access_token']
        return self.auth_token

    def get_tenant_id(self):
        profile_url = self.api_interface_o.compose_url(uri=['profile'])
        self.api_interface_o.perform_api_request(method='GET', auth_token=self.auth_token, url=profile_url)
        self.tenant_id = self.api_interface_o.get_content()["tenantId"]
        return self.tenant_id

    def get_drug_ndc(self):
        return self.testbed_o.get_drug_ndc()
