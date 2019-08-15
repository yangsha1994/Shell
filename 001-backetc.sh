#!/bin/bash
#按日期备份/etc目录，备份到root目录,定时删除五天以前的备份
#author:yangyang

#确认/root/back 目录是否存在

Root_Dir='/root/back'
#$(ls /root/ |grep back)

if [[ -d $Root_Dir  ]];
then
  mkdir -p /root/back;
fi
cd /root/back 
#定义日期
Back_Date=$(date +%Y%m%d)

#打包
tar -zcvf $Back_Date'.tar.gz' /etc/ 1>/dev/null

#删除五天以前的备份

Out_Back=$(find /root/back/*.tar.gz -mtime +5 )
for files in $Out_Back;
do 
  if [[ -n $files ]];
  then
  rm -f /root/back/$files
  fi
done


