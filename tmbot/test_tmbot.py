#!/usr/bin/env python

import unittest
from unittest.mock import patch
from tmbot import TMBot

TEST_TOKEN = "123456789:ABCDEFGHIJKLMNOPQRSTUVWXYZ"
TEST_CHANNEL_ID = "@abcdefgh12345"
TEST_CHECK_URL = "http://server.domain.com"
TEST_CHECK_STRING = "GOOD_TEST_STRING"
TEST_URL = "https://api.telegram.org/bot{}/sendMessage".format(TEST_TOKEN)

MOCK_OK_CHECK_ANSWER = """
<html>
    <body>
        <h1>GOOD_TEST_STRING</h1>
    </body>
</html>
"""
MOCK_ERR_CHECK_ANSWER = """
<html>
    <body>
        <h1>WRONG_TEST_STRING</h1>
    </body>
</html>
"""

class FakeResponse:
    def __init__(self, text, status_code):
        self.text = text
        self.status_code = status_code

    def text(self):
        return self.text

    def status_code(self):
        return self.status_code

class TestPostData:
    def __init__(self, post_data):
        self.post_data = post_data
        self.data_num = -1

    def get_data(self):
        self.data_num += 1
        return self.post_data[self.data_num]

def fakeSleep(t):
    raise InterruptedError()

@patch("time.sleep", new=fakeSleep)
class TestTMBot(unittest.TestCase):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.test = "TEST OK"

    def test_checkError(self):
        test_data = [
            {'chat_id': TEST_CHANNEL_ID, 'text': 'monitoring up'},
            {'chat_id': TEST_CHANNEL_ID, 'text': '{} is broken {} not found'.format(TEST_CHECK_URL, TEST_CHECK_STRING)}
        ]
        test_post_data = TestPostData(test_data)

        def fake_post(url, data):
            self.assertEqual(url, TEST_URL)
            self.assertEqual(data, test_post_data.get_data())

        def fake_get(url, **kwargs):
            return FakeResponse(MOCK_ERR_CHECK_ANSWER, 200)

        try:
            with patch("requests.post", fake_post), patch("requests.get", fake_get):
                TMBot(TEST_TOKEN, TEST_CHANNEL_ID, TEST_CHECK_URL, TEST_CHECK_STRING).run()
        except InterruptedError:
            pass

    def test_checkOK(self):
        test_data = [
            {'chat_id': TEST_CHANNEL_ID, 'text': 'monitoring up'},
            {'chat_id': TEST_CHANNEL_ID, 'text': '{} is OK'.format(TEST_CHECK_URL)}
        ]
        test_post_data = TestPostData(test_data)

        def fake_post(url, data):
            self.assertEqual(url, TEST_URL)
            self.assertEqual(data, test_post_data.get_data())

        def fake_get(url, **kwargs):
            return FakeResponse(MOCK_OK_CHECK_ANSWER, 200)

        try:
            with patch("requests.post", fake_post), patch("requests.get", fake_get):
                TMBot(TEST_TOKEN, TEST_CHANNEL_ID, TEST_CHECK_URL, TEST_CHECK_STRING).run()
        except InterruptedError:
            pass

       
if __name__ == '__main__':
    unittest.main()
