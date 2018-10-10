#!/bin/bash

declare global_logging_dir="${global_app_path}/logging"
declare global_logging_file="${global_logging_dir}/MPHT.log"
declare global_current_date=`date "+%y%m%d-%H%M%S"`
declare global_logging_retention_days=5


# check if the logging directory exists else create it
if [[ ! -d "${global_logging_dir}" ]]; then

	mkdir -p "${global_logging_dir}"

fi

function logging_write_IO {

	local input_text=$1
	local timestamp="[`date "+%y%m%d:%H%M%S"`]>"

	echo ${timestamp}" @"${global_hostname}" %"${input_text} | tee -a "${global_logging_file}"

}

function logging_rotate {

	if [[ -f "${global_logging_file}" ]]; then

		local logging_file_size=`stat --format=%s "${global_logging_file}"`

		if [[ ${logging_file_size} -gt 1000000 ]]; then

			tar cvzf "${global_logging_file}-${global_current_date}.tgz" "${global_logging_file}"

		fi

		while [[ `ls -l "${global_logging_dir}/MPHT-*.tgz" 2>/dev/null | wc -l` -gt ${global_logging_retention_days} ]]; do
	
			# delete the oldest file from the list				
			rm -fr `ls -lt "${global_logging_dir}/MPHT-*.tgz" 2>/dev/null | tail -1 | awk '{print $9}'`

		done
 
	fi

}
