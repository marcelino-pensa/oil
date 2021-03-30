#!/usr/bin/env python3

import time
import xmlrpc.client
import sys

server = xmlrpc.client.ServerProxy('http://' + sys.argv[1] + '.local:9999/RPC2')

print("stopping all processes on " + sys.argv[1] + "...")
server.supervisor.stopAllProcesses()

print("done")