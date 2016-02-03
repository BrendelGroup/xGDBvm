<?php
# This script is renamed and adapted from login.php. It is called by login.php or view.php. Contains updates to the script for agave
session_start();
include_once('/xGDBvm/XGDB/phplib/db.inc.php'); #reads MySQL password from /xGDBvm/admin/dbpass
include_once(dirname(__FILE__).'/login_functions.inc.php');	// for required functions: authenticate()
$global_DB="Admin";
$global_DB2="Genomes";

$dbpass=dbpass();
$db = mysql_connect("localhost", "gdbuser", $dbpass);

$uuid_source_url="http://169.254.169.254/openstack/latest/meta_data.json"; # TODO: put this in sitedef

# Get sitename from /xGDBvm/admin/sitename and use to assign $name for app registration / get keys
$sitename_file='/xGDBvm/admin/sitename';
if(file_exists($sitename_file))
{	
	$file_handle = fopen($sitename_file, "r");
	while (!feof($file_handle))
	{
	   $sitename = fgets($file_handle);
	}
	fclose($file_handle);
$name="xGDBvm-${sitename}";
}
else
{
$name="xGDBvm-unknown";
}
$today=date("Y-m-d h:i:sa");

######## Get posted values ########

if($_POST['action']=="get_keys")  # User wants to obtain secret_id and secret_key 
{
    // get posted values:
    $username=mysql_real_escape_string($_POST['username']);
    $password=mysql_real_escape_string($_POST['password']);
    $auth_url=mysql_real_escape_string($_POST['auth_url']);
    $version=mysql_real_escape_string($_POST['api_version']);
    $redirect=mysql_real_escape_string($_POST['redirect']); //point script back to the page it came from
    ## Test values:
    #$name="xGDBvm";
    $description ="This app is a virtual server for genome annotation, registered on ${today}";
    $callback_url="";
    #$version="v2";
     
    // run 'get_keys' function (login_functions_inc.php) using posted credentials and auth_url:
    $keys= get_keys($username, $password, $auth_url, $name, $description, $callback_url, $version); // sends user/pass (via curl) to auth_url to obtain a consumer_key and consumer_secret, http_code indicates success or not
    //	return array($status, $message, $http_code, $consumer_key, $consumer_secret, $name, $version_details, $url, $header_sent, $response);
    $status=$keys[0];
    $message=$keys[1];
    $http_code=$keys[2]; //200 = success; 401 = bad username/password; 400 Bad Request The request could not be understood by the server due to malformed syntax. 0 = no repsonse (bad URL)
    $consumer_key=$keys[3]; //hash string 
    $consumer_secret=$keys[4]; //hash string 
    $stored_name=$keys[5]; //name spit back by the server, should be same as sent 
    $version_details=$keys[6]; // detailed version
    $url=$keys[7]; // url that was called by cURL.
    $header_sent=$keys[8]; // the header
    $response=$keys[9]; // entire json string
    # DEBUG ONLY - OTHERWISE COMMENT OUT!
    $debug="; message: $message  $response http_code:$http_code key:$consumer_key sec:$consumer_secret name:$stored_name ver:$version_details $username url:$url response:$response";
    # END DEBUG
    
    
    if(validate_keys($consumer_key, $consumer_secret)=="T") # make sure key & value are valid strings, e.g. gTgpCecqtOc6Ao3GmZ_FecVSSV8a
    {
       
       # Add username:key:secret to auth file using htpass (non-encrypted mode)
       $key_secret="${consumer_key}:{$consumer_secret}";
       
       $insert_keys=`/usr/bin/htpasswd -p -b /xGDBvm/admin/auth $username $key_secret`;

       if($insert_keys == 0)
       {
          $result="Keys_Stored&#${username}";
       }
       else
       {
         $result="Keys_Valid_Not_Stored&#${username}"; # Keys were validated but could not be stored. Check auth file at /xGDBvm/admin/auth
       }
    }
    else
    {
      $result="Keys_Not_Valid&#${username}"; # Keys that were returned did not validate.
    }
}
elseif($_POST['action']=="authenticate" ) #user is trying to log in.
{
    $result=""; $id="";
// get posted values:
    $username=mysql_real_escape_string($_POST['username']);
    $password=mysql_real_escape_string($_POST['password']);
    $auth_url=mysql_real_escape_string($_POST['auth_url']);
    $redirect=mysql_real_escape_string($_POST['redirect']); //point script back to the page it came from
    $id=mysql_real_escape_string($_POST['id']); //user has selected GDB or it is set
    
 // get OAuth credentials for this user, VM:
    $handle = fopen("/xGDBvm/admin/auth", "r");
    if($handle)
    {
        while (($line = fgets($handle)) !== false) 
        {
            $pattern="/^".$username.":([A-Za-z0-9\_]+?):([A-Za-z0-9\_]+?)$/"; # e.g. newuser:hZ_z3f4Hf3CcgvGoMix0aksN4BOD6:UH758djfDF8sdmsi004wER
            if(preg_match($pattern, $line, $matches))
            {
                $consumer_key=$matches[1];
                $consumer_secret=$matches[2];
            }
       
        }
        fclose($handle);

        if($consumer_key !="" && $consumer_secret != "")
        {
 // AUTHENTICATE USER: run 'authenticate' function (login_functions.php) using posted credentials and auth_url:
            $auth= authenticate($username, $password, $consumer_key, $consumer_secret, $auth_url, $username); //AUTHENTICATE (login_functions.inc.php): sends user/pass (via curl) to auth_url to obtain a token and expiration time, http_code indicates success or not

 // return array($http_code, $url, $access_token, $refresh_token, $expires, $issued, $lifespan, $header_sent, $response);
            $http_code=$auth[0]; //200 = success; 400=malformed request;  401 = bad username/password 0 = no repsonse (bad URL)
            $url=$auth[1]; //the base (auth) url plus version number.
            $access_token=$auth[2]; //hash string giving user authorization to access remote HPC for limited span
            $refresh_token=$auth[3]; //hash string giving user authorization to extend token life span
            $expires=$auth[4]; // Unix date of expiry (seconds)
            $issued=$auth[5]; // Unix date of issue (seconds)
            $lifespan=$auth[6]; // life span in seconds
            $header_sent=$auth[7]; // the headers
            $response=$auth[8]; // json response
            # DEBUG ONLY!! OTHERWISE COMMENT OUT
            #$debug="; http_code:$http_code url: $url consumer_key:$consumer_key consumer_secret: $consumer_secret token:$access_token refresh:$refresh_token exp:$expires iss:$issued life:$lifespan ";
      
 // assign $_SESSION cookies based on 'authenticate'  
        
            $_SESSION['username']=$username; // from post
            $_SESSION['http_code']=$http_code;
            $_SESSION['access_token']=$access_token;
            $_SESSION['refresh_token']=$refresh_token; # QUESTION: should this be databased?
            $_SESSION['expires']=$expires; 
            $_SESSION['issued'] = $issued;
            $_SESSION['lifespan']=$lifespan; 
            $_SESSION['auth_url']=$auth_url; 
        
            $_SESSION['login_id']=$id; //use this to remember which GDB was actively logged in to. Go to this one if token expires
            $result="user_authenticated_expires_${expires}&#authenticate";
        }
        else
        {
            $debug="user $username; key $consumer_key; secret: $consumer_secret";
            $result="keys_missing&#authenticate";
        }
    }
    else
    {
        $result.="Could not open auth file";
    }
}
elseif($_REQUEST['action']=="refresh" ) #user is trying to extend token lifespan. 
{

// get session variables to use in next step

    $username=$_SESSION['username'];
    $refresh_token=$_SESSION['refresh_token'];
    
// Next few lines: If there is a stored value for refresh_token and pipeline is running, use that.


// get additional posted values:
    $id=isset($_POST['id'])?intval($_POST['id']):""; //user has selected GDB or it is set
    
// get session values
    $username=$_SESSION['username'];
    $redirect=isset($_REQUEST['redirect'])?$_REQUEST['redirect']:"index"; //get or post; point script back to the page it came from
    $auth_url=$_SESSION['auth_url'];

// get OAuth credentials for this user and VM
    $handle = fopen("/xGDBvm/admin/auth", "r");
    if($handle)
    {
        while (($line = fgets($handle)) !== false) 
        {
            $pattern="/^".$username.":([A-Za-z0-9\_]+?):([A-Za-z0-9\_]+?)$/"; # e.g. newuser:hZ_z3f4Hf3CcgvGoMix0aksN4BOD6:UH758djfDF8sdmsi004wER
            if(preg_match($pattern, $line, $matches))
            {
                $consumer_key=$matches[1];
                $consumer_secret=$matches[2];
            }
        }
        fclose($handle);

        if($consumer_key !="" && $consumer_secret != "")
        {    
			$auth= refresh($consumer_key, $consumer_secret, $refresh_token, $auth_url, $username); //(login_functions.inc.php)  function refresh($consumer_key, $consumer_secret, $refresh_token, $auth_url) 

// return array($http_code, $access_token, $refresh_token, $expires, $issued, $lifespan); 
			$http_code=$auth[0]; //200 = success; 400=malformed request;  401 = bad username/password 0 = no repsonse (bad URL)
			$access_token=$auth[1]; //hash string giving user authorization to access remote HPC for limited span
			$refresh_token=$auth[2]; //hash string giving user authorization to extend token life span
			$expires=$auth[3]; // Unix date of expiry (seconds)
			$issued=$auth[4]; // Unix date of issue (seconds)
			$lifespan=$auth[5]; // life span in seconds
			$response=$auth[6]; // the whole response
			#$debug="; http_code:$http_code url: $url token:$access_token refresh:$refresh_token exp:$expires iss:$issued life:$lifespan ";
			#error_log("Refresh request; http_code=".$http_code." response=".$response); // debug
			if($http_code=="200")
			{   
				// assign $_SESSION  variables
				$_SESSION['http_code']=$http_code;
				$_SESSION['access_token']=$access_token;
				$_SESSION['refresh_token']=$refresh_token; 
				$_SESSION['expires']=$expires; 
				$_SESSION['issued'] = $issued;
				$_SESSION['lifespan']=$lifespan;
				$result="token_refreshed_expires_${expires}&#refresh";
			}
			else
			{
            	$result="error_${http_code}&#refresh";
				$_SESSION['refresh_token']="";  // reset refresh_token session value; user will have to log in from scratch
				$_SESSION['http_code']=$http_code; // debug
			}
         }
         else
         {
            $debug="user $username; key $consumer_key; secret: $consumer_secret";
            $result="OAuth keys missing&#refresh";
         }
    }
    else
    {
        $result.="Could not open auth file";
	}
    
}
else
{
   $result="error";
}
//build header based on ID and result.
#$name=($redirect=="configure")?"configure":(($redirect=="process")?"process":"index");
#$name=($redirect=="configure")?"configure.php":(($redirect=="process")?"process.php":(($redirect=="GDB")?"/XGDB/conf/view.php?id=$id/":(($redirect=="index")?"index":"index.php"));

    $name="index.php?"; //default
    
    switch ($redirect) 
    {
case "login":
    $name = "login.php?";
    break;
case "submit":
    $name = "submit.php?id=$id&amp;";
    break;
case "jobs":
    $name = "jobs.php?";
    break;
case "GDB":
    $name = "/XGDB/conf/view.php?";
    break; 
case "index":
    $name = "index.php?";
    break; 
case "manage":
    $name = "manage.php?";
    break; 
case "view":
    $name = "../conf/view.php?id=$id&amp;";
    }

$action=mysql_real_escape_string($_POST['action']);

header("Location: ${name}action=$action&amp;result=$result");
exit;
?>
