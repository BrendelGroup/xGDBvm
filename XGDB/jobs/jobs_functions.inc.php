<?php
# updated 7-11-2016 JDuvick 

################
# Data Display #
################

//strip illegal characters from job name, create composite name

function job_name_strip($job_name) 
{
##  Truncate and strip all but alphanumeric and dash

 $job_name=substr($job_name, 0, 75);
 $job_name=preg_replace("/[^A-Za-z0-9\-]/", '-', $job_name); // all non alphanumerics become dashes
 $job_name=preg_replace("/\-\-+/", "-", $job_name); // collapse dashes to one
 $job_name=preg_replace("/\-$/", "", $job_name); // collapse dashes to one
 $job_name_stripped=strtolower($job_name); //lowercase

return $job_name_stripped;
}

//build dropdown of Development GDB  (from session if available as the selected one)

    function gdb_external_dropdown($current){
    
        $gdb_dropdown_result="<option value=\"\">- Select a GDB -</option>\n\n";
        $gdbQuery="SELECT distinct ID, DBname, Status FROM Genomes.xGDB_Log where (Status = 'Development' OR Status = 'Locked') order by ID";
        $get_gdb = $gdbQuery;
        $check_get_gdb = mysql_query($get_gdb);
        $ID="";
        $DBname="";
        $Status="";
        $selected="";
        while ($gdb_data = mysql_fetch_array($check_get_gdb)) {
                $ID = $gdb_data['ID'];
                $DBid = "GDB".substr(('00'.$ID), -3);
                $selected=($DBid==$current)?' selected="\"selected\"" ':'';
                $DBname = $gdb_data['DBname'];  
                $DBname = substr($DBname, 0, 30); //truncate long GDB name to fit better on page
                
                $Status = $gdb_data['Status'];  
                $Stat = substr($Status, 0, 3);
                $gdb_dropdown_result.= "<option $selected value=\"$ID\">$DBid (${Stat}) $DBname</option>\n\n";
            }   
            
            return $gdb_dropdown_result;
}

/* uid 
  job_id 
  job_type 
  program 
  softwareName 
  job_URL
  HPC_name 
  user 
  admin_email
  seq_type 
  genome_file_size 
  genome_segments 
  input_file_size 
  parameters 
  requested_time 
  processors 
  N 
  Comments text,
  job_start_time
  job_end_time 
  outcome 
*/
//build dropdown of Jobs  with date and type. (passes username from session)

    function jobs_dropdown($username, $type){
    
        switch ($type) 
        {
    case "status":
        $limit = "";
        break;
    case "output":
        $limit = " AND status!=\"PENDING\"";
        break;
    case "terminate":
        $limit = " AND job_end_time IS NULL AND status!=\"DELETED\"";
        }
    
        $jobs_dropdown_result="<option value=\"\">- Select a job (most recent first) -</option>\n\n";
        $jobsQuery="SELECT * FROM Admin.jobs where user=\"$username\" $limit order by job_submitted_time DESC";
        $get_jobs = $jobsQuery;
        $check_get_jobs = mysql_query($get_jobs);
        $job_id="";
        $DBname="";
        $Status="";
        $selected="";
        $n=0;
        while ($jobs_data = mysql_fetch_array($check_get_jobs)) {
                $n=$n+1;
                $job_id = $jobs_data['job_id'];
                $job_id_trimmed=ltrim(substr($job_id, 0, 16), '0');
                $job_name = $jobs_data['job_name'];
                $job_name_display=substr($job_name, 0, 15);
                $job_submitted_time = $jobs_data['job_submitted_time'];
                $status=$jobs_data['status'];
                $uid=$jobs_data['uid'];
                $seq_type = $jobs_data['seq_type']; 
                $input_file_size = $jobs_data['input_file_size'];                   
                $genome_file_size = $jobs_data['genome_file_size'];             
                $jobs_dropdown_result.= "<option value=\"${job_id}\">$uid. job-$job_id_trimmed: $job_name_display... ($status) - $job_submitted_time   </option>\n\n";
            }   
            
            return $jobs_dropdown_result;
}



###################
# Data Validation #
###################

function URLIsValid($url){ // simple check; from stackoverflow
        // first do some quick sanity checks:
        if(!$url || !is_string($url)){
            return false;
        }
        // quick check url is roughly a valid http request: ( http://blah/... ) 
        if( ! preg_match('/^http(s)?:\/\/[a-z0-9-]+(.[a-z0-9-]+)*(:[0-9]+)?(\/.*)?$/i', $url) ){
            return false;
        }
        // all good!
        return true;
    }

function URLIsReal($url){ //from stackoverflow; works in initial tests but not used currently.
   $resURL = curl_init(); 
    curl_setopt($resURL, CURLOPT_URL, $url); 
    curl_setopt($resURL, CURLOPT_BINARYTRANSFER, 1); 
    curl_setopt($resURL, CURLOPT_HEADERFUNCTION, 'curlHeaderCallback'); 
    curl_setopt($resURL, CURLOPT_FAILONERROR, 1); 
    curl_exec ($resURL); 
    $intReturnCode = curl_getinfo($resURL, CURLINFO_HTTP_CODE); 
    curl_close ($resURL); 
    if ($intReturnCode != 200 && $intReturnCode != 302 && $intReturnCode != 304) { 
        return false;
         }
    return true;
    }


### THIS SCRIPT WILL BE REFACTORED FOR JOBS

#######################
# File Type Validation #
#######################

function create_input_list($input_dir, $class, $dbpass)
{ 
//creates a formatted file or file list based on data $class (gdna, transcript (generic; includes est, cdna, tsa) or protein in argument.
// $input_dir is user-specified input data path
//Uses sub-function validate_file_type($name) to check validation and insert validation styling. 
//Returns an array with file list formatted, number of files, file size, and unformatted list.

    $db = mysql_connect("localhost", "gdbuser", $dbpass);
    if(!$db)
    {
        echo "Error: Could not connect to database!";
        exit;
    }
    mysql_select_db("Genomes");
    


    $file_list2="";
    $total_size=0;
    $fileID="";
#   $file_list =`ls -l $input_dir`; //
    $file_list =`ls -l --time-style=long-iso $input_dir`; //

    //system ("chop $list");
    $list = explode( "\n", $file_list ); //file list array
    $n=0; //valid file count
    # now make a version of the file path that can be assigned as an html id tag; escape all forward slashes since we are going to assign them as an html id tag
    $escaped_path=str_replace("/", "\/", $input_dir);
    if (count($list) < 100 ) #avoid huge directories.
    { 
        foreach ( $list as $item )
            {
                $pattern = "/\s+/";
                $replacement = " ";
                $item = preg_replace($pattern, $replacement, $item);
                if ( substr( $item, 0, 1 ) == "-" ) // identifies file (-rw-r--r-- etc) as opposed to directory (drwxrwxr-x etc.)
                {
                    $vals = explode( " ", $item );
                    $filename = $vals[count($vals)-1];
                    
                    if(validate_file_type($filename, $class)!="")# We want to list ONLY one class of filenames in this directory, not ALL files.
                    {       
                        $time = $vals[count($vals)-2];
                        $year_month_day = $vals[count($vals)-3];
                        $size = $vals[count($vals)-4];
                       $filestamp = "$filename:$size:${year_month_day}-$time"; # IMPORTANT: This format MUST be synchronized with FileStamp in /xGDBvm/scripts/xGDB_ValidateFiles.sh
                       $valid="";
                           $entries="";
                           $file_info_icon="information.png"; // This icon communicates validation status (by color) and is a click target for opening validation dialog box
                         if($get_entry="SELECT Valid, EntryCount FROM Datafiles where FileStamp='$filestamp'")
                             { 
                             $mysql_get_entry = mysql_query($get_entry); 
                             while($result_get_entry = mysql_fetch_array($mysql_get_entry)){
                               $valid=$result_get_entry[0]; # T F or NULL
                               $entries=$result_get_entry[1]; # number of entries
                             }
                        }
                        $valid_style="filenoteval"; # default; blue
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

##### Build more markup including escaped filepath and validation icons.  #####

                        $filepath = $escaped_path."\/".$filename; // We use this as a unique ID tag (with escaped slashes) for opening a Jquery dialog.

                        $info_icon_styled=   # for Jquery function
                           "
                              <span id=\"$filepath\" class=\"validatefile-button\" title=\"$filestamp\">
                                 <img class=\"nudge3\" src=\"/XGDB/images/$file_info_icon\" />
                              </span>
                           "
                           ;
##### For GeneSeqer jobs we need to know the Fasta header (defline) type; get this and create a GSQ parameter to pass in the form submission #####

                        $file_path_name="${input_dir}/${filename}";
                        $fasta_header_type=fasta_header_type($file_path_name, $valid_style);
                        $fasta_type=$fasta_header_type[0];
                        $GSQparam=$fasta_header_type[1];
                        
                        
                        $n=$n+1; # To list all files in directory, not just valid ones, move right angle bracket from below to this line.
                        $filename_type = validate_file_type($filename, $class);
                        $filename_type_styled="<span class=\"$valid_style\">${filename_type}:</span>";
                        $filename_styled="<span class=\"$valid_style italic\">$filename</span>";
                        $filename_display = $filename_type_styled."  ".$filename_styled.$info_icon_styled." (".$fasta_type.")".$list_header_line_styled; # see below; next function. 
                        
##### Calculate size in a reasonable numeric range #####
                        $total_size = $total_size + $size;
                        $unit = 0;  //0: bytes, 1:KB, 2: MB, 3: GB
                        while ($size > 1024 && $unit < 4)
                            {
                                $size = round($size / 1024,1);
                                $unit++;
                            }           
##### Continue building the file 'list item' core: filename, validation icon, date and time / size /  #####

                        $file_list2.= "
                        <li class='smallerfont'>
                           $filename_display / $size";

##### If file has been validated, # of entries is available from the MySQL query. Add this here at end of line if available. #####
                           
                        $entries_styled=(empty($entries))?"":
                        "<span style=\"color:#00A592\"> 
                            $entries entries
                        </span>";
                        
##### Determine unit for display and compute absolute size in order to get cumulative total #####
    
                        if($unit == 0) {$file_list2.= " bytes"; $units="bytes"; $abs_size = $size;}
                        if($unit == 1) {$file_list2.= " KB"; $units="KB"; $abs_size  = $size/.001;}
                        if($unit == 2) {$file_list2.= " MB"; $units="MB"; $abs_size = $size/.0000001;}
                        if($unit == 3) {$file_list2.= " GB"; $units="GB"; $abs_size =  $size/.0000000001;}
                        
##### Finish display with the size units and list end #####

                        $file_list2.=" / ".$entries_styled."</li>";
                    }
                }
            }
        }
    $total_size_display=convert_bytes($total_size, 1);
    if($n<1)
        {
        $class="smallerfont warning";
        }
        else
        {
        $class="smallerfont checked";
        }
    $file_list1="
        <span class=\"plaintext largerfont bold\">
            $input_dir 
        </span>
        <span class=\"normalfont\">
            $valid_count_display $invalid_count_display $noteval_count_display
        </span>";
    $file_list1.="
    <ul class='bullet1 indent2'>    ";
    
    $file_list3="</ul>";

##### Assemble the pieces of the header and list  #####

    $file_list_formatted = $file_list1.$file_list2.$file_list3;
    
    return array($file_list_formatted, $n, $total_size, $file_list); //$total_size in MB; we return $n in case we want to validate based on valid files

}


## The function below is called by create_input_list (above); matches file of name $name with standardized suffix according to $class (gdna or transcript) and returns human-readable interpretation (if any) with validation styling
function validate_file_type($name, $class) 
    {
    $types="";
    if($class=="transcript")
        {
                    $types = array
                (

                        "est.fa"   => "ESTs",
                        "cdna.fa"  => "cDNAs",
                        "tsa.fa"   => "transcript assemblies",
                );
        }
        elseif($class=="gdna")
        {
                    $types = array
                (
                        "gdna.fa"  => "genomic DNA",
                );
            
        }
        elseif($class=="est")
        {
                    $types = array
                (
                        "est.fa"  => "ESTs",
                );
            
        }       
        elseif($class=="cdna")
        {
                    $types = array
                (
                        "cdna.fa"  => "cDNAs",
                );
            
        }
        elseif($class=="tsa")
        {
                    $types = array
                (
                        "tsa.fa"  => "TSAs",
                );
            
        }
        elseif($class=="protein" || $class=="prot")
        {
                    $types = array
                (
                        "prot.fa"  => "proteins",
                );
            
        }
        
        if($types!="")
            {
        
                foreach($types as $ext => $type)
                {
            $test = "/\S*".$ext."$/i";
                        if(preg_match($test, $name, $match))
                        {
                                return $type;
                        }
                }
            }
            else
            {
        return "";
            }
    }



#########################
#  Fasta header type    #
#########################   

function fasta_header_type($file_path_name, $class){ //file_path_name is path/filename; class is gdna, transcript, protein.
$header=`head -1 $file_path_name`;
$genbank_pattern='/^>gi\|\d+/';
$simple_pattern='/^>\S+/';
if(preg_match($genbank_pattern, $header))
    {
    $type="GenBank";
    $GSQparam=($class=="gdna")?"l":"d";
    }
    elseif(preg_match($simple_pattern, $header))
    {
    $type="ID only";
    $GSQparam=($class=="gdna")?"L":"D";
    }
    else
    {
    $type="Unknown";
    $GSQparam="";
    }
    return array($type, $GSQparam);
}


#####################
#  Volume Checks    #
#####################   

function df_available($dir)
    { //we want display available space and directory list in the specified volume (this function also found under /xGDBvm/XGDB/conf/conf_functions.inc.php)

        $df =`df ${dir}`; #
                $avail_match = "/.*\s*(\S+?)\s+(\d+?)\s+(\d+?)\s+(\d+?)\s+.*(\/.*)$/"; # last directory (non-greedy) 
                preg_match( $avail_match, $df, $matches);
                
                $filesys=$matches[1];
                $avail=$matches[4];
                $mount=$matches[5];
                
    return array($filesys, $avail, $mount);
    }


#######################
#  Validate directory #
#######################

//returns presence/absence of a key directory and a css class for markup
function validate_dir($dir, $target, $description, $present, $absent) //$dir is the containing dir; $target is the dir whose presence/absence we are testing; others are tags
        {
        $result=$absent; //assume the worst
        $d_list =`ls -a ${dir}`; #All files in data directory
        $d_array = preg_split('/\s+/', $d_list);    //split list by spaces into an array
        if (count($d_array) < 500 ) //safety measure.
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
            elseif($result=="missing" || $result=="not found"  )
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


function calculate_scaffolds($input_path, $gsq_proc, $gth_proc) #input path is all that is needed to find gdna
{
    mysql_select_db("Genomes");
    $size=array();
    $query="SELECT * from Datafiles where Path='$input_path' and SeqType='gdna'"; 
    $get_query = mysql_query($query);
    $gsq_split_available=$gsq_proc/8; # 8:1 threads (processes)
    $gth_split_available=$gth_proc; # 1:1 with threads (processes)
    while ($row = mysql_fetch_array($get_query))
    {
       $sequence_count=$row['EntryCount'];
       $total_size =  $row['SizeTotal'];
       $size[1] =  $row['SizeLargest'];
       $size[2] =  $row['Size2'];
       $size[3] =  $row['Size3'];
       $size[4] =  $row['Size4'];
       $size[5] =  $row['Size5'];
       $size[6] =  $row['Size6'];
       $size[7] =  $row['Size7'];
       $size[8] =  $row['Size8'];
       $size[9] =  $row['Size9'];
       $size[10] =  $row['Size10'];
       $size[11] =  $row['Size11'];
       $size[12] =  $row['Size12'];
       $size[13] =  $row['Size13'];
       $size[14] =  $row['Size14'];
       $size[15] =  $row['Size15'];
       $size[16] =  $row['Size16'];
       $size[17] =  $row['Size17'];
       $size[18] =  $row['Size18'];
       $size[19] =  $row['Size19'];
       $size[20] =  $row['Size20'];
    }   
    $n=0;
    $cumulative_size=0;
    global $large_scaffold_count;
    while ($n < 21 && !isset($large_scaffold_count)) # keep looping until we have counted all the large scaffolds.
    {
        $n=$n+1;
        $curr_size=$size[$n];
        $cumulative_size=$cumulative_size + $curr_size;
        if($curr_size==0)
        {
            $large_scaffold_count=$n-1; # set because we ran out of scaffolds before there was any drop in size
        }
        else
        {
            $m=($n==1)?$n:$n-1; #previous scaff
            $prev_size=$size[$m];
            $size_diff=$prev_size-$curr_size;
            $ratio=$size_diff/$curr_size;
            if($ratio>10)
            {
               $large_scaffold_count=$n-1; # set because we ran out of large scaffolds and the remaining ones are much smaller
               
            }
        }
    }
$chunks=$n; # count of large individual scaffolds plus small 'remaineder' scaffolds catted together
$remainder_size=$total_size - $cumulative_size; # what's left after you subtract out the large scaffolds
$small_scaffold_count=$sequence_count - $large_scaffold_count;
$total_size_display=convert_bytes($total_size, 1); # convert to MB etc.
$cumulative_size_display=convert_bytes($cumulative_size, 1); # convert
$remainder_size_display=convert_bytes($remainder_size, 1);

$gsq_split=($chunks<$gsq_split_available)?$chunks:$gsq_split_available; # The actual split is dictated by relative count of chunks and available split .
$gsq_average=$total_size/$gsq_split;
$gsq_average_display=convert_bytes($gsq_average, 1); # convert 

$gth_split=($chunks<$gth_split_available)?$chunks:$gth_split_available; # The actual split is dictated by relative count of chunks and available split .
$gth_average=$total_size/$gth_split;
$gth_average_display=convert_bytes($gth_average, 1); # convert 

$text1 = ($large_scaffold_count==0)?"<p class=\"normalfont\" style=\"background-color:white\">Genome Files Not Yet Validated</p>":"<p class=\"normalfont\" style=\"background-color:white\">This genome has <b>$large_scaffold_count</b> large scaffolds totalling <b>$cumulative_size_display</b>";
$text2 = ($small_scaffold_count==0)?"</p>":" and <b>$small_scaffold_count</b> small scaffolds totaling <b>$remainder_size_display</b></p>";
$scaffold_size_display=$text1.$text2;
$gsq_split_display=($large_scaffold_count==0)?"":"<p class=\"normalfont\" style=\"background-color:white\">Genome will be split into <b>$gsq_split</b> files averaging <b>$gsq_average_display</b> for HPC <br />(<b>$gsq_proc</b> processors selected, <b>8</b> threads/file for MPI)</p>";
$gth_split_display=($large_scaffold_count==0)?"":"<p class=\"normalfont\" style=\"background-color:white\">Genome will be split into <b>$gth_split</b> files averaging <b>$gth_average_display</b> for HPC <br />(<b>$gth_proc</b> processors selected, <b>1</b> thread/file)</p>";

## GSQ benchmarking: 3.5 MB/hr per thread
## GTH benchmarking: 40 MB/hr per thread
$gsq_round=($gsq_average/3400000 > 1)?0:3; // don't show extra sig. fig. if >1 hr
$gth_round=($gth_average/40000000 > 1)?0:3; // don't show extra sig. fig. if >1 hr

$gsq_time=round($gsq_average/3400000, $gsq_round);
$gth_time=round($gth_average/40000000, $gth_round);
$gsq_time_display=($large_scaffold_count==0)?"":"<p class=\"normalfont\" style=\"background-color:white\">Estimated process time: <b>$gsq_time</b> hrs (actual time depends on query dataset size and other factors)</p>";
$gth_time_display=($large_scaffold_count==0)?"":"<p class=\"normalfont\" style=\"background-color:white\">Estimated process time: <b>$gth_time</b> hrs (actual time depends on query dataset size and other factors)</p>";

return array($large_scaffold_count, $small_scaffold_count, $chunks, $remainder_size, $gsq_split, $gth_split, $scaffold_size_display, $gsq_split_display, $gth_split_display, $gsq_time_display, $gth_time_display);
}

function convert_bytes($size, $round) {
    $unit = 0;  //0: bytes, 1: kilobytes, 2: megabytes, 3: gigabytes
    $rel_size=0;
    while ($size > 1024 && $unit < 4)
        {
            $size = round($size / 1024,$round);
            $unit++;
        }

    if($unit == 0) {$units = " bytes"; $abs_size = $size/1000000;}
    if($unit == 1) {$units = " KB"; $abs_size  = $size/1000;}
    if($unit == 2) {$units = " MB"; $abs_size = $size/1;}
    if($unit == 3) {$units = " GB"; $abs_size =  $size/.001;}
    $size_display="$size $units";

return $size_display;
            
}


function assign_job_stage($STATUS)
{
// Assign $stage variable so we know what section of the workflow we are in. 
// pre = no output expected (status STOPPED, KILLED, FAILED, ARCHIVING_FAILED)
// 1= not yet running  (status PENDING [not relevant in this script], SUBMITTING, PROCESSING_INPUTS, STAGING_INPUTS, STAGED, SUBMITTING, QUEUED)
// 2 = running (status RUNNING) - this is where we start the timer for 12 hr.
// 3 = just finished running (status CLEANING_UP)
// 4  = finished running but outputs not yet in place (status ARCHIVING, ARCHIVING_FINISHED)

    $dead = array('FAILED', 'STOPPED', 'KILLED', 'ARCHIVING_FAILED'); // no output
    $pre = array('SUBMITTED', 'PENDING', 'SUBMITTING', 'PROCESSING_INPUTS', 'STAGED', 'STAGING_JOB', 'STAGING_INPUTS', 'QUEUED'); // not yet running but on the way
    $in = array('RUNNING'); // processing data
    $out = array('CLEANING_UP'); // just finished processing data
    $post = array('ARCHIVING', 'ARCHIVING_FINISHED'); // putting data in place
    $done = array('FINISHED'); // done
    if(in_array($STATUS,$dead))
    {
        $stage = 'dead';
    }
    elseif(in_array($STATUS,$pre))
    {
        $stage = 'pre';
    }
    elseif(in_array($STATUS,$in))
    {
        $stage = 'in';
    }
    elseif(in_array($STATUS,$out))
    {
        $stage = 'out';
    }
    elseif(in_array($STATUS,$post))
    {
        $stage = 'post';
    }
    elseif(in_array($STATUS,$done))
    {
        $stage = 'done';
    }
    else
    {
        $stage = $STATUS; // e.g. 'error'
    }
return $stage;
}

##### App -related functions (see apps.php update_apps.php) #######

//build list of all available apps from Admin.apps

    function list_apps(){
        $apps_list="";
        $query="SELECT * FROM Admin.apps order by platform, program, app_id";
        $get_apps = mysql_query($query);
        $item="";
        while ($row = mysql_fetch_array($get_apps)) {
                $app_id = $row['app_id'];
                $program = $row['program'];
                $version = $row['version'];
                $platform = $row['platform'];
                $nodes = $row['nodes'];
                $proc_per_node = $row['proc_per_node'];
                $apps_list.= "<li>$app_id ($platform)  ${nodes} x ${proc_per_node} </li>";
            }   
            
            return $apps_list;
}

function apps_dropdown($program){

    #$app_dropdown_result="<option value=\"\">- Select an app -</option>\n\n";
    $app_dropdown_result="";
    $app_query="SELECT * FROM Admin.apps WHERE program = '$program' ORDER BY platform, nodes ASC";
    $get_apps = mysql_query($app_query);
    $ID="";
    $DBname="";
    $Status="";
    $selected="";
    while ($row = mysql_fetch_array($get_apps)) {
            $app_id = $row['app_id'];
            $platform = $row['platform'];
            $nodes = $row['nodes'];
            $proc_per_node = $row['proc_per_node'];
            $is_default = $row['is_default'];
            $selected=($is_default=='Y')?' selected="\"selected\"" ':'';
            $default=($is_default=='Y')?' (default)':'';
            $app_dropdown_result.= "<option $selected value=\"$app_id\">$app_id ($platform) ${nodes} x ${proc_per_node} $default </option>\n\n";
        }   
         
        return $app_dropdown_result;
}

###################
# AGAVE Settings  #
###################
# This becomes part of the Agave json string sent to Agave to configure status alerts for the VM and the user. 
# modified 7-11-16 by JDuvick to include policy.

function build_notifications_array($callbackUrl, $admin_email)
{
$notifications_array=($admin_email=="") # user hasn't set up an email alert
?
array
       (
            array
            (
               "url" =>  "$callbackUrl",
               "event" => "*",
               "persistent" => true,
               "policy"=> array
                  (
                       "retryStrategy" => "IMMEDIATE",
                       "retryLimit" => 20,
                       "retryRate" => 5,
                       "retryDelay" => 0,
                       "saveOnFailure" => true
                  )
            )
      )
:
array
       (
            array
            (
                 "url" => "$admin_email",
                 "event" => "RUNNING",
               "persistent" => false
            ),
            array
            (
               "url" => "$admin_email",
               "event" =>  "FAILED",
               "persistent" => false
            ),
            array
            (
               "url" => "$admin_email",
               "event" =>  "FINISHED",
               "persistent" => false
            ),
            array
            (
               "url" =>  "$callbackUrl",
               "event" => "*",
               "persistent" => true,
               "policy"=> array
                  (
                   "retryStrategy" => "IMMEDIATE",
                   "retryLimit" => 20,
                   "retryRate" => 5,
                   "retryDelay" => 0,
                   "saveOnFailure" => true
                  )
            )
      )
;

        
return $notifications_array;
}
?>
