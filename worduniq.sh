#!/bin/bash 
#单词字母去重,按单词出现频率排序，按字母出现的频率排序
#author:yangyang

char='Find a reason to live, strengthen your faith, stick to your life, there is hope in life'



#sort 排序
echo $char |tr "[., ]" "\n"|grep -v "^$"|sort |uniq -c |sort -n 

#tr awk

