#!/bin/bash

iptables -F
iptables -P INPUT ACCEPT
iptables -P OUTPUT ACCEPT
iptables -P FORWARD ACCEPT
SCRIPTPATH="$( cd "$(dirname "$0")" ; pwd -P )"
date >> $SCRIPTPATH/Firewall_Reset.log
