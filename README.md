### Description

- This code is being developed in ROS2 Humble
- It is part of the projects developed by the research group Optimization and Control of Distributed Systems
- Working with Navio2, jetson xavier nx and Ardupilot

# ASV_UL_Docker

![](https://www.uloyola.es/templates/v6/images/isologo_loyola_principal.svg)

# Docker de Deployment

Este repositorio contiene un Dockerfile y los scripts necesarios para la despliegue automatizado de una aplicación ASV. El contenedor Docker facilita la implementación de la aplicación en diversos entornos de manera eficiente y consistente.

## Tabla de Contenidos

1. [Requisitos](#requisitos)
2. [Prepare la imagen](#prepare-la-imagen)
3. [Construcción de tu imagen](#construcción-de-la-imagen)
4. [Ejecuta tu contenedor](#ejecuta-tu-contenedor)

## Requisitos

Antes de comenzar, asegúrate de tener los siguientes requisitos instalados en tu máquina:

- [Docker](https://www.docker.com/get-started)
- [Docker Compose](https://docs.docker.com/compose/install/)
- Archivo de licesnsia de Guribi Academic [WLS License]

En lugar de instalar ROS y otras dependencias directamente en su máquina host, puede usar un contenedor Docker para crear el entorno que necesita para construir y ejecutar los algoritmos.

## Clona el repositorio

```bash
mkdir asv_docker
cd asv_docker
git clone https://github.com/manuelgantiva/asv_UL_Docker.git .
```
## Prepare la imagen

A continuación se describen los pasos para preparar su imagen Docker, dependiendo si desea utilizarla para ejecutar un `.launch` específico o si desea crear una imagen en la que compilar sus archivos. Adicionalmente, se especifica la configuración de los periféricos utilizados en el Yellofish (IMU y Xbee).

Con estos comandos se definirá una regla para identificar los módulos zigbee e imu al conectarlos, lo cual facilitará su conexión con el contenedor Docker. En caso de que no piense utilizarlos (desarrollo exclusivo en ordenador o solo lectura de rosbags), podrá omitir este paso:

```bash
cd /docker
sudo chmod 777 bind_device.sh
sudo sh bind_device.sh
cd ..
```

Si desee desarrollar código, dirígase al paso [Desarrollo](#desarrollo)

### Despliegue

En esta sección se describen los pasos para preparar una prueba de ejecución. Primero, defina el `.launch` y el dron que desea ejecutar al iniciar su Docker. Esto deberá ser modificado en la última línea del archivo [Dockerfile](docker/Dockerfile), previo a la construcción de la imagen:

```docker
CMD ["ros2", "launch", "asv_bringup", "tu_launch.launch.py", "my_id:=4"]
```

Ahora deberá definir la rama del repositorio de ROS2 que utilizará en su contenedor Docker. Esta debe ser especificada en la última línea del archivo [Dependencies](dependencies.REPOS)

```docker
version: hito3
```

Por último, deberá definir los periféricos a los que tendrá conexión su contenedor Docker. Esto lo podrá hacer comentando o eliminando las siguientes líneas del archivo [Entrypoint](docker/entrypoint.sh)

```sh
sudo chmod a+rw /dev/xbee_usb
echo "Enable port Usb xbee"
sudo chmod a+rw /dev/imu_usb
echo "Enable port Usb imu"
```

Con esto, su imagen Docker estará lista para ser construida.

### Desarrollo

Esta sección tiene algunas recomendaciones para desarrollar mediante esta imagen Docker. Sin embargo, se aclara que esta imagen no fue diseñada con este fin, y por lo tanto deberán añadirse los volúmenes necesarios para que los cambios que realicen en su contenedor no se pierdan al cerrarlo.

Primero, deberá cambiar la última línea del archivo [Dockerfile](docker/Dockerfile) previo a la construcción de la imagen. Esto hará que al iniciar su contenedor, este no ejecute ningún `.launch`, y usted lo pueda utilizar para compilar o modificar los archivos:

```docker
# CMD ["ros2", "launch", "asv_bringup", "tu_launch.launch.py", "my_id:=4"]
CMD ["bash"]
```
Ahora deberá definir (o verificar) la rama del repositorio de ROS2 que utilizará en su contenedor Docker. Esta debe ser especificada en la última línea del archivo [Dependencies](dependencies.REPOS), lo cual descargará el último commit de dicha rama:

```docker
version: hito3
```

Para el desarrollo, necesita incluir un (volumen)[https://docs.docker.com/engine/storage/volumes/] que permita incluir código de su ordenador dentro de la imagen a utilizar. Debe modificar el archivo [docker-compose](docker-compose.yaml) y agregar la carpeta que desee de la siguiente forma:

```docker-compose
volumes:
      - /<carpeta-con-archivos>:/asv_ws/src:rw
      - ./bag_files:/bag_files:rw
```

[//]: # (Sin embargo, si usted desea actualizar la rama, deberá actualizar el repositorio y reconstruir la imagen, o crear un volumen enlazado a la carpeta `src`, lo cual le permitirá modificar los archivos sin perderlos al cerrar el contenedor.)

Con esto, podrá modificar los archivos localmente en su host y luego compilarlos en su Docker. Al terminar de crear su imagen, puede acceder al [Tutorial de Desarrollo](dev_quick_start) para desarrollar sus propios nodos. 

Por último, deberá definir los periféricos a los que tendrá conexión su contenedor Docker. Para desarrollo en ordernador, deberá comentar las siguientes líneas del archivo [Entrypoint](docker/entrypoint.sh)

```sh
sudo chmod a+rw /dev/xbee_usb
echo "Enable port Usb xbee"
sudo chmod a+rw /dev/imu_usb
echo "Enable port Usb imu"
```

Con esto, su imagen Docker estará lista para ser construida.

## Construcción de la imagen

Esta sección incluye los pasos para construir su imagen a partir de los documentos previamente configurados y modificados. Es importante que, si modifica alguno de los archivos previamente mencionados, deberá volver a construir su imagen. Dado que esta imagen utiliza Gurobi, es necesario primero identificar la plataforma y arquitectura del host. Además, asegúrese de que el archivo `gurobi.lic` se encuentre en la carpeta `asv_docker`.

Comando para Linux ARM64 (dispositivos ARM, como algunos servidores, Raspberry Pi y Jetson NX):

```bash
docker builder build --target build --platform linux/arm64 --build-arg TARGETPLATFORM=linux/arm64 --build-arg TARGETARCH=arm64 -f docker/Dockerfile -t my/ros:app .
```
Comando para Linux x64 (PCs, WSL y servidores con arquitectura de 64 bits):

```bash
docker builder build --target build --platform linux --build-arg TARGETPLATFORM=linux --build-arg TARGETARCH=x64 -f docker/Dockerfile -t my/ros:app .
```

Este proceso tardará varios minutos.

## Ejecuta tu contenedor

Una vez que su imagen esté construida, podrá ejecutar su contenedor Docker mediante comandos de línea. Sin embargo, para facilitar la configuración y despliegue del contenedor, se ha agregado el archivo [docker-compose](docker-compose.yaml), que permitirá desplegar su contenedor y toda su configuración de forma más sencilla.

Es importante que modifique su archivo [docker-compose](docker-compose.yaml) en la sección de `devices`, en caso de que no quiera utilizar los módulos del Yellofish (IMU y Xbee). Esto lo podrá hacer comentando o eliminando las siguientes líneas:

```docker-compose
devices:
      - /dev/xbee_usb
      - /dev/imu_usb
```

Por último, para ejecutar el contenedor, ubicado en el folder `asv_docker`, podrá ejecutar el comando:

```bash
docker-compose up
```

Para ingresar a la línea de comandos del contenedor, podrá, en una segunda terminal, ejecutar el siguiente comando. De esta forma, podrá utilizar los comandos de ROS2:

```bash
docker exec -it asv_docker bash
```

[//]: # (These are reference links used in the body of this note and get stripped out when the markdown processor does its job. There is no need to format nicely because it shouldn't be seen. Thanks SO - http://stackoverflow.com/questions/4823468/store-comments-in-markdown-syntax)
    
   [WLS License]: <https://www.gurobi.com/features/academic-wls-license/>
   
