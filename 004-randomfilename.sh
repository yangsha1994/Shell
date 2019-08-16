#!/bin/bash
#批量生成随机字符文件名（在oldboy目录下生成10个html文件，每个文件10随机小写字母+oldboy）
#author:yangyang


for ((i=0;i<=10;i++))
do

#生成随机小写字母
Random_str=$( openssl rand -base64 40 | sed 's#[^a-z]##g'|cut -c 2-11 )
#echo $Random_str
touch $Random_str'_oldboy.html'

done
