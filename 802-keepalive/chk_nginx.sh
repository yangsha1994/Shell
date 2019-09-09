#!/bin/bash
#check nginx server status
NGINX=/xfdata/soft/nginx/sbin/nginx
PORT=8010

#</dev/tcp/127.0.0.1/8010
nmap localhost -p $PORT | grep "$PORT/tcp open"
#echo $?
if [ $? -ne 0 ];then
    $NGINX -s stop
    $NGINX
    sleep 3
    nmap localhost -p $PORT | grep "$PORT/tcp open"
    [ $? -ne 0 ] && /etc/init.d/keepalived stop
fi

