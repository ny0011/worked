#!/bin/bash

apt update
apt install -y vim python2.7 python3 openssh-server python-pip python3-pip libapache2-mod-wsgi python-dev python-pip python-requests libpq-dev postgresql postgresql-contrib wget git apache2 rsyslog systemd sudo curl tftpd-hpa python-tz python-pysnmp4 python-lxml libssl-dev libffi-dev python-serial python-pexpect aria2 nfs-kernel-server python-lzma apt-transport-https ca-certificates gnupg lsb-release
apt --fix-broken install -y

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo \
  "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" |  tee /etc/apt/sources.list.d/docker.list > /dev/null
apt install -y docker-ce docker-ce-cli containerd.io
# https://www.ubuntuupdates.org/package/core/bionic/main/updates/libseccomp2

echo "[NOTE] install is finished"
python --version
python3 --version
