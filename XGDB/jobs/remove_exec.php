<?php
session_start();
//this script removes (deletes) a record from  the jobs table in response to user action. Returns to jobs.php
include_once('/xGDBvm/XGDB/phplib/db.inc.php');
include('sitedef.php');
$global_DB= 'Admin';

$dbpass=dbpass();
$db = mysql_connect("localhost", "gdbuser", $dbpass);
if(!$db)
{
	echo "Error: Could not connect to database!";
	exit;
}
mysql_select_db("$global_DB");

// Make sure this is a legitimate process request (prevents browser refresh or illegitimate post from intiating job process)
$post_valid=mysql_real_escape_string($_POST['valid']); // if properly set this is a mt_rand() integer; else not set or guessed value
$session_invalid=mt_rand(); 
$session_valid=(isset($_SESSION['valid']))?$_SESSION['valid']:$session_invalid;  // use bogus random # for comparison if no session value
if ($session_valid != $post_valid) // value passed by $_POST should match $_SESSION value; won't match if POST came from another source.
{
    die('<div class="feature"><span class="warning normalfont">Form submission failed validation </span> <a href="/XGDB/jobs/jobs.php">Return</a></div>');
}


date_default_timezone_set("$TIMEZONE"); // from sitedef.php


// get other POST variables;

$username=mysql_real_escape_string($_POST['username']); 
$job_id=mysql_real_escape_string($_POST['job']);
$action=mysql_real_escape_string($_POST['action']); // 'remove'
$return=mysql_real_escape_string($_POST['return']); // redirect
$uid=intval($_POST['uid']); 

// parse redirect
$location="jobs.php"; // default
switch ($return) 
{
case "jobs":
	$location = "jobs.php";
	break;
case "manage":
	$location = "manage.php"; // in case we add this feature.
}

if($_POST['action']=="remove" && isset($_SESSION['username']) && $_SESSION['username']==$username) // user should only be able to remove their records.
{

	//lockout status options (don't allow remove): PENDING, SUBMITTING, STAGING_JOB, PROCESSING_INPUTS, QUEUED, RUNNING,
	//non-lockout status options (allow remove): FAILED, STOPPED, KILLED, FINISHED, TIMEDOUT
	$delete_query="delete from $global_DB.jobs where (user='$username' AND uid='$uid' AND status !='PENDING' AND status !='SUBMITTING'  AND status !='STAGING_INPUTS' AND status !='STAGING_JOB' AND status !='PROCESSING_INPUTS' AND status!='QUEUED' AND status!='RUNNING' AND status!='ARCHIVING' AND status!='CLEANING_UP')";
	$do_delete = mysql_query($delete_query);
	
	//Find next uid (if any) or previous uid to return to.
	$next_uid_query="SELECT uid from $global_DB.jobs where uid>$uid order by uid ASC limit 1 ";
	$get_next_uid = mysql_query($next_uid_query);
	$row=mysql_fetch_array($get_next_uid);
	$next_uid=$row['uid'];
	
	$prev_uid_query="SELECT uid from $global_DB.jobs where uid<$uid order by uid DESC limit 1";
	$get_prev_uid = mysql_query($prev_uid_query);
	$row=mysql_fetch_array($get_prev_uid);
	$prev_uid=$row['uid'];
	
	$next_uid=($next_uid!="")?$next_uid:$prev_uid; // highlight the next or previous row on return.
	
	
	header("Location: $location?deleted=yes&uid=${uid}#${next_uid}");

}
else
{
header("Location: $location?deleted=none&username=${username}&uid=${uid}");
}

?>