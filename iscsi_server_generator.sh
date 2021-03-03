#!/bin/sh

# HELP MENU
helpMenu="This script generates a local iscsi server using 'targetcli'.
Available flags:
-n:	The number of LUNs to create (default is 5).
-s:	The size of each LUN (default is 20GB).
-p:	The path to the storage files that will be created (default is /home/iscsi_LUNs).
-u:	The user name.
-r:	Resets the configuration in targetcli. Note that the files that were created will not be removed.
-h:	Shows this help menu.

For more information please refer to the targetcli's help."

localIPAddress=""
numOfLUNs=5
sizeOfEachLUN=40GB
storagePath="/home/iscsi_LUNs"
userName="benny"

if [[ "$(rpm -qa | grep targetcli)" == "" ]]; then
	if ! yum -y install targetcli; then
		echo Failed to install targetcli.
		exit 1
	fi
fi

while getopts ":n:s:p:u:rh" opt; do
	case $opt in
		n)  numOfLUNs=$OPTARG
			;;
		s)  sizeOfEachLUN=$OPTARG
			;;
		p)  storagePath=$OPTARG
			;;
		u)  userName=$OPTARG
                        ;;
		r)  targetcli clearconfig confirm=True
			exit 1
			;;
		h)	echo "$helpMenu"
			exit 1
			;;
		\?)
			echo "Invalid option: -$OPTARG"
			echo Showing help menu..
			echo "$helpMenu"
			exit 1
			;;
		:)
			echo "Option -$OPTARG requires an argument."
			exit 1
			;;
	esac
done

if [ ! -d "$storagePath" ]; then
	mkdir -p $storagePath
fi

targetName=iqn.2015-01.com.${userName}:444
targetcli <<- TARGET_CREATION
	/iscsi/ create $targetName
	/iscsi/${targetName}/tpg1/
	set attribute authentication=0 demo_mode_write_protect=0 generate_node_acls=1 cache_dynamic_acls=1
TARGET_CREATION

status=`targetcli /backstores/fileio/ status`
IFS=' ' read -a array <<< "$status"
numOfExistingLUNs=${array[5]}

for (( i=0; i<$numOfLUNs; i++ ))
do
	curLUNNum=$(($numOfExistingLUNs + $i))
	LUNName=lun$i
	fileName=${LUNName}.img
	fileioName=lun$curLUNNum

	targetcli <<- SERVER_CREATION
		/backstores/fileio create $fileioName ${storagePath}/${fileName} $sizeOfEachLUN
		/iscsi/${targetName}/tpg1/luns create /backstores/fileio/${fileioName}
	SERVER_CREATION
done

targetcli /
targetcli saveconfig
targetcli ls
chkconfig target on

firewall-cmd --permanent --add-port=3260/tcp
firewall-cmd --reload


