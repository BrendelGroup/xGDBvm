<?php
 error_reporting(E_ALL & ~E_NOTICE); //disable undeclared variable error 
 ?>

<h2 class="">Configure/Create</h2>
	 <ul class="leftmenu">
		<li class="first"><a<?php if ($leftmenu == 'Config-Home') echo ' class="current" ';?> href="/XGDB/conf/index.php">Getting Started</a></li>
		<li><a <?php if ($leftmenu == 'Config-Instructions') echo ' class="current"' ; ?>  href="/XGDB/conf/instructions.php">Stepwise Instructions</a></li>
		<li><a <?php if ($leftmenu == 'Config-Volumes') echo ' class="current"' ; ?>  href="/XGDB/conf/volumes.php">Data Volumes</a></li>
		<li><a <?php if ($leftmenu == 'Config-Licenses') echo ' class="current"' ; ?>  href="/XGDB/conf/licenses.php">License Keys</a></li>
		<li><a <?php if ($leftmenu == 'Config-Sources') echo ' class="current"' ; ?>  href="/XGDB/conf/sources.php">Data Sources</a></li>
		<li><a <?php if ($leftmenu == 'Config-Data') echo ' class="current"' ; ?>  href="/XGDB/conf/data.php">Data Requirements</a></li>
		<li><a <?php if ($leftmenu == 'Config-Annotate') echo ' class="current"' ; ?>  href="/XGDB/conf/annotate.php">Annotation Guide</a></li>
		<li><a <?php if ($leftmenu == 'Config-Add') echo ' class="current"' ; ?>  href="/XGDB/conf/new.php">Configure New GDB</a></li>
		<li><a <?php if ($leftmenu == 'Config-ViewAll') echo ' class="current" ';?> href="/XGDB/conf/viewall.php">List All Configured</a></li>
		<li><a href='/XGDB/conf/view.php?id=<?php echo $_SESSION['id']; ?>'><span <?php if ($leftmenu!= 'Config-View' && isset($_SESSION['id'])){ echo 'class= "indent2 italic"';}else{echo 'class="display_off"';}  ?>> <?php echo $_SESSION['gdbid']; ?> Conf&nbsp;</span></a> </li>
		<li><span <?php if ($leftmenu == 'Config-View'){ echo 'class="current '.$view.' indent1 italic"';}else{echo 'class="display_off"';}  ?>>Viewing <?php echo $DBid; ?> &nbsp;</span></li>
		<li><span <?php if ($leftmenu == 'Config-View'){ echo 'class="current '.$edit.' indent1 italic"';}else{echo 'class="display_off"';}  ?>>Editing <?php echo $DBid; ?> &nbsp;</span></li>
		<li><span <?php if ($leftmenu == 'Config-View'){ echo 'class="current '.$create.' indent2 italic"';}else{echo 'class="display_off"';}  ?>>Options: Create GDB &nbsp;</span></li>
		<li><span <?php if ($leftmenu == 'Config-View'){ echo 'class="current '.$update.' indent2 italic"';}else{echo 'class="display_off"';}  ?>>Options: Update &nbsp;</span></li>
		<li><span <?php if ($leftmenu == 'Config-View'){ echo 'class="current '.$drop.' indent2 italic"';}else{echo 'class="display_off"';}  ?>>Options: Drop &nbsp;</span></li>
		<li><span <?php if ($leftmenu == 'Config-View'){ echo 'class="current '.$abort.' indent2 italic"';}else{echo 'class="display_off"';}  ?>>Options:Abort &nbsp;</span></li>
		<li><span <?php if ($leftmenu == 'Config-View'){ echo 'class="current '.$log.' indent2 italic"';}else{echo 'class="display_off"';}  ?>>Logfile</span></li>
		<li><a <?php if ($leftmenu == 'Config-Archive') echo ' class="current" ';?> href="/XGDB/conf/archive.php">Archive/Delete GDB</a></li>
	</ul>
<h2 class="topmargin1">Manage...</h2>
	 <ul class="leftmenu darkgrayfont">
		<li class="first"><a href="/admin/index.php">Admin</a></li>
		<li><a href="/XGDB/jobs/index.php">Remote Jobs (HPC)</a></li>
		<li><a href="/XGDB/jobs/jobs.php">List Jobs</a></li>
	</ul>
<h2 class="topmargin1">View...</h2>
	 <ul class="leftmenu darkgrayfont">
		<li class="first"><a href="/XGDB/genomes.php">Current Genomes</a></li>
	</ul>
<h2 class="topmargin1">Help</h2> 
	<ul class="leftmenu darkgrayfont">
			<li class="first"><a <?php if ($leftmenu == 'CreateGDBhelp') echo ' class="current"' ; ?> title="Help for how to create genome browser" href="/XGDB/help/create_gdb.php"><span class=" help_style" >&nbsp;Configure/Create</span></a></li>
			<li><a <?php if ($leftmenu == 'CpGAT') echo ' class="current"' ; ?> title="CpGAT Annotation Pipeline" href="/XGDB/help/cpgat.php/"><span class="help_style">&nbsp;CpGAT</span></a></li>
			<li><a <?php if ($leftmenu == 'TracksHelp') echo ' class="current"' ; ?> title="Help viewing Genome Track tables" href="/XGDB/help/tracks.php"><span class=" help_style" >&nbsp;Genome Tracks</span></a></li>
			<li><a <?php if ($leftmenu == 'Remote_Jobs') echo ' class="current"' ; ?> title="Help for configuring/creating a genome browser" href="/XGDB/help/remote_jobs.php"><span class=" help_style" >&nbsp;Remote Jobs</span></a></li>
			<li><a title="Wiki documentation for xGDBvm" href="http://goblinx.soic.indiana.edu/wiki/doku.php"><span class=" help_style" >&nbsp;Wiki</span></a></li>
	</ul>


