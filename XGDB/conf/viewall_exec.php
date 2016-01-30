<?php
session_start();
$clear=isset($_GET['clear'])?$_GET['clear']:"";
$redirect=isset($_GET['redirect'])?$_GET['redirect']:"";
$name=($redirect=="viewall")?"viewall":(($redirect=="archive")?"archive":"viewall");
if($clear=="true")
{
    unset ($_SESSION['gdb_search']);
    unset ($_SESSION['gdb_field']);
    $msg="cleared";
}else{
    $msg="error";
}
header("Location: ${name}.php?msg=$msg");
?>