#!/usr/bin/env bash
# Download developer version or use eneterprise release
# https://www.ibm.com/developerworks/community/blogs/messaging/entry/develop_on_websphere_mq_advanced_at_no_charge?lang=en
# Script for installing Mq explorer on Ubuntu Linux
# Tested on: Ubuntu 17.04

printf "INFO:  Install MQ Explorer \n"
# install redhat package manager
sudo apt install rpm -y

if [ -e mqadv_dev80_linux_x86-64.tar.gz ]; then
  tar -zxvf ./mqadv_dev80_linux_x86-64.tar.gz
else
  printf "ERROR: mqadv_dev80_linux_x86-64.tar.gz not found \n"
  exit
fi

exit
cd MQServer
# accept license
sudo ./mqlicense.sh -text_only -accept

# dependencies and MQSeriesExplorer package
export MQ_EXPLORER="MQSeriesRuntime-8.0.0-4.x86_64.rpm MQSeriesJRE-8.0.0-4.x86_64.rpm MQSeriesExplorer-8.0.0-4.x86_64.rpm"
sudo rpm -ivh --force-debian --force ${MQ_EXPLORER}
