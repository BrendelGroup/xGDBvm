<?php

##########################
# Data Display Functions #
##########################

//for building directory dropdown for e.g. new.php, view.php Input_Data_Directory

//$input_dirlist=dirlist_dropdown($dir1_dropdown, $dir2_dropdown, $dir3_dropdown, "$Input_Data_Path");//build dropdown for input dir(s)

	function dirlist_dropdown($dir1, $dir2, $dir3, $selected) // we allow option for 3 distinct input directories;
	{
		if($selected!="")
		{
		$dropdown_result="<option selected =\"selected\" value=\"$selected\">$selected</option>\n\n";  // if $selected is not empty, select it as default
		}
		else
		{
		$dropdown_result="";
		}
		$dirs=array($dir1, $dir2, $dir3);
		$dirs=array_filter($dirs); // clear empty elements
		foreach($dirs as $dir) // create a list combining all input directories
		{
            $d_list =`ls -l ${dir} | grep '^d'`; // list only directories under $dir
    #		$d_list = explode( "\s+", $d_list );
            $d_list = preg_split('/\n/', $d_list);
            $i=0;
            if (count($d_list) < 100 ) //safety measure
            {
                foreach ( $d_list as $d_row )
                {
                    $pattern="/^\S+\s+\d+\s+.*\s+(\S+)$/"; // "drwxrwxr-x.  11 apache root  4096 Mar  3 00:42 xGDBvm" => "11" "xGDBvm"
                    $d_pattern=preg_match($pattern, $d_row, $matches);
                    $d_name = isset($matches[1])?$matches[1]:"";
                    if($d_name!="") //at least one subdirectory exists
                    {
                        $i=$i+1;
                        $dropdown_result.= "<option value=\"${dir}${d_name}/\">${dir}${d_name}/</option>\n\n"; //add trailing slash by convention for directories
                    }
                }
                $dropdown_result.= "<option value=\"${dir}\">${dir}</option>\n\n";
            }
        }
        return $dropdown_result;
	}

//for building file dropdown for Repeat Mask, Reference Protein in new.php, view.php

	function filelist_dropdown($dir1, $dir2, $selected) // we allow option for 2 distinct input directories;
	{
		if($selected!="")
		{
		$dropdown_result="<option selected =\"selected\" value=\"$selected\">$selected</option>\n\n";  // if $selected is not empty, select it as default
		}
		else
		{
		$dropdown_result="";
		}
		$dirs=array($dir1, $dir2);
		$dirs=array_filter($dirs); // clear empty elements
		foreach($dirs as $dir) // create a list combining all input directories
		{
   #         $f_list =`ls -l ${dir} | grep -v '^d'`; // don't list directories under $dir
            $f_list =`ls -l ${dir} | grep -v '^d'`; // don't list directories under $dir
    #		$f_list = explode( "\s+", $f_list );
            $f_list = preg_split('/\n/', $f_list);
            $i=0;
            if (count($f_list) < 50 ) //safety measure
            {
                foreach ( $f_list as $f_row )
                {
                    $pattern="/^\S+\s+\d+\s+.*\s+(\S+\.fa)$/"; // "rwxrwxr-x.  11 apache root  4096 Mar  3 00:42 testfile.fa" =>  "testfile.fa"
                    $f_pattern=preg_match($pattern, $f_row, $matches);
                    $f_name = isset($matches[1])?$matches[1]:"";
                    if($f_name!="") //at least one subdirectory exists
                    {
                        $i=$i+1;
                        $dropdown_result.= "<option value=\"${dir}${f_name}\">${dir}${f_name}</option>\n\n";
                    }
                }
               # $dropdown_result.= "<option value=\"${dir}\">${dir}</option>\n\n"; //
            }
        }
        return $dropdown_result;
	}

### The following two functions work together to create a GDB record display with totals per feature type and a link to a sample record for each.

## build link allowing user to click on glyph and view example record.

function build_record_link($DBID, $title, $type, $track, $glyph, $count){ // $type is Loci, Proteins, Transcripts; and $track is SITEDEF.php subarray e.g. 0=est, 1=cdna, 2=tsa, etc.
#	$link="<a  style='text-decoration:none' title='$count $title (click to view example)' href='/$DBID/cgi-bin/getRecord.pl?dbid=0;resid=$num;gsegUID=1'><img alt='?' src='/XGDB/images/$glyph'  class='nudge2'/> $count</a> &#124; &nbsp;";
	$link="<a  style='text-decoration:none' title='$count $title (click to view tabular list)' href='/XGDB/phplib/Display${type}.php?GDB=${DBID}&amp;track=$track'><img alt='?' src='/XGDB/images/$glyph'  class='nudge2'/> $count</a>&nbsp; &#124; ";
	return $link;
}
## build glyphs with counts using function above 
function get_feature_totals($DB){

		mysql_select_db("$DB");

		$query0= "SELECT COUNT(*) FROM gseg"; // Count
		$result0 = mysql_query($query0);
		$gseg_array = mysql_fetch_array($result0);
		$gseg_count = $gseg_array[0];
		$gseg_display="$gseg_count ";

		$query2 = "SELECT SUM(Length(seq)) FROM gseg"; // Length
		$result2 = mysql_query($query2);
		$gseg_array = mysql_fetch_array($result2);
		$gseg_len = $gseg_array[0];
		$gseg_display2="($gseg_len bp) ";

		$query1= "SELECT COUNT(*) FROM mask"; // Mask
		$result1 = mysql_query($query1);
		$mask_array = mysql_fetch_array($result1);
		$mask_count = $mask_array[0];
		$mask_display=($mask_count=="0")?"":"$mask_count N-masked regions";

		$query10= "SELECT COUNT(*) FROM gseg_mask_good_pgs where isCognate=\"True\""; // Mask
		$result10 = mysql_query($query10);
		$repmask_array = mysql_fetch_array($result10);
		$repmask_count = $repmask_array[0];
		$repmask_display=($repmask_count=="0")?"":"($repmask_count repeat-masked)";
		
		$query3= "SELECT COUNT(*) FROM gseg_est_good_pgs"; // Count
		$result3 = mysql_query($query3);
		$est_array = mysql_fetch_array($result3);
		$est_count = $est_array[0];
#		$est_display=($est_count=="0")?"":build_record_link($DB,"EST spliced alignments", "6", "transcripts_est.png", $est_count);
		$est_display=($est_count=="0")?"":build_record_link($DB,"EST spliced alignments", "Transcripts", "EST-0", "transcripts_est.png", $est_count);

		$query4= "SELECT COUNT(*) FROM gseg_cdna_good_pgs"; // Count
		$result4 = mysql_query($query4);
		$cdna_array = mysql_fetch_array($result4);
		$cdna_count = $cdna_array[0];
#		$cdna_display=($cdna_count=="0")?"":build_record_link($DB,"cDNA spliced alignments", "5", "transcripts_cdna.png", $cdna_count);
		$cdna_display=($cdna_count=="0")?"":build_record_link($DB,"cDNA spliced alignments", "Transcripts", "CDNA-0", "transcripts_cdna.png", $cdna_count);

		$query5= "SELECT COUNT(*) FROM gseg_put_good_pgs"; // Count
		$result5 = mysql_query($query5);
		$tsa_array = mysql_fetch_array($result5);
		$tsa_count = $tsa_array[0];
#		$tsa_display=($tsa_count=="0")?"":build_record_link($DB,"TSA spliced alignments", "7", "transcripts_put.png", $tsa_count);
		$tsa_display=($tsa_count=="0")?"":build_record_link($DB,"TSA spliced alignments", "Transcripts", "TSA-0", "transcripts_put.png", $tsa_count);

		$query6= "SELECT COUNT(*) FROM gseg_pep_good_pgs"; // Count
		$result6 = mysql_query($query6);
		$pep_array = mysql_fetch_array($result6);
		$pep_count = $pep_array[0];
#		$pep_display=($pep_count=="0")?"":build_record_link($DB,"protein spliced alignments", "4", "proteins.png", $pep_count);
		$pep_display=($pep_count=="0")?"":build_record_link($DB,"protein spliced alignments", "Proteins", "0", "proteins.png", $pep_count);

		$query7= "SELECT COUNT(*) FROM gseg_gene_annotation"; // Count
		$result7 = mysql_query($query7);
		$gene_array = mysql_fetch_array($result7);
		$gene_count = $gene_array[0];
#		$gene_display=($gene_count=="0")?"":build_record_link($DB,"Gene predictions (pre-computed)", "3", "genemodels.png", $gene_count);
		$gene_display=($gene_count=="0")?"":build_record_link($DB,"Gene predictions (pre-computed)", "Loci", "0", "genemodels.png", $gene_count);

		$query8= "SELECT COUNT(*) FROM gseg_cpgat_gene_annotation"; // Count
		$result8 = mysql_query($query8);
		$cpgat_array = mysql_fetch_array($result8);		
		$cpgat_count = $cpgat_array[0];
#		$cpgat_display=($cpgat_count=="0")?"":build_record_link($DB,"CpGAT gene predictions", "2", "cpgatmodels.png", $cpgat_count);
		$cpgat_display=($cpgat_count=="0")?"":build_record_link($DB,"CpGAT gene predictions", "Loci", "1", "cpgatmodels.png", $cpgat_count);

		$query9= "SELECT COUNT(*) FROM user_gene_annotation where status=\"ACCEPTED\""; // Count
		$result9 = mysql_query($query9);
		$yrgate_array = mysql_fetch_array($result9);		
		$yrgate_count = $yrgate_array[0];
#		$yrgate_display=($yrgate_count=="0")?"":build_record_link($DB,"Community Annotations via yrGATE", "1", "yrgatemodels.png", $yrgate_count);
        $yrgate_display=($yrgate_count=="0")?"":"<a style='text-decoration:none' title='$yrgate_count $title (click to view tabular list)' href=\"/yrGATE/${DB}/CommunityCentral.pl\"><img alt='?' src='/XGDB/images/yrgatemodels.png'  class='nudge2'/> $yrgate_count</a> &#124;";

        $totals_string= "$gseg_display Segments $gseg_display2  $mask_display &nbsp; $repmask_display &nbsp; &#124; &nbsp; $est_display  $cdna_display $tsa_display  $pep_display $gene_display $cpgat_display $yrgate_display";


return $totals_string;
}


##########################
# Example Data Functions #
##########################


#Get Example data, if any (two-column format; see http://www.homeandlearn.co.uk/php/php10p7.html)

function get_example_data($filename)
{
		$fd = fopen($filename, "r");
		$data = array();
				while (!feof($fd) ) 
				{
				$line_of_text = fgets($fd);
				$parts = explode("\t", $line_of_text); //parse two-column input.
#				echo "parts0 = ".$parts[0] . "; parts1 = ". $parts[1]."<br />";
				$field= $parts[0];
				$value=trim($parts[1]);
				$data["$field"] =$value;
#				echo "field = ".$field.";  value = ".$value."<br />";
				}
			fclose($fd);		
return $data;
}

function get_example_text($ID, $save_text)
	{
	
	$Example_Text = "<table id=\"single_example\" class=\"topmargin1\">
    	<colgroup>
    	    <col width=\"20%\" />
    	    <col width=\"80%\" />
    	</colgroup>
    	    <tr>
    	        <td>";
		switch ($ID)
		{
    case 1:
        $Example_Text .= "<span class=\"xgdb_button colorR5\" id=\"selected\">Example 1</span></td><td class=\"\"> This Example demonstrates the basic 'Database Create' function of xGDBvm using a small input dataset.</td></tr></table>
        <p>The dataset consists of 4 genomic scaffolds from <i>Ricinus communis</i>, transcripts, related-species proteins, and precomputed gene models (GFF3 and fasta) (<a href=\"/examples/example1/\">View Input Dataset Here</a>).</p>
        ";
        $Example_Text.=$save_text;
		$save_button = "Save Example 1";
        break;
    case 2:
        $Example_Text .= "<span class=\"xgdb_button colorR6\" id=\"selected\">Example 2</span> </td><td class=\"\"> This Example demonstrates the 'Database Update' feature of xGDBvm.</td></tr></table>
        <p>'Update' allows you to append or replace any data type for an existing GDB. Example $ID is pre-configured to demonstrate this. You only need to follow these <b>three steps</b>:</p>
        <ul class=\"menulist\">
            <li>(1) First, click 'Save Example 2' and then select 'Database Options...' &rarr; 'Create GDB'</li>
            <li>  - This creates a GDB based on a small <a href=\"/examples/example2/\">Input Dataset</a>: two scaffolds with transcript/proteins and gene models</li>
            <li>(2) Click 'Edit Configuration' and activate the 'Update' option by clickin the 'Yes' radio button under 'Update Data and Actions'</li>
            <li>  - Two update actions are pre-configured: 1) Append two scaffolds  and 2) append precomputed gene models</li>
            <li>  - An <a href=\"/examples/example2/new_data/\">Update Dataset Directory</a> is pre-configured containing update datafiles</li>
            <li>(3) Finally, click 'Save' and select 'Database Options...' &rarr; 'Update GDB' to complete the example.</li>
        </ul>
        ";
        $Example_Text.=$save_text;
		$save_button = "Save Example 2";
        break;
    case 3:
        $Example_Text .= "<span class=\"xgdb_button colorR7\" id=\"selected\">Example 3 </span> </td><td class=\"\">This Example Dataset demonstrates the use of <b>pre-computed spliced alignments.</b></td></tr></table>
        <p>GeneSeqer or GenomeThreader output files, appropriately named <img id='config_precomp_spalign' title='Search Help' class='help-button' src='/XGDB/images/help-icon.png' alt='?' />, can simply be included as part of the <a href=\"/examples/example3/\">Input Dataset</a> to bypass any transcript spliced alignment computations.</p>
        ";
        $Example_Text.=$save_text;
		$save_button = "Save Example 3";

        break;
    case 4:
        $Example_Text .= "<span class=\"xgdb_button colorR8\" id=\"selected\">Example 4</span> </td><td class=\"\">This <b>Example Dataset</b> demonstrates the addition of <b>CpGAT Annotation</b> to the GDB workflow.</td></tr></table>
        <p><b>CpGAT</b> &nbsp;<img id='cpgat_overview' alt='cpgat' title='Search Help' class='help-button' />&nbsp; is a tool that computes gene structure models and splicing variants from evidence alignments and <i>de novo</i> gene predictions, and displays them as a track in the GDB browser.</p>
        ";
        $Example_Text.=$save_text;
        $save_button = "Save Example 4";

        break;
    case 5:
        $Example_Text .= "<span class=\"xgdb_button colorR9\" id=\"selected\">Example 5</span> </td><td class=\"\"> This Example demonstrates the 'Database Update' feature of xGDBvm, with CpGAT option.</td></tr></table>
        <p>'Update' allows you to append or replace any data type for an existing GDB. Example $ID is pre-configured to demonstrate these steps:</p>
        <ul class=\"menulist\">
        <li>(1) First, create a new GDB (with CpGAT option) using an <a href=\"/examples/example2/\">Input Dataset</a> (two scaffolds with transcript/protein spliced alignments and gene models) and a <a href=\"/examples/example2/\">reference protein dataset</a> for CpGAT.</li>
        <li>(2) Select the 'Update' option in the Config file to allow new data to be added.</li> 
        <li>(3) Specify update actions and data types: <b>Append</b> scaffolds, transcripts, proteins, gff, and CpGAT annotations.</li>
        <li>(4) Specify an <a href=\"/examples/example2/new_data/\">Update Dataset</a> where the update files will be placed.</li>
        <li>(5) When the above configuration is in place, select 'Database Options...' &rarr; 'Update GDB'.</li>
        </ul>
        ";
        $Example_Text.=$save_text;
		$save_button = "Save Example 5";
        break;
    case 6:
        $Example_Text .= "<span class=\"xgdb_button colorR10\" id=\"selected\">Example 6</span> </td><td class=\"\"> This Example demonstrates the 'Repeat Mask' feature of xGDBvm, with CpGAT option.</td></tr></table>
        <p>'Repeat Mask' uses an indexed FASTA file of know repeat sequences to mark genomic regions with 'X' using <a href=\"http://www.vmatch.de/\">Vmatch</a>. </p>
        <p>Example $ID is pre-configured to demonstrate this using 'fake' repeats which are actually genic regions:</p>
        ";
        $Example_Text.=$save_text;
		$save_button = "Save Example 6";
        break; 
    case 7:
        $Example_Text .= "<span class=\"xgdb_button colorR11\" id=\"selected\">Example 7</span> </td><td class=\"\"> This Example demonstrates the 'Update CpGAT' feature of xGDBvm.</td></tr></table>
        <p>First, create a new GDB using config defaults, then Select the 'Update' option in the Config file to allow new data to be added. It will already be configured to replace existing CpGAT annotations (of course there are none) </p>
        ";
        $Example_Text.=$save_text;
		$save_button = "Save Example 7";
        break; 
    case 8:
        $Example_Text .= "<span class=\"xgdb_button colorR12\" id=\"selected\">Example 8</span> </td><td class=\"\"> This Example demonstrates the <a class=\"help_style \" href=\"/XGDB/help/remote_jobs.php\"> Remote HPC </a>feature of xGDBvm, using a small EST (GeneSeqer) dataset</td></tr></table>
        <p><b>If selecting this option:</b> Your VM must be <a href=\"/XGDB/jobs/index.php\"/>configured</a> for HPC, and you must be logged in. </p>
        ";
        $Example_Text.=$save_text;
		$save_button = "Save Example 8";
        break;
    case 9:
        $Example_Text .= "<span class=\"xgdb_button colorR13\" id=\"selected\">Example 9</span> </td><td class=\"\"> This Example demonstrates the <a class=\"help_style \" href=\"/XGDB/help/remote_jobs.php\"> Remote HPC </a>feature of xGDBvm, using a protein (GenomeThreader) dataset</td></tr></table>
        <p><b>If selecting this option:</b> Your VM must be <a href=\"/XGDB/jobs/index.php\"/>configured</a> for HPC, and you must be logged in. </p>
        ";
        $Example_Text.=$save_text;
		$save_button = "Save Example 9";
        break;
    case 10:
        $Example_Text .= "<span class=\"xgdb_button colorR14\" id=\"selected\">Example 10</span> </td><td class=\"\"> This Example includes diverse file errors and omissions designed to test the error flagging system.</td></tr></table>
        <p><b>If selecting this option, run the 'Data Process Options...' -> 'Validate My Input Data' script and note the error flags that result. </p>
        ";
        $Example_Text.=$save_text;
		$save_button = "Save Example 9";
        break;
    case 'All':
    	$Example_Text = "<p class=\"bottommargin1 instruction\">See how the process works! Click one of the <span class=\"xgdb_button colorR6\">Example</span> buttons to load its configuration, click 'Save', and then follow directions to complete the process.  </p><p><a href=\"/XGDB/conf/new.php\">Hide Examples</a></p>
    	<table id=\"all_examples\" class=\"topmargin1\">
    	<colgroup>
    	    <col width=\"20%\" />
    	    <col width=\"80%\" />
    	</colgroup>
    	<tr><td><a class= \"xgdb_button colorR5\" href=\"/XGDB/conf/new.php?example=1\">Example 1</a></td><td> <b>Simple GDB</b>: 4 scaffolds with spliced-alignment of cDNA, EST, TSA, protein; gene model gff upload</td></tr> 
		<tr><td><a class= \"xgdb_button colorR6 \" href=\"/XGDB/conf/new.php?example=2\">Example 2</a> </td><td> <b>Update option</b>: 2 scaffolds from Example 1, but with option to add 2 additional scaffolds (GDB Update Option)</td></tr> 
		<tr><td><a class= \"xgdb_button colorR7 \" href=\"/XGDB/conf/new.php?example=3\">Example 3</a> </td><td> <b>Precomputed data</b>: 4 scaffolds as in Example 1, but with pre-computed spliced alignments (cDNA, EST, TSA, protein)</td></tr>  
		<tr><td><a class= \"xgdb_button colorR8 \" href=\"/XGDB/conf/new.php?example=4\">Example 4</a> </td><td> <b>CpGAT option</b>: 4 scaffolds as in Example 1, but including optional CpGAT annotation</td></tr>
		<tr><td><a class= \"xgdb_button colorR9 \" href=\"/XGDB/conf/new.php?example=5\">Example 5</a>  </td><td> <b>Update + CpGAT option</b>: 2 scaffolds with CpGAT, updatable with 2 additional scaffolds and CpGAT</td></tr>
		<tr><td><a class= \"xgdb_button colorR10 \" href=\"/XGDB/conf/new.php?example=6\">Example 6</a> </td><td>  <b>RepeatMask + CpGAT option</b>: 4 scaffolds with CpGAT, genome masked in several genic regions using Vmatch</td></tr>
		<tr><td><a class= \"xgdb_button colorR11 \" href=\"/XGDB/conf/new.php?example=7\">Example 7</a> </td><td>  <b>Precomputed data + Update CpGAT:</b> Create simple GDB with spliced alignments, and then run CpGAT later as an update.</td></tr>
		<tr><td><a class= \"xgdb_button colorR12 \" href=\"/XGDB/conf/new.php?example=8\">Example 8</a> </td><td>  <b>Spliced Alignment of EST (HPC)</b>: Create a GDB with EST spliced alignments processed remotely on a high-performance computing platform (iPlant only; see <a href=\"/XGDB/jobs/index.php\">Remote HPC</a> for requirements)</td></tr>
		<tr><td><a class= \"xgdb_button colorR13 \" href=\"/XGDB/conf/new.php?example=9\">Example 9</a> </td><td>  <b>Spliced Alignment of proteins (HPC)</b>: Create a GDB with protein spliced alignments processed remotely on a high-performance computing platform (iPlant only; see <a href=\"/XGDB/jobs/index.php\">Remote HPC</a> for requirements)</td></tr>
		<tr><td><a class= \"xgdb_button colorR14 \" href=\"/XGDB/conf/new.php?example=9\">Example 10</a> </td><td>  <b>Error Test</b>: Includes numerous different file errors and omissions designed to test the error flagging system</td></tr>
		</table>
		";
		$Example_Text.="";
		$save_button="";
	}
	return array($Example_Text, $save_button);
}
##########################
# Validation Functions   #
##########################


function check_int( $str ) //http://php.net/manual/en/language.types.type-juggling.php
	{
		return  is_numeric( $str ) && intval( $str ) - $str == 0;
	}

//returns presence/absence of a key directory and a css class for markup
function validate_dir($dir, $target, $description, $present, $absent) //$dir is the containing dir; $target is the dir whose presence/absence we are testing; others are tags
        {
        $result=$absent; //assume the worst
		$d_list =`ls -a ${dir}`; #All files in data directory
        $d_array = preg_split('/\s+/', $d_list);	//split list by spaces into an array
		if (count($d_array) < 1000 ) //safety measure. NOT /usr/local/bin has a lot of files! So 100 is not a good cutoff...
			{
			foreach ( $d_array as $d_item ) // go through all subdirs and mark $present only if match.
					{

                        if($d_item == $target)
                        {
                        $result=$present;
                        }
                    }
            } // define css markup class to cover the various syntaxes 
            if($result=="present")
            	{
            	 $class= "checked";
				}
            elseif($result=="missing")
            	{
            	 $class= "warning";
				}
            if($result=="installed")
            	{
            	 $class= "checked_installed";
				}
            elseif($result=="not installed")
            	{
            	 $class= "warning";
				}
            elseif($result=="mounted")
            	{
            	 $class= "mounted";
				}
            elseif($result=="not mounted")
            	{
            	 $class= "local";
				}

            return array($result, $class);
		}

function data_directory($dir)
	{ //we want display contents of the directory specified above

		$d_files=""; // 
		$d_list =`ls ${dir}`; #All files in data directory
		$d_list = explode( "\s+", $d_list );
		if (count($d_list) < 100 )
		{ #avoid huge directories.

			foreach ( $d_list as $d_item )
					{
						$d_files .= $d_item."\n";
					}
		}
	return $d_files;	
	}



function df_available($dir)
	{ //we want display available space and directory list in the specified volume

		$df =`df ${dir}`; #
				$avail_match = "/.*\s*(\S+?)\s+(\d+?)\s+(\d+?)\s+(\d+?)\s+.*(\/.*)$/"; # last directory (non-greedy) 
				preg_match( $avail_match, $df, $matches);
				
				$filesys=$matches[1];
				$avail=$matches[4];
				$mount=$matches[5];
				
	return array($filesys, $avail, $mount);
	}



#finds identical volume sizes and creates styles to match (used in volumes.php for tabular display):

function find_shared_volumes($gb1, $gb2, $gb3, $gb4, $gb5, $gb6, $color1, $color2, $color3, $color4, $color5, $color6)
{

	$array1 = array($gb1, $gb2, $gb3, $gb4, $gb5, $gb6);
	$array2= array($color1, $color2, $color3, $color4, $color5, $color6);
	 for ($i=0; $i<=5; $i++)
	 {
		for ($j=$i+1; $j<=5; $j++)
		{
			if($array1[$j]==$array1[$i])
			{
				$array2[$j]=$array2[$i];
			}
		
		}
	}	
return $array2;  //return color map, 
}




function input_directory($Input_Data_Path, $Input_Dir){ //we want to find out if input directory is where the user says it is. UPdated 1-28-16

		$Input_Dir="";
		$Input_Dir = $Input_Data_Path;
		$i_exists=""; // 
		$i_list =`ls ${Input_Dir}/../`; #All directories at the level of the input specified by user
		$i_list = explode( "\s+", $i_list );
		if (count($i_list) < 100 ){ #avoid huge directories.
				$dir_match = "/.*\/(\S+?)\/*$/"; # last directory (non-greedy) 
				preg_match( $dir_match, $Input_Dir, $matches);
				$last_dir=$matches[1];
				$pattern = "/\b${last_dir}\b/";
			foreach ( $i_list as $i_item )
					{
						if (preg_match($pattern, $i_item))
						{
					$i_exists="Yes";
					}
				}
		}
	return $i_exists;	
	}

function output_directory($GDB, $Output_Dir){ //we want to find whether the output directory exists for this GDB; updated 1-28-16 to add Output_Dir param
		$o_exists=""; 
		$o_list =`ls $Output_Dir`;
		$o_list = explode( "\s+", $o_list );
		if (count($o_list) < 100 ){ #avoid huge directories.
			foreach ( $o_list as $o_item )
					{
						$pattern = "/\b${GDB}\b/";
						if (preg_match($pattern, $o_item))
						{
					$o_exists="Yes";
					}
				}
		}

	return $o_exists;
}	
		
function gdb_directory($GDB, $GDB_Dir) {	 //we want to find whether the GDB conf directory exists (matches Current Status)
		$g_exists=""; 
		$g_list =`ls $GDB_Dir`;
		$g_list = explode( "\s+", $g_list );
		if (count($g_list) < 100 ){ #avoid huge directories.
			foreach ( $g_list as $g_item )
					{
						$pattern = "/\b${GDB}\b/";
						if (preg_match($pattern, $g_item))
						{
					$g_exists="Yes";
					}
				}
		}
	return $g_exists;
}
//problem above
function archive_directory($GDB, $Archive_Dir) {	 //we want to find whether the Archive Single GDB directory exists for this GDB(matches Restore Status)	

#        $VM=`uname -n|cut -d "." -f 1`; # identifies this VM
		$a_exists=""; 
		$a_list =`ls $Archive_Dir`;
		$a_list = explode( "\s+", $a_list );
		if (count($a_list) < 100 ){ #avoid huge directories.
			foreach ( $a_list as $a_item )
					{
						$pattern = "/\b${GDB}\b/";
						if (preg_match($pattern, $a_item))
						{
					$a_exists="Yes";
					}
				}
		}
	return $a_exists;
}

function archive_dir_dropdown($data_dir, $archive_dir) {	 //dropdown list of /xGDBvm/data/ArchiveGDB/GDBnnn-~.tar.bz2 files ready to be restored; for new.php and view.php)	Updated 1-28-16 to include data_dir param
#        $VM=`uname -n|cut -d "." -f 1`; # identifies this VM
		$Archive_Path = "${data_dir}${archive_dir}"; // e.g. /xGDBvm/data/ArchiveGDB, from new.php  or view.php
		$xgdb_source="";
		$dcount=0;
		$arch_list =`ls -1 $Archive_Path`; //GDB001-~name.tar.bz2\n  GDB002-~name.tar\n  GDB004-~name.tar\n
		$arch_array = explode( "\n", $arch_list );
		$dropdown_result = "<option value=\"none\">Use GDB Archive (select)</option>\n";
		if (count($arch_array) < 100 ) #avoid huge directories.
			{
			foreach ( $arch_array as $arch_item )
					{
						$pattern = "/^(GDB\d\d\d)(-\S+)(\.tar)$/";
						if (preg_match($pattern, $arch_item, $matches))
							{
                                $xgdb_source=$matches[1];
                                $description=$matches[2];
                                $file="${xgdb_source}${description}.tar"; // does the archive directory exist 
                                if (file_exists("$Archive_Path/$file")) // if we have properly parsed the file as we can reconstruct its filename
                                {
                                    $description=substr($description, 0, 50);
                                    $dropdown_result .= "<option value=\"$file\">${xgdb_source}${description}</option>\n\n";
                                }
                                $dcount=$dcount+1;
							}
					}
			}
			
	$dropdown_result=($dcount>0)?$dropdown_result:"";
	return $dropdown_result;
#	return $arch_list;
#    return count($arch_array); //debug
}


function archiveall_directory($ArchiveAll_Dir) {	 //we want to find whether the Archive All GDB directory exists (matches Restore All Status)
 #       $VM=`uname -n |cut -d "." -f 1`; # identifies this VM. NO LONGER USING THIS AS IDENTIFIER 5/24/14 JPD
		$aa_exists=""; 
		$aa_list =`ls ${ArchiveAll_Dir}/../`;
		$aa_list = explode( "\s+", $aa_list );
		if (count($aa_list) < 100 ){ #avoid huge directories.
			foreach ( $aa_list as $aa_item )
					{
						$pattern = "/\bArchiveAll\b/";
						if (preg_match($pattern, $aa_item))
						{
					$aa_exists="Yes";
					}
				}
		}
	return $aa_exists;
}


	function get_file_codes($name) //called by create_file_list (below); matches file of name $name and creates a filename code string (single letters) for validation purposes
        {
                $code_string="";
                $types = array
                (
                        "gdna.fa"  => "g",
                        "gdna.rm.fa"  => "G",
                        "est.fa"   => "e",
                        "est.gsq"  => "E",
                        "cdna.fa"  => "c",
                        "cdna.gsq" => "C",
                        "tsa.fa"   => "t",
                        "tsa.gsq"  => "T",
                        "prot.fa"  => "p",
                        "prot.gth" => "P",
                        "annot.gff3"     => "a",
                        "annot.mrna.fa"  => "m",
                        "annot.cds.fa"   => "d",
                        "annot.pep.fa"   => "i",
                        "annot.desc.txt" => "s",
                        "cpgat.gff3" => "A",
                        "cpgat.mrna.fa" => "M",
                        "annot.cds.fa"   => "D",
                        "cpgat.pep.fa" => "I",
                        "cpgat.desc.txt" => "S",
                );
                foreach($types as $ext => $code)
                {
			$test = "/\S*".$ext."$/i";
                        if(preg_match($test, $name)) // there should be only one match per function call
                        {
                                $code_string.=$code;

                        }
                }
                    return "$code_string";
	}


### Under development! 1-15-13

	function validate_refpro_type($name, $fasta) //called by validate_refpro (below); matches file of name $name with standardized suffix and returns human-readable interpretation (if any) with validation stying, as part of file_list (see next function) ADDED 3/3/13: Also validates vmatch index filenames.
        {
                $types = array
                (
                        $fasta  => "fasta",
                        $fasta.".phr"  => "phr", //blast
                        $fasta.".pin"  => "pin",
                        $fasta.".pog"  => "pog",
                        $fasta.".psd"  => "psd",
                        $fasta.".psi"  => "psi",
                        $fasta.".psq"  => "psq",
                        $fasta.".al1"  => "al1", // vmatch from here on
						$fasta.".bck"  => "bck", 
						$fasta.".bwt"  => "bwt",
						$fasta.".des"  => "des", 
						$fasta.".lcp"  => "lcp",
						$fasta.".llv"  => "llv",
						$fasta.".ois"  => "ois",
						$fasta.".prj"  => "prj",	 
						$fasta.".sds"  => "sds",
						$fasta.".skp"  => "skp", 
						$fasta.".ssp"  => "ssp",
						$fasta.".sti1"  => "sti1", 
						$fasta.".suf"  => "suf",	 
						$fasta.".tis"  => "tis", 
                );
                foreach($types as $ext => $type)
                {
			$test = "/\S*".$ext."$/i";
                        if(preg_match($test, $name, $match))
                        {
                                return "<span class=\"checked\">$type: </span> ";
                        }
                }
        	return "";
	}


function validate_library($library_file_path, $type, $dbpass) //determines whether the file saved under xGDB_Log corresponds to an actual file e.g. "/home/xgdb-input/xgdbvm/referenceprotein/myreferenceproteins.fa, and if so, marks it up for display
{
		mysql_select_db("Genomes");

		$result="";
		$pattern="/(\/\S+\/)(\S+.fa)$/"; // 
		if(preg_match($pattern, $library_file_path, $matches) && (substr($library_file_path, 0, 8) =="/xGDBvm/")) # if we have the right top level directory path with trailing filename/extension
		{
		    $library_file_dir = $matches[1]; #  e.g. /home/xgdb-input/xgdbvm/referenceprotein/
		    $library_fasta = $matches[2];  # myreferenceproteins.fa
		    # now see if it exists here and capture its metadata
		    $item =`ls -l --time-style=long-iso $library_file_path`; // e.g. -rw-r--r--. 1 root root 5123 2014-06-25 12:38 /xGDBvm/examples/repeatmask/Rc_28153_Repeats.fa
			$pattern = "/\s+/";
			$replacement = " ";
			$item = preg_replace($pattern, $replacement, $item);
			
###### Parse the listed file entrty and add markup for Javascript, styling according to validation ######
			if ( substr( $item, 0, 1 ) == "-" ) # file not a directory
			{
				$vals = explode( " ", $item );
				$actual_file_path = $vals[count($vals)-2];
				
				if($actual_file_path == $library_file_path) # validity check 
				{
					$pattern="/(\/\S+\/)(\S*)$/"; // directory path with trailing filename
					$pattern_match=preg_match($pattern, $library_file_path, $matches);
					$library_dir = $matches[1];  # /xGDBvm/examples/referenceprotein/
					$library_file = $matches[2];  # myRefprot.fa

				   $time = $vals[count($vals)-3];
				   $year_month_day = $vals[count($vals)-4];
				   $size = $vals[count($vals)-5];
				   $filestamp = "$library_file:$size:${year_month_day}-$time"; # IMPORTANT: This format MUST be synchronized with FileStamp in /xGDBvm/scripts/xGDB_ValidateFiles.sh
					

##### Get validation data (if any) from MySQL table based on filestamp, and assign icon color according to result #####

				   $valid="";
				   $entries="";
				   $valid_style="contentsnoteval";
				   $file_info_icon="information.png"; // This icon communicates validation status (by color) and is a click target for opening validation dialog box
				   
				   if($get_entry="SELECT Valid, EntryCount FROM Datafiles where FileStamp='$filestamp'")
				   { 
					 $mysql_get_entry= mysql_query($get_entry); 
					 while($result_get_entry = mysql_fetch_array($mysql_get_entry))
					 {
					   $valid=$result_get_entry[0]; # T F or NULL
					   $entries=$result_get_entry[1]; # number of entries
					 }
				   }
				   if($valid=="T")
				   {
					  $file_info_icon="information_green.png";
					  $valid_style="filevalid";
#					  $v=$v+1;
				   }
				   elseif($valid=="F")
				   {
					  $file_info_icon="information_red.png";
					  $valid_style="filenotvalid";
#					  $iv=$iv+1;
				   }
##### Calculate size in a reasonable numeric range #####
					$unit = 0;
					$abs_size=0;
				    //0: bytes, 1: kilobytes, 2: megabytes, 3: gigabytes
				    while ($size > 1024 && $unit < 4)
				    {
				     	$size = round($size / 1024,2);
						$unit++;
					}
					$part2 = "<ul class=\"bullet1 indent2\"><li><span class=\"$valid_style\">$library_dir</span><span class=\"$valid_style italic\">$library_file</span>";
					$part2.= "&nbsp;<span id=\"$library_file_path\" class=\"validatefile-button\" title=\"$filestamp\"><img class=\"nudge3\" src=\"/XGDB/images/$file_info_icon\" />";
					$part2.="  / ${year_month_day} ${time} / $size ";
					
##### Display info icon appropriate for validity status (icon displayed is based on css class)#####

					$valid_display="<span class=\"contentsnoteval\">  not evaluated</span>"; # default
					$valid_display=($valid=="T")?"<span class=\"contentsvalid\">  valid file</span>":$valid_display;
					$valid_display=($valid=="F")?"<span class=\"contentsnotvalid\"> invalid file</span>":$valid_display;
					   
##### If file has been validated, # of entries is available from the MySQL query. Display value here at end of line. #####
				   $entries_styled=(empty($entries))?"":
				   "<span style=\"color:#00A592\"> 
					  / $entries entries
				   </span>";

##### Determine unit for display and compute absolute size in order to get cumulative total #####
					if($unit == 0) {$units = " bytes"; $abs_size = $size/1000000;}
					if($unit == 1) {$units = " KB"; $abs_size  = $size/1000;}
					if($unit == 2) {$units = " MB"; $abs_size = $size/1;}
					if($unit == 3) {$units = " GB";$abs_size =  $size/.001;}
					$part2.= $units;
					$part3="</span></li></div></div>";
					$part1 = "
					<div class=\"showhide\">
					<p class=\"label\" style=\"cursor:pointer\" title=\"Reference Protein Index for CpGAT Gene Annotation\"> 
						<span class=\"normalfont\">$type:</span>
						<span class=\"normalfont\"> $size $units</span> 
						<span class=\"heading\">$valid_display  $entries_styled (click for details)</span>
					</p>
				    <div class=\" hidden\" style=\"display: none;\">
					";
										
					$result = $part1.$part2.$part3;
				}
				else
				{
					$result="<span class=\"alertnotice bold warning normalfont\">$type file does not match database file </span>";
				}
			}
			else
			{
				$result="<span class=\"alertnotice bold warning normalfont\">$type file is missing </span>";
			}
		}
		else
		{
			$result="<span class=\"alertnotice bold warning normalfont\">Invalid or missing $type file</span>";
		}
		return($result); //

}

# Creates a formatted file list based on $input ($Input_Data_Path "dir" or an already-created archived list  "list").
# Flags any permissions problems with files in $input
# Uses sub-function validate_file_type($name, $class) to check validation and insert validation styling. 
#Formatted differently according to whether it's new or archival ($type). 
# $path is used to reiterate the actual path (since we don't have this from argument 1 if $input="list"); 
# $title is label, and $cutoff is threshold for warning (depends on input)

function create_file_list($input_dir, $type, $path, $title, $cutoff, $dbpass){

###### Connect to database ######
	$db = mysql_connect("localhost", "gdbuser", $dbpass);
	if(!$db)
	{
		echo "Error: Could not connect to database!";
		exit;
	}
	mysql_select_db("Genomes");
	
###### Default Variables ######
	$file_list2="";
	$total_size=0;
	$fileID="";
	$file_codes="";
	$abs_size=0;
	$total_size=0;
    $multifile_error="F";

###### Create or reproduce file list ######

	if($type=="list") //special case: we want to recreated formatted list from stored list
	{
	   $file_list=$input_dir; //
	}
	else 	 # $type="dir" or blank; we want to validate and format a directory list call
	{
	   $file_list =`ls -l --time-style=long-iso $input_dir`; //
	}		
	$list = explode( "\n", $file_list ); # file list array
	$n=0; //valid file count
	$p_flag = ""; $p_hints = ""; //permissions problems default -assume none

###### Parse each item on file list and add markup for Javascript, styling according to validation ######

	# escape all forward slashes since we are going to put them in an id
	$escaped_path=($type=="dir")?str_replace("/", "\/", $input_dir):"";  # We only want to assign this if input is directory.

	if (count($list) < 100 ){ #avoid huge directories.
		$v=0; #valid file count
		$iv=0; #invalid file count
		
		foreach ( $list as $item )
				{
					$pattern = "/\s+/";
					$replacement = " ";
					$item = preg_replace($pattern, $replacement, $item); # collapase spaces
					
###### Select file listings (not directories), parse filename, and run filename validation function   ######

					if ( substr( $item, 0, 1 ) == "-" ) // identifies file (-rw-r--r-- etc) as opposed to directory (drwxrwxr-x etc.)
					{
						$vals = explode( " ", $item );
						
						$filename = $vals[count($vals)-1]; //e.g. the filename, MyFile_est.fa

##### For valid files, parse metadata, create unique filestamp, and start to build a marked-up listing #####

						if(validate_file_type($filename, "")!="")  # We want to list ONLY valid filenames in this directory, not ALL files.
						{
						   $n=$n+1; # To list all files in directory, not just valid ones, move right angle bracket from below to this line.
						   
					       $time = $vals[count($vals)-2];
						   $year_month_day = $vals[count($vals)-3];
						   $size = $vals[count($vals)-4];
						   $filestamp = "$filename:$size:${year_month_day}-$time"; # IMPORTANT: This format MUST be synchronized with FileStamp in /xGDBvm/scripts/xGDB_ValidateFiles.sh
						   
##### Get validation data (if any) from MySQL table based on filestamp, and assign icon color according to result #####

						   $valid="";
						   $entries="";
						   $valid_style="normalfont";
						   $file_info_icon="information.png"; // This icon communicates validation status (by color) and is a click target for opening validation dialog box
						   $validation_time_stamp="";
					       if($get_entry="SELECT Valid, EntryCount, ValidationTimeStamp FROM Datafiles where FileStamp='$filestamp'")
						   { 
							 $mysql_get_entry= mysql_query($get_entry); 
							 while($result_get_entry = mysql_fetch_array($mysql_get_entry))
							 {
							   $valid=$result_get_entry[0]; # T F or NULL
							   $entries=$result_get_entry[1]; # number of entries
							   $validation_time_stamp=$result_get_entry[2]; # we use this to find out if there are any multi-file duplication records in Datafiles (see below)
							 }
						   }
						   if($valid=="T")
						   {
							  $file_info_icon="information_green.png";
							  $valid_style="filevalid";
							  $v=$v+1;
						   }
						   elseif($valid=="F")
						   {
							  $file_info_icon="information_red.png";
							  $valid_style="filenotvalid";
							  $iv=$iv+1;
						   }
						   else
						   {
							  $file_info_icon="information.png";
							  $valid_style="filenoteval";
						   }						   
##### Build more markup including escaped filepath and validation icons.  #####

						   $filepath = ($type=="dir")?$escaped_path."\/".$filename:""; // We use this as a unique ID tag (with escaped slashes) for opening a Jquery dialog when user clicks icon.						   
						   $info_icon_styled=($type=="dir")? # markup for Jquery function. Icon color determined by validation result
						      "
						      <span id=\"$filepath\" class=\"validatefile-button\" title=\"$filestamp\">
						         <img class=\"nudge3\" src=\"/XGDB/images/$file_info_icon\" />
						      </span>
						      "
						      :""; 

##### Get filename code using function that classifies a file type as single-letter code. Concatenate to any previous code string.

						   $file_codes.= get_file_codes($filename); // 

##### Get the filename class (e.g. est, cdna, etc) based on the filename suffix. Style this for display. ######

						   $class=($type=="list")? "darkgrayfont":"$valid_style"; # style with colors and image unless it's just a reconstition of the file list.
						   $filename_class = validate_file_type($filename, $class); # returns descriptive file type name
						   $filename_styled="<span class=\"$class italic\">$filename</span>";
						   $filename_display=$filename_class.$filename_styled.$info_icon_styled; 
						   
##### Start building the file 'list item' core #####
						   $file_list2.= "<li>";
						   
##### Check for permissions problems in the input directory and append file list string #####
					     
						   $permissions = $vals[0];
						   $p_array=str_split($permissions); //-rw-r--r--
						   if($p_array[7] != "r" )
						   {
							  $p_flag = "<span class='warning'>permissions</span>"; // sets flag if any file has permission problem
							  $p_hints = "<span class='tip_style'>To fix permissions problem, on shell: <span class='plaintext'>$ chmod a+r [myfile]</span>
							  <img id='config_data_permissions' title='Click ? for details.' class='help-button nudge1' src='/XGDB/images/help-icon.png' alt='?' />
							  </span>";
							  $file_list2 .= "<span class='warning'>[$permissions]</span>"; 
						   }

##### Calculate size in a reasonable numeric range #####
						   $total_size = $total_size + $size;
						   $unit = 0;  # 0: bytes, 1: kilobytes, 2: megabytes, 3: gigabytes
						   while ($size > 1024 && $unit < 4)
						   {
							   $size = round($size / 1024,2);
							   $unit++;
						   }

##### Continue building the file 'list item' core: filename, validation icon, date and time / size / (entries) #####

						   $file_list2.= "$filename_display / ${year_month_day} ${time} / $size";

##### If file has been validated, # of entries is available from the MySQL query. Add this here at end of line if available. #####
						   
						   $entries_styled=(empty($entries))?"(not evaluated)":
						   "<span style=\"color:#00A592\"> 
						      $entries entries
						   </span>";
						   
##### Determine unit for display and compute absolute size in order to get cumulative total #####

						   if($unit == 0) {$file_list2.= " bytes"; $abs_size = $size/1000000;}
						   if($unit == 1) {$file_list2.= " KB"; $abs_size  = $size/1000;}
						   if($unit == 2) {$file_list2.= " MB"; $abs_size = $size/1;}
						   if($unit == 3) {$file_list2.= " GB";$abs_size =  $size/.001;}
						   
##### Finish display with the size units and list end #####

						   $file_list2.=" / ".$entries_styled;
						   $file_list2.="</li>";
						   
##### Finally, check for duplication or other validation problem in multiple files and display as a list item below the regular file listing

						   if($get_multiple_invalid="select SeqType, SeqTypeCount from Datafiles where ValidationTimeStamp='$validation_time_stamp' and Valid='F' and UserFile='F' and FileStamp LIKE'%$filestamp%'") # UserFile='F' denotes a 'dummy' record that flags invalid file groups that, when catted, have duplicate IDs or mixed ID type.
						   { 
							 $mysql_get_multiple_invalid= mysql_query($get_multiple_invalid); 
							 while($result_get_multiple_invalid = mysql_fetch_array($mysql_get_multiple_invalid))
							 {
							   $seq_type=$result_get_multiple_invalid[0]; # e.g. est
							   $seq_type_count=$result_get_multiple_invalid[1]; # number of entries
							   $multifile_error="T";
						       $file_list2.="<li style=\"list-style-type:none\"><span class=\"warning\">ERROR: The above <b>$seq_type</b> file is one of $seq_type_count files that when combined have duplicate IDs or mixed header type</span> </li>";
							 }
						   }   
					   }
#					$total_size = $total_size + $abs_size; # moved this
				 }
			}
		}

##### Calculate the data and validation totals #####

	$total_size_display = convert_bytes($total_size);  ## Convert to relative size / units
	if($n<$cutoff)
		{
		$class=($type=="list")? "darkgrayfont bold warning":"alertnotice bold warning";
		}
		else
		{
		$class=($type=="list")? "darkgrayfont":"checked";
		}
	$ne=($n-($v+$iv)); # not evaluated (total minus sum of valid + invalid)


##### Build the rest of the list infrastructure (header line, showhide dive and unordered list). Note that $title comes into this function as an argument since text can vary.  #####

	$header_line=
	    "
	    <span class=\"largerfont bold\">
	      $path &nbsp;
	    </span>
	    <span class=\"heading\">
	        Click <img class=\"nudge3\" src=\"/XGDB/images/information_grey.png\" /> to view / validate contents, or use '<span style=\"background-color:#FFB056\">Data Process Options...</span>' to validate all
	        <img id='config_file_contents_validation' title='Click ? for details.' class='help-button nudge1' src='/XGDB/images/help-icon.png' alt='?' />
	    </span> 
	    "
	    ; 
	    
	$valid_count_display=($v>0)?"<span class=\"contentsvalid\"> $v valid files</span>":"";
	$invalid_count_display=($iv>0)?" <span class=\"contentsnotvalid\"> $iv invalid files</span>":"";
	$noteval_count_display=($ne>0)?" <span class=\"contentsnoteval\"> $ne files not evaluated</span>":"";
	$multifile_error_display=($multifile_error=="F")?"":"<span class=\"warning\">ERROR: multi-file duplicate IDs or mixed header <img id='config_file_duplicates_error' title='Click ? for details.' class='help-button nudge1' src='/XGDB/images/help-icon.png' alt='?' /> </span>";
	$file_list1="
	<div class=\"showhide test\">
	<p class=\"label\" style=\"cursor:pointer\" title=\"Show file validation\">
		<span class=\"normalfont\">
			$title:
		</span>
        <span class=\"normalfont\">
            $p_flag
        	$valid_count_display $invalid_count_display $noteval_count_display 
         </span>
	 	<span class=\"heading\">
	 		totalling $total_size_display; $multifile_error_display (click for details) </span>
	 	</span>
	 </p>
	<div class=\" hidden\" style=\"display: none;\">";
	
	$file_list1.="$header_line";
	
	$file_list1.="<ul class=\"bullet1 indent2 create_file_list\">
	"; 
	
	$file_list3="
	</ul>$p_hints
	</div>
	</div>";

##### Assemble the pieces of the header and list  #####
	
	$file_list_formatted = $file_list1.$file_list2.$file_list3;

##### If no data in file list2, don't return anything in this variable  #####

	$file_list_final = ($file_list2 =="")?"":$file_list_formatted;
	
##### Sort the file codes (see above and get_file_codes) and make them into a concatenated string to represent the file 'fingerprint' for this directory. These will be used to predict output.  #####
	
	$file_codes=str_split($file_codes,1);
	sort($file_codes);
	$file_codes=implode('',$file_codes);
                    
	return array($file_list_final, $n, $total_size, $file_list, $file_codes); //$total_size in bytes; we return $n in case we want to validate based on valid files

}


function convert_bytes($size) {
	$unit = 0;  //0: bytes, 1: kilobytes, 2: megabytes, 3: gigabytes
	$rel_size=0;
	while ($size > 1024 && $unit < 4)
		{
			$size = round($size / 1024,2);
			$unit++;
		}

	if($unit == 0) {$units = " bytes"; $abs_size = $size/1000000;}
	if($unit == 1) {$units = " KB"; $abs_size  = $size/1000;}
	if($unit == 2) {$units = " MB"; $abs_size = $size/1;}
	if($unit == 3) {$units = " GB"; $abs_size =  $size/.001;}
	$size_display="$size $units";

return $size_display;
			
}

function validate_file_type($filename, $class) //called by create_file_list (above); matches file of name $filename with standardized suffix and returns human-readable interpretation (if any) with validation stying, as part of file_list
	{
			$types = array
			(
					"gdna\.fa"  => "genomic DNA",
					"gdna\.rm\.fa"  => "genomic DNA, masked",
					"est\.fa"   => "ESTs",
					"est\.gsq"  => "EST alignments",
					"cdna\.fa"  => "cDNAs",
					"cdna\.gsq" => "cDNA alignments",
					"tsa\.fa"   => "transcript assemblies",
					"tsa\.gsq"  => "transcript assembly alignments",
					"prot\.fa"  => "related proteins",
					"prot\.gth" => "related protein alignments",
					"annot\.gff3"     => "annotations",
					"annot\.mrna\.fa"  => "annotated mRNAs",
					"annot\.cds\.fa"   => "annotated CDSs",
					"annot\.pep\.fa"   => "annotated peptides",
					"annot\.desc\.txt" => "annotation descriptions",
					"cpgat\.gff3" => "cpgat annotations",
					"cpgat\.pep\.fa" => "cpgat annotated peptides",
					"cpgat\.mrna\.fa" => "cpgat annotated mRNAs",
					"cpgat\.desc\.txt" => "cpgat annotation descriptions",
					"mask\.fa"   => "N-masked regions",
			);
			foreach($types as $ext => $type)
			{
		$test = "/\S*".$ext."$/i";
					if(preg_match($test, $filename, $match))
					{
							return "<span class=\"$class\">$type: </span> ";
					}
			}
		return "";
}


function get_sequence_type($filepath) //give a $filepath with standardized suffix, returns sequence type associated with that file (for validation summaries - see xGDB_validefile.php)
	{
			$types = array
			(
					"gdna\.fa"  => "gdna",
					"gdna\.rm\.fa"  => "gdna",
					"est\.fa"   => "est",
					"est\.gsq"  => "est",
					"cdna\.fa"  => "cdna",
					"cdna\.gsq" => "cdna",
					"tsa\.fa"   => "tsa",
					"tsa\.gsq"  => "tsa",
					"prot\.fa"  => "prot",
					"prot\.gth" => "prot",
					"annot\.gff3" => "annot",
					"annot\.mrna\.fa"  => "mrna",
					"annot\.pep\.fa"   => "pep",
					"cpgat\.gff3" => "annot",
					"cpgat\.mrna\.fa" => "mrna",
					"cpgat\.pep\.fa" => "pep",
					"annot\.desc\.txt" => "desc",
					"cpgat\.desc\.txt" => "desc",
					"\/referenceprotein\/" => "refprot",
					"\/repeatmask\/" => "repeat",
					"mask\.fa"   => "masked",
			);
			foreach($types as $ext => $type)
			{
		$test = "/\S*".$ext."\S*$/i";  # we allow matches in middle of string also to account for /referenceprotein/ and /repeatmask/.
					if(preg_match($test, $filepath))
					{
							return "$type";
					}
			}
		return "";
}

function get_sequence_format($filepath) //give a $filepath with standardized suffix, returns format type associated with that file (for validation summaries - see xGDB_validefile.php)
	{
			$formats = array
			(
					"gdna\.fa"  => "fa",
					"gdna\.rm\.fa"  => "fa",
					"est\.fa"   => "fa",
					"est\.gsq"  => "gsq",
					"cdna\.fa"  => "fa",
					"cdna\.gsq" => "gsq",
					"tsa\.fa"   => "fa",
					"tsa\.gsq"  => "gsq",
					"prot\.fa"  => "fa",
					"prot\.gth" => "gth",
					"annot\.gff3" => "gff3",
					"annot\.mrna\.fa"  => "fa",
					"annot\.pep\.fa"   => "fa",
					"cpgat\.gff3" => "gff3",
					"cpgat\.mrna\.fa" => "fa",
					"cpgat\.pep\.fa" => "fa",
					"annot\.desc\.txt" => "txt",
					"cpgat\.desc\.txt" => "txt",
					"\/referenceprotein\/" => "fa",
					"\/repeatmask\/" => "fa",
					"mask\.fa"   => "fa",
			);
			foreach($formats as $ext => $format)
			{
		$test = "/\S*".$ext."\S*$/i";  # we allow matches in middle of string also to account for /referenceprotein/ and /repeatmask/.
					if(preg_match($test, $filepath))
					{
							return "$format";
					}
			}
		return "";
}

function get_track_id($filepath) //give a $filepath with standardized suffix, returns track ID associated with that file (for validation summaries - see xGDB_validefile.php)
	{
			$tracks = array
			(
					"gdna\.fa"  => "genome",
					"gdna\.rm\.fa"  => "genome masked",
					"est\.fa"   => "est",
					"est\.gsq"  => "est",
					"cdna\.fa"  => "cdna",
					"cdna\.gsq" => "cdna",
					"tsa\.fa"   => "tsa",
					"tsa\.gsq"  => "tsa",
					"prot\.fa"  => "prot",
					"prot\.gth" => "prot",
					"annot\.gff3" => "annot",
					"annot\.mrna\.fa"  => "annot",
					"annot\.pep\.fa"   => "annot",
					"cpgat\.gff3" => "cpgat",
					"cpgat\.mrna\.fa" => "cpgat",
					"cpgat\.pep\.fa" => "cpgat",
					"annot\.desc\.txt" => "annot",
					"cpgat\.desc\.txt" => "cpgat",
					"\/referenceprotein\/" => "none",
					"\/repeatmask\/" => "masked",
					"mask\.fa"   => "masked",
			);
			foreach($tracks as $ext => $track)
			{
		$test = "/\S*".$ext."\S*$/i";  # we allow matches in middle of string also to account for /referenceprotein/ and /repeatmask/.
					if(preg_match($test, $filepath))
					{
							return "$track";
					}
			}
		return "";
}

function get_sequence_unit($filepath) //give a $filepath with standardized suffix, returns unit type associated with that file (for validation summaries - see xGDB_validefile.php)
	{
			$units = array
			(
					"gdna\.fa"  => "bp",
					"gdna\.rm\.fa"  => "bp",
					"est\.fa"   => "bp",
					"cdna\.fa"  => "bp",
					"tsa\.fa"   => "bp",
					"prot\.fa"  => "aa",
					"annot\.mrna\.fa"  => "bp",
					"annot\.pep\.fa"   => "aa",
					"cpgat\.mrna\.fa" => "bp",
					"cpgat\.pep\.fa" => "aa",
					"\/referenceprotein\/" => "aa",
					"\/repeatmask\/" => "bp",
			);
			foreach($units as $ext => $unit)
			{
		$test = "/\S*".$ext."\S*$/i";  # we allow matches in middle of string also to account for /referenceprotein/ and /repeatmask/.
					if(preg_match($test, $filepath))
					{
							return "$unit";
					}
			}
		return "";
}


# For a given path, finds all non-redundant input directories or CpGAT file paths (eventually other types: update, repmask too) and totals their contents. Calls several other functions in this script.
# argument: $path can be Input_Data_Path, Output_Data_Path, Update_Data_Path, CpGAT_Data_Path
# Returns total file counts and aggregate file size (MB) and number of GDB involved in the count ($n)

function get_data_total($path, $dbpass){
		$file_count=0;
		$file_size=0;
		$countQuery="SELECT count(*) as dbcount from Genomes.xGDB_Log where $path !='' AND $path LIKE '/xGDBvm/data%' AND Status='Development'"; # non-example data paths
		$get_count=$countQuery;
		$check_get_count=mysql_query($get_count);
		$count = $check_get_count;
		$row = mysql_fetch_assoc($count);
		$gdb_count=$row['dbcount'];
		
		$gdbQuery="SELECT DISTINCT $path from Genomes.xGDB_Log where $path !='' AND $path LIKE '/xGDBvm/data%' AND Status='Development'"; # non-example data paths
		$get_gdb = $gdbQuery;
		$check_get_gdb = mysql_query($get_gdb);
		$result = $check_get_gdb;
		$n=0;
		while ($row = mysql_fetch_assoc($result))
			{
			$input_path=$row[$path];
				if($path=="Input_Data_Path" || $path=="Update_Data_Path") 
				{
				$gdb_input=	create_file_list($input_path, "dir", $input_path, "", 0, $dbpass); // returns array($file_list_formatted, $n, $total_size, $file_list)
#				$gdb_input=	create_file_list("/xGDBvm/examples/example2/new_data", "dir", "", "", 0); // requires ($input, $type, $path, $title, $cutoff); returns array($file_list_formatted, $n, $total_size, $file_list)
					$file_count= $file_count+ $gdb_input[1]; // number of valid files
					$file_size=$file_size+ $gdb_input[2]; // number of MB 
					break;
				}
				elseif($path== "CpGAT_ReferenceProt_File" || $path == "RepeatMask_File") //here the argument is a file path

				{
					$gdb_cpgat=	validate_refpro($input_path); // returns array($file_list, $n, $total_size)
					$file_count=$file_count+$gdb_cpgat[1]; // number of valid files
					$file_size=$file_size+$gdb_cpgat[2]; // number of MB 
				}
			$n=$n+1;
			}
			
return array($file_count, $file_size, $gdb_count); // file count and MB size for all validated data of the specified class (input, update, cpgat, mask)
}


# read flat file log contents identified by GDB, file name (Pipeline_procedure.log, Pipeline_procedure.log", Pipeline_procedure.log") whether or not to format ("T" "F" or blank)
function read_pipeline_progress($ID, $Data_Dir, $file, $format) {
    $contents = "";
    $filename = "$Data_Dir".$ID."/logs/".$file;
    if(file_exists($filename))
    {
		if(filesize($filename)>0)
        {
            if(filesize($filename)<81960) # Limit large files such as if thousands of duplicate records were flagged.
            {
                $fd = fopen($filename, "r");
                if(is_readable($filename))
                {
                     $contents = fread($fd, filesize($filename));
                }
                fclose($fd);
            }
            else
            {
            $contents="This file is too large to display. View contents at $filename";
            }
        }
$contents=($format=="T")?format_errors($contents):$contents;
    }
return $contents;
}


function format_errors($errors){
# create html markup including linkes to error explanations (in progress, 5/17/13). 
# Takes text lines as input (e.g. from read_pipeline_progress, above) and parses, adds img links and ids based on line number.
	$tag_left = "<img id='";
	$tag_right = "' title='Click ? for details on this error' class='help-button nudge1' src='/XGDB/images/help-icon.png' alt='?' />";
	$error_markup="<ul class='bullet1'>";
	$error_list = explode( "\n", $errors );
		foreach ( $error_list as $error )
				{
#				$pattern = "/(.*)\((\S+)\)(.*)/i";
				$pattern = "/^(.*)\((\d+\.\d+)\)(.*)/i";
				$replacement="<li>$1($2)${tag_left}pipeline_error_$2${tag_right}$3</li>";
#				$replacement="$1";
				$error_markup.=preg_replace($pattern, $replacement, $error);
				}
	$error_markup.="</ul>";
return $error_markup;
}


## We want to flag any GDBnnn on /xGDBvm/data or /xGDBvm/data that are NOT in the global database or are Development status (and so should not have these directories). 
## So we list files matching GDBnnn in these directories and compare them with  Status=Current IDs in Genomes.xGDB_Log.
function checkExtra($directory){  # the complete path, e.g. $dataDir, or /home/xgdb-data/
	$extraGDB=array();
	$dir = $directory;
	$files =`ls ${dir}/`;
	$file_list = explode( "\n", $files );
		foreach ( $file_list as $file )
				{
				$pattern = "/^(GDB\d\d\d)$/";
				$GDB_match=preg_match($pattern, $file, $matches);
				if(isset($matches[1]))
				{
                    $GDB_ID = $matches[1];
                    $id = (int) substr($GDB_ID, -3); 
                    if($id!="")
                        {
                        $query_extra="SELECT ID FROM Genomes.xGDB_Log WHERE ID=$id AND (Status='Current' || Status='Locked')"; // find out if GDB is in global database
                        $query_result=mysql_query($query_extra);
                        $extra_count = mysql_num_rows($query_result);
                        if ($extra_count==0)
                            {
                            $GDB_path=$dir."".$GDB_ID."/";
                            array_push($extraGDB, $GDB_path);
                            }
                        }
                    }
                }
return $extraGDB;
}


#######################
# Log File Functions  #
#######################
function tail($ID, $file, $path)  # adapted from new.php! $file input should be the same as designated for jquery ui.
{
			$filepath = $path.$file.".log";
			if($fd = fopen($filepath, "r")){
			$data = array();
			$n=0;
					while (!feof($fd) ) {
					$line = fgets($fd);
					$data[$n] =$line;
					$n=$n+1;
					}
		   $lastline1 = count($data)-3; #not sure why count has more lines than file appears to have.
		   $lastline2 = count($data)-2;
		   $line1= $data[$lastline1];
		   $line2= $data[$lastline2];
				fclose($fd);
	return array($line1, $line2);
	}else{
	return array("no logfile", ""); 
	}
}

function input_warnings($path)
{
# This function compares entry counts for Input files that should have the same number of records, for all valid file_codes in a given path, and creates warning flags where numbers don't match
# To do this 1) we generate a list of 'valid' filestamps from the input directory and their totals; 2) generate file code list for the same and compare value pairs, generate warnings as list items

###### 1. Generate Filestamp array

    $file_list =`ls -l --time-style=long-iso $path`; //
    $list = explode( "\n", $file_list ); # file list array
    $filenames=""; # debug only
    $file_codes=""; # string representing each file type.
    ###### Parse each item on file list ######

	if (count($list) < 100 ) #avoid huge directories.
	{
		$filestamps=array();
		$file_code_list="";
		foreach ( $list as $item )
        {
            $pattern = "/\s+/";
            $replacement = " ";
            $item = preg_replace($pattern, $replacement, $item); # collapase spaces
            
            ###### Select file listings (not directories), parse filename, and run filename validation function   ######

            if ( substr( $item, 0, 1 ) == "-" ) // identifies file (-rw-r--r-- etc) as opposed to directory (drwxrwxr-x etc.)
            {
                $vals = explode( " ", $item );
                $filename = $vals[count($vals)-1]; //e.g. the filename, MyFile_est.fa

##### 2. For valid files, parse metadata, and recreate unique filestamp #####

                if(validate_file_type($filename, "")!="")  # We want to list ONLY valid filenames in this directory, not ALL files.
                {                   
                   $time = $vals[count($vals)-2];
                   $year_month_day = $vals[count($vals)-3];
                   $size = $vals[count($vals)-4];
                   $filestamp = "$filename:$size:${year_month_day}-$time"; # IMPORTANT: This format MUST be synchronized with FileStamp in /xGDBvm/scripts/xGDB_ValidateFiles.sh
                   array_push($filestamps, $filestamp);  ### we want a simple array of filestamps.
                   $file_codes.=get_file_codes($filename); ### generate a string that encodes all valid file types in the Input directory
                } # done with valid files
            } # done with files
        } # done with dir list
   } # done with count limit

##### 3. Query the Datafiles table for entry sums that should match each other, using only rows that match our $filestamp 'fingerprint' array. Compare values and generate messages.

/*

*/
    $warning=""; $gene1_annot=""; $gene1_mrna=""; $gene1_pep=""; $gene1_desc=""; $gene2_annot=""; $gene2_mrna=""; $gene2_pep=""; $gene2_desc=""; 
    $gene1="annot"; # current jargon; leave open possibility to generalize and extend these names
    $gene2="cpgat"; # current jargon; leave open possibility to generalize and extend these names
    $n=0; # counter
    
    mysql_select_db("Genomes");

		if((preg_match("/a/", $file_codes) && $get_totals="SELECT SUM(EntryCount), Track, SeqType, Format  FROM Datafiles WHERE SeqType=\"annot\" AND Track=\"$gene1\" AND Path=\"$path\" AND FileStamp IN (\"". implode('","', $filestamps)."\") GROUP BY SeqType"))   # Annotation file exists and is queryable in Datafiles
		{
			$mysql_get_totals= mysql_query($get_totals); 
			while($row = mysql_fetch_array($mysql_get_totals))
			{ 
				$gene1_annot=$row[0]; # Transcripts (not Genes) was assigned to EntryCount in xGDB_validatefile.php
				$gene1_annot_suffix=$row[1].".".$row[2].".".$row[3];
				$gene1_annot_description=validate_file_type($gene1_annot_suffix, "bold");
			}
		 
			if(preg_match("/m/", $file_codes) && $get_totals="SELECT SUM(EntryCount), Track, SeqType, Format  FROM Datafiles WHERE SeqType=\"mrna\" AND Track=\"$gene1\" AND Path=\"$path\" AND FileStamp IN (\"". implode('","', $filestamps)."\") GROUP BY SeqType")   # mRNA file exists and is queryable in Datafiles
			{ 
				$mysql_get_totals= mysql_query($get_totals); 
				while($row = mysql_fetch_array($mysql_get_totals))
				{ 
					$gene1_mrna=$row[0];
					$gene1_mrna_suffix=$row[1].".".$row[2].".".$row[3];
					$gene1_mrna_description=validate_file_type($gene1_mrna_suffix, "bold");					
				}
			$warning_gene1_mrna=($gene1_annot==$gene1_mrna)?"":"<li><span class=\"caution\">NOTE:</span> $gene1_mrna_description (~$gene1_mrna_suffix; $gene1_mrna entries) does not match $gene1_annot_description (~$gene1_annot_suffix; $gene1_annot entries) (N-1)</li>";
			$warning.=$warning_gene1_mrna;
			$n=$n+1;
			}
			if(preg_match("/i/", $file_codes) && $get_totals="SELECT SUM(EntryCount), Track, SeqType, Format FROM Datafiles WHERE SeqType=\"pep\" AND Track=\"$gene1\" AND Path=\"$path\" AND FileStamp IN (\"". implode('","', $filestamps)."\") GROUP BY SeqType")
			{
				$mysql_get_totals= mysql_query($get_totals); 
				while($row = mysql_fetch_array($mysql_get_totals))
				{ 
					$gene1_pep=$row[0];
					$gene1_pep_suffix=$row[1].".".$row[2].".".$row[3];
					$gene1_pep_description=validate_file_type($gene1_pep_suffix, "bold");
				}
			$warning_gene1_pep=($gene1_annot==$gene1_pep)?"":"<li><span class=\"caution\">NOTE:</span> $gene1_pep_description (~$gene1_pep_suffix; $gene1_pep entries) does not match $gene1_annot_description (~$gene1_annot_suffix; $gene1_annot entries) (N-2)</li>";
			$warning.=$warning_gene1_pep;
			}
			if(preg_match("/s/", $file_codes) && $get_totals="SELECT SUM(EntryCount), Track, SeqType, Format FROM Datafiles WHERE SeqType=\"desc\" AND Track=\"$gene1\" AND Path=\"$path\" AND FileStamp IN (\"". implode('","', $filestamps)."\") GROUP BY SeqType")
			{
				$mysql_get_totals= mysql_query($get_totals); 
				while($row = mysql_fetch_array($mysql_get_totals))
				{ 
					$gene1_desc=$row[0];
					$gene1_desc_suffix=$row[1].".".$row[2].".".$row[3];
					$gene1_desc_description=validate_file_type($gene1_desc_suffix, "bold");
				}
			$warning_gene1_desc=($gene1_annot==$gene1_desc)?"":"<li><span class=\"caution\">NOTE:</span> $gene1_desc_description (~$gene1_desc_suffix; $gene1_desc) does not match $gene1_desc_description (~$gene1_annot_suffix; $gene1_annot) (N-3)</li>";
			$warning.=$warning_gene1_desc;
			$n=$n+1;
			}
			}
	### (not done yet: repeat for other matching pairs)
		mysql_select_db("Genomes");
	
		if(preg_match("/A/", $file_codes) && $get_totals="SELECT SUM(EntryCount), Track, SeqType, Format FROM Datafiles WHERE SeqType=\"annot\" AND Track=\"$gene2\" AND Path=\"$path\" AND FileStamp IN (\"". implode('","', $filestamps)."\") GROUP BY SeqType")
		{
			$mysql_get_totals= mysql_query($get_totals); 
			while($row = mysql_fetch_array($mysql_get_totals))
			{ 
				$gene2_annot=$row[0]; # Transcripts (not Genes) was assigned to EntryCount in xGDB_validatefile.php
				$gene2_annot_suffix=$row[1].".".$row[2].".".$row[3];
				$gene2_annot_description=validate_file_type($gene2_annot_suffix, "bold");
			}
			 
			if(preg_match("/M/", $file_codes) && $get_totals="SELECT SUM(EntryCount), Track, SeqType, Format FROM Datafiles WHERE SeqType=\"mrna\" AND Track=\"$gene2\" AND Path=\"$path\" AND FileStamp IN (\"". implode('","', $filestamps)."\") GROUP BY SeqType")
			{
				$mysql_get_totals= mysql_query($get_totals); 
				while($row = mysql_fetch_array($mysql_get_totals))
				{ 
					$gene2_mrna=$row[0];
				    $gene2_mrna_suffix=$row[1].".".$row[2].".".$row[3];
					$gene2_mrna_description=validate_file_type($gene2_mrna_suffix, "bold");					
				}
			$warning_gene2_mrna=($gene2_annot==$gene2_mrna)?"":"<li><span class=\"caution\">NOTE:</span> $gene2_mrna_description (~$gene2_mrna_suffix; $gene2_mrna) does not match $gene2_annot_description (~$gene2_annot_suffix; $gene2_annot) (N-4)</li>";
			$warning.=$warning_gene2_mrna;
			$n=$n+1;
			}

			if(preg_match("/I/", $file_codes) && $get_totals="SELECT SUM(EntryCount), Track, SeqType, Format  FROM Datafiles WHERE SeqType=\"pep\" AND Track=\"$gene2\" AND Path=\"$path\" AND FileStamp IN (\"". implode('","', $filestamps)."\") GROUP BY SeqType")
			{
				$mysql_get_totals= mysql_query($get_totals); 
				while($row = mysql_fetch_array($mysql_get_totals))
				{ 
					$gene2_pep=$row[0];
					$gene2_pep_suffix=$row[1].".".$row[2].".".$row[3];
					$gene2_pep_description=validate_file_type($gene2_pep_suffix, "bold");
				}
			$warning_gene2_pep=($gene2_annot==$gene2_pep)?"":"<li><span class=\"caution\">NOTE:</span> $gene2_pep_description (~$gene2_pep_suffix; $gene2_pep) does not match $gene2_annot_description (~$gene2_annot_suffix; $gene2_annot) (N-5)</li>";
			$warning.=$warning_gene2_pep;
			}
			if(preg_match("/S/", $file_codes) && $get_totals="SELECT SUM(EntryCount), Track, SeqType, Format FROM Datafiles WHERE SeqType=\"desc\" AND Track=\"$gene2\" AND Path=\"$path\" AND FileStamp IN (\"". implode('","', $filestamps)."\") GROUP BY SeqType")
			{
				$mysql_get_totals= mysql_query($get_totals); 
				while($row = mysql_fetch_array($mysql_get_totals))
				{ 
					$gene2_desc=$row[0];
					$gene2_desc_suffix=$row[1].".".$row[2].".".$row[3];
					$gene2_desc_description=validate_file_type($gene2_desc_suffix, "bold");
				}
			$warning_gene2_desc=($gene2_annot==$gene2_desc)?"":"<li><span class=\"caution\">NOTE:</span> $gene2_desc_description (~$gene2_desc_suffix; $gene2_desc) does not match $gene2_annot_description (~$gene2_annot_suffix; $gene2_annot) (N-6)</li>";
			$warning.=$warning_gene2_desc;
			$n=$n+1;
			}
		}


return $warning;

}



function input_errors($file_codes){ //Uses single-letter coded input string to highlight omissions (see get_file_codes for key to abbreviations)
    $errors="";
    $errors.=(!preg_match("/g/", $file_codes) && !preg_match("/G/", $file_codes))?"<li><span class=\"warning\">ERROR</span>: Missing genome file (~gdna.fa or ~gdna.rm.fa)</li>":"";
    $errors.=(preg_match("/g/", $file_codes) && preg_match("/G/", $file_codes))?"<li><span class=\"warning\">ERROR</span>: Mix of repeat masked and unmasked genome files present (~gdna.fa or ~gdna.rm.fa)</li>":"";
    $errors.=(preg_match("/E/", $file_codes) && !preg_match("/e/", $file_codes))?"<li><span class=\"warning\">ERROR</span>: Missing EST file (~est.fa), required with EST spliced alignment file (~est.gsq)</li>":"";
    $errors.=(preg_match("/C/", $file_codes) && !preg_match("/c/", $file_codes))?"<li><span class=\"warning\">ERROR</span>: Missing cDNA file (~cdna.fa), required with cDNA spliced alignment file (~cdna.gsq)</li>":"";
    $errors.=(preg_match("/T/", $file_codes) && !preg_match("/t/", $file_codes))?"<li><span class=\"warning\">ERROR</span>: Missing TSA file (~tsa.fa), required with TSA spliced alignment file (~tsa.gsq)</li>":"";
    $errors.=(preg_match("/P/", $file_codes) && !preg_match("/p/", $file_codes))?"<li><span class=\"warning\">ERROR</span>: Missing Prot file (~prot.fa), required with protein spliced alignment file (prot.gth)</li>":"";
    $errors.=(preg_match("/a/", $file_codes) && !preg_match("/i/", $file_codes))?"<li><span class=\"warning\">NOTE</span>: Peptide file (~annot.pep.fa) recommended to support precomputed annotations (~annot.gff3)</li>":"";
    $errors.=(preg_match("/a/", $file_codes) && !preg_match("/m/", $file_codes))?"<li><span class=\"caution\">NOTE</span>: mRNA file (~annot.mrna.fa) missing; recommended to support precomputed annotations (~annot.gff3)</li>":"";
    $errors.=(preg_match("/A/", $file_codes) && !preg_match("/I/", $file_codes))?"<li><span class=\"caution\">NOTE</span>: Peptide file (~cpgat.pep.fa) missing; recommended to support CpGAT annotations (~cpgat.gff3)</li>":"";
    $errors.=(preg_match("/A/", $file_codes) && !preg_match("/M/", $file_codes))?"<li><span class=\"caution\">NOTE</span>: mRNA file (~cpgat.mrna.fa) missing; recommended to support CpGAT annotations (~cpgat.gff3)</li>":"";
    $errors.=(preg_match("/i/", $file_codes) && !preg_match("/a/", $file_codes))?"<li><span class=\"warning\">ERROR</span>: Predicted peptide file (~annot.pep.fa) detected but no valid gff3 file (~annot.gff3) is present</li>":"";
    $errors.=(preg_match("/m/", $file_codes) && !preg_match("/a/", $file_codes))?"<li><span class=\"warning\">ERROR</span>: Predicted mRNA file (~annot.mrna.fa) detected but no valid gff3 file (~annot.gff3) is present</li>":"";
    $errors.=(preg_match("/s/", $file_codes) && !preg_match("/a/", $file_codes))?"<li><span class=\"warning\">ERROR</span>: Description file (~annot.desc.txt) detected but no valid gff3 file (~annot.gff3) is present</li>":"";
    $errors.=(preg_match("/I/", $file_codes) && !preg_match("/A/", $file_codes))?"<li><span class=\"warning\">ERROR</span>: Predicted peptide file (~annot.pep.fa) detected but no valid gff3 file (~annot.gff3) is present</li>":"";
    $errors.=(preg_match("/M/", $file_codes) && !preg_match("/A/", $file_codes))?"<li><span class=\"warning\">ERROR</span>: CpGAT mRNA file (~cpgat.mrna.fa) detected but no valid gff3 file (~cpgat.gff3) is present</li>":"";
    $errors.=(preg_match("/S/", $file_codes) && !preg_match("/A/", $file_codes))?"<li><span class=\"warning\">ERROR</span>: Description file (~cpgat.desc.txt) detected but no valid gff3 file (~cpgat.gff3) is present</li>":"";
return $errors;
}


function input_results($file_codes,  $cpgat_status, $repeatmask_status, $gsq_compresources, $gth_compresources){ //Uses single-letter coded input string to display expected results (see get_file_codes for key to abbreviations)
    $results="";
    $tracks=0;
    $alignments="";
    $remote="";
    $genome=($repeatmask_status=="Yes" || preg_match("/G/", $file_codes))? "genome (Repeat-Masked)": "genome";
    $gsq_remote=($gsq_compresources=="Remote")?"<span class=\"remote\"> (Remote GSQ Option) </span>":"";
    $gth_remote=($gth_compresources=="Remote")?"<span class=\"remote\"> (Remote GTH Option) </span>":"";
    
    if(preg_match("/g/", $file_codes) && preg_match("/e/", $file_codes) && !preg_match("/E/", $file_codes))
    {
       $tracks =$tracks+1;
       $alignments.="<span class=\"est_color\">EST</span>";
       $results.="<li class=\"result\">Track $tracks. <span class=\"est_color\">EST</span> spliced alignments to $genome $gsq_remote</li>";
    }
    if(preg_match("/g/", $file_codes) && preg_match("/c/", $file_codes) && !preg_match("/C/", $file_codes))
    {
       $tracks =$tracks+1;
       $alignments.="<span class=\"cdna_color\">cDNA</span>";
       $results.="<li class=\"result\">Track $tracks. <span class=\"cdna_color\">cDNA</span> spliced alignments to $genome $gsq_remote</li>";
    }
    if(preg_match("/g/", $file_codes) && preg_match("/t/", $file_codes) && !preg_match("/T/", $file_codes))
    {
       $tracks =$tracks+1;
       $alignments.="<span class=\"tsa_color\">TSA</span>";
       $results.="<li class=\"result\">Track $tracks. <span class=\"tsa_color\">TSA</span> spliced alignments to $genome $gsq_remote</li>";
    }
    if(preg_match("/g/", $file_codes) && preg_match("/E/", $file_codes) && preg_match("/e/", $file_codes))
    {
       $tracks =$tracks+1;
       $alignments.="<span class=\"est_color\">EST</span>";
       $results.="<li class=\"result\">Track $tracks. <span class=\"est_color\">EST</span> (pre-computed) spliced alignments to $genome</li>";
    }
    if(preg_match("/g/", $file_codes) && preg_match("/C/", $file_codes) && preg_match("/c/", $file_codes))
    {
       $tracks =$tracks+1;
       $alignments.="<span class=\"cdna_color\">cDNA</span>";
       $results.="<li class=\"result\">Track $tracks. <span class=\"cdna_color\">cDNA</span> (pre-computed) spliced alignments to $genome</li>";
    }
    if(preg_match("/g/", $file_codes) && preg_match("/T/", $file_codes) && preg_match("/t/", $file_codes))
    {
       $tracks =$tracks+1;
       $alignments.="<span class=\"tsa_color\">TSA</span>";
       $results.="<li class=\"result\">Track $tracks. <span class=\"tsa_color\">TSA</span> (pre-computed) spliced alignments to $genome</li>";
    }
    if(preg_match("/g/", $file_codes) && preg_match("/p/", $file_codes) && !preg_match("/P/", $file_codes))
    {
       $tracks =$tracks+1;
       $alignments.="<span class=\"protein_color\">Protein</span>";
       $results.="<li class=\"result\">Track $tracks. <span class=\"protein_color\">protein</span> spliced alignments to genome $gth_remote</li>";
    }
    if(preg_match("/g/", $file_codes) && preg_match("/P/", $file_codes) && preg_match("/p/", $file_codes))
    {
       $tracks =$tracks+1;
       $alignments.="<span class=\"protein_color\">Protein</span>";
       $results.="<li class=\"result\">Track $tracks. <span class=\"protein_color\">protein</span> (pre-computed) spliced alignments to genome</li>";
    }

### Gene Predictions

    if(preg_match("/g/", $file_codes) && preg_match("/a/", $file_codes) && !preg_match("/m/", $file_codes) && !preg_match("/i/", $file_codes) && !preg_match("/d/", $file_codes))
    {
       $tracks =$tracks+1;
       $results.="<li class=\"result\">Track $tracks. <span class=\"gene-gff_color\">gene predictions</span> from GFF3 file (<span class=\"warning\">no supporting FASTA files detected</span>)</li>";
    }
    if(preg_match("/g/", $file_codes) && preg_match("/a/", $file_codes) && !preg_match("/m/", $file_codes) && preg_match("/i/", $file_codes))
    {
       $tracks =$tracks+1;
       $results.="<li class=\"result\">Track $tracks. <span class=\"gene-gff_color\">gene predictions</span> from GFF file, plus supporting protein FASTA files</li>";
    }
    if(preg_match("/g/", $file_codes) && preg_match("/a/", $file_codes) && !preg_match("/i/", $file_codes) && preg_match("/m/", $file_codes))
    {
       $tracks =$tracks+1;
       $results.="<li class=\"result\">Track $tracks. <span class=\"gene-gff_color\">gene predictions</span> from GFF file, plus supporting mRNA FASTA files</li>";
    }
    if(preg_match("/g/", $file_codes) && preg_match("/a/", $file_codes) && preg_match("/m/", $file_codes) && preg_match("/i/", $file_codes))
    {
       $tracks =$tracks+1;
       $results.="<li class=\"result\">Track $tracks. <span class=\"gene-gff_color\">gene predictions</span> from GFF file, plus supporting protein &amp; mRNA FASTA files </li>";
    }

### Gene Predictions

    if(preg_match("/g/", $file_codes) && preg_match("/A/", $file_codes) && !preg_match("/M/", $file_codes) && !preg_match("/I/", $file_codes) && !preg_match("/d/", $file_codes))
    {
       $tracks =$tracks+1;
       $results.="<li class=\"result\">Track $tracks. <span class=\"cpgat-gff_color\">cpgat predictions</span> (precomputed) from GFF3 file (<span class=\"warning\">no supporting FASTA files detected</span>)</li>";
    }
    if(preg_match("/g/", $file_codes) && preg_match("/A/", $file_codes) && !preg_match("/M/", $file_codes) && preg_match("/I/", $file_codes))
    {
       $tracks =$tracks+1;
       $results.="<li class=\"result\">Track $tracks. <span class=\"cpgat-gff_color\">cpgat predictions</span> (precomputed) from GFF file, plus supporting protein FASTA files</li>";
    }
    if(preg_match("/g/", $file_codes) && preg_match("/A/", $file_codes) && !preg_match("/I/", $file_codes) && preg_match("/M/", $file_codes))
    {
       $tracks =$tracks+1;
       $results.="<li class=\"result\">Track $tracks. <span class=\"cpgat-gff_color\">cpgat predictions</span>(precomputed) from GFF file, plus supporting mRNA FASTA files</li>";
    }
    if(preg_match("/g/", $file_codes) && preg_match("/A/", $file_codes) && preg_match("/M/", $file_codes) && preg_match("/I/", $file_codes))
    {
       $tracks =$tracks+1;
       $results.="<li class=\"result\">Track $tracks. <span class=\"cpgat-gff_color\">cpgat predictions</span> (precomputed) from GFF file, plus supporting protein &amp; mRNA FASTA files</li>";
    }
    if(preg_match("/g/", $file_codes) && $cpgat_status=="Yes" && preg_match("/[EeCcTtPp]/", $file_codes)) // User is running CpGAT pipeline and at least one dataset for spliced alignment exists.
    {
       $tracks =$tracks+1;
       $results.="<li class=\"result\">Track $tracks. <span class=\"cpgat-gff_color\">cpgat predictions</span> utilizing spliced $alignments dataset(s)</li>";
    }

    if((preg_match("/G/", $file_codes) && preg_match("/g/", $file_codes)) || $repeatmask_status=="Yes")
    {
       $tracks =$tracks+1;
       $alignments.="<span class=\"mask_color\">Repeat Mask</span>";
       $results.="<li class=\"result\">Track $tracks. <span class=\"mask_color\">masked</span> regions in genome</li>";
    }


    $results.=(preg_match("/g/", $file_codes) && preg_match("/s/", $file_codes))?"<li class=\"result\">Load Description text for <span class=\"gene_color\">gene predictions</span></li>":"";
    $results.=(preg_match("/g/", $file_codes) && preg_match("/S/", $file_codes))?"<li class=\"result\">Load Description text for <span class=\"cpgat_color\">cpgat predictions</span></li>":"";

$remote=$gsq_remote.$gth_remote; //flag for remote option
$outcome=array($results, $tracks, $remote);
return $outcome;
}


function update_results( $scaff, $est, $cdna, $tsa, $protein, $desc, $genegff, $cpgatgff, $cpgatrun){ //update actions from xGDB_Log
#  Arguments are from MySQL table: $Update_Data_GSEG, $Update_Data_EST, $Update_Data_cDNA, $Update_Data_TrAssembly, $Update_Data_Protein, $Update_Descriptions, $Update_Data_GeneModel, $Update_Data_CpGATModel, Update_Data_CpGAT

    $actions=array("scaff" => $scaff, "est" => $est, "cdna" => $cdna, "tsa" => $tsa, "protein" => $protein, "desc" => $desc, "gene-gff" => $genegff, "cpgat-gff" => $cpgatgff, "cpgat-run" => $cpgatrun);
    $actions_filtered = array_filter($actions, 'strlen'); // remove empties
    $number=0;
    $results="";
    foreach ($actions_filtered as $type => $action)
    {
       $number =$number+1;
       $TYPE=strtoupper($type);
       $results.="<li class=\"result\">$number. <span class=\"${type}_color\">$TYPE</span> data: $action existing track</li>";
    }
return array($results, $number);
}

# we want to find out if input directory has appropriate permissions (in progress 7/19/13)
# If owner is root then permissions must be d[][]r-x; if 
function input_directory_permissions($Input_Data_Path)
{ 

		$Input_Dir="";
		$Input_Dir = $Input_Data_Path;
		$permissions=""; // 
		$dir_detail =`ls -ld ${Input_Dir}`; //lists directory details
        $dir_match = "/(d\s+\.)\S+?(\S+)\s+(\S+).*$/"; # captures directory permissions, owner, group 
        if(preg_match($dir_match, $dir_detail, $matches))
        {
            $permiss=$matches[1];
            $owner=$matches[2];
            $group=$matches[3];
           $result="Directory owner=$owner, group=$group, permissions=$permiss";
        }
        else
        {
	       $result="Input directory is incorrect" ;	
        }
	       return $result;	
}

# read license contents (JSON)
function read_license_contents ($file) {
    if(file_exists($file))
    {
		if(filesize($file)>0)
        {
            if(filesize($file)<81960) # Limit large files 
            {
                $fd = fopen($file, "r");
                if(is_readable($file))
                {
                     $error = "";
                     $contents = fread($fd, filesize($file));
                }
                fclose($fd);
            }    
            else
            {
            $error="file too large";
            $contents="";
            }
        }
        else
        {
        $error="file missing";
        $contents="";
        }
        

		# Turn the response into json which php can manipulate
		if($handled_json = json_decode($contents,true))
		{
            $error .= "";
            $vendor = $handled_json['vendor'];
            $product = $handled_json['license']['product'];
            $version = $handled_json['license']['version'];
            $minversion = $handled_json['license']['minversion'];
            $expiry = $handled_json['license']['expiry'];
            $hostid = $handled_json['license']['hostid'];
            $customer = $handled_json['license']['customer'];
		}
		else
		{
            $error .= " file not readable as JSON";
            $vendor = "unknown";
            $product = "unknown";
            $version = "unknown";
            $minversion = "unknown";
            $expiry = "unknown";
            $hostid = "unknown";
            $customer = "unknown";
		}
		
    }
    
return array($error, $vendor, $product, $version, $minversion, $expiry, $hostid, $customer); 
}


?>
