<?php
	$PageTitle = 'xGDB Help';
	$pgdbmenu = 'Help';
	$submenu = 'Help';
	$leftmenu='AllHelp';
	$global_DB= 'Genomes';
	include("sitedef.php");
	include($XGDB_HEADER);
?>
		<div id="leftcolumncontainer">
			<div class="minicolumnleft">
				<?php include_once("/xGDBvm/XGDB/help/leftmenu.inc.php"); ?>
			</div>
		</div>

		<div id="maincontentscontainer" class="twocolumn">
		<div id="maincontentsfull">
		
<h1 class="help_style topmargin1 bottommargin1"><img alt="" src="/XGDB/images/circle_help.png" />&nbsp; xGDBvm Help (All Resources)</h1>

<p>See also <a title="Wiki documentation for xGDBvm" href="http://goblinx.soic.indiana.edu/wiki/doku.php">&nbsp;xGDB Wiki</a> which includes a <a title="Wiki documentation for xGDBvm" href="http://goblinx.soic.indiana.edu/wiki/doku.php?id=troubleshooting">&nbsp;Troubleshooting Guide</a>
</p>

<h2 class="help topmargin1 bottommargin1">How xGDBvm works 
</h2>
				<div class="big_button">
				<p>
					xGDBvm splice-aligns transcripts &amp; proteins and builds gene models automatically. Users can view/search output data in a full-featured genome browser that can be either public or private. 
				   <a title='How xGDBvm works' class='image-button' id='xGDBvmFlow_large:550:450'><span class="highlight">(click to view schema)</span></a></p>    											
				</div> 

				<div class="big_button">
				
						<a title='Video is also available at https://youtu.be/Kcuy-3IZJ_E' class='xgdb_button smallerfont ytvideo-button video  xgdb_button colorGR3 video-button-gr video' id='create_example_gdb' name='Kcuy-3IZJ_E'>
						xGDBvm: An Overview (4:48)</a>

				</div>

<h2 class="help topmargin1 bottommargin1" name="videos">Video Tutorials
</h2>

<p>See <a href="/XGDB/help/video_tutorials.php">video tutorials page</a></p>
 
									
<h2 class="help topmargin1 bottommargin1">Help pages</h2>

 <span class="heading indent1">Detailed explanation of xGDBvm features and workflows. </span>
						<ul class="menulist topmargin1">
							<li><a title="Help for Admin pages" href="/XGDB/help/admin_gdb.php">Administration</a> - instructions for initial configuration of your xGDBvm</li>
							<li><a title="List of community-annotated genes" href="/XGDB/help/community_central.php/">Community Central</a> - the repository for yrGATE community gene annotations</li>
							<li><a title="Help for how to create genome browser" href="/XGDB/help/create_gdb.php">Configure/Create</a> - step-by-step process for creating a Genome Browser</li>
							<li><a title="Using CpGAT annotation tool" href="/XGDB/help/cpgat.php">CpGAT</a> - how to use CpGAT to annotate genomes</li> 
							<li><a title="Overview of data requirements for xGDBvm pipeline" href="/XGDB/help/requirements.php">Data Requirements</a> - how to format and name your input data files</li>
							<li><a title="Help for Admin pages" href="/XGDB/help/feature_tracks.php">Feature Tracks</a> - genome features (gene models, aligned transcripts, proteins)</li>
							<li><a title="Overview of GAEVAL evaluation system for gene congruence with data" href="/XGDB/help/gaeval.php/">GAEVAL</a> - gene structure quality data</li>
							<li><a title="Viewing, searching, analyzing GBD data" href="/XGDB/help/genome_browser.php">Genome Browsers</a> - how to browse, search, analyze, and annotate genomes</li> 
							<li><a title="Tabular view of data inputs and outputs for xGDBvm pipeline" href="/XGDB/help/input_output.php">Inputs / Outputs</a>- table showing each input data type, scripts that use it, and output types and locations</li> 
							<li><a title="Overview of xGDBvm features" href="/XGDB/help/xgdbvm_overview.php">Overview of xGDBvm</a>- xGDBvm features, navigation, and help/troubleshooting tips</li> 
							<li><a title="Remote HPC Computing for GeneSeqer, GenomeThreader" href="/XGDB/help/input_output.php">Remote HPC Jobs</a>- remote High Performance Compute option (GeneSeqer, GenomeThreader)</li> 
							<li><a title="Help for yrGATE community annotation tool" href="/XGDB/help/yrgate.php/">yrGATE</a> - using the yrGATE gene annotation tool</li>
						</ul>
<h2 class="help topmargin1 bottommargin1">xGDBvm Wiki</h2>

 <span class="heading indent1">Details on xGDBvm, mainly for administrators and developers. Hosted on <a href="http://goblinx.soic.indiana.edu">xGDBvm Project Page</a> (Indiana University) </span>
						<ul class="menulist topmargin1">
							<li><a title="Wiki documentation for xGDBvm" href="http://goblinx.soic.indiana.edu/wiki/">Wiki Home</a> - contents and index</li>
							<li><a title="User Instructions for xGDBvm" href="http://goblinx.soic.indiana.edu/wiki/doku.php?id=user_instructions">User Instructions</a> - how to configure a VM</li>
							<li><a title="Architecture for xGDBvm" href="http://goblinx.soic.indiana.edu/wiki/doku.php?id=architecture">Architecture</a> - directory structure and contents </li>
							<li><a title="Specifications for xGDBvm" href="http://goblinx.soic.indiana.edu/wiki/doku.php?id=architecture">Specifications</a> - concise description of xGDBvm functions, inputs, outputs</li>
							<li><a title="Troubleshooting for xGDBvm" href="http://goblinx.soic.indiana.edu/wiki/doku.php?id=troubleshooting">Troubleshooting</a> - common problems, solutions for users and admins</li>
                        </ul>

<h2 class="help topmargin1 bottommargin1">Other Resources</h2>

			<ul class="menulist bottommargin2">
				<li><a href="/XGDB/help/about.php">About xGDBvm</a></li>
				<li><a href="/XGDB/help/acknowledgments.php">Acknowledgments</a></li>
				<li><a href="http://plantgdb.org">PlantGDB</a></li>
			</ul>
			
			</div><!--end maincontentsfull-->
			</div><!--end maincontentscontainer-->
		<?php include($XGDB_FOOTER); ?>
		</div><!--end pagewidth-->
	</div><!--end innercontainer-->
</div><!--end outercontainer-->
</body>
</html>
