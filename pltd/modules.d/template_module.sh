#!/bin/bash

# declare an array where to store the template already loaded
# if a template has already been loaded it must be present there
declare -a global_loaded_template

function is_template_loaded {

  local template_name=$1
  local template_list=$2
  local search_res="0|"

  for template_list_name in ${template_list}; do

    if [[ "${template_list_name}" == "${template_name}" ]]; then

      search_res="1|"
      break
      
    fi
  done
  
  # return search result
  echo "${search_res}"
}

function template_load {

  local template_name=$1
  local index_free=${#global_loaded_template[@]}
  global_loaded_template[${index_free}]="${template_name}"

  #if [[ "${global_loaded_template[${index_free}]}" == "${template_name}" ]]; then
  if [[ ${#global_loaded_template[@]} -gt ${index_free} ]]; then
    echo "1|[SUCCESS] LOAD TEMPLATE: ${template_name}"

  else

    echo "0|[ERROR] LOAD TEMPLATE: ${template_name}"

  fi
}

function is_template_exist {

  local template_name=$1

  if [[ -f "${global_template_path}/${template_name}" ]]; then

    echo "1|[SUCCESS] EXIST TEMPLATE: ${template_name}"

  else

    echo "0|[ERROR] EXIST TEMPLATE: ${template_name}"

  fi

}

function get_template_arg_num {

  local template_name=$1
  local arg_num=`egrep -io "^# ARG_NUM=[\"0-9]+" "${global_template_path}/${template_name}" | sed 's/\"//g' | awk -F\= '{print $2}'`

  if [[ $arg_num != '' ]]; then

    echo "1|$arg_num"

  else

    echo "0|[ERROR] INTERNAL ERROR: func:get_template_arg_num, arg_num:${arg_num}"

  fi
}

function check_template_integrity {

  local template_details=$1
  local nb_template_fields=`echo "${template_details}" | awk -F\| '{print NF}'`

  # before going further we check if the template details has valid string
  # the number of filed must at least be egal to one, never equal to 0
  if [[ ${nb_template_fields} -gt 0 ]]; then
  
    # as the nb field is valid 
    # we can extract the name of the template without args if any
    local template_name=`echo "${template_details}" | awk -F\| '{print $1}'`
    ((nb_template_arg=nb_template_fields-1))
 
    query_res=`is_template_exist "${template_name}"`
    query_res_code=`echo "${query_res}" | awk -F\| '{print $1}'`
    query_res_desc=`echo "${query_res}" | awk -F\| '{print $2}'`

    if [[ ${nb_template_fields} -gt 0 ]]; then

      if [[ ${query_res_code} -eq 1 ]]; then

       if [[ ${nb_template_fields} -gt 1 ]]; then

         query_res=`get_template_arg_num "${template_name}"`
         query_res_code=`echo "${query_res}" | awk -F\| '{print $1}'`
         query_res_value=`echo "${query_res}" | awk -F\| '{print $2}'`

         if [[ $query_res_code -eq 1 ]] && [[ $query_res_value -eq $nb_template_arg ]]; then

           echo "1|[SUCCESS] INTEGRITY TEMPLATE: ${template_name}"

         else

           echo "0|[ERROR] INTEGRITY TEMPLATE: ${template_name}" 

         fi

      else

        echo "1|[SUCCESS] INTEGRITY TEMPLATE: ${template_name}"

      fi
    
    else

      echo "0|[ERROR] MISSING TEMPLATE : ${template_name}"

    fi

  else

    echo "0|[ERROR] INTERNAL ERROR: func:check_template_integrity, template_def:${template_details}"

  fi

else

  echo "0|[ERROR] INTERNAL ERROR: func:check_template_integrity, template_details:${template_details} nb field =0"

fi
}

function build_template_cmd {

  # assign job name
  local job_name=$2

  # assign job id
  local job_id=$3

  # assign template details
  local template_details=$4

  # assign template action
  local template_action=$1

  # define nb field for this template
  local nb_template_field=`echo "${template_details}" | awk -F\| '{print NF}'`

  # define args list
  local arg_list=""

  # cmd to return
  local to_exec=""

  if [[ ${nb_template_field} -gt 0 ]]; then

    # extract the function name
    to_exec=`echo "${template_details}" | awk -F\| '{print $1}' | awk -F\/ '{print $2}'`" ${template_action} ${job_name} ${job_id}"

    if [[ ${nb_template_field} -gt 1 ]]; then

      # adding arg to function
      for field_value in `seq 2 ${nb_template_field}`; do

        arg_list="${arg_list} "`echo "${template_details}" | awk -F\| -v f_num=${field_value} '{print $f_num}'`

      done     

      to_exec="${to_exec} ${arg_list}"

    fi

  fi

  # return the command to run
  echo "${to_exec}"

}
