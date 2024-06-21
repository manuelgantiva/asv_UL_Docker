#############################
# Base Image for Asv Loyola #
#############################
FROM ros:humble-ros-base as base
ENV ROS_DISTRO=${ROS_DISTRO}
SHELL ["/bin/bash", "-c"]

RUN apt-get update && apt-get install vim -y

ARG GRB_VERSION=11.0.2
ARG GRB_SHORT_VERSION=11.0
ARG TARGETPLATFORM
ARG TARGETARCH

# Añade una línea para imprimir el valor de TARGETPLATFORM
RUN echo "TARGETPLATFORM is $TARGETPLATFORM"

# Añade una línea para imprimir el valor de TARGETARCH
RUN echo "TARGETARCH is $TARGETARCH"

# Condicional para escribir en /platform.txt según la arquitectura
RUN if [ "$TARGETPLATFORM" = "linux/arm64" ]; then \
        echo "armlinux64" > /platform.txt; \
    elif [ "$TARGETARCH" = "arm64" ]; then \
        echo "armlinux64" > /platform.txt; \
    else \
        echo "linux64" > /platform.txt; \
    fi

ENV GRB_PLATFORM=${GRB_PLATFORM}

# install gurobi package and copy the files
WORKDIR /opt

RUN export GRB_PLATFORM=$(cat /platform.txt) && echo $GRB_PLATFORM \
    &&apt-get update \
    && apt-get install --no-install-recommends -y\
       ca-certificates  \
       wget \
    && update-ca-certificates \
    && wget -v https://packages.gurobi.com/${GRB_SHORT_VERSION}/gurobi${GRB_VERSION}_$GRB_PLATFORM.tar.gz \
    && tar -xvf gurobi${GRB_VERSION}_$GRB_PLATFORM.tar.gz  \
    && rm -f gurobi${GRB_VERSION}_$GRB_PLATFORM.tar.gz \
    && mv -f gurobi* gurobi \
    && rm -rf gurobi/$GRB_PLATFORM/docs \
    && mv -f gurobi/$GRB_PLATFORM*  gurobi/linux
# After the file renaming, a clean image is built

WORKDIR /opt/gurobi

ENV GUROBI_HOME /opt/gurobi/linux
ENV PATH $PATH:$GUROBI_HOME/bin
ENV LD_LIBRARY_PATH $GUROBI_HOME/lib

COPY gurobi.lic /opt/gurobi/linux/

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
RUN apt-get update -y
RUN sudo apt-get install -y ros-${ROS_DISTRO}-mavros ros-${ROS_DISTRO}-mavros-extras ros-${ROS_DISTRO}-mavros-msgs
RUN wget https://raw.githubusercontent.com/mavlink/mavros/master/mavros/scripts/install_geographiclib_datasets.sh
RUN sudo bash ./install_geographiclib_datasets.sh 

RUN sudo apt-get install -y ros-${ROS_DISTRO}-xacro

# Build the base Colcon workspace, installing dependencies first.
WORKDIR /asv_ws
RUN chmod +x /asv_ws/src/asv_comunication/scripts/transceiver_xbee.py
RUN chmod +x /asv_ws/src/asv_comunication/scripts/test_observer.py
RUN source /opt/ros/${ROS_DISTRO}/setup.bash \
 && apt-get update -y \
 && rosdep install --from-paths src --ignore-src --rosdistro ${ROS_DISTRO} -y \
 && colcon build --symlink-install --executor sequential

# Set up the entrypoint
WORKDIR /asv_ws
COPY ./docker/entrypoint.sh /
ENTRYPOINT [ "/entrypoint.sh" ]

RUN echo "source /opt/ros/humble/setup.bash" >> ~/.bashrc
RUN echo "source /usr/share/colcon_argcomplete/hook/colcon-argcomplete.bash" >> ~/.bashrc
RUN echo "source /usr/share/colcon_cd/function/colcon_cd.sh" >> ~/.bashrc
RUN echo "source /asv_ws/install/setup.bash" >> ~/.bashrc

RUN echo "export GUROBI_HOME=/opt/gurobi/linux" >> ~/.bashrc
RUN echo "export PATH=\$GUROBI_HOME/bin:\$PATH" >> ~/.bashrc
RUN echo "export LD_LIBRARY_PATH=\$GUROBI_HOME/lib:\$LD_LIBRARY_PATH" >> ~/.bashrc
RUN echo "export GRB_LICENSE_FILE=$GUROBI_HOME/gurobi.lic" >> ~/.bashrc

WORKDIR /bag_files

# launch ros package
CMD ["ros2", "launch", "asv_bringup", "control_test.launch.py", "my_id:=0"]
