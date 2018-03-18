#!/bin/bash
#author：fourge
#date：2017/12/5
#update：参数输入改成参数输入，因为参数传递的问题，auto_mysql()去掉了。
#usage：bash   auto_install_mysql.sh  999  1G   Percona-Server-5.6.37-rel82.2-Linux.x86_64.ssl101.tar.gz   5.6
source /etc/profile
if [ $(id -u ) !="0"];then
    echo "Error：You must be root to run this script,Please use root to install"
    exit 1
fi

clear
echo "#################################################################################"
echo "#################################################################################"
# cur_dir=$(pwd)

MySQL_HOME=/usr/local/mysql
MySQL_DATA=/data/mysql/data
#MySQL_TAR=Percona-Server-5.6.37-rel82.2-Linux.x86_64.ssl101.tar.gz
#MySQL_TAR=Percona-Server-5.7.18-16-Linux.x86_64.ssl101.tar.gz
#read -p "Please input MySQL Version:" MySQL_TAR
MySQL_CONF=/etc/my.cnf
MySQL_USER=mysql

#set importance conf
echo "set importance conf"
#read -p "Please input SERVER_ID:" SERVER_ID
#read -p "Please input InnoDB Buffer Pool Size:" IBPS


#logrotate for errorlog&slowlog

#check mysqld and remove old mysql
/etc/init.d/mysqld  stop 
rpm -qa|grep mysql
rpm -e [Mm]ysql
rpm -e [Pp]ercona
rpm -e [Mm]ariaDB

#install package dependency
yum install -y perl-Data-Dumper.x86_64  numactl  libaio perl #CentOS-7.2.1511
yum install -y perl-Data-Dumper.x86_64 numactl  libaio  perl #CentOS-7.2.1511  

#Selinux  & Iptables
setenforce 0
# /etc/init.d/iptables stop 

#install_mysql(){
/usr/sbin/groupadd mysql
/usr/sbin/useradd -g mysql mysql -s /sbin/nologin

#backup old my.cnf & create new my.cnf
if [ -s /etc/my.cnf ];then
    mv /etc/my.cnf   /etc/my.cnf.`date +%F`.bak
fi
cat >/etc/my.cnf <<EOF
[client]
port = 3456
socket = /data/mysql/mysql.sock
default-character-set = utf8

[mysqld]
##################Basic#####################
port = 3456
socket  = /data/mysql/mysql.sock
basedir = /usr/local/mysql
datadir = /data/mysql/data
character_set_server=utf8
back_log = 500
open-files-limit = 8192
autocommit = 1
transaction_isolation = READ-COMMITTED
skip_name_resolve = 1
federated
skip-ssl
default-storage-engine = InnoDB
lower_case_table_names=1
binlog_format=row
max_connections = 1000
max_connect_errors = 5000
table_open_cache = 2048
max_heap_table_size = 64M
thread_cache_size = 64
explicit_defaults_for_timestamp = 1
log_bin_trust_function_creators = 1
join_buffer_size = 8M
tmp_table_size = 64M
tmpdir = /tmp
max_allowed_packet = 32M
sql_mode = 'NO_AUTO_VALUE_ON_ZERO,STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION,PIPES_AS_CONCAT,ANSI_QUOTES'
wait_timeout = 600
sort_buffer_size = 8M
##################Replication#####################
server-id = $1
#server-id = $SERVER_ID
master_info_repository = TABLE
relay_log_info_repository = TABLE
max_relay_log_size = 1024M
relay_log_purge = 1
sync_relay_log = 0
sync_relay_log_info = 0
log_slave_updates = 1
binlog-checksum = CRC32
master-verify-checksum = 0
slave-sql-verify-checksum = 0
relay_log = relay.log
relay_log_recovery = 1
slave_skip_errors = ddl_exist_errors
##################Logfile#########################
log-error = /data/mysql/errorlog/error.log
slow_query_log = 1
slow_query_log_file = /data/mysql/slowlog/slow.log
long_query_time = 0.2
log-bin = /data/mysql/binlog/mysql-bin
binlog_cache_size = 4M
sync_binlog = 1
max_binlog_cache_size = 4096M
max_binlog_size = 1024M
expire_logs_days = 7
#################Innodb############################
innodb_page_size = 16K
innodb_buffer_pool_size = $2
#innodb_buffer_pool_size = $IBPS
innodb_read_io_threads = 8
innodb_write_io_threads = 8
innodb_flush_log_at_trx_commit = 1
innodb_file_per_table = 1
innodb_max_dirty_pages_pct = 80
innodb_buffer_pool_instances = 2
innodb_buffer_pool_load_at_startup = 1
innodb_buffer_pool_dump_at_shutdown = 1
innodb_lock_wait_timeout = 60
innodb_io_capacity = 1000
innodb_io_capacity_max = 4000
innodb_flush_method = O_DIRECT
innodb_log_files_in_group = 3
innodb_log_group_home_dir = /data/mysql/data
innodb_undo_directory = /data/mysql/data
innodb_undo_logs = 128
innodb_undo_tablespaces = 3
innodb_flush_neighbors = 1
innodb_log_file_size = 1024M
innodb_log_buffer_size = 32M
innodb_purge_threads = 4
innodb_large_prefix = 1
innodb_thread_concurrency = 0
innodb_print_all_deadlocks = 1
innodb_sort_buffer_size = 8M
###################Myisam#########################
key_buffer_size = 16M
read_buffer_size = 8M
read_rnd_buffer_size = 64M
bulk_insert_buffer_size = 64M
myisam_sort_buffer_size = 64M
myisam_repair_threads = 1
myisam_recover_options = backup,force
###################Others##########################
gtid_mode = on
enforce_gtid_consistency = 1
binlog_gtid_simple_recovery = 1
log_slave_updates = 1
skip_slave_start = 1

[mysqldump]
quick
max_allowed_packet = 32M

[mysql]
no-auto-rehash
prompt="\u@\h:\d>"

[myisamchk]
key_buffer_size = 16M
sort_buffer_size = 16M
read_buffer = 8M
write_buffer = 8M

[mysqlhotcopy]
interactive-timeout

EOF
#wget Perconaxxx.tar.gz
#wget  $Percona_Download_Url  -P /data/soft/ 

#OS adjust and optimize
#/etc/security/limits.d/20-nproc.conf

#/etc/security/limits.conf 
cat >>/etc/security/limits.conf<<EOF
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

#hosts
#hostnamectl --static $HOSTNAME   #CentOS7
#echo "$HOSTNAME" >>/etc/sysconfig/network
#echo "$IP  $HOSTNAME" >>/etc/hosts


#mkdir $MySQL_DATA、LOGDIR and chown 
if [ ! -d "/data/mysql" ];then
    mkdir  -p /data/mysql/{data,errorlog,binlog,slowlog}  && chown -R mysql:mysql  /data/mysql
else
    rm -rf /data/mysql;mkdir  -p /data/mysql/{data,errorlog,binlog,slowlog}  && chown -R mysql:mysql  /data/mysql
fi


#uncompress PerconaXX.tar.gz to $MySQL_HOME 
if [ ! -d "/usr/local/mysql" ];then
    mkdir /usr/local/mysql
else
    rm -rf /usr/local/mysql;mkdir /usr/local/mysql
fi
echo $3
tar zxvf $3  -C /usr/local/mysql  --strip-components 1 
#tar zxvf $MySQL_TAR  -C /usr/local/mysql --strip-components 1 
chown -R mysql:mysql /usr/local/mysql 

#copy /etc/init.d/mysqld
cp $MySQL_HOME/support-files/mysql.server  /etc/init.d/mysqld
chmod 700 /etc/init.d/mysqld
chkconfig --add mysqld
chkconfig --level 2345 mysqld on

#initialize mysql5.6
initialize="6"
echo "is install mysql5.6 or mysql5.7?"
#read -p "Please input 6 or 7:" initialize
case "$4" in
#case "$initialize" in
6|5.6|56)
$4="6"
#initialize="6"
echo "your input is 5.6,you will initialize mysql5.6..."
$MySQL_HOME/scripts/mysql_install_db  --defaults-file=$MySQL_CONF --user=$MySQL_USER --basedir=$MySQL_HOME  --datadir=$MySQL_DATA
;;
7|5.7|57)
$4="7"
#initialize="7"
echo "your input is 5.7,you will initialize mysql5.7..."
$MySQL_HOME/bin/mysqld  --initialize-insecure   --user=$MySQL_USER --basedir=$MySQL_HOME  --datadir=$MySQL_DATA
;;
*)
echo "your input error,you will abort initialize mysql..."
exit
;;
esac


#chown  mysql again
chown -R mysql:mysql  /data/mysql
chown -R mysql:mysql /usr/local/mysql

#starting  mysql and set root password
/etc/init.d/mysqld  start 
echo "export PATH=$PATH:$MySQL_HOME/bin">>/etc/profile  && source /etc/profile

/usr/local/mysql/bin/mysqladmin -u root password 'passwd'

#}
#install_mysql

##install master or slave or single mysql
#echo "#####################install master or slave or single mysql #########################"
#echo "######################################################################################"
#isinstallmaster="s"
#echo "Install MySQL Master,Please input m/M ,Install MySQL Slave,Please input s/S,Install MySQL Single,Please input 1/single"
#read -p "Please input m/M or s/S:" isinstallmaster
#
#case "$isinstallmaster" in
#[mM]) 
#isinstallmaster="m"
#echo "your input is m,you will only install mysql master..."
#read -p "Please input replication netmask:" REPL_NETMASK
#/usr/local/mysql/bin/mysql -uroot -ppasswd -e "grant replication slave on *.* to repl@'$REPL_NETMASK' identified by 'passwd'"
#;;
#[sS])
#isinstallmaster="s"
#echo "your input is s,you will install mysql slave..."
#echo -e "Please input the master messages:" 
#read -p "Please input the master_host:" MASTER_IP
#read -p "Please input the master_port:" MASTER_PORT
#read -p "Please input the repl_user:" REPL_USER
#read -p "Please input the repl_password:" REPL_PASSWORD
#/usr/local/mysql/bin/mysql -u root -ppasswd  -e "change master to master_host='$MASTER_IP',master_port=$MASTER_PORT,master_user='$REPL_USER',master_password='$REPL_PASSWORD',master_auto_position=1;"
#/usr/local/mysql/bin/mysql -uroot -ppasswd -e "start slave;"
#;;
#*)
#echo "your input error,you will only install a single mysql..."
#exit
#;;
#esac
#}
#install_mysql