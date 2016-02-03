<?php

# This script validates file information for user input/output files, displays the data (if called via Javascript) and saves the data to a database table using unique filestamp as identity.
# On subsequent launch the script uses database values preferentially if a filestamp match is found in the database.
# This script also evaluates any temporary 'Catted' files representing multiple files of the same file type. In that case UserFile is set to 'F' since it's not actually a user-created file.


include('sitedef.php');
include_once('/xGDBvm/XGDB/conf/conf_functions.inc.php');
include_once('/xGDBvm/XGDB/phplib/db.inc.php');
$dbpass=dbpass();
$db = mysql_connect("localhost", "gdbuser", $dbpass);
$global_DB="Genomes";
date_default_timezone_set("$TIMEZONE");

if ($_GET['context'][0]) {
	$uid = intval($_GET['context'][0]);
	}
	else {
	echo "<h2>Help not available</h2>";
	};
if ($_GET['context'][1]) {
	$title = $_GET['context'][1];
	}
	else {
	$title = 'Untitled Help';
	};
$HELPDIR = '/xGDBvm/XGDB/help/includes/';
include_once($HELPDIR . $helpurl); ?>

?>

