#!/bin/bash
#接收用户输入的10个数，输出最大值
#author:yangyang

#用户输入
declare -i max=0
for ((i=0;i<10;i++))
do
  echo 'please input a number';
  read value
  if [[ $value -gt $max ]];
  then 
     max=$value
  fi
done

echo 'input max number is : '$max 
