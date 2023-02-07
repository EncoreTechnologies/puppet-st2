from test.unit.st2_test_case import St2TestCase
# import mock
import os
import sys

sys.path.append(os.path.join(os.path.dirname(__file__), '..', '..', 'files'))
from st2_task_base import St2TaskBase

sys.path.append(os.path.join(os.path.dirname(__file__), '..', '..', 'tasks'))
from key_decrypt import AESKey


class AESKeyTestCase(St2TestCase):
    __test__ = True

    def test_init(self):
        task = AESKey()
        self.assertIsInstance(task, St2TaskBase)
