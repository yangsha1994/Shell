#!/bin/bash
#MySQL 主从监控:守护脚本，每30s监控一次mysql 主从复制是否异常，异常就发生邮件给管理员
#(函数,,函数返回值作为参数传递,数组取值,邮件发送,数据库命令执行语句，判断整型变量，awk 或方式匹配,)
#author:yangyang

#
path=/server/script                       #<==定义脚本存放路径，请大家注意这个规范
MAIL_GROUP="1111@qq.com 2222@qq.com"      #<==邮件列表
PAGER_GROUP="13620212112 13076938985"     #<==手机列表,以空格分隔
LOG_FILE="/tmp/web_check.log" 
USER=root
PASSWORD=oldboy123
PART=3307
MYSQLCMD="mysql -u$USER -p$PASSWORD -s /data/$PATH/mysql.sock"             
                                          #<==登陆数据库命令
error=(1008 1007 1062)                    #<==可以忽略主从复制的命令号
RETVAL=0                    
[[ ! -d "$path" ]]  && mkdir -p $path 

function JudgeError(){                    #<==定义判断主从复制的错误函数
   for (( i=0 ;i<${error[*]};i++ ))
   do
       if [[ "$1" = ${error[$i]}  ]]      #<==如果传入的错误号和error匹配
       then
         echo "MYSQL slave errorno is $1,auto repairing it."
         #<==自动修复
         $MYSQLCMD -e "stop slave;set global sql_slave_skip_counter=1;start slave"
       fi
        
   done
   return $1

}

#<== 定义判断主从复制状态的函数
function CheckDb(){
    status=$(awk -F ':' '/_Runing|Last_Error|_Behind/{print $NF}' slave.log)
    #<==判断延时转台值是否为数字
    expr  $(status[3]) + 1 &>/dev/null
    [[ $? -ne 0  ]] && {
    status[3]=300
    }
    #<== 两个线程都为yes，并且延时小于120秒，即认为状态正常
    if [[ "${status[0]}" = "Yes" ]] && [[ "${status[1]}" = "Yes" ]] && [[ 120  -gt  "${status[3]}" ]]
    then 
        return 0
    else
        JudgeError ${status[2]}
    fi

}

#<==邮件定义函数

function MAIL(){
    local SUBJECT_CONNECT=$1
    for MAIL_USER in $(echo $MAIL_GROUP)
    do
        #遍历发送邮件
        mail -s "$SUBJECT_CONNECT" $MAIL_USER <$LOG_FILE 
    done
}

#<== 定义手机函数
function PAGER(){
    for PAGER_USER in $(echo $PAGER_GROUP)
    do
        TITLE=$1
        CONNECT=$PAGER_USER
        HTTPGW="http://xxx"
        #<==发送短信地址
        curl -d cdkey="ASDGG-SS" -d password=OLDBOY -d phone=$CONNECT -d message="$TITLE[$2]" $HTTPGW
    done 
} 

#<==发送消息
function SendMsg(){
    if [[ $1 -ne 0 ]]
    then
        RETVAL=1
        #<==报警时间
        NOW_TIME=$(date +'%Y-%m-%d %H:%M:%S')
        #报警主题
        SUBJECT_CONNECT="mysql salve is error ，errorno is $2 ,$NOW_TIME"
        MAIL $SUBJECT_CONNECT >> $LOG_FILE
          
        PAGER  $SUBJECT_CONNECT $NOW_TIME
    else
        echo "mysql slave status is ok."
        RETVAL=1
    fi
   return RETVAL
}

function main(){
   while true
   do
      CheckDb
      #<==传入第一个参数
      SendMsg $?
      sleep 30
   done

}

main


