<?php # this script parses a valid URL from Agave to update status in jobs table and xGDB_Logs table (if pipeline associated job).

$global_DB1= 'Admin';
$global_DB2= 'Genomes';
include('sitedef.php');
$Create_Date = date("m-d-Y");
include_once('/xGDBvm/XGDB/phplib/db.inc.php'); #reads MySQL password from /xGDBvm/admin/dbpass
$dbpass=dbpass();
$error="";

date_default_timezone_set("$TIMEZONE"); // from sitedef.php

############## Part I. Get status and update in jobs table. ##############

## Parse $_GET values from Callback URL sent via Agave API when job was submitted (see jobs/~_jobs.php or scripts/~_remote.php) where ~ is the app abbreviation, e.g. 'gth'.
## These callback values include status ('RUNNING', etc), and error from the remote server ('error' actually is a comment on the current status-related activity)
## We also pass the job ID and a nonce to validate the callback

if(isset($_GET['job_id']) && isset($_GET['nonce'])) # 1st level check: we need both to proceed
{
// get posted nonce, job_id
    $posted_nonce=mysql_real_escape_string($_GET['nonce']); # 
    $job_id=mysql_real_escape_string($_GET['job_id']); # e.g. 12

// validate job id, e.g. 3949611174092533275-e0bd34dffff8de6-0001-007, 2nd level check
    $pattern='/^\d+\-[a-z0-9]+\-\d+\-\d+$/';
    if(preg_match($pattern, $job_id)) # second level check
    {
        $db = mysql_connect("localhost", "gdbuser", $dbpass);
        if(!$db)
        {
            echo "Error: Could not connect to database!";
            exit;
        }
        $valid_nonce="";
        # Get the stored nonce and current status info for this job:
        $jobs_query="Select nonce, requested_time, job_start_time, job_end_time, status, error from $global_DB1.jobs where job_id = '${job_id}' ";
        $get_data = mysql_query($jobs_query);
        while($row=mysql_fetch_array($get_data))
        {
            $valid_nonce=$row['nonce'];
            $requested_time=$row['requested_time'];
            $job_start_time=$row['job_start_time'];
            $job_end_time=$row['job_end_time'];
            $error=$row['error'];
            $old_STATUS=$row['status'];
        } 
        if($posted_nonce == $valid_nonce) # third level check: compare DB-stored nonce with URL-passed nonce. If OK, then update status!
        {
            $STATUS=mysql_real_escape_string($_GET['status']);
            $ERROR=isset($_GET['error'])?" | ".mysql_real_escape_string($_GET['error']):""; #  server error string returned (if any)
            
            $timestamp =  date("Y-m-d H:i:s");
            
#### Timeout error: we want to flag any job where RUNNING time exceeds the user-requested time, as this will likely result in empty output but the Agave system doesn't flag this. 

            $timeout_error="";
            if($old_STATUS=="RUNNING" && $STATUS=="CLEANING_UP") # the job just finished processing stage-- find out if we have exceeded requested process time.
            {
                $running_end_time=$timestamp; # 
                $requested_span= strtotime("1970-01-01 $requested_time UTC");    # hack to obtain seconds 
                $running_span  = $running_end_time - $job_start_time; # how long has the job been running in seconds?
                if($running_span - $requested_span > 0) #  have we exceeded requested time?
                {
                    $timeout_error="WARNING: requested run time ($requested_span sec.) is exceeded ($running_span sec.)";   
                    $error=$timeout_error;
                }   

            }
            
            
####  Now update 'jobs' database table STATUS and timestamps, depending on the nature of the STATUS. Note that time stamps stored here are local to the VM not the HPC.
        
            if($STATUS=="RUNNING") # job execution started so we update 'job_start_time' to bracket this.
            {
            // $update_job_STATUS="Update $global_DB1.jobs set status ='$STATUS', job_start_time='$timestamp', last_updated='$timestamp', comments=CONCAT(comments, '$STATUS',':','$timestamp',', ') where job_id = '$job_id' "; # debug
            $update_job_STATUS="UPDATE $global_DB1.jobs SET status ='$STATUS', job_start_time='$timestamp', last_updated='$timestamp' WHERE job_id = '$job_id' ";
            }
            elseif($STATUS=="CLEANING_UP") # execution stage ended (successfully) so we update 'job_end_time' to bracket this.
            {
            $update_job_STATUS="UPDATE $global_DB1.jobs SET status ='$STATUS', job_end_time='$timestamp', last_updated='$timestamp' WHERE job_id = '$job_id' ";
            }
            elseif($STATUS == "KILLED" || $STATUS == "STOPPED") # execution ended on purpose but did NOT complete, so we update 'job_end_time' and 'process_complete_time' as a terminal flag.
            {
            $update_job_STATUS="UPDATE $global_DB1.jobs SET status ='$STATUS', job_end_time='$timestamp', process_complete_time='$timestamp', last_updated='$timestamp' WHERE job_id = '$job_id' ";
            }
            elseif($STATUS == "FAILED" || $STATUS == "ARCHIVING_FAILED") # execution or archive failed, so we update 'error' and also 'job_end_time' and 'process_complete_time' as a terminal flag.
            {
            $update_job_STATUS="UPDATE $global_DB1.jobs SET status ='$STATUS', job_end_time='$timestamp', process_complete_time='$timestamp', last_updated='$timestamp', comments = CONCAT(comments, ' | ERROR: ', '$error', ': ','$timestamp') WHERE job_id = '$job_id' ";
            }
            elseif($STATUS=="FINISHED") # job finished and archived so we update 'process_complete_time' as a terminal flag.
            {
            $update_job_STATUS="UPDATE $global_DB1.jobs SET status ='$STATUS', process_complete_time='$timestamp', last_updated='$timestamp' WHERE job_id = '$job_id' ";
            }
            else # some other intermediate status, so we only update the intermediate 'latest_update' time stamp.
            {
            $update_job_STATUS="UPDATE $global_DB1.jobs SET status ='$STATUS', last_updated='$timestamp' WHERE job_id = '$job_id' ";
            }
            
#### Create MySQL query to Append job STATUS and time stamp in 'comments' 
            $update_job_comments_STATUS="UPDATE $global_DB1.jobs SET comments = CONCAT(comments, ' | ', '$STATUS', ': ','$timestamp') WHERE job_id = '$job_id' ";

#### Create MySQL query to Append the 'ERROR' string (from server) to 'comments' (where STATUS is currently appended) 
            $update_job_comments_ERROR="UPDATE $global_DB1.jobs SET comments = CONCAT(comments, '$ERROR') WHERE job_id = '$job_id' ";
            
#### Create MySQL query to Append the 'error' string (problem e.g. timeout) to 'error'
            $update_job_error="UPDATE $global_DB1.jobs SET error = CONCAT(error, '$error') WHERE job_id = '$job_id' ";

##### Update 'comments' by concatenating current STATUS. 

            $do_update_comments_STATUS = mysql_query($update_job_comments_STATUS); 
            
##### Update 'comments' column by concatenating current ERROR

            $do_update_comments_ERROR = mysql_query($update_job_comments_ERROR); # 'error' is reserved for timeout errors so far
            
##### Update 'error' column by concatenating current timeout error (if any)
            $do_update_error = mysql_query($update_job_error);
            
##### Update 'status' field ONLY if we haven't yet achieved FINISHED, (even though we keep updating 'comments'). 
##### This is because some STATUS updates may occur out of order after FINISHED has been received, and we want 'status=FINISHED' to be an endpoint for GUI script behavior. 

            if($old_STATUS != "FINISHED"){
            $do_update_job_STATUS = mysql_query($update_job_STATUS);
            }
 
############## Part II. Pipeline Jobs only: Get status and update xGDB_Log table ##############

##### If GDB ID (1, 2, 3, etc) is passed via webhook URL, this is a pipeline-integrated job.
##### So, we update the Genomes.xGDB_Log MySQL table for this ID.
##### During pipeline processing, xGDB_Procedure.sh will monitor this value in order to advance the pipeline.

            if(isset($_GET['ID'])) # e.g. 1
            {
            
            // Get Posted values:
            
			$ID = intval($_GET['ID']); // this is the GDB ID, e.g. '1'
			$type=mysql_real_escape_string($_GET['type']); 
			
			// Assign MySQL column depending on query data type (est, cdna, tsa, prot)
			
			switch ($type) 
				{
			case "est":
				$Job_ID="GSQ_Job_EST"; //column to update
				$Job_Result="GSQ_Job_EST_Result"; //column to update
				break;
			case "cdna":
				$Job_ID="GSQ_Job_cDNA"; //column to update
				$Job_Result="GSQ_Job_cDNA_Result"; //column to update
				break;
			case "tsa": // i.e. put
				$Job_ID="GSQ_Job_PUT"; //column to update
				$Job_Result="GSQ_Job_PUT_Result"; //column to update
				break;
			case "prot": // i.e. put
				$Job_ID="GTH_Job"; //column to update
				$Job_Result="GTH_Job_Result"; //column to update
				break;
			    }
				$update_log = "update $global_DB2.xGDB_Log set $Job_Result = '$STATUS' where ID=$ID AND $Job_ID='$job_id'"; # e.g. GTH_Job = 0001424449412643-5056a550b8-0001-007, GTH_Job_Result=PENDING
				if($update_log = mysql_query($update_log))
				{
					$log_updated=true;
				}
				else
				{
					$log_updated=false;
          			echo "could not update xGDB_Log. DBid or job id does not match";
				}  
            
            }
            
            
        //  echo "$update_job_status"; #debug only
        }
          else
        {
          echo "invalid request. Nonce does not match";
        }
    unset($_GET['job_id']);
    exit;
    }
}
else
{
echo "invalid request. job_id or nonce not specified.";
unset($_GET['job_id']);
unset($_GET['nonce']);
}

?>
