<?php
#error_reporting(E_ALL & ~E_NOTICE); //disable undeclared variable error
session_start();

####### Set POST validation variable for this browser session #######
$valid_post = hash('sha512', mt_rand()*time()); # insure POST identity
$_SESSION['valid'] = $valid_post; 

####### Token lifespan and logout  ########

if (isset($_SESSION['access_token']) && $_SESSION['http_code']=="200")// successful login has already occurred
	{
	$expires=isset($_SESSION['expires'])?$_SESSION['expires']:""; //time when token expires
	$issued=isset($_SESSION['issued'])?$_SESSION['issued']:"";
	$lifespan=isset($_SESSION['lifespan'])?$_SESSION['lifespan']:"";
	$http_code=isset($_SESSION['http_code'])?$_SESSION['http_code']:"";
	$username=isset($_SESSION['username'])?$_SESSION['username']:"";
	$access_token=isset($_SESSION['access_token'])?$_SESSION['access_token']:"";
	$now=date("U");
//	$expires=$issued+30; //debug only
	if($expires<$now)
		{
		$login_id=$_SESSION['login_id']; //return to this config page
		header("Location: ../jobs/logout_exec.php?id=$login_id&msg=expired&redirect=view");
		}
	}
	
$refresh_token=isset($_SESSION['refresh_token'])?$_SESSION['refresh_token']:""; //if present, indicates user is capable of refreshing
$access_token=isset($_SESSION['access_token'])?$_SESSION['access_token']:""; //if present, indicates user is logged in


###### END token lifespan and logout #####

###### Load defaults ######
$VM=`uname -n|cut -d "." -f 1`; # identifies this VM (used for $archive_dir function)
$VM=preg_replace( "/\r|\n/", "", $VM ); // strip line feed
$global_DB= 'Genomes';
$PageTitle = 'GDB Config';
$pgdbmenu = 'Manage';
$submenu1 = 'Config-Home';
$submenu2 = 'Config-View';
$leftmenu='Config-View';
$warning_msg='';
$view="T";
global $gb1_display, $gb1_details, $gb2_display, $gb3_display, $gb4_display, $db_list, $validGB, $locked, $locked_DBid, $logged_in, $archive_dirlist_display;
global $conditional_edit_current, $tail_line1, $tail_line2, $input_results_display, $result_list_hide, $mode_message_display, $input_errors_display;
global $prot_align_total, $prot_total, $put_align_total, $cdna_non_total, $cdna_cog_total, $cdna_algn_total, $cdna_total, $est_non_total, $est_cog_total, $est_algn_total, $est_total, $yrgate_total, $cpgat_gene_anno_total, $gene_loci_total, $gene_anno_total, $anno_gseg_total, $gseg_total, $validUpdateList, $feature_totals_string, $update_results_display, $pipeline_errors_display, $top_list_hide;
global $validUpdateList, $a_list, $validRepMask;
include_once('sitedef.php');
include_once(dirname(__FILE__).'/conf_functions.inc.php');	
include_once('/xGDBvm/XGDB/jobs/login_functions.inc.php'); # for remote compute option (HPC)
include_once(dirname(__FILE__).'/validate.php');
include_once('/xGDBvm/XGDB/phplib/db.inc.php');

$inputDir=$XGDB_INPUTDIR; # 1-26-16 J Duvick - via sitedef.php
$dataDir=$XGDB_DATADIR; # 1-26-16 J Duvick
$inputDirRoot=$XGDB_INPUTDIR_MOUNT; # 1-26-16 J Duvick
$ext_mount_dir=$EXT_MOUNT_DIR;  # 1-26-16 J Duvick

###### Connect to database ######
$dbpass=dbpass();
$db = mysql_connect("localhost", "gdbuser", $dbpass);
if(!$db)
{
	echo "Error: Could not connect to database!";
	exit;
}
mysql_select_db("$global_DB");

$error = (isset($_GET['error']))?$_GET['error']:"";

date_default_timezone_set("$TIMEZONE");

####### SESSION TIME-OF-LIFE BASED ON TOKEN LIFESPAN ########

if (isset($_SESSION['token']) && $_SESSION['http_code']=="200")// successful login has already occurred
	{
	$expires=$_SESSION['expires']; //time when token expires
	$issued=$_SESSION['issued'];
	$lifespan=$_SESSION['lifespan'];
	$http_code=$_SESSION['http_code'];
	$now=date("U");
#	$expires=$issued+30; //debug only

	if($expires<$now) {
		$login_id=$_SESSION['login_id']; //return to the GDB that was originally used for login.
#		header("Location: logout.php?id=$login_id&result=expired"); //9-2-13
		header("Location: logout.php?id=$login_id&msg=expired&redirect=view"); //come back to this page
	   }
	}

##### TAKE US TO THE CORRECT RECORD OR GET US OUT OF HERE (before header loads) #####

	## Find out if at least 1 GDB record exists.
	
	$id_query = "select count(ID) from xGDB_Log";
	$check_get_id = mysql_query($id_query);
	$get_id_query = mysql_fetch_array($check_get_id);
	$id_count = $get_id_query[0];
	
	## if not, send user to create one	
	
	if($id_count==0) // no GDB
		{
		$view="F";
		header("Location: new.php?error=gdbempty");
		}
	
	## If the user is requesting an ID, get (integer) id, build requested GDB ID
	if(mysql_real_escape_string($_REQUEST['id']))  #URL string shows ?id=
		{
		$id = (int) substr('00'. mysql_real_escape_string($_REQUEST['id']), -3); //parses either 3 or GDB003 to an integer;  TODO - need to further sanitize since numerical
	
		## Out of range? Go to list view
		if($id>$id_count || $id==0)
			{
			$view="F";
			header("Location: viewall.php?error=outofrange");
			}
		}// end $__GET
		else
		{ #no ID requested
		$view="F";
		header("Location: viewall.php?error=norequest");
		}
	

### CREATE SESSION VARIABLE ###
if($view=="T"){
	$_SESSION['id']=$id; //
	$_SESSION['gdbid'] = 'GDB'.substr(('00'. $id),-3);//
	}
	
## Load header

	include($XGDB_HEADER);

## Assign $_SESSION values (from login.php) if they exist 


$username= isset($_SESSION['username'])?$_SESSION['username']:"";
$token= isset($_SESSION['token'])?$_SESSION['token']:"";
#$timeout=$_SESSION['timeout'];

# Validate license keys installed (conf_functions.inc.php validate_dir($dir, $target, $description, $present, $absent)
$validate_gm=validate_dir($GENEMARK_KEY_DIR, $GENEMARK_KEY, "GeneMark License Key", "installed", "not installed");
$gm_valid=$validate_gm[0]; $gm_class=$validate_gm[1];
$validate_gth=validate_dir($GENOMETHREADER_KEY_DIR, $GENOMETHREADER_KEY, "GenomeThreader License Key", "installed", "not installed");
$gth_valid=$validate_gth[0]; $gth_class=$validate_gth[1];
$validate_vm=validate_dir($VMATCH_KEY_DIR, $VMATCH_KEY, "Vmatch License Key","installed", "not installed");
$vm_valid=$validate_vm[0]; $vm_class=$validate_vm[1];

#### Validate presence of GTH Key (required for remote GTH) ###

$validate_gth_present=validate_dir($KEY_SOURCE_DIR, $GENOMETHREADER_KEY, "GenomeThreader License Key", "present", "missing");
$gth_present=$validate_gth_present[0]; $gth_present_class=$validate_gth_present[1];
$gth_present_message="<span class=\"$gth_present_class\">GTH license ${gth_present}</span> <img id='jobs_gth_license' title='GenomeThreader License - Help' class='help-button nudge3 smallerfont' src='/XGDB/images/help-icon.png' alt='?' />";


### Set default display by assigning css class to show/hide respective td elements
    $background = "";
    $log = 'display_off'; // don't show logfile pointer in left menu
	$edit = 'display_off'; //default - don't show edit data features when page loads
	$view = 'display_on'; //defaults - do show view data features when page loads
	$create = 'display_off'; // default - don't show create button when page loads 
	$validate = 'display_off'; // default - don't show validate button when page loads 
	$drop = 'display_off'; // default - don't show drop button when page loads
	$cancel = 'display_off'; // default - don't show cancel button when page loads
	$nav = 'display_on'; //defaults - show nav buttons (Select, next/prv)  when page loads
    $abort = 'display_off'; //defaults - hide button to allow abort.
	$update = 'display_off'; //defaults - hide update button
	$annotate='display_off';//defaults - hide annotate button
	$error = 'display_off';
	$required = '';
	$options = 'display_off'; //default - hide options mode flag
	$lockout = 'display_off'; //default - flag that warns user a pipeline is running on a different GDB
	$restore = 'display_off'; // default - don't show restore button unless an archive date exists in DB and is later than restore date
	$warning = ''; //default - display warning unless Create or Update is clicked.
	$conditional_update = 'display_off'; //
	$display_load_archive = 'display_off'; // Normally don't display list of ArchiveGDB datasets (Edit mode only; Development only; data exists only)
	
### Modify display based on posted values: the following variables set a td css class corresponding to either display:block or display:hidden

$post_actions=isset($_POST['actions'])?$_POST['actions']:"";

if($post_actions == 'options'){ // Enter options mode, turn on orange bckgd by default.
$options_bckgd= 'display_on';
}

$post_mode=isset($_POST['mode'])?$_POST['mode']:"";

if($post_mode == 'Cancel' || $post_mode == 'View'  ){ // Enter View mode (Default). No create/drop buttons show.

	$edit = 'display_off';
	$view = 'display_on';
	$create = 'display_off';
	$drop = 'display_off';
	$nav = 'display_on';
	$locked = 'display_on';
	$cancel = 'display_off';
    $abort = 'display_off';
	$annotate='display_off';
    $required = '';
	$validate = 'display_off';
	$options='display_off'; //options display
	$display_load_archive = 'display_off';
	}
if($post_mode == 'Edit'){ // Enter edit mode. No nav, no create, no locked. See also $cpgat_row_hide and $update_row_hide

    $background	= 'edit_bckgd';
    $edit = 'display_on';
	$view = 'display_off';
	$create = 'display_off';
	$drop = 'display_off';
	$nav = 'display_off';
	$locked = 'display_off';
	$cancel = 'display_off';
    $abort = 'display_off';
	$annotate='display_off';
    $required = 'required'; // this styles the required fields on edit
    $options='display_off';
	$lockout = 'display_off'; //default - flag that warns user a pipeline is running on a different GDB
	$display_load_archive =''; // show dropdown of ArchiveGDB datasets (if any)
	}

if($post_mode == 'Save Changes'){ // Leave edit mode. See $cpgat_row_hide and $update_row_hide
	$edit = 'display_off';
	$view = 'display_on';
	$create = 'display_off';
	$drop = 'display_off';
	$nav = 'display_on';
	$locked = 'display_off';
	$cancel = 'display_off';
    $abort = 'display_off';
	$annotate='display_off';
	$validate = 'display_off';
    $required = ''; // this styles the required fields on edit
	$options='display_off';
	}

if($post_mode == 'Create'){ // Enter Data Process Options mode with Create 
    $background	= 'options_bckgd';
	$edit = 'display_off';
	$view = 'display_on';
	$create = 'display_on';
	$validate = 'display_on';
	$drop = 'display_off';
	$locked = 'display_on';
	$nav = 'display_off';
	$cancel = 'display_on';
    $abort = 'display_on';
    $required = '';
	$update = 'display_off';
	$annotate='display_off';
	$options='display_on';
	$warning='display_off'; //suppress extra_GDB warning
	$display_load_archive = 'display_off';
	}

if($post_mode == 'Drop'){ // Enter Data Process Options mode with Drop or Archive
    $background	= 'options_bckgd';
	$edit = 'display_off';
	$view = 'display_on';
	$create = 'display_off';
	$drop = 'display_on';
	$locked = 'display_on';
	$nav = 'display_off';
	$cancel = 'display_on';
    $abort = 'display_on';
    $required = '';
	$update = 'display_off';
	$annotate='display_off';
	$options='display_on';
	}
if($post_mode == 'Update'){ // Enter Data Process Options mode with Update enabled as well as Create/Drop
    $background	= 'options_bckgd';
	$edit = 'display_off';
	$view = 'display_on';
	$create = 'display_on';
	$drop = 'display_on';
	$locked = 'display_on';
	$nav = 'display_off';
	$cancel = 'display_on';
    $abort = 'display_on';
    $required = '';
	$update = 'display_on';
	$validate = 'display_on';
	$annotate='display_off';
	$options='display_on';
	$warning='display_off'; //suppress extra_GDB warning
	}

if($post_mode == 'Annotate'){ // Enter Data Process Options mode with CpGAT Annotate enabled as well as UPdate, Create/Drop
    $background	= 'options_bckgd';
	$edit = 'display_off';
	$view = 'display_on';
	$create = 'display_on';
	$drop = 'display_on';
	$locked = 'display_on';
	$nav = 'display_off';
	$cancel = 'display_on';
    $abort = 'display_on';
    $required = '';
	$update = 'display_off';
	$annotate='display_on';
	}
if($post_mode == 'Error'){ // Enter Data Process Options mode with Drop
	$edit = 'display_off';
	$view = 'display_on';
	$create = 'display_off';
	$drop = 'display_on';
	$locked = 'display_on';
	$nav = 'display_off';
	$cancel = 'display_on';
    $abort = 'display_on';
    $required = '';
	$update = 'display_off';
	$validate = 'display_off';
	$annotate='display_off';
	$error='display_on';
	}


if($post_mode == 'Locked'){ // Enter Data Process Options mode with Locked database
    $background	= 'options_bckgd';
	$edit = 'display_off';
	$view = 'display_on';
	$create = 'display_off';
	$drop = 'display_on';
	$locked = 'display_off';
	$nav = 'display_off';
	$cancel = 'display_on';
	$validate = 'display_off';
	$abort = 'display_on';
    $required = '';
	$update = 'display_off';
	$annotate='display_off';
	$options='display_on';
	}

# Check if pipeline is running on ANY GDB, and show lockout option mode ('create' 'update' database actions disabled)

		$locked_query = "select * from xGDB_Log where Status='Locked' limit 1";
		$check_get_locked= mysql_query($locked_query);
		if($locked_data = mysql_fetch_array($check_get_locked)){
		$locked_id = $locked_data["ID"];
		$locked_DBid = 'GDB'.substr(('00'. $locked_id),-3); #calculated from unique ID
			if($locked_id != "$id" && mysql_real_escape_string($_POST['mode']) != 'Edit'){ # hide actions on OTHER GDB only, not the one that is locked
			$lockout = 'display_on';
			$create = 'display_off';
			$update = 'display_off';
			$validate = 'display_off';
			$locked = 'display_on';
			$options = 'display_off';
				}
	}


### Set dropdown and radio button values that are checked or selected, either by default or based on current database value.###
$checked="checked=\"checked\""; #for type =radio button
$selected="selected=\"selected\"";# for type= option

### Set Update radioboxes to "none" by default, unless data exists to override.
$None_EST_checked = $checked;
$None_cDNA_checked = $checked;
$None_TrAssembly_checked = $checked;
$None_Protein_checked = $checked;
$None_GSEG_checked = $checked;
$None_GeneModel_checked = $checked;

### Select New id

$post_passed=isset($_POST['passed'])?$_POST['passed']:"";
$post_id=isset($_POST['id'])?intval($_POST['id']):""; //should be integer

if($post_passed == 1){

	$id = $post_id;
	$get_data = "select * from xGDB_Log where ID like '$id'";
	
	$_SESSION['search_id'] = $id;


}else{  ### No query - just get the current id data


	$get_data = "select * from xGDB_Log where ID='$id'";
	
	
}

$check_get_data = mysql_query($get_data);
	
function formatDate($format,$dateStr)	{
if (trim($dateStr) == "" || substr($dateStr,0,10) == "0000-00-00") {
	return '';
  }
  $ts = strtotime($dateStr);
  if ($ts === false) {
	return '';
  }
return date($format,$ts); 
}

####### Following section under development 1/20/13, to allow user to load example files. ######
$get_example=isset($_GET['example'])?$_GET['example']:"";
if ($get_example !="") 
	{
		$Xmple = mysql_real_escape_string($_GET['example']);
		$Xmple = strval($Xmple); //convert to string for safety
		if($Xmple > 0 && $Xmple<10)
		{
			$filename = "/xGDBvm/examples/example".$Xmple."/GenomesExample".$Xmple.".txt";
			$data=get_example_data($filename); #get array of example data (conf_functions.inc.php)
		}

 ####### Preceding section under development 1/20/13 ######
    
}else{ # read values from GDB table

	while ($data = mysql_fetch_array($check_get_data)){
		$current_class=""; //assigned below
		
####### Defaults ######

		$Update_Data_Default="/xGDBvm/data/";
		$CpGAT_Data_Default="/xGDBvm/data/";

####### General Info #######
		$ID = $id; #post or get result.
		$DBid = 'GDB'.substr(('00'. $id),-3); #calculated from unique ID										
		$DBname = $data["DBname"];
		$Status=$data["Status"];
		$Process_Type=$data["Process_Type"];
		$Organism=$data["Organism"];
		$Common_Name=$data["Common_Name"];
		$Genome_Type=$data["Genome_Type"];
		$Config_Date=$data["Config_Date"];
		$Archive_Date=$data["Archive_Date"];
		$Archive_File=$data["Archive_File"];
		$Restore_Date=$data["Restore_Date"];
		$Restore_From_File=$data["Restore_From_File"];
	    $Restore_Source=($Restore_From_File!="")?$Restore_From_File:$Archive_File; # If the user hasn't loaded a Restore_From_File, use Archive_File (if present)
		$Archive_All_Date=$data["Archive_All_Date"];
		$Restore_All_Date=$data["Restore_All_Date"];

####### Restore Status #######
        $Restore_GDB=$DBid;
        $Restore_Other="F";
	    $pattern = "/^(GDB\d\d\d)(-\S+)(\.tar)$/"; # Parse the GDB ID from the source filename
	    if (preg_match($pattern, $Restore_From_File, $matches))
	      {
		     $Restore_GDB=$matches[1]; // e.g. GDB002, if the archive was loaded from a different GDB (only matters in Development mode)
		     $Restore_Other="T";
	      }
		
####### Database Status #######

		$Input_Data_Path=$data["Input_Data_Path"];
		$Input_Data_URL = str_replace("/xGDBvm", "", $Input_Data_Path);
		$GFF_Type=$data["GFF_Type"];
		$Create_Date=$data["Create_Date"];
		$Create_History=$data["Create_History"];

####### Transcript Spliced Alignment #######

		$RepeatMask_Status=$data["RepeatMask_Status"];
		$RepeatMask_File=$data["RepeatMask_File"];
		$RepeatMask_File_URL = str_replace("/xGDBvm", "", $RepeatMask_File);
		$Species_Model=$data["Species_Model"];
		
 ####### GSQ Remote Compute Option Status and Display (conditionally display links to Jobs pages) #######		
		
		$GSQ_CompResources=$data["GSQ_CompResources"]; # Local or Remote
		if($Status=="Current"){
			$gsq_compres_display=$GSQ_CompResources;
			}else{
			$gsq_compres_display=($GSQ_CompResources=="Local")?"$GSQ_CompResources":"<a title=\"Go to Remote Jobs -> Submit\" href=\"/XGDB/jobs/submit.php?id=$ID\">$GSQ_CompResources</a>";
			}
		$GSQ_Job_EST=$data["GSQ_Job_EST"];
			$est_job_display=($GSQ_Job_EST =="")?"":"<a href=\"/XGDB/jobs/jobs.php?id=$GSQ_Job_EST\" title=\"view job ID $GSQ_Job_EST\">$GSQ_Job_EST<img class=\"nudge2\" src=\"/XGDB/images/remote_compute.png\" alt=\"R\" /></a>";
		$GSQ_Job_cDNA=$data["GSQ_Job_cDNA"];
			$cdna_job_display=($GSQ_Job_cDNA =="")?"":"<a href=\"/XGDB/jobs/jobs.php?id=$GSQ_Job_cDNA\" title=\"view job ID $GSQ_Job_cDNA\">$GSQ_Job_cDNA<img class=\"nudge2\" src=\"/XGDB/images/remote_compute.png\" alt=\"R\" /></a>";
		$GSQ_Job_PUT=$data["GSQ_Job_PUT"];
			$put_job_display=($GSQ_Job_PUT =="")?"":"<a href=\"/XGDB/jobs/jobs.php?id=$GSQ_Job_PUT\" title=\"view job ID $GSQ_Job_PUT \">$GSQ_Job_PUT<img class=\"nudge2\" src=\"/XGDB/images/remote_compute.png\" alt=\"R\" /></a>";
		$gsq_jobs_display="$est_job_display $cdna_job_display $put_job_display"; // Concatenate if more than one
####### Protein Spliced Alignment #######
		$Gth_Species_Model=$data["Gth_Species_Model"];
		$Alignment_Stringency=$data["Alignment_Stringency"];

 ####### GTH Remote Compute Option Status and Display (conditionally display links to Jobs pages) #######		
		$GTH_CompResources=$data["GTH_CompResources"]; #Local or Remote
		if($Status=="Current"){
			$gth_compres_display=$GTH_CompResources;
			}else{
			$gth_compres_display=($GTH_CompResources=="Local")?"$GTH_CompResources":"<a title=\"Go to Remote Jobs :Process page\" href=\"/XGDB/jobs/submit.php?id=$ID\">$GTH_CompResources</a>";
			}
		$GTH_Job=$data["GTH_Job"];
			$gth_jobs_display=($GTH_Job =="")?"":"<a href=\"/XGDB/jobs/jobs.php?id=$GSQ_Job\" title=\"view job ID $GTH_Job \"><img src=\"/XGDB/images/remote_compute.png\" alt=\"R\" /></a>";
		
######## Database Update ########
		$Update_Status=$data["Update_Status"];
		$Update_Status_Display = ($Update_Status == "Update")? "Yes" : "No";
		$Update_Data_EST=$data["Update_Data_EST"];
		$Update_Data_cDNA=$data["Update_Data_cDNA"];
		$Update_Data_TrAssembly=$data["Update_Data_TrAssembly"];
		$Update_Data_GSEG=$data["Update_Data_GSEG"];
		$Update_Data_Protein=$data["Update_Data_Protein"];
		$Update_Data_GeneModel=$data["Update_Data_GeneModel"];
		$Update_Data_CpGATModel=$data["Update_Data_CpGATModel"];
		$Update_Descriptions=$data["Update_Descriptions"];
		$Update_Data_Path=($data["Update_Data_Path"])? $data["Update_Data_Path"]:$Update_Data_Default;
		$Update_Data_URL = str_replace("/xGDBvm", "", $Update_Data_Path);
		$Update_Comments=$data["Update_Comments"];
		$Update_Date=$data["Update_Date"];
		$Update_History=$data["Update_History"];

######## CpGAT ########
		$CpGAT_Status=$data["CpGAT_Status"];
		$CpGAT_Status_Display = ($CpGAT_Status == "Yes")? "Yes" : "No";
		$CpGAT_ReferenceProt_File=$data["CpGAT_ReferenceProt_File"];
		$CpGAT_ReferenceProt_URL = str_replace("/xGDBvm", "", $CpGAT_ReferenceProt_File);
		$CpGAT_BGF=$data["CpGAT_BGF"];
		$CpGAT_Augustus=$data["CpGAT_Augustus"];
		$CpGAT_GeneMark=$data["CpGAT_GeneMark"];
		$CpGAT_Skip_Mask=$data["CpGAT_Skip_Mask"];
		$CpGAT_Relax_UniRef=$data["CpGAT_Relax_UniRef"];
		$CpGAT_Skip_PASA=$data["CpGAT_Skip_PASA"];
		$CpGAT_Filter_Genes=$data["CpGAT_Filter_Genes"];
		$Update_Data_CpGAT=$data["Update_Data_CpGAT"];


######## Display & Annotation Defaults ########
        $Default_GSEG=$data["Default_GSEG"];
        $Default_lpos=$data["Default_lpos"];
        $Default_rpos=$data["Default_rpos"];
        $yrGATE_Reference=$data["yrGATE_Reference"];
        $yrGATE_Admin_Email=$data["yrGATE_Admin_Email"];
        
######## Genome ########
		$Genome_Source=$data["Genome_Source"]; $Genome_Source_title="Original data source (name of institution)";
      	$Genome_Source_Link=$data["Genome_Source_Link"];
 		$Genome_Version=$data["Genome_Version"];
 		$Genome_Count=$data["Genome_Count"];
  		$Chromosome_Count=$data["Chromosome_Count"];
  		$Unlinked_Chromosome_Count=$data["Unlinked_Chromosome_Count"];
 		$Scaffold_Count=$data["Scaffold_Count"];
 		$BAC_Count=$data["BAC_Count"];
 		$Genome_Comments=$data["Genome_Comments"];


######## Gene Models ########
       	$GeneModel_Version=$data["GeneModel_Version"];
       	$GeneModel_Source=$data["GeneModel_Source"];
       	$GeneModel_Link=$data["GeneModel_Link"];
       	$GeneModel_Comments=$data["GeneModel_Comments"];

######## Alignment Info ########
        $EST_Align_sp=$data["EST_Align_sp"];
        $EST_Align_Version=$data["EST_Align_Version"];
        $EST_Align_Comments=$data["EST_Align_Comments"];
        $cDNA_Align_sp=$data["cDNA_Align_sp"];
		$cDNA_Align_Version=$data["cDNA_Align_Version"];
        $cDNA_Align_Comments=$data["cDNA_Align_Comments"];
        $PUT_Align_sp=$data["PUT_Align_sp"];
        $PUT_Align_Version=$data["PUT_Align_Version"];
		$PUT_Align_Comments=$data["PUT_Align_Comments"];
        
      	$Prot_Align_sp=$data["Prot_Align_sp"];
     	$Prot_Align_Version=$data["Prot_Align_Version"];
      	$Prot_Align_Comments=$data["Prot_Align_Comments"];



    # Archive copied to Data Store? show or hide checkmark depending on whether Data Store copy of archive is current or not
	$display_if_archive_copied=(file_exists("$inputDirRoot/archive/$Restore_From_File"))?"checked":""; 
    
    # Hide parameter table rows and grey out legend (CpGAT, Update option) if flag is not "Yes" and Update is not CpGAT Append or CpGAT Replace #
       
       $cpgat_row_hide = (($CpGAT_Status== "Yes" || $edit=="display_on"))? "": "display_off"; # hide these rows in view mode if CpGAT flag is off.
       $repmask_row_hide = ($RepeatMask_Status== "Yes" || ($CpGAT_Status== "Yes" || $CpGAT_Skip_Mask == "No"))? "": "display_off"; # hide these rows in view mode if Repeat Mask flag is off and CpGAT flag is off (since it could be applied to either).
       $cpgat_legend_gray = ($CpGAT_Status== "Yes"  || $Update_Data_CpGAT !="" || $edit=="display_on")? "": "grayfont"; # color legend gray in view mode if CpGAT flag is off.
    
       $update_row_hide = (($Status == "Current" || $Status == "Locked") && ($Update_Status== "Update" || $edit=="display_on"))? "": "display_off"; # hide these rows in Edit mode, or in view mode if Update flag is off.
       $update_legend_gray = ($Update_Status== "Update" || $edit=="display_on")? "": "grayfont"; # color legend gray in view mode if Update flag is off.
       $update_history_hide = ($Status == "Current" && ($Update_History != "" || $edit=="display_on"))? "": "display_off"; # hide history row in Dev mode, or in view mode if empty (but show if data exist).
    
    
    # Don't allow login display or editing of certain config values (or display of certain buttons like 'Clear' and 'Reset') if database is Current 
    # useage: include this css class in <td> or <input>  element in edit and view where user modification in an existing GDB makes no sense) 
    
    if($Status == "Current"){
     $conditional_view="display_on"; #show non-editable version
     $conditional_edit="display_off"; #hide input box or edit dialog that is specific to Development Status.
     }else{
     $conditional_view=$view; #restore normal mode dependency of display
     $conditional_edit=$edit; #restore normal mode dependency of display
     }
     
    # Show or hide jobs links depending on whether remote status:
    $conditional_jobs=(($GSQ_CompResources == "Remote") || ($GTH_CompResources == "Remote"))?"":"display_off";
    
    # show validated files under "Update" status
    if($Update_Status == "Update"){
        $conditional_update ="";
    }

	# Hide Validate button if restoring from archive (nothing to validate!)
	
	if(!empty($Restore_From_File))
	{
		$validate = 'display_off';

	}
    ######### Set value of parameters posted to 'validate_files.php' (if empty, shell script xGDB_ValidateFiles.php will ignore files under that category):
    
    $validate_input=($Status == "Development")?$Input_Data_Path:""; #  Ignore this category if 'Update' chosen under status=Current
    $validate_update=($Update_Status == "Update" && $Status == "Current")?$Update_Data_Path:""; # Only use if ready to update
    $validate_refprot=($CpGAT_Status == "Yes")?$CpGAT_ReferenceProt_File:"";  # Only use if CpGAT will be run
    $validate_repmask=($RepeatMask_Status == "Yes")?$RepeatMask_File:"";  # Only use if Repeat Masking will be run
    
    ###### Markup for user selected parameters ########

    #GFF table type radio buttons
    $GFF_CpGAT_checked = ($GFF_Type == "CpGAT")? $checked:"";
    $GFF_Other_checked = ($GFF_Type == "Other")? $checked:"";
    
    #Comp Resources radio buttons
    $GSQCompRes_Internal_checked = ($GSQ_CompResources == "")? $checked: ($GSQCompRes_Internal_checked = ($GSQ_CompResources == "Local")? $checked:""); #default or currently assigned value
    $GSQCompRes_External_checked = ($GSQ_CompResources == "Remote")? $checked:"";
    $GTHCompRes_Internal_checked = ($GTH_CompResources == "")? $checked: ($GTHCompRes_Internal_checked = ($GTH_CompResources == "Local")? $checked:""); #default or currently assigned value
    $GTHCompRes_External_checked = ($GTH_CompResources == "Remote")? $checked:"";
    
    #Genome Type dropdown
    $GType_Scaff_selected = ($Genome_Type == "Scaffold")? $selected :"";
    $GType_Chr_selected = ($Genome_Type == "Chromosome")? $selected :"";
    $GType_BAC_selected = ($Genome_Type == "BAC")? $selected :"";
    $GType_ChrScaff_selected = ($Genome_Type == "Chromosome/Scaffold")? $selected :"";
    $GType_BACScaff_selected = ($Genome_Type == "BAC/Scaffold")? $selected :"";
    
    #Update EST radio buttons
    $Append_EST_checked = ($Update_Data_EST == "Append")? $checked:"";
    $Replace_EST_checked = ($Update_Data_EST == "Replace")? $checked:"";
    $None_EST_checked = ($Update_Data_EST == "")? $checked:"";
    
    #Update status radio buttons
    $Update_Status_none_checked = ($Update_Status == "")? $checked:"";
    $Update_Status_Updateable_checked = ($Update_Status == "Update")? $checked:"";
    
    #CpGAT status radio buttons
    $CpGAT_Status_none_checked = ($CpGAT_Status == "")? $checked:"";
    $CpGAT_Status_Updateable_checked = ($CpGAT_Status == "Yes")? $checked:"";
    
    #yrGATE_Ref
    $yrGATE_Ref_pre_checked = ($yrGATE_Reference == "")? $checked : ($yrGATE_Ref_pre_checked = ($yrGATE_Reference == "Precomputed")? $checked:""); #default or currently assigned value
    $yrGATE_Ref_cpgat_checked =($yrGATE_Reference == "CpGAT")? $checked:"";
    
    #Repeat Mask status radio buttons
    $RepeatMask_Status_no_checked = ($RepeatMask_Status == "")? $checked:"";
    $RepeatMask_Status_yes_checked = ($RepeatMask_Status == "Yes")? $checked:"";
    
    $Skip_BGF_checked = ($CpGAT_BGF == "Skip")? $checked :"";
    $Arabidopsis_BGF_checked = ($CpGAT_BGF == "Arabidopsis")? $checked :"";
    $Fruitfly_BGF_checked = ($CpGAT_BGF == "Fruitfly")? $checked :"";
    $maize_BGF_checked = ($CpGAT_BGF == "")? $checked : ($maize_BGF_checked = ($CpGAT_BGF == "maize")? $checked:""); #default or currently assigned value
    $rice_BGF_checked = ($CpGAT_BGF == "rice")? $checked :"";
    $Silkworm_BGF_checked = ($CpGAT_BGF == "Silkworm")? $checked :"";
    $soybean_BGF_checked = ($CpGAT_BGF == "soybean")? $checked :"";
    
    $Skip_Augustus_checked = ($CpGAT_Augustus == "Skip")? $checked :"";
    $arabidopsis_Augustus_checked = ($CpGAT_Augustus == "arabidopsis")? $checked :"";
    $chlamydomonas_Augustus_checked = ($CpGAT_Augustus == "chlamydomonas")? $checked :"";
    $fly_Augustus_checked = ($CpGAT_Augustus == "fly")? $checked :"";
    $maize_Augustus_checked = ($CpGAT_Augustus == "")? $checked : ($maize_Augustus_checked = ($CpGAT_Augustus == "maize")? $checked:""); #default or currently assigned value
    $tomato_Augustus_checked = ($CpGAT_Augustus == "tomato")? $checked :"";
    
    $Skip_GeneMark_checked = ($CpGAT_GeneMark == "Skip")? $checked :"";
    $a_thaliana_GeneMark_checked = ($CpGAT_GeneMark == "a_thaliana")? $checked :"";
    $barley_GeneMark_checked = ($CpGAT_GeneMark == "barley")? $checked :"";
    $c_reinhardtii_GeneMark_checked = ($CpGAT_GeneMark == "c_reinhardtii")? $checked :"";
    $d_melanogaster_GeneMark_checked = ($CpGAT_GeneMark == "d_melanogaster")? $checked :"";
    $corn_GeneMark_checked = ($CpGAT_GeneMark == "")? $checked : ($corn_GeneMark_checked = ($CpGAT_GeneMark == "corn")? $checked:""); #default or currently assigned value
    $m_truncatula_GeneMark_checked = ($CpGAT_GeneMark == "m_truncatula")? $checked :"";
    $o_sativa_GeneMark_checked = ($CpGAT_GeneMark == "o_sativa")? $checked :"";
    $wheat_GeneMark_checked = ($CpGAT_GeneMark == "wheat")? $checked :"";
    
    $CpGAT_Skip_Mask_no_checked = ($CpGAT_Skip_Mask == "")? $checked : ($CpGAT_Skip_Mask_no_checked = ($CpGAT_Skip_Mask == "No")? $checked:""); #default or currently assigned value
    $CpGAT_Skip_Mask_yes_checked = ($CpGAT_Skip_Mask == "Yes")? $checked :"";
    $CpGAT_Relax_UniRef_no_checked = ($CpGAT_Relax_UniRef == "")? $checked : ($CpGAT_Relax_UniRef_no_checked = ($CpGAT_Relax_UniRef == "No")? $checked:""); #default or currently assigned value
    $CpGAT_Relax_UniRef_yes_checked = ($CpGAT_Relax_UniRef == "Yes")? $checked :"";
    $CpGAT_Skip_PASA_no_checked = ($CpGAT_Skip_PASA == "")? $checked : ($CpGAT_Skip_PASA_no_checked = ($CpGAT_Skip_PASA == "No")? $checked:""); #default or currently assigned value
    $CpGAT_Skip_PASA_yes_checked = ($CpGAT_Skip_PASA == "Yes")? $checked : "";
    $CpGAT_Filter_Genes_no_checked = ($CpGAT_Filter_Genes == "")? $checked : ($CpGAT_Filter_Genes_no_checked = ($CpGAT_Filter_Genes == "No")? $checked:""); #default or currently assigned value
    $CpGAT_Filter_Genes_yes_checked = ($CpGAT_Filter_Genes == "Yes")? $checked :"";
    
    
    #Spliced Alignment parameter radio buttons
    $Arabidopsis_checked = ($Species_Model == "")? $checked : ($Arabidopsis_checked = ($Species_Model == "Arabidopsis")? $checked:""); #default or currently assigned value
    $maize_checked = ($Species_Model == "maize")? $checked :"";
    $rice_checked = ($Species_Model == "rice")? $checked :"";
    $Medicago_checked = ($Species_Model == "Medicago")? $checked :"";
    $Drosophila_checked = ($Species_Model == "Drosophila")? $checked:"";
    
    $Strict_Stringency_checked = ($Alignment_Stringency == "")? $checked : ($Strict_Stringency_checked = ($Alignment_Stringency == "Strict")? $checked:""); #default or currently assigned value
    $Moderate_Stringency_checked = ($Alignment_Stringency == "Moderate")? $checked :"";
    $Low_Stringency_checked = ($Alignment_Stringency == "Low")? $checked :"";
    
    $gth_arabidopsis_checked = ($Gth_Species_Model == "")? $checked : ($gth_arabidopsis_checked = ($Gth_Species_Model == "arabidopsis")? $checked:""); #default or currently assigned value
    $gth_maize_checked = ($Gth_Species_Model == "maize")? $checked :"";
    $gth_rice_checked = ($Gth_Species_Model == "rice")? $checked :"";
    $gth_medicago_checked = ($Gth_Species_Model == "medicago")? $checked :"";
    $gth_drosophila_checked = ($Gth_Species_Model == "drosophila")? $checked:"";    

    #Update cDNA radio buttons
    $Append_cDNA_checked = ($Update_Data_cDNA == "Append")? $checked:"";
    $Replace_cDNA_checked = ($Update_Data_cDNA == "Replace")? $checked:"";
    $None_cDNA_checked = ($Update_Data_cDNA == "")? $checked:"";
    
    #Update TrAssembly radio buttons
    $Append_TrAssembly_checked = ($Update_Data_TrAssembly == "Append")? $checked:"";
    $Replace_TrAssembly_checked = ($Update_Data_TrAssembly == "Replace")? $checked:"";
    $None_TrAssembly_checked = ($Update_Data_TrAssembly == "")? $checked:"";
    
    #Update Protein radio buttons
    $Append_Protein_checked = ($Update_Data_Protein == "Append")? $checked:"";
    $Replace_Protein_checked = ($Update_Data_Protein == "Replace")? $checked:"";
    $None_Protein_checked = ($Update_Data_Protein == "")? $checked:"";
    
    #Update GSEG radio buttons
    $Append_GSEG_checked = ($Update_Data_GSEG == "Append")? $checked:"";
    $Replace_GSEG_checked = ($Update_Data_GSEG == "Replace")? $checked:"";
    $None_GSEG_checked = ($Update_Data_GSEG == "")? $checked:"";
    
    #Update Gene Model (gff) radio buttons
    $Append_GeneModel_checked = ($Update_Data_GeneModel == "Append")? $checked:"";
    $Replace_GeneModel_checked = ($Update_Data_GeneModel == "Replace")? $checked:"";
    $None_GeneModel_checked = ($Update_Data_GeneModel == "")? $checked:"";
    
    #Update CpGAT Model (gff) radio buttons
    $Append_CpGATModel_checked = ($Update_Data_CpGATModel == "Append")? $checked:"";
    $Replace_CpGATModel_checked = ($Update_Data_CpGATModel == "Replace")? $checked:"";
    $None_CpGATModel_checked = ($Update_Data_CpGATModel == "")? $checked:"";
    
    
    #Add Gene Description radio buttons
    $Precomputed_Descriptions_checked = ($Update_Descriptions == "Precomputed")? $checked:"";
    $CpGAT_Descriptions_checked = ($Update_Descriptions == "CpGAT")? $checked:"";
    $None_Descriptions_checked = ($Update_Descriptions == "")? $checked:"";
    
    #Update CpGAT radio buttons
    $Append_CpGAT_checked = ($Update_Data_CpGAT == "Append")? $checked:"";
    $Replace_CpGAT_checked = ($Update_Data_CpGAT == "Replace")? $checked:"";
    $None_CpGAT_checked = ($Update_Data_CpGAT == "")? $checked:"";
    
    
    
    #### Construct CpGAT Parameter  (display only)  ####
    
    $CpGATparameter ="";
    
    if(($CpGAT_Status == "Yes" ||$Update_Data_CpGAT != "" ) && $CpGAT_ReferenceProt_File !=""){ # Only allow run if reference protein file is defined too.
    
    ###FOR DEBUG ONLY####
    $CpGATparameter =" -refprotdb $CpGAT_ReferenceProt_File";
    
    if($RepeatMask_File != ""){
      $RepDBFile = $RepeatMask_File;
      $CpGATparameter .= " -repdb $RepDBFile";
    }
    if($CpGAT_Relax_UniRef == "Yes"){
      $CpGATparameter .= " -relax T";
    }
    
    if($CpGAT_Skip_Mask == "Yes"){
      $CpGATparameter .= " -nomask T";
    }
    if($CpGAT_Skip_PASA == "Yes"){
     $CpGATparameter .= " -nopasa T";
    }
    if($CpGAT_BGF != "Skip"){
      $bgf = $CpGAT_BGF;
     $CpGATparameter .= " -bgf $bgf";
    }
    if($CpGAT_Augustus != "Skip"){
      $augustus = $CpGAT_Augustus;
     $CpGATparameter .= " -augustus $augustus";
    }
    if($CpGAT_GeneMark != "Skip"){
      $genemark = $CpGAT_GeneMark;
     $CpGATparameter .= " -genemark $genemark";
    }
    $CpGATparameter .=" -noblast T "; # Default since we already have spliced aligments.

} // end read values from MySQL

## Clear Values on this form

$post_action=isset($_POST['action'])?$_POST['action']:"";

if($post_action == 'Clear') // Clear values and reset to defaults for display on form. Typically from EDIT mode.
{
    $ID=intval($_POST['id']);  #posted value.
    $DBid = 'GDB'.substr(('00'. $id),-3); #calculated from unique ID	
    $DBname="";
    $Organism="";
    $Common_Name="";
    $Create_Date="";
    $Config_Date="";
    $Input_Data_Path="/xGDBvm/data/"; # CURRENT DEFAULT 
    $Status='Development'; # CURRENT DEFAULT
    $Genome_Type="Scaffold"; # CURRENT DEFAULT
    $Genome_Source="";
    $Genome_Source_Link="";
    $Genome_Comments="";
    $Genome_Version="";
    $Genome_Count="NULL";
    $Chromosome_Count="NULL";
    $Unlinked_Chromosome_Count="NULL";
    $Scaffold_Count="NULL";
    $BAC_Count="NULL";
    $GeneModel_Version="";
    $GeneModel_Source="";
    $GeneModel_Link="";
    $GeneModel_Comments="";
    $EST_Align_sp="";
    $EST_Align_Version="";
    $EST_Align_Comments="";
    $cDNA_Align_sp="";
    $cDNA_Align_Version="";
    $cDNA_Align_Comments="";
    $PUT_Align_sp="";
    $PUT_Align_Version="";
    $PUT_Align_Comments="";
    $Prot_Align_sp="";
    $Prot_Align_Commentstext="";
    $Prot_Align_Version="";
    $Default_GSEG="";
    $Default_lpos="";
    $Default_rpos="";
    $yrGATE_Reference="Precomputed"; # CURRENT DEFAULT
    $yrGATE_Admin_Email="";
    $GFF_Type="";
    $Update_Status="No"; # CURRENT DEFAULT
    $Update_Data_Path="/xGDBvm/data/"; # CURRENT DEFAULT
    $Update_Data_EST="";
    $Update_Data_cDNA="";
    $Update_Data_TrAssembly="";
    $Update_Data_Protein="";
    $Update_Data_GSEG="";
    $Update_Data_GeneModel="";
    $Update_Data_CpGATModel="";
    $Update_Descriptions="";
    $Update_Date="";
    $Species_Model="Arabidopsis"; # CURRENT DEFAULT
    $Alignment_Stringency="Strict"; # CURRENT DEFAULT
    $Update_Comments="";
    $Update_History="";
    $CpGAT_Status="";
    $CpGAT_ReferenceProt_File="/xGDBvm/examples/referenceprotein/cegma_core.fa"; # CURRENT DEFAULT
    $RepeatMask_File="/xGDBvm/examples/repeatLib/mips_REdat_4.3_rptmsk.lib"; # CURRENT DEFAULT
    $CpGAT_BGF="";
    $CpGAT_Augustus="";
    $CpGAT_GeneMark="";
    $CpGAT_Skip_Mask="";
    $CpGAT_Relax_UniRef="";
    $CpGAT_Skip_PASA="";
    $CpGAT_Filter_Genes="";
    $Update_Data_CpGAT="";
    $Gth_Species_Model="arabidopsis"; # CURRENT DEFAULT
    $Archive_Date="";
    $Archive_File="";
    $Restore_Date="";
    $Restore_From_File="";
    $RepeatMask_Status="No"; # CURRENT DEFAULT
    $GSQ_CompResources="Local"; # =Local; CURRENT DEFAULT
    $GSQ_Job_EST="";
    $GSQ_Job_EST_Result="";
    $GSQ_Job_cDNA="";
    $GSQ_Job_cDNA_Result="";
    $GSQ_Job_PUT="";
    $GSQ_Job_PUT_Result="";
    $GTH_CompResources="Local"; # =Local; CURRENT DEFAULT
    $GTH_Job="";
    $GTH_Job_Result="";
    $Archive_All_Date="";
    $Restore_All_Date="";
    $Create_History="";

    #see also 'get sequence count' conditional for clear
    
} 


####Display modifications########

    $display_development=($Status == "Development")?"":"display_off";
    
  # don't show GDB "Create GDB' button when Remote Compute job flag, but user is not logged in.
	$conditional_loggedin = ($access_token=="" && ($GSQ_CompResources == "Remote" || $GTH_CompResources == "Remote"))?'display_off':"";

  # check "Locked" status and alter page display accordingly: don't show Edit button or create/drop buttons
  		$status_font_display='standard';
		if($Status == "Locked"){
			$locked="display_off"; # elements designed to be hidden when locked record beinv viewed
	#		$abort="display_off";
			$create = 'display_off';
			$drop = 'display_off';
			$status_font_display="xgdb_locked"; # show greyed out fonts
			$required='';
			}

		if($Status == "Development" || $Status == "Current")
		{
 		$abort="display_off";
		}
		
		$conditional_current_locked = ($Status == "Current" || $Status == "Locked")?"":"display_off";

		if($Status == "Development")
		{
 		$status_font_display="Development"; #legend font color different
 		$top_list_hide=""; #validated file list at top of form) show
		$conditional_edit_current="display_off"; #dialog displays only when Status=Current
		}
		if($Status == "Current")
		{
 		$status_font_display="Current"; #legend font color different
 		$top_list_hide="display_off"; #validated file list at top of form) hide
		$display_load_archive="display_off"; #don't show list of ArchiveGDB datasets.
		}
		if($Status == "Current" && $Update_Status == "Yes")
		{
 		$status_font_display="Update"; #legend font color yellow
		}
		
   # hide table rows that don't have any data associated with them using css class.
		$display_archive = ($Archive_Date != "")? "":"display_off";
		$display_restore = ($Restore_Date != "")? "":"display_off";
		$display_restore_gdb = ($Restore_Source != "")? "":"display_off"; 
		$display_archive_all = ($Archive_All_Date != "")? "":"display_off";
		$display_restore_all = ($Restore_All_Date != "")? "":"display_off";
		$display_progress = ($Status == "Current" || $Status == "Locked")? "":"display_off"; #pipeline progress show/hide under "Status"; JPD 9-5-12
		
}

### Get remote job Authorization URL

	$auth_url=get_auth_url("Admin"); // login_functions.inc.php

### Get remote GeneSeqer job configuration data
	
	$gsq_info=get_remote_config("Admin", "GeneSeqer-MPI");// login_functions.inc.php: returns ($app_description, $app_id, $job_time, $node_count)
	$gsq_platform=$gsq_info[0];
	$gsq_app_id=$gsq_info[1];
	$gsq_job_time=$gsq_info[2];
	$gsq_node_count=$gsq_info[3];

	$gsq_message=($gsq_app_id=="")?"<span class=\"warning indent2\">No GSQ App ID has been configured <a href=\"/XGDB/jobs/configure.php\">(go do it)</a> </span>":"<span class=\"checked indent2\">GSQ App ID: </span> $gsq_app_id";

### don't show GSQ "Remote" config radio button if URL not configured

	$gsq_app_id_config=($gsq_app_id=="" || $auth_url=="")?"display_off":"";
	
### Get remote GenomeThreader job configuration data

	$gth_info=get_remote_config("Admin", "GenomeThreader");// login_functions.inc.php
	$gth_platform=$gth_info[0];
	$gth_app_id=$gth_info[1];
	$gth_job_time=$gth_info[2];
	$gth_node_count=$gth_info[3];

	$gth_message=($gth_app_id=="")?"<span class=\"warning indent2\">No GTH App ID has been configured <a href=\"/XGDB/jobs/configure.php\">(go do it)</a> </span>":"<span class=\"checked indent2\">GTH App ID: </span> $gth_app_id";

### don't show GTH "Remote" config radio button if App ID not configured
	$gth_app_id_config=($gth_app_id=="" || $auth_url=="")?"display_off":"";

#### Validate presence of GTH Key (required for remote GTH) ###

$validate_gth=validate_dir($KEY_SOURCE_DIR, $GENOMETHREADER_KEY, "GenomeThreader License Key", "present", "missing");
$gth_license=$validate_gth[0]; $gth_license_class=$validate_gth[1];
$gth_license_message="<span class=\"$gth_license_class\">GTH license ${gth_license}:</span> ${KEY_SOURCE_DIR}${GENOMETHREADER_KEY} <img id='jobs_gth_license' title='GenomeThreader License - Help' class='help-button nudge3 smallerfont' src='/XGDB/images/help-icon.png' alt='?' />";


### Capture alerts and display them under Data Process Options button

	$alert="";
	
	$get_result=isset($_GET['result'])?$_GET['result']:"";
	
if($get_result=='created' && $Status=='Locked'){
	$alert = '&nbsp; Pipeline initiated ';
	}
if($get_result=='updated' && $Status=='Locked'){ 
	$alert = '&nbsp; Database update initiated ';
	}
if($get_result=='validated' && $Status=='Locked'){ 
	$alert = '&nbsp; Validating input files ';
	}
if($get_result=='aborted' && $Status=='Development'){ 
	$alert = '&nbsp; Pipeline aborted ';
	}
if($get_result=='dropped' && $Status=='Development'){ 
	$alert = '&nbsp; Database dropped ';
	}
if($get_result=='validated' && $Status=='Development'){ 
	$alert = '&nbsp; Validated Inputs ';
	}	
############ Check for presence of key directories #############

#these are checked in conf_functions.inc.php.

$i_exists =input_directory($Input_Data_Path, $inputDir); # updated 1-28-16

$o_exists =output_directory($DBid, $dataDir); # updated 1-28-16

$g_exists = gdb_directory($DBid, $dataDir);

$a_exists = archive_directory($DBid, $dataDir); # updated 1-28-16; archive exists for this GDB

$aa_exists = archiveall_directory($dataDir); # updated 1-28-16



################# If DB already exists, build links and get sequence count from EST, cDNA, GSEG, yrGATE tables########

	$GDB_exists = ""; //default no genome database



if($g_exists=="Yes" && mysql_select_db("$DBid")){ #xGDB MySQL database exists.

	$GDB_exists = "Yes";

	$homepage_link = ($Status=="Current")? "<a style=\"margin-left: -22px\" title=\"View/Edit this record\" href=\"/XGDB/phplib/index.php?GDB=${DBid}\"><img alt=\"home\" src=\"/XGDB/images/DNA.png\" /></a>":""; 

######### Read Pipeline Error file and format ##########

 $pipeline_errors= read_pipeline_progress($DBid, $dataDir, "Pipeline_error.log", "F"); // 
 $pipeline_errors_formatted = read_pipeline_progress($DBid, $dataDir, "Pipeline_error.log", "T"); // 
 $clear_button=(file_exists("/xGDBvm/data/${DBid}/logs/Pipeline_error.log"))?
"
<form method=\"post\" action=\"/XGDB/conf/errors_exec.php\" class=\"styled topmargin1\">
    <input type=\"hidden\" name=\"action\" value=\"clear\" />
    <input type=\"hidden\" name=\"id\" value=\"$id\" />
    <input type=\"hidden\" name=\"valid\" value=\"$valid_post\" />
    <input type=\"hidden\" name=\"redirect\" value=\"view\" />
<span class=\"\">
    <input style=\"width:200px\" id=\"clear_errors\" class=\"  submit\"  type=\"submit\" value=\"Clear Errors\" onclick=\"return confirm('Really clear this file's contents?')\" />
</span>
</form>
":""
;
# don't show error div if none exist or this is being restored from an archive.
 $pipeline_errors_display= ($pipeline_errors=="" || !empty($Restore_From_File))?"":"
<div class=\"showhide\">
    <p class=\" label bold\" style=\"cursor:pointer\" title=\"Show pipeline errors\">
        <span class=\"normalfont\" style=\"color: red\">Pipeline warnings/errors: </span><span class=\"heading normalfont\">(click for details)</span></p>
    <div class=\" hidden error\" style=\"display: none;\">
    <span class=\"normalfont\">$pipeline_errors_formatted </span>
        <div>
            $clear_button
        </div>
    </div>
</div>
";


######### Build links -- Current or Locked DB

  ## only show DB link if database exists and is "Current".
  
	$getGSEG_Region=  ($Status=="Current")? "getGSEG_Region.pl?gseg_gi=".$Default_GSEG."&amp;bac_lpos=".$Default_lpos."&amp;bac_rpos=".$Default_rpos:"";

 	$CpGAT_Data_Out=  ($Status=="Current")?"/xGDBvm/data/GDB005/data/CpGAT/":"";
 	
###### Create "Update" Valid List ######

	$arrayUpdateList = create_file_list($Update_Data_Path, "dir", $Update_Data_Path, "Update", "1", $dbpass); //create validated, formatted update file list based on path - conf_functions.inc.php
	$validUpdateList = $arrayUpdateList[0];
	$validUpdateCount = $arrayUpdateList[1];


######## Create Update Results List ###########

 $update_result_array= update_results($Update_Data_GSEG, $Update_Data_EST, $Update_Data_cDNA, $Update_Data_TrAssembly, $Update_Data_Protein, $Update_Descriptions, $Update_Data_GeneModel, $Update_Data_CpGATModel, $Update_Data_CpGAT); // list of update actions from xGDB_Log
 $update_results=$update_result_array[0];
 $update_action_count=$update_result_array[1];
 $update_results_display= ($update_results=="")?"":"<div class=\"showhide\">
							<p class=\" label bold\" style=\"cursor:pointer\" title=\"Show input results\">
									<span class=\"normalfont\" style=\"font-weight:normal\">Expected Output: </span><span class=\"normalfont\" style=\"color: #00EDCD\"> $update_action_count update actions: <span class=\"heading normalfont\">(click for details)</span></p>
							<div class=\" hidden results\" style=\"display: none;\">
								<ul class=\"menulist bottommargin1\" id=\"update_results\">
								$update_results
								</ul>
								<span class=\"heading\">Not what you expected? Check that all filenames are correct according to <a href=\"/XGDB/conf/data.php#filename_requirements\">Filename Requirements</a></span>
							</div>
						</div>
						";
						
### Display pipeline progress with link to log file.

	$progress_display= ($Status =='Locked' || $Status =='Current' )? "<a id=\"Pipeline_procedure\" title=\"$DBid\" class=\"logfile-button\" src=\"/XGDB/images/help-icon.png\" alt=\"?\" />logfile</a>":"";

### Create Feature Totals String (Current only)  to include in $curr_msg
  $feature_totals_string =($Status=="Current")? get_feature_totals($DBid):""; // conf_functions.inc.php

    ######### modes and messages for GDB ########
    
	$archived_message = ($Status == "Current" && $Archive_Date != "")?" &#124; <span class=\"$display_if_archive_copied\"></span><a title=\"$Archive_File (click to view/download)\" href=\"/XGDB/phplib/download.php?GDB=$DBid&dir=Archive\">Archived </a><img alt='archive' src='/XGDB/images/archive.png' title='Archived Date:".$Archive_Date."' />":"";
	$create ="display_off"; #button mode - don't show create/drop action buttons
	$locked_msg=" 
		<span class=\"instruction\">Processing data.
	    <button class=\"submit refresh bold\" style=\"color:darkmagenta; cursor:pointer; font-size:13px; height:25px\">Click to refresh page.</button>
		To abort, click 'Data Process Options' 
		&#124; <a href=\"/XGDB/conf/viewall.php?id=$ID\"> View as table</a> </span>"; #synchronize with $locked_msg under 'Development' status
	$dev_msg ="The database exists but is Development status. There may be a problem";
	$offline_msg = "Database exists but Offline status. Click 'Edit' to return to Current status.";
	
	### For current GDB, no message just a series of links.
	$curr_msg = $archived_message."&#124; <a title=\"View GDB information in tabular format\" href='/XGDB/conf/viewall.php?id=$ID'> View as table <img class=\"nudge2\" alt=\"\" src=\"/XGDB/images/viewall_conf.png\" /></a> &#124; 
	<a title=\"View pipeline process log (web page view)\" href='/XGDB/conf/logfile.php?id=$ID'> Logfile<img class=\"nudge2\" alt=\"\" src=\"/XGDB/images/logfile-icon.png\" /></a> &#124; 
	<span class=\"$conditional_jobs\"><a class=\"normalfont\" title=\"View remote job list\" href=\"/XGDB/jobs/jobs.php\"> Remote Job <img alt='home' src='/XGDB/images/remote_compute.png' /></a> &#124;</span>
	<a class=\"normalfont\" title=\"$DBid home page\" href=\"/XGDB/phplib/index.php?GDB=${DBid}\">GDB Home <img alt='home' src='/XGDB/images/home_go.png' /></a> &#124;
	<a class=\"normalfont\" title=\"View sample region in genome context\" href=\"/$DBid/cgi-bin/$getGSEG_Region\">GDB Region <img alt='home' src='/XGDB/images/contextview.gif' /></a> &#124;
	<a class=\"normalfont\" title=\"Download output data for this GDB\" href=\"/XGDB/phplib/download.php?GDB=${DBid}&amp;dir=download\"> Download <img alt='home' src='/XGDB/images/download.gif' /></a> &#124;
	 	 <img id='config_current_nav' title='Navigate to GDB. Click ? for details.' class='help-button nudge1' src='/XGDB/images/help-icon.png' alt='?' />
	"
	;
   
   #### Determine which database_message (see above) will appear next to the STATUS display. Message depends on Status.
   
	$database_message = ($Status == "Locked")? $locked_msg : (($Status == "Development") ? $dev_msg : (($Status == "Offline") ? $offline_msg : $curr_msg)); # little message text.
	$Current_option="<option>Current</option>"; #for status dropdown, allow this value.
	$Offline_option="<option>Offline</option>"; #for status dropdown, allow this value.
    $display_current_only=""; // don't add class to hide this element
    
	##### GSEG Queries #####
	
		 if($get_gseg_tot="SELECT count(*) FROM {$DBid}.gseg"){ 
		 $mysql_get_gseg_tot= mysql_query($get_gseg_tot); // get count of GSEG
		while($data_get_gseg_tot = mysql_fetch_array($mysql_get_gseg_tot)){
			$gseg_total=$data_get_gseg_tot[0];
			}
		}

		 if($get_anno_gseg_tot="SELECT count(distinct gseg_gi) FROM {$DBid}.gseg_gene_annotation"){ 
		 $mysql_get_anno_gseg_tot= mysql_query($get_anno_gseg_tot); // get number of annotated gseg
		while($data_get_anno_gseg_tot = mysql_fetch_array($mysql_get_anno_gseg_tot)){
			$anno_gseg_total=$data_get_anno_gseg_tot[0];
			}
		}


	##### EST Queries #####
	
		 if($get_est_tot="SELECT count(*) FROM {$DBid}.est"){
		 $mysql_get_est_tot= mysql_query($get_est_tot); // get all EST
		while($data_get_est_tot = mysql_fetch_array($mysql_get_est_tot)){
			$est_total=$data_get_est_tot[0];
			}
		}
		 if($get_est_algn= "SELECT count(*) FROM {$DBid}.gseg_est_good_pgs"){ // get aligned EST
		 $mysql_get_est_algn= mysql_query($get_est_algn);
		while($data_get_est_algn = mysql_fetch_array($mysql_get_est_algn)){
			$est_algn_total=$data_get_est_algn[0];
			}
		}

		 if($mysql_get_est_cog= mysql_query("SELECT count(*) FROM {$DBid}.gseg_est_good_pgs where isCognate='True' ")){ // get cognate EST
		while($data_get_est_cog = mysql_fetch_array($mysql_get_est_cog)){
			$est_cog_total=$data_get_est_cog[0];
			}
		}
		 if($mysql_get_est_non= mysql_query("SELECT count(*) FROM {$DBid}.gseg_est_good_pgs where isCognate='False'")){ // get noncognate EST
		while($data_get_est_non = mysql_fetch_array($mysql_get_est_non)){
			$est_non_total=$data_get_est_non[0];
			}
		}
		
	##### cDNA Queries #####
	
		 if($get_cdna_tot="SELECT count(*) FROM {$DBid}.cdna"){
		 $mysql_get_cdna_tot= mysql_query($get_cdna_tot); // get all cdna
		while($data_get_cdna_tot = mysql_fetch_array($mysql_get_cdna_tot)){
			$cdna_total=$data_get_cdna_tot[0];
			}
		}
		 if($get_cdna_algn= "SELECT count(*) FROM {$DBid}.gseg_cdna_good_pgs"){ // get aligned EST
		 $mysql_get_cdna_algn= mysql_query($get_cdna_algn);
		while($data_get_cdna_algn = mysql_fetch_array($mysql_get_cdna_algn)){
			$cdna_algn_total=$data_get_cdna_algn[0];
			}
		}

		 if($mysql_get_cdna_cog= mysql_query("SELECT count(*) FROM {$DBid}.gseg_cdna_good_pgs where isCognate='True' ")){ // get cognate EST
		while($data_get_cdna_cog = mysql_fetch_array($mysql_get_cdna_cog)){
			$cdna_cog_total=$data_get_cdna_cog[0];
			}
		}
		 if($mysql_get_cdna_non= mysql_query("SELECT count(*) FROM {$DBid}.gseg_cdna_good_pgs where isCognate='False'")){ // get noncognate EST
		while($data_get_cdna_non = mysql_fetch_array($mysql_get_cdna_non)){
			$cdna_non_total=$data_get_cdna_non[0];
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

		 if($mysql_get_prot= mysql_query("SELECT count(*) FROM {$DBid}.pep")){ // get 1st species total pep
		while($data_get_prot = mysql_fetch_array($mysql_get_prot)){
			$prot_total=$data_get_prot[0];
			}
		}
		
		 if($mysql_get_prot_align= mysql_query("SELECT count(*) FROM {$DBid}.gseg_pep_good_pgs")){ // get 1st species total aligned
		while($data_get_prot_align = mysql_fetch_array($mysql_get_prot_align)){
			$prot_align_total=$data_get_prot_align[0];
			}
		}

    ##### Get Annotation, Locus Count ####
        
		 $mysql_get_gene_annno= mysql_query("SELECT count(*) FROM $DBid.gseg_gene_annotation");
		while($data_get_gene_annno = mysql_fetch_array($mysql_get_gene_annno)){
			$gene_anno_total=$data_get_gene_annno[0];
		}

		if($mysql_get_gene_loci= mysql_query("SELECT count(distinct locus_id) FROM $DBid.gseg_gene_annotation")){
			while($data_get_gene_loci = mysql_fetch_array($mysql_get_gene_loci)){
					$gene_loci_total=$data_get_gene_loci[0];
					}
				}else{
			$gene_loci_total=$gene_anno_total;
		}

    ##### Get CpGAT Annotation, Locus Count ####
        
		 $mysql_get_cpgat_gene_annno= mysql_query("SELECT count(*) FROM $DBid.gseg_cpgat_gene_annotation");
		while($data_get_cpgat_gene_annno = mysql_fetch_array($mysql_get_cpgat_gene_annno)){
			$cpgat_gene_anno_total=$data_get_cpgat_gene_annno[0];
		}

		if($mysql_get_cpgat_gene_loci= mysql_query("SELECT count(distinct locus_id) FROM $DBid.gseg_cpgat_gene_annotation")){
			while($data_get_cpgat_gene_loci = mysql_fetch_array($mysql_get_cpgat_gene_loci)){
					$cpgat_gene_loci_total=$data_get_cpgat_gene_loci[0];
					}
				}else{
			$cpgat_gene_loci_total=$_cpgat_gene_anno_total;
		}
		
	##### Get yrGATE  Count ####
        
		$mysql_get_yrgate= mysql_query("SELECT count(*) FROM $DBid.user_gene_annotation WHERE Status='ACCEPTED'"); // get current yrgate count for this organism and version
		while($data_get_yrgate = mysql_fetch_array($mysql_get_yrgate)){
			$yrgate_total=$data_get_yrgate[0];
		}

    #### build or reconstruct a list of validated input files for a "Current" GDB

$arrayList = create_file_list($Create_History, "list", $Input_Data_Path, "Input (Historical)", "2", $dbpass); //recreate validated, formatted file list based on stored list - conf_functions.inc.php
$validList=$arrayList[0]; //basically a formatted "snapshot" of the input directory file contents. 

$validRefPro = $CpGAT_ReferenceProt_File; //We don't store validated file other than user input. It is by definition validated or the process would not have run!


}elseif  #xGDB MySQL database exists but the /INSTANCE/GDBnnn is missing
		(
		$g_exists!="Yes" && // no GDB INSTANCE directory
		mysql_select_db("$DBid") // GDB database is present
		)
	{ 
		$database_message="<span class=\"alertnotice largerfont\">Warning: A MySQL database exists for $DBid but <pre>/${XGDB_DATADIR}${DBid}/</pre> is missing. </span>";
		$create="display_off"; // disable create button

#### End GDB Exists ####
	}else{

############ GDB Database Not Yet Created (Status='Development').#############

	$archive_dirlist=archive_dir_dropdown($dataDir, "ArchiveGDB"); #this is a list of any ArchiveGDB datasets that are available. Updated 1-28-16 to include dataDir param.
	$display_load_archive=($archive_dirlist=="")?"display_off":"$display_load_archive"; #don't display the dropdown if there are no archives.
	$archive_dirlist_display=($archive_dirlist=="")?"<option value=\"none\">-none-</option>":$archive_dirlist;
	
######### Validate user-proposed Input Data Path files (note - these functions are also called elsewhere in this script for "Current" GDB. ######

$arrayList = create_file_list($Input_Data_Path, "dir", $Input_Data_Path, "Input Directory", "2", $dbpass); //create validated, formatted file list based on dir path - conf_functions.inc.php
$validList = $arrayList[0]; //formatted
$validCount = $arrayList[1];
$validSize= $arrayList[2]; # total bytes from valid files
$validGB= round($validSize/1000000000, 3); 
$validRefPro = ($CpGAT_Status=="Yes")?validate_library($CpGAT_ReferenceProt_File, "Reference Protein Library", $dbpass):""; //from conf_functions.inc.php
$validRepMask = ($RepeatMask_Status=="Yes")?validate_library($RepeatMask_File, "Repeat Mask Library", $dbpass):""; //from conf_functions.inc.php

$file_codes=$arrayList[4]; #single-letter code string
$input_errors=input_errors($file_codes);
$input_warnings=input_warnings($Input_Data_Path);

######## Display Input Results ###########

 $input_results_array= input_results($file_codes, $CpGAT_Status, $RepeatMask_Status, $GSQ_CompResources, $GTH_CompResources); // list of expected results based on one-letter code of input files (see conf_functions.inc.php)
 $input_results=$input_results_array[0];
 $tracks=$input_results_array[1];
 $remote_flag=$input_results_array[2];
 $input_results_display= ($input_results=="")?"":"<div class=\"showhide\">
							<p class=\" label bold\" style=\"cursor:pointer\" title=\"Show input results\">
								<span class=\"normalfont\" style=\"font-weight:normal\">
									Expected Ouput: 
								</span>
								<span class=\"normalfont\" style=\"color: orange\"> 
								    $tracks tracks based on input files: 
								    <span class=\"heading normalfont\">
								        (click for details)
								    </span>
								</span>
							</p>
							<div class=\" hidden results\" style=\"display: none;\">
								<ul class=\"menulist bottommargin1\" id=\"input_results_1\">
								$input_results
								</ul>
								<span class=\"heading\">Not what you expected? Check that all filenames are correct according to <a href=\"/XGDB/conf/data.php#filename_requirements\">Filename Requirements</a></span>
							</div>
						</div>
						";

######## Display Input Errors and warnings ###########
 # $input_warnings="<li> this is a test</li>";
 $input_errors= input_errors($file_codes); // list of any input file errors based on one-letter code of input files (see conf_functions.inc.php)
 $input_errors_display= (($input_errors=="" && $input_warnings=="") || !empty($Restore_From_File))?"":"<div class=\"showhide\">
							<p class=\" label bold\" style=\"cursor:pointer\" title=\"Show input errors\">
									<span class=\"normalfont\" style=\"color: red\">Input File Errors Exist: <span class=\"heading normalfont\">(click for details)</span></p>
							<div class=\" hidden error\" style=\"display: none;\">
								<ul class=\"menulist bottommargin1\" id=\"input_errors\">
								$input_warnings
								$input_errors
								</ul>
								<span class=\"heading\">See <a href=\"/XGDB/conf/data.php#filename_requirements\">Filename Requirements</a> for more information</span>
							</div>
						</div>
						";
############# retrieve disk space data for display ###########
	$validGB_display=$validGB*10; // safety factor threshold

	$path1="/xGDBvm/";
	$df_array1=df_available($path1);
	$filesys1=$df_array1[0];
	$available1=$df_array1[1];
	$gb1=round($available1/1000000, 1);
	$gb1_display =($gb1 <= 0.1)?"<span class=\"warning\">$gb1</span>":"<span class=\"checked\">$gb1</span>";
	$gb1_details =($gb1 <= 0.1)?"<span class=\"warning\">$gb1 GB</span> may not be sufficient!":"<span class=\"checked\">$gb1 GB</span> is sufficient";
	
	$path2="/xGDBvm/data/";
	$df_array2=df_available($path2);
	$filesys2=$df_array2[0];
	$available2=$df_array2[1];
	$gb2=round($available2/1000000, 1);
	$gb2_display =($gb2 <= $validGB_display)?"<span class=\"warning\">$gb2</span>":"<span class=\"checked\">$gb2</span>";

	$path3="/xGDBvm/data/scratch/";
	$df_array3=df_available($path3);
	$filesys3=$df_array3[0];
	$available3=$df_array3[1];
	$gb3=round($available3/1000000, 1);
	$gb3_display =($gb3 <= $validGB_display)?"<span class=\"warning\">$gb3</span>":"<span class=\"checked\">$gb3</span>";


	$path4="/xGDBvm/data/mysql/";
	$df_array4=df_available($path4);
	$filesys4=$df_array4[0];
	$available4=$df_array4[1];
	$gb4=round($available4/1000000, 1);
	
	$gb4_display =($gb4 <= $validGB_display)?"<span class=\"warning\">$gb4</span>":"<span class=\"checked\">$gb4</span>";
	
#############  Login Section for Remote HPC ###############

### show or hide login/logout/refresh blocks depending on token status ###
$conditional_display_logged_out=($access_token=="")?"":"display_off"; # display 'logged out' message only if user is logged out (no access token)
$conditional_display_login=($access_token=="" && $refresh_token=="")?"":"display_off"; # display 'login' option only if user is logged out (no access token) and no refresh token is present
$conditional_display_logout=($access_token!="")?"":"display_off"; # display login details and 'logout' option only if user is logged in.
$conditional_display_refresh=($refresh_token!="")?"":"display_off"; # display 'refresh' option only if refresh_token is present


if($GSQ_CompResources=="Remote" || $GTH_CompResources=="Remote")



//Login Display and Login
		{
			$logged_in=""; // the grey box at top of form showing logged in user
			$auth_url = get_auth_url("Admin"); //login_functions.inc.php
/*/debug: 
		$id=$_SESSION['id'];
		$usersession=$_SESSION['username'];
		$userpost=$_POST['username'];
		$access_token_session=$_SESSION['access_token'];
		$http_code_session=$_SESSION['http_code'];
		$posted_action=$_POST['action']; //now posted to login.php; should be blank.
#		$timeout=$_SESSION['timeout'];
		$time=time();
		$timeU=date("U");
		echo "id=$id; login-msg=$login_msg; http_code=$http_code_session; username=$username; auth_url=$auth_url; user-session=$usersession; user-post=$userpost; token= $access_token; token-session=$tokensession; posted_action=$action; now=$now; expires-session=$expires; lifespan-session =$lifespan; issued-session=$issued; timeU=$timeU; ";
// end debug */

		$login_redirect=($refresh_token=="")?
		"<div style=\"background: #CCC; border: 2px solid yellow\" width=\"93%\" >
        <p style=\"padding:2px\"><a  href=\"/XGDB/jobs/login.php?id=$ID&#login\">Go to login page</a></p>		
		</div>"
		:
		"<div style=\"background: #CCC; border: 2px solid #888\" >
        <span class=\"smallerfont $conditional_display_refresh\">
            <form action=\"/XGDB/jobs/login_exec.php\" method=\"post\">
                <input type=\"hidden\" name=\"action\" value=\"refresh\" />
                <input type=\"hidden\" name=\"redirect\" value=\"view\" />
                <input type=\"hidden\" name=\"id\" value=\"$id\" />
                <input type=\"submit\" name=\"refresh\" value=\" refresh\">
            </form>
        </span>
		</div>"
		;




//Determine login status and display appropriate text/form.

		if(!$auth_url || ((!$gsq_app_id && $GSQ_CompResources=="Remote") || (!$gth_app_id && $GTH_CompResources=="Remote"))) // URL configuration incomplete
			{
			$login_msg = "<span id=\"remote_config_error\" class=\"warning\"> You have selected <b>Remote</b> resources but configuration is incomplete <a href=\"/XGDB/jobs/apps.php\">(check it)</a>";
			}
		elseif($access_token=="") //user hasn't logged in. Show login.
			{
			$login_msg= "<td><span class=\"warning  normalfont\" id=\"login_required\">Authorization required for access to HPC.  </span></td><td>".$login_redirect."</td>";
			$logged_in="";
			}
		elseif($_SESSION['http_code']=="0") //user hasn't configured auth URL. Show link.
			{
			$login_msg= "<span id=\"auth_error\" class=\"warning\">It appears the authorization URL is not correctly configured. <a href=\"/XGDB/jobs/configure.php#auth\">(check it)</a></span>"; //login_functions.inc.php  - displays login form which POSTs action=authenticate to login.php which then redirects back here.
			$logged_in="";
			}
		elseif($_SESSION['http_code']=="401") // unauthorized - wrong username or pw. Show login again.
			{
			$login_msg= "<td><span class=\"warning normalfont\" id=\"login_fail\" >Login Failed. Try Again. </span></td><td>".$login_redirect."</td>";
			$logged_in="";
			}
#		elseif($username!="" && $access_token!="") // user has successfully logged in
		elseif($_SESSION['http_code']=="200") // user has successfully logged in. Let them know how much time left they have
			{
			$time_left=$expires-date("U");
			$time_left=seconds_to_time($time_left);//login_functions.inc.php; calculates d-h-m-s from seconds
			$time_left=$time_left['time'];
			
			$login_msg=
        	 "
            <table width=\"100%\">
                <colgroup>
                    <col width =\"90%\" style=\"background-color: #EEE\"  />
                    <col width =\"10%\"/>
                </colgroup>
                <tr>
					<td style=\"padding:10px; border: 2px solid yellow\"> <span class=\"status_box\"> 
						<span class=\"checked smallerfont\">\"$username\" </span> <span class=\"smallerfont\"> is authorized to <a title=\"click here to submit standalone HPC jobs\" href=\"/XGDB/jobs/submit.php\">submit jobs </a> 
						(token expires in <span class=\"alertnotice\">$time_left</span>) </span>
						<br />
						<span class=\"smallerfont\">$gsq_message</span><br />
						<span class=\"smallerfont\">$gth_message</span><br />
						<span class=\"smallerfont\">$gth_present_message</span>
						</span>
					</td>
					<td style=\"padding:10px; border: 2px solid yellow\">
						<span class=\"smallerfont $conditional_display_refresh\">
						    <form action=\"/XGDB/jobs/login_exec.php\" method=\"post\">
						        <input type=\"hidden\" name=\"action\" value=\"refresh\" />
						        <input type=\"hidden\" name=\"redirect\" value=\"view\" />
						        <input type=\"hidden\" name=\"id\" value=\"$id\" />
                                <input type=\"submit\" name=\"refresh\" value=\" refresh\">
                            </form>
                            
                        </span>
						<span class=\"smallerfont\">
						    <form action=\"/XGDB/jobs/logout_exec.php\" method=\"post\">
						        <input type=\"hidden\" name=\"msg\" value=\"logout\" />
						        <input type=\"hidden\" name=\"redirect\" value=\"view\" />
						        <input type=\"hidden\" name=\"id\" value=\"$id\" />
                                <input type=\"submit\" name=\"logout\" value=\" log out\">
                            </form>
                        </span>
                        <span  class=\"$conditional_display_login normalfont nowrap\">
                            <a style=\"text-decoration: none\" href=\"/XGDB/jobs/login.php#login\"> &nbsp; log in</a>
                        </span>
					</td>
				</tr>
			</table>
			";
			
			/* $login_msg = 
			"<div style=\"border:2px solid yellow; padding:1em; background:#DDD\">
			    <span id=\"logged_in\" class=\"normalfont\">
			        <img class=\"nudge2\" src=\"/XGDB/images/remote_compute.png\" />&nbsp; 
			            <span class=\"checked\">
			                Logged in</span> with <b>Remote Compute Option</b> (token expires in <span class=\"alertnotice\">$time_left</span>).
			                Verify that input data are valid, then click 'Data Process Options' to run pipeline, 
			                or go to <a href=\"/XGDB/jobs/submit.php\">Remote Jobs &rarr; Submit</a> if this is a <b>standalone job.</b>
			            <br />
			            <img class=\"nudge2\" src=\"/XGDB/images/remote_compute.png\" />
			            $gth_present_message
			        </span>";
			$login_msg .=
			  "
			  <div class=\"showhide\">
                    <p class=\" label\" style=\"cursor:pointer\" title=\"Show remote params\">
                            <span class=\"smallerfont\">Remote Job Settings (click for details)</span></p>
                    <div class=\" hidden\" style=\"display: none;\">
                        <table class=\"featuretable\" border=\"0\" style=\"font-size:12px\" width=\"100%\" >
                            <thead>
                                <tr class=\"reverse1\">
                                    <th>
                                        Program
                                    </th>
                                    <th>
                                        Version
                                    </th>
                                    <th>
                                        Job Time
                                    </th>
                                    <th>
                                        Processors
                                    </th>
                            </thead>
                            <tbody>
                                <tr>
                                    <td>GeneSeqer:</td>
                                    <td>$gsq_software</td>
                                    <td>$gsq_job_time </td>
                                    <td>$gsq_proc</td>
                                </tr>
                                <tr>
                                    <td>GenomeThreader:</td>
                                     <td>$gth_software</td>
                                    <td> $gth_job_time</td>
                                    <td>$gth_proc</td>
                                </tr>
                            </tbody>
                        </table>
                        				<a href=\"/XGDB/jobs/configure.php\"><img src=\"/XGDB/images/remote_compute.png\" alt=\"\img\" />Update Remote Settings</a>

				    </div>
				</div>
            </div>
            "
            ;
            */
			}
		}

############# End Login Section ###############

    ###### modes and messages for Development GDB: gdb_msg, locked_msg, user login, etc.
    
    	
	#Other display modifications 
	$drop="display_off"; #button mode - can't drop as it doesn't exist
	$Current_option=""; #for status dropdown, don't allow this value.
	$Offline_option=""; #for status dropdown, don't allow this value.
	$display_current_only="display_off"; #css class - prevent update options fieldset from displaying
	$restore=($Archive_Date=="")?"display_off":""; # don't show restore button unless Archive_Date exists
	$tail_display = ($Status =='Locked')?"display_on":"display_off";
	$restore_msg="
	<span class=\"largerfont $restore\">
		<span class=\"bold\" style=\"color:magenta\">
			Ready to Restore from 
				$Restore_GDB Archive
			<img id='config_restore_ready' title='Edit Help' class='help-button nudge2' src='/XGDB/images/help-icon.png' alt='?' />
		 </span> 
		 To restore, click 
		 <span class=\"heading\">
			 'Data Process Options' &rarr; 'Restore From $Restore_GDB Archive'.
		 </span>
	</span>
	";
    
	if($validCount<2) //Not enough valid input files; or may not be correctly configured for input.
		{
	$create="display_off"; // disable create button
		if($Restore_Other !="T") // Message displayed depends on whether or not user is restoring an archive
			{
			$dev_msg="NOT READY!! Input files are not valid or path is incorrect. <a href=\"#InputDiv\">Go to Input Data</a>";
			}
			else
			{
			$dev_msg.="$restore_msg";
			}
		}
	elseif($GSQ_CompResources=="Remote" || $GTH_CompResources=="Remote")
		{
	$dev_msg=$login_msg; // Set up jobs login scenario. see top of script
		}
 	else  # Data process options mode. All is OK. Display regular message set; optionally display archive message.
		{
	$dev_msg="<span class=\"bold\">Ready to Create $DBid.</span> To proceed, click  <span class=\"heading\">'Data Process Options' &rarr; 'Create New $DBid Database'</span>.";
	$dev_msg.="<br />$restore_msg";
		}
	$locked_msg="Processing data. 
	<button class=\"submit refresh bold\" style=\"color:darkmagenta; cursor:pointer; font-size:13px; height:25px\">Click to refresh page.</button>
    To abort, click 'Data Process Options'.  
		<a href='/XGDB/conf/viewall.php?id=$ID'> View as table </a>
		";
	
	#synchronize with $locked_msg under 'Development' status
	$database_message = ($Status == "Locked")? $locked_msg:$dev_msg;
}
########### End of GDB Database Not Yet Created (Not "Current") ###########$

########### Get list of database names for dropdown selection (View:) ###############

	    mysql_select_db("$global_DB");
		$mysql_get_dbnames= mysql_query("SELECT * FROM $global_DB.xGDB_Log order by DBname"); // get all GDB
		while($data_get_dbnames = mysql_fetch_assoc($mysql_get_dbnames)){
			$dbname_list=$data_get_dbnames['DBname'];
		}
		
		# Generate database list for select statement. see http://www.tech-evangelist.com/2007/11/22/php-select-box/
		$dbname_query = "SELECT ID, DBname FROM $global_DB.xGDB_Log order by ID";
		$rows = mysql_query($dbname_query);
		$db_id="";
		$db="";
		$name="";
		while($row = mysql_fetch_array($rows))
			{
			$db_id=$row['ID'];
			$name=$row['DBname'];
			$db = 'GDB'.substr(('00'. $db_id),-3); #calculated from unique ID										
		  	$db_list .= "<option value=\"".$db_id."\">".$db.": ".$name."</option>\n";
		}

		

}

########## flag any extraneous GDB in /data/ or $XGDB_DATAURL and if so create warning text

$extra_data_msg="";
$extra_data=checkExtra("$dataDir"); //flag any extraneous GDB in data 
if(!empty($extra_data)){
	foreach($extra_data as $data_item){
		$extra_data_list.= "$data_item";
		}
		
	$extra_data_msg= "<div class=\"warningcontainer $warning\"><span class=\"warning normalfont\">Warning! The GDB directory or directories below, found under <a href=\"/data/\">xGDBvm/data/</a>, is not associated with any <span class=\"Current\">Current</span> GDB. Please rename or delete before proceeding:
	&rarr; <a id='config_extra_dir_data' title='Click for more info' class='help-button link'>Click for more information </a> </span>
	<pre class=\"large topmargin1\">
	$extra_data_list
	</pre></div>";
$warning_msg.="$extra_data_msg";
	}



###### (Development mode) Show Restore button in options mode if an archive exists (or the user has configured Restore_From_File), an archive date exists in xGDB_Log and the date is later than any restore date, 

$restore = (($a_exists=="Yes" || !empty($Restore_From_File)) && $Status == "Development" && $options =="display_on" && $Archive_Date != "")?"display_on":"display_off";

##########  Set Data Process Options Mode. $mode is a post variable that is passed when 'Data Process Options' is clicked. Its value is determined by the database value of $Status and whether config data are complete.
########### It determines what button(s) are visible in Data Process Options mode ('Create', 'Update', 'Drop')
########### We are also setting mode_message and model_message_style here.
	$mode="";
## Make sure user only uses "append CpGAT" when "append GSEG" is selected. Prevent user from clicking "update".

global $mode_message,$mode, $mode_message_style;
if($Update_Data_CpGAT=="Append" && $Update_Data_GSEG !="Append" && $Status =="Current" && $Update_Status !="" ){
	$mode="";
	$mode_message=' ERROR: The "Run CpGAT: Append" option is only available with "Genome Segment: Append". <br /><br />'; //
	$mode_message_style="alertnotice";
}
elseif($Status =="Development" && $GDB_exists =="Yes"){ ## Drop option: User chose to Abort GDB while pipeline was running, so it is incomplete
	$mode="Drop";
## Update" Make sure all user options are correct for the Update function, then flag as ready.
}elseif($Status =="Current" && $Update_Status !="" && $Update_Data_Path !="" && ($Update_Data_EST !="" || $Update_Data_cDNA !="" || $Update_Data_TrAssembly !="" || $Update_Data_GSEG !="" || $Update_Data_Protein!="" || $Update_Data_GeneModel !="" || $Update_Data_CpGATModel !="" || $Update_Data_CpGAT !="" || $Update_Descriptions !="")){
	if($validUpdateCount<1) //not enough valid filenames
		{
		$database_message='<span class="warning">NOTE: Update Option selected but filenames invalid or incorrect path. <a href="#UpdateDiv">Jump to Update Options Section</a></span>'; //flag as active
		}
		else
		{
		$mode="Update";
		$mode_message=' Ready to Update'; //flag as active
		$mode_message_style="Update largerfont";
		}

}elseif($Status =="Development" && $DBname !="" && ($CpGAT_Status !="Yes" || $CpGAT_ReferenceProt_File !="")){ #Dev status and CpGAT if "Yes" has RefProt file specified 
	$mode="Create";
	$mode_message='';
}elseif($Status =="Current"){ #Doesn't meet Update criteria so Drop is only option
	$mode="Drop";

}elseif($Status =="Locked"){ #Processing data.
	$mode="Locked";
	$mode_message='';
	$background='locked_bckgd'; #unless user enters Options mode. then it should be orange
}elseif($DBname ==""){ #No database name supplied.
	$mode="Error"; #don't show any database actions, show error message instead
	$mode_message="You forgot to include a <b>Database Name</b>. Click 'Edit Configuration' and enter a name. ";
	$mode_message_style="altertnotice largerfont";
}else {
	$mode="Error"; #don't show any database actions, show error message instead
	$mode_message='There is a problem with this configuration. Check to make sure all required fields are filled out.';
	$mode_message_style="altertnotice largerfont";
}

########

#################  Validate Input Files ##################
#####(note- these functions are also called earlier in this script, where status="Development" ######

######### Logfile display function call ##########

$logfile="Pipeline_procedure"; # default id for jquery ui dialog element, 'Create' mode. Corresponds to logfile in path specified by xGDB_logfile.php
$logfile_path="/xGDBvm/data/".$DBid."/logs/";

if($Process_Type=="validate")
{
$logfile="Validation";
$logfile_path="/xGDBvm/data/scratch/";
}
## Read last 3 lines of logfile in "Locked" mode only:

if ($Status =='Locked'){
	$tail_logfile=tail($DBid, $logfile, $logfile_path); 
 	$tail_line1=$tail_logfile[0];
 	$tail_line2=$tail_logfile[1];
 	}
 	
$tail_display = ($Status =='Locked')?"display_on":"display_off";

######### hide Update parameters unless GDB is Current ########

$conditional_display= ($Status == "Current" || $Update_Status == "Update")? "":"hidden";

######### In Current or Locked Config, hide GSQ, GTH Remote Job ID display text unless 'Remote' chosen ########

$conditional_gsq= ($GSQ_CompResources == "Remote" && $Status!='Development')? "":"display_off";
$conditional_gth= ($GTH_CompResources == "Remote" && $Status!='Development')? "":"display_off";
$conditional_dev=($Status=="Development" || $Update_Status=="Yes")?"":"display_off";

###### Directory Dropdowns and Mounted Volume Flags #######

# data directory:/data/ ($dir1)
$dir1_dropdown="$dataDir"; // 1-26-16
if (file_exists("/xGDBvm/admin/iplant")) { // xGDBvm-iPlant only
    $df_dir1=df_available($dir1_dropdown); // check if /data/ directory is externally mounted (returns array)
    $devloc=str_replace("/","\/",$ext_mount_dir); // read from device location stored in /xGDBvm/admin/devloc via sitedef.php
    $dir1_mount=(preg_match("/$devloc/", $df_dir1[0]))?"<span class=\"checked_mount\">Ext vol mounted</span>":"<span class=\"lightgrayfont\">Ext vol not mounted</span>"; //flag for dir1 mount
}
# data store directory:/input/ ($dir2)
$dir2_dropdown="$inputDir"; // 1-26-16
if (file_exists("/xGDBvm/admin/iplant")) { // xGDBvm-iPlant only
    $df_dir2=df_available($dir2_dropdown); // check if /input/ directory is fuse-mounted (returns array)
 #   $dir2_dropdown=($df_dir2[0]=="fuse"  || $df_dir2[0]=="irodsFs")?"/xGDBvm/input/":""; //only show input dir if fuse-mounted. REMOVED THIS REQUIREMENT 4/16/2014
    $dir2_mount=($df_dir2[0]=="fuse" || $df_dir2[0]=="irodsFs")?"<span class=\"checked_mount\">DataStore mounted</span>":"<span class=\"lightgrayfont\">DataStore not mounted</span>"; //flag for dir1 mount
}
$dir3_dropdown="/xGDBvm/examples/";    // TODO: move to sitedef.php

$input_dirlist=dirlist_dropdown($dir1_dropdown, $dir2_dropdown,  $dir3_dropdown, "$Input_Data_Path");//build dropdown for input dir(s), to include /xGDBvm/input (preferred) or /xGDBvm/data 
#$input_dirlist=dirlist_dropdown("", $dir2_dropdown, $dir3_dropdown, "$Input_Data_Path");// To prevent use of /xGDBvm/data for inputs, uncomment this line and comment out previous.

# display mount status (iPlant only)
$dir1_status=(file_exists("/xGDBvm/admin/iplant"))?"<span class=\"normalfont\" style=\"font-weight:normal\">&nbsp; &nbsp;<a class='help-button' title='Mount status of /xGDBvm/data/' id='config_output_dir_mount'> $dir1_mount </a></span>":"";
$dir2_status=(file_exists("/xGDBvm/admin/iplant"))?"<span class=\"normalfont\" style=\"font-weight:normal\">&nbsp; &nbsp;<a class='help-button' title='Mount status of /xGDBvm/input/' id='config_input_datastore'> $dir2_mount </a></span>":"";

# repeat mask directory and files
$dir4_dropdown="$inputDir/repeatmask/";
$dir5_dropdown="/xGDBvm/examples/repeatmask/";
$repmask_dirlist=filelist_dropdown($dir4_dropdown,  $dir5_dropdown, "$RepeatMask_File");//build dropdown for repeat mask dir(s)

# reference protein directory and files
$dir6_dropdown="$inputDir/referenceprotein/";
$dir7_dropdown="/xGDBvm/examples/referenceprotein/";
$refprot_dirlist=filelist_dropdown($dir6_dropdown,  $dir7_dropdown, "$CpGAT_ReferenceProt_File");//build dropdown for reference protein dir(s)


# update directory
$update_dirlist=dirlist_dropdown($Input_Data_Path, "", "", $Update_Data_Path);//build dropdown for update dir(s)

#$update_dirlist=dirlist_dropdown($Input_Data_Path, $Update_Data_Path);

		$display_block = "
<div id=\"maincontentscontainer\" class=\"twocolumn configure $background\">
	<div style=\"text-align:right; margin:10px 150px -20px 0px\"></div>
	<div id=\"maincontents\" class=\"$background\">
		<div id=\"submenu\" class=\"bottommargin2\" style=\"background-color:#BBB; padding:0 0 3px 0;	white-space:nowrap\">
			<ul>
				<li>&nbsp; <span class=\"whitefont italic\" >Jump to: </span><img id='config_top_menu' title='Edit Help' class='help-button nudge2 smallerfont' src='/XGDB/images/help-icon.png' alt='?' /></li>
				<li><a href=\"#DatabaseDiv\">General Info</a></li>
				<li><a href=\"#InputDiv\">I/O</a></li>
				<li><a href=\"#TransAlignDiv\">Transcript</a></li>
				<li><a href=\"#ProtAlignDiv\">Protein</a></li>
				<li><a href=\"#CpGATDiv\">Gene Prediction</a></li>
				<li><a href=\"#UpdateDiv\">Update</a></li>
				<li><a href=\"#DefaultsDiv\">Other</a></li>
				<li><a href=\"#GenomeDiv\">Genome</a></li>
				<li><a href=\"#SegmentsDiv\">Scaffolds</a></li>
				<li><a href=\"#ModelsDiv\">Gene Models</a></li>
				<li><a href=\"#AlignmentsDiv\">Spliced Alignments</a></li>
			</ul>
		</div>
			<table class=\"topmargin2\" style=\"font-size:12px\" width=\"100%\">
				<!--tr><td>mode= $mode; display_load_archive=$display_load_archive</td></tr-->
				<tr>
					<td width=\"80%\">
		<!-- PAGE TITLE HEADING H1 -->			
						<h1 id=\"heading\" class=\"configure\"> 
							<img alt=\"\" src=\"/XGDB/images/configure.png\" />
							GDB Configuration<img id='config_page' title='Here you can edit parameters or initiate data processing. Click ? for details.' class='help-button nudge1' src='/XGDB/images/help-icon.png' alt='?' />
							
							<span class=\"edit_mode normalfont  $edit nowrap\"> 
								&nbsp;&nbsp;Edit Mode&nbsp;<img id='config_edit_mode' title='Edit Help' class='help-button nudge1' src='/XGDB/images/help-icon.png' alt='?' />&nbsp;
							</span>
							<span class=\"options_mode normalfont $options nowrap\"> 
								&nbsp;&nbsp;Options Mode&nbsp;<img id='config_options_mode' title='Allows user to Validate, Create, Update, Drop, or Abort. Click for more details.' class='help-button nudge1' src='/XGDB/images/help-icon.png' alt='?' />&nbsp;
							</span>
							<span class=\"lockout_mode normalfont $lockout nowrap\"> 
								&nbsp;&nbsp;Lockout Mode - pipeline is running on $locked_DBid &nbsp;<img id='config_lockout_mode' title='No additional GDB processing until pipeline complete.' class='help-button nudge1' src='/XGDB/images/help-icon.png' alt='?' />&nbsp;
							</span>	<!-- span class=\"normalfont\">Input: $i_exists; Output: $o_exists; GDB: $g_exists;  Archive: $a_exists; ArchiveAll: $aa_exists;</span-->
							<span class=\"process_notice largerfont\">$alert</span>
							<span class=\"darkgrayfont smallerfont\"> &nbsp; $logged_in</span>
							
						</h1>
					</td>
					<td align = \"right\">
						<form style=\"display:inline\" method=\"post\" action=\"/XGDB/conf/navigate.php\" class=\"styled\">
							<input type=\"hidden\" name=\"id\" value=\"$ID\" />
							<input type=\"hidden\" name=\"Navigate\" value=\"Previous\" />
							<span class=\"$nav\">
								<input  style = \"margin:0\" id=\"prev\" type=\"submit\" class=\"submit\" value=\"&lt;Prev\"/>
							</span>
						</form>
						<form style=\"display:inline\" method=\"post\" action=\"/XGDB/conf/navigate.php\" class=\"styled\">
							<input type=\"hidden\" name=\"id\" value=\"$ID\" />
							<input type=\"hidden\" name=\"Navigate\" value=\"Next\" />
							<span class=\"$nav\">
								<input  style = \"margin:0\" id=\"next\" type=\"submit\" class=\"submit\" value=\"Next&gt;\" />
							</span>
						</form>
						<form method=\"post\" action=\"/XGDB/conf/load_archive.exec.php\" name=\"load_archive\" class=\"styled\">
							<input type=\"hidden\" name=\"action\" value=\"gdb_load_archive\" />
							<input type=\"hidden\" name=\"ID\" value=\"$ID\" />
							<input type=\"hidden\" name=\"xgdb\" value=\"$DBid\" />
							<div class=\"nowrap $display_load_archive\">
								<select name=\"file\">
									$archive_dirlist_display
								</select>
								<input type=\"submit\" id=\"load_archive\" class=\"submit save_style $display_load_archive\" style=\"color:purple\" value=\"&nbsp;&nbsp;Load Config&nbsp;&nbsp;\"  onclick=\"return confirm('Really load this GDB archive config? It may take some time for large datasets. Then you will need to select Data Process Options -> Restore from Archive to complete the process.')\" />
								 &nbsp;
									 <img src='' id='config_load_archive' alt='save help' title='Click for more info' class='help-button nudge2' />
								 &nbsp;
							</div>
						</form>
					</td>
				</tr>
				<tr>
				    <td>
				        <span class=\"normalfont indent1\" style=\"font-weight:normal\">&nbsp; $dir1_status &nbsp; $dir2_status</span>
				        					&nbsp;
										    <span class=\"$gth_class\">
                                                    GTH $gth_valid
                                            </span>
                                            &nbsp;
										    <span class=\"$gm_class \">
                                                    GM $gm_valid
                                            </span>
                                            &nbsp;
										    <span class=\" $vm_class\">
                                                    VM $vm_valid
                                            </span>
                                            &nbsp;

                                            <img src='' id='config_status_flags' alt='save help' title='Click for more info' class='help-button nudge2' />
				    </td>
				</tr>
			</table>
		
		<div id=\"whatsthisdivfor\">
			
		<!-- GDB TITLE HEADING H1 -->	
			<h1 style=\"border:1px solid #AAA\" class=\" $Status nowrap bottommargin2 topmargin1 indent1\"> 
				 $DBid: &nbsp; &ldquo;$DBname&rdquo;
			</h1>
			
		<!-- GDB STATUS HEADING TABLE (large font) -->
		<div style=\"margin-bottom:30px\">
			<table id=\"status_table\"><!-- to adjust gap in edit mode-->
				<tr>
					<td align=\"left\" width=\"auto\" >
						<span class=\"bigfont\" style=\"white-space:nowrap\"  >
							&nbsp;
								Status:
								 &nbsp;<span style=\"padding:5px; font-variant:small-caps; border:2px solid #AAA\" class= \"view hugefont bold $Status\">$Status</span>
								<img id='config_status' title='Click for more info' class='help-button nudge2' src='/XGDB/images/help-icon.png' alt='?' />
							&nbsp;
						</span>						
					</td>
					<td style=\"padding:0px 0 0 10px\">
							<span class=\"$mode_message_style $mode_message_display\">
								$mode_message
							</span>
							<span class=\"$nav normalfont\">
								$database_message
							</span>
							
							<span class=\"$error alertnotice largerfont\"> 
								Cannot create GDB! Configuration is incomplete.
							</span>
							 $warning_msg
		
					</td>
				</tr>
			</table>
		</div>	
		<!-- LIST OF VALID INPUT FILES, REFPRO FILES -->
		<div id=\"valid_inputs\">
		<table id=\"inputs_errors\">
			<tr>
				<td style=\"padding:0px 0 0 10px\"  valign=\"top\">
					<div id=\"input_list\" class=\"$top_list_hide $locked\">
						$validList
					</div><!-- end input list -->
					<div id=\"refpro_valid\" class=\"$cpgat_row_hide $top_list_hide $locked\">
						$validRefPro
					</div><!-- end refpro valid -->
					<div id=\"repmast_valid\" class=\"$repmask_row_hide $top_list_hide $locked\">
						$validRepMask
					</div><!-- end refpro list -->
					<div id=\"update_list\" class=\"$conditional_update\">
						$validUpdateList
					</div><!-- end validupdate list -->
					<div id=\"pipeline_errors\" class=\"$conditional_current_locked\">
						$pipeline_errors_display
					</div><!-- end pipeline_errors list -->
					<div id=\"input_errors\" class=\"$display_development\">
						$input_errors_display
					</div><!-- end input errors list -->
					<div id=\"input_results_2\" class=\"$result_list_hide $locked\">
						$input_results_display
					</div><!-- end input results -->
					<div id=\"update_results\" class=\"$conditional_update\">
					    $update_results_display
					</div><!-- end update results -->
				</td>
			</tr>
		</table>
		</div><!-- end valid_inputs -->
		<!-- LOGFILE DISPLAY TABLE (DURING LOCKED STATUS) -->	
			<table class=\"tail_display $tail_display\">
                <tbody>
                    <tr>
                        <td>
                            <span class=\"nowrap largerfont\" style=\"color:purple\">
                                Now processing: <br />
                            </span>
                            <span  id=\"${logfile_path}${logfile}\" title=\"$DBid\" class='logfile-button smallerfont link'> 
                                Logfile <img style='margin-bottom:-5px' src='/XGDB/images/logfile-icon.png' alt='?' />
                            </span>
                            <span id='Pipeline_error' title=\"$DBid\" class='logfile-button smallerfont link'> 
                                Errors <img style='margin-bottom:-5px' src='/XGDB/images/logfile-icon.png' alt='?' />
                            </span>
                        </td>
                        <td>
                            <span class=\"normalfont\">$tail_line1 <br /> $tail_line2</span>
                        </td>
                    </tr>
				</tbody>
			</table>
		
		<!-- DATA PROCESS OPTIONS: CREATE DROP ARCHIVE RESTORE ABORT forms -->
		
		<div>
            <span class=\"$conditional_edit alertnotice normalfont\">Edit values and click 'Save Changes', or 'Cancel'. Note required fields (<span class=\"required\"></span>). 'Reset' restores original entries.</span>						
            <span class=\"$conditional_edit_current $edit $current_class alertnotice normalfont\">Edit values and click 'Save Changes', or 'Cancel'. Do not edit configuration parameters unless you are going to run a GDB 'Update'. </span>
		</div>
			<table style=\"font-size:12px\" class=\"topmargin2\" width=\"100%\">
				<tr>
					<td align=\"left\" width=\"54%\">
					    <span class=\"$nav instruction\">To <b>Validate, Create, Drop, Abort, Archive, or Restore</b>, click 'Options' button at right &rarr;</span>
						<span class=\"$create instruction\">To <b>CREATE a new xGDBvm database, $DBid, </b> make sure all necessary data files are in the Input directory,  
						then click <span class=\"heading\">\"Create New Database\" </span> to start pipeline. Once complete (from less a minute to many hours, depending on genome size and number of alignments), the new genome will be added to the '<i>View</i>' menu.<br /><br /></span>

						<span class=\"$restore instruction\">To <b>RESTORE the selected archive</b>, click <span class=\"bold\" style=\"color:purple\">\"Restore from $Restore_GDB Archive\" </span> button.
						 Once complete, the restored genome will be added to the '<i>View</i>' menu.</span>

						<span class=\"$update instruction\">
						To <b>UPDATE</b> $DBid, make sure all necessary data files are in the Update directory and with valid filenames:
						Then click \"Update Database\" to start update pipeline. Once complete (from less a minute to many hours, depending on genome size and number of alignments), the updated genome will be displayed.
						<br /><br /></span>	
						
						<span class=\"$drop instruction\">
						    To <b>DROP</b> (REMOVE) $DBid  and start over, click the \"Drop Database\" button at right. This will PERMANENTLY remove Output data for this GDB, but GDB Configuration and Input data are untouched.
						<br /><br /></span>
						
                        <span class=\"$drop instruction\">
                            To <b>ARCHIVE</b> $DBid, click the \"Archive Database\" button at right. All data and configurations will be saved to your attached data volume under <span class=\"plaintext\">$dataDir/ArchiveGDB_${VM}/</span>. 
						</span>
						<span  class=\"$abort instruction\">To ABORT $DBid when the pipeline has failed or you want to start over with this GDB, click 'Abort Process' to revert to Development Status. Click \"Cancel\" to return to configuration view.</span>
		
					</td>
			
					<td  align=\"right\" width=\"10%\">
						<form method=\"post\" action=\"/XGDB/conf/view.php?id=$ID\" name=\"view_status_on\" class=\"styled\">
							<input id=\"cancel\" class=\"$cancel cancel_style submit\" type=\"submit\" value=\"&nbsp;&nbsp;Cancel&nbsp;&nbsp;\" />
							<input type=\"hidden\" name=\"mode\" value=\"Cancel\" />
						</form>	
			
					</td>
					<td align=\"right\" width=\"40%\">
						<form method=\"post\" name=\"create_drop\" action=\"/XGDB/conf/view.php?id=$ID\" class=\"styled\">
							<input style=\"width:200px\"  id=\"options\" class=\" $nav options_style submit\" type=\"submit\" value=\"Data Process Options...\" />
							<img id='config_db_options' title='Search Help' class='help-button $nav' src='/XGDB/images/help-icon.png' alt='?' />
							<input type=\"hidden\" name=\"action\" value=\"options\" />
							<input type=\"hidden\" name=\"mode\" value=\"$mode\" />
							<input type=\"hidden\" name=\"id\" value=\"$id\" />
						</form>

						<form method=\"post\" action=\"/XGDB/conf/validate_files.php\" class=\"styled\">
						    <input type=\"hidden\" name=\"valid\" value=\"$valid_post\" />
						    <input type=\"hidden\" name=\"id\" value=\"$ID\" />
							<input type=\"hidden\" name=\"xgdb\" value=\"$DBid\" />
							<input type=\"hidden\" name=\"inputdir\" value=\"$validate_input\" />
							<input type=\"hidden\" name=\"updatedir\" value=\"$validate_update\" />
							<input type=\"hidden\" name=\"refprotfile\" value=\"$validate_refprot\" />
							<input type=\"hidden\" name=\"repeatmaskfile\" value=\"$validate_repmask\" />
							<input class=\"$validate submit\"  id=\"create\" type=\"submit\" style=\"color:#488EC5; width:200px\"  value=\"Validate Input Data Files\" onclick=\"return confirm('Really validate datafiles? This may take a few minutes.')\" />
							<img id='config_file_contents_validation' title='Validate all input data files. Click for more details' class=\"help-button $validate\" src='/XGDB/images/help-icon.png' alt='?' />
						</form>


						<form method=\"post\" action=\"/XGDB/conf/create.php\" class=\"styled topmargin1\">
							<input type=\"hidden\" name=\"id\" value=\"$ID\" />
							<input type=\"hidden\" name=\"action\" value=\"update\" />
							<input type=\"hidden\" name=\"valid\" value=\"$valid_post\" />
							<input id=\"update\" style=\"color:#01BFA9\" class=\"$update update_style submit\" type=\"submit\" value=\"Update $DBid Database\" onclick=\"return confirm('Really update this GDB?')\" />
							<img id='config_update_button' title='Process data and Update this database. Click for more details. ' class='help-button $update' src='/XGDB/images/help-icon.png' alt='?' />
						</form>

						<form method=\"post\" action=\"/XGDB/conf/create.php\" class=\"styled topmargin1\">
							<input type=\"hidden\" name=\"id\" value=\"$ID\" />
							<input type=\"hidden\" name=\"action\" value=\"create\" />
							<input type=\"hidden\" name=\"valid\" value=\"$valid_post\" />
							<input class=\"$create submit $conditional_loggedin\"  id=\"create\" type=\"submit\" value=\"Create New $DBid Database\" onclick=\"return confirm('Really create this GDB?')\" />
							<img id='config_create_db' title='Process Input data and create a new genome browser. Click for more details' class=\"help-button $create $conditional_loggedin\" src='/XGDB/images/help-icon.png' alt='?' />
						</form>
						<form method=\"post\" action=\"/XGDB/conf/drop.php\" class=\"styled topmargin1\">
							<input type=\"hidden\" name=\"id\" value=\"$ID\" />
							<input type=\"hidden\" name=\"action\" value=\"drop\" />
							<input type=\"hidden\" name=\"valid\" value=\"$valid_post\" />
							<input type=\"hidden\" name=\"redirect\" value=\"view\" />
							<input style=\"width:200px\" id=\"drop\" class=\"$drop drop_style submit\"  type=\"submit\" value=\"Drop $DBid Database\" onclick=\"return confirm('Really drop this GDB?')\" />
							<img id='config_drop' title='Remove all data for this GDB. Click for more details.' class='help-button $drop' src='/XGDB/images/help-icon.png' alt='?' />
						</form>
						<form method=\"post\" action=\"/XGDB/conf/drop.php\" class=\"styled\">
							<input type=\"hidden\" name=\"id\" value=\"$ID\" />
							<input type=\"hidden\" name=\"action\" value=\"abort\" />
							<input type=\"hidden\" name=\"valid\" value=\"$valid_post\" />
							<input  id=\"abort\" class=\"$abort abort_style submit\"  type=\"submit\" value=\"Abort Process\" onclick=\"return confirm('Really abort this GDB?')\" />
							<img id='config_abort_option' title='Abort Help' class='help-button $abort' src='/XGDB/images/help-icon.png' alt='?' />
						</form>
						<form method=\"post\" name=\"archive\" action=\"/XGDB/conf/archive_exec.php\" class=\"styled topmargin1\">
							<input type=\"hidden\" name=\"id\" value=\"$ID\" />
							<input type=\"hidden\" name=\"xgdb\" value=\"$DBid\" />
							<input type=\"hidden\" name=\"return\" value=\"view\" />
							<input type=\"hidden\" name=\"valid\" value=\"$valid_post\" />
								<input type=\"hidden\" name=\"action\" value=\"archive_one\" />
								<input id=\"archive\" class=\"$drop submit\"  style=\"width: 200px\" type=\"submit\" value=\"Archive $DBid Database\" onclick=\"return confirm('Do you really want to archive? (This will not affect current xGDB data).')\"/>
							<img id='config_archive' title='Help with the Archive button' class='help-button $drop' src='/XGDB/images/help-icon.png' alt='?' />
						</form>
						<form method=\"post\" name=\"restore\" action=\"/XGDB/conf/restore_exec.php\" class=\"styled\">
							<input type=\"hidden\" name=\"id\" value=\"$ID\" />
							<input type=\"hidden\" name=\"xgdb\" value=\"$DBid\" />
							<input type=\"hidden\" name=\"source_file\" value=\"$Restore_From_File\" />
							<input type=\"hidden\" name=\"action\" value=\"restore_one\" />
							<input type=\"hidden\" name=\"valid\" value=\"$valid_post\" />
							<input type=\"hidden\" name=\"return\" value=\"view\" />
							<input id=\"restore\" class=\"$restore submit\" style=\"color:#72028E\" type=\"submit\" value=\"Restore from $Restore_GDB Archive\" onclick=\"return confirm('Do you really want to restore to $Archive_Date version?')\"/>
							<img id=\"config_restore\" title=\"Help with the Restore button\" class=\"help-button $restore\" src=\"/XGDB/images/help-icon.png\" alt=\"?\" />
						</form>
					</td>
				</tr>			
			</table>
		
		<!-- Mode Information, EDIT CLEAR BUTTONS (load this page) / FORM  -->	
		
			<table style=\"font-size:12px\" width=\"100%\">
			
				<tr>
					<td width=\"60%\" align = \"left\" class=\"normalfont\">
							<span class= \"$locked $nav normalfont instruction\">To <b>modify this configuration</b>, click 'Edit' button at right &rarr;</span>						
					</td>
					<td width=\"40%\" align = \"right\">
						<form method=\"post\" action=\"/XGDB/conf/view.php?id=$ID\" name=\"edit_status_on\" class=\"styled\">
							<input style=\"width:200px\" id=\"edit\" class=\"$locked $nav edit_style submit\" type=\"submit\" name=\"mode\" value=\"Edit Configuration...\" />
							<img id='config_edit' title='Click for help with Edit this Configuration' class='help-button $locked $nav' src='/XGDB/images/help-icon.png' alt='?' />
							<input type=\"hidden\" name=\"mode\" value=\"Edit\" />
						</form>
					</td>	
			  </tr>
			</table>
		<!-- CLEAR/CANCEL BUTTONS -->	
		<table width=\"100%\">
			<tr>
				<td width=\"auto\">
						<form method=\"post\" name=\"clear_data\" action=\"/XGDB/conf/view.php?id=$ID\" class=\"styled\">
					        <input id=\"clear\" class=\"$conditional_edit clear_style submit\" style=\"color:#FF8484\"  type=\"submit\" value=\"Clear\" onclick=\"return confirm('Do you really want to clear this configuration and start over? All saved values will be lost')\" />
							<input type=\"hidden\" name=\"action\" value=\"Clear\" />
							<input type=\"hidden\" name=\"mode\" value=\"Edit\" />
							<input type=\"hidden\" name=\"id\" value=\"$ID\" />
						</form>
				</td>
			
				<td width=\"auto\">
				
						<!--form method=\"post\" name=\"clear_data\" action=\"/XGDB/conf/view.php\" class=\"styled\">
							<input class=\"$conditional_edit clear_style submit\" style=\"color:#999\"  type=\"submit\" value=\"Clear\"  />
							<input type=\"hidden\" name=\"clear\" value=\"Clear\" />
							<input type=\"hidden\" name=\"mode\" value=\"Edit\" />
							<input type=\"hidden\" name=\"id\" value=\"$ID\" />
						</form -->
				</td>
				<td width=\"400px\" align=\"right\">
						<form method=\"post\" action=\"/XGDB/conf/view.php?id=$ID\" name=\"view_status_on\" class=\"styled\">
							<input style=\"width:150px\" id=\"cancel2\" class=\"$edit cancel_style submit\" type=\"submit\" value=\"&nbsp;&nbsp;Cancel&nbsp;&nbsp;\" />
							<input type=\"hidden\" name=\"mode\" value=\"Cancel\" />
						</form>
				</td>
			</tr>
		</table>
		<!-- SAVE CONFIG DATA BUTTONS TABLE / FORM (through end of tables)-->	
		<div id=\"big_form\">
					<!-- the big form -->
					<form method=\"post\" name=\"record_data\" action=\"/XGDB/conf/update.php\" class=\"styled topmargin1\">
					<input style=\"color:#999\" class=\"$conditional_edit reset_style submit\" type=\"reset\" value=\"Reset\" name=\"reset\" />
					<input style=\"width:150px; float:right\" id=\"save\" class=\"$edit save_style submit\" type=\"submit\" name=\"submit\" value=\"Save Changes\" />
					<input type=\"hidden\" name=\"id\" value=\"$ID\" />

					
			
            <!-- MAIN CONFIG DATA TABLE / FORM DATA INPUTS -->	
                    <div id=\"GeneralDiv\" class=\"description \">
                        <fieldset  class=\"bottommargin1 topmargin1 xgdb_log $Status\">
                        <legend class=\"conf $status_font_display\"> &nbsp; General Information &nbsp;</legend>
                        <table class=\"xgdb_log $status_font_display\" border=\"0\" style=\"font-size:12px\" width=\"100%\" >
                            <colgroup>
                                <col width =\"25%\" style=\"background-color: #DDD\" />
                                <col width =\"75%\" />
                            </colgroup>
                            <tbody>
                                <tr class=\"$conditional_dev\">
                                    <td>
                                        Data Volumes (GB free):
                                    </td>
                                    <td>
                                        <div class=\"showhide\">
                                            <p class=\"normalfont label\" style=\"cursor:pointer\" title=\"Show file validation\">
                                                    <span class=\"normalfont\" style=\"color: #555\">
                                                        Inputs: 
                                                    </span>
                                                    <span class=\"bold\">
                                                        $validGB
                                                    </span>;
                                                     &nbsp; Root:${gb1_display}; &nbsp; Data:${gb2_display}; &nbsp; Scratch:${gb3_display};  &nbsp; MySQL:${gb4_display}
                                                    <span class=\"heading normalfont\">
                                                        (click for details)
                                                    </span>
                                                </p>
                                            <div class=\" hidden\" style=\"display: none;\">
                                            <p>Based on <span class=\"bold\">$validGB GB</span> of input files, available space rated as <span class=\"checked\"> = adequate</span> or <span class=\"warning\">=not sufficient</span></p>
                                                <ul class=\"bullet1\">
                                                    <li><b>Output Files</b> are created under <span class=\"plaintext largerfont\">/$dataDir/</span>. Available disk space: $gb2_display GB</li>
                                                    <li><b>Scratch</b> (temporary) files are created under <span class=\"plaintext largerfont\">/$dataDir/scratch/</span>. Available disk space: $gb3_display GB</li>
                                                    <li><b>MySQL</b> (database) files are created under <span class=\"plaintext largerfont\">$dataDir/mysql/</span>. Available disk space: $gb3_display GB</li>
                                                </ul>
                                                <p> Refer to <a href=\"/XGDB/conf/volumes.php\">Data Volumes</a> page for more details.</p>						
                                            </div>
                                        </div>
                                    </td>
                                </tr>
                                <tr>
                                    <td>
                                        Database ID:
                                    </td>
                                    <td class=\"no_edit\">
                                        $DBid
                                    </td>
                                </tr>
                                <tr>
                                    <td class=\"$required\" >Database Name:</td>
                                    <td class=\"$view user_entry\">$DBname</td>
                                    <td class=\"$edit\">
                                        <input name=\"DBname\" size=\"50\" value=\"$DBname\" />
                                    </td>
                                </tr>
                                <tr>
                                    <td class=\"$required\">Organism: </td>
                                    <td class=\"$view italic user_entry\">$Organism</td>
                                    <td class=\"$edit\">
                                        <input name=\"Organism\" size=\"35\" value=\"$Organism\" />
                                    </td>
                                </tr>
                                <tr>
                                    <td>Common Name: </td>
                                    <td class=\"$view user_entry\">$Common_Name</td>
                                    <td class=\"$edit\">
                                        <input name=\"Common_Name\" size=\"35\" value=\"$Common_Name\" />
                                    </td>
                                </tr>
                                <tr>
                                    <td>Genome Type: </td>
                                    <td class=\"$view user_entry\">$Genome_Type</td>
                                    <td class=\"$edit\">
                                            <select name=\"Genome_Type\">
                                            <option selected=\"selected\">$Genome_Type</option>
                                                <option>Chromosome</option>
                                                <option>Scaffold</option>
                                                <option>Chromosome/Scaffold</option>
                                                <option>BAC</option>
                                                <option>BAC/Scaffold</option>
                                            </select>
                                    </td>
                                </tr>
                                <tr>
                                    <td>
                                        GDB Status
                                        <span class='$display_current_only smallerfont'>
                                        </span>
                                    </td>
                                    <td class=\"$view no_edit\">
                                        $Status
                                    </td>
                                    <td class=\"$edit\">
                                            <select name=\"Status\">
                                            <option selected=\"selected\">$Status</option>
                                                $Offline_option
                                                $Current_option
                                            </select>
                                    </td>
								</tr>		
								<tr>
									<td class=\"indent2\">Config Last Modified:</td>
									<td class=\"no_edit\">$Config_Date</td>
								</tr>
								<tr class=\"$display_current_only\">
									<td class=\"indent2\">Database Created:</td>
									<td class=\"no_edit\">$Create_Date</td>
								</tr>
								<tr class=\"$display_current_only\">
									<td class=\"indent2\">Database Updated:</td>
									<td class=\"no_edit\">$Update_Date</td>
								</tr>
								<tr class=\"$display_current_only\">
									<td class=\"indent2\">Features: <img id='config_current_features' title='Feature Track totals for this GDB (click to view). Click ? for details.' class='help-button nudge1' src='/XGDB/images/help-icon.png' alt='?' /></td>
									<td class=\"no_edit\"><span style='color:#CF0C14'>$feature_totals_string </span> </td>
								</tr>
								<tr class=\"$display_archive\">
									<td>$DBid Archived: <img id='config_archive_file' title='Archive Help' class='help-button' src='/XGDB/images/help-icon.png' alt='?' /></td>
									<td class=\"no_edit\">$Archive_Date <b>File:</b> <span class=\"plaintext\">$Archive_File</span></td>
								</tr>
								<tr class=\"$display_restore\">
									<td>$DBid Restored: <img id='config_restore_file' title='Search Help' class='help-button' src='/XGDB/images/help-icon.png' alt='?' /></td>
									<td class=\"no_edit\">$Restore_Date <b>File:</b> <span class=\"plaintext\">$Restore_Source</span></td>
								</tr>
								<tr class=\"$display_archive_all\">
									<td>All GDB Archived</td>
									<td class=\"no_edit\">$Archive_All_Date</td>
								</tr>
								<tr class=\"$display_restore_all\">
									<td>All GDB Restored:</td>
									<td class=\"no_edit\">$Restore_All_Date</td>
								</tr>
							</tbody>
						</table>
					</fieldset>
					
				</div>
			
			
				<div id=\"InputDiv\" class=\"description \">
					<fieldset  class=\"bottommargin1 topmargin1 xgdb_log $Status\">
					<legend class=\"conf $status_font_display\"> <img src=\"/XGDB/images/input_output.png\" alt=\"\" /> &nbsp; Input / Output <img id='config_input_data' title='Search Help' class='help-button' src='/XGDB/images/help-icon.png' alt='?' /> &nbsp;</legend>
		
					<div class=\"bottommargin1\">
						<div class=\"heading $edit\">
						    <p class=\"instruction\">
								Place all input data files in the Input Data Directory you specify below.<br /> 
								<span class=\"heading indent1\"><b>Required</b>: <a id='config_data_decisions-gdna' title='Choosing genome data' class=\"help-button link\">Genome</a>,  <a id='config_data_decisions-transcr' title='Choosing transcript data' class=\"help-button link\">Transcript and/or Protein</a></span><br />
								<span class=\"heading indent1\"><b>Optional</b>: <a id='config_data_decisions-anno' title='Choosing annotation data' class=\"help-button link\">Gene predictions</a></span>
						        <br />
						        Your data files must have <span class=\"checked\">VALID</span> filenames and no <span class=\"warning\">permissions</span> problems in order to be processed -- <a id='config_file_names_brief' title='Search Help' class='help-button link' >Click here for details</a> 
							</p>
						</div>
					</div>
					<table class=\"xgdb_log $status_font_display\" border=\"0\" style=\"font-size:12px\" width=\"100%\" >
						<colgroup>
							<col width =\"20%\" style=\"background-color: #DDD\" />
							<col width =\"30%\" />
							<col width =\"50%\" />
						</colgroup>
						<tbody>
							<tr>
								<td class=\"$required\" >
									 Input Data Directory <img id='config_input_dir' title='Input Data Help' class='help-button  nudge2' src='/XGDB/images/help-icon.png' alt='?' /> &nbsp;
								</td>
								<td>
									<span class=\"$conditional_view user_entry plaintext\">
										$Input_Data_Path
									</span>
									<span class=\"$conditional_edit\">
										<!--input name=\"Input_Data_Path\" size=\"30\" value=\"$Input_Data_Path\" /-->
										<select name=\"Input_Data_Path\">
											$input_dirlist
										</select>
									</span>
								</td>
								<td>
									<div class=\"no_edit\">
										$validList
									</div>
								</td>
							</tr>									
							<tr>
								<td class=\"$display_current_only\">
									<span class=\"$display_current_only\">
										Output Data <img id='config_output_dir_download' title='Output Data Help' class='help-button  nudge2' src='/XGDB/images/help-icon.png' alt='?' />
									</span>
								</td>
								<td class=\"$display_current_only\">
									<span class=\"no_edit $display_current_only user_entry plaintext\">
										/xGDBvm/data/$DBid/data/
									</span>
								</td>
								<td class=\"$display_current_only\">
								<a href=\"/XGDB/phplib/download.php?GDB=$DBid&dir=download \">Download $DBid Outputs</a>
								</td>
							</tr>
							<tr class=\"$display_restore_gdb\">
								<td class=\"$display_current_only\">
									<span class=\"$display_current_only\">
										Archive Data <img id='config_archive_output' title='Archive Output Help' class='help-button  nudge2' src='/XGDB/images/help-icon.png' alt='?' />
									</span>
								</td>
								<td class=\"$display_current_only\">
									<span name=\"$Restore_From_File\" class=\"no_edit $display_current_only user_entry plaintext\">
										/xGDBvm/data/ArchiveGDB/
									</span>
								</td>
								<td class=\"$display_current_only\">
								<a href=\"/XGDB/phplib/download.php?GDB=$DBid&dir=Archive\">Download $DBid Archive</a>
								</td>
							</tr>
							</tbody>
						</table>						
					</fieldset>
				</div>
			
				<div id=\"TransAlignDiv\" class=\"description \">
					<fieldset  class=\"bottommargin1 topmargin1 xgdb_log $Status\">
					<legend class=\"conf $status_font_display\"> <img src=\"/XGDB/images/transcripts_est.png\" alt=\"?\" /> &nbsp; Transcript Spliced Alignment  <span class=\"heading\"> (GeneSeqer) </span>  &nbsp;</legend>
						<div class=\"bottommargin1\"><span class=\"heading \"> This process will run automatically if <span class=\"plaintext\"> ~est.fa</span>, <span class=\"plaintext\">~cdna.fa</span> or <span class=\"plaintext\">~tsa.fa</span> files are provided. Repeat masking is advised for large genomes. </span></div>
					<table class=\"xgdb_log $status_font_display\" border=\"0\" style=\"font-size:12px\" width=\"100%\" >
						<colgroup>
							<col width =\"25%\" style=\"background-color: #DDD\" />
							<col width =\"75%\" />
						</colgroup>
						<tbody>

							<tr>
								<td>
								    GSQ Compute <img id='config_comp_res_gsq' title='Search Help' class='help-button' src='/XGDB/images/help-icon.png' alt='?' />
								</td>
								<td>
								    <span class=\"$conditional_view user_entry\">
								        $gsq_compres_display <span class=\"normalfont $conditional_gsq\"> &nbsp;Job ID: $gsq_jobs_display</span>
								    </span>
								    <span class=\"$conditional_edit normalfont\"> 
										<input title =\"internal\" style=\"cursor:pointer\" class=\"normalfont\" type=\"radio\" $GSQCompRes_Internal_checked name=\"GSQ_CompResources\" value=\"Local\"  /> Local &nbsp; &nbsp;
										<span class=\" $gsq_app_id_config\"><input title =\"external\" style=\"cursor:pointer\" class=\"normalfont\" type=\"radio\"  $GSQCompRes_External_checked  name=\"GSQ_CompResources\"  value=\"Remote\" /> Remote</span>
								    </span>
								</td>
							</tr>

							<tr>
								<td>
								    GSQ Species Model:
								</td>
								<td  align = \"left\">
								    <span class=\"$view user_entry\">
								        $Species_Model
								    </span>
								    <span class=\"$edit user_entry normalfont\">
										<input title =\"species_model\" style=\"cursor:pointer\" class=\"normalfont\" type=\"radio\"  $Arabidopsis_checked  name=\"Species_Model\" value=\"Arabidopsis\" /> Arabidopsis &nbsp; &nbsp;
										<input title =\"maize\" style=\"cursor:pointer\" class=\"normalfont\" type=\"radio\" $maize_checked  name=\"Species_Model\" value=\"maize\"  /> maize  &nbsp; &nbsp;
										<input title =\"rice\" style=\"cursor:pointer\" class=\"normalfont\" type=\"radio\"  $rice_checked  name=\"Species_Model\" value=\"rice\" /> rice  &nbsp; &nbsp;	
										<input title =\"Medicago\" style=\"cursor:pointer\" class=\"normalfont\" type=\"radio\"  $Medicago_checked  name=\"Species_Model\" value=\"Medicago\" /> Medicago
										<input title =\"Drosophila\" style=\"cursor:pointer\"  type=\"radio\" $Drosophila_checked name=\"Species_Model\" value=\"Drosophila\" /> Drosophila
								    </span>
								</td>
							</tr>							
							<tr>
								<td>
								    GSQ Alignment Stringency:
								</td>
								<td>
								    <span class=\"$view user_entry\">
								        $Alignment_Stringency
								    </span>
								    <span class=\"$edit user_entry normalfont\">
										<input title =\"other\" style=\"cursor:pointer\" class=\"normalfont\" type=\"radio\"  $Strict_Stringency_checked  name=\"Alignment_Stringency\" value=\"Strict\" /> Strict &nbsp; &nbsp;
										<input title =\"other\" style=\"cursor:pointer\" class=\"normalfont\" type=\"radio\"  $Moderate_Stringency_checked  name=\"Alignment_Stringency\" value=\"Moderate\" /> Moderate &nbsp; &nbsp;
										<input title =\"other\" style=\"cursor:pointer\" class=\"normalfont\" type=\"radio\"  $Low_Stringency_checked  name=\"Alignment_Stringency\" value=\"Low\" /> Low &nbsp; &nbsp;
								    </span>
								</td>
							</tr>
						</tbody>
					</table>
					<table class=\"xgdb_log $status_font_display\" border=\"0\" style=\"font-size:12px\" width=\"100%\" >
						<colgroup>
							<col width =\"25%\" style=\"background-color: #DDD\" />
							<col width =\"75%\" />
						</colgroup>
						<tbody>
							<tr class=\"$cpgat_row_hide\">
								<td class=\"indent2 subhead\" colspan=\"3\" style=\"background:#EEE\">Repeat Mask Option:</td>
							</tr>
							<tr>
								<td  class=\"\">
								    Repeat Mask this Genome? <img id='config_repmask_option' alt='cpgat' title='Configure: Repeat Mask Option Help' class='help-button  nudge2' src='/XGDB/images/help-icon.png' />
								</td>
								<td>
								    <span class=\"$view user_entry\">
								        $RepeatMask_Status
								    </span>
								    <span class=\"$edit normalfont\">
										<input title =\"none\" style=\"cursor:pointer\" class=\"normalfont\" type=\"radio\"  $RepeatMask_Status_no_checked  name=\"RepeatMask_Status\" value=\"\" /> No &nbsp;
										&nbsp;<input title =\"Click make genome sequence repeats prior to GeneSeqer\" style=\"cursor:pointer\" class=\"normalfont\" type=\"radio\"  $RepeatMask_Status_yes_checked  name=\"RepeatMask_Status\" value=\"Yes\" /> Yes &nbsp; &nbsp; &nbsp; 
										<span class=\"heading\">(If Yes, specify <b>Repeat Mask Library</b> below)</span>
								    </span>
								</td>
							</tr>
							<tr>
								<td>
									Repeat Mask Library: <img id='config_repmask_file' title='Search Help' class='help-button' src='/XGDB/images/help-icon.png' alt='?' />
								</td>
								<td>
									<span class=\"$view user_entry plaintext\">
										$RepeatMask_File
									</span>
									<span class=\"$edit\">
										<!--input name=\"RepeatMask_File\" size=\"40\" value=\"$RepeatMask_File\" /-->
										<select name=\"RepeatMask_File\">
											$repmask_dirlist
										</select>									
									</span>
								</td>
							</tr>
						</tbody>
					</table>
					</fieldset>
				</div>
			
				<div id=\"ProtAlignDiv\" class=\"description \">
					<fieldset  class=\"bottommargin1 topmargin1 xgdb_log $Status\">
					<legend class=\"conf $status_font_display\"> <img src=\"/XGDB/images/proteins.png\" alt=\"?\" /> &nbsp; Protein Spliced Alignment  <span class=\"heading\"> (GenomeThreader) </span> </legend>
	                <div class=\"bottommargin1\"><span class=\"heading \"> This process will run automatically if <span class=\"plaintext\"> ~prot.fa</span> files are provided. Repeat masking is not used for protein alignments. </span></div>
					<table class=\"xgdb_log $status_font_display\" border=\"0\" style=\"font-size:12px\" width=\"100%\" >
						<colgroup>
							<col width =\"25%\" style=\"background-color: #DDD\" />
							<col width =\"75%\" />
						</colgroup>
						<tbody>
							<tr>
								<td>
								    GTH Compute <img id='config_comp_res_gth' title='Search Help' class='help-button' src='/XGDB/images/help-icon.png' alt='?' />
								</td>
								<td>
								    <span class=\"$conditional_view user_entry\">
								        $gth_compres_display <span class=\"normalfont $conditional_gth\">&nbsp;Job ID: $gth_jobs_display</span>
								    </span>
								    <span class=\"$conditional_edit normalfont\"> 
										<input title =\"internal\" style=\"cursor:pointer\" class=\"normalfont\" type=\"radio\" $GTHCompRes_Internal_checked name=\"GTH_CompResources\" value=\"Local\"  /> Local &nbsp; &nbsp;
										<span class=\"$gth_app_id_config\">
										    <input title =\"external\" style=\"cursor:pointer\" class=\"normalfont\" type=\"radio\"  $GTHCompRes_External_checked  name=\"GTH_CompResources\"  value=\"Remote\" />
										    Remote
										</span>
								    </span>
								</td>
							</tr>
							<tr>
								<td>
								    GTH Species Model:
								</td>
								<td>
								    <span class=\"$view user_entry\">
								        $Gth_Species_Model
								    </span>
								    <span class=\"$edit user_entry normalfont\">
										<input title =\"gth_arabidopsis\" style=\"cursor:pointer\" class=\"normalfont\" type=\"radio\"  $gth_arabidopsis_checked  name=\"Gth_Species_Model\" value=\"arabidopsis\" /> arabidopsis &nbsp; &nbsp;
										<input title =\"gth_maize\" style=\"cursor:pointer\" class=\"normalfont\" type=\"radio\" $gth_maize_checked  name=\"Gth_Species_Model\" value=\"maize\"  /> maize  &nbsp; &nbsp;
										<input title =\"gth_rice\" style=\"cursor:pointer\" class=\"normalfont\" type=\"radio\"  $gth_rice_checked  name=\"Gth_Species_Model\" value=\"rice\" /> rice  &nbsp; &nbsp;	
										<input title =\"gth_medicago\" style=\"cursor:pointer\" class=\"normalfont\" type=\"radio\"  $gth_medicago_checked  name=\"Gth_Species_Model\" value=\"medicago\" /> medicago
								                <input title =\"gth_drosophila\" style=\"cursor:pointer\"  type=\"radio\" $gth_drosophila_checked name=\"Gth_Species_Model\" value=\"drosophila\" /> drosophila
								    </span>
								</td>
							</tr>
						</tbody>
					</table>
					</fieldset>
				</div>
			
				<div id=\"CpGATDiv\" class=\"description \">
					<fieldset  class=\"bottommargin1 topmargin1 xgdb_log $Status\">
					<legend class=\"conf $status_font_display $cpgat_legend_gray\"> <img src=\"/XGDB/images/cpgatmodels.png\" alt=\"?\" />
					    &nbsp; Gene Prediction 
					    <span class=\"heading\"> 
					        (CpGAT)
					    </span> &nbsp;
					    <img id='config_cpgat_option' alt='cpgat' title='Search Help' class='help-button' src='/XGDB/images/help-icon.png' /> &nbsp;
					</legend>
						<div class=\"bottommargin1\">
						    <span class=\"heading\"> 
						        (Optional) Running the CpGAT gene prediction tool requires transcript and/or protein spliced alignments. <br /> 
						        For optimal results you should also provide a reference protein dataset (see below). <br />
						        <span id='CpGAT_procedure' title=\"$DBid\" class='logfile-button link smallerfont'> 
						            View CpGAT Logfile <img style='margin-bottom:-5px' src='/XGDB/images/logfile-icon.png' alt='?' />
						        </span>
						    </span>
						</div>
					
						<table class=\"xgdb_log $status_font_display\" border=\"0\" style=\"font-size:12px\" width=\"100%\" >
							<colgroup>
								<col width =\"25%\" style=\"background-color: #DDD\" />
								<col width =\"75%\" />
							</colgroup>
							<tbody>
						
									<tr class=\"$cpgat_row_hide\">
										<td  class=\"\">
										    <span class=\"bigfont\">
										        Predict genes?
										    </span> </td>
										<td>
										    <span class=\"$view \">
										        $CpGAT_Status_Display 
										    </span>
										    <span class=\"$edit normalfont\">
												&nbsp;<input title =\"none\" style=\"cursor:pointer\" class=\"normalfont\" type=\"radio\"  $CpGAT_Status_none_checked  name=\"CpGAT_Status\" value=\"\" /> No &nbsp;
												&nbsp;<input title =\"Click to update data for this GDB\" style=\"cursor:pointer\" class=\"normalfont\" type=\"radio\"  $CpGAT_Status_Updateable_checked  name=\"CpGAT_Status\" value=\"Yes\" /> Yes:
										    </span>
										</td>
									</tr>
							</tbody>
						</table>
						<table class=\"xgdb_log $status_font_display\" border=\"0\" style=\"font-size:12px\" width=\"100%\" >
							<colgroup>
								<col width =\"25%\" style=\"background-color: #DDD\" />
								<col width =\"75%\" />
							</colgroup>
							<tbody>
									<tr class=\"$cpgat_row_hide\">
										<td class=\"indent2 subhead\" colspan=\"3\" style=\"background:#EEE\">Reference Protein Index:</td>
									</tr>
									<tr class=\"$cpgat_row_hide\" style=\"background-color: #DDD\">
										<td>
											Reference Protein Index:  <img id='config_cpgat_refprotein' title='Info on CpGAT reference proteins' class='help-button' src='/XGDB/images/help-icon.png' alt='?' />
										</td>
										<td>
										    <span class=\"$view user_entry plaintext\">
												$CpGAT_ReferenceProt_File
										    </span>
										    <span class=\"$edit\">
											    <!--input name=\"CpGAT_ReferenceProt_File\" size=\"60\" value=\"$CpGAT_ReferenceProt_File\" /-->
										       <select name=\"CpGAT_ReferenceProt_File\">
										        	$refprot_dirlist
										       </select>	
										    </span>
                                            <div class=\"no_edit normalfont\">
                                                $validRefPro
                                            </div>
										</td>
									</tr>
							</tbody>
						</table>
						<table class=\"xgdb_log $status_font_display\" border=\"0\" style=\"font-size:12px\" width=\"100%\">
							<colgroup>
								<col width =\"25%\" style=\"background-color: #DDD\" />
								<col width =\"75%\" />
							</colgroup>
							<tbody>
								<tr class=\"$cpgat_row_hide\">
									<td class=\"indent2 subhead\" colspan=\"2\" style=\"background:#EEE\">
										Genefinders:
									</td>
								</tr>
								<tr class=\"$cpgat_row_hide\">
									<td class=\"indent1\">
										BGF:
									</td>
									<td>
										<span class=\"$view user_entry\">
											$CpGAT_BGF
										</span>
										<span class=\"$edit user_entry\">
											&nbsp;
											<input title =\"Skip\" style=\"cursor:pointer\" type=\"radio\"  $Skip_BGF_checked  name=\"CpGAT_BGF\" value=\"Skip\" /> (Skip) &nbsp;
											<input title =\"Arabidopsis\" style=\"cursor:pointer\" type=\"radio\" $Arabidopsis_BGF_checked  name=\"CpGAT_BGF\" value=\"Arabidopsis\"  /> Arabidopsis  &nbsp;
											<input title =\"maize\" style=\"cursor:pointer\" type=\"radio\"  $maize_BGF_checked  name=\"CpGAT_BGF\" value=\"maize\" /> maize &nbsp;
											<input title =\"rice\" style=\"cursor:pointer\" type=\"radio\"  $rice_BGF_checked  name=\"CpGAT_BGF\" value=\"rice\" /> rice &nbsp;
											<input title =\"Silkworm\" style=\"cursor:pointer\" type=\"radio\"   $Silkworm_BGF_checked name=\"CpGAT_BGF\" value=\"Silkworm\"  /> Silkworm  &nbsp;
											<input title =\"soybean\" style=\"cursor:pointer\" type=\"radio\" $soybean_BGF_checked  name=\"CpGAT_BGF\" value=\"Arabidopsis\"  /> soybean  &nbsp; 
											<input title =\"fruitfly\" style=\"cursor:pointer\"  type=\"radio\" $Fruitfly_BGF_checked name=\"CpGAT_BGF\" value=\"Fruitfly\" /> Fruitfly
										</span>
									</td>
								</tr>
								<tr class=\"$cpgat_row_hide\">
									<td class=\"indent1\">
									    Augustus:
									</td>
									<td>
										<span class=\"$view user_entry\">
											$CpGAT_Augustus
									    </span>
									    <span class=\"$edit user_entry\">
											&nbsp;
											<input title =\"Skip\" style=\"cursor:pointer\" class=\"normalfont\" type=\"radio\"  $Skip_Augustus_checked  name=\"CpGAT_Augustus\" value=\"Skip\" /> (Skip) &nbsp;
											<input title =\"maize\" style=\"cursor:pointer\" class=\"normalfont\" type=\"radio\"  $maize_Augustus_checked  name=\"CpGAT_Augustus\" value=\"maize\" /> maize &nbsp;
											<input title =\"tomato\" style=\"cursor:pointer\" class=\"normalfont\" type=\"radio\"  $tomato_Augustus_checked  name=\"CpGAT_Augustus\" value=\"tomato\" /> tomato &nbsp;
											<input title =\"arabidopsis\" style=\"cursor:pointer\" class=\"normalfont\" type=\"radio\" $arabidopsis_Augustus_checked  name=\"CpGAT_Augustus\" value=\"arabidopsis\"  /> arabidopsis  &nbsp;
											<input title =\"chlamydomonas\" style=\"cursor:pointer\" class=\"normalfont\" type=\"radio\" $chlamydomonas_Augustus_checked  name=\"CpGAT_Augustus\" value=\"chlamydomonas\"  /> chlamydomonas  &nbsp;
											<input title =\"fly\" style=\"cursor:pointer\"  type=\"radio\" $fly_Augustus_checked name=\"CpGAT_Augustus\" value=\"fly\" /> fly 
										</span>
									</td>
								</tr>
								<tr class=\"$cpgat_row_hide\">
									<td class=\"indent1\">
									    GeneMark:
									</td>
									<td>
										<span class=\"$view user_entry\">
											$CpGAT_GeneMark
										</span>
										<span class=\"$edit user_entry\">
											&nbsp;
											<input title =\"Skip\" style=\"cursor:pointer\" class=\"normalfont\" type=\"radio\"  $Skip_GeneMark_checked  name=\"CpGAT_GeneMark\" value=\"Skip\" /> (Skip) &nbsp;
											<input title =\"a_thaliana\" style=\"cursor:pointer\" class=\"normalfont\" type=\"radio\" $a_thaliana_GeneMark_checked  name=\"CpGAT_GeneMark\" value=\"a_thaliana\"  /> a_thaliana  &nbsp;
											<input title =\"c_reinhardtii\" style=\"cursor:pointer\" class=\"normalfont\" type=\"radio\"  $c_reinhardtii_GeneMark_checked  name=\"CpGAT_GeneMark\" value=\"c_reinhardtii\" /> c_reinhardtii &nbsp;
											<input title =\"corn\" style=\"cursor:pointer\" class=\"normalfont\" type=\"radio\"  $corn_GeneMark_checked  name=\"CpGAT_GeneMark\" value=\"corn\" /> corn &nbsp;
											<input title =\"d_melanogaster\" style=\"cursor:pointer\" class=\"normalfont\" type=\"radio\"  $d_melanogaster_GeneMark_checked  name=\"CpGAT_GeneMark\" value=\"d_melanogaster\" /> d_melanogaster &nbsp;
											<input title =\"o_sativa\" style=\"cursor:pointer\" class=\"normalfont\" type=\"radio\"  $o_sativa_GeneMark_checked  name=\"CpGAT_GeneMark\" value=\"o_sativa\" /> o_sativa &nbsp;
											<input title =\"m_truncatula\" style=\"cursor:pointer\" class=\"normalfont\" type=\"radio\" $m_truncatula_GeneMark_checked  name=\"CpGAT_GeneMark\" value=\"m_truncatula\"  /> m_truncatula  &nbsp;
											<input title =\"barley\" style=\"cursor:pointer\" class=\"normalfont\" type=\"radio\" $barley_GeneMark_checked  name=\"CpGAT_GeneMark\" value=\"barley\"  /> barley  &nbsp;
											<input title =\"wheat\" style=\"cursor:pointer\" class=\"normalfont\" type=\"radio\" $wheat_GeneMark_checked  name=\"CpGAT_GeneMark\" value=\"wheat\"  /> wheat  &nbsp; 
										</span>
									</td>
								</tr>
								<tr class=\"$cpgat_row_hide\">
									<td class=\"indent2 subhead\" colspan=\"2\" style=\"background:#EEE\">
									    CpGAT Options:
									</td>
								</tr>
								<tr class=\"$cpgat_row_hide\">
									<td class=\"indent1\">
									    Skip Mask:
									</td>
									<td>
										<span class=\"$view user_entry\">
											$CpGAT_Skip_Mask <img id='config_cpgat_option_skipmask' title='Do NOT mask genome before ab inito gene prediction (click for more info)' class='help-button' src='/XGDB/images/help-icon.png' alt='?' />
										</span>
										<span class=\"$edit user_entry\">
											&nbsp;<input title =\"none\" style=\"cursor:pointer\" class=\"normalfont\" type=\"radio\"  $CpGAT_Skip_Mask_no_checked  name=\"CpGAT_Skip_Mask\" value=\"\" /> No &nbsp;
											&nbsp;<input title =\"Skip Repeat Mask for GTH\" style=\"cursor:pointer\" class=\"normalfont\" type=\"radio\"  $CpGAT_Skip_Mask_yes_checked  name=\"CpGAT_Skip_Mask\" value=\"Yes\" /> Yes  &nbsp; &nbsp; &nbsp; <span class=\"heading\">(if No, specify <b>Repeat Mask Index</b> above, or leave blank to use default)</span>
										</span>
									</td>
								</tr>
								<tr class=\"$cpgat_row_hide\">
									<td class=\"indent1\">
									    Relax UniRef: <img id='config_cpgat_option_relaxuniref' title='Allow gene models with no blast support from RefProt (click for more info)' class='help-button' src='/XGDB/images/help-icon.png' alt='?' />
									</td>
									<td class=\"$view user_entry\">
									    $CpGAT_Relax_UniRef 
									</td>
									<td class=\"$edit user_entry\">
											&nbsp;<input title =\"none\" style=\"cursor:pointer\" class=\"normalfont\" type=\"radio\"  $CpGAT_Relax_UniRef_no_checked  name=\"CpGAT_Relax_UniRef\" value=\"\" /> No &nbsp;
											&nbsp;<input title =\"Relax Requirement for UniRef Blast Hit for GTH Output\" style=\"cursor:pointer\" class=\"normalfont\" type=\"radio\"  $CpGAT_Relax_UniRef_yes_checked  name=\"CpGAT_Relax_UniRef\" value=\"Yes\" /> Yes
									</td>
								</tr>
								<tr class=\"$cpgat_row_hide\">
									<td class=\"indent1\">
                                    Skip PASA: <img id='config_cpgat_options_skippasa' title='Do not run PASA to assemble spliced alignments (click for more info)' class='help-button' src='/XGDB/images/help-icon.png' alt='?' />
									</td>
									<td class=\"$view user_entry\">
									    $CpGAT_Skip_PASA
									</td>
									<td class=\"$edit user_entry\">
											&nbsp;<input title =\"none\" style=\"cursor:pointer\" class=\"normalfont\" type=\"radio\"  $CpGAT_Skip_PASA_no_checked  name=\"CpGAT_Skip_PASA\" value=\"\" /> No &nbsp;
											&nbsp;<input title =\"Relax Requirement for UniRef Blast Hit for GTH Output\" style=\"cursor:pointer\" class=\"normalfont\" type=\"radio\"  $CpGAT_Skip_PASA_yes_checked  name=\"CpGAT_Skip_PASA\" value=\"Yes\" /> Yes
									</td>
								</tr>
								<tr class=\"$cpgat_row_hide\">
									<td>
										CpGAT Command String:  <img id='config_cpgat_parameters' title='Feature Track totals for this GDB (click to view). Click ? for details.' class='help-button nudge1' src='/XGDB/images/help-icon.png' alt='?' />
									</td>
									<td>
										<span class=\"smallerfont\">
											$CpGATparameter
										</span>
									</td>
								</tr>
								<tr class=\"$cpgat_row_hide\">
									<td class=\"indent2 subhead\" colspan=\"2\" style=\"background:#EEE\">
									    Track Options:
									</td>
								</tr>
								<tr class=\"$cpgat_row_hide\">
									<td class=\"indent1\">
									    Load Filtered Genes:  <img id='config_cpgat_filtergenes' title='Load ONLY genes with transcript evidence (click for more info)' class='help-button' src='/XGDB/images/help-icon.png' alt='?' />
									</td>
									<td class=\"$view user_entry\">
									    $CpGAT_Filter_Genes
									</td>
									<td class=\"$edit user_entry\"  align = \"left\">
											&nbsp;<input title =\"none\" style=\"cursor:pointer\" class=\"normalfont\" type=\"radio\"  $CpGAT_Filter_Genes_no_checked  name=\"CpGAT_Filter_Genes\" value=\"\" /> No &nbsp;
											&nbsp;<input title =\"Relax Requirement for UniRef Blast Hit for GTH Output\" style=\"cursor:pointer\" class=\"normalfont\" type=\"radio\"  $CpGAT_Filter_Genes_yes_checked  name=\"CpGAT_Filter_Genes\" value=\"Yes\" /> Yes
									</td>
								</tr>
							</tbody>
						</table>
					</fieldset>
				</div><!-- end CpGAT div -->
			
				<div id=\"UpdateDiv\" class=\"description \">
					<fieldset  class=\"bottommargin1 topmargin1 xgdb_log $Status\">
					<legend class=\"conf $status_font_display $update_legend_gray\"><img alt=\"update\" src=\"/XGDB/images/update.png\" /> &nbsp;  Update Options <img id='config_update_option' title='Search Help' class='help-button' src='/XGDB/images/help-icon.png' alt='?' /> &nbsp; <span class=\"largerfont $Update_Status $status_font_display\">$mode_message</span>  <span class=\"heading $edit\"></span></legend>
		
						<div class=\"bottommargin1\"><span class=\"heading\">To configure for update, click 'Yes' below, enter Update Data Path and desired Update Action(s). Then 'Save' and click 'Data Process Options'</span></div>
						<table class=\"xgdb_log $status_font_display $conditional_display\"  border=\"0\" style=\"font-size:12px\" width=\"95%\">
							<colgroup>
								<col width =\"20%\" style=\"background-color: #DDD\" />
								<col width =\"80%\" />
							</colgroup>
							<tbody>
								<tr class=\"$update_row_hide\">
									<td class=\"$update_legend_gray\"><span class=\"largerfont\">Update this GDB?</span></td>
									<td class=\"$view user_entry $update_legend_gray\">$Update_Status_Display</td>
									<td class=\"$edit user_entry\">
											&nbsp;<input title =\"none\" style=\"cursor:pointer\" class=\"normalfont\" type=\"radio\"  $Update_Status_none_checked  name=\"Update_Status\" value=\"\" /> No &nbsp;
											&nbsp;<input title =\"Click to update data for this GDB\" style=\"cursor:pointer\" class=\"normalfont\" type=\"radio\"  $Update_Status_Updateable_checked  name=\"Update_Status\" value=\"Update\" /> Yes &nbsp; &nbsp; <span class=\"heading\"> (If Yes, indicate path to update data files</span>)
										</td>
								</tr>
							</tbody>
						</table>
						<table class=\"xgdb_log $status_font_display $conditional_display\"  border=\"0\" style=\"font-size:12px\" width=\"95%\">
							<colgroup>
								<col width =\"20%\" style=\"background-color: #DDD\" />
								<col width =\"40%\" />
								<col width =\"40%\" />
							</colgroup>
							<tbody>
								<tr class=\"$update_row_hide\">
									<td class=\" indent2 subhead\" colspan=\"3\" style=\"background:#EEE\"> Update Data Path:</td>
								</tr>
								<tr class=\"$update_row_hide $conditional_display\">
									<td>
										  Select Path: <img id='config_update_data' title='Search Help' class='help-button' src='/XGDB/images/help-icon.png' alt='?' /> &nbsp;
									</td>
									<td>
										<span class=\"$view user_entry plaintext largerfont\">
											$Update_Data_Path
										</span>
										<span class=\"$edit\">
											<!--input name=\"Update_Data_Path\" size=\"30\" value=\"$Update_Data_Path\" /-->
										<select name=\"Update_Data_Path\">
											$update_dirlist
										</select>
										</span>
									</td>
									<td class=\"no_edit\">
										$validUpdateList
									</td>
								</tr>							
						    </tbody>
						</table>
						<table class=\"xgdb_log $status_font_display $conditional_display\"  border=\"0\" style=\"font-size:12px\" width=\"95%\">
							<colgroup>
								<col width =\"20%\" style=\"background-color: #DDD\" />
								<col width =\"40%\" />
								<col width =\"20%\" style=\"background-color: #DDD\" />
								<col width =\"20%\" style=\"background-color: #DDD\" />
							</colgroup>
							<tbody>
								<tr class=\"$update_row_hide\">
									<td class=\" indent2 subhead\" style=\"background:#EEE\">Track(s): <img id='config_update_tracks' title='Search Help' class='help-button' src='/XGDB/images/help-icon.png' alt='?' /> </td>
									<td style=\"background:#EEE\"><i>Update Action</i></td>
									<td style=\"background:#EEE\"><i>Required Files</i></td>
									<td style=\"background:#EEE\"><i>Optional Files</i></td>
								</tr>
								<tr class=\"$update_row_hide\">
									<td class=\"indent1 nowrap\">
									    Genome <img  alt=\"\" src=\"/XGDB/images/genomesegments.png\" /> 
									</td>
									<td>
									    <span class=\"$view user_entry\">
									        $Update_Data_GSEG
									    </span>
									    <span class=\"$edit user_entry\">
											&nbsp;<input title =\"none\" style=\"cursor:pointer\" class=\"normalfont\" type=\"radio\"  $None_GSEG_checked  name=\"Update_Data_GSEG\" value=\"\" /> None &nbsp;
											&nbsp;<input title =\"append existing GSEG set\" style=\"cursor:pointer\" class=\"normalfont\" type=\"radio\"  $Append_GSEG_checked  name=\"Update_Data_GSEG\" value=\"Append\" /> Append &nbsp;
											<input title =\"replace existing GSEG set\" style=\"cursor:pointer\" class=\"normalfont\" type=\"radio\" $Replace_GSEG_checked  name=\"Update_Data_GSEG\" value=\"Replace\"  /> Replace/New  &nbsp; 
										</span>
									</td>
									<td>
									    <span style=\"cursor:pointer\" title=\"genome segments\" class=\"plaintext grayfont\">~gdna.fa </span>
									</td>
									<td>
									</td>
								</tr>
								<tr class=\"$update_row_hide\">
									<td class=\"indent1 nowrap\">
									    EST  <img  alt=\"\" src=\"/XGDB/images/transcripts_est.png\" /> 
									</td>
									<td>
									    <span class=\"$view user_entry\">
									        $Update_Data_EST
									    </span>
									    <span class=\"$edit user_entry\">
											&nbsp;<input title =\"none\" style=\"cursor:pointer\" class=\"normalfont\" type=\"radio\"  $None_EST_checked  name=\"Update_Data_EST\" value=\"\" /> None &nbsp;
											&nbsp;<input title =\"append existing EST set\" style=\"cursor:pointer\" class=\"normalfont\" type=\"radio\"  $Append_EST_checked  name=\"Update_Data_EST\" value=\"Append\" /> Append &nbsp;
											<input title =\"replace existing EST set\" style=\"cursor:pointer\" class=\"normalfont\" type=\"radio\" $Replace_EST_checked  name=\"Update_Data_EST\" value=\"Replace\"  /> Replace/New  &nbsp; 
										</span>
									</td>
									<td>
									    <span style=\"cursor:pointer\" title=\"fasta sequence file (required)\" class=\"plaintext grayfont\">~est.fa </span>
									</td>
									<td>
									    <span style=\"cursor:pointer\" title=\"precomputed spliced alignments (optional)\" class=\"plaintext grayfont\">~est.gsq</span>
									</td>
								</tr>
								<tr class=\"$update_row_hide\">
									<td class=\"indent1 nowrap\">
									    cDNA  <img alt=\"?\" src=\"/XGDB/images/transcripts_cdna.png\" />
									</td>
									<td>
									    <span class=\"$view user_entry\">
									        $Update_Data_cDNA
									    </span>
									    <span class=\"$edit user_entry\">
											&nbsp;<input title =\"none\" style=\"cursor:pointer\" class=\"normalfont\" type=\"radio\"  $None_cDNA_checked  name=\"Update_Data_cDNA\" value=\"\" /> None &nbsp;
											&nbsp;<input title =\"append existing cDNA set\" style=\"cursor:pointer\" class=\"normalfont\" type=\"radio\"  $Append_cDNA_checked  name=\"Update_Data_cDNA\" value=\"Append\" /> Append &nbsp;
											<input title =\"replace existing cDNA set\" style=\"cursor:pointer\" class=\"normalfont\" type=\"radio\" $Replace_cDNA_checked  name=\"Update_Data_cDNA\" value=\"Replace\"  /> Replace/New  &nbsp; 
										</span>
									</td>
									<td>
									    <span style=\"cursor:pointer\" title=\"fasta sequence file (required)\" class=\"plaintext grayfont\">~cdna.fa  </span>
									</td>
									<td>
									    <span style=\"cursor:pointer\" title=\"precomputed spliced alignments (optional)\" class=\"plaintext grayfont\">[~cdna.gsq] </span>
									</td>
								</tr>
								<tr class=\"$update_row_hide\">
									<td class=\"indent1 nowrap\">
									    TSA   <img  alt=\"?\" src=\"/XGDB/images/transcripts_put.png\" /> 
									</td>
									<td>
									    <span class=\"$view user_entry\">
									        $Update_Data_TrAssembly
									    </span>
									    <span class=\"$edit user_entry\">
											&nbsp;<input title =\"none\" style=\"cursor:pointer\" class=\"normalfont\" type=\"radio\"  $None_TrAssembly_checked  name=\"Update_Data_TrAssembly\" value=\"\" /> None &nbsp;
											&nbsp;<input title =\"append existing TrAssembly set\" style=\"cursor:pointer\" class=\"normalfont\" type=\"radio\"  $Append_TrAssembly_checked  name=\"Update_Data_TrAssembly\" value=\"Append\" /> Append &nbsp;
											<input title =\"replace existing TrAssembly set\" style=\"cursor:pointer\" class=\"normalfont\" type=\"radio\" $Replace_TrAssembly_checked  name=\"Update_Data_TrAssembly\" value=\"Replace\"  /> Replace/New  &nbsp; 
										</span>
									</td>
									<td>
									    <span style=\"cursor:pointer\" title=\"fasta sequence file (required)\" class=\"plaintext grayfont\">~tsa.fa</span>
									</td>
									<td>
									    <span style=\"cursor:pointer\" title=\"precomputed spliced alignments (optional)\" class=\"plaintext grayfont\">~tsa.gsq</span>
									</td>
								</tr>
								<tr class=\"$update_row_hide\">
									<td class=\"indent1 nowrap\">
									    Protein  <img  alt=\"?\" src=\"/XGDB/images/proteins.png\" /> 
									</td>
									<td>
									    <span class=\"$view user_entry\">
									        $Update_Data_Protein
									    </span>
									    <span class=\"$edit user_entry\">
											&nbsp;<input title =\"none\" style=\"cursor:pointer\" class=\"normalfont\" type=\"radio\"  $None_Protein_checked  name=\"Update_Data_Protein\" value=\"\" /> None &nbsp;
											&nbsp;<input title =\"append existing Protein set\" style=\"cursor:pointer\" class=\"normalfont\" type=\"radio\"  $Append_Protein_checked  name=\"Update_Data_Protein\" value=\"Append\" /> Append &nbsp;
											<input title =\"replace existing Protein set\" style=\"cursor:pointer\" class=\"normalfont\" type=\"radio\" $Replace_Protein_checked  name=\"Update_Data_Protein\" value=\"Replace\"  /> Replace/New  &nbsp; 
										</span>
									</td>
									<td>
									    <span style=\"cursor:pointer\" title=\"fasta sequence file (required)\" class=\"plaintext grayfont\">~prot.fa </span>
									</td>
									<td>
									    <span style=\"cursor:pointer\" title=\"precomputed spliced alignments (optional)\" class=\"plaintext grayfont\">~prot.gth</span>
									</td>
								</tr>
								<tr class=\"$update_row_hide\">
									<td class=\"indent1 nowrap\">
									    Genes 1 <img  alt=\"\" src=\"/XGDB/images/genemodels.png\" /> <br />
									    <span class=\"heading\">(precomputed)</span>
									</td>
									<td>
									    <span class=\"$view user_entry\">
									        $Update_Data_GeneModel
									    </span>
									    <span class=\"$edit user_entry\">
											&nbsp;<input title =\"none\" style=\"cursor:pointer\" class=\"normalfont\" type=\"radio\"  $None_GeneModel_checked  name=\"Update_Data_GeneModel\" value=\"\" /> None &nbsp;
											&nbsp;<input title =\"append existing Gene Model set\" style=\"cursor:pointer\" class=\"normalfont\" type=\"radio\"  $Append_GeneModel_checked  name=\"Update_Data_GeneModel\" value=\"Append\" /> Append &nbsp;
											<input title =\"replace existing Gene Model set\" style=\"cursor:pointer\" class=\"normalfont\" type=\"radio\" $Replace_GeneModel_checked  name=\"Update_Data_GeneModel\" value=\"Replace\"  /> Replace/New &nbsp; 
										</span>
									</td>
									<td>
									    <span style=\"cursor:pointer\" title=\"precomputed Annotation models\" class=\"plaintext grayfont\">~annot.gff3 </span><br />
									</td>
									<td>
									    <span style=\"cursor:pointer\" title=\"precomputed Annotation proteins\" class=\"plaintext grayfont\">~annot.pep.fa </span>
									    <span style=\"cursor:pointer\" title=\"precomputed Annotation mrna\" class=\"plaintext grayfont\">~annot.mrna.fa </span>
									</td>
								</tr>								
								<tr class=\"$update_row_hide\">
									<td class=\"indent1 nowrap\">
									    Genes 2 <img  alt=\"\" src=\"/XGDB/images/cpgatmodels.png\" /> <br />
									    <span class=\"heading\">(precomputed CpGAT)</span>
									</td>
									<td>
									    <span class=\"$view user_entry\">
									        $Update_Data_CpGATModel
									    </span>
									    <span class=\"$edit user_entry\">
											&nbsp;<input title =\"none\" style=\"cursor:pointer\" class=\"normalfont\" type=\"radio\"  $None_CpGATModel_checked  name=\"Update_Data_CpGATModel\" value=\"\" /> None &nbsp;
											&nbsp;<input title =\"append existing CpGATModel set\" style=\"cursor:pointer\" class=\"normalfont\" type=\"radio\"  $Append_CpGATModel_checked  name=\"Update_Data_CpGATModel\" value=\"Append\" /> Append &nbsp;
											<input title =\"replace existing CpGATModel set\" style=\"cursor:pointer\" class=\"normalfont\" type=\"radio\" $Replace_CpGATModel_checked  name=\"Update_Data_CpGATModel\" value=\"Replace\"  /> Replace/New &nbsp; 
										</span>
									</td>
									<td>
									    <span style=\"cursor:pointer\" title=\"preomputed CpGAT models\" class=\"plaintext grayfont\">~cpgat.gff3 </span><br />
									</td>
									<td>
									    <span style=\"cursor:pointer\" title=\"precomputed CpGAT proteins\" class=\"plaintext grayfont\">~cpgat.pep.fa </span>
									    <span style=\"cursor:pointer\" title=\"precomputed CpGAT mrna\" class=\"plaintext grayfont\">~cpgat.mrna.fa</span>
									</td>
								</tr>	
								<tr class=\"$update_row_hide\">
									<td class=\"indent1\">Predict Genes <br />
									    <span class=\"heading\">
									        (CpGAT) <img  alt=\"\" src=\"/XGDB/images/cpgatmodels.png\" />
									    </span>
									</td>
									<td>
									    <span class=\"$view user_entry\">
									        $Update_Data_CpGAT
									    </span>
									    <span class=\"$edit user_entry normalfont\">
											&nbsp;<input title =\"none\" style=\"cursor:pointer\" class=\"normalfont\" type=\"radio\"  $None_CpGAT_checked  name=\"Update_Data_CpGAT\" value=\"\" />
											    None &nbsp;
											&nbsp;<input title =\"append existing CpGAT set\" style=\"cursor:pointer\" class=\"normalfont\" type=\"radio\"  $Append_CpGAT_checked  name=\"Update_Data_CpGAT\" value=\"Append\" />
											    Append &nbsp;
											<input title =\"replace existing CpGAT set\" style=\"cursor:pointer\" class=\"normalfont\" type=\"radio\" $Replace_CpGAT_checked  name=\"Update_Data_CpGAT\" value=\"Replace\"  />
											    Replace/New &nbsp;
										</span>
									</td>
									<td class=\"indent1\" colspan=\"2\">
									    <span class=\"heading\">
                                            NOTE: Make sure CpGAT is correctly configured under <span class=\"Current\">Gene Prediction</span>
                                        </span>
									</td>
								</tr>
								<tr class=\"$update_row_hide\">
									<td class=\" indent2 subhead\" colspan=\"4\" style=\"background:#EEE\"> Add Descriptions:</td>
								</tr>
								<tr class=\"$update_row_hide\">
									<td class=\"indent1\">
									    Add Gene Descriptions: <img id='config_update_descriptions' title='Search Help' class='help-button' src='/XGDB/images/help-icon.png' alt='?' />
									</td>
									<td>
									    <span class=\"$view user_entry\">
									        $Update_Descriptions
									    </span>
									    <span class=\"$edit user_entry\">
											&nbsp;<input title =\"none\" style=\"cursor:pointer\" class=\"normalfont\" type=\"radio\"  $None_Descriptions_checked  name=\"Update_Descriptions\" value=\"\" /> None &nbsp;
											&nbsp;<input title =\"replace or add gene model descriptions\" style=\"cursor:pointer\" class=\"normalfont\" type=\"radio\"  $Precomputed_Descriptions_checked  name=\"Update_Descriptions\" value=\"Precomputed\" /> Genes 1 <img  alt=\"\" src=\"/XGDB/images/genemodels_precomp.png\" /> &nbsp;
											<input title =\"replace or add CpGAT Descriptions\" style=\"cursor:pointer\" class=\"normalfont\" type=\"radio\" $CpGAT_Descriptions_checked  name=\"Update_Descriptions\" value=\"CpGAT\"  /> Genes 2 <img  alt=\"\" src=\"/XGDB/images/cpgatmodels_precomp.png\" />
										</span>
									</td>
								    <td class=\"indent1\" colspan=\"2\">
								        <span class=\"plaintext grayfont\">~annot.desc.txt</span> or <span class=\"plaintext grayfont\">
								          ~cpgat.desc.txt
								        </span>
								    </td>
								</tr>						
								<tr class=\"$update_row_hide\">
									<td class=\"indent2 subhead\" colspan=\"4\" style=\"background:#EEE\">
									    Other Information:
									</td>
								</tr>
								<tr class=\"$update_row_hide\">
									<td>
									    Update Comments:
									</td>
									<td colspan=\"3\">
									    <span class=\"$view user_entry\">
									        $Update_Comments
									    </span>
									    <span class=\"$edit\">
										    <textarea class=\"data_entry smallerfont\" rows=\"1\" name=\"Update_Comments\" cols=\"80\">$Update_Comments</textarea>
										</span>
									</td>
								</tr>
								<tr class=\"$update_history_hide\">
									<td>Update History:</td>
									<td class=\"no_edit $display_current_only\" colspan=\"3\">
										$Update_History
									</td>
								</tr>						
							</tbody>
						</table>
					</fieldset>
				</div>
			
				<div id=\"DefaultsDiv\" class=\"description \">
					<fieldset  class=\"bottommargin1 topmargin1 xgdb_log $Status\">
					<legend class=\"conf largerfont $status_font_display\"> &nbsp;<b>Other Settings</b> <span class=\"heading\"> (Display and yrGATE defaults for this genome)</span> &nbsp;</legend>
					<table class=\"xgdb_log $status_font_display\" border=\"0\" style=\"font-size:12px\" width=\"100%\">
						<colgroup>
							<col width =\"25%\" style=\"background-color: #DDD\" />
							<col width =\"75%\" />
						</colgroup>
						<tbody>
							<tr>
								<td>Default Genome Segment: <img id='config_default_display' title='Search Help' class='help-button' src='/XGDB/images/help-icon.png' alt='?' /></td>
								<td>
									<span class=\"$view user_entry\">
										$Default_GSEG
									</span>
									<span class=\"$edit\">
										<input name=\"Default_GSEG\" size=\"15\" value=\"$Default_GSEG\" />
									</span>
								</td>
							</tr>
							<tr><td class=\"indent2\">Default Left Coordinate:</td><td class=\"$view user_entry\">$Default_lpos</td><td class=\"$edit\"><input name=\"Default_lpos\" size=\"15\" value=\"$Default_lpos\" /></td></tr>
							<tr><td class=\"indent2\">Default Right Coordinate:</td><td class=\"$view user_entry\">$Default_rpos</td><td class=\"$edit\"><input name=\"Default_rpos\" size=\"15\" value=\"$Default_rpos\" /></td></tr>	
							<tr>
								<td><span class=\"tip\" title=\"Click CpGAT to use as yrGATE reference annotation.\">yrGATE Ref. Annot. </span>  <img id='config_yrgate_ref' title='Configure: yrGATE Reference Help' class='help-button  nudge2' src='/XGDB/images/help-icon.png' alt='?' /></td>
								<td>
									<span class=\"$view user_entry\">
										$yrGATE_Reference
									</span>
									<span class=\"$edit user_entry\">
										<input title =\"yrGATE_Ref_pre\" style=\"cursor:pointer\"  type=\"radio\"  $yrGATE_Ref_pre_checked  name=\"yrGATE_Reference\" value=\"Precomputed\" /> Precomputed &nbsp;
										<input title =\"yrGATE_Ref_cpgat\" style=\"cursor:pointer\"  type=\"radio\" $yrGATE_Ref_cpgat_checked  name=\"yrGATE_Reference\" value=\"CpGAT\" /> CpGAT &nbsp;&nbsp;
									</span>
								</td>
							</tr>
						</tbody>
					</table>
				</fieldset>	
				</div>	
				<div id=\"GenomeDiv\" class=\"description \">
					
					<span class=\"hugefont bold topmargin2\">Genome Information (optional)</span>
					
					<hr class=\"featuredivider bottommargin2\" />
					
					<fieldset  class=\"topmargin2 bottommargin1 xgdb_log $Status\">
					<legend class=\"conf largerfont $status_font_display\"> <img alt=\"\" src=\"/XGDB/images/DNA.png\" />&nbsp; Genome: <span class=\"heading $edit\"> (Optional)</span></legend>
						<table class=\"xgdb_log $status_font_display\"  border=\"0\" style=\"font-size:12px\" width=\"100%\">
							<colgroup>
								<col width =\"25%\" style=\"background-color: #DDD\" />
								<col width =\"75%\" />
							</colgroup>
							<tbody>
								<tr>
								<td>Genome Version:</td>
								<td class=\"$view user_entry\">$Genome_Version</td>
								<td class=\"$edit\">
									<input name=\"Genome_Version\" size=\"9\" value=\"$Genome_Version\" />
									</td>
								</tr>
								<tr>
									<td>Genome Source:</td>
									<td class=\"$view user_entry\">$Genome_Source</td>
									<td class=\"$edit\">
										<input name=\"Genome_Source\" size=\"25\" value=\"$Genome_Source\" />
									</td>
								</tr>
								<tr>
									<td>Genome Source Link:</td>
									<td class=\"$view user_entry\"><pre><a href=\"$Genome_Source_Link\">$Genome_Source_Link</a></pre></td>
									<td class=\"$edit\">
										<input name=\"Genome_Source_Link\" size=\"60\" value=\"$Genome_Source_Link\" />
									</td>
								</tr>
								<tr>
									<td>Genome Comments:</td>
									<td class=\"$view user_entry\">$Genome_Comments</td>
									<td class=\"$edit\">
										<textarea class=\"data_entry smallerfont\" rows=\"1\" name=\"Genome_Comments\" cols=\"65\">$Genome_Comments</textarea>
									</td>
								</tr>
							</tbody>
						</table>
					</fieldset>	
				</div>
			
				<div id=\"SegmentsDiv\" class=\"description \">
						<fieldset  class=\"bottommargin1 xgdb_log $Status\">
						<legend class=\"conf largerfont $status_font_display\"> <img alt=\"\" src=\"/XGDB/images/genomesegments.png\" />&nbsp; Genome Segments: <span class=\"heading $edit\"> (record number of segments expected, and type)</span> &nbsp;</legend>
							<table class=\"xgdb_log $status_font_display\" border=\"0\" style=\"font-size:12px\" width=\"100%\">
								<colgroup>
									<col width =\"25%\" style=\"background-color: #DDD\" />
									<col width =\"75%\" />
								</colgroup>
								<tbody>
									<tr class=\"no_edit\">
									    <td class=\"heading\">Genome Segments (Total) Detected:</td><td>$gseg_total</td></tr>
									<tr>
									    <td>Genome Segments Expected:</td><td class=\"$view user_entry\">$Genome_Count</td><td class=\"$edit\"><input name=\"Genome_Count\" size=\"5\" value=\"$Genome_Count\" /></td></tr>
									<tr>
									    <td class=\"indent3\">Chromosomes:</td><td class=\"$view user_entry\">$Chromosome_Count</td><td class=\"$edit\"><input name=\"Chromosome_Count\" size=\"5\" value=\"$Chromosome_Count\" /></td></tr>
									<tr>
									    <td class=\"indent3\">
									        Unlinked Chromosomes:
									    </td>
									    <td class=\"$view user_entry\">
									        $Unlinked_Chromosome_Count
									    </td>
									    <td class=\"$edit\">
									        <input name=\"Unlinked_Chromosome_Count\" size=\"5\" value=\"$Unlinked_Chromosome_Count\" />
									    </td>
									</tr>
									<tr>
									    <td class=\"indent3\">
									        Scaffolds:
									    </td>
									    <td class=\"$view user_entry\">
									        $Scaffold_Count
									    </td>
									    <td class=\"$edit\">
									        <input name=\"Scaffold_Count\" size=\"5\" value=\"$Scaffold_Count\" />
									    </td>
									</tr>
									<tr>
									    <td class=\"indent3\">
									        BACs:
									    </td>
									    <td class=\"$view user_entry\">
									        $BAC_Count
									    </td>
									    <td class=\"$edit\">
									        <input name=\"BAC_Count\" size=\"5\" value=\"$BAC_Count\" />
									    </td>
									</tr>
								</tbody>
							</table>
						</fieldset>	
				</div>
			
				<div id=\"ModelsDiv\" class=\"description \">
						<fieldset  class=\"bottommargin1 xgdb_log $Status\">
						<legend class=\"conf largerfont $status_font_display\"> &nbsp;  Gene Models: <span class=\"heading $edit\"> (Optional)</span></legend>
							<table class=\"xgdb_log $status_font_display\" border=\"0\" style=\"font-size:12px\" width=\"100%\">
								<colgroup>
									<col width =\"25%\" style=\"background-color: #DDD\" />
									<col width =\"75%\" />
								</colgroup>
								<tbody>
									<tr><td>Gene Model Version:</td><td class=\"$view user_entry\">$GeneModel_Version</td><td class=\"$edit\"><input name=\"GeneModel_Version\" size=\"9\" value=\"$GeneModel_Version\" /></td></tr>
									<tr><td>Gene Model Source:</td><td class=\"$view user_entry\">$GeneModel_Source</td><td class=\"$edit\"><input name=\"GeneModel_Source\" size=\"25\" value=\"$GeneModel_Source\" /></td></tr>
									<tr><td>Gene Model Link:</td><td class=\"$view user_entry\"><pre><a href=\"$GeneModel_Link\">$GeneModel_Link</a></pre></td><td class=\"$edit\"><input name=\"GeneModel_Link\" size=\"60\" value=\"$GeneModel_Link\" /></td></tr>
									<tr class=\"no_edit\"><td>Genome Segments Annotated:</td><td>$anno_gseg_total</td></tr>
									<tr class=\"no_edit\"><td><img src=\"/XGDB/images/genemodels.png\" alt=\"\" /> Precomputed Gene Models:</td><td class=\"\">$gene_anno_total</td></tr>
									<tr class=\"no_edit\"><td class=\"indent2\">Gene Loci:</td><td class=\"\">$gene_loci_total</td></tr>
									<tr class=\"no_edit\"><td><img src=\"/XGDB/images/cpgatmodels.png\" alt=\"\" /> CpGAT Gene Models: </td><td class=\"\">$cpgat_gene_anno_total</td></tr>
									<tr class=\"no_edit\"><td width=\"35\"> <img src=\"/XGDB/images/yrgatemodels.png\" alt=\"\" /> yrGATE Annotations: </td><td width=\"5\">$yrgate_total</td></tr>
									<tr><td>GeneModel Comments:</td><td class=\"$view user_entry\">$GeneModel_Comments</td><td  class=\"$edit\"><textarea class=\"data_entry smallerfont\" rows=\"1\" name=\"GeneModel_Comments\" cols=\"65\">$GeneModel_Comments</textarea></td></tr>
								</tbody>
							</table>
						</fieldset>	
				</div>
			
				<div id=\"AlignmentsDiv\" class=\"description \">
						<fieldset  class=\"bottommargin1 xgdb_log $Status\">
						<legend class=\"conf largerfont $status_font_display\"> &nbsp; Transcript Spliced Alignments: <span class=\"heading $edit\">(Optional)</span></legend>
							<table class=\"xgdb_log $status_font_display\" border=\"0\" style=\"font-size:12px\" width=\"100%\">
								<colgroup>
									<col width =\"25%\" style=\"background-color: #DDD\" />
									<col width =\"75%\" />
								</colgroup>
								<tbody>
									<tr>
										<td>
											Aligned EST Species:
										</td>
										<td>
											<span class=\"$view italic user_entry\">
												$EST_Align_sp
											</span>
											<span class=\"$edit\">
												<input name=\"EST_Align_sp\" size=\"35\" value=\"$EST_Align_sp\" />
											</span>
										</td>
									</tr>
									<tr>
										<td>
											Aligned EST Version:
										</td>
										<td>
											<span class=\"$view user_entry\">
												$EST_Align_Version
											</span>
											<span class=\"$edit\">
													<input name=\"EST_Align_Version\" size=\"15\" value=\"$EST_Align_Version\" />
											</span>
										</td>
									</tr>
									<tr><td class=\"indent2 heading\">EST Count Total:</td><td>$est_total</td></tr>
									<tr><td class=\"indent2 heading\"> <img src=\"/XGDB/images/transcripts_est.png\" alt=\"\" /> EST Alignments:</td><td>$est_algn_total</td></tr>
									<tr><td class=\"indent3 heading\">Cognate:</td><td>$est_cog_total</td></tr>
									<tr><td class=\"indent3 heading\">Non-cognate:</td><td>$est_non_total</td></tr>
									<tr>
										<td class=\"indent2 heading\">
											Aligned EST Comments:
										</td>
										<td>
											<span class=\"$view user_entry\">
												$EST_Align_Comments
											</span>
											<span class=\"$edit\">
												<input name=\"EST_Align_Comments\" size=\"75\" value=\"$EST_Align_Comments\" />
											</span>
										</td>
									</tr>
									<tr><td>Aligned cDNA Species:</td><td class=\"$view italic user_entry\">$cDNA_Align_sp</td><td class=\"$edit\"><input name=\"cDNA_Align_sp\" size=\"35\" value=\"$cDNA_Align_sp\" /></td></tr>
									<tr><td>Aligned cDNA Version:</td><td class=\"$view user_entry\">$cDNA_Align_Version</td><td class=\"$edit\"><input name=\"cDNA_Align_Version\" size=\"15\" value=\"$cDNA_Align_Version\" /></td></tr>
									<tr><td class=\"indent2 heading\">cDNA Count Total:</td><td class=\"\">$cdna_total</td></tr>
									<tr><td class=\"indent2 heading\"> <img src=\"/XGDB/images/transcripts_cdna.png\" alt=\"?\" /> cDNA Alignments:</td><td>$cdna_algn_total</td></tr>
									<tr><td class=\"indent3 heading\">Cognate:</td><td>$cdna_cog_total</td></tr>
									<tr><td class=\"indent3 heading\">Non-cognate:</td><td>$cdna_non_total</td></tr>
									<tr>
										<td class=\"indent2 heading\">
											Aligned cDNA Comments:
										</td>
										<td>
											<span class=\"$view user_entry\">
												$cDNA_Align_Comments
											</span>
											<span class=\"$edit\">
												<input name=\"cDNA_Align_Comments\" size=\"75\" value=\"$cDNA_Align_Comments\" />
											</span>
										</td>
									</tr>

									<tr><td>Aligned TSA<span class=\"heading\">*</span> Species:</td><td class=\"$view italic user_entry\">$PUT_Align_sp</td><td class=\"$edit\"><input name=\"PUT_Align_sp\" size=\"35\" value=\"$PUT_Align_sp\" /></td></tr>
									<tr><td>Aligned TSA<span class=\"heading\">*</span> Version:</td><td class=\"$view user_entry\">$PUT_Align_Version</td><td class=\"$edit\"><input name=\"PUT_Align_Version\" size=\"15\" value=\"$PUT_Align_Version\" /></td></tr>
									<tr><td class=\"indent2\"> <img src=\"/XGDB/images/transcripts_put.png\" alt=\"?\" /> TSA<span class=\"heading\">*</span> Alignments:</td><td class=\"\">$put_align_total</td></tr>
									<tr>
										<td class=\"indent2 heading\">
											Aligned TSA* Comments:
										</td>
										<td>
											<span class=\"$view user_entry\">
												$PUT_Align_Comments
											</span>
											<span class=\"$edit\">
												<input name=\"PUT_Align_Comments\" size=\"75\" value=\"$PUT_Align_Comments\" />
											</span>
										</td>
									</tr>
								</tbody>
							</table>
							<span class=\"heading\">*TSA = Transcript Sequence Assembly</span>
						</fieldset>
						
						<fieldset  class=\"bottommargin1 xgdb_log $Status\">
							<legend class=\"conf largerfont $status_font_display\"> &nbsp; Protein Alignments:  <span class=\"heading $edit\">(Optional)</span></legend>
							<table class=\"xgdb_log $status_font_display\" border=\"0\" style=\"font-size:12px\" width=\"100%\">
								<colgroup>
									<col width =\"25%\" style=\"background-color: #DDD\" />
									<col width =\"75%\" />
								</colgroup>
								<tbody>
									<tr><td class=\"indent2\">Species:</td><td class=\"$view italic user_entry\">$Prot_Align_sp</td><td class=\"$edit\"><input name=\"Prot_Align_sp\" size=\"35\" value=\"$Prot_Align_sp\" /></td></tr>
									<tr><td class=\"indent2\">Version:</td><td class=\"$view user_entry\">$Prot_Align_Version</td><td class=\"$edit\"><input name=\"Prot_Align_Version\" size=\"10\" value=\"$Prot_Align_Version\" /></td></tr>
									<tr>
										<td class=\"indent2 heading\">
											Aligned Protein Comments:
										</td>
										<td>
											<span class=\"$view user_entry\">
												$Prot_Align_Comments
											</span>
											<span class=\"$edit\">
												<input name=\"Prot_Align_Comments\" size=\"75\" value=\"$Prot_Align_Comments\" />
											</span>
										</td>
									</tr>
									<tr><td class=\"indent2 heading\">Protein Count Total:</td><td>$prot_total</td></tr>
									<tr><td class=\"indent2 heading\"> <img alt=\"?\" src=\"/XGDB/images/proteins.png\" />&nbsp; Protein Alignments:</td><td>$prot_align_total</td></tr>
								</tbody>
							</table>
						</fieldset>
					</div>
				</form>
				</div><!-- big_form-->
			</div><!-- whatsthisdivfor -->
		</div><!-- maincontents -->
						  <div style=\"clear:both; float:right\">
							<a href=\"http://validator.w3.org/check?uri=referer\"><img
							  src=\"http://www.w3.org/Icons/valid-xhtml10\" alt=\"Valid XHTML 1.0 Transitional\" height=\"15\" width=\"44\" /></a>
						  </div>						
</div> <!-- maincontentscontainer -->
";
	?>
	
						<div id="leftcolumncontainer">
							<div class="minicolumnleft">
							<?php include_once("/xGDBvm/XGDB/conf/leftmenu.inc.php"); ?>
							</div>
						</div>

				<?php
				#	echo "<span class=\"heading\" >".$get_data." | ".$get_est_tot." | ".$get_est_algn." </span>";

					echo $display_block;
				?>
						<div id="rightcolumncontainer">
					</div><!--end rightcolumncontainer-->
				<?php include($XGDB_FOOTER); ?>
				</div><!-- end pagewidth-->
			</div><!-- end inndercontainer-->
		</div><!-- end outercontainer-->
	</body>
</html>
