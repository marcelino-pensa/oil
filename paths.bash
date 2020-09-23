
export ROS_WS=~/catkin_ws
export PENSA_ROS_PATH=$ROS_WS/src/pensa
export PX4_PATH=~/Firmware

source $ROS_WS/devel/setup.bash
export ROS_PACKAGE_PATH=$ROS_PACKAGE_PATH:$PX4_PATH
export ROS_PACKAGE_PATH=$ROS_PACKAGE_PATH:$PX4_PATH/Tools/sitl_gazebo
export ROS_PACKAGE_PATH=$ROS_PACKAGE_PATH:$PENSA_ROS_PATH/simulation/aws-robomaker-bookstore-world-ros1
export ROS_PACKAGE_PATH=$ROS_PACKAGE_PATH:$PENSA_ROS_PATH/simulation/gazebo_files
source $PX4_PATH/Tools/setup_gazebo.bash $PX4_PATH $PX4_PATH/build/px4_sitl_default > /dev/null
export GAZEBO_MODEL_PATH=$GAZEBO_MODEL_PATH:$PENSA_ROS_PATH/third_party/pensa_resources/simulation_files/sim_fiducials
export GAZEBO_MODEL_PATH=$GAZEBO_MODEL_PATH:$PENSA_ROS_PATH/third_party/pensa_resources/simulation_files/store_meshes
export GAZEBO_MODEL_PATH=$GAZEBO_MODEL_PATH:$PENSA_ROS_PATH/simulation/gazebo_files/gazebo_models