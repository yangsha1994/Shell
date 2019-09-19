#!/bin/bash 
#explain:mysql 单机安装脚本
#author:yangyang

GROUP_NAME=mysql
USER_NAME=mysql
MYSQLDB_HOME=/home/mysql/mysql
MYSQLDB_DATA_HOME=/home/mysql/mysql/data
ERROR_EXIT=65
MYSQL_VERSION="mysql-5.7.10"
CMAKE_VERSION="cmake-3.4.3"
BOOST_VERSION="boost_1_59_0"
CPU_NUMBERS=$(cat /proc/cpuinfo |grep "processor"|wc -l)
MYSQL_ID=`ifconfig eth0 | grep "inet addr" | awk -F. '{print $4}' | awk '{print $1}'`
COMPUTER_MEM=`free -m |grep "Mem"|awk '{print $2}'`
MYSQL_MEM=`expr $COMPUTER_MEM - $COMPUTER_MEM / 4`
echo "$MYSQL_MEM"
echo "====================================================="
echo "setup MySQL 5.7.10 on centos6.5_64bit "
echo "your computer is $CPU_NUMBERS processes ,mysql Memory is $MYSQL_MEM M" 
echo "you will input mysql's root  password and mysql's memory"
echo "====================================================="
sleep 1

#addGroup
if [ -z $(cat /etc/group|awk -F: '{print $1}'| grep -w "$GROUP_NAME") ]
then
  groupadd  $GROUP_NAME
    if(( $? == 0 ))
      then
         echo "group $GROUP_NAME add sucessfully!"
    fi   
else
  echo "$GROUP_NAME is exsits"
fi


#addUser
if [ -z $(cat /etc/passwd|awk -F: '{print $1}'| grep -w "$USE_NAME") ]
then
     adduser -g $GROUP_NAME $USER_NAME
     if (( $? == 0 ))
       then
       echo "user $USER_NAME add sucessfully!"
     fi
else
  echo "$USER_NAME is exsits"
fi

yum -y install make gcc-c++ bison-devel  ncurses-devel  perl perl-devel wget
[[ ! -f /tmp/${CMAKE_VERSION}.tar.gz  ]] && {
wget https://cmake.org/files/v3.4/${CMAKE_VERSION}.tar.gz -P /tmp

     if(( $? == 0 ))
       then
        echo "cmake DownLoad sucessfully!" 
       else
        echo "cmake DownLoad failed!"
        exit $ERROR_EXIT
     fi
}

cmakeversion=`echo |awk -F '-' '{print $2}'`
[[ $(cmake -version |grep $cmakeversion  |wc -l ) -lt  0 ]] && {
cd /tmp
tar xzvf ${CMAKE_VERSION}.tar.gz 
cd ${CMAKE_VERSION}
./bootstrap
make && make install
}

yum install gcc gcc-c++ bzip2 bzip2-devel bzip2-libs python-devel -y
[[ ! -f /tmp/${BOOST_VERSION}.tar.gz  ]] && {
wget http://downloads.sourceforge.net/project/boost/boost/1.59.0/${BOOST_VERSION}.tar.gz -P /tmp
     if(( $? == 0 ))
       then
        echo "boost DownLoad sucessfully!" 
       else
        echo "boost DownLoad failed!"
        exit $ERROR_EXIT
     fi
}
#Mysql5.7版本更新后有很多变化，比如json等，连安装都有变化，他安装必须要BOOST库，不过mysql的官网源码有带boost库的源码和不带boost库的源码两种，因此有两种安装方式
cd /tmp
tar xzvf ${BOOST_VERSION}.tar.gz
cd ${BOOST_VERSION}
./bootstrap.sh
./b2 install


[[ ! -f ${MYSQL_VERSION}.tar.gz  ]] && {
wget http://downloads.mysql.com/archives/get/file/${MYSQL_VERSION}.tar.gz -P /tmp 
}

cd /tmp
tar -zxvf ${MYSQL_VERSION}.tar.gz
cd ${MYSQL_VERSION}

#编译

cmake \
-DCMAKE_INSTALL_PREFIX=/home/mysql/mysql \
-DMYSQL_DATADIR=/home/mysql/mysql/data \
-DWITH_BOOST=/usr/local/include/boost \
-DSYSCONFDIR=/etc \
-DWITH_MYISAM_STORAGE_ENGINE=1 \
-DWITH_INNOBASE_STORAGE_ENGINE=1 \
-DWITH_MEMORY_STORAGE_ENGINE=1 \
-DWITH_READLINE=1 \
-DMYSQL_UNIX_ADDR=/var/lib/mysql/mysql.sock \
-DMYSQL_TCP_PORT=3306 \
-DENABLED_LOCAL_INFILE=1 \
-DWITH_PARTITION_STORAGE_ENGINE=1 \
-DEXTRA_CHARSETS=all \
-DDEFAULT_CHARSET=utf8 \
-DDEFAULT_COLLATION=utf8_general_ci
 
make -j$CPU_NUMBERS && make install 

#备份my.cnf
if [ -s /etc/my.cnf ]; then
	mv /etc/my.cnf /etc/my.cnf.`date +%Y%m%d%H%M%S`.bak
fi

#数据目录权限

mkdir -p $MYSQLDB_HOME/log
touch $MYSQLDB_HOME/log/mysql-error.log
touch $MYSQLDB_HOME/log/mysql-slow.log
chown -R mysql:mysql $MYSQLDB_HOME

#配置

cat > /etc/my.cnf << EOF

[mysql]
default-character-set=UTF8
[client]
#default-character-set=UTF8
[mysqld]
#datadir=/var/lib/mysql
socket=/var/lib/mysql/mysql.sock
# Disabling symbolic-links is recommended to prevent assorted security risks
symbolic-links=0
port = 3306
basedir = $MYSQLDB_HOME
datadir = $MYSQLDB_DATA_HOME
pid-file = $MYSQLDB_HOME/mysql.pid
user = mysql
server-id = $MYSQL_ID
#rpl_semi_sync_master_enabled=1
#rpl_semi_sync_master_timeout=1000
#rpl_semi_sync_slave_enabled=1
relay_log_purge=0
read_only=0
slave-skip-errors=1396
lower_case_table_names = 1
character-set-server=utf8
skip-name-resolve
skip-external-locking
back_log = 500
max_connections = 500
max_connect_errors = 2000
open_files_limit = 65535
table_open_cache = 128 
max_allowed_packet = 64M
##thread_concurrency = `expr $CPU_NUMBERS + $CPU_NUMBERS`
key_buffer_size = 64M
read_buffer_size = 64M
read_rnd_buffer_size = 16M
sort_buffer_size = 16M
join_buffer_size = 16M
tmp_table_size = 96M
max_heap_table_size = 96M
query_cache_size = 8M
query_cache_limit = 8M
thread_cache_size = 64
log_bin = mysql-bin
binlog_format = mixed
binlog_cache_size = 8M
sync_binlog = 1
max_binlog_cache_size = 8M
max_binlog_size = 500M
expire_logs_days = 10
log_error = $MYSQLDB_HOME/log/mysql-error.log
slow_query_log = 1
long_query_time = 1
slow_query_log_file = $MYSQLDB_HOME/log/mysql-slow.log
default_storage_engine = InnoDB
innodb_buffer_pool_size = $MYSQL_MEM
innodb_file_per_table = 1
innodb_data_home_dir = $MYSQLDB_DATA_HOME
innodb_data_file_path = ibdata1:500M;ibdata2:1G:autoextend
innodb_log_group_home_dir = $MYSQLDB_HOME
innodb_log_file_size = 500M
innodb_log_buffer_size = 20M
innodb_flush_log_at_trx_commit = 1
innodb_print_all_deadlocks = 1
[mysqld_safe]
log-error=/var/log/mysqld.log
pid-file=/var/run/mysqld/mysqld.pid"

EOF


##初始化

${MYSQLDB_HOME}/bin/mysqld --initialize-insecure --basedir=$MYSQLDB_HOME --datadir=$MYSQLDB_DATA_HOME --user=$USER_NAME
 
cp $MYSQLDB_HOME/support-files/mysql.server /etc/init.d/mysql
chmod 755 /etc/init.d/mysql
chkconfig --add mysql
chkconfig mysql on
/etc/init.d/mysql start 
 
 
cat >> /etc/profile <<EOF
PATH=$MYSQLDB_HOME/bin:\$PATH
export PATH
EOF
 
source /etc/profile
 
 
mysqladmin -u root password $mysqlrootpwd
 
 
echo "set up successfully!enjoy it...."
 
exit 0
