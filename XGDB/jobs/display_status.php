<?php // this script displays job status (non-completed jobs) when called by another script.

### Start the php session to be able to pull login and password tokens
session_start();	
### validate form sender or die ###

$post_valid=$_POST['valid']; // if properly set this is a mt_rand() integer; else not set or guessed value
$session_invalid=mt_rand(); 
$session_valid=(isset($_SESSION['valid']))?$_SESSION['valid']:$session_invalid;  // use bogus random # for comparison if no session value
if ($session_valid != $post_valid) // value passed by $_POST should match $_SESSION value; won't match if POST came from another source.
{
    die('Form submission failed validation');
}

$global_DB1= 'Admin';
$PageTitle = 'Job Status';
$pgdbmenu = 'Manage';
$submenu1 = 'Jobs-Home';
$submenu2 = 'ManageJobs';
$leftmenu='ManageJobs';
include('sitedef.php');
include($XGDB_HEADER);
$Create_Date = date("m-d-Y");
include_once('/xGDBvm/XGDB/phplib/db.inc.php'); #reads MySQL password from /xGDBvm/admin/dbpass
include_once('/xGDBvm/XGDB/jobs/jobs_functions.inc.php'); #common functions required in this script

date_default_timezone_set("$TIMEZONE"); // from sitedef.php

//Get gsq_url from Admin database

$dbpass=dbpass();
$db = mysql_connect("localhost", "gdbuser", $dbpass);
if(!$db)
	{
		echo "Error: Could not connect to database!";
		exit;
	}

//Grab the relevent session cookie data and place them into variables
$username=$_SESSION['username'];
$access_token=$_SESSION['access_token'];

//Grab posted data:
$job_id=mysql_real_escape_string($_POST['job_id']);
$return=mysql_real_escape_string($_POST['return']);

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

if(preg_match($pattern, $job_id) && isset($_SESSION['access_token'])) # second level check
{
    $pattern = "/^(\d+)(\-?.+)$/"; // we just want the first numeric string
    $match=(preg_match($pattern, $job_id, $matches)); 
    $job_id_trimmed=$matches[1]; // first numeric string
    $job_id_rest=$matches[2]; // rest of the job id string

	$id_query="SELECT * from $global_DB1.jobs where job_id='$job_id'";
	$id_result = mysql_query($id_query);
	$row=mysql_fetch_array($id_result);
	$dbid=$row['db_id'];
	$GDB= "GDB".substr("00".${$dbid}, -3, 3);
	$job_url=$row['job_URL'];
	$job_name=$row['job_name'];
	$job_submitted_time=$row['job_submitted_time'];
	$job_start_time=$row['job_start_time'];
	$last_updated=$row['last_updated'];
	$job_end_time=$row['job_end_time'];
	$process_complete_time=$row['process_complete_time'];
	$total_duration = ($process_complete_time==NULL)? time() - strtotime($job_submitted_time): strtotime($process_complete_time)-strtotime($job_submitted_time);	# job still running? Calculate from 'now'
	$process_time  = ($job_end_time==NULL)?"N/A":strtotime($job_end_time) - strtotime($job_start_time);	
	$total_duration = gmdate("H:i:s", $total_duration);
	$process_time = gmdate("H:i:s", $process_time);
	


	//Get base_url from Admin database

	$auth_query="SELECT uid, auth_url, api_version from $global_DB1.admin where auth_url !='' order by uid DESC limit 0,1";
	$get_auth_record = mysql_query($auth_query);
	$auth=mysql_fetch_array($get_auth_record);
	$base_url=$auth['auth_url'];
	$api_version=$auth['api_version'];

	$status_url="${base_url}/jobs/${api_version}/${job_id}/status";
	
	//Create a php curl object
	$ch = curl_init();
	//Set php curl options.
	curl_setopt($ch, CURLOPT_URL,$status_url);
	curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
    curl_setopt($ch, CURLOPT_HTTPHEADER, array( "Content-Type:application/json", "Authorization: Bearer  $access_token"));

	//Execute the php curl and grab the response
	$response = curl_exec($ch);
	$resultStatus = curl_getinfo($ch);

	//Turn the response into json which php can manipulate
	$handled_json = json_decode($response,true);

	//grab the "status" of the job from the json
	$STATUS = $handled_json['result']['status'];
	$status=strtolower($STATUS); # for styling

	# Build page

	echo
			'<div id="leftcolumncontainer">
				<div class="minicolumnleft">';
			
	$left_menu=include_once("/xGDBvm/XGDB/jobs/leftmenu.inc.php");

	echo $left_menu;
	echo'	</div>
		</div>
			<div id="maincontentscontainer" class="twocolumn admin">
				<div id="maincontentsfull">';

	#	echo "<p>id: $id</p> ";// debug only.

	//If the php curl was successful, display the results, if not, print failed results
	if($resultStatus['http_code'] == 200)
	{
		echo "  <h2>Job <span style=\"color:darkred\">$job_id_trimmed</span><span style=\"color:#AAA\">$job_id_rest</span></h2><br />";
		echo "  <h2>Status is: <span class=\"hugefont job_${status}\">$STATUS</span></h2><br />";
		echo "  <h3>Submitted at: $job_submitted_time by $username </h3><br />";
		echo "  <h3>Processing started at: $job_start_time &nbsp;  Processing time: <span style=\"color:red\">$process_time </span> &nbsp; Total job duration: <span style=\"color:green\">$total_duration</span> </h3> ";
		echo "  <div class='showhide'><p title='Show additional information directly below this link' style='cursor:pointer'><span class='label'>Click to view server response</span></p>";
		echo "     <div class='hidden'><p>Response from server:</p><p>$response </p></div>";
	    echo "     </div><!--end showhide --><br />";
	    echo "		<a title=\"configure new GDB\" href=\"/XGDB/jobs/${location}#status\" class=\"xgdb_button colorJobs4 largerfont\">Return </a>";



	}
	else
	{
		echo '     <h3>Call Failed</h3> '.print_r($resultStatus);
		echo "     <p>Response from server:</p><p>$response</p>";
	    echo "		<a title=\"configure new GDB\" href=\"/XGDB/jobs/${location}#status\" class=\"xgdb_button colorJobs4 largerfont\">Return </a>";
	}

	//destroy php curl object
	curl_close ($ch);
}
else
{

	die('Invalid Job ID');
}
	

?>

			</div><!-- end maincontentsfull-->
			
			</div><!-- end maincontentscontainer-->
			<div id="rightcolumncontainer">
				</div><!--end rightcolumncontainer-->
			<?php include($XGDB_FOOTER); ?>
		</div></div></div>
	</body>
</html>
