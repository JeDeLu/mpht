// Format a list of JSON object into HTML
function profileHTMLList(js_obj) {
  
  var HTML_OUTPUT = '' ;
    
  // start the container of the profile list div
  HTML_OUTPUT = HTML_OUTPUT + '<div id="profile_list_container" class="profile_list_container">' ;
    
  var i = 0 ;
  console.log(js_obj.length) ;
  console.log(js_obj) ;
  js_obj.forEach( function(profile) {
    
    var profile_name = profile['profile_name'] ;
      
    HTML_OUTPUT = HTML_OUTPUT + '\
    <div id="profile_name_'+i+'" onclick="showDetails(\'profile_details_'+i+'\') ;" class="obj_name">\
      <div style="display: block; float: left;"><img src="images/profile.png" width="15" height="15" /></div>\
      <div style="display: block; padding-left: 25px;">Name: ' + profile_name + '</div>\
    </div>\
    \
    <div id="profile_details_'+i+'" class="obj_details">\
    <button id="profile_btn_test_'+i+'" class="obj_button_remove" onclick="mpht_run(\'test\', \''+profile_name+'\', \''+i+'\') ;">TEST</button>\
    <button id="profile_btn_update_'+i+'" class="obj_button_remove" onclick="mpht_run(\'update\', \''+profile_name+'\', \''+i+'\') ;">UPDATE</button>\
    <button id="profile_btn_backup_'+i+'" class="obj_button_remove" onclick="mpht_run(\'backup\', \''+profile_name+'\', \''+i+'\') ;">BACKUP</button>\
    <button id="profile_btn_remove_'+i+'" class="obj_button_remove" onclick="deleteExistingProfile(\''+profile_name+'\') ;">REMOVE</button>\
    <div id="obj_disp_run_'+i+'" class="obj_disp_run"></div>\
    </div>';
      
    i += 1 ;
  }) ;
      
  // end the container of the profile list div
  HTML_OUTPUT = HTML_OUTPUT + '</div>' ;
  
  // update the app_disp zone with new html content
  $("#app_disp").html(HTML_OUTPUT) ;
  //$("#app_disp").css("overflow", "scroll") ;
  
}

function showProfiles(obj) {

  // update the button class after click on it
  updateNavBarButtonClass(obj) ;
  
  var description_field = "<span style=\"font-size: 14px; color: #4f94cd;\">PROFILE MANAGEMENT</span><br /><br /><span class=\"description_block\">\
    Helps you to create/remove and run a Profile.<br /> \
    You can list all the profile or search for a profile using full or partial Profile name using the search field. You can run a Profile using the Profile \
    submenu, remember that running a Profile will run all the JOBs that are assigned to it. Be precautious running the correct profile on the correct machine.</span>" ;
   
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
  <div class="obj_title_zone">PROFILE MANAGEMENT</div> \
  <button class="obj_button_create" onclick="clickButtonCreate(\'profile_form\') ;">CREATE</button>\
  <button class="obj_button_list" onclick="clickProfileButtonList() ;">LIST</button>\
  </div> \
  \
  <div id="profile_form" class="obj_form">\
  <div id="profile_form_name" class="obj_form_field">Name: <input type="text" id="profile_form_name_input"/></div>\
  <div id="send_form_new_job" class="send_form_new_obj">\
  <button class="obj_button_send" onclick="createNewProfileObj() ;">SEND</button>\
  </div>\
  </div>\
  \
  </div>\
  \
  <div id="obj_search_zone" class="obj_search_zone">\
  <input type="text" size="75" id="obj_search_field" class="obj_search_field" placeholder="search a profile by name" />\
  <button id="obj_search_button" class="obj_button_search" onclick="clickProfileButtonSearch() ;">SEARCH</button>\
  </div>';
  
  $("#app_interactive").html(HTML_OUTPUT) ;
  
  // update the profiles list
  $("#app_disp").html('') ;

}


function clickProfileButtonSearch() {
  
  var search_value = document.getElementById("obj_search_field").value ;
  
  if ( search_value !== '' ) {
    
    var url = '/get_profile_search_value?value=' + search_value ;
    
    $.get(url, function(data) {
      
      var js_obj = JSON.parse(data) ;
      console.log(js_obj) ;
      profileHTMLList(js_obj) ;
      
    }) ;
  }
}

function clickProfileButtonList() {
  
  $.get("/get_profile_all", function(data) {
    
    js_obj = JSON.parse(data) ;
    
    // display the full list of profile
    profileHTMLList(js_obj) ;

	});
  
}

function mpht_run(method, profile_name, objectId) {
  
  // disable all button once one have been clicked
  $('#profile_btn_test_'+objectId).prop('disabled', true) ;
  $('#profile_btn_update_'+objectId).prop('disabled', true) ;
  $('#profile_btn_backup_'+objectId).prop('disabled', true) ;
  $('#profile_btn_remove_'+objectId).prop('disabled', true) ;
  $('#profile_btn_default_'+objectId).prop('disabled', true) ;
  
  // define some variable
  var url = '/mpht_run?method=' + method + '&profile_name=' + profile_name ;
  var profile_disp_id = 'obj_disp_run_' + objectId ;
  $('#' + profile_disp_id).html('<span style="font-size: 12px; text-decoration-line: blink;"> run method ' + method + ' of the the profile: ' + profile_name + ' please wait ... </span>') ;
  $('#' + profile_disp_id).css("display", "block") ;
  

  $.get(url, function(data) {
    
    js_obj = JSON.parse(data) ;
    
    HTML_OUTPUT = '<code>' ;
    
    js_obj['run_output'].forEach( function(line) {
      HTML_OUTPUT = HTML_OUTPUT + line + '<br />' ;
    }) ;
    
    HTML_OUTPUT = HTML_OUTPUT + '</code>' ;
    $('#' + profile_disp_id).html(HTML_OUTPUT) ;
    
    // enable all button once the run is finished
    $('#profile_btn_test_'+objectId).prop('disabled', false) ;
    $('#profile_btn_update_'+objectId).prop('disabled', false) ;
    $('#profile_btn_backup_'+objectId).prop('disabled', false) ;
    $('#profile_btn_remove_'+objectId).prop('disabled', false) ;
    $('#profile_btn_default_'+objectId).prop('disabled', false) ;
    
  }) ; 
}

function deleteExistingProfile(profile_name) {
  
  var url = '/delete_existing_profile?name=' + profile_name ;
  console.log(url) ;
  $.get(url, function(data) {
    
    var js_obj = JSON.parse(data) ;
    
    js_obj.forEach( function(response) {
      
      var resCode = response['res_code'] ;
      var resDescription = response['res_description'] ;
      
      if ( resCode === 1 ) {
        
        // reload the jobs list
        clickProfileButtonList() ;
        
      }
      
    }) ;
    
  }) ;
  
}

function createNewProfileObj() {
  
  var el = document.getElementById('profile_form_name_input') ;
  var formValue = el.value ;
  var url = "/create_new_profile?name="+formValue ;
  $.get(url, function(data) {
    
    var js_obj = JSON.parse(data) ;
    
    js_obj.forEach( function(response) {
      
      var resCode = response['res_code'] ;
      var resDescription = response['res_description'] ;
      
      if ( resCode === 1 ) {
        
        // reload the jobs list
        clickProfileButtonList() ;
        
      }
      
    }) ;
    
  }) ; 
  
}
