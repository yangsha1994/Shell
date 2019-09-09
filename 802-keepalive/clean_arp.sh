VIP=192.168.0.196
GATEWAY=192.168.0.1
/sbin/arping -I eth0 -c 5 -s $VIP $GATEWAY &>/dev/null
