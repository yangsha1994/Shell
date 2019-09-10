#!/bin/bash 
#explain: tomcat 日志清理(catalina.2019-05-28.log,catalina.out,host-manager.2019-05-28.log,localhost.2019-05-28.log)
#author:yangyang

LOG_DIR=$CATALINA_HAOME
DelTime=`date +"%Y-%m-%d" -d'-20 day'`
TarTime=`date +"%Y-%m-%d" -d'-1 week'`
echo $DelTime
#备份前一天的catalina.out,清空catalina,清理过期日志20天以前
pushd  $CATALINA_HOME/logs
    #catalina.out
    cp catalina.out catalina.out.`date +"%Y-%m-%d" -d'-1 day'`.bak
    echo > catalina.out
    #删除20天
    for n in ` ls *.log *.txt -1 2>/dev/null`
    do
        LogTime=`echo $n | awk -F '.' '{print $(NF-1)}'`
        LogTime=`echo ${Logtime:0-10}`
        if [[ $LogTime < $DelTime ]]
        then
            echo "$n will be deleted."
            rm -rf $n
        fi
    done
    #压缩一周前
    for n in ` ls *.log *.txt -1 2>/dev/null`
    do
        LogTime=`echo $n | awk -F '.' '{print $(NF-1)}'`
        LogTime=`echo ${Logtime:0-10}`
        if [[ $LogTime < $TarTime ]]
        then
            echo "$n will be compress."
            [[ ! -f $TarTime.tar.gz  ]] && {
                touch $TarTime.tar.gz
          }
            tar -zcvfu $TarTime.tar.gz $n
        fi
    done
popd
