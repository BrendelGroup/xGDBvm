<?php
 error_reporting(E_ALL & ~E_NOTICE); //disable undeclared variable error 
 ?>

<h2 class="">Manage</h2>
	<ul class="leftmenu">
		<li><a <?php if ($leftmenu == 'Manage-Home') echo ' class="current"' ; ?>  title="Home Page" href="/XGDB/manage.php">Getting Started</a></li>
		<li><a href="/admin/index.php">Administrate</a></li>
		<li><a href="/XGDB/conf/index.php">Configure/Create</a></li>
		<li><a href="/XGDB/jobs/index.php">Remote Jobs (HPC)</a></li>
	</ul>

<h2 class="topmargin1">Help</h2>
	<ul class="leftmenu">
		    <li><a <?php if ($leftmenu == 'Admin-Help') echo ' class="current"' ; ?>title="Admin Functions" href="/XGDB/help/admin_gdb.php/"><span class=" help_style" >&nbsp;Administrate</span></a></li>
			<li><a <?php if ($leftmenu == 'CommCentralhelp') echo ' class="current"' ; ?>title="List of community-annotated genes" href="/XGDB/help/community_central.php/"><span class=" help_style" >&nbsp;Community Central</span></a></li>
			<li><a <?php if ($leftmenu == 'Remote_Jobs') echo ' class="current"' ; ?> title="Help for managing remote HPC jobs" href="/XGDB/help/remote_jobs.php"><span class=" help_style" >&nbsp;Remote Jobs</span></a></li>
	</ul>
