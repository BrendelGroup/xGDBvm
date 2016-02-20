<?php
#error_reporting(E_ALL & ~E_NOTICE); //disable undeclared variable error
session_start();

####### Set POST validation variable for this browser session #######

$valid_post = hash('sha512', mt_rand()*time()); # insure POST identity
$_SESSION['valid'] = $valid_post;

####### Set defaults ####### 
    $VM=`uname -n |cut -d "." -f 1`; # identifies this VM
	$global_DB= 'Genomes'; //MySQL
	$PageTitle = 'xGDBvm Config - View All';
	$pgdbmenu = 'Manage';
	$submenu1 = 'Config-Home';
	$submenu2 = 'Config-ViewAll';
	$leftmenu='Config-ViewAll';
	include('sitedef.php');
	include($XGDB_HEADER);
	$all_check="checked=\"checked\"";
	$error_message="";
	
	$ArchiveAll_Dir=$XGDB_ARCHALLDIR; # sitedef.php
	
	global $current_check, $dev_check, $locked_check, $offline_check, $all_check;

include_once(dirname(__FILE__).'/conf_functions.inc.php');
include_once('/xGDBvm/XGDB/phplib/db.inc.php');
$dbpass=dbpass();
		$db = mysql_connect("localhost", "gdbuser", $dbpass);
	if(!$db)
	{
		echo "Error: Could not connect to database!";
		exit;
	}
	mysql_select_db("$global_DB");
	$display_if_db = ""; #style for Archive button visibility
	$display_if_nodb = ""; #style for Restore button visibility

date_default_timezone_set("$TIMEZONE");

#Parse error message if any, coming from view.php with a nonexistent ID

if(isset($_GET['error'])){	 #ID filter
		$error = htmlspecialchars($_GET['error']);
		switch ($error){
    case "norequest":
        $error_message = "<span class=\"warning largerfont\"> No valid ID was specified. Select a GDB from the list below</span>";
        break;
    case "outofrange":
        $error_message = "<span class=\"warning largerfont\"> The ID requested does not exist. Select a GDB from the list below.</span>";
        break;
	}
}
#Starting query values

$startQuery="SELECT * from xGDB_Log where 1 ";
$endQuery=" ORDER BY ID ASC";
$searchQuery="";
$statusQuery="";
$filterID="";
$showOne="display_off"; #hide special ID filter text
$showMultiple="";

if(isset($_GET['id'])){	 #ID filter
        
		$filterID = mysql_real_escape_string($_GET['id']);
		$filterQuery = " AND ID = $filterID";
		if(isset($_SESSION['gdb_field']))
		unset($_SESSION['gdb_field']);
		if(isset($_SESSION['gdb_search']))
		unset($_SESSION['gdb_search']);
		$showOne = "";
		$showMultiple = "display_off"; # hide regular text and nav

#create concatenated query from GET
$totalQuery=$startQuery.$filterQuery.$endQuery;

	}else{
	
#grab post or session values and build query string:

$post_passed=isset($_POST['passed'])?$_POST['passed']:"";
$post_search=isset($_POST['search'])?$_POST['search']:"";
$post_field=isset($_POST['field'])?$_POST['field']:"";
$post_status=isset($_POST['status'])?$_POST['status']:"";
$session_gdb_field=isset($_SESSION['gdb_field'])?$_SESSION['gdb_field']:"";
$session_gdb_status=isset($_SESSION['gdb_status'])?$_SESSION['gdb_status']:"";

	if($post_passed == 1){	 #search box
			$searchWord = mysql_real_escape_string(str_replace("*", "%", $post_search));
			$searchField = mysql_real_escape_string(str_replace("*", "%", $post_field));
			$searchQuery = ($searchField =="ID") ? " AND ID = $searchWord":" AND $searchField like '%$searchWord%' ";
			$_SESSION['gdb_field'] = $searchField;
			$_SESSION['gdb_search'] = $searchWord;
	
		}elseif(isset($_SESSION['gdb_field'])){ # session exists	
			$searchWord = $_SESSION[search];
			$searchField = $_SESSION[field];
			$searchQuery = ($searchField =="ID") ? " AND ID = $searchWord":" AND $searchField like '%$searchWord%' ";
			$searchQuery = " AND $searchField like '%$searchWord%' ";
	
		}else{ # No query - display all.
		$searchQuery = "";
	}
	if($post_passed == 2){	# status radio button
			$statusWord = mysql_real_escape_string(str_replace("all", "", $post_status));  # status=all should result in wild card query.
			$statusQuery = "AND Status LIKE '%$statusWord%' ";
			$_SESSION['gdb_status'] = $post_status;
			
	#set up radio button check based on post from status_view form:
	$current_check= (($post_status) == "Current")? "checked=\"checked\"":"";
	$dev_check= (($post_status) == "Development")? "checked=\"checked\"":"";
	$locked_check= (($post_status) == "Locked")? "checked=\"checked\"":"";
	$offline_check= (($post_status) == "Offline")? "checked=\"checked\"":"";
	$all_check= (($post_status) == "all")? "checked=\"checked\"":"";#default;
	
		}elseif(isset($_SESSION['gdb_status'])){ # session exists	
			$statusWord = $_SESSION['status'];
			$statusQuery = " AND Status LIKE '%$statusWord%' ";
	
	$current_check= (($_SESSION['status']) == "Current")? "checked=\"checked\"":"";
	$dev_check= (($_SESSION['status']) == "Development")? "checked=\"checked\"":"";
	$locked_check= (($_SESSION['status']) == "Locked")? "checked=\"checked\"":"";
	$offline_check= (($_SESSION['status']) == "Offline")? "checked=\"checked\"":"";
	$all_check= (($_SESSION['status']) == "all")? "checked=\"checked\"":"";#default;
	
		}else{ # No query - display online current (default).
		$statusQuery = "";
		$current_check="checked=\"checked\"";
	}
	
	#Concatenate POST query strings:
	
	$totalQuery=$startQuery.$searchQuery.$statusQuery.$endQuery;
}

#build result array from totalQuery and store in session
$get_records = $totalQuery;
$check_get_records = mysql_query($get_records);
$result = $check_get_records;
$_SESSION['gdb_query'] = $searchQuery;


#Only display Archive or Restore buttons when at least one GDB exists or NONE exist/Archive Directory exists, respectively, and no LOCK is in place. 

$aa_exists = archiveall_directory($ArchiveAll_Dir); // is there an Archive directory in correct place?

$GDBQuery="SELECT * from Genomes.xGDB_Log";
$lockQuery="SELECT * from Genomes.xGDB_Log where Status='Locked'";
$get_GDB=$GDBQuery;
$check_get_GDB = mysql_query($get_GDB);
$GDB_num_rows = mysql_num_rows($check_get_GDB);
$get_lock=$lockQuery;
$check_get_lock = mysql_query($get_lock);
$lock_num_rows = mysql_num_rows($check_get_lock);

	$display_if_db =  ($GDB_num_rows == 0)? 'display_off': ($lock_num_rows == 0? '':'display_off');  // show or hide "Archive All"
	$display_if_nodb = ($GDB_num_rows == 0 && $aa_exists =="Yes")? '': 'display_off'; //show or hide "Restore All"
	$display_if_nolock =  ($lock_num_rows == 0)? '':'display_off'; //buttons to display only if not locked
	$display_if_lock =  ($lock_num_rows > 0)? '':'display_off'; //elements to display only if locked
#Display Info about the Archive status.

    $archive_present = ($aa_exists =="Yes")? 'Note: An ArchiveGDB directory is present.': 'Note: No Archive is available. '; //pointing out that archive exists
    $archive_option = ($aa_exists =="Yes")? ' or restore from the ArchiveGDB directory': ''; //indicate user can restore if they wish

# submit radio button script

echo "

										<script type=\"text/javascript\">
										/* <![CDATA[ */
										
										function formSubmit(name) {
											//alert('hi got here');
											var objForm = document.forms[name]
											//alert(name);
											objForm.submit();
										}
										/* ]]> */
										</script>
";

#Text depends on whether DB created or not, and Archive status
$table_text = ($GDB_num_rows > 0)?
"
	<span class=\"heading indent2\">
		$archive_present
	</span>
	<span class=\"topmargin1 $display_if_lock indent2\">
		<br /><br /> 
		Pipeline is underway, interface <span class=\"Locked\">Locked</span>.
		<br /><br  />
		To abort process, click <b>GDB ID</b> to open its config page, click <b>Data Process Options &rarr; Abort</b>\".
	</span>
"
: 
"
	<span class=\"warning largerfont\">
		NOTE:
	</span> 
	<span class=\instruction\">
		You haven't created any genome databases yet! To start the process, click <a href=\"/XGDB/conf/new.php\">Configure New</a> $archive_option
	</span>.
";


########## flag any extraneous GDB in /data/ or /data/ and if so create $warning_text

$extra_data_msg="";
$extra_data=checkExtra("data"); //flag any extraneous GDB in data 
if(!empty($extra_data)){
	foreach($extra_data as $data_item){
		$extra_data_list.= "$data_item ";
		}
		
	$extra_data_msg= "<div class=\"warningcontainer\">
		<span class=\"warning normalfont\">
			Important Notice: The GDB directory or directories below, found under <span class=\"plaintext largerfont\">xGDBvm/data/</span>, is not associated with any <span class=\"Current\">Current</span> GDB. Please rename or delete before proceeding: 
			&rarr; <a id='config_extra_dir_data' title='Click for more info' class='help-button link'>Click for more information </a> 
		</span>
		<pre class=\"large topmargin1\">
			$extra_data_list
		</pre></div>";
	$warning_text.="$extra_data_msg";
	}

## Dropdown for selecting GDB subsets ##


$display_block = "



<table style=\"margin:20px 5px 10px 0; width: 100%;\" class=\"$showMultiple\">
			<tr>
				<td width=\"80%\" align = \"left\" class=\"normalfont\">
				<form method=\"post\" action=\"/XGDB/conf/viewall.php\" name=\"status_view\" class=\"styled\">
				<span>Filter by Status:</span>
					<input title =\"Current\" style=\"cursor:pointer\" class=\"normalfont\" type=\"radio\"  name=\"status\" value=\"Current\" $current_check onclick=\"formSubmit('status_view');\" /> <span class=\"Current\">Current</span> &nbsp;
					
					<input title =\"Development\" style=\"cursor:pointer\" class=\"normalfont\" type=\"radio\"  name=\"status\" value=\"Development\" $dev_check onclick=\"formSubmit('status_view');\" /> <span class=\"Development\">Development</span>&nbsp;
					
					<input title =\"Locked\" style=\"cursor:pointer\"  class=\"normalfont\" type=\"radio\"  name=\"status\" value=\"Locked\" $locked_check onclick=\"formSubmit('status_view');\" /> <span class=\"Locked\">Locked</span>&nbsp;
					
					<input title =\"Offline\" style=\"cursor:pointer\"  class=\"normalfont\" type=\"radio\"  name=\"status\" value=\"Offline\" $offline_check onclick=\"formSubmit('status_view');\" /> <span class=\"Offline\">Offline</span>&nbsp;
					
					<input title =\"online\" style=\"cursor:pointer\" class=\"normalfont\" type=\"radio\"  name=\"status\" value=\"all\" $all_check onclick=\"formSubmit('status_view');\" /> All &nbsp;
					<input type=\"hidden\" name=\"passed\" value=\"2\" />
					<!-- input type=\"submit\" name=\"submit\" value=\"Go\" /-->
				</form>
				</td>
				<td width=\"10%\" align = \"right\" class=\"$display_if_nolock\">
					<form method=\"post\" name=\"new_record\" action=\"/XGDB/conf/new.php\" class=\"styled\">
						<input id=\"new\" type=\"submit\" value=\"Configure New\" name=\"New\" class=\"submit\" />
					</form>
				</td>
				<td width=\"10%\" class=\"$display_if_db\" align = \"right\">
					<form method=\"post\" name=\"archive\" action=\"/XGDB/conf/archive_exec.php\" class=\"styled\">
						<input type=\"hidden\" name=\"action\" value=\"archive_all\" />
						<input type=\"hidden\" name=\"return\" value=\"viewall\" />
                        <input type=\"hidden\" name=\"valid\" value=\"$valid_post\" />
						<span class=\"nowrap\"><input id=\"archive\" class=\"submit\"  type=\"submit\" value=\"Archive All\" onclick=\"return confirm('Do you really want to archive? This will not affect current xGDB data, but may overwrite any existing archive data')\"/>
 <img id='config_archive_all' title='Search Help' class='help-button' src='/XGDB/images/help-icon.png' alt='?' /> </span>
 			</form>
				</td>
				<td width=\"10%\" class=\"$display_if_nodb\" align = \"right\">
					<form method=\"post\" name=\"restore\" action=\"/XGDB/conf/restore_exec.php\" class=\"styled\">
						<input type=\"hidden\" name=\"action\" value=\"restore_all\" />
						<input type=\"hidden\" name=\"return\" value=\"viewall\" />
                        <input type=\"hidden\" name=\"valid\" value=\"$valid_post\" />
						<span class=\"nowrap\"><input id=\"restore\" class=\"submit\" style=\"color:darkgreen\" type=\"submit\" value=\"Restore\" onclick=\"return confirm('Do you really want to restore? (This will load data from attached drive)')\"/>
 <img id='config_restore_all' title='Search Help' class='help-button' src='/XGDB/images/help-icon.png' alt='?' /> </span>
					</form>
				</td>
				<td width=\"10%\" class=\"$display_if_db\" align = \"right\">
					<form method=\"post\" name=\"drop_all\" action=\"/XGDB/conf/deleteall_exec.php\" class=\"styled\">
						<input type=\"hidden\" name=\"action\" value=\"deleteall\" />
						<input type=\"hidden\" name=\"redirect\" value=\"archive\" />
                        <input type=\"hidden\" name=\"valid\" value=\"$valid_post\" />
						<span class=\"nowrap\"><input id=\"deleteall\" class=\"submit\" type=\"submit\" style=\"color:red\" value=\"Delete All\" onclick=\"return confirm('Do you really want to delete ALL GDB, annotations, and archives? NOT REVERSIBLE')\"/>
                        <img id='config_delete_all' title='Search Help' class='help-button' src='/XGDB/images/help-icon.png' alt='?' /> </span>
					</form>
				</td>
			</tr>
	</table>
				

";

$display_block .= "<table class=\"featuretable bottommargin1 striped\" style=\"font-size:12px\" cellpadding=\"6\">
<thead align=\"center\">
				<tr class=\"reverse_1\">
					<th rowspan=\"2\">
						GDB <br /> ID <br /><br />
					<span class=\"lightgrayfont\">(Click <img src=\"/XGDB/images/configure.png\" alt=\"\" /> to view config)</span>
					</th>
					<th colspan=\"4\">Links to:<img id='config_viewall_links' title='Search Help' class='help-button' src='/XGDB/images/help-icon.png' alt='?' /></th>
					<!--th rowspan=\"2\">C<br />o<br />n<br />f<br />i<br />g</th -->
					<th rowspan=\"2\">Name<br /></th>
					<th rowspan=\"2\">Status</th>
					<th rowspan=\"2\">Organism </th>
					<th rowspan=\"2\">Type</th>
					<th class=\"smallerfont\" rowspan=\"2\" style=\"text-align:left\">&nbsp;&nbsp;Status Date: <br /><br /><img style=\"margin-bottom:-4px\" alt=\"\" src=\"/XGDB/images/configure.png\" /> &nbsp; Configured<br />
						<img style=\"margin-bottom:-4px\"  alt=\"\" src=\"/XGDB/images/create.png\" /> &nbsp; Created<br /> 
						<img style=\"margin-bottom:-4px\"  alt=\"\" src=\"/XGDB/images/update.png\" /> &nbsp; Updated<br />
					</th>
					<th colspan=\"2\" class=\"smallerfont\" >
					Archived &amp; Restored  &nbsp; <img id='config_archive_restore_column' title='Search Help' class='help-button' src='/XGDB/images/help-icon.png' alt='?' />
					</th>
					<th rowspan=\"2\"><img src=\"/XGDB/images/genomesegments.png\" alt=\"\" /> &nbsp;gDNA <br /> seg -<br /> ments </th>
					<th colspan=\"3\"># Gene Annotations / <span class=\"lightgrayfont\">Loci</span></th>
					<th colspan=\"3\"># Transcript Alignments / <span class=\"lightgrayfont\">Total</span></th>
					<th colspan=\"2\"># Protein Alignments / <span class=\"lightgrayfont\">Total</span></th>
				</tr>
				<tr class=\"reverse_1\">
					<th>Home</th>
					<th>Sample <br /> region</th>
					<th>Down  <br /> loads</th>
					<th>Log Files <br /></th>
					<th class=\"smallerfont\" >GDB</th>
					<th class=\"smallerfont\" >All</th>
					<th><img src=\"/XGDB/images/genemodels.png\" alt=\"\" /> &nbsp; GFF3
					</th>
					<th><img src=\"/XGDB/images/cpgatmodels.png\" alt=\"\" /> &nbsp; CpGAT
					</th>
					<th><img src=\"/XGDB/images/yrgatemodels.png\" alt=\"\" /> &nbsp;yrGATE</th>
					<th><img src=\"/XGDB/images/transcripts_est.png\" alt=\"\" /> &nbsp;EST</th>
					<th><img src=\"/XGDB/images/transcripts_cdna.png\" alt=\"\" /> &nbsp;cDNA</th>
					<th><img src=\"/XGDB/images/transcripts_put.png\" alt=\"\" /> &nbsp;TSA<span class=\"heading\">*</span></th>
					<th>Species</th>
					<th><img src=\"/XGDB/images/proteins.png\" alt=\"\" /> &nbsp;<br />Proteins </th>

				</tr>
		</thead>
<tbody>
";
									while ($row = mysql_fetch_assoc($result)) {
									
									
										$status_class=""; //assigned below
										$Status=$row["Status"];		
										$Status_display = ($Status=="Current") ? "Current" :(($Status=="Locked") ? "Locked" : (($Status=="Development") ? "Dev" : (($Status=="Offline") ? "Offline" : "?")));
										
										$ID=$row["ID"];
										$Organism=$row["Organism"];
										$Common_Name=$row["Common_Name"];
										$Create_Date=$row["Create_Date"];
										$Config_Date=$row["Config_Date"];
										$Update_Date=$row["Update_Date"];
										$Archive_Date=$row["Archive_Date"];
										$Restore_Date=$row["Restore_Date"];
										$Archive_All_Date=$row["Archive_All_Date"];
										$Restore_All_Date=$row["Restore_All_Date"];
										$Input_Data_Path=$row["Input_Data_Path"];
										$DBid = 'GDB'.substr(('00'. $ID),-3); #calculated from unique ID										
										$DBname = $row["DBname"];
										$homepage_link = ($Status=="Current")? "<a title=\"View $DBname home page\" href=\"/$DBid/\"><img alt=\"conf\"  src=\"/XGDB/images/home_go.png\" /></a>":"";										
										$DBid_link = "<a class=\"nowrap\" href=\"/XGDB/conf/view.php?id=$ID\"><span class=\"configure\">$DBid </span> <img alt=\"conf\" src=\"/XGDB/images/configure.png \" /> </a>";
										$output_data_link=($Status=="Current")? "<a title=\"Output data for $DBname ($DBid)\" href=\"/XGDB/phplib/download.php?GDB=$DBid&amp;dir=download\"><img alt=\"conf\" src=\"/XGDB/images/door_out.png\" /></a>":"";
										$input_data_URL = str_replace("/xGDBvm", "", $Input_Data_Path);
										$input_data_link="<a title=\"Input data path for $DBname: $Input_Data_Path\" href=\"$input_data_URL\"><img alt=\"conf\" src=\"/XGDB/images/door_in.png\" /></a>";
 										$Genome_Count=$row["Genome_Count"];
										$Genome_Type=$row["Genome_Type"];
										$CpGAT_Status=$row["CpGAT_Status"];
										$GeneModel_Link=$row["GeneModel_Link"];
        								$Prot_Align_sp=$row["Prot_Align_sp"];
        								$GSQ_CompResources=$row["GSQ_CompResources"];
        								$GTH_CompResources=$row["GTH_CompResources"];
        								$GSQ_Job_EST=$row["GSQ_Job_EST"];
										$GSQ_Job_cDNA=$row["GSQ_Job_cDNA"];
										$GSQ_Job_PUT=$row["GSQ_Job_PUT"];
										$GTH_Job=$row["GTH_Job"];
										$Default_GSEG=$row["Default_GSEG"];
										$Default_lpos=$row["Default_lpos"]?$row["Default_lpos"]:"1";
										$Default_rpos=$row["Default_rpos"]?$row["Default_rpos"]:"10000";
										$getGSEG_Region="getGSEG_Region.pl?gseg_gi=".$Default_GSEG."&amp;bac_lpos=".$Default_lpos."&amp;bac_rpos=".$Default_rpos;
										$context_view_link =  ($Status=="Current")? "<a title=\"View sample region in genome context\" href=\"/$DBid/cgi-bin/$getGSEG_Region\"><img alt=\"globe\" src=\"/XGDB/images/contextview.gif\" /></a>":"";	        								
						## Compute resources Remote flag
										$comp_res_flag =  ($Status == "Development" && ($GSQ_CompResources == "Remote" || $GTH_CompResources == "Remote"))? "<a class=\"smallerfont\" href=\"/XGDB/jobs/process.php?id=$ID\"><img src=\"/XGDB/images/remote_compute.png\" alt=\"Ext\" /></a>":"";



#										if($Status =="Current"){ #for styling table background
#												$status_class="current";									
#												}else{
#												$status_class="not_current";
#										}
									    $status_class= $Status; #assign css class to rows

						####Display modifications########
						
						
								$CpGAT_display ="";
								if ($CpGAT_Status=="Yes" && ($Status =='Locked' || $Status =='Current' )){
								$CpGAT_display ="<img src='' alt='' id='CpGAT_procedure' title='$DBid' class='logfile-button' />";
										} else {
								$CpGAT_display ="";
										}								
								
						######### display GSQ, GTH Remote Job Icon ID and link (Current or Locked GDB) ########
					
								$est_job_display=($GSQ_Job_EST !="" && $Status=="Current")?"<a href=\"/XGDB/jobs/jobs.php?id=$GSQ_Job_EST\" title=\"view job ID $GSQ_Job_EST\"><img src=\"/XGDB/images/remote_compute.png\" alt=\"R\" /></a>":"";
								$cdna_job_display=($GSQ_Job_cDNA !="" && $Status=="Current")?"<a href=\"/XGDB/jobs/jobs.php?id=$GSQ_Job_cDNA\" title=\"view job ID $GSQ_Job_cDNA\"><img src=\"/XGDB/images/remote_compute.png\" alt=\"R\" /></a>":"";
								$put_job_display=($GSQ_Job_PUT !="" && $Status=="Current")?"<a href=\"/XGDB/jobs/jobs.php?id=$GSQ_Job_PUT\" title=\"view job ID $GSQ_Job_PUT \"><img src=\"/XGDB/images/remote_compute.png\" alt=\"R\" /></a>":"";
								$prot_job_display=($GTH_Job !="" && $Status=="Current")?"<a href=\"/XGDB/jobs/jobs.php?id=$GSQ_Job\" title=\"view job ID $GTH_Job \"><img src=\"/XGDB/images/remote_compute.png\" alt=\"R\" /></a>":"";


						######## Check Progress File and format for inclusion in table (Locked or Current only) ##########
						
					#	$progress = ($Status =='Locked' || $Status =='Current')? read_pipeline_progress($DBid):"";
 					#	$progress_display= ($Status =='Locked' || $Status =='Current' )? "<div class=\"description  showhide\">
					#				<a class=\"label\" style=\"cursor:pointer\" title=\"Show pipeline progress log\"><span class=\"heading smallerfont\"> progress log</span></a>
					#				<div class=\" hidden\" style=\"display: none;\">
					#			<pre class=\"normal\">$progress</pre>
					#				</div>
					#			</div>":"";
								
					$progress_display= ($Status =='Locked' || $Status =='Current' )? "<img src='' alt='' id='/xGDBvm/data/$DBid/logs/Pipeline_procedure' title='Procedure log for $DBid (popup)' class='logfile-button' />":"";
					$progress_display.= ($Status =='Locked' || $Status =='Current' )? "<img src='' alt='' id='/xGDBvm/data/$DBid/logs/Pipeline_error' title='Error log for $DBid (popup)' class='logfile-button' />":"";
								
								
                         ######## Display Dates with image and date ##########
                         
						$Config_Date_Display = ($Config_Date!='')? '<img alt="config" src="/XGDB/images/configure.png" />'.$Config_Date :'';
						$Create_Date_Display = ($Create_Date!='')? '<br /><img alt="create	" src="/XGDB/images/create.png" />'.$Create_Date :'';
						$Update_Date_Display = ($Update_Date!='')? '<br /><img alt="update" src="/XGDB/images/update.png" />'.$Update_Date :'';
						
                         ######## Archive /Restore Dates with image and hover-over date ##########

						$Archive_Date_Display = ($Archive_Date!='')? '<br /><img alt="archive" src="/XGDB/images/archive.png" title="Archived Date:'.$Archive_Date.'" />' :'';
						$Restore_Date_Display = ($Restore_Date!='')? '<br /><img alt="restore" src="/XGDB/images/restored.png" title="Restored Date: '.$Restore_Date.'" />' :'';
 						$Archive_All_Date_Display = ($Archive_All_Date!='')? '<br /><img alt="arch_all" src="/XGDB/images/archive_all.png" title="All GDB Archived Date:'.$Archive_All_Date.'" />' :'';
						$Restore_All_Date_Display = ($Restore_All_Date!='')? '<br /><img alt="res_all" src="/XGDB/images/restored_all.png" title="All GDB Restored Date: '.$Restore_All_Date.'" />' :'';

 
						################# If DB already exists, get sequence count from EST, cDNA, GSEG, yrGATE tables########
						
						if(mysql_select_db("$DBid")){
						
						$global_DB_exists = "";
						$gseg_total="";
						$est_total="";
						$est_align_total="";
						$cdna_total="";
						$cdna_align_total="";
						$put_total="";
						$put_align_total="";
						$prot_total="";
						$prot_align_total="";
						$gene_anno_total="";
						$gene_loci_total="";
						$cpgat_gene_anno_total="n/a";
						$cpgat_gene_loci_total="n/a";
						$yrgate_total="";
						


							##### GSEG Queries #####
							
								 if($get_gseg_tot="SELECT count(*) FROM {$DBid}.gseg"){
								 $mysql_get_gseg_tot= mysql_query($get_gseg_tot); // get all GSEGs
								while($data_get_gseg_tot = mysql_fetch_array($mysql_get_gseg_tot)){
									$gseg_total=$data_get_gseg_tot[0];
									}
								}

				
							##### EST Queries #####
							
								 if($get_est_tot="SELECT count(*) FROM {$DBid}.est"){
								 $mysql_get_est_tot= mysql_query($get_est_tot); // get all EST
								while($data_get_est_tot = mysql_fetch_array($mysql_get_est_tot)){
									$est_total=$data_get_est_tot[0];
									}
								}
								 if($get_est_align= "SELECT count(*) FROM {$DBid}.gseg_est_good_pgs"){; // get aligned EST
								 $mysql_get_est_align= mysql_query($get_est_align);
								while($data_get_est_align = mysql_fetch_array($mysql_get_est_align)){
									$est_align_total=$data_get_est_align[0];
									}
								}

								
							##### cDNA Queries #####
							
								 if($get_cdna_tot="SELECT count(*) FROM {$DBid}.cdna"){
								 $mysql_get_cdna_tot= mysql_query($get_cdna_tot); // get all cdna
								while($data_get_cdna_tot = mysql_fetch_array($mysql_get_cdna_tot)){
									$cdna_total=$data_get_cdna_tot[0];
									}
								}
								 if($get_cdna_align= "SELECT count(*) FROM {$DBid}.gseg_cdna_good_pgs"){ // get aligned EST
								 $mysql_get_cdna_align= mysql_query($get_cdna_align);
								while($data_get_cdna_align = mysql_fetch_array($mysql_get_cdna_align)){
									$cdna_align_total=$data_get_cdna_align[0];
									}
								}

							##### TSA Queries #####
							
								 if($get_put_tot="SELECT count(*) FROM {$DBid}.put"){
									 $mysql_get_put_tot= mysql_query($get_put_tot); // get all put
									while($data_get_put_tot = mysql_fetch_array($mysql_get_put_tot)){
										$put_total=$data_get_put_tot[0];
									}
								}
								 if($get_put_align= "SELECT count(*) FROM {$DBid}.gseg_put_good_pgs"){ // get aligned EST
									 $mysql_get_put_align= mysql_query($get_put_align);
									while($data_get_put_align = mysql_fetch_array($mysql_get_put_align)){
										$put_align_total=$data_get_put_align[0];
									}
								}

							##### Peptide Queries. Since table names vary, get table name from user-selected database value ##########
						
								 if($mysql_get_prot= mysql_query("SELECT count(*) FROM {$DBid}.pep")){ // get species total pep
								while($data_get_prot = mysql_fetch_array($mysql_get_prot)){
									$prot_total=$data_get_prot[0];
									}
								}

								 if($mysql_get_prot_align= mysql_query("SELECT count(*) FROM {$DBid}.gseg_pep_good_pgs")){ // get species total aligned
								while($data_get_prot_align = mysql_fetch_array($mysql_get_prot_align)){
									$prot_align_total=$data_get_prot_align[0];
									}
								}
						
							##### Get Published Annotation, Locus Count ####
								
								 if($mysql_get_gene_annno= mysql_query("SELECT count(*) FROM $DBid.gseg_gene_annotation")){
								while($data_get_gene_annno = mysql_fetch_array($mysql_get_gene_annno)){
									$gene_anno_total=$data_get_gene_annno[0];
									}
								}
						
								if($mysql_get_gene_loci= mysql_query("SELECT count(distinct locus_id) FROM $DBid.gseg_gene_annotation")){
									while($data_get_gene_loci = mysql_fetch_array($mysql_get_gene_loci)){
											$gene_loci_total=$data_get_gene_loci[0];
											}
										}else{
									$gene_loci_total=$gene_anno_total;
								}

							##### Get CpGAT Annotation, Locus Count ####
								
								 if($mysql_get_cpgat_gene_annno= mysql_query("SELECT count(*) FROM $DBid.gseg_cpgat_gene_annotation")){
								while($data_get_cpgat_gene_annno = mysql_fetch_array($mysql_get_cpgat_gene_annno)){
									$cpgat_gene_anno_total=$data_get_cpgat_gene_annno[0];
									}
								}
						
								if($mysql_get_cpgat_gene_loci= mysql_query("SELECT count(distinct locus_id) FROM $DBid.gseg_cpgat_gene_annotation")){
									while($data_get_cpgat_gene_loci = mysql_fetch_array($mysql_get_cpgat_gene_loci)){
											$cpgat_gene_loci_total=$data_get_cpgat_gene_loci[0];
											}
										}else{
									$cpgat_gene_loci_total=$cpgat_gene_anno_total;
								}
								
								
							##### Get yrGATE  Count ####
								
								$mysql_get_yrgate= mysql_query("SELECT count(*) FROM $DBid.user_gene_annotation WHERE Status='ACCEPTED' and Organism='$Organism' "); // get current yrgate count for this organism and version
								while($data_get_yrgate = mysql_fetch_array($mysql_get_yrgate)){
									$yrgate_total=$data_get_yrgate[0];
								}
						
							
						}else{
						$global_DB_exists = "NOTE: MySQL DB does not exist";
						$gseg_total="";
						$est_total="";
						$est_align_total="";
						$cdna_total="";
						$cdna_align_total="";
						$put_total="";
						$put_align_total="";
						$prot_total="";
						$prot_align_total="";
						$gene_anno_total="";
						$gene_loci_total="";
						$cpgat_gene_anno_total="";
						$cpgat_gene_loci_total="";
						$yrgate_total="";
						}											
											
										
$display_block .= "						




										 <tr align=\"right\" class=\"$status_class\">
										 		<td align=\"center\"  style=\"color:#F4746E; font-weight: bold\" >
										 			$DBid_link
												</td>
												<td align=\"center\">
												$homepage_link
												</td>
												<td align=\"center\">
													$context_view_link
												</td>
												<td align=\"center\">
													$output_data_link
													$comp_res_flag
												</td>
												<td  align=\"center\">
												$progress_display $CpGAT_display
												</td>
												<td align=\"center\">
													$DBname
												</td>
												<td align=\"center\">
													$Status_display
												</td>	

												<td class=\"italic\">
													$Organism
												</td>
												<td>
													$Genome_Type
												</td>
												<td align=\"left\" class=\"italic smallerfont nowrap\">
													$Config_Date_Display
													$Create_Date_Display
													$Update_Date_Display
												</td>
												<td class=\"italic smallerfont nowrap\">
													$Archive_Date_Display
													$Restore_Date_Display
												</td>
												<td>
													$Archive_All_Date_Display													
													$Restore_All_Date_Display													
												</td>
	
												<td align=\"center\">
													$gseg_total
												</td>
												<td>
													{$gene_anno_total} <br/> <span class=\"darkgrayfont\">${gene_loci_total}</span>
												</td>
												<td>
													{$cpgat_gene_anno_total} <br/> <span class=\"darkgrayfont\">${cpgat_gene_loci_total}</span>
												</td>
												<td align=\"center\">
													{$yrgate_total}
												</td>

												<td>
													{$est_align_total} <br/> <span class=\"darkgrayfont\">{$est_total}</span><br />$est_job_display
												</td>
												<td>
													{$cdna_align_total} <br/> <span class=\"darkgrayfont\">{$cdna_total}</span><br />$cdna_job_display
												</td>
												<td>
													{$put_align_total} <br/> <span class=\"darkgrayfont\">{$put_total}</span><br />$put_job_display
												</td>
												<td class=\"italic smallerfont\">
													{$Prot_Align_sp}
												</td>
												<td>
													{$prot_align_total} <br/> <span class=\"darkgrayfont\">{$prot_total}</span><br />$prot_job_display
												</td>	
											</tr>";
}

$display_block .= "</tbody></table>";
$display_block .= "<span class=\"heading\">*TSA = Transcript Sequence Assembly</span>"

?>

	<div id="leftcolumncontainer">
		<div class="minicolumnleft">
			<?php include_once("/xGDBvm/XGDB/conf/leftmenu.inc.php"); ?>
		</div>
	</div>
	<div id="maincontentscontainer" class="twocolumn overflow configure">
			<div id="maincontentsfull" class="configure">
			<h1 class="configure bottommargin1"><img alt="" src="/XGDB/images/configure.png" /> List All Configured<span class="<?php echo $showOne; ?>">: <?php echo $DBid; ?> </span> <span class="bigfont <?php echo $showOne; ?>">(<a href="/XGDB/conf/viewall.php">View All GDB</a>)</span> <img id='config_viewall' title='Here you view or manage configured GDB. Click ? for details.' class='help-button nudge1' src='/XGDB/images/help-icon.png' alt='?' /> <?php echo $error_message ?></h1>



<table class="topmargin1" width="100%" border="0">
	<tr valign="top">
		<td width="60%" class="normalfont">
			<?php echo "$table_text"; echo "$warning_text"; ?> 
		</td>
</tr>
<tr>
		<td width="40%" align="left" valign="bottom">
			<span class="instruction normalfont">Click GDB ID to view configuration.</span>
		</td>
		<td width="40%" align="right" valign="bottom">

		<form method="post" action="/XGDB/conf/viewall.php" class="styled  <?php echo $showMultiple; ?>">
				<span class="normalfont">Filter:
				  <select name="field">
					<option value="DBname">Database Name</option>
					<option value="ID">GDB #</option>
					<option value="Organism">Organism</option>
				  </select> 
				  on  </span>
				<input type="text" name="search" size="15" />
				<input type="hidden" name="passed" value="1" />
				<input  id="search" class="submit" type="submit" name="submit" value="Search" />
		 <?php
		if (($_SESSION['gdb_field'])){
			echo "Search on: $searchField = <span style=\"color:red\">$searchWord</span> | <a href=\"/XGDB/conf/viewall_exec.php?clear=true&amp;name=viewall\">Clear Search Results</a>";
		} else {
			echo "";
		}
		?>
		</form>
		
		</td>
	</tr>
</table>


<?php 

#	echo "Current: $current_check; Dev: $dev_check; Offine: $locked_check; All: $all_check <span class=\"heading smallerfont\">Total Query: ".$totalQuery." <br /> Search Query: ".$searchQuery." <br /> Status Query:".$statusQuery."</span>";

	echo $display_block;
?>

	 					 </div>
					</div><!--end maincontentsfull-->
						  <div style="clear:both; float:right">
							<a href="http://validator.w3.org/check?uri=referer"><img
							  src="http://www.w3.org/Icons/valid-xhtml10" alt="Valid XHTML 1.0 Transitional" height="15" width="44" /></a>
						  </div>						
				</div><!--end maincontentscontainer-->
				<?php include($XGDB_FOOTER); ?>
			</div><!--end innercontainer-->
		</div><!--end outercontainer-->
	</body>
</html>
