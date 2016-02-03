<?php ob_start();
include('sitedef.php');
date_default_timezone_set("$TIMEZONE"); // from sitedef.php
session_start();
if (preg_match('/(GDB\d\d\d)/', $_SERVER['HTTP_REFERER'], $matches))
        $X = $matches[1];
if (preg_match('/(GDB\d\d\d)/',$_REQUEST['GDB'], $matches)) ;
        $X = $matches[1];
if(empty($SITEDEF_H)) { require('/xGDBvm/data/' . $X .'/conf/SITEDEF.php'); }

$track_index = htmlspecialchars($_GET['track']); //from SITEDEF.php GENE[]0] GENE[1] etc.
// get track table from SITEDEF.php based on get value 
$index=intval($track_index); 
$table_core=$GENE[$index]['locus_table'];

$DBid = $X;
$sessID=$table_core.$DBid; // synchronized with DisplayLoci.php session ID schema
$s_query = $sessID."query";
$query = $_SESSION[$s_query]; /* matches queryTotal from DisplayLoci.php */
//echo $query;

/* Send query to MySQL */

$dbpass=dbpass();
$link = mysql_pconnect("localhost", "gdbuser", $dbpass) or die(mysql_error());
$dbh = mysql_select_db("$DBid", $link); //
$csv_output = "Locus ID,GSEG,From,To,Len, Intron Count,Strand,Transcripts,Locus Description,Gene,Coverage,Integrity, yrGATE Anno Count,yrGATE Gene Product, Status, Published Anno(s)";
$csv_output .= "\n";
$values = mysql_query($query);
while ($data_array = mysql_fetch_array($values)) 
{

	$locus_id = $data_array['locus_id'];
	$gseg_gi = $data_array['gseg_gi'];
	$l_pos = $data_array['l_pos'];
	$r_pos = $data_array['r_pos'];
	$len = round(($r_pos-$l_pos)/1000, 1);
	$introns=$data_array['intron_count'];
	$strand = $data_array['strand'];
	$transcript_count = $data_array['transcript_count'];
	$description = $data_array['description'];
	$description_display= preg_replace('/,/', " ",$description);//replacing the commas in description column by space, because the commas in description column creates problem in csv output.
	$gene = $data_array['gene'];
	$coverage = $data_array['coverage'];
	$integrity = $data_array['integrity'];
	$count = $data_array['count'];
	$proteinId = $data_array['proteinId'];
	$status = $data_array['max_status'];
	
	$csv_output .= "$locus_id,$gseg_gi,$l_pos,$r_pos,$len,$introns, $strand,$transcript_count,$description_display,$gene,$coverage,$integrity,$count,$proteinId,$status";
	$csv_output .= "\n";
}//end of while loop

$file="${DBid}loci";
$filename = $file."_".date("Y-m-d_H",time());
header("Content-type: application/vnd.ms-excel");
header("Content-disposition: csv" . date("Y-m-d") . ".csv");
header("Content-disposition: filename=$filename.csv");
print $csv_output;
exit;

ob_flush();
?>

