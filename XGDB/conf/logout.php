<?php
session_start();
$id=isset($_GET['id'])?intval($_GET['id']):"1";
$redirect=isset($_GET['redirect'])?$_GET['redirect']:"view";
$msg=isset($_GET['msg'])?$_GET['msg']:"expired";
$msg = preg_replace('/[^A-Za-z0-9]/', '', $msg); 
unset ($_SESSION['token']);
unset ($_SESSION['expires']);
unset ($_SESSION['issued']);
unset ($_SESSION['lifespan']);
unset ($_SESSION['http_code']);
unset ($_SESSION['username']);
unset ($_SESSION['auth_url']);
$name=($redirect=="view")?"view.php":(($redirect=="viewall")?"viewall.php":"index.php");
header("Location: ${name}?id=$id&msg=$msg");

?>