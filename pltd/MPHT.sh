#!/bin/bash
#
# *
# * setting display
# *
#
setterm -background black
setterm -foreground white
setterm -clear all
#
#
echo "| ********************************************************************************************************"
echo "|"
echo "|	 MULTI PLATFORM HARDENING TOOL"
echo "|"
echo "| ********************************************************************************************************"
#
# *
# * declare any global variables here
# *
#
declare global_run_datetime=`date +"%y%m%d%H%M%S"`
declare -i global_opt_test=0
declare -i global_opt_backup=0
declare -i global_opt_update=0
declare -i global_opt_restore=0
declare -i global_opt_list=0
declare -i global_opt_debug=0
declare global_current_path=`pwd`
declare global_exec_path=`dirname $0`
declare global_app_path=`cd "${global_exec_path}" ; grep "app_root_path" ../settings.json | awk -F\" '{print $4}'`/latest
declare global_hostname=`cd "${global_exec_path}" ; grep "hostname" ../settings.json | awk -F\" '{print $4}'`
cd "${global_current_path}"
declare global_system_version
declare global_server_profile="${global_app_path}/server-profile"
declare global_server_patch="${global_app_path}/server-patch"
declare global_profile_path="${global_app_path}/profile.d"
declare global_patch_path="${global_app_path}/patch.d"
declare global_output_path="${global_app_path}/output/${global_hostname}"
declare global_output_patch_file="${global_output_path}/${global_hostname}_patch_report_${global_run_datetime}.csv"
declare global_temporary_path="${global_app_path}/tmp"
declare global_arg_path
declare global_arg_name="all"
declare global_arg_version
declare global_arg_tolist
declare global_backup_path="${global_app_path}/backup"
declare global_backup_metadata
declare global_restore_path="${global_app_path}/backup/${global_hostname}"
declare global_template_path="${global_app_path}/template.d"
declare global_temp_profile_name
declare global_profile_name="default"
declare -a job_id_list

#
# *
# * PARSING ARG AND OPTS
# * 
#

args=`getopt -s bash -o bdhl:no::p:rtuv: -l backup,debug,help,list:,profile:,name:,path:,restore,test,update,version: -- "$@"`
eval set -- ${args}
while true ; do

	case $1 in
	
		-t|--test)
			global_opt_test=1
		;;

		-b|--backup)
			global_opt_backup=1
		;;

		-d|--debug)
			set -x
      global_opt_debug=1
		;;

		-h|--help)
			usage
		;;

		-l|--list)
			global_opt_list=1
			global_arg_tolist="$2"
			shift
		;;

		-u|--update)
			global_opt_update=1
		;;

		-r|--restore)
			global_opt_restore=1
		;;

		-p|--path)
			global_arg_path="$2"
			shift
		;;

    -o|--profile)
      global_temp_profile_name="$2"
			shift
    ;;

		-n|--name)
			global_arg_name="$2"
			shift
		;;

    -v|--version)
      global_arg_version="$2"
    ;;

		--)
			break
		;;

		*)
			usage
			exit 1
		;;

	esac
	shift
done


#
# *
# * call modules here
# *
#

source "${global_app_path}/modules.d/display_module.sh"
source "${global_app_path}/modules.d/logging_module.sh"
source "${global_app_path}/modules.d/job_module.sh"
source "${global_app_path}/modules.d/profile_module.sh"
source "${global_app_path}/modules.d/template_module.sh"
source "${global_app_path}/modules.d/metadata_module.sh"
logging_rotate

#
# *
# * call functions here
# *
#
source "${global_app_path}/external_func.sh"


# *
# * CALL PRE_PROCESSING
# *
# * Pre-processing identify profile, load jobs and templates
# * once the queue constructed, it update job actions according the user command
source "${global_app_path}/pre-processing.sh"


# ################################ RUNNER ####################################
#
# nothing to change here
#

for job_index in `seq 0 ${global_job_index_max}`; do


  if [[ ${global_job_index_max} -lt 100 ]]; then
	  
    if [[ ${job_index} -lt 10 ]]; then
	
	  	job_id_print="0${job_index}"
  	else		

		  job_id_print="${job_index}"
  	fi

  elif [[ ${global_job_index_max} -lt 1000 ]]; then

    if [[ ${job_index} -lt 10 ]]; then
	
	  	job_id_print="00${job_index}"
  	elif [[ ${job_index} -lt 100 ]]; then		

		  job_id_print="0${job_index}"
    else

      job_id_print="${job_index}"
  	fi
  fi

	job_name=`echo "${global_job_queue[${job_index}]}" | awk -F, '{print $1}'`
	
	# test backup update go thru the job list from first to last we use the job index
  job_template_details=`echo "${global_job_queue[${job_index}]}" | awk -F\, '{print $2}'`
  test_value=`echo "${global_job_queue[${job_index}]}" | egrep -o "test=[01]?" | awk -F\= '{print $2}'`
  backup_value=`echo "${global_job_queue[${job_index}]}" | egrep -o "backup=[01]?" | awk -F\= '{print $2}'`
  update_value=`echo "${global_job_queue[${job_index}]}" | egrep -o "update=[01]?" | awk -F\= '{print $2}'`
  
	# restore section must be different since it goes from last to first we use the restore index
	((restore_job_index=${global_job_index_max}-${job_index}))
	restore_job_template_details=`echo "${global_job_queue[${restore_job_index}]}" | awk -F\, '{print $2}'`
	restore_value=`echo "${global_job_queue[${restore_job_index}]}" | egrep -o "restore=[01]?" | awk -F\= '{print $2}'`
		
	restore_job_name_res=`get_job_name_by_id "${restore_job_index}" "${global_job_list}"`
	if [[ `echo "${restore_job_name_res}" | awk -F\| '{print $1}'` -eq 1 ]]; then
	
		restore_job_name=`echo "${restore_job_name_res}" | awk -F\| '{print $2}'`
	fi	
	
	# *
	# * starting checking with test
	# *
	if [[ ${test_value} -eq 1 ]]; then

		if [[ global_opt_debug -eq 1 ]]; then
			echo "[FLAG] exec_test_${job_index} ${job_name}"
		fi

		# ADDING EXCEPTION HERE:
		# all the jobs are working same except the check_patch_update
		# the template calls several patch checking, in order to avoid breaking generic design we need to loop over patch list from here
		if [[ `echo "${job_template_details}" | awk -F\/ '{print $2}'` == "check_patch_update" ]]; then
		
			echo "  --  "
			logging_write_IO "[INFO] STARTING WITH PATCH REPORT"
			  
			# define the local variable for the patch file
			patch_file=`patch_manager_get_patch_file`
			logging_write_IO "[INFO] USING PATCH FILE: ${patch_file}" 
			
			# define the output directory
			if [[ ! -d "${global_output_path}" ]]; then
				
				# create the output directory
				logging_write_IO "[INFO] CREATE OUTPUT DIR: ${global_output_path}"
				mkdir "${global_output_path}"
			
			fi
			
			# insert CSV column name into the CSV report file
			logging_write_IO "[INFO] CREATE OUTPUT PATCH FILE: ${global_output_patch_file}"
			echo "hostname,cpu_core_num,cpu_model_name,total_memory,uptime,ip_1,net_1,ip_2,net_2,ip_3,net_3,ip_4,net_4,ip_5,net_5,ip_6,net_6,errata_name,errata_patch_file,server_patch_file,patch_status" > "${global_output_patch_file}"
			
			if [[ -f "${global_patch_path}/${patch_file}" ]]; then
			
				# move from file name to absolute ref
				patch_file="${global_patch_path}/${patch_file}"
			
				# start looping over the errata present in the patch file
				for errata_name in `patch_manager_get_errata_list ${patch_file}`; do
		
					echo  " -- "
					logging_write_IO "[INFO] START WORKING ON ERRATA: `prt_stdout_inverted ${errata_name}`"
			
					# start looping over the package list of the errata transmitted by previous loop
					for rpm_pack_name in `patch_manager_get_rpm_from_errata "${errata_name}" "${patch_file}"`; do
					
						test_cmd=`build_template_cmd "test" "${job_name}" "${job_index}" "${job_template_details}|${errata_name}|${rpm_pack_name}"`
						test_res=`eval "${test_cmd}"`
						test_res_code="`echo ${test_res} | awk -F\| '{print $1}'`"
						
						logging_write_IO "`echo ${test_res} | awk -F\| '{print $2}'`"
					
					done
				
				done
				
				logging_write_IO "[INFO] ENDING WITH PATCH REPORT"
			
			fi
		
		else
    	
    	test_cmd=`build_template_cmd "test" "${job_name}" "${job_index}" "${job_template_details}"`    
			test_res=`eval "${test_cmd}"`
			test_res_code=`echo ${test_res} | awk -F\| '{print $1}'`
		
			logging_write_IO "`echo ${test_res} | awk -F\| '{print $2}'`"
	
		fi
	
	# *
	# * continue checking with backup if test check failed
	# *
	elif [[ ${backup_value} -eq 1 ]]; then

		if [[ ${update_value} -eq 1 ]]; then

    	test_cmd=`build_template_cmd "test" "${job_name}" "${job_index}" "${job_template_details}"`    
			test_res=`eval "${test_cmd}"`
			test_res_code=`echo ${test_res} | awk -F\| '{print $1}'`

			# * test the job before backup and update
			# * if the test result is success then no backup no update
			# * if the test result is fail then backup and update to be run			
			if [[ ${test_res_code} -eq 1 ]]; then

				logging_write_IO "`echo ${test_res} | awk -F\| '{print $2}'`"

			elif [[ ${test_res_code} -eq 0 ]]; then

				if [[ global_opt_debug -eq 1 ]]; then
					echo "[FLAG] exec_update_${job_index} ${job_name}"
				fi

    		backup_cmd=`build_template_cmd "backup" "${job_name}" "${job_index}" "${job_template_details}"`    
				backup_res=`eval "${backup_cmd}"`
				backup_res_code=`echo ${backup_res} | awk -F\| '{print $1}'`
				
				# display the backup result				
				logging_write_IO "`echo "${backup_res}" | awk -F\| '{print $2}'`"

				# * if the backup_res_code is success then update can be execute
				# * if the backup_res_code is fail then the update is skip
				if [[ ${backup_res_code} -eq 1 ]]; then
				
					if [[ global_opt_debug -eq 1 ]]; then
						echo "[FLAG] exec_update_${job_index} ${job_name}"
					fi
					
    			update_cmd=`build_template_cmd "update" "${job_name}" "${job_index}" "${job_template_details}"`    
					update_res=`eval "${update_cmd}"`
					update_res_code=`echo ${update_res} | awk -F\| '{print $1}'`
		
					# * print job update result
					logging_write_IO "`echo "${update_res}" | awk -F\| '{print $2}'`"

				fi

			fi

		else
			
			if [[ global_opt_debug -eq 1 ]]; then
						echo "[FLAG] exec_backup_${job_index} ${job_name}"
			fi
			
    	backup_cmd=`build_template_cmd "backup" "${job_name}" "${job_index}" "${job_template_details}"`    
			backup_res=`eval "${backup_cmd}"`
			backup_res_code=`echo ${backup_res} | awk -F\| '{print $1}'`
			
			# print job backup result
			logging_write_IO "`echo "${backup_res}" | awk -F\| '{print $2}'`"
		
		fi
	
	# *
	# * continue with restore if the test and backup check failed
	# *
	elif [[ ${restore_value} -eq 1 ]]; then

			if [[ global_opt_debug -eq 1 ]]; then
				echo "[FLAG] exec_restore_${job_index} ${job_name}"
			fi

			restore_cmd=`build_template_cmd "restore" "${restore_job_name}" "${restore_job_index}" "${restore_job_template_details}" `
			restore_res=`eval "${restore_cmd}"`
			restore_res_code=`echo ${restore_res} | awk -F\| '{print $1}'`
			
			# print job restore result
			logging_write_IO "`echo "${restore_res}"  | awk -F\| '{print $2}'`"

	fi
done


