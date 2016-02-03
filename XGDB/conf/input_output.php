<?php
error_reporting(E_ALL & ~E_NOTICE); //disable undeclared variable error
	$global_DB= 'Genomes';
	$PageTitle = 'xGDBvm Inputs Outputs';
	$pgdbmenu = 'Configure';
	$submenu = 'Data';
	$leftmenu='Config-Data';
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
						
				
		<div id="maincontentscontainer" class="onecolumn">
		<div id="maincontentsfull" style="overflow:auto">
							<div class="feature">									
									<h1 class="admin bottommargin1 darkgrayfont"><img alt="" src="/XGDB/images/configure.png" /> Data Inputs/Outputs <img id='config_data' title='Here you can confirm the correct data directories. Click ? for details.' class='help-button nudge1' src='/XGDB/images/help-icon.png' alt='?' /></h1>
									
										<p>The table below describes each input data type/filename, and its equivalent output date type/filename/location. <a href="/XGDB/conf/data.php">Return to Data Requirements</a></p>

							<div class="feature">									
							<?php include_once("/xGDBvm/XGDB/help/includes/config_input_output.inc.php"); ?>
							</div>							
							</div><!--end maincontents-->
						</div><!--end maincontentscontainer-->
						<div id="rightcolumncontainer">
						</div><!--end rightcolumncontainer-->
			<?php include($XGDB_FOOTER); ?>
		</div></div></div>
	</body>
</html>
