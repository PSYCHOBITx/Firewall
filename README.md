# Setup Firewall using iptables


path=`pwd`
count=$(grep -c "*/10  *  * * *   root    ${path}/reset_iptables.sh" /etc/crontab)
#Reset iptables every 10 minutes
if [ $count -eq 0 ]; then
#echo "*/10  *  * * *   root    ${path}/reset_iptables.sh" >> /etc/crontab
  echo "*/10  *  * * *   root    ${path}/reset_iptables.sh" 
fi

