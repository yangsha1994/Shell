#!/bin/bash 
#explain:清理zookeeper 日志
#author:yangyang

ZOOKEEPER_INSTALL_DIR="/xfdata/soft"
ZOOKEEPER_VERSION="3.4.12"
ZOOKERPER_USER=zookeeper

#snapshot file dir
dataDir=${ZOOKEEPER_INSTALL_DIR}/zookeeper-${ZOOKEEPER_VERSION}/data/version-2
#tran log dir
dataLogDir=${ZOOKEEPER_INSTALL_DIR}/zookeeper-${ZOOKEEPER_VERSION}/logs/version-2
#zk log dir
logDir=${ZOOKEEPER_INSTALL_DIR}/zookeeper-${ZOOKEEPER_VERSION}/logs
#Leave 60 files
count=60
count=$[$count+1]

ls -t $dataLogDir/log.* | tail -n +$count | xargs rm -f
ls -t $dataDir/snapshot.* | tail -n +$count | xargs rm -f
ls -t $logDir/zookeeper.log.* | tail -n +$count | xargs rm -f
