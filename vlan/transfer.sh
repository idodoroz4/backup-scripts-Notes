#!/bin/bash

sshpass -p qum5net scp ifcfg-ens3 root@192.168.100.80:/etc/sysconfig/network-scripts/ifcfg-ens3
sshpass -p qum5net scp ifcfg-ens8 root@192.168.100.80:/etc/sysconfig/network-scripts/ifcfg-ens8

#sshpass -p qum5net ssh root@192.168.100.80 ip link add link ens3 name ens3.5 type vlan id 5
#sshpass -p qum5net ssh root@192.168.100.80 ip addr add 192.168.100.200/24 brd 192.168.100.255 dev ens3.5
