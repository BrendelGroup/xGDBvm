<?php

error_reporting(E_ALL & ~E_NOTICE);

session_start();

include_once('/xGDBvm/XGDB/jobs/login_functions.inc.php'); #common functions required in this script
include_once('/xGDBvm/XGDB/phplib/db.inc.php'); #reads MySQL password from /xGDBvm/admin/dbpass
include_once('/xGDBvm/XGDB/jobs/jobs_functions.inc.php'); #common functions required in this script
include('sitedef.php');


$inputDir=$XGDB_INPUTDIR; # 1-26-15 
$dataDir=$XGDB_DATADIR; # 1-26-15 
$inputDirRoot=$XGDB_INPUTDIR_MOUNT; # 1-26-16 J Duvick - corrected 2-2-16

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

$redirect ="login"; // return here if logged out

// Check login status and redirect to logout if warranted
$logout_result = login_status($redirect, $username, $http_code, $access_token, $refresh_token, $login_id, $expires); // login.functions_inc.php; checks login/refresh status based on elapsed time and stored refresh token
$logout_redirect = $logout_result[0];
$time_left = $logout_result[1];

if($logout_redirect != "")
{
header("Location: $logout_redirect"); // logs out (resets session variables)
}
####### END Token lifespan and logout  ########

// Create a nonce for cross-script validation
$nonce = hash('sha512', mt_rand()); # as nonce;

$global_DB= 'Admin';
$PageTitle = 'User Login';
$pgdbmenu = 'Manage';
$submenu1 = 'Jobs-Home';
$submenu2 = 'ConfigJobs';
$leftmenu='UserLogin';
include($XGDB_HEADER);
$Create_Date = date("m-d-Y");
$debug_display="";#"<span class=\"heading smallerfont\">$access_token $refresh_token</span>"; # populate as needed for debugging ONLY
$dbpass=dbpass();

$db = mysql_connect("localhost", "gdbuser", $dbpass);
if(!$db)
	{
		echo "Error: Could not connect to $test database!";
		exit;
	}

$conditional_display_auth="display_off";

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
## Get most recent Authorization URL (if any) from database; set update/insert depending on whether prev value exists

	$auth_query="SELECT uid, auth_url, api_version, auth_update from $global_DB.admin where auth_url !='' order by uid DESC limit 0,1";
	$get_auth_record = $auth_query;
	$check_get_auth_record = mysql_query($get_auth_record);
	$auth_result = $check_get_auth_record;
	$auth=mysql_fetch_array($auth_result);
	$auth_url=$auth['auth_url'];  // this should be something like https://agave.iplantc.org
	$api_version=$auth['api_version'];
//TESTING COMMENT OUT FOR LIVE:
#	$auth_url="https://agave.iplantc.org";  # test
//END TESTING
	$auth_update=$auth['auth_update'];
	$auth_message=($auth_url=="")?"<span class=\"warning indent2\">no Authorization URL has been added </span>":"<span class=\"checked indent2\">Authorization URL was changed to '$auth_url' on $auth_update </span>";
	$auth_command=($auth_update=="")?"insert":"update";
    $auth_keys_message="<span class=\"tip_style\">If your username is not displayed above, enter it below and click 'Get Keys'</span>";  
#    $refresh_token="43b0a0c845dff623a62ad5d74028a";

## Conditional display of login DELETE THIS?

#	$conditional_display=($auth_url!="" && ($gsq_url!="" || $gth_url!=""))?"":"display_off";

## Get dropdown(s) (conf_functions.inc.php)


/*/debug
echo "http_code=$http_code; token=$access_token; username=$username; expires=$expires; dbid=$dbid; time left= $time_left";
//debug */

### Get list of GDB with 'Development' status for dropdown:
$gdb_dev_list = gdb_external_dropdown($dbid);

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

$gsq_query="SELECT app_id from ${global_DB}.apps WHERE program='GeneSeqer-MPI' AND is_default='Y' ";
$get_gsq = mysql_query($gsq_query);
while ($row = mysql_fetch_array($get_gsq)) {

    $gsq_default=$row["app_id"];
}
	$gsq_message=($gsq_default=="")?"<span class=\"warning indent2\">No GSQ App has been configured <a href=\"/XGDB/jobs/apps.php\">(go do it)</a> </span>":"<span class=\"checked indent2\">GSQ App ID:</span>$gsq_default";
	
$gth_query="SELECT app_id from ${global_DB}.apps WHERE program='GenomeThreader' AND is_default='Y' ";
$get_gth = mysql_query($gth_query);
while ($row = mysql_fetch_array($get_gth)) {

    $gth_default=$row["app_id"];
}
	$gth_message=($gth_default=="")?"<span class=\"warning indent2\">No GTH App has been configured <a href=\"/XGDB/jobs/apps.php\">(go do it)</a> </span>":"<span class=\"checked indent2\">GTH App ID:</span>$gth_default";


### show or hide login/logout/refresh blocks depending on token status ###
$conditional_display_logged_out=($access_token=="")?"":"display_off"; # display 'logged out' message only if user is logged out (no access token)
$conditional_display_login=($access_token=="" && $refresh_token=="")?"":"display_off"; # display 'login' option only if user is logged out (no access token) and no refresh token is present
$conditional_display_logout=($access_token!="")?"":"display_off"; # display login details and 'logout' option only if user is logged in.
$conditional_display_refresh=($refresh_token!="")?"":"display_off"; # display 'refresh' option only if refresh_token is present

### Build messages:

$http_code=isset($_SESSION['http_code'])?$_SESSION['http_code']:"";// code returned by curl
$result=isset($_GET['result'])?mysql_real_escape_string($_GET['result']):"";
$authenticate_message=($result=="Keys_Stored")?"<p><span class=\"checked\">Token refreshed</span></p>":"<p><span class=\"tip_style normalfont\"><b>Login in below</b> with your iPlant username/password to obtain temporary authorization to submit jobs.</span></p>";
$refresh_message=($result=="Token_Refreshed")?"<p><span class=\"checked\">Token refreshed</span></p>":"<p><span class=\"tip_style normalfont\">You can <b>click below</b> to refresh your temporary authorization period (even if you are logged out)</p>";


if($http_code=='401' && $_GET['action']=="authenticate") // failed auth
	{
	$authenticate_message="<p><span class=\"warning\">Login failed. Check username/password and try again</span></p>";
	$refresh_message="<p><span class=\"warning\">Refresh failed. You may need to log in again</span></p>";
	}
elseif($http_code=='0' && $_GET['action']=="authenticate") // no contact
	{
	$authenticate_message="<p><span class=\"warning\">No response from auth server. Check <a href=\"/XGDB/jobs/configure.php\">'Configure for HPC'</a> page to be sure server properly configured. 
	Check HPC server status here: <a title=\"Visit XSEDE User Services newsfeed\" href=\"https://www.xsede.org/news/-/news/search?_usernews_WAR_usernewsportlet_categories=80&_usernews_WAR_usernewsportlet_types=OUTAGE\">Stamped(GSQ)</a>; <a title=\"Visit XSEDE User Services newsfeed\" href=\"https://www.xsede.org/news/-/news/search?_usernews_WAR_usernewsportlet_categories=32&_usernews_WAR_usernewsportlet_keywords=&_usernews_WAR_usernewsportlet_types=OUTAGE\">Lonestar (GTH)</a>.
	</span></p>";
	}
elseif($http_code=='400' && $_GET['action']=="authenticate") // bad credentials
	{
	$authenticate_message="<p><span class=\"warning\"><span class=\"yellow\">Your login credentials were not accepted. Please check and try again.</span></p>";
	}
else
	{
	$authenticate_message="<p><span class=\"warning\">Login required. Enter credentials below (make sure Auth Keys are loaded).</span></p>";
	}
#### Validate presence of GTH Key (required for remote GTH) ###

$validate_gth=validate_dir($KEY_SOURCE_DIR, $GENOMETHREADER_KEY, "GenomeThreader License Key", "present", "missing");
$gth_valid=$validate_gth[0]; $gth_class=$validate_gth[1];
$gth_valid_message="<span class=\"$gth_class\">GTH license ${gth_valid}:</span> ${KEY_SOURCE_DIR}${GENOMETHREADER_KEY} <img id='jobs_gth_license' title='GenomeThreader License - Help' class='help-button nudge3 smallerfont' src='/XGDB/images/help-icon.png' alt='?' />";


### Build display blocks


$header_display_block = "

<div class=\"featurediv bottommargin2\">
<table width=\"95%\">
            <colgroup>
                <col width =\"35%\" />
                <col width =\"65%\" style=\"background-color: #EEE\"  />
                <col width =\"5%\" />
            </colgroup>
            <tr>
            <td>
                <h1 class=\"jobs\">
                   <img src=\"/XGDB/images/remote_compute.png\" alt=\"\" /> Authorize / Log In $debug_display
                </h1>
                <span class=\"normalfont\" style=\"font-weight:normal\">&nbsp; $dir1_status<br />  &nbsp;  $dir2_status </span>
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
                    <a style=\"text-decoration: none\" href=\"/XGDB/jobs/login.php#login\"> &nbsp; log in</a>
                </span>
            </td>
        </tr>
    </table>
<div class=\"feature topmargin1\">
<p class=\"indent1\"><span class=\"normalfont \">Each user is required to <b>Get Authorization Keys</b> (a one-time process) and <b>log in</b> to submit remote jobs through xGDBvm. Login tokens expire in 4 hr; click <b>'refresh'</b> to re-authenticate. To check the authorization status of this VM/app, log in to the <a target=\"_blank\" href=\"https://agave.iplantc.org/store/site/pages/applications.jag\">Agave Applications</a> page.
</p>
</div>
";


### Build Forms ###


$get_auth_keys_block="
<!-- get_auth_keys -->
<div class=\"feature\">
	<fieldset class=\"topmargin1 xgdb_log\">
		<legend class=\"conf\"> &nbsp;<b>Get Authorization Keys&nbsp;</b><img id='jobs_auth_keys' title='More information about Authorization Keys' class='help-button  nudge2' src='/XGDB/images/help-icon.png' alt='?' /></legend>

		<div id=\"auth\" class=\"featurediv indent2\">
					<form action=\"login_exec.php\" method=\"post\">				
					<input type=\"hidden\" name=\"action\" value=\"get_keys\" />
					<input type=\"hidden\" name=\"auth_url\" value=\"$auth_url\" />
					<input type=\"hidden\" name=\"api_version\" value=\"$api_version\" />
					<input type=\"hidden\" name=\"redirect\" value=\"login\" />
					
	                	   <div class=\"$conditional_display_auth\">
	                	     <p> &nbsp;<b>Keys are loaded to this VM for:</b> $user_list </p>
		                   </div>
					
		$auth_keys_message
	
				<table class=\"xgdb_log\" border=\"0\" style=\"font-size:12px\" width=\"75%\" >
					<tr>
		                <td>   
							 <label class=\"\" for=\"username\"><b>Username</b></label>
						</td>
						<td>
						   <input type=\"text\" size=\"10\" name=\"username\" id=\"username\" placeholder=\"$username\" />
						</td>
		                <td>   
							 <label class=\"\" for=\"password\"><b>Password</b></label>
						</td>
						<td>
						   <input type=\"password\" size=\"15\" name=\"password\" id=\"password\"  />
						</td>
						<td align=\"right\">
								<input type=\"submit\" name=\"login_submit_button\" id=\"login_submit_button\" value=\" &nbsp;&nbsp;Get Keys&nbsp;&nbsp; \"/><img id='jobs_auth_keys' title='Remote HPC authorization keys. Click ? for details.' class='help-button nudge1' src='/XGDB/images/help-icon.png' alt='?' /> 
						</td>

		           </tr>
				</table>
				</form>
		</div>

	</fieldset>
</div>
";

$authenticate_display_block = "

<!-- Auth Login -->
<div class=\"feature $conditional_display_login\">
	<fieldset class=\"bottommargin2 topmargin2 xgdb_log\">
		<legend class=\"conf\"> &nbsp;<b>Log in&nbsp;</b><img id='jobs_authenticate' title='More information about Authorization' class='help-button  nudge2' src='/XGDB/images/help-icon.png' alt='?' /></legend>

		<div id=\"login\" class=\"featurediv indent2\">
					<form action=\"login_exec.php\" method=\"post\">				
					<input type=\"hidden\" name=\"action\" value=\"authenticate\" />
					<input type=\"hidden\" name=\"auth_url\" value=\"$auth_url\" />
					<input type=\"hidden\" name=\"api_version\" value=\"$api_version\" />
					<input type=\"hidden\" name=\"redirect\" value=\"login\" />
		$authenticate_message
	
				<table class=\"xgdb_log\" border=\"0\" style=\"font-size:12px\" width=\"75%\" >
					<tr id=\"authenticate\" >
						<td>   
							 <label class=\"\" for=\"username\"><b>Username</b></label>
						</td>
						<td>
						   <input type=\"text\" size=\"10\" name=\"username\" id=\"username\" />
						</td>
						<td>
							<label class=\"\" for=\"inputPassword\"><b>Password</b></label>
						</td>
						<td>
						  <input type=\"password\" size=\"15\" name=\"password\" id=\"inputPassword\" />
						</td>
						<td align=\"right\">
							  <!--button type=\"submit\" class=\"btn\">Log in</button -->
								<input type=\"submit\" name=\"login_submit_button\" id=\"login_submit_button\" value=\" &nbsp;&nbsp;Sign In&nbsp;&nbsp; \"/><img id='jobs_login_token' title='Remote HPC login/token authorization. Click ? for details.' class='help-button nudge1' src='/XGDB/images/help-icon.png' alt='?' /> 
						</td>
					</tr>

				</table>
				</form>
		</div>
		<div class=\"$conditional_display_logout\">
		  <br /><p> &nbsp;<span class=\"checked\">User is authorized for GeneSeqer and GenomeThreader.</span> To run standalone HPC jobs go to <a href=\"/XGDB/jobs/submit.php\">Submit Jobs </a>. To check job status, go to <a href=\"/XGDB/jobs/jobs.php\">List Jobs </a></p>
		</div>
	</fieldset>
</div>

";
$refresh_display_block="
<!-- Token Refresh -->
<div class=\"feature bottommargin1 $conditional_display_refresh\">
<fieldset class=\"bottommargin1 topmargin1 xgdb_log\">
	<legend class=\"conf\"> &nbsp;<b>Refresh Login </b><img id='jobs_refresh_token' title='Refresh token authorization. Click ? for details.' class='help-button nudge1' src='/XGDB/images/help-icon.png' alt='?' /></legend>

	<div id=\"login\" class=\"featurediv indent2\">
				<form action=\"login_exec.php\" method=\"post\">				
				<input type=\"hidden\" name=\"action\" value=\"refresh\" />
				<input type=\"hidden\" name=\"username\" value=\"$username\" />
				<input type=\"hidden\" name=\"auth_url\" value=\"$auth_url\" />
				<input type=\"hidden\" name=\"redirect\" value=\"login\" />
	$refresh_message
	
			<table class=\"xgdb_log\" border=\"0\" style=\"font-size:12px\" width=\"50%\" >
				<tr id=\"refresh\" >
					<td align=\"center\">
						  <!--button type=\"submit\" class=\"btn\">Sign in</button -->
							<input type=\"submit\" name=\"login_submit_button\" id=\"login_submit_button\" value=\" &nbsp;&nbsp;Refresh Login Authorization&nbsp;&nbsp; \"/> 
							
					</td>
				</tr>

			</table>
			</form>
	</div>
</fieldset>
</div>
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
					echo $header_display_block;
					echo $get_auth_keys_block;
#					if($time_left>0)
#					{
					echo $auth_status_block;
#					}
					echo $authenticate_display_block;

					echo $refresh_display_block;
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
