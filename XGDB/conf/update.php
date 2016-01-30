<?php ob_start(); //This script updates Genomes.xGDB_Log with user-input configuration data from view.php
session_start();
include('sitedef.php');
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
	$error = $_GET['error'];

date_default_timezone_set("$TIMEZONE");

///////////////				get old records				//////////////////

$id = mysql_real_escape_string($_POST['id']);
$get_record = "select * from xGDB_Log where id = '$id'";
$check_get_record = mysql_query($get_record);
$update="F"; //flag for update

while ($data = mysql_fetch_array($check_get_record)){ 

####### Database Info #######
		$ID=$id; # post or get value
		$DBname=$data["DBname"]; # e.g. AtGDB
		$Organism=$data["Organism"];
		$Common_Name=$data["Common_Name"];
		$Status=$data["Status"];
		$Genome_Type=$data["Genome_Type"];
		$GFF_Type=$data["GFF_Type"];
#		$Config_Date=$data["Config_Date"]; # Don't need this from database, it's updated if any records are altered.

####### Input Datsa #######
		$Input_Data_Path=$data["Input_Data_Path"];
		$Create_Date=$data["Create_Date"]; # Date of creation or last update

######## Transcript Spliced Alignment #######
		$RepeatMask_Status=$data["RepeatMask_Status"]; # 
		$RepeatMask_File=$data["RepeatMask_File"]; # 
		$Species_Model=$data["Species_Model"];
		$Alignment_Stringency=$data["Alignment_Stringency"];
		$GSQ_CompResources=$data["GSQ_CompResources"];

######## Protein Spliced Alignment ########
		$Gth_Species_Model=$data["Gth_Species_Model"];
		$GTH_CompResources=$data["GTH_CompResources"];
		$GTH_Job=$data["GTH_Job"];

######## Gene Prediction ########
		$CpGAT_Status=$data["CpGAT_Status"];
		$CpGAT_ReferenceProt_File=$data["CpGAT_ReferenceProt_File"];
		$CpGAT_GSEG=$data["CpGAT_GSEG"];
		$CpGAT_BGF=$data["CpGAT_BGF"];
		$CpGAT_Augustus=$data["CpGAT_Augustus"];
		$CpGAT_GeneMark=$data["CpGAT_GeneMark"];
		$CpGAT_Skip_Mask=$data["CpGAT_Skip_Mask"];
		$CpGAT_Relax_UniRef=$data["CpGAT_Relax_UniRef"];
		$CpGAT_Skip_PASA=$data["CpGAT_Skip_PASA"];
		$CpGAT_Filter_Genes=$data["CpGAT_Filter_Genes"];

####### Database Update #######
		$Update_Status=$data["Update_Status"]; # 
		$Update_Data_Path=$data["Update_Data_Path"]; # ADDED 3/19/15. Not sure why it was missing before.
		$Update_Data_EST=$data["Update_Data_EST"]; # 
		$Update_Data_cDNA=$data["Update_Data_cDNA"]; # 
		$Update_Data_TrAssembly=$data["Update_Data_TrAssembly"]; # 
		$Update_Data_Protein=$data["Update_Data_Protein"]; # 
		$Update_Data_GSEG=$data["Update_Data_GSEG"]; # 
		$Update_Data_CpGAT=$data["Update_Data_CpGAT"]; # 
		$Update_Data_GeneModel=$data["Update_Data_GeneModel"]; # 
		$Update_Data_CpGATModel=$data["Update_Data_CpGATModel"]; # 
		$Update_Descriptions=$data["Update_Descriptions"]; # 
		$Update_Comments=$data["Update_Comments"]; # 
		

######## Genome ########
		$Genome_Version=$data["Genome_Version"]; 
		$Genome_Source=$data["Genome_Source"]; 
      	$Genome_Source_Link=$data["Genome_Source_Link"];
 		$Genome_Comments=$data["Genome_Comments"];
    	$Masking=$data["Masking"];
 		$Genome_Count=$data["Genome_Count"];
  		$Chromosome_Count=$data["Chromosome_Count"];
  		$Unlinked_Chromosome_Count=$data["Unlinked_Chromosome_Count"];
 		$Scaffold_Count=$data["Scaffold_Count"];
 		$BAC_Count=$data["BAC_Count"];


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

######## Configuration Info ########
        $Default_GSEG=$data["Default_GSEG"];
        $Default_lpos=$data["Default_lpos"];
        $Default_rpos=$data["Default_rpos"];
        $yrGATE_Reference=$data["yrGATE_Reference"];
		$yrGATE_Admin_Email=$data["yrGATE_Admin_Email"];

	}	
///////////////				compare to new records		////////////////////

#$DBname = mysql_real_escape_string($_POST['DBname']);

### Note: null values not being passed Try something like this: http://www.phpbuilder.com/board/showthread.php?t=10362086


####### General Info #######

				if (mysql_real_escape_string($_POST['DBname']) != $DBname){
				$DBname = mysql_real_escape_string($_POST['DBname']);
			    $DBname = preg_replace('/:/', '-', $DBname); # colon is used as sed delimiter in 'configure' script
			    
####### First make sure user-edited DBname is unique: ############

				 $dbname_query = "SELECT * FROM xGDB_Log where DBname = '$DBname';";
				 $check_dbname_query = mysql_query($dbname_query);
				 $rows = mysql_num_rows($check_dbname_query);
				
				 if($rows !=0){
				
					die('The DBname <b>\''.$DBname.'\'</b> already exists in this xGDBvm. Use the back browser button and change DBname to make it unique.');
				
				}else{
					$update_DBname = "update xGDB_Log set DBname = '$DBname' where ID = $ID";
					$check_update_DBname = mysql_query($update_DBname);
					$update="T";
					}
				}
				
####### Proceed to General Database Info ###########

				if (mysql_real_escape_string($_POST['Status']) != $Status){
				$Status = mysql_real_escape_string($_POST['Status']);
				$update_Status = "update xGDB_Log set Status = '$Status' where ID = $ID";
				$check_update_Status = mysql_query($update_Status);
				$update="T";
				}		
				
				if (mysql_real_escape_string($_POST['Organism']) != $Organism){
				$Organism = mysql_real_escape_string($_POST['Organism']);
				$update_Organism = "update xGDB_Log set Organism = '$Organism' where ID = $ID";
				$check_update_Organism = mysql_query($update_Organism);
				$update="T";
				}
				
				if (mysql_real_escape_string($_POST['Common_Name']) != $Common_Name){
				$Common_Name = mysql_real_escape_string($_POST['Common_Name']);
				$update_Common_Name = "update xGDB_Log set Common_Name = '$Common_Name' where ID = $ID";
				$check_update_Common_Name = mysql_query($update_Common_Name);
				$update="T";
				}
			
				if (mysql_real_escape_string($_POST['Genome_Type']) != $Genome_Type){
				$Genome_Type = mysql_real_escape_string($_POST['Genome_Type']);
				$update_Genome_Type = "update xGDB_Log set Genome_Type = '$Genome_Type' where ID = $ID";
				$check_update_Genome_Type = mysql_query($update_Genome_Type);
				$update="T";
				}

####### Input Data  #######
				if (mysql_real_escape_string($_POST['Input_Data_Path']) != $Input_Data_Path){
				$Input_Data_Path = mysql_real_escape_string($_POST['Input_Data_Path']);
				$update_Input_Data_Path = "update xGDB_Log set Input_Data_Path = '$Input_Data_Path' where ID = $ID";
				$check_update_Input_Data_Path = mysql_query($update_Input_Data_Path);
				$update="T";
				}
				if (mysql_real_escape_string($_POST['GFF_Type']) != $GFF_Type){
				$GFF_Type = mysql_real_escape_string($_POST['GFF_Type']);
				$update_GFF_Type = "update xGDB_Log set GFF_Type = '$GFF_Type' where ID = $ID";
				$check_update_GFF_Type = mysql_query($update_GFF_Type);
				$update="T";
				}

####### Spliced Alignment (GSQ)  #######

				if (mysql_real_escape_string($_POST['RepeatMask_Status']) != $RepeatMask_Status){
				$RepeatMask_Status = mysql_real_escape_string($_POST['RepeatMask_Status']);
				$update_RepeatMask_Status = "update xGDB_Log set RepeatMask_Status = '$RepeatMask_Status' where ID = $ID";
				$check_update_RepeatMask_Status = mysql_query($update_RepeatMask_Status);
				$update="T";
				}
				if (mysql_real_escape_string($_POST['RepeatMask_File']) != $RepeatMask_File){
				$RepeatMask_File = mysql_real_escape_string($_POST['RepeatMask_File']);
				$update_RepeatMask_File = "update xGDB_Log set RepeatMask_File = '$RepeatMask_File' where ID = $ID";
				$check_update_RepeatMask_File = mysql_query($update_RepeatMask_File);
				$update="T";
				}
				if (mysql_real_escape_string($_POST['Species_Model']) != $Species_Model){
				$Species_Model = mysql_real_escape_string($_POST['Species_Model']);
				$update_Species_Model = "update xGDB_Log set Species_Model = '$Species_Model' where ID = $ID";
				$check_update_Species_Model = mysql_query($update_Species_Model);
				$update="T";
				}
				if (mysql_real_escape_string($_POST['Alignment_Stringency']) != $Alignment_Stringency){
				$Alignment_Stringency = mysql_real_escape_string($_POST['Alignment_Stringency']);
				$update_Alignment_Stringency = "update xGDB_Log set Alignment_Stringency = '$Alignment_Stringency' where ID = $ID";
				$check_update_Alignment_Stringency= mysql_query($update_Alignment_Stringency);
				$update="T";
				}
				if (mysql_real_escape_string($_POST['GSQ_CompResources']) != $GSQ_CompResources){
				$GSQ_CompResources = mysql_real_escape_string($_POST['GSQ_CompResources']);
				$update_GSQ_CompResources = "update xGDB_Log set GSQ_CompResources = '$GSQ_CompResources' where ID = $ID";
				$check_update_GSQ_CompResources = mysql_query($update_GSQ_CompResources);
				$update="T";
				}
####### Spliced Alignment (GTH)  #######
				if (mysql_real_escape_string($_POST['Gth_Species_Model']) != $Gth_Species_Model){
				$Gth_Species_Model = mysql_real_escape_string($_POST['Gth_Species_Model']);
				$update_Gth_Species_Model = "update xGDB_Log set Gth_Species_Model = '$Gth_Species_Model' where ID = $ID";
				$check_update_Gth_Species_Model= mysql_query($update_Gth_Species_Model);
				$update="T";
				}
				if (mysql_real_escape_string($_POST['GTH_CompResources']) != $GTH_CompResources){
				$GTH_CompResources = mysql_real_escape_string($_POST['GTH_CompResources']);
				$update_GTH_CompResources = "update xGDB_Log set GTH_CompResources = '$GTH_CompResources' where ID = $ID";
				$check_update_GTH_CompResources = mysql_query($update_GTH_CompResources);
				$update="T";
				}
####### Gene Prediction  #######

				if (mysql_real_escape_string($_POST['CpGAT_Status']) != $CpGAT_Status){
				$CpGAT_Status = mysql_real_escape_string($_POST['CpGAT_Status']);
				$update_CpGAT_Status = "update xGDB_Log set CpGAT_Status = '$CpGAT_Status' where ID = $ID";
				$check_update_CpGAT_Status = mysql_query($update_CpGAT_Status);
				$update="T";
				}
				if (mysql_real_escape_string($_POST['CpGAT_ReferenceProt_File']) != $CpGAT_ReferenceProt_File){
				$CpGAT_ReferenceProt_File = mysql_real_escape_string($_POST['CpGAT_ReferenceProt_File']);
				$update_CpGAT_ReferenceProt_File = "update xGDB_Log set CpGAT_ReferenceProt_File = '$CpGAT_ReferenceProt_File' where ID = $ID";
				$check_update_CpGAT_ReferenceProt_File = mysql_query($update_CpGAT_ReferenceProt_File);
				$update="T";
				}
				if (mysql_real_escape_string($_POST['CpGAT_BGF']) != $CpGAT_BGF){
				$CpGAT_BGF = mysql_real_escape_string($_POST['CpGAT_BGF']);
				$update_CpGAT_BGF = "update xGDB_Log set CpGAT_BGF = '$CpGAT_BGF' where ID = $ID";
				$check_update_CpGAT_BGF = mysql_query($update_CpGAT_BGF);
				$update="T";
				}
				if (mysql_real_escape_string($_POST['CpGAT_Augustus']) != $CpGAT_Augustus){
				$CpGAT_Augustus = mysql_real_escape_string($_POST['CpGAT_Augustus']);
				$update_CpGAT_Augustus = "update xGDB_Log set CpGAT_Augustus = '$CpGAT_Augustus' where ID = $ID";
				$check_update_CpGAT_Augustus = mysql_query($update_CpGAT_Augustus);
				$update="T";
				}
				if (mysql_real_escape_string($_POST['CpGAT_GeneMark']) != $CpGAT_GeneMark){
				$CpGAT_GeneMark = mysql_real_escape_string($_POST['CpGAT_GeneMark']);
				$update_CpGAT_GeneMark = "update xGDB_Log set CpGAT_GeneMark = '$CpGAT_GeneMark' where ID = $ID";
				$check_update_CpGAT_GeneMark = mysql_query($update_CpGAT_GeneMark);
				$update="T";
				}
				if (mysql_real_escape_string($_POST['CpGAT_Skip_Mask']) != $CpGAT_Skip_Mask){
				$CpGAT_Skip_Mask = mysql_real_escape_string($_POST['CpGAT_Skip_Mask']);
				$update_CpGAT_Skip_Mask = "update xGDB_Log set CpGAT_Skip_Mask = '$CpGAT_Skip_Mask' where ID = $ID";
				$check_update_CpGAT_Skip_Mask = mysql_query($update_CpGAT_Skip_Mask);
				$update="T";
				}
				if (mysql_real_escape_string($_POST['CpGAT_Relax_UniRef']) != $CpGAT_Relax_UniRef){
				$CpGAT_Relax_UniRef = mysql_real_escape_string($_POST['CpGAT_Relax_UniRef']);
				$update_CpGAT_Relax_UniRef = "update xGDB_Log set CpGAT_Relax_UniRef = '$CpGAT_Relax_UniRef' where ID = $ID";
				$check_update_CpGAT_Relax_UniRef = mysql_query($update_CpGAT_Relax_UniRef);
				$update="T";
				}
				if (mysql_real_escape_string($_POST['CpGAT_Skip_PASA']) != $CpGAT_Skip_PASA){
				$CpGAT_Skip_PASA = mysql_real_escape_string($_POST['CpGAT_Skip_PASA']);
				$update_CpGAT_Skip_PASA = "update xGDB_Log set CpGAT_Skip_PASA = '$CpGAT_Skip_PASA' where ID = $ID";
				$check_update_CpGAT_Skip_PASA = mysql_query($update_CpGAT_Skip_PASA);
				$update="T";
				}
				if (mysql_real_escape_string($_POST['CpGAT_Filter_Genes']) != $CpGAT_Filter_Genes){
				$CpGAT_Filter_Genes = mysql_real_escape_string($_POST['CpGAT_Filter_Genes']);
				$update_CpGAT_Filter_Genes = "update xGDB_Log set CpGAT_Filter_Genes = '$CpGAT_Filter_Genes' where ID = $ID";
				$check_update_CpGAT_Filter_Genes = mysql_query($update_CpGAT_Filter_Genes);
				$update="T";
				}

####### Database Update  #######

				if (mysql_real_escape_string($_POST['Update_Status']) != $Update_Status){
				$Update_Status = mysql_real_escape_string($_POST['Update_Status']);
				$update_Update_Status = "update xGDB_Log set Update_Status = '$Update_Status' where ID = $ID";
				$check_update_Update_Status = mysql_query($update_Update_Status);
				$update="T";
				}

				if (mysql_real_escape_string($_POST['Update_Data_EST']) != $Update_Data_EST){
				$Update_Data_EST = mysql_real_escape_string($_POST['Update_Data_EST']);
				$update_Update_Data_EST = "update xGDB_Log set Update_Data_EST = '$Update_Data_EST' where ID = $ID";
				$check_update_Update_Data_EST = mysql_query($update_Update_Data_EST);
				$update="T";
				}
				if (mysql_real_escape_string($_POST['Update_Data_cDNA']) != $Update_Data_cDNA){
				$Update_Data_cDNA = mysql_real_escape_string($_POST['Update_Data_cDNA']);
				$update_Update_Data_cDNA = "update xGDB_Log set Update_Data_cDNA = '$Update_Data_cDNA' where ID = $ID";
				$check_update_Update_Data_cDNA = mysql_query($update_Update_Data_cDNA);
				$update="T";
				}
				if (mysql_real_escape_string($_POST['Update_Data_TrAssembly']) != $Update_Data_TrAssembly){
				$Update_Data_TrAssembly = mysql_real_escape_string($_POST['Update_Data_TrAssembly']);
				$update_Update_Data_TrAssembly = "update xGDB_Log set Update_Data_TrAssembly = '$Update_Data_TrAssembly' where ID = $ID";
				$check_update_Update_Data_TrAssembly = mysql_query($update_Update_Data_TrAssembly);
				$update="T";
				}
				if (mysql_real_escape_string($_POST['Update_Data_Protein']) != $Update_Data_Protein){
				$Update_Data_Protein = mysql_real_escape_string($_POST['Update_Data_Protein']);
				$update_Update_Data_Protein = "update xGDB_Log set Update_Data_Protein = '$Update_Data_Protein' where ID = $ID";
				$check_update_Update_Data_Protein = mysql_query($update_Update_Data_Protein);
				$update="T";
				}
				if (mysql_real_escape_string($_POST['Update_Data_GSEG']) != $Update_Data_GSEG){
				$Update_Data_GSEG = mysql_real_escape_string($_POST['Update_Data_GSEG']);
				$update_Update_Data_GSEG = "update xGDB_Log set Update_Data_GSEG = '$Update_Data_GSEG' where ID = $ID";
				$check_update_Update_Data_GSEG = mysql_query($update_Update_Data_GSEG);
				$update="T";
				}
				if (mysql_real_escape_string($_POST['Update_Data_GeneModel']) != $Update_Data_GeneModel){
				$Update_Data_GeneModel = mysql_real_escape_string($_POST['Update_Data_GeneModel']);
				$update_Update_Data_GeneModel = "update xGDB_Log set Update_Data_GeneModel = '$Update_Data_GeneModel' where ID = $ID";
				$check_update_Update_Data_GeneModel = mysql_query($update_Update_Data_GeneModel);
				$update="T";
				}
				if (mysql_real_escape_string($_POST['Update_Data_CpGATModel']) != $Update_Data_CpGATModel){
				$Update_Data_CpGATModel = mysql_real_escape_string($_POST['Update_Data_CpGATModel']);
				$update_Update_Data_CpGATModel = "update xGDB_Log set Update_Data_CpGATModel = '$Update_Data_CpGATModel' where ID = $ID";
				$check_update_Update_Data_CpGATModel = mysql_query($update_Update_Data_CpGATModel);
				$update="T";
				}
				if (mysql_real_escape_string($_POST['Update_Descriptions']) != $Update_Descriptions){
				$Update_Descriptions = mysql_real_escape_string($_POST['Update_Descriptions']);
				$update_Update_Descriptions = "update xGDB_Log set Update_Descriptions = '$Update_Descriptions' where ID = $ID";
				$check_update_Update_Descriptions = mysql_query($update_Update_Descriptions);
				$update="T";
				}
				if (mysql_real_escape_string($_POST['Update_Data_Path']) != $Update_Data_Path){
				$Update_Data_Path = mysql_real_escape_string($_POST['Update_Data_Path']);
				$update_Update_Data_Path = "update xGDB_Log set Update_Data_Path = '$Update_Data_Path' where ID = $ID";
				$check_update_Update_Data_Path = mysql_query($update_Update_Data_Path);
				$update="T";
				}
				if (mysql_real_escape_string($_POST['Update_Data_CpGAT']) != $Update_Data_CpGAT){
				$Update_Data_CpGAT = mysql_real_escape_string($_POST['Update_Data_CpGAT']);
				$update_Update_Data_CpGAT = "update xGDB_Log set Update_Data_CpGAT = '$Update_Data_CpGAT' where ID = $ID";
				$check_update_Update_Data_CpGAT = mysql_query($update_Update_Data_CpGAT);
				$update="T";
				}
				if (mysql_real_escape_string($_POST['Update_Comments']) != $Update_Comments){
				$Update_Comments = mysql_real_escape_string($_POST['Update_Comments']);
				$update_Update_Comments = "update xGDB_Log set Update_Comments = '$Update_Comments' where ID = $ID";
				$check_update_Update_Comments = mysql_query($update_Update_Comments);
				$update="T";
				}


				
	######## Genome Metadata ########
	
				if (mysql_real_escape_string($_POST['Genome_Version']) != $Genome_Version){
				$Genome_Version = mysql_real_escape_string($_POST['Genome_Version']);
				$update_Genome_Version = "update xGDB_Log set Genome_Version = '$Genome_Version' where ID = $ID";
				$check_update_Genome_Version = mysql_query($update_Genome_Version);
				$update="T";
				}
	
				if (mysql_real_escape_string($_POST['Genome_Source']) != $Genome_Source){
				$Genome_Source = mysql_real_escape_string($_POST['Genome_Source']);
				$update_Genome_Source = "update xGDB_Log set Genome_Source = '$Genome_Source' where ID = $ID";
				$check_update_Genome_Source = mysql_query($update_Genome_Source);
				$update="T";
				}
				
				if (mysql_real_escape_string($_POST['Genome_Source_Link']) != $Genome_Source_Link){
				$Genome_Source_Link = mysql_real_escape_string($_POST['Genome_Source_Link']);
				$update_Genome_Source_Link = "update xGDB_Log set Genome_Source_Link = '$Genome_Source_Link' where ID = $ID";
				$check_update_Genome_Source_Link = mysql_query($update_Genome_Source_Link);
				$update="T";
				}

				if (mysql_real_escape_string($_POST['Genome_Count']) != $Genome_Count){
				$Genome_Count = mysql_real_escape_string($_POST['Genome_Count']);
				$update_Genome_Count = "update xGDB_Log set Genome_Count = '$Genome_Count' where ID = $ID";
				$check_update_Genome_Count = mysql_query($update_Genome_Count);
				$update="T";
				}
	
				if (mysql_real_escape_string($_POST['Chromosome_Count']) != $Chromosome_Count){
				$Chromosome_Count = mysql_real_escape_string($_POST['Chromosome_Count']);
				$update_Chromosome_Count = "update xGDB_Log set Chromosome_Count = '$Chromosome_Count' where ID = $ID";
				$check_update_Chromosome_Count = mysql_query($update_Chromosome_Count);
				$update="T";
				}
	
				
				if (mysql_real_escape_string($_POST['Unlinked_Chromosome_Count']) != $Unlinked_Chromosome_Count){
				$Unlinked_Chromosome_Count = mysql_real_escape_string($_POST['Unlinked_Chromosome_Count']);
				$update_Unlinked_Chromosome_Count = "update xGDB_Log set Unlinked_Chromosome_Count = '$Unlinked_Chromosome_Count' where ID = $ID";
				$check_update_Unlinked_Chromosome_Count = mysql_query($update_Unlinked_Chromosome_Count);
				$update="T";
				}
	
	
				
				if (mysql_real_escape_string($_POST['Scaffold_Count']) != $Scaffold_Count){
				$Scaffold_Count = mysql_real_escape_string($_POST['Scaffold_Count']);
				$update_Scaffold_Count = "update xGDB_Log set Scaffold_Count = '$Scaffold_Count' where ID = $ID";
				$check_update_Scaffold_Count = mysql_query($update_Scaffold_Count);
				$update="T";
				}
	
	
				
				if (mysql_real_escape_string($_POST['BAC_Count']) != $BAC_Count){
				$BAC_Count = mysql_real_escape_string($_POST['BAC_Count']);
				$update_BAC_Count = "update xGDB_Log set BAC_Count = '$BAC_Count' where ID = $ID";
				$check_update_BAC_Count = mysql_query($update_BAC_Count);
				$update="T";
				}
	
				
				if (mysql_real_escape_string($_POST['Genome_Comments']) != $Genome_Comments){
				$Genome_Comments = mysql_real_escape_string($_POST['Genome_Comments']);
				$update_Genome_Comments = "update xGDB_Log set Genome_Comments = '$Genome_Comments' where ID = $ID";
				$check_update_Genome_Comments = mysql_query($update_Genome_Comments);
				$update="T";
				}
	
	######## Gene Models ########
	
				
				if (mysql_real_escape_string($_POST['GeneModel_Version']) != $GeneModel_Version){
				$GeneModel_Version = mysql_real_escape_string($_POST['GeneModel_Version']);
				$update_GeneModel_Version = "update xGDB_Log set GeneModel_Version = '$GeneModel_Version' where ID = $ID";
				$check_update_GeneModel_Version = mysql_query($update_GeneModel_Version);
				$update="T";
				}
	
	
				
				if (mysql_real_escape_string($_POST['GeneModel_Source']) != $GeneModel_Source){
				$GeneModel_Source = mysql_real_escape_string($_POST['GeneModel_Source']);
				$update_GeneModel_Source = "update xGDB_Log set GeneModel_Source = '$GeneModel_Source' where ID = $ID";
				$check_update_GeneModel_Source = mysql_query($update_GeneModel_Source);
				$update="T";
				}
	
	
				
				if (mysql_real_escape_string($_POST['GeneModel_Link']) != $GeneModel_Link){
				$GeneModel_Link = mysql_real_escape_string($_POST['GeneModel_Link']);
				$update_GeneModel_Link = "update xGDB_Log set GeneModel_Link = '$GeneModel_Link' where ID = $ID";
				$check_update_GeneModel_Link = mysql_query($update_GeneModel_Link);
				$update="T";
				}
	
				if (mysql_real_escape_string($_POST['GeneModel_Comments']) != $GeneModel_Comments){
				$GeneModel_Comments = mysql_real_escape_string($_POST['GeneModel_Comments']);
				$update_GeneModel_Comments = "update xGDB_Log set GeneModel_Comments = '$GeneModel_Comments' where ID = $ID";
				$check_update_GeneModel_Comments = mysql_query($update_GeneModel_Comments);
				$update="T";
				}
			
	######## Alignment Info ########
	
				if (mysql_real_escape_string($_POST['EST_Align_sp']) != $EST_Align_sp){
				$EST_Align_sp = mysql_real_escape_string($_POST['EST_Align_sp']);
				$update_EST_Align_sp = "update xGDB_Log set EST_Align_sp = '$EST_Align_sp' where ID = $ID";
				$check_update_EST_Align_sp = mysql_query($update_EST_Align_sp);
				$update="T";
				}
	
				if (mysql_real_escape_string($_POST['EST_Align_Version']) != $EST_Align_Version){
				$EST_Align_Version = mysql_real_escape_string($_POST['EST_Align_Version']);
				$update_EST_Align_Version = "update xGDB_Log set EST_Align_Version = '$EST_Align_Version' where ID = $ID";
				$check_update_EST_Align_Version = mysql_query($update_EST_Align_Version);
				$update="T";
				}
			
	
				if (mysql_real_escape_string($_POST['EST_Align_Comments']) != $EST_Align_Comments){
				$EST_Align_Comments = mysql_real_escape_string($_POST['EST_Align_Comments']);
				$update_EST_Align_Comments = "update xGDB_Log set EST_Align_Comments = '$EST_Align_Comments' where ID = $ID";
				$check_update_EST_Align_Comments = mysql_query($update_EST_Align_Comments);
				$update="T";
				}
			
				if (mysql_real_escape_string($_POST['cDNA_Align_sp']) != $cDNA_Align_sp){
				$cDNA_Align_sp = mysql_real_escape_string($_POST['cDNA_Align_sp']);
				$update_cDNA_Align_sp = "update xGDB_Log set cDNA_Align_sp = '$cDNA_Align_sp' where ID = $ID";
				$check_update_cDNA_Align_sp = mysql_query($update_cDNA_Align_sp);
				$update="T";
				}
	
				if (mysql_real_escape_string($_POST['cDNA_Align_Version']) != $cDNA_Align_Version){
				$cDNA_Align_Version = mysql_real_escape_string($_POST['cDNA_Align_Version']);
				$update_cDNA_Align_Version = "update xGDB_Log set cDNA_Align_Version = '$cDNA_Align_Version' where ID = $ID";
				$check_update_cDNA_Align_Version = mysql_query($update_cDNA_Align_Version);
				$update="T";
				}
			
	
				if (mysql_real_escape_string($_POST['cDNA_Align_Comments']) != $cDNA_Align_Comments){
				$cDNA_Align_Comments = mysql_real_escape_string($_POST['cDNA_Align_Comments']);
				$update_cDNA_Align_Comments = "update xGDB_Log set cDNA_Align_Comments = '$cDNA_Align_Comments' where ID = $ID";
				$check_update_cDNA_Align_Comments = mysql_query($update_cDNA_Align_Comments);
				$update="T";
				}
	
				if (mysql_real_escape_string($_POST['PUT_Align_sp']) != $PUT_Align_sp){
				$PUT_Align_sp = mysql_real_escape_string($_POST['PUT_Align_sp']);
				$update_PUT_Align_sp = "update xGDB_Log set PUT_Align_sp = '$PUT_Align_sp' where ID = $ID";
				$check_update_PUT_Align_sp = mysql_query($update_PUT_Align_sp);
				$update="T";
				}
	
				if (mysql_real_escape_string($_POST['PUT_Align_Version']) != $PUT_Align_Version){
				$PUT_Align_Version = mysql_real_escape_string($_POST['PUT_Align_Version']);
				$update_PUT_Align_Version = "update xGDB_Log set PUT_Align_Version = '$PUT_Align_Version' where ID = $ID";
				$check_update_PUT_Align_Version = mysql_query($update_PUT_Align_Version);
				$update="T";
				}
			
	
				if (mysql_real_escape_string($_POST['PUT_Align_Comments']) != $PUT_Align_Comments){
				$PUT_Align_Comments = mysql_real_escape_string($_POST['PUT_Align_Comments']);
				$update_PUT_Align_Comments = "update xGDB_Log set PUT_Align_Comments = '$PUT_Align_Comments' where ID = $ID";
				$check_update_PUT_Align_Comments = mysql_query($update_PUT_Align_Comments);
				$update="T";
				}
				
			
				if (mysql_real_escape_string($_POST['Prot_Align_sp']) != $Prot_Align_sp){
				$Prot_Align_sp = mysql_real_escape_string($_POST['Prot_Align_sp']);
				$update_Prot_Align_sp = "update xGDB_Log set Prot_Align_sp = '$Prot_Align_sp' where ID = $ID";
				$check_update_Prot_Align_sp = mysql_query($update_Prot_Align_sp);
				$update="T";
				}
	
				if (mysql_real_escape_string($_POST['Prot_Align_Version']) != $Prot_Align_Version){
				$Prot_Align_Version = mysql_real_escape_string($_POST['Prot_Align_Version']);
				$update_Prot_Align_Version = "update xGDB_Log set Prot_Align_Version = '$Prot_Align_Version' where ID = $ID";
				$check_update_Prot_Align_Version = mysql_query($update_Prot_Align_Version);
				$update="T";
				}
	
				if (mysql_real_escape_string($_POST['Prot_Align_Comments']) != $Prot_Align_Comments){
				$Prot_Align_Comments = mysql_real_escape_string($_POST['Prot_Align_Comments']);
				$update_Prot_Align_Comments = "update xGDB_Log set Prot_Align_Comments = '$Prot_Align_Comments' where ID = $ID";
				$check_update_Prot_Align_Comments = mysql_query($update_Prot_Align_Comments);
				$update="T";
				}

	### Configuration defaults ###
	
				if (mysql_real_escape_string($_POST['Default_GSEG']) != $Default_GSEG){
				$Default_GSEG = mysql_real_escape_string($_POST['Default_GSEG']);
				$update_Default_GSEG = "update xGDB_Log set Default_GSEG = '$Default_GSEG' where ID = $ID";
				$check_update_Default_GSEG = mysql_query($update_Default_GSEG);
				$update="T";
				}
			
	
	
				if (mysql_real_escape_string($_POST['Default_lpos']) != $Default_lpos){
				$Default_lpos = mysql_real_escape_string($_POST['Default_lpos']);
				$update_Default_lpos = "update xGDB_Log set Default_lpos = '$Default_lpos' where ID = $ID";
				$check_update_Default_lpos = mysql_query($update_Default_lpos);
				$update="T";
				}
			
	
				if (mysql_real_escape_string($_POST['Default_rpos']) != $Default_rpos){
				$Default_rpos = mysql_real_escape_string($_POST['Default_rpos']);
				$update_Default_rpos = "update xGDB_Log set Default_rpos = '$Default_rpos' where ID = $ID";
				$check_update_Default_rpos = mysql_query($update_Default_rpos);
				$update="T";
				}

				if (mysql_real_escape_string($_POST['yrGATE_Reference']) != $yrGATE_Reference){
				$yrGATE_Reference = mysql_real_escape_string($_POST['yrGATE_Reference']);
				$update_yrGATE_Reference = "update xGDB_Log set yrGATE_Reference = '$yrGATE_Reference' where ID = $ID";
				$check_update_yrGATE_Reference = mysql_query($update_yrGATE_Reference);
				$update="T";
				}


				if (mysql_real_escape_string($_POST['yrGATE_Admin_Email']) != $yrGATE_Admin_Email){
				$yrGATE_Admin_Email = mysql_real_escape_string($_POST['yrGATE_Admin_Email']);
				$update_yrGATE_Admin_Email = "update xGDB_Log set yrGATE_Admin_Email = '$yrGATE_Admin_Email' where ID = $ID";
				$check_update_yrGATE_Admin_Email = mysql_query($update_yrGATE_Admin_Email);
				$update="T";
				}

       ### if any column is updated, create date stamp
				if($update == "T"){
				$Config_Date = date("Y-m-d H:i:s");
				$update_Config_Date = "update xGDB_Log set Config_Date = '$Config_Date' where ID = $ID";
				$check_update_Config_Date = mysql_query($update_Config_Date);
				}
	
	header("Location: view.php?id=$ID");
	exit();

?>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<title>Untitled Document</title>
</head>

<body>
<?php echo " get_record: "; echo $get_record ; echo "   | \n  $DBname: "; echo $DBname; echo " \n  |  POST ID:  "; echo $_POST['DBname']; echo " \n  |  update_DBname: "; echo $update_DBname; echo "| Organism"; echo $update_Organism; echo "| Common_Name"; echo $update_Common_Name;
?> 
</body>
</html>
<?php ob_flush();?>
