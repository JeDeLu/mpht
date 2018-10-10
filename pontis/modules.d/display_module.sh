#!/bin/bash

function prt_func_res {

	local job_id=$1	
	local job_name=$2
	local ftype=$3
	local msg=$5

	case $4 in
		
		ok|OK)
		
			local func_res=1"|[`prt_stdout_bold ${ftype}`]--{`prt_stdout_yellow ${job_id}`}--( `prt_stdout_blue ${job_name}` )> `prt_stdout_res_ok \"${msg}\"`"
			
		;;

		nok|NOK)
	
			local func_res=0"|[`prt_stdout_bold ${ftype}`]--{`prt_stdout_yellow ${job_id}`}--( `prt_stdout_blue ${job_name}` )> `prt_stdout_res_nok \"${msg}\"`"
			
		;;
		
		warning|WARNING)
		
			local func_res=1"|[`prt_stdout_bold ${ftype}`]--{`prt_stdout_yellow ${job_id}`}--( `prt_stdout_blue ${job_name}` )> `prt_stdout_res_warn \"warning: ${msg}\"`"
			
		;;

		*)

		;;

	esac

	echo ${func_res}

}

function prt_stdout_res_ok {
	
	local string=$1

	echo -e "\033[0;32m${string}\033[0m"

}

function prt_stdout_res_nok {

	local string=$1

	echo -e "\033[0;31m${string}\033[0m"

}

function prt_stdout_res_warn {

	local string=$1

	echo -e "\033[0;33m${string}\033[0m"

}

function prt_stdout_bold {

	local string=$1

	echo -e "\033[1m${string}\033[0m"

}

function prt_stdout_blue {

	local string=$1

	echo -e "\e[94m${string}\e[0m"

}

function prt_stdout_green {

	local string=$1

	echo -e "\e[32m${string}\e[0m"

}

function prt_stdout_yellow {

	local string=$1

	echo -e "\e[93m${string}\e[0m"

}

function prt_stdout_magenta {

	local string=$1

	echo -e "\e[95m${string}\e[0m"

}

function prt_stdout_red {

	local string=$1

	echo -e "\033[0;31m${string}\033[0m"

}

function prt_stdout_underline {

	local string=$1
	
	echo -e "\e[4m${string}\e[0m"

}

function prt_stdout_inverted {

	local string=$1
	
	echo -e "\e[7m${string}\e[0m"

}