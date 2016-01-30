<?php // this script displays job status (non-completed jobs) when called by another script. Updated for Agave 2/11/15
error_reporting(E_ALL & ~E_NOTICE); //disable undeclared variable error

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

	$global_DB= 'Admin';
	$PageTitle = 'External Processes';
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

    $pattern='/^[\d{16}-\d{8}-[a-z,0-9]{10]}-\d{4}-d{3}$/'; # Job ID e.g. 0001424105021858-5056a550b8-0001-007
    if(preg_match($pattern, $job_id)) # second level check
    {
    $job_id_trimmed=ltrim(substr($job_id, 0, 16), '0'); // e.g. 0001424105021858
    
	$url_query="SELECT * from $global_DB.jobs where job_id='$job_id'";
	$url_result = mysql_query($url_query);
	$row=mysql_fetch_array($url_result);
	$dbid=$row['db_id'];
	$GDB= "GDB".substr("00".${dbid}, -3, 3);
	$job_url=$row['job_URL'];
	$job_name=$row['job_name'];
	$job_submitted_time=$row['job_submitted_time'];
	$job_start_time=$row['job_start_time'];
	$last_updated=$row['last_updated'];
	$job_end_time=$row['job_end_time'];
	$process_complete_time=$row['process_complete_time'];
    $running_time  = time() - strtotime($job_start);	
	$running_time = gmdate("H:i:s", $diff);

	//Create a php curl object
	$ch = curl_init();
	
	//Get base_url from Admin database

	$auth_query="SELECT uid, auth_url, api_version from $global_DB1.admin where auth_url !='' order by uid DESC limit 0,1";
	$get_auth_record = mysql_query($auth_query);
	$auth=mysql_fetch_array($get_auth_record);
	$base_url=$auth['auth_url'];
	$api_version=$auth['api_version'];

	
	$status_url="${base_url}/${api_version}/${job_id}/status";
	$ch_values = "$username:$token";
	
	//Set php curl options.
	curl_setopt($ch, CURLOPT_URL,$status_url);
	curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
	curl_setopt($ch, CURLOPT_USERPWD, $ch_values);
	
	//Execute the php curl and grab the response
	$response = curl_exec($ch);
	$resultStatus = curl_getinfo($ch);
	
	//Turn the response into json which php can manipulate
	$handled_json = json_decode($response,true);
	
	//grab the "status" of the job from the json
	$status = $handled_json['result']['status'];
	
	
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
	if($resultStatus['http_code'] == 200) {
		echo "<h2>Job $job_id status is:  $status</h2><br />";
		echo " <p>Job ID: $job_id_display ($job_name),";
		echo " Submitted at: $job_submit_time by $username</p> ";
		echo " Processing started at: $job_start_time; Running time: $running_time </p> ";
		 echo "<p>array=$response</p>"; //debug
	} else {
		echo '<h3>Call Failed</h3> '.print_r($resultStatus);
		echo "<p>array=$response</p>";
	}

	//destroy php curl object
	curl_close ($ch);

}
else
{
    die('Invalid Job ID');
}
	

?>

			<table style="padding:10px 0 0 40px">
									<tr>
										<td>
											<a title="configure new GDB" href="/XGDB/jobs/<?php echo $return ?>.php#status" class="xgdb_button colorJobs4 largerfont">Return </a>
										</td>
									</tr>
								</table>

			</div><!-- end maincontentsfull-->
			
			</div><!-- end maincontentscontainer-->
			<div id="rightcolumncontainer">
				</div><!--end rightcolumncontainer-->
			<?php include($XGDB_FOOTER); ?>
		</div></div></div>
	</body>
</html>
