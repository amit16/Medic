import yaml
import logging as logger


file_path = "/Users/amit/PycharmProjects/Medic/REST_API/conf/config.yaml"


class TestBed:
    def __init__(self):
        self.common_database = dict()
        with open(file_path, 'r') as myfile:
            data = yaml.safe_load(myfile)
        self.common_database = data
        logger.info("Setup YAML - \n{0}".format(yaml.dump(self.common_database,
                                                          default_flow_style=False,
                                                          allow_unicode=True)))

    def get_base_url(self):
        url = self.common_database["base"]["api_url"]
        return url

    def get_credentials(self, user):
        if user == "patient":
            patient_credentials = self.common_database["credentials"]["patient"]
            return patient_credentials

        if user == "tenant_admin":
            tenant_admin_credentials = self.common_database["credentials"]["tenant_admin"]
            return tenant_admin_credentials

        if user == "superuser":
            superuser_credentials = self.common_database["credentials"]["superuser"]
            return superuser_credentials

    def get_domain(self):
        return self.common_database.get("site")

    def get_tenant(self):
        return self.common_database.get("tenant")

    def get_drug_ndc(self):
        drug = self.common_database.get("drug")
        return drug["ndc"]

