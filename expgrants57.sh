#/bin/bash
# show create user 为5.7版本开始存在，5.6执行报错。

source /etc/profile

pwd=passwd
expgrants57()  
{  
  mysql -B -u'root' -p${pwd} -N    $@ -e "SELECT CONCAT(  'SHOW CREATE USER   ''', user, '''@''', host, ''';' ) AS query FROM mysql.user" | \
  mysql -u'root' -p${pwd} -P3306 -f  $@ | \
  sed 's#$#;#g;s/^\(CREATE USER for .*\)/-- \1 /;/--/{x;p;x;}' 
 
  mysql -B -u'root' -p${pwd} -N    $@ -e "SELECT CONCAT(  'SHOW GRANTS FOR ''', user, '''@''', host, ''';' ) AS query FROM mysql.user" | \
  mysql -u'root' -p${pwd} -P3306 -f  $@ | \
  sed 's/\(GRANT .*\)/\1;/;s/^\(Grants for .*\)/-- \1 /;/--/{x;p;x;}'   
}  

expgrants57 > ./grants57.sql
echo "flush privileges" >>./grants57.sql
