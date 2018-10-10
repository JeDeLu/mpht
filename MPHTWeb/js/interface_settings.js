function showSettings(obj) {
      
  // update the button class after click on it
  updateNavBarButtonClass(obj) ;
  
  var description_field = "<span style=\"font-size: 14px; color: #4f94cd;\">SETTINGS MANAGEMENT</span><br /><br /><span class=\"description_block\">\
    Shows the global settings of the webserver and client <br /> \
    Some of the settings are read-only access, there are presented only to inform about the value some others settings are read-write access and can be updated as desired or suggested \
    <br />Please have a look at the beside list and update the settings as requiered.</span>" ;
  
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
  <div class="obj_title_zone">SETTINGS MANAGEMENT</div> \
  </div> \
  \
  </div>'; 
  
  $("#app_interactive").html(HTML_OUTPUT) ;
  
  // update the page content with the list of the settings
  settingsList() ;
  
}

function settingsList() {
  
  var url = '/list_settings' ;
  
  $.get(url, function(data) {
   
    js_obj = JSON.parse(data) ;
    console.log(js_obj) ;
    
    HTML_OUTPUT ='\
    \
    <div class="obj_settings">\
    <div class="obj_settings_key"><b>hostname</b><br />hostname of the running front-end</div>\
    <div class="obj_settings_value">' + js_obj['hostname'] + '</div>\
    </div>\
    \
    <div class="obj_settings">\
    <div class="obj_settings_key"><b>app_root_path</b><br />root path of the back-end app</div>\
    <div class="obj_settings_value">' + js_obj['app_root_path'] + '</div>\
    </div>\
    \
    <div class="obj_settings">\
    <div class="obj_settings_key"><b>app_webserv_path</b><br />root path of the front-end web server</div>\
    <div class="obj_settings_value">' + js_obj['app_webserv_path'] + '</div>\
    </div>\
    \
    <div class="obj_settings">\
    <div class="obj_settings_key"><b>app_webserv_ip</b><br />listening ip address of the front-end web server</div>\
    <div class="obj_settings_value">' + js_obj['app_webserv_ip'] + '</div>\
    </div>\
    \
    <div class="obj_settings">\
    <div class="obj_settings_key"><b>app_webserv_port</b><br />opened socket value of the front-end web server</div>\
    <div class="obj_settings_value">' + js_obj['app_webserv_port'] + '</div>\
    </div>';
    
    $("#app_disp").html(HTML_OUTPUT) ;
    
  }) ;
   
}
