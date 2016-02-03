<?php
	$global_DB= 'yrgate';
	$PageTitle = 'yrGATE Set Up';
	$pgdbmenu = 'Manage';
	$submenu1 = 'Admin-Home';
	$submenu2 = 'Admin-Email';
	$leftmenu='Admin-Email';
	include('sitedef.php');
	include($XGDB_HEADER);
    $Create_Date = date("m-d-Y");
 	include_once('/xGDBvm/XGDB/phplib/db.inc.php'); #reads MySQL password from /xGDBvm/admin/dbpass
	$dbpass=dbpass();
	$db = mysql_connect("localhost", "gdbuser", $dbpass);
	if(!$db)
		{
			echo "Error: Could not connect to $test database!";
			exit;
		}

date_default_timezone_set("$TIMEZONE"); // from sitedef.php

## yrGATE admin email added?

	$yrgate_query="SELECT uid, admin_email, admin_email_date from Admin.admin where admin_email !='' order by uid ASC limit 0,1";
	$get_yrgate_records = $yrgate_query;
	$check_get_yrgate_records = mysql_query($get_yrgate_records);
	$yrgate_result = $check_get_yrgate_records;
	$array=mysql_fetch_array($yrgate_result);
	$admin_email=$array['admin_email'];
	$yrgate_date=$array['admin_email_date'];
	$admin_email_message=($admin_email=="")?"":"<div id=\"updated\"><p class=\"checked indent2\">Admin email was changed to $admin_email on $yrgate_date </p></div>";
	$type=($admin_email=="")?"insert":"update";

$display_block = "
<table width=\"100%\">
	<tr>
		<td align=\"left\" width=\"50%\">
			<h1 class=\"admin bottommargin1\"> <img src=\"/XGDB/images/user.png\" alt=\"\" /> Set Up Admin Email</h1>
		</td>
	</tr>
</table>

<fieldset  class=\"bottommargin1 xgdb_log\">
<legend class=\"largerfont\"> &nbsp;<b> Admin Email (global)</b></legend>

<form method=\"post\" name=\"setup\" action=\"/admin/email_exec.php\" >
	<input type=\"hidden\" name=\"action\" value=\"setup\"/>
	<input type=\"hidden\" name=\"type\" value=\"$type\"/>

	<table style=\"font-size:12px\" class=\"bottommargin1\" width=\"100%\">
		<tr>
			<td>
				<p>The email address below will receive notification of system-wide events  such as completion of external HPC jobs (NOT the same as yrGATE ADMIN)
					<img id='admin_email' title='Search Help' class='help-button' src='/XGDB/images/help-icon.png' alt='?' /> 
				</p>
			
			<p><span class=\"tip_style\"><b>Enter email address(es) separated by commas,</b> then click <b>Update</b> button at right.</span></p>
				$admin_email_message
			</td>
			<td align=\"right\">
				<input type=\"submit\" name=\"submit\" id=\"submit_button\" value=\" &nbsp;&nbsp;Update&nbsp;&nbsp; \"/>
			</td>
	</tr>
</table>

<table class=\"xgdb_log\" border=\"0\" style=\"font-size:12px\" width=\"95%\" >
	<colgroup>
		<col width =\"20%\" />
		<col width =\"20%\" />
		<col width =\"60%\" />
	</colgroup>
	<tbody>
			<tr style=\"height: 20px\">
				<td class=\"required\" >
					Admin Email
				</td>
				<td>
					<input name=\"admin_email\" size=\"50\" value=\"$admin_email\" /> 
				</td>
			</tr>		
	</tbody>
</table>
</form>
</fieldset>


";


	?>
	
		<div id="leftcolumncontainer">
			<div class="minicolumnleft">
			<?php include_once("/xGDBvm/admin/leftmenu.inc.php"); ?>
			</div>
		</div>
			<div id="maincontentscontainer" class="twocolumn admin">
				<div id="maincontentsfull">
				<?php
					echo $display_block;
				?>
				<p />
			</div><!--end maincontentsfull-->
						  <div style="clear:both; float:right">
							<a href="http://validator.w3.org/check?uri=referer"><img
							  src="http://www.w3.org/Icons/valid-xhtml10" alt="Valid XHTML 1.0 Transitional" height="15" width="44" /></a>
						  </div>						
			</div><!--end maincontentscontainer-->
			<div id="rightcolumncontainer">
				</div><!--end rightcolumncontainer-->
			<?php include($XGDB_FOOTER); ?>
		</div></div></div>
	</body>
</html>
