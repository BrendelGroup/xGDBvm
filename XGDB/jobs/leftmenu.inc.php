<?php
 error_reporting(E_ALL & ~E_NOTICE); //disable undeclared variable error 
 ?>

<h2 class=""><!--img style="margin-left:-18px" alt="" src="/XGDB/images/configure.png" /-->Remote Jobs (HPC)</h2>
	 <ul class="leftmenu darkgrayfont">
		<li class="first"><a<?php if ($leftmenu == 'Jobs-Home') echo ' class="current" ';?> href="/XGDB/jobs/index.php">Getting Started</a></li>
		<li><a <?php if ($leftmenu == 'Jobs-Instructions') echo ' class="current"' ; ?>  href="/XGDB/jobs/instructions.php">Stepwise Instructions</a></li>
		<li><a <?php if ($leftmenu == 'ConfigJobs') echo ' class="current"' ; ?>  href="/XGDB/jobs/configure.php">Configure API</a></li>
		<li><a <?php if ($leftmenu == 'ConfigApps') echo ' class="current"' ; ?>  href="/XGDB/jobs/apps.php">Configure Apps</a></li>
		<li><a <?php if ($leftmenu == 'UserLogin') echo ' class="current"' ; ?>  href="/XGDB/jobs/login.php">Authorize / Log In</a></li>
		<li><a <?php if ($leftmenu == 'Jobs-Resources') echo ' class="current"' ; ?>  href="/XGDB/jobs/resources.php">Estimate Resources</a></li>
		<li><a <?php if ($leftmenu == 'SubmitJob') echo ' class="current"' ; ?>  href="/XGDB/jobs/submit.php">Submit Job - Standalone</a></li>
		<li><a <?php if ($leftmenu == 'SubmitGDBJob') echo ' class="current"' ; ?>  href="/XGDB/jobs/submit_pipeline.php">Submit Job - Pipeline</a></li>
		<li><a <?php if ($leftmenu == 'ManageJobs') echo ' class="current"' ; ?>  href="/XGDB/jobs/manage.php">Manage Jobs</a></li>
		<li><a <?php if ($leftmenu == 'ListJobs') echo ' class="current"' ; ?>  href="/XGDB/jobs/jobs.php">List All Jobs</a></li>
	</ul> 
<h2 class="topmargin1">Manage...</h2>
	 <ul class="leftmenu darkgrayfont">
		<li class="first"><a href="/admin/index.php">Admin</a></li>
		<li class="first"><a href="/XGDB/conf/index.php">Config/Create</a></li>
		<li><a href='/XGDB/conf/view.php?id=<?php echo $_SESSION['gdbid']; ?>'><span <?php if ($leftmenu!= 'Config-View' && isset($_SESSION['id'])){ echo 'class= "indent2 italic"';}else{echo 'class="display_off"';}  ?>> <?php echo $_SESSION['gdbid']; ?> Conf&nbsp;</span></a> </li>
	</ul>
<h2 class="topmargin1">Help</h2>
	<ul class="leftmenu darkgrayfont">
			<li><a <?php if ($leftmenu == 'Remote_Jobs') echo ' class="current"' ; ?> title="Help for managing remote HPC jobs" href="/XGDB/help/remote_jobs.php"><span class=" help_style" >&nbsp;Remote Jobs</span></a></li>
			<li class="first"><a title="Wiki documentation for xGDBvm" href="http://goblinx.soic.indiana.edu/wiki/doku.php"><span class=" help_style" >&nbsp;Wiki</span></a></li>
	</ul>

