<?php
error_reporting(E_ALL & ~E_NOTICE); //disable undeclared variable error
	$global_DB= 'Genomes';
	$PageTitle = 'xGDBvm logfile';
	$pgdbmenu = 'Manage';
	$submenu1 = 'Config-Home';
	$submenu2 = 'Config-View';
	$leftmenu='Config-View';
	include('sitedef.php');
	include($XGDB_HEADER);
include_once(dirname(__FILE__).'/conf_functions.inc.php');
include_once(dirname(__FILE__).'/validate.php');

### Set default display by assigning css class to show/hide respective left menu elements
    $background = "";
   $log = ''; // show logfile pointer in left menu
	$edit = 'display_off'; //default - don't show edit pointer in left menu
	$view = 'display_on'; //defaults - do show view data pointer in left menu
	$create = 'display_off'; // default - don't show create pointer in left menu
	$drop = 'display_off'; //defaults - do show drop data pointer in left menu
	$abort = 'display_off'; // default - don't show abort pointer in left menu
	$update = 'display_off'; // default - don't show update pointer in left menu
		
	if(mysql_real_escape_string($_GET['id'])){ #URL string shows ?id=
	$id = (int) substr('00'. mysql_real_escape_string($_GET['id']), -3); //picks up either 3 or GDB003   TODO - need to further sanitize since numerical
	$DBid = "GDB".substr('00'. $id, -3);
	}else{ ## no GET - go to first one.
	$DBid="GDB001";
	}

$file="Pipeline_procedure";

if(preg_match("/procedure/", $_GET['file']) || preg_match("/error/", $_GET['file'])){ #URL string shows &file=
	$file=mysql_real_escape_string($_GET['file']);
}	
	
	switch ($file) // also display links to other logfiles
		{
    case "Pipeline_procedure":
		$file2="CpGAT_procedure";
		$file3="Pipeline_error";
        break;
    case "CpGAT_procedure":
		$file2="Pipeline_error";
		$file3="Pipeline_procedure";
        break;
    case "Pipeline_error":
		$file2="Pipeline_procedure";
		$file3="CpGAT_procedure";
        break;
}

$filepath = "${XGDB_DATADIR}${DBid}/logs/${file}.log";

		$fd = fopen($filepath, "r");
		$contents = fread($fd, filesize($filepath));
		fclose($fd);
		$contents = ($contents == "")?"-No output-":$contents;	
$formatted_contents = "
<div id=\"maincontentscontainer\" class=\"twocolumn configure $background\">
	<div style=\"text-align:right; margin:10px 150px -20px 0px\">
	</div>
	<div id=\"maincontents\" class=\"$background logfile\">
		<div class=\"dialogcontainer\" >
			<h2 class=\"bottommargin1\">
			${file}.log for $DBid &nbsp; &nbsp; 
			<span class=\"heading\"> 
				<a href=\"/XGDB/conf/view.php?id=$id\"><img src=\"/XGDB/images/configure.png\" alt=\"\" /> Configure</a>; &nbsp;
				<a href=\"/XGDB/phplib/index.php?GDB=$DBid\"> <img src=\"/XGDB/images/home_go.png\" alt=\"\" /> Browse</a>; &nbsp;
				<a href=\"/XGDB/phplib/download.php?GDB=$DBid&dir=download\"> <img src=\"/XGDB/images/download.png\" alt=\"\" /> Data Download</a>
			 </span>
			</h2>
			<span class=\"heading\">
			Other logfiles: 
			<a href=\"/XGDB/conf/logfile.php?id=$id&amp;file=$file2\"> <img src=\"/XGDB/images/logfile-icon.png\" alt=\"\" />${file2} </a> &nbsp;
			<a href=\"/XGDB/conf/logfile.php?id=$id&amp;file=$file3\"> <img src=\"/XGDB/images/logfile-icon.png\" alt=\"\" />${file3} </a>
			&nbsp; &nbsp; 
			</span>
		</div>
<div class=\"dialogcontainer\">
	<pre class=\"normal\" align=\"left\">
$contents
	</pre>
</div>";




$display_block= $formatted_contents;
?>
		<div id="leftcolumncontainer">
			<div class="minicolumnleft">
			<?php include_once("/xGDBvm/XGDB/conf/leftmenu.inc.php"); ?>
			</div>
		</div>

				<?php

					echo $display_block;
				?>
				<p />
			</div><!--end maincontents-->
			
			</div><!--end maincontentscontainer-->
			<div id="rightcolumncontainer">
				</div><!--end rightcolumncontainer-->
			<?php include($XGDB_FOOTER); ?>
		</div></div></div>
	</body>
</html>
