<?php
 error_reporting(E_ALL & ~E_NOTICE); //disable undeclared variable error 
 ?>

<ul class="leftmenu">
		<li class="first"><a <?php if ($leftmenu == 'Home') echo ' class="current" ';?>title="Home Page" href="/"><span class="current_section">Home</span></a></li>
</ul>
<h2 class="topmargin1">Manage</h2>
<ul class="leftmenu">
		<li class=""><a href="/XGDB/manage/index.php">Getting Started</a></li>
		<li class=""><a href="/admin/index.php">Admin</a></li>
		<li class=""><a href="/XGDB/conf/index.php">Configure/Create</a></li>
		<li class=""><a href="/XGDB/jobs/index.php">Remote Jobs (HPC)</a></li>
	</ul>
<h2 class="topmargin1">View</h2>
	<ul class="leftmenu">
		<li><a <?php if ($leftmenu == 'Start') echo ' class="current" ';?>title="Getting Started Page" href="/XGDB/index.php">Getting Started</a></li>
		<li><a <?php if ($leftmenu == 'Genome Browsers') echo ' class="current" ';?>title="Home Page" href="/XGDB/genomes.php">Current Genomes</a></li>
		<li><a <?php if ($leftmenu == 'GDBstats') echo ' class="current" ';?>title="GDB Statistics" href="/XGDB/GDBstats.php">Genome Statistics</a></li>
				</ul>
<h2 class="topmargin1">Annotate</h2>
	<ul class="leftmenu">
		<li class="first"><a <?php if ($leftmenu == 'Annotation') echo ' class="current" ';?> title="Tools for Community Annotation of Gene Structure"
	href="/src/yrGATE/">Getting Started</a></li>
	</ul>
<h2 class="topmargin1">Help</h2>
	<ul class="leftmenu">
			<li class="first"><a <?php if ($leftmenu == 'AllHelp') echo ' class="current"' ; ?> title="View All Help Resources" href="/XGDB/help/index.php"><span class=" help_style" >&nbsp;- All Help -</span></a></li>
			<li><a title="All video tutorials" href="/XGDB/help/video_tutorials.php"><span class=" help_style" >&nbsp;- Video Tutorials -</span></a></li>
			<li><a <?php if ($leftmenu == 'AnnoTableHelp') echo ' class="current"' ; ?>title="Feature Track tables for each track type" href="/XGDB/help/feature_tracks.php/"><span class=" help_style" >&nbsp;Feature Tracks</span></a></li>
			<li><a <?php if ($leftmenu == 'CommCentralhelp') echo ' class="current"' ; ?>title="List of community-annotated genes" href="/XGDB/help/community_central.php/"><span class=" help_style" >&nbsp;Community Central</span></a></li>
			<li><a <?php if ($leftmenu == 'GAEVALhelp') echo ' class="current"' ; ?>title="Overview of GAEVAL evaluation system for gene congruence with data" href="/XGDB/help/gaeval.php/"><span class=" help_style" >&nbsp;GAEVAL</span></a></li>
			<li><a <?php if ($leftmenu == 'ViewGDBhelp') echo ' class="current"' ; ?> title="Viewing, searching, analyzing GBD data" href="/XGDB/help/using_gdb.php"><span class=" help_style" >&nbsp;Genome Browsers</span></a></li>
			<li><a <?php if ($leftmenu == 'yrGATEhelp') echo ' class="current"' ; ?>title="Help for yrGATE community annotation tool" href="/XGDB/help/yrgate.php/"><span class=" help_style" >&nbsp;yrGATE </span></a></li>
		<li><a <?php if ($leftmenu == 'Overview') echo ' class="current"' ; ?> title="Overview of xGDBvm functions" href="/XGDB/help/xgdbvm_overview.php/"><span class=" help_style" >&nbsp;xGDBvm Overview</span></a></li>
	</ul>
<h2 class="topmargin1">Wiki</h2>
	<ul class="leftmenu">
			<li class="first"><a title="Wiki documentation for xGDBvm" href="http://goblinx.soic.indiana.edu/wiki/doku.php"><span class=" help_style" >&nbsp;Wiki Home</span></a></li>
			<li><a title="Wiki troubleshooting" href="http://goblinx.soic.indiana.edu/wiki/doku.php?id=troubleshooting"><span class=" help_style" >&nbsp;Troubleshooting</span></a></li>
	</ul>