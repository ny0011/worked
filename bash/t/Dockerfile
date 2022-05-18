FROM ubuntu:18.04
ENV DEBIAN_FRONTEND=noninteractive
RUN \
echo exit 0 > /usr/sbin/policy-rc.d && \
ln -s /usr/share/zoneinfo/Asia/Seoul /etc/localtime && \
apt update && \
apt purge --auto-remove resolvconf && \
apt install -y sudo openssh-server systemd rsyslog curl vim git wget apache2  python2.7 python3 python-pip python3-pip libapache2-mod-wsgi python-dev python-pip python-requests libpq-dev postgresql postgresql-contrib tftpd-hpa python-tz python-pysnmp4 python-lxml libssl-dev libffi-dev python-serial python-pexpect aria2 nfs-kernel-server python-lzma && \
apt --fix-broken install -y
CMD ["/sbin/init"]
