<?php
if (preg_match('/(GDB\d\d\d)/', $_SERVER['HTTP_REFERER'], $matches))
	$X = $matches[1];
if ($_GET['GDB']) //the user can select a version from the dropdown; GDB consists of GDBnnn
	$X = mysql_real_escape_string($_GET['GDB']);

$X1 = substr($X,3,3); //e.g. 001

require('/xGDBvm/XGDB/phplib/sitedef.php'); // For list of available GDBs
include_once('/xGDBvm/XGDB/phplib/db.inc.php');
if(empty($SITEDEF_H)) { require('/xGDBvm/data/GDB' . $X1 . '/conf/SITEDEF.php'); }
if(empty($PARAM_H)){require('/xGDBvm/XGDB/phplib/getPARAM.php');}
require('/xGDBvm/XGDB/phplib/SSI_GDBprep.php');
virtual("${CGIPATH}SSI_GDBgui.pl/TWO_COLUMN_HEADER/" . $SSI_QUERYSTRING);

$global_DB="Genomes";
$Update_Data_Default="/xGDBvm/input/";
$leftmenu = 'resources';
$db_list="";

	
	$id = (int) substr('00'. mysql_real_escape_string($_GET['GDB']), -3); //picks up either 3 or GDB003   TODO - need to further sanitize since numerical
	$DBid = "GDB".substr('00'. $id, -3);


if(preg_match("/procedure/", $_GET['type']) || preg_match("/error/", $_GET['type'])){ #URL string shows &file=
	$file=mysql_real_escape_string($_GET['type']);
	
	
	switch ($file) // also display links to other logfiles
		{
    case "Pipeline_procedure":
		$file2="CpGAT_procedure";
		$file3="Pipeline_error";
        break;
    case "CpGAT_procedure":
		$file2="Pipeline_error";
		$file3="Pipeline_procedure";
        break;
    case "Pipeline_error":
		$file2="Pipeline_procedure";
		$file3="CpGAT_procedure";
        break;
	}

	$filepath = "/xGDBvm/data/$DBid/logs/${file}.log";

		$fd = fopen($filepath, "r");
		$contents = fread($fd, filesize($filepath));
		fclose($fd);
# Logfile Display
	$display_block = "
<div id=\"mainWLS\">
	<div id=\"maincontents\">
		<div class=\"dialogcontainer\" >
				<h2 class=\"bottommargin1\">
				${file}.log for $DBid &nbsp; &nbsp; 

				</h2>
				<p class=\"heading indent1\">
				Other logfiles: <a href=\"/XGDB/phplib/resource.php?GDB=$DBid&amp;type=$file2\">$file2</a>; <a href=\"/XGDB/phplib/resource.php?GDB=$DBid&amp;type=$file3\">$file3</a>
				</p>
			</div>
		<div class=\"dialogcontainer\">
	<pre class=\"normal\">
$contents
	</pre>
	</div>
						  <div class=\"topmargin1 bottommargin1\" style=\"clear:both; float:right\">
							<a href=\"http://validator.w3.org/check?uri=referer\"><img
							  src=\"http://www.w3.org/Icons/valid-xhtml10\" alt=\"Valid XHTML 1.0 Transitional\" height=\"15\" width=\"44\" /></a>
						  </div>						
	";



	}elseif(preg_match("/data/", mysql_real_escape_string($_GET['type']))){ ## no file - resources instead

	$file=mysql_real_escape_string($_GET['type']);
		$dbpass=dbpass();
		$db = mysql_connect("localhost", "gdbuser", $dbpass);
		if(!$db)
		{
			echo "Error: Could not connect to database!";
			exit;
		}
		mysql_select_db("$global_DB");
	
	
	### Select New id
	
	
		$get_data = "select * from xGDB_Log where ID='$id' and Status='Current'";
		
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


	while ($data = mysql_fetch_array($check_get_data)){
		$current_class=""; //assigned below
####### General Info #######
		$ID = $id; #post or get result.
		$DBid = 'GDB'.substr(('00'. $id),-3); #calculated from unique ID										
		$DBname = $data["DBname"];
		$Status=$data["Status"];
		$Organism=$data["Organism"];
		$Common_Name=$data["Common_Name"];
		$Create_Date=$data["Create_Date"];
		$Config_Date=$data["Config_Date"];
		$Input_Data_Path=$data["Input_Data_Path"];
		$Input_Data_URL = str_replace("/xGDBvm", "", $Input_Data_Path);
		$Genome_Type=$data["Genome_Type"];
		$GFF_Type=$data["GFF_Type"];

####### GSQ Parameters #######
		$Species_Model=$data["Species_Model"];
		$Alignment_Stringency=$data["Alignment_Stringency"];

######## Database Update ########
		$Update_Status=$data["Update_Status"];
		$Update_Data_EST=$data["Update_Data_EST"];
		$Update_Data_cDNA=$data["Update_Data_cDNA"];
		$Update_Data_TrAssembly=$data["Update_Data_TrAssembly"];
		$Update_Data_GSEG=$data["Update_Data_GSEG"];
		$Update_Data_Protein=$data["Update_Data_Protein"];
		$Update_Data_GeneModel=$data["Update_Data_GeneModel"];
		$Update_Data_Path=($data["Update_Data_Path"])? $data["Update_Data_Path"]:$Update_Data_Default;
		$Update_Data_URL = str_replace("/xGDBvm", "", $Update_Data_Path);
		$Update_Comments=$data["Update_Comments"];
		$Update_Date=$data["Update_Date"];
		$Update_History=$data["Update_History"];

######## Display & Annotation Defaults ########
        $Default_GSEG=$data["Default_GSEG"];
        $Default_lpos=$data["Default_lpos"];
        $Default_rpos=$data["Default_rpos"];
        $yrGATE_Admin_Email=$data["yrGATE_Admin_Email"];######## Genome ########
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

######## Configuration Info ########
        $Default_GSEG=$data["Default_GSEG"];
        $Default_lpos=$data["Default_lpos"];
        $Default_rpos=$data["Default_rpos"];



		
####Display modifications########


	##### GSEG Queries #####
		 if($get_anno_gseg_tot="SELECT count(*)FROM {$DBid}.gseg"){ 
		 $mysql_get_anno_gseg_tot= mysql_query($get_anno_gseg_tot); // get number of annotated gseg
		while($data_get_anno_gseg_tot = mysql_fetch_array($mysql_get_anno_gseg_tot)){
			$anno_gseg_total=$data_get_anno_gseg_tot[0];
			}
		}
		
		 if($get_gseg_tot="SELECT count(distinct gseg_gi) FROM {$DBid}.gseg_gene_annotation"){ 
		 $mysql_get_gseg_tot= mysql_query($get_gseg_tot); // get number of gseg
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
		
	##### PUT Queries #####
	
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
		
	##### Peptide Queries. ##########

		 if($mysql_get_prot= mysql_query("SELECT count(*) FROM {$DBid}.pep")){ // get total pep
		while($data_get_prot = mysql_fetch_array($mysql_get_prot)){
			$prot_total=$data_get_prot[0];
			}
		}
		
		 if($mysql_get_prot_align= mysql_query("SELECT count(*) FROM {$DBid}.gseg_pep_good_pgs")){ // get total aligned
		while($data_get_prot_align = mysql_fetch_array($mysql_get_prot_align)){
			$prot_align_total=$data_get_prot_align[0];
			}
		}

    ##### Get Precomputed Annotation, Locus Count ####
        
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
        
		 $mysql_get_cpgat_annno= mysql_query("SELECT count(*) FROM $DBid.gseg_cpgat_gene_annotation");
		while($data_get_cpgat_annno = mysql_fetch_array($mysql_get_cpgat_annno)){
			$cpgat_anno_total=$data_get_cpgat_annno[0];
		}

		if($mysql_get_cpgat_loci= mysql_query("SELECT count(distinct locus_id) FROM $DBid.gseg_cpgat_gene_annotation")){
			while($data_get_cpgat_loci = mysql_fetch_array($mysql_get_cpgat_loci)){
					$cpgat_loci_total=$data_get_cpgat_loci[0];
					}
				}else{
			$cpgat_loci_total=$cpgat_anno_total;
		}

		
	##### Get yrGATE  Count ####
        
		$mysql_get_yrgate= mysql_query("SELECT count(*) FROM $DBid.user_gene_annotation WHERE Status='ACCEPTED'"); // get current yrgate count for this organism and version
		while($data_get_yrgate = mysql_fetch_array($mysql_get_yrgate)){
			$yrgate_total=$data_get_yrgate[0];
		}

 ########### Get list of database names for dropdown selection ###############

#	    mysql_select_db("$global_DB");
		$mysql_get_dbnames= mysql_query("SELECT * FROM $global_DB.xGDB_Log order by DBname"); // get all GDB
		while($data_get_dbnames = mysql_fetch_assoc($mysql_get_dbnames)){
			$dbname_list=$data_get_dbnames['DBname'];
		}
		
		# Generate database list for select statement. see http://www.tech-evangelist.com/2007/11/22/php-select-box/
		$dbname_query = "SELECT ID, DBname FROM $global_DB.xGDB_Log order by ID";
		$rows = mysql_query($dbname_query);
		while($row = mysql_fetch_array($rows))
			{
		  	$db_list .= "<option value=\"".$row['ID']."\">".$row['DBname']."</option>\n";
		}

		

	}

# Resources Display
		$display_block = "
		
				
<div id=\"mainWLS\">
	<div id=\"maincontents\">
		<table style=\"font-size:12px\" class=\"bottommargin2\" width=\"100%\">
		
			<tr>
				<td align=\"left\" width=\"54%\">
					<h1 class=\"bottommargin1\">	
					<img alt=\"\" src=\"/XGDB/images/information.png\" />&nbsp;Data and Sources for $DBname <i>($Organism)</i>
					</h1>
				</td>
				</tr>
				<tr>
					<td>
						<span class=\"instruction\">To view or edit GDB configuration visit <a title=\"View configuration data for this genome database\" href=\"/XGDB/conf/view.php?id=$DBid\"> $DBid Configuration</a>; View <a href=\"/XGDB/phplib/resource.php?GDB=$DBid&amp;type=Pipeline_procedure\">Pipeline Logs</a></span>
					</td>
				</tr>
		</table>

		<div style=\"width:95%\">
		<fieldset  class=\"bottommargin1 topmargin1 xgdb_viewonly\">
		<legend class=\"resource\"> &nbsp;Overview:</legend>
		<table class=\"xgdb_log\" border=\"0\" style=\"font-size:12px\" width=\"95%\" >
			<colgroup>
				<col width =\"40%\" style=\"background-color: #E8F8FC\" />
				<col width =\"60%\" />
			</colgroup>
			<tbody>
				<tr>
				    <td>Database ID:</td><td>$DBid
				    </td>
				</tr>
				<tr>
					<td>Database Name:</td>
					<td>$DBname</td>
				</tr>
				<tr>
					<td>Organism: </td>
					<td class=\" italic bold\">$Organism</td>
				</tr>
				<tr>
					<td>Common Name: </td>
					<td>$Common_Name</td>
				</tr>
				<tr>
					<td>Genome Type: </td>
					<td>$Genome_Type</td>
				</tr>
			</tbody>
		</table>
		</fieldset>
		
		<fieldset  class=\"bottommargin1 xgdb_viewonly\">
		<legend class=\"resource\"> &nbsp;<b>Genome:</b></legend>
		<table class=\"xgdb_log\"  border=\"0\" style=\"font-size:12px\" width=\"95%\">
			<colgroup>
				<col width =\"40%\" style=\"background-color: #E8F8FC\" />
				<col width =\"60%\" />
			</colgroup>
			<tbody>
				<tr>
				<td>Genome Version:</td>
				<td>$Genome_Version</td>
		
				</tr>
				<tr>
					<td>Genome Source:</td>
					<td>$Genome_Source</td>
				</tr>
				<tr>
					<td>Genome Source Link:</td>
					<td><a href=\"$Genome_Source_Link\">$Genome_Source_Link</a></td>
				</tr>
				<tr>
					<td>Genome Comments:</td>
					<td>$Genome_Comments</td>
				</tr>
			</tbody>
		</table>
		</fieldset>	
		
		
		<fieldset  class=\"bottommargin1 xgdb_viewonly\">
		<legend class=\"resource\"> &nbsp;Genome Segments:</legend>
		<table class=\"xgdb_log\" border=\"0\" style=\"font-size:12px\" width=\"95%\">
			<colgroup>
				<col width =\"40%\" style=\"background-color: #E8F8FC\" />
				<col width =\"60%\" />
			</colgroup>
			<tbody>
				<tr><td class=\"heading\">Genome Segments (Total):</td><td>$gseg_total</td></tr>
				<tr><td class=\"indent3\">Chromosomes:</td><td>$Chromosome_Count</td></tr>
				<tr><td class=\"indent3\">Unlinked Chromosomes:</td><td>$Unlinked_Chromosome_Count</td></tr>
				<tr><td class=\"indent3\">Scaffolds:</td><td>$Scaffold_Count</td></tr>
				<tr><td class=\"indent3\">BACs:</td><td>$BAC_Count</td></tr>
				<tr><td>Genome Segments Expected:</td><td>$Genome_Count</td></tr>
		
			</tbody>
		</table>
		</fieldset>	
		<fieldset  class=\"bottommargin1 xgdb_viewonly\">
		<legend class=\"resource\"> &nbsp;Gene Predictions: <img class=\"nudge2\" src=\"/XGDB/images/genemodels_simple.png\" alt=\"?\" /> </legend>
		<table class=\"xgdb_log\" border=\"0\" style=\"font-size:12px\" width=\"95%\">
			<colgroup>
				<col width =\"40%\" style=\"background-color: #E8F8FC\" />
				<col width =\"60%\" />
			</colgroup>
			<tbody>
				<tr><td>Precomputed Gene Models - Version:</td><td>$GeneModel_Version</td></tr>
				<tr><td class=\"indent2\">Source:</td><td class=\"bold indent1\">$GeneModel_Source</td></tr>
				<tr><td class=\"indent2\">Link:</td><td class=\"bold indent1\"><a href=\"$GeneModel_Link\">$GeneModel_Link</a></td></tr>
				<tr><td class=\"indent2\">Segments Annotated:</td><td class=\"bold indent1\">$anno_gseg_total</td></tr>
				<tr><td class=\"indent2\">Total Gene Models:</td><td class=\"bold indent1\">$gene_anno_total</td></tr>
				<tr><td class=\"indent2\">Total Gene Loci:</td><td class=\"bold indent1\">$gene_loci_total</td></tr>
				<tr><td class=\"indent2\">Comments:</td><td>$GeneModel_Comments</td></tr>
			</tbody>
		</table>
		</fieldset>	
		<fieldset  class=\"bottommargin1 xgdb_viewonly\">
		<legend class=\"resource\"> &nbsp;<b>Gene Predictions: <img class=\"nudge2\" src=\"/XGDB/images/cpgatmodels_simple.png\" alt=\"?\" /></b> </legend>
		<table class=\"xgdb_log\" border=\"0\" style=\"font-size:12px\" width=\"95%\">
			<colgroup>
				<col width =\"40%\" style=\"background-color: #E8F8FC\" />
				<col width =\"60%\" />
			</colgroup>
			<tbody>
				<tr><td>CpGAT Gene Models:</td><td class=\"bold indent1\">$cpgat_anno_total</td></tr>
				<tr><td>CpGAT Gene Loci:</td><td class=\"bold indent1\">$cpgat_loci_total</td></tr>
			</tbody>
		</table>
		</fieldset>					
		<fieldset  class=\"bottommargin1 xgdb_viewonly\">
		<legend class=\"resource\"> &nbsp; Gene Predictions: yrGATE <img class=\"nudge2\" src=\"/XGDB/images/yrgatemodels_simple.png\" alt=\"?\" /></legend>
		<table class=\"xgdb_log\" border=\"0\" style=\"font-size:12px\" width=\"95%\">
			<colgroup>
				<col width =\"40%\" style=\"background-color: #E8F8FC\" />
				<col width =\"60%\" />
			</colgroup>
			<tbody>
				<tr><td width=\"35\">yrGATE Gene Models: </td><td>$yrgate_total</td></tr>
			</tbody>
		</table>
		</fieldset>	
		
		<fieldset  class=\"bottommargin1 xgdb_viewonly\">
		<legend class=\"resource\"> &nbsp;<b>Transcript Spliced Alignments:</b></legend>
		<table class=\"xgdb_log\" border=\"0\" style=\"font-size:12px\" width=\"95%\">
			<colgroup>
				<col width =\"40%\" style=\"background-color: #E8F8FC\" />
				<col width =\"60%\" />
			</colgroup>
			<tbody>
				<tr><td>Aligned EST Species:</td><td>$EST_Align_sp</td></tr>
				<tr><td>Aligned EST Version:</td><td>$EST_Align_Version</td></tr>
				<tr><td class=\"indent2 heading\">EST Count Total:</td><td>$est_total</td></tr>
				<tr><td class=\"indent2 heading\">EST Alignments:</td><td>$est_algn_total</td></tr>
				<tr><td class=\"indent2\">Comments:</td><td>$EST_Align_Comments</td></tr>
				<tr><td class=\"indent3 heading\">Cognate:</td><td>$est_cog_total</td></tr>
				<tr><td class=\"indent3 heading\">Non-cognate:</td><td>$est_non_total</td></tr>
				<tr><td>Aligned cDNA Species:</td><td>$cDNA_Align_sp</td></tr>
				<tr><td>Aligned cDNA Version:</td><td>$cDNA_Align_Version</td></tr>
				<tr><td class=\"indent2 heading\">cDNA Count Total:</td><td>$cdna_total</td></tr>
				<tr><td class=\"indent2 heading\">cDNA Alignments:</td><td>$cdna_algn_total</td></tr>
				<tr><td class=\"indent2\">Comments:</td><td>$cDNA_Align_Comments</td></tr>
				<tr><td class=\"indent3 heading\">Cognate:</td><td>$cdna_cog_total</td></tr>
				<tr><td class=\"indent3 heading\">Non-cognate:</td><td>$cdna_non_total</td></tr>
				<tr><td>Aligned PUT Species:</td><td>$PUT_Align_sp</td></tr>
				<tr><td>Aligned PUT Version:</td><td>$PUT_Align_Version</td></tr>
				<tr><td class=\"indent2\">Comments:</td><td>$PUT_Align_Comments</td></tr>
				<tr><td class=\"indent2\">PUT Alignments:</td><td>$put_align_total</td><td></td></tr>
			</tbody>
		</table>
		</fieldset>
		
		<fieldset  class=\"bottommargin1 xgdb_viewonly\">
		<legend class=\"resource\"> &nbsp;<b>Protein Alignments:</b></legend>
		<table class=\"xgdb_log\" border=\"0\" style=\"font-size:12px\" width=\"95%\">
			<colgroup>
				<col width =\"40%\" style=\"background-color: #E8F8FC\" />
				<col width =\"60%\" />
			</colgroup>
			<tbody>
				<tr><td class=\"indent2\">Species:</td><td>$Prot_Align_sp</td></tr>
				<tr><td class=\"indent2\">Version:</td><td>$Prot_Align_Version</td></tr>
				<tr><td class=\"indent2\">Comments:</td><td>$Prot_Align_Comments</td></tr>
				<tr><td class=\"indent2 heading\">Protein Count Total:</td><td>$prot_total</td></tr>
				<tr><td class=\"indent2 heading\">Protein Alignments:</td><td>$prot_align_total</td></tr>
			</tbody>
		</table>
		</fieldset>
	</div>
						  <div style=\"clear:both; float:right\">
							<a href=\"http://validator.w3.org/check?uri=referer\"><img
							  src=\"http://www.w3.org/Icons/valid-xhtml10\" alt=\"Valid XHTML 1.0 Transitional\" height=\"15\" width=\"44\" /></a>
						  </div>						
		";

} #end if loop for resource	?>

				<?php
#	echo "<span class=\"heading\" >".$get_data." | ".$get_est_tot." | ".$get_est_algn." </span>";

					echo $display_block;
				?>

		</div><!-- end maincontents -->
		</div><!-- end mainWLS-->
<?php
//require('SSI_GDBprep.php');
require('/xGDBvm/XGDB/phplib/SSI_GDBprep.php');
virtual("${CGIPATH}SSI_GDBgui.pl/STANDARD_FOOTER/" . $SSI_QUERYSTRING);
?>
