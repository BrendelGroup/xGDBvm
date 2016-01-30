<?php
	$PageTitle = 'Current Genomes - Overview';
	$pgdbmenu = 'Genomes';
	$submenu1 = 'GenomeList';
	$submenu2 = 'GenomeList';
	$leftmenu='GenomeList';
	$global_DB= 'Genomes';
	$bckgrnd_class='gdb';
	include("sitedef.php");
	include($XGDB_HEADER);
	
	$error_message="";
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
?>
		<div id="leftcolumncontainer">
			<div class="minicolumnleft">
				<?php include_once("/xGDBvm/XGDB/leftmenu.inc.php"); ?>
			</div>
		</div>

		<div id="maincontentscontainer" class="twocolumn">
		<div id="maincontentsfull">
<?php

$Query="SELECT * from $global_DB.xGDB_Log where Status='Current' order by ID ASC";
$get_records = $Query;
$check_get_records = mysql_query($get_records);
$result = $check_get_records;
if(!$result){
$display_block="<span class=\"indent1 largerfont\">No genome browsers have been created yet. To start one, first visit our genome browser <a href=\"/XGDB/conf/new.php\">configuration page</a>, or <a href=\"/XGDB/conf/new.php?example=1\">start with our sample data</a> to see how the process works.</span>

<span class=\"indent1 largerfont topmargin1\"><a href=\"/\">Return to Home Page</a></span>

<br />
<br />
<br />
";
}else{
$display_block="
		<h1 class=\"bottommargin1\">Current Genomes <span class=\"heading\">on this xGDBvm instance</span> $error_message</h1>

		<p class=\"instruction\">Click on an icon (&nbsp; <img alt=\"home\" src= \"/XGDB/images/home_go.png\" /> = Home Page,  <img alt=\"Context\" src=\"/XGDB/images/contextview.gif\" \> = Context View <img alt=\"search\" src= \"/XGDB/images/magnifier.png\" /> = Search ,  etc.,) to view a specific data type or tool for that genome.</p>

				<table class=\"featuretable topmargin1 bottommargin1\">
				<colgroup align=\"center\">
				<col width=\"7%\" />
				<col width=\"5%\" />
				<col width=\"10%\" />
				<col width=\"5%\" />
				<col width=\"5%\" />
				<col width=\"5%\" />
				<col width=\"5%\" />
				<col width=\"5%\" />
				<col width=\"5%\" />
				<col width=\"5%\" />
				<col width=\"5%\" />
				<col width=\"5%\" />
				<col width=\"5%\" />
				<col width=\"5%\" />
				<col width=\"10%\" />
				<col width=\"5%\" />
				<col width=\"5%\" />
				</colgroup>
				<thead>
				<!--tr class=\"{sorter: false}\">
					<th></th>
					<th colspan=\"3\">Species</th>
					<th colspan=\"3\"></th>
					<th colspan=\"2\">Protein Alignments</th>
				</tr-->
					<tr class=\"reverse_1\">
						<th align=\"center\" >xGDBvm ID<span class=\"lightgrayfont\"><br />(click to view)</span></th>
						<th align=\"center\" >Name</th>
						<th align=\"center\" >Species</th>
						<th align=\"center\">Genome<br />Type</th>
						<th align=\"center\">Date Created</th>
						<th align=\"center\">Home <br />Page</th>
						<th align=\"center\">View <br />Sample <br /> Region</th>
						<th align=\"center\">Data <br />Down- <br /> load</th>
						<th align=\"center\" >Search</th>
						<th align=\"center\" >&nbsp;B&nbsp;<br />&nbsp;L&nbsp;<br />&nbsp;A&nbsp;<br />&nbsp;S&nbsp;<br />&nbsp;T&nbsp;</th>
						<th align=\"center\">Gene <br /> Anno-<br />tations <br />(Loci)</th>
						<th align=\"center\">Commu-<br />nity <br /> Anno-<br />tations</th>
						<th align=\"center\">GAEVAL <br /> Tables</th>
						<th align=\"center\">Transcript <br /> Aligmnents</th>
						<th align=\"center\">Protein Spliced-Alignments</th>
						<th align=\"center\">Summary <br /> Statistics</th>
						<th align=\"center\">Con-<br />figure</th>
						<th align=\"center\">Log-<br />file</th>
					</tr>
				</thead>
				<tbody>
";
}
	while ($row = mysql_fetch_assoc($result)) {
			
		$ID=$row["ID"];
		$DBid = 'GDB'.substr(('00'. $ID),-3); #calculated from unique ID		
		$DBid_link =  "<a title=\"View $DBid home page\" href=\"/$DBid/\">$DBid</a>";										
		$DBname = $row["DBname"];
		$DBname_link =  "<a title=\"View $DBname home page\" href=\"/XGDB/phplib/index.php?GDB=$DBid\">$DBname</a>";	//not used currently									
		$Organism=$row["Organism"];	
		$Genome_Type=$row["Genome_Type"];
		$Create_Date=$row["Create_Date"];
		$Genome_Count=$row["Genome_Count"];
		$Prot_Align_sp=$row['Prot_Align_sp'];
		$Default_GSEG=$row["Default_GSEG"];
		$Default_lpos=$row["Default_lpos"]?$row["Default_lpos"]:"1";
		$Default_rpos=$row["Default_rpos"]?$row["Default_rpos"]:"10000";
		$getGSEG_Region="getGSEG_Region.pl?gseg_gi=".$Default_GSEG."&amp;bac_lpos=".$Default_lpos."&amp;bac_rpos=".$Default_rpos;
		$context_view_link =  "<a title=\"View sample region in genome context\" href=\"/$DBid/cgi-bin/$getGSEG_Region\"><img alt=\"globe\" src=\"/XGDB/images/contextview.gif\" /></a>";										
		$homepage_link = "<a title=\"View $DBname home page\" href=\"/$DBid/\"><img alt=\"conf\" src=\"/XGDB/images/home_go.png\" /></a>";
	

#### DB queries ####


$get_est_count=mysql_query("SELECT count(*) FROM {$DBid}.gseg_est_good_pgs");
$get_cdna_count = mysql_query("SELECT count(*) FROM {$DBid}.gseg_cdna_good_pgs");
$get_put_count = mysql_query("SELECT count(*) FROM {$DBid}.gseg_put_good_pgs");

$est = 	(mysql_result($get_est_count, 0)=="0")?"":"EST";
$cdna = 	(mysql_result($get_cdna_count, 0)=="0")?"":"cDNA";
$put = 	(mysql_result($get_put_count, 0)=="0")?"":"PUT";

$display_block.="
				<tr>
					<td align=\"center\" class=\"reverse_2 bold\" ><b>$DBid_link</b></td>
					<td align=\"center\"><b>$DBname</b></td>
					<td><span class=\"species\">$Organism</span> </td>
					<td align=\"center\">$Genome_Type</td>
					<td align=\"center\">$Create_Date</td>
					<td align=\"center\">$homepage_link</td>
					<td align=\"center\">$context_view_link</td>
					<td align=\"center\"><a title=\"Download Bulk Data for $display_key\" href=\"/XGDB/phplib/download.php?GDB=$DBid\"><img alt=\"download\" src= \"/XGDB/images/download.png\" /></a></td>	
					<td align=\"center\"><a title=\"$DBname Advanced Search\" href=\"/$DBid/cgi-bin/search.pl\"><img alt=\"search\" src= \"/XGDB/images/magnifier.png\" /></a></td>
					<td align=\"center\"><a title=\"$DBname BLAST\" href=\"/$DBid/cgi-bin/blastGDB.pl\"><img alt=\"blast\" src= \"/XGDB/images/blast.png\" /></a></td>
					<td align=\"center\"><a title=\"$DBname Display Loci and Annotations\" href=\"/XGDB/phplib/DisplayLoci.php?GDB=$DBid\"><img alt=\"loci\" src= \"/XGDB/images/loci.png\" /></a></td>
					<td align=\"center\"><a title=\"$DBname Show CommunityCentral list of yrGATE Annotations\" href=\"/yrGATE/$DBid/CommunityCentral.pl\"><img alt=\"comment\" src= \"/XGDB/images/annotate.gif\" /></a></td>
					<td align=\"center\"><a title=\"$DBnameDisplay GAEVAL table data\" href=\"/XGDB/phplib/GAEVAL.php?GDB=$DBid\"><img alt=\"gaeval\" src= \"/XGDB/images/GAEVAL.png\" /></a></td>
					<td>$est $cdna $put</td>
					<td><a title=\"Protein alignment for $DBname protein alignments>\" href=\"/XGDB/phplib/GSEG_AnnProt.php?GDB=$DBid\">$Prot_Align_sp</a></td>
					<td align=\"center\"><a title=\"$display_key Data Sources and Methods\" href=\"/XGDB/phplib/resource.php?GDB=$DBid&amp;type=data\"><img alt=\"info\" src= \"/XGDB/images/information.png\" /></a></td>	
					<td align=\"center\"><a href=\"/XGDB/conf/view.php?id=$ID\">&nbsp;<img alt=\"conf\" src=\"/XGDB/images/configure.png\" /></a></td>
					<td align=\"center\"><a href=\"/XGDB/phplib/resource.php?GDB=$DBid&amp;type=Pipeline_procedure\">&nbsp;<img alt=\"conf\" src=\"/XGDB/images/magnifier.png\" /></a></td>
				</tr>
		";
	}
		
$display_block .= "</tbody></table>";

echo $display_block;
?>


			</div><!--end maincontentsfull-->
			</div><!--end maincontentscontainer-->
		<?php include($XGDB_FOOTER); ?>
		</div><!--end pagewidth-->
	</div><!--end innercontainer-->
</div><!--end outercontainer-->
</body>
</html>
