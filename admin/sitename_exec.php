<?php ob_start(); ?>
<?php
$PageTitle = 'xGDBvm Sitename admin error';
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
	$sitename =  mysql_real_escape_string($_POST['sitename']); //
	$sitename = substr($sitename, 0, 20); // LIMIT LENGTH
	### error tests ###
		$error="";
	
		####### 1. check empty email #######
		
		$error.= ($sitename == "")? " You forgot to enter a sitename.<br />":"";
	
		if($error =="")
		{

		file_put_contents("/xGDBvm/admin/sitename", $sitename);

		header("Location: sitename.php#updated");
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