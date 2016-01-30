<?php // this script displays certain job output file contents when called by another script (manage.php or jobs.php)
#error_reporting(E_ALL & ~E_NOTICE); //disable undeclared variable error

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
$PageTitle = 'Job Output';
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
	$section=$job_id;
	break;
case "manage":
	$location = "manage.php";
	$section="output";
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
	$GDB= "GDB".substr("00".$dbid, -3, 3);
	$STATUS=$row['status'];
	$status=strtolower($STATUS);
	$job_url=$row['job_URL'];
	$job_name=$row['job_name'];
	$job_submitted_time=$row['job_submitted_time'];
	$job_start_time=$row['job_start_time'];
	$last_updated=$row['last_updated'];
	$job_end_time=$row['job_end_time'];
	$process_complete_time=$row['process_complete_time'];
	$total_duration = ($process_complete_time=="")? time() - strtotime($job_submitted_time): strtotime($process_complete_time)-strtotime($job_submitted_time);	# job still running? Calculate from 'now'
	$process_time  = ($job_end_time=="")?"N/A":strtotime($job_end_time) - strtotime($job_start_time);	
	$total_duration = gmdate("H:i:s", $total_duration);
	$process_time = gmdate("H:i:s", $process_time);
	$now=date("Y:m:d H:i:s");


	//Get base_url from Admin database

	$auth_query="SELECT uid, auth_url, api_version from $global_DB1.admin where auth_url !='' order by uid DESC limit 0,1";
	$get_auth_record = mysql_query($auth_query);
	$auth=mysql_fetch_array($get_auth_record);
	$base_url=$auth['auth_url'];
	$api_version=$auth['api_version'];

	$output_url="${base_url}/jobs/${api_version}/${job_id}/outputs/listings/";
	
	//Create a php curl object
	$ch = curl_init();
	//Set php curl options.
	curl_setopt($ch, CURLOPT_URL,$output_url);
	curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
    curl_setopt($ch, CURLOPT_HTTPHEADER, array("Authorization: Bearer  $access_token"));

	//Execute the php curl and grab the response
	$response = curl_exec($ch);
	$resultStatus = curl_getinfo($ch);
	curl_close($ch);
	
	if($resultStatus['http_code'] == 200)
	{
		//Turn the response into json which php can manipulate
		// Close the curl object
	
		$handled_json = json_decode($response,true);
	

		//grab the "status" of the job from the json

		$files= $handled_json['result'];
		# $error="https://agave.iplantc.org/jobs/v2/0001425313556329-5056a550b8-0001-007/outputs/media/gth-gdb006-example-1---4-scaffold-hpc-standalone-gth-0001425313556329-5056a550b8-0001-007.err";
		# $error_filename=$handled_json["result"][3]["name"];
		# $error_file_path=$handled_json["result"][3]["_links"]["self"]["href"];
		# $get_file_url="{$base_url}/jobs/${api_version}/${job_id}/ouputs/media/${error_filename}";
	
		// Identify the file we want to retrieve, using the array output of the returned json string.
		$version=$handled_json["version"]; # for information purposes
		$n=sizeof($handled_json["result"]);
		$error_filename="";
		$file_list="<ul class=\"bullet1\">";
		for($i = 0; $i < $n;$i++)
		{
			$filename=$handled_json["result"][$i]["name"];
			$file_length=$handled_json["result"][$i]["length"];
			$file_list.="<li>$filename ($file_length)</li>";
			$pattern1='/^[a-zA-Z0-9-\_]+\.out$/';# out file, e.g. gth-gdb006-example-1---4-scaffold-hpc-standalone-gth-0001425313556329-5056a550b8-0001-007.out
			$pattern2='/^[a-zA-Z0-9-\_]+\.err$/';# error file, e.g. gth-gdb006-example-1---4-scaffold-hpc-standalone-gth-0001425313556329-5056a550b8-0001-007.err
			if(preg_match($pattern1, $filename))
			{
				$out_filename=$filename;
				$out_file_url=$handled_json["result"][$i]["_links"]["self"]["href"]; # same as "{$base_url}/jobs/${api_version}/${job_id}/ouputs/media/${out_filename}" 
				$out_file_length=$handled_json["result"][$i]["length"];
			}	
			if(preg_match($pattern2, $filename))
			{
				$err_filename=$filename;
				$err_file_url=$handled_json["result"][$i]["_links"]["self"]["href"]; # same as "{$base_url}/jobs/${api_version}/${job_id}/ouputs/media/${err_filename}"
				$err_file_length=$handled_json["result"][$i]["length"];
			}
		}
	    $file_list.="</ul>";

		if($out_filename!="" && $out_file_length<2000000) 
		{
			$timeout = 5;
			$ch = curl_init();
			curl_setopt($ch, CURLOPT_URL, $out_file_url);
			curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
			curl_setopt($ch, CURLOPT_CONNECTTIMEOUT, $timeout);
			curl_setopt($ch, CURLOPT_HTTPHEADER, array("Authorization: Bearer  $access_token"));
			curl_setopt($ch, CURLOPT_HEADER, 0);  
			$data1 = curl_exec($ch);
			$resultStatus1 = curl_getinfo($ch);
			curl_close($ch);
		}
		else
		{
		$data1="ERROR: no output file was retrieved or file too large. Result = $resultStatus1";
		}
		if($err_filename!="" && $err_file_length<20000000)
 		{
			$timeout = 5;
			$ch = curl_init();
			curl_setopt($ch, CURLOPT_URL, $err_file_url);
			curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
			curl_setopt($ch, CURLOPT_CONNECTTIMEOUT, $timeout);
			curl_setopt($ch, CURLOPT_HTTPHEADER, array("Authorization: Bearer  $access_token"));
			curl_setopt($ch, CURLOPT_HEADER, 0);  
			$data2 = curl_exec($ch);
			$resultStatus2 = curl_getinfo($ch);
			curl_close($ch);
		}
		else
		{
		$data2="ERROR: no error file was retrieved or file too large. Result = $resultStatus2";
		}

			# Build page

			echo
					'<div id="leftcolumncontainer">
						<div class="minicolumnleft">';
			
			include_once("/xGDBvm/XGDB/jobs/leftmenu.inc.php");

			echo'	</div>
				</div>
					<div id="maincontentscontainer" class="twocolumn admin">
						<div id="maincontentsfull">';

			#	echo "<p>id: $id</p> ";// debug only.

			//If the php curl was successful, display the results, if not, print failed results
			if($resultStatus1['http_code'] == 200 || $resultStatus2['http_code'] == 200) // either or both responded.
			{
				echo "  <h2>Output files for job <span style=\"color:darkred\">$job_id_trimmed</span><span style=\"color:#AAA\">$job_id_rest</span></h2><br />";
				echo "  <h3>Job submitted at: $job_submitted_time by $username . Status: <span class=\"job_${status} hugefont\">$STATUS</span> &nbsp; <a title=\"Return to previous page\" href=\"/XGDB/jobs/${location}#${section}\" class=\"xgdb_button colorJobs3 largerfont\">Return to $return </a></h3><br />";
				echo "  <h3>Files retrieved at: $now. Total of $i files currently in output directory. </h3><br />";
				echo "  <h3>Base URL: $base_url; Version: $version </h3><br />";
				echo    $file_list;
				echo "  <div class=\"featurediv\"> ";
				echo "  <h2 class=\"bottommargin1\">Output File:</h2> <pre style=\"font-size:15px\"> $out_filename</pre> ";
				echo "  <h2 class=\"topmargin1 bottommargin1\">Contents:</h2>";
				echo "  <pre style=\"font-size:13px\">$data1</span> </pre> ";
				echo "  </div>";
				echo "  <hr />";
				echo "  <div class=\"featurediv topmargin2\"> ";
				echo "  <h2 class=\"bottommargin1\">Error File:</h2> <pre style=\"font-size:15px\"> $err_filename</pre>";
				echo "  <h2 class=\"topmargin1 bottommargin1\">Contents:</h2>";
				echo "  <pre style=\"font-size:13px\">$data2</span> </pre> ";
				echo "  </div>";
				echo "  <br /><a title=\"Return to previous page\" href=\"/XGDB/jobs/${location}#${section}\" class=\"xgdb_button colorJobs4 largerfont\">Return to $return</a>";
		echo "<div class='showhide'><p title='Show additional information directly below this link' style='cursor:pointer'><span class='label'>Click to view server response</span></p>";
		echo "<div class='hidden'><p>Response from server:</p><p>$response </p></div>";
	    echo "</div><!--end showhide --><br />";

			}
			else
			{
				echo "     <h3>ERROR: call to outputs/media failed</h3> ".print_r($resultStatus);
				echo "		<a title=\"Return to previous page\" href=\"/XGDB/jobs/${location}#${section}\" class=\"xgdb_button colorJobs4 largerfont\">Return to $return </a>";
			}
	}
	else
	{
		echo "     <h3>ERROR: Call to outputs/listings failed</h3> ".print_r($resultStatus);
		echo "		<a title=\"Return to previous page\" href=\"/XGDB/jobs/${location}#${section}\" class=\"xgdb_button colorJobs3 largerfont\">Return to $return </a>";
	}
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
