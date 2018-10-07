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
  
  // update the profiles list
  $("#app_disp").html('') ;
      
}
