#!/bin/bash
#chkconfig 2345 20 80
#rsync 独立进程的脚本
#author:yangyang
if [[ $# -ne 1  ]]
then 
 echo $"usage:$0 {start|stop|restart}"
 exit 1
fi 

case $1 in
"start")
  rsync --daemon
  sleep 2
  if [[ $(netstat -lntup |grep rdync|wc -l ) -ge 1 ]]
  then 
     echo "rsync is started. "
     exit 0
  fi 
;;
"stop")
  killall rsync &>/dev/null
  sleep 2
  if [[  $(netstat -lntup |grep rsync|wc -l ) -eq 0   ]]
  then 
     echo "rsync is stoped"
     exit 0 
  fi 
;;
"restart")
   killall rsync &>/dev/null 
   sleep 2
  if [[  $(netstat -lntup |grep rsync|wc -l ) -eq 0   ]]
  then
   rsync --daemon
   if [[ $(netstat -lntup |grep rdync|wc -l ) -ge 1 ]]
   then
     echo "rsync is restarted. "
     exit 0
   fi 


  fi
;;
esac


