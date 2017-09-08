#!/bin/bash
#export mysql.user & grant,normal used to  data migration
#author:fourge
#date:2017/09/09 0:39

source /etc/profile
PASSWD=passwd
MYSQL_SOCK=/data/mysql/mysql.sock

expgrants(){
   mysql -B -uroot -p$PASSWD -N -S $MYSQL_SOCK    -e "SELECT CONCAT(  'SHOW GRANTS FOR ''', user, '''@''', host, ''';' ) AS query FROM mysql.user where user <>'root'"  |mysql -uroot -p$PASSWD -S $MYSQL_SOCK  $@ |   sed 's/\(GRANT .*\)/\1;/;s/^\(Grants for .*\)/-- \1 /;/--/{x;p;x;}' 
}
expgrants >./grants.sql
echo "flush privileges" >>./grants.sql
