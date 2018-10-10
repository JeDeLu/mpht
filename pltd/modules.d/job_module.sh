#!/bin/bash

declare -a global_job_queue

function get_job_id_by_name {

  # assign the job name to search
  local job_name=$1

  # job list received from user
  local job_list=$2

  # init the search res to return
  local search_res="0|"

  # initiate counter
  local j_position=0

  for job_list_name in ${job_list}; do

    if [[ "`echo "${job_list_name}" | awk -F, '{print $1}'`" == "${job_name}" ]]; then

      search_res="1|${j_position}"
      break
    fi

    # incrementing j_position for next loop
    ((j_position=${j_position}+1))

  done

  # return the res at end of loop
  echo "${search_res}"

}

function get_job_name_by_id {

	# assign the job id
	local job_id=$1
	
	# job list received from the user
	local job_list=$2

	# init the search res 
	local search_res="0|"
	
	# define the length of the job list
	local job_list_length=`echo "${job_list}" | awk '{print NF}'`
	
	# set the position in the loop
	local j_position=0
	
	if [[ ${job_id} -lt ${job_list_length} ]]; then
	
		for job_details in ${job_list}; do
	 
	 		if [[ ${j_position} -eq ${job_id} ]]; then
	 		
				search_res="1|`echo ${job_details} | awk -F\, '{print $1}'`"
				break

			fi
			
			((j_position=${j_position}+1))
			
		done

	fi
	
	# return the res at end
	echo "${search_res}"

}

function job_list_all {

	echo "[ == JOB QUEUE == ]"
	echo "	\\"
  echo "	|--[ID ]--( JOB NAME )"

  for job_id in `seq 0 ${global_job_index_max}`; do

  	if [[ ${global_job_index_max} -lt 100 ]]; then

  		if [[ ${job_id} -lt 10 ]]; then

  			job_id_print="0${job_id}"

  		elif [[ ${job_id} -lt 100 ]]; then

  			job_id_print="${job_id}"

  		fi

  	elif [[ ${global_job_index_max} -lt 1000 ]]; then

  		if [[ ${job_id} -lt 10 ]]; then

  			job_id_print="00${job_id}"

  		elif [[ ${job_id} -lt 100 ]]; then

  			job_id_print="0${job_id}"

  		elif [[ ${job_id} -lt 1000 ]]; then

  			job_id_print="${job_id}"

  		fi

  	fi

  	job_name=`echo ${global_job_queue[${job_id}]} | awk -F\, '{print $1}'`

  	echo -e "	|--[\e[93m${job_id_print}\e[0m]--( \e[94m${job_name}\e[0m )"

  done

}
