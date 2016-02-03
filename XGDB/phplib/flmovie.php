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

<object width=\"1280\" height=\"720\"><param name=\"allowfullscreen\" value=\"true\" /><param name=\"allowscriptaccess\" value=\"always\" /><param name=\"movie\" value=\"http://vimeo.com/moogaloop.swf?clip_id=$movie&amp;server=vimeo.com&amp;show_title=0&amp;show_byline=0&amp;show_portrait=0&amp;color=&amp;fullscreen=1\" /><embed src=\"http://vimeo.com/moogaloop.swf?clip_id=$movie&amp;server=vimeo.com&amp;show_title=0&amp;show_byline=0&amp;show_portrait=0&amp;color=&amp;fullscreen=1\" type=\"application/x-shockwave-flash\" allowfullscreen=\"true\" allowscriptaccess=\"always\" width=\"1280\" height=\"720\"></embed></object>
	</div>
</body>
</html>"
;
?>