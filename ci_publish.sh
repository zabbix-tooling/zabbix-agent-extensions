#!/bin/bash

TARGET_HOST=$1
TARGET_USER=${2:-"aptly"}
TARGET_DESTINATION=${3:-"/srv/repos/"}
TARGET_DESTINATION_YUM=${TARGET_DESTINATION}"yum"
TARGET_DESTINATION_APT="/tmp"

set -e

echo -------------------------Publishing YUM---------------------------

set -x
scp zabbix-agent-extensions*.rpm ${TARGET_USER}@${TARGET_HOST}:${TARGET_DESTINATION_YUM}
ssh ${TARGET_USER}@${TARGET_HOST} "/usr/bin/createrepo -s sha ${TARGET_DESTINATION_YUM}"
set +x

echo -------------------------Publishing APT---------------------------

DEB_FILE=`ls zabbix-agent-extensions*.deb`
set -x
scp ${DEB_FILE} ${TARGET_USER}@${TARGET_HOST}:${TARGET_DESTINATION_APT}

ssh ${TARGET_USER}@${TARGET_HOST} "aptly repo add -force-replace stable ${TARGET_DESTINATION_APT}/${DEB_FILE}"
ssh ${TARGET_USER}@${TARGET_HOST} "aptly snapshot create stable-$(date "+%Y-%m-%d_%H-%M") from repo stable"
ssh ${TARGET_USER}@${TARGET_HOST} "aptly publish drop trusty"
ssh ${TARGET_USER}@${TARGET_HOST} "aptly publish snapshot stable-$(date "+%Y-%m-%d_%H-%M")"

ssh ${TARGET_USER}@${TARGET_HOST} "rm ${TARGET_DESTINATION_APT}/${DEB_FILE}"
set +x
