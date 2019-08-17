#!/bin/bash
#I am oldboy teacher welcome to oldboy training class 打印这句话中字母不大于6的单词
#author:yangyang

#awk 实现

echo "I am oldboy teacher welcome to oldboy training class" | awk '{ for(i=1;i<=$NF ;i++) if(length($i)<=6 ) print $i }'

