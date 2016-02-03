<?php
include "sitedef.php";
global $pgdbmenu, $submenu1, $submenu2
/*
	Synchronize any changes made in this file with:
		/XGDB/perllib/xgdbGUIconf.pl - For xGDB menus
		/cgi-bin/lib/perllib/header.pl
		/tool/blast/blast.html
		/tool/GeneSeqer/GeneSeqer.html - preserve menu highlighting!
	Do this by copying from the "view source" window of any page that includes this file - ie, make a hard copy.
		Or copy the contents of the bottom text area from /admin/menu.php
			This file, pgdbmenu.inc.php, contains PHP code which won't be useful in PERL code or plain XHTML. -dhrasmus

*/
?>
<!-- Menu uses the jquery superfish.js plugin. Styling in superfish.css -->

<div id="menuwidth">
	<div id="pgdbmenu">
		<ul class="sf-menu">
			<li><a style="text-align:center"<?php if ($pgdbmenu == 'Home') echo ' class="current"';?> href="/">Home</a></li>
			<li><a style="text-align:center"<?php if ($pgdbmenu == 'Manage') echo ' class="current"';?> href="/XGDB/manage/index.php">Manage</a>
				<ul style="width:160px" class="nowrap">
					<li><a<?php if ($submenu1 == 'Manage-Home') echo ' class="current manage" ';?> href="/XGDB/manage/index.php">-Getting Started-</a></li>
					<li><a <?php if ($submenu1 == 'Admin-Home') echo ' class="current"' ; ?> title="Administrative pages" href="/admin/index.php/">Admin </a>
						<ul style="width:180px" class="nowrap">
							<li><a <?php if ($submenu2 == 'Admin-Home') echo ' class="current" ';?> href="/admin/index.php">-Getting Started-</a></li>
							<li><a <?php if ($submenu2 == 'Admin-Setup') echo ' class="current" ';?> href="/admin/setup.php">Set Up Passwords</a></li>
							<li><a <?php if ($submenu2 == 'Admin-Sitename') echo ' class="current" ';?> href="/admin/sitename.php">Set Up Site Name</a></li>
							<li><a <?php if ($submenu2 == 'Admin-Email') echo ' class="current" ';?> href="/admin/email.php">Set Up Admin Email</a></li>
							<li><a <?php if ($submenu2 == 'Admin-Users') echo ' class="current"' ; ?>  href="/admin/users.php">Manage Users</a></li>
							<li><a <?php if ($submenu2 == 'Admin-Groups') echo ' class="current" ';?> href="/admin/groups.php">Manage User Groups</a></li>
							<li><a <?php if ($submenu2 == 'Admin-Help') echo ' class="current" ';?> href="/XGDB/help/admin_gdb.php">&nbsp;&nbsp;Admin Help</a></li>
						</ul>								
					</li>
					<li><a <?php if ($submenu1 == 'Config-Home') echo ' class="current"' ; ?> title="Configure/Create GDB" href="/XGDB/conf/index.php/">Configure/Create</a>
					
						<ul  style="width:190px" class="nowrap">
							<li><a<?php if ($submenu2 == 'Config-Home') echo ' class="current" ';?> href="/XGDB/conf/index.php">-Getting Started-</a></li>
							<li><a <?php if ($submenu2 == 'Config-Instructions') echo ' class="current"' ; ?>  href="/XGDB/conf/instructions.php">Stepwise Instructions</a></li>
							<li><a <?php if ($submenu2 == 'Config-Volumes') echo ' class="current"' ; ?>  href="/XGDB/conf/volumes.php">Data Volumes</a></li>
							<li><a <?php if ($submenu2 == 'Config-Licenses') echo ' class="current"' ; ?>  href="/XGDB/conf/licenses.php">License Keys</a></li>
							<li><a <?php if ($submenu2 == 'Config-Sources') echo ' class="current"' ; ?>  href="/XGDB/conf/sources.php">Data Sources</a></li>
							<li><a <?php if ($submenu2 == 'Config-Data') echo ' class="current"' ; ?>  href="/XGDB/conf/data.php">Data Requirements</a></li>
							<li><a <?php if ($submenu2 == 'Config-Annotate') echo ' class="current"' ; ?>  href="/XGDB/conf/annotate.php">Annotation Guide</a></li>
							<li><a <?php if ($submenu2 == 'Config-New') echo ' class="current"' ; ?>  href="/XGDB/conf/new.php">Configure New GDB</a></li>
							<li><a <?php if ($submenu2 == 'Config-ViewAll') echo ' class="current" ';?> href="/XGDB/conf/viewall.php">List All Configured</a></li>						
							<li><a <?php if ($submenu2 == 'Config-Archive') echo ' class="current"' ; ?>  href="/XGDB/conf/archive.php">Archive/Delete GDB</a></li>
												<?php asort($xGDB);
												foreach ($config as $keys=>$value[0]){
													echo "<li style=\"background-color:#41BEE1; width:30em;\"><a href=\"/XGDB/conf/view.php?id=$value[0]/\"> Config: $value[0]  $keys-</a></li>";
												}?>
						</ul>
				
				 	</li>
					<li><a <?php if ($submenu1 == 'Jobs-Home') echo ' class="current"' ; ?> title="Remote Jobs pages" href="/XGDB/jobs/index.php/">Remote Jobs</a>
						 <ul style="width:15em" class="nowrap">
							<li><a <?php if ($submenu2 == 'Jobs-Home') echo ' class="current" ';?> href="/XGDB/jobs/index.php">-Getting Started-</a></li>
							<li><a <?php if ($submenu2 == 'Jobs-Instructions') echo ' class="current"' ; ?>  href="/XGDB/jobs/instructions.php">Stepwise Instructions</a></li>
							<li><a <?php if ($submenu2 == 'Jobs-Resources') echo ' class="current"' ; ?>  href="/XGDB/jobs/resources.php">Estimate Resources</a></li>
							<li><a <?php if ($submenu2 == 'ConfigJobs') echo ' class="current"' ; ?>  href="/XGDB/jobs/configure.php">Configure API</a></li>
							<li><a <?php if ($submenu2 == 'ConfigApps') echo ' class="current"' ; ?>  href="/XGDB/jobs/apps.php">Configure Apps</a></li>
							<li><a <?php if ($submenu2 == 'UserLogin') echo ' class="current"' ; ?>  href="/XGDB/jobs/login.php">Authenticate User</a></li>
							<li><a <?php if ($submenu2 == 'SubmitJob') echo ' class="current"' ; ?>  href="/XGDB/jobs/submit.php">Submit Standalone Job</a></li>
							<li><a <?php if ($submenu2 == 'SubmitGDBJob') echo ' class="current"' ; ?>  href="/XGDB/jobs/submit_pipeline.php">Submit Pipeline Job</a></li>
							<li><a <?php if ($submenu2 == 'ManageJobs') echo ' class="current"' ; ?>  href="/XGDB/jobs/manage.php">Manage Jobs</a></li>
							<li><a <?php if ($submenu2 == 'ListJobs') echo ' class="current"' ; ?>  href="/XGDB/jobs/jobs.php">List All Jobs</a></li>
						</ul>
					</li>
				</ul>
			</li>
			<li><a style="text-align:center"<?php if ($pgdbmenu == 'Genomes') echo ' class="current"';?> href="/XGDB/">View</a>
				<ul class="nowrap">
					<li style="width:30em; overflow:hidden"><a <?php if ($submenu2 == 'View-Home') echo ' class="current_gdb"' ; ?>title="View- Getting Started" href="/XGDB/index.php/">-Getting Started-</a></li>
					<li style="width:30em; overflow:hidden"><a <?php if ($submenu2 == 'GenomeList') echo ' class="current_gdb"' ; ?>title="List of current genomes" href="/XGDB/genomes.php/">Current Genomes</a></li>
					<li style="width:30em; overflow:hidden"><a <?php if ($submenu2 == 'GDBstats') echo ' class="current_gdb"' ; ?>title="Statistics of current genomes" href="/XGDB/GDBstats.php/">Genome Statistics</a></li>
					<?php asort($xGDB);
					foreach ($xGDB as $keys=>$value){
						echo "<li style=\"width:30em; overflow:hidden; background-color:#41BEE1\"><a href=\"/XGDB/phplib/index.php?GDB=${value}\">$value &nbsp;&nbsp; $keys - </a></li>";
					}?>
				</ul>
			</li>
			<li><a style="text-align:center"<?php if ($pgdbmenu == 'Annotation') echo ' class="current"';?> href="/src/yrGATE/">Annotate</a>
				<ul class="nowrap">
					<?php asort($xGDB);
						echo "<li style=\"width:18em; overflow:hidden\"><a href=\"/src/yrGATE/\">-Getting Started-</a></li>";
						echo "<li style=\"width:18em; overflow:hidden\"><a href=\"/src/yrGATE/overview.php\">yrGATE Overview</a></li>";
						foreach ($xGDB as $keys=>$value){
						echo "<li style=\"width:18em; background-color:#41BEE1; overflow:hidden\"><a href=\"/yrGATE/$value/CommunityCentral.pl\">$value &nbsp;&nbsp; Community Central</a></li>";
					}?>
				</ul>
			</li>
			<li><a style="text-align:center"<?php if($pgdbmenu=='Help') echo ' class="current"';?> href="/XGDB/help/">Help</a>
				<ul style="width:12em" class="nowrap">
					<li class="first"><a <?php if ($submenu1 == 'AllHelp') echo ' class="current"' ; ?> title="View All Help Resources" href="/XGDB/help/index.php"> - All Help Resources - </a></li>
					<li><a  <?php if ($submenu2 == 'VideoHelp') echo ' class="current"' ; ?> title="Video tutorials" href="/XGDB/help/video_tutorials.php"> - Video Tutorials - </a></li>
					<li><a <?php if ($submenu2 == 'Admin-Help') echo ' class="current"' ; ?> title="Help for Admin pages" href="/XGDB/help/admin_gdb.php">Administration</a></li>
					<li><a <?php if ($submenu2 == 'CommCentralhelp') echo ' class="current"' ; ?> title="List of community-annotated genes" href="/XGDB/help/community_central.php/">Community Central</a></li>
					<li><a <?php if ($submenu2 == 'CreateManage') echo ' class="current"' ; ?> title="Help for how to create genome browser" href="/XGDB/help/create_gdb.php">Configure/Create</a></li>
					<li><a <?php if ($submenu2 == 'CpGAT') echo ' class="current"' ; ?> title="CpGAT Annotation Pipeline" href="/XGDB/help/cpgat.php/">CpGAT</a></li>
					<li><a <?php if ($submenu2 == 'Requirements') echo ' class="current"' ; ?> title="Overview of data requirements for xGDBvm pipeline" href="/XGDB/conf/data.php/">Data Requirements</a></li>
					<li><a <?php if ($submenu2 == 'TracksHelp') echo ' class="current"' ; ?> title="Help with Feature Track tables" href="/XGDB/help/feature_tracks.php/">Feature Tracks</a></li>
					<li><a <?php if ($submenu2 == 'GAEVALhelp') echo ' class="current"' ; ?> title="Overview of GAEVAL evaluation system for gene congruence with data" href="/XGDB/help/gaeval.php/">GAEVAL</a></li>
					<li><a <?php if ($submenu2 == 'ViewGDBhelp') echo ' class="current"' ; ?> title="Viewing, searching, analyzing GBD data" href="/XGDB/help/genome_browser.php">Genome Browsers</a></li>
					<li><a <?php if ($submenu2 == 'Input_Output') echo ' class="current"' ; ?> title="Tabular view of data inputs and outputs" href="/XGDB/conf/input_output.php/">Inputs / Outputs</a></li>
					<li><a <?php if ($submenu2 == 'Remote_Jobs') echo ' class="current"' ; ?> title="Help for how to create genome browser" href="/XGDB/help/remote_jobs.php">Remote HPC Jobs</a></li>
					<li><a <?php if ($submenu2 == 'Overview') echo ' class="current"' ; ?> title="Overview of xGDBvm features" href="/XGDB/help/xgdbvm_overview.php/">xGDBvm Overview</a></li>
					<li><a title="xGDBvm Wiki" href="http://goblinx.soic.indiana.edu/wiki/doku.php">xGDBvm Wiki</a></li>
					<li><a <?php if ($submenu1 == 'yrGATEhelp') echo ' class="current"' ; ?> title="Help for yrGATE community annotation tool" href="/XGDB/help/yrgate.php/">yrGATE</a></li>
				</ul>
			</li>
		</ul>
	</div>
</div><!-- end of menuwidth div -->

