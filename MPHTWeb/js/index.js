function bannerUpdatePackage() {
  
  /*
   * get current default package
   */
  
  // get all the package from server
  var url = '/get_package_all' ; 
  
  // sending get request
  $.get(url, function(data) { 
  
    var js_obj = JSON.parse(data) ;
    
    // current package is the one which is active = true and deploy = true
    js_obj.forEach( function( js_package) {
          
      var package_name = js_package['name'] ;
      var package_active = js_package['active'] ;
      var package_deploy = js_package['deploy'] ;
     
      if( package_active === true && package_deploy === true) {
        console.log(package_name) ;
        $('#app_banner_package').html(package_name);
        
      }
    }) ;
  }) ;
}


function firstLoad() {
  
  /*
   * get the current active host against the server client run 
   */
  
  
  bannerUpdatePackage() ;
  
  
}
  
  
  



function updateNavBarButtonClass(obj) {
  
  var thisElId = obj.id ;
  var activeBgColor = "#ADD8E6" ;
  var inactiveBgColor = "#F0F0F0" ;
  var liList = document.getElementsByTagName("li") ;
  
  for ( var elLi of liList ) {
    
    if ( elLi.id !== "nav_bar_bt_description" ) {
      
      if (elLi.id === thisElId) {
         
        elLi.style.backgroundColor = activeBgColor ;
         
      } else if ( elLi.id !== "nav_bar_soft_ico") {
         
        elLi.style.backgroundColor = inactiveBgColor ;    
      }
    }
  }     
}

function clickButtonCreate(objectId) {
  
  $("#package_import").css("display", "none") ;
  $("#" + objectId).css("display", "block") ;
  
}

function clickButtonImport(objectId) {
  
  $("#package_form").css("display", "none") ;
  $("#" + objectId).css("display", "block") ;
}

function showDetails(objectId) {
  
  var el = document.getElementById(objectId) ;
  
  if (el.style.display === "none" ) {
    
    el.style.display = "block" ;
  } else {
    
    el.style.display = "none" ;
  }
  
}



    

