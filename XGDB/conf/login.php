<?php
session_start();
$id=mysql_real_escape_string($_GET['id']); //from login_form
#include_once(dirname(__FILE__).'/login_functions.inc.php');	// for required functions: authenticate()
include_once('/xGDBvm/XGDB/jobs/login_functions.inc.php'); # for remote compute option (HPC)

//see http://community.developer.authorize.net/t5/The-Authorize-Net-Developer-Blog/Handling-Online-Payments-Part-6-Preventing-Duplicate-Submissions/ba-p/11168

//Authenticate and get token
# $authenticate=$_POST['action'];//debug

	if($_POST['action']=="authenticate" ) #user is trying to log in.
		{
// get posted values:
	$username=mysql_real_escape_string($_POST['username']);
	$password=mysql_real_escape_string($_POST['password']);
	$auth_url=mysql_real_escape_string($_POST['auth_url']);
	
// assign $_SESSION cookies to user credentials obtained via $_POST
	$_SESSION['username']=$username;
	$_SESSION['password']=$password;	

// Run 'authenticate' function using posted credentials and auth_url:
	$auth= authenticate($username, $password, $auth_url); //AUTHENTICATE: login_functions.inc.php
	$http_code=$auth[0]; //200 = success; 401 = bad username/password 0 = no repsonse (bad URL)
	$token=$auth[1]; //hash string giving user authorization to access remote HPC for limited span
	$expires=$auth[2]; // Unix date of expiry (seconds)
	$issued=$auth[3]; // Unix date of issue (seconds)
	$lifespan=$auth[4]; // life span in seconds
		
// assign $_SESSION cookies based on 'authenticate'  

	$_SESSION['http_code']=$http_code;
	$_SESSION['token']=$token;
	$_SESSION['expires']=$expires; 
	$_SESSION['issued'] = $issued;
	$_SESSION['lifespan']=$lifespan; 
	$_SESSION['auth_url']=$auth_url; 
	
	$_SESSION['login_id']=$id; //use this to remember which GDB was actively logged in to. Go to this one when token expires
		}
		else
		{
		$result="error";
		}
//build header based on ID and result.
header("Location: view.php?id=$id&result=login");
exit;
?>