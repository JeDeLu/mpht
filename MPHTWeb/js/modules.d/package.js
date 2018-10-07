
const fs = require('fs') ;
const path = require('path') ;
const package_path = '../package.d/' ;
const bin_path = '../latest/bin/' ;
const { exec } = require('child_process') ;

/* ******************* package_get_all_obj
 * this function return a list of package object
 * 
 * {
 * "name": package_name:string,
 * "active": package_active:boolean,
 * "deploy": package_deploy:boolean
 * }
 *
 */

function package_get_all_obj(callback) {
  
  var obj_list = new Array() ;
  var packageNameRe = /[\w\-\.]{1,}\.pkg/ ;
  var packages = fs.readdirSync(package_path) ;
  console.log(packages) ;
    
  packages.forEach( function(package) {
  
    // check if the file returned have a package name equivalent
    if( packageNameRe.test(package)) {
      
      var packageName = package.replace(".pkg", "") ;
      var packagePath = path.join("../", packageName) ;
        console.log(packagePath) ;
      exist = fs.existsSync( packagePath) ;
      if( exist) {
          
        stats = fs.lstatSync( '../latest') ;
              
        var packageDeploy = true ;
        var realpath = fs.realpathSync('../latest') ; 
        
        if( path.basename(realpath) === packageName) {
          var packageActive = true ;
          obj_list.push({"name": packageName, "active": packageActive, "deploy": packageDeploy}) ;
              
        } else {
          
          var packageActive = false ;
          obj_list.push({"name": packageName, "active": packageActive, "deploy": packageDeploy}) ;
        }
            
            
      } else {
        
        var packageDeploy = false ;
        var packageActive = false ;
          
        obj_list.push({"name": packageName, "active": packageActive, "deploy": packageDeploy}) ;
      }
        
    } 
  
  }) ;

  return callback(obj_list) ;
  
}

function package_activate(package_name, callback) {
  
  var cmd_to_run = bin_path + 'acpkg "' + package_name + '"' ;
  
  exec(cmd_to_run, function(err, stdout, stderr) {
    console.log(err, stdout, stderr) ;
    if( stdout.toString().split('\n')[0] === "1" ) {
      
      return callback({"res_code": 1, "res_description": "success", "res_data": []}) ;
      
    } else {
      
      return callback({"res_code": 0, "res_description": 'failed - ' + stderr.toString() , "res_data": []}) ;
      
    }  
  }) ;
}

function package_create(package_name, callback) {
  
  var cmd_to_run = bin_path + 'mkpkg "' + package_name + '"' ;
  
  exec(cmd_to_run, function(err, stdout, stderr) {
    console.log(err, stdout, stderr) ;
    if( stdout.toString().split('\n')[0] === "1" ) {
      
      return callback({"res_code": 1, "res_description": "success", "res_data": []}) ;
      
    } else {
      
      return callback({"res_code": 0, "res_description": 'failed - ' + stderr.toString() , "res_data": []}) ;
      
    }  
  }) ;
}

function package_deploy(package_name, callback) {
  
  var cmd_to_run = bin_path + 'depkg "' + package_name + '"' ;
  
  exec(cmd_to_run, function(err, stdout, stderr) {
    console.log(err, stdout, stderr) ;
    if( stdout.toString().split('\n')[0] === "1" ) {
      
      return callback({"res_code": 1, "res_description": "success", "res_data": []}) ;
      
    } else {
      
      return callback({"res_code": 0, "res_description": 'failed - ' + stderr.toString() , "res_data": []}) ;
      
    }  
  }) ;
}

function package_undeploy(package_name, callback) {
  
  var cmd_to_run = bin_path + 'undepkg "' + package_name + '"' ;
  
  exec(cmd_to_run, function(err, stdout, stderr) {
    console.log(err, stdout, stderr) ;
    if( stdout.toString().split('\n')[0] === "1" ) {
      
      return callback({"res_code": 1, "res_description": "success", "res_data": []}) ;
      
    } else {
      
      return callback({"res_code": 0, "res_description": 'failed - ' + stderr.toString() , "res_data": []}) ;
      
    }  
  }) ;
  
}

function package_remove(package_name, callback) {
  
  var cmd_to_run = bin_path + 'rempkg "' + package_name + '"' ;
  
  exec(cmd_to_run, function(err, stdout, stderr) {
    console.log(err, stdout, stderr) ;
    if( stdout.toString().split('\n')[0] === "1" ) {
      
      return callback({"res_code": 1, "res_description": "success", "res_data": []}) ;
      
    } else {
      
      return callback({"res_code": 0, "res_description": 'failed - ' + stderr.toString() , "res_data": []}) ;
      
    }  
  }) ;
  
}

module.exports.package_get_all_obj = package_get_all_obj ;
module.exports.package_activate = package_activate ;
module.exports.package_create = package_create ;
module.exports.package_deploy = package_deploy ;
module.exports.package_undeploy = package_undeploy ;
module.exports.package_remove = package_remove ;



