<?php // this script queries job status when launched by another script, updates Admin.jobs, and returns to the initiating script page.
error_reporting(E_ALL & ~E_NOTICE); //disable undeclared variable error

# Start the php session to be able to pull login and password tokens
session_start();

$post_valid=$_POST['valid']; // if properly set this is a mt_rand() integer; else not set or guessed value
$session_invalid=mt_rand(); 
$session_valid=(isset($_SESSION['valid']))?$_SESSION['valid']:$session_invalid;  // use bogus random # for comparison if no session value
if ($session_valid != $post_valid) // value passed by $_POST should match $_SESSION value; won't match if POST came from another source.
{
    die('Form submission failed validation');
}

$global_DB= 'Admin';
include('sitedef.php');
include_once('/xGDBvm/XGDB/phplib/db.inc.php'); #reads MySQL password from /xGDBvm/admin/dbpass
$statement="";
$dbpass=dbpass();
$db = mysql_connect("localhost", "gdbuser", $dbpass);
if(!$db)
{
	echo "Error: Could not connect to database!";
	exit;
}

date_default_timezone_set("$TIMEZONE"); // from sitedef.php

    
# Get username, action, return URL and job number 
    $username=isset($_SESSION['username'])?$_SESSION['username']:""; // username for login to authenticate
    $job_id=mysql_real_escape_string($_REQUEST['job']); # job_id, e.g.  0001424105021858-5056a550b8-0001-007 
    $action=mysql_real_escape_string($_REQUEST['action']);  
    $return=mysql_real_escape_string($_REQUEST['return']);
    $return_page=($return=="jobs")?"jobs.agave.php":(($return=="manage")?"manage.agave.php":"index.agave.php");
    
## Get  Base URL, version from Admin database;

	$auth_query="SELECT auth_url, api_version from $global_DB.admin where auth_url !='' order by uid DESC limit 0,1";
	$auth_result = mysql_query($auth_query);
	$auth=mysql_fetch_array($auth_result);
	$base_url=$auth['auth_url'];
	$api_version=$auth['api_version'];

    $access_token=$_SESSION['access_token']; #  TODO: Check VM-stored version of session


    if($action=="update")
    {
        # Grab the relevent session cookie data and place them into variables

        if(isset($_SESSION['access_token']))
        {    
            # Create a php curl object
            # curl -sk -H "Authorization: Bearer de32225c235cf47b9965997270a1496c" https://$API_BASE_URL/jobs/$API_VERSION (returns list of abbreviated job descriptions)
            # curl -sk -H "Authorization: Bearer de32225c235cf47b9965997270a1496c" https://$API_BASE_URL/jobs/$API_VERSION/$JOB_ID (returns full description of this job
            # curl -sk -H "Authorization: Bearer de32225c235cf47b9965997270a1496c" https://$API_BASE_URL/jobs/$API_VERSION/$JOB_ID/status (brief: job_id, status)
            $ch = curl_init();

            # Base url for foundation api for php curl
            $job_url = "${base_url}/jobs/$api_version/$job_id/status";
            # Set php curl options.
            curl_setopt($ch, CURLOPT_URL,$job_url);
            curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
            curl_setopt($ch, CURLOPT_HTTPHEADER, array( "Content-Type:application/json", "Authorization: Bearer  $access_token"));

            # Execute the php curl and grab the response
            $response = curl_exec($ch);
            $resultStatus = curl_getinfo($ch);

            # Turn the response into json which php can manipulate
            $handled_json = json_decode($response,true);

            # grab the "status" of the job from the json
            $status = $handled_json['result']['status'];
            $http_code=$resultStatus['http_code'];
            # If the php curl was successful, update the jobs table and set result for url
            if($http_code == 200 || $http_code==201) 
            {
                $time=date("Y-m-d H:i:s"); //
                $job_end_time=$handled_json['result']['endTime'];
                $statement = "UPDATE $global_DB.jobs SET status='$status', last_updated='$time', job_end_time='$job_end_time' WHERE job_id = '$job_id'"; // unlikely to update incorrect record
                if($do_statement = mysql_query($statement))
                {
                $result="job_status_updated";
                $row_id="$job_id"; //highlights the row
                }
                else
                {
                $result="job_status_update_failed";
                $status="unknown";
                $id="message"; //highlights the message at top of form
                }
                #debug		echo "<h2>Job $id is $status</h2><br />";
            }
            elseif($http_code==401)
            {
                $result="change_status_not_authorized";
                $status="unknown";
                $id="message"; //highlights the message at top of form
            }
            else // call failed
            {
               $result="no_response_from_api";
               $status="unknown";
               $highlight="message";
               #debug		echo 'Call Failed '.print_r($resultStatus);
               #debug		echo "$response";
            }
            curl_close ($ch);
        }
        else
        {
            $result="user_not_logged_in";
            $status="unknown";
            $id="message";
        }
    header("Location: $return_page?result=${http_code}&amp;job=${job_id}#${row_id}"); // report status and highlight status table cell which should now be updated
    }
    elseif($action=="matches")
    {
        $query = "Select job_id, seq_type, program from $global_DB.jobs WHERE job_id = '$job_id'"; //
        $query_result= mysql_query($query);
        $array=mysql_fetch_assoc($query_result);
        $job_id=$array['job_id'];
        $seq_type=$array['seq_type'];
        $PROGRAM=$array['program'];
        $program=strtolower($PROGRAM); // e.g. gsq, gth
        $extra_dir=($program=="gsq")?"GSQOUTPUT/":"";
        $path="/xGDBvm/input/archive/jobs/job-${job_id}/${extra_dir}*${seq_type}.${program}";
        $match=`grep -c "MATCH" $path`;
        $match=preg_replace( "/\r|\n/", "", $match );
    #    $match="123456";
        if (is_numeric($match))
        { // either 0 or greater
            $statement = "UPDATE $global_DB.jobs SET outcome='$match' WHERE job_id = '$job_id'"; // unlikely to update incorrect record
            if($do_statement = mysql_query($statement))
            {
            $result="match_updated_${path}";
            }
            else
            {
            $result="match_update_failed";
            }
        }
        else // file must be missing
        {
            $statement = "UPDATE $global_DB.jobs SET outcome='0', comments= CONCAT(comments, ' | ERROR: no output file') WHERE job_id = '$job_id'"; // unlikely to update incorrect record
            if($do_statement = mysql_query($statement))
            {
                $result="no_output_${path}";
            }
            else
            {
                $result="no_output_update_failed";
            }
        }
        header("Location: $return_page?result=${result}&amp;job=${job_id}&amp;#${job_id}"); // report status and highlight status table cell which should now be updated
    }
    elseif($action=="kill")
    {
        if(isset($_SESSION['access_token']))
        {    
            // Create a php curl object
             $ch = curl_init();

            // Base url for Agave api for php curl
            $job_url = "${base_url}/jobs/$api_version/$job_id";
            
            //Set php curl options.
            curl_setopt($ch, CURLOPT_URL,$job_url);
            curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
            curl_setopt($ch, CURLOPT_HTTPHEADER, array("Authorization: Bearer  $access_token"));
            $post_string = array("action=kill");
            curl_setopt($ch, CURLOPT_POST, true);
            curl_setopt($ch, CURLOPT_POSTFIELDS, $post_string);

            # Execute the php curl and grab the response
            $response = curl_exec($ch);
            $resultStatus = curl_getinfo($ch);

            # Turn the response into json which php can manipulate
            $handled_json = json_decode($response,true);

            # grab the "status" of the job from the json
            $status = $handled_json['result']['status'];
            $http_code=$resultStatus['http_code'];
            # If the php curl was successful, update the jobs table and set result for url
            if($http_code == 200 || $http_code==201) 
            {
                $result="job_stopped";
                $id="$job_id"; //highlights the row
            }
            elseif($http_code==401)
            {
                $result="job_status_not_authorized";
                $status="unknown";
                $id="message"; //highlights the message at top of form
            }
            else // call failed
            {
               $result="no_response_from_api";
               $status="unknown";
               $id="message";
               #debug		echo 'Call Failed '.print_r($resultStatus);
               #debug		echo "$response";
            }
            curl_close ($ch);
        }
        else
        {
            $result="user_not_logged_in";
            $status="unknown";
            $id="message";
        }
    header("Location: $return_page?result=${http_code}&amp;job=${job_id}#${id}"); // report status and highlight status table cell which should now be updated


    }
    elseif($action=="delete")
    {
    $test="2";
    }
    else
    {
        $result="incorrect_parameter";
    }

header("Location: $return_page?result=${result}&amp;job_url=${job_url}&amp;http_code=${http_code}&amp;job=${job_id}&amp;#${job_id}"); // report status and highlight status table cell which should now be updated
?>

