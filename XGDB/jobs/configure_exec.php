<?php ob_start();
$PageTitle = 'xGDBvm Comp Res error';
$pgdbmenu = 'Configure';
$submenu = 'Configure-CompRes';
$global_DB="Admin";
include('sitedef.php');
$leftmenu='Error';
include($XGDB_HEADER);
include_once('/xGDBvm/XGDB/phplib/db.inc.php');
include_once('/xGDBvm/XGDB/jobs/jobs_functions.inc.php');
$dbpass=dbpass();
$error="";
$db = mysql_connect("localhost", "gdbuser", $dbpass);
$action = mysql_real_escape_string($_POST['action']);
$command = mysql_real_escape_string($_POST['command']);

date_default_timezone_set("$TIMEZONE"); // from sitedef.php

global $insert, $update, $statement;
if($action =='auth_url')
	{

	$url =  mysql_real_escape_string($_POST['auth_url']); // 
	$version =  mysql_real_escape_string($_POST['api_version']); // 
	$date =  date("Y-m-d H:i:s");

	### error tests ###
#		$error="$url \n $command \n $action \n $date";

		$error="";
		
		####### 1. check empty form field #######
		
		$error.= ($url == "")? " You forgot to enter an auth URL.<br />":"";
		$error.= URLIsValid($url)? "":"URL Is invalid";
		if($error =="")
		{
			if($command=='insert')
			{
				$statement = "insert into Admin.admin (auth_update, auth_url, api_version) values ('$date', '$url', '$version')";
				$insert="T";
			}
			elseif($command=='update')
			{

			
#build update statement

				$statement = "update Admin.admin set auth_update='$date', auth_url= '$url', api_version='$version' where auth_url !=''";
				$update="T";

			}
			$do_statement = mysql_query($statement);
			
		### return to compres page
		
			header("Location: configure.php#auth");
			exit();
	
		}
	}
elseif($action == 'gsq_app')
	{
	$gsq_app_description =  mysql_real_escape_string($_POST['gsq_app_description']); //
	$gsq_app_id =  mysql_real_escape_string($_POST['gsq_app_id']); //
	$time =  mysql_real_escape_string($_POST['gsq_job_time']); // 
	$gsq_proc =  intval($_POST['gsq_proc']); // 
	$gsq_proc_per_node =  intval($_POST['gsq_proc_per_node']); // 
	$date =  date("Y-m-d H:i:s");

	### error tests ###
#		$error="$url \n $command \n $action \n $date";

		$error="";
		
		####### 1. check empty form field #######
		
		$error.= ($gsq_app_id == "")? " You forgot to enter a GSQ App ID.<br />":"";
		if($error =="")
		{
			if($command=='insert')
			{
				$statement = "insert into Admin.admin (gsq_update, gsq_job_time, gsq_url, gsq_software, gsq_proc, gsq_proc_per_node) values ('$date', '$time', '$gsq_app_description', '$gsq_app_id', $gsq_proc, $gsq_proc_per_node)";
				$insert="T";
			}
			elseif($command=='update')
			{

			
#build update statement

				$statement = "update Admin.admin set gsq_update='$date', gsq_url= '$gsq_app_description', gsq_software='$gsq_app_id', gsq_job_time='$time', gsq_proc=$gsq_proc, gsq_proc_per_node=$gsq_proc_per_node where gsq_software !=''";
				$update="T";

			}
			$do_statement = mysql_query($statement);
			
		### return to compres page
		
			header("Location: configure.php#gsq");
			exit();
	
		}
  }

elseif($action == 'gth_app')
	{
	$gth_app_description =  mysql_real_escape_string($_POST['gth_app_description']); // 
	$gth_app_id =  mysql_real_escape_string($_POST['gth_app_id']); // 
	$time =  mysql_real_escape_string($_POST['gth_job_time']); // 
	$gth_proc =  intval($_POST['gth_proc']); //
	$gth_proc_per_node =  intval($_POST['gth_proc_per_node']); // 
	$date =  date("Y-m-d H:i:s");

	### error tests ###
#		$error="$url \n $command \n $action \n $date";

		$error="";
		
		####### 1. check empty form field #######
		
		$error.= ($gth_app_id == "")? " You forgot to enter a GTH App ID.<br />":"";
		if($error =="")
		{
			if($command=='insert')
			{
				$statement = "insert into Admin.admin (gth_update, gth_url, gth_software, gth_job_time, gth_proc, gth_proc_per_node) values ('$date', '$gth_app_description', '$gth_app_id', '$time', $gth_proc, $gth_proc_per_node)";
				$insert="T";
			}
			elseif($command=='update')
			{

			
#build update statement

				$statement = "update Admin.admin set gth_update='$date', gth_url= '$gth_app_description', gth_software='$gth_app_id', gth_job_time='$time', gth_proc=$gth_proc, gth_proc_per_node=$gth_proc_per_node where gth_software !=''";
				$update="T";

			}
			$do_statement = mysql_query($statement);
			
		### return to compres page
		
			header("Location: configure.php#gth");
			exit();
	
		}
  }
	
?>
/*
  `uid` int(6) NOT NULL auto_increment,
  `sitename` varchar(32) NOT NULL default '',
  `adminpass_update` varchar(32) NOT NULL default '',
  `adminpass_update_date` varchar(32) NOT NULL default '',
  `dbpass_update` varchar(32) NOT NULL default '',
  `dbpass_update_date` varchar(32) NOT NULL default '',
  `xgdbpass_update` varchar(32) NOT NULL default '',
  `xgdbpass_update_date` varchar(32) NOT NULL default '',
  `admin_email_date` varchar(255) NOT NULL default '',
  `admin_email` varchar(255) NOT NULL default '',
  `auth_url` varchar(255) NOT NULL default '',
  `api_version` varchar(255) NOT NULL default '',
  `auth_update` varchar(32) NOT NULL default '',
  `gsq_url` varchar(255) default '',
  `gsq_software` varchar(32) NOT NULL default '',
  `gsq_job_time` varchar(32) NOT NULL default '',
  `gsq_update` varchar(32) NOT NULL default '',
  `gth_url` varchar(255) NOT NULL default '',
  `gth_software` varchar(32) NOT NULL default '',
  `gth_job_time` varchar(32) NOT NULL default '',
  `gth_update` varchar(32) NOT NULL default '',
  `gsq_proc` int(3) NOT NULL default '0',
  `gth_proc` int(3) NOT NULL default '0',
  */
<body>

		<div id="leftcolumncontainer">
			<div class="minicolumnleft">
			<?php include_once("/xGDBvm/XGDB/phplib/leftmenu.inc.php"); ?>
			</div>
		</div>
			<div id="maincontentscontainer" class="twocolumn">
				<div id="maincontentsfull">
				<h1 class="bottommargin1">Error Message:</h1>
				<p><span class="warning largerfont">
				<?php echo $error; ?></span></p>
				</h1>
				<p>Use the browser "back" button to return to the previous screen and correct the problem.</p>
				</div><!--end maincontentsfull-->
			</div><!--end maincontentscontainer-->
			<div id="rightcolumncontainer">
				</div><!--end rightcolumncontainer-->
			<?php include($XGDB_FOOTER); ?>
		</div></div></div>
	</body>
</html>

</body>
</html>
<?php ob_flush();?>