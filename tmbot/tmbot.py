#!/usr/bin/env python

# Demo web monitoring bot for Telegram
# author: Anton Dmitrenok <avdmitrenok@gmail.com>

import configparser
import requests
import argparse
import daemon
import time
import sys
import os

# Suppress https cert check warnings
import urllib3
urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)

DEFAULT_CONFIG_FNAME = "tmbot.cfg"
DEFAULT_CHECK_TRESHOLD = 1 # sec
DEFAULT_API_URL = "https://api.telegram.org"
DEFAULT_HOST_CHECK_INTERVAL = 1 # sec

CHECK_REQUEST_TIMEOUT = 5 # sec

MSG_ON_CONNECT = "monitoring up"
MSG_ON_FAILURE = "{} is broken {} not found"
MSG_ON_RESTORE = "{} is OK"

class TMBot:

    def __init__(self, token, channel_id, check_url, check_string):
        self.bot_token = token
        self.bot_api_url = DEFAULT_API_URL + "/bot{}/".format(token)
        self.bot_channel_id = channel_id
        self.check_url = check_url
        self.check_string = check_string
        self.check_treshold = DEFAULT_CHECK_TRESHOLD
        self.check_state_ok = None
        self.host_check_interval = DEFAULT_HOST_CHECK_INTERVAL

    def __check_host(self):
        try:
            resp = requests.get(self.check_url, verify=False, timeout=CHECK_REQUEST_TIMEOUT)
            if resp.status_code == 200:
                if self.check_string in resp.text:
                    return True
        except:
            pass
        return False

    def __send_message(self, message):
        params = {'chat_id': self.bot_channel_id, 'text': message}
        resp = requests.post(self.bot_api_url + "sendMessage", params)

    def run(self):
        self.__send_message(MSG_ON_CONNECT)
        while True:
            if self.__check_host():
                if self.check_state_ok is None or not self.check_state_ok:
                    self.__send_message(MSG_ON_RESTORE.format(self.check_url))
                    self.check_state_ok = True
            else:
                if self.check_state_ok is None or self.check_state_ok:
                    self.__send_message(MSG_ON_FAILURE.format(self.check_url, self.check_string))
                    self.check_state_ok = False
            time.sleep(self.host_check_interval)

def main(argv):
    arg_parser = argparse.ArgumentParser(formatter_class=argparse.ArgumentDefaultsHelpFormatter)
    arg_parser.add_argument("-c", "--config-file", default=DEFAULT_CONFIG_FNAME, required=False, help="Configuration file")
    args = arg_parser.parse_args(argv)

    if not os.path.exists(args.config_file):
        print("ERROR: Config file not found", file=sys.stderr)
        sys.exit(255)
    config = configparser.ConfigParser()
    config.read(args.config_file)
    try:
        config_params = [config['MAIN'][param_name] for param_name in ['token', 'channel_id', 'check_url', 'check_string']]
    except KeyError as err:
        print("ERROR: Config parameter {} not found".format(str(err)), file=sys.stderr)
        sys.exit(254)
    
    with daemon.DaemonContext():
        TMBot(*config_params).run()

if __name__ == "__main__":
    main(sys.argv[1:])
