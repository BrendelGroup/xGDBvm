<?php ob_start();
session_start();

### validate form sender or die ###
$post_valid=$_POST['valid']; // if properly set this is a mt_rand() integer; else not set or guessed value
$session_invalid=mt_rand(); 
$session_valid=(isset($_SESSION['valid']))?$_SESSION['valid']:$session_invalid;  // use bogus random # for comparison if no session value
if ($session_valid != $post_valid) // value passed by $_POST should match $_SESSION value; won't match if POST came from another source.
{
    die('Form submission failed validation');
}

$global_DB= 'Genomes';
include_once('/xGDBvm/XGDB/phplib/db.inc.php');
include_once(dirname(__FILE__).'/conf_functions.inc.php');
include('sitedef.php');
require('/xGDBvm/XGDB/phplib/validation_functions.inc.php'); #validation functions required in this script

$dbpass=dbpass();
$db = mysql_connect("localhost", "gdbuser", $dbpass);
if(!$db){
	echo "Error: Could not connect to mysql!";
	exit;
}
mysql_select_db('$global_DB');
if((mysql_real_escape_string($_POST['action']) == 'create') || (mysql_real_escape_string($_POST['action']) == 'update' )){
	$action=mysql_real_escape_string($_POST['action']);
	$id = mysql_real_escape_string($_POST['id']);

$get_data = "select * from Genomes.xGDB_Log where ID='$id'";
$check_get_data = mysql_query($get_data);
$data = mysql_fetch_array($check_get_data);

date_default_timezone_set("$TIMEZONE");
 
$current_class=""; //assigned below
		
####### General Info #######
		$ID = $id; #post result.
		$DBid = 'GDB'.substr(('00'. $id),-3); #calculated from unique ID										
		$DBname = $data["DBname"];
		$Status=$data["Status"];
		$Organism=$data["Organism"];
		$GSQ_CompResources = $data["GSQ_CompResources"];
		$GTH_CompResources = $data["GTH_CompResources"];

####### Database Creation #######

		$Input_Data_Path=$data["Input_Data_Path"];
		$input_path_trim=trim($Input_Data_Path); //trim spaces from ends
		$input_path=preg_replace('/\s/', '_', $input_path_trim); //change any directory name spaces into "_"
        $input_path=shell_args_whitelist($input_path); //from validation_functions.inc.php 2/26/15
        $GFF_Type=$data["GFF_Type"];
		$gff_type = ($GFF_Type =="CpGAT")?"standard":"other"; //specifies gff3 file type, whether CpGAT generated or "other".

####### GSQ Parameters #######
		$RepeatMask_Status=$data["RepeatMask_Status"];
		$RepeatMask_File=$data["RepeatMask_File"];
		$Species_Model=$data["Species_Model"];
		$Alignment_Stringency=$data["Alignment_Stringency"];
		
####### GSQ Parameters #######
		$Gth_Species_Model=$data["Gth_Species_Model"];

######## CpGAT ########
		$CpGAT_Status=$data["CpGAT_Status"];
		$CpGAT_ReferenceProt_File=$data["CpGAT_ReferenceProt_File"];
		$CpGAT_BGF=$data["CpGAT_BGF"];
		$CpGAT_Augustus=$data["CpGAT_Augustus"];
		$CpGAT_GeneMark=$data["CpGAT_GeneMark"];
		$CpGAT_Skip_Mask=$data["CpGAT_Skip_Mask"];
		$CpGAT_Relax_UniRef=$data["CpGAT_Relax_UniRef"];
		$CpGAT_Skip_PASA=$data["CpGAT_Skip_PASA"];
		$CpGAT_Filter_Genes=$data["CpGAT_Filter_Genes"];
		$Update_Data_CpGAT=$data["Update_Data_CpGAT"];
		$Update_Status=$data["Update_Status"];


####### Database Update #######

####### Get snapshot of input files (valid list) #####

$arrayList = create_file_list($Input_Data_Path, "dir", "", "", 2, $dbpass); //from conf_functions.inc.php  create_file_list($input, $type, $path, $title, $cutoff)
$validList = $arrayList[3]; # not formatted, just the raw list (what we will store)

####### Set up Computer Resources Parameter String (GSQ) #######

$GSQ_CompResParameter=" Local "; // Default arguments.

if(($GSQ_CompResources =="Remote")){ //require correct config.
    $remote=true;
    $username=$_SESSION['username']; // the user's iPlant login
    $refresh_token=$_SESSION['refresh_token']; // obtained from iPlant authentication URL
    $server = $_SERVER['SERVER_NAME']; // required for callback URL

	$GSQ_CompResParameter = " Remote $username $refresh_token $server "; # FIXME we don't need to send the token anymore.

	}

####### Set up Computer Resources Parameter String (GTH) #######

$GTH_CompResParameter=" Local "; // Default
if(($GTH_CompResources =="Remote")){ //require correct config.
    $remote=true;
    $username=$_SESSION['username'];
    $refresh_token=$_SESSION['refresh_token'];
    $server = $_SERVER['SERVER_NAME']; // required for callback URL
	$GTH_CompResParameter = " Remote $username $refresh_token $server"; # FIXME we don't need to send the token anymore.

	}

####### Set up RepeatMask (GeneSeqer) Parameter String (if any) #######

$mask_option="";
$GenomeMaskParameter="";
if(($RepeatMask_Status =="Yes") && $RepeatMask_File !=""){ //require correct config.

	  $GenomeMaskParameter = " \"$RepeatMask_File \"";
	  $mask_option=" -r";

	  }

####### Create GeneSeqer Parameter String (-g flag) ######

$GSQparameter = " -s $Species_Model";  # Updated 2/17/16: the Alignment_Stringency parameters MUST be specified AFTER Species_Model or else they are overridden.

switch ($GSQparameter) {
    case ($Alignment_Stringency == "Strict"):
        $GSQparameter .= " -x 30 -y 45 -z 60 -w 0.80";
        break;
     case ($Alignment_Stringency == "Moderate"):
        $GSQparameter .= " -x 16 -y 24 -z 48 -w 0.80";
        break;
    case ($Alignment_Stringency == "Low"):
        $GSQparameter .= " -x 12 -y 12 -z 30 -w 0.80";
        break;
	}
		
$GSQparameter .= " -m 999999999"; #maxnest, maximum alignments per segment (set to ceiling)


####### Create GenomeThreader Parameter String (-t flag) ######

$GTHparameter=" -species $Gth_Species_Model ";

####### Create CPGATparameter string (-a flag) ######

$anno_option="";
$CpGATparameter="";
$CpGATfilter=""; 

if((($Update_Status =="Yes" && $Update_Data_CpGAT !="") ||  $CpGAT_Status=="Yes") && $CpGAT_ReferenceProt_File !=""){ //require correct config: (Update status=Yes AND CpGAT update is requested), OR [Create mode ]CpGAT Yes, AND refprot file present.
    $pattern="/^.+\/(.+?$)/";
    preg_match($pattern, $CpGAT_ReferenceProt_File, $matches); 
	$CpGAT_ReferenceProt=$matches[1]; # grab just the file name, not the path. We are going to send it to a new location.
	$CpGAT_ReferenceProt_Path="/xGDBvm/data/scratch/$DBid/data/CpGAT/BLASTDIR/$CpGAT_ReferenceProt";
	$anno_option=" -a";
	$CpGATparameter =" -refprotdb $CpGAT_ReferenceProt_Path";
    $CpGATfilter=" -f unfiltered"; # default; new 1/18/13 whether to use filtered or unfiltered gff (default)
	
	if(($CpGAT_Skip_Mask != "Yes") && ($RepeatMask_File != "")){ //require correct config
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
	if($CpGAT_Filter_Genes == "Yes"){
	 $CpGATfilter = " -f filtered";
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
	$CpGATparameter .=" -nogth T "; # skip genomethreader steps by default
}

############## Option 1: Execute Base (Create) Database  ##############

	if($action=="create" && $Status == "Development"){ // Only allow the script to run if Development DB. Safety feature.  NOTE _ need second option for UPDATE!
		$status_update_query = "update $global_DB.xGDB_Log set Status = 'Locked' where ID=$id";
		$update_status = mysql_query($status_update_query);  //should be uncommented unless debug mode
		$create_history_query = "update $global_DB.xGDB_Log set Create_History = '$validList' where ID=$id"; // this is an unformatted list of valid input files - a "snapshot" of the input.
		$create_history = mysql_query($create_history_query);  //should be uncommented unless debug mode
		$warning="";
		
###### Set up "create" pipeline command using base info: -i Input [-r RepeatMask] -g GSQparams -t GTHparams -c GFFtype [-a CpGATparams] [-f CpGATfilter] -m GSQ_CompResParameter -n GTH_CompResParameter [-r RepeatMask] [-n DBname]########

		$command =  "/xGDBvm/scripts/xGDB_Procedure.sh -d \"$DBname\" -i \"$DBid $id $input_path\"  -g \"$GSQparameter\" -t \"$GTHparameter\" -c $gff_type -m \"$GSQ_CompResParameter\" -n \"$GTH_CompResParameter\" $mask_option $GenomeMaskParameter  $anno_option \"$CpGATparameter\" $CpGATfilter >> /tmp/log & ";  // NEW command

		exec($command);  //should be uncommented unless debug mode
		header("Location: view.php?id=$id&result=created");  //should be uncommented unless debug mode

############# Option 2: Execute Edit (Update) Database ##############

	}elseif($action=="update" && $Status == "Current"){ //For Database Update only

######## Database Update Parameters and flags (flag = append (A) or update (U)) ########

		$Update_Data_EST=$data["Update_Data_EST"];
		$est_flag=substr($Update_Data_EST, 0, 1); #A or U
		
		$Update_Data_cDNA=$data["Update_Data_cDNA"];
		$cdna_flag=substr($Update_Data_cDNA, 0, 1);
		
		$Update_Data_TrAssembly=$data["Update_Data_TrAssembly"];
		$put_flag=substr($Update_Data_TrAssembly, 0, 1);
		
		$Update_Data_GSEG=$data["Update_Data_GSEG"];
		$gseg_flag=substr($Update_Data_GSEG, 0, 1);
		
		$Update_Data_Protein=$data["Update_Data_Protein"];
		$protein_flag=substr($Update_Data_Protein, 0, 1);
		
		$Update_Data_GeneModel=$data["Update_Data_GeneModel"];
		$gff_flag=substr($Update_Data_GeneModel, 0, 1);

		$Update_Data_CpGATModel=$data["Update_Data_CpGATModel"];
		$cpgff_flag=substr($Update_Data_CpGATModel, 0, 1);
		
		$Update_Data_CpGAT=$data["Update_Data_CpGAT"];
		$anno_flag=substr($Update_Data_CpGAT, 0, 1);
		
		$Update_Data_Path=$data["Update_Data_Path"];
		$update_path_trim=trim($Update_Data_Path); //trim spaces from ends
		$update_path=preg_replace('/\s/', '_', $update_path_trim); //change any directory name spaces into "_"

######## For Descriptions, flag suffix is precomputed (P) or CpGAT (C) ########

		$Update_Descriptions=$data["Update_Descriptions"];
		$desc_flag=substr($Update_Descriptions, 0, 1);
		
	######## Create Update String (consisting of the update path and any/all update actions) - note white space after each. #########
	
		$Update_String = "${update_path} "; #e.g. /xGDBvm/data/MyData/UpdateData/
		$Update_String .= ($Update_Data_GSEG !="") ? "gseg${gseg_flag} ":""; #gsegA or gsegR
		$Update_String .= ($Update_Data_EST !="") ? "est${est_flag} ":""; #estA or estR
		$Update_String .= ($Update_Data_cDNA !="") ? "cdna${cdna_flag} ":"";
		$Update_String .= ($Update_Data_TrAssembly !="") ? "put${put_flag} ":"";
		$Update_String .= ($Update_Data_Protein !="") ? "pep${protein_flag} ":"";
		$Update_String .= ($Update_Data_GeneModel !="") ? "gff${gff_flag} ":"";
		$Update_String .= ($Update_Data_CpGATModel !="") ? "cpgff${cpgff_flag} ":"";
		$Update_String .= ($Update_Data_CpGAT !="") ? "cpgat${anno_flag} ":"";
		$Update_String .= ($Update_Descriptions !="") ? "desc${desc_flag} ":""; # descP or descC

		$status_update_query = "update $global_DB.xGDB_Log set Status = 'Locked', Process_Type = '$action' where ID=$id";
		$update_status = mysql_query($status_update_query); //should be uncommented unless debug mode
		$warning="";
		
    ######## Remove CpGAT parameter string (which determines whether CpGAT will run) unless CpGAT_Status='Yes' Update_Data_CpGAT = cpgatR or cpgatA ########
    
        $CpGATparameter = ($CpGAT_Status ="Yes") ? $CpGATparameter:"";
    	$CpGATparameter = ($Update_Data_CpGAT !="") ? $CpGATparameter:"";

###### Set up "update" pipeline command using -i Input -e EDITparams -g GSQparams -t GTHparams -c GFFtype  -m GSQ_CompResParameter -n GTH_CompResParameter  [-a CpGATparam] 
		$command =  "/xGDBvm/scripts/xGDB_Procedure.sh -i \"$DBid $id $input_path \"  -g \"$GSQparameter\" -t \"$GTHparameter\" -e  \"$Update_String\" -c $gff_type  -m \"$GSQ_CompResParameter\" -n \"$GTH_CompResParameter\"  $anno_option \"$CpGATparameter\" $CpGATfilter >> /tmp/log & ";		
		exec($command);
		header("Location: view.php?id=$id&result=updated");	

############### Option 3: Exit without Executing ################
		
	}else{
				
			$warning= "Could not proceed. Unable to update status";
			
#			exit();
	}
}
?>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<title>Run xGDBvm script- Error</title>
</head>

<body>
<?php echo "$command"; ?>
</body>
</html>
<?php ob_flush();?>
