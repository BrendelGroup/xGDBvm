<?php
if ($_GET['movieid'][0]) {
	$movie = $_GET['movieid'][0];
	$movieurl = "/XGDB/help/av/{$movie}.mov";
} else {
	echo "<h2>Movie Not Available</h2>";
}
if ($_GET['movieid'][1]) {
	$movietitle = $_GET['movieid'][1];
} else {
	$movietitle = 'Untitled Movie';
}
echo
'<html>
	<head></head>
<body>
	<div id="video_bckgd">
		<h2><?php echo $movietitle; ?></h2>

		<object height="712" width="1280" codebase="http://www.apple.com/qtactivex/qtplugin.cab" classid="clsid:02BF25D5-8C17-4B23-BC80-D3488ABDDC6B">
			<param value="' . $movieurl . '" name="src"/>
			<param value="false" name="autoplay"/>
			<param value="true" name="controller"/>
			<param value="false" name="loop"/>
			<embed height="712" width="1280" pluginspage="http://www.apple.com/quicktime/download/" loop="false" controller="true" autoplay="false" src="' . $movieurl . '"/>
		</object>
	</div>
</body>
</html>';
?>
