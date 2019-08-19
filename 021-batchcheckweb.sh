#!/bin/bash
#批量检查web地址是否正常
#author:yangyang
check=(
www.baidu.com
www.runoob.com
www.blog.csdn.net
)

while((1))
do  
    for ((i=0;i<3;i++ ))
    do
       if [[ $(nmap -sP ${check[$i]} |grep "up" |wc -l) -gt 0 ]]
       then 
          echo " ${check[$i]} is up "
       else
          echo  "${check[$i]} is down"
       fi
    done
sleep 10
done
