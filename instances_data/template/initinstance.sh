#!/bin/bash
echo "********************************************"
echo "** starting instance first initialisation **"
echo "********************************************"

BOOTSECRETSDIR=~/boot_data
cd ~
echo "your authorized public key to connect to the instance" >> ~/.ssh/authorized_keys
cp $BOOTSECRETSDIR/.bash_aliases ~/
mkdir -p ~/.ssh 
cp $BOOTSECRETSDIR/id_rsa* ~/.ssh/
sudo chown pi:pi ~/.ssh/*
sudo chmod u=rw,g=,o= ~/.ssh/id_rsa
sudo chmod u=rw,g=r,o=r ~/.ssh/id_rsa.pub

echo "if [ -f ~/.bash_aliases ]; then . ~/.bash_aliases;fi;" >> ~/.bashrc
sudo mkdir -p /media/mydisk1 /media/mydisk2

ssh-keyscan -H github.com >> ~/.ssh/known_hosts
git config --global user.email "myname@email.com" && \
git config --global user.name "my NAME"
mkdir -p ~/servicesrepo
git clone git@github.com:simonAndre/servicesrepo.git ~/servicesrepo
cp $BOOTSECRETSDIR/.env ~/servicesrepo/
tar -xvzf $BOOTSECRETSDIR/ssl_certs.tgz -C ~/servicesrepo/
docker pull python:rc-alpine && docker pull python:rc-slim && \
cd ~/servicesrepo

docker-compose pull

# and whatever...

echo "******************************************"
echo "** instance first initialisation done   **"
echo "******************************************"
echo ""
echo ""
echo ""