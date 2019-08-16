#!/bin/bash 
#更新README的脚本说明
Script=$(find . -iname "00*.sh" |sort -n )
#echo $Script
for files in $Script
do
 #echo $files
 Number=$(echo "$files" | cut -c 3-5 )
 Mask=$(sed -n '2p' $files)
 if [[ -z $(cat ./README.md | grep  "$Mask" ) ]];
 then 
   echo -e "\n"$Number"\n"$Mask >> README.md  
 fi 
done

