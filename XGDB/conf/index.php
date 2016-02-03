<?php
session_start();
	$global_DB= 'xGDBvm';
	$PageTitle = 'xGDBvm Configure';
	$pgdbmenu = 'Manage';
	$submenu1 = 'Config-Home';
	$submenu2 = 'Config-Home';
	$leftmenu='Config-Home';
	include('sitedef.php');
	include($XGDB_HEADER);
	include_once('/xGDBvm/XGDB/phplib/db.inc.php');
include_once('/xGDBvm/XGDB/conf/conf_functions.inc.php'); #common functions required in this script
	$dbpass=dbpass();
		$db = mysql_connect("localhost", "gdbuser", $dbpass);
	if(!$db)
	{
		echo "Error: Could not connect to database!";
		exit;
	}
		mysql_select_db("$global_DB");

		## count number of GDB.
		$curr_query = "select count(ID) from xGDB_Log where Status='Current'";
		$check_get_curr = mysql_query($curr_query);
		$get_curr_query = mysql_fetch_array($check_get_curr);
		$curr_count = $get_curr_query[0];
		$dev_query = "select count(ID) from xGDB_Log where Status='Development'";
		$check_get_dev = mysql_query($dev_query);
		$get_dev_query = mysql_fetch_array($check_get_dev);
		$dev_count = $get_dev_query[0];
		$lock_query = "select count(ID) from xGDB_Log where Status='Locked'";
		$check_get_lock = mysql_query($lock_query);
		$get_lock_query = mysql_fetch_array($check_get_lock);
		$lock_count = $get_lock_query[0];
		$total_count=$dev_count+$curr_count+$lock_count;

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


		
		$path1="/xGDBvm/";
	$df_array1=df_available($path1);
	$filesys1=$df_array1[0];
	$available1=$df_array1[1];
	$gb1=round($available1/1000000, 1);
	
	$path2="/xGDBvm/data/";
	$df_array2=df_available($path2);
	$filesys2=$df_array2[0];
	$available2=$df_array2[1];
	$gb2=round($available2/1000000, 1);
	
	$path3="/xGDBvm/data/scratch/";
	$df_array3=df_available($path3);
	$filesys3=$df_array3[0];
	$available3=$df_array3[1];
	$gb3=round($available3/1000000, 1);

	
	$path4="/xGDBvm/data/mysql/";
	$df_array4=df_available($path4);
	$filesys4=$df_array4[0];
	$available4=$df_array4[1];
	$gb4=round($available4/1000000, 1);

## License key status

# Validate license keys (conf_functions.inc.php validate_dir($dir, $target, $description, $present, $absent)
$validate_gm=validate_dir($GENEMARK_KEY_DIR, $GENEMARK_KEY, "GeneMark License Key", "installed", "not installed");
$gm_valid=$validate_gm[0]; $gm_class=$validate_gm[1];
$validate_gth=validate_dir($GENOMETHREADER_KEY_DIR, $GENOMETHREADER_KEY, "GenomeThreader License Key", "installed", "not installed");
$gth_valid=$validate_gth[0]; $gth_class=$validate_gth[1];
$validate_vm=validate_dir($VMATCH_KEY_DIR, $VMATCH_KEY, "Vmatch License Key","installed", "not installed");
$vm_valid=$validate_vm[0]; $vm_class=$validate_vm[1];

	
## Set GDB message (list items) based on status totals
	$gdb_message.=($total_count==0)? "<li><span class=\" warning\"> No GDB have been configured</li>":"";
	$gdb_message.=($lock_count==1)? "<li><span class=\" warning darkgrayfont largerfont\"> This VM currently has $lock_count GDB config with status <span class=\"Locked\">'Locked></span> </span>(<a href=\"/XGDB/conf/viewall.php\">View list</a>)</li>":"";
	$gdb_message.=($dev_count>0)?"<li><span class=\"normalfont largerfont\"> This VM currently has $dev_count GDB with status <span class=\"Development\">'Development></span> </span>(<a href=\"/XGDB/conf/viewall.php\">View list</a>)</li>":"";
	$gdb_message.=($curr_count>0)?"<li><span class=\"normalfont largerfont\"> This VM currently has $curr_count GDB with status <span class=\"Current\">'Current'</span></span> (<a href=\"/XGDB/conf/viewall.php\">View list</a>) </li>":"";

	$DBdropdown = "
		<form method=\"post\" name=\"search_dbid\" action=\"/XGDB/conf/view.php\">
			<td class=\"\" width=\"30%\">
					<input type=\"submit\" class=\"xgdb_button colorConf2 largerfont\" value=\"View Configuration:\" name=\"View\" />
					<input type=\"hidden\" name=\"passed\" value=\"1\" />
					<select name=\"id\" class=\"largerfont\" style=\"background-color:#FBD896\">
					$defaultDB
					$db_list
					</select>
					 - Select an existing configuration
			</form>
	";
	
	$conditional_nogdb=($_SESSION['gdbid']=="" || $total_count == 0 )?"display_off":""; // hide button if no id has been edited already, or no GDB configured
	$conditional_nolist=( $total_count == 0 )?"display_off":"";
	$conditional_gdb=($total_count != 0 )?"display_off":""; // hide alt (greyed out) button if GDB have been configured
	?>


				<div id="leftcolumncontainer">
					<div class="minicolumnleft">
						<?php include_once("/xGDBvm/XGDB/conf/leftmenu.inc.php"); ?>
					</div>
				</div>
				<div id="maincontentscontainer" class="twocolumn overflow configure">
					<div id="maincontents">	
							<h1 class="configure bottommargin1"><img alt="" src="/XGDB/images/configure.png" /> Configure/Create: <i>Getting Started</i> <img id='config_home' title='Getting started to create a GDB. Click ? for details.' class='help-button nudge1' src='/XGDB/images/help-icon.png' alt='?' /></h1>
							
							<div>
								<ul class="bullet1 indent2">
									<?php echo $gdb_message ?>
								</ul>
							</div>
				<p class="topmargin2"><span class="largerfont"><b>Click below</b> for a step-by-step guide to creating a new genome database <b>(GDB)</b></span></p>	

						<div class="feature">			

								<table style="padding:0 0 0 40px">
									<tr>
										<td>
											<p><a title="Step-by-Step Instructions to Create GDB" href="/XGDB/conf/instructions.php" class="xgdb_button colorConf1 largerfont">Stepwise Instructions</a></p>
										</td>
										<td>
											<p></p>
										</td>
									</tr>
								</table>
						</div>
						<div class="feature topmargin1">
						<p class="topmargin2"><span class="largerfont"><b>Click the links below</b> to set up and configure your GDB, or choose from the menu at left.</span></p>
						</div>
							<div class="feature">
							<h2 class="indent2 bottommargin1">1. Initial Setup</h2>
								<table style="padding:0 0 0 40px">
									<tr>
										<td>
											<p><a title="Confirm Data Volumes" href="/XGDB/conf/volumes.php" class="xgdb_button colorConf2 largerfont">Data Volumes</a></p>
										</td>
										<td>
											<p>Click for more details on how to configure correctly for your data requirements.<br />
											Free space (GB): <span class="plaintext">/xGDBvm/</span> <span class=" bold"><?php echo $gb1 ?></span>; <span class="plaintext">/xGDBvm/data/</span> <span class=" bold"><?php echo $gb2 ?></span>;  <span class="plaintext">/xGDBvm/data/scratch/</span> <span class=" bold"><?php echo $gb3 ?></span>; <span class="plaintext">/xGDBvm/data/mysql/</span> <span class=" bold"><?php echo $gb4 ?></span> </p>
										</td>
									</tr>
								</table>
								<table style="padding:0 0 0 40px">
									<tr>
										<td>
										<p><a title="Input data requirements" href="/XGDB/conf/licenses.php" class="xgdb_button colorConf2 largerfont">License Keys</a> 
										</p>
										</td>
										<td>
											<p>Click to manage software licenses.<br />
											 License status: 
										    <span class="<?php echo $gm_class ?>">
                                                    GeneMark <?php echo $gm_valid ?>
                                            </span>
										    <span class="<?php echo $vm_class ?>">
                                                    Vmatch <?php echo $vm_valid ?>
                                            </span>
										    <span class="<?php echo $gth_class ?>">
                                                    GenomeThreader <?php echo $gth_valid ?>
                                            </span>
											</p>
										</td>
									</tr>
								</table>
								<table style="padding:0 0 0 40px">
									<tr>
										<td>
											<p><a title="Configure External Processing" href="/XGDB/jobs/index.php" class="xgdb_button colorConf2 largerfont">Remote Jobs (HPC)</a></p>
										</td>
										<td>
											<p>Click to configure xGDBvm to send data to a High Performance Compute cluster (optional).</p>
										</td>
									</tr>
								</table>
						</div>
						<div class="feature">
							<h2 class="indent2 bottommargin1">2. Data Inputs</h2>
								<table style="padding:0 0 0 40px">
									<tr>
										<td>
											<p><a title="Input data requirements" href="/XGDB/conf/sources.php" class="xgdb_button colorConf3 largerfont">Data Sources</a></p>
										</td> 
										<td>
											<p>A decision tree for choosing input data</p>
										</td>
									</tr>
								</table>
								<table style="padding:0 0 0 40px">
									<tr>
										<td>
											<p><a title="Input data requirements" href="/XGDB/conf/data.php" class="xgdb_button colorConf3 largerfont">Data Requirements</a></p>
										</td>
										<td>
											<p>View filename conventions and instructions for preparing input data</p>
										</td>
									</tr>
								</table>
							</div>
						<div class="feature">
							<h2 class="indent2 bottommargin1">3. Configure / Create Browser</h2>
								<table style="padding:0 0 0 40px">
									<tr>
										<td>
											<p><a title="configure new GDB" href="/XGDB/conf/new.php" class="xgdb_button colorConf4 largerfont">Configure New GDB</a></p>
										</td>
										<td>
											<p>Click to initiate a <b>new GDB configuration</b></p>
										</td>
									</tr>
								</table>
								<table style="padding:0 0 0 40px">
									<tr>
										<td>
											<p><a title="configure new GDB" href="/XGDB/conf/new.php?example=All" class="xgdb_button colorConf4 largerfont">Try an Example</a></p>
										</td>
										<td>
											<p>Click to try a <b>sample dataset</b></p>
										</td>
									</tr>
								</table>
						</div>
						<div class="feature">
							<h2 class="indent2 bottommargin1">4. Manage Configurations</h2>
								<table style="padding:0 0 0 40px">
									<tr class="<?php echo $conditional_nolist ?>">
										<td>
											<p><a title="manage configured" href="/XGDB/conf/viewall.php" class="xgdb_button colorConf5 largerfont">List All Configured</a></p>
										</td>
										<td>
											<p>Click to view <b>list of configured GDB's</b> with links and statistics for each.</p>
										</td>
									</tr>
									<tr class="<?php echo $conditional_gdb ?>">
										<td>
											<p><a title="manage configured" href="/XGDB/conf/viewall.php" class="xgdb_button colorConf5 largerfont">List All Configured</a></p>
										</td>
										<td>
											<p><span class="warning">No GDB have been configured yet so this button will display an <b>empty list</b>. But go ahead if you are curious! </span></p>
										</td>
									</tr>
								</table>
								<table style="padding:0 0 0 40px">
									<tr  class="<?php echo $conditional_nogdb ?>">
										<td >
											<p><a title="edit most recently accessed GDB" href="/XGDB/conf/view.php?id=<?php echo $_SESSION['id']; ?>" class="xgdb_button colorConf5 largerfont"><span style="color:yellow"><?php echo $_SESSION['gdbid']; ?> Config</span></a></p>
										</td>
										<td>
											<p>Edit most recently configured GDB</p>
										</td>
									</tr>
								</table>
								<table style="padding:0 0 0 40px">
									<tr>
										<td >
											<p><a title="archive or restore GDB" href="/XGDB/conf/archive.php" class="xgdb_button colorConf5 largerfont"> Archive/Restore</a></p>
										</td>
										<td>
											<p>Save your GDB data as an archive for sharing or restoring</p>
										</td>
									</tr>
								</table>
						</div>
						<div class="feature">
							<h2 class="indent2 bottommargin1">5. Other Settings</h2>
								
								<table style="padding:0 0 0 40px">
									<tr>
										<td>
											<p><a title="Configure Admin Features" href="/admin/index.php" class="xgdb_button colorG2 largerfont">Administrate Access</a></p>
										</td>
										<td>
											<p>Restrict access to admin pages, set up login passwords, manage yrGATE users</p>
										</td>
									</tr>
									<tr>
										<td>
											<p><a title="Configure Remote Processing" href="/XGDB/jobs/index.php" class="xgdb_button colorJobs3 largerfont">Remote HPC Jobs</a></p>
										</td>
										<td>
											<p>Configure High Performance Compute options</p>
										</td>
									</tr>
								</table>
							</div>
						<hr class="featuredivider topmargin1" />
						</div><!--end maincontents-->
						  <div style="clear:both; float:right">
							<a href="http://validator.w3.org/check?uri=referer"><img
							  src="http://www.w3.org/Icons/valid-xhtml10" alt="Valid XHTML 1.0 Transitional" height="15" width="44" /></a>
						  </div>						
					</div><!--end maincontentsfull-->
				</div><!--end maincontentscontainer-->
				<?php include($XGDB_FOOTER); ?>
			</div><!--end innercontainer-->
		</div><!--end outercontainer-->
	</body>
</html>