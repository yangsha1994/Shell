#!/bin/bash
#监控进程运行
#author:yangyang


if [[ $(netstat -lntup |grep mysqld |wc -l )  -gt 0 ]]
then 
   echo "Mysql is Running."
else
   echo "Mysql is not Running"
   /etc/init.d/msyqld start 
fi

