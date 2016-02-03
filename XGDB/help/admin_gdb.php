<?php
	$PageTitle = 'xGDBvm - Admin Help';
	$pgdbmenu = 'Help';
	$submenu1= 'Admin-Help';
	$submenu2= 'Admin-Help';
	$leftmenu = 'Admin-Help';
	include '/xGDBvm/XGDB/phplib/sitedef.php';
	include('/xGDBvm/XGDB/phplib/header.php');
?>
	<div id="leftcolumncontainer">
		<div class="minicolumnleft">
			<?php include_once("/xGDBvm/XGDB/help/leftmenu.inc.php"); ?>
		</div>
				</div>
					<div id="maincontentscontainer" class="threecolumn">
						<div id="maincontents" class="help">
						
							<h1 id="heading" class="help_style bottommargin1"><img alt="" src="/XGDB/images/circle_help.png" />&nbsp;Administration for xGDBvm<span class="heading"> &nbsp;Manage website passwords and yrGATE users &amp; groups</span>
							</h1>
						<div class="helpsection">
						<p>The <i>Manage &rarr; <a href="/admin/">Admin</a></i> pages should be configured as login-only and provide tools for 1) configuring and securing your xGDBvm instance; and 2) managing users registered for <a class="help_style" href="/XGDB/help/community_central.php">Community Annotation</a>.</p>
						
						</div>
						<div class="helpsection" id="contents">
							<!--Table of Contents-->
							
							<h2 id="contents_heading" class="help">Contents</h2>
							<ul class="contentslist">
								<li><b>Overview</b>
									<ul class="bullet1">
										<li><a href="#admin_overview">Admin tools</a></li>
									</ul>
								</li>
								</ul>
								<ul class="contentslist">
								<li><b>Password Protection</b>
									<ul class="bullet1">
										<li><a href="#admin_adminpass">Set password for administrative sections</a></li>
										<li><a href="#admin_xgdbpass">Set password for entire website</a></li>
										<li><a href="#admin_dbpass">Set password for MySQL</a></li>
									</ul>
								</li>
								<li><b>Global Site Setup</b>
									<ul class="bullet1">
										<li><a href="#admin_sitename">Add a sitename</a></li>
										<li><a href="#admin_email">Set up admin email</a></li>
									</ul>
								</li>
								<li><b>yrGATE Users and Groups</b>
									<ul class="bullet1">
										<li><a href="#admin_users_account">yrGATE user accounts</a></li>
										<li><a href="#admin_users">Manage yrGATE users</a></li>
										<li><a href="#admin_user_groups">yrGATE User Groups</a></li>
									</ul>
								</li>
								<li><b>Managing Submissions and Curation</b>
									<ul class="bullet1">
										<li><a href="#admin_curation_setup">How to set up for curation</a></li>
										<li><a href="#admin_yrgate_emails">yrGATE email notifications</a></li>
										<li><a href="#admin_curation_session">The Curation Session </a></li>
										<li><a href="#admin_curator_comments">Curator Comments  </a></li>
									</ul>
								</li>
							</ul>
			
					</div>
			<!-- Content based on include files -->
			
						<div class="helpsection">
							<h2 class="help">Overview</h2>
								<div class="feature" id="admin_overview">
									<?php include('/xGDBvm/XGDB/help/includes/admin_overview.inc.php'); ?>
										<a class="smallerfont indent2" href="#heading">[top]</a>
								</div>
						</div>
						<div class="helpsection">
							<h2 class="help">Initial Setup</h2>
								<div class="feature" id="admin_adminpass">
									<?php include('/xGDBvm/XGDB/help/includes/admin_adminpass.inc.php'); ?>
										<a class="smallerfont indent2" href="#heading">[top]</a>
								</div>
								<div class="feature" id="admin_xgdbpass">
									<?php include('/xGDBvm/XGDB/help/includes/admin_xgdbpass.inc.php'); ?>
										<a class="smallerfont indent2" href="#heading">[top]</a>
								</div>
								<div class="feature" id="admin_dbpass">
									<?php include('/xGDBvm/XGDB/help/includes/admin_dbpass.inc.php'); ?>
										<a class="smallerfont indent2" href="#heading">[top]</a>
								</div>
						</div>
						<div class="helpsection">
							<h2 class="help">Global Site Configuration</h2>
								<div class="feature" id="admin_sitename">
									<?php include('/xGDBvm/XGDB/help/includes/admin_sitename.inc.php'); ?>
										<a class="smallerfont indent2" href="#heading">[top]</a>
								</div>
								<div class="feature" id="admin_email">
									<?php include('/xGDBvm/XGDB/help/includes/admin_email.inc.php'); ?>
										<a class="smallerfont indent2" href="#heading">[top]</a>
								</div>
							</div>
						<div class="helpsection">
							<h2 class="help">Managing yrGATE User Accounts</h2>
								<div class="feature" id="admin_users_account">
									<?php include('/xGDBvm/XGDB/help/includes/admin_users_account.inc.php'); ?>
										<a class="smallerfont indent2" href="#heading">[top]</a>
								</div>
								<div class="feature" id="admin_users">
									<?php include('/xGDBvm/XGDB/help/includes/admin_users.inc.php'); ?>
										<a class="smallerfont indent2" href="#heading">[top]</a>
								</div>
								<div class="feature" id="admin_user_groups">
									<?php include('/xGDBvm/XGDB/help/includes/admin_user_groups.inc.php'); ?>
										<a class="smallerfont indent2" href="#heading">[top]</a>
								</div>
						</div>
						<div class="helpsection">
							<h2 class="help">yrGATE Submissions and Curation</h2>
								<div class="feature" id="admin_curation_setup">
									<?php include('/xGDBvm/XGDB/help/includes/admin_curation_setup.inc.php'); ?>
										<a class="smallerfont indent2" href="#heading">[top]</a>
								</div>
								<div class="feature" id="admin_yrgate_emails">
									<?php include('/xGDBvm/XGDB/help/includes/admin_yrgate_emails.inc.php'); ?>
										<a class="smallerfont indent2" href="#heading">[top]</a>
								</div>
								<div class="feature" id="admin_curation_session">
									<?php include('/xGDBvm/XGDB/help/includes/admin_curation_session.inc.php'); ?>
										<a class="smallerfont indent2" href="#heading">[top]</a>
								</div>
								<div class="feature" id="admin_curator_comments">
									<?php include('/xGDBvm/XGDB/help/includes/admin_curator_comments.inc.php'); ?>
										<a class="smallerfont indent2" href="#heading">[top]</a>
								</div>
						</div>
					</div><!--end maincontents-->
						  <div style="clear:both; float:right">
							<a href="http://validator.w3.org/check?uri=referer"><img
							  src="http://www.w3.org/Icons/valid-xhtml10" alt="Valid XHTML 1.0 Transitional" height="15" width="44" /></a>
						  </div>						
				</div><!--end maincontentscontainer-->
			<?php include('/xGDBvm/XGDB/phplib/footer.php'); ?>
		</div><!--end pagewidth-->
	</div><!--end innercontainer-->
</div><!--end outercontainer-->
</body>
</html>

