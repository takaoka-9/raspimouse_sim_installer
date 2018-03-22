#!/usr/bin/env bash

set -e

UBUNTU_VER=$(lsb_release -sc)
ROS_VER=kinetic
[ "$UBUNTU_VER" = "trusty" ] && ROS_VER=indigo

sudo apt-get install -y ros-${ROS_VER}-desktop-full

source ~/catkin_ws/devel/setup.bash || { echo "catkin_ws is not working correctly"; exit 1; }

roscd && \
	[[ -z $(pwd | grep opt) ]] && cd ../src || { echo "catkin_ws is not working correctly"; exit 1; }
[ -e "raspimouse_ros" ] && { cd raspimouse_ros; git pull; } || git clone https://github.com/ryuichiueda/raspimouse_ros.git
roscd && cd .. && source ~/catkin_ws/devel/setup.bash && catkin_make

roscd && cd ../src
[ -e "raspimouse_sim" ] && { cd raspimouse_sim; git pull; git checkout ${ROS_VER}-devel; } ||  git clone -b ${ROS_VER}-devel https://github.com/rt-net/raspimouse_sim.git
roscd && cd ..
rosdep install -r --from-paths src --skip-keys raspimouse_ros --skip-keys raspimouse_gazebo --skip-keys raspimouse_control --skip-keys raspimouse_description
roscd && cd .. && source ~/catkin_ws/devel/setup.bash && catkin_make

source ~/catkin_ws/devel/setup.bash

mkdir -p ~/.gazebo/models && cd ~/.gazebo/models
[ -e "ground_plane" ] || \
	cd /tmp && \
	wget -l1 -np -nc -r "http://models.gazebosim.org/sun" --accept=gz && \
	wget -l1 -np -nc -r "http://models.gazebosim.org/ground_plane" --accept=gz && \
	wget -l1 -np -nc -r "http://models.gazebosim.org/gas_station" --accept=gz && \
	cd "models.gazebosim.org" && \
	for i in *; do tar -zvxf "$i/model.tar.gz"; done && \
	cp -vfR * ~/.gazebo/models/

###HOW TO VERIFY###
# roslaunch raspimouse_gazebo raspimouse_with_samplemaze.launch 
# rosrun raspimouse_control controller_vel_publisher.py
