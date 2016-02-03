<?php
#	session_start(); //Fixme - currently throws error. Session already started?
	$global_DB= 'Genomes'; //MySQL
	$PageTitle = 'GDB Statistics';
	$pgdbmenu = 'Genomes';
	$submenu1 = 'GDBstats';
	$submenu2 = 'GDBstats';
	$leftmenu='GDBstats';
	$bckgrnd_class='gdb';
	include('sitedef.php');
	include($XGDB_HEADER);
	include_once('/xGDBvm/XGDB/phplib/db.inc.php');
	$dbpass=dbpass();
		$db = mysql_connect("localhost", "gdbuser", $dbpass);
	if(!$db)
	{
		echo "Error: Could not connect to database!";
		exit;
	}
	mysql_select_db("$global_DB");
	
$startQuery="SELECT * from xGDB_Log where Status='Current' ";
$endQuery=" ORDER BY ID ASC";

#grab post or session values and build query string:

$post_passed=isset($_POST['passed'])?$_POST['passed']:"";
$post_stats_field=isset($_POST['stats_field'])?$_POST['field']:"";
$post_stats_search=isset($_POST['stats_search'])?$_POST['search']:"";

if($post_passed == 1){	 #search box
		$searchWord = mysql_real_escape_string(str_replace("*", "%", $_POST[search]));
		$searchField = mysql_real_escape_string(str_replace("*", "%", $_POST[field]));
		$searchQuery = " AND $_POST[field] like '%$searchWord%' ";
		$_SESSION['stats_field'] = $_POST['field'];
		$_SESSION['stats_search'] = $_POST['search'];

	}elseif($post_stats_field !=""){ # session exists	
		$searchWord = $post_stats_search;
		$searchField = $post_stats_field;
		$searchQuery = " AND $searchField like '%$searchWord%' ";

	}else{ # No query - display all.
	$searchQuery = "";
}


#Concatenate query strings:

$totalQuery=$startQuery.$searchQuery.$endQuery;

#build result array and store in session
$get_records = $totalQuery;
$check_get_records = mysql_query($get_records);
$result = $check_get_records;
$_SESSION['stats_query'] = $searchQuery;

#Text depends on whether DB created or  not
$table_text = "<p class=\"instruction\">Click <img alt=\"globe\" src=\"/XGDB/images/contextview.gif\" /> to view default region in genome context.</p>";





## Dropdown for selecting GDB subsets ##


$display_block = "

										<!-- submit forms on mouse click -->
										<script type=\"text/javascript\">
										/* <![CDATA[ */
										
										function formSubmit(name) {
											//alert('hi this is Jon');
											var objForm = document.forms[name]
											//alert(name);
											objForm.submit();
										}
										/* ]]> */
										</script>

				

";

$display_block .= "<table class=\"featuretable bottommargin1\" style=\"font-size:12px\" cellpadding=\"6\">
<thead align=\"center\">
				<tr class=\"reverse_1\">
					<th rowspan=\"2\">xGDBvm ID<span class=\"lightgrayfont\"><br />(click to view)</span></th>
					<th rowspan=\"2\">Name<br /></th>
					<th rowspan=\"2\">Organism</th>
					<th rowspan=\"2\">Type </th>
					<th rowspan=\"2\">Default<br />Region</th>
					<th rowspan=\"2\">GSEG Count </th>
					<th rowspan=\"2\">Gene <br />Loci/
					<br />Tran-<br />scripts</th>
					<th rowspan=\"2\">yrGATE <br /> Anno-<br />ta-<br />tions </th>
					<th colspan=\"3\">Transcripts Aligned / Total</th>
					<th colspan=\"2\">Related-species Protein</th>
				</tr>
				<tr class=\"reverse_1\">
					<th>EST</th>
					<th>cDNA</th>
					<th>PUT</th>
					<th>Species</th>
					<th>Aligned /<br /> Total </th>

				</tr>
		</thead>
<tbody>
";

									while ($row = mysql_fetch_assoc($result)) {
									
																			
										$ID=$row["ID"];
										$Organism=$row["Organism"];
										$CommonName=$row["Common_Name"];
										$Create_Date=$row["Create_Date"];
										$Config_Date=$row["Config_Date"];
										$Input_Data_Path=$row["Input_Data_Path"];
										$DBid = 'GDB'.substr(('00'. $ID),-3); #calculated from unique ID										
										$DBname = $row["DBname"];
										$DBid_link = "<a class=\"nowrap\"  href=\"/$DBid/\">$DBid </a>";
 										$Genome_Count=$row["Genome_Count"];
										$Genome_Type=$row["Genome_Type"];
										$GeneModel_Link=$row["GeneModel_Link"];
        								$Prot_Align_sp=$row["Prot_Align_sp"];
										$Default_GSEG=$row["Default_GSEG"];
										$Default_lpos=$row["Default_lpos"]?$row["Default_lpos"]:"1";
										$Default_rpos=$row["Default_rpos"]?$row["Default_rpos"]:"10000";
										$getGSEG_Region="getGSEG_Region.pl?gseg_gi=".$Default_GSEG."&amp;bac_lpos=".$Default_lpos."&amp;bac_rpos=".$Default_rpos;
										$context_view_link =  "<a title=\"View sample region in genome context\" href=\"/$DBid/cgi-bin/$getGSEG_Region\"><img alt=\"globe\" src=\"/XGDB/images/contextview.gif\" /></a>";	        								



#										if($Status =="Current"){ #for styling table background
#												$status_class="current";									
#												}else{
#												$status_class="not_current";
#										}

						####Display modifications########
								
								$xGDB_link= "<a href=/\"".$DBid."/\">".$DBid."</a>";
				
						################# If DB already exists, get sequence count from EST, cDNA, GSEG, yrGATE tables########
						
						if(mysql_select_db("$DBid")){
						
						$global_DB_exists = "";

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
						
							##### Get Annotation, Locus Count ####
								
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
								
							##### Get yrGATE  Count ####
								
								$mysql_get_yrgate= mysql_query("SELECT count(*) FROM $DBid.user_gene_annotation WHERE Status='ACCEPTED' and Organism='$Organism' "); // get current yrgate count for this organism and version
								while($data_get_yrgate = mysql_fetch_array($mysql_get_yrgate)){
									$yrgate_total=$data_get_yrgate[0];
								}
						
							
						}else{
						$global_DB_exists = "NOTE: MySQL DB does not exist";
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
						$yrgate_total="";
						}											
											
										
$display_block .= "						




										 <tr align=\"right\">


										 		<td align=\"center\"  class=\"reverse_2 bold\" >
										 			$DBid_link
												</td>
												<td align=\"left\">
													$DBname
												</td>


												<td class=\"italic\">
													$Organism
												</td>
												<td>
													$Genome_Type
												</td>
												<td align=\"center\">
													$context_view_link
												</td>	
												<td align=\"center\">
													$gseg_total
												</td>
												<td>
													{$gene_loci_total} <br/> ${gene_anno_total}
												</td>
												<td align=\"center\">
													{$yrgate_total}
												</td>

												<td>
													{$est_align_total} <br/> {$est_total}
												</td>
												<td>
													{$cdna_align_total} <br/> {$cdna_total}
												</td>
												<td>
													{$put_align_total} <br/> {$put_total}
												</td>
												<td>
													{$Prot_Align_sp}
												</td>
												<td>
													{$prot_align_total} <br/> {$prot_total}
												</td>	
											</tr>";
}

$display_block .= "</tbody></table>";

?>

	<div id="leftcolumncontainer">
		<div class="minicolumnleft">
			<?php include_once("/xGDBvm/XGDB/leftmenu.inc.php"); ?>
		</div>
	</div>
	<div id="maincontentscontainer" class="twocolumn">
			<div id="maincontentsfull">
			<h1>Genome Statistics</h1>



<table class="topmargin1" width="100%" border="0">
	<tr valign="top">
		<td width="60%" class="normalfont">
			<?php echo "$table_text"; ?> 
		</td>
		<td width="40%" align="right" valign="bottom">
		
		<form method="post" action="/XGDB/GDBstats.php">
				<span class="normalfont">Filter:
				  <select name="field">
					<option value="DBname">Database Name</option>
					<option value="DBid">xGDB ID</option>
					<option value="Organism">Latin Name</option>
				  </select> 
				  on  </span>
				<input type="text" name="search" size="15" /> 
				<input type="hidden" name="passed" value="1" /> 
				<input type="submit" name="submit" value="Search" />
		 <?php
		if (isset($_SESSION['stats_field'])){
			echo "Search on: $searchField = <span style=\"color:red\">$searchWord</span> |  <a href=\"/XGDB/GDBstats_exec.php?clear=true&amp;name=GDBstats\">Clear Search Results</a>";
		} else {
			echo "";
		}
		?>
		</form>
		
		</td>
	</tr>
</table>
<br />

<?php 

#	echo "Current: $current_check; Dev: $dev_check; Offine: $locked_check; All: $all_check <span class=\"heading smallerfont\">Total Query: ".$totalQuery." <br /> Search Query: ".$searchQuery." <br /> Status Query:".$statusQuery."</span>";

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
