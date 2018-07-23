#!/usr/bin/env python
import json
import subprocess
import sys
try:
    # python 2
    from urlparse import urlparse
except ImportError:
    # python 3
    from urllib.parse import urlparse

params = json.load(sys.stdin)
noop = params.get('_noop', False)
api_key = params.get('api_key')
auth_token = params.get('auth_token')
username = params.get('username')
password = params.get('password')
pack = params['pack']

exitcode = 0

def make_error(msg):
  error = {
      "_error": {
          "kind": "file_error",
          "msg": msg,
          "details": {},
      }
  }
  return error

result = {}
try:
    env = {}

    # prefer API key over auth tokens
    if api_key:
        env['ST2_API_KEY'] = api_key
    elif auth_token:
        env['ST2_AUTH_TOKEN'] = auth_token
    else:
        if not username:
            raise ValueError("'username' must be specified if not providing 'api_key' or 'auth_token'")
        if not password:
            raise ValueError("'password' must be specified if not providing 'api_key' or 'auth_token'")

        # auth on the command line, reuse the auth token for all subsequent calls
        output = subprocess.check_output(['st2', 'auth', '--only-token', '-p', password, username],
                                         stderr=subprocess.STDOUT)
        env['ST2_AUTH_TOKEN'] = output

    if noop:
        result['_noop'] = True

        is_url = urlparse(pack).scheme != ""
        if is_url:
            result['url'] = True
        else:
            output = subprocess.check_output(['st2', 'pack', 'show', '--json', pack],
                                             stderr=subprocess.STDOUT,
                                             env=env)
            result.update(json.loads(output))
    else:
        output = subprocess.check_output(['st2', 'pack', 'install', '--json', pack],
                                         stderr=subprocess.STDOUT,
                                         env=env)
        result = json.loads(output)

except subprocess.CalledProcessError as e:
    exitcode = 1
    result = make_error("Could not install pack {}: {} \n {}".format(pack, str(e), e.output))
except Exception as e:
    exitcode = 1
    result = make_error("Could not install pack {}: {}".format(pack, str(e)))

print(json.dumps(result))
exit(exitcode)
