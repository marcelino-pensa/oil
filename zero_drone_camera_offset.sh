#!/bin/bash
set -Eeuxo pipefail

sed -i "s|<arg name=\"t265_x_offset\" default=\".*\" />|<arg name=\"t265_x_offset\" default=\"0.0\" />|" /root/rosws/src/pensa/system_config/launch/daisy.launch
