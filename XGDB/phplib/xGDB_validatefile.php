<?php

# This script validates file information for user input/output files, displays the data (if called via Javascript) and saves the data to a database table using unique filestamp as identity.
# On subsequent launch the script uses database values preferentially if a filestamp match is found in the database.
# This script also evaluates any temporary 'Catted' files representing multiple files of the same file type. In that case UserFile is set to 'F' since it's not actually a user-created file.


include('sitedef.php');
include_once('/xGDBvm/XGDB/conf/conf_functions.inc.php');
include_once('/xGDBvm/XGDB/phplib/db.inc.php');
$dbpass=dbpass();
$db = mysql_connect("localhost", "gdbuser", $dbpass);
$global_DB="Genomes";
date_default_timezone_set("$TIMEZONE");
$emboss_path=$EMBOSS; # sitedef.php 
$EMBOSS = "/usr/local/src/EMBOSS/EMBOSS-6.5.7/emboss";
global $valid, $fastavalid, $fasta_validate_display, $fasta_validate_message, $validation_time_stamp, $exists, $message, $file, $filepath, $filestamp, $sequences, $contents, $gsqcontents, $error, $validate, $fastacontents, $maskcontents, $gdnasizes, $gff3contents, $gsqcontents, $gthcontents, $txtcontents, $sample_contents, $valid_output, $duplicates, $genes, $gsqalignments, $gsqerror, $gthalignments, $gtherror, $txtentries, $txterror, $xresidues_display, $track, $seqtype, $seqtypecount, $hardmaskN, $hardmaskX, $batch, $transcripts, $entries, $defline_tabs, $fasta_defline, $total, $average, $median, $min, $max1, $max1, $max2, $max3, $max4, $max5, $max6, $max7, $max8, $max9, $max10, $max11, $max12, $max13, $max14, $max15, $max16, $max17, $max18, $max19, $max20, $unit;

###############################################################
# Step 1. Get arguments for GDB and file validation target(s) #
###############################################################

## arguments via Javascript as name/value (if one-off validation) or from shell script xGDB_ValidateFiles.sh as argv (if batch)

if (isset($_GET['timestamp']))
	{
		$validation_time_stamp=mysql_real_escape_string($_GET['timestamp']);  # not currently used but we might want to pass from one-off validadtion.
	}
	elseif(isset($argv[1])) 
	{
	   $validation_time_stamp = mysql_real_escape_string($argv[1]); #  from /xGDBvm/scripts/xGDB_ValidateFiles.sh if this is a batch validate request 
       $message="(xGDB_validate.phpb The script has acquired the batch validation time stamp for this run. validate_time_stamp=".$validation_time_stamp;
 # debug     file_put_contents($logfile_path, $message."\n", FILE_APPEND);
	}
	else 
	{
	   $validation_time_stamp=date("Y-m-d H:i:s"); # timestamp for one-off validation
	}
if (isset($_GET['context'][0]))  // filepath;  the path to the file including the filename (this is specified in 'id' tag in html and passed via Javascript if standalone request) 
	{
		$filepath = mysql_real_escape_string($_GET['context'][0]); // 
	}
elseif(isset($argv[2])) # batch request filepath from xGDB_ValidateFiles.sh
	{
	   $filepath = trim(mysql_real_escape_string($argv[2])); 
       $message="(xGDB_validate.php) The script has acquired the valiation file path for this file. filepath=".$filepath;
	} 
	 else
	{
	   $message= "(xGDB_validate.php) ERROR: file path not available";
#       error_log($message."\n");
	   print "<h2 style=\"color:red\">$error</h2>";
	   exit;
	}
$filepath = str_replace("\\", "", $filepath);  // human-readable version, get rid of any escaped slashes
$filepath=str_replace("//", "/", $filepath); // in case of extraneous slash
$pattern='/(.*\/)(\S+?)$/';
preg_match($pattern, $filepath, $matches );
$path=$matches[1]; # parse filename from the path
$file=$matches[2]; # parse filename from the path

if(!file_exists($filepath)) // somehow the file was moved/deleted after this web page was loaded.
	{
	   $message= "(xGDB_validate.php) ERROR: file is missing (it was moved or renamed, or path is incorrect)";
#       error_log($message."\n");
	   print "<h2 style=\"color:red\">$error</h2>";
	   exit;
	}

if (isset($_GET['context'][1])) //filestamp;  the unique file identifier (this is specified in 'title' tag in html and passed via Javascript if standalone request) .
	{
	   $filestamp = mysql_real_escape_string($_GET['context'][1]);
	}
	elseif(isset($argv[3])) 
	{ 
	   $filestamp = trim(mysql_real_escape_string($argv[3]));
	   $message= "(xGDB_validate.php) the unique file stamp was acquired; filestamp=".$filestamp;
#      error_log($message."\n");
	} 
    else
	{
	   $message= "(xGDB_validate.php) ERROR: the unique file stamp was NOT acquired";
#       error_log($message."\n");
	}

if (isset($_GET['batch']))
    {
        $batch=($_GET['batch']=="T")?"T":"F";  #batch validate request.
    }
	elseif(isset($argv[4])) 
	{ 
	   $batch = $argv[4]; # flag for batch jobs
       $batch=($argv[4]=="T")?"T":"F"; 
	   $message= "(xGDB_validate.php) The batch validation flag is set to ".$batch;
#       error_log($message."\n");
	} 
    else
    {
    $validation_time_stamp=date("Y-m-d H:i:s");
    }

if(isset($argv[5])) 
	{ 
	   $seqtypecount = $argv[5]; # sequence type count (integer)
	   $message= "(xGDB_validate.php) The sequence type count is ".$seqtypecount;
#      error_log($message."\n");
	} 
    else
	{
	   $message= "(xGDB_validate.php) ERROR: the sequence type count was NOT acquired";
#       error_log($message."\n");
	}

if(isset($argv[6])) 
	{ 
	   $user_file = $argv[6]; # userFile? (T or F)
	   $message= "(xGDB_validate.php) Is this an actual file ?  '".$user_file."'";
#       error_log($message."\n");
	} 
    else
	{
	   $message= "(xGDB_validate.php) ERROR: we didn't get the flag denoting 'Is this an actual file?'";
#       error_log($message."\n");
	}
################################################################################################################
# Step 2. (iPlant only) Copy $file to scratch dir for analysis (minimize i/o on DataStore is attached)     #
################################################################################################################


if (file_exists("/xGDBvm/admin/iplant") && file_exists("/xGDBvm/data/scratch")) // xGDBvm-iPlant only; make sure scratch directory exists
	{ 
		$filepath_scratch ="/xGDBvm/data/scratch/temp_".$file; // this is where we will copy the file to analyze it if this is an iPlant VM (since I/O performance is slow with Data Store)
	}
	else
	{
	$filepath_scratch = $filepath; // otherwise there is no need to copy to scratch directory for performance reasons.
	}
###### End iPlant-specific step ######


###########################################################################################################################
# Step 3. Now determine if this file has already been validated, and if not a batch request, retrieve data for display    #
###########################################################################################################################

mysql_select_db("$global_DB");
$file_query = "select * from Datafiles where FileStamp='$filestamp'"; // FileStamp 
$check_get_file = mysql_query($file_query);
$get_file_query = mysql_fetch_array($check_get_file);
$filestamp_stored=$get_file_query['FileStamp'];
if($filestamp == $filestamp_stored && $batch == "T") 
{

# error_log($message."\n\n");

# We simply update the ValidationTimeStamp so that all files in this directory have the same time stamp (in case some, not all were newly validated) NOT WORKING 9/29/14
 
mysql_select_db("$global_DB");
$update_query = "UPDATE Datafiles SET ValidationTimeStamp='$validation_time_stamp' WHERE FileStamp='$filestamp';"; // FileStamp 
$execute = mysql_query($update_query);

$insert_query="INSERT INTO Validation (FileStamp, ValidationTimeStamp) VALUES ('$filestamp', '$validation_time_stamp')"; //  
$execute = mysql_query($insert_query);

$message= "(xGDB_validate.php)  Updated ValidationTimeStamp $validation_time_stamp saved to the database tables 'Datafiles' and 'Validation' for this file (filestamp $filestamp). ***Exiting.***";
#error_log($message."\n\n");

exit(); # Nothing else to do. Validation data exist for this file and this is a batch query.
}
elseif($filestamp == $get_file_query['FileStamp'] && $batch != "T")  //file data exist in 'Datafiles' table and this is a one-off request - retrieve them for display.
{
		$exists = "T";
		$valid  = $get_file_query['Valid'];
		$user_file  = $get_file_query['UserFile'];
#		$validation_time_stamp=$get_file_query['ValidationTimeStamp']; NO, we don't load this. It gets overwritten with the new one each time.
		$file = $get_file_query['FileName'];
		$path = $get_file_query['Path'];
		$filepath=$path.$file; # reconstructed
		$filestamp = $get_file_query['FileStamp'];
		$filesize = $get_file_query['FileSize'];
		$seqtype = $get_file_query['SeqType'];
		$seqtypecount = $get_file_query['SeqTypeCount'];
		$format = $get_file_query['Format'];
		$track = $get_file_query['Track'];

		$statistics_array=array(
			0 => $get_file_query['EntryCount'], //count
			1 => $get_file_query['SizeTotal'], //total
			2 => $get_file_query['SizeAverage'], //average
			3 => $get_file_query['SizeMedian'],  //median
			4 => $get_file_query['SizeSmallest'], //min  
			5 => $get_file_query['SizeLargest'], //max1
			6 => $get_file_query['Size2'], //max2
			7 => $get_file_query['Size3'], //max3
			8 => $get_file_query['Size4'], //max4
			9 => $get_file_query['Size5'], //max5
			10 => $get_file_query['Size6'], //max6
			11 => $get_file_query['Size7'], //max7
			12 => $get_file_query['Size8'], //max8
			13 => $get_file_query['Size9'], //max9
			14 => $get_file_query['Size10'], //max10
			15 => $get_file_query['Size11'],//max11
			16 => $get_file_query['Size12'], //max12
			17 => $get_file_query['Size13'], //max13
			18 => $get_file_query['Size14'], //max14
			19 => $get_file_query['Size15'], //max15
			20 => $get_file_query['Size16'], //max16
			21 => $get_file_query['Size17'], //max17
			22 => $get_file_query['Size18'], //max18
			23 => $get_file_query['Size19'], //max19
			24 => $get_file_query['Size20'], //max20
		);
		
		$hardmaskN = $get_file_query['HardMaskN']; //"valid" masking with N
		$hardmaskX = $get_file_query['HardMaskX']; //invalid masking with X
		$fastavalid = $get_file_query['FastaValid']; //valid as in recognizable define and no duplicates (response: OK)
		$fasta_validate_message = $get_file_query['FastaValidateMessage']; //valid or invalid fasta details
		$fasta_defline = $get_file_query['FastaDefline']; //fasta defline type (genebank, idonly)
		$sample_contents_html = $get_file_query['SampleContents']; //First 3 lines of file contents
		$defline_tabs = $get_file_query['DeflineTabs']; //defline_tabs should be absent (default 0)
		#$duplicate = $get_file_query['Duplicates']; //
		$unit =  $get_file_query['Unit']; //aa or bp
		$entries =  $get_file_query['Entries']; //aa or bp
		$transcripts =  $get_file_query['Transcripts']; //aa or bp
		$genes =  $get_file_query['Genes']; //aa or bp
		$gsqalignments =  $get_file_query['GSQAlignments']; // for .gsq files
		$gthalignments =  $get_file_query['GTHAlignments']; // for .gth files
}

else //no file data exists- copy the file to /xGDBvm/scratch and open the file so we can extract a sample and save to database (same for batch/nonbatch query)
{ 
        $exists="F";
        $copy_to_scratch = (file_exists("/xGDBvm/admin/iplant"))?`cp $filepath $filepath_scratch`:""; // Conditional copy to scratch directory.
		$fd = fopen($filepath_scratch, "r"); //non-iPlant: this filepath is the same as the original filepath.
		$sample_contents = fread($fd, 200);
		$sample_contents = mysql_real_escape_string($sample_contents); # stored in Datafiles data table.
		$sample_contents_html = htmlspecialchars($sample_contents); # for display
		fclose($fd);
			
	    $message= "(xGDB_validate.php)  New data. Opened the file ".$filepath_scratch." for reading";
#        error_log($message."\n\n");
       
} // OK. We have now opened the file and read its contents, grabbed a sample.



######  Determine sequence type for this file (needed for various subsequent queries)

$seqtype=get_sequence_type($filepath); # e.g. "est"; see conf_functions.inc.php
$format=get_sequence_format($filepath); # e.g. "fa"; see conf_functions.inc.php
$track=get_track_id($filepath); # e.g. "est1"; see conf_functions.inc.php

###### Get totals for this file type among data than may have already been saved (outcome not saved; for display only as the y in 'number x out of y total').  Note we do this whether or not THIS particular file has already been validated.

$seq_type_count_display="";
$type_count_query = "select count(*) from Datafiles where ValidationTimeStamp='$validation_time_stamp' AND SeqType='$seqtype'"; // Limits query results to this validation session (if batch) 
$check_get_type_count = mysql_query($type_count_query);
$get_type_count_query = mysql_fetch_array($check_get_type_count);
$type_count_total=$get_type_count_query[0];
if($type_count_total > 1)
{
   $seq_type_count_display="<span style=\"color:darkorange\"> $seqtypecount of $type_count_total</span>";
}

### Get file size and process for display

		$filesize=($exists=="T")?$filesize:trim(`wc -c < $filepath_scratch`);  # file size in bytes
		$filesize_display=convert_bytes($filesize); # conf_functions.inc.php
#     	$filesize_display=preg_replace('/(?<=\d)(?=(\d\d\d)+$)/', ',', $filesize);

### for gff3 output only ###
	    if($exists=="F") # we must get data
	    {
#		    $pattern="/.+annot\.gff3$/";
#		    if(preg_match($pattern, $filepath_scratch))

            if($seqtype=="annot" && $track=="annot")
		    {
		    $test="hello";
		    $transcripts=`grep -c -P "\tmRNA\t" $filepath_scratch`;
		    $entrycount=$transcripts;
		    $genes=`grep -c -P "\tgene\t" $filepath_scratch`;
		    $valid=($transcripts>0)?"T":"F";
		    $gfferror=($transcripts>0)?"":"<span class=\"alertnotice\">ERROR: no transcripts could be parsed</span>";
		    }
		}
		if($seqtype=="annot" && $track=="annot" && $batch != "T") # either from the above patternmatch or from database
		{
			$gff3contents=
			"
			<h2 class=\"bottommargin1\">File type:<span class=\"grayfont largerfont largerfont\"> GFF3 table </span></h2>
		
			<h2 class=\"bottommargin1\">Transcript count: <span class=\"grayfont largerfont\">$transcripts $gfferror</span></h2>
			<h2>Gene count: <span class=\"grayfont largerfont\">$genes </span></h2>
			"
			;
		}

	    if($exists=="F") # we must get data
	    {
            if($seqtype=="annot" && $track=="cpgat")
		    {
		    $transcripts=`grep -c -P "\tmRNA\t" $filepath_scratch`;
		    $entrycount=$transcripts;
		    $genes=`grep -c -P "\tgene\t" $filepath_scratch`;
		    $valid=($transcripts>0)?"T":"F";
		    $gfferror=($transcripts>0)?"":"<span class=\"alertnotice\">ERROR: no transcripts could be parsed</span>";
		    }
		}
		if($seqtype=="annot" && $track=="cpgat" && $batch != "T") # either from the above patternmatch or from database. Display it!
		{
			$gff3contents=
			"
			<h2 class=\"bottommargin1\">File type:<span class=\"grayfont largerfont largerfont\"> GFF3 table </span></h2>
		
			<h2 class=\"bottommargin1\">Transcript count: <span class=\"grayfont largerfont\">$transcripts $gfferror</span></h2>
			<h2>Gene count: <span class=\"grayfont largerfont\">$genes </span></h2>
			"
			;
		}
### for spliced alignment output ONLY ###
	    if($exists=="F") # we must test for gth ooutput data
	    {
        if($format=="gth")
		    {
		        $gthalignments=`grep -c "MATCH" $filepath_scratch`;
		        $entrycount=$gthalignments;
		        $valid=($gthalignments>0)?"T":"F";
		        $gtherror=($gthalignments>0)?"":"<span class=\"alertnotice\">ERROR: no GenomeThreader alignments could be parsed</span>";
 		    }
		}
		if($format=="gth" && $batch != "T") # either from the above patternmatch or from database. Display it!
		{
			$gthcontents=
			"
			<h2 class=\"bottommargin1\">File type:<span class=\"grayfont largerfont largerfont\"> GenomeThreader output $seqtype $seq_type_count_display</span></h2>
		
			<h2>GenomeThreader query matches to genome: <span class=\"grayfont largerfont\">$gthalignments $gtherror</span></h2>
			"
			;
		}
	    if($exists=="F") # we must test for gsq output data
	    {
        if($format=="gsq")
		    {
		        $gsqalignments=`grep -c "MATCH" $filepath_scratch`;
		        $entrycount=$gsqalignments;
		        $valid=($gsqalignments>0)?"T":"F";
		        $gsqerror=($gsqalignments>0)?"":"<span class=\"alertnotice\">ERROR: no GeneSeqer alignments could be parsed</span>";
		    }
		}
		if($format=="gsq" && $batch != "T") # either from the above patternmatch or from database
		{
		$gsqcontents=
		"
		<h2 class=\"bottommargin1\">File type:<span class=\"grayfont largerfont largerfont\"> GeneSeqer output $seqtype $seq_type_count_display</span></h2>
		
		<h2>GeneSeqer query matches to genome: <span class=\"grayfont largerfont\">$gsqalignments  $gsqerror</span></h2>
		"
		;
		}

### for annotation (tab-delimited) text file ONLY ###
	    if($exists=="F") # we must test for .txt output data
	    {
        if($seqtype=="desc" && $track=="annot")
		    {
      			$txtentries=`grep -c -P "^.+\t.+$" $filepath_scratch`; #tab-delimited file with 2 columns
		        $valid=($txtentries>0)?"T":"F";
		        $txterror=($txtentries>0)?"":"<span class=\"alertnotice\">ERROR</span>";
		        $entrycount="$txtentries";
		    }
		}
		if($seqtype=="desc" && $track=="annot") # either from the above patternmatch or from database. Display it!
		{
		$txtcontents=
		"
		<h2 class=\"bottommargin1\">File type:<span class=\"grayfont largerfont largerfont\"> Text (tabular) output </span></h2>
		
		<h2>Number of records: <span class=\"grayfont largerfont\">$txtentries $txterror </span></h2>
		"
		;   
		}

 ### for cpgat text file ONLY ###
	    if($exists=="F") # we must test for .txt output data
	    {
        if($seqtype=="desc" && $track=="cpgat")
		    {
      			$txtentries=`grep -c -P "^.+\t.+$" $filepath_scratch`; #tab-delimited file with 2 columns
		        $valid=($txtentries>0)?"T":"F";
		        $txterror=($txtentries>0)?"":"<span class=\"alertnotice\">ERROR</span>";
		        $entrycount="$txtentries";
		    }
		}

		if($seqtype=="desc" && $track=="cpgat" && $batch != "T") # either from the above patternmatch or from database. Display it!
		{
		$txtcontents=
		"
		<h2 class=\"bottommargin1\">File type:<span class=\"grayfont largerfont largerfont\"> Text (tabular) output </span></h2>
		
		<h2>Number of records: <span class=\"grayfont largerfont\">$txtentries $txterror </span></h2>
		"
		;   
		}
        
### for fasta ONLY ###

		if($exists=="F") # we must get fasta info using EMBOSS
		{
        if($format=="fa")
		    {

     # EMBOSS infoseq for fasta information
				$statistics=`${emboss_path}/infoseq -sequence $filepath_scratch -only -length |sort -n | awk ' { sum+=$1; } END { print NR-1; } END { print sum; } END { print sum/(NR-1); } OFMT="%3.0f" { a[i++]=$1; } END { print a[int(i/2)]; } END { print a[int(1)]; }  END { print a[int(i-1)]; } END { print a[int(i-2)]; } END { print a[int(i-3)]; } END { print a[int(i-4)]; } END { print a[int(i-5)]; } END { print a[int(i-6)]; } END { print a[int(i-7)]; } END { print a[int(i-8)]; } END { print a[int(i-9)]; } END { print a[int(i-10)]; } END { print a[int(i-11)]; } END { print a[int(i-12)]; } END { print a[int(i-13)]; } END { print a[int(i-14)]; } END { print a[int(i-15)]; } END { print a[int(i-16)]; } END { print a[int(i-17)]; } END { print a[int(i-18)]; } END { print a[int(i-19)]; } END { print a[int(i-20)]; } '`; 
				$statistics = str_replace("Length", "", $statistics); # hack to get get rid of spurious string 'Length' that Emboss prints out after first null length
				$statistics_array=explode("\n", $statistics);
			
			}  # else use values from database
			
		}
		if($format=="fa") # either from the above or from database: Make the array!
		{
				$entrycount=$statistics_array[0];
				$total=$statistics_array[1]; //aggregate bp or aa
				$average=$statistics_array[2]; // mean size
				$median=$statistics_array[3]; //median (center value)
				$min=$statistics_array[4]; // smallest
				$max1=$statistics_array[5]; // largest  
				$max2=$statistics_array[6]; // 2nd largest  
				$max3=$statistics_array[7]; // 
				$max4=$statistics_array[8]; //
				$max5=$statistics_array[9]; // 5th largest
				$max6=$statistics_array[10]; //   
				$max7=$statistics_array[11]; //
				$max8=$statistics_array[12]; //
				$max9=$statistics_array[13]; //
				$max10=$statistics_array[14]; // 10th largest
				$max11=$statistics_array[15]; //
				$max12=$statistics_array[16]; //
				$max13=$statistics_array[17]; //
				$max14=$statistics_array[18]; //
				$max15=$statistics_array[19]; //
				$max16=$statistics_array[20]; //
				$max17=$statistics_array[21]; // 
				$max18=$statistics_array[22]; //
				$max19=$statistics_array[23]; //
				$max20=$statistics_array[24]; // 20th largest

				$entrycount_display=(is_numeric($entrycount))?preg_replace('/(?<=\d)(?=(\d\d\d)+$)/', ',', $entrycount):"-";
				$total_display=(is_numeric($total))?preg_replace('/(?<=\d)(?=(\d\d\d)+$)/', ',', $total):"-";
				$average_display=(is_numeric($average))?preg_replace('/(?<=\d)(?=(\d\d\d)+$)/', ',', $average):"-";
				$median_display=preg_replace('/(?<=\d)(?=(\d\d\d)+$)/', ',', $median);
				$min_display=preg_replace('/(?<=\d)(?=(\d\d\d)+$)/', ',', $min);
				$max1_display=(is_numeric($max1))?preg_replace('/(?<=\d)(?=(\d\d\d)+$)/', ',', $max1):"-";
				$max2_display=(is_numeric($max2))?preg_replace('/(?<=\d)(?=(\d\d\d)+$)/', ',', $max2):"-";
				$max5_display=(is_numeric($max5))?preg_replace('/(?<=\d)(?=(\d\d\d)+$)/', ',', $max3):"-";
				$max10_display=(is_numeric($max10))?preg_replace('/(?<=\d)(?=(\d\d\d)+$)/', ',', $max10):"-";
				$max20_display=(is_numeric($max20))?preg_replace('/(?<=\d)(?=(\d\d\d)+$)/', ',', $max20):"-";

		if($exists=="F") # we must get the data
		{		
				# Pattern matching to detect illegal tabs in defline (all fasta) - result has the power to set $valid="F"
				$defline_tabs=0; #(default)
				$pattern="/.+\.fa$/"; # All fasta
				if(preg_match($pattern, $filepath_scratch))
				{
				$defline_tabs=trim(`grep ">" $filepath_scratch | grep -P "\t" | wc -w`);
				}
		} # else $defline_tabs is defined by data from table
		
				$defline_tabs_display = ($defline_tabs==0)?"":"<h2 class=\"topmargin1 bottommargin1\"><span class=\"warning largerfont\">Warning detected tabs in defline:</span><span class=\"grayfont largerfont largerfont\"> $defline_tabs </span></h2>";
				$valid=($defline_tabs==0 && $valid!="F")?"T":"F";
				
		if($exists=="F") # we must get the data
		{
				$unit=get_sequence_unit($filepath);

		} # else $unit is defined by data from table
		
	## Pattern matching to detect repeat masking and illegal characters (nucleotide) - hardmaskX result has the power to set $valid="F"

		if($exists=="F" && $unit=="bp") # (for nucleotide files) we must get the data
		{
                $hardmaskN=0;
                $hardmaskX=0;
#				$pattern="/.+[^p][^p][^e][^p]\.fa$/"; # fasta file, not prot.fa or pep.fa
#				if(preg_match($pattern, $filepath_scratch))
				if($unit=="bp")
				{
				$hardmaskN=trim(`grep -v ">" $filepath_scratch | grep -o "[N]" | wc -w`); # Hard masked sequence (N) count
				$hardmaskX=trim(`grep -v ">" $filepath_scratch | grep -o "[xX]" | wc -w`);
				}
		} # else $hardmaskN and HardMaskX are defined by data from table
				$hardmaskN_percent = ($total == 0)?"": round(($hardmaskN/$total),4)*100; # Don't divide by zero!
				$hardmaskN_display = ($hardmaskN==0)?"":"<h2 class=\"topmargin1 bottommargin1\">N-Masked residues:<span class=\"grayfont largerfont largerfont\"> $hardmaskN ($hardmaskN_percent %)</span></h2>";
				$hardmaskX_display = ($hardmaskX==0)?"":"<h2 class=\"topmargin1 bottommargin1\"><span class=\"warning largerfont\">Warning detected non-standard bases (X):</span><span class=\"grayfont largerfont largerfont\"> $hardmaskX </span></h2>";
				$valid=($hardmaskX==0 && $valid!="F")?"T":"F";   # ERROR with cegma
				# build table
				$fastacontents=($batch=="T")?"":
				"
				<table class=\"featuretable topmargin1\">
				<caption style=\"font-weight:bold; text-align:left\" class=\"bigfont bottommargin1\">File statistics:</caption>
			<colgroup>
				<col width =\"10%\" />
				<col width =\"10%\" />
				<col width =\"10%\" />
				<col width =\"10%\" />
				<col width =\"10%\" />
				<col width =\"10%\" />
				<col width =\"10%\" />
				<col width =\"10%\" />
				<col width =\"10%\" />
				<col width =\"10%\" />
				<col width =\"10%\" />
			</colgroup>
			<tbody>
				<tr style=\"text-align: center\"  class=\"reverse_1 bold\">
					<th   rowspan=\"2\" >Fasta Sequences
					<th   rowspan=\"2\" >Aggregate Size ($unit)
					<th   rowspan=\"2\" >Average Size ($unit)
					<th colspan=\"7\">
					Sequence Length Distribution ($unit)
					</th>
				</tr>
				<tr style=\"text-align: center\"  class=\"reverse_1 bold\">
					<th>Largest 
					</th>
					<th>2<sup style=\"color:white\">nd</sup>
					</th>
					<th>5<sup style=\"color:white\">th</sup>
					</th>
					<th>10<sup style=\"color:white\">th</sup>
					</th>
					<th>20<sup style=\"color:white\">th</sup>
					</th>
					<th>Smallest
					</th>
					<th>Median 
					</th>
				</tr>
				<tr  style=\"text-align: center\"  class=\"grayfont bold\">
					<td>$entrycount_display
					</td>
					<td>$total_display
					</td>
					<td>$average_display
					</td>
					<td>$max1_display
					</td>
					<td>$max2_display
					</td>
					<td>$max5_display
					</td>
					<td>$max10_display
					</td>
					<td>$max20_display
					</td>
					<td>$min_display
					</td>
					<td>$median_display
					</td>
				</tr>
			</tbody>
			</table>
		"		;
        # Additional data for genome data file only (still in fasta loop):
			if($seqtype=="gdna")
			{
				$gdnasizes=($batch=="T")?"": # For non-batch display only
				"
				<table class=\"featuretable topmargin1\">
					<caption style=\"font-weight:bold; text-align:left\" class=\"bigfont bottommargin1\">Genomic DNA: 20 largest scaffold sizes:</caption>
				<colgroup>
					<col width =\"10%\" />
					<col width =\"10%\" />
					<col width =\"10%\" />
					<col width =\"10%\" />
					<col width =\"10%\" />
					<col width =\"10%\" />
					<col width =\"10%\" />
					<col width =\"10%\" />
					<col width =\"10%\" />
					<col width =\"10%\" />
				</colgroup>
					<tr  style=\"text-align: center\"  class=\"smallerfont\">
						<td>1</td><td>2</td><td>3</td><td>4</td><td>5</td><td>6</td><td>7</td><td>8</td><td>9</td><td>10</td>
					</tr>
					<tr  style=\"text-align: center\"  class=\"grayfont smallerfont\">
						<td>$max1
						</td>
						<td>$max2
						</td>
						<td>$max3
						</td>
						<td>$max4
						</td>
						<td>$max5
						</td>
						<td>$max6
						</td>
						<td>$max7
						</td>
						<td>$max8
						</td>
						<td>$max9
						</td>
						<td>$max10
						</td>
					</tr>
					<tr  style=\"text-align: center\"  class=\"smallerfont\">
						<td>11</td><td>12</td><td>13</td><td>14</td><td>15</td><td>16</td><td>17</td><td>18</td><td>19</td><td>20</td>
					</tr>
					<tr  style=\"text-align: center\"  class=\"grayfont smallerfont\">
						<td>$max11
						</td>
						<td>$max12
						</td>
						<td>$max13
						</td>
						<td>$max14
						</td>
						<td>$max15
						</td>
						<td>$max16
						</td>
						<td>$max17
						</td>
						<td>$max18
						</td>
						<td>$max19
						</td>
						<td>$max20
						</td>
					</tr>
				</table>
				"
				;
		    }  # end gdna only
		
 # Validate IDs using fasta-validate.pl (checks for duplicate ID, identifies all defline (header) types). Parse output and compile a message based on valid/nonvalid outcome
        if($exists=="F") # we must validate IDs (check for duplicates, fasta header defline type), build up a cumulative $fasta_validate_message and assign $fasta_defline
        {
        	$fasta_validate_message="";
 		    $validate_fasta=`/xGDBvm/scripts/fasta-validate.pl --output skip $filepath_scratch`;
		    $validate_fasta_truncated=substr($validate_fasta, 0, 500); //don't display entire text if it vomited errors
#		    $validate_output=nl2br($validate_fasta_truncated);
		    if(empty($validate_fasta_truncated)) # outcome if the file itself is empty or contains only non-fasta data
		    {
		    $fasta_validate_message="No fasta data found";
		    $valid="F";
		    $fastavalid="F";
			$fasta_style="alertnotice bold";
		    }
		    else
		    {
		    # Sample the first two outputs for both ERROR (dup) and Defline type (single or mixed). There is a line feed between each output which we'll use to distinguish 1st from 2nd. Resolve validity at each step. 
				$error1pattern="/^.*ERROR.*?'(\S*)'.*?\n.*$/sm";  // (sm allows line breaks) first ERROR line e.g. "ERROR: found duplicated sequence ID (gi) '111142456' in /xGDBvm/examples/example1/Ex1.dup.est.fa" (note that we allow empty quotes with this regex)
				$error2pattern="/^.*ERROR.*?'\S*'.*?\nERROR.*?'(\S*)'.*?\n*$/sm";  // second ERROR line (indicates 2 OR MORE dups)
								
				if(preg_match($error1pattern, $validate_fasta_truncated, $matches1)) # We have at least 1 dup
				{
					$duplicateid1=$matches1[1];
					$fasta_validate_message="A duplicate ID found ($duplicateid1); ";
					$fastavalid="F";
					$valid="F";
				}
				if(preg_match($error2pattern, $validate_fasta_truncated, $matches2)) # We have at least 2 dups
				{
					$duplicateid2=$matches2[1];
					$fasta_validate_message=$fasta_validate_message."A second duplicate ID found ($duplicateid2); more are possible. ";	
					$fastavalid="F";
					$valid="F";
				}
				
			    $defline1pattern="/^.*?Detected\s(\d+)?.*?'(\S+)'\sdefline.*?\n.*$/sm";  // from output e.g. "Detected 146 sequences with 'GenBank' defline format"; first defline result
				$defline2pattern="/^.*?Detected\s\d+?.*?'\S+'\sdefline.*?\n.*Detected\s(\d+).*?'(\S+)'\sdefline.*/sm";  // from output e.g in addition to above, "Detected 4 sequences with 'idonly' defline format"; second defline result (BAD! Means mixed types)
				
				if(preg_match($defline1pattern, $validate_fasta_truncated, $matches1))
				{
					$deflinecount1=$matches1[1];
					$deflinetype1=$matches1[2];
					$fasta_validate_message=$fasta_validate_message."Detected $deflinecount1 sequences with $deflinetype1 defline; ";
					$fastavalid=($fastavalid!="F")?"T":"F"; # could have been invalid from above
					$valid=($valid!="F")?"T":"F";  # could have been invalid from above
					$fasta_defline=$deflinetype1; # Stored variable; Either GenBank or IDonly
				}
				if(preg_match($defline2pattern, $validate_fasta_truncated, $matches2))
				{
					$deflinecount2=$matches2[1];
					$deflinetype2=$matches2[2];
					$fasta_validate_message=$fasta_validate_message."Detected $deflinecount2 sequences with $deflinetype2 defline";
					$valid="F";
					$fastavalid="F";
					$fasta_defline="Mixed!! ($deflinetype1 and $deflinetype2)";
				}

		    }
		} # else $exists ="T" so use database value for $fasta_validate_message

		$fasta_style=($fastavalid=="T")?"checked":"alertnotice bold"; 
		$fasta_validate_display="<h2 class=\"topmargin1 bottommargin1\">Fasta validation (sequence type: ${seqtype}; units: ${unit} ${seq_type_count_display})</h2><span class=\"$fasta_style\"> $fasta_validate_message</span>";
		    
	} # end fasta only loop


###### INSERT into to database if NEW data; UPDATE (overwrite) ValidationTimeStmp for EXISTING data. #########

if($exists=="F") # we just got all this data from the actual file (or a temp file)
{
	mysql_select_db("$global_DB");
	$query="INSERT INTO Datafiles SET
	Valid='$valid',
	UserFile='$user_file',
	ValidationTimeStamp='$validation_time_stamp',
	FileName='$file',
	Path='$path',
	FileStamp='$filestamp',
	FileSize='$filesize',
	SeqType='$seqtype',
	SeqTypeCount='$seqtypecount',
	Format='$format',
	Track='$track',
	EntryCount='$entrycount',
	SizeTotal='$total',
	SizeAverage='$average',
	SizeMedian='$median',
	SizeSmallest='$min',
	SizeLargest='$max1',
	Size2='$max2',
	Size3='$max3',
	Size4='$max4',
	Size5='$max5',
	Size6='$max6',
	Size7='$max7',
	Size8='$max8',
	Size9='$max9',
	Size10='$max10',
	Size11='$max11',
	Size12='$max12',
	Size13='$max13',
	Size14='$max14',
	Size15='$max15',
	Size16='$max16',
	Size17='$max17',
	Size18='$max18',
	Size19='$max19',
	Size20='$max20',
	HardMaskN='$hardmaskN',
	HardMaskX='$hardmaskX',
	FastaValid='$fastavalid',
	DeflineTabs='$defline_tabs',
	FastaValidateMessage='$fasta_validate_message',
	FastaDefline='$fasta_defline',
	SampleContents='$sample_contents',
	Duplicates='$duplicates',
	Unit='$unit',
	Genes='$genes',
	Transcripts='$transcripts',
	Entries='$entries',
	GSQAlignments='$gsqalignments',
	GTHAlignments='$gthalignments'
	"
	;
	$execute = mysql_query($query);
	echo $execute;

    ### Add record to 'Validation' table
	mysql_select_db("$global_DB");
	$insert_query="INSERT INTO Validation (FileStamp, ValidationTimeStamp) VALUES ('$filestamp', '$validation_time_stamp')"; //  
    $execute = mysql_query($insert_query);
	
    if($batch=="T")
    {
    $message= "(xGDB_validate.php)  New data saved to the database table Datafiles";
#    error_log($message."\n\n");
    }
}

###### xGDBvm-iPlant only, we remove scratch file after evaluating it;########
     # make sure scratch directory exists and contains the scratch file we've just evaluated, then delete the scratch file.
     # We take extra care to make sure we are not deleting anything other than the scratch file we created!

if ($exists=="F" && file_exists("/xGDBvm/admin/iplant") && file_exists("/xGDBvm/data/scratch") && file_exists("/xGDBvm/data/scratch/temp_$file")) 
{
    $remove_scratch_file = `rm /xGDBvm/data/scratch/temp_$file`;
}

####### Finally display the data (non-batch only) ########

if($batch != "T")

{
	if($valid=="T")
	{
	$valid_display="<span class=\"checked\">Contents PASSED VALIDATION</span>";
	}
	elseif($valid=="F")
	{
	$valid_display="<span class=\"warning bold\">Contents FAILED VALIDATION</span><span class=\"heading\"> (see below)</span>";
	}
	else
	{
	$valid_display="<span class=\"alertnotice bold\">NOT VALIDATED</span>";
	}

	$formatted_contents = "
	
	<div class=\"feature\" >

	<span class= \"alertnotice bold\"> $error</span>

	<h1 class=\"bottommargin1 configure\"> $file <span class=\"heading\"> $exists-$filestamp $valid_display </span></h1>

	<h2 class=\"topmargin1 bottommargin1\"> File path:	<span class=\"grayfont largerfont\">$filepath </span></h2> 
	<h2 class=\"topmargin1 bottommargin1\"> File size: <span class=\"grayfont largerfont\">$filesize_display </span></h2>


	$fastacontents

	$gdnasizes

	$hardmaskN_display

	$hardmaskX_display

	$xresidues_display

	$defline_tabs_display

	$gsqcontents

	$gthcontents

	$gff3contents

	$txtcontents

	<h2 class=\"topmargin1 bottommargin1\">Sample contents (first 200 char)</h2>
	<pre class=\"largerfont\">$sample_contents_html</pre>

	$fasta_validate_display
	
	<div class=\"feature\">
	<span class=\"heading\"> NOTE: This script checks for duplicate IDs and classifies each fasta defline by type (ID only versus GenBank). Mixed ID types are NOT ALLOWED for spliced alignment inputs</span>
	</div>
	</div>

	";

	echo $formatted_contents;
}

?>

