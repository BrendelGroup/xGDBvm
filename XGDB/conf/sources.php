<?php
error_reporting(E_ALL & ~E_NOTICE); //disable undeclared variable error
session_start();

	$global_DB= 'Genomes';
	$PageTitle = 'xGDBvm Data Sources';
	$pgdbmenu = 'Manage';
	$submenu1 = 'Config-Home';
	$submenu2 = 'Config-Sources';
	$leftmenu='Config-Sources';
	$warning_msg='';
	include('sitedef.php');
	include($XGDB_HEADER);
include_once(dirname(__FILE__).'/conf_functions.inc.php');
include_once(dirname(__FILE__).'/validate.php');
include_once('/xGDBvm/XGDB/phplib/db.inc.php');
$dbpass=dbpass();
#$ExtraHeadInfo = "
#</script>
#<script language=\"javascript\" type=\"text/javascript\" src=\"/XGDB/javascripts/fillFields.js\">
#</script>
#"; //testing J Duvick 9/3/12


	$db = mysql_connect("localhost", "gdbuser", $dbpass);
	if(!$db)
	{
		echo "Error: Could not connect to database!";
		exit;
	}
	mysql_select_db("$global_DB");
	$error = $_GET['error'];
	
	?>
						
						<div id="leftcolumncontainer">
							<div class="minicolumnleft">
							<?php include_once("/xGDBvm/XGDB/conf/leftmenu.inc.php"); ?>
							</div>
						</div>
				
							<div id="maincontentscontainer" class="twocolumn overflow configure">
								<div id="maincontentsfull" class="configure">
								<h1 class="configure bottommargin1"><img alt="" src="/XGDB/images/configure.png" /> Choose Data Sources <img id='config_data_sources' title='Here you can learn what types of data to use. Click ? for details.' class='help-button nudge1' src='/XGDB/images/help-icon.png' alt='?' /></h1>
								<div class="feature">									
											<p><span class="largerfont">Use the following table to guide you to the correct data sources for your genome annotation</span></p>
	
											<p><span class="largerfont">Next you will need to prepare data files according to filename and ID conventions -- see <a href="/XGDB/conf/data.php">Data Requirements</a> page</span></p>
	
											<p><span class="largerfont">To upload data to your Data Store (iPlant users), use the <a href="http://preview.iplantcollaborative.org/de/?type=data">iPlant Data Tool</a></span></p>
								</div>
								<div class="feature">
								<h2 class="topmargin1 bottommargin1">Sequence type (jump to section)</h2>
								<ul class="menulist">
									<li>
										<a href="#gdna">Genome Sequence</a> - assembled as pseudochromosomes or (super)scaffolds
									</li>
									<li>
										<a href="#transcr">Transcripts/Proteins</a> - may be from same or related species; splice-aligned to genome as an aid to gene-finding
									</li>
									<li>
										<a href="#anno">Annotations</a> - previously-computed gene models that can be displayed along with the above
									</li>
								</ul>
								</div>
								<div class="feature topmargin2" style="background:#CCC">									
								<?php include_once("/xGDBvm/XGDB/help/includes/config_data_decisions-gdna.inc.php"); ?>
								</div>
								<div class="feature" style="background:#CCC">									
								<?php include_once("/xGDBvm/XGDB/help/includes/config_data_decisions-transcr.inc.php"); ?>
								</div>
								<div class="feature" style="background:#CCC">									
								<?php include_once("/xGDBvm/XGDB/help/includes/config_data_decisions-anno.inc.php"); ?>
								</div>
							</div><!--end maincontents-->
						  <div style="clear:both; float:right">
							<a href="http://validator.w3.org/check?uri=referer"><img
							  src="http://www.w3.org/Icons/valid-xhtml10" alt="Valid XHTML 1.0 Transitional" height="15" width="44" /></a>
						  </div>						
						</div><!--end maincontentscontainer-->
						<div id="rightcolumncontainer">
						</div><!--end rightcolumncontainer-->
			<?php include($XGDB_FOOTER); ?>
		</div></div></div>
	</body>
</html>
