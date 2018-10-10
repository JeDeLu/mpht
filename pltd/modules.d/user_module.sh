#!/bin/bash

user_file="/etc/passwd"
password_file="/etc/shadow"

function user_exist {

	local username=$1
	
	if [[ `egrep -c "^${username}\:" "${user_file}"` -eq 1 ]]; then

		echo 1

	else

		echo 0

	fi
}

function user_create {
	
	local username=$1
	local uid=$2
	local gid=$3
	local cmd_res=0


	if [[ "${uid}" == '' ]] && [[ "${gid}" == '' ]]; then
	
		useradd "${username}" &>/dev/null

		if [[ `user_exist "${username}"` -eq 1 ]]; then

			cmd_res=1

		fi

	elif [[ "${uid}" != '' ]] && [[ "${gid}" == '' ]]; then

		useradd -u "${uid}" "${username}" &>/dev/null		

		if [[ `user_exist "${username}" "${uid}"` -eq 1 ]]; then

			cmd_res=1

		fi

	elif [[ "${uid}" != '' ]] && [[ "${gid}" != '' ]]; then


		useradd -u "${uid}" -g "${gid}" "${username}" &>/dev/null		

		if [[ `user_exist "${username}" "${uid}" "${gid}"` -eq 1 ]]; then

			cmd_res=1

		fi

	elif [[ "${uid}" == '' ]] && [[ "${gid}" != '' ]]; then

		useradd -g "${gid}" "${username}" &>/dev/null		

		if [[ `user_exist "${username}" "${gid}"` -eq 1 ]]; then

			cmd_res=1

		fi

	fi

	echo "${cmd_res}"
	
}

function user_delete {

	local user_name=$1

	userdel ${user_name} &>/dev/null

	if [[ $? -eq 0 ]]; then

		echo 1

	else

		echo 0

	fi
}


function user_in_group {

	local username=$1
	local group_ref=$3
	
	case $2 in
		name)

			grep "^${group_ref}\:" ${group_file} | grep "${username}" >/dev/null

			if [[ $? -eq 0 ]]; then

				echo 1
			
			else 

				echo 0

			fi 
		;;

		gid)
			
			grep "\:${group_ref}\:" ${group_file} | grep "${username}" >/dev/null

			if [[ $? -eq 0 ]]; then

				echo 1

			else

				echo 0

			fi
		;;

		*)
		;;
	esac
}


function user_home_get {

	local user_name=$1
	local user_home	
	
	grep "^${user_name}" ${user_file} &>/dev/null
	if [[ $? -eq 0 ]]; then
	
		user_home=`awk -F\: -v user=${user_name} '$1 ~ user {print $6}' ${user_file}`
		
		if [[ $? -eq 0 ]]; then

			echo "1|${user_home}"		

		else
			
			echo "0|"

		fi

	else

		echo "0|"	

	fi
}

function user_shell_get {

	local user_name=$1

	local user_shell=`awk -F\: -v user=${user_name} '$1 == user {print $7}' ${user_file}`

	if [[ $? -eq 0 ]]; then

		echo 1"|${user_shell}"

	else

		echo 0"|"

	fi
}

function user_shell_set {

	local user_name=$1
	local user_shell=$2

	usermod -s "${user_shell}" "${user_name}" &>/dev/null

	if [[ $? -eq 0 ]]; then

		echo 1

	else

		echo 0

	fi
}

function user_restore_cmd_get {

	source ./modules.d/group_module.sh

	local user_name=$1
	local user_id=`awk -F\: -v user=${user_name} '$1 == user {print $3}' ${user_file}`

	local user_gid=`awk -F\: -v user=${user_name} '$1 == user {print $4}' ${user_file}`
	local user_group_name=`group_name_per_id ${user_gid}`

	local user_info=`awk -F\: -v user=${user_name} '$1 == user {print $5}' ${user_file}`
	local user_home=`awk -F\: -v user=${user_name} '$1 == user {print $6}' ${user_file}`
	local user_shell=`awk -F\: -v user=${user_name} '$1 == user {print $7}' ${user_file}`

	cmd_line="useradd -c \"${user_info}\" -d ${user_home} -m -s ${user_shell} -u ${user_id} -g ${user_group_name} ${user_name} &>/dev/null"

	echo "${cmd_line}"
}

function user_password_lock_set {

	local username=$1
	local lock_pattern="!!"
	local shadow_pwd_field=`awk -F\: '{print $2}' "${password_file}"`
	local old_pattern="^${username}:${shadow_pwd_field}:"
	local new_pattern="^${username}:${lock_pattern}:"

	if [[ "${shadow_pwd_field}" != "${lock_pattern}" ]] ; then 
 	
 		sed -i "s/${old_pattern}/${new_pattern}/" "${password_file}" &>/dev/null

 	fi

	user_password_lock_get

}

function user_password_lock_get {

	local username=$1
	local shadow_pwd_field=`awk -F\: '{print $2}' "${password_file}"`
	
	if [[ "${shadow_pwd_field}" ==  "!!" ]]; then

		echo 1

	else

		echo 0

	fi
}

function user_is_uid {

	local username="$1"
	local uid="$2"
	local useruid_found=`awk -v user=${username} -F\: '$1 == user {print $3}' "${user_file}"`

	if [[ ${uid} -eq ${useruid_found} ]]; then

		echo 1 

	else

		echo 0

	fi

}


function user_is_gid {

	local username="$1"
	local gid="$2"
	local usergid_found=`awk -v user=${username} -F\: '$1 == user {print $4}' "${user_file}"`

	if [[ ${gid} -eq ${usergid_found} ]]; then

		echo 1 

	else

		echo 0

	fi

}