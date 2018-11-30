#!/bin/bash
#author: fourge
#date: 2018/11
#useage:  bash    install_mysql_smy_V0.1.sh  

SERVER_ID=`/sbin/ifconfig -a|grep inet|grep -v 127.0.0.1|grep -v inet6|awk '{print $2}'|tr -d "addr:" |awk -F'.' '{print $3$4}'`
INNODB_BUFFER_POOL=`awk '($1 == "MemTotal:"){print $2/1024/1024*0.7}' /proc/meminfo  |awk -F . '{print $1}'`G


 
source /etc/profile
if [ $(id -u ) !="0"];then
    echo "Error: You must be root to run this script,Please use root to install"
    exit 1
fi

clear
echo "######################STARTING Install MySQL...############################"

MySQL_HOME=/usr/local/mysql
MySQL_DATA=/data/3306/data
MySQL_CONF=/etc/my.cnf
MySQL_USER=mysql

#stop Selinux  & Iptables 
setenforce 0
/etc/init.d/iptables stop  &&  chkconfig iptables off

#create mysql user
/usr/sbin/groupadd mysql
/usr/sbin/useradd -g mysql mysql -s /sbin/nologin

#backup old my.cnf & create new my.cnf
if [ -s /etc/my.cnf ];then
    mv /etc/my.cnf   /etc/my.cnf.`date +%F`.bak
fi
cat >/etc/my.cnf <<EOF
##### /etc/mysql/my.cnf                   ####
###  Part 1 basic settings                   ###
###  Part 2 logsettings                     ###
###  Part 3 replication settings               ###
###  Part 4 innodb settings                  ###

[mysql]
prompt=(\\u@\\h) [\\d]>
max_allowed_packet             = 64M
no_auto_rehash

[mysqld]
########basic settings########

server-id = $SERVER_ID
port = 3306
user = mysql
socket = /tmp/mysql.sock
autocommit = 1
character_set_server=utf8
skip_name_resolve = 1
max_connections = 512
max_connect_errors = 10
open_files_limit=65565
innodb_open_files=2048

#init-connect='INSERT INTO PERCONA.T_LOGIN_INFO VALUES(NULL,CONNECTION_ID(),NOW(),USER(),CURRENT_USER());'

basedir= /usr/local/mysql/
datadir = /data/3306/data
tmpdir = /data/3306/tmp

transaction_isolation = READ-COMMITTED
sql_mode = "STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION"
read_buffer_size = 2097152
read_rnd_buffer_size = 2097152
sort_buffer_size = 2097152
join_buffer_size = 2097152
tmp_table_size = 67108864
max_allowed_packet = 64M
query_cache_size = 0
query_cache_type = 0
lower_case_table_names=1

########log settings########
log_error = /data/3306/log/error.log
log_timestamps = SYSTEM
slow_query_log = 1
log_queries_not_using_indexes  = 0
slow_query_log_file = /data/3306/log/slow.log
log_slow_admin_statements = 1
log_slow_slave_statements = 1
expire_logs_days = 7
long_query_time = 1

########replication settings########
master_info_repository = TABLE
relay_log_info_repository = TABLE
log_bin =/data/3306/binlog/mysql-bin
sync_binlog = 1
binlog_format = row
relay_log = /data/3306/binlog/relay.log
relay_log_recovery = 1
#relay_log_purge = 0
#slave_parallel_workers = 5
skip_slave_start = 1
log_slave_updates    = 1 
slave-parallel-type=LOGICAL_CLOCK
slave_parallel_workers = 4

########innodb settings########
innodb_buffer_pool_size = $INNODB_BUFFER_POOL
innodb_buffer_pool_instances = 8
innodb_buffer_pool_load_at_startup = 1
innodb_buffer_pool_dump_at_shutdown = 1
innodb_lru_scan_depth = 2000
innodb_lock_wait_timeout = 120
innodb_io_capacity = 8000
innodb_io_capacity_max = 12000
innodb_flush_method = O_DIRECT
innodb_flush_log_at_trx_commit = 1
innodb_file_format=Barracuda
innodb_log_group_home_dir = /data/3306/redo
innodb_undo_directory = /data/3306/undo
innodb_undo_logs = 128
innodb_undo_tablespaces = 3 
#innodb_flush_neighbors = 0
innodb_log_file_size = 1G
innodb_log_buffer_size = 16777216
innodb_purge_threads = 4
innodb_large_prefix = 1
innodb_print_all_deadlocks = 1
#innodb_strict_mode = 1

########other settings########
key_buffer_size                = 256M
#myisam_recover                = BACKUP,FORCE
max_heap_table_size            = 67108864

[mysqldump]
max_allowed_packet             = 64M

[client]
port                           = 3306
socket                         = /tmp/mysql.sock

EOF


#/etc/security/limits.conf 
cat >/etc/security/limits.conf<<EOF
*               soft     nofile         1048576
*               hard     nofile         1048576
*               soft     nproc          65535
*               hard     nproc          65535
mysql           soft     nproc          65535
mysql           hard     nproc          65535
EOF

#/etc/sysctl.conf
cat >/etc/sysctl.conf<<EOF
# System default settings live in /usr/lib/sysctl.d/00-system.conf.
# To override those settings, enter new settings here, or in an /etc/sysctl.d/<name>.conf file
#
# For more information, see sysctl.conf(5) and sysctl.d(5).
net.ipv4.conf.default.rp_filter = 1
net.ipv4.conf.default.accept_source_route = 0
kernel.sysrq = 0
kernel.core_uses_pid = 1
net.ipv4.tcp_syncookies = 1
kernel.msgmnb = 65536
kernel.msgmax = 65536
kernel.shmmax = 68719476736
kernel.shmall = 4294967296
net.ipv4.tcp_max_tw_buckets = 20000
net.ipv4.tcp_sack = 1
net.ipv4.tcp_window_scaling = 1
net.ipv4.tcp_rmem = 4096        87380   4194304
net.ipv4.tcp_wmem = 4096        16384   4194304
net.core.wmem_default = 8388608
net.core.rmem_default = 8388608
net.core.rmem_max = 16777216
net.core.wmem_max = 16777216
net.core.netdev_max_backlog = 262144
net.ipv4.tcp_max_orphans = 3276800
net.ipv4.tcp_max_syn_backlog = 262144
net.ipv4.tcp_timestamps = 0
net.ipv4.tcp_synack_retries = 1
net.ipv4.tcp_syn_retries = 1
net.ipv4.tcp_tw_recycle = 1
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_mem = 94500000 915000000 927000000
net.ipv4.tcp_fin_timeout = 20
net.ipv4.tcp_keepalive_time = 30
net.ipv4.ip_local_port_range = 1024    65000
vm.overcommit_memory = 1
vm.swappiness = 20
vm.vfs_cache_pressure = 200
vm.zone_reclaim_mode = 0
##add 
vm.dirty_background_ratio=5
vm.dirty_ratio=10
##
net.ipv4.ip_forward = 0
net.ipv4.conf.all.arp_ignore = 1
net.ipv4.conf.all.arp_announce = 2
EOF


#mkdir $MySQL_DATA¡¢LOGDIR and chown 
if [ ! -d "/data/3306" ];then
    mkdir  -p /data/3306/{log,data,binlog,tmp,undo,redo}  && chown -R mysql:mysql  /data/3306
else
    rm -rf /data/3306;mkdir  -p /data/3306/{log,data,binlog,tmp,undo,redo}  && chown -R mysql:mysql  /data/3306
fi

wget -P /tmp   http://192.168.100.101/mysql-5.7.24-linux-glibc2.12-x86_64.tar.gz  

#uncompress mysql.tar.gz to MySQL_HOME
if [ ! -d "/usr/local/mysql" ];then
    mkdir /usr/local/mysql
else
    rm -rf /usr/local/mysql;mkdir /usr/local/mysql
fi

tar zxvf  /tmp/mysql-5.7.24-linux-glibc2.12-x86_64.tar.gz  -C /usr/local/mysql  --strip-components 1
  
#tar zxvf $MySQL_TAR  -C /usr/local/mysql --strip-components 1 
chown -R mysql:mysql /usr/local/mysql 

#copy /etc/init.d/mysqld
cp $MySQL_HOME/support-files/mysql.server  /etc/init.d/mysqld
chmod 700 /etc/init.d/mysqld
#chkconfig --add mysqld
#chkconfig --level 2345 mysqld on

#initiate mysql5.7
$MySQL_HOME/bin/mysqld  --initialize-insecure   --user=$MySQL_USER --basedir=$MySQL_HOME  --datadir=$MySQL_DATA

#chown  mysql again
chown -R mysql:mysql  /data/3306
chown -R mysql:mysql  /usr/local/mysql

#starting  mysql and set root password
/etc/init.d/mysqld  start 
echo "export PATH=$PATH:$MySQL_HOME/bin">>/etc/profile  
source /etc/profile

/usr/local/mysql/bin/mysqladmin -u root password 'passwd'
