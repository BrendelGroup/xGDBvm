<?php
	include('sitedef.php');

if ($_GET['context'][0]) {
	$prefix = $_GET['context'][0];
	$filename = $prefix . ".log";
	}
	else {
	echo "<h2>File not available</h2>";
	};
if ($_GET['context'][1]) {
	$DBid = $_GET['context'][1];
	}
	else {
	$title = 'No GDB';
	};
$filepath = "$filename";

		$fd = fopen($filepath, "r");
		$contents = fread($fd, filesize($filepath));
		fclose($fd);		
$formatted_contents = "
<div class=\"dialogcontainer\" ><h2>$filename <span class=\"heading link\"><a href=\"/XGDB/conf/logfile.php?id=$DBid&amp;file=$prefix\">View as web page</a></span></h2></div>
<div class=\"dialogcontainer\"><pre class=\"smallish\" align=\"left\">$contents</pre></div>";
echo $formatted_contents;

?>

