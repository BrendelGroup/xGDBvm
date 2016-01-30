<?php
#error_reporting(E_ALL & ~E_NOTICE); //disable undeclared variable error

session_start();
include_once('/xGDBvm/XGDB/phplib/db.inc.php');
if (preg_match('/(GDB\d\d\d)/', $_SERVER['HTTP_REFERER'], $matches))
        $X = $matches[1];
if (preg_match('/(GDB\d\d\d)/',$_REQUEST['GDB'], $matches)) ;
        $X = $matches[1];

if(empty($SITEDEF_H)) { require('/xGDBvm/data/' . $X .'/conf/SITEDEF.php'); }
if(empty($PARAM_H)){require('/xGDBvm/XGDB/phplib/getPARAM.php');}
require_once('/xGDBvm/XGDB/phplib/SSI_GDBprep.php');
virtual("${CGIPATH}SSI_GDBgui.pl/STANDARD_HEADER/$SSI_QUERYSTRING");
require_once('/xGDBvm/XGDB/phplib/DisplayLoci_functions.inc.php');
?>
<link rel="stylesheet" type="text/css" href="/XGDB/css/GDBstyle.css" />
<?php
$pgdbmenu = "Genomes";
$DBid = $X;
$myDBver="0"; #versions not implemented in xGDBvm
$leftmenu = "AllGenes";
$PageTitle = "All".$DBid.  " Genes";

	$Source = mysql_real_escape_string($_GET['source']); //Source of gene models for GAEVAL display
		if($Source == 'GFF'){
	$Source_display = 'Pre-computed';
	$DBtable='gseg_locus_annotation';
	$display_message="<p class=\"largerfont bold alertnotice topmargin2 bottommargin2\">NOTE: There are no data in this table because a GFF table has not been provided for this genome.<br /> <br /> 
To upload a pre-existing set of gene models from a GFF file, go to the <a href=\"/XGDB/conf/view.php?id=$X\">$X configuration page </a> and follow the instructions to update with GFF option.</p>";
	}elseif($Source == 'CpGAT'){
	$Source_display = 'from CpGAT';
	$DBtable='gseg_cpgat_locus_annotation';
	$display_message="<p class=\"largerfont bold alertnotice topmargin2 bottommargin2\">NOTE: There are no data in this table because CpGAT has not been run for this genome.<br /> <br /> 
To run CpGAT and generate a set of gene models, go to the <a href=\"/XGDB/conf/view.php?id=$X\">$X configuration page </a> and follow the instructions to update with CpGAT option.</p>";
	}else{
	$display_message="<span class=\"largerfont bold alertnotice topmargin2 bottommargin2\">NOTE: There are no data because a source (GFF, CpGAT) has not been specified.";
	}
	
	
	$recordPoint='getGSEG_Region.pl';
	$l_posName='bac_lpos';
	$r_posName='bac_rpos';
	$idname='gseg_gi';
$dbpass=dbpass();
$link = mysql_pconnect("localhost", "gdbuser", $dbpass) or die(mysql_error());
$dbh = mysql_select_db("$DBid", $link); //



//session and other variables
$sessID=$Source.$X; //a unique ID root for session variables. Needs to include source and GDBid

$s_limit = $sessID."limit";
$s_page = $sessID."page";
$s_query = $sessID."query";

$s_passed = array(); //which post (1, 2, etc)
$s_field = array(); //the query field
$s_word = array(); //the query item
$s_link = array(); //link builder
$n=5;//adjust to match number of simultaneous query sessions
$i=1;
while($i<=$n){//create unique session array names
	$s_passed[$i]=$sessID."passed".$i;
	$s_field[$i]=$sessID."field".$i;
	$s_word[$i]=$sessID."word".$i;
	$s_link[$i]=$sessID."link".$i;
  $i++;
  }

?>

<div id="mainWLS2">
	<div id="maincontentscontainer">
		<div id="maincontents">

		<h1 class="bottommargin1"><?php echo $submenu; ?> Annotation Projects &nbsp; <img id="displayprojects_dialog" title="Click for Gene Loci Help" style="margin-bottom:-1px" src="/XGDB/images/help-icon.png" alt="?" class="xgdb-help-button" /> <span class="heading link">&nbsp;[<a href="/XGDB/phplib/DisplayLoci.php?source=<?php echo $Source; ?>&amp;GDB=<?php echo $DBid; ?>">Return to Loci/Annotations Page</a>]</span>&nbsp;&nbsp;
		</h1>
		
		<p>Projects are informal gene categories intended as an aid to annotators. <b>Click a number</b> in columns 4 - 7 to view entries.<br />
		</p>
				<?php include_once('/xGDBvm/XGDB/phplib/projects.inc.php'); ?>
				<br />
		<p>*NOTE that since a locus may be assigned to more than one project, the aggregate total for projects will be greater than the total for all loci/annotations.</p> 
		</div>
	</div><!--mainWLS2-->
</div>
<?php include("/xGDBvm/XGDB/phplib/footer.php"); ?>
</div>
</body>
</html>
