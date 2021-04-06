#!/bin/bash

set -eux

apt-get update
apt-get upgrade -y
apt-get dist-upgrade -y

apt-get autoremove -y
rm -rf /var/lib/apt/lists/*

