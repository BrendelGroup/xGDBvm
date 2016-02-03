<?php ob_start(); 
$PageTitle = 'XGDB Password Error';
$pgdbmenu = 'Setup';
$submenu = 'Setup';
include('sitedef.php');
$leftmenu='Error';
include($XGDB_HEADER);
include_once('/xGDBvm/XGDB/phplib/db.inc.php');
$dbpass=dbpass();
$error="";
$db = mysql_connect("localhost", "gdbuser", $dbpass);
$action = mysql_real_escape_string($_POST['action']);

if($action =='update')
	{
	$new_xgdbpass1 = $_POST['xgdbpass1']; //
	$new_xgdbpass2 = $_POST['xgdbpass2']; //

### error tests ###
	$error="";

	####### 1. check password match #######
	
	$error.= ($new_xgdbpass1 == $new_xgdbpass2)? "":"-The passwords you supplied do not match <br /> ";
	$error.= ($new_xgdbpass1 == "")? " You forgot to enter a password.<br />":"";

	if($error =="")
		{
	
### launch script that will write new password to htpass file

		$command = "/xGDBvm/scripts/xGDB_newXGDBpass.sh -p $new_xgdbpass1";
		exec($command);
	
### return to setup page

		header("Location: setup.php");
		exit();
## user wants to remove password protection

		}
	}
	elseif($action =='remove')
	{
	
	
## do something here
	$command = "/xGDBvm/scripts/xGDB_deleteXGDBpass.sh";
	exec($command);

### return to setup page
	
	header("Location: setup.php");
	exit();	
			
	}
	else
	{
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