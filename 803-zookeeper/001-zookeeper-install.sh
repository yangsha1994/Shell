#!/bin/bash 
#explain； zookeeper脚本安装 #log clean autopurge.snapRetainCount(保留个数) 和 autopurge.purgeInterval(多长时间清理一次)
#author:yangyang

#
ZOOKEEPER_INSTALL_DIR="/xfdata/soft"
ZOOKEEPER_VERSION="3.4.12"
ZOOKERPER_USER=zookeeper

#tar
[[ ! -f zookeeper-${ZOOKEEPER_VERSION}.tar.gz   ]] &&{
   wget http://archive.apache.org/dist/zookeeper/zookeeper-${ZOOKEEPER_VERSION}/zookeeper-${ZOOKEEPER_VERSION}.tar.gz
}
tar -zxvf zookeeper-${ZOOKEEPER_VERSION}.tar.gz -C ${ZOOKEEPER_INSTALL_DIR} &>/dev/null 


#config

cat > ${ZOOKEEPER_INSTALL_DIR}/zookeeper-${ZOOKEEPER_VERSION}/conf/zoo.cfg << EOF

# The number of milliseconds of each tick
tickTime=500
# The number of ticks that the initial 
# synchronization phase can take
initLimit=10
# The number of ticks that can pass between 
# sending a request and getting an acknowledgement
syncLimit=5
# the directory where the snapshot is stored.
# do not use /tmp for storage, /tmp here is just 
# example sakes.
dataDir=${ZOOKEEPER_INSTALL_DIR}/zookeeper-${ZOOKEEPER_VERSION}/zookeeper/data
dataLogDir=${ZOOKEEPER_INSTALL_DIR}/zookeeper-${ZOOKEEPER_VERSION}/logs
# the port at which the clients will connect
clientPort=2181
# the maximum number of client connections.
# increase this if you need to handle more clients
maxClientCnxns=500
#
# Be sure to read the maintenance section of the 
# administrator guide before turning on autopurge.
#
# http://zookeeper.apache.org/doc/current/zookeeperAdmin.html#sc_maintenance
#
# The number of snapshots to retain in dataDir
autopurge.snapRetainCount=20
# Purge task interval in hours
# Set to "0" to disable auto purge feature
autopurge.purgeInterval=10
server.1=192.168.0.202:2888:3888
server.2=192.168.0.203:2888:3888
server.3=192.168.0.204:2888:3888

EOF

#log dir

sed -i 's#zookeeper\.root\.logger=INFO, CONSOLE#zookeeper.root.logger=INFO,ROLLINGFILE#g' ${ZOOKEEPER_INSTALL_DIR}/zookeeper-${ZOOKEEPER_VERSION}/conf/log4j.properties
sed -i "s#ZOO_LOG_DIR=\"\.\"#ZOO_LOG_DIR=${ZOOKEEPER_INSTALL_DIR}/logs#g"  ${ZOOKEEPER_INSTALL_DIR}/zookeeper-${ZOOKEEPER_VERSION}/bin/zkEnv.sh
sed -i 's#ZOO_LOG4J_PROP=\"INFO,CONSOLE\"#ZOO_LOG4J_PROP=\"INFO,ROLLINGFILE\"#g' ${ZOOKEEPER_INSTALL_DIR}/zookeeper-${ZOOKEEPER_VERSION}/bin/zkEnv.sh



