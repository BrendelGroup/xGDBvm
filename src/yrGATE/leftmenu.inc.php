<?php
 error_reporting(E_ALL & ~E_NOTICE); //disable undeclared variable error 
 ?>

<h2 class="">&nbsp;Annotate</h2>
	<ul class="leftmenu">
		<li class="first"><a <?php if ($leftmenu == 'Annotation') echo ' class="current" ';?> title="Tools for Community Annotation of Gene Structure" href="/src/yrGATE/">Getting Started</a></li>
		<li class="first"><a <?php if ($leftmenu == 'yrGATE_Overview') echo ' class="current" ';?> title="What is the yrGATE tool" href="/src/yrGATE/overview.php">yrGATE Overview</a></li>
					<?php asort($xGDB);
						foreach ($xGDB as $keys=>$value){
						echo "<li><a href=\"/yrGATE/$value/CommunityCentral.pl\">Comm.Central ($value)</a></li>";
					}?>
	
	</ul>

<h2 class="topmargin1">View Genomes</h2>
	<ul class="leftmenu">
		<li><a <?php if ($leftmenu == 'View-Home') echo ' class="current"' ; ?>  title="View Genomes - Home Page" href="/XGDB/index.php">Getting Started</a></li>
		<li><a  <?php if ($leftmenu == 'GenomeList') echo ' class="current"' ; ?>  href="/XGDB/genomes.php">Current Genomes</a></li>
		</ul>
<h2 class="topmargin1">&nbsp; Help</h2>
	<ul class="leftmenu">
			<li class="first"><a <?php if ($leftmenu == 'AllHelp') echo ' class="current"' ; ?> title="View All Help Resources" href="/XGDB/help/index.php"><span class=" help_style" >&nbsp;- All Help -</span></a></li>
			<li><a title="All video tutorials" href="/XGDB/help/video_tutorials.php"><span class=" help_style" >&nbsp;- Video Tutorials -</span></a></li>
			<li><a <?php if ($leftmenu == 'CommCentralhelp') echo ' class="current"' ; ?>title="List of community-annotated genes" href="/XGDB/help/community_central.php"><span class=" help_style" >&nbsp; Comm. Central</span></a></li>
			<li><a <?php if ($leftmenu == 'GAEVALhelp') echo ' class="current"' ; ?>title="Overview of GAEVAL evaluation system for gene congruence with data" href="/XGDB/help/gaeval.php"><span class=" help_style" >&nbsp; GAEVAL</span></a></li>
			<li><a <?php if ($leftmenu == 'yrGATEhelp') echo ' class="current"' ; ?>title="Help for yrGATE community annotation tool" href="/XGDB/help/yrgate.php"><span class=" help_style" >&nbsp; yrGATE </span></a></li>
			<li><a title="Wiki documentation for xGDBvm" href="http://goblinx.soic.indiana.edu/wiki/doku.php"><span class=" help_style" >&nbsp;xGDBvm Wiki</span></a></li>
	</ul>
