<?php
	$global_DB= 'Admin';
	$PageTitle = 'xGDBvm Admin';
	$pgdbmenu = 'Manage';
	$submenu = 'Admin';
	$leftmenu='Admin-View';
	include('sitedef.php');
	include($XGDB_HEADER);

	$db = mysql_connect("localhost", "gdbuser", "xgdb");
	if(!$db)
	{
		echo "Error: Could not connect to database!";
		exit;
	}
	mysql_select_db("$global_DB");
	$error = $_GET['error'];


	echo "<script language=\"javascript\" type=\"text/javascript\">
function confirmAndUpdate(){
	var agree=confirm(\"Are you sure you wish to update?\");
	if(agree)
		return true;
	else
		return false;
}
</script>
";

### Set default display by assigning css class to show/hide respective td elements

	$edit = 'display_off'; //default - don't show edit data features when page loads
	$view = 'display_on'; //defaults - do show view data features when page loads
	$cancel = 'display_off'; // default - don't show cancel button when page loads
	$nav = 'display_on'; //defaults - show nav buttons (Select, next/prv)  when page loads


### Modify display based on post values

if(mysql_real_escape_string($_POST['mode']) == 'Cancel' || mysql_real_escape_string($_POST['mode']) == 'View'  ){ // Enter View mode (Default). No create/drop buttons show.

	$edit = 'display_off';
	$view = 'display_on';
	$create = 'display_off';
	$nav = 'display_on';
	$cancel = 'display_off';
    $required = ''; 
	}
if(mysql_real_escape_string($_POST['mode'] == 'Edit')){ // Enter edit mode. No nav, no create, no locked
	$edit = 'display_on';
	$view = 'display_off';
	$nav = 'display_off';
	$cancel = 'display_off';
    $required = 'required'; // this styles the required fields on edit
	}



### Select New id



	$get_data = "select * from $global_DB.admin";
	

	$check_get_data = mysql_query($get_data);


	while ($data = mysql_fetch_array($check_get_data)){
		$current_class=""; //assigned below
####### General Info ########
		$ID = $id; #post or get result.
		$Username = $data["user_name"];
		$Fullname=$data["fullname"];
		$Email=$data["email"];
		$Phone=$data["phone"];
		$Admin_Type=$data["admin_type"];

}

$display_block .= "
<div id=\"view_header\" style=\"height:100px\">
<table style=\"font-size:12px\" class=\"bottommargin2\" width=\"100%\">

	<tr>
		<td align=\"left\" width=\"54%\">
			<h1 class=\"admin\">xGDBvm Admin
				<span class=\"warning  largerfont $edit\"> 
					(edit)
				</span>
			</h1>
		</td>
        </tr>
</table>

<table  style=\"margin-top:-12px\"><!-- to adjust gap in edit mode-->
	<tr>
		<td align=\"left\" width=\"100%\">
						<span class=\"$nav normalfont $database_message_style\">$database_message</span> 
		</td>
	</tr>
</table>
<table style=\"font-size:12px\" width=\"100%\">

	<tr>
		<td width=\"60%\" align = \"left\" class=\"normalfont\">
						<span class=\"$view largerfont	\"><b>Admin Settings: </b></span> <span class=\"$locked $nav\">To modify, click 'Edit...'.</span>
						<span class=\"$edit\">Edit values, enter Admin password and click 'Save Changes', or 'Cancel'. Note required fields (<span class=\"required\"></span>). <br />'Reset' restores original entries; 'Clear' blanks all entries.</span>
			</td><td 
			align=\"right\">
			<form method=\"post\" action=\"/admin/view.php?id=$ID\" name=\"edit_status_on\">
				<input class=\"$locked $nav \"type=\"submit\" name=\"mode\" value=\"Edit...\" />
				<input type=\"hidden\" name=\"mode\" value=\"Edit\" />
			</form>
		</td>	
	
		<td width=\"20%\" align = \"left\">
			<form method=\"post\" action=\"/admin/view.php?id=$ID\" name=\"view_status_on\">
				<input style=\"color:#999\" class=\"$edit\" type=\"submit\" value=\"&nbsp;&nbsp;Cancel&nbsp;&nbsp;\" />
				<input type=\"hidden\" name=\"mode\" value=\"Cancel\" />
			</form>
			
		</td>
		<td width=\"20%\" align = \"right\">
		
			<form method=\"post\" name=\"clear_data\" action=\"/admin/view.php\">
				<input class=\"$edit\" style=\"color:#999\"  type=\"submit\" value=\"Clear\"  />
				<input type=\"hidden\" name=\"clear\" value=\"Clear\" />
				<input type=\"hidden\" name=\"mode\" value=\"Edit\" />
				<input type=\"hidden\" name=\"id\" value=\"$ID\" />
			</form>
		</td>
  </tr>
</table>
</div>
	<form method=\"post\" name=\"record_data\" action=\"/admin/view.php\">
		<table width=\"100%\">
			<tr width=\"100%\">
				<td width=\"66%\" align=\"right\">
					<span  class=\"$edit normalfont\"> Password: &nbsp;</span>
					<input class=\"$edit\" type=\"password\" size=\"20\" name=\"password\" />
					<input class=\"$edit\" type=\"submit\" name=\"submit\" value=\"Save Changes\" />
				</td>
				<td width=\"33%\"  align=\"right\">
					<input class=\"$edit\" style=\"color:#999\"  type=\"reset\" value=\"Reset\" name=\"reset\" />
				</td>
			</tr>
		</table>

<fieldset  class=\"bottommargin1 topmargin1 xgdb_log\">
<legend class=\"largerfont\"> &nbsp;<b>General Info:</b></legend>
<table class=\"xgdb_log $font_display\" border=\"0\" style=\"font-size:12px\" width=\"95%\" >
	<colgroup>
		<col width =\"25%\" style=\"background-color: #DDD\" />
		<col width =\"75%\" />
	</colgroup>
	<tbody>
		<tr style=\"height: 20px\">
			<td class=\"$required no_edit\" >Username:</td>
			<td class=\"$view bold\">$Username</td>
			<td class=\"$edit\">
				<input name=\"DBname\" size=\"35\" value=\"$DBname\" />
			</td>
		</tr>

		<tr style=\"height: 20px\">
			<td class=\"$required\" >Full Name: </td>
			<td class=\"$view bold\">$Fullname</td>
			<td class=\"$edit\">
				<input name=\"Fullname\" size=\"35\" value=\"$Fullname\" />
			</td>
		</tr>
		<tr style=\"height: 20px\">
			<td>Password: </td>
			<td class=\"$view bold\"></td>
			<td class=\"$edit\">
				<input type=\"password\" size=\"20\" name=\"password\" />
			</td>
		</tr>
	</tbody>
</table>
</fieldset>
</form>
";
	?>
	
		<div id="leftcolumncontainer">
			<div class="minicolumnleft">
			<?php include_once("/xGDBvm/admin/leftmenu.inc.php"); ?>
			</div>
		</div>
			<div id="maincontentscontainer" class="twocolumn">
				<div id="maincontentsfull">
				<?php
#	echo "<span class=\"heading\" >".$get_data." | ".$get_est_tot." | ".$get_est_algn." </span>";

					echo $display_block;
				?>
				<p />
			</div><!--end maincontentsfull-->
			
			</div><!--end maincontentscontainer-->
			<div id="rightcolumncontainer">
				</div><!--end rightcolumncontainer-->
			<?php include($XGDB_FOOTER); ?>
		</div></div></div>
	</body>
</html>
