<?php

####	This file is included with the Genome Browser home page (/xGDBvm/data/GDBnnn/index.php)

include_once('/xGDBvm/XGDB/phplib/db.inc.php');
$dbpass=dbpass();
$db = mysql_connect("localhost", "gdbuser", $dbpass);
	
//temporarily accessing the DB to pull out DBname and Create Date dynamically
if(!$db)
{
	echo "Error: Could not connect to database!";
	exit;
}
//Pull out DBname from xGDB_Log table
$DB= $pserver_usergdb;
$ID = (int) (substr($DB,-3)); #calculated from DBid									
		mysql_select_db('Genomes');
		
		$get_dbinfo = "SELECT DBname, Organism, Default_GSEG, Default_lpos, Default_rpos, Create_Date FROM xGDB_Log WHERE ID=$ID;";
		$mysql_get_dbinfo = mysql_query($get_dbinfo);
		$data_get_dbinfo = mysql_fetch_assoc($mysql_get_dbinfo);
		$dbname=$data_get_dbinfo['DBname'];
		$organism=$data_get_dbinfo['Organism'];
		$default_gseg=$data_get_dbinfo['Default_GSEG'];
		$default_lpos=$data_get_dbinfo['Default_lpos'];
		$default_rpos=$data_get_dbinfo['Default_rpos'];
		$create_date=$data_get_dbinfo['Create_Date'];

		
		mysql_select_db($DB);
	
		$get_longest = "select gi, length(seq) as len from gseg as a where length(seq)= (select max(length(seq)) from gseg where gi = a.gi) order by length(seq) DESC limit 1";
		$mysql_get_longest = mysql_query($get_longest);
		$data_get_longest = mysql_fetch_assoc($mysql_get_longest);
		$longest=$data_get_longest["gi"];
		$len_longest=$data_get_longest["len"];

		$genome_query = "SELECT Organism, Genome_Type, Create_Date, Default_GSEG, Default_lpos, Default_rpos FROM Genomes.xGDB_Log where ID=$ID"; // data
		$genome_result = mysql_query($genome_query);
		$row = mysql_fetch_array($genome_result);
		$Organism = $row["Organism"];
		$Genome_Type = $row["Genome_Type"];
		$Create_Date = $row["Create_Date"];
		$default_gseg = ($row["Default_GSEG"]=="")?$longest:$row["Default_GSEG"]; #if no default is stored, use the longest gseg as default.
		$default_lpos = ($row["Default_lpos"]=="")?"1":$row["Default_lpos"];
		$default_rpos = ($row["Default_rpos"]=="")?"10000":$row["Default_rpos"];

		?>
	
	<script type="text/javascript">
/* <![CDATA[ */
function setGSEG(gi){
  document.guiFORM.gseg_gi.value = gi;
  document.guiFORM.bac_lpos.value = 1;
  document.guiFORM.bac_rpos.value = 10000;
  getRegion(<?php echo "'${CGIPATH}getGSEG_Region.pl'"; ?>);
  return 1;
}
/* ]]> */
</script>
<div id="mainWLS" align="center">
<div id="maincontents">

<h1 class="bottommargin2">
	<img alt="" src="/XGDB/images/home_mono.gif" />
   <?php echo $DB.": ".$dbname ?> <i>(<?php echo $organism; ?>)</i>
   <span class="heading">
   	 &nbsp;&nbsp;<img id='genome_home' title='Genome Browser Home Page Help' class='xgdb-help-button' src='/XGDB/images/help-icon.png' alt='?' />&nbsp;&nbsp;&#149;&nbsp;&nbsp;
   	 CREATED: <?php echo $create_date; ?>
   	 &nbsp; &nbsp; &#149;&nbsp; <a title= "View <?php echo $dbname; ?> configuration" href="/XGDB/conf/view.php?id=<?php echo $DB ?>"><img alt="" class="nudge2" src="/XGDB/images/configure.png" /> Configuration</a>
	</span>
</h1>


<fieldset  id="navigation" class="bottommargin5  GDB">
<legend class="GDB"> &nbsp;Navigation <a href="#top"><img src="/XGDB/images/top_arrow.png" alt="?" /></a></legend>
<div class="GDB indent2">
<p class="bottommargin1">
	<b>Jump to ID:&nbsp; </b><select class="normalfont" name="set_gi" onchange="setGSEG(this.value);" style="width:160px;">
		<option value="Select Phase_1 BACs"> Select a Segment ID</option>
		<?php 
//temporarily accessing the DB to pull out GSEG IDs dynamically
			mysql_select_db("$DB");
			$query = "SELECT gi, length(seq) FROM gseg ORDER BY length(seq) desc";
			$result = mysql_query($query);
			$numRows = mysql_num_rows($result);
			while($row = mysql_fetch_row($result)){
				echo "<option value=\"$row[0]\">$row[0] ($row[1] bp)</option>";
			}
		?>
	</select>
	<img id='genome_jump_to_segment' title='Help with Jump to Segment' class='xgdb-help-button nudge2' src='/XGDB/images/help-icon.png' alt='?' />
	&nbsp; &nbsp; &nbsp;
	<a title=<?php echo "\"Jump to $default_gseg from $default_lpos to $default_rpos\""; ?> style="text-decoration:none" class="bold xgdb_button colorB0"
	href=<?php echo "\"${CGIPATH}getGSEG_Region.pl?dbid=0&amp;gseg_gi=$default_gseg&amp;bac_lpos=$default_lpos&amp;bac_rpos=$default_rpos\""; ?>>View Default Region</a> 
		<img id='genome_view_default' title='View Default button explained' class='xgdb-help-button nudge2' src='/XGDB/images/help-icon.png' alt='?' />
		&nbsp; &nbsp;

	</p>

	<div class="description  showhide"><p title="Show additional genome information directly below this link" class="label normalfont" style="cursor:pointer">Click for Navigation Hints...</p>
		<div class=" hidden">
			
	<?php include_once('/xGDBvm/XGDB/help/includes/genome_navigate_hints.inc.php'); ?>
	
				<p>
					<a title="Video also available at http://vimeo.com/plantgdb/xgdbvm-1" class='topmargin1 bottommargin1 xgdb_button colorB4 flvideo-button video' id='create_genome_browser' name='28518868'>See a Video Demo</a>
				</p>
		</div>
	
	</div>
</div>
</fieldset>

<fieldset  id="overview"  class="bottommargin5  GDB">
<legend class="GDB"> &nbsp;Track Overview</b> <span class="heading"> (Click trackname for tabular view)</span> <a href="#top"><img src="/XGDB/images/top_arrow.png" alt="" /></a> </legend>
<div class="GDB indent2">
<?php

$genome_query = "SELECT Organism, Genome_Type, Create_Date, Default_GSEG, Default_lpos, Default_rpos FROM Genomes.xGDB_Log where ID=$ID"; // data
$genome_result = mysql_query($genome_query);
$row = mysql_fetch_array($genome_result);
$Organism = $row["Organism"];
$Genome_Type = $row["Genome_Type"];
$Create_Date = $row["Create_Date"];
$Default_GSEG = $row["Default_GSEG"];
$Default_lpos = $row["Default_lpos"];
$Default_rpos = $row["Default_rpos"];

$gseg_summary="<h3>Genome Segments</h3><ul class=\"bullet1 indent2\">";
   foreach ($GENOME as $index=>$track){
      $table_select=$track['table'];
      $track_select=$track['track'];
      $color_select=$track['color'];
      $num=$index;
      $query_count = "SELECT COUNT(*) FROM $table_select"; // Count
     $result_count = mysql_query($query_count);
      while($get_gseg = mysql_fetch_array($result_count)){
      $gseg=$get_gseg[0];
       }
      $gseg_display=preg_replace('/(?<=\d)(?=(\d\d\d)+$)/', ',', $gseg);

      $query_length = "SELECT SUM(Length(seq)) FROM $table_select"; // Length
      $result_length = mysql_query($query_length);
      while($get_length = mysql_fetch_array($result_length)){
         $length=$get_length[0];
        }
      $length_display=preg_replace('/(?<=\d)(?=(\d\d\d)+$)/', ',', $length);

      $gseg_summary .= "<li><span class=\"largerfont\"  style=\"border:1px solid $color_select; text-decoration:none; color:gray; background-color:$color_select\" >&nbsp;$track_select </span> &nbsp; - <b>$gseg_display</b> segments,  $length_display bp total length</li>";
   }
   $gseg_summary.="</ul>";
   echo $gseg_summary;

$mask_summary="<h3>N-Masked Regions</h3><ul class=\"bullet1 indent2\">";
   foreach ($MASK as $index=>$track){
      $table_select=$track['table'];
      $track_select=$track['track'];
      $color_select=$track['color'];
      $num=$index;
      $query_count = "SELECT COUNT(*) FROM $table_select"; // Count
     $result_count = mysql_query($query_count);
      while($get_mask = mysql_fetch_array($result_count)){
      $mask=$get_mask[0];
       }
      $mask_display=preg_replace('/(?<=\d)(?=(\d\d\d)+$)/', ',', $mask);

      $query_length = "SELECT SUM(Length(seq)) FROM $table_select"; // Length
      $result_length = mysql_query($query_length);
      while($get_length = mysql_fetch_array($result_length)){
         $length=$get_length[0];
        }
      $length_display=preg_replace('/(?<=\d)(?=(\d\d\d)+$)/', ',', $length);
      
      $gseg_count = "SELECT COUNT(DISTINCT gseg_gi) FROM gseg_${table_select}_good_pgs"; //
      $result_gseg_count = mysql_query($gseg_count);
      while($get_gseg_count = mysql_fetch_array($result_gseg_count)){
         $gcount=$get_gseg_count[0];
        }
      $repeatmask_count = "SELECT COUNT(*) FROM gseg_${table_select}_good_pgs where isCognate=\"True\""; //
      $result_repeatmask_count = mysql_query($repeatmask_count);
      while($get_repeatmask_count = mysql_fetch_array($result_repeatmask_count)){
         $rm_count=$get_repeatmask_count[0];
        }
       
      $count_display=preg_replace('/(?<=\d)(?=(\d\d\d)+$)/', ',', $gcount);
      $mask_summary .= "<li><span class=\"largerfont\"  style=\"border:1px solid $color_select; text-decoration:none; color:gray; background-color:$color_select\" >&nbsp;$track_select </span> &nbsp; - <b>$mask_display</b> total regions ($rm_count repeat regions) on $count_display segments,  $length_display bp total length</li>";
   }
   $mask_summary.="</ul>";
   echo $mask_summary;
   

/*$array = array( 'GENE', 'EST', 'PUT', 'CDNA', 'PEP');

foreach( $array as $type )

{
TODO: GENERALIZE THESE USING THE ABOVE ARRAY AND FOREACH */

      $gene_head="";
      $gene_display=0;
      $gene_summary="";
   foreach ($GENE as $index=>$track){
      $table_select=$track['table'];
      $track_select=$track['track'];
      $color_select=$track['color'];
      $display_select=$track['display'];
      $display=($display_select==0)?0:1;
      $num=$index;
   if($display !=0){
      $gene_head="<h3>Gene Models</h3><ul class=\"bullet1 indent2\">";
      $query = "SELECT COUNT(*) FROM ${DB}.gseg_${table_select}_annotation"; // Count
      $submit_query = mysql_query($query);
      $query_result = mysql_fetch_array($submit_query);
      $count=$query_result[0];
      $gene_display=$gene_display+$count;
      $gene_summary .= ($query_result[0]=="0")?"":
      "<li>
         <a style=\"text-decoration:none\" href=\"/XGDB/phplib/DisplayLoci.php?GDB=$DB&amp;track=$num\" >
         <span class=\"whitefont largerfont\" onmouseover=\"this.className='grayfont largerfont'\" onmouseout=\"this.className='whitefont largerfont'\" style=\"border:1px solid $color_select; background-color:$color_select\">
            &nbsp;$track_select 
            </span>
         </a>
          &nbsp; - <b>$count</b> gene models&nbsp;
        </li>";
      }
   }
   $gene_summary.="</ul>";
   $gene_summary=($gene_display>0)?$gene_summary:"";
   $gene_head=($gene_display>0)?$gene_head:"";
   echo $gene_head;
   echo $gene_summary;

  
      $est_head="";
      $est_summary="";
      $est_display=0;
   foreach ($EST as $index=>$track){
      $table_select=$track['table'];
      $track_select=$track['track'];
      $color_select=$track['color'];
      $display_select=$track['display'];
      $display=($display_select==0)?0:1;
      $num=$index;
   if($display !=0){
      $est_head="<h3>EST</h3><ul class=\"bullet1 indent2\">";
      $query = "SELECT COUNT(*) FROM ${DB}.gseg_${table_select}_good_pgs"; // Count
      $submit_query = mysql_query($query);
      $query_result = mysql_fetch_array($submit_query);
      $count=$query_result[0];
      $est_display=$est_display+$count;
      $est_summary .= ($query_result[0]=="0")?"":
      "<li>
         <a style=\"text-decoration:none\" href=\"/XGDB/phplib/DisplayTranscripts.php?GDB=$DB&amp;track=EST-$num\" >
         <span class=\"whitefont largerfont\" onmouseover=\"this.className='grayfont largerfont'\" onmouseout=\"this.className='whitefont largerfont'\" style=\"border:1px solid $color_select; background-color:$color_select\">
            &nbsp;$track_select 
            </span>
         </a>
          &nbsp; - <b>$count</b> spliced alignments&nbsp;
        </li>";
      }
   }
   $est_summary.="</ul>";
   $est_head=($est_display>0)?$est_head:"";
   $est_summary=($est_display>0)?$est_summary:"";
   echo $est_head;
   echo $est_summary;
   
     
      $cdna_head="";
      $cdna_summary="";
      $cdna_display=0;
   foreach ($CDNA as $index=>$track){
      $table_select=$track['table'];
      $track_select=$track['track'];
      $color_select=$track['color'];
      $display_select=$track['display'];
      $display=($display_select==0)?0:1;
      $num=$index;
   if($display !=0){
      $cdna_head="<h3>cDNA</h3><ul class=\"bullet1 indent2\">";
      $query = "SELECT COUNT(*) FROM ${DB}.gseg_${table_select}_good_pgs"; // Count
      $submit_query = mysql_query($query);
      $query_result = mysql_fetch_array($submit_query);
      $count=$query_result[0];
      $cdna_display=$cdna_display+$count;
      $cdna_summary .= ($query_result[0]=="0")?"":
      "<li>
         <a style=\"text-decoration:none\" href=\"/XGDB/phplib/DisplayTranscripts.php?GDB=$DB&amp;track=CDNA-$num\" >
         <span class=\"whitefont largerfont\" onmouseover=\"this.className='grayfont largerfont'\" onmouseout=\"this.className='whitefont largerfont'\" style=\"border:1px solid $color_select; background-color:$color_select\">
            &nbsp;$track_select 
            </span>
         </a>
          &nbsp; - <b>$count</b> spliced alignments &nbsp;
        </li>";
      }
   }
   $cdna_summary.="</ul>";
   $cdna_head=($cdna_display>0)?$cdna_head:"";
   $cdna_summary=($cdna_display>0)?$cdna_summary:"";

   echo $cdna_head;
   echo $cdna_summary;
   
      $tsa_head="";
      $tsa_display=0;
      $tsa_summary="";
   foreach ($TSA as $index=>$track){
      $table_select=$track['table'];
      $track_select=$track['track'];
      $color_select=$track['color'];
      $display_select=$track['display'];
      $display=($display_select==0)?0:1;
      $num=$index;
   if($display !=0){
      $tsa_head="<h3>TSA</h3><ul class=\"bullet1 indent2\">";
      $query = "SELECT COUNT(*) FROM ${DB}.gseg_${table_select}_good_pgs"; // Count
      $submit_query = mysql_query($query);
      $query_result = mysql_fetch_array($submit_query);
      $count=$query_result[0];
      $tsa_display=$tsa_display+$count;
      $tsa_summary .= ($query_result[0]=="0")?"":
      "<li>
         <a style=\"text-decoration:none\" href=\"/XGDB/phplib/DisplayTranscripts.php?GDB=$DB&amp;track=TSA-$num\" >
         <span class=\"whitefont largerfont\" onmouseover=\"this.className='grayfont largerfont'\" onmouseout=\"this.className='whitefont largerfont'\" style=\"border:1px solid $color_select; background-color:$color_select\">
            &nbsp;$track_select 
            </span>
         </a>
          &nbsp; - <b>$count</b> spliced alignments &nbsp;
        </li>";
      }
   }
   $tsa_summary.="</ul>";
   $tsa_head=($tsa_display>0)?$tsa_head:"";
   $tsa_summary=($tsa_display>0)?$tsa_summary:"";
   echo $tsa_head;
   echo $tsa_summary;

      $pep_head="";
      $pep_display=0;
      $pep_summary="";
   foreach ($PEP as $index=>$track){
      $table_select=$track['table'];
      $track_select=$track['track'];
      $color_select=$track['color'];
      $display_select=$track['display'];
      $display=($display_select==0)?0:1;
      $num=$index;
   if($display !=0){
      $pep_head="<h3>Protein</h3><ul class=\"bullet1 indent2\">";
      $query = "SELECT COUNT(*) FROM ${DB}.gseg_${table_select}_good_pgs"; // Count
      $submit_query = mysql_query($query);
      $query_result = mysql_fetch_array($submit_query);
      $count=$query_result[0];
      $pep_display=$pep_display+$count;
      $pep_summary .= ($query_result[0]=="0")?"":
      "<li>
         <a style=\"text-decoration:none\" href=\"/XGDB/phplib/DisplayProteins.php?GDB=$DB&amp;track=$num\" >
         <span class=\"whitefont largerfont\" onmouseover=\"this.className='grayfont largerfont'\" onmouseout=\"this.className='whitefont largerfont'\" style=\"border:1px solid $color_select; background-color:$color_select\">
            &nbsp;$track_select 
            </span>
         </a>
          &nbsp; - <b>$count</b> spliced alignments &nbsp;
        </li>";
      }
   }
   $pep_summary.="</ul>";
   $pep_head=($pep_display>0)?$pep_head:"";
   $pep_summary=($pep_display>0)?$pep_summary:"";
   echo $pep_head;
   echo $pep_summary;

//}
?>

</div>
</fieldset>

<fieldset  id="annotate"  class="bottommargin5  GDB">
<legend class="GDB"> &nbsp;Community Annotation  <a href="#top"><img src="/XGDB/images/top_arrow.png" alt="?" /></a> </legend>
<div class="GDB indent2">

<?php
							$submit_query = "SELECT COUNT(*) FROM ${DB}.user_gene_annotation where status=\"SUBMITTED_FOR_REVIEW\""; // Count
							$accepted_query = "SELECT COUNT(*) FROM ${DB}.user_gene_annotation where status=\"ACCEPTED\""; // Count
							$submit_result = mysql_query($submit_query);
							$accepted_result = mysql_query($accepted_query);
							$submit = mysql_fetch_array($submit_result);
							$accepted= mysql_fetch_array($accepted_result);
							$anno_submit=($submit[0]=="")?"0":$submit[0];
							$anno_accept=($accepted[0]=="")?"0":$accepted[0];

?>

<h2 class="bottommargin1">
	User-contributed gene structures:</h2>
		<p class="indent2"><span class="largerfont bold"> 
                        <?php echo $anno_accept ?> 
         <span style="background-color:#1FE5A9; color:white">	ACCEPTED </span>  &nbsp; and 
                         <?php echo $anno_submit ?> 
         <span style="background-color:#DF9829; color:white">	PENDING </span> &nbsp; annotations
                </span>
        </p>
        <p class="indent2">Visit <a href="/yrGATE/<?php echo $DB ?>/CommunityCentral.pl">Community Central</a> - a list of curated, community annotations for this genome. </p>
        <p class="indent2"><a href="/yrGATE/<?php echo $DB; ?>/userRegister.pl">Register</a> - create an account and contribute gene structure annotations.</p>
        
<h2 class="bottommargin1 topmargin2">Video Tutorials</h2>
        
        <p class="indent2"><a title="Annotating gene structure using yrGATE" class='flvideo-button xgdb_button colorB3 video-button-bl bottommargin1' id='using_yrgate' name='7858561'>Using yrGATE</a> </p>
        <p class="indent2"><a  title="Viewing or Editing Annotations in Community Central" class='flvideo-button xgdb_button  colorB3  video-button-bl' id='community_central' name='tbd'>Community Central</a> (tba)</p>
<h2 class="topmargin2"> More resources: </h2>
<ul class="bullet1 indent2">
	<li>
		All <a href="/XGDB/phplib/annotation.php?GDB=<?php echo $DB; ?>">video tutorials for Community Annotation </a>
	</li>
	<li>
		<a class="help_style" href="/XGDB/help/yrgate.php">yrGATE Help</a>
	</li>
</ul>
</div>
</fieldset>

<fieldset id="resources" class="bottommargin5  GDB">
<legend class="GDB"> &nbsp; Tools &amp; Resources  <a href="#top"><img src="/XGDB/images/top_arrow.png" alt="?" /></a> </legend>
<div class="GDB indent2">

<p>See also region-specific tools in the 

<a title=<?php echo "\"Jump to $default_gseg from $default_lpos to $default_rpos\""; ?> style="text-decoration:none" class="bold"
	href=<?php echo "\"${CGIPATH}getGSEG_Region.pl?dbid=0&amp;gseg_gi=$default_gseg&amp;bac_lpos=$default_lpos&amp;bac_rpos=$default_rpos\""; ?>>Genome Context View</a>
	
submenus</p>
<!--Tools-->
			
				<h2 class="topmargin1 bottommargin1">Analyze</h2>
					<?php require('tooltable.inc.php'); ?>


<!--Search / Download-->
			<h2 class="topmargin2 bottommargin1">Search / Download</h2>
						<?php require('downloadtable.inc.php'); ?>

<!--Logfiles-->
			<h2 class="topmargin2 bottommargin1">Log Files <span class="heading"> (Admin password access may be required)</span></h2>
						<?php require('logtable.inc.php'); ?>

</div>

</fieldset>
<br />

<fieldset id="help"  class="GDB">
<legend class="GDB"> &nbsp;Help Pages  <a href="#top"><img src="/XGDB/images/top_arrow.png" alt="?" /></a> </legend>
<div class="GDB indent2">

<!--Help-->
				<ul class="menulist">
					<li><a title="View All Help Resources" href="/XGDB/help/index.php">All Help Resources</a></li>
					<li><a title="Help for community central" href="/XGDB/help/community_central.php/">Community Central</a> - How to manage annotations</li>
					<li><a title="Overview of CpGAT annotation tool" href="/XGDB/help/cpgat.php/">CpGAT</a> - how to annotate genes in xGDBvm</li> 
					<li><a title="Help for how to create genome browser" href="/XGDB/help/create_gdb.php">Creating a Browser</a></li>
					<li><a title="Overview of data requirements for xGDBvm pipeline" href="/XGDB/help/requirements.php">Data Requirements</a> - how to format and name your input data files</li>
					<li><a title="Overview of GAEVAL evaluation system for gene congruence with data" href="/XGDB/help/gaeval.php/">GAEVAL</a> - Understanding gene quality scores</li> 
					<li><a title="Help for how to view genome browser" href="/XGDB/help/genome_browser.php">Genome Browser</a> - Viewing, Searching, Analyzing</li>
	                <li><a title="Tabular view of data inputs and outputs for xGDBvm pipeline" href="/XGDB/conf/input_output.php">Inputs / Outputs</a>- table showing each input data type, scripts that use it, and output types and locations</li> 
					<li><a title="Overview of Locus Tables - CpGAT and pre-computed" href="/XGDB/help/feature_tracks.php/">Feature Tracks</a> - Viewing, searching track data</li> 
					<li><a title="Wiki documentation" href="/http://goblinx.soic.indiana.edu/wiki/">Wiki</a> - a support wiki for xGDBvm</li> 
					<li><a title="Help for yrGATE community annotation tool" href="/XGDB/help/yrgate.php/">yrGATE</a> - How to annotate genes</li>
				</ul>
</div>
</fieldset>

<div style="clear:both">

</div>
						  <div style="clear:both; float:right" class="topmargin1 bottommargin1">
							<a href="http://validator.w3.org/check?uri=referer"><img
							  src="http://www.w3.org/Icons/valid-xhtml10" alt="Valid XHTML 1.0 Transitional" height="15" width="44" /></a>
						  </div>						

</div><!-- end maincontents -->

</div><!-- end mainWLS-->
