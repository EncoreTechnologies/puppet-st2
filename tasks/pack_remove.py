#!/usr/bin/env python3
import os
import sys

# import Bolt task helper
sys.path.append(os.path.join(os.path.dirname(__file__), '..', 'files'))
from st2_task_base import St2TaskBase


class St2PackRemove(St2TaskBase):

    def task_impl(self, args):
        # remove the list of packs
        packs = args['packs']
        cmd = ['st2', 'pack', 'remove', '--json'] + packs
        return self.exec_cmd(cmd, 'remove packs')


if __name__ == '__main__':
    St2PackRemove().run()
