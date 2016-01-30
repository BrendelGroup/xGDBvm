<?php
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
	$emboss_path=$EMBOSS; # sitedef.php  ; 1-20-2016
	$inputDir=$XGDB_INPUTDIR; # 1-26-15 
	$InputDataDIR=$XGDB_DATADIR; # 1-26-15 

date_default_timezone_set("$TIMEZONE"); // from sitedef.php
//
// This script for Standalone HPC jobs creates a job URL for remote GeneSeqer processing based on values posted from submit.php.  
// It communicates with a wrapper script that parses the json output to create a GeneSeqer command line call. (See submit.php for parameter names). The script also stores job-related data in Admin.jobs (if successsfully submitted)

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
    die('<div class="feature"><span class="warning normalfont">Form submission failed validation (it may have already been sent) - $post_valid</span> <a href="/XGDB/jobs/submit.php">Return</a></div>');
}

// grab session variables
	$username=$_SESSION['username'];
	$access_token=$_SESSION['access_token'];
	
//grab posted ID and create GDBid
	$ID=intval($_POST['id']); # e.g. 1
	$IDjustify="00".$ID;
	$DBid = "GDB".substr($IDjustify, -3, 3);

//grab and sanitize other posted values from submit.php

	 $version=mysql_real_escape_string($_POST['version']);
	 $app_id=mysql_real_escape_string($_POST['gsq_app_id']); # Agave, e.g. gsq-u-2.0
	 $processorCount=intval($_POST['gsq_proc']); # Agave; selectable by user in submit.php
	 $processorsPerNode=intval($_POST['gsq_proc_per_node']); # Agave; selectable by user in submit.php
     $base_url=mysql_real_escape_string($_POST['auth_url']); # Agave; this is the base url
     $api_version=mysql_real_escape_string($_POST['api_version']); # Agave; this is current version e.g. v2
	 $estSeq=mysql_real_escape_string($_POST['estSeq']); # This is the temporary path to the transcript file (minus the file suffix - to be added here)
	 $gsq_split=intval($_POST['gsq_split']);
	 $total_scaffold_count=intval($_POST['total_scaffold_count']);
	 $requested_time=mysql_real_escape_string($_POST['requested_time']);
	 $admin_email=mysql_real_escape_string($_POST['admin_email']);
	 $input_data_path=mysql_real_escape_string($_POST['input_data_path']); //
	 $username=mysql_real_escape_string($_POST['username']);
	 $libfname=mysql_real_escape_string($_POST['libfname']);
#	 $genomeFormat=mysql_real_escape_string($_POST['genomeFormat']);
	 $outputPath=mysql_real_escape_string($_POST['outputPath']); //to be modified further before posting- see below
#	 $transcriptFile=mysql_real_escape_string($_POST['transcriptFile']);
	 $Species=mysql_real_escape_string($_POST['Species']);
	 $wsize=mysql_real_escape_string($_POST['wsize']);
	 $minqHSP=mysql_real_escape_string($_POST['minqHSP']);
	 $minqHSPc=mysql_real_escape_string($_POST['minqHSPc']);
	 $minESTc=mysql_real_escape_string($_POST['minESTc']);
	 $maxnest=mysql_real_escape_string($_POST['maxnest']);	 
	 $gsq_job_name=mysql_real_escape_string($_POST['gsq_job_name']);
     $job_name_submit = job_name_strip($gsq_job_name); // jobs_functions.inc.php; strip any user-added illegal chars
     
	// calculate file sizes	

	$trans_array_est = create_input_list($input_data_path, "est", $dbpass); # calculate total file size - est (jobs_functions.inc.php)
	$trans_array_cdna = create_input_list($input_data_path, "cdna", $dbpass); # calculate total file size - cdna (jobs_functions.inc.php)
	$trans_array_tsa = create_input_list($input_data_path, "tsa", $dbpass); # calculate total file size - tsa (jobs_functions.inc.php)
	$gdna_array = create_input_list($input_data_path, "gdna", $dbpass); # calculate total file size - genome 
	$genome_file_size=$gdna_array[2]; // for jobs database as total genome file size
	
	// Get processor info from database based on selected app_id (note: 'nodes' is not required, the app is pre-configured for node count, but we sent it anyway for informational purposes)

	$query="SELECT nodes, proc_per_node, memory_per_node, platform from $global_DB.apps where app_id ='$app_id'";
	$result = mysql_query($query);
	$row=mysql_fetch_array($result);
	$nodes=$row['nodes'];
	$HPC_name=$row['platform'];
	$proc_per_node=$row['proc_per_node']; // should be max
	$memory_per_node=$row['memory_per_node']; // default is '2' currently

	$transcript_type=mysql_real_escape_string($_POST['transcript_type']); //used to assign est, cdna, tsa. See below:
		switch ($transcript_type) //build outPutFile based on transcript type (est, cdna, tsa)
			{
		case "est":
			$outPutFile = "${DBid}est.gsq"; //json parameter: filename for output
			$estSeq=$estSeq."est.fa"; // json paramater: filename for input
			$input_file_size=$trans_array_est[2]; // save to jobs database table as total transcript file size
			break;
		case "cdna":
			$outPutFile = "${DBid}cdna.gsq";
			$estSeq=$estSeq."cdna.fa";
			$input_file_size=$trans_array_cdna[2];
			break;
		case "tsa":
			$outPutFile = "${DBid}tsa.gsq";
			$estSeq=$estSeq."tsa.fa";
			$input_file_size=$trans_array_tsa[2];
		   }

	$submitted =  date("Y-m-d H:i:s");
	$submitted_url =str_replace(":", "", $submitted);
	$submitted_url =str_replace("-", "", $submitted_url);
	$submitted_url=str_replace(" ", "-", $submitted_url); //can be passed as part of URL
	$user_string=substr($username, 0,2); //standardized to lower case for file naming

//Create input directories for remote HPC and cat/copy data there from /xGDBvm/input/xgdbvm/DataDIR. 
//NOTE - these directories must equate to the POSTed parameters for libfname, ESTseq, outputPath, which are used on the remote end to grab/deposit data.

$InputDataDIR="$input_data_path"; //  e.g. /xGDBvm/input/xgdbvm/myDataDir/. From xGDBvm perspective, relative to root, Where this script will look to grab input files and place them under RemoteDIR
#$InputDataDIR=(preg_match("/^[A-Za-z0-9-_\/]+$/", $InputDataDIR))? $InputDataDIR:""; # sanitize

$TempDIRbase="$inputDir/tmp/"; // Top leve input directory path, e.g.  /xGDBvm/input/xgdbvm/tmp/. From xGDBvm perspective, relative to root. This is where this script will create a new directory structure RemoteDIR for HPC to grab data from. Update 1-26-16 to include /tmp
$TempDIRinputs="${TempDIRbase}${DBid}_hpcs/"; #    e.g. /xGDBvm/input/tmp/GDB001_hpcs/  (s is for standalone) The base directory structure for this GDB's remote data. Where remote HPC will look for data (NOTE: from HPC perspective, this is /username/hpcGDB001)
$TempDIRscaff="${TempDIRinputs}SCFDIR/"; #    e.g. /xGDBvm/input/tmp/GDB001_hpcs/SCFDIR/ genome inputs go here
$TempDIRtranscript="${TempDIRinputs}MRNADIR/"; #   e.g. /xGDBvm/input/tmp/GDB001_hpcs/MRNADIR/ EST, cDNA, TSA inputs go here
# $TempDIRoutput="${TempDIR}GSQOUT/"; #   e.g. /xGDBvm/input/tmp/GDB001_hpcs/GSQOUT/  Output files come back to here. NOT REALLY. DEPRECATED. OUTPUT GOES TO /xGDBvm/input/archive/jobs

// Obtain fasta header types

$file_path_transcript=`ls -1 $input_data_path/*${transcript_type}.fa | head -1`;  # read line 1 of first matching file
$fasta_header_array=fasta_header_type($file_path_transcript, $transcript_type);
$EstFormat=$fasta_header_array[1];

$file_path_gdna=`ls -1 $input_data_path/*gdna.fa | head -1`;  # read line 1 of first matching file
$fasta_header_array=fasta_header_type($file_path_gdna, "gdna");
$genomeFormat=$fasta_header_array[1];

mkdir($TempDIRinputs,0777);
mkdir($TempDIRscaff,0777);
mkdir($TempDIRtranscript,0777);
# mkdir($TempDIRoutput,0777);

// Copy required input data to DataStore ($InputDataDIR). Since this is not a pipeline job, there is no scratch directory involved -- just the user's input dir.
$cat_transcript =  "cat ${InputDataDIR}/*${transcript_type}.fa  >${TempDIRtranscript}${DBid}${transcript_type}.fa";  // error fixed 8/28; cat together input and copy to hpc input dir.

exec($cat_transcript);  //should be uncommented unless debug mode

$cat_gdna =  "cat ${InputDataDIR}/*gdna.fa >$TempDIRscaff/${DBid}gdna.fa";  // cat together input and copy to hpc input dir.
exec($cat_gdna); 

if($genomeFormat=="l"){
$input_format="-sformat1 ncbi"; // Required in order to preserve the ncbi (GenBank) -formatted headers
$output_format="-osformat2 ncbi"; // Required in order to preserve the ncbi (GenBank) -formatted headers
}else{
$input_format="";
$output_format="";
}

sleep(30); # IRODS can be a bit slow to update filesystem

$sort_gdna = "${emboss_path}/sizeseq -descending -sequences $TempDIRscaff/${DBid}gdna.fa $input_format -outseq $TempDIRscaff/${DBid}gdna.fa $output_format"; // sort by size; optimal input for splitting script, fastasplit.pl
exec($sort_gdna);



##### Build first part of page #####
	
	echo
			'<div id="leftcolumncontainer">
				<div class="minicolumnleft">';
				
	$left_menu=include_once("/xGDBvm/XGDB/jobs/leftmenu.inc.php");
	
	echo $left_menu;
	echo'</div>
		</div>
			<div id="maincontentscontainer" class="twocolumn admin">
				<div id="maincontentsfull">
				<h1 class="admin"> <img src="/XGDB/images/remote_compute.png" alt="" />Job Submission Result: GeneSeqer </h1>
				';
	

##### Make sure we have input files in place before proceedint #####

$transcript_path="$TempDIRtranscript/${DBid}${transcript_type}.fa";
$scaff_path="$TempDIRscaff/${DBid}scaff.fa";

if(!file_exists($transcript_path) && !file_exists($scaff_path))
{
		echo "<h3>Copy Input Data Failed</h3> ";

		echo "</div>";
}
else
{


############## CURL SUBMIT  ###############
 
//Create a php curl object  
	$ch = curl_init();
	$ch_values = "$username:$token";  // we are passing a token in place of password
	
//construct the url for this app

	$job_url="${base_url}/jobs/${api_version}";
	
//Default parameters
	$archive=true; //debug, deposits output in /input/archive/jobs/
	$splitSize=$nodes; // for GeneSeqer-MPI, we distribute genome segments among available nodes (e.g. 3 nodes processing 12 chromosomes= 3-way split, or 4 chromosomes per node), and use individual processors on each node to calculate a fraction of the EST sequences. MPI then combines results at each node.
	$total_threads=$proc_per_node*$nodes;

//deprecated	$nodeCount=intval(($processorCount/$processorsPerNode)+0.5); // e.g. splitsize 18 ; 18/12 + 0.5 = 2. So we will specify 2 processors but only 18 out of 24 cores in the 2 processors are used.
//CALLBACK URL - see http://agaveapi.co/notifications-and-events/
    $nonce = hash('sha512', mt_rand()*time()); # insure callback identity
#	$callbackUrl="https://".$_SERVER['SERVER_NAME']."/XGDB/jobs/webhook.php?nonce=".$nonce."&job_id=\${JOB_ID}&status=\${JOB_STATUS}&start=\${JOB_START_TIME}&end=\${JOB_END_TIME}&updated=\${LAST_UPDATED}";
	$callbackUrl="https://".$_SERVER['SERVER_NAME']."/XGDB/jobs/webhook.php?nonce=".$nonce."&job_id=\${JOB_ID}&status=\${JOB_STATUS}&error=\${JOB_ERROR}";

//Setting post array that we will jsonify. See http://agaveapi.co/live-docs/#!/jobs/submit_post_1

//If amin_email missing, don't include email webhooks.

$notifications=($admin_email=="")
?
array
	   (
			array(
			   "url" =>  "$callbackUrl",
			   "event" => "*",
			   "persistent" => true
			)
		)
:
array
	   (
		   array(
				 "url" => "$admin_email",
				 "event" => "RUNNING",
			   "persistent" => false
			),
			array(
			   "url" => "$admin_email",
			   "event" =>  "FINISHED",
			   "persistent" => false
			),
			array(
			   "url" => "$admin_email",
			   "event" =>  "FAILED",
			   "persistent" => false
			),
			array(
			   "url" =>  "$callbackUrl",
			   "event" => "*",
			   "persistent" => true
			)
		)
;
//create array
	$job_data = array
	(
	   "name" => "$job_name_submit",
	   "appId" => "$app_id",
	   "nodeCount"=>$nodes, // deprecated but we send anyway
	   "processorsPerNode" =>$proc_per_node,
	   "maxRunTime" =>"$requested_time",
	   "memoryPerNode" =>$memory_per_node,
	   "archive" =>"$archive",
	   "archiveSystem" =>"data.iplantcollaborative.org",
	   "notifications" =>$notifications,
		"inputs" => array
		(
           "libfname" =>"$libfname", 
           "estSeq" =>"$estSeq",
        ),
        "parameters" => array
        (
           "Species" =>"$Species",
           "EstFormat" => "$EstFormat",
           "genomeFormat" => "$genomeFormat",
           "wsize" =>"$wsize", 
           "minqHSP" =>"$minqHSP", 
           "minqHSPc" =>"$minqHSPc", 
           "minESTc" =>"$minESTc",
           "maxnest" =>"$maxnest", 
           "minESTc" =>"$minESTc", 
           "splitSize" =>"$splitSize",
           "outputPath" =>"$outputPath",
           "outPutFile" => "$outPutFile"
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
	
//for information purposes, build the parameter string that GeneSeqer sees:
$parameters="-s $Species -$genomeFormat $libfname -$EstFormat $estSeq -x $wsize -y $minqHSP -z $minqHSPc -w $minESTc -m $maxnest -o $outputPath$outPutFile";

//If the php curl was successful, display the results, if not, print failed results

if($resultStatus['http_code'] == 200 || $resultStatus['http_code'] == 201)
	{
		$job_id=$handled_json['result']['id']; //  e.g. 3949611174092533275-e0bd34dffff8de6-0001-007
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
		values  ('$nonce','$job_id', '$job_name_submit', '$STATUS', $ID, 'Standalone', 'GSQ', '$app_id', '$job_url', '$HPC_name', '$username', '$admin_email', '$transcript_type', '$genome_file_size', '$total_scaffold_count', '$gsq_split', '$input_file_size', '$parameters', '$requested_time', '$total_threads', '$memory_per_node', '', '$postField', '$response', '$job_submitted_time')"; 
		$do_statement = mysql_query($statement);

        echo "<div class='feature'>";
        echo "<h3>Job Details:</h3>";
        echo "<div class='showhide'><p title='Show additional information directly below this link' style='cursor:pointer'><span class='label'>Click to view posted data</span></p>";
        echo "<div class='hidden'><p><b>Posted:</b> $postField</p> <p><b>GSQ Parameters: </b>$parameters </p></div>";// debug only.
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
        echo "<div class='hidden'><p><b>Posted:</b> $postField</p> <p><b>GSQ Parameters: </b>$parameters </p></div>";// debug only.
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