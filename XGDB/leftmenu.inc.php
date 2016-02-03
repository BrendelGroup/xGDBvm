<?php
 error_reporting(E_ALL & ~E_NOTICE); //disable undeclared variable error 
 ?>

<h2 class="">View Genomes</h2>
	<ul class="leftmenu view">
		<li><a <?php if ($leftmenu == 'View-Home') echo ' class="current"' ; ?>  title="View Genomes - Home Page" href="/XGDB/index.php">Getting Started</a></li>
		<li><a  <?php if ($leftmenu == 'GenomeList') echo ' class="current"' ; ?>  href="/XGDB/genomes.php">Current Genomes</a></li>
		<li><a <?php if ($leftmenu == 'GDBstats') echo ' class="current"' ; ?> href="/XGDB/GDBstats.php">Genome Statistics</a></li>
		</ul>

<h2 class="topmargin1">&nbsp;Annotate</h2>
	<ul class="leftmenu">
		<li class="first"><a <?php if ($leftmenu == 'Annotation') echo ' class="current" ';?> title="Tools for Community Annotation of Gene Structure" href="/src/yrGATE/">Getting Started</a></li>
	</ul>
<h2 class="topmargin1">Help</h2>
	<ul class="leftmenu">
		<li class="first"><a <?php if ($leftmenu == 'AllHelp') echo ' class="current"' ; ?> title="View All Help Resources" href="/XGDB/help/index.php"><span class=" help_style" >All Help </span></a></li>
		<li><a title="All video tutorials" href="/XGDB/help/video_tutorials.php"><span class=" help_style" >Video Tutorials</span></a></li>
		<li><a <?php if ($leftmenu == 'ViewGDBhelp') echo ' class="current"' ; ?> title="Viewing, searching, analyzing GBD data" href="/XGDB/help/genome_browser.php"><span class=" help_style" >Genome Browser</span></a></li>
		<li><a <?php if ($leftmenu == 'AnnoTableHelp') echo ' class="current"' ; ?>title="Locus tables displaying annotated loci (pre-computed or CpGAT-derived)" href="/XGDB/help/anno_tables.php/"><span class=" help_style" >Annotation Tables</span></a></li>
		<li><a <?php if ($leftmenu == 'yrGATEhelp') echo ' class="current"' ; ?>title="Help for yrGATE community annotation tool" href="/XGDB/help/yrgate.php/"><span class=" help_style" >yrGATE </span></a></li>
		<li><a <?php if ($leftmenu == 'CommCentralhelp') echo ' class="current"' ; ?>title="List of community-annotated genes" href="/XGDB/help/community_central.php/"><span class=" help_style" >Comm Central</span></a></li>
		<li><a <?php if ($leftmenu == 'GAEVALhelp') echo ' class="current"' ; ?>title="Overview of GAEVAL evaluation system for gene congruence with data" href="/XGDB/help/gaeval.php/"><span class=" help_style" >GAEVAL</a></a></li>
		<li><a title="Wiki documentation for xGDBvm" href="/wiki/"><span class=" help_style" >&nbsp;Wiki</a></a></li>
	</ul>


