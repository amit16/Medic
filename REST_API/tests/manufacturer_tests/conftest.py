import pytest

from REST_API.tests.common.SetupMedvAPI import SetupMedvAPI


medv_api_o = SetupMedvAPI()


@pytest.fixture(scope='session')
def auth_token():
    return medv_api_o.get_auth_token("tenant_admin")


@pytest.fixture(scope='session')
def tenant_id():
    return medv_api_o.get_tenant_id()


@pytest.fixture(scope='session')
def url():
    return medv_api_o.get_api_url()


@pytest.fixture(scope='session')
def ndc():
    return medv_api_o.get_drug_ndc()