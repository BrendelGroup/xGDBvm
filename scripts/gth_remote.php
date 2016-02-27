<?php
#error_reporting(E_ALL ^ E_NOTICE);
#date_default_timezone_set('UTC');
   /*
This script is launched by the pipeline script xGDB_Procedure.sh when GTH_CompResource 'Remote Compute' flag is present.
It creates a job URL for remote GTH computation, based on stored values for the specified GDB together with dynamically read parameters for ID (GDB ID#), username, token
It communicates with a wrapper script that parses json output to create a GTH command line call.
Input  directories are fixed so that the xGDBvm pipeline can deposit input files from standardized pathnames.
Output is sent by default to the users' DataStore directory /archive/jobs/
Parameter names/values included in the json string are below (some user-configurable, others not)
*/

include('sitedef.php');
include_once('/xGDBvm/XGDB/phplib/db.inc.php'); #reads MySQL password from /xGDBvm/admin/dbpass
include_once('/xGDBvm/XGDB/jobs/jobs_functions.inc.php'); # to estimate file sizes
include_once('/xGDBvm/XGDB/jobs/login_functions.inc.php'); # To get refresh token

$inputDIR=$XGDB_INPUTDIR; # 1-26-2016 e.g. /xGDBvm/input/xgdbvm/
$inputTopDir=$INPUT_TOPDIR; # 1-26-2016 top level directory for xGDBv -related files on user's iPlant Data Store, e.g. xgdbvm/

$global_DB1= 'Admin';
$global_DB2= 'Genomes';
$dbpass=dbpass();
$db = mysql_connect("localhost", "gdbuser", $dbpass);
if(!$db)
	{
		echo "Error: Could not connect to database!";
		exit;
	}

## process arguments coming from shell script xGDB_Procedure.sh
## php $ScriptDIR/${prg}_remote.php $Id $PRG_username $PRG_token $gsq_server ${trn} $trn_type ## launches script that submits remote job using curl, and updates Genomes.xGDB_Log with status. $ID $username $refresh_token $gsq_server (e.g. 128.196.1.13) $type $trn_type (hard-coded for now)
# php $ScriptDIR/${prg}_remote.php $Id $PRG_username $prg_server ${trn} $fasta_header_type 
if(isset($argv[1])) { $ID = $argv[1]; } // e.g. 1
if(isset($argv[2])) { $username = $argv[2]; } 
if(isset($argv[3])) { $server = $argv[3]; } // e.g. 128.196.142.15 (need this for callback url)
if(isset($argv[4])) { $type = $argv[4]; } // (prot)
if(isset($argv[5])) { $format = $argv[5]; } // (P) not used - dummy value for now



//debug
error_log("\n gth_remote.php get arguments: \n id=".$ID."\n username=".$username."\n server=".$server."\n type=".$type."\n format=".$format."\n");
//end debug

####### Part I. $_GET parameters ########
# Get ID and create DBid
	$IDjustify="00".$ID;
	$DBid = "GDB".substr($IDjustify, -3, 3);
//debug
echo "\n DBid=$DBid \n";

####### Part IIA. Parameters from MySQL ########

## Get most recent Authorization URL from Admin.admin database;

	$auth_query="SELECT uid, auth_url, api_version from $global_DB1.admin where auth_url !='' order by uid DESC limit 0,1";
	$auth_result = mysql_query($auth_query);
	$auth=mysql_fetch_array($auth_result);
	$base_url=$auth['auth_url'];
	$api_version=$auth['api_version'];

/*## Get job info, Processors, etc. from Admin.admin database

	$gth_query="SELECT uid, gth_software, gth_url, gth_job_time, gth_proc, gth_proc_per_node, gth_update from $global_DB1.admin where gth_software !='' order by uid DESC limit 0,1";
	$get_gth_record = mysql_query($gth_query);
	$gth=mysql_fetch_array($get_gth_record);
	$appId=$gth['gth_software'];
	$HPC_Name=$gth['gth_url'];
	$processorCount=$gth['gth_proc'];
	$processorsPerNode=$gth['gth_proc_per_node'];
	$requestedTime=$gth['gth_job_time']; #requestedTime. NOTE: to debug error condition, comment out this variable. job submit will fail.
*/

// Get processor info from database based on the DEFAULT app_id (note: 'nodes' is not required, the app is pre-configured for node count, but we sent it anyway for informational purposes)

	$query="SELECT app_id, nodes, proc_per_node, memory_per_node, max_job_time, platform FROM $global_DB1.apps WHERE program ='GenomeThreader' AND is_default ='Y'";
	$result = mysql_query($query);
	$row=mysql_fetch_array($result);
	$app_id=$row['app_id'];
	$nodes=$row['nodes'];
	$proc_per_node=$row['proc_per_node']; // should be 12 or 16
	$memory_per_node=$row['memory_per_node']; // default is '2' currently
	$requested_time=$row['max_job_time']; // To do: make this user-configurable from within the view.php script
	$HPC_name=$row['platform'];

## Get GTH parameters: Species_Model & Input_Data_Directory [input data path] for the GDB selected
	$param_query="SELECT Gth_Species_Model, Input_Data_Path from $global_DB2.xGDB_Log where ID= $ID";
	$get_param_record = $param_query;
	$check_get_param_record = mysql_query($get_param_record);
	$param_result = $check_get_param_record;
	$param=mysql_fetch_array($param_result);	
	$Species=$param['Gth_Species_Model']; #Species
	$input_data_path=$param['Input_Data_Path']; #parse for input data size

## Get admin_email from Admin database

	$email_query="SELECT uid, admin_email FROM Admin.admin where admin_email !='' order by uid DESC limit 0,1";
	$get_email_record = $email_query;
	$check_get_email_record = mysql_query($get_email_record);
	$email_result = $check_get_email_record;
	$email=mysql_fetch_array($email_result);
	$admin_email=$email['admin_email']; 

####### Part IIB. Other parameters and calculations ########

## Calculate file sizes (information only;  write to jobs database) based on original data locations
	$prot_array = create_input_list($input_data_path, $type, $dbpass); # calculate total file size - transcript (jobs_functions.inc.php)
	$gdna_array = create_input_list($input_data_path, "gdna", $dbpass); # calculate total file size - genome 
	$input_file_size=$prot_array[2];
	$genome_file_size=$gdna_array[2];
	

## Set other parameters
	$splitSize=$proc_per_node; // proc_per_node is Agave version of processorCount; this value will be used by wrapper script to direct fastasplit.pl to divvy out genome portions to each thread.
	$total_threads=$proc_per_node*$nodes;
	$archive=true; //debug, deposits output in /input/archive/jobs/
	$licenseFile="/${username}/${inputTopDir}keys/gth.lic";
	$submitted =  date("Y-m-d-H-i-s");
	$job_name="${DBid}-gth-pipeline-${submitted}";	//e.g. GDB001-gth-pipeline-2015-03-01-04-22-44 *Caution if changing this: some chars such as parentheses may be illegal for job name 

####### Part IIC. Set data paths and filenames for Curl ########

## Specify TEMPORARY user input data paths with user's home directory as base  - the pipeine creates this directory and deposits data there
	$user_input_prot_path="/${username}/${inputTopDir}tmp/${DBid}_hpc/Protein/"; //e.g."/username/xgdbvm/tmp/GDB001_hpc/Protein/"
	$user_input_scaff_path="/${username}/${inputTopDir}tmp/${DBid}_hpc/SCFDIR/"; //e.g."/username/xgdbvm/tmp/GDB001_hpc/SCFDIR/" (note: this dataset is already size-sorted by commands in xGDB_Procedure.sh)

## Construct input path and output name variables for Curl statement. NOTE: these are used by TACC so they are relative to iPlant Data Store user home page ($username)

	$inputProtein="${user_input_prot_path}${DBid}prot.fa";  //user's DataStore path, for json; Protein File, e.g. /username/xgdb/tmp/GDB001_hpc/Protein/GDB002est
	$inputGenomic="${user_input_scaff_path}${DBid}gdna.fa"; // user's DataStore path, for json; Genome File, e.g. /username/xgdb/tmp/GDB001_hpc/SCFDIR/GDB002scaffold	
	$outputName="${DBid}prot.gth"; // for json; e.g. GDB001prot.gth
	// deprecated $outPutPath="$user_output_data_path"; //for json; e.g. /username/GDB001_hpc/GTHOUT/

## Calculate split count and scaffold number for display 

    $scaffolds=calculate_scaffolds($user_input_scaff_path, $proc_per_node, $proc_per_node); # jobs_functions.inc.php
    $gth_split=$scaffolds[5]; # this is for information purposes only, it is the split of segments we predict will be used 

    $large_scaffold_count=$scaffolds[0];
    $small_scaffold_count=$scaffolds[1];
    $total_scaffold_count=$large_scaffold_count + $small_scaffold_count;
	
############## Part III. Refresh access_token for Agave API #############

 // A. First, get the OAuth App credentials for this user, VM:
 
    $handle = fopen("/xGDBvm/admin/auth", "r");
    $auth_error="";        

    if($handle)
    {
        while (($line = fgets($handle)) !== false) 
        {
            $pattern="/^".$username.":([A-Za-z0-9\_]+?):([A-Za-z0-9\_]+?)$/"; # e.g. newuser:hZ_z3f4Hf3CcgvGoMix0aksN4BOD6:UH758djfDF8sdmsi004wER
            if(preg_match($pattern, $line, $matches))
            {
                $consumer_key=$matches[1];
                $consumer_secret=$matches[2];
            }
        }
        fclose($handle);
        
        if($consumer_key =="" || $consumer_secret == "")
        {
        $auth_error="The consumer_key or consumer_secret could not be read; ";
        }
    }
    else
    {
   		$auth_error="The /xGDBvm/admin/auth file for storing consumer_key and consumer_secret is missing; ";
    }

// B. Next, grab the cached refresh_token and GET A NEW ACCESS_TOKEN using 'refresh' command for OAuth. We also cache the new refresh token.

    if($auth_error=="")
    {
    // Run 'get_refresh_token' function (login_functions.inc.php) From flat file /xGDBvm/admin/refresh
        $refresh_token=get_refresh_token($username); // 
    // Run 'refresh' function (login_functions.inc.php) Uses refresh_token to re-authenticate user and retrieve new OAuth2 access_token for our Curl job request. It also retrieves and stores a new refresh_token (replacing the old one)
        $auth_array=refresh($consumer_key, $consumer_secret, $refresh_token, $base_url, $username);  // 
        # returns  array($http_code, $access_token, $refresh_token, $expires, $issued, $lifespan, $response);
        $old_refresh_token=$refresh_token; // debug purposes
		$http_code=$auth_array[0]; // 200 = success; 400=malformed request;  401 = bad username/password 0 = no repsonse (bad URL)
	    $access_token=$auth_array[1]; # this will give us access via Curl to the Agave API
	    $refresh_token=$auth_array[2]; # this is a brand-new refresh_token (it .

// DEBUG ONLY; COMMENT OUT OTHERWISE
	# error_log("\n \n http_code :".$http_code." \n \n consumer_key :".$consumer_key."\n \n consumer_secret :".$consumer_secret."\n \n new access_token :".$access_token."\n\n new refresh_token:".$refresh_token."\n \n old refresh_token:".$old_refresh_token."\n\n"); 
// END DEBUG ONLY

    }
    else
	{
		$auth_error .= "No access token could be obtained; ";
	}
	if ($auth_error!="")
	{
	error_log("\n Authentication FAILED - ".$auth_error."\n");
	}
	else
	{
############## Part IV. Populate CURL object and submit #############

	error_log("\n Authentication returned http_code $http_code.\n"); #  

	# following line DEBUG ONLY! COMMENT OUT WHEN LIVE
	# error_log("\n refresh_token=".$refresh_token."\n \n access_token=".$access_token."\n \n username=".$username."\n"); # DEBUG ONLY! COMMENT OUT WHEN LIVE

	//Create a php curl object  
		$ch = curl_init();
	
	//construct the url for this app

		$job_url="${base_url}/jobs/${api_version}"; # from Admin.admin database

	//CALLBACK URL - see http://agaveapi.co/notifications-and-events/
		$nonce = hash('sha512', mt_rand()*time()); # insure callback identity
    $callbackUrl="https://".$server."/XGDB/jobs/webhook.php?nonce=".$nonce."&ID=".$ID."&type=prot&job_id=\${JOB_ID}&status=\${JOB_STATUS}&error=\${JOB_ERROR}"; // this script will update status in MySQL tables monitored by the pipeline
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
				   "event" =>  "FAILED",
				   "persistent" => false
				),
				array(
				   "url" => "$admin_email",
				   "event" =>  "FINISHED",
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
		   "name" => "$job_name",
		   "appId" => "$app_id",
		   "nodeCount"=>$nodes,
		   "processorsPerNode" =>$proc_per_node,
		   "maxRunTime" =>"$requested_time",
		   "memoryPerNode" =>$memory_per_node,
		   "archive" =>$archive,
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
	 $attempts=0;
	 $max_attempts=5;
     for ($i = 1; $i <= $max_attempts; $i++)
     {
	//Execute the php curl and grab the response
		$response = curl_exec($ch);
		$resultStatus = curl_getinfo($ch);
	
		//Turn the response into json which php can manipulate 
		$handled_json = json_decode($response,true);

		//If the php curl was successful, display the results, if not, print failed results

	//for information purposes, build the parameter string that GenomeThreader sees:
		$parameters="-genomic $inputGenomic -protein $inputProtein -o $outputName -species $Species";

	#/* comment out this block to debug
	$http_code=$resultStatus['http_code'];
	$attempts=$attempts+1;
	if($http_code == 200 || $http_code == 201)
	break;
	sleep(30);
	}
	// After up to 5 tries, 
	if($http_code == 200 || $http_code == 201)
	{
		$message=$handled_json['result']['message']; // status message
		$job_id=$handled_json['result']['id']; // e.g 0001424105021858-5056a550b8-0001-007
		$job_id_trimmed=ltrim(substr($job_id, 0, 16), '0'); // e.g. 0001424105021858
		$job_id_rest=substr($job_id, 16, 20); // e.g. -5056a550b8-0001-007
		$submit_time=$handled_json['result']['submitTime']; // from Agave
		$submit_time_u=strtotime($submit_time);
		$start_time=$handled_json['result']['startTime']; //from Agave	
		$job_submitted_time=date("Y-m-d H:i:s"); // submitted by the VM. For now we are storing this value, not $submit_time
		$job_submitted_time_u=strtotime($job_submitted_time);
	    $STATUS=$handled_json['result']['status']; // PENDING is the standard response if successful
		$status=strtolower($STATUS); # for styling
		$nodeCount=$handled_json['nodeCount']; #not using this at present
		$archive_path=($STATUS=="PENDING")?"/${username}/archive/jobs/job-${job_id}/":"N/A";
		$comment="$attempts attempts; ";
        $comment.="${STATUS}: $submit_time | "; // This is the actual submit time returned by the server. Subsequent status updates will be concatenated here.
		// Store job data in Admin.jobs database table.

		$statement="Insert into $global_DB1.jobs (nonce, job_id, job_name, status, db_id, job_type, program, softwareName, job_URL, HPC_name, user, admin_email, seq_type, genome_file_size, 
		genome_segments, split_count, input_file_size, parameters, requested_time, processors, memory, comments, posted_data, server_response, job_submitted_time)
		values  ('$nonce','$job_id', '$job_name', '$STATUS', $ID, 'Pipeline', 'GTH', '$app_id', '$job_url', '$HPC_name', '$username', 
		'$admin_email', '$type', '$genome_file_size', '$total_scaffold_count', '$splitSize', '$input_file_size', '$parameters', '$requested_time', '$total_threads', '$memory_per_node', '$comment', '$postField', '$response', '$job_submitted_time')"; 
		$do_statement = mysql_query($statement);
	
# Report the outcome 

error_log("\n gth_remote.php cURL SUCCEEDED. Submitted to URL:".$job_url." \n postField=".$postField."\n parameters=".$parameters."\n status=".$STATUS."\n job_id=".$job_id."\n");


# Create job_directory, unique identifier. This may be needed to retrieve output where remote HPC deposits in the user's archive directory e.g. archive/jobs/job-[job_id]/GDBnnn.gth
		$job_directory ="job-".$job_id; // combination of remote job ID and local job name. e.g. job-0001424449412643-5056a550b8-0001-007


# write job_id and result (status) to xGDB_Log table. NOTE: this is NOT jobs table! The job_id is read by the pipeline script as a sign to proceed, and it also provides the name of the output directory.

		$job_id_query = "update $global_DB2.xGDB_Log set GTH_Job = '$job_id', GTH_Job_Result ='$STATUS' where ID=$ID"; # e.g. GTH_Job = 0001424449412643-5056a550b8-0001-007, GTH_Job_Result=PENDING
		$job_id_update = mysql_query($job_id_query);  

	} 
	else
	{ //Curl submit failed

        error_log("\n gth_remote.php FAILED. cURL submitted to URL:".$job_url." http_code=".$http_code." \n \n postField=".$postField."\n \n parameters=".$parameters."\n \n message=".$message."\n \n response=".$response."\n \n");
		$STATUS="ERROR";
		$status=$handled_json['status'];// error is the typical response (NOTE: this is different from $STATUS where a job has been successfully submitted)
		$comment="$attempts attempts; ";
		$comment .= $handled_json['message'];// Failed to submit job is the typical response
	
# Create job_name, a text identifier for failed job (no job ID assigned, so just use failure result, e.g. 'null')
		$job_id ="error-".$job_name; // combination of 'null' and local job name. e.g. error-Q2Ejd-20130313-203456
		
        $response_display = str_replace('>', ' ', (str_replace('>', ' ', $response))); // we will be displaying this in a table; it may be formatted

# Store job data in Admin.jobs database table.
		$statement="Insert into $global_DB1.jobs 
		(job_id, job_name, status, db_id, job_type, program, softwareName, job_URL, HPC_name, user, admin_email, seq_type, genome_file_size, genome_segments, split_count, input_file_size, parameters, requested_time, processors, memory, comments, job_submitted_time, error)
		values
		('$job_id', '$job_name', '$STATUS', $ID, 'Pipeline', 'GTH ', '$app_id', '$job_url', '$HPC_name', '$username', '$admin_email', '$type', '$genome_file_size', '$total_scaffold_count', '$splitSize', '$input_file_size', '$parameters', '$requested_time', '$proc_per_node', '$memory_per_node', '$comment', '$submitted', 'job submission FAILED - http code: $http_code - response: $response_display')";
	
		$do_statement = mysql_query($statement);


		$job_id_query = "update $global_DB2.xGDB_Log set GTH_Job = '$job_id', GTH_Job_Result ='error' where ID=$ID"; // read by xGDB_Procedure.sh		
		$job_id_update = mysql_query($job_id_query);  

	}
 //destroy php curl object 
	curl_close ($ch);
}
?>