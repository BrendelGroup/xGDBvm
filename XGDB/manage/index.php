<?php
session_start();
	$global_DB= 'xGDBvm';
	$PageTitle = 'xGDBvm Manage';
	$pgdbmenu = 'Manage';
	$submenu = 'Manage-Home'; 
	$leftmenu='Manage-Home';
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

		# Generate database list for select statement.
		$dbid_query = "SELECT ID, DBname FROM xGDB_Log order by ID ASC";
		$rows = mysql_query($dbid_query);
		global $db_list;
		while($row = mysql_fetch_array($rows))
			{
			$ID="00".$row['ID'];
			$ID=substr($ID, -3, 3);
			$GDB="GDB".$ID;
		  	$db_list .= "<option value=\"".$row['ID']."\">".$GDB.". ".$row['DBname']."</option>\n";
		}
		# Default for dropdown:
		$default_query = "SELECT ID, DBname FROM xGDB_Log order by ID ASC limit 1";
		$default_row = mysql_query($default_query);
		while($default = mysql_fetch_array($default_row))
			{
			$ID="00".$default['ID'];
			$ID=substr($ID, -3, 3);
			$GDB="GDB".$ID;
			$defaultDB = "<option value=\"".$default['ID']."\">".$GDB.": ".$default['DBname']."</option>";
		}
	$DBdropdown = "
		<form method=\"post\" name=\"search_dbid\" action=\"/XGDB/conf/view.php\">
			<td class=\"\" width=\"30%\">
					<input type=\"submit\" class=\"xgdb_button colorConf4 largerfont\" value=\"View Configuration:\" name=\"View\" />
					<input type=\"hidden\" name=\"passed\" value=\"1\" />
					<select name=\"id\" class=\"largerfont\" style=\"background-color:#FBD896\">
					$defaultDB
					$db_list
					</select>
					 - Select an existing configuration
			</form>
	";
	$conditional_gdb=($_SESSION['gdbid']=="")?"display_off":""; // hide button if no id has been edited already
	
	?>

						<div id="leftcolumncontainer">
					<div class="minicolumnleft">
						<?php include_once("/xGDBvm/XGDB/manage/leftmenu.inc.php"); ?>
					</div>
				</div>
					<div id="maincontentscontainer" class="twocolumn overflow configure">
						<div id="maincontents">	
							<h1 class="admin bottommargin1"><img alt="" src="/XGDB/images/configure.png" /> Manage xGDBvm: <i>Getting Started</i> <img id='manage_overview' title='Getting started to manage xGDBvm. Click ? for details.' class='help-button nudge1' src='/XGDB/images/help-icon.png' alt='?' /></h1>
							<div class="feature">			
								<p><span class="largerfont"><b>Manage</b> is where you <b>set up/secure your VM</b>, and <b>configure/create genome browsers</b>. </span></p>
								<p><span class="tip_style">Just getting started?</span><span class="instruction">Visit <b>Admin</b> pages first to secure and name your website, and then proceed to <b>Configure/Create</b> to explore how to create a GDB. iPlant users may need to configure <b>Remote HPC</b>.</span></p>
								<p class="indent2"><span class="warning">NOTE: login credentials may be required to access these pages. </span></p>
							</div>
							<div class="feature">
									<div class="big_button">
										<span class="bold hugefont grayfont">1. </span><a title="Manage passwords on this VM" href="/admin/index.php" class="xgdb_button colorG2 largerfont">  <img src="/XGDB/images/user.png" alt="" /> Admin Setup/Secure &nbsp;&nbsp;</a>
										<span class="normalfont"> - Administer password protection, name your xGDBvm, manage yrGATE users </span>
									</div>
									<div class="big_button">
										<span class="bold hugefont grayfont">2. </span><a title="Genome configuration" href="/XGDB/conf/index.php" class="xgdb_button colorConf4 largerfont"> <img alt="" src="/XGDB/images/configure.png" /> Configure/ Create GDB</a>
										<span class="topmargin1 normalfont">  - Configure and create a new GDB (Genome Data Broker) using your data.</span>
									</div>

									<div class="big_button">
										<span class="bold hugefont grayfont">3. </span> <a title="Genome configuration" href="/XGDB/jobs/index.php" class="xgdb_button colorJobs4 largerfont"> <img alt="" src="/XGDB/images/remote_compute.png" /> Remote HPC Jobs  &nbsp;&nbsp; &nbsp;&nbsp; &nbsp;</a>
										<span class="topmargin1 normalfont"> - Set up / manage remote spliced alignment jobs (optional - iPlant users only)</span>
									</div>
							</div>
					</div><!--end maincontents-->
					

				  <div style="clear:both; float:right">
					<a href="http://validator.w3.org/check?uri=referer"><img
					  src="http://www.w3.org/Icons/valid-xhtml10" alt="Valid XHTML 1.0 Transitional" height="15" width="44" /></a>
				  </div>
  
				</div><!--end maincontentscontainer-->
					<?php include($XGDB_FOOTER); ?>
				</div><!--end pagewidth-->
			</div><!--end innercontainer-->
		</div><!--end outercontainer-->
	</body>
</html>