
# ASV_UL_Docker

### Description

- This code is being developed using ROS2 Humble  
- Part of the projects developed by the Optimization and Control of Distributed Systems research group
- Compatible with Navio2, Navigator, and other Ardupilot-based systems that support MAVLink
- Designed to work with Jetson Xavier NX.
- Includes a Docker image for deploying control algorithms in experimental validation


![](https://www.uloyola.es/templates/v6/images/isologo_loyola_principal.svg)

This repository contains a Dockerfile and the necessary scripts for the automated deployment of an ASV application. The Docker container streamlines the deployment process, ensuring efficient and consistent implementation across different environments.

## Table of Contents

1. [Requirements](#requirements)
   - [Deployment](#deployment)  
   - [Development](#development)
3. [Prepare the Image](#prepare-the-image)  
4. [Build the Image](#build-the-image)  
5. [Run Your Container](#run-your-container)

## Requirements

Before getting started, make sure the following are installed on your system:

- [Docker](https://www.docker.com/get-started)  
- [Docker Compose](https://docs.docker.com/compose/install/)  

Instead of installing ROS and other dependencies directly on your host machine, you can use a Docker container to create the environment needed to build and run the control algorithms.

## Clone the Repository

To get started, first create a working directory and clone the repository into it. Make sure to use the `beckermn` branch, which contains the deployment setup.

Open a terminal and run:

```bash
mkdir asv_docker
cd asv_docker
git clone -b beckermn https://github.com/manuelgantiva/asv_UL_Docker.git .
```

The `.` at the end of the `git clone` command places the contents of the repository directly into the current folder, avoiding the creation of an extra subdirectory.

## Prepare the Image

The following steps explain how to prepare your Docker image, depending on whether you want to use it to run a specific `.launch` file or to compile and develop your own code. Additionally, it includes the setup of the hardware peripherals used in the Yellofish platform (IMU and XBee).

The commands below will configure udev rules to identify the ZigBee and IMU modules when connected. This makes it easier to link them to the Docker container. If you don’t plan to use these devices (e.g., desktop-only development or reading rosbag files), you can skip this step:

```bash
cd /docker
sudo chmod 777 bind_device.sh
sudo sh bind_device.sh
cd ..
```

If you plan to develop code inside the container, go to the [Development](#desarrollo) section.

### Deployment

This section describes the steps required to prepare a test run. First, define the `.launch` file and the vehicle ID you want to execute when the Docker container starts. This must be specified in the last line of the [Dockerfile](docker/Dockerfile) before building the image:

```docker
CMD ["ros2", "launch", "asv_bringup", "your_launch.launch.py", "my_id:=4"]
```

Next, define the branch of the ROS2 repository that the container will use. This must be set in the last line of the [dependencies](dependencies.REPOS) file:

```docker
version: beckermn
```

Finally, configure which peripherals the Docker container should access. You can do this by commenting out or removing the following lines in the [Entrypoint](docker/entrypoint.sh) file if you are not using these devices:

```sh
sudo chmod a+rw /dev/xbee_usb
echo "Enable port Usb xbee"
sudo chmod a+rw /dev/imu_usb
echo "Enable port Usb imu"
```

Once these settings are in place, your Docker image is ready to be built.

### Development

This section provides some recommendations for using the Docker image for development purposes. Note, however, that this image was not originally designed for development, so you will need to manually mount volumes to avoid losing changes when the container is closed.

First, modify the last line of the [Dockerfile](docker/Dockerfile) before building the image. This change prevents the container from launching any `.launch` files automatically, allowing you to compile or edit files manually:

```docker
# CMD ["ros2", "launch", "asv_bringup", "your_launch.launch.py", "my_id:=4"]
CMD ["bash"]
```

Next, define (or verify) the branch of the ROS2 repository that the container will use. This is set in the last line of the dependencies.REPOS file, which pulls the latest commit from that branch:

```docker
version: beckermn
```

To include your code from the host system into the Docker container, you need to configure a [volume](https://docs.docker.com/engine/storage/volumes/). Edit the [docker-compose](docker-compose.yaml) file and add the desired folders like this:

```docker-compose
volumes:
      - /<carpeta-con-archivos>:/asv_ws/src:rw
      - ./bag_files:/bag_files:rw
```

This allows you to edit files locally on your host machine and compile them inside the container without losing changes.

Finally, for desktop development, you should comment out the hardware-specific commands in the [Entrypoint](docker/entrypoint.sh) file to avoid issues related to missing devices:

```sh
sudo chmod a+rw /dev/xbee_usb
echo "Enable port Usb xbee"
sudo chmod a+rw /dev/imu_usb
echo "Enable port Usb imu"
```
With these modifications, your Docker image will be ready for development workflows.

## Build the Image

This section outlines the steps to build your Docker image using the previously configured and modified files. If you make any changes to the files mentioned earlier, you must rebuild the image.

it's important to first identify your host's platform and architecture.

##### Build Command for Linux ARM64  
(Used for ARM-based devices such as some servers, Raspberry Pi, and Jetson NX):

```bash
docker builder build --target build --platform linux/arm64 --build-arg TARGETPLATFORM=linux/arm64 --build-arg TARGETARCH=arm64 -f docker/Dockerfile -t my/ros:app .
```

##### Build Command for Linux x64

(Used for standard PCs, WSL, and 64-bit servers):

```bash
docker builder build --target build --platform linux --build-arg TARGETPLATFORM=linux --build-arg TARGETARCH=x64 -f docker/Dockerfile -t my/ros:app .
```

This process may take several minutes to complete.

## Run Your Container

Once your image is built, you can run the Docker container using command-line tools. However, to simplify configuration and deployment, this repository includes a [docker-compose.yaml](docker-compose.yaml) file. It helps launch the container along with all its settings in a more streamlined way.

If you're not using the Yellofish modules (IMU and XBee), make sure to edit the `devices` section in the [docker-compose.yaml](docker-compose.yaml) file. You can comment out or remove the following lines:

```yaml
devices:
  - /dev/xbee_usb
  - /dev/imu_usb
```

To launch the container, navigate to the `asv_docker` folder and run:

```bash
docker-compose up
```

To access the container’s terminal and run ROS2 commands, open a second terminal and execute:

```bash
docker exec -it asv_docker bash
```