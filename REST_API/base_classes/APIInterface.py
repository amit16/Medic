'''
Created on Sept 20, 2020

@author: amit
'''
import os
import re
from typing import Dict, Any, Union

import yaml
import json
import logging
import inspect
import time

from REST_API.base_classes.constants import *

logger = logging.getLogger('Library')
logfile = os.path.join(os.path.dirname(os.path.realpath(__file__)), os.path.basename(__file__) + '.log')
logging.basicConfig(filename=logfile, level=logging.DEBUG)


class APIInterface(RestApi):
    api_response: Dict[str, Union[Union[str, None, Dict[Any, Any]], Any]]

    def __init__(self, base_url=None):
        self.BaseURL = base_url

    def perform_api_request(self, method, url, payload=None, **kwargs):
        """Performs the API request : POST, GET, PUT, DEL
        :param method:
        :param url:
        :param payload:
        :return:
        response
        """
        if 'signin' in url:
            username = payload.get("username")
            password = payload.get("password")
            payload = self.get_signin_data(username, password)
        self.api_obj = RestApi()
        if method == 'POST':
            self.api_response = self.api_obj.post(url=url, data=payload, **kwargs)
        elif method == 'GET':
            self.api_response = self.api_obj.get(url=url, **kwargs)
        elif method == 'PUT':
            self.api_response = self.api_obj.put(url=url, data=payload, **kwargs)
        elif method == 'DELETE':
            self.api_response = self.api_obj.delete(url=url, **kwargs)
        return self.api_response

    def get_signin_data(self, username, password):
        """ Get user credentials in json
        :param username:
        :param password:
        :return:
        credentials in json dump - login_data
        """
        credentials = {'username': username, 'password': password}
        login_data = json.dumps(credentials)
        return login_data

    def compose_url(self, version='v1.0', level='api', uri=None):
        """ Composes the URL for the REST API call
        Args:
           uri : list of resource to be suffixed to the base URL
           version : API version
           level : api or iapi
        Returns:
           (request_url)
           status_code: Returns the request_url for the REST call
        """
        request_url = self.BaseURL + '/' + level + '/' + version
        for resource in uri:
            request_url = request_url + '/' + resource
        return request_url

    def get_status(self):
        """ Gets the status_code of the last REST API call
        Args:
           None
        Returns:
           status_code: Returns the status_code for the last REST call
        """
        return self.api_response.get('response')

    def get_content(self):
        """ Gets the content of the last REST API call
        Args:
           None
        Returns:
           content: Returns the content for the last REST call
                    (response.json())
        """
        try:
            return self.api_response.get('json_response')
        except ValueError:
            return None

    def get_request(self):
        """ Gets the request of the last REST API call
        Args:
           None
        Returns:
           request: Returns the request details for the last REST call
                    (request.json())
        """
        try:
            return self.api_obj.get_request()
        except ValueError:
            return None


if __name__ == '__main__':
    ''' Unit Test '''
    creds = {'username': 'default-superuser@medvantx.com', 'password': 'devAdminEw11o##@'}
    URL = "https://api-dev.medvantxos.com"
    api = APIInterface(URL)
    post_url = api.compose_url(uri=['signin'])
    post_response = api.perform_api_request(method='POST', url=post_url, payload=creds)

    Authtoken = api.get_content()['access_token']
    profile_url = api.compose_url(uri=['profile'])
    get_response = api.perform_api_request(method='GET', url=profile_url, auth_token=Authtoken)