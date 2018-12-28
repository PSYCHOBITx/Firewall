# Setup Firewall using iptables

## Simple firewall rules to filter packets using Linux kernel netfilter framework.

## Steps

> 1. Update set_iptables.sh with appropriate network interfaces.
> 2. Add rules if you have more than 2 interfaces.
> 3. Execute set_iptables.sh with sudo permission.
>> sudo ./set_iptables.sh
> 4. While testing remotely, add crontab entry to reset firewall every 10 minutes.
