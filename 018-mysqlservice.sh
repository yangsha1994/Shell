#!/bin/bash
#chkconfig 2345 20 80
#mysql 启动脚本
#author:yangyang

#变量
PORT=3306
MYSQLUSER="root"
MYSQLPASS="hylink"
SOCKERT="/var/lib/mysql/mysql.socket"
CMDDIR="/xfdata/soft/pxc/bin/"

#判断参数个数
if [[ $# -ge 1  ]]
then 
    
echo $"usage:$0 {start|stop|status|restart}"
    exit 1
fi 

#函数

function start(){
    if [[ $(netstat -lntup |grep mysql |wc -l )  -eq 0  ]]
    then
        printf "starting Mysql ......"
        /bin/sh $CMDDIR/mysqld_safe 
    else
        echo "Mysql is runing."
    fi    

}

function stop(){
    if [[ $(netstat -lntup |grep mysql |wc -l )  -eq  0  ]]
    then 
       echo  "Mysql is stop"
    else
       killall mysql 
    fi

}

function status(){
  if [[ $(netstat -lntup |grep mysql |wc -l )  -eq  0  ]]
  then
     echo "mysql is not runing."
  else
     echo "mysql is runing "
  fi
   
}

function restart(){
   stop
   sleep 5
   start 
}

case $1 in 
start)
    start;;
stop)
    stop;;
status)
    status;;
restart)
    restart;;
esac




