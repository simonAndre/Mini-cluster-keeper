#!/bin/bash
# utilisation : ./runflash <nom_instance> <device> [<image>] [<wifi ssid> <wifi passwd>]

defaultimage='https://github.com/hypriot/image-builder-rpi/releases/download/v1.12.3/hypriotos-rpi-v1.12.3.img.zip'

help() {
    echo "rpi flashing utility for making private cloud instances on raspberry pi"
    echo "usage : ./runflash <instance name> <device> [<image>] [<wifi ssid> <wifi passwd>]"
    echo "[<image>] is a file (zipped or unzipped) or an http location. Default to hypriot v1.12.3"
}

case $# in
    2) instanceName=$1; deviceToFlash=$2; image=$defaultimage ;;
    3) instanceName=$1; deviceToFlash=$2; image=$3 ;;
    4) instanceName=$1; deviceToFlash=$2; image=$defaultimage; wifissid=$3; wifipass=$4 ;;
    5) instanceName=$1; deviceToFlash=$2; image=$3; wifissid=$4; wifipass=$5 ;;
    *) help; echo "bad argument count"; exit 1 ;;
esac

if ! [[ -e ./instances_data/$instanceName ]]; then echo "no instance data entry for $instanceName"; exit 1; fi

echo "writing image [$image] on device [$deviceToFlash] for instance [$instanceName]"

if [[ -n $wifissid ]] && [[ -n $wifipass ]]
then
	wifiargs="--ssid $wifissid --password $wifipass"
    echo "using wifi ssid $wifissid and password ****"
fi

(cd ./instances_data/$instanceName && tar -czvf ../../boot_secrets.tgz .)

sudo ./flash --hostname $instanceName \
--device $deviceToFlash --bootconf ./config.txt --userdata ./user-data.yml \
$wifiargs --file ./boot_secrets.tgz $image

rm boot_secrets.tgz

exit 0