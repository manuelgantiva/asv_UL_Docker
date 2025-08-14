#############################
# Base Image for Asv Loyola #
#############################
FROM ros:humble-ros-base as base
ENV ROS_DISTRO=${ROS_DISTRO}
SHELL ["/bin/bash", "-c"]

RUN apt-get update && apt-get install vim nano -y 

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

# install libraries pip
RUN pip install digi-xbee

# Install CasAdi
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    gcc g++ gfortran cmake git pkg-config liblapack-dev \
    python3-dev python3-numpy python3-scipy swig \
    coinor-libipopt-dev && \
    rm -rf /var/lib/apt/lists/*

COPY ./casadi.repos .
RUN vcs import < casadi.repos
RUN rm casadi.repos
RUN mv CasADI casadi

WORKDIR /casadi
RUN mkdir build && \
    cd build && \
    cmake .. \
      -DWITH_PYTHON=OFF \
      -DWITH_IPOPT=ON \
      -DWITH_THREAD=ON \
      -DWITH_OPENMP=ON \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_INSTALL_PREFIX=/usr/local && \
    make -j$(nproc) && \
    make install && \
    ldconfig

 # Use Cyclone DDS as middleware
 RUN apt-get update && apt-get install -y --no-install-recommends \
  ros-${ROS_DISTRO}-rmw-cyclonedds-cpp
 ENV RMW_IMPLEMENTATION=rmw_cyclonedds_cpp
 
 # Install mavros and other packages mavlink
 RUN apt-get update -y
 RUN sudo apt-get install -y ros-${ROS_DISTRO}-mavros ros-${ROS_DISTRO}-mavros-extras ros-${ROS_DISTRO}-mavros-msgs
 RUN wget https://raw.githubusercontent.com/mavlink/mavros/master/mavros/scripts/install_geographiclib_datasets.sh
 RUN sudo bash ./install_geographiclib_datasets.sh 
 
 RUN sudo apt-get install -y ros-${ROS_DISTRO}-xacro
 
 #############################
 # Compilation Stage #
 #############################
 FROM base as build
 
 # Create Colcon workspace with external dependencies
 WORKDIR /
 RUN mkdir -p /bag_files
 RUN mkdir -p /asv_ws
 WORKDIR /asv_ws
 COPY ./dependencies.repos .
 RUN vcs import < dependencies.repos
 RUN mv ASV_Loyola_US_low_level src
 RUN rm dependencies.repos
 
 # Build the base Colcon workspace, installing dependencies first.
 WORKDIR /asv_ws
 RUN chmod +x /asv_ws/src/asv_comunication/scripts/transceiver_xbee.py
 RUN source /opt/ros/${ROS_DISTRO}/setup.bash \
  && apt-get update -y \
  && rosdep install --from-paths src --ignore-src --rosdistro ${ROS_DISTRO} -y \
  && colcon build --symlink-install --executor sequential
 
 RUN echo "source /opt/ros/humble/setup.bash" >> ~/.bashrc
 RUN echo "source /usr/share/colcon_argcomplete/hook/colcon-argcomplete.bash" >> ~/.bashrc
 RUN echo "source /usr/share/colcon_cd/function/colcon_cd.sh" >> ~/.bashrc
 RUN echo "source /asv_ws/install/setup.bash" >> ~/.bashrc
 
 # Set up the entrypoint
 WORKDIR /asv_ws
 COPY ./docker/entrypoint.sh /
 ENTRYPOINT [ "/entrypoint.sh" ]
 
 WORKDIR /bag_files
 
 # launch ros package
# CMD ["ros2", "launch", "asv_bringup", "real_test.launch.py", "my_id:=3", "rec:=True"]
CMD ["bash"]
