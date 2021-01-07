#!/bin/bash
# utilisation : ./runflash <nom_instance> <device> [<image>] [-w<wifi ssid> -p<wifi passwd>]

flashimage='https://github.com/hypriot/image-builder-rpi/releases/download/v1.12.3/hypriotos-rpi-v1.12.3.img.zip'

usage() {
    echo """  
runflash: runflash [OPTION] <instance_name> <device>
    rpi flashing utility for making private cloud instances on raspberry pi

    Mandatory args: 
        <instance_name> name of the new instance to flash
        <device>        device to flash (don't provide a partition but the whole device). Be carreful, as it will be rewritten    

    Options:
        -d          instance data directory
        -i          image file (zipped or unzipped) or an http location. Default to hypriot v1.12.3
        -w          Wifi ssid
        -p          Wifi password

    example : 
        ./runflash.sh -d ./instances_data/home_instances/sanelec3/ -i https://github.com/hypriot/image-builder-rpi/releases/download/v1.12.3/hypriotos-rpi-v1.12.3.img.zip -w serenandre -p moustik77 sanelec3 /dev/sdb
"""
}
exit_abnormal() {
  usage
  exit 1
}

# parse des arguments optionnels
while getopts 'hd:i:w:p:' flag; do
    case "${flag}" in
	d)  if [ -d $OPTARG ]; then INSTANCE_DIR=$OPTARG; else echo "bad directory for instance dir">&2; exit 1; fi;;
	i)  flashimage=$OPTARG;;
	w)  wifissid=$OPTARG;;
	p)  wifipass=$OPTARG;;
    h)  help; exit 0;;
    :)  echo "Missing option argument for -$OPTARG" >&2;exit_abnormal; exit 1;;
	*)  exit_abnormal;;
	esac
done

# on shifte des arguments optionnels pour ne conserver que les obligatoires (non précédés par -)
shift $((OPTIND - 1))
if [ $# -ne 2 ]; then echo "Check your args, expecting 2 mandatory args, actual: $#.">&2; exit_abnormal; fi
instanceName=$1; deviceToFlash=$2;

# test existance deviceToFlash
[ -e $deviceToFlash ] && echo "device to flash: $deviceToFlash" || (echo "bad device: $deviceToFlash">&2; exit_abnormal)


# assignation par défaut de INSTANCE_DIR à partir du nom de l'image (si non définit par l'option)
: ${INSTANCE_DIR:="./instances_data/$instanceName"} 

# test existnace repertoire d'instance
if ! [[ -e $INSTANCE_DIR ]]; then echo "no instance data entry for $instanceName"; exit 1; fi

# fichier user-data.yml : soit dans le rep d'instance sinon on utiilse celui de la racine
[ -e $INSTANCE_DIR/user-data.yml ] && userdatafile=$INSTANCE_DIR/user-data.yml || userdatafile=./user-data.yml

echo "writing image [$flashimage] on device [$deviceToFlash] for instance [$instanceName], using instance directory: $INSTANCE_DIR and user-data file : $userdatafile"

if [[ -n $wifissid ]]
then
	[[ -n $wifipass ]] && (wifiargs="--ssid $wifissid --password $wifipass"; \
        echo "using wifi ssid $wifissid and password ****") \
        || (echo "Missed password for WIFI">&2; exit_abnormal)
fi

CWD=$PWD

(cd $INSTANCE_DIR && tar -czvf $CWD/boot_secrets.tgz .)



sudo ./flash --hostname $instanceName \
--device $deviceToFlash --bootconf ./config.txt --userdata $userdatafile \
$wifiargs --file ./boot_secrets.tgz $flashimage

rm boot_secrets.tgz

exit 0