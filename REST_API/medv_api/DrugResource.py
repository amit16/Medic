from REST_API.base_classes.APIInterface import *


class DrugResource(APIInterface):
    """Drug/Product API Resource

    POST /iapi/v1.0/tenant/{tenant_id}/drug
    GET  /iapi/v1.0/tenant/{tenant_id}/drugs
    PUT  /iapi/v1.0/tenant/{tenant_id}/drug/{drug_id}
    DEL  /iapi/v1.0/tenant/{tenant_id}/drug/{drug_id}
    """

    def __init__(self, request_url, auth_token, tenant_id, ndc=None, name=None, description=None, brand_name=None,
                 image_url=None, active_ingredient=None, strength=None, quantity=None, price=None, pack_form=None,
                 pack_size=None, labeler_name=None, group_id=None, gcn=None,
                 route=None, type=None, active=None):
        self.resource = 'drug'
        self.request_url = request_url
        self.auth_token = auth_token

        self.tenant_id = tenant_id
        self.ndc = ndc
        self.name = name
        self.description = description
        self.brand_name = brand_name
        self.image_url = image_url
        self.active_ingredient = active_ingredient
        self.strength = strength
        self.quantity = quantity
        self.price = price
        self.pack_form = pack_form
        self.pack_size = pack_size
        self.labeler_name = labeler_name
        self.group_id = group_id
        self.gcn = gcn
        self.route = route
        self.type = type
        self.active = active
        self.api = APIInterface(self.request_url)

    def create_drug(self, payload_data=None):
        drug_uri = ['tenant', self.tenant_id, self.resource]
        post_data = parse_data(payload_data)

        post_url = self.api.compose_url(level='iapi', uri=drug_uri)
        self.api.perform_api_request(method='POST', url=post_url, payload=post_data, auth_token=self.auth_token)
        return self.api

    def update_drug(self, drug_name=None, drug_id=None, payload_data=None):
        if not drug_id:
            drug_d = self.get_drug_by_name(drug_name)
            drug_id = drug_d["id"]
        drug_uri = ['tenant', self.tenant_id, self.resource, drug_id]
        put_data = parse_data(payload_data)

        put_url = self.api.compose_url(level='iapi', uri=drug_uri)
        self.api.perform_api_request(method='PUT', url=put_url, payload=put_data, auth_token=self.auth_token)
        return self.api

    def get_all_drugs(self):
        drug_uri = ['tenant', self.tenant_id, self.resource + 's']
        get_url = self.api.compose_url(level='iapi', uri=drug_uri)
        self.api.perform_api_request(method='GET', url=get_url, auth_token=self.auth_token)
        return self.api

    def get_drug_by_id(self, drug_id):
        drug_uri = ['tenant', self.tenant_id, self.resource, drug_id]
        get_url = self.api.compose_url(level='iapi', uri=drug_uri)
        self.api.perform_api_request(method='GET', url=get_url, auth_token=self.auth_token)
        return self.api

    def get_drug_by_name(self, name=None):
        all_drug = self.get_all_drugs()
        for drug in all_drug.get_content():
            if drug['name'] == name:
                return drug
        return False

    def delete_drug(self, drug_name=None, drug_id=None):
        if not drug_id:
            drug_d = self.get_drug_by_name(drug_name)
            if not drug_d:
                return False
            drug_id = drug_d["id"]
        drug_uri = ['tenant', self.tenant_id, self.resource, drug_id]
        del_url = self.api.compose_url(level='iapi', uri=drug_uri)
        self.api.perform_api_request(method='DELETE', url=del_url, auth_token=self.auth_token)
        return self.api


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

    drug_o = DrugResource(request_url=URL, auth_token=Authtoken, tenant_id=tenant_id)
    print(drug_o.get_all_drugs())

    new_drug = drug_o.delete_drug(drug_name='TestDrug_Updated')
    print(new_drug)
