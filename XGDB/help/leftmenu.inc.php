<?php
 error_reporting(E_ALL & ~E_NOTICE); //disable undeclared variable error 
 ?>

<h2 class=""><!--img style="margin-left:-24px" alt="" src="/XGDB/images/browse.png" /--> Help</h2>
	<ul class="leftmenu">
		<li class="first"><a <?php if ($leftmenu == 'AllHelp') echo ' class="current"' ; ?> title="View All Help Resources" href="/XGDB/help/index.php"><span class=" help_style" >&nbsp; - All Help Resources -</span></a></li>
		<li><a title="All video tutorials" href="/XGDB/help/video_tutorials.php"> <span class=" help_style" >&nbsp; - Video Tutorials - </span></a></li>
		<li><a <?php if ($leftmenu == 'Admin-Help') echo ' class="current"' ; ?> title="Admin Functions" href="/XGDB/help/admin_gdb.php"><span class=" help_style" >&nbsp;Administration</span></a></li>
		<li><a <?php if ($leftmenu == 'CommCentralhelp') echo ' class="current"' ; ?> title="List of community-annotated genes" href="/XGDB/help/community_central.php"><span class=" help_style" >&nbsp;Community Central</span></a></li>
		<li><a <?php if ($leftmenu == 'CreateManage') echo ' class="current"' ; ?> title="Config/Create GDB Functions" href="/XGDB/help/create_gdb.php"><span class=" help_style" >&nbsp;Configure/Create</span></a></li>
		<li><a <?php if ($leftmenu == 'CpGAT') echo ' class="current"' ; ?> title="CpGAT Gene Annotation" href="/XGDB/help/cpgat.php"><span class=" help_style" >&nbsp;CpGAT</span></a></li>
		<li><a <?php if ($submenu == 'Requirements') echo ' class="current"' ; ?> title="Overview of data requirements for xGDBvm pipeline" href="/XGDB/conf/data.php"><span class=" help_style" >&nbsp;Data Requirements</span></a></li>
		<li><a <?php if ($leftmenu == 'AnnoTableHelp') echo ' class="current"' ; ?> title="Feature Track tables" href="/XGDB/help/feature_tracks.php"><span class=" help_style" >&nbsp;Feature Tracks</span></a></li>
		<li><a <?php if ($leftmenu == 'GAEVALhelp') echo ' class="current"' ; ?> title="Overview of GAEVAL evaluation system for gene congruence with data" href="/XGDB/help/gaeval.php"><span class=" help_style" >&nbsp;GAEVAL</span></a></li>
		<li><a <?php if ($leftmenu == 'ViewGDBhelp') echo ' class="current"' ; ?> title="Viewing, searching, analyzing GBD data" href="/XGDB/help/genome_browser.php"><span class=" help_style" >&nbsp;Genome Browser</span></a></li>
		<li><a <?php if ($leftmenu == 'Input_Output') echo ' class="current"' ; ?> title="GBD data inputs and outputs" href="/XGDB/conf/input_output.php"><span class=" help_style" >&nbsp;Inputs/Outputs</span></a></li>
		<li><a <?php if ($leftmenu == 'Remote_Jobs') echo ' class="current"' ; ?> title="Remote HPC jobs via xGDBvm" href="/XGDB/help/remote_jobs.php"><span class=" help_style" >&nbsp;Remote HPC Jobs</span></a></li>
		<li><a <?php if ($leftmenu == 'yrGATEhelp') echo ' class="current"' ; ?> title="Help for yrGATE community annotation tool" href="/XGDB/help/yrgate.php"><span class=" help_style" >&nbsp;yrGATE </span></a></li>
		<li><a <?php if ($leftmenu == 'Overview') echo ' class="current"' ; ?> title="Overview of xGDBvm functions" href="/XGDB/help/xgdbvm_overview.php"><span class=" help_style" >&nbsp;xGDBvm Overview</span></a></li>
	</ul>

<h2 class="topmargin1">Wiki</h2>
	<ul class="leftmenu">
			<li class="first"><a title="Wiki documentation for xGDBvm" href="http://goblinx.soic.indiana.edu/wiki/doku.php"><span class=" help_style" >&nbsp;Wiki Home</span></a></li>
			<li><a title="Wiki troubleshooting" href="http://goblinx.soic.indiana.edu/wiki/doku.php?id=troubleshooting"><span class=" help_style" >&nbsp;Troubleshooting</span></a></li>
	</ul>