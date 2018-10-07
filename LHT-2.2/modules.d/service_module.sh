#!/bin/bash

function service6_exist {

	local service_name=$1

	chkconfig --list "${service_name}" &>/dev/null

	if [[ $? -eq 0 ]]; then

		echo 1
	
	else

		echo 0

	fi
}

function service7_exist {

	local service_name=$1

	local service_active=`systemctl is-active "${service_name}" 2>/dev/null`

	if [[ "${service_active}" == "active" ]] || [[ "${service_active}" == "inactive" ]]; then

		echo 1

	else

		echo 0

	fi
}


function service6_on_get {

	local service_name=$1
	local level=`runlevel | awk '{print $2}'`
	((field=${level}+2))
	local service_line=`chkconfig --list "${service_name}" 2>/dev/null`
	
	if [[ `echo ${service_line} | awk '{print NF}'` -gt 2 ]]; then

		local status=`echo ${service_line} | awk -v f=${field} '{print $f}' | awk -F\: '{print $2}'`	

	else

		local status=`echo ${service_line} | awk '{print $2}'`

	fi

	if [[ ${status} == "on" ]]; then

		echo 1

	else

		echo 0

	fi
}

function service7_on_get {

	local service_name=$1

	local service_enable=`systemctl is-enabled "${service_name}" 2>/dev/null`

	if [[ "${service_enable}" == "enabled" ]]; then

		echo 1

	else

		echo 0

	fi
}


function service6_on_set {

	local service_name=$1

	chkconfig "${service_name}" on &>/dev/null

	if [[ `service6_on_get "${service_name}"` -eq 1 ]]; then

		echo 1

	else

		echo 0

	fi
}

function service7_on_set {

	local service_name=$1

	systemctl enable "${service_name}" &>/dev/null

	if [[ `service7_on_get "${service_name}"` -eq 1 ]]; then

		echo 1

	else

		echo 0

	fi
}


function service6_off_get {

	local service_name=$1
	local level=`runlevel | awk '{print $2}'`
	((field=${level}+2))
	local service_line=`chkconfig --list "${service_name}" 2>/dev/null`
	
	if [[ `echo ${service_line} | awk '{print NF}'` -gt 2 ]]; then

		local status=`echo ${service_line} | awk -v f=${field} '{print $f}' | awk -F\: '{print $2}'`	

	else

		local status=`echo ${service_line} | awk '{print $2}'`

	fi

	if [[ ${status} == "off" ]]; then

		echo 1

	else

		echo 0

	fi
}

function service7_off_get {

	local service_name=$1

	local service_enable=`systemctl is-enabled "${service_name}" 2>/dev/null`

	if [[ "${service_enable}" == "disabled" ]]; then

		echo 1

	else

		echo 0

	fi
}


function service6_off_set {

	local service_name=$1

	chkconfig "${service_name}" off &>/dev/null

	if [[ $? -eq 0 ]]; then

		echo 1

	else

		echo 0

	fi
}

function service7_off_set {

	local service_name=$1

	systemctl disable "${service_name}" &>/dev/null

	if [[ $? -eq 0 ]]; then

		echo 1

	else

		echo 0

	fi
}



function xinetd_sub_off {

	local service_on=0
	local service_name=xinetd
	local xinet_dir="/etc/inetd.d/"
  local subservlist=""

	for subserv in `ls /etc/xinetd.d/`; do

		if [[ `service6_on_get ${subserv}` -eq 1 ]]; then

			service_on=1
			subservlist=${subserv}","${subservlist}

		fi

	done

	if [[ ${service_on} -eq 0 ]]; then

		echo 1

	else

		echo 0"|"${subservlist}

	fi

}
