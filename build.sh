#!/bin/bash

## You will need to place the GPFS rpms in your vagrant directory. Update the following variables if you are using different versions.

GPFS_BASE_BASE_RPM="gpfs.base-3.5.0-3.x86_64.rpm"
GPFS_GPL_BASE_RPM="gpfs.gpl-3.5.0-3.noarch.rpm"
GPFS_GPL_PTF_RPM="gpfs.gpl-3.5.0-24.noarch.rpm"

## Samba Source Package. Change to point to the version you want to build

SAMBA_SRPM="http://ftp.redhat.com/redhat/linux/enterprise/5Server/en/os/SRPMS/samba3x-3.6.23-13.el5_11.src.rpm"

## Redhats RPM Signing key. You are unlikely to need to change this.

YUM_GPG_KEY="https://www.redhat.com/security/37017186.txt"

cat <<EOF >~/.rpmmacros
%_topdir   /vagrant/rpmbuild
EOF

mkdir -p /vagrant/rpmbuild/{BUILD,RPMS,SOURCES,SPECS,SRPMS}

yum install -y yum-utils rpm-build shadow-utils
sed -i'' 's/gpgcheck=1/gpgcheck=0/' /etc/yum.conf

# Download gpfs.base and gpfs.gpl
yum localinstall -y /vagrant/${GPFS_BASE_BASE_RPM} /vagrant/${GPFS_GPL_BASE_RPM}
# Download gpfs.gpl PTF update
rpm -U /vagrant/${GPFS_GPL_PTF_RPM}

/usr/sbin/useradd mockbuild
/usr/sbin/groupadd mockbuild

cd /tmp
wget ${SAMBA_SRPM} -O samba.src.rpm -nv
wget ${YUM_GPG_KEY} -O gpg.key -nv
rpm --import gpg.key

yum-builddep -y samba.src.rpm
yum install -y ctdb-devel gcc
rpmbuild --rebuild samba.src.rpm

