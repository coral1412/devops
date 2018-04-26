#!/bin/bash
#author：fourge
#date：2018/4/25
#update：Installtion for MongoDB ReplSet
#usage：auto_install_mongodb.sh  mongodb-linux-x86_64-rhel62-3.6.4.tgz
#update：
	#v1.1 disable THP,running as the mongodb user;
	

source /etc/profile
if [  "$(whoami)" != 'root'  ];then
    echo "*****Error：You must be root to run this script,Please use root to install*****"
    exit 1
fi

if [ -d "/data/mongodb" ];then
    echo "*****Error："/data/mongodb" directory already exists,Please check the "/data/mongodb" and drop the directory*****"
    exit 1
fi

clear
echo "#################################################################################"
echo "                           Starting Install MongoDB..."
echo "#################################################################################"



/usr/sbin/groupadd mongodb
/usr/sbin/useradd -g mongodb mongodb -s /sbin/nologin

cat >>/etc/security/limits.conf << EOF
mongod soft nofile 1047586
mongod hard nofile 1047586  
mongod soft nproc  524288
mongod hard nproc  524288
EOF

echo never > /sys/kernel/mm/transparent_hugepage/defrag 
echo never > /sys/kernel/mm/transparent_hugepage/enabled
cat >/etc/init.d/disable-transparent-hugepages <<EOF
#!/bin/sh
### BEGIN INIT INFO
# Provides:          disable-transparent-hugepages
# Required-Start:    $local_fs
# Required-Stop:
# X-Start-Before:    mongod mongodb-mms-automation-agent
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Disable Linux transparent huge pages
# Description:       Disable Linux transparent huge pages, to improve
#                    database performance.
### END INIT INFO

case \$1 in
  start)
    if [ -d /sys/kernel/mm/transparent_hugepage ]; then
      thp_path=/sys/kernel/mm/transparent_hugepage
    elif [ -d /sys/kernel/mm/redhat_transparent_hugepage ]; then
      thp_path=/sys/kernel/mm/redhat_transparent_hugepage
    else
      return 0
    fi

    echo 'never' > \${thp_path}/enabled
    echo 'never' > \${thp_path}/defrag

    unset thp_path
    ;;
esac
EOF

chmod 755 /etc/init.d/disable-transparent-hugepages && chkconfig --add disable-transparent-hugepages && chkconfig  disable-transparent-hugepages on

#mkdir data/log/mongodb & keyfile

mkdir -p /data/mongodb/{mongodb,data,log}

echo "8nzsAWzNS3CJ1It9dXqNCrI9dGjnVJ7rjkHKpSgZRJRR5IY44jHlpucQULIdad1Q
5fkry3cj66DHDp4ycP+arMfdERmGnCylIB99J4gmBCH7NweIoC3dADgr3+OL1zq9
7YrPchdeKPcQHB7/DH5fSF4KeHO3ymAnIMjf4xAR7xxA42qH5smoSF7BI3wOLomx
ZrLHGpu29JDy+/EkGH7QWqglrVQsFHdRkFBgUzloxjjBGjCxX6W7/RfHRMYsynqY
/8JVo2WY0sHYoOBdJlYk6Na6gT5pGFiYwGTP0O9Y6KU9bKpHTD2OHpd9R7b42XO6
LKHdIgjYLyOwBp6r3MtHjnZHfJUqcSf1MN16Rg8K++pK4ShL7KiktpwdDvc/jy43
/RRl69g0c9LH7k01ZVF4YJ+EDoyI+w59NbGqDo+wOlEON34++kVMKovqDkSTrDvf
nvqjnAC03bIwdjrgUBc38UdUyqG9r674eI55fBP7XLwdRgAARh8bPCxtX9odW2co
4F7cSSqvemJrQjqbeUHr9uWJoFuEULf1FDyter6WAMC2vYuQib35kS+UXXMq3TR/
18yek/praUajNz0AoAl4obo1goorwwwc6FZgI+QLRQ8S5KCqssZnN7tPAUkd8IWi
CyZIPMuWaFA+WSTN0A4iI+qN1FO4qnYcyF0EygD4nhVhGz0mZ1uZdGqf5BOcg7Jn
R9ARfJ8ZnPVwyZxa+IrDV5+1j+ZIrB/yP+LULFEM5vaIslylhLX/fa0M44CcKEBM
FORwv3H+CiUeEKvwKFV/PaCQ0paHKgG4DIY+7FPVOAQ7XSp8XeHj46lSun0FqU6u
aUs3eF1LxU/WsLoSgbu4tUTWBbxfDU0b6baK8YZIzyqr/k1Cdazi8TN8gxHgX2EV
vNcTJ6Kn0Df+sDciMtcDUNMB9V3yMfkPFDeRGrzlP0Ag2r3bJToXoAbE1VGIy466
dxyKxbNE4tgLMACA+sMVy+kADJcw" >>/data/mongodb/keyfile

chmod 600 /data/mongodb/keyfile


#error logrorate
#--already setting
#use admin ; db.adminCommand( { logRotate : 1 } )

#mongodb conf
cat >/data/mongodb/mongodb.conf <<EOF
systemLog:
  destination: file
  path: "/data/mongodb/log/mongodb.log"
  quiet: false
  traceAllExceptions: true
  logRotate: reopen
  logAppend: true
  timeStampFormat: iso8601-utc
storage:
  dbPath: "/data/mongodb/data/"
  journal:
     enabled: true
  directoryPerDB: true
  indexBuildRetry: false
  engine: wiredTiger
  wiredTiger:
    engineConfig:
      cacheSizeGB: 25
      journalCompressor: snappy
      directoryForIndexes: true
    collectionConfig:
      blockCompressor: snappy
    indexConfig:
      prefixCompression: true
processManagement:
  fork: true
  pidFilePath: "/data/mongodb/mongodb.pid"
net:
  bindIp: `/sbin/ifconfig -a|grep inet|grep -v 127.0.0.1|grep -v inet6|awk '{print $2}'|tr -d "addr:" |head -n 1`
  port: 49019
  maxIncomingConnections: 65535
  wireObjectCheck: true
  http:
    enabled: false
    JSONPEnabled: false
    RESTInterfaceEnabled: false
operationProfiling:
  slowOpThresholdMs: 1000
  mode: slowOp
replication:
  oplogSizeMB: 512
  replSetName: "`hostname |cut -f 1,2 -d '_'`"
  secondaryIndexPrefetch: "all"
security:
  keyFile: /data/mongodb/keyfile
EOF

# untar mongodb.tgz
tar zxvf $1 -C /data/mongodb/mongodb  --strip-components 1

echo "export PATH=$PATH:/data/mongodb/mongodb/bin">>/etc/profile
source /etc/profile

#start mongodb script
if [ -f /etc/init.d/mongod ];then
    cp /etc/init.d/mongod  /etc/init.d/mongodbak`date +%F`
fi

cat >/etc/init.d/mongod <<EOF
#!/bin/bash
# author: fourge
# mongodb boot shell
# MongoDB Startup script
# it is v.1.0 version.
# chkconfig: - 85 15
# processname:mongod 
 
MGDB_PATH="/data/mongodb/mongodb"
MGDB_CONF="/data/mongodb/mongodb.conf"
 
cd \${MGDB_PATH}
 
MGDB_START(){
 
        if [ \`ps -ef|grep 'mongod -f'|grep -v grep|wc -l\` !=  0 ];then
                echo "MongoDB already start"
                exit 1
        fi
    sudo su - mongodb -s /bin/bash -c "\${MGDB_PATH}/bin/mongod -f  \${MGDB_CONF}"
    if [ \$? -eq 0 ];then
        echo -n "MongoDB start "
        echo -n "["
        echo -ne "\033[32m"
        echo -n "Successful"
        echo -ne "\e[0m"
        echo  "]"
    else
        echo "MongoDB start failed"
 
    fi
}
 
MGDB_STOP(){
 
        sudo su - mongodb -s /bin/bash -c "\${MGDB_PATH}/bin/mongod -f  \${MGDB_CONF} --shutdown"
        if [ \$? -eq 0 ];then
                echo -n "MongoDB stop "
                echo -n "["
                echo -ne "\033[32m"
                echo -n "Successful"
                echo -ne "\e[0m"
                echo  "]"
        else
                echo "MongoDB  already stopped"

        fi
}
 
MGDB_STATUS(){
 
    if [ \`ps -ef|grep 'mongod -f'|grep -v grep |wc -l\` = 0  ];then
    #if [ \$? != 0 ];then
        echo -n "MongoDB is "
	echo -n "["
	echo -ne "\033[31m"
	echo -n " Stopped"
	echo -ne "\e[0m "
	echo "]"
    else
	echo -n "MongoDB is"
        echo -n "["
	echo -ne "\033[32m"
	echo -n " Running"
	echo -ne "\e[0m "
        echo "]"
    fi
}
 
case "\$1" in 
    start)
        MGDB_START
        ;;
    stop)
        MGDB_STOP
        ;;
    status)
        MGDB_STATUS
        ;;
    restart)
        MGDB_STOP
        MGDB_START
        ;;
    *)
        echo $"Usage: \$0 { start | stop | status | restart }"
        exit 1
esac
EOF

chmod +x /etc/init.d/mongod && chkconfig --add  mongod && chkconfig mongod on

#starting mongod
chown -R mongodb:mongodb  /data/mongodb
#sudo su - mongodb -s /bin/bash  /etc/init.d/mongod start
sudo su - mongodb -s /bin/bash -c "/data/mongodb/mongodb/bin/mongod -f  /data/mongodb/mongodb.conf"
