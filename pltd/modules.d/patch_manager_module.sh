#/bin/bash

if [[ -d "/dev/shm" ]]; then

	rpmdb="/dev/shm/rpmdb"

elif [[ -d "/var/tmp" ]]; then

	rpmdb="/var/tmp/rpmdb"

else

	rpmdb="/tmp/rpmdb"

fi


if [[ -f "${rpmdb}" ]]; then

	chmod 600 "${rpmdb}"
	rpm -qa >"${rpmdb}"

else

	rpm -qa >"${rpmdb}"
	chmod 600 "${rpmdb}"

fi


function patch_manager_get_rpm_version {

	# define local rpm name
	local rpm_pack=$1
	
	# define local rpm version
	# local rpm_version=`echo ${rpm_pack} | grep -Eo "\-[0-9]{1,}\.[a-zA-Z0-9_\.]{1,}\-" | sed -e "s/\-//g"`
	local rpm_version=`echo ${rpm_pack} | grep -Eo "\-[0-9]{1,}\.[0-9a-zA-Z\.]{1,}-[0-9a-zA-Z_\.]{1,}\.(i686|x86_64|i386|noarch)" | sed -e "s/\.x86_64$//g" -e "s/\.i686$//g" -e "s/\.i386$//g" -e "s/\.noarch$//g" | awk -F\- '{print $2}'`
	
	# return the rpm version of the package passed as arg #1
	echo ${rpm_version}

}

function patch_manager_get_rpm_release {

	# define local rpm name
	local rpm_pack=$1

	# define local rpm release
	# local rpm_release=`echo ${rpm_pack} | grep -Eo "[0-9]{1,}\.[0-9]{1,}\-[0-9]{1,}\.[a-zA-Z0-9_\.]{1,}\." | awk -F\- '{print $2}' | sed "s/\.$//g"`
	local rpm_release=`echo ${rpm_pack} | grep -Eo "\-[0-9]{1,}\.[0-9a-zA-Z\.]{1,}-[0-9a-zA-Z_\.]{1,}\.(i686|x86_64|i386|noarch)" | sed -e "s/\.x86_64$//g" -e "s/\.i686$//g" -e "s/\.i386$//g" -e "s/\.noarch$//g" | awk -F\- '{print $3}'`
	
	# return the rpm release of the package passed as arg #1
	echo ${rpm_release}
	
}

function patch_manager_get_rpm_name {

	# define the local rpm name
	local rpm_pack=$1
	
	# define local rpm name
	# local rpm_name=`echo ${rpm_pack} | grep -Eo "^[0-9a-zA-Z_\-]{1,}\-" | sed -e "s/\-$//g"`
	local rpm_name=`echo ${rpm_pack} | sed -r "s/\-[0-9a-zA-Z\.]{1,}-[0-9a-zA-Z_\.]{1,}\.(i686|x86_64|i386|noarch)//g"`

	# return the rpm name of the package passed as arg #1
	echo ${rpm_name}
	
}

function patch_manager_get_rpm_arch {

	# define the local rpm name
	local rpm_pack=$1
	
	# define the local rpm arch
	local rpm_arch=`echo ${rpm_pack} | grep -Eo "\.[a-zA-Z0-9_\-]{1,}$" | sed "s/^\.//g"`
	
	# return the rpm arch
	echo ${rpm_arch} 

}

function patch_manager_get_errata_list {

	# define the patch list from where to extract the errata list
	local patch_file=$1
	
	for errata_name in `sed -ne "/^errata/p" -e "s/[\ ]{1,}$//g" "${patch_file}" | awk -F\. '{print $2}'`; do
		
		fdflg=0
		
		for errata_from_list in `echo ${patch_list[@]}`; do
	
			if [[ "${errata_name}" == "${errata_from_list}" ]]; then
			
				fdflg=1
				break
			
			fi
				
		done
		
		if [[ ${fdflg} -eq 0 ]]; then
		
			arr_free_index=${#patch_list[@]}
			patch_list[${arr_free_index}]="${errata_name}"
		
		fi
	
	done

	# return the content of the errata	
	echo "${patch_list[@]}"

}


function patch_manager_get_rpm_from_errata {

	# local define the errata name to use as ref to look for rpm pack
	local errata_name=$1
	
	# local define the patch list from where to identify the rpm list
	local patch_file=$2
	
	# define the list of rpm
	local rpm_list=`sed -ne "/^errata/p" -e "s/[\ ]{1,}$//g" "${patch_file}" | awk -F\= -v errata_search=${errata_name} '$0 ~ errata_search {print $2}'`

	# return the list of rpm
	echo ${rpm_list}

}


function patch_manager_normalize_rpm_name {

	# define the package name to normalize
	local rpm_pack=$1
	
	# remove the .rpm extension since this is not kept inside the rpm db
	echo ${rpm_pack//.rpm/}
	
}

function patch_manager_is_rpm_installed {

	# define the package to search in the rpm db
	local rpm_pack=$1
	
	if [[ `egrep -c "${rpm_pack}" "${rpmdb}"` -eq 1 ]]; then
	
		echo 1
	
	else
	
		echo 0
	
	fi

}

function patch_manager_get_patch_file {

	if [[ -f ${global_server_patch} ]] && [[ `egrep -c "^{global_hostname}," "${global_server_patch}"` -eq 1 ]];  then
	
		local server_patch_file=`egrep "^${global_hostname}," | awk -F\, '{print $2}'`
	
	else
	
		local server_patch_file=${global_rhel_release}
	
	fi


	# return the patch version
	echo "${server_patch_file}"

}


function patch_manager_get_rpm_installed_by_rpm_name {

	# define the rpm name to look for
	local rpm_name=$1
	
	if [[ `grep -Ewc "${rpm_name}" "${rpmdb}"` -eq 1 ]]; then
	
		# rpm name found
		local rpm_name_found=`egrep -w "${rpm_name}" "${rpmdb}"`

	elif [[ `grep -Ewc "${rpm_name}" "${rpmdb}"` -gt 1 ]]; then
		
		for rpm_pack in `grep -Ew "${rpm_name}" "${rpmdb}"`; do
		
			local rpm_found_name=`patch_manager_get_rpm_name "${rpm_pack}"`
			if [[ "${rpm_found_name}" == "${rpm_name}" ]]; then
			
				local rpm_name_found="${rpm_pack}"
				break
			
			fi
		
		done
		
	else
	
		# set value 0 to rpm_name_found because no rpm is matching this name
		local rpm_name_found=""
		
	fi
	
	# return the rpm name found
	echo "${rpm_name_found}" 

}