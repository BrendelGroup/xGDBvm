<?php ob_start(); //This script inserts a new row in Genomes.xGDB_Log with user-input configuration data from new.php
error_reporting(E_ALL & ~E_NOTICE & ~E_WARNING); //disable undeclared variable error
include_once('/xGDBvm/XGDB/phplib/db.inc.php');
$dbpass=dbpass();
	$global_DB= 'Genomes';
	$db = mysql_connect("localhost", "gdbuser", $dbpass);
	if(!$db)
	{
		echo "Error: Could not connect to database!";
		exit;
	}
	mysql_select_db("$global_DB");
	$Config_Date = date("Y-m-d H:i:s");


####### Variables #######

			$DBname ="";
			$Organism =""; 
			$Common_Name =""; 
			$Genome_Type =""; 
			$Input_Data_Path =""; 
			$GFF_Type =""; 
			$Genome_Version ="";
			$Genome_Source =""; 
			$Genome_Source_Link =""; 
			$Genome_Count =""; 
			$Chromosome_Count =""; 
			$Unlinked_Chromosome_Count =""; 
			$Scaffold_Count =""; 
			$BAC_Count =""; 
			$Genome_Comments =""; 
			$Species_Model =""; 
			$Alignment_Stringency =""; 
			$GeneModel_Version =""; 
			$GeneModel_Source =""; 
			$GeneModel_Link =""; 
			$GeneModel_Comments =""; 
			$EST_Align_sp =""; 
			$EST_Align_Version =""; 
			$EST_Align_Comments =""; 
			$cDNA_Align_sp =""; 
			$cDNA_Align_Version =""; 
			$cDNA_Align_Comments =""; ;
			$PUT_Align_sp =""; 
			$PUT_Align_Version =""; 
			$PUT_Align_Comments =""; 
			$Prot_Align_sp ="";
			$Prot_Align_Version ="";;
			$Prot_Align_Comments ="";
			$Default_GSEG =""; 
			$Default_lpos =""; 
			$Default_rpos ="";
			$yrGATE_Reference ="";
			$yrGATE_Admin_Email =""; 
			$Update_Status =""; 
			$Update_Data_Path ="";
			$Update_Data_EST =""; 
			$Update_Data_cDNA =""; 
			$Update_Data_TrAssembly =""; 
			$Update_Data_Protein =""; 
			$Update_Data_GSEG =""; 
			$Update_Data_GeneModel ="";
			$Update_Descriptions ="";
			$Update_Comments =""; 
			$CpGAT_Status="";
			$CpGAT_ReferenceProt_File="";
			$RepeatMask_File="";
			$CpGAT_BGF="";
			$CpGAT_Augustus="";
			$CpGAT_GeneMark	="";
			$CpGAT_Skip_Mask="";
			$CpGAT_Relax_UniRef="";
			$CpGAT_Skip_PASA="";
			$CpGAT_Filter_Genes="";
			$Update_Data_CpGAT="";
			$Gth_Species_Model="";
  			$RepeatMask_Status="";
    		$GSQ_CompResources="";
    		$GSQ_Job="";
			$GTH_CompResources="";
  			$GTH_Job="";
  			$Restore_From_OtherGDB="";


##########################get posted records and update	

####### General Info #######
			$DBname = mysql_real_escape_string($_POST['DBname']);
			$DBname = preg_replace('/:/', '-', $DBname); # colon is used as sed delimiter in 'configure' script
			$Organism = mysql_real_escape_string($_POST['Organism']);
			$Common_Name = mysql_real_escape_string($_POST['Common_Name']);
			$Genome_Type = mysql_real_escape_string($_POST['Genome_Type']);
			$Input_Data_Path = mysql_real_escape_string($_POST['Input_Data_Path']);
			$GFF_Type = mysql_real_escape_string($_POST['GFF_Type']);

######## Transcript Spliced Alignment ########

			$RepeatMask_Status = mysql_real_escape_string($_POST['RepeatMask_Status']);
			$RepeatMask_File = mysql_real_escape_string($_POST['RepeatMask_File']);
			$Species_Model = mysql_real_escape_string($_POST['Species_Model']);
			$Alignment_Stringency = mysql_real_escape_string($_POST['Alignment_Stringency']);
			$GSQ_CompResources = mysql_real_escape_string($_POST['GSQ_CompResources']);

######## Protein Spliced Alignment ########

			$Gth_Species_Model = mysql_real_escape_string($_POST['Gth_Species_Model']);
			$GTH_CompResources = mysql_real_escape_string($_POST['GTH_CompResources']);

####### Configuration #########

			$Default_GSEG = mysql_real_escape_string($_POST['Default_GSEG']);
			$Default_lpos = mysql_real_escape_string($_POST['Default_lpos']);
			$Default_rpos = mysql_real_escape_string($_POST['Default_rpos']);
			$yrGATE_Reference = mysql_real_escape_string($_POST['yrGATE_Reference']);
			$yrGATE_Admin_Email = mysql_real_escape_string($_POST['yrGATE_Admin_Email']);

######## Update Info (for Example pre-loaded data only) ########

			$Update_Status = mysql_real_escape_string($_POST['Update_Status']);
			$Update_Data_Path = mysql_real_escape_string($_POST['Update_Data_Path']);
			$Update_Data_EST = mysql_real_escape_string($_POST['Update_Data_EST']);
			$Update_Data_cDNA = mysql_real_escape_string($_POST['Update_Data_cDNA']);
			$Update_Data_TrAssembly = mysql_real_escape_string($_POST['Update_Data_TrAssembly']);
			$Update_Data_Protein = mysql_real_escape_string($_POST['Update_Data_Protein']);
			$Update_Data_GSEG = mysql_real_escape_string($_POST['Update_Data_GSEG']);
			$Update_Data_GeneModel = mysql_real_escape_string($_POST['Update_Data_GeneModel']);
			$Update_Descriptions = mysql_real_escape_string($_POST['Update_Descriptions']);
			$Update_Comments = mysql_real_escape_string($_POST['Update_Comments']);

######## CpGAT Info ########

			$CpGAT_Status = mysql_real_escape_string($_POST['CpGAT_Status']);
			$CpGAT_ReferenceProt_File = mysql_real_escape_string($_POST['CpGAT_ReferenceProt_File']);
			$CpGAT_BGF = mysql_real_escape_string($_POST['CpGAT_BGF']);
			$CpGAT_Augustus = mysql_real_escape_string($_POST['CpGAT_Augustus']);
			$CpGAT_GeneMark = mysql_real_escape_string($_POST['CpGAT_GeneMark']);
			$CpGAT_Skip_Mask = mysql_real_escape_string($_POST['CpGAT_Skip_Mask']);
			$CpGAT_Relax_UniRef = mysql_real_escape_string($_POST['CpGAT_Relax_UniRef']);
			$CpGAT_Skip_PASA = mysql_real_escape_string($_POST['CpGAT_Skip_PASA']);
			$CpGAT_Filter_Genes = mysql_real_escape_string($_POST['CpGAT_Filter_Genes']);
			$Update_Data_CpGAT = mysql_real_escape_string($_POST['Update_Data_CpGAT']);

######## Genome ########

			$Genome_Version = mysql_real_escape_string($_POST['Genome_Version']);
			$Genome_Source = mysql_real_escape_string($_POST['Genome_Source']);
			$Genome_Source_Link = mysql_real_escape_string($_POST['Genome_Source_Link']);
			$Genome_Comments = mysql_real_escape_string($_POST['Genome_Comments']);

######## Genome Segments ########

			$Genome_Count = mysql_real_escape_string($_POST['Genome_Count']);
			$Chromosome_Count = mysql_real_escape_string($_POST['Chromosome_Count']);
			$Unlinked_Chromosome_Count = mysql_real_escape_string($_POST['Unlinked_Chromosome_Count']);
			$Scaffold_Count = mysql_real_escape_string($_POST['Scaffold_Count']);
			$BAC_Count = mysql_real_escape_string($_POST['BAC_Count']);

######## Gene Models ########

			$GeneModel_Version = mysql_real_escape_string($_POST['GeneModel_Version']);
			$GeneModel_Source = mysql_real_escape_string($_POST['GeneModel_Source']);
			$GeneModel_Link = mysql_real_escape_string($_POST['GeneModel_Link']);
			$GeneModel_Comments = mysql_real_escape_string($_POST['GeneModel_Comments']);

######## Transcript Alignments ########
			$GSQ_CompResources = mysql_real_escape_string($_POST['GSQ_CompResources']);
			$EST_Align_sp = mysql_real_escape_string($_POST['EST_Align_sp'])?mysql_real_escape_string($_POST['EST_Align_sp']):$Organism; //defaults to Organism
			$EST_Align_Version = mysql_real_escape_string($_POST['EST_Align_Version']);
			$EST_Align_Comments = mysql_real_escape_string($_POST['EST_Align_Comments']);
			$cDNA_Align_sp = mysql_real_escape_string($_POST['cDNA_Align_sp'])?mysql_real_escape_string($_POST['cDNA_Align_sp']):$Organism;
			$cDNA_Align_Version = mysql_real_escape_string($_POST['cDNA_Align_Version']);
			$cDNA_Align_Comments = mysql_real_escape_string($_POST['cDNA_Align_Comments']);
			$PUT_Align_sp = mysql_real_escape_string($_POST['PUT_Align_sp'])?mysql_real_escape_string($_POST['PUT_Align_sp']):$Organism;
			$PUT_Align_Version = mysql_real_escape_string($_POST['PUT_Align_Version']);
			$PUT_Align_Comments = mysql_real_escape_string($_POST['PUT_Align_Comments']);

######## Protein Alignments ########
			$GTH_CompResources = mysql_real_escape_string($_POST['GTH_CompResources']);
			$Prot_Align_sp = mysql_real_escape_string($_POST['Prot_Align_sp']);
			$Prot_Align_Version = mysql_real_escape_string($_POST['Prot_Align_Ver']);
			$Prot_Align_Comments = mysql_real_escape_string($_POST['Prot_Align_Comments']);
			
####### Make sure user-provided DBname is unique: ############

 $dbname_query = "SELECT * FROM xGDB_Log where DBname = '$DBname';";
 $check_dbname_query = mysql_query($dbname_query);
 $rows = mysql_num_rows($check_dbname_query);

 if($rows !=0){

    die('The DBname <b>\''.$DBname.'\'</b> already exists in this xGDBvm. Use the back browser button and change DBname to make it unique.');

}else{

    ## Get ID count
    $id_query="SELECT count(ID) as id_count FROM Genomes.xGDB_Log";
    $get_id_query = mysql_query($id_query);
    $id_query_result = mysql_fetch_array($get_id_query);
    $id_count=$id_query_result['id_count'];

	####### Insert values #######
	
	mysql_select_db("$global_DB");
	$query = "INSERT INTO xGDB_Log SET
	DBname='$DBname',
	Organism='$Organism',
	Common_Name='$Common_Name',
	Status='Development',
	Genome_Type='$Genome_Type',
	Config_Date='$Config_Date',
	Input_Data_Path='$Input_Data_Path',
	GFF_Type='$GFF_Type',
	Genome_Version='$Genome_Version',
	Genome_Source='$Genome_Source',
	Genome_Source_Link='$Genome_Source_Link',
	Genome_Count='$Genome_Count',
	Chromosome_Count='$Chromosome_Count',
	Unlinked_Chromosome_Count='$Unlinked_Chromosome_Count',
	Scaffold_Count='$Scaffold_Count',
	BAC_Count='$BAC_Count',
	Genome_Comments='$Genome_Comments',
	GeneModel_Version='$GeneModel_Version',
	GeneModel_Source='$GeneModel_Source',
	GeneModel_Link='$GeneModel_Link',
	GeneModel_Comments='$GeneModel_Comments',
	EST_Align_sp='$EST_Align_sp',
	EST_Align_Version='$EST_Align_Version',
	EST_Align_Comments='$EST_Align_Comments',
	cDNA_Align_sp='$cDNA_Align_sp',
	cDNA_Align_Version='$cDNA_Align_Version',
	cDNA_Align_Comments='$cDNA_Align_Comments',
	PUT_Align_sp='$PUT_Align_sp',
	PUT_Align_Version='$PUT_Align_Version',
	PUT_Align_Comments='$PUT_Align_Comments',
	Prot_Align_sp='$Prot_Align_sp',
	Prot_Align_Version='$Prot_Align_Version',
	Prot_Align_Comments='$Prot_Align_Comments',
	Default_GSEG='$Default_GSEG',
	Default_lpos='$Default_lpos',
	Default_rpos='$Default_rpos',
	yrGATE_Reference='$yrGATE_Reference',
	yrGATE_Admin_Email='$yrGATE_Admin_Email',
	Species_Model='$Species_Model',
	Alignment_Stringency='$Alignment_Stringency',
	Update_Status='$Update_Status',
	Update_Data_Path='$Update_Data_Path',
	Update_Data_EST='$Update_Data_EST',
	Update_Data_cDNA='$Update_Data_cDNA',
	Update_Data_TrAssembly='$Update_Data_TrAssembly',
	Update_Data_Protein='$Update_Data_Protein',
	Update_Data_GSEG='$Update_Data_GSEG',
	Update_Data_GeneModel='$Update_Data_GeneModel',
	Update_Comments='$Update_Comments',
	CpGAT_Status='$CpGAT_Status',
	CpGAT_ReferenceProt_File='$CpGAT_ReferenceProt_File',
	RepeatMask_File='$RepeatMask_File',
	CpGAT_BGF='$CpGAT_BGF',
	CpGAT_Augustus='$CpGAT_Augustus',
	CpGAT_GeneMark	='$CpGAT_GeneMark',
	CpGAT_Skip_Mask='$CpGAT_Skip_Mask',
	CpGAT_Relax_UniRef='$CpGAT_Relax_UniRef',
	CpGAT_Skip_PASA='$CpGAT_Skip_PASA',
	CpGAT_Filter_Genes='$CpGAT_Filter_Genes',
	Update_Data_CpGAT='$Update_Data_CpGAT',
	Gth_Species_Model='$Gth_Species_Model',
	RepeatMask_Status='$RepeatMask_Status',
	GSQ_CompResources='$GSQ_CompResources',
	GTH_CompResources='$GTH_CompResources'
	";
	
	
	
				
				
	$success = mysql_query($query);
	echo $success;
	
	$redirect_query = "select ID from $global_DB.xGDB_Log order by ID DESC limit 1";
	$check_redirect = mysql_query($redirect_query);
	$n = mysql_num_rows($check_redirect);
	$new_id_array = mysql_fetch_array($check_redirect);
	$new_id = $new_id_array['ID'];
	if($n==0)
		{
			header("Location: view.php");
		}
	else 
		{
			header("Location: view.php?id=".$new_id);
		}
	
	exit();
	#} # end check for unique DBname
}
?>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<title>Add xGDBvm- Error</title>
</head>

<body>
<?php echo "$warning"; ?>
</body>
</html>
<?php ob_flush();?>

