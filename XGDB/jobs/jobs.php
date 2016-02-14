<?php  # This script is an update of the jobs.php for the Agave API
#error_reporting(E_ALL & ~E_NOTICE); //disable undeclared variable error
session_start();

####### Set POST validation variable for this browser session #######
$valid_post = mt_rand();
$_SESSION['valid'] = $valid_post;

$PageTitle = 'List Jobs';
include('sitedef.php');
include_once('/xGDBvm/XGDB/jobs/login_functions.inc.php'); #common functions required in this script
include_once(dirname(__FILE__).'/jobs_functions.inc.php');

$inputDir=$XGDB_INPUTDIR; # 1-26-15 
$dataDir=$XGDB_DATADIR; # 1-26-15 
$inputDirRoot=$XGDB_INPUTDIR_MOUNT; # 1-26-16 J Duvick - corrected 2-2-16

    #date_default_timezone_set("$TIMEZONE"); // from sitedef.php

// Get session data that persists from the last login.
$username=isset($_SESSION['username'])?$_SESSION['username']:"";// username for login to authenticate
$http_code=isset($_SESSION['http_code'])?$_SESSION['http_code']:"";// code returned by curl
$expires=isset($_SESSION['expires'])?$_SESSION['expires']:""; //Authorization token expiration
$access_token=isset($_SESSION['access_token'])?$_SESSION['access_token']:""; //if present, indicates user is authenticated
$refresh_token=isset($_SESSION['refresh_token'])?$_SESSION['refresh_token']:""; //if present, indicates user is capable of refreshing even if access_token has expired.
$username=isset($_SESSION['username'])?$_SESSION['username']:"";// username for login to authenticate
$dbid=isset($_SESSION['dbid'])?$_SESSION['dbid']:""; //most recent GDB configuration viewed or edited (NOT NEEDED HERE?)
$login_id=isset($_SESSION['login_id'])?$_SESSION['login_id']:""; // (set by login_exec.php); this is the GDB that was originally used for login (if any), go to the logout script, and return here.
$redirect ="login";

$logout_result=login_status($redirect, $username, $http_code, $access_token, $refresh_token, $login_id, $expires); // login.functions_inc.php; checks login/refresh status based on elapsed time and stored refresh token
$logout_redirect=$logout_result[0];
$time_left=$logout_result[1];
$refresh_current=$logout_result[2];

if($logout_redirect !="")
{
header("Location: $logout_redirect"); // logs out (resets session variables)
}
    
    // Session variables
    $refresh_token=isset($_SESSION['refresh_token'])?$_SESSION['refresh_token']:""; //if set, indicates user is capable of refreshing
    $access_token=isset($_SESSION['access_token'])?$_SESSION['access_token']:""; //if set, indicates user is logged in
    $username=isset($_SESSION['username'])?$_SESSION['username']:""; //if set, indicates user is logged in

	include($XGDB_HEADER);
	$global_DB1= 'Admin'; //MySQL
	$global_DB2= 'Genomes'; //MySQL
	$pgdbmenu = 'Manage';
	$submenu1 = 'Jobs-Home';
	$submenu2 = 'ListJobs';
	$leftmenu='ListJobs';
	include_once('/xGDBvm/XGDB/phplib/db.inc.php');
	$dbpass=dbpass();
		$db = mysql_connect("localhost", "gdbuser", $dbpass);
	if(!$db)
	{
		echo "Error: Could not connect to database!";
		exit;
	}
	mysql_select_db("$global_DB1");
	$error = isset($_GET['error'])?$_GET['error']:"";

####### Set variables #######

$all_check="checked=\"checked\"";

global $pending_check,$staging_check,$queued_check,$submitting_check,$finished_check,$empty_check,$failed_check,$running_check,$stopped_check, $deleted_check, $timedout_check,$all_check;

####### Set POST validation variable for this browser session #######

$valid_post = mt_rand();
$_SESSION['valid'] = $valid_post;

####### check  $_GET login message
$result=isset($_GET['result'])?$_GET['result']:"";
$login_message="";
if ($result == "user_not_logged_in" && !isset($_SESSION['access_token']))
{
   $login_message="<span class=\"warning normalfont\">Login or login session expired. You must <a href=\"/XGDB/jobs/login.php\">login</a> to update job status.</span>";
}

#Starting query values

$startQuery="SELECT * from jobs where 1 ";
$endQuery=" ORDER BY uid ASC";
$searchQuery="";
$statusQuery="";
$filterID="";
$id_display="";
$filter_message="";

if(isset($_GET['id'])){	 #job ID URL
$id = trim(mysql_real_escape_string($_GET['id']));

		$filterID = $id;
		$filterQuery = " AND job_id = \"$filterID\"";
		unset($_SESSION['job_field']); # destroy any POST/SESSION
		unset($_SESSION['job_search']);# destroy

#create concatenated query from GET
$totalQuery=$startQuery.$filterQuery.$endQuery;
$filter_message ="<span class=\"heading\">Showing result for job_id=<span style=\"color:red\">$filterID </span></span><a href=\"/XGDB/jobs/jobs_exec.php?redirect=jobs\"><span class=\"normalfont\">(Show All Jobs)</span></a>";

	}else{
	
#grab post or session values and build query string:

$post_passed=isset($_POST['job_passed'])?$_POST['job_passed']:"";

	if($post_passed == 1){	 #search box
			$searchWord = trim(mysql_real_escape_string(str_replace("*", "%", $_POST['search'])));
			$searchField = mysql_real_escape_string(str_replace("*", "%", $_POST['field']));
			$searchQuery = ($searchField =="dbid") ? " AND db_id = $searchWord":" AND $searchField like '%$searchWord%' ";
			$_SESSION['job_field'] = isset($_POST['field'])?mysql_real_escape_string($_POST['field']):"";
			$_SESSION['job_search'] = isset($_POST['search'])?mysql_real_escape_string($_POST['search']):"";
	
		}elseif(isset($_SESSION['job_field'])){ # session exists	
			$searchWord = $_SESSION['job_search'];
			$searchField = $_SESSION['job_field'];
			$searchQuery = ($searchField =="dbid") ? " AND db_id = $searchWord":" AND $searchField like '%$searchWord%' ";
			$searchQuery = " AND $searchField like '%$searchWord%' ";
	
		}else{ # No query - display all.
		$searchQuery = "";
	}
	
	if($post_passed == 2){	# status radio button
			$statusWord = mysql_real_escape_string(str_replace("all", "", $_POST['status']));
			$statusQuery = "AND Status LIKE '%$statusWord%' ";
			$_SESSION['job_status'] = isset($_POST['status'])?mysql_real_escape_string($_POST['status']):"";
			
	#set up radio button check based on post from status_view form:

	// See http://agaveapi.co/job-management/
	$pending_check= (($_POST['status']) == "PENDING")? "checked=\"checked\"":""; // pending
	$staged_check= (($_POST['status']) == "STAGED")? "checked=\"checked\"":""; // staged = HPC STAGED
	$queued_check= (($_POST['status']) == "QUEUED")? "checked=\"checked\"":""; // queued = HPC QUEUED
	$submitting_check= (($_POST['status']) == "SUBMITTING")? "checked=\"checked\"":""; // submitting = HPC SUCCESS (job submit)
	$finished_check= (($_POST['status']) == "FINISHED")? "checked=\"checked\"":""; //finished - xGDB_Procedure.sh detects data records in output
	$deleted_check= (($_POST['status']) == "DELETED")? "checked=\"checked\"":""; // empty - xGDB_Procedure.sh detects no data in output
	$failed_check= (($_POST['status']) == "FAILED")? "checked=\"checked\"":""; // error - nothing was successfully submitteee
	$running_check= (($_POST['status']) == "RUNNING")? "checked=\"checked\"":"";
	$stopped_check= (($_POST['status']) == "STOPPED")? "checked=\"checked\"":"";
	$timedout_check= (($_POST['status']) == "TIMEDOUT")? "checked=\"checked\"":"";
	$all_check= (($_POST['status']) == "all")? "checked=\"checked\"":"";#default;

}elseif(isset($_SESSION['job_status'])){ # session exists	
	$statusWord = str_replace("all", "", $_SESSION['job_status']); // 'all' replaced with nothing
	$statusQuery = " AND status LIKE '%$statusWord%' ";
	$pending_check= (($_SESSION['job_status']) == "PENDING")? "checked=\"checked\"":"";
	$staged_check= (($_SESSION['job_status']) == "STAGED")? "checked=\"checked\"; class=\"job_staged\"":"";
	$queued_check= (($_SESSION['job_status']) == "QUEUED")? "checked=\"checked\"; class=\"job_queued\"":"";
	$submitting_check= (($_SESSION['job_status']) == "SUBMITTING")? "checked=\"checked\"":"";
	$finished_check= (($_SESSION['job_status']) == "FINISHED")? "checked=\"checked\"":"";
	$deleted_check= (($_SESSION['job_status']) == "DELETED")? "checked=\"checked\"":"";
	$stopped_check= (($_SESSION['job_status']) == "STOPPED")? "checked=\"checked\"":"";
	$running_check= (($_SESSION['job_status']) == "RUNNING")? "checked=\"checked\"":"";
	$failed_check= (($_SESSION['job_status']) == "FAILED")? "checked=\"checked\"":"";
	$timedout_check= (($_SESSION['job_status']) == "TIMEDOUT")? "checked=\"checked\"":"";
	$all_check= (($_SESSION['job_status']) == "all")? "checked=\"checked\"":"";#default;
	
		}else{ # No query - display online current (default).
		$statusQuery = "";
		$current_check="checked=\"checked\"";
	}
	
	#Concatenate POST query strings:
	
	$totalQuery=$startQuery.$searchQuery.$statusQuery.$endQuery;
	$sessionQuery=$searchQuery.$statusQuery.$endQuery;
	$_SESSION['job_query'] = $sessionQuery;
##	echo $totalQuery;

}

### Directory Mount Status ###
# data directory:/data/ ($dir1)
 $dir1_status="";
if (file_exists("/xGDBvm/admin/iplant")) { // xGDBvm-iPlant only
   $dir1="/xGDBvm/data/"; // TODO: move to sitedef.php
   $df_dir1=df_available($dir1); // check if /data/ directory is externally mounted (returns array)
	$devloc=str_replace("/","\/",$EXT_MOUNT_DIR); // read from device location stored in /xGDBvm/admin/devloc via sitedef.php
	$dir1_mount=(preg_match("/$devloc/", $df_dir1[0]))?"<span class=\"checked_mount\">Ext vol mounted</span>":"<span class=\"lightgrayfont\">Ext vol not mounted</span>"; //flag for dir1 mount
	$dir1_status="<span class=\"normalfont \" style=\"font-weight:normal\"><a class='help-button' title='Mount status of /xGDBvm/data/' id='config_input_ebs'> $dir1_mount </a></span>";
}

# data store directory:/input/ ($dir2)
 $dir2_status="";
if (file_exists("/xGDBvm/admin/iplant")) { // xGDBvm-iPlant only
	$dir2="$inputDirRoot"; // TODO: move to sitedef.php
	$df_dir2=df_available($dir2); // check if /input/ directory is fuse-mounted (returns array)
	$dir2_dropdown=($df_dir2[0]=="fuse"  || $df_dir2[0]=="irodsFs")?"/xGDBvm/input/":""; //only show input dir if fuse-mounted
	$dir2_mount=($df_dir2[0]=="fuse" || $df_dir2[0]=="irodsFs")?"<span class=\"checked_mount nowrap\">DataStore mounted</span>":"<span class=\"lightgrayfont\">DataStore not mounted</span>"; //flag for dir2 mount (Data Store) top of form
	$mount_status_alert=($df_dir2[0]=="fuse" || $df_dir2[0]=="irodsFs")?"<span class=\"checked nowrap\">DataStore mounted</span>":"<span class=\"warning\">DataStore not mounted</span>"; //more intrusive flag
	$dir2_status="<span class=\"normalfont \" style=\"font-weight:normal\"><a class='help-button' title='Mount status of $inputDirRoot' id='config_input_irods'> $dir2_mount </a></span>";
}

## Get GTH GSQ app info

$gsq_query="SELECT app_id from ${global_DB1}.apps WHERE program='GeneSeqer-MPI' AND is_default='Y' ";
$get_gsq = mysql_query($gsq_query);
while ($row = mysql_fetch_array($get_gsq)) {

    $gsq_default=$row["app_id"];
}
$gth_query="SELECT app_id from ${global_DB1}.apps WHERE program='GenomeThreader' AND is_default='Y' ";
$get_gth = mysql_query($gth_query);
while ($row = mysql_fetch_array($get_gth)) {

    $gth_default=$row["app_id"];
}

$gsq_message=($gsq_default=="")?"<span class=\"warning indent2\">No GSQ App has been configured <a href=\"/XGDB/jobs/apps.php\">(go do it)</a> </span>":"<span class=\"checked indent2\">GSQ App ID:</span>$gsq_default";

$gth_message=($gth_default=="")?"<span class=\"warning indent2\">No GTH App has been configured <a href=\"/XGDB/jobs/apps.php\">(go do it)</a> </span>":"<span class=\"checked indent2\">GTH App ID: </span>$gth_default";

## Get most recent Authorization URL (if any) from database; set update/insert depending on whether prev value exists

	$auth_query="SELECT uid, auth_url, api_version, auth_update from $global_DB1.admin where auth_url !='' order by uid DESC limit 0,1";
	$get_auth_record = $auth_query;
	$check_get_auth_record = mysql_query($get_auth_record);
	$auth_result = $check_get_auth_record;
	$auth=mysql_fetch_array($auth_result);
	$auth_url=$auth['auth_url'];  // this should be something like https://agave.iplantc.org
	$api_version=$auth['api_version'];

### show or hide login/logout/refresh blocks depending on token status ###
$conditional_display_logged_out=($access_token=="")?"":"display_off"; # display 'logged out' message only if user is logged out (no access token)
$conditional_display_login=($access_token=="" && $refresh_token=="")?"":"display_off"; # display 'login' option only if user is logged out (no access token) and no refresh token is present
$conditional_display_logout=($access_token!="")?"":"display_off"; # display login details and 'logout' option only if user is logged in.
$conditional_display_refresh=($refresh_token!="")?"":"display_off"; # display 'refresh' option only if refresh_token is present

#### Validate presence of GTH Key (required for remote GTH) ###

$validate_gth=validate_dir($KEY_SOURCE_DIR, $GENOMETHREADER_KEY, "GenomeThreader License Key", "present", "missing");
$gth_valid=$validate_gth[0]; $gth_class=$validate_gth[1];
$gth_valid_message="<span class=\"$gth_class\">GTH license ${gth_valid}:</span> ${KEY_SOURCE_DIR}${GENOMETHREADER_KEY} <img id='jobs_gth_license' title='GenomeThreader License - Help' class='help-button nudge3 smallerfont' src='/XGDB/images/help-icon.png' alt='?' />";

# submit radio button script

echo "

										<script type=\"text/javascript\">
										/* <![CDATA[ */
										
										function formSubmit(name) {
											//alert('hi got here');
											var objForm = document.forms[name]
											//alert(name);
											objForm.submit();
										}
										/* ]]> */
										</script>
";



#build result array from totalQuery and store in session
$get_records = $totalQuery;
$check_get_records = mysql_query($get_records);
$records = $check_get_records;
$display_block = "


<table style=\"margin:20px 5px 10px 0; width: 100%;\" class=\"\">
								<colgroup>
									<col width =\"95%\" />
								</colgroup>	
			<tr>
				<td width=\"80%\" align = \"left\" class=\"normalfont\">
				<form method=\"post\" action=\"/XGDB/jobs/jobs.php\" name=\"status_view\" class=\"styled\">
				View Jobs: 
					<input title =\"pending\" style=\"cursor:pointer\" class=\"normalfont\" type=\"radio\"  name=\"status\" value=\"PENDING\" $pending_check onclick=\"formSubmit('status_view');\" /> <span class=\"job_pending\">PENDING</span>&nbsp;
					<input title =\"submitting\" style=\"cursor:pointer\" class=\"normalfont\" type=\"radio\"  name=\"status\" value=\"SUBMITTING\" $submitting_check onclick=\"formSubmit('status_view');\" /> <span class=\"job_submitting\">SUBMITTING</span>&nbsp;
					<input title =\"staged\" style=\"cursor:pointer\" class=\"normalfont\" type=\"radio\"  name=\"status\" value=\"STAGED\" $submitting_check onclick=\"formSubmit('status_view');\" /> <span class=\"job_staged\">STAGED</span>&nbsp;
					<input title =\"queued\" style=\"cursor:pointer\" class=\"normalfont\" type=\"radio\"  name=\"status\" value=\"QUEUED\" $queued_check onclick=\"formSubmit('status_view');\" /> <span class=\"job_queued\">QUEUED</span> &nbsp;		
					<input title =\"running\" style=\"cursor:pointer\"  class=\"normalfont\" type=\"radio\"  name=\"status\" value=\"RUNNING\" $running_check onclick=\"formSubmit('status_view');\" /> <span class=\"job_running\">RUNNING</span>&nbsp;
					<input title =\"finished\" style=\"cursor:pointer\"  class=\"normalfont\" type=\"radio\"  name=\"status\" value=\"FINISHED\" $finished_check onclick=\"formSubmit('status_view');\" /> <span class=\"job_finished\">FINISHED</span>&nbsp;
					<input title =\"failed\" style=\"cursor:pointer\"  class=\"normalfont\" type=\"radio\"  name=\"status\" value=\"FAILED\" $failed_check onclick=\"formSubmit('status_view');\" /> <span class=\"job_failed\">FAILED</span>&nbsp;
					<input title =\"stopped\" style=\"cursor:pointer\"  class=\"normalfont\" type=\"radio\"  name=\"status\" value=\"STOPPED\" $stopped_check onclick=\"formSubmit('status_view');\" /> <span class=\"job_stopped\">STOPPED</span>&nbsp;
					<input title =\"deleted\" style=\"cursor:pointer\"  class=\"normalfont\" type=\"radio\"  name=\"status\" value=\"DELETED\" $deleted_check onclick=\"formSubmit('status_view');\" /> <span class=\"job_deleted\">DELETED</span>&nbsp;			
					<input title =\"timedout\" style=\"cursor:pointer\"  class=\"normalfont\" type=\"radio\"  name=\"status\" value=\"TIMEDOUT\" $timedout_check onclick=\"formSubmit('status_view');\" /> <span class=\"job_timedout\">TIMEDOUT</span>&nbsp;		
					<input title =\"online\" style=\"cursor:pointer\" class=\"normalfont\" type=\"radio\"  name=\"status\" value=\"all\" $all_check onclick=\"formSubmit('status_view');\" /> All
					<input type=\"hidden\" name=\"job_passed\" value=\"2\" />
					<!--input type=\"submit\" name=\"submit\" value=\"Go\" /-->
				</form>
				</td>
			</tr>
	</table>

";

$display_block .= "

<table class=\"featuretable bottommargin1 striped\" style=\"font-size:12px\" cellpadding=\"6\">
<thead align=\"center\">
				<tr class=\"th_jobs reverse_3\">
					<th>
 						UID
					</th>
					<th>
						Job ID / Name <img id='jobs_job_id' title='Remote Job ID. Click ? for details.' class='help-button nudge1' src='/XGDB/images/help-icon.png' alt='?' /> <br />
					</th>
					<th>
						Date & Time Submitted ($TIMEZONE)
					</th>
					<th>
						Date & Time Completed / TOTAL Job Duration (h) <br /><span class=\"redfont\">Still Running</span>
					</th>
					<th>
						App ID
					</th>
					<th style=\"cursor:pointer\"; title=\"whether data is from Example or user-specified\">
					    Data <br />
					    Type
					</th>
					<th>
						JOB STATUS / Last Update / <span class=\"alertnotice italic\">RUNNING Time	</span>
					</th>
					<th>
					Action / Result <img id='jobs_job_actions' title='Job actions. Click ? for details.' class='help-button nudge1' src='/XGDB/images/help-icon.png' alt='?' />
					</th>
					<th>
						GDB ID <br /><span class=\"lightgrayfont italic\">(click to view config)</span>
					</th>
					<th>
						job_type
					</th>
					<th>
						User
					</th>
					<th>
						Seq Type
					</th>
					<th>
						Genome File Size
					</th>
					<th>
						Input File Size
					</th>
					<th>
						Requested Time
					</th>
					<th>
						Thr<br />eads
					</th>
					<th>
						Mem<br />ory
					</th>
					<th>
						<span class=\"alertnotice\">ERROR</span>
					</th>
					
				</tr>
		</thead>
<tbody>
";
$failure="";
$i=0;
$uid_list=array();
while ($row = mysql_fetch_assoc($records)) {
    $i=$i+1;
    $uid=$row["uid"];
    $uid_list[$i]=$uid; // for checkboxes
    $checked_id="record".$i;
    $job_id=$row["job_id"]; // e.g. 3949611174092533275-e0bd34dffff8de6-0001-007
	$pattern = "/^(\d+)\-?.+$/";
    $match=(preg_match($pattern, $job_id, $matches));
    $job_id_trimmed=$matches[1];
    $job_name=$row["job_name"]; // e.g. gdb007-example-1-4-scaffold-test-for-hpc
    $job_directory="job-${job_id}"; // e.g. job-3949611174092533275-e0bd34dffff8de6-0001-007; destination directory name
    $status=$row["status"]; // e.g. RUNNING
    $status_lowercase=strtolower($status); # e.g. running; for help links
    $status=($status=="SUCCESS")?"SUBMITTING":$status;
    $failure=($failure=="" && ($status=="FAILED" || $status=="STOPPED" || $status=="KILLED" || $status=="NO_OUTPUT" || $status=="ARCHIVING_FAILED"  || $status== "TIMEDOUT" || $status== "EMPTY"))?"FAILURE":"$failure"; //all or none status
    $db_id=$row["db_id"];
    $job_submitted_time = $row["job_submitted_time"];
    $job_start_time = $row["job_start_time"];
    $job_end_time = $row["job_end_time"];
    $process_complete_time = $row["process_complete_time"];
    $last_updated = $row["last_updated"];
#    $last_updated_display=(isset($job_end_time))?$job_end_time:$last_updated;
    $last_updated_display=$last_updated;
    $submit=strtotime($job_submitted_time);
    if($process_complete_time==""){ 
      $end_or_now=time(); // still running - calculate to now
      $total_time_style="redfont";
      }
      else
      {
    	$end_or_now=strtotime($job_end_time);
        $total_time_style="normalfont";
      }
    $diff_sec  = $end_or_now - $submit;
    $total_time = sprintf('%02d:%02d:%02d', ($diff_sec / 3600), ($diff_sec / 60 % 60), $diff_sec % 60); // format calculated string as total H:i:s (total job time may be >24 hr)
    $total_time_display=($status !="")?$total_time:"(no job)";
    $start=strtotime($job_start_time);
    $end=isset($job_end_time)?strtotime($job_end_time) : time();
    $run_sec  = $end - $start;
	$run = (isset($job_start_time))?sprintf('%02d:%02d:%02d', ($run_sec / 3600), ($run_sec / 60 % 60), $run_sec % 60):""; // format calculated string as total H:i:s (total run time might be >24 hr)

	$run_styled= ($status == "FINISHED" || $status == "ARCHIVING_FINISHED" || $status=="STOPPED" || $status=="CLEANING_UP" || $status=="ARCHIVING_FAILED" || $status=="KILLED" || $status=="FAILED" || $status=="DELETED" )?"<span class=\"alertnotice\">$run</span>":($status=="RUNNING"? "<span class=\"alertnotice italic\">$run</span>":""); // show red if still running
	
	$outcome = $row["outcome"];
    $id =$row["db_id"];
    $DBid = 'GDB'.substr(('00'. $id),-3);								
    $job_type=$row["job_type"];
    $program=$row["program"]; # e.g. GTH or GSQ
    $appId=$row["softwareName"]; # Unique name configured on configure.php
    $job_description=$row["job_URL"];
    $HPC_name=$row["HPC_name"];
    $user=$row["user"];
    $admin_email=$row["admin_email"];
    $seq_type=$row["seq_type"];
    $genome_file_size=$row["genome_file_size"];
    $genome_file_size_display=convert_bytes($genome_file_size, 0);
    $genome_segments=$row["genome_segments"];
    $split_count=$row["split_count"];
    $input_file_size = $row["input_file_size"];
    $input_file_size_display=convert_bytes($input_file_size, 0);
    $parameters = $row["parameters"];
    $requested_time = $row["requested_time"];
    $processor_count = $row["processors"];
    $memory = $row["memory"];
    $comments = $row["comments"];
    $error = $row["error"];
   # $error_display=($error=="")?"": "<br /><span class=\"warning smallerfont\">$error</span><br /><span class=\"smallerfont\">$comments</span>";
    $error_display=($error=="")?"": "<a name=\"uid\" class=\"help-button2\" title=\"Click '?' for status progress.\"><span class=\"warning smallerfont\">$error</span></a>"; //invokes jquery dialog help
    $running_pattern="/RUNNING/";
    $running = preg_match($running_pattern, $comments)?true:false; // Search the concatenated status output for RUNNING. 
    $output_copied = $row["output_copied"];		
    $output_copied_display = ($output_copied!="")?"<span title=\"$output_copied\">Copied</span>":"";				
    $job_status_class = ($status=="QUEUED") ? "job_queued" :(($status=="PENDING") ? "job_pending" :(($status=="STAGING_JOB") ? "job_staging" :(($status=="SUBMITTING") ? "job_submitting" : (($status=="RUNNING") ? "job_running" : (($status=="DELETED") ? "job_deleted" : (($status=="STOPPED") ? "job_stopped" : (($status=="TIMEDOUT") ? "job_timedout" : (($status=="FINISHED") ? "job_finished" : (($status=="FAILED") ? "job_failed" : (($status=="ERROR") ? "job_error" : ""))))))))));
    $job_status_linked = "<a name=\"jobs_status_$status_lowercase\" class=\"help-button2\" title=\"JOB PROCESS LOG. Click '?' for explanation of current status. \nSUBMITTED: $job_submitted_time | $comments | $error\"><span class=\"nolinkstyle\">$status</span></a>"; //invokes jquery dialog help
    $DBid_display="<span class=\"largerfont\"><a title=\"View configuration page for this GDB\" href=\"/XGDB/conf/view.php?id=$id\">$DBid</a></span>";
    $program_display="<span style=\"cursor:pointer\" title=\"parameters: $parameters\">$appId</span>";
    $program_lower=strtolower($program);
    $job_id_display= ($job_end_time!="") ? "<span style=\"cursor:pointer; color:#222\" title=\"$job_id\">$job_id_trimmed</span>":"<span style=\"cursor:pointer; color:red\" title=\"$job_id\">$job_id_trimmed</span>";
    $job_id_display= ($job_id=="")?"<span style=\"cursor:pointer; color:red\" title=\"For some reason no job ID has been assigned.\">NO JOB WAS SUBMITTED</span>":$job_id_display;
    $output_file="${DBid}${seq_type}.${program_lower}"; //e.g. GDB001est.gsq
    $output_path="/xGDBvm/input/archive/jobs/$job_directory/$output_file"; // e.g. /xGDBvm/input/archive/jobs/job-0001424105021858-5056a550b8-0001-007/GDB001est.gsq
    $copied_filename="job-$job_id.$output_file"; // if copied to user's input directory, this will be filename
    ## Get MySQL 'xGDB_Log.Input_Data_Path' as destination_path (for button display)
    $path_query = "SELECT Input_Data_Path FROM $global_DB2.xGDB_Log WHERE ID=$id";
    $check_get_path = mysql_query($path_query);
    $get_result = mysql_fetch_array($check_get_path);
    $Input_Data_Path = $get_result[0];
    $pattern='/\/examples\//';
    $data_type=(preg_match($pattern, $Input_Data_Path))?"exmpl":"user"; // example data or user-specified (determines whether 'Copy' button visible)
    
    ## Prepare action buttons. 
   // SHOW OUTPUT LOGS.     
 
   // REMOVE THIS RECORD FROM JOBS TABLE (does not affect archive or server data). Note - checks are in place so active jobs will not be deleted.     
    $remove_record = ($user == $username && ($status == "DELETED" || $job_id=="" || $status=="" || $status=="ERROR")) ?
    "<form method=\"post\" action=\"/XGDB/jobs/remove_exec.php\" name=\"remove_record\">
    <input type=\"hidden\" name=\"action\" value=\"remove\" />
    <input type=\"hidden\" name=\"valid\" value=\"$valid_post\" />
    <input type=\"hidden\" value=\"$username\" name=\"username\" />
    <input type=\"hidden\" name=\"job\" value=\"$job_id\" />
    <input type=\"hidden\" name=\"uid\" value=\"$uid\" />
    <input type=\"hidden\" name=\"return\" value=\"jobs\" />
    <input title=\"Remove this record from the jobs table \n(does not affect archived data or server data)\" id=\"delete_record_button\" style=\"color:#888\" type=\"submit\" value=\" REMOVE \" name=\"delete_record\" onclick=\"return confirm('Delete this record from xGDBvm? (will not affect archived output or job entry)')\" />
	</form>
	"
	:
	""
	;
	// DISPLAY OUTPUT LOGS if job has reached the RUNNING stage
    $display_logfiles = ($user == $username && $access_token != "" && ($status == "RUNNING" || $status == "CLEANING_UP"  || $status == "ARCHIVING"  || $status == "ARCHIVING_FINISHED"  || $status == "ARCHIVING_FAILED"  || $status == "FAILED" || $status == "FINISHED" || $status == "NO_OUTPUT")) ?  
    "<form method=\"post\" action=\"/XGDB/jobs/display_logfiles.php\" name=\"display_output\">
    <input type=\"hidden\" name=\"action\" value=\"display\" />
    <input type=\"hidden\" name=\"valid\" value=\"$valid_post\" />
    <input type=\"hidden\" name=\"job_id\" value=\"$job_id\" />
    <input type=\"hidden\" name=\"return\" value=\"jobs\">
    <input title=\"Display output logs for this job \" id=\"display_output_button\" type=\"submit\" style=\"color:magenta\" value=\" LOGS \" name=\"display_output\" onclick=\"return confirm('Display output logs for this job?')\">
	</form>
	"
	:
	""
	;
    // STOP JOB ON SERVER: Show 'Stop' button if user logged in and job status is at or prior to RUNNING
    $hpc_stop = ($user == $username && $access_token != "" && ($status == "PENDING" || $status == "STAGING_INPUTS" || $status == "QUEUED" || $status == "SUBMITTING" || $status == "STAGED" || $status == "PROCESSING_INPUTS" || $status == "RUNNING" || $status == "STAGING_JOB" || $status == "CLEANING_UP"  || $status == "ARCHIVING"  || $status == "ARCHIVING_FINISHED")) ? 
    "<form method=\"post\" action=\"stop-or-delete_exec.php\">
    <input type=\"hidden\" value=\"stop\" name=\"action\">
    <input type=\"hidden\" value=\"$valid_post\" name=\"valid\">
    <input type=\"hidden\" value=\"jobs\" name=\"return\">
    <input type=\"hidden\" value=\"$job_id\" name=\"job\">
    <input  title=\"Stop this job from running\" id=\"stop\" type=\"submit\" style=\"color:red\" value=\" STOP JOB \" name=\"stop\" onclick=\"return confirm('Stop this job? (Not undo-able)')\")>
    </form>
    "
    :
    "";
    // DELETE JOB FROM SERVER: Show 'Delete' button if user logged in and job is Finished (no end time)
    $hpc_delete = ($user == $username && ($process_complete_time!="" || $status == "STOPPED" || $status == "FAILED") && $access_token != ""  && $status != "DELETED") ?
    "
    <form method=\"post\" action=\"stop-or-delete_exec.php\">
    <input type=\"hidden\" value=\"delete\" name=\"action\">
    <input type=\"hidden\" value=\"$valid_post\" name=\"valid\">
    <input type=\"hidden\" value=\"jobs\" name=\"return\">
    <input type=\"hidden\" value=\"$job_id\" name=\"job\">
    <input title=\"Delete this job from the HPC server \n (will not affect archived outputs)\" id=\"delete\" style=\"color:black\" type=\"submit\" value=\" DELETE \" name=\"delete\" onclick=\"return confirm('Delete this job? (will not affect archived output)')\">
    </form>
    "
    :
    "";
    // COUNT MATCHES in ARCHIVE: Show 'Count' button if user logged in and job is Finished (end time)
   $hpc_match_count =  ($user == $username && $status =="FINISHED" && $outcome == "" ) ? 
    "
    <form method=\"post\" action=\"matches_exec.php\">
    <input type=\"hidden\" value=\"matches\" name=\"action\">
    <input type=\"hidden\" value=\"$valid_post\" name=\"valid\">
    <input type=\"hidden\" value=\"jobs\" name=\"return\">
    <input type=\"hidden\" value=\"$job_id\" name=\"job\">
    <span  class=\"\"><input title=\"Click to return the number of spliced alignment matches in output file\" id=\"matches\" type=\"submit\" value=\" COUNT \" name=\"copy\" onclick=\"return confirm('Count number of spliced alignment matches? (this could take awhile)')\"><span>
    </form>
    "
    :
    "";
    // COPY OUTPUT from ARCHIVE: Show 'Copy' button if job is Finished and not yet copied, as long as job type is Standalong and data is not example data.
    $hpc_copy= ($user == $username && $status =="FINISHED" && $output_copied == "" && $job_type=="Standalone" && $data_type=="user")? //output complete, not copied to input dir, not example ($data_type=user)
    "
    <form method=\"post\" action=\"copy_exec.php\">
    <input type=\"hidden\" value=\"copy\" name=\"action\">
    <input type=\"hidden\" value=\"$valid_post\" name=\"valid\">
    <input type=\"hidden\" value=\"jobs\" name=\"return\">
    <input type=\"hidden\" value=\"$job_id\" name=\"job\">
    <span class=\"\"><input title=\"Copy from archive to input directory as: \n $Input_Data_Path/$copied_filename\" style=\"color:green\" id=\"copy\" type=\"submit\" value=\" COPY  \" name=\"copy\" onclick=\"return confirm('Copy output data to your current Input directory?')\"></span>
    </form> 
    
    "
    :
    "";
    // RELOAD PAGE Show 'Reload' button if job is not completed (user doesn't need to be logged in, data are updated automatically from server)
    $reload_page= ($process_complete_time =="" && $status !="FAILED" ) ?   //output complete.
    "
    <form method=\"post\" action=\"reload_exec.php\">
    <input type=\"hidden\" value=\"reload\" name=\"action\">
    <input type=\"hidden\" value=\"jobs\" name=\"return\">
    <input type=\"hidden\" value=\"$job_id\" name=\"job_id\">
    <span class=\"\"><input title=\"Reload the page (update status)\" id=\"reload\" type=\"submit\" value=\" Update  \" name=\"reload\"></span>
    </form> 
    "
    :
    "";
    $outcome = ($outcome != "")?"<span class=\"plaintext smallerfont\">$outcome</span> total":"";
    $display_block .= "						
				 <tr align=\"right\" class=\"\"  id=\"$uid\">
				 	<td  align=\"center\" >
				 	<span style=\"color:#999\">$uid</span>
				 	</td>
					<td>
						$job_id_display
						<br />
						<span class=\"smallerfont grayfont\">
						$job_name
						</span>
					</td>
					<td>
						<span class=\"smallerfont grayfont\">$job_submitted_time</span>
					</td>
					<td>
						<span class=\"smallerfont grayfont\">$process_complete_time</span> <br /> <span class=\"$total_time_style\">$total_time_display</span>
					</td>
					<td>
						$program_display
					</td>
					<td>
					    $data_type
					</td>
					<td class=\"$job_status_class\">
					</a><span class=\"bold\">$job_status_linked</span> <br />
					<span class=\"smallerfont grayfont\">$last_updated_display</span><br />
					$run_styled
					<span class=\"nowrap\">$reload_page</span>

					</td>
					<td id=\"$job_id\">
						 $outcome
						 $output_copied_display
						 <span class=\"nowrap\">$hpc_stop</span>
						 <span class=\"nowrap\">$hpc_match_count</span>
						 <span class=\"nowrap\">$hpc_copy</span>
						 <span class=\"nowrap\">$hpc_delete</span>
						 $display_logfiles
						 $remove_record
					</td>
					<td>
						$DBid_display
					</td>
					<td>
						<span class=\"$job_type\">$job_type</span>
					</td>
					<td>
						$user
					</td>
					<td>
						<span class=\"${seq_type}_color\">$seq_type</span>
					</td>
					<td>
						$genome_file_size_display
					</td>
					<td>
						$input_file_size_display
					</td>
					<td>
						$requested_time
					</td>
					<td>
						$processor_count
					</td>
					<td>
						$memory
					</td>
					<td align=\"left\">
					$error_display	
					</td>
				</tr>
			";
}

$status_message=($failure=="")?"Troubleshooting Jobs":"Why did my Job Fail?";

$display_block .= "
<tr>
<td class=\"reverse_1\" colspan=\"18\">
</td>
</tr>
</tbody>
</table>
<input  type=\"hidden\" name=\"count\" value=\"$i\" />"
;

?>
	<div id="leftcolumncontainer">
		<div class="minicolumnleft">
			<?php include_once("/xGDBvm/XGDB/jobs/leftmenu.inc.php"); ?>
		</div>
	</div>
	<div id="maincontentscontainer" class="twocolumn overflow configure">
			<div id="maincontentsfull" class="configure">
<div class="featurediv bottommargin2">
<table width="95%">
					<colgroup>
						<col width ="35%" />
						<col width ="2%" />
						<col width ="60%" style="background-color: #EEE"  />
						<col width ="5%" />
					</colgroup>
					<tr>
					<td>
						<h1 class="jobs">
						   <img src="/XGDB/images/remote_compute.png" alt="" />&nbsp;List Remote Jobs (HPC) <img id='jobs_viewall' title='Here you view or manage configured GDB. Click ? for details.' class='help-button nudge1' src='/XGDB/images/help-icon.png' alt='?' />
						</h1>
				        <span class="normalfont" style="font-weight:normal">&nbsp; <?php echo $dir1_status ?> <br /> &nbsp; <?php echo $dir2_status ?> </span>
					</td>
					<td>
					</td>
					<td style="padding:10px; border: 1px solid #DDD"> <span class="status_box <?php echo $conditional_display_logout ?>"> 
						<span class="smallerfont"><span class="checked"><?php echo $username ?></span> is authorized to submit jobs</span>
						<span class="smallerfont">(token expires in <span class="alertnotice"><?php echo $time_left ?></span>)</span>
						<br />
						<span class="smallerfont"><?php echo $gsq_message ?></span><br />
						<span class="smallerfont"><?php echo $gth_message ?></span><br />
						<span class="smallerfont"><?php echo $gth_valid_message ?></span>
						</span>
						<span class="<?php echo $conditional_display_logged_out ?> normalfont indent2"><span class="warning">You are not currently authenticated for remote computing on this VM.</span></span>
					</td>
					<td style="padding:10px; border: 1px solid #DDD">
						<span class= "smallerfont <?php echo $conditional_display_refresh ?>">
						    <form action= "/XGDB/jobs/login_exec.php "method= "post">
						        <input type= "hidden" name= "action" value= "refresh" />
						        <input type= "hidden" name= "redirect" value= "jobs" />
                                <input title="Click to refresh your login credentials" type= "submit" name= "refresh" value= "refresh">
                            </form>
                        </span>
						<span class= "smallerfont nowrap <?php echo $conditional_display_logout ?>">
						    <form action= "/XGDB/jobs/logout_exec.php " method= "post">
						        <input type= "hidden" name= "msg" value= "logout" />
						        <input type= "hidden" name= "redirect" value= "jobs" />
                                <input type= "submit" name= "logout" value="log out">
                            </form>
                        </span>
                        <span  class="<?php echo $conditional_display_login ?> nowrap normalfont">
                            <a style="text-decoration: none" href="/XGDB/jobs/login.php#login"> &nbsp; log in</a>
                        </span>
					</td>
				</tr>
			</table>
</div>
		<form method="post" action="/XGDB/jobs/jobs.php" class="styled">
				<span class="normalfont">Search:
				  <select name="field">
					<option value="job_id">Job ID</option>
					<option value="db_id">GDB #</option>
				  </select> 
				  for  </span>
				<input type="text" name="search" size="15" /> <input type="hidden" name="job_passed" value="1" /> <input  id="search" class="submit" type="submit" name="submit" value="Search" />
		 <?php
		if (isset($_SESSION['job_field'])){
			echo "Search on: $searchField = <span style=\"color:red\">$searchWord</span> | <a href=\"/XGDB/jobs/jobs_exec.php?redirect=jobs\">Clear Search Results</a>";
		} else {
			echo "$filter_message";
		}
		
		?>
		</form>
	
<!-- ?php echo "Session Query:".$sessionQuery;
?-->
<div class="description showhide "><p title="Show additional information directly below this link" class="label" style="cursor:pointer"> Click to show instructions...</p>
   <div class=" hidden">";
    <div class="feature">
			<ul class="bullet1">
			    <li>
                    To show current job status, click '<i>Update Status</i>' in a table cell (<span class="alertnotice">NOTE: You must be logged in)</span>. 
<a target="_blank" title="Jobs troubleshooting" href="/XGDB/help/remote_jobs.php#status" class="xgdb_button colorR8 largerfont">&nbsp; <?php echo $status_message ?> &nbsp;</a> </li>
                <li>Job errors/timeout may be the result of <b> HPC server outage</b>; Check <a title="Visit XSEDE User Services newsfeed" href="https://www.xsede.org/news/-/news/search?_usernews_WAR_usernewsportlet_categories=80&_usernews_WAR_usernewsportlet_types=OUTAGE">GSQ (Stampede)</a>; <a target="_blank" title="Visit XSEDE User Services newsfeed" href="https://www.xsede.org/news/-/news/search?_usernews_WAR_usernewsportlet_categories=32&_usernews_WAR_usernewsportlet_keywords=&_usernews_WAR_usernewsportlet_types=OUTAGE">GTH (Lonestar)</a> server status.
                </li>
                <li>
                    To <b>terminate</b> (stop) a job on the remote server, go to <a href="/XGDB/jobs/manage.php">Manage Jobs</a> or use the <a target="_new" href="https://foundation.iplantcollaborative.org/iplant-test/">Foundation API </a> &nbsp; (login required) where you can also delete or troubleshoot job results.
                </li>
                <li>
                    You can <b>Remove</b> job records from this table using the checkboxes in column 1 (this action does not affect job status on remote HPC).
                </li>
			</ul>
    </div>
</div>
</div>
<?php 

#	echo "Current: $current_check; Dev: $dev_check; Offine: $locked_check; All: $all_check <span class=\"heading smallerfont\">Total Query: ".$totalQuery." <br /> Search Query: ".$searchQuery." <br /> Status Query:".$statusQuery."</span>";

# foreach($uid_list as $i => $uid){ // debug only
#    echo "counter=".$i; echo ", uid=".$uid; echo "\n";
#    }
	echo $display_block;
	
	
?>

	 					 </div><!-- end jobs_table-->
					
						<div style="clear:both; float:right">
							<a href="http://validator.w3.org/check?uri=referer"><img
							  src="http://www.w3.org/Icons/valid-xhtml10" alt="Valid XHTML 1.0 Transitional" height="15" width="44" /></a>
						</div>						

					</div><!--end maincontentsfull-->
				</div><!--end maincontentscontainer-->
				<?php include($XGDB_FOOTER); ?>
			</div><!--end innercontainer-->
		</div><!--end outercontainer-->
	</body>
</html>
