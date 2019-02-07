#!/usr/bin/env python
import json
import os
import re
import subprocess
import sys
import traceback

# import Bolt task helper
sys.path.append(os.path.join(os.environ['PT__installdir'], 'python_task_helper', 'files'))
from task_helper import TaskHelper, TaskError

try:
    # python 2
    from urlparse import urlparse
except ImportError:
    # python 3
    from urllib.parse import urlparse  # noqa

# try to find a [ or { at the start of a line
JSON_START_PATTERN = re.compile("(\\[|{)", re.MULTILINE)


class St2TaskBase(TaskHelper):

    def login(self, args):
        self.api_key = args.get('api_key')
        self.auth_token = args.get('auth_token')
        self.username = args.get('username')
        self.password = args.get('password')
        # inherit environment variables from the Bolt context to preserve things
        # like locale... otherwise we get errors from the StackStorm client.
        self.env = os.environ

        # prefer API key over auth tokens
        if self.api_key:
            self.env['ST2_API_KEY'] = self.api_key
        elif self.auth_token:
            self.env['ST2_AUTH_TOKEN'] = self.auth_token
        elif self.username and self.password:
            # auth on the command line with username/password
            cmd = ['st2', 'auth', '--only-token', '-p', self.password, self.username]
            stdout = subprocess.check_output(cmd)
            self.env['ST2_AUTH_TOKEN'] = stdout.rstrip()
        # else
        #    assume auth token is written in client config for this user.
        #    don't worry, if there is no auth we'll get an error

    def scan_for_json(self, stdout):
        # the output from st2 pack install doesn't print out in pure JSON, so
        # look for the JSON in the output
        start_pos = 0
        stdout_json = None
        while start_pos < len(stdout):
            # try to find the start of JSON
            m = JSON_START_PATTERN.search(stdout[start_pos:])
            if m:
                # we found some json potentially, get the position of the match
                # in the string and increment our start position that much
                start_pos += m.span(0)[0]
                try:
                    # try to parse JSON starting at the position of our JSON
                    # character match
                    stdout_json = json.loads(stdout[start_pos:])
                    break
                except ValueError:
                    # JSON parse failed, so start looking for JSON data beginning
                    # at the next character
                    start_pos += 1
                    pass
            else:
                # didn't find a patch in the entire string, bail out
                break

        # if we found JSON, return the parse result
        # else return the raw stdout
        if stdout_json:
            return {'result': stdout_json}
        else:
            return {'result': stdout}

    def exec_cmd(self, cmd, error_msg):
        result = {}
        try:
            stdout = subprocess.check_output(cmd,
                                             stderr=subprocess.STDOUT,
                                             env=self.env)
            result.update(self.scan_for_json(stdout))
        except subprocess.CalledProcessError as e:
            tb = traceback.format_exc()
            raise TaskError(("Could not {}: {} \n {}\n {}".
                             format(error_msg, str(e), e.output, tb)),
                            'st2.task.base/subprocess_error')
        except Exception as e:
            tb = traceback.format_exc()
            raise TaskError(("Could not {}: {}\n {}".
                             format(error_msg, str(e), tb)),
                            'st2.task.base/exec_exception')
        return result

    def task(self, args):
        try:
            self.login(args)
            return self.task_impl(args)
        except Exception as e:
            tb = traceback.format_exc()
            raise TaskError(str(e) + '\n' + tb,
                            'st2.task.base/task_exception')

    def task_impl(self, args):
        raise NotImplementedError()
