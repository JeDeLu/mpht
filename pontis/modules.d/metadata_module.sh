#!/bin/bash

function metadata_return_restore_path {

	# set the local restore path
	local local_restore_path=$1

	# current profile cksum
	local current_profile_cksum=`cksum "${global_profile_path}/${global_profile_name}" | awk '{print $1}'`

	# list counter
	local counter=0

	# user selection
	local user_select=999999


	if [[ `grep -r "backup.profile.name=${global_profile_name}" "${local_restore_path}" | wc -l` -gt 0 ]]; then

		echo " -- RESTORE FOLDER ID LIST"
		for RESTORE_FILE in `grep -rl "backup.profile.name=${global_profile_name}" ${local_restore_path} | sort -n`; do

			# restore profile cksum
			restore_profile_cksum=`grep "^backup.profile.cksum=" ${RESTORE_FILE} | awk -F\= '{print $2}'`

			# check cksum are same
			if [[ "${restore_profile_cksum}" == "${current_profile_cksum}" ]]; then

				restore_dir_list[${counter}]=`echo "${RESTORE_FILE}" | awk -F\/ '{print $7}'`

				echo " ID: ${counter})- NAME: [${restore_dir_list[${counter}]}], INTEGRITY: THE PROFILE ${global_profile_name} MATCH THE CURRENT PROFILE INTEGRITY "

				((counter=${counter}+1))

			fi

		done


		((select_max=${#restore_dir_list[@]}))
		while [[ ${user_select} -gt ${select_max} ]]; do

			echo " -- "
			echo "% ENTER THE RESTORE FOLDER ID FROM ABOVE LIST TO SELECT RESTORE FOLDER."
			echo -n "% "
			read user_select

			if [[ `echo ${user_select} | egrep -c "^[0-9]{1,}$"` -gt 0 ]] && [[ ${user_select} -lt ${select_max} ]]; then

				break

			else

				user_select=999999
				echo "[ERROR] INVALID VALUE -- YOU MUST SELECT A VALID NUMBER BETWEEN: 0<>${select_max}"

			fi

		done

		restore_folder="${restore_dir_list[${user_select}]}"

	else

		echo "[ERROR] THERE IS NO BACKUP MATCHING THIS PROFILE ${global_profile_name}"
		exit 1

	fi

}



echo " -- "
logging_write_IO "[INFO] LOAD METADATA MODULE"

logging_write_IO "[INFO] CONFIGURE BACKUP SETTINGS"
# * start backup pre-processing
# * 
# * get the backup directory
# *
# * if the backup directory passed by user exist
# * then set backup directory variable for further use
# * else set the backup directory to his default value
if [[ ${global_opt_update} -eq 1 ]] || [[ ${global_opt_backup} -eq 1 ]]; then
  
  if [[ "${global_arg_path}" != "" ]] && [[ -d "${global_arg_path}" ]]; then

	  # * set the backup directory name
		global_backup_path="${global_arg_path}"

  fi

  # * re-define backup path
  global_backup_path="${global_backup_path}/${global_hostname}/${global_run_datetime}"
  logging_write_IO "[SUCCESS] DEFINE BACKUP PATH ${global_backup_path}"

  # * create the backup directory
  mkdir -p ${global_backup_path}

	# * create the metadata file
  global_backup_metadata="${global_backup_path}/.@metadata"
  touch "${global_backup_metadata}"
  logging_write_IO "[SUCCESS] CREATE METADATA FILE ${global_backup_metadata}"
  
fi


logging_write_IO "[INFO] CONFIGURE RESTORE SETTINGS"
# * start restore pre-processing
# *
# * get the restore directory
# *
# * if the restore directory passed by the user exist
# * then set the restore directory variable for further use
# * else set the restore directory to his default value
if [[ ${global_opt_restore} -eq 1 ]]; then

  if [[ "${global_arg_path}" != "" ]] && [[ -d "${global_arg_path}" ]]; then

    # * set the restore directory name
    global_restore_path="${global_arg_path}"

    if [[ -f "${global_restore_path}/.@metadata" ]]; then
    
    	# we set the metadata file
    	global_restore_metadata="${global_restore_path}/.@metadata"
		
    	# * inform about the new restore path and metadata file
    	logging_write_IO "[SUCCESS] DEFINE RESTORE PATH: ${global_restore_path}"
    	logging_write_IO "[SUCCESS] DEFINE RESTORE METADATA: ${global_restore_metadata}"
    	
    else
    
    	# the path provided by the user must contain a metadata file
    	logging_write_IO "[ERROR] MISSING METADATA IN RESTORE PATH"    	
    
    fi

  elif [[ "${global_arg_path}" != "" ]] && [[ ! -d "${global_arg_path}" ]]; then

    # * inform about the failure
    logging_write_IO "[ERROR] MISSING RESTORE PATH : ${global_restore_path}"
    
  else
  
    # * the arg_path is empty
    # * we use the default restore path which is the backup path
    logging_write_IO "[SUCCESS] DEFINE RESTORE PATH: ${global_restore_path}"
    
    # looking for the latest backup folder
    if [[ `ls -ltr "${global_restore_path}" | wc -l` -gt 0 ]]; then
    
    	# get the latest directory from default restore folder
    	# restore_folder=`ls -ltr "${global_restore_path}" | tail -1 | awk '{print $9}'`	
    	
    	metadata_return_restore_path "${global_restore_path}"
    	#restore_folder_code=`echo "${restore_folder_req}" | awk -F\| '{print $1}'`
    	#restore_folder_data=`echo "${restore_folder_req}" | awk -F\| '{print $2}'`
    	#if [[ "${restore_folder_code}" -eq 1 ]]; then
    	#	restore_folder="${restore_folder_data}"

    	# check if the metadata
    	if [[ -f "${global_restore_path}/${restore_folder}/.@metadata" ]]; then
    	
    		global_restore_metadata="${global_restore_path}/${restore_folder}/.@metadata"
				logging_write_IO "[INFO] THE RESTORE FILE USE ${global_restore_metadata}"    	
			fi
    
		fi
    
	fi


	# at this stage we identified the restore file
	# we need to make sure the current the profile used for the restore is the same as the one used for the backup
	restore_profile_name=`egrep "^backup.profile.name=" ${global_restore_metadata} | awk -F= '{print $2}'`
	restore_profile_cksum=`egrep "^backup.profile.cksum=" ${global_restore_metadata} | awk -F= '{print $2}'`

	# the profile name from restore file matches with the name of the current profile used
	# if the cksum from the restore file is the same than the checksum returned by current profile 
	# then we continue, else we make a copy of the existing profile and we restore the profile from metadata
	if [[ "${restore_profile_name}" == "${global_profile_name}" ]]; then

		logging_write_IO "[INFO] THE RESTORE PROFILE ${restore_profile_name} MATCH THE CURRENT PROFILE"

		# collect current profile checksum to compare it
		current_profile_cksum=`cksum "${global_profile_path}/${global_profile_name}" | awk '{print $1}'`
		
		if [[ "${current_profile_cksum}" != "${restore_profile_cksum}" ]]; then

			logging_write_IO "[ERROR] THE CKSUM RESTORE PROFILE ${restore_profile_cksum} NOT MATCH THE CURRENT ${current_profile_cksum}"
			exit 1

			# take a backup of the current profile
			# logging_write_IO "[INFO] BACKUP CURRENT PROFILE FROM ${global_profile_name} TO ${global_profile_name}_${current_profile_cksum}"
			# cp "${global_profile_path}/${global_profile_name}" "${global_profile_path}/${global_profile_name}_${current_profile_cksum}"
			# restore the profile from metadata
			# logging_write_IO "[INFO] RESTORE THE PROFILE FROM METADATA TO CURRENT PROFILE"
			# egrep "^backup.profile.line" "${global_restore_metadata}" | sed -r "s/backup.profile.line.[0-9]{1,}=//" > "${global_profile_path}/${global_profile_name}"

		else

			logging_write_IO "[INFO] THE CKSUM RESTORE PROFILE ${restore_profile_cksum} MATCH THE CURRENT ${current_profile_cksum}"

		fi

	else

		logging_write_IO "[ERROR] THE RESTORE PROFILE ${restore_profile_name} NOT MATCH THE CURRENT PROFILE ${global_profile_name}"
		exit 1

		# the profile name from restore file dont match with the current profile used
		# if the profile still exist, then we check the cksum
		# if the cksum is different then we backup the file and push the profile from the metadata to the new file
		# if the profile not exist, then we recreate the file from metadata
		# finally we assign the new profile name as specified in the metadata
		
		# if [[ -f "${global_profile_path}/${restore_profile_name}" ]]; then
		#
		#		logging_write_IO "[INFO] THE RESTORE PROFILE IS FOUND ${restore_profile_name}"
		#
		#	collect current profile checksum to compare it
		#		current_profile_cksum=`cksum "${global_profile_path}/${restore_profile_name}" | awk '{print $1}'`
		#
		#	if [[ "${current_profile_cksum}" != "${restore_profile_cksum}" ]]; then
		#
		#		logging_write_IO "[INFO] THE METADATA CKSUM RESTORE PROFILE ${restore_profile_cksum} NOT MATCH THE FOUND ${current_profile_cksum}"
		#
		#		# take a backup of the current profile
		#
		#		logging_write_IO "[INFO] BACKUP RESTORE PROFILE FROM ${restore_profile_name} TO ${restore_profile_name}_${current_profile_cksum}"
		#
		#		cp "${global_profile_path}/${restore_profile_name}" "${global_profile_path}/${restore_profile_name}_${current_profile_cksum}"
		#
		#		# restore the profile from metadata
		#
		#		logging_write_IO "[INFO] RESTORE THE PROFILE FROM METADATA TO RESTORE PROFILE"
		#
		#		egrep "^backup.profile.line" "${global_restore_metadata}" | sed -r "s/backup.profile.line.[0-9]{1,}=//" > "${global_profile_path}/${global_profile_name}"
		#
		#	fi
		#
		#	logging_write_IO "[INFO] RE-DEFINE THE CURRENT PROFILE ${global_profile_name} TO RESTORE PROFILE ${restore_profile_name}"
		#
		#	# update the global profile name			
		#	global_temp_profile_name="${restore_profile_name}"
		#
		#else
		#
		#	logging_write_IO "[INFO] THE RESTORE PROFILE IS FOUND ${restore_profile_name}"
		#	logging_write_IO "[INFO] RESTORE THE PROFILE FROM METADATA TO RESTORE PROFILE"
		#
		#	# restore the profile from metadata
		#	egrep "^backup.profile.line" "${global_restore_metadata}" | sed -r "s/backup.profile.line.[0-9]{1,}=//" > "${global_profile_path}/${restore_profile_name}"
		#
		#	logging_write_IO "[INFO] RE-DEFINE THE CURRENT PROFILE ${global_profile_name} TO RESTORE PROFILE ${restore_profile_name}"
		#
		#	# update the global profile name
		#	global_temp_profile_name="${restore_profile_name}"
		#
		#fi

	fi

fi




# *
# * update metadata
# *
function update_metadata {

	local job_id=$1
	local type=$2
	local value=$3

	case $2 in
		file)
			
			local target=$3
			local dest="${global_backup_path}/"`basename ${target}`".job."${job_id}
			local is_symlink=0

			# if the source provided is a symbolic link
			# then reset the source with the new path
			if [[ -L ${target} ]]; then
				
				local is_symlink=1
				local src=`ls -l ${target} | awk '{print $11}'`

				if [[ `dirname ${src}` == "." ]]; then

					src=`dirname ${target}`"/"${src}

				fi
				
			fi

			
			
			if [[ ${is_symlink} -eq 0 ]]; then

				local target_owner=`stat --format=%U ${target}`
				local target_group=`stat --format=%G ${target}`
				local target_perms=`stat --format=%a ${target}`
				local target_cksum=`cksum ${target} | awk '{print $1}'`
				
				cp ${target} ${dest}
				#echo "#${job_id}|${target_perms}|${target_owner}|${target_group}|${target}|${target_cksum}" >> "${backup_metadata_file}"
				echo "backup.job.${job_id}.meta=${target_perms}|${target_owner}|${target_group}|${target}|${target_cksum}" >> "${backup_metadata_file}"
				#echo "cmd[${job_id}]=\cp -f ${dest} ${target} ; chmod ${target_perms} ${target} ; chown ${target_owner}:${target_group} ${target}" >> "${backup_metadata_file}" 
				echo "backup.job.${job_id}.cmd=\cp -f ${dest} ${target} ; chmod ${target_perms} ${target} ; chown ${target_owner}:${target_group} ${target}" >> "${backup_metadata_file}"
				
			else

				local src_owner=`stat --format=%U ${src}`
				local src_group=`stat --format=%G ${src}`
				local src_perms=`stat --format=%a ${src}`
				local src_cksum=`cksum ${src} | awk '{print $1}'`

				cp ${src} ${dest}
				#echo "#${job_id}|${src_perms}|${src_owner}|${src_group}|${src}|${src_cksum}" >> "${backup_metadata_file}"
				echo "backup.job.${job_id}.meta=${src_perms}|${src_owner}|${src_group}|${src}|${src_cksum}" >> "${backup_metadata_file}"
				#echo "cmd[${job_id}]=\cp -f ${dest} ${src} ; chmod ${src_perms} ${src} ; chown ${src_owner}:${src_group} ${src} ; rm -fr ${target} ; ln -s ${src} ${target}" >> "${backup_metadata_file}"
				echo "backup.job.${job_id}.cmd=\cp -f ${dest} ${src} ; chmod ${src_perms} ${src} ; chown ${src_owner}:${src_group} ${src} ; rm -fr ${target} ; ln -s ${src} ${target}" >> "${backup_metadata_file}"
			
			fi


			;;

			cmd)

				local command=$3
				echo "backup.job.${job_id}.cmd=${command}" >> "${backup_metadata_file}"
			;;

			*)
			;;
		
	esac	

	# * we do check if a new restore command as been correctly added to metadata file before confirming the backup is fine
	#grep "^cmd\[${job_id}\]=" ${backup_metadata_file} >/dev/null
	if [[ `egrep -c "^backup\.job\.${job_id}\.cmd=" ${backup_metadata_file}` -eq 1 ]]; then
	#if [[ $? -eq 0 ]]; then
				
		echo 1
			
	else

		echo 0

	fi
}

function metadata_write_restore_cmd {

	# define the job id
	local job_id=$1

	# define the restore command to backup
	local restore_cmd=$2
	
	# write the restore command into the metadata file
	echo "backup.job.${job_id}.cmd=${restore_cmd}" >> "${global_backup_metadata}"

	# check the restore command has been successfully written	
	if [[ `egrep -c "^backup\.job\.${job_id}\.cmd=" ${global_backup_metadata}` -eq 1 ]]; then
	
		echo 1
	
	else
	
		echo 0
	
	fi

}


function metadata_is_restore_cmd {

	# define the job_id for which to collect the restore cmd
	local job_id=$1
	
	if [[ `egrep -c "^backup\.job\.${job_id}\.cmd=" ${global_restore_metadata}` -eq 1 ]]; then
	
		echo 1
	
	else
	
		echo 0
		
	fi

}


function metadata_get_restore_cmd {

	# define the job_id for which to collect the restore cmd
	local job_id=$1
	
	# get the restore command
	local restore_cmd=`egrep "^backup\.job\.${job_id}\.cmd=" ${global_restore_metadata} | sed -r "s/backup.job.[0-9]{1,}.cmd=//"` 

	# return the restore command
	echo ${restore_cmd}

}


function metadata_write_system_info  {

	# define the system hostname
	local system_hostname=${global_hostname}

	# write the meta info
	echo "backup.system.hostname=${system_hostname}" >> "${global_backup_metadata}"
	
		
}

function metadata_write_profile_info {

	# define the system profile cksum
	local system_profile_cksum=`cksum "${global_profile_path}/${global_profile_name}" | awk '{print $1}'`

	# write the meta info profile name
	echo "backup.profile.name=${global_profile_name}" >> "${global_backup_metadata}"
	
	# write the current profile checksum
	echo "backup.profile.cksum=${system_profile_cksum}" >> "${global_backup_metadata}"
	
	# inject the profile into the metadata
	OLD_IFS=$IFS
	IFS=$'\n'

	local line_counter=0
	for profile_line in `cat "${global_profile_path}/${global_profile_name}"`; do

		echo "backup.profile.line.${line_counter}=${profile_line}" >> "${global_backup_metadata}"
		((line_counter=${line_counter}+1))

	done

	IFS=$OLD_IFS
}


#
# preparing the backup metadata file
if [[ ${global_opt_update} -eq 1 ]] || [[ ${global_opt_backup} -eq 1 ]]; then

	# writes the system info into the metadata backup file
	metadata_write_system_info

  # write the profile info into the metadata backup file
  metadata_write_profile_info

fi