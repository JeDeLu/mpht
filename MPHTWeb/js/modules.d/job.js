
const path = require('path') ;
const fs = require('fs') ;
const profile = require('./profile') ;
const profile_path = '../latest/profile.d/' ;


function job_exists(profile_name, job_name, callback) {
  
  var profile_file_path = path.join(profile_path, profile_name) ;
  var file_content = fs.readFileSync(profile_file_path, 'utf-8') ;
  var res_to_return = false ;
  
  lines = file_content.toString().split('\n') ;
  
  lines.forEach( function(line) {
    
   var targetStr = 'jobname=' + job_name + ',' ;
   var targetRe = new RegExp(targetStr) ;
    
   if( targetRe.test(line)) {
     
     res_to_return = true ;
   } 
  }) ;
  
  return callback(res_to_return) ;
}


/*
 * this function return an array of json object job
 * this object contains job full details
 * 
 * the json object is represented as follow: 
 * 
 * {
 *  name: <job_name> type:string,
 *  job_active: <yes|no> type:string,
 *  description: <job_description> type:string,
 *  profile: <profile_name> type:string,
 *  template_name: <template_name> type:string,
 *  template_args: <list_of_args> type:array
 * }
 * 
 */
function job_list_all_object(callback) {
  
  var json_obj_list = [] ;
  
  profile.profile_list_all( function(profile_file) {
    
    profile_file.forEach( function (profile_name) {
         
      var current_profile_path = path.join(profile_path, profile_name) ;
      var jobActiveRe = /^\[[xX]\] / ;
      var jobInactiveRe = /^\[[oO]\] / ;
      var jobCommentRe = /^#/ ;
  
      file_content = fs.readFileSync(current_profile_path, 'utf8') ;
      
      lines = file_content.toString().split('\n') ;
      
      lines.forEach(function (line) {        
        
        if(line !== '') {
        
          if (! jobCommentRe.test(line) ) {
            if ( jobActiveRe.test(line) ) {
            
              job_active = "yes" ;
            } else if ( jobInactiveRe.test(line) ) {
            
              job_active = "no" ;
            }
          
            job_name = line.split(',')[0].split('=')[1] ;
            template_name = line.split(',')[1].split('=')[1].split('|')[0] ;
            template_args = line.split(',')[1].split('=')[1].split('|').slice(1,) ;
            json_obj_list.push({"profile": profile_name, "active": job_active, "name": job_name, "template_name": template_name, "template_args": template_args }) ;
          }
        }
      }) ;
    }) ;
    
    return callback(json_obj_list) ;
  }) ;
}



function job_list_all_obj_by_value(value, callback) {
  
  var json_obj_list = [] ;
  
  profile.profile_list_all( function(profile_file) {
    
    profile_file.forEach( function (profile_name) {
         
      var current_profile_path = path.join(profile_path, profile_name) ;
      var jobActiveRe = /^\[[xX]\] / ;
      var jobInactiveRe = /^\[[oO]\] / ;
      var jobCommentRe = /^#/ ;
      var valueToSearch = new RegExp(value) ;
      console.log(value) ;
  
      file_content = fs.readFileSync(current_profile_path, 'utf8') ;
      
      lines = file_content.toString().split('\n') ;
      
      lines.forEach(function (line) {        
        
        if(line !== '') {
        
          if (! jobCommentRe.test(line) ) {
            if ( jobActiveRe.test(line) ) {
            
              job_active = "yes" ;
            } else if ( jobInactiveRe.test(line) ) {
            
              job_active = "no" ;
            }
          
            job_name = line.split(',')[0].split('=')[1] ;
            template_name = line.split(',')[1].split('=')[1].split('|')[0] ;
            template_args = line.split(',')[1].split('=')[1].split('|').slice(1,) ;
            if ( valueToSearch.test(job_name) ) {
              
              json_obj_list.push({"profile": profile_name, "active": job_active, "name": job_name, "template_name": template_name, "template_args": template_args }) ;
            }
          }
        }
      }) ;
    }) ;
    
    return callback(json_obj_list) ;
  }) ;
}



function job_create_new(profile, name, active, realm, template, args, callback) {
  
  var profile_name = profile ;
  var profile_file_path = path.join(profile_path, profile_name) ;
  var job_name = name ;
  var job_active = active ;
  var job_template_realm = realm ;
  var job_template_name = template ;
  var job_template_args = args.split(',') ;
  var return_obj = [] ;

  
  if ( fs.existsSync(profile_file_path) ) {
  
    job_exists(profile_name, job_name, function(data) {
      console.log('first_check '+data) ;
      if( data !== true) {
        
        job_line = '' ;
        if ( job_active === "yes" ) {
    
          job_line = job_line + '[X] ';
        } else if ( job_active === "no" ) {
    
          job_line = job_line + '[O] ' ;
        }
  
        job_line = job_line + 'jobname='+ job_name + ',template=' + job_template_realm + '/' + job_template_name;
  
        if ( job_template_args.length > 0 ) {
    
          arg_string = '' ;
          job_template_args.forEach( function(arg) {
      
            arg_string = arg_string + "|" + arg ; 
          }) ;
    
          job_line = job_line + arg_string + '\n' ;
        }
  
        fs.appendFileSync(profile_file_path, job_line, { "encoding": "utf-8", "mode": "600", "flag": "a" } ) ;
    
        job_exists(profile_name, job_name, function(data) {
          console.log('second check '+data) ;
          if( data === true ) {
      
            return callback({"res_code": 1, "res_description": "job creation success"}) ;
          } else {
      
            return callback({"res_code": 0, "res_description": "job creation failed - write error"}) ;
          }
        }) ;
        
      } else {
        
        return callback({"res_code": 0, "res_description": "job creation failed - job already exist"}) ;
      }
    });
  }
}

function job_remove(profile_name, job_name, callback) {
  
  var new_profile_path = path.join(profile_path, profile_name) ;
  var new_profile_path_tmp = path.join(profile_path, '.' + profile_name + '.tmp') ;
  var obj_list = [] ;
  
  if ( fs.existsSync(new_profile_path) ) {
    
    var profile_lines = fs.readFileSync(new_profile_path, 'utf-8').toString().split('\n') ;
    var targetStr = 'jobname=' + job_name + ',' ;
    var emptyLine = /^$/ ;
    var targetRe = new RegExp(targetStr) ;
    
    profile_lines.forEach( function(line) {
      
      if ( !targetRe.test(line) || !emptyLine.test(line) ) {
        
        fs.appendFileSync(new_profile_path_tmp, line + '\n', {"encoding": "utf-8", "mode": 600, "flag": "a+"} ) ;
      }
    }) ;
    
    fs.renameSync(new_profile_path_tmp, new_profile_path) ;
    return callback( {"res_code": 1, "res_description": "job remove successs"} ) ; 
  } else {
    
    return callback( {"res_code": 0, "res_description": "job remove failes - profile not exist"} ) ;
  }
}



module.exports.job_list_all_object = job_list_all_object ;
module.exports.job_list_all_obj_by_value = job_list_all_obj_by_value ;
module.exports.job_create_new = job_create_new ;
module.exports.job_exists = job_exists ;
module.exports.job_remove = job_remove ;
