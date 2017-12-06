#!/bin/bash
#author:fourge
#date:2017/12/6
#readme: auto install mha manager/node
#usage：bash   auto_mha.sh  [n|N|node]/[m|M|manager]
#auto_install_mysql执行在先

#useradd mysqlmha
groupadd mysqlmha
useradd -g mysqlmha  mysqlmha
echo "1Ku0NpOZulcwiApTA==" |passwd --stdin "mysqlmha"

#config ssh   --未完成
yum install -y expect
auto_ssh_copy_id(){
	expect -c "set timeout -1
		spawn ssh-copy-id mysqlmha
	



"
}

echo "mysqlmha ALL=(root) NOPASSWD:/sbin/ifconfig" >>/etc/sudoers

#config epel iptables/firewalld.service  selinux
mv /etc/yum.repos.d/epel.repo /etc/yum.repos.d/epel.repo.backup
mv /etc/yum.repos.d/epel-testing.repo /etc/yum.repos.d/epel-testing.repo.backup
yum install -y wget

osversion=`cat /etc/redhat-release  |awk -F ' ' '{print $4}' |awk -F '.' '{print $1}'`
case "$osversion" in
7)
echo "your os version is 7"
/etc/init.d/iptables stop  && chkconfig iptables off &&  setenforce 0
wget -O /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-7.repo
#echo "$hostname" >>/etc/sysconfig/network
;;
6)
echo "your os version is 6"
systemctl stop firewalld.service  && systemctl disable firewalld.service  && setenforce 0
wget -O /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-6.repo
#hostname set-hostname $hostname
;;
esac
exit 0

#echo -e "ip1    hostname1 \nip2    hostname2\nip3    hostname3" >>/etc/hosts 
echo -e "192.168.111.22   hhlysz-chatsql01 \n192.168.111.23   hhlysz-chatsql02 \n192.168.111.24   hhlysz-chatsql03"  >>/etc/hosts


#MHA mysql user  ##应该在auto_install_mysql中实现，auto_install_mysql执行在先
#/usr/local/mysql/bin/mysql -uroot -p"passwd" -e "grant all privileges on *.* to 'masterha'@'172.16.16.%' identified by ' passwd';"
#/usr/local/mysql/bin/mysql -uroot -pudFdxE#hhly -e "grant all privileges on *.* to 'masterha'@'192.168.111.%' identified by 'mysqlmhapasswd';"


#install mha manager/node
case $1 in
node|n|N)
echo "current host role is node..."
yum localinstall  -y mha4mysql-node-0.56-0.el6.noarch.rpm
;;

manager|m|M)
echo "current host role is mha manager..."
yum localinstall  -y mha4mysql-node-0.56-0.el6.noarch.rpm
yum localinstall  -y mha4mysql-manager-0.56-0.el6.noarch.rpm
mkdir -p  /etc/conf/mysqlmha
mkdir -p /mysqlmha/mha/  && chown -R mysqlmha:mysqlmha  /mysqlmha/mha
;;
*)
echo "your input is error,please try enter correct role..."
;;
esac
