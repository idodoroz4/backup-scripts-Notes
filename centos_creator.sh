#! /bin/bash

if [ "$1" == "" ]
then
  echo "provide a file name"
else
  virt-builder centos-7.2 --format qcow2 --size 60G --root-password password:12345678 --hostname localhost -o $1.qcow2
fi
