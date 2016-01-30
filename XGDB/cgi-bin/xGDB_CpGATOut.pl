#!/usr/bin/perl -I/xGDBvm/XGDB/perllib -I/xGDBvm/XGDB/perllib/DSO -I/xGDBvm/INSTANCES/



use CGI ":all";
use GSQDB;
use GDBgui;
use DBI;

#use CGI qw/:standard :html escapeHTML sub/;
#use IO::File;

do 'SITEDEF.pl';
do 'getPARAM.pl';
do 'AnnoPipe_conf.pl';

my $myDB=$DBver[$#DBver]->{DB};
my $TEST="TEST";
my $ufname=param('ufname'); # upload file name
my $dbArray_Protein = param('pdb');
my $dbArray_TRANSCRIPT = param('tdb');
my $xgdbFlag = param('xgdbFlag');
# my $xgdbFlag="TEST";
my $DefaultFlag = param('DefaultFlag');
my $CpGATparameter = param('CpGATparameter');
my @dbArray_Protein = split (/ /,$dbArray_Protein);
my @dbArray_TRANSCRIPT = split (/ /,$dbArray_TRANSCRIPT);
#my $XGDB=$GV->{dbTitle};
my $DBname=$GV->{dbName};
my $random_number = rand(); 

my $db=new GSQDB($cgi_paramHR);
my $GDBpage = new GDBgui();
my $file_path;
my $file_prefix;
$cgi_paramHR->{altCONTEXT} = "BAC";
my $addtrackDIV=$db->AddTrackBotton($cgi_paramHR); # function in GSQDB.pm; adds a button to launch add user track feature (jquery-ui)

## set the file path prefix based on passed parameter:
my $filePre=$1 if ($ufname=~ /(\S+)\.filtered\.gff3/); # 
my $DNA_id=$filePre;
my ($gseg_gi,$l_pos,$r_pos);
#parse the gseg_gi and range from the ID
$DNA_id =~ s/^.*\///;
$DNA_id =~ s/\.[^\.]+$//;
if ($DNA_id =~ /(\S+)from(\d+)to(\d+)/){
        $gseg_gi=$1; # this is the one we need
        $l_pos=$2;
        $r_pos=$3;
}

my $testout;
my $test="hi";
if ($test=~ /(\S*)/)
{
$testout=$1;
}else{
$testout="null";
}
#$ufname ="/xGDBvm/tmp/GDB007/CpGAT/CpGAT-1399467004/scaff_28153from1to90000.filtered.gff3";
#if ($ufname=~ /(\/xGDBvm\/tmp\/GDB\d+\/CpGAT\/CPGAT-\d+\/?)(\S+\.filtered\.gff3)/)  # /xGDBvm/tmp/GDB006/CpGAT/CpGAT-1398372293/scaff_28153from1to90000.filtered.gff3 
if ($ufname=~ /(\/xGDBvm\/tmp\/GDB\d+\/CpGAT\/CpGAT-\d+\/)(\S+)\.filtered\.gff3/)  # e.g. /xGDBvm/tmp/GDB006/CpGAT/CpGAT-1398372293/scaff_28153from1to90000.filtered.gff3 
{  
    $file_path=$1; #/xGDBvm/tmp/GDB006/CpGAT/CpGAT-1398372293/
    $file_prefix=$2;  # scaff_28153from1to90000
} 
###### This section deals with .gff files which may contain altered genome segment IDs due to some CpGAT requirement
###### It renames these IDs to the original form. Both .filtered and .unfiltered gff3 file are handled.
###### TO DO: Move this section into WebCpGAT and iterate over ALL .gff3 files so they are ALL CORRECTLY FORMATTED
# create a temp file with correct IDs

my $filtered = $ufname; # ~.filtered.gff3
my $unfiltered = $filePre.".unfiltered.gff3";
@myFiles = ($filtered, $unfiltered);

foreach $file (@myFiles) {
 	
  open(FILE, "$file") || die("Cannot open $file");
    open(OUT,">$file.corrected");
   while(<FILE>)
   {	
	   if ($_ =~ /^#/ or $_ =~/^\s+/){
		 print OUT "$_";
	   }else{
        ($tmpchr,$source,$type,$tmpl_pos,$tmpr_pos,$score,$tmpstrand,$phase,$attributes) = split(/\t/, $_);
    	$tmpchr=$gseg_gi; # CpGAT changes ID underscores to dashes when creating GFF3 table; thus we had to substitute back in the actual ID (with underscores, if any)
	   #$tmpl_pos = $tmpl_pos + $l_pos -1;
	   #$tmpr_pos = $tmpr_pos + $l_pos -1;
     	print OUT "$tmpchr\t$source\t$type\t$tmpl_pos\t$tmpr_pos\t$score\t$tmpstrand\t$phase\t$attributes";
	   }
   }
# overwrite the old .gff3 with the corrected one. Done!
   system("mv $file.corrected $file ");
}
###### End section ######

if ($DefaultFlag){
	$CpGATparameter =~ s/-gth\s+\S+//;
	 $PAGE_CONTENTS .= "<h1 class='bottommargin1'>CpGAT Output</h1> <p><b>You have selected the following CpGAT parameters:</b><br />";
            $PAGE_CONTENTS .= "<i>$CpGATparameter</i><br />";
	$PAGE_CONTENTS .= "<p><b>You have selected the evidence alignments from: $xgdbFlag</b><br />";
}else{
      if($dbArray_Protein)
        { $PAGE_CONTENTS .= "<p><b>You have selected the following protein databases:</b></p><br />";
	        foreach my $dbArraymember (@dbArray_Protein)
	        {
		      my @files=split(/\//,$dbArraymember);
              my $file = $files[$#files];
              $PAGE_CONTENTS .= "<i>$file</i><br />";
            }
        }
     if($dbArray_TRANSCRIPT)
        {
	      $PAGE_CONTENTS .= "<p><b>You have selected the following transcript databases:</b></p><br />";
	      foreach my $dbArraymember (@dbArray_TRANSCRIPT)
	        {
		      my @files=split(/\//,$dbArraymember);
		      my $file = $files[$#files];
              $PAGE_CONTENTS .= "<i>$file</i><br />";
           }
        }
   $PAGE_CONTENTS .= "<h1  >CpGAT Output</h1> <p>CpGAT parameters were: <i>$CpGATparameter</i></p>";
   $PAGE_CONTENTS .= "<p class=\"topmargin1\">The genome region is $gseg_gi:$l_pos..$r_pos <a href=\"/$xgdbFlag/cgi-bin/getGSEG_Region.pl?dbid=0&amp;gseg_gi=$gseg_gi&amp;bac_lpos=$l_pos&amp;bac_rpos=$r_pos\">(return to Genome Context view)</a></p>";
}
$PAGE_CONTENTS .= "<h2 class=\"topmargin1	 bottommargin1\">Output files<span class='heading'> Click filename to view contents/save to your local drive:</span></h2>";
$PAGE_CONTENTS .= "<p class='indent2'>NOTE: <b>\".unfiltered.\"</b> files include <i>ab inito</i> models lacking blast hits.</p>";
$PAGE_CONTENTS .= "<div class='featurediv'> <ul class='bullet1 indent2'>";

$filePre= $filePre .".*filtered";
my @files=qx(ls ${filePre}.gff3 ${filePre}.pep ${filePre}.trans);

#jfdenton modified the file collection loop to include rootPath
#create hyperlinked file list
foreach (@files) {
    my $path=$rootPATH;
	my $file=$_;
	my $size=qx(wc -c $file);
	my @sizes=split(/\s/,$size);
	my $size = $sizes[0];
     $count= qx(grep -c -P "\tmRNA\t" $file)." gene models" if ($file =~ /.*\.gff3/);
     $count= qx(grep -c ">" $file)."fasta translations" if ($file =~ /.*\.pep/);
     $count= qx(grep -c ">" $file)." fasta transcripts" if ($file =~ /.*\.trans/);

#    else
#    {
#    my $count="0";
#    }
	$file =~ s/\/xGDBvm\///;
        $file = $path . $file;
	my @labels=split(/\//,$file);
	my $label = $labels[$#labels];
	$label =~ s/\n//;
        print STDERR $file;
	if ($label =~ /Delete/){
	 }else{
	  $PAGE_CONTENTS .= "<li><span class=\"normalfont\" ><a href=\"$file\">$label</a> - $size bytes; $count </span></li>";
	}
}
$PAGE_CONTENTS .= "</ul>";
$PAGE_CONTENTS .= "<div id=\"options\">";
$PAGE_CONTENTS .= "<h2 class=\"topmargin2 bottommargin1\">Displaying CpGAT Output in your Genome Browser</h2>";

$PAGE_CONTENTS .= "<div id=\"option1\"><hr />";
$PAGE_CONTENTS .= "<h3 class=\"topmargin2 bottommargin2 bold\">Option 1: Create User Track</h1> <p class=\"indent2\">Creates a temporary <span class='user_color'>User</span> track visible only to you; can be deleted. <span class=\"heading\">(Note: user tracks do not appear in yrGATE evidence plot. See Option 2 if you require this.</span> </p><ol class='orderedlist1 indent2'><li>Click filtered or unfiltered ~.gff3 file above, and save it to your local drive.</li><li>Click 'Add User Track' button below and follow instructions to upload and create a temporary user track</li><li> Return to <a href=\"/$xgdbFlag/cgi-bin/getGSEG_Region.pl?dbid=0&amp;gseg_gi=$gseg_gi&amp;bac_lpos=$l_pos&bac_lpos=$l_pos&amp;bac_rpos=$r_pos\">Genome Context view</a></li></ol>";
$PAGE_CONTENTS .= "<div style=\"padding: 20px\" id=\"temp_track\">
$addtrackDIV
</div>
</div>
</div>
<!-- end featurediv -->
<br /><hr />
";
$PAGE_CONTENTS .= "<h3 class=\"topmargin2 bottommargin2 bold\">Option 2: APPEND CpGAT Track</h3> <p class=\"indent2\">Creates or appends a <span class='cpgat_color'>CpGAT</span> track using the GDB Update pipeline.</p><ol class='orderedlist1 indent2'><li>Inspect the ~.gff3 files above and decide whether you want to upload <b>filtered</b> or <b>unfiltered</b> models. </li><li> Click 'Filtered' or 'Unfiltered' button below. This will automatically configure your GDB to upload this output as a CpGAT track, appending existing models. </li><li>You will be redirected to your <a href=\"/XGDB/conf/view.php?id=$xgdbFlag\">GDB Configuration page</a>, which should now have <span class='Update'>'Ready to Update'</span> status.</li><li>Confirm expected track outcome, and then click 'Data Process Options &rarr; 'Update $xgdbFlag'</li></ol>";
$PAGE_CONTENTS .= "<div style=\"padding: 20px\" id=\"append_div\">";
$PAGE_CONTENTS .="
<span class=\"normalfont\">Configure to <b>APPEND</b> CpGAT using:</span> &nbsp;
<a class=\"xgdb_button short colorGR6\" href=\"/XGDB/conf/cpgat_update_exec.php?update=Append&amp;GDB=$xgdbFlag&amp;file_path=$file_path&amp;file_prefix=$file_prefix&amp;filter_status=filtered\" onclick=\"return confirm('Do you really want to APPEND these filtered models to CpGAT track?')\">Filtered</a>
&nbsp;&nbsp;
<a class=\"xgdb_button short colorGR6\" href=\"/XGDB/conf/cpgat_update_exec.php?update=Append&amp;GDB=$xgdbFlag&amp;file_path=$file_path&amp;file_prefix=$file_prefix&amp;filter_status=unfiltered\" onclick=\"return confirm('Do you really want to APPEND these unfiltered models to CpGAT track?')\">Unfiltered</a> 
";
$PAGE_CONTENTS .= "</div>
<br /><hr />";

$PAGE_CONTENTS .= "<h3 class=\"topmargin2 bottommargin2 bold\">Option 3: REPLACE CpGAT Track</h3> <p class=\"indent2\">Replaces existing <span class='cpgat_color'>CpGAT</span> track data using the GDB Update pipeline. <span class=\"alertnotice bold\">WARNING: THIS OPTION WILL REPLACE CpGAT MODELS GLOBALLY, NOT JUST FROM THIS REGION!!! USE ADVISEDLY</span></p><ol class='orderedlist1 indent2'><li>Inspect the ~.gff3 files above and decide whether you want to upload <b>filtered</b> or <b>unfiltered</b> models. </li><li> Click the 'Filtered' or 'Unfiltered' button below. This will automatically configure your GDB to upload this output as a <span style=\"background-color:magenta\">CpGAT </span> track, replacing existing models. </li><li>You will be redirected to your <a href=\"/XGDB/conf/view.php?id=$xgdbFlag\">GDB Configuration page</a>, which should now have <span class='Update'>'Ready to Update'</span> status.</li><li>Confirm expected track outcome, and then click 'Data Process Options &rarr; 'Update $xgdbFlag'</li></ol>";

$PAGE_CONTENTS .= "<div style=\"padding: 20px\" id=\"replace_div\">";
$PAGE_CONTENTS .="
<span class=\"normalfont\">Configure to <span class=\"bold redfont\">REPLACE</span> CpGAT using:</span> &nbsp;
<a class=\"xgdb_button short colorGR6\" href=\"/XGDB/conf/cpgat_update_exec.php?update=Replace&amp;GDB=$xgdbFlag&amp;file_path=$file_path&amp;file_prefix=$file_prefix&amp;filter_status=filtered\" onclick=\"return confirm('Do you really want to REPLACE existing CpGAT models with filtered models from this region? THIS STEP CANNOT BE UNDONE')\">Filtered</a>
&nbsp;&nbsp;
<a class=\"xgdb_button short colorGR6\" href=\"/XGDB/conf/cpgat_update_exec.php?update=Replace&amp;GDB=$xgdbFlag&amp;file_path=$file_path&amp;file_prefix=$file_prefix&amp;filter_status=unfiltered\" onclick=\"return confirm('Do you really want to REPLACE existing CpGAT models with unfiltered models from this region? THIS STEP CANNOT BE UNDONE')\">Unfiltered</a>
";
$PAGE_CONTENTS .= "</div><hr />";
$PAGE_CONTENTS .= "</div>";
$cgi_paramHR->{headHR}    = {-cookie=>[$sCookie]};
$cgi_paramHR->{htmlHR}    = {-title=>"CpGAT Output-${SITENAMEshort} ",
			     -script=>[
				  {-src=>"${JSPATH}dynamicWindow.js"},
				  {-src=>"${JSPATH}sortable_context_region.js"},
					{-src=>"${JSPATH}ajaxfileupload.js"},
				],
			    };
$cgi_paramHR->{main}      = $PAGE_CONTENTS;
$GDBpage->printXGDB_page($cgi_paramHR);

