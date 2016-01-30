<!DOCTYPE html
	PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
	 "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml"> 
<head>
	<meta http-equiv="content-type" content="text/html;charset=utf-8" />
	<title><?php echo $PageTitle; ?></title>
	<link rel="StyleSheet" type="text/css" title="Default" href="/XGDB/css/plantgdb.css" media="screen" />
	<link rel="StyleSheet" type="text/css" href="/XGDB/css/superfish.css" media="screen" />
	<link rel="stylesheet" type="text/css" href="/XGDB/javascripts/jquery/themes/base/ui.all.css" />
	<link rel="Alternative StyleSheet" type="text/css" href="/XGDB/css/plantgdb_print.css" media="print" />
	<!--[if IE 6]>
	<link rel="StyleSheet" type="text/css" href="/XGDB/css/plantgdb_ie6.css" />
	<![endif]-->
	<?php
#		echo $ExtraHeadInfo;
	?>
	<script type="text/javascript" src="/XGDB/javascripts/jquery.js"></script>
	<script src="/XGDB/javascripts/jquery/ui/ui.core.js" type="text/javascript"></script>
	
	<script src="/XGDB/javascripts/jquery/ui/ui.sortable.js" type="text/javascript"></script>
	<script src="/XGDB/javascripts/jquery/ui/ui.draggable.js" type="text/javascript"></script>
	<script src="/XGDB/javascripts/jquery/ui/ui.resizable.js" type="text/javascript"></script>
	<script src="/XGDB/javascripts/jquery/ui/ui.dialog.js" type="text/javascript"></script>
	<script src="/XGDB/javascripts/jquery/ui/effects.core.js" type="text/javascript"></script>
	<script src="/XGDB/javascripts/jquery/ui/effects.highlight.js" type="text/javascript"></script>
	<script src="/XGDB/javascripts/jquery/external/bgiframe/jquery.bgiframe.js" type="text/javascript"></script>

	<script type="text/javascript" src="/XGDB/javascripts/jquery.tablesorter.js"></script>
	<script type="text/javascript" src="/XGDB/javascripts/superfish.js"></script>
	<script type="text/javascript" src="/XGDB/javascripts/hoverIntent.js"></script>
	<script type="text/javascript" src="/XGDB/javascripts/default.js"></script>
</head>
<body>
<div id="outercontainer">
	<div id="innercontainer">
		<div id="logomenucontainer"><!-- Container w/ same background color as logo and pgdbmenu -->
			<div id="headerwidth"><!-- This nested container allows FF2.0 to handle floated divs with % width -->
				<a name="top"></a>
				<?php 
				$sitename_file='/xGDBvm/admin/sitename';
				if(file_exists($sitename_file))
				{	
					$file_handle = fopen($sitename_file, "r");
					while (!feof($file_handle))
					{
					   $sitename = fgets($file_handle);
					}
					fclose($file_handle);
				}
				else
				{
				$sitename="";
				}
				?>
			
				
				<?php include_once(dirname(__FILE__) . '/pgdbtopleft.inc.php'); // Top left nav area ?>
				<div id="pgdblogo">
				<div style="position:absolute; top:32px; left:2%"><?php echo "<span id=\"sitename\">$sitename</span>" ?></div>
					<a style="background:none" href= "/"><img id="xGDBvm_banner" alt="XGDBVM" src="/XGDB/images/Banner.png" /></a>
				</div>
				<?php
					include_once(dirname(__FILE__) . '/pgdbtopright.inc.php'); // Top right nav area
					include_once(dirname(__FILE__) . '/pgdbmenu.inc.php'); // Main dropdown menu
				?>
			</div><!--end headerwidth-->
		</div><!--end logomenucontainer-->
		<div id="pagewidth" class="<?php echo isset($pgdbmenu)?$pgdbmenu:''; ?>"><!-- This nested container allows FF2.0 to handle floated divs with % width -->

<?php		
				$adminpassword_file='/xGDBvm/admin/adminpassword';
				$xgdbpassword_file='/xGDBvm/admin/xgdbpassword';
				if(!file_exists($xgdbpassword_file) && !file_exists($adminpassword_file))
				{	
				$showhide="";
				}
				else
				{
				$showhide="display_off";
				}
$message = "<div id=\"message\" class=\"$showhide\"><h2>Your xGDBvm instance is NOT password-protected! Please visit <a class=\"white\" href=\"/admin/setup.php#password\">Manage &rarr; Admin &rarr; Setup</a> and choose a password option.</h2></div>";

echo $message;
				?>
