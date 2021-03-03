#!/bin/bash
#set -x

vm_name=$1
snapshot_name=$2
choice=$3

network_name='Network1'
playbook=/home/irosenzw/utils/local_vm_utils/playbook.yml
ansible_inventory=/home/irosenzw/utils/local_vm_utils/hosts

REVERT=false

function usage(){
	cat << __EOF__
usage: $0 vm_name snapshot_name run|update

__EOF__
}

function get_vm(){
	local vm=$(virsh list --all | grep $vm_name | awk '{print $2}')
	vm_count=$(virsh list --all | grep $vm_name | awk '{print $2}' | wc -l)
	if [[ $vm ]]; then
		if [[ $vm_count -eq 1 ]]; then
			vm_full_name=$vm
			local vmMac=$(virsh domiflist $vm_full_name | grep $network_name | awk '{print $5}')
			vm_ip=$(cat /var/lib/libvirt/dnsmasq/$network_name.hostsfile | grep $vmMac | awk -F',' '{print $2}')
			return 0
		else
			echo -e "Error: Found more then one VM: \n$vm\n"
			exit 1
		fi
	else
		echo -e "Error: No VM was found"
		exit 1
	fi
	return 1

}


function get_snapshot(){

	if [[ ! $snapshot_name ]]; then
		echo -n "please provide a snapshot: "
		read snap
		snapshot_name=$snap
	fi

	local snapshot=$(virsh snapshot-list $vm_full_name | awk '{print $1}' | grep $snapshot_name )
	local snapshot_count=$(virsh snapshot-list $vm_full_name | awk '{print $1}' | grep $snapshot_name | wc -l)

	if [[ $snapshot ]]; then
		if [[ $snapshot_count -eq 1  ]]; then
			final_snapshot=$snapshot
			return 0
		else
			echo -e "Error: found more then 1 snapshot: \n$snapshot\n"
			exit 1
		fi
	else
		echo -e "Error: No Snapshot was found"
		echo -e "Available snapshots:"
		virsh snapshot-list $vm_full_name
		exit 1
	fi
	return 1

}


function revert_to_snapshot() {
	local ans
	if [ ! $REVERT ]; then
		echo -n "Are you sure you want to revert $vm_full_name to $final_snapshot? [y/n] "
		read ans
		REVERT=true
	else
		ans="yes"
	fi

	if [[ "$ans" == "y" || "$ans" == yes ]]; then
		$(virsh snapshot-revert $vm_full_name --snapshotname $final_snapshot)
	else
		echo "No positive answer was given"
	fi
}

function get_vm_ip() {
	local vmMac=$(virsh domiflist $vm_full_name | grep $network_name | awk '{print $5}')
	vm_ip=$(cat /var/lib/libvirt/dnsmasq/$network_name.hostsfile | grep $vmMac | awk -F',' '{print $2}')
}


function yum_update_vm(){

	echo "Running yum update on $vm_full_name"
	# find host's group name in ansible invetory by searching for vm's IP
	# each vm has it's own group

	# get line number of vm_ip in inventory
	local host_line=$(cat $ansible_inventory | grep -n $vm_ip | awk -F':' '{print $1}')
	let group_line=$host_line-1

	vm_ansible_host_group=$(sed -n $group_line'p' $ansible_inventory | sed 's/\[\(.*\)\]/\1/')

	# run ansible on the relevant host
	ansible-playbook $playbook \
		-i $ansible_inventory \
		--extra-vars "host=$vm_ansible_host_group"

}

function start_from_scratch(){
	get_vm
	if [[ $vm_full_name ]]; then
		get_snapshot
		if [[ $final_snapshot ]]; then
			revert_to_snapshot
			virsh start $vm_full_name
		fi
	fi
}

function check_ssh_connection(){

	# check if vm can be connected via ssh
	check_ssh=$(nmap $vm_ip -PN -p ssh | grep open)
	while [ ! $check_ssh ]
	do
		echo "check for SSH connection"
		sleep 5
		check_ssh=$(nmap $vm_ip -PN -p ssh | grep open | awk '{print $2}')
	done

	echo "SSH connection can be established"

}

function update_snapshot(){
	start_from_scratch

	check_ssh_connection
	local copy_ssh_key=$(sshpass -p "qum5net" ssh-copy-id root@$vm_ip)
	yum_update_vm
	virsh shutdown $vm_full_name

	# check if vm has shutdown
	vm_status=$(virsh domstate $vm_full_name)
	while [ ! "$vm_status" == "shut off" ]
	do
		echo "checking if vm is down - vm status: $vm_status"
		sleep 5
		vm_status=$(virsh domstate $vm_full_name)
	done

	echo "VM is down"
	virsh snapshot-delete $vm_full_name --snapshotname $final_snapshot
	virsh snapshot-create-as $vm_full_name --name $final_snapshot
	run
}

function run(){
	start_from_scratch
	check_ssh_connection
	ssh root@$vm_ip
}


if [[ -z "${vm_name}" || -z "${snapshot_name}" || -z "${choice}"  ]]; then
	echo "invalid options. aborting..."
	usage
	exit 1
fi

case "${choice}" in
	run)
		run
		;;
	update)
		update_snapshot
		;;
	*)
		printf "Invalid choice ${choice}. Aborting..."
		usage
		exit 1
		;;
esac

