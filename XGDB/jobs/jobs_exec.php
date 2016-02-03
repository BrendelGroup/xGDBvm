<?php
## Clears jobs.php search results but not any status filters in effect.
session_start();
$redirect=isset($_GET['redirect'])?$_GET['redirect']:"jobs.php";
$msg=isset($_GET['msg'])?$_GET['msg']:"cleared";
$msg = preg_replace('/[^A-Za-z0-9\s]/', '', $msg); //sanitize
unset ($_SESSION['job_search']);
unset ($_SESSION['job_field']);
$location=($redirect=="jobs")?"jobs.php":"index.php";
header("Location: ${location}?msg=$msg");
?>