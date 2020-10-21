import copy
import os
import pytest
import logging as logger

from REST_API.medv_api.DrugResource import DrugResource
import REST_API.tests.manufacturer_tests.api_tests.drug_api_data as drug_conf
from REST_API.utils.HelperModule import *


@pytest.mark.manufacturer_api
class TestDrugAPI:

    def test_setup(self, url, auth_token, tenant_id):
        logger.info("Starting Setup for : {} execution".format(self.__class__.__name__))
        drug_o = DrugResource(request_url=url,
                              auth_token=auth_token,
                              tenant_id=tenant_id)
        drug_payload = drug_conf.drug_create_data
        post_response = drug_o.create_drug(drug_payload)
        assert post_response.get_status() == 200
        drug = drug_o.get_drug_by_name(drug_conf.drug_create_data["name"])
        drug_id = drug["id"]
        drug_conf.drug_create_data["id"] = drug_id

    def test_get_all_drugs(self, url, auth_token, tenant_id):
        drug_o = DrugResource(request_url=url,
                              auth_token=auth_token,
                              tenant_id=tenant_id)
        get_response = drug_o.get_all_drugs()
        assert get_response.get_status() == 200
        response_type = check_response_type(get_response.get_content(), "list")
        assert response_type is True

    def test_get_specific_drug(self, url, auth_token, tenant_id):
        drug_o = DrugResource(request_url=url,
                              auth_token=auth_token,
                              tenant_id=tenant_id)
        specific_drug_id = drug_conf.drug_create_data["id"]
        get_response = drug_o.get_drug_by_id(specific_drug_id)
        assert get_response.get_status() == 200

    def test_create_drug(self, url, auth_token, tenant_id, ndc):
        drug_o = DrugResource(request_url=url,
                              auth_token=auth_token,
                              tenant_id=tenant_id)
        all_drugs = drug_o.get_all_drugs()
        specific_drug_d = all_drugs.get_content()[0]
        specific_drug_d["name"] = "New_Drug"
        specific_drug_d["ndc"] = ndc
        post_response = drug_o.create_drug(specific_drug_d)
        assert post_response.get_status() == 200
        request_data = post_response.get_content()
        specific_drug_id = post_response.get_id()
        response_verification = compare_dicts(expected_d=specific_drug_d,
                                              actual_d=request_data,
                                              ignore_key=['id', 'dateCreated', 'dateModified', 'tenantId'])
        assert response_verification is True
        get_response = drug_o.get_drug_by_id(specific_drug_id)
        assert get_response.get_status() == 200

    def test_create_drug_with_existing_ndc(self, url, auth_token, tenant_id, ndc):
        drug_o = DrugResource(request_url=url,
                              auth_token=auth_token,
                              tenant_id=tenant_id)
        all_drugs = drug_o.get_all_drugs()
        specific_drug_d = all_drugs.get_content()[0]
        specific_drug_d["name"] = "Existing_Drug"
        specific_drug_d["ndc"] = ndc
        post_response = drug_o.create_drug(specific_drug_d)
        assert post_response.get_status() == 400

    def test_delete_drug(self, url, auth_token, tenant_id):
        drug_o = DrugResource(request_url=url,
                              auth_token=auth_token,
                              tenant_id=tenant_id)
        del_response = drug_o.delete_drug(drug_name="New_Drug")
        assert del_response.get_status() == 200

    def test_delete_non_existent_drug(self, url, auth_token, tenant_id):
        drug_o = DrugResource(request_url=url,
                              auth_token=auth_token,
                              tenant_id=tenant_id)
        del_response = drug_o.delete_drug(drug_id="4bf7dba0-23a8-40ce-a7dd-4f5e757c6d93")
        assert del_response.get_status() == 404

    def test_create_drug_with_existing_name(self, url, auth_token, tenant_id):
        drug_o = DrugResource(request_url=url,
                              auth_token=auth_token,
                              tenant_id=tenant_id)
        all_drugs = drug_o.get_all_drugs()
        specific_drug_d = all_drugs.get_content()[0]
        specific_drug_d["name"] = "New_Drug"
        specific_drug_d["ndc"] = "00023361607"
        post_response = drug_o.create_drug(specific_drug_d)
        assert post_response.get_status() == 200
        response_verification = compare_dicts(expected_d=specific_drug_d,
                                              actual_d=post_response.get_content(),
                                              ignore_key=['id', 'dateCreated', 'dateModified', 'tenantId'])
        assert response_verification is True

        # Cleanup the created Drug
        del_response = drug_o.delete_drug(drug_name="New_Drug")
        assert del_response.get_status() == 200

    @pytest.mark.parametrize("update_param, expected_repsonse", [
            ("name", 200),
            ("ndc", 200),
            ("description", 200),
            ("brandName", 200),
            ("activeIngredient", 200),
            ("strength", 200),
            ("quantity", 200),
            ("price", 200),
            ("packSize", 200),
            ("labelerName", 200),
            ("route", 200),
            ("termsAndConditions", 200),
            ("prescriberInformation", 200)
            ])
    def test_update_drug_name(self, url, auth_token, tenant_id, update_param, expected_repsonse):
        drug_o = DrugResource(request_url=url,
                              auth_token=auth_token,
                              tenant_id=tenant_id)
        drug_id = drug_conf.drug_create_data["id"]
        drug_payload = copy.deepcopy(drug_conf.drug_create_data)
        drug_payload[update_param] = drug_conf.drug_update_data[update_param]
        put_response = drug_o.update_drug(payload_data=drug_payload, drug_id=drug_id)

        out_response = put_response.get_content()
        assert put_response.get_status() == expected_repsonse
        assert out_response[update_param] == drug_conf.drug_update_data[update_param]

    def test_teardown(self, url, auth_token, tenant_id):
        logger.info("Starting Cleanup for : {} execution".format(self.__class__.__name__))
        drug_o = DrugResource(request_url=url,
                              auth_token=auth_token,
                              tenant_id=tenant_id)

        # Cleanup the created Drug
        drug_payload = copy.deepcopy(drug_conf.drug_create_data)
        update_response = drug_o.update_drug(drug_name=drug_conf.drug_create_data["name"], payload_data=drug_payload)
        assert update_response.get_status() == 200
        del_response = drug_o.delete_drug(drug_conf.drug_create_data["name"])
        assert del_response.get_status() == 200
