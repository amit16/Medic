

import os
import re
import json
import time
import unittest
import logging as logger
import requests
from urllib.error import HTTPError
from urllib.error import URLError
##adding this disable warning displayed
requests.packages.urllib3.disable_warnings()


def post(url, data=None, **kwargs):
    """Create method which is wraper around requests.posts
       Args:
         url:      URL for the new Request post
         data:     Dictionary object to send in the body of requests.post
         **kwargs: Optional arguments that request takes, plus
                   - AUTH_TOKEN
    """
    logger.info("RestApi Create")
    json_response = None
    error = {}

    cookie = {}
    # Define the post header
    headers = {}
    headers["Accept"] = 'application/json'

    auth_token = kwargs.get('auth_token', None)
    if auth_token:
        headers["Authorization"] = "Bearer %s" % auth_token

    origin = kwargs.get('origin', None)
    if origin:
        headers["origin"] = origin

    content_type = kwargs.get('content_type', None)
    if content_type:
        headers['Content-type'] = content_type
    else:
        if data:
            headers['Content-type'] = 'application/json'

    try:
        logger.info('post requests url: %s' % url)
        logger.info('post requests headers: %s' % headers)
        logger.info('post requests data: %s' % data)
        logger.info('post requests cookie: %s' % cookie)
        # Post the request
        response = requests.post(url=url,
                                 headers=headers,
                                 data=data, cookies=cookie,
                                 verify=False, stream=True)
        try:
            json_response = response.json()
        except:
            json_response = None

        # Process response
        logger.info(
            'post response status_code: %s' % response.status_code)
        logger.info('post response url:         %s' % response.url)
        if response.headers:
            logger.info('post response headers: %s' % response.headers)
    except (HTTPError, URLError) as e:
        error = e
        if isinstance(e, HTTPError):
            error_message = e.read()
            print("\n******\nPOST Error: %s %s" %
                  (url, error_message))
        elif e.reason.args[0] == 10061:
            print(
                "\033[1;31m\nURL open error: Please check if the API server is up or URL access issue\033[1;m")
        else:
            print(e.reason.args)
        raise e  # We raise error only when unknown errors occurs (other than HTTP error and url open error 10061)
    except Exception as e:
        msg = 'RestApiException: post request error: %s' % (e)
        logger.error(msg)
        json_response = None

    return {'response': response.status_code, 'text': response.text, 'json_response': json_response, 'error': error}


def get(url, **kwargs):
    """Get method which is wraper around requests.get
       Args:
         url:      URL for the new Request post
         **kwargs: Optional arguments that request takes, plus
                   - AUTH_TOKEN
    """
    logger.info("RestApi Read")
    json_response = None
    error = {}

    cookie = {}
    # Define the post header
    headers = {}
    headers["Accept"] = 'application/json'

    auth_token = kwargs.get('auth_token', None)
    if auth_token:
        headers["Authorization"] = "Bearer %s" % auth_token

    origin = kwargs.get('origin', None)
    if origin:
        headers["origin"] = origin

    try:
        logger.debug('get requests url: %s' % url)
        logger.debug('get requests headers: %s' % headers)
        logger.debug('get requests cookie: %s' % cookie)

        # Post the request
        response = requests.get(url=url,
                                headers=headers, cookies=cookie,
                                verify=False, stream=True)
        try:
            json_response = response.json()
        except:
            json_response = None

        # Process response
        logger.debug('get response status_code: %s' % response.status_code)
        logger.debug('get response url:         %s' % response.url)
        if response.headers:
            logger.debug('get response headers: %s' % response.headers)
    except (HTTPError, URLError) as e:
        error = e
        if isinstance(e, HTTPError):
            error_message = e.read()
            print("\n******\nGET Error: %s %s" %
                  (url, error_message))
        elif e.reason.args[0] == 10061:
            print(
                "\033[1;31m\nURL open error: Please check if the API server is up or URL access issue\033[1;m")
        else:
            print(e.reason.args)
        raise e  # We raise error only when unknown errors occurs (other than HTTP error and url open error 10061)
    except Exception as e:
        msg = 'RestApiException: get request error: %s' % (e)
        logger.error(msg)
        json_response = None

    return {'response': response.status_code, 'text': response.text, 'json_response': json_response, 'error': error}


def put(url, data=None, **kwargs):
    """Create method which is wraper around requests.posts
       Args:
         url:      URL for the new Request post
         data:     Dictionary object to send in the body of requests.post
         **kwargs: Optional arguments that request takes, plus
                   - AUTH_TOKEN
    """
    logger.info("RestApi update")

    cookie = {}
    json_response = None
    error = {}

    # Define the post header
    headers = {}
    headers["Accept"] = 'application/json'

    auth_token = kwargs.get('auth_token', None)
    if auth_token:
        headers["Authorization"] = "Bearer %s" % auth_token

    origin = kwargs.get('origin', None)
    if origin:
        headers["origin"] = origin

    # Adding the != None check for appdef change in 4.5.1
    if data != None:
        headers['Content-type'] = 'application/json'

    try:
        logger.debug('put requests url: %s' % url)
        logger.debug('put requests headers: %s' % headers)
        logger.debug('put requests data: %s' % data)
        logger.debug('put requests cookie: %s' % cookie)
        # Post the request
        response = requests.put(url=url,
                                headers=headers,
                                data=data, cookies=cookie,
                                verify=False, stream=True)
        try:
            json_response = response.json()
        except:
            json_response = None

        # Process response
        logger.debug('put response status_code: %s' % response.status_code)
        logger.debug('put response url:         %s' % response.url)
        if response.headers:
            logger.debug('put response headers: %s' % response.headers)
    except (HTTPError, URLError) as e:
        error = e
        if isinstance(e, HTTPError):
            error_message = e.read()
            print("\n******\nPUT Error: %s %s" %
                  (url, error_message))
        elif e.reason.args[0] == 10061:
            print(
                "\033[1;31m\nURL open error: Please check if the API server is up or URL access issue\033[1;m")
        else:
            print(e.reason.args)
        raise e  # We raise error only when unknown errors occurs (other than HTTP error and url open error 10061)
    except Exception as e:
        msg = 'RestApiException: put request error: %s' % (e)
        logger.error(msg)
        json_response = None

    return {'response': response.status_code, 'text': response.text, 'json_response': json_response, 'error': error}


def delete(url, **kwargs):
    """Create method which is wraper around requests.posts
       Args:
         url:      URL for the new Request post
         **kwargs: Optional arguments that request takes, plus
                   - AUTH_TOKEN
    """
    logger.info("RestApi Create")

    cookie = {}
    json_response = None
    error = {}

    # Define the post header
    headers = {}
    headers["Accept"] = 'application/json'

    auth_token = kwargs.get('auth_token', None)
    if auth_token:
        headers["Authorization"] = "Bearer %s" % auth_token

    origin = kwargs.get('origin', None)
    if origin:
        headers["origin"] = origin

    try:
        logger.debug('delete requests url: %s' % url)
        logger.debug('delete requests headers: %s' % headers)
        # logger.debug('delete requests data: %s' %data)
        logger.debug('delete requests cookie: %s' % cookie)
        # Post the request
        response = requests.delete(url=url,
                                   headers=headers, cookies=cookie,
                                   verify=False, stream=True)
        try:
            json_response = response.json()
        except:
            json_response = None

        # Process response
        logger.debug(
            'delete response status_code: %s' % response.status_code)
    except (HTTPError, URLError) as e:
        error = e
        if isinstance(e, HTTPError):
            error_message = e.read()
            print("\n******\nPUT Error: %s %s" %
                  (url, error_message))
        elif e.reason.args[0] == 10061:
            print(
                "\033[1;31m\nURL open error: Please check if the API server is up or URL access issue\033[1;m")
        else:
            print(e.reason.args)
        raise e  # We raise error only when unknown errors occurs (other than HTTP error and url open error 10061)
    except Exception as e:
        msg = 'RestApiException: put request error: %s' % (e)
        logger.error(msg)
        json_response = None

    return {'response': response.status_code, 'text': response.text, 'json_response': json_response, 'error': error}


if __name__ == '__main__':
    ''' Unit Test '''
    payload = {'username': 'default-superuser@medvantx.com', 'password': 'devAdminEw11o##@'}
    data = json.dumps(payload)
    url = "https://api-dev.medvantxos.com/api/v1.0/signin"
    post_response = post(url=url, data=data, origin='https://api-dev.medvantxos.com')
    import pdb; pdb.set_trace()
    auth_token = post_response['json_response']['access_token']

    get_response = get(url="https://api-dev.medvantxos.com/api/v1.0/profile", auth_token=auth_token)


