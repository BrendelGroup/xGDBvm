<?php
if (preg_match('/(GDB\d\d\d)/', $_SERVER['HTTP_REFERER'], $matches))
	$X = $matches[1];
if ($_GET['GDB']) //the user can select a version from the dropdown; GDB consists of GDBnnn
	$X = $_GET['GDB'];

$X1 = substr($X,3,3); //e.g. 001

require('/xGDBvm/XGDB/phplib/sitedef.php'); // For list of available GDBs
include_once('/xGDBvm/XGDB/phplib/db.inc.php');
if(empty($SITEDEF_H)) { require('/xGDBvm/INSTANCES/GDB' . $X1 . '/conf/SITEDEF.php'); }
if(empty($PARAM_H)){require('/xGDBvm/XGDB/phplib/getPARAM.php');}
require('/xGDBvm/XGDB/phplib/SSI_GDBprep.php');
virtual("${CGIPATH}SSI_GDBgui.pl/TWO_COLUMN_HEADER/" . $SSI_QUERYSTRING);


$pgdbmenu = "Genomes";

$leftmenu = 'annotation';
$PageTitle = $DBid.  "Annotation Videos";
	
	$id = (int) substr('00'. mysql_real_escape_string($_GET['GDB']), -3); //picks up either 3 or GDB003   TODO - need to further sanitize since numerical
	$DBid = "GDB".substr('00'. $id, -3);
	
	
	$dbpass=dbpass();
	$link = mysql_pconnect("localhost", "gdbuser", $dbpass) or die(mysql_error());
	$dbh = mysql_select_db("$DBid", $link); //
	
	$query = "SELECT uid FROM user_gene_annotation"; //
	$result = mysql_query($query);
	$anno_total = mysql_num_rows($result);
	
				?>


<div id="mainWLS2">
<div id="maincontentscontainer">
<div id="maincontents" class="<?php echo $display; ?>">
<h1 class="topmargin1 bottommargin1 conf resource anno">Community Annotation with yrGATE</h1>

<h2>What's this?</h2>

 <p>Users can create a <a href="/yrGATE/<?php echo $DB; ?>/userRegister.pl">login account </a> and contribute gene structure annotations using the <a class="help_style" href="/XGDB/help/yrgate.php">yrGATE tool</a>. The <a class="help_style" href="/XGDB/help/gaeval.php">GAEVAL</a> system makes it easy to identify gene structures that are likely to be incorrect. User-submitted annotations are curated and published on the <a href="/yrGATE/<?php echo $DB ?>/CommunityCentral.pl">Community Annotation Central</a> page of this GDB.</p>

 <p class="indent2"><b>Currenty there are <?php echo $anno_total; ?> community annotations for <?php echo $DBid; ?></b></p>

<h2>Resources</h2>

<ul class="bullet1">
	<li class="NavMenu"><a class="help_style" title="Help for yrGATE community annotation tool" href="/XGDB/help/yrgate.php">Using yrGATE</a></li>
	<li class="NavMenu"><a class="help_style" title="List of community-annotated genes" href="/XGDB/help/community_central.php">Using Comm Central</a></li>
	<li class="NavMenu"><a class="help_style" title="Overview of GAEVAL evaluation system for gene congruence with data" href="/XGDB/help/gaeval.php">Using GAEVAL</a></li>
</li>
</ul>

<h2 class="topmargin1"> See how it works, step by step!</h2>
<p class=""> Click any step below with a <img class='nudge2' src='/XGDB/images/video_gr25.png' /> icon to view a brief video tutorial: <span class='colorGR2 xgdb_button' style='width:10px'> Overview </span> &nbsp; <span class='colorGR3 xgdb_button'> Detailed  </span>  &nbsp; <span class='colorGR4 xgdb_button'> Administrator </span> </p>
<p class="tip_stylse"><b>NOTE</b>: you may need to configure your browser to allow popups</p>

<?php require('/xGDBvm/XGDB/help/includes/annotation_tutorials.inc.php'); ?>


		</div>
		</div><!-- end maincontentscontainer -->
		</div><!-- end mainWLS-->
<?php
//require('SSI_GDBprep.php');
require('/xGDBvm/XGDB/phplib/SSI_GDBprep.php');
virtual("${CGIPATH}SSI_GDBgui.pl/STANDARD_FOOTER/" . $SSI_QUERYSTRING);
?>
