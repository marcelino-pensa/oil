#!/bin/bash
set -Eeuxo pipefail

sed -i "s|<arg name=\"gcs_url\" value=\".*\"/>|<arg name=\"gcs_url\" value=\"udp://@VARIP\"/>|" /root/rosws/src/pensa/system_config/launch/daisy.launch
