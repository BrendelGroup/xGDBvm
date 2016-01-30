<?php ob_start(); //This script is called by /xGDBvm/XGDB/cgi-bin/xGDB_CpGATOut.pl 

session_start();

### validate form sender or die ###

#$post_valid=$_GET['valid']; // if properly set this is a mt_rand() integer; else not set or guessed value
#$session_invalid=mt_rand(); 
#$session_valid=(isset($_SESSION['valid']))?$_SESSION['valid']:$session_invalid;  // use bogus random # for comparison if no session value
#if ($session_valid != $post_valid) // value passed by $_GET should match $_SESSION value; won't match if POST came from another source.
#{
#    die('Form submission failed validation');
#}

###### Connect to database ######
$global_DB="Genomes";
include_once('/xGDBvm/XGDB/phplib/db.inc.php'); 
$dbpass=dbpass();
$db = mysql_connect("localhost", "gdbuser", $dbpass);
if(!$db)
{
	echo "Error: Could not connect to database!";
	exit;
}
mysql_select_db("$global_DB");

### GET actions ###
   $update=$_GET['update']; 
#   $update=($update=="append")?"Append":"Replace";
   $file_path=$_GET['file_path']; //file path, e.g. /xGDBvm/tmp/GDB001/CpGAT/CpGAT-1398372293/
   $file_prefix=$_GET['file_prefix']; // file prefix, e.g. scaff_28153from1to90000
   $GDB=$_GET['GDB']; //e.g. GDB001, the GDBID of the GD
   $id=intval(substr($GDB,-3)); // e.g. 1
   $filter_status=$_GET['filter_status']; // e.g. 'filtered' or'unfiltered')
   $filter_status=($filter_status=="filtered")?"filtered":"unfiltered";
   
### Validate file path
    $pattern = "/^\/xGDBvm\/tmp\/${GDB}\/CpGAT\/CpGAT-\d*\/$/"; #
   if (preg_match($pattern, $file_path, $matches))
	  {

### Build the source and destination filepaths	  
      $gff_source_path=$file_path.$file_prefix.".".$filter_status.".gff3";
      $mrna_source_path=$file_path. $file_prefix.".".$filter_status.".trans";
      $pep_source_path=$file_path. $file_prefix.".".$filter_status.".pep";

### Create the update directory (remove any old one)      
      $update_dir=$file_path."/update/"; // e.g. /xGDBvm/tmp/GDB001/CpGAT/CpGAT-1398372293/update/
      if(file_exists($update_dir)){
	  $remove_update_dir = "rm -rf $update_dir"; // Note $filepath is validated above!
      exec($remove_update_dir);
      }
      mkdir($update_dir,0777);
      
      $gff_dest_path=$update_dir.$file_prefix.".".$filter_status.".cpgat.gff3"; // e.g. /xGDBvm/tmp/GDB001/CpGAT/CpGAT-1398372293/update/scaff_28153from1to90000.filtered.cpgat.gff3
      $mrna_dest_path=$update_dir.$file_prefix.".".$filter_status.".cpgat.mrna.fa";
      $pep_dest_path=$update_dir.$file_prefix.".".$filter_status.".cpgat.pep.fa";

### Cat the source to destination
      
      $cat_gff =  "cat $gff_source_path  >$gff_dest_path";  // 
      $cat_mrna =  "cat $mrna_source_path  >$mrna_dest_path";  // 
      $cat_pep=  "cat $pep_source_path  >$pep_dest_path";  // 

  exec($cat_gff);  //      
  exec($cat_mrna);  //     
  exec($cat_pep);  //     

### Update the Genomes.xGDB_Log entry for Update_Status, Update_Path, Update_Action

	$statement1="update Genomes.xGDB_Log set Update_Status=\"Update\" where ID=$id";
	$statement2="update Genomes.xGDB_Log set Update_Data_CpGATModel=\"$update\" where ID=$id";
	$statement3="update Genomes.xGDB_Log set Update_Data_Path=\"$update_dir\" where ID=$id";
	$do_statement1 = mysql_query($statement1);
	$do_statement2 = mysql_query($statement2);
	$do_statement3 = mysql_query($statement3);


   	  }
   else  # Source file not named correctly
      {
      $warning = "The archive source file is incorrectly named or missing, and it could not be identified";
      exit();
      }
      
      
   $return=$_GET['return'];
   $return_url ="/XGDB/conf/view.php?id=$id";
   $command = "$return  >> /tmp/log & ";
   error_log("$command");
   exec($command);
   header("Location: $return_url");
?>

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<title>Run xGDBvm script- Error</title>
</head>

<body>
<?php echo "return: $return"; echo "file_path: $file_path <br />"; echo "GDB: $GDB <br />"; echo "filter_status: $filter_status" ?> # debug only
<?php echo "warning"; ?>
</body>
</html>
<?php ob_flush();?>
