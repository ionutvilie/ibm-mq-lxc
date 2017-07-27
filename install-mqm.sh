#!/usr/bin/env bash
# Fail on error
set -e

TMP_DIR=$(dirname "$0")
cd ${TMP_DIR}

export MQ_PACKAGES="MQSeriesRuntime-8.0.0-4.x86_64.rpm MQSeriesServer-8.0.0-4.x86_64.rpm MQSeriesClient-8.0.0-4.x86_64.rpm
MQSeriesJava-8.0.0-4.x86_64.rpm MQSeriesJRE-8.0.0-4.x86_64.rpm MQSeriesGSKit-8.0.0-4.x86_64.rpm
MQSeriesSDK-8.0.0-4.x86_64.rpm MQSeriesMan-8.0.0-4.x86_64.rpm MQSeriesSamples-8.0.0-4.x86_64.rpm
MQSeriesAMS-8.0.0-4.x86_64.rpm MQSeriesAMQP-8.0.0-4.x86_64.rpm "

export DEBIAN_FRONTEND=noninteractive
# Recommended: Update all packages to the latest level
apt-get update
apt-get upgrade -y
# These packages should already be present, but let's make sure
apt-get install -y \
    bash \
    curl \
    rpm \
    tar \
    bc
# # Download and extract the MQ installation files
tar -zxvf *.tar.gz
# Recommended: Create the mqm user ID with a fixed UID and group, so that the
# file permissions work between different images

groupadd --gid 5000 mqm
useradd --uid 5000 --gid mqm --home /var/mqm mqm --shell /bin/bash
usermod -G mqm root

# Configure file limits for mqm user
echo "mqm       hard  nofile     10240" >> /etc/security/limits.conf
echo "mqm       soft  nofile     10240" >> /etc/security/limits.conf
# Configure kernel parameters to values suitable for running MQ
export CONFIG="/etc/sysctl.conf"
cp ${CONFIG} /etc/sysctl.conf.bak
sed -i '/^fs.file-max\s*=/{h;s/=.*/=524288/};${x;/^$/{s//fs.file-max=524288/;H};x}' ${CONFIG}
sed -i '/^kernel.shmmni\s*=/{h;s/=.*/=4096/};${x;/^$/{s//kernel.shmmni=4096/;H};x}' ${CONFIG}
sed -i '/^kernel.shmmax\s*=/{h;s/=.*/=268435456/};${x;/^$/{s//kernel.shmmax=268435456/;H};x}' ${CONFIG}
sed -i '/^kernel.shmall\s*=/{h;s/=.*/=2097152/};${x;/^$/{s//kernel.shmall=2097152/;H};x}' ${CONFIG}
sed -i '/^kernel.sem\s*=/{h;s/=.*/=32 4096 32 128/};${x;/^$/{s//kernel.sem=32 4096 32 128/;H};x}' ${CONFIG}
cd MQServer
# Accept the MQ license
./mqlicense.sh -text_only -accept
# Install MQ using the RPM packages
rpm -ivh --force-debian --force ${MQ_PACKAGES}
# Recommended: Set the default MQ installation (makes the MQ commands available on the PATH)
/opt/mqm/bin/setmqinst -p /opt/mqm -i
# Clean up all files
rm -rf ${TMP_DIR}
# Clean up unwanted files, to help ensure a smaller image file is created
apt-get clean -y

# display mqm version
dspmqver
