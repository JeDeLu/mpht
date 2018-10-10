#!/bin/bash

function file_owner_get {
	
	local file_name=$1
	local file_owner=`stat --format=%U ${file_name} 2>/dev/null`

	if [[ $? -eq 0 ]]; then
	
		echo 1"|${file_owner}"

	else
		
		echo 0"|"

	fi	
}

function file_owner_set {
	
	local file_name=$2
	local file_owner=$1

	chown ${file_owner} ${file_name}
	
	if [[ $? -eq 0 ]]; then

		echo 1

	else

		echo 0

	fi
}

function file_group_get {

	local file_name=$1
	local file_group=`stat --format=%G ${file_name} 2>/dev/null`

	if [[ $? -eq 0 ]]; then

		echo 1"|${file_group}"

	else

		echo 0"|"

	fi
}

function file_group_set {

	local file_name=$2
	local file_group=$1

	chown :${file_group} ${file_name}

	if [[ $? -eq 0 ]]; then

		echo 1

	else

		echo 0

	fi
}

function file_perm_get {

	local file_name=$1
	local file_perm=`stat --format=%a ${file_name} 2>/dev/null`

	if [[ $? -eq 0 ]]; then

		echo 1"|${file_perm}"

	else

		echo 0"|"

	fi
}

function file_perm_set {

	local file_name=$2
	local file_perm=$1

	chmod ${file_perm} ${file_name}

	if [[ $? -eq 0 ]]; then

		echo 1

	else

		echo 0

	fi
}

function file_exist {
	
	local file_type=$1
	local file_name=$2

	case $1 in
		file)
	
			if [[ -f "${file_name}" ]]; then

				echo 1

			else
			
				echo 0

			fi
		;;

		dir)

			if [[ -d "${file_name}" ]]; then

				echo 1

			else

				echo 0

			fi
		;;

		*)
		;;

	esac

}

function file_create {
	
	local file_type=$1
	local file_name=$2

	case $1 in
		file)

			touch "${file_name}"

			if [[ $? -eq 0 ]]; then

				echo 1

			else
		
				echo 0

			fi
		;;

		dir)

			mkdir -p "${file_name}"
			
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

function file_delete {

	local file_name=$1

	# avoid to introduce wildcard '*' into path, the file cannot be a '*'
	if [[ `echo "${file_name}" | egrep -c "\*"` -gt 0 ]]; then
		
		echo 0

	# if the nature of the file is one of the 3 elements
	else
		
		rm -fr "${file_name}" &>/dev/null
	 
		if [[ $? -eq 0 ]]; then
		
			echo 1

		else
		
			echo 0

		fi

	fi
}

function file_symlink_src_get {

	local file_name=$1

	local src=`ls -l ${file_name} | awk '{print $11}'`

	echo ${src}
}

function file_immutable_set {

	local file_name=$1

	chattr +i ${file_name}

	if [[ $? -eq 0 ]]; then
	
		echo 1

	else

		echo 0

	fi
}

function file_immutable_get {

	local file_name=$1

	if [[ `lsattr "${file_name}" | egrep -oc "\-i\-"` -eq 1 ]]; then

		echo 1

	else

		echo 0

	fi
}

function file_source_get {

	local file_name="$1"
	local file_source
	local current_dir=`pwd`

	while true; do

    file_dir=`dirname "${file_name}"`
		cd "${file_dir}"
		file_dir=`pwd`
		file_base=`basename "${file_name}"`
		
		if [[ -L "${file_base}" ]]; then
		
			file_name=`ls -l "${file_base}" | awk '{print $11}'`
			
		else
		
			file_source="${file_dir}/${file_base}"
			break
			
		fi

	done
	
	cd "${current_dir}"
	echo "${file_source}"

}


function file_match_line_pattern {

	# the line
	local line=$1
	
	# the file name
	local file_name=$2
	
	# init the search res
	local search_res="0|"
	
	# identify the number of matching lines in the file
	local nb_line=`egrep -oc "^${line}$" "${file_name}"`
	
	# no line found
	if [[ ${nb_line} -eq 0 ]]; then
	
		search_res="0|NO FOUND"
	
	# one line found
	elif [[ ${nb_line} -eq 1 ]]; then
	
		search_res="1|ONE FOUND"
	
	# more than one line found
	else
	
		search_res="2|MULTIPLE FOUND"
	
	fi
	
	# return the result of the search
	echo "${search_res}"
	
}
	

function file_match_pattern {

	# * looking into file for an exact match
	# *
	# * look first for an exact pattern match
	# * if the exact match is returning OK
	# * then return the RC = 1 without pattern
	# *
	# * if the exact match is returning NOK
	# * then look for a partial pattern match
	# * if the partial pattern matches
	# * then return the RC = 0 and the pattern
	# *

	local file_name=$1
	local exact_pattern=$2
	local partial_pattern=$3
	local RC=0
	local RP="" 

	if [[ `egrep -oc "^${exact_pattern}" ${file_name}` -eq  1 ]]; then

		RC=1

	elif [[ `egrep -c "${partial_pattern}" "${file_name}"` -gt 1 ]]; then

		if [[ `egrep -c "^${partial_pattern}" "${file_name}"` -gt 0 ]]; then

			RP=`egrep "^${partial_pattern}" "${file_name}" | tail -1`

		elif [[ `egrep -c "^#[\ ]*${partial_pattern}|^#${partial_pattern}" "${file_name}"` -gt 0 ]]; then

			RP=`egrep "^#[\ ]*${partial_pattern}|^#${partial_pattern}" "${file_name}" | tail -1`

		elif [[ `egrep -c "^#.*${partial_pattern}" "${file_name}"` -gt 0 ]]; then
			
			RP=`egrep "^#.*${partial_pattern}" "${file_name}" | tail -1`

		else

			RP=`egrep "${partial_pattern}" "${file_name}" | tail -1`

		fi

	else

		RP=`egrep "${partial_pattern}" "${file_name}"`

	fi

	echo ${RC}"|${RP}"

}

