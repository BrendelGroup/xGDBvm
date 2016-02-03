<?php // this script counts number of matches in a (GTH or GSQ) spliced alignment output file
#error_reporting(E_ALL & ~E_NOTICE); //disable undeclared variable error

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

$inputDir=$XGDB_INPUTDIR; # 1-26-16 J Duvick - e.g /xGDBvm/input/xgdbvm/ (from sitedef.php)
$dataDir=$XGDB_DATADIR; # 1-26-16 J Duvick e.g. /xGDBvm/data
$inputDirMount=$XGDB_INPUTDIR_MOUNT; # 1-26-16 J Duvic, e.g. /xGDBvm/input

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
    $return_page=($return=="jobs")?"jobs.php":(($return=="manage")?"manage.php":"index.php");
    
## Get  Base URL, version from Admin database;

	$auth_query="SELECT auth_url, api_version from $global_DB.admin where auth_url !='' order by uid DESC limit 0,1";
	$auth_result = mysql_query($auth_query);
	$auth=mysql_fetch_array($auth_result);
	$base_url=$auth['auth_url'];
	$api_version=$auth['api_version'];

    $access_token=$_SESSION['access_token']; #  TODO: Check VM-stored version of session

    if($action=="matches")
    {
        $query = "Select job_id, seq_type, program from $global_DB.jobs WHERE job_id = '$job_id'"; //
        $query_result= mysql_query($query);
        $array=mysql_fetch_assoc($query_result);
        $job_id=$array['job_id'];
        $seq_type=$array['seq_type'];
        $PROGRAM=$array['program'];
        $program=strtolower($PROGRAM); // e.g. gsq, gth
        #$extra_dir=($program=="gsq")?"GSQOUTPUT/":""; 
        $extra_dir=""; # 8/25/15
        $path="${inputDirMount}archive/jobs/job-${job_id}/${extra_dir}*${seq_type}.${program}";
        $match=`grep -c "MATCH" $path`; # supposedly this speeds up search for simple match 
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
    else
    {
        $result="incorrect_parameter";
    }

header("Location: $return_page?result=${result}#${job_id}"); // report status and highlight status table cell which should now be updated
?>

