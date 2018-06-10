auto  scripts
====
* [auto_install_msyql.sh](https://github.com/coral1412/devops/blob/master/auto_install_mysql.sh)

分分钟自动化可定制安装MySQL5.6和5.7，包括单实例，从库以及主从飞速部署（从库当前仅支持GTID），一个脚本搞定。

* [auto_install_msyql_2.3.sh](https://github.com/coral1412/devops/blob/master/auto_install_mysql_2.3.sh)

上述auto_install_mysql.sh手动自定义输入参数变量改成脚本命令参数输入。

* [expgrants.sh](https://github.com/coral1412/devops/blob/master/expgrants.sh)

用于MySQL系统用户及权限备份/导出。

* [mysql_check.sh](https://github.com/coral1412/devops/blob/master/mysql_check.sh)

用于检测一个MySQL实例不合理的地方,包括但不限于表存储引擎以及表注释以及用户权限等。

* [auto_install_pyenv_virtualenv.sh](https://github.com/coral1412/devops/blob/master/auto_install_pyenv_virtualenv.sh)

用于安装virtualenv、virtualenvwrapper以及pyenv,并初始化一个指定版本的Python及项目虚拟环境<br>
usage：source auto_install_pyenv_virtualenv.sh  python_version  virtualenvname

* [install_aliyun_epel.sh](https://github.com/coral1412/devops/blob/master/install_aliyun_epel.sh)

根据系统版本安装阿里云的EPEL YUM源的脚本