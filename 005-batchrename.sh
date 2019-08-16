#!/bin/bash
#批量改名（将oldboy改为oldgirl，并将扩展名改为大写）三种实现
#author:yangyang

#for循环实现
for files in $(find . -iname "*.html" )
do
   rename=$(echo $files|sed 's#oldboy#oldgirl#g'|sed 's#html#HTML#g')
#   echo $rename 
   mv $files $rename
done

#awk 实现

ls | grep .HTML |awk -F '_' {print "mv" $0 "$1"_oldgil.HTML}

#rename 实现


