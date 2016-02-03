<?php
session_start();
	$global_DB= 'xGDBvm';
	$PageTitle = 'xGDBvm View Genomes';
	$pgdbmenu = 'Genomes';
	$submenu = 'View-Home'; 
	$leftmenu='View-Home';
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
	?>


				<div id="leftcolumncontainer">
					<div class="minicolumnleft">
						<?php include_once("/xGDBvm/XGDB/leftmenu.inc.php"); ?>
					</div>
				</div>
				<div id="maincontentscontainer" class="twocolumn overflow configure">
						<div id="maincontents">	
								<h1 class="bottommargin1">View Genomes: <i>Getting Started</i> <img id='view' title='Getting started to view/analyze a GDB. Click ? for details.' class='help-button nudge1' src='/XGDB/images/help-icon.png' alt='?' /></h1>
							<div class="feature">			
								
								<div class="description  showhide"><p title="Show additional information directly below this link" class="normalfont" style="cursor:pointer">You can browse, search and analyze genome data in Genome Data Brokers <b>(GDB)</b> created on this VM (click for more info...)</p>
									<div class=" hidden">
		
											<ul class="bullet1" style="list-style-type:none"	>
												<li>1) Access any GDB from the dropdown <i>View</i> menu above, or click <a title="Current xGDBvm Genome Browser list" href="/XGDB/genomes.php"><i>Current Genomes</i></a> to view all GDB with links to data and tools.</li>
												<li>2) For each GDB, <b>Genome Context View</b> displays all features (genes, aligned transcripts, etc.) for a region and supports zooming, scrolling, and track customizing.
												<li>3) Each GDB has multiple <b>search</b> features allowing you to retrieve sequence features by ID or keyword</li>
												<li>4) Blast and spliced alignment tools (GeneSeqer, GenomeThreader) are available for similarity searching or spliced-alignment</li>
												<li>5) You can re-annotate a region using CpGAT, or add your own annotation data for display.</li>
											</ul>
		
									</div>
								</div>
							</div>
							<div class="feature">
								 <h3 class="topmargin1">Click a GDB link below to browse the genome:</h3>
							</div>
							<div class="feature">
								 <ul class="directorylist bottommargin1 indent2">
										<?php asort($xGDB);
					                 	foreach ($xGDB as $key=>$value){
						                echo "<li class=\"indent2\"><a style=\"text-decoration:none\" class=\"xgdb_button colorO2\" href=\"/$value/\">$value </a> &nbsp;<span class=\"largerfont\"> - $key</span></li>";
					                     }?>
                                    </ul>
                            </div>
							<div class="feature">
								 <h3 class="topmargin1">More links:</h3>
							</div>
									<div class="big_button">
										<a title="Current Genomes on this VM" href="/XGDB/genomes.php" class="xgdb_button colorO2 largerfont">&nbsp; Genomes Link &nbsp;</a>
										<span class="normalfont">-  List of currently annotated genomes (<b>GDB</b>) and links to each tool or feature</span>
									</div>
									<div class="big_button">
										<a title="Genome data" href="/XGDB/GDBstats.php" class="xgdb_button colorO2 largerfont">&nbsp; Genome Statistics &nbsp;</a>
										<span class="topmargin1 normalfont">-  Feature counts and types for each genome</span>
									</div>
								<div class="feature">
								<ul class="bullet1 indent2">
									<li>For detailed documentation, visit these help pages: <a class="help_style" href="/XGDB/help/using_gdb.php">Genome Browsers</a> and <a class="help_style" href="/XGDB/help/anno_tables.php">Annotation Tables</a> </li>
									<li>To see xGDBvm in action, check out the <a class="help_style" href="/XGDB/help/video_tutorials.php#use">Video Tutorials</a>.</li>
								</ul>
								</div>
								<div class="feature">
								 <h3 class="topmargin2">Contribute annotations</h3>
								 </div>

									<div class="big_button">
										<a title="Genome Annotation" href="/src/yrGATE/index.php" class="xgdb_button colorGR2 largerfont">Get Started</a>
									</div>
							<div class="feature">

								<ul class="bullet1 indent2">
									<li>Annotation help is available at: <a class="help_style" href="/XGDB/help/yrgate.php">yrGATE</a> <a class="help_style" href="/XGDB/help/community_central.php">Community Central</a> <a class="help_style" href="/XGDB/help/gaeval.php">GAEVAL</a> </li>
									<li>Or check out the <a class="help_style" href="/XGDB/help/video_tutorials.php#annotation">Video Tutorials</a>.</li>
								</ul>
							</div>							
					</div><!--end maincontents-->
				</div><!--end maincontentscontainer-->
				<?php include($XGDB_FOOTER); ?>
			</div><!--end innercontainer-->
		</div><!--end outercontainer-->
	</body>
</html>