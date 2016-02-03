<?php ob_start(); ?>
<?php
$PageTitle = 'xGDBvm yrGATE admin error';
$pgdbmenu = 'Admin';
$submenu = 'Admin';
include('sitedef.php');
$leftmenu='Error';
include($PLANTGDB_HEADER);
include_once('/xGDBvm/XGDB/phplib/db.inc.php');
$dbpass=dbpass();
$error="";
$db = mysql_connect("localhost", "gdbuser", $dbpass);
$action = mysql_real_escape_string($_POST['action']);
global $insert, $update, $statement;
if($action =='setup')
	{
	$admin_email =  mysql_real_escape_string($_POST['admin_email']); //
	$admin_email_date =  date("Y-m-d H:i:s");

	### error tests ###
		$error="";
	
		####### 1. check empty email #######
		
		$error.= ($admin_email == "")? " You forgot to enter an email address.<br />":"";
	
		if($error =="")
		{
			if(mysql_real_escape_string($_POST['type'])=='insert')
			{
				$statement = "insert into Admin.admin (admin_email_date, admin_email) values ('$admin_email_date', '$admin_email')";
				$insert="T";
			}
			elseif(mysql_real_escape_string($_POST['type'])=='update')
			{
				$statement = "update Admin.admin set admin_email_date='$admin_email_date', admin_email= '$admin_email' where admin_email !=''";
				$update="T";
			}
			$do_statement = mysql_query($statement);
		
			header("Location: email.php#updated");
			exit();
	
		}
	}
?>

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
			<?php include($PLANTGDB_FOOTER); ?>
		</div></div></div>
	</body>
</html>

</body>
</html>
<?php ob_flush();?>