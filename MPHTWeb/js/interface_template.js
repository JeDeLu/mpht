function templateHTMLList(js_obj) {
  
  // flush html content removing previous output
  $("#app_disp").html('') ;
  
  var i = 0 ;
  var HTML_OUTPUT = '' ;
       
  js_obj.forEach( function( js_template) {
          
    template_name = js_template['name'] ;
    template_realm = js_template['realm'] ;
    template_description = js_template['description'] ;
    template_args_num = js_template['args_number'] ;
    template_args_desc = js_template['args_description'] ;
          
    HTML_OUTPUT = HTML_OUTPUT + '\
    <div id="template_name_'+i+'" onclick="showDetails(\'template_details_'+i+'\');" class="obj_name">\
      <div style="display: block; float: left;"><img src="images/template.png" width="15" height="15" /></div>\
      <div style="display: block; padding-left: 25px;">Name: ' + template_name + '</div>\
    </div> \
    <div id="template_details_'+i+'" class="obj_details">\
    <div class="template_details_value"><b>realm:</b> '+template_realm+'</div>\
    <div class="template_details_value"><b>description:</b> '+template_description+'</div>\
    <div class="template_details_value"><b>arguments number:</b> '+template_args_num+'</div>\
    ' ;
      
    var j = 0 ;
    if ( typeof(template_args_desc === "object") && template_args_desc.length > 0 ) { 
      template_args_desc.forEach(function ( arg_desc) {
      
        HTML_OUTPUT = HTML_OUTPUT + '<div class="template_details_value"><b> arg '+j+' description:</b> '+arg_desc+'</div>' ;
        j += 1 ;
       
      }) ;
    }
      
    HTML_OUTPUT = HTML_OUTPUT + '\
    <div id="obj_details_cmd_'+i+'" class="obj_details_cmd">\
    <div id="obj_attr_entry_'+i+'" class="obj_input" style="display: none ;"><input id="obj_entry_value_'+i+'" size="35" type="text" placeholder="name the copy or rename this template here" /></div>\
    <button id="obj_button_copy_'+i+'" class="obj_details_button" style="display: none ;" onclick="clickTemplateButtonCopy(\''+template_realm+'\', \''+template_name+'\', \''+i+'\') ;">COPY</button>\
    <button id="obj_button_edit_'+i+'" class="obj_details_button" style="display: none ;" onclick="clickTemplateButtonEdit(\''+i+'\') ;">EDIT</button>\
    <button id="obj_button_save_'+i+'" class="obj_details_button" style="display: none ;" onclick="clickTemplateButtonSave(\''+template_realm+'\', \''+template_name+'\', \''+i+'\') ;">SAVE</button>\
    <button id="obj_button_view_'+i+'" class="obj_details_button" onclick="clickTemplateButtonView(\''+template_realm+'\', \''+template_name+'\', \''+i+'\') ;">VIEW</button>\
    </div>\
    <div id="obj_content_view_'+i+'" class="obj_content_view"></div>\
    \
    </div>' ;
    
    i += 1 ;
      
  }) ;
  
  // update html code with new content
  $("#app_disp").html(HTML_OUTPUT) ;
}

function clickTemplateButtonView(realm_name, template_name, displayId) {
  
  var displayBoxId = 'obj_content_view_' + displayId ;
  var objBtnView = 'obj_button_view_' + displayId ;
  var objBtnEdit = 'obj_button_edit_' + displayId ;
  var objBtnSave = 'obj_button_save_' + displayId ;
  var objBtnCopy = 'obj_button_copy_' + displayId ;
  var objBtnInput = 'obj_attr_entry_' + displayId ;
  var displayBoxStatus = $('#' + displayBoxId).css("display") ;
  var url = '/get_template_content?realm_name=' + realm_name + '&template_name=' + template_name ;
  
  if( displayBoxStatus === "none" ) {

    $.get(url, function(data) {
  
      var js_obj = JSON.parse(data) ;
    
      if( js_obj['res_code'] === 1 ) {
      
        var HTML_OUTPUT = '<code>' ;
        js_obj['res_data'].forEach( function(line) {
        
          HTML_OUTPUT = HTML_OUTPUT + line + '<br />' ;
        }) ;
      
        HTML_OUTPUT = HTML_OUTPUT + '</code>' ;
        $('#' + displayBoxId).html(HTML_OUTPUT) ;
        $('#' + displayBoxId).css("display", "block") ;
        $('#' + objBtnView).html('HIDE') ;
        $('#' + objBtnEdit).css("display", "block") ;
        $('#' + objBtnSave).css("display", "block") ;
        $('#' + objBtnCopy).css("display", "block") ;
        $('#' + objBtnInput).css("display", "inline-block") ;
                
      }
    }) ;
  } else if( displayBoxStatus === "block" ) {
    
    $('#' + displayBoxId).html('') ;
    $('#' + displayBoxId).css("display", "none") ;
    $('#' + objBtnView).html('VIEW') ;
    $('#' + objBtnEdit).css("display", "none") ;
    $('#' + objBtnSave).css("display", "none") ;
    $('#' + objBtnCopy).css("display", "none") ;
    $('#' + objBtnInput).css("display", "none") ;
    
  }
}

function clickTemplateButtonList() {
  
   $.get("/get_template_all", function (data) {
        
    var js_obj = JSON.parse(data) ;
    
    // format template list into HTML format
    templateHTMLList(js_obj) ;
        
  }) ;
}

function showTemplates(obj) {
  
  $("#obj_search_btn").bind("click", function clickTemplateButtonSearch() { 
  
    var search_value = document.getElementById("obj_search_field").value ;
    var url = '/get_template_search_value?search_value=' + search_value ;
 
    if( search_value !== '' ) {

      $.get(url, function( data) {
   
      var js_obj = JSON.parse(data) ;
      templateHTMLList(js_obj) ;
      }) ;
    }
  }) ; 
      
  // update the button class after click on it
  updateNavBarButtonClass(obj) ;
  
    var description_field = "<span style=\"font-size: 14px; color: #4f94cd;\">TEMPLATE MANAGEMENT</span><br /><br /><span class=\"description_block\">Helps you to update, create templates.<br />\
    A template is the definition of a scenario, the template skeleton is composed of four section test, backup, restore and update. \
    Every template section is triggered by the scenario the profile runs, ie: a profile running the test scenario will call every jobs of it to trigger the test \
    section of the template is composed of.<br />The template is used to define a job, there is no limitation, \
    the same template can be called by several jobs from the same profile or different profile.<br />.</span>" ;
  
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
  <div class="obj_title_zone">TEMPLATE MANAGEMENT</div> \
  <button class="obj_button_create" onclick="clickButtonCreate(\'template_form\') ;">CREATE</button>\
  <button class="obj_button_list" onclick="clickTemplateButtonList() ;">LIST</button>\
  </div> \
  \
  <div id="template_form" class="obj_form">\
  <div id="template_form_name" class="obj_form_field">Name: <input type="text" id="template_form_name_input"/></div>\
  <div id="template_form_description" class="obj_form_field">Description:<input type="text" id="template_form_description_input"/></div>\
  <div id="template_form_num_args" class="obj_form_field">num args:\
  <select id="template_form_select_num_args" onchage="updateTemplateArgFields() ;">\
  <option value="0" selected>0</option>\
  <option value="1">1</option>\
  <option value="2">2</option>\
  <option value="3">3</option>\
  <option value="4">4</option>\
  <option value="5">5</option>\
  <option value="6">6</option>\
  <option value="7">7</option>\
  <option value="8">8</option>\
  </select>\
  </div>\
  <div id="template_form_args_desc" class="obj_form_field"></div>\
  <div id="send_form_new_job" class="send_form_new_obj">\
  <button class="obj_button_send" onclick="createNewTemplateObj() ;">SEND</button>\
  </div>\
  </div>\
  \
  </div>';
  
  $("#app_interactive").html(HTML_OUTPUT) ;
  
  // update the profiles list 
  clickTemplateButtonList() ; 
}

function clickTemplateButtonEdit(editableId) {
  
  var objEditableContent = 'obj_content_view_' + editableId  ;
  var objBtnEdit = 'obj_button_edit_' + editableId ;
  var buttonValue = $('#' + objBtnEdit).html() ;
  
  if( buttonValue === 'EDIT') {
  
    $('#' + objEditableContent).attr("contentEditable", true) ;
    $('#' + objEditableContent).css("background-color", "#F0F8FF") ;
    $('#' + objBtnEdit).html('READ-ONLY') ;
    
    
  } else if( buttonValue === 'READ-ONLY') {
    
    $('#' + objEditableContent).attr("contentEditable", false) ;
    $('#' + objEditableContent).css("background-color", "#FFF") ;
    $('#' + objBtnEdit).html('EDIT') ;
    
  }
}

function clickTemplateButtonSave(templateRealm, templateName, objectId) {
  
  var textToSend = $('#obj_content_view_' + objectId).html() ; 
  
  // html content treatment to save in file
  // remove balise <code>
  //textToSave = textToSave.replace('<code>', '') ;
  //textToSave = textToSave.replace('</code>', '') ;
  //textToSend = textToSave.replace('<br>', '\n') ;
  //console.log(textToSave) ;
  var url = '/update_template?template_realm=' + templateRealm + '&template_name=' + templateName ;
  
  $.get(url, {"template_data": textToSend},  function(data) {
    
    js_obj = JSON.parse(data) ;
    
  }) ;
}

function clickTemplateButtonCopy(templateRealm, templateName, objectId) {
  
  var inputId = 'obj_entry_value_' + objectId ;
  var template_orig_name = templateName ;
  var template_dest_name = $("#" + inputId).val() ;
  var url = '/copy_template?template_realm=' + templateRealm + '&template_orig_name=' + template_orig_name + '&template_dest_name=' + template_dest_name ;
  
  $.get(url, function( data) {
    
    js_obj = JSON.parse(data) ;
    
  }) ;
}
