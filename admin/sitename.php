<?php
$global_DB= 'Admin';
$PageTitle = 'Sitename Set Up';
$pgdbmenu = 'Manage';
$submenu1 = 'Admin-Home';
$submenu2 = 'Admin-Sitename';
$leftmenu='Admin-Sitename';
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

# Get sitename from /xGDBvm/admin/sitename
$sitename_file='/xGDBvm/admin/sitename';
if(file_exists($sitename_file))
{	
	$file_handle = fopen($sitename_file, "r");
	while (!feof($file_handle)) {
	   $sitename = fgets($file_handle);
	}
	fclose($file_handle);
}
else
{
$sitename="";
}

 
$display_block = "
<table width=\"100%\">
	<tr>
		<td align=\"left\" width=\"50%\">
			<h1 class=\"admin bottommargin1 darkgrayfont\"> <img src=\"/XGDB/images/user.png\" alt=\"\" /> Set Up Site Name</h1>
		</td>
	</tr>
</table>

<fieldset  class=\"bottommargin1 xgdb_log\">
<legend class=\"largerfont\"> &nbsp;<b> Site Name: <span style=\"border:2px solid yellow\"> $sitename</span></b></legend>

<form method=\"post\" name=\"setup\" action=\"/admin/sitename_exec.php\" >
	<input type=\"hidden\" name=\"action\" value=\"setup\"/>

	<table style=\"font-size:12px\" class=\"bottommargin1\" width=\"100%\">
		<tr>
			<td>
			<p><span class=\"tip_style\"><b>Enter name you would like to appear in the header of this website (max 20 characters including spaces),</b> then click <b>Update</b> button at right.</span></p>
			</td>
			<td align=\"right\">
				<input type=\"submit\" name=\"submit\" id=\"submit_button\" value=\" &nbsp;&nbsp;Update&nbsp;&nbsp; \" />
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
					Site Name
				</td>
				<td>
					<input name=\"sitename\" size=\"20\" placeholder=\"$sitename\" /> 
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
