#!/bin/bash 
#等腰三角形
#autuor:yangyang

for ((i=0;i<=6;i++))
do

  for ((j=(7-$i);j>0;j-- ))
  do
   printf   "* "
  done
  echo ''
done
