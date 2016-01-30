<?php
session_start();

	$PageTitle = 'CpGAT Tool Help';
	$pgdbmenu = 'Help';
	$submenu1 = 'CpGAT';
	$submenu2 = 'CpGAT';
	$leftmenu='CpGAT';
	$global_DB= 'Genomes';
	include("sitedef.php");
	include($XGDB_HEADER);
?>


		<div id="leftcolumncontainer">
			<div class="minicolumnleft">
				<?php include_once("/xGDBvm/XGDB/help/leftmenu.inc.php"); ?>
			</div>
		</div>

		<div id="maincontentscontainer" class="threecolumn">
						<div id="maincontents" class="help">
						
							<h1 id="heading" class="help_style bottommargin2"><img alt="" src="/XGDB/images/circle_help.png" />&nbsp;CpGAT Annotation<span class="heading"> &nbsp;Comprehensive Genome Annotation Tool</span> 
							</h1>
						
						<div class="helpsection" id="contents">
							<!--Table of Contents-->
							
							<h2 id="contents_heading" class="help">Contents</h2>
							<ul class="contentslist">
								<li><b>Overview</b>
									<ul class="bullet1 indent2">
										<li><a href="#cpgat_overview">What is CpGAT?</a></li>
										<li><a href="#cpgat_schema">CpGAT Schema</a></li>
									</ul>
								</li>
								<li><b>Data Inputs</b>
									<ul class="bullet1 indent2">
										<li><a href="#cpgat_data">CpGAT Data</a></li>
										<li><a href="#config_cpgat_refprotein">Reference Protein</a></li>
									</ul>
								</li>
								<li><b>Data Outputs</b>
									<ul class="bullet1 indent2">
										<li><a href="#cpgat_output_display">CpGAT Display</a></li>
										<li><a href="#cpgat_output_files">Output Data Files</a></li>
									</ul>
								</li>
								<li><b>CpGAT Pipeline Configuration</b>
									<ul class="bullet1 indent2">
										<li><a href="#config_cpgat_genefinders">Gene Finders</a></li>
										<li><a href="#config_cpgat_option_skipmask">Skip Mask</a></li>
										<li><a href="#config_cpgat_option_relaxuniref">Relax Uniref</a></li>
										<li><a href="#config_cpgat_option_skippasa">Skip Pasa</a></li>
										<li><a href="#config_cpgat_filtergenes">Filter Genes</a></li>
									</ul>
								</li>
								<li><b>CpGAT Region Tool</b>
									<ul class="bullet1 indent2">
										<li><a href="#cpgat_tool_overview">Overview</a></li>
										<li><a href="#cpgat_tool_parameters">Parameters</a></li>
										<li><a href="#cpgat_tool_addusertrack">Add User Track</a></li>
										<li><a href="#cpgat_tool_addtrack">Append CpGAT Track</a></li>
									</ul>
								</li>
							</ul>

					</div>
			<!-- Content based on include files -->
			
			
						<div class="helpsection">
							<h2 class="help">Overview</h2>
								<div class="feature" id="cpgat_overview">
									<?php include('/xGDBvm/XGDB/help/includes/cpgat_overview.inc.php'); ?>
										<a class="smallerfont indent2" href="#heading">[top]</a>
								</div>
								<div class="feature" id="cpgat_schema">
									<?php include('/xGDBvm/XGDB/help/includes/cpgat_schema.inc.php'); ?>
										<a class="smallerfont indent2" href="#heading">[top]</a>
								</div>
						</div>
						<div class="helpsection">
							<h2 class="help">Data Inputs</h2>
								<div class="feature" id="cpgat_data">
									<?php include('/xGDBvm/XGDB/help/includes/cpgat_data.inc.php'); ?>
										<a class="smallerfont indent2" href="#heading">[top]</a>
								</div>

								<div class="feature" id="config_cpgat_refprotein">
									<?php include('/xGDBvm/XGDB/help/includes/config_cpgat_refprotein.inc.php'); ?>
										<a class="smallerfont indent2" href="#heading">[top]</a>
								</div>
						</div>
						<div class="helpsection">
						
							<h2 class="help">Data Outputs</h2>
								<div class="feature" id="cpgat_output_display">
                        <p> <b>CpGAT Data Display</b> (tbd)	</p>
						<a class="smallerfont indent2" href="#heading">[top]</a>
								</div>

							<div class="feature" id="cpgat_output_files">
                    <p> <b>CpGAT Data Files</b> (tbd)	</p>

                        <a class="smallerfont indent2" href="#heading">[top]</a>
								</div>
						</div>

						<div class="helpsection">
							<h2 class="help">CpGAT Pipeline Configuration</h2>
								<div class="feature" id="config_cpgat_genefinders">
									<?php include('/xGDBvm/XGDB/help/includes/config_cpgat_genefinders.inc.php'); ?>
										<a class="smallerfont indent2" href="#heading">[top]</a>
								</div>
								<div class="feature" id="config_cpgat_option_skipmask">
									<?php include('/xGDBvm/XGDB/help/includes/config_cpgat_option_skipmask.inc.php'); ?>
										<a class="smallerfont indent2" href="#heading">[top]</a>
								</div>
								<div class="feature" id="config_cpgat_option_relaxuniref">
									<?php include('/xGDBvm/XGDB/help/includes/config_cpgat_option_relaxuniref.inc.php'); ?>
										<a class="smallerfont indent2" href="#heading">[top]</a>
								</div>
								<div class="feature" id="config_cpgat_option_skippasa">
									<?php include('/xGDBvm/XGDB/help/includes/config_cpgat_option_skippasa.inc.php'); ?>
										<a class="smallerfont indent2" href="#heading">[top]</a>
								</div>
								<div class="feature" id="config_cpgat_filtergenes">
									<?php include('/xGDBvm/XGDB/help/includes/config_cpgat_filtergenes.inc.php'); ?>
										<a class="smallerfont indent2" href="#heading">[top]</a>
								</div>
						</div>
						<div class="helpsection" id="regiontool">
							<h2 class="help">CpGAT Region Tool</h2>
								<div class="feature" id="cpgat_tool_overview">
									<?php include('/xGDBvm/XGDB/help/includes/cpgat_tool_overview.inc.php'); ?>
										<a class="smallerfont indent2" href="#heading">[top]</a>
								</div>
								<div class="feature" id="cpgat_tool_parameters">
									<?php include('/xGDBvm/XGDB/help/includes/cpgat_tool_parameters.inc.php'); ?>
										<a class="smallerfont indent2" href="#heading">[top]</a>
								</div>
								<div class="feature" id="cpgat_tool_addusertrack">
									<?php include('/xGDBvm/XGDB/help/includes/cpgat_tool_addusertrack.inc.php'); ?>
										<a class="smallerfont indent2" href="#heading">[top]</a>
								</div>
								<div class="feature" id="cpgat_tool_addtrack">
									<?php include('/xGDBvm/XGDB/help/includes/cpgat_tool_addtrack.inc.php'); ?>
										<a class="smallerfont indent2" href="#heading">[top]</a>
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
