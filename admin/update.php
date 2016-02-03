## Work in progress 8-10-22 JPD. This script executes database update using values passed from admin_new.php

<?php ob_start();?>
<?php 
session_start();

	$global_DB= 'Genomes';
	$db = mysql_connect("localhost", "gdbuser", "xgdb");
	if(!$db)
	{
		echo "Error: Could not connect to database!";
		exit;
	}
	mysql_select_db("$global_DB");
	$error = $_GET['error'];
	
	
///////////////           get password hash  ///////////////////

$get_password = "select password from Admin";
$check_get_record = mysql_query($get_record);

///////////////				get old records				//////////////////

if(mysql_real_escape_string($_POST['password'])=="Save Changes"){
$get_record = "select * from Admin";
$check_get_record = mysql_query($get_record);
$update="F"; //flag for update

while ($data = mysql_fetch_array($check_get_record)){    ####### General Info #######
		$ID=$id; # post or get value
		$DBname=$data["DBname"]; # e.g. AtGDB
		$Organism=$data["Organism"];
		$Common_Name=$data["Common_Name"];
		$Status=$data["Status"];
		$Genome_Type=$data["Genome_Type"];
		$Create_Date=$data["Create_Date"]; # e.g. 12-26-2010
		$Input_Data_Path=$data["Input_Data_Path"]; # e.g. 12-26-2010

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


	}	
///////////////				compare to new records		////////////////////

#$DBname = mysql_real_escape_string($_POST['DBname']);

### Note: null values not being passed Try something like this: http://www.phpbuilder.com/board/showthread.php?t=10362086


####### General Info #######

				if (mysql_real_escape_string($_POST['DBname']) != $DBname){
				$DBname = mysql_real_escape_string($_POST[DBname]);
				$update_DBname = "update xGDB_Log set DBname = '$DBname' where ID = $ID";
				$check_update_DBname = mysql_query($update_DBname);
				$update="T";
				}

				if (mysql_real_escape_string($_POST['Status']) != $Status){
				$Status = mysql_real_escape_string($_POST[Status]);
				$update_Status = "update xGDB_Log set Status = '$Status' where ID = $ID";
				$check_update_Status = mysql_query($update_Status);
				$update="T";
				}		
				
				if (mysql_real_escape_string($_POST['Organism']) != $Organism){
				$Organism = mysql_real_escape_string($_POST[Organism]);
				$update_Organism = "update xGDB_Log set Organism = '$Organism' where ID = $ID";
				$check_update_Organism = mysql_query($update_Organism);
				$update="T";
				}
				
				if (mysql_real_escape_string($_POST['Common_Name']) != $Common_Name){
				$Common_Name = mysql_real_escape_string($_POST[Common_Name]);
				$update_Common_Name = "update xGDB_Log set Common_Name = '$Common_Name' where ID = $ID";
				$check_update_Common_Name = mysql_query($update_Common_Name);
				$update="T";
				}
			
				if (mysql_real_escape_string($_POST['Genome_Type']) != $Genome_Type){
				$Genome_Type = mysql_real_escape_string($_POST[Genome_Type]);
				$update_Genome_Type = "update xGDB_Log set Genome_Type = '$Genome_Type' where ID = $ID";
				$check_update_Genome_Type = mysql_query($update_Genome_Type);
				$update="T";
				}
				if (mysql_real_escape_string($_POST['Input_Data_Path']) != $Input_Data_Path){
				$Input_Data_Path = mysql_real_escape_string($_POST[Input_Data_Path]);
				$update_Input_Data_Path = "update xGDB_Log set Input_Data_Path = '$Input_Data_Path' where ID = $ID";
				$check_update_Input_Data_Path = mysql_query($update_Input_Data_Path);
				$update="T";
				}
	
	######## Genome ########
	
				if (mysql_real_escape_string($_POST['Genome_Version']) != $Genome_Version){
				$Genome_Version = mysql_real_escape_string($_POST[Genome_Version]);
				$update_Genome_Version = "update xGDB_Log set Genome_Version = '$Genome_Version' where ID = $ID";
				$check_update_Genome_Version = mysql_query($update_Genome_Version);
				$update="T";
				}
	
				if (mysql_real_escape_string($_POST['Genome_Source']) != $Genome_Source){
				$Genome_Source = mysql_real_escape_string($_POST[Genome_Source]);
				$update_Genome_Source = "update xGDB_Log set Genome_Source = '$Genome_Source' where ID = $ID";
				$check_update_Genome_Source = mysql_query($update_Genome_Source);
				$update="T";
				}
				
				if (mysql_real_escape_string($_POST['Genome_Source_Link']) != $Genome_Source_Link){
				$Genome_Source_Link = mysql_real_escape_string($_POST[Genome_Source_Link]);
				$update_Genome_Source_Link = "update xGDB_Log set Genome_Source_Link = '$Genome_Source_Link' where ID = $ID";
				$check_update_Genome_Source_Link = mysql_query($update_Genome_Source_Link);
				$update="T";
				}
				
				if (mysql_real_escape_string($_POST['Masking']) != $Masking){
				$Masking = mysql_real_escape_string($_POST[Masking]);
				$update_Masking = "update xGDB_Log set Masking = '$Masking' where ID = $ID";
				$check_update_Masking = mysql_query($update_Masking);
				$update="T";
				}
	
				
				if (mysql_real_escape_string($_POST['Genome_Count']) != $Genome_Count){
				$Genome_Count = mysql_real_escape_string($_POST[Genome_Count]);
				$update_Genome_Count = "update xGDB_Log set Genome_Count = '$Genome_Count' where ID = $ID";
				$check_update_Genome_Count = mysql_query($update_Genome_Count);
				$update="T";
				}
	
				if (mysql_real_escape_string($_POST['Chromosome_Count']) != $Chromosome_Count){
				$Chromosome_Count = mysql_real_escape_string($_POST[Chromosome_Count]);
				$update_Chromosome_Count = "update xGDB_Log set Chromosome_Count = '$Chromosome_Count' where ID = $ID";
				$check_update_Chromosome_Count = mysql_query($update_Chromosome_Count);
				$update="T";
				}
	
				
				if (mysql_real_escape_string($_POST['Unlinked_Chromosome_Count']) != $Unlinked_Chromosome_Count){
				$Unlinked_Chromosome_Count = mysql_real_escape_string($_POST[Unlinked_Chromosome_Count]);
				$update_Unlinked_Chromosome_Count = "update xGDB_Log set Unlinked_Chromosome_Count = '$Unlinked_Chromosome_Count' where ID = $ID";
				$check_update_Unlinked_Chromosome_Count = mysql_query($update_Unlinked_Chromosome_Count);
				$update="T";
				}
	
	
				
				if (mysql_real_escape_string($_POST['Scaffold_Count']) != $Scaffold_Count){
				$Scaffold_Count = mysql_real_escape_string($_POST[Scaffold_Count]);
				$update_Scaffold_Count = "update xGDB_Log set Scaffold_Count = '$Scaffold_Count' where ID = $ID";
				$check_update_Scaffold_Count = mysql_query($update_Scaffold_Count);
				$update="T";
				}
	
	
				
				if (mysql_real_escape_string($_POST['BAC_Count']) != $BAC_Count){
				$BAC_Count = mysql_real_escape_string($_POST[BAC_Count]);
				$update_BAC_Count = "update xGDB_Log set BAC_Count = '$BAC_Count' where ID = $ID";
				$check_update_BAC_Count = mysql_query($update_BAC_Count);
				$update="T";
				}
	
				
				if (mysql_real_escape_string($_POST['Genome_Comments']) != $Genome_Comments){
				$Genome_Comments = mysql_real_escape_string($_POST[Genome_Comments]);
				$update_Genome_Comments = "update xGDB_Log set Genome_Comments = '$Genome_Comments' where ID = $ID";
				$check_update_Genome_Comments = mysql_query($update_Genome_Comments);
				$update="T";
				}
	
	######## Gene Models ########
	
				
				if (mysql_real_escape_string($_POST['GeneModel_Version']) != $GeneModel_Version){
				$GeneModel_Version = mysql_real_escape_string($_POST[GeneModel_Version]);
				$update_GeneModel_Version = "update xGDB_Log set GeneModel_Version = '$GeneModel_Version' where ID = $ID";
				$check_update_GeneModel_Version = mysql_query($update_GeneModel_Version);
				$update="T";
				}
	
	
				
				if (mysql_real_escape_string($_POST['GeneModel_Source']) != $GeneModel_Source){
				$GeneModel_Source = mysql_real_escape_string($_POST[GeneModel_Source]);
				$update_GeneModel_Source = "update xGDB_Log set GeneModel_Source = '$GeneModel_Source' where ID = $ID";
				$check_update_GeneModel_Source = mysql_query($update_GeneModel_Source);
				$update="T";
				}
	
	
				
				if (mysql_real_escape_string($_POST['GeneModel_Link']) != $GeneModel_Link){
				$GeneModel_Link = mysql_real_escape_string($_POST[GeneModel_Link]);
				$update_GeneModel_Link = "update xGDB_Log set GeneModel_Link = '$GeneModel_Link' where ID = $ID";
				$check_update_GeneModel_Link = mysql_query($update_GeneModel_Link);
				$update="T";
				}
	
				if (mysql_real_escape_string($_POST['GeneModel_Comments']) != $GeneModel_Comments){
				$GeneModel_Comments = mysql_real_escape_string($_POST[GeneModel_Comments]);
				$update_GeneModel_Comments = "update xGDB_Log set GeneModel_Comments = '$GeneModel_Comments' where ID = $ID";
				$check_update_GeneModel_Comments = mysql_query($update_GeneModel_Comments);
				$update="T";
				}
			
	######## Alignment Info ########
	
				if (mysql_real_escape_string($_POST['EST_Align_sp']) != $EST_Align_sp){
				$EST_Align_sp = mysql_real_escape_string($_POST[EST_Align_sp]);
				$update_EST_Align_sp = "update xGDB_Log set EST_Align_sp = '$EST_Align_sp' where ID = $ID";
				$check_update_EST_Align_sp = mysql_query($update_EST_Align_sp);
				$update="T";
				}
	
				if (mysql_real_escape_string($_POST['EST_Align_Version']) != $EST_Align_Version){
				$EST_Align_Version = mysql_real_escape_string($_POST[EST_Align_Version]);
				$update_EST_Align_Version = "update xGDB_Log set EST_Align_Version = '$EST_Align_Version' where ID = $ID";
				$check_update_EST_Align_Version = mysql_query($update_EST_Align_Version);
				$update="T";
				}
			
	
				if (mysql_real_escape_string($_POST['EST_Align_Comments']) != $EST_Align_Comments){
				$EST_Align_Comments = mysql_real_escape_string($_POST[EST_Align_Comments]);
				$update_EST_Align_Comments = "update xGDB_Log set EST_Align_Comments = '$EST_Align_Comments' where ID = $ID";
				$check_update_EST_Align_Comments = mysql_query($update_EST_Align_Comments);
				$update="T";
				}
			
				if (mysql_real_escape_string($_POST['cDNA_Align_sp']) != $cDNA_Align_sp){
				$cDNA_Align_sp = mysql_real_escape_string($_POST[cDNA_Align_sp]);
				$update_cDNA_Align_sp = "update xGDB_Log set cDNA_Align_sp = '$cDNA_Align_sp' where ID = $ID";
				$check_update_cDNA_Align_sp = mysql_query($update_cDNA_Align_sp);
				$update="T";
				}
	
				if (mysql_real_escape_string($_POST['cDNA_Align_Version']) != $cDNA_Align_Version){
				$cDNA_Align_Version = mysql_real_escape_string($_POST[cDNA_Align_Version]);
				$update_cDNA_Align_Version = "update xGDB_Log set cDNA_Align_Version = '$cDNA_Align_Version' where ID = $ID";
				$check_update_cDNA_Align_Version = mysql_query($update_cDNA_Align_Version);
				$update="T";
				}
			
	
				if (mysql_real_escape_string($_POST['cDNA_Align_Comments']) != $cDNA_Align_Comments){
				$cDNA_Align_Comments = mysql_real_escape_string($_POST[cDNA_Align_Comments]);
				$update_cDNA_Align_Comments = "update xGDB_Log set cDNA_Align_Comments = '$cDNA_Align_Comments' where ID = $ID";
				$check_update_cDNA_Align_Comments = mysql_query($update_cDNA_Align_Comments);
				$update="T";
				}
	
				if (mysql_real_escape_string($_POST['PUT_Align_sp']) != $PUT_Align_sp){
				$PUT_Align_sp = mysql_real_escape_string($_POST[PUT_Align_sp]);
				$update_PUT_Align_sp = "update xGDB_Log set PUT_Align_sp = '$PUT_Align_sp' where ID = $ID";
				$check_update_PUT_Align_sp = mysql_query($update_PUT_Align_sp);
				$update="T";
				}
	
				if (mysql_real_escape_string($_POST['PUT_Align_Version']) != $PUT_Align_Version){
				$PUT_Align_Version = mysql_real_escape_string($_POST[PUT_Align_Version]);
				$update_PUT_Align_Version = "update xGDB_Log set PUT_Align_Version = '$PUT_Align_Version' where ID = $ID";
				$check_update_PUT_Align_Version = mysql_query($update_PUT_Align_Version);
				$update="T";
				}
			
	
				if (mysql_real_escape_string($_POST['PUT_Align_Comments']) != $PUT_Align_Comments){
				$PUT_Align_Comments = mysql_real_escape_string($_POST[PUT_Align_Comments]);
				$update_PUT_Align_Comments = "update xGDB_Log set PUT_Align_Comments = '$PUT_Align_Comments' where ID = $ID";
				$check_update_PUT_Align_Comments = mysql_query($update_PUT_Align_Comments);
				$update="T";
				}
				
			
				if (mysql_real_escape_string($_POST['Prot_Align_sp']) != $Prot_Align_sp){
				$Prot_Align_sp = mysql_real_escape_string($_POST[Prot_Align_sp]);
				$update_Prot_Align_sp = "update xGDB_Log set Prot_Align_sp = '$Prot_Align_sp' where ID = $ID";
				$check_update_Prot_Align_sp = mysql_query($update_Prot_Align_sp);
				$update="T";
				}
	
				if (mysql_real_escape_string($_POST['Prot_Align_Version']) != $Prot_Align_Version){
				$Prot_Align_Version = mysql_real_escape_string($_POST[Prot_Align_Version]);
				$update_Prot_Align_Version = "update xGDB_Log set Prot_Align_Version = '$Prot_Align_Version' where ID = $ID";
				$check_update_Prot_Align_Version = mysql_query($update_Prot_Align_Version);
				$update="T";
				}
	
				if (mysql_real_escape_string($_POST['Prot_Align_Comments']) != $Prot_Align_Comments){
				$Prot_Align_Comments = mysql_real_escape_string($_POST[Prot_Align_Comments]);
				$update_Prot_Align_Comments = "update xGDB_Log set Prot_Align_Comments = '$Prot_Align_Comments' where ID = $ID";
				$check_update_Prot_Align_Comments = mysql_query($update_Prot_Align_Comments);
				$update="T";
				}
			
	
	### Configuration defaults ###
	
				if (mysql_real_escape_string($_POST['Default_GSEG']) != $Default_GSEG){
				$Default_GSEG = mysql_real_escape_string($_POST[Default_GSEG]);
				$update_Default_GSEG = "update xGDB_Log set Default_GSEG = '$Default_GSEG' where ID = $ID";
				$check_update_Default_GSEG = mysql_query($update_Default_GSEG);
				$update="T";
				}
			
	
	
				if (mysql_real_escape_string($_POST['Default_lpos']) != $Default_lpos){
				$Default_lpos = mysql_real_escape_string($_POST[Default_lpos]);
				$update_Default_lpos = "update xGDB_Log set Default_lpos = '$Default_lpos' where ID = $ID";
				$check_update_Default_lpos = mysql_query($update_Default_lpos);
				$update="T";
				}
			
	
				if (mysql_real_escape_string($_POST['Default_rpos']) != $Default_rpos){
				$Default_rpos = mysql_real_escape_string($_POST[Default_rpos]);
				$update_Default_rpos = "update xGDB_Log set Default_rpos = '$Default_rpos' where ID = $ID";
				$check_update_Default_rpos = mysql_query($update_Default_rpos);
				$update="T";
				}

				if($update == "T"){
				$Config_Date = date("m-d-Y g:i a");
				$update_Config_Date = "update xGDB_Log set Config_Date = '$Config_Date' where ID = $ID";
				$check_update_Config_Date = mysql_query($update_Config_Date);
				}
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
