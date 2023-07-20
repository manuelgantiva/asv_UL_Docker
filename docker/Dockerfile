#############################
# Base Image for Asv Loyola #
#############################
FROM ros:humble-ros-base as base
ENV ROS_DISTRO=${ROS_DISTRO}
SHELL ["/bin/bash", "-c"]

# ROS fundamentals
RUN apt-get update && apt-get install -y \
        build-essential \
        python3-colcon-common-extensions \
        python3-pip \
        python3-pybind11 \
        python3-pytest-cov \
        python3-rosdep \
        python3-rosinstall-generator \
        python3-vcstool \
        wget \
&& rm -rf /var/lib/apt/lists/* \
&& apt-get clean

# install ros package
RUN apt-get update && apt-get install -y \
      ros-${ROS_DISTRO}-demo-nodes-cpp \
      ros-${ROS_DISTRO}-demo-nodes-py && \
    rm -rf /var/lib/apt/lists/*

# install libraries pip
RUN pip install digi-xbee

# Use Cyclone DDS as middleware
RUN apt-get update && apt-get install -y --no-install-recommends \
 ros-${ROS_DISTRO}-rmw-cyclonedds-cpp
ENV RMW_IMPLEMENTATION=rmw_cyclonedds_cpp

# Create Colcon workspace with external dependencies
RUN mkdir -p /bag_files
RUN mkdir -p /asv_ws
WORKDIR /asv_ws
COPY ./dependencies.repos .
RUN vcs import < dependencies.repos
RUN mv ASV_Loyola_US_low_level src
RUN rm dependencies.repos

# Install mavros and other packages mavlink
RUN sudo apt-get install -y ros-${ROS_DISTRO}-mavros ros-${ROS_DISTRO}-mavros-extras ros-${ROS_DISTRO}-mavros-msgs
RUN wget https://raw.githubusercontent.com/mavlink/mavros/master/mavros/scripts/install_geographiclib_datasets.sh
RUN sudo bash ./install_geographiclib_datasets.sh 

# Build the base Colcon workspace, installing dependencies first.
WORKDIR /asv_ws
RUN chmod +x /asv_ws/src/asv_comunication/scripts/send_xbee.py
RUN chmod +x /asv_ws/src/asv_comunication/scripts/receive_xbee.py  
RUN chmod +x /asv_ws/src/asv_comunication/scripts/asv_xbee.py
RUN chmod +x /asv_ws/src/asv_comunication/scripts/test_observer.py
RUN source /opt/ros/${ROS_DISTRO}/setup.bash \
 && apt-get update -y \
 && rosdep install --from-paths src --ignore-src --rosdistro ${ROS_DISTRO} -y \
 && colcon build --symlink-install

# Set up the entrypoint
WORKDIR /asv_ws
COPY ./docker/entrypoint.sh /
ENTRYPOINT [ "/entrypoint.sh" ]

RUN echo "source /opt/ros/humble/setup.bash" >> ~/.bashrc
RUN echo "source /usr/share/colcon_argcomplete/hook/colcon-argcomplete.bash" >> ~/.bashrc
RUN echo "source /usr/share/colcon_cd/function/colcon_cd.sh" >> ~/.bashrc
RUN echo "source /asv_ws/install/setup.bash" >> ~/.bashrc

# launch ros package
CMD ["ros2", "launch", "asv_bringup", "send_data.launch.py"]
