#!/bin/bash
#author yangyang
#link-document
#文档：0221-部署 Kubernetes-初始化环境.note
#链接：http://note.youdao.com/noteshare?id=db7152a71a08d274610c3e5899ae2f2d&sub=25BF724F58CF47E783CE15ECD6D66072

#更新yum 源---------------------------------------------------------------------
# update kunpneng arm yum mirror
cat << EOF >  /etc/yum.repos.d/CentOS-Base-kunpeng.repo
[kunpeng]
name=CentOS-kunpeng - Base - mirrors.huaweicloud.com
baseurl=https://mirrors.huaweicloud.com/kunpeng/yum/el/7/aarch64/
gpgcheck=0
enabled=1
EOF

#update docker mirror

cat << EOF >/etc/yum.repos.d/docker-ce.repo
[docker-ce-stable]
name=Docker CE Stable - \$basearch
baseurl=https://mirrors.aliyun.com/docker-ce/linux/centos/7/\$basearch/stable
enabled=1
gpgcheck=1
gpgkey=https://mirrors.aliyun.com/docker-ce/linux/centos/gpg

[docker-ce-stable-debuginfo]
name=Docker CE Stable - Debuginfo \$basearch
baseurl=https://mirrors.aliyun.com/docker-ce/linux/centos/7/debug-\$basearch/stable
enabled=0
gpgcheck=1
gpgkey=https://mirrors.aliyun.com/docker-ce/linux/centos/gpg

[docker-ce-stable-source]
name=Docker CE Stable - Sources
baseurl=https://mirrors.aliyun.com/docker-ce/linux/centos/7/source/stable
enabled=0
gpgcheck=1
gpgkey=https://mirrors.aliyun.com/docker-ce/linux/centos/gpg

[docker-ce-edge]
name=Docker CE Edge - \$basearch
baseurl=https://mirrors.aliyun.com/docker-ce/linux/centos/7/\$basearch/edge
enabled=0
gpgcheck=1
gpgkey=https://mirrors.aliyun.com/docker-ce/linux/centos/gpg

[docker-ce-edge-debuginfo]
name=Docker CE Edge - Debuginfo \$basearch
baseurl=https://mirrors.aliyun.com/docker-ce/linux/centos/7/debug-\$basearch/edge
enabled=0
gpgcheck=1
gpgkey=https://mirrors.aliyun.com/docker-ce/linux/centos/gpg

[docker-ce-edge-source]
name=Docker CE Edge - Sources
baseurl=https://mirrors.aliyun.com/docker-ce/linux/centos/7/source/edge
enabled=0
gpgcheck=1
gpgkey=https://mirrors.aliyun.com/docker-ce/linux/centos/gpg

[docker-ce-test]
name=Docker CE Test - \$basearch
baseurl=https://mirrors.aliyun.com/docker-ce/linux/centos/7/\$basearch/test
enabled=0
gpgcheck=1
gpgkey=https://mirrors.aliyun.com/docker-ce/linux/centos/gpg

[docker-ce-test-debuginfo]
name=Docker CE Test - Debuginfo \$basearch
baseurl=https://mirrors.aliyun.com/docker-ce/linux/centos/7/debug-\$basearch/test
enabled=0
gpgcheck=1
gpgkey=https://mirrors.aliyun.com/docker-ce/linux/centos/gpg

[docker-ce-test-source]
name=Docker CE Test - Sources
baseurl=https://mirrors.aliyun.com/docker-ce/linux/centos/7/source/test
enabled=0
gpgcheck=1
gpgkey=https://mirrors.aliyun.com/docker-ce/linux/centos/gpg

[docker-ce-nightly]
name=Docker CE Nightly - \$basearch
baseurl=https://mirrors.aliyun.com/docker-ce/linux/centos/7/\$basearch/nightly
enabled=0
gpgcheck=1
gpgkey=https://mirrors.aliyun.com/docker-ce/linux/centos/gpg

[docker-ce-nightly-debuginfo]
name=Docker CE Nightly - Debuginfo \$basearch
baseurl=https://mirrors.aliyun.com/docker-ce/linux/centos/7/debug-\$basearch/nightly
enabled=0
gpgcheck=1
gpgkey=https://mirrors.aliyun.com/docker-ce/linux/centos/gpg

[docker-ce-nightly-source]
name=Docker CE Nightly - Sources
baseurl=https://mirrors.aliyun.com/docker-ce/linux/centos/7/source/nightly
enabled=0
gpgcheck=1
gpgkey=https://mirrors.aliyun.com/docker-ce/linux/centos/gpg
EOF


cat << EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-aarch64/
enabled=1
gpgcheck=0
repo_gpgcheck=0
gpgkey=https://mirrors.aliyun.com/kubernetes/yum/doc/yum-key.gpg https://mirrors.aliyun.com/kubernetes/yum/doc/rpm-package-key.gpg
EOF

#c初始化环境---------------------------------------------------------------------
#关闭swap
swapoff -a
cp -p /etc/fstab /etc/fstab.bak$(date '+%Y%m%d%H%M%S')
sed -i "s/\/dev\/mapper\/centos-swap/\#\/dev\/mapper\/centos-swap/g" /etc/fstab


#开启内核参数方便记录
echo 1 > /proc/sys/net/bridge/bridge-nf-call-iptables
echo 1 > /proc/sys/net/bridge/bridge-nf-call-ip6tables
echo 1 > /proc/sys/net/ipv4/ip_forward
#验证
lsmod | grep br_netfilter

#kube-proxy使用ipvs来实现负载均衡，所以需要安装ipvs环境。载入系统模块
modprobe ip_vs
modprobe ip_vs_rr
modprobe ip_vs_wrr
modprobe ip_vs_sh
modprobe nf_conntrack_ipv4

# 必须先安装 nfs-utils 才能挂载 nfs 网络存储
yum install -y nfs-utils >> /dev/null  2>&1

# 关闭 防火墙
systemctl stop firewalld
systemctl disable firewalld

# 关闭 SeLinux
setenforce 0
sed -i "s/SELINUX=enforcing/SELINUX=disabled/g" /etc/selinux/config


#同步时间
yum install ntpdate -y && ntpdate time.windows.com

#yum安装docker和Kubernetes-------------------------------------------------------
yum install -y yum-utils >> /dev/null  2>&1
yum makecache fast >> /dev/null  2>&1

#安装docker
yum install -y docker-ce-19.03 docker-ce-cli-19.03   >> /dev/null  2>&1
if [ ! -f /etc/docker/daemon.json ]
then
  mkdir /etc/docker
  touch /etc/docker/daemon.json
fi

echo -e '{\n"registry-mirrors": ["https://hub-mirror.c.163.com", "https://docker.mirrors.ustc.edu.cn"],\n"exec-opts": [ "native.cgroupdriver=systemd" ]\n}' >/etc/docker/daemon.json

systemctl daemon-reload
systemctl restart docker

#验证 调整docker
docker info| grep Cgroup
systemctl start docker&& systemctl enable docker



#清理x86 清楚已存在镜像
docker rm $(docker ps -aq)
docker rmi $(docker images -aq)
#安装Kubernetes
yum install -y kubelet-1.19.0 kubectl-1.19.0 kubeadm-1.19.0 kubernetes-cni-1.19.0 kubernetes-cni-1.19.0 -y >> /dev/null  2>&1
