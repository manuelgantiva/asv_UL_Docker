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

source ~/.bashrc
sudo chmod a+rw /dev/xbee_usb
echo "Enable port Usb xbee"
sudo chmod a+rw /dev/imu_usb
echo "Enable port Usb imu"

# Run gurobi_cl and check its status
# Function to run gurobi_cl and retry if it fails
run_gurobi() {
  while true; do
    gurobi_cl
    if [ $? -eq 0 ]; then
      echo "gurobi_cl succeeded"
      break
    else
      echo "gurobi_cl failed, retrying in 30 seconds..."
      sleep 10
    fi
  done
}

run_gurobi

# Execute the command passed into this entrypoint
exec "$@"