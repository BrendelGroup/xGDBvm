<?php # This script is the Agave successor to the submit.php script (renamed to be more accurate in describing its function) Latest update: 3/8/15
session_start();

####### Set POST validation variable for this browser session #######

$valid_post = mt_rand();
$_SESSION['valid'] = $valid_post;

include('sitedef.php');
include_once('/xGDBvm/XGDB/jobs/login_functions.inc.php'); #common functions required in this script
date_default_timezone_set("$TIMEZONE"); // from sitedef.php

####### Token lifespan and logout  ########

// Get session data that persists from the last login.
$username=isset($_SESSION['username'])?$_SESSION['username']:"";// username for login to authenticate
$http_code=isset($_SESSION['http_code'])?$_SESSION['http_code']:"";// code returned by curl
$expires=isset($_SESSION['expires'])?$_SESSION['expires']:""; //Authorization token expiration
$access_token=isset($_SESSION['access_token'])?$_SESSION['access_token']:""; //if present, indicates user is authenticated
$refresh_token=isset($_SESSION['refresh_token'])?$_SESSION['refresh_token']:""; //if present, indicates user is capable of refreshing even if access_token has expired.
$username=isset($_SESSION['username'])?$_SESSION['username']:"";// username for login to authenticate
$dbid=isset($_SESSION['dbid'])?$_SESSION['dbid']:""; //most recent GDB configuration viewed or edited (NOT NEEDED HERE?)
$login_id=isset($_SESSION['login_id'])?$_SESSION['login_id']:""; // (set by login_exec.php); this is the GDB that was originally used for login (if any), go to the logout script, and return here.

$redirect ="submit"; // return here if logged out

// Check login status and redirect to logout if warranted
$logout_result = login_status($redirect, $username, $http_code, $access_token, $refresh_token, $login_id, $expires); // login.functions_inc.php; checks login/refresh status based on elapsed time and stored refresh token
$logout_redirect = $logout_result[0];
$time_left = $logout_result[1];

if($logout_redirect != "")
{
header("Location: $logout_redirect"); // logs out (resets session variables)
}

###### End token lifespan and logout #####

// Set globals and includes

$debug='display_off';
$global_DB= 'Admin';
$PageTitle = 'Submit Standalone Job';
$pgdbmenu = 'Manage';
$submenu1 = 'Jobs-Home';
$submenu2 = 'SubmitJob';
$leftmenu='SubmitJob';
include('sitedef.php');
include($XGDB_HEADER);
$Create_Date = date("m-d-Y");
include_once('/xGDBvm/XGDB/phplib/db.inc.php'); #reads MySQL password from /xGDBvm/admin/dbpass
include_once('/xGDBvm/XGDB/jobs/jobs_functions.inc.php'); #common functions required in this script
$inputDir=$XGDB_INPUTDIR; # 1-26-15 from sitedef.php; e.g. /xGDBvm/input/xgdbvm/
$inputDirRoot=$XGDB_INPUTDIR_ROOT; # 1-26-16 J Duvick This is the top level path, e.g. /xGDBvm/input/
$inputTopDir=$INPUT_TOPDIR; # 1-26-2016 top level directory for xGDBv -related files on user's iPlant Data Store, e.g. xgdbvm/

//access MySQL
$dbpass=dbpass();
$db = mysql_connect("localhost", "gdbuser", $dbpass);
if(!$db)
	{
		echo "Error: Could not connect to $test database!";
		exit;
	}


#### Validate presence of GTH Key (required for remote GTH) ###

$validate_gth=validate_dir($KEY_SOURCE_DIR, $GENOMETHREADER_KEY, "GenomeThreader License Key", "present", "missing");
$gth_valid=$validate_gth[0]; $gth_class=$validate_gth[1];
$gth_valid_message="<span class=\"$gth_class\">GTH license ${gth_valid}:</span> ${KEY_SOURCE_DIR}${GENOMETHREADER_KEY} <img id='jobs_gth_license' title='GenomeThreader License - Help' class='help-button nudge3 smallerfont' src='/XGDB/images/help-icon.png' alt='?' />";


### show or hide login/logout/refresh blocks depending on token status ###
$conditional_display_logged_out=($access_token=="")?"":"display_off"; # display 'logged out' message only if user is logged out (no access token)
$conditional_display_login=($access_token=="" && $refresh_token=="")?"":"display_off"; # display 'login' option only if user is logged out (no access token) and no refresh token is present
$conditional_display_logout=($access_token!="")?"":"display_off"; # display login details and 'logout' option only if user is logged in.
$conditional_display_refresh=($refresh_token!="")?"":"display_off"; # display 'refresh' option only if refresh_token is present

## Get most recent Authorization URL from Admin database;

	$auth_query="SELECT uid, auth_url, api_version, auth_update from $global_DB.admin where auth_url !='' order by uid DESC limit 0,1";
	$auth_result = mysql_query($auth_query);
	$auth=mysql_fetch_array($auth_result);
	$auth_url=$auth['auth_url'];
	$api_version=$auth['api_version'];
	$auth_update=$auth['auth_update'];
	$auth_message=($auth_url=="")?"<span class=\"warning indent2\">No base URL has been configured <a href=\"/XGDB/jobs/configure.php\">(go do it)</a> </span>":"<span class=\"checked indent2\">Auth URL $auth_url is current</span>";

## Get processor (core) count for the default app for GSQ

	$gsq_query="SELECT * from $global_DB.apps where program ='GeneSeqer-MPI' and is_default='Y'";
	$gsq_result = mysql_query($gsq_query);
	$gsq=mysql_fetch_array($gsq_result);
	$gsq_appId=$gsq['app_id'];
	$gsq_nodes=$gsq['nodes'];
	$gsq_proc_per_node=$gsq['proc_per_node'];
	$gsq_proc=$gsq_nodes*$gsq_proc_per_node;
	$is_default=$gsq['is_default'];
	$gsq_message=($gsq_appId=="")?"<span class=\"warning indent2\">No GSQ App has been configured <a href=\"/XGDB/jobs/apps.php\">(go do it)</a> </span>":"<span class=\"checked indent2\">GSQ App ID:</span>$gsq_appId";

## Get processor (core) count for the default app for GTH

	$gth_query="SELECT * from $global_DB.apps where program ='GenomeThreader' and is_default='Y'";
	$gth_result = mysql_query($gth_query);
	$gth=mysql_fetch_array($gth_result);
	$gth_appId=$gth['app_id'];
	$gth_nodes=$gth['nodes'];
	$gth_proc_per_node=$gth['proc_per_node'];
	$gth_proc=$gth_nodes*$gth_proc_per_node;
	$is_default=$gth['is_default'];
	$gth_message=($gth_appId=="")?"<span class=\"warning indent2\">No GTH App has been configured <a href=\"/XGDB/jobs/apps.php\">(go do it)</a> </span>":"<span class=\"checked indent2\">GTH App ID:</span>$gth_appId";

# query for admin_email

	$email_query="SELECT uid, admin_email from $global_DB.admin where admin_email !='' order by uid DESC limit 0,1";
	$email_result = mysql_query($email_query);
	$email=mysql_fetch_array($email_result);
	$admin_email=$email['admin_email'];



/*/debug: 
		$usersession=$_SESSION['username'];
		$userpost=$_POST['username'];
		$tokensession=$_SESSION['access_token'];
		$http_code_session=$_SESSION['http_code'];
		$posted_action=$_POST['action']; //now posted to login.php; should be blank.
#		$expires-session=$_SESSION['expires'];
		$remaining=$expires-time();
		$time=time();
		$timeU=date("U");
		$sessionID=$_SESSION['id'];
		$isset_token=isset($_SESSION['token']);
		$msg=$_GET['msg'];
		echo "ID=$sessionID; access token=$access_token; isset-token=$isset_token; msg=$msg; login-msg=$login_msg; http_code=$http_code_session; userpost=$userpost; username=$username; auth_url=$auth_url; user-session=$usersession; user-post=$userpost; access_token= $access_token; token-session=$tokensession; posted_action=$action; now=$now; remaining=$remaining; expires-session=$expires; lifespan-session =$lifespan; issued-session=$issued; timeU=$timeU; ";
// end debug */

#The user needs to select a valid GDB ID or else they will not be able to submit job.

if(isset($_GET['id']))
	{
//create a session ID variable
	$ID=intval($_GET['id']);
	$_SESSION['id']=$ID;
	}
	elseif(isset($_SESSION['id']))
	{
	$ID=$_SESSION['id'];
	}
	else
	{
	$ID="";
	}
// Get data assoc. with this ID and reconstruct GDBnnn

$gdbQuery="SELECT DBname, Status FROM Genomes.xGDB_Log where ID =$ID"; 
$get_gdb = $gdbQuery;
$check_get_gdb = mysql_query($get_gdb);
global $DBid;
while ($gdb_data = mysql_fetch_array($check_get_gdb))
		{
		$DBname = $gdb_data['DBname'];	
		$Status = $gdb_data['Status'];
		$DBid="00".$ID;
		$DBid = "GDB".substr($DBid, -3, 3);
		$dbid = strtolower($DBid);
		}
$job_name = "${DBid}-${DBname}";
$job_name_submit = job_name_strip($job_name); // display only; jobs_functions.inc.php; strip illegal chars
 
##  Create dropdown using the current DBid (if any) as the "selected" option 
$gdb_dev_list = gdb_external_dropdown($DBid); # (jobs_functions.inc.php; POSTS id=ID)

## create program-specific app list dropdowns 
$gsq_apps_dropdown=apps_dropdown('GeneSeqer-MPI'); //jobs_functions.inc.php
$gth_apps_dropdown=apps_dropdown('GenomeThreader'); //jobs_functions.inc.php

## Get GTH parameters for the GDB selected
$param_query="SELECT Status, Species_Model,Alignment_Stringency, Gth_Species_Model,Input_Data_Path from Genomes.xGDB_Log where ID= $ID";
$get_param_record = $param_query;
$check_get_param_record = mysql_query($get_param_record);
$param_result = $check_get_param_record;
$param=mysql_fetch_array($param_result);
$status=$param['Status'];
$gsq_species=$param['Species_Model'];
$gsq_alignment_stringency=$param['Alignment_Stringency'];

## Get GenomeThreader parameters for the GDB selected
$gth_species=$param['Gth_Species_Model'];

## Get input data path for the GDB selected
$gsq_input_path=$param['Input_Data_Path']; //This is the user-specified input data path set up under view.php, e.g. /xGDBvm/input/xgdbvm/myInputs/
$gth_input_path=$param['Input_Data_Path']; //This is the user-specified input data path set up under view.php, e.g. /xGDBvm/input/xgdbvm/myInputs/

## Create DataStore user base including user-specified directory from input path (these have user's home directory as base) Updated 1/26/16 to include /xgdbvm/tmp in path
$user_input_base="/${username}/${inputTopDir}tmp/${DBid}_hpcs/"; // e.g. /username/xgdbvm/tmp/GDB001_hpcs/  ("s" is for Standalone, so won't interfere with running pipeline temp dir)

### Directory Mount Status ###
# data directory:/data/ ($dir1)
 $dir1_status="";
if (file_exists("/xGDBvm/admin/iplant")) { // xGDBvm-iPlant only
   $dir1="/xGDBvm/data/"; // TODO: move to sitedef.php
   $df_dir1=df_available($dir1); // check if /data/ directory is externally mounted (returns array)
	$devloc=str_replace("/","\/",$EXT_MOUNT_DIR); // read from device location stored in /xGDBvm/admin/devloc via sitedef.php
	$dir1_mount=(preg_match("/$devloc/", $df_dir1[0]))?"<span class=\"checked_mount\">Ext vol mounted</span>":"<span class=\"lightgrayfont\">Ext vol not mounted</span>"; //flag for dir1 mount
	$dir1_status="<span class=\"normalfont \" style=\"font-weight:normal\"><a class='help-button' title='Mount status of /xGDBvm/data/' id='config_input_ebs'> $dir1_mount </a></span>";
}

# data store directory:/input/ ($dir2)
 $dir2_status_display="";
 $data_store_mount="not mounted"; 
if (file_exists("/xGDBvm/admin/iplant")) { // xGDBvm-iPlant only
	$dir2="$inputDirRoot"; // 
	$df_dir2=df_available($dir2); // check if /input/ directory is fuse-mounted (returns array)
	$dir2_status=($df_dir2[0]=="fuse"  || $df_dir2[0]=="irodsFs")?"mounted":"not mounted";
	$dir2_dropdown=($dir2_status=="mounted")?"/xGDBvm/input/":""; //only show input dir if fuse-mounted
	$dir2_status_formatted=($dir2_status=="mounted")?"<span class=\"checked_mount nowrap\">DataStore mounted</span>":"<span class=\"lightgrayfont\">DataStore not mounted</span>"; //flag for dir2 mount (Data Store) top of form
	$mount_status_alert=($df_dir2[0]=="fuse" || $df_dir2[0]=="irodsFs")?"<span class=\"checked nowrap\">DataStore mounted</span>":"<span class=\"warning\">DataStore not mounted</span>"; //more intrusive flag
	$dir2_status_display="<span class=\"normalfont \" style=\"font-weight:normal\"><a class='help-button' title='Mount status of $inputDirRoot' id='config_input_irods'> $dir2_status_formatted </a></span>";
}

## Hide "Job Submit" button unless all parameters (gdb, login, appId) in place
$class_if_ready = ($DBid!=="")?"":"display_off";
$class_if_not_ready = ($DBid=="")?"":"display_off";
$gsq_class_if_ready = (($DBid!="") && ($access_token!="") && ($gsq_appId!="") && ($dir2_status=="mounted"))?"":"display_off";
$gsq_class_if_not_ready = (($DBid=="") || ($access_token=="") || ($gsq_appId=="") || ($dir2_status=="not mounted"))?"":"display_off";
$gth_class_if_ready = (($DBid!="") && ($access_token!="") && ($gsq_appId!="") && ($dir2_status=="mounted"))?"":"display_off";
$gth_class_if_not_ready = (($DBid=="") || ($access_token=="") || ($gsq_appId=="") || ($dir2_status=="not mounted"))?"":"display_off";


// Build first part of page (we still don't know if the login query succeeded)

echo
		'<div id="leftcolumncontainer">
			<div class="minicolumnleft">';

include_once("/xGDBvm/XGDB/jobs/leftmenu.inc.php");
			
echo'	</div>
		</div>
			<div id="maincontentscontainer" class="twocolumn admin">
				<div id="maincontentsfull">';

//If response went well, print three forms for user to use.  If not ask for user to re-enter data

#if(1) # debug only


	if ($DBid!="") //user has entered a GDB; show actual data. Otherwise just show blank form.
		{
			$gdb_link="<a title=\"Visit $DBid Config Page\" href=\"/XGDB/conf/view.php?id=$ID\">$DBid</a>"; // display instead of "required"
			$gdb_config_display="<a title=\"View$DBid configuration page (opens a new web browser page/tab\" target=\"_blank\" href=\"/XGDB/conf/view.php?id=$ID\">View $DBid configuration page</a>";
	
		// Assign default parameters
		
            $gsq_output_path="/".$username."/".$inputTopDir."/tmp/".$DBid."_hpcs/GSQOUT/"; // e.g. /username/xgdbvm/tmp/GDB001hpc/GSQOUT/  NOTE - not using this currently but leaving in place
            $gth_output_path="/".$username."/".$inputTopDir."/tmp/".$DBid."_hpcs/GTHOUT/"; // e.g. /username/xgdbvm/tmp/GDB001hpc/GTHOUT/  NOTE - not using this currently but leaving in place
			
		// Parse from parameter string: wsize, minqHSP, minqHSPc, Species
			switch ($gsq_alignment_stringency)
				{
			case ($gsq_alignment_stringency == "Strict"):
				$parameters = "-x 30 -y 45 -z 60 -w 0.80";
				break;
			 case ($gsq_alignment_stringency == "Moderate"):
				$parameters = "-x 16 -y 24 -z 48 -w 0.80";
				break;
			case ($gsq_alignment_stringency == "Low"):
				$parameters = "-x 12 -y 12 -z 30 -w 0.80";
				break;
				}

			$param = explode(" ", $parameters);
			$wsize=$param[1]; // -x
			$minqHSP=$param[3];// -y
			$minqHSPc=$param[5]; // -z 
			$minESTc=$param[7]; // -w  
		## GeneSeqer parameters
			$libfname="${user_input_base}SCFDIR/${DBid}gdna.fa"; # temp input path for Genome File e.g. /username/hpcGDB002/SCFDIR/GDB002gdna.fa	
			$EstFormat="D"; # Assumes non-GenBank FASTA headers
			$estSeq="${user_input_base}MRNADIR/${DBid}";  # temp input path for path for Transcript File e.g. /username/hpcGDB002/MRNADIR/GDB002 (NOTE!! transcript type suffix e.g. est is added after post to gsq_job.php)
			$maxnest="999999999"; # this is the default
			$editable="";
		## GenomeThreader parameters
			$input_g="${user_input_base}SCFDIR/${DBid}gdna.fa"; # temp input path for Genome File e.g. /username/hpcGDB002/SCFDIR/GDB002gdna.fa	
			$input_p="${user_input_base}Protein/${DBid}prot.fa";  # temp input path for Transcript File e.g. /username/hpcGDB002/Protein/GDB002prot.fa

		##  Set validation style for input files
			$valid_est_array = create_input_list($gsq_input_path, "transcript", $dbpass); // generic; covers est, cdna, tsa
			$valid_est=$valid_est_array[0];
			$valid_prot_array = create_input_list($gsq_input_path, "protein", $dbpass);
			$valid_prot=$valid_prot_array[0];
			$valid_gdna_array = create_input_list($gsq_input_path, "gdna", $dbpass);
			$valid_gdna=$valid_gdna_array[0];
			$valid_out_array = create_input_list($output_data_path, "gsq.".$DBid, $dbpass); # e.g. 	gsq.GDB001cdna, test for type in function.
			$valid_out=$valid_out_array[0];
        ## Set return job estimates based on size distribution of gdna:
            $scaffolds=calculate_scaffolds($gsq_input_path, $gsq_proc, $gth_proc); # jobs_functions.inc.php
            // return array($large_scaffold_count, $small_scaffold_count, $chunks, $remainder_size, $gsq_split, $gth_split, $scaffold_size_display, $gsq_split_display, $gth_split_display, $gsq_time_display, $gth_time_display);

            $large_scaffold_count=$scaffolds[0];
            $small_scaffold_count=$scaffolds[1];
            $total_scaffold_count=$large_scaffold_count + $small_scaffold_count;
            $break_point_count=$scaffolds[2];
            $remainder_size=$scaffolds[3];
            $gsq_split=$scaffolds[4];
            $gth_split=$scaffolds[5];
            $scaffold_sizes_display=$scaffolds[6];
            $gsq_split_display=$scaffolds[7];
            $gth_split_display=$scaffolds[8];
            $gsq_time_display=$scaffolds[9];
            $gth_time_display=$scaffolds[10];

		}
## Set GSQ parameter values that are not user-modifiable
	
	
	## Load help files for display


		echo "<div class=\"featurediv bottommargin2\"> 
		<table width=\"95%\">
					<colgroup>
						<col width =\"30%\" />
						<col width =\"10%\" />
						<col width =\"55%\" style=\"background-color: #EEE\"  />
						<col width =\"5%\" />
					</colgroup>	
					<tr>
					<td>
						<h1 class=\"jobs\"> <img src=\"/XGDB/images/remote_compute.png\" alt=\"\" /> &nbsp;Submit Standalone Job </h1>
						<span class=\"$debug\">large_scaffold_count=$large_scaffold_count small_scaffold_count=$small_scaffold_count break_point_count=$break_point_count remainder_size=$remainder_size; sizes_display=$scaffold_sizes_display</span>
				        <span class=\"normalfont\" style=\"font-weight:normal\">&nbsp; $dir1_status  &nbsp; $dir2_status_display </span>

					</td>
					<td> <span class=\"bigfont bold\"> <a title=\"Visit $DBid Config Page\" href=\"/XGDB/conf/view.php?id=$ID\">$DBid</a> </span>
					</td>
					<td style=\"padding:10px; border: 1px solid #DDD\"> <span class=\"status_box $conditional_display_logout\"> 
						<span class=\"checked smallerfont\">\"$username\" </span>is authorized to submit jobs  
						(token expires in <span class=\"alertnotice\">$time_left</span>)
						<!-- span class=\"smallerfont $conditional_display_refresh\"><a title=\"refresh authorization\" href=\"/XGDB/jobs/login_exec.php?action=refresh&redirect=submit\">(refresh)</a></span-->
						<br />
						<span class=\"smallerfont\">$gsq_message</span><br />
						<span class=\"smallerfont\">$gth_message</span><br />
						<span class=\"smallerfont\">$gth_valid_message</span>
						</span>
						<span class=\"$conditional_display_logged_out normalfont indent2\"><span class=\"warning\">You are not currently authenticated for remote computing on this VM.</span>
					</td>
					<td style=\"padding:10px; border: 1px solid #DDD\">
						<span class=\"smallerfont $conditional_display_refresh\">
						    <form action=\"/XGDB/jobs/login_exec.php\" method=\"post\">
						        <input type=\"hidden\" name=\"action\" value=\"refresh\" />
						        <input type=\"hidden\" name=\"redirect\" value=\"submit\" />
                                <input type=\"submit\" name=\"refresh\" value=\"refresh\">
                            </form>
                            
                        </span>
                        
						<span class=\"smallerfont $conditional_display_logout nowrap\">
						    <form action=\"/XGDB/jobs/logout_exec.php\" method=\"post\">
						        <input type=\"hidden\" name=\"msg\" value=\"logout\" />
						        <input type=\"hidden\" name=\"redirect\" value=\"submit\" />
                                <input type=\"submit\" name=\"logout\" value=\"log out\">
                            </form>
                        </span>
                        <span  class=\"$conditional_display_login normalfont nowrap\">
                            <a style=\"text-decoration: none\" href=\"/XGDB/jobs/login.php#login\"> &nbsp; log in</a>
                        </span>
                        </td>
				</tr>
			</table>
			</div>";
	
		echo "
			<div class=\"featurediv topmargin2 bottommargin2\">
				 <p>
				    <span class=\"largerfont \">Below you can submit a standalone <a href=\"#gsq\">GSQ</a> or <a href=\"#gth\">GTH</a> job. When finished, you can add the output to an annotation workflow.</span>
				 </p>
				 <p>
				    <span class=\"largerfont \"> First you MUST configure a GDB with <span class=\"Development\">Development</span> status that points to your input data, then <b>select</b> it below. </span>
				</p>
				<p>
				<span class=\"tip_style largerfont\">
				    Check server status before submitting:
				 <a target=\"_blank\" title=\"Visit XSEDE User Services newsfeed\" href=\"https://www.xsede.org/news/-/news/search?_usernews_WAR_usernewsportlet_categories=80&_usernews_WAR_usernewsportlet_types=OUTAGE\">Stampede</a>; 
				 <a target=\"_blank\" title=\"Visit XSEDE User Services newsfeed\" href=\"https://www.xsede.org/news/-/news/search?_usernews_WAR_usernewsportlet_categories=32&_usernews_WAR_usernewsportlet_keywords=&_usernews_WAR_usernewsportlet_types=OUTAGE\">Lonestar</a>
                </span> 
				 </p>
				 <div class=\"description showhide \"><p title=\"Show additional information directly below this link\" class=\"label\" style=\"cursor:pointer\"> Click for instructions...</p>
					<div class=\" hidden\">";
					
				include_once('/xGDBvm/XGDB/help/includes/jobs_standalone.inc.php'); 
		echo "
					</div><!-- end hidden -->
				</div><!-- end showhide-->
			</div>

			<fieldset id=\"login\"  class=\"bottommargin1 topmargin2 xgdb_jobs\">
				
		    <legend class=\"conf\"> &nbsp; Select a GDB ($gdb_link) <img id='jobs_configure' title='Learn about GDB requirement' class='help-button  nudge2' src='/XGDB/images/help-icon.png' alt='?' /></legend>

			<div class=\"featurediv topmargin2 bottommargin2\">
			<form action=\"submit.php?id=$id\" method=\"get\">
			<table class=\"xgdb_log\" border=\"0\" style=\"font-size:12px\" width=\"95%\" >
				<tr>
					<td>
					<label class=\"\" for=\"id\"><b>GDB ID:<b></label>
				</td>
					<td align=\"left\">
	
						<select name=\"id\">
							$gdb_dev_list
						</select>
	
					  	<button type=\"submit\" class=\"btn\">Select DB</button>
					</td>
					<td align=\"right\">
						$gdb_config_display
					</td>
				</tr>
			</table>
			</form>
			</div>
			</fieldset>
			<br />
			";
			
	 echo "<div id=\"gsq\" class=\"topmargin2 bottommargin2\">
			<form class=\"\" action=\"gsq_job.php\" method=\"post\">
				<input  type=\"hidden\" name=\"auth_url\" value=\"$auth_url\" />
				<input  type=\"hidden\" name=\"api_version\" value=\"$api_version\" />
				<input  type=\"hidden\" name=\"gdb\" value=\"$DBid\" />
				<input  type=\"hidden\" name=\"id\" value=\"$ID\" />
				<input  type=\"hidden\" name=\"access_token\" value=\"$access_token\" />
				<input  type=\"hidden\" name=\"username\" value=\"$username\" />
				<input  type=\"hidden\" name=\"input_data_path\" value=\"$gsq_input_path\" />
				<input  type=\"hidden\" name=\"outputPath\" value=\"$gsq_output_path\" />
				<input   type=\"hidden\"  name=\"estSeq\" value=\"$estSeq\" />
				<input  type=\"hidden\" name=\"libfname\" value=\"$libfname\" />
				<input  type=\"hidden\" name=\"total_scaffold_count\" value=\"$total_scaffold_count\" />
				<input  type=\"hidden\" name=\"gsq_split\" value=\"$gsq_split\" />
                <input type=\"hidden\" name=\"valid\" value=\"$valid_post\" />
				<fieldset id=\"gsq\"  class=\"bottommargin1 topmargin2 xgdb_jobs\">
				
				<legend class=\"conf\"> &nbsp; Submit a GeneSeqer-MPI Job: <a title=\"Visit $DBid Config Page\" href=\"/XGDB/conf/view.php?id=$ID\">$DBid</a> &nbsp; <img id='jobs_geneseqer' title='More information about GeneSeqer-MPI HPC' class='help-button  nudge2' src='/XGDB/images/help-icon.png' alt='?' /></legend>
					<div class=\"bottommargin1\">
						<span class=\"largerfont\"> <b>Instructions:</b> Make sure you have selected the correct configured GDB from the dropdown above, and then follow the steps below to submit job. Monitor progress on <a href=\"/XGDB/jobs/jobs.php\">List Jobs</a> page</span>
					</div>
				<div class=\"topmargin2\" \"bottommargin1\">
				<table id=\"gsq_data\" class=\"xgdb_log featuretable bottommargin1\" border=\"0\" style=\"font-size:12px\" width=\"95%\" >
					<colgroup>
						<col width =\"50%\" />
						<col width =\"50%\" />
					</colgroup>
					<tbody>
							<tr class=\"jobs\">
						    <th class=\"bigfont\" colspan=\"2\"; style=\"text-align:center\">
						    		<b>Genome</b>
                            </td>
                        </tr>
						<tr>
							<td> 
								<p class= \"bold\"> <span class=\"hugefont\">1.</span> Verify that the genome input file contents are correct and <span class=\"filevalid\">valid</span> (click <img class=\"nudge3\" alt=\"info\" src=\"/XGDB/images/information.png\" />) </p>
							</td>
							<td valign=\"center\">
								$valid_gdna
							</td>
						</tr>
						<tr>
							<td> 
							    <p class=\"bold\"> <span class=\"hugefont\">2.</span> Check genome size distribution, split, and estimated job time at right, and <a title=\"open Configure page\" href=\"/XGDB/jobs/configure.php#gsq_configure\">change job parameters</a> if needed.</p>
							</td>
 							<td>
								$scaffold_sizes_display
								$gsq_split_display
								$gsq_time_display
								<p class=\"italic\">Max=12 hr. To reduce job time, <a href=\"/XGDB/jobs/apps.php\">select an app with more processors (cores) as default</a>.
							</td>
						</tr>
						<tr class=\"jobs\">
						    <th class=\"bigfont\" colspan=\"2\"; style=\"text-align:center\">
						    		<b>Query mRNA</b>
                            </td>
                        </tr>
						<tr>
							<td>
							   <p class= \"largerfont bold\"><span class=\"hugefont\">3.</span>  Verify that the query file(s) contents are correct and are <span class=\"filevalid\">valid</span> (click <img class=\"nudge3\" alt=\"info\" src=\"/XGDB/images/information.png\" />)</p>
						    </td>
							<td valign=\"center\">
								$valid_est
							</td>
						</tr>
						<tr>
							<td class=\"$edit user_entry\"  align = \"left\" class=\"bigfont\">
							   <p class= \"bold\"><span class=\"hugefont\">4.</span> Choose which Query Sequence Type to align:</p>
							</td>
							<td>
							   <span class=\"indent2\">
								   <input type=\"radio\" name=\"transcript_type\" checked=\"checked\" id=\"est_type\" value=\"est\"> EST&nbsp;
								   <input type=\"radio\" name=\"transcript_type\" id=\"cdna_type\" value=\"cdna\"> cDNA &nbsp;
								   <input type=\"radio\" name=\"transcript_type\" id=\"tsa_type\" value=\"tsa\"> TSA 
							   </span>
							</td>
						</tr>					
						<tr>
							<td colspan=\"2\">
							 <p class= \"largerfont bold\"><span class=\"hugefont\">5.</span>  Modify GeneSeqer / Job parameter defaults as desired below</p>
							</td>
						</tr>
						<tr>
							<td colspan=\"2\">
							 <p class= \"largerfont bold\"><span class=\"hugefont\">6.</span>  Click 'Submit GSQ Job'. Page may take awhile to refresh while data are being transferred.</p>
							</td>
						</tr>

				</tbody>
				</table>
				<table id=\"gsq_params\" class=\"xgdb_log featuretable topmargin2\" border=\"0\" style=\"font-size:12px\" width=\"95%\" >
					<colgroup>
						<col width =\"25%\" style=\"background-color: #DDD\" />
						<col width =\"25%\" />
						<col width =\"40%\" />
					</colgroup>
					<tbody>
						<tr class=\"jobs\">
							<th>
								<b>GSQ Parameters</b>
							</th>
							<th>
								<b>Modify Defaults (optional)</b>
							</th>
							<th>
								<b>Comments</b>
							</th>
						</tr>
						<tr>
							<td>Species Model:</td>
							<td class=\"$edit user_entry\"  align = \"left\" class=\"bigfont\">
								 <input size=\"10\" type=\"text\" name=\"Species\"  value=\"$gsq_species\" $editable />
							</td>
							<td>
							Choose species model appropriate for your genome
							</td>
						</tr>					
						<tr>
							<td>Word Size (-x):</td>
							<td class=\"$edit user_entry\"  align = \"left\" class=\"bigfont\">
								 <input size=\"4\" type=\"text\" name=\"wsize\"  value=\"$wsize\" $editable />
							</td>
							<td rowspan=\"4\"> 
								Currently set to \"$gsq_alignment_stringency\"  stringency ($parameters)<br />
								Increasing 'Word Size', 'min HSP Quality', or 'min HSP chain Quality'  will improve search speed and selectivity but reduce sensitivity.<br />
								'min EST coverage': Alignments with lower than threshold coverage will not be pursued.<br /><br />
								See <a target=\"_blank\" title=\"View xGDBvm Wiki (opens a new Web browser page) \" href=\"http://goblinx.soic.indiana.edu/wiki/doku.php?id=geneseqer&s[]=geneseqer#geneseqer_help\">xGDBvm wiki</a> for details
							</td>
						</tr>					
						<tr>
							<td>min HSP qual (-y):</td>
							<td class=\"$edit user_entry\"  align = \"left\" class=\"bigfont\">
								 <input size=\"4\" type=\"text\" name=\"minqHSP\"  value=\"$minqHSP\" $editable />
							</td>
						</tr>					
						<tr>
							<td>min HSP chain qual (-z):</td>
							<td class=\"$edit user_entry\"  align = \"left\" class=\"bigfont\">
								 <input size=\"4\" type=\"text\" name=\"minqHSPc\" value=\"$minqHSPc\" $editable />
							</td>
						</tr>					
						<tr>
							<td>min EST coverage (-w; 0<>1.0):</td>
							<td class=\"$edit user_entry\"  align = \"left\" class=\"bigfont\">
								 <input size=\"4\" type=\"text\" name=\"minESTc\" value=\"$minESTc\" $editable />
							</td>
						</tr>	
						<tr>
							<td>Max est per segment (-m):</td>
							<td class=\"$edit user_entry\"  align = \"left\" class=\"bigfont\">
								<input size=\"10\" type=\"text\" name=\"maxnest\"  value=\"$maxnest\" $editable />
							</td>
							<td>
								Max spliced alignments per genomic DNA segment
							</td>
						</tr>
						<tr class=\"jobs\">
							<th>
								<b>Job Parameters</b>
							</th>
							<th>
								<b>Modify Defaults (optional)</b>
							</th>
							<th>
								<b>Comments</b>
							</th>
						</tr>
						<tr>
							<td>App ID:</td>
							<td class=\"$edit user_entry\"  align = \"left\" class=\"bigfont\">
	        		    	 <select name=\"gsq_app_id\">
	        			        $gsq_apps_dropdown
	        			     </select>	
	        			  </td>
							<td>
                                Choose appropriate app for genome size & segmentation <a href=\"/XGDB/jobs/apps.php\">(more info)</a>
							</td>
						</tr>
						<tr>
							<td>Requested Time:</td>
							<td class=\"$edit user_entry\"  align = \"left\" class=\"bigfont\">
	        		    	 <select name=\"requested_time\">
                                    <option selected=\"selected\" value=\"12:00:00\">12 h </option>
                                    <option value=\"06:00:00\">6 h </option>
                                    <option value=\"03:00:00\">3 h </option>
                                    <option value=\"01:00:00\">1 h </option>
                                    <option value=\"00:10:00\">10 m </option>
                                    <option value=\"00:01:00\">1 m </option>
                            </select>
							</td>
							<td>
								Choose minimum time that exceeds expected process time (12 hr max)
							</td>
						</tr>
						<tr>
							<td>Admin Email </td>
							<td class=\"$edit user_entry\"  align = \"left\" class=\"bigfont\">
								 <input size=\"20\" type=\"text\" name=\"admin_email\" id=\"gsq_admin_email\" value=\"$admin_email\" />
							</td>
							<td>
								Will be notified when job starts, finishes or fails
							</td>
						</tr>						
						<tr>
							<td>GSQ Job Name <span class=\"heading\">(max 75 char)</span></td>
							<td class=\"$edit user_entry\"  align = \"left\" class=\"bigfont\">
								 <input size=\"50\" type=\"text\" name=\"gsq_job_name\" id=\"gsq_job_name\" value=\"$job_name_submit\"  $editable />
							</td>
							<td>
							    Alphanumeric characters & dashes only
							</td>
						</tr>

					</tbody>
				</table>
				</div>
					<div class=\"topmargin2 bottommargin1\">
						 <button id=\"submit_gsq\" type=\"submit\" class=\"bigfont $gsq_class_if_ready\" onclick=\"return confirm('Really submit GeneSeqer-MPI job?')\">Submit GSQ Job</button>
						 <button type=\"\" class=\"bigfont $gsq_class_if_not_ready\" style=\"color:#CCC\">Not Ready</button>
					</div>
				</fieldset>
			</form>
		</div>
		<br />
		<br />";
	echo "<div id=\"gth\" class=\"topmargin2\">
			<form class=\"form-horizontal\" action=\"gth_job.php\" method=\"post\">
				<input  type=\"hidden\" name=\"auth_url\" value=\"$auth_url\" />
				<input  type=\"hidden\" name=\"api_version\" value=\"$api_version\" />
				<input  type=\"hidden\" name=\"gdb\" value=\"$DBid\" />
				<input  type=\"hidden\" name=\"id\" value=\"$ID\" />
				<input  type=\"hidden\" name=\"input_data_path\" value=\"$gth_input_path\" />
				<input  type=\"hidden\" name=\"output_data_path\" value=\"$gth_output_path\" />
				<input   type=\"hidden\"  name=\"input_g\" value=\"$input_g\" />
				<input  type=\"hidden\" name=\"input_p\" value=\"$input_p\" />
				<input  type=\"hidden\" name=\"gth_split\" value=\"$gth_split\" />
				<input  type=\"hidden\" name=\"total_scaffold_count\" value=\"$total_scaffold_count\" />
                <input type=\"hidden\" name=\"valid\" value=\"$valid_post\" />

				<fieldset id=\"gth\" class=\"bottommargin1 topmargin2 xgdb_jobs\">
				<legend class=\"conf\"> &nbsp; Submit a GenomeThreader Job: <a title=\"Visit $DBid Config Page\" href=\"/XGDB/conf/view.php?id=$ID\">$DBid</a> &nbsp; <img id='jobs_genomethreader' title='More information about GenomeThreader HPC' class='help-button  nudge2' src='/XGDB/images/help-icon.png' alt='?' /></legend>
					<div class=\"bottommargin2\">
						<span class=\"largerfont\"> <b>Instructions:</b> Make sure you have selected the correct configured GDB from the dropdown above, and then follow the steps below to submit job. Monitor progress on <a href=\"/XGDB/jobs/jobs.php\">List Jobs</a> page</span>
					</div>
				<div>	
				<table id=\"gth_data\" class=\"xgdb_log featuretable bottommargin1\" border=\"0\" style=\"font-size:12px\" width=\"95%\" >
					<colgroup>
						<col width =\"50%\" />
						<col width =\"50%\" />
					</colgroup>
					<tbody>
						<tr class=\"jobs\">
						    <th  class=\"bigfont\" colspan=\"2\"; style=\"text-align:center\">
						    		<b>Genome</b>
                            </td>
						<tr>
							<td> 
								<p class= \"bold\"> <span class=\"hugefont\">1.</span> Verify that genome file(s) contents are <span class=\"filevalid\">valid</span> (click <img class=\"nudge3\" alt=\"info\" src=\"/XGDB/images/information.png\" />)</p>
							</td>
							<td valign=\"center\">
								$valid_gdna
							</td>
						</tr>
						<tr>
							<td>
							    <p class=\"bold\"><span class=\"hugefont\">2.</span> Check genome size distribution, split, and estimated job time at right, and <a title=\"open Configure page\" href=\"/XGDB/jobs/configure.php#gth_configure\">change job parameters</a> if needed.</p>
							</td>
							<td valign=\"center\">
								$scaffold_sizes_display
								$gth_split_display
								$gth_time_display
								<p class=\"italic\">Max=12 hr. To reduce job time, <a href=\"/XGDB/jobs/apps.php\">select an app with more processors (cores) as default</a>.
						    </td>
						</tr>
						<tr class=\"jobs>
						    <th class=\"bigfont\" colspan=\"2\"; style=\"text-align:center\">
						    		<b>Query Protein</b>
                            </td>
                        </tr>
						<tr>
							<td>
								<p class= \"bold\"> <span class=\"hugefont\">3.</span> Verify that query file(s) contents are <span class=\"filevalid\">valid</span> (click <img class=\"nudge3\" alt=\"info\" src=\"/XGDB/images/information.png\" />)</p>
							</td>
							<td valign=\"center\">
								$valid_prot
							</td>
						</tr>
						<tr>
							<td colspan=\"2\">
							 	<p class= \"largerfont bold\"><span class=\"hugefont\">4.</span>  Modify GenomeThreader /Job parameter defaults as desired below</p>
							 </td>
						</tr>
						<tr>
							 <td colspan=\"2\">
							 	<p class= \"largerfont bold\"><span class=\"hugefont\">5.</span>  Click 'Submit GTH Job'. Page may take awhile to refresh while data are being transferred.</p>
							</td>
						</tr>					
						</tbody>
					</table>
				<table id=\"gth_params\" class=\"xgdb_log featuretable topmargin2\" border=\"0\" style=\"font-size:12px\" width=\"95%\" >
					<colgroup>
						<col width =\"25%\" style=\"background-color: #DDD\" />
						<col width =\"25%\" />
						<col width =\"40%\" />
					</colgroup>
					<tbody>
						<tr class=\"jobs\">
							<th>
								<b>GTH Parameters</b>
							</th>
							<th>
								<b>Modify Defaults (optional)</b>
							</th>
							<th>
								<b>Comments</b>
							</th>
						</tr>

						<tr>
							<td>Species Model:</td>
							<td class=\"$edit user_entry\"  align = \"left\" class=\"bigfont\">
								 <input size=\"10\" type=\"text\" name=\"Species\" value=\"$gth_species\" class=\"\" />
							</td>
							<td>
							Choose species model appropriate for your genome
							</td>
						</tr>
						<tr class=\"jobs\">
							<th>
								<b>Job Parameters</b>
							</th>
							<th>
								<b>Modify Defaults (optional)</b>
							</th>
							<th>
								<b>Comments</b>
							</th>
						</tr>
						<tr>
							<td>App ID:</td>
							<td class=\"$edit user_entry\"  align = \"left\" class=\"bigfont\">
	        		    	 <select name=\"gth_app_id\">
	        			        $gth_apps_dropdown
	        			     </select>	
							</td>
							<td>
                                Choose appropriate app for genome size & segmentation <a href=\"/XGDB/jobs/apps.php\">(more info)</a>
							</td>
						</tr>
						<tr>
							<td>Requested Time:</td>
							<td class=\"$edit user_entry\"  align = \"left\" class=\"bigfont\">
	        		    	 <select name=\"requested_time\">
                                    <option selected=\"selected\" value=\"12:00:00\">12 h </option>
                                    <option value=\"06:00:00\">6 h </option>
                                    <option value=\"03:00:00\">3 h </option>
                                    <option value=\"01:00:00\">1 h </option>
                                    <option value=\"00:10:00\">10 m </option> 
                                    <option value=\"00:01:00\">1 m </option>
                            </select>
							</td>
							<td>
								Choose minimum time that exceeds expected process time (12 hr max)
							</td>
						</tr>
						<tr>
							<td>Admin Email <span class=\"heading\">(will be notified on completion)</span></td>
							<td class=\"$edit user_entry\"  align = \"left\" class=\"bigfont\">
								 <input size=\"20\" type=\"text\" name=\"admin_email\" id=\"gth_admin_email\" value=\"$admin_email\"  $editable />
							</td>
							<td>
								Will be notified when job starts, finishes or fails
							</td>
						</tr>
						<tr>
							<td>GTH Job Name <span class=\"heading\">(max 75 char)</span></td>
							<td class=\"$edit user_entry\"  align = \"left\" class=\"bigfont\">
								 <input size=\"50\" type=\"text\" name=\"gth_job_name\" id=\"gth_job_name\" value=\"$job_name_submit\"  $editable />
							</td>
							<td>
							    Alphanumeric characters & dashes only
							</td>
						</tr>

					</tbody>
				</table>
				</div>
					<div class=\"topmargin2 bottommargin1\">
						 <button id=\"submit_gth\"  type=\"submit\" class=\"bigfont $gth_class_if_ready\" onclick=\"return confirm('Really submit GenomeThreader job?')\">Submit GTH Job</button>
						 <button type=\"\" class=\"bigfont $gth_class_if_not_ready\" style=\"color:#CCC\">Not Ready</button>
					</div>
				</fieldset>
		  
			</form>
		</div>";
		
?>

			</div><!--end maincontentsfull-->
						  <div style="clear:both; float:right">
							<a href="http://validator.w3.org/check?uri=referer"><img
							  src="http://www.w3.org/Icons/valid-xhtml10" alt="Valid XHTML 1.0 Transitional" height="15" width="44" /></a>
						  </div>						
			</div><!--end maincontentscontainer-->
			<div id="rightcolumncontainer">
				</div><!--end rightcolumncontainer-->
			<?php include($XGDB_FOOTER); ?>
		</div></div></div>
	</body>
</html>
