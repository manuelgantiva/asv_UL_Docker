#!/bin/bash
# Basic entrypoint for ROS / Colcon Docker containers

# Source ROS 2
source /opt/ros/${ROS_DISTRO}/setup.bash
echo "Sourced ROS 2 ${ROS_DISTRO}"

# Source the base workspace, if built
if [ -f /home/asv_ws/install/setup.bash ]
then
  source /home/asv_ws/install/setup.bash
  echo "Sourced Asv_WS base workspace"
fi

# Source the base workspace, if built
if [ -f /home/aca_ws/install/setup.bash ]
then
  source /home/aca_ws/install/setup.bash
  echo "Sourced ACADOS_WS base workspace"
fi

source ~/.bashrc
echo "Sourced bashrc"
# sudo chmod a+rw /dev/xbee_usb
# echo "Enable port Usb xbee"
# sudo chmod a+rw /dev/imu_usb
# echo "Enable port Usb imu"

# Execute the command passed into this entrypoint
exec "$@"