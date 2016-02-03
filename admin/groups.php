<?php
#error_reporting(E_ALL & ~E_NOTICE); //disable undeclared variable error

//see http://www.phpeasystep.com/mysql/10.html
//http://www.techrepublic.com/article/handling-multiple-submits-in-a-single-form-with-php/5242116

	$global_DB= 'yrgate'; //MySQL
	$PageTitle = 'xGDBvm Groups';
	$pgdbmenu = 'Manage';
	$submenu1 = 'Admin-Home';
	$submenu2 = 'Admin-Groups';
	$leftmenu='Admin-Groups';
	$all_check="checked";
	$added_user_text="";
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
 	require_once('/xGDBvm/admin/admin_functions.inc.php');

### Set default display by assigning css class to show/hide respective td elements
	$addgroup = 'display_off';
	$adduser = 'display_off';
	$edituser = 'display_off'; //default - don't show edit data features when page loads
	$view = 'display_on_block'; //defaults - do show view data features when page loads
	$cancel = 'display_off'; // default - don't show cancel button when page loads
	$viewedit = '';
	$group_dropdown="";
	$user_dropdown=user_dropdown(""); // defaults to all users
	$selected_group="";
	
## radio button values that are checked or selected, either by default or based on current database value.###

	$checked="checked=\"checked\""; #for type =radio button

## Default Query

$Query="SELECT a.user as user, a.gdb as gdb, a.private_group as private_group, a.uid as uid, a.status as status, b.account_type as account_type, b.email as email from $global_DB.user_group as a left join $global_DB.users as b on a.user=b.user_name WHERE account_type != 'INACTIVE' order by a.private_group, a.gdb, a.status, a.user ";


### Modify display based on post values: the following variables set a td css class corresponding to either display:block or display:hidden

$post_mode=isset($_POST['mode'])?$_POST['mode']:"";

if($post_mode == 'Cancel' || $post_mode == 'View'  ){ // Enter View mode (Default).

	$edituser = 'display_off';
	$addgroup = 'display_off';
	$adduser = 'display_off';
	$view = 'display_on_block';
	$cancel = 'display_off';
	$viewedit = '';

	}
$post_mode=isset($_POST['mode'])?$_POST['mode']:"";
$post_group=isset($_POST['group'])?$_POST['group']:"";

if($post_mode == 'EditUser'){ // Enter edit mode; display "INACTIVE" users
	$addgroup = 'display_off';
	$adduser = 'display_off';
	$edituser = '';
	$view = 'display_off';
	$cancel = 'display_on';
	$viewedit = '';
$Query="SELECT a.user as user, a.gdb as gdb, a.private_group as private_group, a.uid as uid, a.status as status, b.account_type as account_type, b.email as email from $global_DB.user_group as a left join $global_DB.users as b on a.user=b.user_name order by a.private_group, a.gdb, a.status, a.user ";

	}
if($post_mode == 'AddGroup'){ // Enter new group mode.
	$addgroup = '';
	$adduser = 'display_off';
	$edituser = 'display_off';
	$view = 'display_off';
	$cancel = 'display_on';
	$viewedit = 'display_off';
	}
if($post_mode == 'AddUser' && $post_group != ''){ //Enter Add User mode; require group 
	$addgroup = 'display_off';
	$adduser = '';
	$edituser = 'display_off';
	$view = 'display_off';
	$cancel = 'display_on';
	$viewedit = 'display_off';
	$selected_group= isset($_POST['group'])?$_POST['group']:""; //user has selected group for which to add users
	$user_dropdown=user_dropdown($selected_group); //dropdown should show only users not already in the group
	}

$get_mode=isset($_GET['mode'])?$_GET['mode']:"";

if($get_mode == 'AddUser'){ //Allows the script 'update_groups.php' to invoke AddUser mode
	$addgroup = 'display_off';
	$adduser = '';
	$edituser = 'display_off';
	$view = 'display_off';
	$cancel = 'display_on';
	$viewedit = 'display_off';
	$selected_group= mysql_real_escape_string($_GET['group']); //we will continue adding users to this group
	$added_user= mysql_real_escape_string($_GET['user']);
	$added_user_text="&nbsp;'".$added_user."' added to group.";
	$user_dropdown=user_dropdown($selected_group); //dropdown should show only users not already in the group
	}
	


#get result count
$get_records = $Query;
$check_get_records = mysql_query($get_records);
$result = $check_get_records;
#Count table rows
$count=mysql_num_rows($result);

	
$grouplist=list_groups(); //list of current troups
$gdb_dropdown=gdb_dropdown(); //list all GDB available
$groups_dropdown=groups_dropdown(); //select a group

### Mode Button Display
$display_block ="
<table style=\"font-size:12px\" width=\"92%\">
<tbody>
	<tr>
		<td colspan=\"8\">
			<h2 class=\"$edituser indent1 bottommargin1\">
				Edit Group Membership:
			</h2>
			<p class=\"$edituser instruction\"> 
				Click radio button(s) to change user Group Member Type, then click 'Update'.  <span class=\"heading\"> (Inactive Users are <span class=\"gray\">Gray</span>)</span>
			</p>
			<p class=\"$edituser instruction\">
				Select 'REMOVE' to delete a user-group assignment (does NOT affect user's yrGATE account)
			</p>
			<h2 class=\"$addgroup indent1 bottommargin1\">
				Create New Group
			</h2>
			<p class=\"$addgroup instruction indent1\">
				Enter New Group name, single GDB or 'All', and Group Administrator (required).
			</p>
			<p class=\"$addgroup instruction indent1\">
				Once you have created this group, click 'Add Users to Group...' from the Groups page.
			</p>			
   			<p class= \"$view\">
   				yrGATE users can be assigned to one or more <b>Groups</b> that share common curation resources. On this page you can <b>create Groups</b>, add <b>Users</b>, and edit <b>Group Membership</b> (assign Group Admins; remove Members from Group). See also <a href=\"/admin/users.php\">Manage User Accounts</a>
   			</p>
   			<p class= \"$view\">
   				<b>Only Active users are shown except in Edit mode </b>.
   			</p>
   				<p class=\"$view instruction indent1\">Select an action from the choices below: 
   			</p>
			<h2 class=\"$adduser indent1 bottommargin1\">
			Add Users to Group:
			</h2>
			</td>
   	</tr>
	<tr>
   		<td width=\"20%\" align = \"left\">
   		
   		</td>
		<td align=\"right\" valign=\"bottom\">
			<form method=\"post\" action=\"/admin/groups.php\" name=\"add_group_on\" class=\"styled\">
				<input id=\"creategrp\" class=\"submit $view\" type=\"submit\" name=\"mode\" value=\"1. Create New Group...\" />
				<input type=\"hidden\" name=\"mode\" value=\"AddGroup\" />
			</form>
		</td>
		<td width=\"20%\" align = \"right\" >
		</td>
		<td align=\"right\">
			<form method=\"post\" action=\"/admin/groups.php\" name=\"add_users_on\" class=\"styled\">
				<select class=\"submit $view normalfont\" name=\"group\">$groups_dropdown</select><br />
				<input id=\"adduser\" class=\"submit $view\" type=\"submit\" name=\"mode\" value=\"2. Add Users to Group...\" />
			    <input type=\"hidden\" name=\"mode\" value=\"AddUser\" />
            </form>
		</td>
	    <td width=\"20%\" align=\"right\">
		</td>
		<td align = \"right\" valign=\"bottom\">
			<form method=\"post\" action=\"/admin/groups.php\" name=\"edit_status_on\" class=\"styled\">
				<input id=\"editacct\" class=\"submit $view\" type=\"submit\" name=\"mode\" value=\"3. Edit Group Membership...\" />
				<input type=\"hidden\" name=\"mode\" value=\"EditUser\" />
			</form>
		</td>
		<td width=\"20%\" align = \"right\">
			<form method=\"post\" action=\"/admin/groups.php\" name=\"view_status_on\" class=\"styled\">
				<input id=\"cancel\" class=\"$cancel submit\" type=\"submit\" value=\"&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Cancel&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;\" />
				<input type=\"hidden\" name=\"mode\" value=\"Cancel\" />
			</form>
		</td>
	</tr>
	</tbody>
</table>
";
#Action Button Display and Table Headers
$display_block .= "

<form name=\"form1\" method=\"post\" action=\"/admin/update_groups.php\" class=\"styled\">

<table style=\"font-size:12px\" width=\"92%\">
			<tr>
				<td class=\"$adduser indent2\" width=\"90%\">
					<p class=\"instruction\">Select Username and Account Type (USER or ADMIN) </p>
					<p class=\"instruction\">If adding more users to this Group, click 'Insert & Next'; or, click 'Insert & Done'</p>
				</td>
				<td>
					<input id=\"update\"  class=\"$edituser submit\" type=\"submit\" name=\"edit_action\" value=\"Update Accounts\">
					<input id=\"count\"  class=\"$edituser submit\" type=\"hidden\" name=\"count\" value=\"$count\">
				</td>
				<td align=\"right\">
					<input id=\"insert_group\"  class=\"$addgroup submit\" type=\"submit\" name=\"group_action\" value=\"Create Group\">
				</td>
				<td>
                    <input id=\"insertuser_repeat\"  class=\"$adduser submit\" type=\"submit\" name=\"user_action_repeat\" value=\"Insert &amp; Next\">
					<input id=\"insertuser\"  class=\"$adduser submit\" type=\"submit\" name=\"user_action\" value=\"Insert &amp; Done\">
				</td>
			</tr>
</table>
<table class=\"featuretable bottommargin1 topmargin1\" style=\"font-size:12px\" cellpadding=\"6\">
		<thead align=\"center\">
						<tr class=\"$viewedit\">
							<th class=\"reverse_1\">User Group</th>
							<th class=\"reverse_1\">GDB </th>
							<th class=\"reverse_1\">User</th>
							<th class=\"reverse_1\">Email</th>
							<th class=\"reverse_1\" style=\"width:250px\">
							Group Member Type 
							<img id='admin_group_account' title='Help' class='help-button nudge1' src='/XGDB/images/help-icon.png' alt='?' />
							</th>
						</tr>
		
		</thead>
		<tbody>
";
# Table Body Rows for View mode

				$user_check=array();
				$admin_check=array();
				$inactive_check=array();
				$user_style=array();
				$admin_style=array();
				$inactive_style=array();
				
				$i=0; //cycle through all records
				while ($row = mysql_fetch_array($result)) {
					$uid=$row["uid"];
					$group=$row["private_group"];
					$user=$row["user"];
					$status=$row["status"];
					$account_type=$row["account_type"];
					$gdb=$row["gdb"];
					$email=$row["email"];
					//determine which radio button should be checked for each user based on current value
 					$user_check[$i] = ($status == "USER")? $checked:"";
 					$admin_check[$i] = ($status == "ADMIN")? $checked:"";
 					$inactive_check[$i] = ($status == "REMOVE")? $checked:"";
 					$user_style[$i] = ($status == "USER")? 'vltblue':"";
 					$admin_style[$i] = ($status == "ADMIN")? 'vltgreen':"";
 					$inactive_style[$i] = ($status == "REMOVE")? 'vltred':"";
 					
 					$status_class[$i] ='';
 					$status_class[$i] = ($account_type == "INACTIVE")? "gray grayfont":"";
######### ''Edit User Accounts' data fields ########

 			$display_block .=
 				"<tr id=\"uid_$i\" align=\"right\" class=\"$viewedit $status_class[$i]\">
					<td align=\"left\" class=\"bold\">
						$group
					</td>

					<td align=\"center\">
						$gdb
					</td>
					<td align=\"left\">
						$user

					<td align=\"left\">
						$email						
					</td>
					<td align=\"center\" class=\"$view $user_style[$i] $admin_style[$i] $inactive_style[$i]\" style=\"width:250px\">
						$status
					</td>		
					<td class=\"$edituser\"  align = \"center\" style=\"width:250px\">
						&nbsp;
						<input title =\"user\" style=\"cursor:pointer\" class=\"normalfont\" type=\"radio\"  id=\"user\" $user_check[$i]  name=\"status{$i}\" value=\"USER\" /> <span class=\"$user_style[$i]\"> USER &nbsp; &nbsp;</span>
						<input title =\"admin\" style=\"cursor:pointer\" class=\"normalfont\" type=\"radio\" id=\"admin\" $admin_check[$i]  name=\"status{$i}\" value=\"ADMIN\"  /> <span class=\"$admin_style[$i]\"> ADMIN  &nbsp; &nbsp;</span>
						<input  title =\"delete\" style=\"cursor:pointer\" class=\"normalfont\" type=\"radio\"  id=\"delete\" $inactive_check[$i]  name=\"status{$i}\" value=\"REMOVE\" /> <span class=\"$inactive_style[$i]\"> <span style=\"color:red\">REMOVE</span></span>
						<input title =\"uid\" type=\"hidden\"  id=\"uid\"  name=\"uid{$i}\" value=\"$uid\" />
					</td>
			</tr>";
$i=$i+1;

}

########## 'Add User to Group' data fields ########

$display_block .= 
"
<tr class=\"$adduser\">
	<td>
		<input type=\"hidden\" name=\"adduser_group\" value=\"$selected_group\" /> <span class=\"bigfont\">Selected Group: <b>$selected_group</b></span> 
		<span class=\"heading\">$added_user_text</span>
	</td>
	<td><select class=\"largerfont\"  name=\"adduser\">$user_dropdown</select></td>
	<td class=\"$adduser\"  align = \"center\" style=\"width:250px\">&nbsp;
		<input title =\"user\" style=\"cursor:pointer\" class=\"largerfont\" type=\"radio\"  id=\"user\"  checked=\"checked\"  name=\"adduser_status\" value=\"USER\" /> <span class=\"$user_style[$i]\"> USER &nbsp; &nbsp;</span>
		<input title =\"admin\" style=\"cursor:pointer\" class=\"largerfont\" type=\"radio\" id=\"admin\"   name=\"adduser_status\" value=\"ADMIN\"  /> <span class=\"$admin_style[$i]\"> ADMIN  &nbsp; &nbsp;</span>
	</td>
</thr>
";

########## 'Create New Group' data fields ########

$display_block .=
"
<tr class=\"$addgroup\">
	<td colspan=\"3\" style=\"padding:20px\"><span class=\"normalfont bold\">Current Groups:</span><br /><br />
		<ul class=\"featurelist indent1\">
			$grouplist
		</ul>
	</td>
</tr>

<tr class=\"$addgroup\" >
	<td style=\"padding:20px\">
		 <span class=\"bold largerfont\">New Group: <span class=\"heading smallerfont\"> &lt; 20 char; spaces OK</span> </span><br /><br />
	 	<input class=\"largerfont indent1\"  style=\"text-align:left\" type=\"text\" name=\"add_group\" size=\"32\" value=\"-enter group name-\" onfocus=\"this.value=''\" />
	</td>
	<td style=\"padding:20px\"><span class=\"bold largerfont\">Select GDB for this Group &nbsp; </span><br /><br />
			<select class=\"indent1 largerfont\" name=\"addgroup_gdb\">$gdb_dropdown</select>
		</td>
	<td style=\"padding:20px\"><span class=\"bold largerfont\">Group Administrator:<br /> <br />
		<select name=\"addgroup_user\" class=\"largerfont\">$user_dropdown</select></span>
	</td>
</tr>
";

$display_block .= "
		</tbody>
	</table>
</form>

";

?>
	<div id="leftcolumncontainer">
		<div class="minicolumnleft">
			<?php include_once("/xGDBvm/admin/leftmenu.inc.php"); ?>
		</div>
	</div>
	<div id="maincontentscontainer" class="threecolumn overflow configure">
			<div id="maincontentsfull" class="configure">
			
			<h1 class="admin bottommargin1"><img src="/XGDB/images/user.png" alt="" /> Manage User Groups <img id='admin_user_groups' title='Search Help' class='help-button' src='/XGDB/images/help-icon.png' alt='?' /> <span class="heading">No yrGATE user accounts? <a href="/yrGATE/GDB001/userRegister.pl">Create one now</a></span></h1>


<?php 
	echo $display_block;
?>

	  </div>
					</div><!--end maincontentsfull-->
				</div><!--end maincontentscontainer-->
				<?php include($XGDB_FOOTER); ?>
			</div><!--end innercontainer-->
		</div><!--end outercontainer-->
	</body>
</html>
