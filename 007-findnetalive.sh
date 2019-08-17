#!/bin/bash
#扫描网络内存活的主机
#author:yangyang

#nmap 扫描输出

[[ -z $(rpm -qa nmap) ]] && yum install nmap -y 

CMD="nmap -sP"
IP="192.168.68.0/24"
$CMD $IP | awk '/Nmap scan report for /{print $NF}'




