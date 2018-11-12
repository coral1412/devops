#!/usr/bash
#判断是否为root用户执行脚本
if [ $UID -ne 0 ];then
	echo "Please choose root user execute!"
	exit 1
fi

#定义下载的Python3版本号，以及Python3安装目录
PYTHON_VERSION=3.6.1
PYTHON_DATADIR=/usr/local/python3

#安装Python3的依赖包
yum -y install wget gcc gcc-c++ libffi-devel zlib-devel

#检测Python3目录及Python3.6安装包,如不存在创建目录或下载安装包
if [ ! -d ${PYTHON_DATADIR} ];then
	mkdir -p ${PYTHON_DATADIR}
fi

if [ ! -f /tmp/Python-${PYTHON_VERSION}.tgz ];then
	wget -P /tmp https://www.python.org/ftp/python/${PYTHON_VERSION}/Python-${PYTHON_VERSION}.tgz
fi

#解压缩并编译安装Python3
cd /tmp && tar zxvf Python-${PYTHON_VERSION}.tgz && cd Python-${PYTHON_VERSION}&& ./configure --prefix=${PYTHON_DATADIR} && make && make install 

#创建Python3的软链接并测试Python3是否安装成功
ln -s  ${PYTHON_DATADIR}/bin/python3  /usr/bin/python3.6
ln -s  ${PYTHON_DATADIR}/bin/pip3  /usr/bin/pip3.6

python3=`python3.6 -V` && echo -e  "\e[1;32m $python3 \e[0m"
pip3=`pip3.6 -V` && echo -e "\e[1;32m $pip3 \e[0m"
