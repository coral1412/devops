#!/bin/bash
#author:fourge
#date:2017/09/10 2：00

source /etc/profile
PASSWD=passwd
MYSQL_SOCK=/data/mysql/mysql.sock
if [ ! -d checkdir ];then
    mkdir checkdir
	CHECK_DIR=checkdir
else
	rm -rf checkdir;
	mkdir checkdir;CHECK_DIR=checkdir
fi

#检测用户是否有%用户
mysql -uroot -p$PASSWD -S $MYSQL_SOCK -e "select host,user from mysql.user where host='%';"  >./$CHECK_DIR/host_user.txt  2>&1

#存储引擎不为innodb
mysql -uroot -p$PASSWD -S $MYSQL_SOCK -e "select table_schema,table_name,engine from information_schema.tables where table_schema not  in('sys','test','performance_schema','mysql','information_schema') and engine  not in('innodb')"  >./$CHECK_DIR/not_innodb.txt  2>&1
## database 需要过滤mysql，information_schema，performance_schema,[sys]等

#表和列没有注释的
mysql -uroot -p$PASSWD -S $MYSQL_SOCK -e "select table_schema,table_name,table_comment from information_schema.tables where table_comment='' and table_schema not  in('sys','test','performance_schema','mysql','information_schema')"  >./$CHECK_DIR/table_comment_isnull.txt 2>&1


#查看表的字符集和排序规则
#mysql -uroot -p$PASSWD -S $MYSQL_SOCK -e "select table_schema,table_name,TABLE_COLLATION  from tables where table_schema not in ('sys','test','performance_schema','mysql','information_schema') ;"

#column
mysql -uroot -p$PASSWD -S $MYSQL_SOCK -e "select table_schema,table_name,CHARACTER_SET_NAME,COLLATION_NAME,COLUMN_name from information_schema.columns where table_schema not in ('sys','test','performance_schema','mysql','information_schema')"


#修改字段的排序规则
#mysql -uroot -p$PASSWD -S $MYSQL_SOCK -e "SELECT * FROM (SELECT CONCAT( 'ALTER TABLE `', table_name,'` MODIFY `', column_name, '` ',DATA_TYPE,'(',CHARACTER_MAXIMUM_LENGTH,') CHARACTER SET UTF8 COLLATE utf8_bin',(CASEWHEN IS_NULLABLE = 'NO' THEN' NOT NULL'ELSE '' END)，';') NAMEFROMinformation_schema. COLUMNSWHERETABLE_SCHEMA  not in('sys','mysql','test','information_schema','performance_schema')) t;"
