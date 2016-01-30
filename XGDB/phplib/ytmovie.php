<?php
if ($_GET['movieid'][0]) {
	$movie = $_GET['movieid'][0];
	}
	else {
	echo "<h2>Movie Not available</h2>";
	};
if ($_GET['movieid'][1]) {
	$movietitle = $_GET['movieid'][1];
	}
	else {
	$movietitle = 'Untitled Movie';
	};
echo
"<html>
	<head></head>
<body>
	<div id=\"video_bckgd\">
		<h2>$movietitle</h2>
<iframe width=\"720\" height=\"480\" src=\"//www.youtube.com/embed/${movie}?rel=0&vq=hd720\" frameborder=\"0\" allowfullscreen></iframe>
	</div>
</body>
</html>"
;
?>

