#!/bin/bash 
#模拟keepalive
VIP=192.168.0.211
PORT=80
ipvstools=$(rpm -qa ipvsadm |wc -l )
if [[ $ipvstools -ne 1  ]]
then 
    yum install ipvsadm  -y 

fi


while true 
do
   ping -w2 -c2 $(VIP) >/dev/null 2>&1
   if [[ $? -ne 0  ]]
   then 
       /bin/sh ipvs start
   else
      /bin/sh ipvs stop
   fi
   sleep 5 
done
