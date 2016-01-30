<?php ob_start(); ?>
<?php 
$global_DB= 'Genomes';
include_once('/xGDBvm/XGDB/phplib/db.inc.php');
$dbpass=dbpass();
$db = mysql_connect("localhost", "gdbuser", $dbpass);
mysql_select_db('$global_DB');
$id = mysql_real_escape_string($_POST['id']);

#$first_query = "select ID from $global_DB.xGDB_Log order by ID ASC limit 1;";
#$check_first = mysql_query($first_query);
#$first_record_array = mysql_fetch_array($check_first);
#$first_record = $first_record_array['ID'];

#$last_query = "select ID from $global_DB.xGDB_Log order by ID DESC limit 1;";
#$check_last = mysql_query($last_query);
#$last_record_array = mysql_fetch_array($check_last);
#$last_record = $last_record_array['ID'];


if($_POST['Navigate']=='Previous')
	{
		$redirect_query = "select ID from $global_DB.xGDB_Log where ID<'$id' order by ID DESC limit 1;";
	}
elseif($_POST['Navigate']=='Next')
	{
		$redirect_query = "select ID from $global_DB.xGDB_Log where ID>'$id' order by ID ASC limit 1;";	
	}
#elseif($_POST['Navigate']=='Last')
#	{
#		$redirect_query = "select ID from $global_DB.xGDB_Log order by ID DESC limit 1;";	
#	}
	

$check_redirect = mysql_query($redirect_query);
$n = mysql_num_rows($check_redirect);
$new_record_array = mysql_fetch_array($check_redirect);
$new_record = $new_record_array['ID'];
if($n==0)
        {
                header("Location: view.php?id=1");
        }
else
        {
                header("Location: view.php?id=$new_record");
        }


echo "$id"; echo " | redirect_query: "; echo "$redirect_query"; echo " | check_redirect: "; echo "$check_redirect";


