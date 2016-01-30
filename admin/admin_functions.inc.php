<?php


//generic for building a dropdown list of distinct values given a data column, db and table

	function admin_dropdown($column, $db, $table){
	
		$admin_dropdown_result="<option selected =\"selected\" value=\"\">- Select a $column -</option>\n\n";
		$adminQuery="SELECT distinct $column FROM $db.$table";
		$get_admin = $adminQuery;
		$check_get_admin = mysql_query($get_admin);
		$adminSelect="";
		while ($admin_data = mysql_fetch_array($check_get_admin)) {
				$adminSelect = $admin_data[$column];
				$admin_dropdown_result.= "<option value=\"$adminSelect\">$adminSelect</option>\n\n";
			}	
			
			return $admin_dropdown_result;
}
//get a list of users not in the selected working group. If selected group is empty, then defaults to all users.

	function user_dropdown($selected_group){
	
		$user_dropdown_result="<option selected =\"selected\" value=\"\">- Select username-</option>\n\n";
		$userQuery="SELECT distinct user_name FROM users where user_name not in (select user from user_group where private_group='$selected_group')";
		$get_user = $userQuery;
		$check_get_user = mysql_query($get_user);
		$userSelect="";
		while ($user_data = mysql_fetch_array($check_get_user)) {
				$userSelect = $user_data['user_name'];
				$user_dropdown_result.= "<option value=\"$userSelect\">$userSelect</option>\n\n";
			}	
			
			return $user_dropdown_result;
}

//specific for building a dropdown list of all available GDB
	function gdb_dropdown(){
	
		$gdbQuery="SELECT ID FROM Genomes.xGDB_Log";
		$get_gdb = $gdbQuery;
		$check_get_gdb = mysql_query($get_gdb);
		$gdbSelect="";
		$gdbAll="All";
		$gdb_dropdown_result="<option selected =\"selected\" value=\"$gdbAll\">All</option>\n\n";
		while ($gdb_data = mysql_fetch_array($check_get_gdb)) {
				$gdbSelect = $gdb_data['ID'];
				$ID= substr('00'. $gdbSelect, -3);
				$GDB='GDB'.$ID; # reconstruct GDBnnn from id
				$gdb_dropdown_result.= "<option value=\"$GDB\">$GDB</option>\n\n";
			}	
			
			return $gdb_dropdown_result;
}
//build list of all available groups from yrgate.user_group

	function list_groups(){
		$groups_dropdown_result="";
		$groupsQuery="SELECT distinct private_group FROM yrgate.user_group order by private_group";
		$get_groups = $groupsQuery;
		$check_get_groups = mysql_query($get_groups);
		$groupselect="";
		while ($group_data = mysql_fetch_array($check_get_groups)) {
				$groupselect = $group_data['private_group'];
				$groups_dropdown_result.= "<li>$groupselect</li>";
			}	
			
			return $groups_dropdown_result;
}

//specific for building a dropdown list of all available GDB
	function groups_dropdown(){
	
		$groupsQuery="SELECT distinct private_group FROM yrgate.user_group order by private_group";
		$get_groups = $groupsQuery;
		$check_get_groups = mysql_query($get_groups);
		$gdbSelect="";
		$groups_dropdown_result="<option selected =\"selected\" value=\"\">- select group -</option>\n\n";
		while ($group_data = mysql_fetch_array($check_get_groups)) {
				$group_select = $group_data['private_group'];
				$groups_dropdown_result.= "<option value=\"$group_select\">$group_select</option>\n\n";
			}	
			
			return $groups_dropdown_result;
}

?>
