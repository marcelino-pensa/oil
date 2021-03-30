#!/bin/bash
set -Eeuxo pipefail

grep -qF 'USER' /root/.ssh/authorized_keys || grep -F 'USER' /home/pensa/.ssh/authorized_keys >> /root/.ssh/authorized_keys