#! /usr/bin/env python
import datetime, time
import random
from collections import OrderedDict
from deepdiff import DeepDiff
import collections
from robot.api import logger
import pprint
import string
pp = pprint.PrettyPrinter(indent=4)

def convert_unicode_to_string(data):
    if isinstance(data, basestring):
        return str(data)
    elif isinstance(data, collections.Mapping):
        return dict(map(convert_unicode_to_string, data.iteritems()))
    elif isinstance(data, collections.Iterable):
        return type(data)(map(convert_unicode_to_string, data))
    else:
        return data

def search_key_in_list_of_dictionary(key_to_search, value, dict1):
    for item in dict1:
        if item[key_to_search] == value:
            return True
    return False

def dictionary_search_list(key_to_search, dict1):
    data_l = []
    for key, value in dict1.items():
        if key == key_to_search:
            data_l.append(value)
        elif isinstance(value, collections.Mapping):
            rec_value_l = dictionary_search_list(key_to_search, value)
            for rec_value in rec_value_l:
                data_l.append(rec_value)
        elif isinstance(value, collections.Iterable):
            for item in value:
                if isinstance(item, collections.Mapping):
                    rec_item_val_l = dictionary_search_list(key_to_search, item)
                    for rec_item in rec_item_val_l:
                        data_l.append(rec_item)
    return data_l


def dictionary_search(key_to_search, dictionary):
    data = dictionary_search_list(key_to_search, dictionary)
    data_len = len(data)
    if data_len == 0:
        return None
    elif data_len == 1:
        return data[0]
    else:
        return data

def compare_dicts(expected_d, actual_d, ignore_key='id', count=False):
    logger.info('The expected dictionary is {} \n'.format(expected_d))
    logger.info('The actual dictionary is {} \n'.format(actual_d))
    if ignore_key in actual_d:
        actual_d.pop(ignore_key)
    result_flag = True
    result_diff = DeepDiff(expected_d, actual_d, ignore_order=True, report_repetition=True)
    if not result_diff:
        logger.info("PASS: Both the expected and actual dictionaries are same.")
    else:
        result_flag = False
        logger.info('Error: The following values are different in both dictionaries \n'
                        '{} \n'.format(pp.pformat(result_diff)))
    return result_flag


def compare_lists(expected_l, actual_l, count=False):
    """
    Description:
        This funciton compares two lists and fails if different. On failure,
        it prints the values that are different incluiding the duplicates.
    :param Count:
        Verifies only the count of lists
    :return:
        True/False
    """
    logger.debug('The expected list is {} \n'.format(expected_l))
    logger.debug('The actual list is {} \n'.format(actual_l))
    result_flag = True

    if not count:
        expected_counter = collections.Counter(expected_l)
        actual_counter = collections.Counter(actual_l)
        added = expected_counter - actual_counter
        removed = actual_counter - expected_counter
        if added:
            logger.info("Error: The following values are not found in actual list {}".format(
                pp.pformat(list(added.elements()))
            ))
            result_flag = False
        if removed:
            logger.info("Error: The following values are additionally present in actual list {}".format(
                pp.pformat(list(removed.elements()))
            ))
            result_flag = False
        if result_flag:
            logger.info("PASS: Both the expected and actual lists are same.")
    else:

        if len(expected_l) != len(actual_l):
            logger.info("Error: The following lists counts are different 'expected-{} actual-{}'".format(
                len(expected_l), len(actual_l)
            ))
            result_flag = False
        if result_flag:
            logger.debug("PASS: Both the expected and actual lists count are same.")

    return result_flag


def banner(text, ch='=', length=120):
    """Print Banner"""
    spaced_text = ' %s ' % text
    banner = spaced_text.center(length, ch)
    return banner


def keys_exists(element, *keys):
    '''
    Check if *keys (nested) exists in `element` (dict).
    '''
    if type(element) is not dict and type(element) is not OrderedDict:
        raise AttributeError('keys_exists() expects dict as first argument.')
    if len(keys) == 0:
        raise AttributeError('keys_exists() expects at least two arguments, one given.')

    _element = element
    for key in keys:
        try:
            _element = _element[key]
        except KeyError:
            return False
    return True


def dict_key_exist(d1, d2, compare_keys):
    if compare_keys[0] not in d1.keys() or compare_keys[0] not in d2.keys():
        return False
    else:
        if len(compare_keys) > 1:
            if type(d1.get(compare_keys[0])) is dict and type(d2.get(compare_keys[0])) is dict:
                return dict_key_exist(d1.get(compare_keys[0]), d2.get(compare_keys[0]), compare_keys[1:])
            else:
                return False
    return True


def key_exist(d1, compare_keys):
    """
    Check if *keys (nested) exists in `d1` (dict).
    """
    if compare_keys[0] not in d1.keys():
        return False
    else:
        if len(compare_keys) > 1:
            if type(d1.get(compare_keys[0])) is dict:
                return __key_exist(d1.get(compare_keys[0]), compare_keys[1:])
            else:
                return False
    return True


def random_billing_id(length_of_string=5):
    """
    Generates a random five-digit number
    """
    N = length_of_string
    billing_id = ''.join(random.choices(string.ascii_uppercase + string.digits, k=N))
    return billing_id


def random_patient_name():
    """Generates a randome name"""
    rand_str = ''.join(random.choices(string.ascii_uppercase, k=2))
    return 'AutoQA' + rand_str


def year_start(year):
    return time.mktime(datetime.date(year, 1, 1).timetuple())


def random_birth_date(year=1985):
    """Generates a randome date between 1985 to 1995"""
    stamp = random.randrange(year_start(year), year_start(year + 10))
    return datetime.date.fromtimestamp(stamp).strftime('%d-%m-%Y')


def check_response_type(data, expected_type):
    """
    Check input data's type
    """
    if expected_type == 'list':
        return isinstance(data, list)
    elif expected_type == 'dict':
        return isinstance(data, dict)
    elif expected_type == 'str':
        return isinstance(data, str)
    else:
        return False
