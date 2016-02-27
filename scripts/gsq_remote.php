<?php
#error_reporting(E_ALL ^ E_NOTICE);

include('sitedef.php');
include_once('/xGDBvm/XGDB/phplib/db.inc.php'); #reads MySQL password from /xGDBvm/admin/dbpass
include_once('/xGDBvm/XGDB/jobs/jobs_functions.inc.php'); # to estimate file sizes
include_once('/xGDBvm/XGDB/jobs/login_functions.inc.php'); # To get refresh token

$inputDir=$XGDB_INPUTDIR; # 1-26-2016 e.g. /xGDBvm/input/xgdbvm/
$inputTopDir=$INPUT_TOPDIR; # 1-26-2016 top level directory for xGDBv -related files on user's iPlant Data Store, e.g. /xgdbvm/

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
if(isset($argv[3])) { $server = $argv[3]; }
if(isset($argv[4])) { $type = $argv[4]; }  // est, cdna, tsa
if(isset($argv[5])) { $format = $argv[5]; } // genbank or simple fasta headers


//debug
error_log("\n gsq_remote.php get arguments: \n id=".$ID."\n username=".$username."\n server=".$server."\n type=".$type."\n format=".$format."\n");
//end debug


####### Part I. $_GET parameters ########
# Get ID and create DBid
    $IDjustify="00".$ID;
    $DBid = "GDB".substr($IDjustify, -3, 3);
//debug
echo "\n DBid=$DBid \n";

# Use $type to populate additional output variables:
global $gsq_job, $gsq_job_result, $transcript_dir;
    switch ($type) 
    {
case "est":
    $gsq_job="GSQ_Job_EST"; //column to update
    $gsq_job_result="GSQ_Job_EST_Result"; //column to update
    $transcript_dir="MRNADIR";
    break;
case "cdna":
    $gsq_job="GSQ_Job_cDNA"; //column to update
    $gsq_job_result="GSQ_Job_cDNA_Result"; //column to update
    $transcript_dir="MRNADIR";
    break;
case "tsa": // i.e. put
    $gsq_job="GSQ_Job_PUT"; //column to update
    $gsq_job_result="GSQ_Job_PUT_Result"; //column to update
    $transcript_dir="PUTDIR";
    break;
   }
# Use $format to create EstFormat for json:
    switch ($format) 
    {
case "d":
    $EstFormat = "d";
    break;
case "D":
    $EstFormat = "D";
    break;   
   }

//debug
echo "\n gsq_job=$gsq_job \n";

####### Part IIA. Parameters from MySQL ########

## Get most recent Authorization URL from Admin.admin database;

$auth_query="SELECT uid, auth_url, api_version from $global_DB1.admin where auth_url !='' order by uid DESC limit 0,1";
$auth_result = mysql_query($auth_query);
$auth=mysql_fetch_array($auth_result);
$base_url=$auth['auth_url'];
$api_version=$auth['api_version'];

/*## Get gsq_job_time (requestedTime), Processors, etc. from Admin database

$gsq_query="SELECT uid, gsq_software, gsq_url, gsq_job_time, gsq_proc, gsq_proc_per_node, gsq_update from $global_DB1.admin where gsq_software !='' order by uid DESC limit 0,1";
$get_gsq_record = mysql_query($gsq_query);
$gsq=mysql_fetch_array($get_gsq_record);
$appId=$gsq['gsq_software'];
$HPC_Name=$gsq['gsq_url'];
$processorCount=$gsq['gsq_proc'];
$processorsPerNode=$gsq['gsq_proc_per_node'];
$requestedTime=$gsq['gsq_job_time']; #requestedTime. NOTE: to debug error condition, comment out this variable. job submit will fail.
*/

## Get processor info from database based on DEFAULT app_id (note: 'nodes' is not required, the app is pre-configured for node count, but we sent it anyway for informational purposes)

$query="SELECT nodes, proc_per_node, memory_per_node, nodes, max_job_time, app_id, platform FROM $global_DB1.apps WHERE program ='GeneSeqer-MPI' AND  is_default ='Y'";
$result = mysql_query($query);
$row=mysql_fetch_array($result);
$proc_per_node=$row['proc_per_node']; // should be 12 or 16
$memory_per_node=$row['memory_per_node']; // default is '2' currently
$nodes=$row['nodes'];
$requested_time=$row['max_job_time']; // To do: make this user-configurable from within the view.php script
$platform=$row['platform'];
$app_id=$row['app_id'];

## Get GeneSeqer parameters: Species_Model, Alignment_Stringency, Input_Data_Directory [input data path] for the GDB selected
$param_query="SELECT Species_Model,Alignment_Stringency, Input_Data_Path from $global_DB2.xGDB_Log where ID= $ID";
$get_param_record = $param_query;
$check_get_param_record = mysql_query($get_param_record);
$param_result = $check_get_param_record;
$param=mysql_fetch_array($param_result);    
$Species=$param['Species_Model']; #Species
$Alignment_Stringency=$param['Alignment_Stringency']; #parse for wsize, minqHSP, minqHSPc
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
$trans_array = create_input_list($input_data_path, $type, $dbpass); # calculate total file size - transcript (jobs_functions.inc.php)
$gdna_array = create_input_list($input_data_path, "gdna", $dbpass); # calculate total file size - genome
$input_file_size=$trans_array[2];
$genome_file_size=$gdna_array[2];

## Set other parameters
$splitSize=$nodes; // for GeneSeqer-MPI, we distribute genome segments among available nodes (e.g. 3 nodes processing 12 chromosomes= 3-way split, or 4 chromosomes per node), and use individual processors on each node to calculate a fraction of the EST sequences. MPI then combines results at each node.
$total_threads=$proc_per_node*$nodes;
$archive=true; //debug, deposits output in /input/archive/jobs/
$submitted =  date("Y-m-d-H-i-s");
$job_name="${DBid}-gsq-pipeline-${submitted}";  //e.g. GDB001-GSQ-Pipeline-2015-03-01-04-22-44

# Hard coded: maxnest, genomeFormat

$maxnest="999999999";//for json
$genomeFormat="L";//non-GenBank libfname -- for json

# Parse from parameter string: wsize, minqHSP, minqHSPc, Species
switch ($Alignment_Stringency) 
{
    case ($Alignment_Stringency == "Strict"):
        $parameters = "-x 30 -y 45 -z 60 -w 0.80";
        break;
     case ($Alignment_Stringency == "Moderate"):
        $parameters = "-x 16 -y 24 -z 48 -w 0.80";
        break;
    case ($Alignment_Stringency == "Low"):
        $parameters = "-x 12 -y 12 -z 30 -w 0.80";
        break;
}
$param = explode(" ", $parameters);
$wsize=$param[1]; // -x; for json
$minqHSP=$param[3];// -y for json
$minqHSPc=$param[5]; // -z  for json
$minESTc=$param[7]; // -w  for json


####### Part IIC. Set data paths and filenames for Curl ########

## Specify TEMPORARY user input data paths with user's iPlant DataStore home directory as base 
$user_input_mrna_path="/${username}/${inputTopDir}tmp/${DBid}_hpc/$transcript_dir/"; //e.g."/username/xgdbvm/tmp/GDB001_hpc/MRNADIR/"
$user_input_scaff_path="/${username}/${inputTopDir}tmp/${DBid}_hpc/SCFDIR/"; //e.g."/username/xgdbvm/tmp/GDB001_hpc/SCFDIR/"

## Specify TEMPORARY output directory; the pipeline creates this directory and picks up remote-computed output data there.
$user_output_data_path="/${username}${inputTopDir}${DBid}_hpc/GSQOUT/"; // e.g."/username/GDB001_hpc/GSQOUT/"  NOT USING THIS CURRENTLY. OUTPUT GOES TO /home/user/archive/jobs/

# Construct input and output paths. NOTE: these are used by TACC so they are relative to iPlant Data Store user home page ($username)

$estSeq="${user_input_mrna_path}${DBid}${type}.fa";  //for json; Input Transcript File, e.g. [DataStore]/username/GDB001_hpc/SCFDIR/GDB002est.fa [cdna tsa]
$libfname="${user_input_scaff_path}${DBid}gdna.fa"; // for json; Input Genome File, e.g.  [DataStore]/username/GDB001_hpc/SCFDIR/GDB002gdna.fa  
$outPutFile="${DBid}${type}.gsq"; // for json; e.g. GDB001est.gsq
$outPutPath="$user_output_data_path"; //for json; e.g.  [DataStore]/username/GDB001_hpc/GSQOUT/

## Calculate scaffold number for display (we use the sorted scaffolds in the temp directory)
$scaffolds=calculate_scaffolds($user_input_scaff_path, $proc_per_node, $proc_per_node); # jobs_functions.inc.php
$gsq_split=$scaffolds[4]; # this is for information purposes only, it is the split of segments we predict will be used 

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

error_log("\n Authentication returned http_code $http_code.\n"); #  

// DEBUG ONLY; COMMENT OUT OTHERWISE
#error_log("\n \n http_code :".$http_code." \n \n consumer_key :".$consumer_key."\n \n consumer_secret :".$consumer_secret."\n \n new access_token :".$access_token."\n\n new refresh_token:".$refresh_token."\n \n old refresh_token:".$old_refresh_token."\n\n"); 
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

    # DEBUG ONLY! COMMENT OUT WHEN LIVE
    error_log("\n Authentication succeeded. cURL submitted to URL: \n \n refresh_token=".$refresh_token."\n \n access_token=".$access_token."\n \n username=".$username."\n"); # DEBUG ONLY! COMMENT OUT WHEN LIVE

    //Create a php curl object  
        $ch = curl_init();
    
    //construct the url for this app

        $job_url="${base_url}/jobs/${api_version}"; # from Admin.admin database

    //CALLBACK URL - see http://agaveapi.co/notifications-and-events/
        $nonce = hash('sha512', mt_rand()*time()); # insure callback identity
        $callbackUrl="https://".$server."/XGDB/jobs/webhook.php?nonce=".$nonce."&ID=".$ID."&type=$type&job_id=\${JOB_ID}&status=\${JOB_STATUS}&error=\${JOB_ERROR}"; // this script will update status in MySQL tables monitored by the pipeline

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
               "libfname" => "$libfname",
                "estSeq" => "$estSeq"
            ),
            "parameters" => array
            (
               "splitSize" =>"$splitSize",
               "outPutFile" =>"$outPutFile",
               "outPutPath" =>"$outPutPath",
               "EstFormat" => "$EstFormat",
               "genomeFormat" => "$genomeFormat",
               "Species" => "$Species",
               "wsize" => "$wsize",
               "minqHSP" => "$minqHSP",
               "minqHSPc" => "$minqHSPc",
               "minqHSPc" => "$minqHSPc",
               "minESTc" => "$minESTc",
               "maxnest" => "$maxnest"
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
    //Set up a loop to retry submission every (30 seconds) if not successful, up to (5) attempts.
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
        $parameters="-s $Species -$genomeFormat $libfname -$EstFormat $estSeq -x $wsize -y $minqHSP -z $minqHSPc -w $minESTc -m $maxnest -o $outPutPath$outPutFile ";

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
        $nodeCount=$handled_json['nodeCount'];
        $archive_path=($STATUS=="PENDING")?"/${username}/archive/jobs/job-${job_id}/":"N/A";
        $comment="$attempts attempts; ";
        $comment.="${STATUS}: $submit_time | "; // This is the actual submit time returned by the server. Subsequent status updates will be concatenated here.
        // Store job data in Admin.jobs database table.

        $statement="Insert into $global_DB1.jobs (nonce, job_id, job_name, status, db_id, job_type, program, softwareName, job_URL, HPC_name, user, admin_email, seq_type, genome_file_size, 
        genome_segments, split_count, input_file_size, parameters, requested_time, processors, memory, comments, posted_data, server_response, job_submitted_time)
        values  ('$nonce','$job_id', '$job_name', '$STATUS', $ID, 'Pipeline', 'GSQ', '$app_id', '$job_url', '$HPC_name', '$username', 
        '$admin_email', '$type', '$genome_file_size', '$total_scaffold_count', '$splitSize', '$input_file_size', '$parameters', '$requested_time', '$proc_per_node', '$memory_per_node', '$comment', '$postField', '$response', '$job_submitted_time')"; 
        $do_statement = mysql_query($statement);
    
# Report the outcome 

error_log("\n gsq_remote.php cURL SUCCEEDED. Submitted to URL:".$job_url." \n postField=".$postField."\n parameters=".$parameters."\n status=".$STATUS."\n job_id=".$job_id."\n");


# Create job_directory, unique identifier. This may be needed to retrieve output where remote HPC deposits in the user's archive directory e.g. archive/jobs/job-[job_id]/GDBnnn.gsq
        $job_directory ="job-".$job_id; // combination of remote job ID and local job name. e.g. job-0001424449412643-5056a550b8-0001-007

# write job_id and result (status) to xGDB_Log table. NOTE: this is NOT jobs table! The job_id is read by the pipeline script as a sign to proceed, and it also provides the name of the output directory.

        $job_id_query = "update $global_DB2.xGDB_Log set $gsq_job = '$job_id', $gsq_job_result ='$STATUS' where ID=$ID"; # e.g. GSQ_Job_EST = 0001424449412643-5056a550b8-0001-007, GSQ_Job__EST_Result=PENDING
        $job_id_update = mysql_query($job_id_query);  

    } 
    else
    { //Curl submit failed

         error_log("\n gsq_remote.php FAILED. cURL submitted to URL:".$job_url." http_code=".$http_code." \n \n postField=".$postField."\n \n parameters=".$parameters."\n \n message=".$message."\n \n response=".$response."\n \n");
        
        $STATUS="ERROR";
        $status=$handled_json['status'];// error is the typical response (NOTE: this is different from $STATUS where a job has been successfully submitted)
        $comment="$attempts attempts; ";
        $comment.=$handled_json['message'];// Failed to submit job is the typical response
    
# Create job_name, a text identifier for failed job (no job ID assigned, so just use failure result, e.g. 'null')
        $job_id ="error-".$job_name; // combination of 'null' and local job name. e.g. error-Q2Ejd-20130313-203456

        $response_display = str_replace('>', ' ', (str_replace('>', ' ', $response))); // we will be displaying this in a table; it may be formatted

# Store job data in Admin.jobs database table.
        $statement="Insert into $global_DB1.jobs 
        (job_id, job_name, status, db_id, job_type, program, softwareName, job_URL, HPC_name, user, admin_email, seq_type, genome_file_size, genome_segments, split_count, input_file_size, parameters, requested_time, processors, memory, comments, job_submitted_time, error)
        values
        ('$job_id', '$job_name', '$STATUS', $ID, 'Pipeline', 'GSQ ', '$app_id', '$job_url', '$HPC_name', '$username', '$admin_email', '$type', '$genome_file_size', '$total_scaffold_count', '$splitSize', '$input_file_size', '$parameters', '$requested_time', '$total_threads', '$memory_per_node', '$comment', '$submitted', 'job submission FAILED - http code: $http_code - response: $response_display')";
    
        $do_statement = mysql_query($statement);
        error_log("\n Updated jobs as follows:".$statement." Success=".$do_statement." \n \n");

        $job_id_query = "update $global_DB2.xGDB_Log set $gsq_job = '$job_id', $gsq_job_result ='error' where ID=$ID"; // read by xGDB_Procedure.sh     
        $job_id_update = mysql_query($job_id_query);  

        error_log("\n Updated xGDB_Log as follows:".$job_id_query." Success=".$job_id_update." \n \n");
    }
 //destroy php curl object 
    curl_close ($ch);
}
?>
