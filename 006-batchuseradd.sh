#!/bin/bash
#创建10个账号oldboy01-oldboy10,并设置密码 （密码为随机数，要求是8位数字与字母混合）
#author:yangyang

. /etc/init.d/functions
#变量
user="oldboy";
passfile='/tmp/user.log';

for i in $(seq -w 10)
do

useradd $user$i
#随机数
pass=$(echo "yang$RANDOM"|md5sum |cut -c 3-11)
#设置密码
echo "$pass" |passwd --stdin &>/dev/null && \
echo -e "user:$user$i \t passwd:$pass"
if [[ "$?" -eq 0  ]];
then
  action "$user$i is ok " /bin/true
else
  action "$user$i is ok " /bin/false
fi
echo "----------------"

cat $passfile

done
