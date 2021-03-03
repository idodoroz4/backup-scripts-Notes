#!/bin/bash
parentNIC=ens3
newNIC=macvlan0
macAddress=00:1a:4a:16:33:06

# add new macvlan interface
ip link add dev $newNIC link $parentNIC type macvlan

# change mac address for the NIC
ip link set dev $newNIC address $macAddress

#save routes
ip route save >/tmp/routes

# run dhcp client for the new interface
dhclient -v -pf /tmp/aa.pid  $newNIC
sleep 1

# show the address received for the NIC
ip addr show $newNIC

# cleanup and restore routes
pkill -F /tmp/aa.pid
ip link del dev $newNIC
ip route restore </tmp/routes
