# Procédure de création de nouvelles instances raspberry pi à partir de cloud-init et d'images hypriot 

**Simon ANDRE - novembre 2020**

largelly based on [hypriot images and flashing tool](https://blog.hypriot.com)





basée sur une image hypriot
amorcage via cloud-init customisé

le point d'entrée est runflash.sh ex: `./runflash.sh sandre-app2 /dev/sdb /tmp/hypriotos-rpi-v1.12.3.img`

la customisation d'image se fait dnas un sous-repertoire de [./instances_data] du nom de l'instance



## hypriot et cloud-init

les images hypriot sont basées sur des raspbian headless sur lesquelles sont ajoutés les applicatifs docker (et les couches docker-compose et swarm).
elles sont régulièrement updatées et s'appuient sur cloud-init pour leur procédure de customisation.

cloud-init permet d'initialiser le serveur  rpi server at first boot.

des configurations spécifiques à nos instance sont disponibles dans les sous-repertoires de [./instances_data]

* les images hypriot récentes sont à trouver ici : [hyperiot images](https://blog.hypriot.com/downloads/) 

* to get the last version of the  flash tool : `wget https://raw.githubusercontent.com/hypriot/flash/master/flash .`   (pour info, [github du flash tool](https://github.com/hypriot/flash) with this option) )

## utilitaire runflash.sh

Il s'agit d'un wrapper autour de l'utilitaire flash d'hypriot.

forme d'execution: `runflash <nom_instance> <device> [<image>] [<wifi ssid> <wifi passwd>]`

  *   <nom_instance> : surcharge le nom de l'instance à flasher sur celle définit dnas la section [hostname] du fichier `user-data.yml`
  *   <wifi ssid> : identifiant du réseau WIFI sur lequel connecter la nouvelle instance 
  *   <wifi passwd> : pass du réseau WIFI
  *   <device> : device pointant vers la sdcard à flasher (bien contrler que c'est le bon avec `fdisk -l`)


## Données ajoutées à l'image lors de la procédure de flashage

### données d'initialisation d'instance

définis dnas les fichiers sous le repertoire `./instances_data/<instance_name>`

  * le couple id_rsa et id_rsa.pub : clef SSH d'identification du noeud. Sera utilisé pour authentifier l'accès à Github (doit donc être déclaré dans les clef publiques autorisées à puller le repo git contenant les scripts docker)
  * le fichier .env : secrets pour docker-compose
  * letsencrypt.tgz : repertoire letsencrypt permettant de renouer les certificats SSL 
  * ssl_certs.tgz 
  * .bash_aliases : la customisation bash pour l'utilisateur [pi]


### fichier ./config.txt

fichier de customisation du raspbery pi (équivalent du bios)

la configuration de [sanelec2] active l'accès au GPIO et aux bus I2C et SPI dnas leur groupe respectif afin que l'on puisse les piloter sans privilèges root (pour pouvoir les piloter depuis un container)

attention, dans le fichier config.txt, `enable_uart=0` permet de desactiver le UART pour rendre le wifi disponible, [voir ici](https://github.com/hypriot/blog/issues/60). Si cette ligne est opmise => pas de wifi

### fichier user-data.yaml

il s'agit du script cloud-init. le contenu de ce fichier ira dans /boot/user-data.

Dans sa configuration actuelle, ce fichier d'initialisation crée l'utilisateur [pi] avec ses accès, actualise les packages, en installe d'autres puis dans la section [runcmd] passe la main au script personalisé par image `./instances_data/<instance_name>/initinstance.sh`.

sur mes images, le seul accès possible au serveur ainsi flashé se fait via SSH à partir d'une des clef ssh inscrites dnas la section [users/ssh_authorized_keys]

[documentation cloud-init](https://cloudinit.readthedocs.io/en/latest/index.html)


## installation initiale via cloud-init

* flasher une carte ssd avec la procédure du script runflash.sh
* puis copier le contenu du repertoire [sandre-app_secrets] sur la partition boot de la carte dnas le repertoire [/boot/boot_secrets]. Ce reptoire doit contenir : 
* lancer le pi avec la carte, attendre le premier reboot que la première installation cloud-init soit temrinée ( pour suivre ou cela en est :  `tail -f /var/log/cloud-init-output.log`)


## étapes d'install manuelles

* création d'une clef ssh : `ssh-keygen`
* copie de la clef publique sur le repository git pour être autorisé à puller les repo privés, [c'est ici](https://github.com/settings/keys)
* git clone --depth 1 git@github.com:simonAndre/homeserver.git
* copie des certificats utilisés par les containers dans le repoertoreoi ~/homeserver/ssl_certs
* installation des certifs via certbot (letsencrypt)
