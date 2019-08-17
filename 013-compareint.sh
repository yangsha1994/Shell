#!/bin/bash 
#比较两个用户读入的数字，比较大小，提示参数是否为整数和一数字，输出比较结果
#author:yangyang

#读入数字


read -p "please input two num :" a b 
echo $a $b
[[ -z $a ]] || [[ -z $b ]] && {

echo "please input two num again.1"
exit 1

} 

expr $a + 10  &> /dev/null
RETVAL1=$?

expr $b + 10 &>/dev/null
RETVAL2=$?

[[ $RETVAL1 -ne 0  ]] || [[ $RETVAL2 -ne 0  ]] && {

echo "please input two num again.2"
exit 2

}

[[ $a -gt $b ]] && {

echo "$a 大于 $b"
exit 0

}

[[  $b -gt $a  ]] && {

echo "$a 小于 $b"
exit 0

}



