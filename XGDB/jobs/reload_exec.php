<?php
session_start();

# $authenticate=$_POST['action'];//debug

if($_POST['action']=="reload" ) #
	{

$return=mysql_real_escape_string($_POST['return']); //point script back to the page it came from
$job_id=mysql_real_escape_string($_POST['job_id']); //
$location="jobs.php"; //default
		
		switch ($return) 
		{
    case "jobs":
        $location = "jobs.php";
        break;
    case "submit":
        $location = "submit.php";
		}
		
header("Location: ${location}#${job_id}");
}
else
{
exit;
}
?>
