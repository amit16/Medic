from mailosaur import MailosaurClient
from mailosaur.models import SearchCriteria

class Mailosaur(object):
    def __init__(self, api_key):
        self.client = MailosaurClient(api_key)

    def generate_email_address(self, server_id):
        return self.client.servers.generate_email_address(server_id)

    def get_email(self, server_id, email_address):
        criteria = SearchCriteria()
        criteria.sent_to = email_address
        return self.client.messages.get(server_id, criteria)

    def subject_should_equal(self, message, expected):
        assert(message.subject == expected)