function packageHTMLList(js_obj) {
  
  // flush html content removing previous output
  $("#app_disp").html('') ;
  
  var i = 0 ;
  var HTML_OUTPUT = '' ;
       
  js_obj.forEach( function( js_package) {
          
    package_name = js_package['name'] ;
    package_active = js_package['active'] ;
    package_deploy = js_package['deploy'] ;
    
    if( package_active === true && package_deploy === true) {
      
      // we do nothing since the active package is untouchable
      // HTML_OUTPUT = HTML_OUTPUT + '\
      // <button id="obj_button_deactivate_' + i + '" class="obj_details_button" onclick="clickPackageButtonDeactivate(\'' + package_name + '\');">deactivate</button>' ;
      
    } else if( package_active === false && package_deploy === false) {
      
      HTML_OUTPUT = HTML_OUTPUT + '\
      <div id=package_name_'+i+'" style="overflow: hidden;" onclick="showDetails(\'package_details_'+i+'\');" class="obj_name"> \
      <div style="display: block; float: left; "><img src="images/package.png" width="15" height="15" /></div> \
      <div style="display: block; float: left; padding-left: 10px">Name: ' + package_name + '</div> \
      <div id="package_active_' + i + '"style="display: block; float: left; padding-left: 30px; width: 100px; align: center;">Active: ' + package_active + '</div> \
      <div id="package_deploy_' + i + '"style="display: block; float: left; padding-left: 30px; width: 100px; align: center;">Deploy: ' + package_deploy + '</div> \
      </div> \
      <div id="package_details_'+i+'" class="obj_details" style="overflow: hidden;"> \
      <button id="obj_button_deploy_' + i + '" class="obj_details_button" onclick="clickPackageButtonDeploy(\'' + package_name + '\');">deploy</button> \
      <button id="obj_button_deploy_' + i + '" class="obj_details_button" onclick="clickPackageButtonRemove(\'' + package_name + '\');">remove</button> \
      </div>';
      
    } else if( package_active === true && package_deploy === false) {
    
      // should never appears
      // this scenario is never expected since a package must be deployed before to be active
      HTML_OUTPUT = HTML_OUTPUT + '\
      <div id=package_name_'+i+'" style="overflow: hidden;" onclick="showDetails(\'package_details_'+i+'\');" class="obj_name"> \
      <div style="display: block; float: left; "><img src="images/package.png" width="15" height="15" /></div> \
      <div style="display: block; float: left; padding-left: 10px">Name: ' + package_name + '</div> \
      <div id="package_active_' + i + '"style="display: block; float: left; padding-left: 30px; width: 100px; align: center;">Active: ' + package_active + '</div> \
      <div id="package_deploy_' + i + '"style="display: block; float: left; padding-left: 30px; width: 100px; align: center;">Deploy: ' + package_deploy + '</div> \
      </div> \
      <div id="package_details_'+i+'" class="obj_details" style="overflow: hidden;"> \
      <button id="obj_button_deploy_' + i + '">activate</button> \
      </div>';
    
    } else if(package_active === false && package_deploy === true) {
    
      HTML_OUTPUT = HTML_OUTPUT + '\
      <div id=package_name_'+i+'" style="overflow: hidden;" onclick="showDetails(\'package_details_'+i+'\');" class="obj_name"> \
      <div style="display: block; float: left; "><img src="images/package.png" width="15" height="15" /></div> \
      <div style="display: block; float: left; padding-left: 10px">Name: ' + package_name + '</div> \
      <div id="package_active_' + i + '"style="display: block; float: left; padding-left: 30px; width: 100px; align: center;">Active: ' + package_active + '</div> \
      <div id="package_deploy_' + i + '"style="display: block; float: left; padding-left: 30px; width: 100px; align: center;">Deploy: ' + package_deploy + '</div> \
      </div> \
      <div id="package_details_'+i+'" class="obj_details" style="overflow: hidden;"> \
      <button id="obj_button_activate_' + i + '" class="obj_details_button" onclick="clickPackageButtonActivate(\'' + package_name + '\');">activate</button>\
      <button id="obj_button_undeploy_' + i + '" class="obj_details_button" onclick="clickPackageButtonUndeploy(\'' + package_name + '\');">undeploy</button> \
      </div>';
    }
    
    i += 1 ;
      
  }) ;
  
  // update the app_disp zone with new html content
  $("#app_disp").html(HTML_OUTPUT) ;
  $("#app_disp").css("overflow", "scroll") ;
    
}


function showPackages(obj) {
      
  // update the button class after click on it
  updateNavBarButtonClass(obj) ;
  
  var description_field = "<span style=\"font-size: 14px; color: #4f94cd;\">PACKAGE MANAGEMENT</span><br /><br /><span class=\"description_block\">Helps you to update your item versioning.<br />\
    A package is a set of application items such profiles, templates, jobs.<br />The package management interface permit you \
    to create a copy of the running package then active it and update it to alter it without impacting your previous running version.<br />\
    To make a new package active, you must first deploy it then active it, as soon as a package becomes active any new items alter \
    will be available only on the current active package. Keep in mind that a package becomes active only if it has been previously deployed \
    after that this package will be protect so the undeploy will be possible only if another package becomes active instead.</span>" ;
  
  $('#menu_description').html(description_field) ;
  $('#nav_bar_bt_description').css('display', 'block') ;
  
  // flush the app_disp section
  $("#app_disp").html("") ;
  $("#app_disp").css("overflow", "visible") ;
  
  // update the app disp with the new profile create
  var HTML_OUTPUT = '\
  <div class="obj_create_zone">\
  \
  <div id="job_bt_zone" class="obj_bt_zone">\
  <div class="obj_title_zone">PACKAGE MANAGEMENT</div> \
  <button class="obj_button_create" onclick="clickButtonCreate(\'package_form\') ;">CREATE</button>\
  <button class="obj_button_list" onclick="clickPackageButtonList() ;">LIST</button>\
  <button class="obj_button_import" onclick="clickButtonImport(\'package_import\') ;">IMPORT</button>\
  </div> \
  \
  <div id="package_form" class="obj_form">\
  <div id="package_form_name" class="obj_form_field">Name: <input type="text" id="package_form_name_input"/></div>\
  <div id="send_form_new_job" class="send_form_new_obj">\
  <button class="obj_button_send" onclick="clickPackageButtonCreate() ;">SEND</button>\
  </div>\
  </div>\
  \
  <div id="package_import" class="obj_form">\
  <div id="package_form_name" class="obj_form_field">Name: <input type="text" id="package_form_name_input"/></div>\
  <div id="send_form_new_job" class="send_form_new_obj">\
  <button class="obj_button_send" onclick="clickPackageButtonCreate() ;">SEND</button>\
  </div>\
  </div>\
  \
  </div>\
  \
  <div id="obj_search_zone" class="obj_search_zone">\
  <input type="text" size="75" id="obj_search_field" class="obj_search_field" placeholder="search a package by name" />\
  <button id="obj_search_button" class="obj_button_search" onclick="clickTemplateButtonSearch() ;">SEARCH</button>\
  </div>';
  
  $("#app_interactive").html(HTML_OUTPUT) ;
  
  // update the profiles list
  $("#app_disp").html('') ;
      
}

function clickPackageButtonList() {
  
  var url = '/get_package_all' ;
  
  $.get(url, function( data) { 
  
    js_obj = JSON.parse(data) ;
    
    packageHTMLList(js_obj) ;
  
  }) ;
  
}

function clickPackageButtonCreate() {
  
  var package_name = $('#package_form_name_input').val() ;
  var url = '/create_package?package_name=' + package_name ;
  
  $.get(url, function(data) {
    
    js_obj = JSON.parse(data) ;
    var res_code = js_obj['res_code'] ;
    var res_description = js_obj['res_description'] ;
    var res_data = js_obj['res_data'] ;
    
    if ( res_code === 1 ) {
      
      clickPackageButtonList() ;
    }
  }) ;
}

function clickPackageButtonActivate( pkg_name) {
  
  var package_name = pkg_name ;
  var url = '/activate_package?package_name=' + package_name ;
 
  $.get(url, function(data) { 
  
    js_obj = JSON.parse(data) ;
    
    var res_code = js_obj['res_code'] ;
    var res_description = js_obj['res_description'] ;
    var res_data = js_obj['res_data'] ;
    
    if( res_code === 1 ) {
      
      // since the new default package is changed 
      // we update the banner with the new name
      bannerUpdatePackage() ;
      
      // reload the package list to provide the new update on screen
      clickPackageButtonList() ;
    }
   
  }) ;
}

function clickPackageButtonDeploy( pkg_name) {
  
  var package_name = pkg_name ;
  var url = '/deploy_package?package_name=' + package_name ;
 
  $.get(url, function(data) { 
   
    js_obj = JSON.parse(data) ;
   
    var res_code = js_obj['res_code'] ;
    var res_description = js_obj['res_description'] ;
    var res_data = js_obj['res_data'] ;
   
    if( res_code === 1 ) {
     
      clickPackageButtonList() ;
    }
  }) ;
}

function clickPackageButtonUndeploy( pkg_name) {
  
  var package_name = pkg_name ;
  var url = '/undeploy_package?package_name=' + package_name ;
 
  $.get(url, function(data) { 
   
    js_obj = JSON.parse(data) ;
   
    var res_code = js_obj['res_code'] ;
    var res_description = js_obj['res_description'] ;
    var res_data = js_obj['res_data'] ;
   
    if( res_code === 1 ) {
      
      clickPackageButtonList() ;
    }
  }) ;  
}

function clickPackageButtonRemove( pkg_name) {
  
  var package_name = pkg_name ;
  var url = '/remove_package?package_name=' + package_name ;
  
  $.get(url, function(data) {
    
    js_obj = JSON.parse(data) ;
    
    var res_code = js_obj['res_code'] ;
    var res_description = js_obj['res_description'] ;
    var res_data = js_obj['res_data'] ;
   
    if( res_code === 1 ) {
      
      clickPackageButtonList() ;
    }
  }) ;
}