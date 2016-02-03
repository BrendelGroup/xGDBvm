<?php
if(empty($SITEDEF_H)){include_once('SITEDEF.php');}
if(empty($PARAM_H)){include_once('getPARAM.php');}
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
if(empty($HELPDIR)){$HELPDIR = dirname(__FILE__).'/help/';}
include_once($HELPDIR . $helpurl); ?>

