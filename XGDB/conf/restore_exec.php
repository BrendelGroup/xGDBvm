<?php ob_start(); //This script is called by view.php or archive.php and calls a shell script to load GDB data from /xGDBvm/data/ArchiveAll (all GDB) or /xGDBvm/data/ArchiveGDB (single)

session_start();

require('/xGDBvm/XGDB/phplib/validation_functions.inc.php'); #validation functions required in this script

### validate form sender or die ###

$post_valid=$_POST['valid']; // if properly set this is a mt_rand() integer; else not set or guessed value
$session_invalid=mt_rand(); 
$session_valid=(isset($_SESSION['valid']))?$_SESSION['valid']:$session_invalid;  // use bogus random # for comparison if no session value
if ($session_valid != $post_valid) // value passed by $_POST should match $_SESSION value; won't match if POST came from another source.
{
    die('Form submission failed validation');
}


### POST actions ###

if($_POST['action'] == 'restore_all') //Restore ALL GDB
{ 
	$warning="";
        $return=$_POST['return'];
        $return_url=($return=="archive")?"archive.php":(($return=="viewall")?"viewall.php":"index.php");
		$command = "/xGDBvm/scripts/xGDB_RestoreAll.sh";
		exec($command);
		header("Location: ${return_url}");
}
elseif(($_POST['action'] == 'restore_one') && ($_POST['id'] != '') && ($_POST['xgdb'] !='')) // Restore ONE GDB
{
   $warning="";		
   $id=intval($_POST['id']); // e.g. 1, the ID of the GDB requesting restoration
   $xgdb=$_POST['xgdb']; //e.g. GDB001, the GDBID of the GDB requesting restoration
   $xgdb=shell_args_whitelist($xgdb); // sanitize 2/26/15
   $source_file=$_POST['source_file']; //e.g GDB002-[description-species].tar; The archive source may be the SAME numbered GDB archive as the current GDB, or (if specified by user and stored in xGDB_Log.Restore_From_OtherGDB) a DIFFERENT-numbered GDB archive....
   $pattern = "/^(GDB\d\d\d)(-\S+)(\.tar)$/"; # Parse the GDB ID from the source filename
   if (preg_match($pattern, $source_file, $matches))
	  {
		  $xgdb_source=$matches[1]; // e.g. GDB001
	  }
   else  # Source file not named correctly
      {
      $warning = "The archive source file is incorrectly named or missing, and it could not be loaded";
      exit();
      }
   $id_source=intval(substr($xgdb_source,-3));// e.g. 2
   $return=$_POST['return'];
   $return_url=($return=='view')?"view.php?id=$id":"archive.php#$xgdb";
   $command = "/xGDBvm/scripts/xGDB_RestoreOneGDB.sh $xgdb $id $xgdb_source $id_source  >> /tmp/log & ";
   error_log("$command");
   exec($command);
   header("Location: $return_url");
}
else
{ 
   $warning= "Could not proceed. Unable to restore";
   exit();
}

?>

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<title>Run xGDBvm script- Error</title>
</head>

<body>
<?php echo "$warning"; ?>
</body>
</html>
<?php ob_flush();?>
