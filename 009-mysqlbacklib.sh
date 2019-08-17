#!/bin/bash
#mysql 分库备份
#author:yangyang

PATH="/xfdata/soft/mysql/bin";
Back_Path='/data/mysql/back/';
#数据库用户以及密码
Mysql_User="rooy";
Mysql_Passwd='hylink';
Mysql_Socket='/var/lib/mysql/mysql.sock';

CMDLogin="mysql -u$Mysql_User -p$Mysql_Passwd -s $Mysql_Socket";

CMDDump="mysqldump -u$Mysql_User -p$Mysql_Passwd -s $Mysql_Socket"
#创建备份目录
[[ ! -d $Back_Path ]] && mkdir -p $Back_path

for dbname   in  $($CMD_Login -e "show databases;" |sed '1,2d '| egrep -v "mysql|schema");
do
    mkdir $Back_Path'/'$(dbname)'_'$(date +%F) -p
    for table  in $($CMD_Login -e "show tables from $dbname" |sed '1d' )
    do
        $CMD_Dump $dbname $table  |gzip > $Back_Path'/'$dbname'_'$(date +%F)'/'$(dbname)'_'$table.sql.gz
    done
done
