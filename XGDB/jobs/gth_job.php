<?php // Latest update: 7-11-16 JDuvick 
error_reporting(E_ALL & ~E_NOTICE); //disable undeclared variable error
// Start the php session to be able to pull login and password tokens
	session_start();
	$global_DB= 'Admin';
	$PageTitle = 'External Processes';
	$pgdbmenu = 'Jobs';
	$submenu = 'Process';
	$leftmenu='Jobs-Process';
	include('sitedef.php');
	include($XGDB_HEADER);
    $Create_Date = date("m-d-Y");
 	include_once('/xGDBvm/XGDB/phplib/db.inc.php'); #reads MySQL password from /xGDBvm/admin/dbpass
	include_once('/xGDBvm/XGDB/jobs/jobs_functions.inc.php'); #common functions required in this script
	require('/xGDBvm/XGDB/phplib/validation_functions.inc.php'); #common functions required in this script	
	
	$emboss_path=$EMBOSS; # sitedef.php  ; 1-20-2016
	$inputDIR=$XGDB_INPUTDIR; # 1-26-2016 
	$inputTopDir=$INPUT_TOPDIR; # 1-26-2016 top level directory for xGDBv -related files on user's iPlant Data Store, e.g. xgdbvm/

date_default_timezone_set("$TIMEZONE"); // from sitedef.php
//
// This script for Standalone HPC jobs creates a job URL for remote GenomeThreader processing based on values posted from submit.php.  
// It communicates with a wrapper script that parses the json output to create a GenomeThreader command line call. (See submit.php for parameter names). The script also stores job-related data in Admin.jobs (if successsfully submitted)

//access MySQL
$dbpass=dbpass();
$db = mysql_connect("localhost", "gdbuser", $dbpass);
if(!$db)
	{
		echo "Error: Could not connect to database!";
		exit;
	}
	
// Make sure this is a legitimate process request (prevents browser refresh or illegitimate post from intiating job process)
$post_valid=$_POST['valid']; // if properly set this is a mt_rand() integer; else not set or guessed value
$session_invalid=mt_rand(); 
$session_valid=(isset($_SESSION['valid']))?$_SESSION['valid']:$session_invalid;  // use bogus random # for comparison if no session value
if ($session_valid != $post_valid) // value passed by $_POST should match $_SESSION value; won't match if POST came from another source.
{
    die('<div class="feature"><span class="warning normalfont">Form submission failed validation (it may have already been sent)</span> <a href="/XGDB/jobs/submit.php">Return</a></div>');
}

// grab session variables
	$username=$_SESSION['username'];
	$access_token=$_SESSION['access_token'];
	
//grab posted ID and create GDBid
	$ID=intval($_POST['id']); # e.g. 1
	$IDjustify="00".$ID;
	$DBid = "GDB".substr($IDjustify, -3, 3);

//grab and sanitize other posted values from submit.php
	 $version=mysql_real_escape_string($_POST['version']); # Agave
	 $app_id=mysql_real_escape_string($_POST['gth_app_id']); # Agave,
     $base_url=mysql_real_escape_string($_POST['auth_url']); # Agave; this is the base url
     $api_version=mysql_real_escape_string($_POST['api_version']); # Agave; this is current version e.g. v2
	 $inputGenomic=mysql_real_escape_string($_POST['input_g']);//temp input path for Genome File e.g. /username/xgdbvm/tmp/GDB002_hpcs/SCFDIR/GDB002gdna.fa	
	 $inputProtein=mysql_real_escape_string($_POST['input_p']);//temp input path for Protein File e.g. /username/xgdbvm/tmp/GDB002_hpcs/Protein/GDB002prot.fa	
	 $gth_split=intval($_POST['gth_split']);
	 $total_scaffold_count=intval($_POST['total_scaffold_count']);
	 $Species=mysql_real_escape_string($_POST['Species']);
	 $requested_time=mysql_real_escape_string($_POST['requested_time']);
	 $admin_email=mysql_real_escape_string($_POST['admin_email']);
	 $input_data_path=mysql_real_escape_string($_POST['input_data_path']); //
	 $transcript_type="prot"; //by definition, the only type for GenomeThreader
	 $gth_job_name=mysql_real_escape_string($_POST['gth_job_name']); // already regex'd for illegal characters
     $job_name_submit = job_name_strip($gth_job_name); // jobs_functions.inc.php; strip any user-added illegal chars

   // reconstruct outputName
   
   	$outputName=$DBid."prot.gth"; # e.g. GDB001prot.gth
   	
	// calculate file sizes	(for reporting)

	$trans_array_prot = create_input_list($input_data_path, "protein", $dbpass); # calculate total file size - prot (jobs_functions.inc.php)
	$input_file_size=$trans_array_prot[2]; // save to jobs database as total protein file size
	$gdna_array = create_input_list($input_data_path, "gdna", $dbpass); # calculate total file size - genome 
	$genome_file_size=$gdna_array[2]; // for jobs database as total genome file size

// Get processor info from database based on selected app_id (note: 'nodes' is not required, the app is pre-configured for node count, but we sent it anyway for informational purposes)

	$query="SELECT nodes, proc_per_node, memory_per_node, platform FROM $global_DB.apps WHERE app_id ='$app_id'";
	$result = mysql_query($query);
	$row=mysql_fetch_array($result);
	$nodes=$row['nodes'];
	$HPC_name=$row['platform'];
	$proc_per_node=$row['proc_per_node']; // should be 12 or 16
	$memory_per_node=$row['memory_per_node']; // default is '2' currently


//Create input directories for remote HPC and cat/copy data there from DataDIR. 
//NOTE - these directories must equate to the POSTed parameters for $input_g, $input_p and $gth_output_path which are used on the remote end to deposit data.

$InputDataDIR="$input_data_path"; //  e.g. /xGDBvm/input/xgdbvm/myDataDir/ Existing directory. Stored in MySQL xGDB_Log. Corresponds to: From an xGDBvm perspective, relative to root, Where this script will look to grab input files and place them under TempDIR
$InputDataDIR=(preg_match("/^[A-Za-z0-9-_\/]+$/", $InputDataDIR))? $InputDataDIR:""; # sanitize

$TempDIRbase="$inputDIR/tmp/"; // Top level input directory path, e.g.  /xGDBvm/input/xgdbvm/tmp/. From xGDBvm perspective, relative to root. This is where this script will create a new directory structure TempDIR for HPC to grab data from. Update 1-26-16 to include /tmp
$TempDIRinputs=$TempDIRbase.$DBid."_hpcs/"; #  e.g. /xGDBvm/input/xgdbvm/tmp/GDB001_hpcs/ (s is for standalone)  To be created by Apache = the base directory structure for this GDB's standalone remote data. Where remote HPC will look for data (NOTE: from HPC perspective, this is /username/hpcGDB001)
$TempDIRscaff="${TempDIRinputs}SCFDIR/"; #    e.g. /xGDBvm/input/xgdbvm/tmp/GDB001_hpcs/SCFDIR/ Created by Apache = genome inputs go here
$TempDIRprotein="${TempDIRinputs}Protein/"; #   e.g. /xGDBvm/input/xgdbvm/tmp/GDB001_hpcs/Protein/ Created by Apache = Protein inputs go here
#$TempDIRoutput="${TempDIRinputs}GTHOUT/"; #   e.g. /xGDBvm/input/xgdbvm/tmp/GDB001_hpcs/GTHOUT/  Created by Apache = Output files come back to here. NOTE: DEPRECATED, outputs go to /xGDBvm/input/archive/jobs/


mkdir($TempDIRinputs,0777);
mkdir($TempDIRscaff,0777);
mkdir($TempDIRprotein,0777);
#mkdir($TempDIRoutput,0777);

$cat_proteins =  "cat ${InputDataDIR}/*prot.fa  > $TempDIRprotein/${DBid}prot.fa";  // cat together input and copy to hpc input dir.

exec($cat_proteins);  //should be uncommented unless debug mode
 
$cat_gdna =  "cat ${InputDataDIR}/*gdna.fa >$TempDIRscaff/${DBid}gdna.fa";  // cat together input and copy to hpc input dir.
exec($cat_gdna); 

sleep(30); # IRODS is sometimes slow to update filesystem

$sort_gdna = "${emboss_path}/sizeseq -sequences ${TempDIRscaff}${DBid}gdna.fa -descending -outseq $TempDIRscaff/${DBid}gdna.fa"; // sort by size; optimal input for splitting script, fastasplit.pl
exec($sort_gdna);


#### Build page

	echo
			'<div id="leftcolumncontainer">
				<div class="minicolumnleft">';
				
	$left_menu=include_once("/xGDBvm/XGDB/jobs/leftmenu.inc.php");
	
	echo $left_menu;
	echo'</div>
		</div>
			<div id="maincontentscontainer" class="twocolumn admin">
				<div id="maincontentsfull">
				<h1 class="admin"> <img src="/XGDB/images/remote_compute.png" alt="" />Job Submission Result: GenomeThreader </h1>
				';
	
//If the php curl was successful, display the results, if not, print failed results

#### Make sure data were transferred #####

$prot_path="$TempDIRprotein/${DBid}prot.fa";
$scaff_path="$TempDIRscaff/${DBid}scaff.fa";

if(!file_exists($prot_path) && !file_exists($scaff_path))
{
		echo "<h3>Copy Input Data Failed</h3> ";
        echo "<p>No job was submitted</p>";
		echo "</div>";
}
else
{
############## CURL SUBMIT  ###############
 
//Create a php curl object  
	$ch = curl_init();
	
//construct the url for this app

	$job_url="${base_url}/jobs/${api_version}";
	
//Default parameters
	$archive=true; //debug, deposits output in /input/archive/jobs/
	$licenseFile="${username}/${inputTopDir}keys/gth.lic"; # 1-26-16 J Duvick e.g. /jduvick/xgdbvm/keys/gth.lic
	$splitSize=$proc_per_node; // proc_per_node is Agave version of processorCount; this value will be used by wrapper script to direct fastasplit.pl to divvy out genome portions to each thread.
	$total_threads=$proc_per_node*$nodes;
    $nonce = hash('sha512', mt_rand()*time()); # insure callback identity
	$callbackUrl="https://".$_SERVER['SERVER_NAME']."/XGDB/jobs/webhook.php?nonce=".$nonce."&job_id=\${JOB_ID}&status=\${JOB_STATUS}&error=\${JOB_ERROR}";

//Setting post array that we will jsonify. See http://agaveapi.co/live-docs/#!/jobs/submit_post_1

$notifications = build_notifications_array($callbackUrl, $admin_email); # see jobs_functions.inc.php; an array for alerts to the VM / user (if admin email configured)

//create array
	$job_data = array
	(
	   "name" => "$job_name_submit",
	   "appId" => "$app_id",
	   "nodeCount"=>$nodes,
	   "processorsPerNode" =>$proc_per_node,
	   "maxRunTime" =>"$requested_time",
	   "memoryPerNode" =>$memory_per_node,
	   "archive" =>"$archive",
	   "archiveSystem" =>"data.iplantcollaborative.org",
	   "notifications" =>$notifications,
		"inputs" => array
		(
           "inputGenomic" =>"$inputGenomic", 
           "inputProtein" =>"$inputProtein",
           "licenseFile" =>"$licenseFile"
        ),
        "parameters" => array
        (
           "speciesName" =>"$Species", 
           "splitSize" =>"$splitSize",
           "outputName" =>"$outputName"
	   )
	);

// Encode data array as JSON object and strip escaped slashes.	
    $postField = str_replace("\/", "/", json_encode($job_data));

//Set php curl options including authorization
	curl_setopt($ch, CURLOPT_URL,$job_url);
	curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
	curl_setopt($ch, CURLOPT_POST, true);
	curl_setopt($ch, CURLOPT_POSTFIELDS, $postField );
    curl_setopt($ch, CURLOPT_HTTPHEADER, array( "Content-Type:application/json", "Authorization: Bearer  $access_token"));

//Execute the php curl and grab the response
	$response = curl_exec($ch);
	$resultStatus = curl_getinfo($ch);
	

//Turn the response into json which php can manipulate 
	$handled_json = json_decode($response,true);
	
//for information purposes, build the parameter string that GenomeThreader sees:
    $parameters="-genomic $inputGenomic -protein $inputProtein -o $outputName -species $Species";



if($resultStatus['http_code'] == 200 || $resultStatus['http_code'] == 201)
	{
		$job_id=$handled_json['result']['id']; // e.g. 3949611174092533275-e0bd34dffff8de6-0001-007
		$pattern = "/^(\d+)(\-?.+)$/"; // we just want the first numeric string
        $match=(preg_match($pattern, $job_id, $matches)); 
        $job_id_trimmed=$matches[1]; // first numeric string
        $job_id_rest=$matches[2]; // rest of the job id string
		$message=$handled_json['result']['message']; // status message
		$submit_time=$handled_json['result']['submitTime']; // from Agave
		$submit_time_u=strtotime($submit_time);
		$start_time=$handled_json['result']['startTime']; //from Agave	
		$job_submitted_time=date("Y-m-d H:i:s"); // submitted by the VM. For now we are storing this value, not $submit_time
		$job_submitted_time_u=strtotime($job_submitted_time);
		$STATUS=$handled_json['result']['status']; // PENDING is the standard response.
		$status=strtolower($STATUS); # for styling
		$nodeCount=$handled_json['nodeCount'];
		$archive_path=($STATUS=="PENDING")?"/${username}/archive/jobs/job-${job_id}/":"N/A";

		// Store job data in Admin.jobs database table.
  
		$statement="Insert into $global_DB.jobs (nonce, job_id, job_name, status, db_id, job_type, program, softwareName, job_URL, HPC_name, user, admin_email, seq_type, genome_file_size, 
		genome_segments, split_count, input_file_size, parameters, requested_time, processors, memory, comments, posted_data, server_response, job_submitted_time)
		values  ('$nonce','$job_id', '$job_name_submit', '$STATUS', $ID, 'Standalone', 'GTH', '$app_id', '$job_url',  '$HPC_name', '$username', 
		'$admin_email', '$transcript_type', '$genome_file_size', '$total_scaffold_count', '$gth_split', '$input_file_size', '$parameters', '$requested_time', '$total_threads', '$memory_per_node', '', '$postField', '$response', '$job_submitted_time')"; 
		$do_statement = mysql_query($statement);

        echo "<div class='feature'>";
        echo "<h3>Job Details:</h3>";
        echo "<div class='showhide'><p title='Show additional information directly below this link' style='cursor:pointer'><span class='label'>Click to view posted data</span></p>";
        echo "<div class='hidden'><p><b>Posted:</b> $postField</p> <p><b>GTH Parameters: </b>$parameters </p></div>";// debug only.
        echo "</div><!--end showhide -->";

	    echo "<div class='showhide'><p title='Show additional information directly below this link' style='cursor:pointer'><span class='label'>Click to view server response</span></p>";
		echo "<div class='hidden'><p>Response from server:</p><p>$response </p></div>";
	    echo "</div><!--end showhide --><br />";
		echo "<h3>Your Job ID is ${job_id_trimmed}<span style=\"color:#AAA\">${job_id_rest}</span></h3><br />";
		echo "<h3>Your Job Submit Time <span style=\"color:red\">$job_submitted_time </span> </h3><br />";
		echo "<h3>Your Job Status is <span class=\"job_${status} hugefont\">$STATUS</span></h3><br />";
		echo "<h3>Your Job Output File(s) will be at $archive_path</h3><br />";
		echo "<h3><a href='/XGDB/jobs/jobs.php#$job_id'>View Jobs List</a></h3><br />";
		echo "</div>";

	} 
	else
	{ //Here it failed
        echo "<div class='feature'>";
        echo "<h3>Job Details:</h3>";
        echo "<div class='showhide'><p title='Show additional information directly below this link' style='cursor:pointer'><span class='label'>Click to view posted data</span></p>";
        echo "<div class='hidden'><p><b>Posted:</b> $postField</p> <p><b>GTH Parameters: </b>$parameters </p></div>";// debug only.
        echo "</div><!--end showhide -->";
		echo "<h3>Call Failed</h3> ";
		echo "<p class=\"bold\">Result:</p><p>".print_r($resultStatus)."</p>";
		echo "<p class=\"bold\">Response from server:</p><p>$response</p>";
		echo "</div>";
		
	}
	
	//destroy php curl object 
	curl_close ($ch);
} 
?>

			</div><!--end maincontentsfull-->
			
			</div><!--end maincontentscontainer-->
			<div id="rightcolumncontainer">
				</div><!--end rightcolumncontainer-->
			<?php include($XGDB_FOOTER); ?>
		</div></div></div>
	</body>
</html>