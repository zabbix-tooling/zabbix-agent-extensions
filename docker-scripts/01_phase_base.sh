#!/bin/bash

set -eux

apt-get autoremove -y
source /etc/lsb-release

apt-get update 
apt-get install curl vim-tiny sudo jq python3 -y
apt-get upgrade -y
apt-get dist-upgrade -y
apt-get autoremove -y
apt-get clean
apt-get autoremove -y

rm -rf /var/lib/apt/lists/*

echo "set nocompatible" > /var/lib/zabbix/.vimrc
