<?php
error_reporting(E_ALL & ~E_NOTICE); //disable undeclared variable error

//see http://www.phpeasystep.com/mysql/10.html

	$global_DB= 'yrgate'; //MySQL
	$PageTitle = 'xGDBvm Users';
	$pgdbmenu = 'Manage';
	$submenu1 = 'Admin-Home';
	$submenu2 = 'Admin-Users';
	$leftmenu='Admin-Users';
	include('sitedef.php');
	include($XGDB_HEADER);
	$all_check="checked";
 	include_once('/xGDBvm/XGDB/phplib/db.inc.php'); #reads MySQL password from /xGDBvm/admin/dbpass
	$dbpass=dbpass();
	$db = mysql_connect("localhost", "gdbuser", $dbpass);
	if(!$db)
		{
			echo "Error: Could not connect to database!";
			exit;
		}
	mysql_select_db("$global_DB");
	$error = $_GET['error'];
	

### Set default display by assigning css class to show/hide respective td elements

	$edit = 'display_off'; //default - don't show edit data features when page loads
	$view = 'display_on_block'; //defaults - do show view data features when page loads
	$cancel = 'display_off'; // default - don't show cancel button when page loads

## radio button values that are checked or selected, either by default or based on current database value.###

	$checked="checked=\"checked\""; #for type =radio button

### Modify display based on post values: the following variables set a td css class corresponding to either display:block or display:hidden

$Query="SELECT uid, user_name, email, fullname, phone, account_type from $global_DB.users where account_type != 'INACTIVE' order by account_type ASC, uid ASC";


if(mysql_real_escape_string($_POST['mode']) == 'Cancel' || mysql_real_escape_string($_POST['mode']) == 'View'  ){ // Enter View mode (Default).

	$edit = 'display_off';
	$view = 'display_on_block';
	$cancel = 'display_off';

	}
if(mysql_real_escape_string($_POST['mode']) == 'Edit'){ // Enter edit mode. Show all users including INACTIVE
	$edit = 'display_on_block';
	$view = 'display_off';
	$cancel = 'display_on';
$Query="SELECT uid, user_name, email, fullname, phone, account_type from $global_DB.users order by account_type ASC, uid ASC";

	}

if(mysql_real_escape_string($_POST['mode']) == 'Save Changes'){ // Leave edit mode.
	$edit = 'display_off';
	$view = 'display_on_block';
	$cancel = 'display_off';
	}



#build result arrays and store in session
$get_records = $Query;
$check_get_records = mysql_query($get_records);
$result = $check_get_records;
#Count table rows
$count=mysql_num_rows($result);

$display_block ="
<table style=\"font-size:12px\" width=\"92%\">
	<tr>
		<td colspan=\"7\" align = \"left\" class=\"normalfont\">
			<p class=\"$edit instruction\">Click to select a different <b>Account Type</b>, then click 'Update', or 'Cancel'.</p>
   			<p class= \"$view \"> Anyone can <a class=\"help_style\" href=\"/XGDB/help/yrgate.php/#yrgate_registration_help\">register</a> for a yrGATE <a class=\"help_style\" href=\"/XGDB/help/community_central.php/#comm_central_manage\">user account</a> giving them access to gene structure annotation (users listed below). You can promote a user to <b>ADMIN</b> status or make an account <b>INACTIVE</b>. See also <a href=\"/admin/groups.php\">Manage User Groups</a>.</p>
   			<p class= \"$view topmargin1 instruction\"> <b>Only active users shown.</b> Click button at right to edit Account Type, including Inactives.</p>
   		</td>
		<td colspan=\"3\" align = \"right\">
			<form method=\"post\" action=\"/admin/users.php\" name=\"edit_status_on\" class=\"styled\">
				<input id=\"edit\" class=\"submit $view\" type=\"submit\" name=\"mode\" value=\"Edit Account Type...\" />
				<input type=\"hidden\" name=\"mode\" value=\"Edit\" />
			</form>
		</td>
		<td align = \"right\">
			<form method=\"post\" action=\"/admin/users.php\" name=\"view_status_on\" class=\"styled\">
				<input id=\"cancel\" class=\"$edit submit\" type=\"submit\" value=\"&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Cancel&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;\" />
				<input type=\"hidden\" name=\"mode\" value=\"Cancel\" />
			</form>
		</td>
  </tr>
	<tr>
		<td>
		   	<p class=\"$view instruction\">
		   	    No accounts? <a href=\"/yrGATE/GDB001/userRegister.pl\">Create one now</a>
		   	</p>
		</td>
	</tr>
</table>
";

$display_block .= "

<form name=\"form1\" method=\"post\" action=\"/admin/update_users.php\" class=\"styled\">

<table style=\"font-size:12px\" width=\"92%\">
			<tr>
				<td  width=\"92%\">

				</td>

				<td>
					<input id=\"update\"  class=\"$edit submit\" type=\"submit\" name=\"update\" value=\"&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Update&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;\" />
					<input id=\"count\"  class=\"$edit submit\" type=\"hidden\" name=\"count\" value=\"$count\" />
					<input id=\"update_action\"  class=\"$edit submit\" type=\"hidden\" name=\"action\" value=\"Update\" />
				</td>
			</tr>
</table>
<table class=\"featuretable bottommargin1 topmargin1\" style=\"font-size:12px\" cellpadding=\"6\">
		<thead align=\"center\">
						<tr>
							<th class=\"reverse_1\">UID</th>
							<th class=\"reverse_1\">Username</th>
							<th class=\"reverse_1\">Full Name</th>
							<th class=\"reverse_1\">Email </th>
							<th class=\"reverse_1\">Phone</th>
							<th  class=\"reverse_1\" colspan=\"2\">Annotations Submitted</th>
							<th  class=\"reverse_1\" colspan=\"2\">Annotations Accepted</th>
							<th  class=\"reverse_1\" style=\"width:250px\">
								Account Type  
								<img id='admin_users_account' title='Help' class='help-button nudge1' src='/XGDB/images/help-icon.png' alt='?' />
							</th>
						</tr>
		
		</thead>
		<tbody>
";


				$user_check=array();
				$admin_check=array();
				$inactive_check=array();
				$user_style=array();
				$admin_style=array();
				$inactive_style=array();
				
				$i=0; //cycle through all records
				while ($row = mysql_fetch_array($result)) {
					$id=$rows["uid"];// create an array of uids starting with 0
					$uid=$row["uid"];
					$user_name=$row["user_name"];
					$fullname=$row["fullname"];
					$email=$row["email"];
					$phone=$row["phone"];
					$account_type=$row["account_type"];
					//determine which radio button should be checked for each user based on current value
 					$user_check[$i] = ($account_type == "USER")? $checked:"";
 					$admin_check[$i] = ($account_type == "ADMIN")? $checked:"";
 					$inactive_check[$i] = ($account_type == "INACTIVE")? $checked:"";
 					$user_style[$i] = ($account_type == "USER")? vltblue:"";
 					$admin_style[$i] = ($account_type == "ADMIN")? vltgreen:"";
 					$inactive_style[$i] = ($account_type == "INACTIVE")? vltred:"";
 					
 					$status_class[$i] = ($account_type == "INACTIVE")? "gray grayfont":"";

			# count annotations per user
			
			 # cycle through all Current GDB and count the user's annotations for each, total out the other end
			 		$submitted_total=0;
			 		$submitted_GDB="";
			 		$accepted_total=0;
			 		$accepted_GDB="";
					$Query2="SELECT ID from Genomes.xGDB_Log WHERE Status='Current'"; #
					$get_records2 = $Query2;
					$check_get_records2 = mysql_query($get_records2);
					$result2 = $check_get_records2;
					while($GDBarray=mysql_fetch_array($result2, MYSQL_NUM))
					{
						$r=$GDBarray[0];
						$k="00".$r;
						$id=substr($k, -3); 
						$DBid="GDB".$id; # recreate the GDB ID

					# ACCEPTED annotations
						$Query3="SELECT uid from $DBid.user_gene_annotation WHERE USERid='$user_name' and status='ACCEPTED'"; # we need total annotations for each user for all GDB
						$get_records3 = $Query3;
						$check_get_records3 = mysql_query($get_records3);
						$result3 = $check_get_records3;
						$count3=mysql_num_rows($result3);
						if($count3 !="")
						{
							$accepted_total = $accepted_total + $count3;
							if($accepted_GDB =="") #No annos yet accumulated; this is the first one
							{
							$accepted_GDB="<a href=\"/yrGATE/$DBid/CommunityCentral.pl?search_field=annotator&search_term=$user_name\">$DBid</a>";
							}else
							{
							$accepted_GDB = $accepted_GDB."<br /> <a href=\"/yrGATE/$DBid/CommunityCentral.pl?search_field=annotator&search_term=$user_name\">$DBid</a>";
							}
						}



					# SUBMITTED annotations
						$Query4="SELECT uid from $DBid.user_gene_annotation WHERE USERid='$user_name' and (status='ACCEPTED' or status='SUBMITTED_FOR_REVIEW')"; # we need total annotations for each user for all GDB
						$get_records4 = $Query4;
						$check_get_records4 = mysql_query($get_records4);
						$result4 = $check_get_records4;
						$count4=mysql_num_rows($result4);
						if($count4 !="")
						{
							$submitted_total = $submitted_total + $count4;
							if($submitted_GDB =="") #No annos yet accumulated; this is the first one
							{
							$submitted_GDB=$DBid;
							}else
							{
							$submitted_GDB = $submitted_GDB."<br />".$DBid;
							}
						}

					}
 			$display_block .= "	

			 <tr align=\"right\" class=\"$status_class[$i]\">
					<td align=\"right\">
						$uid						
					</td>
					<td align=\"left\"  class=\"reverse bold\" >
						$user_name
					</td>

					<td align=\"left\">
						$fullname
					</td>
					<td align=\"left\">
						$email
					</td>
						<td align=\"center\">
						$phone
					</td>
					<td align=\"center\">
						$submitted_total
					</td>
					<td align=\"center\">
						$submitted_GDB			
					</td>					
					<td align=\"center\">
						$accepted_total
					</td>
					<td align=\"center\">
						$accepted_GDB			
					</td>					
					<td align=\"center\" class=\"$view $user_style[$i] $admin_style[$i] $inactive_style[$i]\" style=\"width:auto;  border:none\">
						$account_type
					</td>		
					<td class=\"$edit\"  align = \"center\" style=\"width:250px; border:none\">
						&nbsp;
						<input title =\"user\" style=\"cursor:pointer\" class=\"normalfont\" type=\"radio\"  id=\"user\" $user_check[$i]  name=\"account_type{$i}\" value=\"USER\" /> <span class=\"$user_style[$i]\"> USER &nbsp; &nbsp;</span>
						<input title =\"admin\" style=\"cursor:pointer\" class=\"normalfont\" type=\"radio\" id=\"admin\" $admin_check[$i]  name=\"account_type{$i}\" value=\"ADMIN\"  /> <span class=\"$admin_style[$i]\"> ADMIN  &nbsp; &nbsp;</span>
						<input  title =\"delete\" style=\"cursor:pointer\" class=\"normalfont\" type=\"radio\"  id=\"delete\" $inactive_check[$i]  name=\"account_type{$i}\" value=\"INACTIVE\" /> <span class=\"$inactive_style[$i]\"> INACTIVE  &nbsp; &nbsp;</span>
						<input title =\"uid\" type=\"hidden\"  id=\"uid\"  name=\"uid{$i}\" value=\"$uid\" />
					</td>
			</tr>";
$i=$i+1;

}

$display_block .= "
		</tbody>
	</table>
</form>

";

// Check if button name "Submit" is active, do this


#function update_user(){
#if($Submit){
#for($i=0;$i<$count;$i++){
#$sql1="UPDATE $global_DB.users SET account_type='account_type[$i]' WHERE uid='$id[$i]'";
#$result1=mysql_query($sql1);
#}
#}
#echo $sql1;

#if($result1){
#header("location:users.php");
#echo $sql1;
#}
#mysql_close();

?>
	<div id="leftcolumncontainer">
		<div class="minicolumnleft">
			<?php include_once("/xGDBvm/admin/leftmenu.inc.php"); ?>
		</div>
	</div>
	<div id="maincontentscontainer" class="twocolumn overflow configure">
		<div id="maincontentsfull" class="configure">
			<h1 class="admin  bottommargin1"><img src="/XGDB/images/user.png" alt="" /> Manage Users <img id='admin_users' title='Search Help' class='help-button' src='/XGDB/images/help-icon.png' alt='?' /></h1>


<?php 
	echo $display_block;
?>

	                </div>
	                
						  <div style="clear:both; float:right">
							<a href="http://validator.w3.org/check?uri=referer"><img
							  src="http://www.w3.org/Icons/valid-xhtml10" alt="Valid XHTML 1.0 Transitional" height="15" width="44" /></a>
						  </div>						

					</div><!--end maincontentsfull-->
				</div><!--end maincontentscontainer-->
				<?php include($XGDB_FOOTER); ?>
			</div><!--end innercontainer-->
		</div><!--end outercontainer-->
	</body>
</html>
