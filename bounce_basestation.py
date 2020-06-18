#!/usr/bin/env python3

import time
import xmlrpc.client

server = xmlrpc.client.ServerProxy('http://basestation.local:9999/RPC2')

print("stopping all processes on basestation...")
server.supervisor.stopAllProcesses()
time.sleep(3)
print("stopped. Starting all processes (could take up to 30s)...")
server.supervisor.startAllProcesses()

print("done")