
const fs = require('fs') ;
const path = require('path') ;
const profile_path = '../latest/profile.d/' ;
const log_path = '../latest/log/' ;
const exec_path = '../latest/' ;
const { exec } = require('child_process') ;

function profile_list_all(callback) {
  
  fs.readdir(profile_path, function (err, files) {
    
    return callback(files) ;
    
  }) ;
    
} 

function profile_list_all_obj(callback) {
  
  var obj_list = [] ;
  
  fs.readdir(profile_path, function(err, files) { 
    
    files.forEach( function(file) {
    
      obj_list.push({ "profile_name": file })  ;
    
    }) ;
    
    return callback(obj_list) ;  
  }) ;
}

function profile_list_all_obj_by_value(value, callback) {
  
  var obj_list = new Array() ;
  var targetRe = new RegExp(value) ;
  
  fs.readdir(profile_path, function(err, files) {
    
    files.forEach( function(file) {
      
      if( targetRe.test(file) ) {
        
        obj_list.push({"profile_name": file }) ;
      }  
    }) ;
    
    return callback(obj_list) ;
  }) ;
}

function profile_create_new(profile_name, callback) {
  
  var new_profile_path = profile_path + profile_name ; 
  var return_obj = [] ;
  
  if ( ! fs.existsSync(new_profile_path) ) {
    
    fs.writeFileSync(new_profile_path, '', 'utf-8', '600') ;
    if ( fs.existsSync(new_profile_path) ) {
      
      return_obj.push( {"res_code": 1, "res_description": "profile creation success"} ) ;
    }
  } else {
    
    return_obj.push( {"res_code": 0, "res_description": "profile already exists"} ) ;
  }
  
  return callback(return_obj) ;
  
}

function profile_remove(profile_name, callback) {
  
  var existing_profile_path = profile_path + profile_name ;
  var return_obj = [] ;
  
  if ( fs.existsSync(existing_profile_path) ) {
    
    fs.unlinkSync(existing_profile_path) ;
    if ( ! fs.existsSync(existing_profile_path) ) {
      
      return_obj.push( {"res_code": 1, "res_description": "profile deleted successful"} ) ;
    }  
  } else {
    
    return_obj.push( {"res_code": 0, "res_description": "profile doesnt exist"} ) ;
  }
  
  return callback(return_obj) ;
  
}


function mpht_run(method, profile_name, callback) {
  
  // run the process
  var cmd_to_run = 'cd ../latest/ ; ./MPHT.sh --' + method + ' --profile ' + profile_name ;
  console.log(cmd_to_run) ;
  exec(cmd_to_run, function(err, stdout, stderr) {
    
    console.log('err' + err) ;
    console.log('stdout' + stdout) ;
    console.log('stderr' + stderr) ;
    
    var run_output = stdout.toString().split('\n') ;
    return callback({"run_output": run_output}) ;
    
  }) ;
  
}

module.exports.profile_create_new = profile_create_new ;
module.exports.profile_remove = profile_remove ;
module.exports.profile_list_all = profile_list_all ;
module.exports.profile_list_all_obj = profile_list_all_obj ;
module.exports.profile_list_all_obj_by_value = profile_list_all_obj_by_value ;
module.exports.mpht_run = mpht_run ;

