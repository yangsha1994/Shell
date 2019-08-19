#!/bin/bash 
#监控web 站点目录下(/var/html/www)的所有文件是否被恶意篡改(文件内容被更改)，如有发送邮件定时执行三分钟一次
#author:yangyang

#大小，修改时间，内容，数量
#find /var/html/www/ -typy f > /opt/wenjian.db.ori 
#find /var/html/www/ -type f|xargs md5sum >/opt/yangyang.db.ori
#指纹检查：md5sum -c --quiet /opt/zhiwen.db.ori 
#文件检查：diff /opt/wenjian* 

#变量定义
FingerFile="/opt/zhiwen.db.ori "
FileFile="/opt/wenjian.db.ori"


#检查是否存在原指纹库,不存在就创建并推出推出脚本
if [[ ! -f $FingerFile ]]
then 
   echo "not find FingerFile, now will create it.";
   find /var/html/www/ -type f|xargs md5sum > $FingerFile
   exit 1 
elif [[ ! -f $FileFile]]
   echo "not find FileFile, now will create it. "   
   exit 1
else
   echo "find File is ok.compare list :---------------------"
fi

while true 
do
zhiwenCMD=$(md5sum -c --quiet /opt/zhiwen.db.ori )
wenjianCMD=$(diff /opt/wenjian*)
#生成现在的指纹文件，并进行对比

[[ `echo $zhiwenCMD | wc -l ` -gt 0  ]]  || [[ `echo $wenjianCMD | wc -l ` -gt 0  ]] && {
  
  echo $zhiwenCMD \n $wenjianCMD |xargs mail -s "data: `date +%Y-%m-%d %H:%M:%S` web's files is error :\n  " 478210830@qq.com >> $/tmp/log.log

sleep 3

done


