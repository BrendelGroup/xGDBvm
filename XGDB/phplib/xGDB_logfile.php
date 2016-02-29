<?php
    include('sitedef.php');

if ($_GET['context'][0])
{
	$filepath = $_GET['context'][0];
}
else
{
echo "<h2>File not available</h2>";
}
if ($_GET['context'][1])
{
    $ID = $_GET['context'][1];
}
else 
{
	$title = 'No ID';
}

$file="Pipeline_procedure"; # default

switch ($file) // to prepare a link to logfile.php (it wants the filename minus the file extension, plu ID)
{
	case (preg_match("/Pipeline_procedure/", $filepath) ? true : false):
		$file="Pipeline_procedure";
		break;
	case (preg_match("/Pipeline_error/", $filepath) ? true : false):
		$file="Pipeline_error";
		break;
	case (preg_match("/CpGAT_procedure/", $filepath) ? true : false):
		$file="CpGAT_procedure";
		break;
}

$fd = fopen($filepath, "r");
$contents = fread($fd, filesize($filepath));
fclose($fd);        

$formatted_contents = 
"
    <div class=\"dialogcontainer\" >
        <h2>
            $filepath
            <span class=\"heading link\">
                <a href=\"/XGDB/conf/logfile.php?id=$ID&amp;file=$file\">View as web page</a>
            </span></h2>
    </div>
    <div class=\"dialogcontainer\">
        <pre class=\"smallish\" align=\"left\">
$contents
        </pre>
    </div>
";

echo $formatted_contents;

?>

