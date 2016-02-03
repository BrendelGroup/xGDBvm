<?php
session_start();
$clear=isset($_GET['clear'])?$_GET['clear']:"";
$redirect=isset($_GET['redirect'])?$_GET['redirect']:"";
$name=($redirect=="GDBstats")?"GDBstats":"GDBstats";
if($clear=="true")
{
    unset ($_SESSION['stats_search']);
    unset ($_SESSION['stats_field']);
    $msg="cleared";
}else{
    $msg="error";
}
header("Location: ${name}.php?msg=$msg");
?>