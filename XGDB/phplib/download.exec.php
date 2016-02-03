<?php
if (preg_match('/(GDB\d\d\d)/', $_GET['GDB'], $matches)) // be careful to only allow correct syntax for this directory name
{
$GDB= $matches[1];
}
else
{
$GDB="GDB001";
}

if (isset($_GET['dir']))
{
	$dir = htmlspecialchars($_GET['dir']);
}
if (isset($_GET['file']))
{
	$file = htmlspecialchars($_GET['file']);
}
$read="F";
switch ($dir) 
{
case "download":
   $root="/xGDBvm/data/$GDB";
   $dir="/data/download";
   $read="T";
break;
case "XGDB_MYSQL":
   $root="/xGDBvm/data/$GDB";
   $dir="/data/XGDB_MYSQL";
   $read="T";
break;
case "GSQ/GSQOUT":
   $root="/xGDBvm/data/$GDB";
   $dir="/data/GSQ/GSQOUT";
   $read="T";
break;
case "GTH/GTHOUT":
   $root="/xGDBvm/data/$GDB";
   $dir="/data/GTH/GTHOUT";
   $read="T";
break;
case "CpGAT":
   $root="/xGDBvm/data/$GDB";
   $dir="/data/CpGAT";
   $read="T";
break;
case "BLAST":
   $root="/xGDBvm/data/$GDB";
   $dir="/data/BLAST";
   $read="T";
break;
case "ArchiveGDB":
   $root="/xGDBvm/data";
   $dir="/ArchiveGDB";
   $read="T";
break;


}

$filepath="${root}${dir}/$file";

if (file_exists($filepath) && $read=="T") {
    header('Content-Description: File Transfer');
    header('Content-Type: text/plain; charset=utf-8');
    header('Content-Disposition: attachment; filename='.basename($filepath));
##    header('Content-Transfer-Encoding: binary');
    header('Expires: 0');
    header('Cache-Control: must-revalidate');
    header('Pragma: public');
    header('Content-Length: ' . filesize($filepath));
    ob_clean();
    flush();
    readfile($filepath);
    exit;
}
?>
