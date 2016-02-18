<?php 
ob_start(); 
session_start();
include_once('/xGDBvm/XGDB/phplib/db.inc.php'); #reads MySQL password from /xGDBvm/admin/dbpass
$dbpass=dbpass();
$db = mysql_connect("localhost", "gdbuser", $dbpass);
$error="";
if(!$db){
    echo "Error: Could not connect to mysql!";
    exit;
    }
$global_DB= 'Admin';
mysql_select_db('$global_DB');


//this script updates all records in Admin.apps based on posted values from app.php
/*
CREATE TABLE `apps` (
  `uid` int(6) NOT NULL auto_increment,
  `app_id` varchar(255) NOT NULL default '',
  `program` varchar(255) default '',
  `version` varchar(255) default '',
  `platform` varchar(255) NOT NULL default '',
  `nodes` int(3) default NULL,
  `proc_per_node` int(3) default NULL,
  `date_added`  datetime default NULL,
  `description` varchar(255) NOT NULL default '',
  `developer` varchar(255) NOT NULL default '',
  `is_default` enum('Y', 'N') NOT NULL default 'N',
  `max_job_time` varchar(32) NOT NULL default '12:00:00',
*/
// Make sure this is a legitimate process request (prevents browser refresh or illegitimate post from updating app)

$post_valid=mysql_real_escape_string($_POST['valid']); // if properly set this is a mt_rand() integer; else not set or guessed value
$session_invalid=mt_rand(); 
$session_valid=(isset($_SESSION['valid']))?$_SESSION['valid']:$session_invalid;  // use bogus random # for comparison if no session value
if ($session_valid != $post_valid) // value passed by $_POST should match $_SESSION value; won't match if POST came from another source.
{
    die('<div class="feature"><span class="warning normalfont">Form submission failed validation - </span> <a href="/XGDB/jobs/apps.php">Return</a></div>');
}

########## Create New App ###########
// Inserts new app record ; if first app for this program, automatically assign is_default=Y. Return to apps.php and highlight new row.
if
($_POST['action']=="insert")
{
    $app_id=trim(mysql_real_escape_string($_POST['app_id'])); // make sure no leading trailing nonprintables since user may copy this from display
    $program=mysql_real_escape_string($_POST['program']);
    $platform=mysql_real_escape_string($_POST['platform']);
    $nodes=intval($_POST['nodes']);
    $proc_per_node=intval($_POST['proc_per_node']);
    $description=trim(mysql_real_escape_string($_POST['description'])); 
    $developer=trim(mysql_real_escape_string($_POST['developer']));
    $is_default=mysql_real_escape_string($_POST['is_default']);
    $max_job_time=mysql_real_escape_string($_POST['max_job_time']);
    $max_uid=intval($_POST['max_uid']);
    $next_uid=$max_uid+1;

    $query="SELECT uid from ${global_DB}.apps WHERE program='$program'";
    $get_uid = mysql_query($query);
    $program_count=mysql_num_rows($get_uid);
    
    if($is_default=="N" && $program_count==0) # if this is first app for program, force it to be default even if user didn't select it
    {
        $is_default="Y";
    }
    if($is_default=="Y" && $program !="")
    {
        $clear_defaults="UPDATE $global_DB.apps SET is_default='N' WHERE program='$program'"; # set all 
        $clear=mysql_query($clear_defaults);
    }
    $add_app="INSERT INTO $global_DB.apps (app_id, program, platform, nodes, proc_per_node, date_added, description, developer, is_default, max_job_time) values ('$app_id', '$program', '$platform', $nodes, $proc_per_node, now(), '$description', '$developer', '$is_default', '$max_job_time')"; // ADMIN hard-coded on purpose
    $insert=mysql_query($add_app);
    
    if($insert) # 2-17-16 added this loop which will always retrieve the latest uid (for highlighting) even if records were previously deleted.
    {
        $max_query="SELECT MAX(uid) as max_uid from ${global_DB}.apps";
        $get_max = mysql_query($max_query);
        while($row = mysql_fetch_assoc($get_max))
        {
            $max_uid=$row['max_uid'];
        }
        header("location:apps.php#${max_uid}");
    }
    else
    {
        $error="There was a problem inserting $app_id";
    }
    
    mysql_close();

}
elseif($_POST['action']=="remove")
{
######### remove app from list ###########

   $uid=intval($_POST['uid']); //
   $app_id=mysql_real_escape_string($_POST['app_id']);
   $program=mysql_real_escape_string($_POST['program']);
   $update_sql="DELETE FROM $global_DB.apps WHERE uid=$uid";
   $result=mysql_query($update_sql);
   if($result)
   {
        header("location:apps.php?result=removed");
   }
   else
   {
        $error="There was a problem removing $app_id";
   }
mysql_close();

}
elseif($_POST['action']=="default")
{
######### make this app the default ###########

    $uid=intval($_POST['uid']); // 
    $app_id=mysql_real_escape_string($_POST['app_id']);
    $program=mysql_real_escape_string($_POST['program']);
    $uid=intval($_POST['uid']);
    $query1="UPDATE $global_DB.apps SET is_default='N' WHERE (program='$program' AND is_default='Y')"; # strip default status from all apps for this program
    $query2="UPDATE $global_DB.apps SET is_default='Y' WHERE uid=$uid"; # make this one default
    if(mysql_query($query1) && mysql_query($query2))
    {
        header("location:apps.php?result=default#${uid}");
    }
    else
    {
        $error="There was a problem setting $app_id as default ";
    }
        mysql_close();
}


?>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<title>Run xGDBvm script- Error</title>
</head>

<body>
<?php 
echo $error;
 ?>
</body>
</html>
<?php ob_flush();?>