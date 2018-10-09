
const http = require('http') ;
const fs = require('fs') ;
const url = require('url') ;
const querystring = require('querystring') ;
const profile = require('./js/modules.d/profile') ;
const package = require('./js/modules.d/package') ;
const job = require('./js/modules.d/job') ;
const template = require('./js/modules.d/template') ;
const path = require('path') ;
const addr = '0.0.0.0' ;
const port = '1112' ;
const serverRoot = '/root/AMDOCS/MPHTWeb/' ;

const HTTPserver = http.createServer( ( req, res ) => {

	/* first of all we refuse everything which is not GET*/
	if ( req.method === "GET" ) {
		
		/* 
		 * DEFINE WEB HTTP RESPONSE 
		 */
    
    // DEFAULT SERVER RESPONSE HEADER
    res.statusCode = 200 ;
    res.setHeader( 'Content-Type', 'Application/JSON') ;
    
    /*
     * URL REGEXP catcher 
     */
    
    urlData = url.parse( req.url, true) ;
    
    // JOB REGEXP DEFINITION 
    var getJobSearchRe = /^\/get_job_search_value\?value=\w{1,}/ ;
    
    /*
     * PACKAGE REGEXP DEFINITION 
     */ 
    var getPackageAllRe = /^\/get_package_all$/ ;
    var activatePackageRe = /^\/activate_package\?package_name=[\w\.\-]{1,}/ ;
    var createPackageRe = /^\/create_package\?package_name=[\w\-\.]{1,}/ ;
    var deployPackageRe = /^\/deploy_package\?package_name=[\w\.\-]{1,}/ ;
    var removePackageRe = /^\/remove_package\?package_name=[\w\.\-]{1,}/ ;
    var undeployPackageRe = /^\/undeploy_package\?package_name=[\w\.\-]{1,}/ ;
    
    // PACKAGE REGEXP catching value from URL 
    var packageNameRe = /\?package_name=[\w\-\.]{1,}/ ;
    
    // PROFILE REGEXP DEFINITION
    var getProfileAllRe = /^\/get_profile_all$/ ;
    var createProfileRe = /^\/create_new_profile\?name=\w{1,}/ ;
    var deleteProfileRe = /^\/delete_existing_profile\?name=\w{1,}/ ;
    var getProfileSearchRe = /^\/get_profile_search_value\?value=\w{1,}/ ;
    
    var mphtRunRe = /^\/mpht_run\?method=\w{1,}&profile_name=\w{1,}/ ;
    
    // IMAGE REGEXP DEFINITION
    var imgPNGRe = /[\w/]{1,}\.png/ ;
    var imgJPEGRe = /[\w/]{1,}\.jpeg/ ;
    
    
    /*
     * 
     * URL GET DATA CATCHER
     */
    // PACKAGE GET DATA REGEXP
    var packageNameRe = /\?package_name=[\w\.\-]{1,}/ ;
    
    
    
    console.log(req.url) ;
    if( urlData['pathname'] === '/get_template_realm') {

      template.list_all_realm_object( function( HTTPResponse) {
        
        res.write( JSON.stringify(HTTPResponse)) ;
        res.end() ;
        
      }) ; 
      
    } else if( urlData['pathname'] === '/get_template_name_by_realm' ) {
      
      var realmName = urlData['query']['realm_name'] ;
      
      template.list_by_realm_object(name, function( HTTPResponse) {
        
        res.write( JSON.stringify(HTTPResponse)) ;
        res.end() ;
        
      }) ; 
      
    } else if( urlData['pathname'] === '/get_template_obj') {
      
      realmName = urlData['query']['realm_name'] ;
      templateName = urlData['query']['template_name'] ;
      
      template.list_object_by_template_object(realmName, templateName, function( HTTPResponse) {
        
        res.write( JSON.stringify(HTTPResponse)) ;
        res.end() ;
        
      }) ;
      
    } else if ( urlData['pathname'] === '/get_template_content') {
      
      var realmName = urlData['query']['realm_name'] ;
      var templateName = urlData['query']['template_name'] ;
      
      template.disp_content_by_template(realmName, templateName, function( HTTPResponse) {
        
        res.write(JSON.stringify(HTTPResponse)) ;
        res.end() ;
         
      }) ;
      
    } else if( deleteProfileRe.test(req.url)) {
      
      nameRe = /\?name=\w{1,}/ ;
      name = req.url.match(nameRe)[0].split('=')[1] ;
      
      profile.profile_remove(name, function( HTTPResponse) {
        
        res.write( JSON.stringify(HTTPResponse)) ;
        res.end() ;
        
      }) ;
      
    } else if( createProfileRe.test(req.url)) {
    
      nameRe = /\?name=\w{1,}/ ;
      name = req.url.match(nameRe)[0].split('=')[1] ;
      
      profile.profile_create_new(name, function( HTTPResponse) {
        
        res.write(JSON.stringify(HTTPResponse)) ;
        res.end() ;
        
      }) ;
     
    } else if (getProfileAllRe.test(req.url)) {
      
      profile.profile_list_all_obj( function( HTTPResponse) {
        
        res.write(JSON.stringify(HTTPResponse)) ;
        res.end() ;
        
      }) ;
      
    } else if( getProfileSearchRe.test(req.url)) {
    
      var profileNameRe = /value=\w{1,}/ ;
      var profile_name = req.url.match(profileNameRe)[0].split('=')[1] ;
      
      profile.profile_list_all_obj_by_value(profile_name, function( HTTPResponse) {
        
        res.write(JSON.stringify(HTTPResponse)) ;
        res.end() ;
        
      }) ;      
    
    } else if( activatePackageRe.test(req.url)) {
      
      var package_name = req.url.match(packageNameRe)[0].split('=')[1] ;
      
      package.package_activate( package_name, function( HTTPResponse) {
      
         res.write( JSON.stringify(HTTPResponse)) ;
         res.end() ;
        
      }) ;
    
    } else if( createPackageRe.test(req.url)) {
    
      var package_name = req.url.match(packageNameRe)[0].split('=')[1] ;
      
      package.package_create( package_name, function(HTTPResponse) {
        
        res.write( JSON.stringify(HTTPResponse)) ;
        res.end() ;
        
      }) ;

    } else if( deployPackageRe.test(req.url)) {
    
      var package_name = req.url.match(packageNameRe)[0].split('=')[1] ;
      package.package_deploy(package_name, function( HTTPResponse) {
        
        res.write( JSON.stringify( HTTPResponse)) ;
        res.end() ;
        
      }) ;
    
    } else if( getPackageAllRe.test(req.url)) {
      
      package.package_get_all_obj( function( HTTPResponse) {
      
        res.write( JSON.stringify( HTTPResponse)) ;
        res.end() ;
        
      }) ;
    
    } else if( undeployPackageRe.test(req.url)) {
      
      var package_name = req.url.match(packageNameRe)[0].split('=')[1] ;
      
      package.package_undeploy( package_name, function( HTTPResponse) {
      
         res.write( JSON.stringify(HTTPResponse)) ;
         res.end() ;
        
      }) ;
      
    } else if( removePackageRe.test(req.url)) {
      
      var package_name = req.url.match(packageNameRe)[0].split('=')[1] ;
      
      package.package_remove( package_name, function( HTTPResponse) {
      
         res.write( JSON.stringify(HTTPResponse)) ;
         res.end() ;
        
      }) ;
      
    } else if( urlData['pathname'] === '/create_job' ) { 
      
      var jobName = urlData['query']['job_name'] ;
      var profileName = urlData['query']['profile_name'] ;
      var activeName = urlData['query']['active'] ;
      var realmName = urlData['query']['template_realm'] ;
      var templateName = urlData['query']['template_name'] ;
      var argsName = urlData['query']['template_args'] ;
    
      job.job_create_new( profileName, jobName, activeName, realmName, templateName, argsName, function( HTTPResponse) {
        
        res.write(JSON.stringify(HTTPResponse)) ;
        res.end() ;
      
      }) ;
      
    } else if ( urlData['pathname'] === '/remove_job') {
      
      var jobName = urlData['query']['job_name'] ;
      var profileName = urlData['query']['profile_name'] ;
      
      job.job_remove(profileName, jobName, function( HTTPResponse) { 
      
        res.write( JSON.stringify(HTTPResponse) ) ;
        res.end() ;
      
      }) ;
    
    } else if ( getJobSearchRe.test(req.url) ) { 
    
      valueRe = /\?value=\w{1,}/ ;
      value = req.url.match(valueRe)[0].split('=')[1] ;
      
      job.job_list_all_obj_by_value(value, function( HTTPResponse) {
        
        res.write( JSON.stringify(HTTPResponse) ) ;
        res.end() ;
        
      }) ;
      
    } else if ( urlData['pathname'] === '/get_job_all') {
      
      job.job_list_all_object( function ( HTTPResponse) {
        
        res.write(JSON.stringify(HTTPResponse)) ;
        res.end() ;
      
      }) ;

    } else if ( urlData['pathname'] === '/get_template_all') {
    
      template.list_all_object( function( HTTPResponse) {
        
        res.write(JSON.stringify(HTTPResponse)) ;
        res.end() ;
      
      }) ;
      
    } else if ( urlData['pathname'] === '/get_template_search_value') {
      
      var searchValue = urlData['query']['search_value'] ;
      
      template.template_list_all_obj_by_value( searchValue, function( HTTPResponse) {
        
        res.write( JSON.stringify(HTTPResponse)) ;
        res.end() ;
        
      }) ;
      
    } else if ( urlData['pathname'] === '/update_template') {
      
      var template_realm = urlData['query']['template_realm'] ;
      var template_name = urlData['query']['template_name'] ;
      var template_data = urlData['query']['template_data'] ;
      
      
      template.template_update_file(template_realm, template_name, template_data, function( HTTPResponse) {
        
        res.write(JSON.stringify( HTTPResponse)) ;
        res.end() ;
        
      }) ;
    
    } else if ( mphtRunRe.test(req.url)) {
      
      var methodRe = /\?method=\w{1,}/ ;
      var profileNameRe = /&profile_name=\w{1,}/ ;
      var method = req.url.match(methodRe)[0].split("=")[1] ;
      var profileName = req.url.match(profileNameRe)[0].split("=")[1] ;
    
      profile.mpht_run(method, profileName, function( HTTPResponse) {
        
        res.write( JSON.stringify(HTTPResponse)) ;
        res.end() ;
        
      }) ;
      
    } else if ( imgPNGRe.test(req.url)) {
      
      res.statusCode = 200 ;
      res.setHeader = ('Content-Type', 'image/png') ;
      
      
      fs.readFile('images/' + req.url.split('/')[2], function(err, data) {
        
        res.write(data, 'binary') ;
        res.end() ;
        
      }) ;
      
      
		/* handle any other file requested from the client */
		} else {

      /* handle the webroot directory and return the index */
      if ( req.url === "/" ) {
		
        HTMLpage = path.join( serverRoot, 'index.html' ) ;

      } else {

        HTMLpage = path.join( serverRoot, req.url ) ;

      }

      console.log(HTMLpage) ;

      /* handle the file extension to define the content-type */
      var fileExt = path.extname(HTMLpage) ;
		
      /* default setting the content-type is set to html */
      res.setHeader('Content-Type', 'text/html') ;

      if ( fileExt === '.html' ) {

        res.setHeader( 'Content-Type', 'text/html' ) ;

      } else if ( fileExt === '.js' ) {

        res.setHeader( 'Content-Type', 'application/javascript' ) ;

      } else if ( fileExt === '.css' ) {

        res.setHeader( 'Content-Type', 'text/stylesheet' ) ;

      } else {

        HTMLpage = path.join( serverRoot, 'err/unsupportedExt.html' ) ;

      } 


      /* read the content of file requested by the browser */
      fs.readFile( HTMLpage, (err, data) => {

        if (err) {

          res.statusCode = 404 ;
          
          /* ****** DISPLAY ERROR 404 MESSAGE ****** */
          /* open the 404 error page and stream the content */
          HTMLpage = path.join(serverRoot, 'err/404.html') ;
          fs.readFile( HTMLpage, (err, data) => {

            res.write(data) ;
            res.end() ;

          }) ;

        } else {

          res.statusCode = 200 ;
          res.write(data) ;
          res.end() ;
        }

      }) ;

    }

  }

}) ;

HTTPserver.listen({host: addr, port: port}, () => {console.log('started on addr: '+addr+' and port '+port+' !!!')}) ;