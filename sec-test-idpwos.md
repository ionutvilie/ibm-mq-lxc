# Test MQ IDPWOS in lxc

References:
 - [CHLAUTH Made Simple](http://www-01.ibm.com/support/docview.wss?uid=swg27041997&aid=1)

## Prerequisites
 - install MQExplorer on Host

## On lxc mqm

```bash
$ sudo lxc exec mqm bash
# root@mqm:~#
groupadd ionut
useradd --gid ionut --home /home/ionut ionut --shell /bin/bash
passwd ionut
su - mqm
# mqm@mqm:~$
crtmqm QMGR01
strmqm QMGR01
runmqsc QMGR01
```

runmqsc copy / paste in the above shell

```mqsc
def listener(SYSTEM.DEFAULT.LISTENER.TCP) TRPTYPE(TCP) CONTROL(QMGR) PORT(1414) REPLACE
start listener(SYSTEM.DEFAULT.LISTENER.TCP)
def chl(SYSTEM.ADMIN.SVRCONN) chltype(SVRCONN) MCAUSER(' ') replace

* block everything
SET CHLAUTH ('*') TYPE(ADDRESSMAP) ADDRESS('*') USERSRC(NOACCESS)
SET CHLAUTH('SYSTEM.ADMIN.SVRCONN') TYPE(blockuser) +
DESCR('Rule to override *MQADMIN blockuser on this channel') +
USERLIST('nobody') ACTION(replace)

SET CHLAUTH('SYSTEM.ADMIN.SVRCONN') TYPE(USERMAP) +
CLNTUSER('ionut') USERSRC(MAP) MCAUSER('mqm') +
ADDRESS('10.31.181.1') +
DESCR('Allow ionut as mqm') ACTION(replace)

REFRESH SECURITY

* DISPLAY CHLAUTH(SYSTEM.ADMIN.SVRCONN) MATCH(RUNCHECK) CLNTUSER('ionut') ADDRESS('10.31.181.1')
*      6 : DISPLAY CHLAUTH(SYSTEM.ADMIN.SVRCONN) MATCH(RUNCHECK) CLNTUSER('ionut') ADDRESS('10.31.181.1')
* AMQ8878: Display channel authentication record details.
*    CHLAUTH(SYSTEM.ADMIN.SVRCONN)           TYPE(USERMAP)
*    ADDRESS(10.31.181.1)                    CLNTUSER(ionut)
*    MCAUSER(mqm)           
*
* DISPLAY CHLAUTH(SYSTEM.ADMIN.SVRCONN) MATCH(RUNCHECK) CLNTUSER('alice') ADDRESS('10.31.181.1')
*     7 : DISPLAY CHLAUTH(SYSTEM.ADMIN.SVRCONN) MATCH(RUNCHECK) CLNTUSER('mircea') ADDRESS('10.31.181.1')
* AMQ8878: Display channel authentication record details.
*    CHLAUTH(SYSTEM.*)                       TYPE(ADDRESSMAP)
*    ADDRESS(*)                              USERSRC(NOACCESS)

```

## On localhost

- start MQExplorer
- add remote Queue Manager
  - qmgr:QMGR01 
  - IP:10.31.181.111 | IP from lxc list
  - Port:1414
  - UserId:ionut   pass from local container user <save or prompt>
