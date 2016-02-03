<?php
 error_reporting(E_ALL & ~E_NOTICE); //disable undeclared variable error 
 ?>
<h2 class="">Admin</h2>
	 <ul class="leftmenu">
		<li class="first"> <a<?php if ($leftmenu == 'Admin-Home') echo ' class="current" ';?> href="/admin/index.php">Getting Started</a></li>
		<li><a <?php if ($leftmenu == 'Admin-Setup') echo ' class="current" ';?> href="/admin/setup.php">Set Up Passwords</a></li>
		<li><a <?php if ($leftmenu == 'Admin-Sitename') echo ' class="current" ';?> href="/admin/sitename.php">Set Up Site Name</a></li>
		<li><a <?php if ($leftmenu == 'Admin-Email') echo ' class="current" ';?> href="/admin/email.php">Set Up Admin Email</a></li>
		<li><a <?php if ($leftmenu == 'Admin-Users') echo ' class="current"' ; ?>  href="/admin/users.php">Manage Users</a></li>
		<li><a <?php if ($leftmenu == 'Admin-Groups') echo ' class="current" ';?> href="/admin/groups.php">Manage User Groups</a></li>
	</ul>
<h2 class="topmargin1">Manage...</h2>
	 <ul class="leftmenu darkgrayfont">
		<li class="first"><a href="/XGDB/conf/index.php">Config/Create</a></li>
		<li><a href='/XGDB/conf/view.php?id=<?php echo $_SESSION['gdbid']; ?>'><span <?php if ($leftmenu!= 'Config-View' && isset($_SESSION['id'])){ echo 'class= "indent2 italic"';}else{echo 'class="display_off"';}  ?>> <?php echo $_SESSION['gdbid']; ?> Conf&nbsp;</span></a> </li>
		<li><a href="/XGDB/jobs/index.php">Remote Jobs</a></li>
	</ul>
<h2 class="topmargin1">Help</h2>
	<ul class="leftmenu">
		    <li><a <?php if ($leftmenu == 'Admin-Help') echo ' class="current"' ; ?> title="Admin Functions" href="/XGDB/help/admin_gdb.php/"><span class=" help_style" >&nbsp;Administrate</span></a></li>
	</ul>
