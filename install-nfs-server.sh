#! /bin/bash

# user and group creation
groupadd kvm -g 36
useradd vdsm -u 36 -g kvm

# install nfs packages
yum install nfs-utils -y

# create share folder and set permissions
mkdir /var/nfs_folder 
chmod 755 /var/nfs_folder/
chown 36:36 /var/nfs_folder/

# give everyone permissions to it:
echo "/var/nfs_folder	*(rw,sync,no_subtree_check,all_squash,anonuid=36,anongid=36)" > /etc/exports

# restart NFS service
systemctl start rpcbind.service
systemctl start nfs-server.service
systemctl start nfs-lock.service 

systemctl enable rpcbind.service
systemctl enable nfs-server.service
systemctl enable nfs-lock.service

service nfs restart

# add the service to firewalld
firewall-cmd --add-service=nfs --permanent
firewall-cmd --reload
