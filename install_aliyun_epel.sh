#/bin/bash
mv /etc/yum.repos.d/epel.repo /etc/yum.repos.d/epel.repo.backup
mv /etc/yum.repos.d/epel-testing.repo /etc/yum.repos.d/epel-testing.repo.backup
osversion=`uname -r |awk -F - '{print $2}' |awk -F . '{print $2}'`
#osversion=`lsb_release -r |awk   '{print $2}'  |awk -F . '{print $1}'`
if [ $osversion == 'el5' ];then
  wget -O /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-5.repo
elif [ $osversion == 'el6' ];then
  wget -O /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-6.repo
elif [ $osversion == 'el7' ];then
  wget -O /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-7.repo
else
  echo "匹配不到你当前系统版本的EPEL源"
fi
yum clean all && yum makecache