from mailosaur import MailosaurClient
from mailosaur.models import SearchCriteria
from robot.api import logger
import pprint
import time
pp = pprint.PrettyPrinter(indent=4)


class Mailosaur(object):

    def __init__(self, api_key):
        self.client = MailosaurClient(api_key)
        self.email_list = dict()

    def generate_email_address(self, server_id):
        return self.client.servers.generate_email_address(server_id)

    def get_email_list(self, server_id, email_address):
        criteria = SearchCriteria()
        criteria.sent_to = email_address
        self.email_list = self.client.messages.search(server=server_id, criteria=criteria, timeout=100000)
        logger.info("Email list found")

    def check_welcome_email(self, server_id, email_address, patient_name):
        summary = " Hello {0}, Thank you for creating a new account! " \
                  "You may now use our handy online tools and in".format(patient_name)
        self.get_email_list(server_id, email_address)
        logger.info("Email List : {}".format(pp.pformat(self.email_list.items)))
        for email in self.email_list.items:
            logger.info("Comparing emails output : {0}".format(
                pp.pformat(email.subject)
            ))
            if email.subject == "Wecome To Medvantx" and summary in email.summary:
                return True
        return False

    def check_verify_email(self, server_id, email_address, patient_name):
        summary = " Hello {0}, Verify your email below Please confirm your " \
                  "email address to complete your account".format(patient_name)
        wait = 60
        while wait:
            self.get_email_list(server_id, email_address)
            logger.info("Email List : {}".format(pp.pformat(self.email_list.items)))
            if len(self.email_list.items) > 1:
                break
            wait = wait - 1
            time.sleep(2)

        for email in self.email_list.items:
            logger.info("Comparing emails subject : {0} - {1}".format(
                email.subject, email.summary))
            if email.subject == "Verify your email address" and summary in email.summary:
                return True
        return False

    def get_verification_token(self, server_id, email_address):
        message_id = None
        wait = 60
        while wait:
            self.get_email_list(server_id, email_address)
            logger.info("Email List : {}".format(pp.pformat(self.email_list.items)))
            if len(self.email_list.items) > 2:
                break
            wait = wait - 1
            time.sleep(2)
        for email in self.email_list.items:
            logger.info("Comparing emails output : {0}".format(
                pp.pformat(email.subject)
            ))
            if email.subject == "Verify your email address":
                message_id = email.id
        if not message_id:
            return False
        email_obj = self.client.messages.get_by_id(message_id)
        for link in email_obj.html.links:
            if link.text == "Verify My Email":
                token_link = link.href
        token = token_link.split("otc=")[1]
        return token


if __name__ == '__main__':
    mc = Mailosaur("Cw0bnKbM9HcGDOA")
    ve = mc.get_verification_token(server_id="rc2y5mmp", email_address="RI86RE3CQE.rc2y5mmp@mailosaur.io")
    print(ve)
