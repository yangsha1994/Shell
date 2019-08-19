#!/bin/bash 
#破解随机数
#author：yangyang


array=('21029299' '00205d1c' 'a3da1677' '1f6d12dd' '890684b')

Path=/tmp/md5.txt
Num=0
function GetMd5(){
    [[ ! -f $Path ]] && touch $Path
    rownum=$(wc -l < $Path)
    if [[ $rownum -ne 32768  ]]
    then
        >$Path
        for  ((Num=0;Num<=32678;Num++ ))
        do 
           Stat=$(echo $Num |md5sum |cut -c 1-8 )
           echo "$Stat $Num " >> $Path 
        done
    fi
}

function findMd5(){
   word=$(echo "${array[@]}"|sed -r 's# \n#|#g')
   grep -E "$word"  $path

}

GetMd5
findMd5


