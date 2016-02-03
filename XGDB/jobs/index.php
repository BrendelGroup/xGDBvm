<?php
#error_reporting(E_ALL & ~E_NOTICE); //disable undeclared variable error
session_start();

#### Defaults
$global_DB1= 'Genomes';
$global_DB2= 'Admin';
$PageTitle = 'xGDBvm Remote Jobs';
$pgdbmenu = 'Manage';
$submenu1 = 'Jobs-Home';
$submenu2 = 'Jobs-Home';
$leftmenu='Jobs-Home';
include('sitedef.php');
include_once('/xGDBvm/XGDB/phplib/db.inc.php');
include_once('/xGDBvm/XGDB/jobs/login_functions.inc.php');
include_once('/xGDBvm/XGDB/jobs/jobs_functions.inc.php'); #common functions required in this script
$inputDir=$XGDB_INPUTDIR; # 1-26-15 
$dataDir=$XGDB_DATADIR; # 1-26-15
$inputDirRoot=$XGDB_INPUTDIR_MOUNT; # 1-26-16 J Duvick  - corrected 2-2-16

$dbpass=dbpass();
    $db = mysql_connect("localhost", "gdbuser", $dbpass);
if(!$db)
{
    echo "Error: Could not connect to database!";
    exit;
}
    mysql_select_db("$global_DB1");

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

$redirect ="index"; // return here if logged out

// Check login status and redirect to logout if warranted
$logout_result = login_status($redirect, $username, $http_code, $access_token, $refresh_token, $login_id, $expires); // login.functions_inc.php; checks login/refresh status based on elapsed time and stored refresh token
$logout_redirect = $logout_result[0];
$time_left = $logout_result[1];

if($logout_redirect != "")
{
header("Location: $logout_redirect"); // logs out (resets session variables)
}

include($XGDB_HEADER); //relocated here

### show or hide login/logout/refresh blocks depending on token status ###
$conditional_display_logged_out=($access_token=="")?"":"display_off"; # display 'logged out' message only if user is logged out (no access token)
$conditional_display_login=($access_token=="" && $refresh_token=="")?"":"display_off"; # display 'login' option only if user is logged out (no access token) and no refresh token is present
$conditional_display_logout=($access_token!="")?"":"display_off"; # display login details and 'logout' option only if user is logged in.
$conditional_display_refresh=($refresh_token!="")?"":"display_off"; # display 'refresh' option only if refresh_token is present

# Generate database list for select statement.
$dbid_query = "SELECT ID, DBname FROM $global_DB1.xGDB_Log where status='Development' order by ID ASC";
$rows = mysql_query($dbid_query);
$db_list="";
while($row = mysql_fetch_array($rows))
    {
    $DBname=$row['DBname'];
    $ID=$row['ID'];
    $ID_padded="00".$ID;
    $ID_padded=substr($ID_padded, -3, 3);
    $GDB="GDB".$ID_padded;
    $db_list .= "<option value=\"$ID\">".$GDB.": ".$DBname.": ".$ID."</option>";

}
# Default for dropdown:
$default_query = "SELECT ID, DBname FROM $global_DB1.xGDB_Log where status='Development' order by ID ASC limit 1";
$default_row = mysql_query($default_query);
while($default = mysql_fetch_array($default_row))
    {
    $DBname_default=$default['DBname'];
    $ID_default=$default['ID'];
    $ID_default_padded="00".$ID_default;
    $ID_default_padded=substr($ID_default_padded, -3, 3);
    $GDB_default="GDB".$ID_default_padded;
    $defaultDB = "<option value=\"$ID_default\">".$GDB_default.": ".$DBname_default.": ".$ID_default."</option>";
}
$DBdropdown = "
    <td width=\"100%\">
    <form method=\"post\" name=\"search_dbid\" action=\"/XGDB/conf/view.php\">
            <input type=\"submit\" class=\"largerfont\" value=\"View Configuration:&nbsp; &nbsp;\" name=\"View\" />
            <select name=\"id\" class=\"largerfont\">
            $defaultDB
            $db_list
            </select>
             - Select an existing configuration
    </form>
    </td>
";

$conditional_gdb=!isset($_SESSION['gdbid'])?"display_off":""; // hide this feature if no id has been edited already
$conditional_login=!isset($_SESSION['access_token'])?"display_off":""; // hide this feature if user not logged in



## Query database for jobs config status

$auth_query="SELECT uid, auth_url from $global_DB2.admin where auth_url !='' order by uid DESC limit 0,1";
$get_auth_record = $auth_query;
$check_get_auth_record = mysql_query($get_auth_record);
$auth_result = $check_get_auth_record;
$auth=mysql_fetch_array($auth_result);
$auth_url=$auth['auth_url'];

$gsq_query="SELECT app_id from ${global_DB2}.apps WHERE program='GeneSeqer-MPI' AND is_default='Y' ";
$get_gsq = mysql_query($gsq_query);
while ($row = mysql_fetch_array($get_gsq)) {

    $gsq_default=$row["app_id"];
}
$gth_query="SELECT app_id from ${global_DB2}.apps WHERE program='GenomeThreader' AND is_default='Y' ";
$get_gth = mysql_query($gth_query);
while ($row = mysql_fetch_array($get_gth)) {

    $gth_default=$row["app_id"];
}

$gsq_remote_query="SELECT count(*) as remote from $global_DB1.xGDB_Log where Status='Development' AND GSQ_CompResources !='Local'; ";
$get_gsq_remote = $gsq_remote_query;
$check_get_gsq_remote = mysql_query($get_gsq_remote);
$gsq_remote_result = $check_get_gsq_remote;
$gsq_remote=mysql_fetch_array($gsq_remote_result);
$gsq_remote_count=$gsq_remote['remote'];

$gth_remote_query="SELECT count(*) as remote from $global_DB1.xGDB_Log where Status='Development' AND GTH_CompResources !='Local'; ";
$get_gth_remote = $gth_remote_query;
$check_get_gth_remote = mysql_query($get_gth_remote);
$gth_remote_result = $check_get_gth_remote;
$gth_remote=mysql_fetch_array($gth_remote_result);
$gth_remote_count=$gth_remote['remote'];

$pend_query="SELECT count(*) as pending from $global_DB2.jobs where (status='pending' OR status='submitting' OR status='staging_job' OR status='queued' OR status='running') ; ";
$get_pend_record = $pend_query;
$check_get_pend_record = mysql_query($get_pend_record);
$pend_result = $check_get_pend_record;
$pend=mysql_fetch_array($pend_result);
$pending=$pend['pending'];

$success_query="SELECT count(*) as completed from $global_DB2.jobs where status='archiving_finished'; ";
$get_success_record = $success_query;
$check_get_success_record = mysql_query($get_success_record);
$success_result = $check_get_success_record;
$success=mysql_fetch_array($success_result);
$completed=$success['completed'];

$fail_query="SELECT count(*) as failed from $global_DB2.jobs where (status='failed' OR status='stopped' OR status='empty' OR status='timeout' ); ";
$get_fail_record = $fail_query;
$check_get_fail_record = mysql_query($get_fail_record);
$fail_result = $check_get_fail_record;
$fail=mysql_fetch_array($fail_result);
$failed=$fail['failed'];


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
$dir2_status="";
if (file_exists("/xGDBvm/admin/iplant")) { // xGDBvm-iPlant only
$dir2="$inputDirRoot"; // TODO: move to sitedef.php
$df_dir2=df_available($dir2); // check if /input/ directory is fuse-mounted (returns array)
$dir2_dropdown=($df_dir2[0]=="fuse"  || $df_dir2[0]=="irodsFs")?"/xGDBvm/input/":""; //only show input dir if fuse-mounted
$dir2_mount=($df_dir2[0]=="fuse" || $df_dir2[0]=="irodsFs")?"<span class=\"checked_mount nowrap\">DataStore mounted</span>":"<span class=\"lightgrayfont\">DataStore not mounted</span>"; //flag for dir2 mount (Data Store) top of form
$mount_status_alert=($df_dir2[0]=="fuse" || $df_dir2[0]=="irodsFs")?"<span class=\"checked nowrap\">DataStore mounted</span>":"<span class=\"warning\">DataStore not mounted</span>"; //more intrusive flag
$dir2_status="<span class=\"normalfont \" style=\"font-weight:normal\"><a class='help-button' title='Mount status of $inputDirRoot' id='config_input_irods'> $dir2_mount </a></span>";
}
# display mount status

#### Validate presence of GTH Key (required for remote GTH) ###

$validate_gth=validate_dir($KEY_SOURCE_DIR, $GENOMETHREADER_KEY, "GenomeThreader License Key", "present", "missing");
$gth_valid=$validate_gth[0]; $gth_class=$validate_gth[1];
$gth_valid_message="<span class=\"$gth_class\">GTH license ${gth_valid}</span>";


# Load usernames already authorized (if any)  TODO: Put this section in login_functions.inc.php

$handle = fopen("/xGDBvm/admin/auth", "r");
if ($handle) 
{
	$user_list="<span class=\"normalfont\">";
	$i=0;
    while (($line = fgets($handle)) !== false) 
    {
    	$pattern="/^(\S+?):([A-Za-z0-9\_]+?):([A-Za-z0-9\_]+?)$/"; # e.g. newuser:hZ_z3f4Hf3CcgvGoMix0aksN4BOD6:UH758djfDF8sdmsi004wER
    	if(preg_match($pattern, $line, $matches))
    	{
       		$username=$matches[1];
       		$key=$matches[2];
       		$secret=$matches[3];
       		$user_list.="<span id=\"$username\" class=\"checked\">$username </span>";
       		$i++;
       }
    }
if($i==0)
	{
	$user_list="<span class=\"normalfont\">NONE";
	}
$user_list.="</span>";
$conditional_display_auth="";

fclose($handle);
} else {
$user_list="<span class=\"alertnotice warning\"> ERROR: could not read auth file</span>";
$conditional_display_auth="";
}

## Set messages
$keys_message=($auth_url=="")
?
"<span class=\"alertnotice warning\"> No auth login configured</span>"
:
"<span class=\"checked\">Auth login configured</span>";


$auth_message=($auth_url=="")
?
"<span class=\"alertnotice warning\"> No API path configured</span>"
:
"<span class=\"checked\">API path configured</span>";
$gsq_message=($gsq_default=="")
?
"<span class=\"alertnotice warning\"> No GSQ software configured</span>"
:
"<span class=\"checked\">$gsq_default</span>";
$gth_message=($gth_default=="")
?
"<span class=\"alertnotice warning\"> No GTH software configured</span>"
:
"<span class=\"checked\">$gth_default </span>"; 

$gsq_remote_message=($gsq_remote_count=="0")
?
"<span class=\"alertnotice warning\"> No GDB configured (GSQ)</span>"
:
"<span class=\"checked\">$gsq_remote_count GDB configured (GSQ)</span>";	

$gth_remote_message=($gth_remote_count=="0")
?
"<span class=\"alertnotice warning\"> No GDB configured (GTH)</span>"
:
"<span class=\"checked\">$gth_remote_count GDB configured (GTH)</span>";

$pending_message=($pending=="0")
?
""
:
(
    ($pending=="1")?"<span class=\"in_progress\">1 job in progress</span>"
    :
    "<span class=\"in_progress\">$pending jobs in progress</span>"
)
;	

$completed_message=($completed=="0")
?
""
:
(
    ($completed=="1")?"<span class=\"checked\">1 job completed</span>"
    :
    "<span class=\"checked\">$completed jobs completed</span>"
)
;	

$failed_message=($failed=="0")
?
""
:
(
    ($completed=="1")?"<span class=\"alert_notice warning bold\">1 job failed, stopped, or empty</span>"
    :
    "<span class=\"alert_notice warning bold\">$failed jobs failed, stopped, or empty</span>"
)
;	

?>


			<div id="leftcolumncontainer">
				<div class="minicolumnleft">
					<?php include_once("/xGDBvm/XGDB/jobs/leftmenu.inc.php"); ?>
				</div>
			</div>
			<div id="maincontentscontainer" class="twocolumn overflow configure">
				<div id="maincontents">	
<?php

				echo "
				<div class=\"bottommargin1\"> 
					<table width=\"100%\">
                            <colgroup>
                                <col width =\"35%\" />
                                <col width =\"65%\" style=\"background-color: #EEE\"  />
                            </colgroup>	
                            <tr>
                            <td>
                                <h1 class=\"jobs\"> <img alt=\"\" src=\"/XGDB/images/remote_compute.png\" /> Remote Jobs: $logout_redirect <i>Getting Started</i></h1>
                                <span class=\"normalfont\" style=\"font-weight:normal\">&nbsp; $dir1_status  &nbsp; $dir2_status </span>
                            </td>
							<td style=\"padding:10px; border: 1px solid #DDD\">
								<span class=\"status_box $conditional_display_logout\"> 
									<span class=\"checked smallerfont\">\"$username\" </span>
									<span class=\"smallerfont\">is authorized to run remote jobs (token expires in <span class=\"alertnotice\">$time_left</span>)<br />
									<span class=\"smallerfont\">$gsq_message</span><br />
									<span class=\"smallerfont\">$gth_message</span><br />
									<span class=\"smallerfont\">$gth_valid_message</span>
									</span>
								</span>
								<span class=\"$conditional_display_logged_out normalfont indent2\">
									<span class=\"warning\">You are not currently authenticated for remote computing on this VM.</span>
								</span>
							</td>
							<td style=\"padding:10px; border: 1px solid #DDD\">
								<span class=\"smallerfont $conditional_display_refresh\">
									<form action=\"/XGDB/jobs/login_exec.php\" method=\"post\">
										<input type=\"hidden\" name=\"action\" value=\"refresh\" />
										<input type=\"hidden\" name=\"redirect\" value=\"login\" />
										<input title=\"Click to refresh your login credentials\"  type=\"submit\" name=\"refresh\" value=\" refresh\">
									</form>
					
								</span>
				
								<span class=\"smallerfont $conditional_display_logout nowrap\">
									<form action=\"/XGDB/jobs/logout_exec.php\" method=\"post\">
										<input type=\"hidden\" name=\"msg\" value=\"logout\" />
										<input type=\"hidden\" name=\"redirect\" value=\"login\" />
										<input type=\"submit\" name=\"logout\" value=\" log out\">
									</form>
								</span>
								<span  class=\"$conditional_display_login normalfont nowrap\">
									<a style=\"text-decoration: none\" href=\"/XGDB/jobs/login.php#index\"> &nbsp; log in</a>
								</span>
							</td>
                        </tr>
                    </table>
                </div>";


?>

		        <p>xGDBvm can send spliced-alignment input data to a <b>High Performance Compute</b> cluster for accelerated processing, either as a <b>standalone</b> job or as part of a <b>GDB pipeline process</b>. iPlant login credentials and VM-mounted DataStore are required.  Use the links below to configure, prepare and run HPC jobs. </p>
		        <hr />
						<div class="feature" id="instructions">

				<h2 class="topmargin1 bottommargin1">START HERE:</h2>	

								<table style="padding:20px 0 20px 40px">
									<tr>
										<td>
											<p><a title="Step-by-Step Instructions to Create GDB" href="/XGDB/jobs/instructions.php" class="xgdb_button colorJobs2 largerfont">Stepwise Instructions</a></p>
										</td>
										<td>
											<p></p>
										</td>
									</tr>
								</table>
						</div><!-- end feature-->

						<div class="feature" id="configure">
							<h2 class="bottommargin1">CONFIGURE</h2>
								<table style="padding:20px 0 20px 40px">
									<tr>
										<td>
											<span class="nowrap"><a title="configure API" href="/XGDB/jobs/configure.php?redirect=configure" class="xgdb_button colorJobs2 largerfont">Configure API</a> <img id='jobs_configure_defaults' title='How to configure HPC API' class='help-button nudge3 smallerfont' src='/XGDB/images/help-icon.png' alt='?' /></span>
										</td>
										<td>
											<p>Configure or update the API defaults   (check latest versions <a title="open xGDBvm wiki" href="http://goblinx.soic.indiana.edu/wiki/doku.php?id=agave&#current_api_settings">here</a>)
											<br /><b>Status: </b><?php echo $auth_message; echo '&nbsp';?></p>
										</td>
									</tr>
								</table>
								<table style="padding:20px 0 20px 40px">
									<tr>
										<td>
											<span class="nowrap"><a title="configure new GDB" href="/XGDB/jobs/apps.php" class="xgdb_button colorJobs2 largerfont">Configure Apps</a> <img id='jobs_configure_apps' title='How to configure HPC Apps' class='help-button nudge3 smallerfont' src='/XGDB/images/help-icon.png' alt='?' /></span>
										</td>
										<td>
											<p>Configure or update HPC Apps (check latest versions <a title="open xGDBvm wiki" href="http://goblinx.soic.indiana.edu/wiki/doku.php?id=hpc&amp;#current_app_ids">here</a>)
											<br /><b>Status: </b><?php echo $gsq_message;  echo '&nbsp;'; echo $gth_message; echo '&nbsp;'; ?></p>
										</td>
									</tr>
								</table>
								<table style="padding:20px 0 20px 40px">
									<tr>
										<td>
											<a title="configure new GDB" href="/XGDB/jobs/login.php" class="xgdb_button colorJobs2 largerfont">Authorize / Log In</a> <img id='jobs_auth_keys' title='How to set up OAuth keys and register VM' class='help-button nudge3 smallerfont' src='/XGDB/images/help-icon.png' alt='?' />
										</td>
										<td>
											<p> Register this VM and log in.<br />
											<b>Keys loaded for:</b> <?php echo $user_list; ?></p>

										</td>
									</tr>
								</table>
						</div><!-- end feature-->

						<div class="feature" id="submit">
							<h2 class="bottommargin1">RUN JOBS</h2>
								<table style="padding:20px 0 20px 40px">
									<tr>
										<td>
											<a title="configure new GDB" href="/XGDB/jobs/resources.php?redirect=resources" class="xgdb_button colorJobs2 largerfont">Estimate Resources</a>
										</td>
										<td>
											<p>Determine what HPC resources and parameters will be needed to process your data
										</td>
									</tr>
								</table>
								<table style="padding:20px 0 20px 40px">
									<tr>
										<td>
											<a title="configure new GDB" href="/XGDB/jobs/submit.php" class="xgdb_button colorJobs2 largerfont">Submit Standalone Job</a>
										</td>
										<td>
											<p>Submit a Standalone <b>GeneSeqer</b> or <b>GenomeThreader</b> job (DataStore must be mounted) <br /><b>Status: </b><?php echo $mount_status_alert; echo $gth_valid_message;  ?> </p>

										</td>
									</tr>
								</table>
								<table style="padding:20px 0 20px 40px">
									<tr>
										<td>
											<a title="configure new GDB" href="/XGDB/jobs/submit_pipeline.php" class="xgdb_button colorJobs2 largerfont">Submit Pipeline Job</a>
										</td>
										<td>
											<p>Configure GDB pipeline to send <b>GeneSeqer</b> or <b>GenomeThreader</b> jobs to remote HPC</p>

										</td>
									</tr>
								</table>
						</div><!-- end feature-->

						<div class="feature" id="manage">
							<h2 class="bottommargin1">MANAGE JOBS</h2>
								<table style="padding:20px 0 20px 40px">
									<tr>
										<td>
											<a title="manage configured" href="/XGDB/jobs/jobs.php" class="xgdb_button colorJobs2 largerfont">List All Jobs</a>
										</td>
										<td>
											<p>List jobs with running time, status, and error reports; terminate/delete jobs, and evaluate/copy output.
											<br /><b>Status: </b><?php echo $pending_message; echo '&nbsp;'; echo $completed_message; echo '&nbsp;'; echo $failed_message; ?></p>
										</td>
									</tr>
								</table>
								<table style="padding:20px 0 20px 40px">
									<tr>
										<td>
											<a title="manage configured" href="/XGDB/jobs/manage.php" class="xgdb_button colorJobs2 largerfont">Manage Jobs</a>
										</td>
										<td>
											<p>Check job status, view log files or terminate jobs for a single job</p>
										</td>
									</tr>
								</table>
								<table style="padding:20px 0 20px 40px" class="<?php echo $conditional_gdb; ?>">
									<tr>
										<td>
											<a title="edit most recently accessed GDB" href="/XGDB/conf/view.php?id=<?php echo $_SESSION['id']; ?>" class="xgdb_button colorConf4 largerfont"><span style="color:yellow"><?php echo $_SESSION['gdbid']; ?></span>  Config</a>
										</td>
										<td>
											<p> View / Edit the most recently configured GDB  <span class="heading">(required for remote job submission)</span></p> 
										</td>
									</tr>
								</table>
							
								<table style="padding:20px 0 0 40px">
									<tr>
											<?php echo $DBdropdown; ?>
									</tr>
								</table>
						</div><!-- end feature links-->
					</div><!--end maincontentsfull-->
				  <div style="clear:both; float:right">
							<a href="http://validator.w3.org/check?uri=referer"><img
							  src="http://www.w3.org/Icons/valid-xhtml10" alt="Valid XHTML 1.0 Transitional" height="15" width="44" /></a>
				  </div>						
				</div><!--end maincontentscontainer-->
				</div><!--pagewidth-->

				<?php include($XGDB_FOOTER); ?>
			</div><!--end innercontainer-->
		</div><!--end outercontainer-->
	</body>
</html>