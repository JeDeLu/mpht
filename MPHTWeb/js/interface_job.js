function jobHTMLList(js_obj) {
  
  
  var i = 0 ;
  var HTML_OUTPUT = '' ;
    
  js_obj.forEach( function( job) {
          
    var job_profile = job['profile'] ;
    var job_active = job['active'] ;
    var job_name = job['name'] ;
    var job_template_name = job['template_name'] ;
    var job_template_args = job['template_args'] ;
           
    HTML_OUTPUT = HTML_OUTPUT + '\
    <div id="job_name_'+i+'" onclick="showDetails(\'job_details_'+i+'\') ;" class="obj_name">\
      <div style="display: block; float: left;"><img src="images/job.png" width="15" height="15" /></div>\
      <div style="display: block; padding-left: 25px;">Name: ' + job_name + '</div>\
    </div>\
    <div id="job_details_'+i+'" class="obj_details">\
    <div class="obj_details_value">profile: '+job_profile+'</div>\
    <div class="obj_details_value">template: '+job_template_name+'</div>' ;
      
    if ( job_active === "yes" ) {
      
      HTML_OUTPUT = HTML_OUTPUT + '<div class="obj_details_value">active: <input type="checkbox" checked disabled="disabled"/></div>' ;
    } else if ( job_active === "no" ) {
        
      HTML_OUTPUT = HTML_OUTPUT + '<div class="obj_details_value">active: <input type="checkbox" disabled="disabled" /></div>' ;
    }
      
    if ( typeof(job_template_args) === "object" && job_template_args.length > 0 ) {
        
      var j = 0 ;
      job_template_args.forEach( function(job_arg) {
          
        HTML_OUTPUT = HTML_OUTPUT + '<div class="obj_details_value">arg '+j+' value: '+job_arg+'</div>' ;
        j += 1 ;
          
      }) ;
    }
      
    HTML_OUTPUT = HTML_OUTPUT + '\
    \
    <div id="obj_details_cmd" class="obj_details_cmd">\
    <button class="obj_details_button" onclick="clickJobButtonRem(\''+job_name+'\', \''+job_profile+'\') ;">REMOVE</button>\
    </div>\
    \
    </div>' ;
    i += 1 ;    
    
  }) ;
  
  // flush the app_disp section
  $("#app_disp").html("") ;
  $("#app_disp").css("overflow", "visible") ;
  
  // update the app_disp section with new html content
  $("#app_disp").html(HTML_OUTPUT) ;
  $("#app_disp").css("overflow", "scroll") ;
  
}
  
function showJobs(obj) {
      
  // update the button class after click on it
  updateNavBarButtonClass(obj) ;
  
  var description_field = "<span style=\"font-size: 14px; color: #4f94cd;\">JOB MANAGEMENT</span><br /><br /><span class=\"description_block\">\
    Helps you to create/update a job.<br />List all job and interact with them, while creating your new job for your profile, remember the following :\
    a job name must be unique inside a profile,<br /> A job can be active or inactive depending on your which but \
    if a job is inactive it won't be run by the profile. Search for a job by filling the search field with the complete name of a job \
    or with a partial name of the job. A job removed from a profile won't be recovered, just keep in mind that the best way to update a job is \
    delete existing and create new.</span>" ;
    
  $('#menu_description').html(description_field) ;
  $('#nav_bar_bt_description').css('display', 'block') ;
  
  // update the app disp with the new profile create
  var HTML_OUTPUT = '\
  <div class="obj_create_zone">\
  \
  <div id="job_bt_zone" class="obj_bt_zone">\
  <div class="obj_title_zone">JOB MANAGEMENT</div> \
  <button class="obj_button_create" onclick="clickButtonCreate(\'job_form\') ;">CREATE</button>\
  <button class="obj_button_list" onclick="clickJobButtonList() ;">LIST</button>\
  </div> \
  \
  <div id="job_form" class="obj_form">\
  <div id="job_form_name" class="obj_form_field">Name: <input type="text" id="job_form_name_input"/></div>\
  <div id="job_form_profile_name" class="obj_form_field"></div>\
  <div id="job_form_template_realm" class="obj_form_field"></div>\
  <div id="job_form_template_name" class="obj_form_field"></div>\
  <div id="job_form_active" class="obj_form_field">active: <input id="job_form_active_checkbox" type="checkbox"/></div>\
  <div id="job_form_args" class="obj_form_field"></div>\
  <div id="send_form_new_job" class="send_form_new_obj">\
  <button class="obj_button_send" onclick="createNewJobObj() ;">SEND</button>\
  </div>\
  </div>\
  \
  </div>\
  \
  <div id="obj_search_zone" class="obj_search_zone">\
  <input type="text" size="75" id="obj_search_field" class="obj_search_field" placeholder="search a job by name" />\
  <button id="obj_search_button" class="obj_button_search" onclick="clickJobButtonSearch() ;">SEARCH</button>\
  </div>';
  
  $("#app_interactive").html(HTML_OUTPUT) ;
  
  // show the job profile name drop down menu at first
  showJobProfileNameDDMenu() ;
  
  //show the job template drop down menu at first
  showJobTemplateRealmDDMenu() ;
  
  //flush the content of the app_disp
  $("#app_disp").html('') ;
}

function clickJobButtonList() {
  
  // update the content with the list of jobs.
  $.get("/get_job_all", function(data) {
        
    // get this object which is a list of json objects
    var js_obj = JSON.parse(data) ;
    
    //
    jobHTMLList(js_obj) ;
        
  }) ;
}

function clickJobButtonSearch() {
  
  var search_value = document.getElementById("obj_search_field").value ;
  var url = '/get_job_search_value?value=' + search_value ;
  
  if ( search_value !== '' ) {
    
    $.get(url, function(data) {
      
      var js_obj = JSON.parse(data) ;
      jobHTMLList(js_obj) ;  
    }) ;
  }
}

function clickJobButtonRem(job_name, job_profile) {
  
  var url = '/remove_job?profile_name=' + job_profile + '&job_name=' + job_name;
  
  $.get(url, function(data) {
    
    js_obj = JSON.parse(data) ;
    console.log(js_obj['res_code']) ;
     if (js_obj['res_code'] === 1 ) {
      
      // if the search field is not empty then run search
      var search_value = document.getElementById("obj_search_field").value ;
      if( search_value !== '' ) {
        
        clickButtonSearch() ;
      } else {
      // else run the full listing
      
        clickButtonList() ;
      }
    }
  }) ;
}



function createNewJobObj() {
  
  var job_profile = document.getElementById("job_profile_select").value ;
  var job_name = document.getElementById("job_form_name_input").value ;
  var el_active = document.getElementById("job_form_active_checkbox") ;
  console.log(el_active) ;
  if (el_active.checked === true ) {
    job_active = "yes" ;
  } else { job_active = "no" ; }
  
  var el_realm = document.getElementById("jobTemplateSelectRealm") ;
  var job_realm = el_realm.options[el_realm.selectedIndex].value ;
  
  var el_template = document.getElementById("jobTemplateSelectName") ;
  var job_template = el_template.options[el_template.selectedIndex].value ;
  
  var job_template_arg_list = document.getElementsByTagName("input") ;
  var inputIdRe = /jobTemplateArg_\d{1,}/ ;
  var argList = new Array() ;
  console.log(job_template_arg_list) ;
  console.log(typeof(job_template_arg_list)) ;
  for(var j=0; j<job_template_arg_list.length; j++) {
    
    if( inputIdRe.test(job_template_arg_list[j].id)) {
      
      argList.push(job_template_arg_list[j].value) ;
    }
  }
  
  var url = '/create_job?profile_name=' + job_profile + '&job_name=' + job_name + '&active=' + job_active + '&template_realm=' + job_realm + '&template_name=' + job_template + '&template_args=' + argList.join();
  console.log(url) ;
   
  $.get(url, function(data) {
    
    var js_obj = JSON.parse(data) ;
    console.log(js_obj) ;
    if( js_obj['res_code'] === 1) {
      
      // if the search field is not empty then run search
      var search_value = document.getElementById("obj_search_field").value ;
      if( search_value !== '' ) {
        
        clickButtonSearch() ;
      } else {
      // else run the full listing
      
        clickButtonList() ;
      }
    }
    
  }) ;
  
}

function showJobProfileNameDDMenu() {
  
  $.get('/get_profile_all', function(data) {
    
    var js_obj = JSON.parse(data) ;
    var HTML_OUTPUT = 'Profile name: <select id="job_profile_select">' ;
    
    js_obj.forEach( function(profile) {
    
      var profile_name = profile['profile_name'] ;   
      HTML_OUTPUT = HTML_OUTPUT + '<option value="'+profile_name+'">'+profile_name+'</option>' ;
    
    }) ;
    
    $("#job_form_profile_name").html(HTML_OUTPUT + '</select>') ;
  }) ;
}


function showJobTemplateNameDDMenu(realm_name) {
  
  $.get('/get_template_name_by_realm?name=' + realm_name, function(data) {
    
    var js_obj = JSON.parse(data) ;
    var HTML_OUTPUT = 'Template name: <select id="jobTemplateSelectName" onchange="loadJobTemplateArgs() ;">' ;
    
    js_obj.forEach( function(template) {
      
      template_name = template['name'] ;
      HTML_OUTPUT = HTML_OUTPUT + '<option value="'+template_name+'">'+template_name+'</option>' ;
      
    }) ;
    
    $("#job_form_template_name").html(HTML_OUTPUT + '</select>') ;
  }) ; 
}


function showJobTemplateRealmDDMenu() {
  
  $.get('/get_template_realm', function(data) {
    
    var js_obj = JSON.parse(data) ;
    var HTML_OUTPUT = 'template realm: <select id="jobTemplateSelectRealm" onchange="loadJobTemplateName() ;">' ;
     
    js_obj.forEach( function(realm) {
      
      realm_name = realm['name'] ;
      HTML_OUTPUT = HTML_OUTPUT + '<option value="'+realm_name+'">'+realm_name+'</option>' ;
    }) ;
    
    $("#job_form_template_realm").html(HTML_OUTPUT + '</select>') ;
  }) ;  
}

function showJobTemplateArgsInput( realm_name, template_name) {
  
  var url = '/get_template_obj?realm_name=' + realm_name + '&template_name=' + template_name ;
   
  $.get(url, function( data) {
    
    var js_obj = JSON.parse(data) ;
    var template_num_args = js_obj['template_argn'] ;
    var template_arg_arr = js_obj['template_argp'] ;
    var HTML_OUTPUT = '';
    
    if( template_num_args > 0 ) {
      var i = 0 ;
      template_arg_arr.forEach( function(template_arg) {
        
        HTML_OUTPUT = HTML_OUTPUT + '<input id="jobTemplateArg_' + i + '" type="text" placeholder="' + template_arg + '" />' ;
        
      }) ;
    }
    
    $("#job_form_args").html(HTML_OUTPUT) ;
    
  }) ;
}

function loadJobTemplateName() {
  
  var realmValue = document.getElementById("jobTemplateSelectRealm").value ;
  showJobTemplateNameDDMenu(realmValue) ;
}

function loadJobTemplateArgs() {
  
  var realm_name = document.getElementById("jobTemplateSelectRealm").value ;
  var template_name = document.getElementById("jobTemplateSelectName").value ;
  showJobTemplateArgsInput(realm_name, template_name) ;
}