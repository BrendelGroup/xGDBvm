<?php ob_start();
session_start();

##### Validate form sender or die #####

$post_valid=$_POST['valid']; // if properly set this is a mt_rand() integer; else not set or guessed value
$session_invalid=mt_rand(); 
$session_valid=(isset($_SESSION['valid']))?$_SESSION['valid']:$session_invalid;  // use bogus random # for comparison if no session value
if ($session_valid != $post_valid) // value passed by $_POST should match $_SESSION value; won't match if POST came from another source.
{
    die('Form submission failed validation');
}

##### Defaults Includes and Database Connect #####
$global_DB= 'Genomes';
include_once('/xGDBvm/XGDB/phplib/db.inc.php');
$dbpass=dbpass();
$db = mysql_connect("localhost", "gdbuser", $dbpass);
if(!$db)
{
	echo "Error: Could not connect to mysql!";
	exit;
}
mysql_select_db("$global_DB");

##### POST redirect #####

$id = intval($_POST['id']);
$DBid = 'GDB'.substr(('00'. $id),-3);

if(isset($_POST['redirect']))
{
$redirect=($_POST['redirect']=="archive")?"archive.php#$DBid":(($_POST['redirect']=="viewall")?"viewall.php":"view.php?id=$id&result=dropped");
}else{
$redirect="view.php?id=$id&result=dropped";
}

##### Drop #####
if($_POST['action'] == 'drop') 
{
	$warning="";	
	$DBid = 'GDB'.substr(('00'. $id),-3);
	
		$command = "/xGDBvm/scripts/DropGDB.sh \"$DBid\" \"$id\"";
		exec($command);
        $_SESSION['id']=$id; // reset session value to point to latest GDB modified.
		header("Location: $redirect");
		
}
##### Delete Last Record and reset auto_increment  #####
elseif($_POST['action'] == 'delete_last') // Delete the last GDB completely, including its database, output directory, and  record in Genomes.xGDB_Log;
{
	$warning="";	
	$DBid = 'GDB'.substr(('00'. $id),-3);

        $command1 = "/xGDBvm/scripts/DeleteGDB.sh \"$DBid\" \"$id\"";
        exec($command1);
        # reset session variables
        $maxIDQuery="SELECT MAX(ID) as max_id FROM $global_DB.xGDB_Log";
        $get_maxIDQuery=mysql_query($maxIDQuery);
        $maxIDQuery_result=mysql_fetch_array($get_maxIDQuery);
        $maxID=$maxIDQuery_result['max_id'];
        $_SESSION['id']=isset($maxID)?$maxID:"1"; // reset session value to point to latest GDB not deleted.
        $_SESSION['gdbid'] = 'GDB'.substr(('00'. $maxID),-3);
        header("Location: archive.php?result=delete&id=$id");
}

##### Abort Pipeline #####
elseif($_POST['action'] == 'abort')
{
	$warning="";	
	$DBid = 'GDB'.substr(('00'. $id),-3);
        
    $command = "/xGDBvm/scripts/AbortGDB.sh \"$DBid\" \"$id\"";
    $_SESSION['id']=$id; // reset session value to point to latest GDB modified.
    exec($command);
            
    header("Location: view.php?id=$id&result=aborted");
    
}
else
{
    $warning= "Could not proceed. Unable to update $DBid ";
    exit();
}

?>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<title>xGDBvm Error</title>
</head>

<body>
<?php echo "$warning"; ?>
</body>
</html>
<?php ob_flush();?>
