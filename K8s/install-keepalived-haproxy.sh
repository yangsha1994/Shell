#!/bin/bash
###author yangyang
#a安装keepalived——haproxy


##安装keepalived----------------------------------------------------------------
# 1. 安装yum
yum install -y keepalived

# 2.备份配置文件
cp /etc/keepalived/keepalived.conf /etc/keepalived/keepalived.conf-back

# 3.编辑配置文件
cat > /etc/keepalived/keepalived.conf << EOF
! Configuration File for keepalived

global_defs {
   router_id LVS_DEVEL
}

vrrp_script check_haproxy {
    script "killall -0 haproxy"
    interval 3
    weight -2
    fall 10
    rise 2
}

vrrp_instance VI_1 {
    state MASTER
    interface eth0  # 虚拟网卡桥接的真实网卡
    virtual_router_id 51
    # 优先级配置，每台服务器最好都不一样，如100，90，80等，优先级越高越先使用
    priority 90
    advert_int 1
    authentication {
        auth_type PASS
        auth_pass 111
    }
    virtual_ipaddress {
        192.168.0.200 # 对外提供的虚拟IP
    }
    track_script {
        check_haproxy
    }
}
EOF

# 4.启动
systemctl start keepalived && systemctl enable keepalived && systemctl status keepalived


##安装haproxy--------------------------------------------------------------------


# 1.安装
yum install -y haproxy

# 2.备份配置文件
cp /etc/haproxy/haproxy.cfg /etc/haproxy/haproxy.cfg-back

# 3.编辑配置文件
cat > /etc/haproxy/haproxy.cfg << EOF
#---------------------------------------------------------------------
# Global settings
#---------------------------------------------------------------------
global
    # to have these messages end up in /var/log/haproxy.log you will
    # need to:
    #
    # 1) configure syslog to accept network log events.  This is done
    #    by adding the '-r' option to the SYSLOGD_OPTIONS in
    #    /etc/sysconfig/syslog
    #
    # 2) configure local2 events to go to the /var/log/haproxy.log
    #   file. A line like the following can be added to
    #   /etc/sysconfig/syslog
    #
    #    local2.*                       /var/log/haproxy.log
    #
    log         127.0.0.1 local2

    chroot      /var/lib/haproxy
    pidfile     /var/run/haproxy.pid
    maxconn     4000
    user        haproxy
    group       haproxy
    daemon

    # turn on stats unix socket
    stats socket /var/lib/haproxy/stats

#---------------------------------------------------------------------
# common defaults that all the 'listen' and 'backend' sections will
# use if not designated in their block
#---------------------------------------------------------------------
defaults
    mode                    http
    log                     global
    option                  httplog
    option                  dontlognull
    option http-server-close
    option forwardfor       except 127.0.0.0/8
    option                  redispatch
    retries                 3
    timeout http-request    10s
    timeout queue           1m
    timeout connect         10s
    timeout client          1m
    timeout server          1m
    timeout http-keep-alive 10s
    timeout check           10s
    maxconn                 3000

#---------------------------------------------------------------------
# kubernetes apiserver frontend which proxys to the backends
#---------------------------------------------------------------------
frontend kubernetes-apiserver
    mode                 tcp
    bind                 *:6444  # 对外提供服务的端口，必须和kubernetes一致
    option               tcplog
    default_backend      kubernetes-apiserver #后端服务的名称

#---------------------------------------------------------------------
# round robin balancing between the various backends
#---------------------------------------------------------------------
backend kubernetes-apiserver
    mode        tcp
    balance     roundrobin
    server  k8s-31 192.168.0.31:6443 check # 后端服务器hostname和IP
    server  k8s-42 192.168.0.42:6443 check # 后端服务器hostname和IP
    server  k8s-243 192.168.0.243:6443 check # 后端服务器hostname和IP
EOF

# 4.启动
systemctl start haproxy && systemctl enable haproxy && systemctl status haproxy

[root@k8s-31 shell]# cat install-keepalived-haproxy.sh
#!/bin/bash
###author yangyang
#a安装keepalived——haproxy


##安装keepalived----------------------------------------------------------------
# 1. 安装yum
yum install -y keepalived

# 2.备份配置文件
cp /etc/keepalived/keepalived.conf /etc/keepalived/keepalived.conf-back

# 3.编辑配置文件
cat > /etc/keepalived/keepalived.conf << EOF
! Configuration File for keepalived

global_defs {
   router_id LVS_DEVEL
}

vrrp_script check_haproxy {
    script "killall -0 haproxy"
    interval 3
    weight -2
    fall 10
    rise 2
}

vrrp_instance VI_1 {
    state MASTER
    interface eth0  # 虚拟网卡桥接的真实网卡
    virtual_router_id 51
    # 优先级配置，每台服务器最好都不一样，如100，90，80等，优先级越高越先使用
    priority 90
    advert_int 1
    authentication {
        auth_type PASS
        auth_pass 111
    }
    virtual_ipaddress {
        192.168.0.200 # 对外提供的虚拟IP
    }
    track_script {
        check_haproxy
    }
}
EOF

# 4.启动
systemctl start keepalived && systemctl enable keepalived && systemctl status keepalived


##安装haproxy--------------------------------------------------------------------


# 1.安装
yum install -y haproxy

# 2.备份配置文件
cp /etc/haproxy/haproxy.cfg /etc/haproxy/haproxy.cfg-back

# 3.编辑配置文件
cat > /etc/haproxy/haproxy.cfg << EOF
#---------------------------------------------------------------------
# Global settings
#---------------------------------------------------------------------
global
    # to have these messages end up in /var/log/haproxy.log you will
    # need to:
    #
    # 1) configure syslog to accept network log events.  This is done
    #    by adding the '-r' option to the SYSLOGD_OPTIONS in
    #    /etc/sysconfig/syslog
    #
    # 2) configure local2 events to go to the /var/log/haproxy.log
    #   file. A line like the following can be added to
    #   /etc/sysconfig/syslog
    #
    #    local2.*                       /var/log/haproxy.log
    #
    log         127.0.0.1 local2

    chroot      /var/lib/haproxy
    pidfile     /var/run/haproxy.pid
    maxconn     4000
    user        haproxy
    group       haproxy
    daemon

    # turn on stats unix socket
    stats socket /var/lib/haproxy/stats

#---------------------------------------------------------------------
# common defaults that all the 'listen' and 'backend' sections will
# use if not designated in their block
#---------------------------------------------------------------------
defaults
    mode                    http
    log                     global
    option                  httplog
    option                  dontlognull
    option http-server-close
    option forwardfor       except 127.0.0.0/8
    option                  redispatch
    retries                 3
    timeout http-request    10s
    timeout queue           1m
    timeout connect         10s
    timeout client          1m
    timeout server          1m
    timeout http-keep-alive 10s
    timeout check           10s
    maxconn                 3000

#---------------------------------------------------------------------
# kubernetes apiserver frontend which proxys to the backends
#---------------------------------------------------------------------
frontend kubernetes-apiserver
    mode                 tcp
    bind                 *:6444  # 对外提供服务的端口，必须和kubernetes一致
    option               tcplog
    default_backend      kubernetes-apiserver #后端服务的名称

#---------------------------------------------------------------------
# round robin balancing between the various backends
#---------------------------------------------------------------------
backend kubernetes-apiserver
    mode        tcp
    balance     roundrobin
    server  k8s-31 192.168.0.31:6443 check # 后端服务器hostname和IP
    server  k8s-42 192.168.0.42:6443 check # 后端服务器hostname和IP
    server  k8s-243 192.168.0.243:6443 check # 后端服务器hostname和IP
EOF

# 4.启动
systemctl start haproxy && systemctl enable haproxy && systemctl status haproxy
