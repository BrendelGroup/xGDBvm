<?php ob_start(); ?>
<?php
$PageTitle = 'MySQL Password Error';
$pgdbmenu = 'Setup';
$submenu = 'Setup';
$leftmenu='Error';
include('sitedef.php');
include($XGDB_HEADER);
include_once('/xGDBvm/XGDB/phplib/db.inc.php');
$dbpass=dbpass();
$error="";
$db = mysql_connect("localhost", "gdbuser", $dbpass);

$query="select ID from Genomes.xGDB_Log where status ='Current'";

### Make sure the user does not already have GDB in place (which wouldn't be configured correctly for a new MySQL pw)
$get_records = $query;
$check_get_records = mysql_query($get_records);
$result = $check_get_records;
$count=mysql_num_rows($result);

$error.=($count==False)?"":" You have one or more 'Current' GDB so you cannot modify the MySQL password <br /> ";

$action = mysql_real_escape_string($_POST['action']);

if($action =='update' && $error=='')
	{
	$new_dbpass1 = $_POST['dbpass1']; //
	$new_dbpass2 = $_POST['dbpass2']; //

### error tests ###

	####### 1. check password match #######
	
	$error.= ($new_dbpass1 == $new_dbpass2)? $error:" The passwords you supplied do not match <br /> ";
	$error.= ($new_dbpass1 == "")? " You forgot to enter a password.<br />":$error;


	if($error ==""){
	
### write new password to temp password file (which will be created)

		file_put_contents("/xGDBvm/admin/new_dbpass", $new_dbpass1);

### update the MySQL permissions for user=gdbuser by invoking a shell script

	$command = "/xGDBvm/scripts/xGDB_newDbpass.sh";
	exec($command);

### return to setup page

			 header("Location: setup.php?action=dbpass");
		exit();

		}else{
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
			<?php include($XGDB_FOOTER); ?>
		</div></div></div>
	</body>
</html>

</body>
</html>
<?php ob_flush();?>
