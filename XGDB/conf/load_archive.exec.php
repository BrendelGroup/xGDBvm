<?php ob_start(); // loads archive data to new or existing xGDB_Log data row, and points the xGDB_Log to the correct ArchiveGDB/GDBnnn-[name].tar.bz2 file
include_once('/xGDBvm/XGDB/phplib/db.inc.php');
$dbpass=dbpass();
    $VM=`uname -n|cut -d "." -f 1`; # identifies this VM (used for $archive_dir function)
    $VM=preg_replace( "/\r|\n/", "", $VM ); // strip line feed
	$global_DB= 'Genomes';
	$db = mysql_connect("localhost", "gdbuser", $dbpass);
	if(!$db)
	{
		$warning= "Error: Could not connect to database!";
		exit;
	}
	mysql_select_db("$global_DB");

	$mysqluser='gdbuser';
	$ArchiveDir="/xGDBvm/data/ArchiveGDB";

$action=$_POST['action'];
if($action=='gdb_load_archive') //user has requested to replace existing Config with an archived Config
	 {
		 $warning="";		
		 $id=mysql_real_escape_string($_POST['ID']); // the destination ID, e.g. 1 
		 $xgdb=mysql_real_escape_string($_POST['xgdb']); // the destination GDB ID, e.g. GDB001
		 $file=($_POST['file']); // e.g. GDB002-[description-species].tar
		 $pattern = "/^(GDB\d\d\d)(-\S+)(\.tar)$/";
		 if (preg_match($pattern, $file, $matches))
			{
				$xgdb_source=$matches[1]; // e.g. GDB001
			}

		 $id_source=intval(substr($xgdb_source,-3)); // e.g. 2
      ### We are going to pluck xGDB_Log.txt out of the source tarball (POSTed $file) and swap its ID number with destination ID, in order to use the file in the creation of a destination config entry having the destination ID
        $command0="cd $ArchiveDir; tar --extract --file=${file} xGDB_Log.txt"; // # Extract the xGDB_Log.txt file from tarball, whose filename starts with the source GDB ID, e.g. GDB001-:
        $command1="echo \"delete from $global_DB.xGDB_Log where ID=$id\"|mysql -p$dbpass -u$mysqluser Genomes"; // we are going to replace this database entry with "Restore" data using the same ID
		$command2="sed  -i \"1s/^[0-9]*\\t/$id\\t/\" $ArchiveDir/xGDB_Log.txt "; # replace archive ID with destination ID
		$command3="/usr/bin/mysqlimport --local -p$dbpass -u$mysqluser $global_DB $ArchiveDir/xGDB_Log.txt"; # the data get loaded to Genomes.xGDB_log with destination ID (--local gets around permission problem)
		$command4="echo \"UPDATE $global_DB.xGDB_Log SET Restore_From_File='$file', Archive_Date=now(), Status='Development', DBname=concat(DBname,' (from $xgdb_source archive)') WHERE ID=$id\"|mysql -p$dbpass -u$mysqluser Genomes"; # Log the ID swap data in xGDB_Log database table entry.
        $command5= "rm -rf $ArchiveDir/xGDB_Log.txt"; # we are finished with this modified file so delete it. There is still the original copy in the tarball, of course.
		exec($command0);
		exec($command1);
		exec($command2);
		exec($command3);
		exec($command4);
		exec($command5);

			header("Location: view.php?id=$id");
		exit();
	}
	elseif($action=='new_load_archive')  // User has requested a new Config, to be loaded with archived Config data
	{
		 $warning="";		
		 $file=($_POST['file']); // e.g. GDB002-[description-species].tar
		 $pattern = "/^(GDB\d\d\d)(-\S+)(\.tar)$/";
		 if (preg_match($pattern, $file, $matches))
			{
				$xgdb_source=$matches[1]; // e.g. GDB001
			}

		 $id_source=intval(substr($xgdb_source,-3)); // e.g. 2
		 
		// Get next integer ID
			$id_query = "select ID from $global_DB.xGDB_Log order by ID DESC limit 1";
			$check_id = mysql_query($id_query);
			$new_id_array = mysql_fetch_array($check_id);
			$new_id = $new_id_array['ID'];		  
			$new_id = $new_id+1;		  

      ### We are going to pluck xGDB_Log.txt out of the source tarball (POSTed $file) and swap its ID number with destination ID, in order to use the file in the creation of a destination config entry having a NEW ID
            $command0="cd $ArchiveDir; tar --extract --file=${file} xGDB_Log.txt"; // # Extract the xGDB_Log.txt file from tarball:
			$command1="sed -i \"1s/^[0-9]*\\t/$new_id\\t/\" $ArchiveDir/xGDB_Log.txt "; # replace archive ID with destination ID
			$command2="/usr/bin/mysqlimport --local -p$dbpass -u$mysqluser $global_DB $ArchiveDir/xGDB_Log.txt"; # --local gets around permission problem
			$command3="echo \"UPDATE $global_DB.xGDB_Log SET Restore_From_File='$file', Status='Development', DBname=concat(DBname,' (from $xgdb_source archive)') WHERE ID=$new_id\"|mysql -p$dbpass -u$mysqluser Genomes";  # Log the ID swap data in xGDB_Log
            $command4= "rm -rf $ArchiveDir/$xgdb_source/xGDB_Log.txt"; // we are finished with this file so delete it. There is still the original copy in the tarball, of course.
		    exec($command0);
            exec($command1);
            exec($command2);
            exec($command3);
            exec($command4);
			header("Location: view.php?id=$new_id");
		exit();

	}else{

		$warning= "Could not proceed. Unable to restore";
		
#		exit();
	}

	?>

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<title>Run xGDBvm script- Error</title>
</head>

<body>

<h1>TEST</h1>
<?php echo " warning="; "$warning"; echo " <br /> action="; echo $action; echo " <br /> command1="; echo $command1; echo " <br /> command2=";  echo $command2; echo "<br /> command3="; echo $command3; echo "<br /> command4=";  echo $command4; ?>
 
</body>
</html>
<?php ob_flush();?>
