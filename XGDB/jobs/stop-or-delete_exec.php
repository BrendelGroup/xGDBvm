<?php
// This script sends a 'stop' or 'delete' command. Called by user input on jobs.php or manage.php	
session_start();

### validate form sender or die ###
$post_valid=$_POST['valid']; // if properly set this is a mt_rand() integer; else not set or guessed value
$session_invalid=mt_rand(); 
$session_valid=(isset($_SESSION['valid']))?$_SESSION['valid']:$session_invalid;  // use bogus random # for comparison if no session value
if ($session_valid != $post_valid) // value passed by $_POST should match $_SESSION value; won't match if POST came from another source.
{
    die('Form submission failed validation');
}

### Defaults
	$global_DB1= 'Admin';
	$global_DB2= 'Genomes';
	include('sitedef.php');
 	include_once('/xGDBvm/XGDB/phplib/db.inc.php'); #reads MySQL password from /xGDBvm/admin/dbpass
	include_once('/xGDBvm/XGDB/jobs/jobs_functions.inc.php'); #common functions required in this script

    date_default_timezone_set("$TIMEZONE"); // from sitedef.php

	//Connect to database

	$dbpass=dbpass();
	$db = mysql_connect("localhost", "gdbuser", $dbpass);
	if(!$db)
		{
			echo "Error: Could not connect to database!";
			exit;
		}

	//Get base_url from Admin database

	$auth_query="SELECT uid, auth_url, api_version from $global_DB1.admin where auth_url !='' order by uid DESC limit 0,1";
	$get_auth_record = mysql_query($auth_query);
	$auth=mysql_fetch_array($get_auth_record);
	$base_url=$auth['auth_url'];
	$api_version=$auth['api_version'];

	//Grab the relevent session cookie data and place them into variables
	
	$username=$_SESSION['username'];
	$access_token=$_SESSION['access_token'];

    // get posted values and sanitize
    $action=mysql_real_escape_string($_POST['action']); # kill delete or resubmit
    $return=mysql_real_escape_string($_POST['return']); # for redirect
	$job_id=mysql_real_escape_string($_POST['job']); 
    
    // where do we return to?
    switch ($return) 
		{
	case "jobs":
		$location = "jobs.php";
		break;
	case "manage":
		$location = "manage.php";
		}
    $pattern='/^(\d+)\-([a-z0-9]+\-\d+\-\d+)$/';# Job ID e.g. 3949611174092533275-e0bd34dffff8de6-0001-007
  
    // All requirements met? Proceed with curl 
    if(preg_match($pattern, $job_id) && isset($_SESSION['access_token'])) # second level check
    {
    
        //Create a php curl object
        $ch = curl_init();
        
        //Base url for foundation api for php curl

        //curl -sk -H "Authorization: Bearer de32225c235cf47b9965997270a1496c" -X POST -d "action=kill" https://$API_BASE_URL/jobs/$API_VERSION/$JOB_ID
    
        $job_url="${base_url}/jobs/$api_version/${job_id}"; # e.g. https://agave.iplantc.org/jobs/v2/job/0001424105021858-5056a550b8-0001-007        
        //Set php curl options.
        curl_setopt($ch, CURLOPT_URL,$job_url);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
        curl_setopt($ch, CURLOPT_HTTPHEADER, array( "Content-Type:application/json", "Authorization: Bearer  $access_token"));
        if($action=="stop")
        {
        	$desired_status="STOPPED";
            $job_action = array
			(
			   "action" => "stop",
			);

		// Encode data array as JSON object and strip escaped slashes (none here but leave this in place).	
			$post_string = str_replace("\/", "/", json_encode($job_action));

	        curl_setopt($ch, CURLOPT_POST, true);
	        curl_setopt($ch, CURLOPT_POSTFIELDS, $post_string);
	    }
        elseif($action=="kill")
        {
        	$desired_status="KILLED";
            $job_action = array
			(
			   "action" => "kill",
			);

		// Encode data array as JSON object and strip escaped slashes (none here but leave this in place).	
			$post_string = str_replace("\/", "/", json_encode($job_action));

	        curl_setopt($ch, CURLOPT_POST, true);
	        curl_setopt($ch, CURLOPT_POSTFIELDS, $post_string);
	    }
	    elseif($action=="delete")
	    {
        	$nominal_status="DELETED"; # not part of the API 
	        curl_setopt($ch, CURLOPT_CUSTOMREQUEST, "DELETE");
	    }
        //Execute the php curl and grab the response
        $response = curl_exec($ch);
        $resultStatus = curl_getinfo($ch);
        $http_code=$resultStatus['http_code'];
        $handled_json = json_decode($response,true);
        $status = $handled_json['status']; # success is the good outcome
	    $STATUS = $handled_json['result']['status']; # e.g. "STOPPED"
            if($http_code == 200 || $http_code==201)   //success
            {
            //Turn the response into json which php can manipulate
            //grab the "status" of the job from the json
                $status = $handled_json['status'];
                $timestamp =  date("Y-m-d H:i:s");
                if($action=="stop" || $action=="kill" )
                {
                $job_end_time = $handled_json['result']['endTime'];
                $update_job_status="UPDATE $global_DB1.jobs SET status = '$STATUS', job_end_time='$job_end_time', process_complete_time='$timestamp', last_updated='$timestamp' WHERE job_id = '$job_id' "; # the API should update 'comments' using webhook.php callback.
                }
                elseif($action=="delete")
                {
                $update_job_status="UPDATE $global_DB1.jobs SET status ='$nominal_status', last_updated='$timestamp', comments=CONCAT(comments, ' | DELETED', '$timestamp') WHERE job_id = '$job_id' "; # no webhook so we manually update 'comments'
                }
                $result="job_${action}_accomplished";
                $id="$job_id"; //highlights the row on redirect
                $do_update = mysql_query($update_job_status);
      
            }
            elseif(!isset($STATUS))
            {
                $result="job_${action} did not result in updated STATUS";
                $status="unknown";
                $id="message"; //highlights the message at top of form
            }
            elseif($http_code==401)
            {
                $result="job_${action}_not_authorized";
                $status="unknown";
                $id="message"; //highlights the message at top of form
            }
            elseif($http_code==404)
            {
                $result="requested_resource_not_available";
                $status="unknown";
                $id="message"; //highlights the message at top of form
            }
            else // call failed
            {
               $result="no_response_from_api";
               #$status="unknown";
               $id="message";
            }
            curl_close ($ch);


	 }   
	else // Requirements not met.
	{
		$result="job_id_incorrect_or_no_token";
	}
#header("Location: $location?http_code=$http_code&base_url=$base_url&api_version=$api_version&job_url=$job_url&result=$result&username=$username&action=$action&job_id=$job_id");
header("Location: $location?action=$action&http_code=$http_code&result=$result&#${job_id}");

?>


