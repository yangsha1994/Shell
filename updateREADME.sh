#!/bin/bash 
#更新README的脚本说明

filedir=$1
readmedir=$2

Script=$(find $1 -iname "0*.sh" |sort -n )
#echo $Script
for files in $Script
do
 #echo $files
 Number=$(echo "$files" | cut -c 3-5 )
 Mask=$(grep "explain" $files)
 if [[ -z $(cat ./README.md | grep  "$Mask" ) ]];
 then 
   echo -e "\n"$Number"\n"$Mask >> $2'/README.md'
 fi 
done

