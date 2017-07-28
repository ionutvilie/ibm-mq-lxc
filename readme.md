# IBM MQ Linux Container (lxc)

Tests are made with developer versions of IBM products mq8. 
These are not easy to find using google, I first discovered ibm's public ftp server by looking at the ibm mq docker file (IBM's official github repository).
[public.dhe.ibm.com](http://public.dhe.ibm.com/ibmdl/export/pub/software/websphere/messaging/mqadv/)

 - lxc - linux container. can run more than one process
 - docker - application container, intended to run only one process

## Prerequisites

[Download MQ Dev80 for Linux](https://www.ibm.com/developerworks/community/blogs/messaging/entry/develop_on_websphere_mq_advanced_at_no_charge?lang=en)



## localhost

localhost is the main Ubuntu OS where containers will run (eg: Ubuntu notebook)   

### LXC - LXD
```bash
#Install lxc
sudo apt install -y lxc lxd
# Conficure lxd
sudo lxd init
```

### MQ Explorer
```bash
# install redhat package manager
sudo apt install rpm -y
tar -zxvf ./mqadv_dev80_linux_x86-64.tar.gz
cd MQServer
# accept license
sudo ./mqlicense.sh -text_only -accept
# dependencies and MQSeriesExplorer package
export MQ_EXPLORER="MQSeriesRuntime-8.0.0-4.x86_64.rpm MQSeriesJRE-8.0.0-4.x86_64.rpm MQSeriesExplorer-8.0.0-4.x86_64.rpm"
sudo rpm -ivh --force-debian --force ${MQ_EXPLORER}
```

## Linux Container

```bash
#launch ubuntu:16.04 container as mqm
sudo lxc launch ubuntu:16.04 mqm
chmod +x install-mqm.sh
sudo lxc file push mqadv_dev80_linux_x86-64.tar.gz mqm/tmp/mqm/ -p
sudo lxc file push install-mqm.sh mqm/tmp/mqm/ -p
sudo lxc exec mqm /tmp/mqm/install-mqm.sh
```

### Optional

- Save container as image

```bash
$ sudo lxc publish --public=false mqm --alias=mqm/8.0.0.4 --force
Container published with fingerprint: 47e8619070ae4323423295199bfd19b43cf0c956e1dd73c8adf5dedc6e433cbc
$ sudo lxc image list
+-------------+--------------+--------+---------------------------------------------+--------+----------+------------------------------+
|    ALIAS    | FINGERPRINT  | PUBLIC |                 DESCRIPTION                 |  ARCH  |   SIZE   |         UPLOAD DATE          |
+-------------+--------------+--------+---------------------------------------------+--------+----------+------------------------------+
| mqm/8.0.0.4 | 47e8619070ae | no     |                                             | x86_64 | 577.92MB | Jul 27, 2017 at 9:13pm (UTC) |
+-------------+--------------+--------+---------------------------------------------+--------+----------+------------------------------+
|             | 8220e89e33e6 | no     | ubuntu 16.04 LTS amd64 (release) (20170721) | x86_64 | 153.94MB | Jul 27, 2017 at 6:50am (UTC) |
+-------------+--------------+--------+---------------------------------------------+--------+----------+------------------------------+
```
- launch additional container

```bash
$ sudo lxc launch mqm/8.0.0.4 mqm2
Creating mqm2
Starting mqm2
$ sudo lxc list
+------+---------+----------------------+-----------------------------------------------+------------+-----------+
| NAME |  STATE  |         IPV4         |                     IPV6                      |    TYPE    | SNAPSHOTS |
+------+---------+----------------------+-----------------------------------------------+------------+-----------+
| mqm  | RUNNING | 10.31.181.111 (eth0) | fd42:f3ba:2c86:9e59:216:3eff:fe16:c38 (eth0)  | PERSISTENT | 0         |
+------+---------+----------------------+-----------------------------------------------+------------+-----------+
| mqm2 | RUNNING | 10.31.181.51 (eth0)  | fd42:f3ba:2c86:9e59:216:3eff:fef0:f59e (eth0) | PERSISTENT | 0         |
+------+---------+----------------------+-----------------------------------------------+------------+-----------+
```
