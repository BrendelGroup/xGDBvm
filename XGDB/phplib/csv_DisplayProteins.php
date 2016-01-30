<?php ob_start();
include('sitedef.php');
date_default_timezone_set("$TIMEZONE"); // from sitedef.php
session_start();
if (preg_match('/(GDB\d\d\d)/', $_SERVER['HTTP_REFERER'], $matches))
        $X = $matches[1];
if (preg_match('/(GDB\d\d\d)/',$_REQUEST['GDB'], $matches)) ;
        $X = $matches[1];
if(empty($SITEDEF_H)) { require('/xGDBvm/data/' . $X .'/conf/SITEDEF.php'); }

$track_index = htmlspecialchars($_GET['track']); //from SITEDEF.php PEP[]0] PEP[1] etc.
// get track table from SITEDEF.php based on get value 
$index=intval($track_index); 
$table_core=$PEP[$index]['table'];

$DBid = $X;
$sessID=$table_core.$DBid; // synchronized with DisplayProteins.php session ID schema
$s_query = $sessID."query";
$query = $_SESSION[$s_query]; /* matches queryTotal from DisplayProteins.php */
//echo $query;

/* Send query to MySQL */

$dbpass=dbpass();
$link = mysql_pconnect("localhost", "gdbuser", $dbpass) or die(mysql_error());
$dbh = mysql_select_db("$DBid", $link); //
$csv_output = "Protein_ID,GSEG,From,To, Length, mRNA Length, Similarity,Coverage,Copy #, Description";

$csv_output .= "\n";
$values = mysql_query($query);
while ($data_array = mysql_fetch_array($values)) 
{
	$gi = $data_array['gi'];
	$gseg_gi = $data_array['gseg_gi'];
	$l_pos = $data_array['l_pos'];
	$r_pos = $data_array['r_pos'];
	$mlength = $data_array['mlength'];
	$len = round(($r_pos-$l_pos)/1000, 1);
	$G_O=$data_array['G_O'];
	$sim = $data_array['sim'];
	$cov = $data_array['cov'];
	$description = $data_array['description'];
	$description_display= preg_replace('/,/', " ",$description);//replacing the commas in description column by space, because the commas in description column creates problem in csv output.
	$copy_num = $data_array['copy_num'];
    $csv_output .= "$gi,$gseg_gi,$l_pos,$r_pos,$len, $mlength, $sim,$cov,$copy_num, $description_display";
	$csv_output .= "\n";
}//end of while loop

$file="${DBid}proteins";
$filename = $file."_".date("Y-m-d_H",time());
header("Content-type: application/vnd.ms-excel");
header("Content-disposition: csv" . date("Y-m-d") . ".csv");
header("Content-disposition: filename=$filename.csv");
print $csv_output;
exit;

ob_flush();
?>

