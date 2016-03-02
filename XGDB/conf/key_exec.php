<?php
// Buffer output
ob_start();
session_start();
include_once('sitedef.php'); // where license keys are configured.

### validate form sender or die ###

$post_valid=$_POST['valid']; // if properly set this is a mt_rand() integer; else not set or guessed value
$session_invalid=mt_rand(); 
$session_valid=(isset($_SESSION['valid']))?$_SESSION['valid']:$session_invalid;  // use bogus random # for comparison if no session value
if ($session_valid != $post_valid) // value passed by $_POST should match $_SESSION value; won't match if POST came from another source.
{
    die('Form submission failed validation');
}
$inputDir=$XGDB_INPUTDIR; # 1-26-16 J Duvick
$dataDir=$XGDB_DATADIR; # 1-26-16 J Duvick
$gm_dir= $GENEMARK_KEY_DIR; //e.g. "/usr/local/src/GENEMARK/genemark_hmm_euk.linux_64/";
$gm_key_destination=$GENEMARK_KEY; //e.g. ".gm_key"
$gm_key_distribution=str_replace('.','', $gm_key_destination); // distributed without a "."
$gth_dir=$GENOMETHREADER_KEY_DIR; //e.g. "/usr/local/bin/";
$gth_key=$GENOMETHREADER_KEY; //e.g. "gth.lic";
$vm_dir=$VMATCH_KEY_DIR; //e.g. "/usr/local/bin/";
$vm_key=$VMATCH_KEY; //e.g. "vmatch.lic";

$warning='';

// copy genomethreader key 
if($_POST['action'] == 'gth')
{
    $id="gth";
	$source_path="$inputDir/keys/$gth_key";
	$destination_path = "$gth_dir/$gth_key";		
	
    if (!copy($source_path, $destination_path))
    {
       $warning ="failed to copy $gth_key...\n";
    }
    else
    {
    	header("Location: licenses.php?action=gth#gth");
    }
}
elseif($_POST['action'] == 'vm')
{
	$source_path="$inputDir/keys/$vm_key";
	$destination_path = "$vm_dir/$vm_key";		
	
    if (!copy($source_path, $destination_path))
    {
       $warning ="failed to copy $vm_key...\n";
    }
    else
    {
    	header("Location: licenses.php?action=vm#vm");
    }
}
elseif($_POST['action'] == 'gm')
{
	$source_path="$inputDir/keys/$gm_key_distribution";
	$source_path_alt="$inputDir/keys/$gm_key_destination"; // "." may be present
	$destination_path = "${gm_dir}${gm_key_destination}";	
	
    if (file_exists($source_path) && !copy($source_path, $destination_path))
    {
       $warning ="failed to copy $inputDir/keys/$gm_key_distribution to ${gm_dir}${gm_key_destination}...\n";
    }
    elseif (file_exists($source_path_alt) && !copy($source_path_alt, $destination_path))
    {
       $warning ="failed to copy $inputDir/keys/$gm_key_destination to ${gm_dir}${gm_key_destination}...\n";
    }
    else 
    {
    	header("Location: licenses.php?action=gm#gm");
    }
}
else
{
	$warning = "Could not proceed. Unable to take any action";
	exit();
}

?>

<html>
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
		<title>Error: xGDBvm key install</title>
	</head>
	<body>
		<?php echo "$warning"; ?>
	</body>
</html>

<?php ob_flush(); ?>
