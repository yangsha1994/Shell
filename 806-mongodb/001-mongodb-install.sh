#!/bin/bash
#explain:mongodb 安装脚本

# 下载目录
downloadsDir=/root/Downloads
# 安装目录
appDir=/xfdata/soft/mongodb

# 判断备份目录是否存在，不存时新建目录 
[ ! -d $downloadsDir ] && mkdir -p $downloadsDir
cd $downloadsDir

# 下载mongodb
[[ ! -f mongodb-linux-x86_64-3.6.5.tgz  ]] && {
curl -O http://downloads.mongodb.org/linux/mongodb-linux-x86_64-3.6.5.tgz 
}
# 解压mongodb
tar -zxvf  mongodb-linux-x86_64-3.6.5.tgz

rm -rf $appDir
mkdir -p $appDir

# 复制mongodb数据库文件到$appDir目录下
cp -R /root/Downloads/mongodb-linux-x86_64-2.6.7/* $appDir

mkdir -p $appDir/data/db
mkdir -p $appDir/log
mkdir -p $appDir/conf
mkdir -p $appDir/bin
chmod -R 777 $appDir

echo > $appDir/mongo.conf
cat  $appDir/mongo.conf << EOF

systemLog:
    destination: file
    path: /xfdata/data/mongodb/logs/mongodb.log
storage:
    dbPath: /xfdata/data/mongodb/db
processManagement:
    fork: true
    pidFilePath: /xfdata/soft/mongodb/logs/mongod.pid
net:
    bindIp: 0.0.0.0
EOF


# 以修复模式启动
# ./bin/mongod -f mongod.conf --repair

# 启动mongd服务
./bin/mongod -f mongod.conf

# 连接数据库
./bin/mongo
