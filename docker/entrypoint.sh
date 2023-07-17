#!/bin/bash
# Basic entrypoint for ROS / Colcon Docker containers

# Source ROS 2
source /opt/ros/${ROS_DISTRO}/setup.bash
echo "Sourced ROS 2 ${ROS_DISTRO}"

# Source the base workspace, if built
if [ -f /asv_ws/install/setup.bash ]
then
  source /asv_ws/install/setup.bash
  echo "Sourced Asv_WS base workspace"
fi

sudo chmod a+rw /dev/ttyUSB0
echo "Enable port Usb"

# Execute the command passed into this entrypoint
exec "$@"