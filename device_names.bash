export ROS_IP=$(hostname -I | cut -d" " -f1)

export PERCH_NAME=lp0

parent_path=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )

export DRONE_HOSTNAME=`cat ~/oil/drone_hostname`
export BASESTATION_HOSTNAME=`cat ~/oil/basestation_hostname`
export PERCH_HOSTNAME=`cat ~/oil/perch_hostname`
