#!/bin/bash 
#输出九九乘法表
#author:yangyang
declare -i var=0
for i in {1..9}
do
   for j in {1..9}
   do
       if [[ $i -ge $j ]]
       then 
         let "var=$i*$j"
         printf "$i \* $j ="$var'\t'
       fi
   done
   echo ''
done
