<?php ob_start(); #removes error text from Pipeline_error.log, called by view.php
session_start();

##### Validate form sender or die #####

$post_valid=$_POST['valid']; // if properly set this is a mt_rand() integer; else not set or guessed value
$session_invalid=mt_rand(); 
$session_valid=(isset($_SESSION['valid']))?$_SESSION['valid']:$session_invalid;  // use bogus random # for comparison if no session value
if ($session_valid != $post_valid) // value passed by $_POST should match $_SESSION value; won't match if POST came from another source.
{
    die('Form submission failed validation');
}

##### POST redirect #####

$id = intval($_POST['id']);

if(isset($_POST['redirect']))
{
$redirect=($_POST['redirect']=="view")?"view.php?id=$id":"viewall.php";
}else{
$redirect="viewall.php";
}

##### Drop #####
$post_action=isset($_POST['action'])?$_POST['action']:"";
if($post_action == 'clear') 
{
	$warning="";
	$DBid = 'GDB'.substr(('00'. $id),-3);
	$file="/xGDBvm/data/$DBid/logs/Pipeline_error.log";
	if(file_exists($file))
	{
		$blank = '';
        file_put_contents($file, $blank);
        $_SESSION['id']=$id; // reset session value to point to latest GDB modified.
		header("Location: $redirect");

	}
}
else
{
    $warning= "Could not proceed. Unable to clear $DBid error log";
    exit();
}

?>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<title>xGDBvm Error</title>
</head>

<body>
<?php echo "$warning"; ?>
</body>
</html>
<?php ob_flush();?>
