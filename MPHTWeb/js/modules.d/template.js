

const fs = require('fs') ;
const path = require('path') ;
const root_path = "../latest/" ;
const temp_path = "../latest/tmp" ;
const template_path = "../latest/template.d/" ;

/*
 * this function returns a list of json objects
 * the json object contains all the information about the template object
 * the json object is structured as follow :
 * {
 * 
 *  "name": <template_name> type:string 
 *  "section": <section_name> type:string
 *  "description": <template_description> type:string
 *  "args_number": <template_arg_number> type:int
 *  "args_description": <template_arg_desc> type:array
 * 
 * }
 * 
 */

function list_all_realm_object(callback) {
  
  var obj_list = [] ;
  var section_folder_list = fs.readdirSync(template_path) ;
  
  section_folder_list.forEach( function(section_folder) {
    
    obj_list.push( {"name": section_folder} ) ;
  }) ;
  
  return callback(obj_list) ;
}

function list_by_realm_object(realm_name, callback) {
  
  var obj_list = [] ;
  var realm_path = path.join(template_path, realm_name) ;
  console.log(realm_path) ;
  var template_list = fs.readdirSync(realm_path) ;
  console.log(template_list) ;
  template_list.forEach( function(template) {
    
    obj_list.push( {"name": template} ) ;
  }) ;
  console.log(obj_list) ;
  return callback(obj_list) ;
}


function list_all_object(callback) {
  
  var obj_list = [] ;
  var section_folder_list = fs.readdirSync(template_path) ;
       
  section_folder_list.forEach(function(section_folder) {
      
    current_section_path = path.join(template_path, section_folder) ;
    
    template_file_list = fs.readdirSync(current_section_path) ;
    template_file_list.forEach( function(template) { 
      
      current_template_path = path.join(current_section_path, template) ;
        
      file_content = fs.readFileSync(current_template_path, 'utf-8') ;
        
      lines = file_content.toString().split('\n') ;
        
      var template_arg_desc = [] ;
        
      lines.forEach( function(line) {
          
        var descRE = /^# DESC=\"[\w\-\ ]{1,}\"/ ;
        var nameRE = /^# NAME=\"[\w\-\ ]{1,}\"/ ;
        var argnRE = /^# ARG_NUM=\"[0-9]{1,}\"/ ;
        var argpRE = /^# ARG#\d=\"[\w\-\ ]{1,}\"/ ;
        
        if ( descRE.test(line) ) {

          //this line contains the template description
         template_description = line.split('\"')[1] ;
          /*
           * 
           * do something here
           * 
           */

        } else if( nameRE.test(line) ) {
          //this line contains the template name
          template_name = line.split('\"')[1] ;
          /*
           * 
           * do something here
           * 
           */


        } else if ( argnRE.test(line) ) {

          //this line contains the template number args
          template_arg_num = line.split('\"')[1] ;
          /*
           * 
           * do something here
           * 
           */

        } else if ( argpRE.test(line) ) {

          //this line contains the template arg position X description
          template_arg_pos = line.split('#')[2].split('=')[0] ;
          template_arg_pos = template_arg_pos - 1 ;
          template_arg_desc[template_arg_pos] = line.split('\"')[1] ;
          /*
           * 
           * do something here
           * 
           */

        }
         
      }) ;
      
      obj_list.push({"name": template_name, "realm": section_folder, "description": template_description, "args_number": template_arg_num, "args_description": template_arg_desc }) ;
      
    }) ;
  
  }) ;
  
  return callback(obj_list) ;
}

function list_object_by_template_object (realm_name, template_name, callback) {
  
  var obj_list = [] ;
  var template_path = "../latest/template.d/" ;
  var template_path = path.join(template_path, realm_name, template_name) ;
  var file_content = fs.readFileSync(template_path, 'utf-8') ;
  
  var descRE = /^# DESC=\"[\w\-\ ]{1,}\"/ ;
  var nameRE = /^# NAME=\"[\w\-\ ]{1,}\"/ ;
  var argnRE = /^# ARG_NUM=\"[0-9]{1,}\"/ ;
  var argpRE = /^# ARG#\d=\"[\w\-\ ]{1,}\"/ ;
  
  lines = file_content.toString().split('\n') ;
  
  var template_name ;
  var template_desc ;
  var template_argn ;
  var template_argp = new Array() ;
  
  lines.forEach( function(line) {
  
    if( nameRE.test(line)) {
      
      template_name = line.split('\"')[1] ;
    } else if( descRE.test(line)) {
      
      template_desc = line.split('\"')[1] ;
    } else if( argnRE.test(line)) {
      
      template_argn = line.split('\"')[1] ;
    } else if( argpRE.test(line)) {
      
      template_argp.push(line.split('\"')[1]) ;
    }
  }) ;
  
  obj_list = {"name": template_name, "description": template_desc, "template_argn": template_argn, "template_argp": template_argp} ;
  return callback(obj_list) ;
}

function disp_content_by_template(realm_name, template_name, callback) {
  
  var current_template_path = path.join(template_path, realm_name, template_name) ;
  
  fs.readFile(current_template_path, function(err, file_content) { 
  
    var file_data = file_content.toString().split('\n') ;
    
    return callback({"res_code": 1, "res_description": "success", "res_data": file_data}) ;
  
  }) ;
}

function template_create_new(realm_name, template_name, template_desc, template_num_args, template_desc_args) {}

function template_list_all_obj_by_value( value, callback) {
  
  var obj_list = [] ;
  var section_folder_list = fs.readdirSync(template_path) ;
  var targetRe = new RegExp(value) ;
  
  section_folder_list.forEach(function(section_folder) {
      
    current_section_path = path.join(template_path, section_folder) ;
    
    template_file_list = fs.readdirSync(current_section_path) ;
    template_file_list.forEach( function(template) { 
      
      if( targetRe.test( template)) {
        console.log(value) ; 
        console.log(template) ;
        current_template_path = path.join(current_section_path, template) ;
        
        file_content = fs.readFileSync(current_template_path, 'utf-8') ;
        
        lines = file_content.toString().split('\n') ;
        
        var template_arg_desc = [] ;
        
        lines.forEach( function(line) {
          
          var descRE = /^# DESC=\"[\w\-\ ]{1,}\"/ ;
          var nameRE = /^# NAME=\"[\w\-\ ]{1,}\"/ ;
          var argnRE = /^# ARG_NUM=\"[0-9]{1,}\"/ ;
          var argpRE = /^# ARG#\d=\"[\w\-\ ]{1,}\"/ ;
        
          if ( descRE.test(line) ) {

            //this line contains the template description
            template_description = line.split('\"')[1] ;
            /*
           * 
           * do something here
           * 
           */

          } else if( nameRE.test(line) ) {
            //this line contains the template name
            template_name = line.split('\"')[1] ;
            /*
            * 
            * do something here
            * 
            */


          } else if ( argnRE.test(line) ) {

            //this line contains the template number args
            template_arg_num = line.split('\"')[1] ;
            /*
            * 
            * do something here
            * 
            */

          } else if ( argpRE.test(line) ) {

            //this line contains the template arg position X description
            template_arg_pos = line.split('#')[2].split('=')[0] ;
           template_arg_pos = template_arg_pos - 1 ;
            template_arg_desc[template_arg_pos] = line.split('\"')[1] ;
            /*
            * 
            * do something here
            * 
            */

          }
        }) ;
        
        obj_list.push({"name": template_name, "realm": section_folder, "description": template_description, "args_number": template_arg_num, "args_description": template_arg_desc }) ;
      }
      
    }) ;
  
  }) ;
  
  return callback(obj_list) ;  
  
}

function template_update_file( template_realm, template_name, template_data, callback) {
  
  var tempTemplateName = template_name + '.tmp' ;
  var tempTemplatePath = path.join( temp_path, tempTemplateName) ;
  var templatePath = path.join( template_path, template_realm, template_name) ;
  var template_lines = template_data.split('<br>') ;
  
  template_lines.forEach( function(template_line) {
    
    template_line = template_line.replace('<code>', '') ;
    template_line = template_line.replace('</code>', '') ;
    template_line = template_line.replace('&amp;', '&') ;
    template_line = template_line.replace('&gt;', '>') ;
    template_line = template_line.replace('&lt;', '<') ;
    
    fs.appendFileSync(tempTemplatePath, template_line + '\n') ;
    
  }) ;
  
  fs.rename(tempTemplatePath, templatePath, function(err) {
    
    if( err) {
      
      return callback({"res_code": 0, "res_description": err, "res_data": []}) ;
    } else { 
    
      return callback({"res_code": 1, "res_description": "success", "res_data": []}) ;
    }
  }) ;
}

module.exports.disp_content_by_template = disp_content_by_template ;
module.exports.list_object_by_template_object = list_object_by_template_object ;
module.exports.list_all_realm_object = list_all_realm_object ;
module.exports.list_by_realm_object = list_by_realm_object ;
module.exports.list_all_object = list_all_object ;
module.exports.template_create_new = template_create_new ;
module.exports.template_list_all_obj_by_value = template_list_all_obj_by_value ;
module.exports.template_update_file = template_update_file ;
