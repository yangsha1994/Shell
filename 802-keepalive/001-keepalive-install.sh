#!/bin/bash 
#keepalive 脚本集合
#author:yangyang 


 ###

KEEPALIVED_USER="keepalived"
KEEPALIVED_VERSION="1.4.5"
KEEPALIVED_INSTALL_DIR="/usr/local"

yum install -y kernel-devel openssl openssl-devel ipvsadm &> /dev/null
ln -s /usr/src/kernels/`uname -r`/ /usr/src/linux

# check keepalived user
id -u ${KEEPALIVED_USER=} &> /dev/null
[ $? -ne 0 ] && useradd -M -s /bin/bash ${KEEPALIVED_USER}

# check tar file
if [ ! -f keepalived-${KEEPALIVED_VERSION}.tar.gz ];then
 echo "keepalived tar file not exists."
 echo "download from offical website..."
 wget http://www.keepalived.org/software/keepalived-${KEEPALIVED_VERSION}.tar.gz
else
 tar xf keepalived-${KEEPALIVED_VERSION}.tar.gz
fi

# comline keepalived
pushd keepalived-${KEEPALIVED_VERSION}
./configure --prefix=${KEEPALIVED_INSTALL_DIR} --sysconf=/etc &> /dev/null
make &> /dev/null
make install &> /dev/null
popd
/bin/cp /usr/local/sbin/keepalived /usr/bin/

# config log
sed -i 's@^KEEPALIVED_OPTIONS=.*@KEEPALIVED_OPTIONS="-D -d -S 0"@' /etc/sysconfig/keepalived
#cat >> "local0.* /var/log/keepalived/keepalived.log" /etc/rsyslog.conf
cat > /etc/rsyslog.d/keepalived.conf << EOF
local0.* /var/log/keepalived.log
&~
EOF
/etc/init.d/rsyslog restart &> /dev/null

# man config

#service 
/etc/init.d/keepalived start
chmod +x /etc/init.d/keepalived
chkconfig keepalived on 
