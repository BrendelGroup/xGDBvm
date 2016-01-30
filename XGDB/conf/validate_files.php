#### Initiates validation of input, repeatmask, referenceprotein, update data files in response to user action (view.php). Most recent update: Oct 3, 2014 (JPD)
<?php ob_start();
session_start();

### validate form sender or die ###
$post_valid=$_POST['valid']; // if properly set this is a mt_rand() integer; else not set or guessed value
$session_invalid=mt_rand(); 
$session_valid=(isset($_SESSION['valid']))?$_SESSION['valid']:$session_invalid;  // use bogus random # for comparison if no session value
if ($session_valid != $post_valid) // value passed by $_POST should match $_SESSION value; won't match if POST came from another source.
{
    die('Form submission failed validation');
}
if(isset($_POST['id']) && isset($_POST['xgdb']) && (isset($_POST['inputdir']) || isset($_POST['updatedir']) || isset($_POST['refprotfile']) || isset($_POST['repeatmaskfile']) ) ) # need IDs and at least one path
{

global $warning;

##### get posted values, sanitize and set arguments #####
 
	$id=intval($_POST['id']);
	$arg_id=" -i $id ";
	$xgdb=escapeshellarg($_POST['xgdb']);
	$arg_xgdb=" -x $xgdb ";
	$inputdir=escapeshellarg($_POST['inputdir']);
	$arg_inputdir=empty($inputdir)?"":" -n $inputdir "; # optional
	$refprotfile=escapeshellarg($_POST['refprotfile']);
	$arg_refprotfile=empty($refprotfile)?"":" -p $refprotfile "; # optional
	$repeatmaskfile=escapeshellarg($_POST['repeatmaskfile']);
	$arg_repeatmaskfile=empty($repeatmaskfile)?"":" -m $repeatmaskfile ";  # optional
	$updatedir=escapeshellarg($_POST['updatedir']);
	$arg_updatedir=empty($updatedir)?"":" -u $updatedir "; # optional

###### Run validate shell script with arguments ######

	$command =  "/xGDBvm/scripts/xGDB_ValidateFiles.sh $arg_id $arg_xgdb $arg_inputdir $arg_refprotfile $arg_repeatmaskfile $arg_updatedir >> /tmp/log & ";		
	
	exec($command);
	header("Location: view.php?id=$id&result=validated");	
}
else
{
	$warning= "Could not proceed. Unable to validate files";
}
?>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<title>Run validation script- Error</title>
</head>

<body>
<?php echo "$warning"; echo "id=$id xgdb=$xgdb inputdir=$inputdir"; ?>
</body>
</html>
<?php ob_flush();?>
