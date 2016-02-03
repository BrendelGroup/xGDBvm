<html>
<head>

<?php
if ($_GET['imageid'][0]) {
	$compound_id = explode(":",$_GET['imageid'][0]);
	$imageurl = "/XGDB/help/images/" . $compound_id[0] . ".png";

	$dialog_width  = ($compound_id[1])?$compound_id[1]:480;
	$dialog_height = ($compound_id[2])?$compound_id[2]:640;
	$imagetitle = ($_GET['imageid'][1])?$_GET['imageid'][1]:'Untitled Image';

	$script_inline = '<script type="text/javascript">$(function(){$(\'#image_dialog\').dialog(\'option\',\'title\',"' . $imagetitle . '");$(\'#image_dialog\').dialog(\'option\',\'width\',' . "$dialog_width );" . '$(\'#image_dialog\').dialog(\'option\',\'height\',' . "$dialog_height ); " . '$(\'#image_dialog\').css(\'height\',' . ($dialog_height - 41) . ');})</script>';

	echo "</head><body><div id=\"image_bckgd\"><img alt=\"$imagetitle\" src=\"$imageurl\" /></div>$script_inline";

} else {
	echo "<title>Image Not Available</title></head><body><h2>Image Not Available</h2>";
}

?>
</body>
</html>
