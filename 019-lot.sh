#!/bin/bash 
#抓阄:产生随机数01-99,数字越大越容易去实践, 已经出现的数字不能重复
#author:yangyang

RecordFile="/tmp/recordfile.txt"
lot=0
[[ ! -f  $RecordFile  ]] && touch $RecordFile

#产生不重复的随机数
function ranmonlot(){
      
   while ((1))
   do
       #随机数lot
       lot=$(expr $RANDOM % 99 + 1)
       [[ $(cat $RecordFile |grep "$lot" |wc -l)  -eq 0  ]] && {
           break;
       }
   done 
     
}


#将输入的名称记录到文件中
function recordname(){
   #循环输入名字
   echo > $RecordFile
   for ((i=1;i<=100;i++ ))
   do
       #
       echo "请输入你的名字！"
       read studentname
       [[ -z $studentname   ]] && {
          break;
       }
       ranmonlot
       echo $studentname':'$lot  >> $RecordFile
   done
}

function main(){
   recordname 
   cat $RecordFile |sort -t ":" -k 2 -n 

}

main
