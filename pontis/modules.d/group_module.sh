#!/bin/bash

group_file="/etc/group"


function group_exist {

	local group_name="$1"
	local gid=$2
	local cmd_res=0

	if [[ "$gid" == '' ]]; then
		
		if [[ `grep -c "^${group_name}\:" "${group_file}"` -eq 1 ]]; then

			cmd_res=1

		fi

	else

		if [[ `grep -c "^${group_name}\:.*\:${gid}\:" "${group_file}"` -eq 1 ]]; then

			cmd_res=1

		fi

	fi

	echo ${cmd_res}

}


function group_create {
	
	local group_name=$1
	local gid=$2
	local cmd_res=0

	if [[ "$gid" == '' ]] ; then

		groupadd "${group_name}" &>/dev/null

		if [[ `group_exist "${group_name}"` -eq 1 ]]; then

			cmd_res=1

		fi

	else

		groupadd "${group_name}" -g "${gid}"

		if [[ `group_exist "${group_name}" "${gid}"` -eq 1 ]]; then

			cmd_res=1

		fi

	fi

	echo ${cmd_res}

}

function group_delete {

	local group_name=$1

		groupdel "${group_name}" &>/dev/null

	if [[ `group_exist "${group_name}"` -eq 0 ]]; then

		echo 1

	else

		echo 0

	fi
}


function group_add_user {

	local group_name=$1
	local username=$2

	usermod -a -G ${group_name} ${username} &>/dev/null
	
	if [[ $? -eq 0 ]]; then
	
		echo 1

	else

		echo 0

	fi
}

function group_restore_cmd_get {

	local group_name=$1
	#local group_id=`awk -F\: -v grp=${group_name} '$1 == grp {print $3}' ${group_file}` 

	#	cmd_line="groupadd -g ${group_id} ${group_name}"
	cmd_line="groupadd ${group_name} &>/dev/null"

	echo "${cmd_line}"
}

function group_name_per_id {

	local group_id=$1

	echo `awk -F\: -v grp=${group_id} '$3 == grp {print $1}' ${group_file}`

}

