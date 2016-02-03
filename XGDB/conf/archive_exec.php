<?php
// Buffer output
ob_start();
session_start();

### validate form sender or die ###

$post_valid=$_POST['valid']; // if properly set this is a mt_rand() integer; else not set or guessed value
$session_invalid=mt_rand(); 
$session_valid=(isset($_SESSION['valid']))?$_SESSION['valid']:$session_invalid;  // use bogus random # for comparison if no session value
if ($session_valid != $post_valid) // value passed by $_POST should match $_SESSION value; won't match if POST came from another source.
{
    die('Form submission failed validation');
}

require('/xGDBvm/XGDB/phplib/validation_functions.inc.php'); #validation functions required in this script


// Archive all GDBs - coming from viewall.php or archive.php
if(($_POST['action'] == 'archive_all') && ($_POST['id'] == '') && ($_POST['xgdb'] == ''))
{
#	$page=(isset($_GET['page']))?mysql_real_escape_string($_GET['page']):"viewall";
	$return=$_POST['return'];
	$return=shell_args_whitelist($return); //sanitize 2/26/15
	$warning = "";		
	$command = "/xGDBvm/scripts/xGDB_ArchiveAll.sh & ";
	exec($command);
	header("Location: ${return}.php");
}

// Archive a single GDB - coming from view.php or archive.php
elseif(($_POST['action'] == 'archive_one') && ($_POST['id'] != '') && ($_POST['xgdb'] != ''))
{
	$warning = "";
	$id = $_POST['id'];
	$id=intval($id);
	$xgdb = $_POST['xgdb'];
	$xgdb=shell_args_whitelist($xgdb);
	$return=$_POST['return'];
	$return=shell_args_whitelist($return);
	$return_url=($return=='view')?"view.php?id=$id":"archive.php";
	$command = "/xGDBvm/scripts/xGDB_ArchiveOneGDB.sh $xgdb $id >> /tmp/log & ";
	exec($command);
	header("Location: ${return_url}");			
}
// Delete a single archive under /xGDBvm/data/ArchiveGDB/- coming from archive.php
elseif(($_POST['action'] == 'delete_one') && ($_POST['id'] != '') && ($_POST['xgdb'] != ''))
{
	$warning = "";
	$xgdb = $_POST['xgdb'];
	$xgdb=shell_args_whitelist($xgdb);
	$id = intval($_POST['id']);
	$file = $_POST['source_file']; # Restore_From_File (from Genomes.xGDB_Log), a filename e.g. GDB002-Description-Species.tar
	$file=shell_args_whitelist($file);
	$return="archive.php";
	$return_url=($return=='view')?"view.php?id=$id":"archive.php";
	$command = "/xGDBvm/scripts/xGDB_DeleteOneArchive.sh $xgdb $id $file >> /tmp/log & ";
	exec($command);
	header("Location: ${return_url}");			
}
// Copy archives under /xGDBvm/data/ArchiveGDB/ - coming from archive.php
elseif(($_POST['action'] == 'copy_one'))
{
	$warning = "";
	$xgdb = $_POST['xgdb'];
	$xgdb=shell_args_whitelist($xgdb);
	$id = intval($_POST['id']);
	$file = $_POST['source_file']; # Restore_From_File (from Genomes.xGDB_Log), a filename e.g. GDB002-Description-Species.tar
	$file=shell_args_whitelist($file);
	$return_url="archive.php";
	$command = "/xGDBvm/scripts/xGDB_CopyOneArchive.sh $xgdb $id $file >> /tmp/log & ";
	exec($command);
	header("Location: ${return_url}");			
}
// Delete all archives under /xGDBvm/data/ArchiveAllGDB/ - coming from archive.php
elseif(($_POST['action'] == 'delete_archive_all'))
{
	$warning = "";
	$return="archive.php";
	$return_url=($return=='view')?"view.php?id=$id":"archive.php";
	$command = "/xGDBvm/scripts/xGDB_DeleteArchiveAll.sh >> /tmp/log & ";
	exec($command);
	header("Location: $return_url");			
}
// Error
else
{
	$warning = "Could not proceed. Unable to archive";
	exit();
}

?>

<html>
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
		<title>Error: xGDBvm archive script</title>
	</head>
	<body>
		<?php echo "$warning"; ?>
	</body>
</html>

<?php ob_flush(); ?>
