#!/bin/bash 
#监控Memcache 缓存服务
#nc 命令
#author:yangyang

if [[ $(netstat -lntup |grep 11211|wc -l )  -lt 1 ]]
then 
    echo "Memcached Service is error."
    exit 1
fi 
printf "del key \r\n " |nc 127.0.0.1 11211 $>/dev/null
printf "set key 0 0 10 \r\noldboy1234\r\n" |nc 127.0.0.1 11211 &>/deb/null
McValue=$( printf "get key \r\n"|nc 127.0.0.1 11211 &>/dev/null )

if [[ $McValues -eq 1  ]]
then 
    echo ""
else
    echo ""
fi
