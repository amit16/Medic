import json
from robot.api import logger

file_path = "/Users/amit/PycharmProjects/Medic/Resources/config.json"


class SetupConfig:
    ROBOT_LIBRARY_SCOPE = 'GLOBAL'

    def __init__(self):
        self.common_database = dict()
        with open(file_path, 'r') as myfile:
            data = myfile.read()
        self.common_database = json.loads(data)
        logger.info("Setup JSON - \n{0}".format(json.dumps(self.common_database, indent=4, sort_keys=True)))

    def set_base_url(self):
        Base_URL = self.common_database.get("base_url")

    def get_patient_email(self):
        patient_details = self.common_database.get("patient_details")
        return patient_details.get("username")

    def get_patient_password(self):
        patient_details = self.common_database.get("patient_details")
        return patient_details.get("password")

    def get_domain(self):
        return self.common_database.get("domain")

    def get_tenant(self):
        return self.common_database.get("tenant")

    def get_drug_ndc(self):
        return self.common_database.get("drug_ndc")

