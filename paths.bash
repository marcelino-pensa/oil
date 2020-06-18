
export ROS_WS=~/catkin_ws
export PENSA_ROS_PATH=$ROS_WS/src/pensa
export PX4_PATH=~/src/Firmware

source $ROS_WS/devel/setup.bash
export ROS_PACKAGE_PATH=$ROS_PACKAGE_PATH:$PX4_PATH
export ROS_PACKAGE_PATH=$ROS_PACKAGE_PATH:$PX4_PATH/Tools/sitl_gazebo
export ROS_PACKAGE_PATH=$ROS_PACKAGE_PATH:$PENSA_ROS_PATH/aws-robomaker-bookstore-world-ros1
source $PX4_PATH/Tools/setup_gazebo.bash $PX4_PATH $PX4_PATH/build/px4_sitl_default > /dev/null
export GAZEBO_MODEL_PATH=$GAZEBO_MODEL_PATH:$PENSA_ROS_PATH/system_config/gazebo_models
export GAZEBO_MODEL_PATH=$GAZEBO_MODEL_PATH:$PENSA_ROS_PATH/third_party/pensa_resources/sim_fiducials
export GAZEBO_MODEL_PATH=$GAZEBO_MODEL_PATH:$PENSA_ROS_PATH/third_party/pensa_resources/store_meshes
