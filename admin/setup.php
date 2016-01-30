<?php
$global_DB= 'yrgate';
$PageTitle = 'xGDBvm Set Up';
$pgdbmenu = 'Manage';
$submenu1 = 'Admin-Home';
$submenu2 = 'Admin-Setup';
$leftmenu='Admin-Setup';
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
$dbpass_message="";
$admin_message="";

date_default_timezone_set("$TIMEZONE"); // from sitedef.php

## Get password flags

$adminpassword_file='/xGDBvm/admin/adminpassword';
$xgdbpassword_file='/xGDBvm/admin/xgdbpassword';
$adminpass=file_exists($adminpassword_file)?true:false;
$xgdbpass=file_exists($xgdbpassword_file)?true:false;



## Set messages
	$adminpass_message=($adminpass==true)
		?
		"<p class=\"locked indent2\">The 'Manage' sections of this VM are password-protected (you must log in as 'admin' to access these pages)</p>"
		:
		"<p class=\"alertnotice warning indent2\"> No admin password is in effect (anyone with access can modify your data!)</p>";

	$xgdbpass_message=($xgdbpass==true)
		?
		"<p class=\"locked indent2\">This VM is password-protected (you must log in as 'user' to access any pages)</p>"
		:
		"<p class=\"alertnotice warning indent2 \">No global website password is in effect (anyone can access this website if it is online)</p>";

	$dbpass_message=(file_get_contents('/xGDBvm/admin/dbpass') == 'xgdb')
		?
		"<p class=\"alertnotice warning indent2 \">The default MySQL password has not been changed</p>"
		:
		"<p class=\"locked indent2\">The MySQL password has been updated</p>";
 
## input box color if passwords set		
	$adminpass_style=($adminpass=="" || $adminpass=="Removed")?"":"gray";
	$dbpass_style=($dbpass=="")?"":"gray";
	$xgdbpass_style=($xgdbpass=="" || $xgdbpass=="Removed")?"":"gray";

## Remove button display Remove

	$adminpass_remove=($adminpass=="")?"display_off":"";
	$xgdbpass_remove=($xgdbpass=="")?"display_off":"";


$display_block = "
<table width=\"100%\">
	<tr>
		<td align=\"left\" width=\"50%\">
			<h1 class=\"admin bottommargin1\"><img src=\"/XGDB/images/user.png\" alt=\"\" /> Set Up Passwords</h1>
		</td>
		<td align=\"right\" width=\"50%\">
		</td>
	</tr>
</table>
<div id=\"password\" style=\"padding:20px\">
<fieldset class=\"bottommargin1 xgdb_log\" style=\"padding: 20px 0 20px 40px\">
<legend class=\"setup\"> &nbsp;<b>A. Password-protect your VM</b> <span class=\"heading\">(choose option 1 or 2; NOT both)</span></legend>


<fieldset  class=\"bottommargin1 xgdb_log\">
<legend class=\"setup\"> &nbsp;Option 1. Require password for Management pages only <img id='admin_adminpass' title='Adminpass Help' class='help-button nudge2' src='/XGDB/images/help-icon.png' alt='?' /></legend>
	<form method=\"post\" name=\"setup\" action=\"/admin/adminpass_exec.php\" >
	
	<p>Management sections (<i>Admin</i>, <i>Config/Create</i>, and <i>Remote Jobs </i>) are accessed under the <i>Manage</i> menu item. <b>Password-protecting these directories is recommended if your VM is accessible over the internet</b>. Otherwise anyone could modify or delete your output data!
	<br /><br />
	<span class=\"alertnotice\">NOTE: Do not add an Admin-level password if you have already password-protected the whole website (see below), as the system will not work will with 2 levels of password protection</span>
</p>
	
		<table style=\"font-size:12px\" class=\"bottommargin1\" width=\"100%\">
			<tr>
                <td>
                    <p class=\"instruction\">
	                    To restrict access to admin/config/jobs pages,<span class=\"warning\">first <b>remove</b> any VM-level password (see below), as the system will not work will with 2 levels of password protection</span><br />
	                     Next enter a password below, then click <b>Update</b> button at right.
                        <br />You will then be required to log in as username=<b>'admin'</b> with your new password.
                        <br />You can change password whenever you like, or remove password protection by clicking <b>'Remove'</b>
                    </p>
                     $adminpass_message
			    </td>
					<td align=\"right\">
						<input type=\"submit\" name=\"submit\" id=\"submit_adminpass\" value=\" &nbsp;&nbsp;Update&nbsp;&nbsp; \"/>
						<input type=\"hidden\" name=\"action\" value=\"update\"/>
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
						<td>
							<span  class=\"bold\">username:</span>
						</td>
						<td>
							<span  class=\"largerfont bold\">admin</span>
						</td>
					</tr>
					<tr style=\"height: 20px\">
						<td class=\"required\" >
							New password:
						</td>
						<td>
							<input  class=\"$adminpass_style\" type=\"password\" name=\"adminpass1\" size=\"25\" /><span class=\"heading\"></span>
						</td>
					</tr>
					<tr style=\"height: 20px\">
						<td class=\"required\" >
							Enter again:
						</td>
						<td>
							<input class=\"$adminpass_style\" type=\"password\" name=\"adminpass2\" size=\"25\" /><span class=\"heading\"></span>
						</td>
					</tr>	
			</tbody>
		</table>
	</form>
	<form method=\"post\" name=\"setup\" action=\"/admin/adminpass_exec.php\" >
		<table style=\"font-size:12px\" class=\"bottommargin1\" width=\"100%\">
			<tr>
				<td align=\"right\" class=\"$adminpass_remove\">
                    <input type=\"submit\" name=\"submit\" id=\"remove_adminpass\" value=\" &nbsp;&nbsp;Remove&nbsp;&nbsp; \" />
                    <input type=\"hidden\" name=\"action\" value=\"remove\" />
				</td>
			</tr>
		</table>
	</form>
</fieldset>
<fieldset  class=\"bottommargin1 xgdb_log\">
<legend class=\"setup\"> &nbsp; Option 2. Require password for entire xGDBvm website <img id='admin_xgdbpass' title='XGDBpass Help' class='help-button nudge2' src='/XGDB/images/help-icon.png' alt='?' /></legend>
	<form method=\"post\" name=\"setup\" action=\"/admin/xgdbpass_exec.php\" >	
		<table style=\"font-size:12px\" class=\"bottommargin1\" width=\"100%\">
			<tr>
                <td>
                    <p class=\"instruction indent2\">

                        To make the entire website private, <span class=\"warning\">first <b>remove</b> any Admin-level password (see above), as the system will not work will with 2 levels of password protection</span><br />
                    	 Next enter a password below, then click <b>Update</b> button at right.
                        <br />You will then be required to log in as username= <b>'user'</b> with your new password.
                        <br />You can change password whenever you like, or remove password protection by clicking <b>'Remove'</b>
                    </p>
                    $xgdbpass_message
                </td>
                <td align=\"right\">
                    <input type=\"submit\" name=\"submit\" id=\"submit_button_1\" value=\" &nbsp;&nbsp;Update&nbsp;&nbsp; \"/>
                    <input type=\"hidden\" name=\"action\" value=\"update\"/>
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
						<td>
							<span  class=\"bold\">username:</span>
						</td>
						<td>
							<span  class=\"largerfont bold\">user</span>
						</td>
					</tr>
					<tr style=\"height: 20px\">
						<td class=\"required\" >
							New password:
						</td>
						<td>
							<input  class=\"$xgdbpass_style\" type=\"password\" name=\"xgdbpass1\" size=\"25\" /><span class=\"heading\"></span>
						</td>
					</tr>
					<tr style=\"height: 20px\">
						<td class=\"required\" >
							Enter again:
						</td>
						<td>
							<input class=\"$xgdbpass_style\" type=\"password\" name=\"xgdbpass2\" size=\"25\" /><span class=\"heading\"></span>
						</td>
					</tr>	
			</tbody>
		</table>
	</form>
	<form method=\"post\" name=\"setup\" action=\"/admin/xgdbpass_exec.php\" >
		<table style=\"font-size:12px\" class=\"bottommargin1\" width=\"100%\">
			<tr>
                <td align=\"right\" class=\"$xgdbpass_remove\">
                    <input type=\"submit\" name=\"submit\" id=\"remove_xgdbpass\" value=\" &nbsp;&nbsp;Remove&nbsp;&nbsp; \" />
                    <input type=\"hidden\" name=\"action\" value=\"remove\" />
				</td>
			</tr>
		</table>
	</form>
</fieldset>
</div>
<div id=\"dbpass\">

</fieldset>

<fieldset  class=\"bottommargin1 topmargin2 xgdb_log\">
<legend class=\"setup\"> &nbsp;<b>B. Change default MySQL password</b> <img id='admin_dbpass' title='DBpass Help' class='help-button nudge2' src='/XGDB/images/help-icon.png' alt='?' /></legend>

<form method=\"post\" name=\"setup\" action=\"/admin/dbpass_exec.php\" >

<table style=\"font-size:12px\" class=\"bottommargin1\" width=\"100%\">
	<tr>
	<td><p>Your data will be more secure with a unique MySQL password behind the scenes, so we recommend you create one (although you will never need it on the web interface)</p><p class=\"instruction indent2\"> Enter a suitable password below, then click <b>Update</b> button at right <br />(NOTE: do this BEFORE you create any genome databases.)</p>
	$dbpass_message
	</td>
			<td align=\"right\">
				<input type=\"submit\" name=\"submit\" id=\"submit_button_2\" value=\" &nbsp;&nbsp;Update&nbsp;&nbsp; \"/>
				<input type=\"hidden\" name=\"action\" value=\"update\"/>

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
					<span  class=\"heading\">MySQL user:</span>
				</td>
				<td>
					<span  class=\"heading\">gdbuser</span>
				</td>
			</tr>
			<tr>
				<td class=\"required\" >
					MySQL password:
				</td>
				<td>
					<input class=\"$dbpass_style\" type=\"password\" name=\"dbpass1\" size=\"25\"/>
				</td>
			</tr>
			<tr style=\"height: 20px\">
				<td class=\"required\" >
					Enter again:
				</td>
				<td>
					<input class=\"$dbpass_style\" type=\"password\" name=\"dbpass2\" size=\"25\"/>
				</td>
			</tr>
	</tbody>
</table>
</form>

</fieldset>
</div>

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
