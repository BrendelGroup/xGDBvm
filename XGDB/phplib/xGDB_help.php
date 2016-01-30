<?php
if ($_GET['context'][0]) {
	$help = $_GET['context'][0];
	$helpurl = $help . ".inc.php";
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

