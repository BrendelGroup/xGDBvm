<?php
#error_reporting(E_ALL & ~E_NOTICE); //disable undeclared variable error
session_start();

#### Defaults
$global_DB1= 'Genomes';
$global_DB2= 'Admin';
$PageTitle = 'xGDBvm Remote Jobs';
$pgdbmenu = 'Manage';
$submenu1 = 'Jobs-Instructions';
$submenu2 = 'Jobs-Instructions';
$leftmenu='Jobs-Instructions';
include('sitedef.php');
include($XGDB_HEADER);
include_once('/xGDBvm/XGDB/phplib/db.inc.php');
include_once('/xGDBvm/XGDB/jobs/login_functions.inc.php');
include_once('/xGDBvm/XGDB/jobs/jobs_functions.inc.php'); #common functions required in this script
$inputDir=$XGDB_INPUTDIR; # 1-26-15 
$dataDir=$XGDB_DATADIR; # 1-26-15 
$inputDirRoot=$XGDB_INPUTDIR_ROOT; # 1-26-16 J Duvick

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
$dir2="$inputDirRoot/"; //
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


# Load usernames already authorized (if any)

$handle = fopen("/xGDBvm/admin/auth", "r");
if ($handle) {
$user_list="<span class=\"normalfont\">";
    while (($line = fgets($handle)) !== false) {
    $pattern="/^(\S+?):([A-Za-z0-9\_]+?):([A-Za-z0-9\_]+?)$/"; # e.g. newuser:hZ_z3f4Hf3CcgvGoMix0aksN4BOD6:UH758djfDF8sdmsi004wER
    if(preg_match($pattern, $line, $matches)){
       $username=$matches[1];
       $key=$matches[2];
       $secret=$matches[3];
       $user_list.="<span id=\"$username\" class=\"checked\">$username </span>";
       }
    }
$user_list.="</span>";
$conditional_display_auth="";
} else {
$user_list="No users";
} 
fclose($handle);

## Set messages
$keys_message=($auth_url=="")
?
"<span class=\"alertnotice warning\"> No auth login configured</span>"
:
"<span class=\"checked\">Auth login configured</span>";


$auth_message=($auth_url=="")
?
"<span class=\"alertnotice warning\"> No auth login configured</span>"
:
"<span class=\"checked\">Auth login configured</span>";
$gsq_message=($gsq_software=="")
?
"<span class=\"alertnotice warning\"> No GSQ software configured</span>"
:
"<span class=\"checked\">$gsq_software</span>";
$gth_message=($gth_software=="")
?
"<span class=\"alertnotice warning\"> No GTH software configured</span>"
:
"<span class=\"checked\">$gth_software </span>"; 

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
                                <h1 class=\"jobs\"> <img alt=\"\" src=\"/XGDB/images/remote_compute.png\" /> Stepwise Instructions</h1>
                                <span class=\"normalfont\" style=\"font-weight:normal\">&nbsp; $dir1_status  &nbsp; $dir2_status </span>
                            </td>
                            <td class=\"$conditional_login smallerfont\" style=\"padding:10px; border: 1px solid #AAA\"> 
                                <span class=\"checked smallerfont\">\"$username\" </span>is authorized at $auth_url
                                (token expires in <span class=\"alertnotice\">$time_left</span>)
                                <span class=\"smallerfont\"><a title=\"log out of this authorization session\" href=\"/XGDB/jobs/logout.php?id=$ID&amp;msg=logout&amp;redirect=index\">(logout)</a></span>
                            </td>
                        </tr>
                    </table>
                </div>";


?>
						<div class="feature">
		                    <p>See also <a href="/XGDB/help/remote_jobs.php">Help Pages</a> </p>
							<?php include_once("/xGDBvm/XGDB/help/includes/jobs_overview.inc.php"); ?>
						</div><!-- end feature-->
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