<?php // this script copies output data from archive to the GDB input directory and returns to the initiating script page.
#error_reporting(E_ALL & ~E_NOTICE); //disable undeclared variable error
# Start the php session to be able to pull login and password tokens
session_start();

### validate form sender or die ###

$get_valid=$_POST['valid']; // if properly set this is a mt_rand() integer; else not set or guessed value
$session_invalid=mt_rand(); 
$session_valid=(isset($_SESSION['valid']))?$_SESSION['valid']:$session_invalid;  // use bogus random # for comparison if no session value
if ($session_valid != $get_valid) // value passed by $_POST should match $_SESSION value; won't match if GET came from another source.
{
    die('Form submission failed validation');
}

$global_DB1= 'Genomes';
$global_DB2= 'Admin';
include('sitedef.php');
include_once('/xGDBvm/XGDB/phplib/db.inc.php'); #reads MySQL password from /xGDBvm/admin/dbpass

$inputDir=$XGDB_INPUTDIR; # 1-26-16 J Duvick - e.g /xGDBvm/input/xgdbvm/ (from sitedef.php)
$dataDir=$XGDB_DATADIR; # 1-26-16 J Duvick e.g. /xGDBvm/data
$inputDirMount=$XGDB_INPUTDIR_MOUNT; # 1-26-16 J Duvic, e.g. /xGDBvm/input


$statement="";
$dbpass=dbpass();
$db = mysql_connect("localhost", "gdbuser", $dbpass);
if(!$db)
    {
        echo "Error: Could not connect to database!";
        exit;
    }                                                     
 
 #Other GET variables
$return=$_POST['return']; // e.g. 'jobs'
$job_id=mysql_real_escape_string($_POST['job']); // job id;

$location=($return=="jobs")?"jobs.php":"manage.php";
        
date_default_timezone_set("$TIMEZONE"); // from sitedef.php

if(isset($_POST['job']) && isset($_POST['return'])) 
{

// validate job id, e.g. 3407263385550908955-242ac113-0001-007, and get valid nonce to compare with posted value.
    $pattern='/^\d+-[a-z0-9]+-\d+-\d+$/'; # 2-20-16 I made this check more generic as the structure of this ID string seems to change periodically.
    if(preg_match($pattern, $job_id)) # second level check
    {

		## Get 'Source' MySQL values from Admin.jobs table
		$job_query = "SELECT * FROM $global_DB2.jobs WHERE job_id = '$job_id'"; // job number passed as $_POST
		echo "$job_query \n";
		$get_job = mysql_query($job_query);
		$results = mysql_fetch_assoc($get_job);
		$id = $results['db_id']; // GDB ID, e.g. 1
		$job_id = $results['job_id'];
		$job_name = $results['job_name'];
		$job_name = str_replace(' ', '-', $job_name); // the server does this so we need to emulate
		$job_name = strtolower($job_name); // the server does this so we need to emulate
		$source_dir = "job-${job_id}"; // job-0001424105021858-5056a550b8-0001-007 - this is actually the name of the output directory
		$PROGRAM = $results['program']; // GST, GTH
		$program = strtolower($PROGRAM);
		$seq_type = $results['seq_type']; // est, cdna, tsa, prot
		$count= $results['outcome']; // total sequences
	
		## Put together a SOURCE PATH for the HPC output file:
		$DBid = 'GDB'.substr(('00'. $id),-3);// GDB001
		$source_file="${DBid}${seq_type}.${program}"; // GB001est.gsq
		$out_file="${job_name}-${job_id}.out"; // gth-gdb006-example-1---4-scaffold-hpc-standalone-gth-0001425504861447-5056a550b8-0001-007.out
		$err_file="${job_name}-${job_id}.err"; // gth-gdb006-example-1---4-scaffold-hpc-standalone-gth-0001425504861447-5056a550b8-0001-007.err
		#$extra_dir=($program=="gsq")?"GSQOUTPUT/":""; // Added 12-10-13 to accomodate extra directory level for GSQ
		$extra_dir=""; # 8/25/15
		$source_path="${inputDirMount}/archive/jobs/${source_dir}/${extra_dir}${source_file}"; // e.g. /xGDBvm/input/archive/jobs/job-10073-q3ejd-20130429-202001/GSQOUTPUT/GDB003est.gsq
 		$out_path="/${inputDirMount}/archive/jobs/${source_dir}/${out_file}";
 		$err_path="${inputDirMount}/archive/jobs/${source_dir}/${err_file}";
		## Get 'Destination' MySQL values from 'xGDB_Log.Input_Data_Path', and validate against the possible input paths
		$path_query = "SELECT Input_Data_Path FROM $global_DB1.xGDB_Log WHERE ID=$id";
		$check_get_path = mysql_query($path_query);
		$get_result = mysql_fetch_assoc($check_get_path);
	
		$destination_dir = $get_result['Input_Data_Path']; // e.g. /xGDBvm/input/MyInputData/
		$pattern1 = '/^\/xGDBvm\/data\/[0-9A-Za-z\/]+/'; // we might want to copyt to user input that is here
		$pattern2 = '/^\/xGDBvm\/input\/[0-9A-Za-z\/]+/'; //.. or here
		$pattern3 = '/^\/xGDBvm\/examples\/[0-9A-Za-z\/]+/'; //.. but we want to block attempts to copy here

		# Put together a DESTINATION PATH for the HPC output file:
		$destination_file="job-$job_id.$source_file"; // e.g.  job-10073_GDB003est.gsq
		$destination_out_file="${program}-${DBid}-${job_id}.out"; // shorten it a bit - remove job_name
		$destination_err_file="${program}-${DBid}-${job_id}.err";  // shorten it a bit - remove job_name
		$destination_path="$destination_dir/$destination_file";
		$destination_out_path="$destination_dir/$destination_out_file";
		$destination_err_path="$destination_dir/$destination_err_file";
		
		## If directory exists and path is valid, create distination path, and then copy source file to destination
		if(file_exists($destination_dir) && ((preg_match($pattern1, $destination_dir) || preg_match($pattern2, $destination_dir))))
	#    if(file_exists($destination_dir)) # debug
		{
			if (!copy($source_path, $destination_path))
			{
			   $result ="copy_failed-possible-permission-problem-$source_path-$destination_path";
			}
			else
			{
			   $result ="copy_.${program}_file_succeeded";
			   $date_time=date("Y-m-d H:i:s");
			   
				if (!copy($out_path, $destination_out_path))
				{
				   $result .=" copy_.out_file_failed";
				}
				else
				{
				   $result .=" copy_.out_file_succeeded";
				}
				if (!copy($err_path, $destination_err_path))
				{
				   $result .=" copy_.err_file_failed";
				}
				else
			   {
				   $result .=" copy_.err_file_succeeded";
			   }
			   if ($count>0) # the user has already counted output; so let's make a validation record in Genomes.Datafiles table!
			   {
					$Valid= "T";
					$ValidationTimeStamp=$date_time;
					$FileName=$destination_file;
					$Path=$destination_dir;
					$SeqType=$seq_type; // prot est cdna tsa 
					$SeqTypeCount=0;
					$Format= $program;  // gsq gth
					$Track=$seq_type; //prot
					$EntryCount=$count; 
					$FileStamp=`ls -l --time-style=long-iso $destination_path|awk -F ' ' '{print $8 ":" $5 ":" $6 "-" $7}'  `;  # -rw-r--r--. 1 jduvick root 418605 2014-07-22 17:59 Ex1.gdna.fa; we want $name:$size:${year_month_day}-$time (7:4:5:6) e.g. Ex1.gdna.fa:418605:2014-07-22-17:59
					$FileSize=`ls -l --time-style=long-iso $destination_path|awk -F ' ' '{print $5}'`;
					$insert = "INSERT INTO $global_DB1.Datafiles (Valid, ValidationTimeStamp, Path, SeqType, SeqTypeCount, Format, Track, EntryCount, FileStamp, FileSize) values ('$Valid', '$ValidationTimeStamp', '$Path', '$SeqType', $SeqTypeCount, '$Format', '$Track', $EntryCount, '$FileStamp', $FileSize)";
					$execute_insert = mysql_query($insert);
				}
		   
			   $update = "UPDATE $global_DB2.jobs SET output_copied='Copied ${program} file, .err file, .out file to $destination_dir -- $date_time' where job_id = '$job_id'";
			   $execute_update = mysql_query($update);
			}
		}
		elseif(preg_match($pattern3, $destination_dir))
		{
		$result ="cannot_copy_to_example_dir";
		}
		else
		{
		 $result ="input_data_path_invalid";
		 echo $result;
		}
	}
	else
	{
		 $result ="job_id_invalid";
	}
}
else
{
     $result ="variables_invalid";
}
header("Location: $location?result=$result#$job_id"); // report status
?>

