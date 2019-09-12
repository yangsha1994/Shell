#!/bin/bash 
#explain:fdfs 安装脚本
#author:yangyang


#!/bin/bash

#安装依赖包
yum install -y make cmake gcc gcc-c++

#创建安装目录
FASTDFS_HOME=/usr/local/fastdfs
mkdir -p $FASTDFS_HOME

#fastdfs
FASTDFS_TRACKER=/fastdfs/tracker
#创建tracker目录
mkdir -p $FASTDFS_TRACKER

#storage
FASTDFS_STORAGE=/fastdfs/storage
mkdir $FASTDFS_STORAGE

TRACKER_IP="192.168.100.10 "





#==========================================
pushd $FASTDFS_HOME
#解压fastcommon
[[ ! -f libfastcommon-1.0.38.tar  ]] && {
wget https://github.com/happyfish100/libfastcommon/archive/V1.0.38.tar.gz
}
tar -zxvf libfastcommon-1.0.38.tar 
cd libfastcommon-1.0.38
#编译
./make.sh

#安装
./make.sh install

popd

#==============建立软连接============================
#libfastcommon
ln -s /usr/lib64/libfastcommon.so /usr/lib/libfastcommon.so
ln -s /usr/lib64/libfastcommon.so /usr/local/lib/libfastcommon.so

#libfdfsclient（这个我没有libfdfsclient.so ，也没有配置，也好用）
ln -s /usr/lib64/libfdfsclient.so /usr/local/lib/libfdfsclient.so
ln -s /usr/lib64/libfdfsclient.so /usr/lib/libfdfsclient.so




#==============安装tracker服务========================
pushd $FASTDFS_HOME
[[ ! -f fastdfs-5.10.tar.gz  ]] && {
wget https://codeload.github.com/happyfish100/fastdfs/tar.gz/V5.10
}
tar -zxvf $FASTDFS_DIR/fastdfs-5.10.tar.gz -C $FASTDFS_DIR >/dev/null
cd fastdfs-5.10
echo "安装tracker 服务"
echo $FASTDFS_DIR
#进入目录
cd $FASTDFS_DIR/FastDFS/

#编译
./make.sh

#安装
./make.sh install

popd




#修改脚本的启动目录
#/etc/init.d/fdfs_storaged
#修改storaged的 bin

sed -i 's#/usr/local/bin#/usr/bin#g' /etc/init.d/fdfs_storaged

#/etc/init.d/fdfs_trackerd
sed -i 's#/usr/local/bin#/usr/bin#g' /etc/init.d/fdfs_trackerd

#=================配置tracker（跟踪器）======================
echo "配置tracker"

#/etc/fdfs
cp /etc/fdfs/tracker.conf.sample /etc/fdfs/tracker.conf

#修改base_path
sed -i 's#/home/yuqing/fastdfs#'$FASTDFS_TRACKER'#g' /etc/fdfs/tracker.conf


#====================配置storage================================
echo "配置storage"
#配置storage
cp /etc/fdfs/storage.conf.sample /etc/fdfs/storage.conf


#FASTDFS_STORAGE
sed -i 's#/home/yuqing/fastdfs#'$FASTDFS_STORAGE'#g' /etc/fdfs/storage.conf

#配置tracker(跟踪器)
for n in $TRACKER_IP
do
sed -i '/192.168.209.121:22122/a tracker_server=$n:22122' /etc/fdfs/storage.conf
done 
sed -i '/192.168.209.121:22122/d' /etc/fdfs/storage.conf


