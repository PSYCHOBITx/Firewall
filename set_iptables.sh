#!/bin/bash

apt-get install -fmy iptables-persistent

#count=0
#for f in `ls /sys/class/net`; do
#   export eth$count=$f
#   (( count++ ))
#   eval echo \$eth${count}
#   echo $f
#done

#Allow DHCP/DNS/SSH/RSYNC/NTP on eth0
export eth0=
#Allow HTTP/HTTPS/RSYNC/DNS/NTP/ICMP on eth1
export eth1=

iptables -F
iptables -X
iptables -t nat -F
iptables -t nat -X
iptables -t mangle -F
iptables -t mangle -X

iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT DROP

iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT
iptables -A INPUT -i $eth0 -j LOG --log-prefix "IPtables dropped packets:"
iptables -A INPUT -i $eth1 -j LOG --log-prefix "IPtables dropped packets:"

#DNS
iptables -A OUTPUT -p udp --dport 53 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A INPUT  -p udp --sport 53 -m state --state ESTABLISHED     -j ACCEPT
iptables -A OUTPUT -p tcp --dport 53 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A INPUT  -p tcp --sport 53 -m state --state ESTABLISHED     -j ACCEPT

#SSH
iptables -A INPUT -i $eth0 -p tcp --dport 22 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
iptables -A INPUT -p tcp --dport 22 -m conntrack --ctstate NEW,ESTABLISHED -j REJECT --reject-with tcp-reset
iptables -A OUTPUT -p tcp --sport 22 -m conntrack --ctstate ESTABLISHED -j ACCEPT
#iptables -A INPUT -p tcp --dport 22 -m state --state NEW,ESTABLISHED -j ACCEPT
#iptables -A OUTPUT -p tcp --sport 22 -m state --state ESTABLISHED -j ACCEPT


#HTTP/HTTPS
iptables -A INPUT -i $eth1 -p tcp --dport 80 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -o $eth1 -p tcp --sport 80 -m state --state ESTABLISHED -j ACCEPT
iptables -A INPUT -i $eth1 -p tcp --dport 443 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -o $eth1 -p tcp --sport 443 -m state --state ESTABLISHED -j ACCEPT

#RSYNC
iptables -A INPUT -p tcp --sport 873 -m state --state ESTABLISHED -j ACCEPT
iptables -A OUTPUT -p tcp --dport 873 -m state --state NEW,ESTABLISHED -j ACCEPT

#NTP
iptables -A OUTPUT -p udp --dport 123 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A INPUT -p udp --sport 123 -m state --state ESTABLISHED -j ACCEPT
#Ping
iptables -A INPUT -i $eth1 -p icmp -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT
iptables -A OUTPUT -o $eth1 -p icmp -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT
#DHCP
iptables -A INPUT -i $eth0 -p udp --dport 67:68 --sport 67:68 -j ACCEPT

#limit
iptables -A INPUT -i $eth1 -p tcp --dport 80 -m limit --limit 100/minute --limit-burst 200 -j ACCEPT
iptables -A INPUT -i $eth1 -p tcp --dport 443 -m limit --limit 100/minute --limit-burst 200 -j ACCEPT
iptables -A INPUT -p tcp --syn --dport 22 -m connlimit --connlimit-above 5 -j REJECT

#Drop at last
iptables -A INPUT -m conntrack --ctstate INVALID -j DROP
iptables -A INPUT -j DROP
iptables -A OUTPUT -j DROP

#Save rules
iptables-save | sudo tee /etc/iptables/rules.v4

#Reset iptables every 10 minutes for testing from remote
#path=`pwd`
#count1=$(grep -c "*/10  *  * * *   root    ${path}/reset_iptables.sh" /etc/crontab)
#if [ $count1 -eq 0 ]; then
#  echo "*/10  *  * * *   root    ${path}/reset_iptables.sh" >> /etc/crontab
#fi
