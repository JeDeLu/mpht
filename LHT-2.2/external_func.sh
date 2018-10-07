#!/bin/bash

# ********************** EXTERNAL FUNCTIONS *********************************
# * this file define all the functions called by the main script
# * 
# *
# * declare any global functions here
# *


function get_test_value_by_id { 

	local job_id=$1

	echo `echo ${job[${job_id}]} | awk -F, '{print $2}' | awk -F= '{print $2}'`

}

function get_backup_value_by_id {
	
	local job_id=$1
 
	echo `echo ${job[${job_id}]} | awk -F, '{print $3}' | awk -F\| '{print $1}' | awk -F= '{print $2}'`

}

function get_backup_state_by_id {

	local job_id=$1

	echo `echo ${job[${job_id}]} | awk -F, '{print $3}' | awk -F\| '{print $2}' | awk -F= '{print $2}'`

}

function get_backup_src_by_id {

	local job_id=$1

	echo `echo ${job[${job_id}]} | awk -F, '{print $3}' | awk -F\| '{print $3}' | awk -F= '{print $2}'`

}

function get_backup_dest_by_id {

	local job_id=$1

	echo `echo ${job[${job_id}]} | awk -F, '{print $3}' | awk -F\| '{print $4}' | awk -F= '{print $2}'`
}

function get_update_value_by_id {

	local job_id=$1
 
	echo `echo ${job[${job_id}]} | awk -F, '{print $4}' | awk -F= '{print $2}'`

}

function get_restore_value_by_id { 

	local job_id=$1

	echo `echo ${job[${job_id}]} | awk -F, '{print $5}' | awk -F\| '{print $1}' | awk -F= '{print $2}'`

}

function get_restore_src_by_id {

	local job_id=$1

	echo `echo ${job[${job_id}]} | awk -F, '{print $5}' | awk -F\| '{print $2}' | awk -F= '{print $2}'`

}

function get_restore_dest_by_id {

	local job_id=$1

	echo `echo ${job[${job_id}]} | awk -F, '{print $5}' | awk -F\| '{print $3}' | awk -F= '{print $2}'`

}


function update_test_by_id { 

	local job_id=$1	
	local level=2
	local nbcol=`echo ${job[$1]} | awk -F, '{print NF}'`
	local newstr=`echo ${job[$1]} | awk -F, '{print $1}'`
	local todo_test

	case $2 in 
		0|disable)
			todo_test="test=0"
		;;
		1|enable)
			todo_test="test=1"
		;;
		*)
			usage
			exit 1
		;;
	esac

  for index in `seq 2 $nbcol`; do
		if [[ ${index} -eq ${level} ]]; then
			newstr="${newstr} ${todo_test} "
		else
			newstr="${newstr} `echo ${job[${job_id}]} | awk -F, -v colnum=$index '{print $colnum}'`"
		fi  
	done

	job[${job_id}]=`echo ${newstr} | sed 's%\ %,%'g`

}

function update_backup_by_id {  

	local job_id=$1
	local level=3
	local nbcol=`echo ${job[$1]} | awk -F, '{print NF}'`
	local newstr=`echo ${job[$1]} | awk -F, '{print $1}'`
	local todo_backup
	local backup_value=`get_backup_value_by_id $1`
	local backup_state=`get_backup_state_by_id $1`
	local backup_src=`get_backup_src_by_id $1`
	local backup_dest=`get_backup_dest_by_id $1`

	case $2 in 
		0|disable)
			todo_backup="backup=0|state=${backup_state}|src=${backup_src}|dest=${backup_dest}"
		;;
		1|enable)
			todo_backup="backup=1|state=${backup_state}|src=${backup_src}|dest=${backup_dest}"
		;;
		state)
			case $3 in
				0|failed)
					todo_backup="backup=${backup_value}|state=0|src=${backup_src}|dest=${backup_dest}"
				;;
				1|success)
					todo_backup="backup=${backup_value}|state=1|src=${backup_src}|dest=${backup_dest}"
				;;
				*)
					usage
					exit 1
				;;
			esac
		;;
		*)
			usage
			exit 1
		;;
	esac

  for index in `seq 2 $nbcol`; do
		if [[ ${index} -eq ${level} ]]; then
			newstr="${newstr} ${todo_backup} "
		else
			newstr="${newstr} `echo ${job[${job_id}]} | awk -F, -v colnum=$index '{print $colnum}'`"
		fi  
	done

	job[${job_id}]=`echo ${newstr} | sed 's%\ %,%'g`

}

function update_update_by_id { 

	local job_id=$1
	local level=4
	local nbcol=`echo ${job[${job_id}]} | awk -F, '{print NF}'`
	local newstr=`echo ${job[${job_id}]} | awk -F, '{print $1}'`
	local todo_update

	case $2 in 
		0|disable)
			todo_update="update=0"
		;;
		1|enable)
			todo_update="update=1"
		;;
		*)
			usage
			exit 1
		;;
	esac

  for index in `seq 2 $nbcol`; do
		if [[ ${index} -eq ${level} ]]; then
			newstr="${newstr} ${todo_update} "
		else
			newstr="${newstr} `echo ${job[${job_id}]} | awk -F, -v colnum=$index '{print $colnum}'`"
		fi  
	done

	job[${job_id}]=`echo ${newstr} | sed 's%\ %,%'g`

 }

function update_restore_by_id {

	local job_id=$1
	local level=5
	local nbcol=`echo ${job[${job_id}]} | awk -F, '{print NF}'`
	local newstr=`echo ${job[${job_id}]} | awk -F, '{print $1}'`
	local todo_restore
	local restore_value=`get_restore_value_by_id ${job_id}`
	local restore_src=`get_restore_src_by_id ${job_id}`
	local restore_dest=`get_restore_dest_by_id ${job_id}`

	case $2 in 
		0|disable)
			todo_restore="restore=0|${restore_src}|${restore_dest}"
		;;
		1|enable)
			todo_restore="restore=1|${restore_src}|${restore_dest}"
		;;
		*)
			usage
			exit 1
		;;
	esac

  for index in `seq 2 $nbcol`; do
		if [[ ${index} -eq ${level} ]]; then
			newstr="${newstr} ${todo_restore} "
		else
			newstr="${newstr} `echo ${job[${job_id}]} | awk -F, -v colnum=$index '{print $colnum}'`"
		fi  
	done

	job[${job_id}]=`echo ${newstr} | sed 's%\ %,%'g`

}

function reset_job_queue_enable_test_by_id {
	
	local job_id=$1

	update_test_by_id ${job_id} "enable"
	update_backup_by_id ${job_id} "disable"			
	update_update_by_id ${job_id} "disable"
	update_restore_by_id ${job_id} "disable"

}

function reset_job_queue_enable_backup_by_id {

	local job_id=$1

	update_test_by_id ${job_id} "disable"
	update_backup_by_id ${job_id} "enable"			
	update_update_by_id ${job_id} "disable"
	update_restore_by_id ${job_id} "disable"

}

function update_job_queue_enable_update_by_id {
	
	local job_id=$1

	update_test_by_id ${job_id} "disable"			
	update_update_by_id ${job_id} "enable"
	update_restore_by_id ${job_id} "disable"

}

function reset_job_queue_enable_restore_by_id {
	
	local job_id=$1

	update_test_by_id ${job_id} "disable"
	update_backup_by_id ${job_id} "disable"			
	update_update_by_id ${job_id} "disable"
	update_restore_by_id ${job_id} "enable"

}

function usage {

echo " * =*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=* "
echo " * 		                   LINUX HARDENING TOOL	 "
echo " * =*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=* "
echo " * "
echo " * usage and available arguments"
echo " * "
echo " * --backup :"
echo " * --list : list the jobs queue"
echo " * --name : precise one or more job to run"
echo " * --test : test the and return if the change is correctly set or not"
echo " * --update : apply the change only if the value is not correctly set"
echo " * --profile : specify the profile to run, if no profile then run default"
echo " * "
echo " * run the below to list the job from the queue"
echo " * LHT.sh --list"
echo " * "
echo " * run the below to check if the value are correctly set"
echo " * LHT.sh --test"
echo " * "
echo " * run the below to check only one or more job"
echo " * LHT.sh --test --name <jobname1>,<jobname2>"
echo " * "
echo " * run the below to update all the jobs from the list"
echo " * LHT.sh --update"
echo " * "
echo " * run the below to update two jobs from the queue"
echo " * LHT.sh --update --name <jobname1>,<jobname2>"
echo " * "
echo " * run the below to restore the last backup"
echo " * LHT.sh --restore"
echo " * "
echo " * " 
echo " * =*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*"

}


