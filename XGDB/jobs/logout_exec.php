<?php
session_start();
$id=isset($_REQUEST['id'])?intval($_REQUEST['id']):"";
$redirect=isset($_REQUEST['redirect'])?$_REQUEST['redirect']:"login";
$msg=isset($_REQUEST['msg'])?$_REQUEST['msg']:"";
$msg_display = preg_replace('/[^A-Za-z0-9\_]/', '', $msg); //sanitize

# For all logout types, reset session values related to access token: 

unset($_SESSION['access_token']);
unset($_SESSION['expires']);
unset($_SESSION['issued']);
unset($_SESSION['lifespan']);
unset($_SESSION['http_code']);

# For 'refresh' logout, in addition reset session value for refresh token: 

if($msg=="refresh")
{
unset($_SESSION['refresh_token']);
$msg_display="bad_refresh_token";
}

# NOTE we don't reset session values for refresh_token, username, or auth_url

# Determine redirect

$name="login.php?"; #default redirect

switch ($redirect)
    {
case "configure":
    $name="configure.php?";
    break;
case "submit":
    $name="submit.php?id=$id&amp;";
    break;
case "login":
    $name="login.php?";
    break;
case "manage":
    $name="manage.php?";
    break;
case "index":
    $name="index.php?";
    break;
case "jobs":
    $name="jobs.php?";
    break;
case "view":
    $name="../conf/view.php?id=$id&amp;";
}
header("Location: ${name}result=$msg_display");

?>