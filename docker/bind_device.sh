#!/bin/bash
echo "start copying imu_usb.rules and xbee_usb.rules to /etc/udev/rules.d/"

# Copiar las reglas del dispositivo IMU
sudo cp imu_usb.rules /etc/udev/rules.d

# Copiar las reglas del dispositivo de comunicaciones
sudo cp xbee_usb.rules /etc/udev/rules.d

# Recargar y reiniciar el servicio udev
echo "Reloading and restarting udev service..."
sudo service udev reload
sleep 2
sudo service udev restart

echo "Finish!!!"
