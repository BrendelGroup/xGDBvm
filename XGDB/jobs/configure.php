<?php
#error_reporting(E_ALL & ~E_NOTICE); //disable undeclared variable error
session_start();
	$global_DB= 'Admin';
	$PageTitle = 'Configure Defaults';
	$pgdbmenu = 'Manage';
	$submenu1 = 'Jobs-Home';
	$submenu2 = 'ConfigJobs';
	$leftmenu='ConfigJobs';
	include('sitedef.php');
	include($XGDB_HEADER);
    $Create_Date = date("m-d-Y");
 	include_once('/xGDBvm/XGDB/phplib/db.inc.php'); #reads MySQL password from /xGDBvm/admin/dbpass
 	include_once('/xGDBvm/XGDB/jobs/jobs_functions.inc.php'); #common functions required in this script
 	include_once('/xGDBvm/XGDB/jobs/login_functions.inc.php'); #common functions required in this script
	$inputDir=$XGDB_INPUTDIR; # 1-26-16 J Duvick - sitedef.php
	$dataDir=$XGDB_DATADIR; # 1-26-16 J Duvick
	$inputDirRoot=$XGDB_INPUTDIR_ROOT; # 1-26-16 J Duvick
	
	$dbpass=dbpass();
	$db = mysql_connect("localhost", "gdbuser", $dbpass);
	if(!$db)
		{
			echo "Error: Could not connect to $test database!";
			exit;
		}

date_default_timezone_set("$TIMEZONE"); // from sitedef.php

global $token,$expires,$lifespan,$http_code,$username,$token,$login_id;
$gsq_proc_default="32";
$gsq_proc_per_node_default="16";
$gth_proc_default="16";
$gth_proc_per_node_default="16";

## Get most recent Authorization URL (if any) from database; set update/insert depending on whether prev value exists

	$auth_query="SELECT uid, auth_url, api_version, auth_update from $global_DB.admin where auth_url !='' order by uid DESC limit 0,1";
	$get_auth_record = $auth_query;
	$check_get_auth_record = mysql_query($get_auth_record);
	$auth_result = $check_get_auth_record;
	$auth=mysql_fetch_array($auth_result);
	$auth_url=$auth['auth_url'];
	$api_version=!empty($auth['api_version'])?$auth['api_version']:"v2";
	$auth_update=$auth['auth_update'];
	$auth_message=($auth_url=="")?"<span class=\"warning indent2\">no Authorization URL has been added </span>":"<span class=\"checked indent2\">Authorization URL was updated on $auth_update </span>";
	$auth_command=($auth_update=="")?"insert":"update";

## Get most recent GSQ URL (if any) from database; set update/insert depending on whether prev value exists

	$gsq_query="SELECT uid,gsq_url, gsq_software, gsq_job_time, gsq_proc, gsq_proc_per_node, gsq_update from $global_DB.admin where gsq_url !='' order by uid DESC limit 0,1";
	$get_gsq_record = $gsq_query;
	$check_get_gsq_record = mysql_query($get_gsq_record);
	$gsq_result = $check_get_gsq_record;
	$gsq=mysql_fetch_array($gsq_result);
	$gsq_app_description=$gsq['gsq_url'];
	$gsq_app_id=$gsq['gsq_software'];
	$gsq_job_time=($gsq['gsq_job_time']=="")?"12:00:00":$gsq['gsq_job_time'];
	$gsq_job_time_display=intval($gsq_job_time)." hours";
	$gsq_proc=($gsq['gsq_proc']==0)?$gsq_proc_default:$gsq['gsq_proc'];
	$gsq_proc_per_node=($gsq['gsq_proc_per_node']==0)?$gsq_proc_per_node_default:$gsq['gsq_proc_per_node'];
	$gsq_update=$gsq['gsq_update'];
	$gsq_message=($gsq_app_id=="")?"<span class=\"warning indent2\">no GSQ App ID has been added </span>":"<span class=\"checked indent2\">GSQ configuration was updated on $gsq_update </span>";
	$gsq_command=($gsq_update=="")?"insert":"update";

## Get most recent GTH URL (if any) from database; set update/insert depending on whether prev value exists

	$gth_query="SELECT uid,gth_url, gth_software, gth_job_time, gth_proc, gth_proc_per_node, gth_update from $global_DB.admin where gth_url !='' order by uid DESC limit 0,1";
	$get_gth_record = $gth_query;
	$check_get_gth_record = mysql_query($get_gth_record);
	$gth_result = $check_get_gth_record;
	$gth=mysql_fetch_array($gth_result);
	$gth_app_description=$gth['gth_url'];
	$gth_app_id=$gth['gth_software'];
	$gth_job_time=($gth['gth_job_time']=="")?"12:00:00":$gth['gth_job_time'];
	$gth_job_time_display=intval($gth_job_time)." hours";
	$gth_proc=($gth['gth_proc']==0)?$gth_proc_default:$gth['gth_proc'];
	$gth_proc_per_node=($gth['gth_proc_per_node']==0)?$gth_proc_per_node_default:$gth['gth_proc_per_node'];
	$gth_update=$gth['gth_update'];
	$gth_message=($gth_app_id=="")?"<span class=\"warning indent2\">no GTH app ID has been added </span>":"<span class=\"checked indent2\">GTH configuration was updated on $gth_update </span>";
	$gth_command=($gth_update=="")?"insert":"update";

## Conditional display of login

	$conditional_display=($auth_url!="" && ($gsq_app_id!="" || $gth_app_id!=""))?"":"display_off";

## Get dropdown(s) (conf_functions.inc.php)

//get session data for display
$username=isset($_SESSION['username'])?$_SESSION['username']:"";// username for login to authenticate
$http_code=isset($_SESSION['http_code'])?$_SESSION['http_code']:"";// username for login to authenticate
$expires=isset($_SESSION['expires'])?$_SESSION['expires']:""; //authentication token expiration
$token=isset($_SESSION['token'])?$_SESSION['token']:""; //if present, indicates user is authenticated
$dbid=isset($_SESSION['dbid'])?$_SESSION['dbid']:""; //most recent GDB configuration viewed or edited

$gdb_dev_list = gdb_external_dropdown($dbid);

//calculate token time left for display
$time_left=$expires-time();
$time_left=seconds_to_time($time_left);//login_functions.inc.php; calculates d-h-m-s from seconds
$time_left=$time_left['time'];

/*/debug
echo "http_code=$http_code; token=$token; username=$username; expires=$expires; dbid=$dbid; time left= $time_left";
//debug */

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
	$dir2="$inputDirRoot"; // 
	$df_dir2=df_available($dir2); // check if /input/ directory is fuse-mounted (returns array)
	$dir2_dropdown=($df_dir2[0]=="fuse"  || $df_dir2[0]=="irodsFs")?"$inputDir":""; //only show input dir if fuse-mounted
	$dir2_mount=($df_dir2[0]=="fuse" || $df_dir2[0]=="irodsFs")?"<span class=\"checked_mount nowrap\">DataStore mounted</span>":"<span class=\"lightgrayfont\">DataStore not mounted</span>"; //flag for dir2 mount (Data Store) top of form
	$mount_status_alert=($df_dir2[0]=="fuse" || $df_dir2[0]=="irodsFs")?"<span class=\"checked nowrap\">DataStore mounted</span>":"<span class=\"warning\">DataStore not mounted</span>"; //more intrusive flag
	$dir2_status="<span class=\"normalfont \" style=\"font-weight:normal\"><a class='help-button' title='Mount status of $inputDirRoot' id='config_input_irods'> $dir2_mount </a></span>";
}

### hide login dialog if logged in ###
$conditional_display_login=($token=="" || $http_code!='200')?"display_off":"";
$conditional_display_logout=($token!="" && $http_code=='200')?"display_off":"";
$conditional_display_url=($gsq_app_id=="" && $gth_app_id=="")?"display_off":"";
//show error message if login failed
$error_message="<p><span class=\"tip_style normalfont\"><b>Login in below</b> to obtain temporary authorization to submit jobs. Specify the <b>GDB</b> where your data is configured.</span></p>";
if($http_code=='401' && $_GET['action']=="login") // failed auth
	{
	$error_message="<p><span class=\"warning\">Login failed. Check username/password and try again</span></p>";
	}elseif($http_code=='0' && $_GET['action']=="login") // no contact
	{
	$error_message="<p><span class=\"warning\">No response from auth server. Make sure it's properly configured and active. 
	Check HPC server status here: <a title=\"Visit XSEDE User Services newsfeed\" href=\"https://www.xsede.org/news/-/news/search?_usernews_WAR_usernewsportlet_categories=80&_usernews_WAR_usernewsportlet_types=OUTAGE\">Stamped(GSQ)</a>; <a title=\"Visit XSEDE User Services newsfeed\" href=\"https://www.xsede.org/news/-/news/search?_usernews_WAR_usernewsportlet_categories=32&_usernews_WAR_usernewsportlet_keywords=&_usernews_WAR_usernewsportlet_types=OUTAGE\">Lonestar (GTH)</a>.
	</span></p>";
	}

#### Validate presence of GTH Key (required for remote GTH) ###

$validate_gth=validate_dir($KEY_SOURCE_DIR, $GENOMETHREADER_KEY, "GenomeThreader License Key", "present", "missing");
$gth_valid=$validate_gth[0]; $gth_class=$validate_gth[1];
$gth_valid_message="<span class=\"$gth_class\">GTH license ${gth_valid}:</span> ${KEY_SOURCE_DIR}${GENOMETHREADER_KEY} <img id='jobs_gth_license' title='GenomeThreader License - Help' class='help-button nudge3 smallerfont' src='/XGDB/images/help-icon.png' alt='?' />";


### Build Forms ###
$display_block = "

<div class=\"bottommargin1\">
<table width=\"100%\">
					<colgroup>
						<col width =\"35%\" />
						<col width =\"65%\" style=\"background-color: #EEE\"  />
					</colgroup>
					<tr>
					<td>
						<h1 class=\"jobs\"> <img src=\"/XGDB/images/remote_compute.png\" alt=\"\" />Configure API for High Performance Computing <img id='jobs_configure_defaults' title='How to configure HPC defaults' class='help-button nudge1 smallerfont' src='/XGDB/images/help-icon.png' alt='?' /></h1>
				        <span class=\"normalfont\" style=\"font-weight:normal\">&nbsp; $dir1_status  &nbsp; $dir2_status </span>
					</td>
					<td class=\"status_box $conditional_display_login\" style=\"padding:10px; border: 1px solid #AAA\"> 
					</td>
				</tr>
			</table>
</div>
<div class=\"featurediv bottommargin1\">
<p class=\"indent1\"><span class=\"normalfont \"> On this page you can set up <b>API configuration</b> to access a Remote Compute Resource (or these may already be configured for you). Once configured, you can <a href=\"/XGDB/jobs/login.php\">sign in</a> and run discrete Remote Compute jobs under <i>'Remote Jobs'</i> &rarr; <i>'View/Submit'</i>, or initiate an xGDBvm pipeline process under <i>'Create/Manage'</i> &rarr; <i>'Configure'</i> with the Remote Compute option.</span>
</p>
</div>
<div class=\"$conditional_display_login $conditional_display_url\">
<p> &nbsp;<b>Logged in and configured.</b> To run standalone HPC jobs or check job status, go to <a href=\"/XGDB/jobs/submit.php\">View/Submit Jobs </a>.</p>
</div>
<br />
<!-- Auth URL -->
<div id=\"userauth\" class=\"featurediv topmargin2\">
<fieldset class=\"bottommargin2 topmargin2 xgdb_log\">
	<legend class=\"conf\"> &nbsp;<b>Configure Base URL for Agave API &nbsp;</b></legend>
	
	<form method=\"post\" name=\"setup\" action=\"configure_exec.php\" >
		<input type=\"hidden\" name=\"action\" value=\"auth_url\"/>
		<input type=\"hidden\" name=\"command\" value=\"$auth_command\"/>
		
		<table style=\"font-size:12px\" class=\"bottommargin1\" width=\"100%\">
			<tr>
				<td>
					<span class=\"tip_style normalfont\"> Enter base URL and current version, then click 'Update' button at right.</span>
					(check latest versions <a title=\"open xGDBvm wiki\" href=\"http://goblinx.soic.indiana.edu/wiki/doku.php?id=agave&#current_api_settings\">here</a>)
				</td>
		</tr>
		<tr>
			<td  id=\"auth\" colspan=\"2\">
				<p> $auth_message</p>
			</td>
		</tr>
	</table>
	
	<table class=\"xgdb_log\" border=\"0\" style=\"font-size:12px\" width=\"95%\" >
		<tbody>
				<tr style=\"height: 20px\">
					<td class=\"required\" >
						<b>URL</b>
					</td>
					<td>
						<input name=\"auth_url\" size=\"50\" placeholder=\"https://agave.iplantc.org\" value=\"$auth_url\" /> 
					</td>
					<td><b>Version</b><br />
						<input name=\"api_version\" size=\"7\"  value=\"$api_version\" /> 
					</td>
					<td align=\"right\">
						<input type=\"submit\" name=\"auth_submit_button\" id=\"auth_submit_button\" value=\" &nbsp;&nbsp;Update&nbsp;&nbsp; \"/>
					</td>
				</tr>
		</tbody>
	</table>
	</form>

</fieldset>
</div>
<br />

";
	?>
	
		<div id="leftcolumncontainer">
			<div class="minicolumnleft">
			<?php include_once("/xGDBvm/XGDB/jobs/leftmenu.inc.php"); ?>
			</div>
		</div>
			<div id="maincontentscontainer" class="twocolumn admin">
				<div id="maincontentsfull">
				<?php
					echo $display_block;
				?>
				<br />
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
