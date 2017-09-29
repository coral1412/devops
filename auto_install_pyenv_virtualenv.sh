#!/bin/bash
#ENV：CentOS 7
#AUTHOR：fourge
#DATE:2017/09/25
source /etc/profile
pyver=$1
virname=$2
echo '----------step one----------'
#install pip
rpm -qa |grep pip 1>/dev/null
if [ $? -ne 0 ];then
    #yum install -y python-pip
    echo "pip is already exists"
else
    curl https://bootstrap.pypa.io/get-pip.py |python  # ||yum -y install epel-release && yum install -y python-pip
fi

#配置豆瓣pypi镜像
if [ ! -d /root/.pip ];then
    mkdir /root/.pip 
else
    echo "/root/.pip already exists"
fi 
cat>>/root/.pip/pip.conf<<EOF
[global]
index-url=https://pypi.doubanio.com/simple
format=columns
EOF

echo "----------step two----------"
echo "install pyenv"
yum -y install zlib-devel bzip2 bzip2-devel readline-devel sqlite sqlite-devel openssl-devel  gcc  gcc-c++ patch git

curl -L https://raw.githubusercontent.com/yyuu/pyenv-installer/master/bin/pyenv-installer | bash

echo 'export PATH="/root/.pyenv/bin:$PATH"'>>~/.bash_profile
echo 'eval "$(pyenv init -)"' >>~/.bash_profile
echo 'eval "$(pyenv virtualenv-init -)"' >>~/.bash_profile
#exec $SHELL -l
source ~/.bash_profile

echo '----------step three----------'
echo "install virtualenv & virtualenvwrapper"
if [ ! -d /data/virtualenv ];then
    mkdir -p /data/virtualenv
fi
pip install virtualenv
pip install virtualenvwrapper
export VIRTUALENVS_HOME=/data/virtualenv
mkdir -p $VIRTUALENVS_HOME/workspace
cat>>/root/.bash_profile<<EOF
export WORKON_HOME=$VIRTUALENVS_HOME/.virtualenvs
export PROJECT_HOME=$VIRTUALENVS_HOME/workspace
source `which virtualenvwrapper.sh`
EOF
source ~/.bash_profile

pyenv install -v $pyver
mkproject -p  /root/.pyenv/versions/"$pyver"/bin/python $virname

