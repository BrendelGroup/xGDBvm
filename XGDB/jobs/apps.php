<?php
error_reporting(E_ALL & ~E_NOTICE);
session_start();

####### Set POST validation variable for this browser session #######
$valid_post = mt_rand();
$_SESSION['valid'] = $valid_post;


	$global_DB1= 'Admin';
	$PageTitle = 'Configure Apps';
	$pgdbmenu = 'Manage';
	$submenu1 = 'Jobs-Home';
	$submenu2 = 'ConfigApps';
	$leftmenu='ConfigApps';
	include('sitedef.php');
    $Create_Date = date("m-d-Y");
 	include_once('/xGDBvm/XGDB/phplib/db.inc.php'); #reads MySQL password from /xGDBvm/admin/dbpass
 	include_once('/xGDBvm/XGDB/jobs/jobs_functions.inc.php'); #common functions required in this script

	$all_check="checked";
	include('sitedef.php');
	include($XGDB_HEADER);
 	include_once('/xGDBvm/XGDB/phplib/db.inc.php'); #reads MySQL password from /xGDBvm/admin/dbpass
	$dbpass=dbpass();
	$db = mysql_connect("localhost", "gdbuser", $dbpass);
	if(!$db)
	{
		echo "Error: Could not connect to database!";
		exit;
	}
	mysql_select_db("$global_DB1");

### Set default display by assigning css class to show/hide respective td elements
	$add_app_class = 'display_off';
	$edit_app_class = 'display_off'; //default - don't show edit data features when page loads
	$view = 'display_on_block'; //defaults - do show view data features when page loads
	$cancel = 'display_off'; // default - don't show cancel button when page loads
	$viewedit = '';
	$group_dropdown="";
	$selected_group="";
	

### Modify display based on post values: the following variables set a td css class corresponding to either display:block or display:hidden

$post_mode=isset($_POST['mode'])?$_POST['mode']:"";

if($post_mode == 'Cancel' || $post_mode == 'View'  ){ // Enter View mode (Default).

	$edit_app_class = 'display_off';
	$add_app_class = 'display_off';
	$view = 'display_on_block';
	$cancel = 'display_off';
	$viewedit = '';

	}
$post_mode=isset($_POST['mode'])?$_POST['mode']:"";

if($post_mode == 'AddApp'){ // Enter new group mode.
	$add_app_class = '';
	$edit_app_class = 'display_off';
	$view = 'display_off';
	$cancel = 'display_on';
	$viewedit = 'display_off';
	}


$apps_list=list_apps(); //jobs_functions.inc.php; lists exising apps as reference

$display_block ="
<h2 class=\"$add_app_class  bottommargin1\">
    Add New App
</h2>
<table style=\"font-size:12px\" width=\"100%\">
<tbody>
	<tr>
		<td align=\"left\" valign=\"bottom\">
			<form method=\"post\" action=\"/XGDB/jobs/apps.php\" name=\"add_app_on\" class=\"styled\">
				<input id=\"creategrp\" class=\"submit $view\" type=\"submit\" name=\"add_new_app\" value=\"Add New App...\" />
				<input type=\"hidden\" name=\"mode\" value=\"AddApp\" />
			</form>
		</td>
		<td width=\"20%\" align = \"right\">
			<form method=\"post\" action=\"/XGDB/jobs/apps.php\" name=\"view_status_on\" class=\"styled\">
				<input id=\"cancel\" class=\"$cancel submit\" type=\"submit\" value=\"&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Cancel&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;\" />
				<input type=\"hidden\" name=\"mode\" value=\"Cancel\" />
			</form>
		</td>
	</tr>
	</tbody>
</table>

";

#Action Button Display and Table Headers
$display_block .= "


<table class=\"featuretable bottommargin1 topmargin1\" style=\"font-size:12px\" cellpadding=\"6\">
		<thead align=\"center\">
						<tr class=\"$viewedit\">
							<th class=\"reverse_1\">App ID</th>
							<th class=\"reverse_1\">Program</th>
							<th class=\"reverse_1\">Vers</th>
							<th class=\"reverse_1\">Platform</th>
							<th class=\"reverse_1\">Nodes</th>
							<th class=\"reverse_1\">Proc Per Node</th>
							<th class=\"reverse_1\">Cores</th>
							<th class=\"reverse_1\">Date Added</th>
							<th class=\"reverse_1\">Description</th>
							<th class=\"reverse_1\">Developer</th>
							<th class=\"reverse_1\">Max (h) </th>
							<th class=\"reverse_1\">Make Default</th>
							<th class=\"reverse_1\">Remove From List</th>
						</tr>
		
		</thead>
		<tbody>
";
		
		
		## Default Query

$query="SELECT * from ${global_DB1}.apps ORDER BY program, nodes  ASC ";
$get_records = mysql_query($query);
#Count table rows
$count=mysql_num_rows($get_records);

$i=1; //cycle through all records
while ($row = mysql_fetch_array($get_records)) {

    $uid=$row["uid"];
    $app_id=$row["app_id"];
    $program=$row["program"];
    $version=$row["version"];
    $platform=$row["platform"];
    $nodes=$row["nodes"];
    $proc_per_node=$row["proc_per_node"];
    $cores=$nodes*$proc_per_node; 
    $date_added=$row["date_added"];
    $description=$row["description"];
    $developer=$row["developer"];
    $is_default=$row["is_default"];
    $is_default_display=($is_default=="Y")?"(default)":"";
    $max_job_time=$row["max_job_time"];

### Mode Button Display

$remove_app = ($is_default !="Y")?
"<form method=\"post\" action=\"/XGDB/jobs/apps_exec.php\" name=\"remove_app\">
<input type=\"hidden\" name=\"action\" value=\"remove\" />
<input type=\"hidden\" name=\"valid\" value=\"$valid_post\" />
<input type=\"hidden\" name=\"uid\" value=\"$uid\" />
<input type=\"hidden\" name=\"uid\" value=\"$uid\" />
<input type=\"hidden\" name=\"app_id\" value=\"$app_id\" />
<input type=\"hidden\" name=\"return\" value=\"apps\" />
<input title=\"Remove `$app_id` from the list of $program apps\" id=\"delete_record_button\" style=\"color:red\" type=\"submit\" value=\" X \" name=\"delete_record\" onclick=\"return confirm('Remove `$app_id` from the $program list? (will not affect the actual app)')\" />
</form>
"
:
"";
$make_default = ($is_default !="Y")? 
"<form method=\"post\" action=\"/XGDB/jobs/apps_exec.php\" name=\"make_default\">
<input type=\"hidden\" name=\"action\" value=\"default\" />
<input type=\"hidden\" name=\"valid\" value=\"$valid_post\" />
<input type=\"hidden\" name=\"program\" value=\"$program\" />
<input type=\"hidden\" name=\"uid\" value=\"$uid\" />
<input type=\"hidden\" name=\"app_id\" value=\"$app_id\" />
<input type=\"hidden\" name=\"return\" value=\"apps\" />
<input title=\"Make `$app_id` the default app for this program\" id=\"default_button\" style=\"color:green\" type=\"submit\" value=\"D\" name=\"default\" onclick=\"return confirm('Make `$app_id` the default app for $program? ')\" />
</form>
"
:
"";

$default_class=($is_default =="Y")? "highlight":"";

######### ''Edit User Accounts' data fields ########

 			$display_block .=
 				"<tr id=\"$uid\" align=\"right\" class=\"$viewedit $default_class\">
					<td align=\"left\" >
						<span class=\"nowrap\">$app_id</span>
					</td>
					<td align=\"center\" class=\"bold\">
						$program
					</td>
					<td align=\"left\">
						$version

					<td align=\"left\">
						$platform						
					</td>
					<td align=\"center\">
						$nodes
					</td>		
					<td align=\"center\">
						$proc_per_node
					</td>		
					<td align=\"center\" class=\"bold\">
						$cores
					</td>		
					<td align=\"center\">
						$date_added
					</td>		
					<td align=\"center\">
						$description
					</td>		
					<td align=\"center\">
						$developer
					</td>		
					<td align=\"center\">
						$max_job_time
					</td>		
					<td align=\"center\">
						$is_default_display
                        $make_default
                    </td>
                    <td align = \"center\" style=\"width:250px\">
                    $remove_app
                    </td>
			</tr>";
$i=$i+1;

}


########## 'Add New App' data fields ########

## get max uid ##
$query="SELECT MAX(uid) as max_uid from ${global_DB1}.apps ";
$get_records = mysql_query($query);
$row = mysql_fetch_array($get_records);
$max_uid=$row['max_uid'];

$display_block .=
"

<tr class=\"$add_app_class\">
<td>
<form method=\"post\" action=\"/XGDB/jobs/apps_exec.php\" class=\"styled\">

<ul class=\"nobullet  indent1\">
            <li>
                 <label class=\"required\" for=\"App ID\">App ID: </label>
                    <input class=\"form_class1\" style=\"text-align:left\" type=\"text\" name=\"app_id\" size=\"30\"  />
            </li>
            <li>
                <label for=\"program\">Program Name: </label>
               <select class=\"form_class1\" name=\"program\">
                    <option value=\"GeneSeqer-MPI\">GeneSeqer-MPI</option>
                    <option value=\"GenomeThreader\">GenomeThreader</option>
                </select>
            </li>
                <label for=\"version\">Program Version: </label>
                    <input class=\"form_class1\"  style=\"text-align:left\" type=\"text\" name=\"version\" size=\"2\" />
            <li>
                <label for=\"platform\">HPC Platform: </label>
               <select class=\"form_class1\" name=\"platform\">
                    <option value=\"Stampede\">Stampede</option>
                    <option value=\"Lonestar\">Lonestar</option>
                </select>
            </li>
            <li>
                 <label for=\"nodes\">Nodes Used: </label>
                    <input class=\"form_class1\"  style=\"text-align:left\" type=\"text\" name=\"nodes\" size=\"4\" />
            </li>
            <li>
                 <label for=\"proc_per_node\">Processors Per Node: </label>
                    <input class=\"form_class1\"  style=\"text-align:left\" type=\"text\" name=\"proc_per_node\" size=\"4\"  />
            </li>
            <li>
                 <label for=\"description\">Description: </label>
                    <input class=\"form_class1\"  style=\"text-align:left\" type=\"text\" name=\"description\" size=\"35\" />
            </li>
            <li>
                 <label for=\"developer\">Developer: </label>
                    <input class=\"form_class1\"  style=\"text-align:left\" type=\"text\" name=\"developer\" size=\"12\"  />
            </li>
            <li>
                 <label for=\"max_job_time\">Max Job Time (h): </label>
                <select class=\"form_class1\" name=\"max_job_time\">
                    <option selected =\"selected\" value=\"12:00:00\">12</option>
                    <option value=\"06:00:00\">6</option>
                    <option value=\"04:00:00\">4</option>
                    <option value=\"01:00:00\">1</option>
                </select>
            </li>
            <li>
                 <label for=\"is_default\">Default?: </label>
                <select class=\"form_class1\" name=\"is_default\">
                    <option selected =\"selected\" value=\"No\">No</option>
                    <option value=\"Y\">Yes</option>
                    <option value=\"N\">No</option>
                </select>
            </li>
        </ul>
    <input type=\"submit\" id=\"insert_app\"  style=\"background-color:lightgreen\" class=\"$add_app_class submit\" name=\"insert\" value=\"&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Insert&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; \">
    <input type=\"hidden\" id=\"insert_action\" name=\"action\" value=\"insert\">
    <input type=\"hidden\" id=\"insert_max_uid\" name=\"max_uid\" value=\"$max_uid\">
    <input type=\"hidden\" id=\"insert_valid\" name=\"valid\" value=\"$valid_post\">
    </form>
    </td>
</tr>
<tr class=\"$add_app_class\">
	<td><span class=\"normalfont bold\">Current Apps:</span><br /><br />
		<ul class=\"nobullet indent1 bottommargin1\">
			$apps_list
		</ul>
	</td>
</tr>
";
//| uid | app_id| program   | version | platform | nodes | proc_per_node | date_added          | description | developer | is_default | max_job_time |

$display_block .= "
		</tbody>
	</table>

";

?>
	<div id="leftcolumncontainer">
		<div class="minicolumnleft">
			<?php include_once("/xGDBvm/XGDB/jobs/leftmenu.inc.php"); ?>
		</div>
	</div>
	<div id="maincontentscontainer" class="twocolumn overflow configure">
			<div id="maincontentsfull" class="configure">
			
			<h1 class="admin bottommargin1"><img src="/XGDB/images/user.png" alt="" /> Configure HPC Apps <img id='jobs_configure_apps' title='Search Help' class='help-button' src='/XGDB/images/help-icon.png' alt='?' /> </h1>
            <p>Apps in this list appear in a dropdown menu for <a href="/XGDB/jobs/submit.php">standalone job</a> submission, allowing you to select the appropriate number of cores for your genome (see <a href="/XGDB/jobs/resources.php">Resources</a>). Default app (<span class="highlight"> highlighted </span>) is used when a <a href="/XGDB/jobs/submit_pipeline.php">pipeline job</a> is run (to change default, click 'D'). </p>
            
            <p>You can check the latest App versions for xGDBvm <a title="open xGDBvm wiki" href="http://goblinx.soic.indiana.edu/wiki/doku.php?id=hpc&amp;#current_app_ids">here</a></p>

<?php 
	echo $display_block;
?>

	  </div>
					</div><!--end maincontentsfull-->
				</div><!--end maincontentscontainer-->
				<?php include($XGDB_FOOTER); ?>
			</div><!--end innercontainer-->
		</div><!--end outercontainer-->
	</body>
</html>
