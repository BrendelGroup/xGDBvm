<?php
	$PageTitle = 'xGDBvm - Virtual Genome Environment';
	$pgdbmenu = 'Home';
	$submenu1= 'Home';
	$submenu2= 'Home';	
	$leftmenu = 'Home';
	$global_DB1= 'Genomes';
	$global_DB2= 'Admin';
	include '/xGDBvm/XGDB/phplib/sitedef.php';
	include('/xGDBvm/XGDB/phplib/header.php');
	include_once('/xGDBvm/XGDB/phplib/db.inc.php');
	
	###### Connect to database ######
	$dbpass=dbpass();
	$db = mysql_connect("localhost", "gdbuser", $dbpass);
	if(!$db)
	{
		echo "Error: Could not connect to database!";
		exit;
	}
	mysql_select_db("$global_DB1");
	
	global $count;
	$Query="SELECT ID from xGDB_Log";
	$get_records = $Query;
	$check_get_records = mysql_query($get_records);
	$result = $check_get_records;
	if($count == mysql_fetch_array($result)){
	$config_link = "/XGDB/conf/index.php";
	$config_text =" &nbsp; &nbsp; Getting Started &nbsp; &nbsp;";
	}else{
	$config_link = "/XGDB/conf/viewall.php";
	$config_text ="&nbsp; View Configurations &nbsp;";
	}
?>
					<div id="leftcolumncontainer">
						<div class="minicolumnleft">
							<?php include_once("/xGDBvm/XGDB/phplib/leftmenu.inc.php"); ?>
						</div>
					</div><!-- end leftcolumncontainer -->
					<div id="maincontentscontainer" class="threecolumn">
					<div id="maincontents">

					<h1>Welcome to xGDB<i>vm</i>, <span class="heading indent"> a virtual environment for viewing and annotating genomes.</span></h1>

								<hr class="featuredivider" />

								<div class="feature">
								<span class="heading largerfont"> Click below to learn more about xGDBvm:</span>
								</div><!-- end feature -->
				<!--Create Genomes-->
								<div class="feature topmargin1">
										<div class="showhide" id="create_genomes">
											<p title="Click for more information" style="cursor:pointer">
												<span class="bigfont bold reverse">Manage<span class="heading reverse"> - Create a Genome Browser  using your own data</span></span></p>
											<div class=" hidden">
    											<p>
    											    Splice-align transcripts &amp; proteins and build gene models automatically, then view/search output data in a full-featured genome browser that can be either public or private. 
    											    <a title='How xGDBvm works' class='image-button' id='xGDBvmFlow_large:550:560'>
													    <span class="highlight">(click to view schema)</span>
													</a>
    											</p>
			        							<div class="big_button">
													<a title="Getting Started page" href="/XGDB/manage/index.php" class="xgdb_button colorConf1">Click to get started</a>

													<span class="heading"> - If this is a new xGDBvm, start here for best results!</span>
													<p class="topmargin2 indent2">
														<br /><span class="warning"> NOTE: these pages are for administrators and may be password protected </span> 
													</p>
												</div>
											<p>See xGDBvm in action with <b>video tutorials:</b></p>
												<div class="big_button">
												
                                                        <a title='Video is also available at http://www.youtube.com/watch?v=3KL9ceP11yo' class='xgdb_button smallerfont ytvideo-button video  xgdb_button colorGR3 video-button-gr video' id='create_example_gdb' name='3KL9ceP11yo'>
                                                        1: Spin up a new VM</a>
                                                        <span class="topmargin1 heading"> (4:39) - Create/Configure a new xGDBvm instance on iPlant Atmosphere </span>

												</div>
												<div class="big_button">
												
                                                        <a title='Video is also available at https://www.youtube.com/watch?v=Pv58RNHDwIA' class='xgdb_button smallerfont ytvideo-button video  xgdb_button colorGR3 video-button-gr video' id='create_example_gdb' name='Pv58RNHDwIA'>
                                                        2: Test your new VM</a>
                                                        <span class="topmargin1 heading"> (6:42) - Test a new xGDBvm instance with pre-configured sample data </span>

												</div>
													<p><a href="/XGDB/help/index.php#videos">more video tutorials</a></p>

									   </div><!-- end hidden div-->
									</div><!-- end showhide -->
								</div><!--end feature-->
				<!--View Genomes-->

								<div class="feature topmargin2 bottommargin2">
									<div class="showhide" id="view_genomes">
										<p title="Click for more information" style="cursor:pointer">
											<span class="bigfont bold reverse">View <span class="heading reverse"> - Browse / Search Genomes on this VM</span>  </span>
									    </p>
					                    <div class="hidden">
										<p>Once you have created a GDB using the above tools, the data are immediately displayed online. xGDBvm's <a class="help_style bold" title="Get help on genome browsers" href="/XGDB/help/genome_browser.php">genome browser</a> provides a wealth of tools for searching or querying your genome.</p>
										<div class="big_button">
											<a title="Existing genome" href="/XGDB/genomes.php" class="xgdb_button colorO1 largerfont">View Current Genomes</a> <span class="heading"> - See a list of current genomes and links to tools and views </span>
										</div >
										<div class="big_button">
											<a title="Genome browsers at PlantGDB" class='flvideo-button bottommargin1 xgdb_button colorGR3 video-button-gr' id='genome_browser_demo' name='28518868'>Watch Video</a> <span class="heading"> - Take a visual tour of the basic features of xGDBvm's genome browser</span>
										</div>	
									</div><!--end of hidden div-->
									</div><!--end of showhide div-->
								</div> <!-- end feature -->
				<!--Community Annotation-->
								<div class="feature bottommargin2">
									<div class="showhide" id="community_annotation">
									<p title="Click for more information" style="cursor:pointer">
									<span class="bigfont bold reverse">Annotate <span class="heading reverse"> - Improve gene model annotations using the yrGATE tool</span> </span>
								</p>
								<div class="hidden">
									<h3>Community Annotation Tool (yrGATE)</h3>
										<p>xGDBvm's <a class="help_style bold" title="Get help on community annotation" href="/XGDB/help/yrgate.php">yrGATE Tool</a> allows users to improve the quality of gene structure predictions displayed on this VM. After curation, user-submitted annotations are immediately displayed for the entire community.</p>

										<div class="big_button">
											<a title="Existing genome" href="/src/yrGATE/index.php" class="xgdb_button colorGreen1 largerfont">View Community Annotations</a> <span class="heading"> - Links to Community Annotation pages</span>
										</div >

									    <div class="big_button">
										<a title="Annotating gene structure using yrGATE" class='flvideo-button bottommargin1 xgdb_button colorGR3 video-button-gr' id='yrgate_demo' name='7858561'>Watch Video</a> 
									</div>		
									<h3>Gene Quality Index (GAEVAL)</h3>
								<p>Automated gene calls are not always accurate. xGDBvm's <a class="help_style bold" title="Get help on GAEVAL" href="/XGDB/help/gaeval.php">GAEVAL</a> script flags discrepancies between EST/cDNA evidence-based alignments and gene models, and makes it easy to spot gene models in need of re-annotation.</p>
								</div><!--end of hidden div-->
							</div><!--end of showhide div-->
						</div><!--end feature-->
				</div><!--end maincontents-->
						  <div style="clear:both; float:right">
							<a href="http://validator.w3.org/check?uri=referer">
							<img src="http://www.w3.org/Icons/valid-xhtml10" alt="Valid XHTML 1.0 Transitional" height="15" width="44" />
							</a>
						  </div>						
			</div><!--end maincontentscontainer-->
			<?php include('/xGDBvm/XGDB/phplib/footer.php'); ?>
		</div><!--end pagewidth-->
	</div><!--end innercontainer-->
</div><!--end outercontainer-->
</body>
</html>
