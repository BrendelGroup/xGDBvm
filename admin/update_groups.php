<?php ob_start(); ?>
<?php 
include_once('/xGDBvm/XGDB/phplib/db.inc.php'); #reads MySQL password from /xGDBvm/admin/dbpass
$dbpass=dbpass();
$db = mysql_connect("localhost", "gdbuser", $dbpass);
$error="";
if(!$db){
	echo "Error: Could not connect to mysql!";
	exit;
	}
$global_DB= 'yrgate';
mysql_select_db('$global_DB');

//this script updates all records in yrgate.user_group based on posted values from group.php

########## Create New Group ###########

if($_POST['group_action'])
	{

		if
		(
		$_POST['add_group']!="" &&
		$_POST['addgroup_gdb']!="" &&
		$_POST['addgroup_user']!=""
		)
		{
		
		$group=mysql_real_escape_string($_POST['add_group']);
		$gdb=mysql_real_escape_string($_POST['addgroup_gdb']);
		$user=mysql_real_escape_string($_POST['addgroup_user']);

		 // get posted admin user_name
				$group_sql="INSERT INTO $global_DB.user_group (private_group, gdb, user, status) values ('$group', '$gdb', '$user', 'ADMIN')"; // ADMIN hard-coded on purpose
#				echo $group_sql;
				$group_result=mysql_query($group_sql);
				if($group_result)
				{
				header("location:groups.php");
				}

			mysql_close();
		}
		else
		{
		$error="Back up and complete all fields";
		}
	}


##########  Add User to Group ###########  

if($_POST['user_action'] || $_POST['user_action_repeat'] )
		{

		$adduser=mysql_real_escape_string($_POST['adduser']); // get posted user name
		$adduser_group=mysql_real_escape_string($_POST['adduser_group']); // get posted group name
		$adduser_status=mysql_real_escape_string($_POST['adduser_status']); // get posted status
				$gdb_query="Select gdb from $global_DB.user_group where private_group='$adduser_group' limit 1"; # need to find out which db is specified for this group.
				$gdb_result=mysql_query($gdb_query);
				$gdb=mysql_fetch_row($gdb_result);
				$gdb_one=$gdb[0];
				$group_sql="INSERT INTO $global_DB.user_group (private_group, gdb, user, status) values ('$adduser_group', '$gdb_one', '$adduser', '$adduser_status')"; // ADMIN hard-coded on purpose
#				echo $group_sql;
				$group_result=mysql_query($group_sql);
				if($group_result)
				{
				if($_POST['user_action_repeat'] )
					{
						header("location:groups.php?mode=AddUser&group=$adduser_group&user=$adduser");
					}else
					{
						header("location:groups.php");
					}
				}
				else
				{
				$error="This user is already a member of this group";
				}
			mysql_close();
	}

######### Edit User Accounts or remove user ###########

if($_POST['edit_action'])
{
	$count=mysql_real_escape_string($_POST['count']); // total number of records posted
	for($i=0;$i<$count;$i++)
		{
			$status=mysql_real_escape_string($_POST['status'.$i]); // get posted status value for each record (corresponding to unique status name)
			$uid=mysql_real_escape_string($_POST['uid'.$i]); // get posted uid value for each record (corresp. to unique uid name)
			if($status=='REMOVE')
				{
			$update_sql="DELETE FROM $global_DB.user_group WHERE uid=$uid";
				}
				else
				{
			$update_sql="UPDATE $global_DB.user_group SET status='$status' WHERE uid=$uid";
				}
	#		echo $update_sql;
			$result=mysql_query($update_sql);
		}
	if($result)
		{
		header("location:groups.php");
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
echo $error;
 ?>
</body>
</html>
<?php ob_flush();?>