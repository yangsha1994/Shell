#!/bin/bash 
#更新README的脚本说明

cd $1
 
Script=`find  . -iname "[0-9]*.sh" |sort -n `
for files in $Script
do
 #echo $files
 Number=$(echo "$files" | cut -c 3-5 )
 Mask=$(grep "explain" $files)
 if [[ -z $(cat README.md | grep  "$Mask" ) ]]
 then 
   echo -e "\n"$Number"\n"$Mask >> README.md
 fi 
done

