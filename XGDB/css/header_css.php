<?php
header('Content-type: text/css');
include("sitedef.php");
$menubar_bgcolor = "#abf4ad";

/* This script no longer used. It has been replaced by:
	/css/search.css
	/css/plantgdb.css
- Dan Rasmussen. 2009-07-20.
*/

?>


body
{
	margin: 0px;
}

table.footer
{
	width: 100%;
	border: solid black;
	border-width: 1px 0px;
	margin: 10px 0px;
	padding: 10px;
}

table.footer a
{
	text-decoration: none;
}

table.footer td
{
	padding: 5px 10px;
	margin: 5px 10px;
}

.bgclass
{
	background:<?php echo $menubar_bgcolor?>;
}

#dummylist
{
	margin: 5px;
	padding: 0px;
	list-style: none;
}

#dummylist img
{
	border: 0;
	padding: 0px;
}

#feature
{
	border: dashed yellow 3px;
	padding: 2px 0 2px 5px;
	margin: 0px;
	background: white;
}

#feature a
{
	background: transparent;
	color: black;
	text-decoration: none;
}

#feature a:hover
{
	background: transparent;
}

#topMenuBar
{
	width: "100%";
	border: 0;
	border-collapse: collapse;
	padding:0;
	margin:0;
	background:<?php echo $menubar_bgcolor?>;
}

#topMenuBar td
{
	!padding: 5px;
	padding: 0;
	spacing: 0;
}

/* SideBar */
.sidebar_row
{
	//width:150px;
	height:20px;
}

.sidebar_row_header
{
	height:20px;
	background:#009933;
	color:<?php echo $menubar_bgcolor?>;
	padding-left:8px;
	font-family:Arial;
	text-decoration:none;
	font-size:14px;
}
.sidebar_row a
{
	display:block;
	//width:150px;
	padding-left:8px;
	background:<?php echo $menubar_bgcolor?>;
	font-family:Arial;
	color:black;
	text-decoration:none;
	font-size:14px;
}

.sidebar_row a:hover
{
	background:#009933;
	color:<?php echo $menubar_bgcolor?>;
}

.sidebar_line
{
	border-bottom:thin dashed gray;
	width:20px;
	height:5px;
}

.sidebar_line_space
{
	height:5px;
}

/* Horizontal Cells */

.horizontal_cells
{
	border:thin solid gray;
	width:80px;
}
.horizontal_cells a
{
	font-weight:bold;
	text-decoration:none;
	font-family:Arial;
	font-size:13px;
	color:black;
	font-variant:small-caps;
}

.horizontal_cells a:hover
{
	color:<?php echo $menubar_bgcolor?>;
}

.popup_menu_link
{
	color:black;
	text-decoration:none;
}

.mainstage, TABLE
{
	font-family:Arial;
	color:black;
	font-size:14px;
}

.mainstage font
{
	font-family:Arial;
	color:black;
	font-size:14px;
}

.mainstage h1
{
	font-family:Arial;
	color:black;
	font-size:16px;
	font-weight:bold;
}

.mainstage h2
{
	font-family:Arial;
	color:black;
	font-size:14px;
	font-weight:bold;
}

.mainstage a
{
	font-family:Arial;
	color:blue;
	font-size:14px;
	text-decoration:underline;
}

.footer
{
	font-family:Arial;
	color:black;
	font-size:12px;
}

.topl_row a
{
	font-family:Arial;
	color:blue;
	font-size:14px;
	font-weight:bold;
	text-decoration:none;
}

.topl_row a:hover
{
	color:green;
}

 /* for internal table */

.sidebar_row_context_1_headingb
{
	height:20px;
	padding-left:8px;
	background:#8edcf2;
	font-family:Arial;
	color:black;
	text-decoration:none;
	font-size:10px;
	vertical-align:middle;
}

.sidebar_row_context_1_heading
{
	height:20px;
	padding-left:8px;
	font-family:Arial;
	color:black;
	text-decoration:none;
	font-size:12px;
	vertical-align:bottom;
	border-bottom:lightblue 1px solid;
}
.sidebar_row_context_1 a
{
	background:white;
	display:block;
	width:150px;
	padding-left:18px;
	font-family:Arial;
	color:black;
	text-decoration:none;
	font-size:10px;
}

.sidebar_row_context_1 a:hover
{
	background: url(<?echo $PLANTGDB_IMAGEURL;?>/arrowlink.gif) no-repeat left;color:black;
}

.title
{
	font-family:Arial;
	font-size:32px;
	color:black;
	font-weight:bold;
	text-align:center;
}

/* end for internal table */

.secondary_menu a
{
	font-family:Arial, Helvetica, sans-serif;
	font-size:10px;
	color:#8edcf2;
	background:blue;
	text-decoration:none;
}

.secondary_menu a:hover
{
	color:blue;
	background:#8edcf2;
}

.blankclass
{
	color:inherit;
	font-family:inherit;
	font-size:inherit;
	text-decoration:inherit;
	background:inherit;
}

.popup
{
	position: absolute;
	visibility: hidden;
	font-family: Arial;
	font-size:10px;
	color:gray;
	background-color: #E0E0E0;
	width: 170px;
	border: 0px solid black;
	padding: 3px;
	z-index: 10;
}

