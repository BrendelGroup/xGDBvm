<?php
### creates GUI elements and forms that allow user to query job status or kill a job.
#error_reporting(E_ALL & ~E_NOTICE); //disable undeclared variable error
session_start();
include('sitedef.php');
date_default_timezone_set("$TIMEZONE"); // from sitedef.php

####### Set POST validation variable for this browser session #######

$valid_post = mt_rand();
$_SESSION['valid'] = $valid_post;
include_once('/xGDBvm/XGDB/jobs/login_functions.inc.php'); #common functions required in this script

// Get session data that persists from the last login.
$username=isset($_SESSION['username'])?$_SESSION['username']:"";// username for login to authenticate
$http_code=isset($_SESSION['http_code'])?$_SESSION['http_code']:"";// code returned by curl
$expires=isset($_SESSION['expires'])?$_SESSION['expires']:""; //Authorization token expiration
$access_token=isset($_SESSION['access_token'])?$_SESSION['access_token']:""; //if present, indicates user is authenticated
$refresh_token=isset($_SESSION['refresh_token'])?$_SESSION['refresh_token']:""; //if present, indicates user is capable of refreshing even if access_token has expired.
$username=isset($_SESSION['username'])?$_SESSION['username']:"";// username for login to authenticate
$dbid=isset($_SESSION['dbid'])?$_SESSION['dbid']:""; //most recent GDB configuration viewed or edited (NOT NEEDED HERE?)
$login_id=isset($_SESSION['login_id'])?$_SESSION['login_id']:""; // (set by login_exec.php); this is the GDB that was originally used for login (if any), go to the logout script, and return here.

$redirect ="manage"; // return here if logged out

// Check login status and redirect to logout if warranted
$logout_result = login_status($redirect, $username, $http_code, $access_token, $refresh_token, $login_id, $expires); // login.functions_inc.php; checks login/refresh status based on elapsed time and stored refresh token
$logout_redirect = $logout_result[0];
$time_left = $logout_result[1];

if($logout_redirect != "")
{
header("Location: $logout_redirect"); // logs out (resets session variables)
}

// Set globals and includes
$global_DB= 'Admin';
$PageTitle = 'Manage Jobs';
$pgdbmenu = 'Manage';
$submenu1 = 'Jobs-Home';
$submenu2 = 'ManageJobs';
$leftmenu='ManageJobs';
global $username,$token,$expires,$lifespan,$http_code,$login_id;
include('sitedef.php');
include($XGDB_HEADER);
$Create_Date = date("m-d-Y");
include_once('/xGDBvm/XGDB/phplib/db.inc.php'); #reads MySQL password from /xGDBvm/admin/dbpass
include_once('/xGDBvm/XGDB/jobs/jobs_functions.inc.php'); #common functions required in this script

$inputDir=$XGDB_INPUTDIR; # 1-26-15 
$dataDir=$XGDB_DATADIR; # 1-26-15 
$inputDirRoot=$XGDB_INPUTDIR_ROOT; # 1-26-16 J Duvick


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

## Get most recent Authorization URL from Admin database;

	$auth_query="SELECT uid, auth_url, auth_update from $global_DB.admin where auth_url !='' order by uid DESC limit 0,1";
	$get_auth_record = $auth_query;
	$check_get_auth_record = mysql_query($get_auth_record);
	$auth_result = $check_get_auth_record;
	$auth=mysql_fetch_array($auth_result);
	$auth_url=$auth['auth_url'];
	$auth_update=$auth['auth_update'];
	$auth_message=($auth_url=="")?"<span class=\"warning indent2\">No authorization URL has been configured <a href=\"/XGDB/jobs/configure.php\">(go do it)</a> </span>":"<span class=\"checked indent2\">Auth URL $auth_url is current</span>";

## Get GTH GSQ app info

$gsq_query="SELECT app_id from ${global_DB}.apps WHERE program='GeneSeqer-MPI' AND is_default='Y' ";
$get_gsq = mysql_query($gsq_query);
while ($row = mysql_fetch_array($get_gsq)) {

    $gsq_default=$row["app_id"];
}
$gth_query="SELECT app_id from ${global_DB}.apps WHERE program='GenomeThreader' AND is_default='Y' ";
$get_gth = mysql_query($gth_query);
while ($row = mysql_fetch_array($get_gth)) {

    $gth_default=$row["app_id"];
}

$gsq_message=($gsq_default=="")?"<span class=\"warning indent2\">No GSQ App has been configured <a href=\"/XGDB/jobs/apps.php\">(go do it)</a> </span>":"<span class=\"checked indent2\">GSQ App ID:</span>$gsq_default";

$gth_message=($gth_default=="")?"<span class=\"warning indent2\">No GTH App has been configured <a href=\"/XGDB/jobs/apps.php\">(go do it)</a> </span>":"<span class=\"checked indent2\">GTH App ID: </span>$gth_default";


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

/*/debug: 
		$usersession=$_SESSION['username'];
		$userpost=$_POST['username'];
		$tokensession=$_SESSION['token'];
		$http_code_session=$_SESSION['http_code'];
		$posted_action=$_POST['action']; //now posted to login.php; should be blank.
#		$expires-session=$_SESSION['expires'];
		$remaining=$expires-time();
		$time=time();
		$timeU=date("U");
		$sessionID=$_SESSION['id'];
		$isset_token=isset($_SESSION['token']);
		$msg=$_GET['msg'];
		echo "ID=$sessionID; token=$token; isset-token=$isset_token; msg=$msg; login-msg=$login_msg; http_code=$http_code_session; userpost=$userpost; username=$username; auth_url=$auth_url; user-session=$usersession; user-post=$userpost; token= $token; token-session=$tokensession; posted_action=$action; now=$now; remaining=$remaining; expires-session=$expires; lifespan-session =$lifespan; issued-session=$issued; timeU=$timeU; ";
// end debug */

// Get data assoc. with this ID and reconstruct GDBnnn

##  Create dropdown using the current DBid (if any) as the "selected" option 
if(isset($ID))
{
    $DBid="00".$ID;
    $DBid = "GDB".substr($DBid, -3, 3);
}
else
{
$DBid="";
}

$jobs_dropdown_status=jobs_dropdown($username, "status"); # 
$jobs_dropdown_output=jobs_dropdown($username, "output"); # 
$jobs_dropdown_terminate=jobs_dropdown($username, "terminate"); # 


### show or hide login/logout/refresh blocks depending on token status ###
$conditional_display_logged_out=($access_token=="")?"":"display_off"; # display 'logged out' message only if user is logged out (no access token)
$conditional_display_login=($access_token=="" && $refresh_token=="")?"":"display_off"; # display 'login' option only if user is logged out (no access token) and no refresh token is present
$conditional_display_logout=($access_token!="")?"":"display_off"; # display login details and 'logout' option only if user is logged in.
$conditional_display_refresh=($refresh_token!="")?"":"display_off"; # display 'refresh' option only if refresh_token is present

echo
		'<div id="leftcolumncontainer">
			<div class="minicolumnleft">';
			
include_once("/xGDBvm/XGDB/jobs/leftmenu.inc.php");
			
echo"	</div>
		</div>
			<div id=\"maincontentscontainer\" class=\"twocolumn admin\">
				<div id=\"maincontentsfull\">";

echo "<div class=\"featurediv bottommargin2\"> 
        <table width=\"95%\">
            <colgroup>
                <col width =\"30%\" />
                <col width =\"65%\" style=\"background-color: #EEE\"  />
                <col width =\"5%\"/>
            </colgroup>
            <tr>
            <td>
                <h1 class=\"jobs\"> <img src=\"/XGDB/images/remote_compute.png\" alt=\"\" /> Manage Jobs:</h1>
                <span class=\"normalfont\" style=\"font-weight:normal\">&nbsp; $dir1_status <br /> &nbsp; $dir2_status </span>
            </td>
            <td style=\"padding:10px; border: 1px solid #DDD\"> <span class=\"status_box $conditional_display_logout\"> 
                <span class=\"checked smallerfont\">\"$username\" </span> is authorized to submit jobs  
                (token expires in <span class=\"alertnotice\">$time_left</span>)
                <br />
                <span class=\"smallerfont\">$gsq_message</span><br />
                <span class=\"smallerfont\">$gth_message</span><br />
                <span class=\"smallerfont\">$gth_valid_message</span>
                </span>
                <span class=\"$conditional_display_logged_out normalfont indent2\"><span class=\"warning\">You are not currently authenticated for remote computing on this VM.</span></span>
            </td>
            <td style=\"padding:10px; border: 1px solid #DDD\">
                <span class=\"smallerfont $conditional_display_refresh\">
                    <form action=\"/XGDB/jobs/login_exec.php\" method=\"post\">
                        <input type=\"hidden\" name=\"action\" value=\"refresh\" />
                        <input type=\"hidden\" name=\"redirect\" value=\"manage\" />
                        <input type=\"submit\" name=\"refresh\" value=\" refresh\">
                    </form>
                    
                </span>
                <span class=\"smallerfont $conditional_display_logout\">
                    <form action=\"/XGDB/jobs/logout_exec.php\" method=\"post\">
                        <input type=\"hidden\" name=\"msg\" value=\"logout\" />
                        <input type=\"hidden\" name=\"redirect\" value=\"manage\" />
                        <input type=\"submit\" name=\"logout\" value=\" log out\">
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
         <p><span class=\"largerfont \">Here you can check <a href=\"#status\">job status</a> or <a href=\"#kill\">terminate</a> a job. Or, visit <a target=\"_blank\" href=\" http://agaveapi.co/live-docs/#\">The Agave API </a> for comprehensive job management tools. </span>
    <br />
    </div>
    ";

		
echo "	<div id=\"status\" class=\"topmargin2\">
            <form class=\"form-horizontal\" action=\"display_status.php\" method=\"post\">
            <input  type=\"hidden\" name=\"return\" value=\"manage\" />
            <input type=\"hidden\" name=\"valid\" value=\"$valid_post\" />
            <fieldset class=\"bottommargin1 topmargin1 xgdb_log\">
            <legend class=\"conf\"> &nbsp; Check Status of a Job:</legend>
                <div class=\"bottommargin1\"><p><span class=\"instructions \"> Select a job ID and click 'Check Status'. </span></p>
                </div>
            <table class=\"xgdb_log $status_font_display\" border=\"0\" style=\"font-size:12px\" width=\"95%\" >
                <colgroup>
                    <col width =\"25%\" style=\"background-color: #DDD\" />
                    <col width =\"75%\" />
                </colgroup>
                <tbody>
                    <tr>
                        <td>Job ID:</td>
                        <td class=\"$edit user_entry\"  align = \"left\" class=\"bigfont\">
                            <select name=\"job_id\" required> 
                                $jobs_dropdown_status
                            </select>
                        </td>
                    </tr>
                </tbody>
            </table>
                <div class=\"topmargin1 bottommargin1\">
                    <button type=\"submit\" class=\"bigfont\">Check Status</button>
                </div>
            </fieldset>
        </form>
    </div>";
    
echo "<div id=\"output\">
        <form class=\"form-horizontal\" action=\"display_logfiles.php\" method=\"post\">
            <input  type=\"hidden\" name=\"return\" value=\"manage\" />
            <input type=\"hidden\" name=\"valid\" value=\"$valid_post\" />
            <fieldset id=\"stop\" class=\"bottommargin1 topmargin1 xgdb_log\">
            <legend class=\"conf\"> &nbsp; View Job Outputs:</legend>
                <div class=\"bottommargin1\"><p><span class=\"instructions \"> Click 'View Job Outputs' to view ~.out and ~.err files for a job in progress or completed.</p>
                </div>
            <table class=\"xgdb_log $status_font_display\" border=\"0\" style=\"font-size:12px\" width=\"95%\" >
                <colgroup>
                    <col width =\"25%\" style=\"background-color: #DDD\" />
                    <col width =\"75%\" />
                </colgroup>
                <tbody>
                    <tr>
                        <td>Job ID:</td>
                        <td class=\"$edit user_entry\"  align = \"left\" class=\"bigfont\">
                            <select name=\"job_id\" required> 
                                $jobs_dropdown_output
                            </select>
                        </td>
                    </tr>
                </tbody>
            </table>
                <div class=\"topmargin1 bottommargin1\">
                    <button type=\"submit\" class=\"bigfont\">View Job Outputs</button>
                </div>
            </fieldset>
    </form>
    </div>
    ";

echo "<div id=\"stop\">
        <form class=\"form-horizontal\" action=\"stop-or-delete_exec.php\" method=\"post\">
            <input  type=\"hidden\" name=\"return\" value=\"manage\" />
            <input type=\"hidden\" name=\"valid\" value=\"$valid_post\" />
            <input type=\"hidden\" name=\"action\" value=\"stop\" />
            <fieldset id=\"stop\" class=\"bottommargin1 topmargin1 xgdb_log\">
            <legend class=\"conf\"> &nbsp; Terminate a Job:</legend>
                <div class=\"bottommargin1\"><p><span class=\"instructions \"> Select a submitted, still-running job ID and click 'Terminate Job'. This sends a 'kill' command to the remote HPC and is not reversible.</p>
                </div>
            <table class=\"xgdb_log $status_font_display\" border=\"0\" style=\"font-size:12px\" width=\"95%\" >
                <colgroup>
                    <col width =\"25%\" style=\"background-color: #DDD\" />
                    <col width =\"75%\" />
                </colgroup>
                <tbody>
                    <tr>
                        <td>Job ID:</td>
                        <td class=\"$edit user_entry\"  align = \"left\" class=\"bigfont\">
                            <select name=\"job_id\" required> 
                                $jobs_dropdown_terminate
                            </select>
                        </td>
                    </tr>
                </tbody>
            </table>
                <div class=\"topmargin1 bottommargin1\">
                    <button type=\"submit\" class=\"bigfont\">Terminate Job</button>
                </div>
            </fieldset>
    </form>
    </div>
    ";
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
