<?php
	$global_DB= 'Admin';
	$PageTitle = 'xGDBvm Admin Home';
	$pgdbmenu = 'Manage';
	$submenu1 = 'Admin-Home';
	$submenu2 = 'Admin-Home';
	$leftmenu='Admin-Home';
	include('sitedef.php');
	include($XGDB_HEADER);
 	include_once('/xGDBvm/XGDB/phplib/db.inc.php'); #reads MySQL password from /xGDBvm/admin/dbpass
	$dbpass=dbpass();
	$db = mysql_connect("localhost", "gdbuser", $dbpass);
	if(!$db)
	{
		echo "Error: Could not connect to database!";
		exit;
	}
		mysql_select_db("$global_DB");
		$error = $_GET['error'];

# Get sitename from /xGDBvm/admin/sitename
$sitename_file='/xGDBvm/admin/sitename';
if(file_exists($sitename_file))
{	
	$file_handle = fopen($sitename_file, "r");
	while (!feof($file_handle)) {
	   $sitename = fgets($file_handle);
	}
	fclose($file_handle);
}
else
{
$sitename="";
}

#query for mysql password changes and build result array
$db_query="select uid, dbpass_update_date as date, dbpass_update as status from Admin.admin where dbpass_update_date !='' order by uid desc limit 1";

$get_db_records = $db_query;
$check_get_db_records = mysql_query($get_db_records);
$db_result = $check_get_db_records;
$db=mysql_fetch_array($db_result);

## Has user updated db passwords?
	$dbpass=$db["status"];
	$dbpass_date=$db["date"];


## query for yrGATE email and build result array
$yrgate_query="SELECT uid, admin_email, admin_email_date from Admin.admin where admin_email !='' order by uid ASC limit 0,1";
$get_yrgate_records = $yrgate_query;
$check_get_yrgate_records = mysql_query($get_yrgate_records);
$yrgate_result = $check_get_yrgate_records;
$yrgate=mysql_fetch_array($yrgate_result);	
## Has user updated yrgate passwords?
	$yrgate_email=$yrgate["admin_email"];
	$yrgate_email_date=$yrgate["admin_email_date"];

	
## query for user total and build result array
$users_query="select count(*) from yrgate.users";
$get_users_records = $users_query;
$check_get_users_records = mysql_query($get_users_records);
$users_result = $check_get_users_records;
$users=mysql_fetch_array($users_result);	
	$user_count=$users[0];

## query for group total and build result array
$group_query="select count(distinct private_group) from yrgate.user_group";
$get_group_records = $group_query;
$check_get_group_records = mysql_query($get_group_records);
$group_result = $check_get_group_records;
$group=mysql_fetch_array($group_result);	
	$group_count=$group[0];

## Get password flags

$adminpassword_file='/xGDBvm/admin/adminpassword';
$xgdbpassword_file='/xGDBvm/admin/xgdbpassword';
$adminpass=file_exists($adminpassword_file)?true:false;
$xgdbpass=file_exists($xgdbpassword_file)?true:false;


## Set messages
	$adminpass_message=($adminpass==true)
		?
		"<p class=\"locked indent2\">The 'Manage' sections of this VM are password-protected</p>"
		:
		"<p class=\"alertnotice warning indent2\"> No admin/config password is in effect</p>";
	$dbpass_message=($dbpass=="")
		?
		"<p class=\"alertnotice warning indent2 \">The default MySQL password has not been changed</p>"
		:
		"<p class=\"locked indent2\">MySQL password has been changed from default</p>";
	$xgdbpass_message=($xgdbpass==true)
		?
		"<p class=\"locked indent2\">This VM is password-protected</p>"
		:
		"<p class=\"alertnotice warning indent2 \">No global website password is in effect</p>";
		
	$yrgate_email_message=($yrgate_email=="" || $yrgate_email=="Removed")
		?
		"<p class=\"alertnotice warning indent2\"> No Admin email address has been added</p>"
		:
		"<p class=\"checked indent2\">Admin email '<span class=\"darkgrayfont\">$yrgate_email</span>' was added on $yrgate_email_date </p>";
	$sitename_message=($sitename=="")
		?
		"<p class=\"alertnotice warning indent2\"> No site name has been added</p>"
		:
		"<p class=\"checked indent2\">Site name '<span class=\"darkgrayfont\">$sitename</span>' is in effect </p>";
				
	$users_message=($user_count=="0")
		?
		"<p class=\"alertnotice warning indent2\"> No yrGATE users have been registered on this xGDBvm</p>"
		:
		"<p class=\"checked indent2\">Number of yrGATE Users registered on this xGDBvm: <span class=\"darkgrayfont\">$user_count</span> </p>";
		
	$groups_message=($group_count=="0")
		?
		"<p class=\"alertnotice warning indent2\"> No yrGATE user groups have been created on this xGDBvm</p>"
		:
		"<p class=\"checked indent2\">Number of User Groups on this xGDBvm: <span class=\"darkgrayfont\">$group_count</span></p>";
	?>


				<div id="leftcolumncontainer">
					<div class="minicolumnleft">
						<?php include_once("/xGDBvm/admin/leftmenu.inc.php"); ?>
					</div>
				</div>
				<div id="maincontentscontainer" class="twocolumn overflow">
					<div id="maincontents">	
						<h1 class="admin bottommargin1"><img src="/XGDB/images/user.png" alt="" /> Administration - <i>Getting Started</i></h1>
					<p class="indent2"><span class="largerfont"> Here you can add a site name, manage website password protection and <a class="help_style" href="/XGDB/help/yrgate.php">yrGATE</a> administration, user accounts, and group membership.</span></p>
					
					<p class="indent2"><span class="tip_style">If you haven't done so, you may want to <b>password protect</b> the <i>Admin</i>, <i>Create/Manage</i>, and <i>Remote Jobs</i> sections (see below). </span></p>
				<div class="feature">
					<h2 class="topmargin1 bottommargin1 indent1">Password protection</h2>
					
						<div class="big_button">
							<a title="manage users" href="/admin/setup.php" class="xgdb_button colorG3 largerfont">Set Up Passwords</a>
							<span class="topmargin1 normalfont">- create/change passwords to make your xGDBvm instance more secure</span>
										<div class="feature">			
											<?php echo $adminpass_message; ?>
											<?php echo $xgdbpass_message; ?>
											<?php echo $dbpass_message; ?>
										</div>
						</div>

					
					</div>
				<div class="feature">
					<h2 class="topmargin1 bottommargin1 indent1">Global Site Information</h2>
						<div class="big_button">
							<a title="manage users" href="/admin/sitename.php" class="xgdb_button colorG3 largerfont">Add a Site Name</a>
							<span class="topmargin1 normalfont">- Specify name to appear in the site header. </span>
										<div class="feature">		
											<?php echo $sitename_message; ?>
										</div>
						</div>
						<div class="big_button">
							<a title="manage users" href="/admin/email.php" class="xgdb_button colorG3 largerfont">Set Up Admin Email</a>
							<span class="topmargin1 normalfont">- Specify email address to be notified with global xGDBvm messages (e.g. when HPC jobs are completed). </span>
										<div class="feature">
											<?php echo $yrgate_email_message; ?>
										</div>
						</div>
					</div>
				<div class="feature">
					<h2 class="topmargin1 bottommargin1 indent1">yrGATE Users</h2>
					
						<div class="big_button">
							<a title="manage users" href="/admin/users.php" class="xgdb_button colorG3 largerfont">Manage yrGATE Users</a>
							<span class="topmargin1 normalfont">- View <b>yrGATE User</b> information (Community Annotation); modify USER/ADMIN status. </span>
										<div class="feature">
											<?php echo $users_message; ?>
										</div>
						</div>
						<div class="big_button">
							<a title="manage users" href="/admin/groups.php" class="xgdb_button colorG3 largerfont">Manage yrGATE Groups</a>
							<span class="topmargin1 normalfont">- Set up <b>User Groups</b> to provide common curation by assigned ADMINs. </span>
										<div class="feature">
											<?php echo $groups_message; ?>
										</div>
						</div>
					</div>
				<div class="feature">
					<h2 class="topmargin1 bottommargin1 indent1">Admin Help</h2>

						<div class="big_button">
							<a title="manage users" href="/XGDB/help/admin_gdb.php" class="xgdb_button colorG3 largerfont">Administration Help</a>
							
							<span class="topmargin1 normalfont">- Guide for using these pages </span>
		
						</div>
				</div>
					  </div><!-- end maincontents -->
						  <div style="clear:both; float:right">
							<a href="http://validator.w3.org/check?uri=referer"><img
							  src="http://www.w3.org/Icons/valid-xhtml10" alt="Valid XHTML 1.0 Transitional" height="15" width="44" /></a>
						  </div>						
					</div><!--end maincontentsfull-->
				</div><!--end maincontentscontainer-->
				<?php include($XGDB_FOOTER); ?>
			</div><!--end innercontainer-->
		</div><!--end outercontainer-->
	</body>
</html>
