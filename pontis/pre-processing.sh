#!/bin/bash

echo " -- "
logging_write_IO "[INFO] PRE-PROCESSING START"

# SYSTEM INFO
# start collecting system information
global_rhel_release=`egrep -o  "[0-9]{1,}\.[0-9]{1,}" /etc/redhat-release`
global_kernel_release=`uname -r`



echo " -- "
logging_write_IO "[INFO] LOAD JOBS AND TEMPLATES"
# * start with templating 
# *
# * load job and templates
# *
# * this block verify that the templates in the profile exist
# * if the template exist
# * then load the template and update the template buffer
if [[ ${global_profile_name_exist} -eq 1 ]] && [[ ${global_profile_integrity} -eq 1 ]]; then

  for job_details in `get_all_profile_active_jobs "${global_profile_name}"`; do
  # for template_details in `get_all_profile_template "${global_profile_name}"`; do

    if [[ ${global_opt_debug} -eq 1 ]]; then
      echo ${#global_loaded_template[@]}
      echo ${global_loaded_template[@]}
    fi

    # extracting the jobname from the job details
    job_name=`echo "${job_details}" | egrep -o "jobname=[0-9a-zA-Z_\-]+" | awk -F\= '{print $2}'`

    # extracting the template details from the job details
    template_details=`echo "${job_details}" | egrep -o "template=[0-9a-zA-Z_\/\.\-\|]+" | awk -F\= '{print $2}'`
    
    # checking the template integrity
    query_res=`check_template_integrity "${template_details}"`
    query_res_code=`echo "${query_res}" | awk -F\| '{print $1}'`
    query_res_desc=`echo "${query_res}" | awk -F\| '{print $2}'`

    if [[ $query_res_code -eq 1 ]]; then

      # template integrity check returned success '1'
      # we can extract template name from template details
      template_name=`echo "${template_details}" | awk -F\| '{print $1}'`

      # load the job into the job queue
      # we first check if the job already exist in the job queue
      job_list="${global_job_queue[@]}"
			query_res=`get_job_id_by_name "${job_name}" "${job_list}"`
      query_res_code=`echo "${query_res}" | awk -F\| '{print $1}'`
      query_res_desc=`echo "${query_res}" | awk -F\| '{print $2}'`

      if [[ ${query_res_code} -eq 0 ]]; then

        # the job name is not present in the queue
        # we need to store job def inside the queue
        index_free=${#global_job_queue[@]}
        global_job_queue[${index_free}]="${job_name},${template_details},test=0,restore=0,backup=0,update=0"
        
        # reload the job list var after fresh add
        job_list="${global_job_queue[@]}"

        if [[ `get_job_id_by_name "${job_name}" "${job_list}" | awk -F\| '{print $2}'` -eq ${index_free} ]]; then

          # inform user the job has been successfully added
         	logging_write_IO "[SUCCESS] ADD JOB ${job_name} AS POSITION ${index_free}"

          # the job has been successfully loaded into the job queue
          # we check the template is loaded or not
          template_list="${global_loaded_template[@]}"
          query_res=`is_template_loaded "${template_name}" "${template_list}"`
          query_res_code=`echo "${query_res}" | awk -F\| '{print $1}'`
          query_res_desc=`echo "${query_res}" | awk -F\| '{print $2}'`

          # if the template is not loaded in the store
          # then will store the template at next block
          if [[ ${query_res_code} -eq 0 ]]; then

            # load the template load the template into the store
            index_free=${#global_loaded_template[@]}
            global_loaded_template[${index_free}]="${template_name}"

	          # if the template has been successfully loaded
            # then source the template
            if [[ ${global_loaded_template[${index_free}]} == "${template_name}" ]]; then
            
            	if [[ ${global_opt_debug} -eq 1 ]]; then
              	logging_write_IO "[SUCCESS] LOAD TEMPLATE ${template_name}"
              fi
              
              source "${global_template_path}/${template_name}" 

            else

              logging_write_IO "[ERROR] LOAD TEMPLATE ${template_name}"
            fi

          else
          
           	if [[ ${global_opt_debug} -eq 1 ]]; then 
            	logging_write_IO "[SUCCESS] LOAD TEMPLATE ${template_name} ALREADY PRESENT IN QUEUE"
          	fi
          	
          fi

        fi

      fi

    else

      logging_write_IO "[ERROR] LOAD JOB ${job_name} ALREADY PRESENT IN QUEUE"

    fi

  done
fi



((global_job_index_max=${#global_job_queue[@]}-1))
global_job_list="${global_job_queue[@]}"


# *
# * USER SELECT TEST
# *
if [[ ${global_opt_test} -eq 1 ]] ; then

  if [[ ${global_arg_name} != "all" ]]; then
  
    nbcol=`echo ${global_arg_name} | awk -F, '{print NF}'`
    
    if [[ ${nbcol} -gt 0 ]]; then
    
      for index in `seq 1 ${nbcol}`; do

        job_name=`echo ${global_arg_name} | awk -F, -v var=${index} '{print $var}'`
        job_index_res=`get_job_id_by_name "${job_name}" "${global_job_list}"`
        job_index_code=`echo "${job_index_res}" | awk -F\| '{print $1}'`
        job_index=`echo "${job_index_res}" | awk -F\| '{print $2}'`

        if [[ ${job_index_code} -eq 1 ]]; then

          global_job_queue[${job_index}]=`echo "${global_job_queue[${job_index}]}" | sed -r 's/test=[01]?/test=1/'`       
        else

          echo -e '\n|[ERR]: INVALID JOB NAME: '${job_name}'\n|'  ; exit 1
        fi

      done
    fi

  elif [[ ${global_arg_name} == "all" ]]; then
      
    # looping over the queue to initialize it
    for job_index in `seq 0 ${global_job_index_max}`; do

      global_job_queue[${job_index}]=`echo "${global_job_queue[${job_index}]}" | sed -r 's/test=[01]?/test=1/'`

    done

  else
    
    usage
    exit 1

  fi


#
# USER SELECTED BACKUP
# 
elif [[ ${global_opt_backup} -eq 1 ]]; then

  if [[ ${global_arg_name} == "all" ]]; then
  
    for job_index in `seq 0 ${global_job_index_max}`; do

      global_job_queue[${job_index}]=`echo ${global_job_queue[${job_index}]} | sed -r 's/backup=[01]?/backup=1/'` 
      
      # *
      # * enable the update in the job queue
      # * 
      if [[ ${global_opt_update} -eq 1 ]]; then

        global_job_queue[${job_index}]=`echo ${global_job_queue[${job_index}]} | sed -r 's/update=[01]?/update=1/'`

      fi

    done
    
  elif [[ ${global_arg_name} != "all" ]]; then
  
    nbcol=`echo ${global_arg_name} | awk -F, '{print NF}'`

    if [[ ${nbcol} -gt 0 ]]; then
    
      for index in `seq 1 ${nbcol}`; do

        job_name=`echo ${global_arg_name} | awk -F, -v var=${index} '{print $var}'`
        job_index_res=`get_job_id_by_name "${job_name}" "${global_job_list}"`     
        job_index_code=`echo "${job_index_res}" | awk -F\| '{print $1}'`
        job_index=`echo "${job_index_res}" | awk -F\| '{print $2}'` 

        if [[ "${job_index}" != "" ]] && [[ ${job_index_code} -eq 1 ]]; then

          global_job_queue[${job_index}]=`echo ${global_job_queue[${job_index}]} | sed -r 's/backup=[01]?/backup=1/'` 

          # * 
          # * enable the update in the job queue
          # *
          if [[ ${global_opt_update} -eq 1 ]]; then

            global_job_queue[${job_index}]=`echo ${global_job_queue[${job_index}]} | sed -r 's/update=[01]?/update=1/'`

          fi

        else

          echo -e '\n|[ERR]: INVALID JOB NAME: '${job_name}'\n|'  ; exit 1
        
        fi  

      done
    fi

  else

    usage
    exit 1
    
  fi


# *
# * USER SELECTED RESTORE
# *
elif [[ ${global_opt_restore} -eq 1 ]]; then

  # *
  # * in the case where the .@metadata file exist in the folder we continue restoring
  # * 
  # * taking the assumption that we can restore only what we previously backup
  # * then we set to backup the id we get from the file
  
  # * check the metadata file exist
  if [[ -f "${global_restore_metadata}" ]]; then

    if [[ ${global_arg_name} == "all" ]]; then

      for job_index in `grep "^backup.job." ${global_restore_metadata} | awk -F= '{print $1}' | awk -F\. '{print $3}'`; do
    
        # *
        # * enable restore in the job queue
        # *
        global_job_queue[${job_index}]=`echo ${global_job_queue[${job_index}]} | sed -r 's/restore=[01]?/restore=1/'`

      done

    elif [[ ${global_arg_name} != "all" ]]; then

      nbcol=`echo ${global_arg_name} | awk -F, '{print NF}'`  
    
      if [[ ${nbcol} -gt 0 ]]; then
    
        for index in `seq 1 ${nbcol}`; do

          job_name=`echo ${global_arg_name} | awk -F, -v var=${index} '{print $var}'`
          job_index_res=`get_job_id_by_name "${job_name}" "${global_job_list}"`     
          job_index_code=`echo "${job_index_res}" | awk -F\| '{print $1}'`
          job_index=`echo "${job_index_res}" | awk -F\| '{print $2}'`

          if [[ "${job_index}" != '' ]] && [[ ${job_index_code} -eq 1 ]]; then

            grep "^backup.job.${job_index}.cmd=" ${global_restore_metadata} 

            if [[ $? -eq 0 ]]; then
        
              # *
              # * enable restore in the job queue
              # * 
              global_job_queue[${job_index}]=`echo ${global_job_queue[${job_index}]} | sed -r 's/restore=[01]?/restore=1/'`

            fi      

          else

            echo -e '\n|[ERR]: INVALID JOB NAME: '${job_name}'\n|'  ; exit 1

          fi

        done    

      fi

    fi

  else

    usage
    exit 1

  fi


# *
# * USER SELECTED UPDATE
# *
elif [[ ${global_opt_update} -eq 1 ]]; then

  if [[ ${global_arg_name} == "all" ]]; then
  
    for job_index in `seq 0 ${global_job_index_max}`; do

      # we do set backup before to perform the update
      global_job_queue[${job_index}]=`echo ${global_job_queue[${job_index}]} | sed -r 's/backup=[01]?/backup=1/'`

      # we do set update once we have set the backup      
      global_job_queue[${job_index}]=`echo ${global_job_queue[${job_index}]} | sed -r 's/update=[01]?/update=1/'`     
        
    done
    
  elif [[ ${global_arg_name} != "all" ]]; then
  
    nbcol=`echo ${global_arg_name} | awk -F, '{print NF}'`

    if [[ ${nbcol} -gt 0 ]]; then
    
      for index in `seq 1 ${nbcol}`; do

        job_name=`echo ${global_arg_name} | awk -F, -v var=${index} '{print $var}'`
        job_index_res=`get_job_id_by_name "${job_name}" "${global_job_list}"`     
        job_index_code=`echo "${job_index_res}" | awk -F\| '{print $1}'`
        job_index=`echo "${job_index_res}" | awk -F\| '{print $2}'`

        if [[ "${job_index}" != "" ]] && [[ $job_index_code -eq 1  ]]; then

          # we do set backup before to perform the update
          global_job_queue[${job_index}]=`echo ${global_job_queue[${job_index}]} | sed -r 's/backup=[01]?/backup=1/'`

          # we do set update once we have set the backup      
          global_job_queue[${job_index}]=`echo ${global_job_queue[${job_index}]} | sed -r 's/update=[01]?/update=1/'`     
      
        else

          echo -e '\n|[ERR]: INVALID JOB NAME: '${job_name}'\n|'  ; exit 1

        fi

      done

    fi

  else

    usage
    exit 1
    
  fi

elif [[ ${global_opt_list} -eq 1 ]]; then

  case ${global_arg_tolist} in


    jobs)
      job_list_all
    ;;

    profiles)
      echo "profile to be displaied"
    ;;

  esac

  
fi

# * END PRE-PROCESSING
# *
echo " -- "
logging_write_IO "[INFO] PRE-PROCESSING END"