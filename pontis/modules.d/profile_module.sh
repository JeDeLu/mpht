#!/bin/bash



echo " -- "
logging_write_IO "[INFO] LOAD PROFILE MODULE"


function is_profile_exist {

  local profile_name=$1
  if [[ `ls "${global_profile_path}" | grep -wc "${profile_name}"` -eq 1 ]]; then

    echo "1|[SUCCESS] FOUND PROFILE: ${profile_name}" 

  else

    echo "0|[ERROR] MISSING PROFILE: ${profile_name}"

  fi 
}

function check_profile_integrity {

  local profile_name=$1
  local profile_path="${global_profile_path}/${profile_name}"

  if [[ -f "${profile_path}" ]]; then

    OLD_IFS=$IFS
    IFS=$'\n'
    for LINE in `cat "${profile_path}"`; do

      if [[ `echo $LINE | egrep -c "^\[[XxOo]\] jobname=[0-9a-zA-Z_\-]+,template=[0-9a-zA-Z_\/\-]+$|^\[[XxOo]\] jobname=[0-9a-zA-Z_\-]+,template=[0-9a-zA-Z_\/\-]+\|[0-9a-zA-Z_\/\.\|\-]+$"` -eq 0 ]]; then

        echo "0|[ERROR] CORRUPTED PROFILE: ${profile_path} LINE: ${LINE} FROM ${profile_path}"
 			  exit 1 
 
      fi

    done

    echo "1|[SUCCESS] INTEGRITY PROFILE: ${profile_name}"
    IFS=$OLD_IFS

  else

    echo "0|[ERROR] MISSING PROFILE: ${profile_name}"

  fi
}

function get_all_profile_template {

  local profile_name=$1
  echo `cat "${global_profile_path}/${profile_name}" | egrep -v "^#" | egrep "^\[[Xx]\]" | egrep -o "template=[0-9a-zA-Z_\/\-]+|template=[0-9a-zA-Z_\/\-]+\|[0-9a-zA-Z_\/\.\|\-]+" | awk -F\= '{print $2}'`

}

function get_all_profile_active_jobs {

  local profile_name=$1
	echo `awk '$1 ~ /^\[[Xx]\]/ {print $2}' "${global_profile_path}/${profile_name}"`

}

logging_write_IO "[INFO] COLLECT AND CHECK PROFILE"

global_profile_name_exist=0
global_profile_integrity=0

# * start profile preprocessing
# *
# * load the profile
# *

# check if the profile name return by user exist
# if it exist then this profile is used
# else the system look into the server-profile config file
# if the hostname is linked to a profile the profile is taken as reference
# else the default profile is used
if [[ "${global_temp_profile_name}" != "" ]]; then

	global_profile_name="${global_temp_profile_name}"
	
else

	if [[ -f "${global_server_profile}" ]]; then
	
		if [[ `egrep -c "^${global_hostname}," "${global_server_profile}"` -eq 1 ]]; then
		
			global_temp_profile_name=`egrep "^${global_hostname}," "${global_server_profile}" | awk -F\, '{print $2}'`
			
			if [[ ${global_temp_profile_name} != "" ]]; then
			
				global_profile_name="${global_temp_profile_name}"
				
			else
			
				echo "[ERROR] there is no PROFILE NAME LINKED TO ${global_hostname} in ${global_server_profile}"
				exit 1
				
			fi
		
		elif [[ `egrep -c "^${global_hostname}," "${global_server_profile}"` -gt 1 ]]; then
		
			echo "[ERROR] there are more than one PROFILE LINKED TO ${global_hostname} in ${global_server_profile}"
			exit 1
		
		fi
		
	fi
		
fi
 
query_res=`is_profile_exist "${global_profile_name}"`          
query_res_code=`echo ${query_res} | awk -F\| '{print $1}'`
query_res_desc=`echo ${query_res} | awk -F\| '{print $2}'`

logging_write_IO "${query_res_desc}"

if [[  ${query_res_code} -eq 1 ]]; then

  global_profile_name_exist=1
  global_profile_uniq_identifier=`cksum "${global_profile_path}/${global_profile_name}" | awk '{print $1}'`

  # * profile has been found
  # * check profile integrity
  query_res=`check_profile_integrity "${global_profile_name}"`
  query_res_code=`echo "${query_res}" | awk -F\| '{print $1}'`
  query_res_desc=`echo "${query_res}" | awk -F\| '{print $2}'`

  logging_write_IO "${query_res_desc}"

  if [[ ${query_res_code} -eq 1 ]]; then

    global_profile_integrity=1

  fi

else

  echo "${query_res_desc}"
  exit 1

fi