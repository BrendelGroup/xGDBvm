<?php
#error_reporting(E_ALL & ~E_NOTICE); //disable undeclared variable error
session_start();

####### Set POST validation variable for this browser session #######

$valid_post = mt_rand();
$_SESSION['valid'] = $valid_post;

####### Set defaults #######

    $VM=`uname -n |cut -d "." -f 1`; # identifies this VM
	$global_DB= 'Genomes'; //MySQL
	$PageTitle = 'xGDBvm - Archive';
	$pgdbmenu = 'Manage';
	$submenu1 = 'Config-Home';
	$submenu2 = 'Config-Archive';
	$leftmenu='Config-Archive';
	include('sitedef.php');
	include($XGDB_HEADER);
	$all_check="checked";
	$inputDir=$XGDB_INPUTDIR; # 1-26-16
	$dataDir=$XGDB_DATADIR; # 1-26-16 
	$inputdir=$XGDB_INPUTDIR; # 1-28-16 top level of symlinked DataStore mount, e.g. /xGDBvm/input/. 
	$ArchiveAll_Dir=$XGDB_ARCHALLDIR;
	
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
	$error = isset($_GET['error'])?$_GET['error']:"";
	
	$display_if_db = ""; #style for Archive button visibility
	$display_if_nodb = ""; #style for Restore button visibility
	
#Starting query values

$startQuery="SELECT * from xGDB_Log where 1 ";
$endQuery=" ORDER BY ID ASC";
$searchQuery="";
$statusQuery="";
$filterID="";

		
	#Concatenate POST query strings:
	
	$totalQuery=$startQuery.$searchQuery.$statusQuery.$endQuery;


#build result array from totalQuery and store in session
$get_records = $totalQuery;
$check_get_records = mysql_query($get_records);
$result = $check_get_records;
$_SESSION['gdb_query'] = $searchQuery;


#Only display Archive or Restore buttons when at least one GDB exists or NONE exist/Archive Directory exists, respectively, and no LOCK is in place. 

$aa_exists = archiveall_directory($ArchiveAll_Dir); // is there an Archive directory in correct place?

$GDBQuery="SELECT * FROM Genomes.xGDB_Log";
$lockQuery="SELECT * FROM Genomes.xGDB_Log WHERE Status='Locked'";
$archiveallQuery="SELECT * FROM Genomes.xGDB_Log WHERE Archive_All_Date!=''";
$maxIDQuery="SELECT MAX(ID) as max_id FROM Genomes.xGDB_Log";

$get_GDB=$GDBQuery;
$check_get_GDB = mysql_query($get_GDB);
$GDB_num_rows = mysql_num_rows($check_get_GDB);
$get_lock=$lockQuery;
$check_get_lock = mysql_query($get_lock);
$lock_num_rows = mysql_num_rows($check_get_lock);
$get_archivall=$archiveallQuery;
$check_get_archiveall = mysql_query($get_archivall);
$archiveall_num_rows = mysql_num_rows($check_get_archiveall);
$get_maxIDQuery=$maxIDQuery;
$check_get_maxIDQuery=mysql_query($maxIDQuery);
$maxIDQuery_result=mysql_fetch_array($check_get_maxIDQuery);
$maxID=$maxIDQuery_result['max_id'];

	$display_if_db =  ($GDB_num_rows == 0)? 'display_off': ($lock_num_rows == 0? '':'display_off');  // show or hide "Archive All"
	$display_if_nodb = ($GDB_num_rows == 0 && $aa_exists =="Yes")? '': 'display_off'; //show or hide "Restore All"
	$display_if_nolock =  ($lock_num_rows == 0)? '':'display_off'; //buttons to display only if not locked
	$display_if_lock =  ($lock_num_rows > 0)? '':'display_off'; //elements to display only if locked
	$cols_if_lock =  ($lock_num_rows > 0)? '6':'5'; //colspan changes if hidden column is displayed
	$display_if_archiveall =  ($archiveall_num_rows > 0)?"":"display_off";

###### Directory Dropdowns and Mounted Volume Flags #######

# data directory:/data/ ($dir1)
# data directory:/data/ ($dir1)
$dir1_dropdown="/xGDBvm/data/"; // TODO: move to sitedef.php
if (file_exists("/xGDBvm/admin/iplant")) { // xGDBvm-iPlant only
    $df_dir1=df_available($dir1_dropdown); // check if /data/ directory is externally mounted (returns array)
    $devloc=str_replace("/","\/",$EXT_MOUNT_DIR); // read from device location stored in /xGDBvm/admin/devloc via sitedef.php
    $dir1_mount=(preg_match("/$devloc/", $df_dir1[0]))?"<span class=\"checked_mount\">Ext vol mounted</span>":"<span class=\"lightgrayfont\">Ext vol not mounted</span>"; //flag for dir1 mount
}
# data store directory:/input/ ($dir2)
$dir2_dropdown="$inputDir"; // 1-26-16 J Duvick from sitedef.php
if (file_exists("/xGDBvm/admin/iplant")) { // xGDBvm-iPlant only
    $df_dir2=df_available($dir2_dropdown); // check if /input/ directory is fuse-mounted (returns array)
 #   $dir2_dropdown=($df_dir2[0]=="fuse"  || $df_dir2[0]=="irodsFs")?"$inputDir":""; //only show input dir if fuse-mounted. REMOVED THIS REQUIREMENT 4/16/2014
    $dir2_mount=($df_dir2[0]=="fuse" || $df_dir2[0]=="irodsFs")?"<span class=\"checked_mount\">DataStore mounted</span>":"<span class=\"lightgrayfont\">DataStore not mounted</span>"; //flag for dir1 mount
}

# display mount status (iPlant only)
$dir1_status=(file_exists("/xGDBvm/admin/iplant"))?"<span class=\"normalfont\" style=\"font-weight:normal\">&nbsp; &nbsp;<a class='help-button' title='Mount status of /xGDBvm/data/' id='config_input_ebs'>  $dir1_mount </a></span>":"";
$dir2_status=(file_exists("/xGDBvm/admin/iplant"))?"<span class=\"normalfont\" style=\"font-weight:normal\">&nbsp; &nbsp;<a class='help-button' title='Mount status of /xGDBvm/input/' id='config_input_datastore'> $dir2_mount </a></span>":"";


#Text depends on whether DB created or not, and Archive status
$display_block = ($GDB_num_rows > 0)?
"
	<span class=\"normalfont topmargin1 $display_if_lock\">
		Processing is underway, highlighted GDB is <span class=\"Locked largerfont bold\" style=\"padding-left:0.7em\"> Locked </span> &nbsp;
		<button class=\"submit $display_if_lock refresh bold\" style=\"color:magenta; cursor:pointer; font-size:13px; height:25px\">Click to refresh page.</button>

		<br /><br  />
		To abort process, click <b>GDB ID</b> to open its config page, click <b>Data Process Options &rarr; Abort</b>\".
	</span>
"
: 
"
	<span class=\"instruction largerfont\">
		NOTE: You haven't created any genome databases yet! To start the process, click <a href=\"/XGDB/conf/new.php\">Configure New</a> $archive_option
";


########## flag any extraneous GDB in /data/ and if so create $warning_text

$extra_data_msg="";
$extra_data=checkExtra("data"); //flag any extraneous GDB in data 
if(!empty($extra_data))
{
	foreach($extra_data as $data_item)
	{
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


$display_block .= "



<table style=\"margin:20px 5px 10px 0; width: 100%;\">
			<tr>
			
				<td width=\"80%\">
				</td>
				<td align=\"right\">
					<form method=\"post\" class=\"$display_if_db styled\" name=\"delete_all\" action=\"/XGDB/conf/deleteall_exec.php\">
						<input type=\"hidden\" name=\"action\" value=\"deleteall\" />
						<input type=\"hidden\" name=\"redirect\" value=\"archive\" />
                        <input type=\"hidden\" name=\"valid\" value=\"$valid_post\" />
						<span class=\"nowrap\"><input id=\"deleteall\" class=\"submit\" type=\"submit\" style=\"color:red\" value=\"Delete All GDB\" onclick=\"return confirm('Do you really want to delete ALL GDB output data, annotations, and archives? NOT REVERSIBLE')\"/>
                        <img id='config_delete_all' title='Delete Help' class='help-button' src='/XGDB/images/help-icon.png' alt='?' /> </span>
					</form>				
				</td>
				<td class=\"$display_if_db\" align = \"right\">
					<form method=\"post\" name=\"archive\" action=\"/XGDB/conf/archive_exec.php\" class=\"styled\">
						<input type=\"hidden\" name=\"action\" value=\"archive_all\" />
						<input type=\"hidden\" name=\"return\" value=\"archive\" />
                        <input type=\"hidden\" name=\"valid\" value=\"$valid_post\" />
						<span class=\"nowrap\"><input id=\"archive\" class=\"submit\" type=\"submit\" value=\"Archive All GDB\" onclick=\"return confirm('Do you really want to archive all GDB? This will not affect current GDB data, but will overwrite any existing archive data.')\"/>
 						<img id='config_archive_all' title='Click for Info' class='help-button' src='/XGDB/images/help-icon.png' alt='?' /> </span>
 					</form>
				</td>
				
				<td class=\"$display_if_nodb\" align = \"right\">
					<form method=\"post\" name=\"restore\" action=\"/XGDB/conf/restore_exec.php\" class=\"styled\">
						<input type=\"hidden\" name=\"action\" value=\"restore_all\" />
						<input type=\"hidden\" name=\"return\" value=\"archive\" />
                        <input type=\"hidden\" name=\"valid\" value=\"$valid_post\" />
						<span class=\"nowrap\"><input id=\"restore\" class=\"submit\" style=\"color:darkgreen\" type=\"submit\" value=\"Restore All GDB\" onclick=\"return confirm('Do you really want to restore? (This will load data from attached drive)')\"/>
						<img id='config_restore_all' title='Restore Help' class='help-button' src='/XGDB/images/help-icon.png' alt='?' /> </span>
					</form>
				</td>
				<td class=\"$display_if_db\" align = \"right\">
					<form method=\"post\" name=\"delete_archive_all\" action=\"/XGDB/conf/archive_exec.php\" class=\"styled $display_if_archiveall\">
						<input type=\"hidden\" name=\"action\" value=\"delete_archive_all\" />
						<input type=\"hidden\" name=\"return\" value=\"archive\" />
                        <input type=\"hidden\" name=\"valid\" value=\"$valid_post\" />
                        <span class=\"nowrap\"><input id=\"delete_archive_all\" class=\"submit\" type=\"submit\" style=\"color:firebrick\" value=\"Delete Archive All\" onclick=\"return confirm('Do you really want to delete all Archives? (Current Data will not be altered)')\"/>
 							<img id='config_delete_archive_all' title='Delete Archives Help' class='help-button' src='/XGDB/images/help-icon.png' alt='?' /> </span>
					</form>
				</td>
			</tr>
	</table>
				

";

$display_block .= "<table class=\"featuretable bottommargin1 striped\" style=\"font-size:12px\" cellpadding=\"6\">
<thead align=\"center\">
				<tr  class=\"reverse_1\">
					<th rowspan=\"2\" >
						GDB <br /> ID <br /><br />
					<span class=\"grayfont\">(Click <img src=\"/XGDB/images/configure.png\" alt=\"\" /> to view config)</span>
					</th>
					<th rowspan=\"2\">GDB Home</th>
					<!--th rowspan=\"2\">C<br />o<br />n<br />f<br />i<br />g</th -->
					<th rowspan=\"2\">Name<br /></th>
					<th rowspan=\"2\">Status</th>
					<th rowspan=\"2\">Organism </th>
					<th rowspan=\"2\">Total <br />Fea- tures<sup>1</sup> </th>					
					<th class=\"smallerfont\" rowspan=\"2\" style=\"text-align:left\">&nbsp;&nbsp;&nbsp;Status Date: <br /><br />
					   &nbsp;&nbsp; <img style=\"margin-bottom:-4px\" alt=\"\" src=\"/XGDB/images/configure.png\" /> &nbsp; Configured<br />
						&nbsp;&nbsp; <img style=\"margin-bottom:-4px\"  alt=\"\" src=\"/XGDB/images/create.png\" /> &nbsp; Created<br /> 
						&nbsp;&nbsp; <img style=\"margin-bottom:-4px\"  alt=\"\" src=\"/XGDB/images/update.png\" /> &nbsp; Updated<br />
					</th>
					<th rowspan=\"2\" >
					Drop GDB
 							<img id='config_drop_column' title='More information about Drop' class='help-button' src='/XGDB/images/help-icon.png' alt='?' /> </span>
					</th>
					<th rowspan=\"2\" >
					Delete GDB <img id='config_delete_GDB' title='Click for info' class='help-button' src='/XGDB/images/help-icon.png' alt='?' />
					</th>
					<th colspan=\"2\" class=\"\" >
					Archived &amp; Restored &nbsp; <img id='config_archive_symbols' title='Restored Help' class='help-button' src='/XGDB/images/help-icon.png' alt='?' />
					</th>
					<th colspan=\"3\">
					Manage GDB Archive <img id='config_manage_archive' title='Help with Archive GDB' class='help-button' src='/XGDB/images/help-icon.png' alt='?' />
					</th>
				</tr>
				<tr class=\"reverse_1\"> 
					<th class=\"smallerfont\" >All GDB</th>
					<th class=\"smallerfont\" >
					Single GDB:
						<br /><br />
					   &nbsp;&nbsp; <img style=\"margin-bottom:-4px\" alt=\"\" src=\"/XGDB/images/archive.png\" /> &nbsp; Archived<br />
						&nbsp;&nbsp; <img style=\"margin-bottom:-4px\"  alt=\"\" src=\"/XGDB/images/restored.png\" /> &nbsp; Restored<br />
 					</th>
					<th class=\"smallerfont\" >Archive or Restore</th>
					<th class=\"smallerfont\" >Delete Archive</th>
					<th class=\"smallerfont\" >Copy Archive to Data Store <img id='config_copy_archive' title='Help with Copy to Data Store' class='help-button' src='/XGDB/images/help-icon.png' alt='?' /><br />(<span class=\"checked\"> </span> = current)</th>
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
										$Archive_File=$row["Archive_File"];
										$Restore_From_File=$row["Restore_From_File"];
										$Archive_All_Date=$row["Archive_All_Date"];
										$Restore_All_Date=$row["Restore_All_Date"];
										$Restore_Source=($Restore_From_File!="")?$Restore_From_File:$Archive_File; # If the user hasn't loaded a Restore_From_File, use Archive_File (if present)
										$Input_Data_Path=$row["Input_Data_Path"];
										$DBid = 'GDB'.substr(('00'. $ID),-3); #calculated from unique ID										
										$DBname = $row["DBname"];
										$homepage_link = ($Status=="Current")? "<a title=\"View $DBname home page\" href=\"/$DBid/\"><img alt=\"conf\"  src=\"/XGDB/images/home_go.png\" /></a>":"";										
										$DBid_link = "<a class=\"nowrap\" href=\"/XGDB/conf/view.php?id=$ID\"><span class=\"configure\">$DBid </span><img alt=\"conf\" src=\"/XGDB/images/configure.png \" /> </a>";
										$output_data_link=($Status=="Current" || $Status=="Locked")? "<a title=\"Output data download for $DBname\" href=\"/XGDB/phplib/download.php?GDB=$DBid\"><img alt=\"conf\" src=\"/XGDB/images/door_out.png\" /></a>":"";
										$temp_data_link=($Status=="Locked")? "<a title=\"Temp data directory for $DBname \" href=\"/xGDBvmData/$DBid/\"><img alt=\"conf\" src=\"/XGDB/images/temp_dir.png\" /></a>":"";
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
										$Default_GSEG=$row["Default_GSEG"];
										$Default_lpos=$row["Default_lpos"]?$row["Default_lpos"]:"1";
										$Default_rpos=$row["Default_rpos"]?$row["Default_rpos"]:"10000";
										$getGSEG_Region="getGSEG_Region.pl?gseg_gi=".$Default_GSEG."&amp;bac_lpos=".$Default_lpos."&amp;bac_rpos=".$Default_rpos;
										$context_view_link =  ($Status=="Current")? "<a title=\"View sample region in genome context\" href=\"/$DBid/cgi-bin/$getGSEG_Region\"><img alt=\"globe\" src=\"/XGDB/images/contextview.gif\" /></a>":"";	        								
						## Compute resources Remote flag
										$comp_res_flag =  ($Status == "Development" && ($GSQ_CompResources == "Remote" || $GTH_CompResources == "Remote"))? "<a class=\"smallerfont\" href=\"/XGDB/jobs/process.php?id=$ID\"><img src=\"/XGDB/images/remote_compute.png\" alt=\"Ext\"/></a>":"";
                        ## Don't Display buttons only if archive/restore in progress.
										$archive_hide=($Archive_Date == "In Progress")?"display_off":"";
										$restore_hide=($Restore_Date == "In Progress")?"display_off":"";
						## Change to "Locked" status if archiving or restoring underway.
										$refresh_hide=($Status == "Locked")?"":"display_off";
#										if($Status =="Current"){ #for styling table background
#												$status_class="current";									
#												}else{
#												$status_class="not_current";
#										}
									    $status_class= $Status; #assign css class to rows

						####Display modifications########
														
								$xGDB_link= "<a href=/\"".$DBid."/\">".$DBid."</a>";

						######## Check Progress File and format for inclusion in table (Locked or Current only) ##########
								
						$progress_display= ($Status =='Locked' || $Status =='Current' )? "<img id='Pipeline_procedure' title='$DBid' class='logfile-button' src='/XGDB/images/help-icon.png' alt='?' />":"";
								
								
                         ######## Display Dates with image and date ##########
                         
						$Config_Date_Display = ($Config_Date!='')? '<img alt="config" src="/XGDB/images/configure.png" />'.$Config_Date :'';
						$Create_Date_Display = ($Create_Date!='')? '<br /><img alt="create	" src="/XGDB/images/create.png" />'.$Create_Date :'';
						$Update_Date_Display = ($Update_Date!='')? '<br /><img alt="update" src="/XGDB/images/update.png" />'.$Update_Date :'';
						
                         ######## Archive /Restore Dates with image and hover-over date ##########

						$Archive_Date_Display = ($Archive_Date!='' && is_file("/xGDBvm/data/ArchiveGDB/$Archive_File"))? '<br /><a href="/XGDB/phplib/download.php?GDB='.$DBid.'&amp;dir=Archive"><img alt="archive" title="/xGDBvm/data/ArchiveGDB/'.$Archive_File.'" src="/XGDB/images/archive.png" /></a>'.$Archive_Date :'';
						$Restore_Date_Display = ($Restore_Date!='')? '<br /><img alt="restore" title="/xGDBvm/data/ArchiveGDB/'.$Restore_Source.'")" src="/XGDB/images/restored.png" />'.$Restore_Date :'';
 						$Archive_All_Date_Display = ($Archive_All_Date!='')? '<br /><a href="/data/ArchiveAll/'.$DBid.'/"><img alt="archive all" title="Archive All GDB" src="/XGDB/images/archive_all.png" /></a>'.$Archive_All_Date :'';
						$Restore_All_Date_Display = ($Restore_All_Date!='')? '<br /><img alt="restore all" title="Restore All GDB" src="/XGDB/images/restored_all.png" />'.$Restore_All_Date :'';

 						######## Show or hide Restore/ Delete buttons depending on data/Status (and always hide if Status=Locked) ############
 						
 						$archive_confirmed= (is_file("/xGDBvm/data/ArchiveGDB/$Archive_File") && $Archive_Date != '')?'T':'F';
 						
 						$display_if_archive=($Status == 'Current' && $Status != 'Locked')?"":"display_off"; # GDB must be "Current"
 						$display_if_current=($Status == 'Current' && $Status != 'Locked')?"":"display_off"; # GDB must be "Current"
 						$display_if_restore=($Status == 'Development' && $Archive_Date != '')?"":"display_off"; # GDB must be "Development" and Archive must exist
 						$display_if_delete=($Archive_Date == '' || $Status == 'Locked')?"display_off":""; # There must be an ArchiveGDB present to delete
 						
 						######## Show or hide checkmark based on file time stamp ############
						# /xGDBvm/data/ArchiveGDB/GDB001-Example-4---CpGAT-Option-20160210-121814.tar
						$display_if_copied=(is_file("${inputdir}/archive/$Archive_File"))?"checked":""; # show or hide checkmark depending on last access
						
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
						
						$total_features=$gseg_total+$est_align_total+$cdna_align_total+$put_align_total+$prot_align_total+$gene_anno_total+$cpgat_gene_anno_total;
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
						$total_features="";
						}											

$display_if_last= ($maxID==$ID)?"":"display_off";
									
										
$display_block .= "						

    <tr id=\"$DBid\" align=\"right\" class=\"$status_class\">
        <td align=\"center\"  class=\"bold\" >
            $DBid_link <br />
        </td>
        <td align=\"center\">
        $homepage_link
        </td>
        <td align=\"left\">
            $DBname
        </td>
        <td align=\"center\" class=\"bold\">
            $Status_display
        </td>	
    
        <td class=\"italic\">
            $Organism
        </td>
        <td>$total_features
        </td>
        <td align=\"left\" class=\"italic smallerfont nowrap\">
            $Config_Date_Display
            $Create_Date_Display
            $Update_Date_Display
        </td>
        <td align=\"center\">
        <form method=\"post\" name=\"drop\" action=\"/XGDB/conf/drop.php\" class=\"styled topmargin1 $display_if_current\">
            <input type=\"hidden\" name=\"action\" value=\"drop\" />
            <input type=\"hidden\" name=\"id\" value=\"$ID\" />
            <input type=\"hidden\" name=\"xgdb\" value=\"$DBid\" />
            <input type=\"hidden\" name=\"valid\" value=\"$valid_post\" />
			<input type=\"hidden\" name=\"redirect\" value=\"archive\" />
            <input title=\"Drop this GDB but retain its configuration\" class=\"submit drop \" type=\"submit\" style=\"color:gray\" value=\"Drop\" onclick=\"return confirm('Do you really want to drop $DBid database?\\n\\nThis will remove ALL ouptut data for this GDB.\\n\\n It will revert to Development status\\nand the GDB Configuration will be retained')\"/>
        </form>
        </td>
        <td align=\"center\">
        <form method=\"post\" name=\"delete\" action=\"/XGDB/conf/drop.php\" class=\"styled topmargin1 $display_if_last $display_if_nolock\">
            <input type=\"hidden\" name=\"action\" value=\"delete_last\" />
            <input type=\"hidden\" name=\"id\" value=\"$ID\" />
            <input type=\"hidden\" name=\"xgdb\" value=\"$DBid\" />
			<input type=\"hidden\" name=\"redirect\" value=\"archive\" />
            <input type=\"hidden\" name=\"valid\" value=\"$valid_post\" />
            
            <input title=\"Delete this GDB, its configuration, and archive (if any)\" class=\"submit delete $display_if_last $restore_hide\" type=\"submit\" style=\"color:red\" value=\"Delete\" onclick=\"return confirm('Do you really want to delete $DBid?\\n\\nThis will remove ALL ouptut data for this GDB,\\nINCLUDING any GDB archive.\\n\\nTHIS ACTION IS NOT REVERSIBLE\\n\\n(Tip: to preserve the Archive, first COPY it to your DataStore)\\n\\n')\"/>
        </form>
        </td>
        <td class=\"italic smallerfont nowrap\">
            $Archive_All_Date_Display													
            $Restore_All_Date_Display													
        </td>
        <td class=\"italic smallerfont nowrap\">
            $Archive_Date_Display
            $Restore_Date_Display
        </td>
        <td align=\"center\">
        <form method=\"post\" name=\"archive\" action=\"/XGDB/conf/archive_exec.php\" class=\"styled topmargin1 $display_if_archive\">
            <input type=\"hidden\" name=\"id\" value=\"$ID\" />
            <input type=\"hidden\" name=\"xgdb\" value=\"$DBid\" />
            <input type=\"hidden\" name=\"action\" value=\"archive_one\" />
            <input type=\"hidden\" name=\"return\" value=\"archive\" />
            <input type=\"hidden\" name=\"valid\" value=\"$valid_post\" />
            <input title=\"Archive data from this GDB\" class=\"submit archive $archive_hide\" type=\"submit\" style=\"color:darkblue\" value=\"Archive\" onclick=\"return confirm('Do you really want to archive?\\n\\n(This will not affect current xGDB data)')\" />
        </form>
        <form method=\"post\" name=\"restore\" action=\"/XGDB/conf/restore_exec.php\" class=\"styled topmargin1 $display_if_restore\">
            <input type=\"hidden\" name=\"id\" value=\"$ID\" />
            <input type=\"hidden\" name=\"xgdb\" value=\"$DBid\" />
            <input type=\"hidden\" name=\"action\" value=\"restore_one\" />
            <input type=\"hidden\" name=\"return\" value=\"archive\" />
            <input type=\"hidden\" name=\"valid\" value=\"$valid_post\" />
			<input type=\"hidden\" name=\"source_file\" value=\"$Restore_Source\" />
            <input title=\"Restore data from the GDB Archive\" class=\" submit restore $restore_hide\" style=\"color:darkgreen\" type=\"submit\" value=\"Restore\" onclick=\"return confirm('Do you really want to restore?\\n\\n(This creates a new xGDB database)')\" />
        </form>
        </td>
        <td align=\"center\" >
        <form method=\"post\" name=\"delete_archive\" action=\"/XGDB/conf/archive_exec.php\" class=\"styled topmargin1 $display_if_delete\">
            <input type=\"hidden\" name=\"id\" value=\"$ID\" />
            <input type=\"hidden\" name=\"xgdb\" value=\"$DBid\" />
            <input type=\"hidden\" name=\"source_file\" value=\"$Archive_File\" />
            <input type=\"hidden\" name=\"action\" value=\"delete_one\" />
            <input type=\"hidden\" name=\"return\" value=\"archive\" />
            <input type=\"hidden\" name=\"valid\" value=\"$valid_post\" />
            <input title=\"Delete the archived data from this GDB (does not affect GDB output data)\" class=\"submit delete_archive\" style=\"color:firebrick\" type=\"submit\" value=\"Delete\" onclick=\"return confirm('Do you really want to delete the archive for this GDB?\\n\\n(This will not affect your GDB database)')\" />
        </form>
        </td>
        <td align=\"center\">
        <form method=\"post\" name=\"copy_archive\" action=\"/XGDB/conf/archive_exec.php\" class=\"styled topmargin1 $display_if_delete $display_if_copied\">
            <input type=\"hidden\" name=\"id\" value=\"$ID\" />
            <input type=\"hidden\" name=\"xgdb\" value=\"$DBid\" />
            <input type=\"hidden\" name=\"source_file\" value=\"$Archive_File\" />
            <input type=\"hidden\" name=\"action\" value=\"copy_one\" />
            <input type=\"hidden\" name=\"return\" value=\"archive\" />
            <input type=\"hidden\" name=\"valid\" value=\"$valid_post\" />
            <input title=\"Copy the archived data from this GDB (does not affect GDB output data)\" class=\"submit copy_archive\" style=\"color:darkgreen\" type=\"submit\" value=\"Copy\" onclick=\"return confirm('Do you really want to copy the archive for this GDB?\\n\\n(This will not affect your GDB archive)')\" />
        </form>
        </td>
    </tr>";
}

$display_block .= "</tbody></table>";

?>

	<div id="leftcolumncontainer">
		<div class="minicolumnleft">
			<?php include_once("/xGDBvm/XGDB/conf/leftmenu.inc.php"); ?>
		</div>
	</div>
	<div id="maincontentscontainer" class="twocolumn overflow configure">
			<div id="maincontentsfull" class="configure">
			<h1 class="configure bottommargin1"><img alt="" src="/XGDB/images/configure.png" /> Archive/Restore/Delete GDB <img id='config_archive_delete' title='Here you can archive or drop current GDB. Click ? for details.' class='help-button nudge1' src='/XGDB/images/help-icon.png' alt='?' /></h1>
			
			<span class="normalfont indent1" style="font-weight:normal">&nbsp; <?php echo $dir1_status; ?> &nbsp; <?php echo $dir2_status; ?></span>

				<div class="topmargin2 showhide"><p title="Show additional information directly below this link" class="label normalfont" style="cursor:pointer">How to use this page...</p>
				 	<div class=" hidden">

				<?php include_once("/xGDBvm/XGDB/help/includes/config_archive_delete.inc.php") ?>
				</div>
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
