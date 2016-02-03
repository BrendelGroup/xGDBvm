<?php
#######  Functions used for user login to remote compute. Called by /xGDBvm/XGDB/jobs/submit.php  and /xGDBvm/XGDB/conf/view.php ########

include('sitedef.php');
date_default_timezone_set("$TIMEZONE"); // from sitedef.php

function login_status($redirect, $username, $http_code, $access_token, $refresh_token, $login_id, $expires) // Invoked on each Web page where OAuth2 login status is displayed and login-dependent html elements are at work. Redirects to log user out if login conditions are not met. Calls other functions on this page.
{
    $redirect_string="";
	if ($access_token != "" && $http_code == "200")// Successful login has already occurred, let's check if it's still valid
	{		
	// Check if the session refresh_token is current:
		$refresh_current = check_refresh_stored($username, $refresh_token); // login_functions.inc.php; True or False; compares session, stored tokens (below)
    // Compute time left (for display) and determine if login is current based on $expired time:
		$now=date("U");
		$seconds_left=$expires-time();
		$time_left=seconds_to_time($seconds_left);//login_functions.inc.php; calculates d-h-m-s from seconds
		$time_left=$time_left['time'];
		$login_current=($expires < $now)?"False":"True";
		
    // Assign appropriate redirect string based on refresh_token (highest priority), login time left:
    
        if($refresh_current == "False")  // Web browser refresh is out of date; create redirect string that will reset all login-related session values
        {
		    $redirect_string ="logout_exec.php?id=$login_id&msg=refresh&redirect=$redirect";
        }
		elseif($login_current == "False") // Login lifespan is ended; create redirect string that will reset access_token and related values (but preserve refresh token)
		{
		    $redirect_string= "logout_exec.php?id=$login_id&msg=expired&redirect=$redirect";
		}  
	} 
	elseif ($refresh_token != "" && $access_token=="")// User is logged out but still has refresh token session variable.
	{
	// If session value of refresh_token is not current, assign redirect string for logout that resets all session values including refresh_token
		$refresh_current = check_refresh_stored($username, $refresh_token); // login_functions.inc.php; compares session, stored tokens (below)
		if($refresh_current == "False")
		{
		    $redirect_string = "logout_exec.php?id=$login_id&msg=refresh&redirect=$redirect";
		}
	}
return array($redirect_string, $time_left, $refresh_current);
}


//This function performs the key and secret retrieval. Currently used by login_exec.php
//curl -sku "$API_USERNAME:$API_PASSWORD" 
// -X POST
// -d "consumer_name=my_cli_app&description=Client app used for scripting up cool stuff"
// https://$API_BASE_URL/clients/$version

function get_keys($username, $password, $auth_url, $name, $description, $callback_url, $version) # under development 12/3/14 see http://agaveapi.co/authentication-token-management/  NOTE: Not sure if Agave has a $proxy_lifetime argument.
{

	$ch = curl_init();
	
	//Set php curl options. 
	$url="${auth_url}/clients/${version}"; # see http://agaveapi.co/client-registration/
	curl_setopt($ch, CURLOPT_URL,$url);
	curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1); 
	curl_setopt($ch, CURLOPT_POST, true);
	$credentials = "${username}:${password}";
	curl_setopt($ch, CURLOPT_USERPWD, $credentials);
    curl_setopt($ch, CURLOPT_HTTPHEADER, array( 'Content-Type:application/x-www-form-urlencoded'));

    $post_params = array(
    "clientName=${name}",
	"description=${description}",
	"tier=UNLIMITED",
	"callbackUrl=${callback_url}"
	);
	
	$post_string = implode('&', $post_params); # use instead of http_build_query
	curl_setopt($ch, CURLOPT_POSTFIELDS, $post_string); 
	
	//Execute the php curl and grab the response 
	$response = curl_exec($ch);                                          
	$resultStatus = curl_getinfo($ch);
	$handled_json = json_decode($response,true);
	$status=$handled_json['status'];
	$message=$handled_json['message'];
	$version_details=$handled_json['version'];
	$consumer_key=$handled_json['result']['consumerKey'];
	$consumer_secret=$handled_json['result']['consumerSecret'];

	if($resultStatus['http_code'] == 200) // success
	{	
		$http_code="200"; // successful login
	}
		else if($resultStatus['http_code'] == 401) //failed login - authorization error
	{
		// login failed 
		$http_code = "401";
	}
		else
	{
		$http_code= '0';//Login Failed (no/bad authorization URL) 
	}
	//Destroy php curl object
	curl_close ($ch);
return array($status, $message, $http_code, $consumer_key, $consumer_secret, $name, $version_details, $url, $response);
}

function validate_keys($consumer_key, $consumer_secret) # Make sure the key hashes are valid format
{
$key_value="${consumer_key}:${consumer_secret}";
   $pattern="/^[A-Za-z0-9\_]+?:[A-Za-z0-9\_]+?$/"; # e.g. hZ_z3f4Hf3CcgvGoMix0aksN4BOD6
   if (preg_match($pattern, $key_value))
      {
        $valid="T";
      }
      else
      {
        $valid="F";
      }
    return $valid;
}

function validate_token($username, $refresh_token) # Make sure the token hash is valid format
{
$key_value="${username}:${refresh_token}";
   $pattern="/^".$username.":[a-z0-9]+?$/";# e.g. jim_jones:z3f4Hf3CcgvGoMix0aksN4BOD6
   if (preg_match($pattern, $key_value))
      {
        $valid="T";
      }
      else
      {
        $valid="F";
      }
    return $valid;
}

function authenticate($username, $password, $consumer_key, $consumer_secret, $auth_url, $username) # Get a token;  see http://agaveapi.co/authentication-token-management/ 
	{
	#  First, create a php curl object to retrieve a token (step 1) using this syntax: (http://agaveapi.co/getting-started-with-the-agave-api/)
    #  curl -sk -X POST \
    #    -d "grant_type=client_credentials&username=nryan@mlb.com&password=<password>&scope=PRODUCTION" \
    #    -u "$CONSUMER_KEY:$CONSUMER_SECRET"  \
    #    -H "Content-Type: application/x-www-form-urlencoded" \
    #     https://agave.iplantc.org/token
    
	$ch = curl_init();
	
	# Next, set php curl options for initial request. 
	$url="${auth_url}/token"; # see http://agaveapi.co/authentication-token-management/ "Authenticating to an API"
	curl_setopt($ch, CURLOPT_URL,$url); #
	curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1); 
	curl_setopt($ch, CURLOPT_POST, true);
	$credentials = "${consumer_key}:${consumer_secret}"; #OK
	curl_setopt($ch, CURLOPT_USERPWD, $credentials); #OK
    curl_setopt($ch, CURLOPT_HTTPHEADER, array( 'Content-Type:application/x-www-form-urlencoded')); #Fixed
    $u_username=urlencode($username);
    $u_password=urlencode($password);
    $post_params = array(
      "grant_type=password",
      "username=${u_username}",
      "password=${u_password}",
      "scope=PRODUCTION"
	); 
    #curl_setopt($ch, CURLOPT_CUSTOMREQUEST, "POST"); # uncomment when debugging headers
	#$post_string = http_build_query($post_params);
    $post_string = implode('&', $post_params); # use instead of http_build_query per Rion Dooley
	curl_setopt($ch, CURLOPT_POSTFIELDS, $post_string);
	
	# Next, execute the php curl and grab the response
	
	$response = curl_exec($ch);                                          
    $resultStatus = curl_getinfo($ch);
    $header_sent = curl_getinfo($ch, CURLINFO_HEADER_OUT );

    # sample response:
    # {
    #   "token_type":"bearer",
    #   "expires_in":3600,
    #   "refresh_token":"b546d976911cd4a0a958e6f762ebcadf",
    #   "access_token":"2c3573cde6f88cf27e8819dc2019"
    # }
	# variables:
	$refresh_token=""; 
	$access_token=""; 
	$expires_in=""; 
	$issued=""; 
	$lifespan="";

    if($resultStatus['http_code'] == 200) // success
		{	
		$http_code="200"; // successful response to token request
		$handled_json = json_decode($response,true);
		
			# Get tokens and etc.
			$access_token=$handled_json['access_token'];
			$refresh_token=$handled_json['refresh_token'];
			$expires_in=$handled_json['expires_in'];
			$time=time();
			$expires=date($time + $expires_in);
			$issued=date($time);
			$lifespan=date($expires_in);
			
		// store the refresh_token (takes precedenced over any session value)
   		 $token_stored=store_refresh_token($username, $refresh_token); // see function below; true or false

		}
		else if($resultStatus['http_code'] == 401) //failed login - authorization error
		{
		$http_code = "401";
		}
		else
		{
		$http_code= $resultStatus['http_code'];//Request Failed (no/bad authorization URL) 
		}
		
        # Now destroy php curl object
	    curl_close ($ch);
	    # DEBUG ONLY (following line):
		# error_log($http_code." ".$url." ".$access_token." ".$refresh_token ." ".$expires." ".$issued." ".$lifespan." ".$header_sent." ".$response); 
	return array($http_code, $url, $access_token, $refresh_token, $expires, $issued, $lifespan, $header_sent, $response);
	}

function refresh($consumer_key, $consumer_secret, $refresh_token, $auth_url, $username) # see http://agaveapi.co/authentication-token-management/  
	{
	# DEBUG ONLY (following line):
	# error_log("refresh function :consumer_key:".$consumer_key." consumer_secret:".$consumer_secret." refresh_token".$refresh_token." username:".$username);
	//Create a php curl object that embodies this curl command:
	# curl -sk -X POST \
	#    -d "grant_type=refresh_token&scope=PRODUCTION&refresh_token=b546d976911cd4a0a958e6f762ebcadf" \
	#    -u "$CONSUMER_KEY:$CONSUMER_SECRET" \
	#    -H "Content-Type: application/x-www-form-urlencoded" \
	#    https://$API_BASE_URL/token
		   
	$ch = curl_init();
	# Next, set php curl options for initial request. 
	$url="${auth_url}/token"; # see http://agaveapi.co/authentication-token-management/ "Authenticating to an API"
	curl_setopt($ch, CURLOPT_URL,$url); #
	curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1); 
	curl_setopt($ch, CURLOPT_POST, true);
	$credentials = "${consumer_key}:${consumer_secret}"; #OK
	curl_setopt($ch, CURLOPT_USERPWD, $credentials); #OK
    curl_setopt($ch, CURLOPT_HTTPHEADER, array( 'Content-Type:application/x-www-form-urlencoded')); #Fixed
    $post_params = array(
      "grant_type=refresh_token",
      "refresh_token=${refresh_token}",
      "scope=PRODUCTION"
	); 
    #curl_setopt($ch, CURLOPT_CUSTOMREQUEST, "POST"); # uncomment when debugging headers
    $post_string = implode('&', $post_params); # use instead of http_build_query per Rion Dooley
	curl_setopt($ch, CURLOPT_POSTFIELDS, $post_string);

	// Getting results
	
	//Execute the php curl and grab the response 
	$response = curl_exec($ch);                                          
	$resultStatus = curl_getinfo($ch);

	$refresh_token=""; 
	$expires_in=""; 
	$issued=""; 
	$lifespan="";

	if($resultStatus['http_code'] == 200) // success
	{	
		$http_code="200"; // successful login
		$handled_json = json_decode($response,true);
	//Get tokens and etc.
	//response_example={ "token_type":"bearer", "expires_in":3600, "refresh_token":"b546d976911cd4a0a958e6f762ebcadf", "access_token":"2c3573cde6f88cf27e8819dc2019"};		
		$access_token=$handled_json['access_token'];
		$refresh_token=$handled_json['refresh_token'];
		$expires_in=$handled_json['expires_in'];
		$time=time();
		$expires=date($time + $expires_in);
		$issued=date($time);
		$lifespan=date($expires_in);
	// IMPORTANT! Store the new refresh_token (it takes precedence over any session value)
		$token_stored=store_refresh_token($username, $refresh_token); // see function below; true or false
		$token_verified=check_refresh_stored($username, $refresh_token);
	}
	else if($resultStatus['http_code'] == 401) //failed login - authorization error
	{
		// login failed - show user/password form again.
		$http_code = "401";
	}
	else
	{
		$http_code= $resultStatus['http_code'];//Request Failed (no/bad authorization URL) 
	}
	//Destroy php curl object
	curl_close ($ch);
	### DEBUG ONLY
	### error_log($http_code." ".$access_token." ".$refresh_token." ".$expires." ".$issued." ".$lifespan." ".$response);
	### error_log("token stored:".$token_stored."; token storage verified: ".$token_verified);
	return array($http_code, $access_token, $refresh_token, $expires, $issued, $lifespan, $response);
}

function get_refresh_token($username) # Get stored value if it exists; else return the session value.
{
    $handle = fopen("/xGDBvm/admin/refresh", "r");
    if($handle)
    {	
        while (($line = fgets($handle)) !== false) 
        {
            $pattern="/^".$username.":([a-z0-9]+?)$/"; # e.g. j_user:a6a3a0a883d9e13b32b09f6b3bd908c
            if(preg_match($pattern, $line, $matches))
            {
                $stored_token=$matches[1];
            }
        }
        fclose($handle);

        if($stored_token != "")
        {
			$refresh_token=$stored_token; //
			$token_stored=true;
		}
		else
		{
			$refresh_token=""; // no matching value
			$token_stored=false;
		}
	}
	else
	{
		$refresh_token=""; // no file 
		$token_stored=false;
	}
return $refresh_token;
}


function store_refresh_token($username, $refresh_token)
{
	$store_refresh_token=`/usr/bin/htpasswd -p -b /xGDBvm/admin/refresh $username $refresh_token`; // add or overwrite this user's entry in the refresh file (it may not have changed if there is already an active login for this user)

	if($store_refresh_token == 0) // success
	{
	  $token_stored=true;
	  $result .="Refresh_token stored successfully in /xGDBvm/admin/refresh. ";
	}
	else
	{
	   $token_stored=false;
	   $result .="ERROR: Could not store refresh_token in /xGDBvm/admin/refresh ";
	}
	## error_log($result);  # Debug only!!!
	
return $token_stored;
}

function check_refresh_stored($username, $refresh_token)  // Checks the stored value of refresh token vs the supplied value.
{
	// Compare parameter passed and stored value for refresh_token
	$handle = fopen("/xGDBvm/admin/refresh", "r");
	if($handle)
	{	
		while (($line = fgets($handle)) !== false) 
		{
			$pattern="/^".$username.":".$refresh_token."$/"; # e.g. j_user:a6a3a0a883d9e13b32b09f6b3bd908c
			if(preg_match($pattern, $line, $matches))
			{
				$stored = "True";
			}
		}
		fclose($handle);
	$stored=($stored=="True")?"True":"False"; // either we found it or we didn't.
	}
	else
	{
		$stored="NA"; // or, we couldn't read the file, so no comparison possible.
	}

return $stored; // true or falsen or no value

}


// Get most recent Authorization URL (if any) from database;

function get_auth_url($global_DB)
	{
	
		$auth_query="SELECT uid, auth_url, auth_update from ${global_DB}.admin where auth_url !='' order by uid DESC limit 0,1";
		$get_auth_record = $auth_query;
		$check_get_auth_record = mysql_query($get_auth_record);
		$auth_result = $check_get_auth_record;
		while($auth=mysql_fetch_array($auth_result))
		{
		$auth_url=$auth['auth_url'];
		return $auth_url;
		}
	}

//Checks for ${prg} URL and other job info in Admin db where ${prg} = GeneSeqer-MPI or GenomeThreader
function get_remote_config($global_DB, $prg) { 

$query="SELECT * from Admin.apps WHERE program='$prg' AND is_default='Y' ";
	$result = mysql_query($query);
	while($row=mysql_fetch_array($result))
	{
	$app_id=$row["app_id"];
	$platform=$row["platform"];
	$max_job_time=$row["max_job_time"];
	$nodes=$row["nodes"];

	return array($platform, $app_id, $max_job_time, $nodes);
	}
}

## Get GTH GSQ app info

$gsq_query="SELECT app_id from Admin.apps WHERE program='GeneSeqer-MPI' AND is_default='Y' ";
$get_gsq = mysql_query($gsq_query);
while ($row = mysql_fetch_array($get_gsq)) {

    $gsq_default=$row["app_id"];
}
$gth_query="SELECT app_id from Admin.apps WHERE program='GenomeThreader' AND is_default='Y' ";
$get_gth = mysql_query($gth_query);
while ($row = mysql_fetch_array($get_gth)) {

    $gth_default=$row["app_id"];
}

$gsq_message=($gsq_default=="")?"<span class=\"warning indent2\">No GSQ App has been configured <a href=\"/XGDB/jobs/apps.php\">(go do it)</a> </span>":"<span class=\"checked indent2\">GSQ App ID:</span>$gsq_default";

$gth_message=($gth_default=="")?"<span class=\"warning indent2\">No GTH App has been configured <a href=\"/XGDB/jobs/apps.php\">(go do it)</a> </span>":"<span class=\"checked indent2\">GTH App ID: </span>$gth_default";


//Convert seconds to readable time. From http://stackoverflow.com/questions/8273804/convert-seconds-into-days-hours-minutes-seconds-in-php

function seconds_to_time($inputSeconds) {
    $secondsInAMinute = 60;
    $secondsInAnHour  = 60 * $secondsInAMinute;
    $secondsInADay    = 24 * $secondsInAnHour;

    // extract days
    $days = floor($inputSeconds / $secondsInADay);

    // extract hours
    $hourSeconds = $inputSeconds % $secondsInADay;
    $hours = floor($hourSeconds / $secondsInAnHour);

    // extract minutes
    $minuteSeconds = $hourSeconds % $secondsInAnHour;
    $minutes = floor($minuteSeconds / $secondsInAMinute);
    
     // extract the remaining seconds
    $remainingSeconds = $minuteSeconds % $secondsInAMinute;
    $seconds = ceil($remainingSeconds);

    // return the final array
    $result = array(
        'h' => (int) $hours,
        'm' => (int) $minutes,
        's' => (int) $seconds,
        'time' => "${hours}h ${minutes}m  ${seconds}s",
    );
    return $result; // an array
}

function get_uuid($query_url) {  # The uuid uniquely identifies a VM.
$ch = curl_init($query_url);
$url = $query_url;  # e.g. http://169.254.169.254/openstack/latest/meta_data.json
curl_setopt($ch, CURLOPT_URL,$url);
curl_setopt($ch, CURLOPT_HTTPHEADER, array( 'Content-Type:application/x-www-form-urlencoded'));
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
$response = curl_exec($ch);
curl_close($ch);
$handled_json = json_decode($response,true);
$uuid=$handled_json['uuid']; # e.g. e1d65480-45ac-49a1-8d66-8a637e277fae

return $uuid; 

}

?>