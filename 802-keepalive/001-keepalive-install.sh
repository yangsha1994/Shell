#!/bin/bash 
#explain: keepalive 安装脚本 将配置都集合在安装目录下的conf 目录，配置在脚本中写入，需要时修改脚本内配置,已经修改日志配置转到安装目录下
#author:yangyang 


###

KEEPALIVED_USER="keepalived"
KEEPALIVED_VERSION="1.4.5"
KEEPALIVED_INSTALL_DIR="/usr/local/keepalived"

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
fi

tar xf keepalived-${KEEPALIVED_VERSION}.tar.gz


#ee comlnie keepalived
pushd keepalived-${KEEPALIVED_VERSION}
./configure --prefix=${KEEPALIVED_INSTALL_DIR} --sysconf=/${KEEPALIVED_INSTALL_DIR}/conf &> /dev/null
make &> /dev/null
make install &> /dev/null
popd
/bin/cp  ${KEEPALIVED_INSTALL_DIR}/sbin/keepalived /usr/bin/

# config log
sed -i 's@^KEEPALIVED_OPTIONS=.*@KEEPALIVED_OPTIONS="-D -d -S 0"@' ${KEEPALIVED_INSTALL_DIR}/conf/sysconfig/keepalived
#cat >> "local0.* /var/log/keepalived/keepalived.log" /etc/rsyslog.conf
cat > /etc/rsyslog.d/keepalived.conf << EOF
local0.*  ${KEEPALIVED_INSTALL_DIR}/keepalived.log
&~
EOF
/etc/init.d/rsyslog restart &> /dev/null

# man config

#service 
cat > /etc/init.d/keepalived <<EOF

#!/bin/sh
#
# Startup script for the Keepalived daemon
#
# processname: keepalived
# pidfile: /var/run/keepalived.pid
# config: /etc/keepalived/keepalived.conf
# chkconfig: - 21 79
# description: Start and stop Keepalived

# Source function library
. /etc/rc.d/init.d/functions

# Sourcde configuration file (we set KEEPALIVED_OPTIONS there)
. ${KEEPALIVED_INSTALL_DIR}/conf/sysconfig/keepalived
RETVAL=0
prog="keepalived"

config="${KEEPALIVED_INSTALL_DIR}/conf/keepalived/keepalived.conf"
exec="${KEEPALIVED_INSTALL_DIR}/sbin/keepalived" 
start() {
    echo -n $"Starting \$prog: "
    daemon \$exec -D -f \$config -S 0
    RETVAL=\$?
    echo
    [ \$RETVAL -eq 0 ] && touch /var/lock/subsys/\$prog
}

stop() {
    echo -n $"Stopping \$prog: "
    killproc keepalived
    RETVAL=\$?
    echo
    [ \$RETVAL -eq 0 ] && rm -f /var/lock/subsys/\$prog
}

reload() {
    echo -n $"Reloading \$prog: "
    killproc keepalived -1
    RETVAL=\$?
    echo
}

# See how we were called.
case "\$1" in
    start)
        start
        ;;
    stop)
        stop
        ;;
    reload)
        reload
        ;;
    restart)
        stop
        start
        ;;
    condrestart)
        if [ -f /var/lock/subsys/\$prog ]; then
            stop
            start
        fi
        ;;
    status)
        status keepalived
        RETVAL=\$?
        ;;
    *)
        echo "Usage: \$0 {start|stop|reload|restart|condrestart|status}"
        RETVAL=1
esac

exit \$RETVAL

EOF

chmod +x /etc/init.d/keepalived	
/etc/init.d/keepalived start
chkconfig keepalived on 

#chk_nginx,clean_arp
cat > ${KEEPALIVED_INSTALL_DIR}/conf/chk_nginx.sh << EOF

#!/bin/bash
#check nginx server status
NGINX=/xfdata/soft/nginx/sbin/nginx
PORT=8010

#</dev/tcp/127.0.0.1/8010
nmap localhost -p \$PORT | grep "\$PORT/tcp open"
if [ \$? -ne 0 ];then
    \$NGINX -s stop
    \$NGINX
    sleep 3
    nmap localhost -p \$PORT | grep "\$PORT/tcp open"
    [ \$? -ne 0 ] && /etc/init.d/keepalived stop
fi

EOF

cat >${KEEPALIVED_INSTALL_DIR}/conf/clean_arp.sh << EOF
VIP=192.168.0.196
GATEWAY=192.168.0.1
/sbin/arping -I eth0 -c 5 -s $VIP $GATEWAY &>/dev/null

EOF

chmod +x ${KEEPALIVED_INSTALL_DIR}/conf/chk_nginx.sh
chmod +x ${KEEPALIVED_INSTALL_DIR}/conf/clean_arp.sh
#keepalive.conf 

cat >   ${KEEPALIVED_INSTALL_DIR}/conf/keepalived/keepalived.conf << EOF



global_defs {
       notification_email {
         acassen@firewall.loc
         failover@firewall.loc
         sysadmin@firewall.loc
       }
       notification_email_from Alexandre.Cassen@firewall.loc
       smtp_server 192.168.200.1
       smtp_connect_timeout 5
       router_id LVS_DEVEL
    }

    vrrp_script check_nginx {
       script "${KEEPALIVED_INSTALL_DIR}/conf/chk_nginx.sh"
            interval 1
            weight -10
            fall 2
            rise 1
    }


  vrrp_instance VI_1 {
        state MASTER
        interface eth0
        virtual_router_id 152
        priority 99
        advert_int 1
        authentication {
            auth_type PASS
            auth_pass 1111
        }

            track_script {
                    check_nginx
            }

        virtual_ipaddress {
            192.168.0.196          
        }
    notify_master "${KEEPALIVED_INSTALL_DIR}/conf/clean_arp.sh"
    }

    vrrp_instance VI_2 {
        state MASTER
        interface eth0
        virtual_router_id 66
        priority 100
        nopreempt
        advert_int 1
        authentication {
            auth_type PASS
            auth_pass 1111
        }

        virtual_ipaddress {
            192.168.0.205
        }
   # notify_master "/etc/keepalived/clean_arp.sh"
    }



   virtual_server 192.168.0.205 8066 { # 虚拟ip 

     delay_loop 2   # check the real_server status for every 2 seconds.
     lb_algo rr   #LVS   arithmetic
     lb_kind DR    #LVS model
     persistence_timeout 10   #k
     protocol TCP 

       real_server 192.168.0.202 8066 {  # 真实本机IP
         weight 3
         TCP_CHECK {
             connect_timeout 5    #timeout
             nb_get_retry 3       #conect times to try to connect
             delay_before_retry 3   #interval of retry
             connect_port 8066  # check mysql port
         }
     }

     real_server 192.168.0.203 8066 {  # 真实本机IP
         weight 3 
         TCP_CHECK { 
             connect_timeout 5    #timeout
             nb_get_retry 3       #conect times to try to connect
             delay_before_retry 3   #interval of retry
             connect_port 8066  # check mysql port
         }
     } 


     real_server 192.168.0.204 8066 {  # 真实本机IP
         weight 3
         TCP_CHECK { 
             connect_timeout 5    #timeout
             nb_get_retry 3       #conect times to try to connect
             delay_before_retry 3   #interval of retry
             connect_port 8066  # check mysql port
         }
     }

}


EOF


#

 
	
