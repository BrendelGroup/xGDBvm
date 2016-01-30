<?php ob_start();
session_start();
$post_valid=$_POST['valid'];
$session_valid=$_SESSION['valid'];
if ($session_valid != $post_valid) {
    die('Form submission failed validation');
}

if($_POST['action'] == 'deleteall'){
	$warning="";		
		session_destroy(); // get rid of all session variables, both job-related and GDB -related.
		$command = "/xGDBvm/scripts/DeleteAllGDB.pl";
		$redirect=($_POST['redirect']=="archive")?"archive.php":(($_POST['redirect']=="viewall")?"viewall.php":"index.php");
		exec($command);
		header("Location: $redirect?action=deletepall");
		
		}else{

		$warning= "Could not proceed. Unable to delete all";
		
		exit();
	}

?>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<title>Run xGDBvm script- Error</title>
</head>

<body>
<?php echo "$warning"; ?>
</body>
</html>
<?php ob_flush();?>
