<?php ob_start(); ?>
<?php 
include_once('/xGDBvm/XGDB/phplib/db.inc.php'); #reads MySQL password from /xGDBvm/admin/dbpass
$dbpass=dbpass();
$db = mysql_connect("localhost", "gdbuser", $dbpass);

if(!$db){
echo "Error: Could not connect to mysql!";
exit;
}
$global_DB= 'yrgate';
mysql_select_db('$global_DB');

//this script updates all records in yrgate.users based on posted values from users.php

if(mysql_real_escape_string($_POST['action']) == 'Update'){
	$count=mysql_real_escape_string($_POST['count']); // total number of records posted


	for($i=0;$i<$count;$i++){
		$account_type=mysql_real_escape_string($_POST['account_type'.$i]); // get posted account_type value for each record (corresponding to unique account_type name)
		$uid=mysql_real_escape_string($_POST['uid'.$i]); // get posted uid value for each record (corresp. to unique uid name)
		$sql="UPDATE $global_DB.users SET account_type='$account_type' WHERE uid=$uid";
		echo $sql;
		$result=mysql_query($sql);
		}
	if($result){
		header("location:users.php");
		}
	mysql_close();
}
?>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<title>Runn xGDBvm script- Error</title>
</head>

<body>
<?php 

#debug: $i="0"; $j="1"; echo "Count: $count\n"; echo "; account_type0:\n"; echo $_POST['account_type'.$i]; echo "; uid0:\n"; echo $_POST['uid'.$i]; echo "; account_type1:\n"; echo $_POST['account_type'.$j]; echo "; uid1:\n"; echo $_POST['uid'.$j];

 ?>
</body>
</html>
<?php ob_flush();?>