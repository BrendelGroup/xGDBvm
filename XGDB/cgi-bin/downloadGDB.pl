#!/usr/bin/perl
use CGI ":all";
use GSQDB;
use GDBgui;

do 'SITEDEF.pl';
do 'GDBgui.pl';
do 'getPARAM.pl';

my $db;
my $dbString = param('db');
if ( $dbString =~ /^[0-9A-Za-z]*$/ )# whitelisted 5/19/15
{
$db=$dbidString;
} else {
    die("incorrect inputs");
}
my $dbid;
my $dbidString = param('dbid');
if ( $dbidString =~ /^[0-9]*$/ )# whitelisted 5/19/15
{
$dbid=$dbidString;
} else {
    die("incorrect inputs");
}
$dbid = defined($dbid)? $dbid : $#DBver;

my $GDBpage = new GDBgui();
my $xGDB=$DBver[$#DBver]->{DB};
my(@hits, $DBpath, $l_pos, $r_pos, $err); 
if (!param('hits')) {
		$id = $DBver[$#DBver]->{ExempleGI};
		$l_pos = $DBver[$#DBver]->{defaultL_pos};
		$r_pos = $DBver[$#DBver]->{defaultR_pos};
}
my $hitString = param('hits');
if ( $hitString =~ /^[0-9A-Za-z\_\:\.-]*$/ ) { # whitelisted 5/19/15
@hits = split(/\:/,$hitString);
$id = $hits[0];
$DBpath ="${DATADIR}";
$l_pos = $hits[1];
$r_pos = $hits[2];
$err = 0;
$err = param('error');
$db = $xGDB.'scaffold';
} else {
    die("incorrect inputs");
}
my @tempAS;
my @dbNames;
my $index = 0;
while ($DBver[$#DBver]->{tracks}[$index]->{trackname}) {
	my $trackName = $DBver[$#DBver]->{tracks}[$index]->{trackname};
	$dbNames[$index]=$DBver[$#DBver]->{tracks}[$index]->{db_table};	
	$tempAS[$index] = $trackName;
	$index++;
}

$index = 0;
my @AlignedSeqs;
for (my $i = 4; $i < $#tempAS+1; $i++) {
	if ($tempAS[$i] =~ m/EST/ or $dbNames[$i] eq 'est') {
		$AlignedSeqs[$index] = EST;
	} elsif ($tempAS[$i] =~ m/cDNA/) {
		$AlignedSeqs[$index] = cDNA;
	} elsif ($tempAS[$i] =~ m/TSA/) {
			$AlignedSeqs[$index] = TSA;
	} elsif ($tempAS[$i] =~ m/Query-Protein/ or $dbNames[$i]=~ /pep/) {
			$AlignedSeqs[$index] = 'Query-Protein';
	}elsif ($tempAS[$i] =~ m/-BAC/) {
		#$AlignedSeqs[$index] = BAC;
                # do nothing
                $index--;
	} elsif ($tempAS[$i] =~ m/yrGATE/) {
			$index--;
			#$AlignedSeqs[$index] = yrGATE;
	} elsif ($tempAS[$i] =~ m/annotation-mRNA/) {
			$index--;
			#$AlignedSeqs[$index] = Annotation;
	}
	$index++;
}
$AlignedSeqs[$index++] = "Gene Models (mRNA)";
$AlignedSeqs[$index] = "Gene Models (Protein)";

#my @GeneModels= ("GenBank","GFF","EMBL");
my @GeneModels= ("GenBank","EMBL");
my $hit = "$id:$l_pos:$r_pos";

## create page
my ($PAGE_CONTENTS,$seq,$msg);
$PAGE_CONTENTS = "<h1 class=\"bottommargin1\">Retrieve Sequences From Region <img id='genome_region_search' title='Help with Download from Region' class='xgdb-help-button' src='/XGDB/images/help-icon.png' alt='?' /></h1><br />";

$PAGE_CONTENTS .= "<div style=\"margin-left:2em\">\n";
$PAGE_CONTENTS .= "<h3 class=\"bottommargin2\">STEP 1. ENTER Scaffold ID and Region:</h3>\n";
$PAGE_CONTENTS .= "</form>\n";
if ($err == 1) {
	# The inputs were not integers.
	$PAGE_CONTENTS .= "ERROR: The inputs must be integers.<br />\n";
	$PAGE_CONTENTS .= "Please enter a different set of inputs.<br /><br />\n";
} elsif ($err == 2) {
	# The right position entered is less than the left position.
	$PAGE_CONTENTS .= "ERROR: The start position cannot be greater than the end position.<br />\n";
	$PAGE_CONTENTS .= "Please enter a different set of inputs.<br /><br />\n";
} elsif ($err == 3) {
	# The segment selected is nonexistent.
	$PAGE_CONTENTS .= "ERROR: The Segment ID entered is nonexistent.<br />\n";
	$PAGE_CONTENTS .= "Please enter a different set of inputs.<br /><br />\n";
} elsif ($err == 4) {
	# The Start position entered is not within the possible range.
	$PAGE_CONTENTS .= "ERROR: The start and/or end position is not within the range of possible values.<br />\n";
	$PAGE_CONTENTS .= "Please enter a different set of inputs.<br /><br />\n";
}

$PAGE_CONTENTS .= "<form action=\"${CGIPATH}formatReader.pl\" method=\"post\">\n";
$PAGE_CONTENTS .= "<input type=\"hidden\" name=\"program\" value=\"downloadGDB\" />\n";
$PAGE_CONTENTS .= "<input type=\"hidden\" name=\"db\" value=\"$db\" />\n";
$PAGE_CONTENTS .= "<input type=\"hidden\" name=\"dbid\" value=\"$cgi_paramHR->{dbid}\" />\n";
$PAGE_CONTENTS .= "<input type=\"hidden\" name=\"xGDB\" value=\"$xGDB\" />\n";
$PAGE_CONTENTS .= "<span class=\"normalfont bold\">Segment ID: \n";
$PAGE_CONTENTS .= "<input type=\"text\" name=\"id\" size=\"8\" value=\"$id\" />\n";
$PAGE_CONTENTS .= "Start: \n";
$PAGE_CONTENTS .= "<input type=\"text\" name=\"l_pos\" size=\"8\" value=\"$l_pos\" />\n";
$PAGE_CONTENTS .= "End: \n";
$PAGE_CONTENTS .= "<input type=\"text\" name=\"r_pos\" size=\"8\" value=\"$r_pos\" />\n";
$PAGE_CONTENTS .= "<br /><br />\n";
$PAGE_CONTENTS .= "<h3 class=\"bottommargin1 topmargin1\">STEP 2. Click 'Go' to set up region query:</h3>\n";
$PAGE_CONTENTS .= "<input type=\"submit\" value=\"Go\" />\n";
$PAGE_CONTENTS .= "</span></form>\n";
$PAGE_CONTENTS .= "<br /><br /><br />\n";

# Only print the following portions of the page if the genome region is possible.
if (!$err) {
$PAGE_CONTENTS .= "<h3 class=\"bottommargin1\">STEP 3a: Click to display Genome Segment</h3>\n";
$PAGE_CONTENTS .= "<form action=\"${CGIPATH}formatReader.pl\" method=\"post\">\n";
$PAGE_CONTENTS .= "<input type=\"hidden\" name=\"program\" value=\"downloadRegion\" />\n";
$PAGE_CONTENTS .= "<input type=\"hidden\" name=\"db\" value=\"$db\" />\n";
$PAGE_CONTENTS .= "<input type=\"hidden\" name=\"GSEGflag\" value=1 />\n";
$PAGE_CONTENTS .= "<input type=\"hidden\" name=\"dbid\" value=\"$cgi_paramHR->{dbid}\" />\n";
$PAGE_CONTENTS .= "<input type=\"hidden\" name=\"hits\" value=\"$hit\" />\n";
$PAGE_CONTENTS .= "<input type=\"hidden\" name=\"DBpath\" value=\"$DBpath\" />\n";
$PAGE_CONTENTS .= "<input type=\"hidden\" name=\"id\" value=\"$id\" />\n";
$PAGE_CONTENTS .= "<input type=\"hidden\" name=\"l_pos\" value=\"$l_pos\" />\n";$PAGE_CONTENTS .= "<input type=\"hidden\" name=\"r_pos\" value=\"$r_pos\" />\n";
$PAGE_CONTENTS .= "<input type=\"hidden\" name=\"xGDB\" value=\"$xGDB\" />\n";
$PAGE_CONTENTS .= "<input type=\"submit\" value=\"Display Genomic Sequence for Download\" />\n";
$PAGE_CONTENTS .= "</form>\n";
$PAGE_CONTENTS .= "<br /><br /><br />\n";

$PAGE_CONTENTS .= "<h3 class=\"bottommargin1\">STEP 3b: Select and click to display Aligned/Annotated Sequences:</h3>\n";
$PAGE_CONTENTS .= "<form action=\"${CGIPATH}formatReader.pl\" method=\"post\">\n";
$PAGE_CONTENTS .= "<input type=\"hidden\" name=\"program\" value=\"downloadRegion\" />\n";
$PAGE_CONTENTS .= "<input type=\"hidden\" name=\"xGDB\" value=\"$xGDB\" />\n";
$PAGE_CONTENTS .= "<input type=\"hidden\" name=\"id\" value=\"$id\" />\n";
$PAGE_CONTENTS .= "<input type=\"hidden\" name=\"l_pos\" value=\"$l_pos\" />\n";
$PAGE_CONTENTS .= "<input type=\"hidden\" name=\"r_pos\" value=\"$r_pos\" />\n";
$PAGE_CONTENTS .= "<input type=\"hidden\" name=\"DBpath\" value=\"$DBpath\" />\n";
my $count = 0;
foreach $AlignedSeq (@AlignedSeqs){
	$PAGE_CONTENTS .= "<input type=\"radio\" name=\"sequence\" value=\"$AlignedSeq\" id=\"alignedseq$count\" />\n";
	$PAGE_CONTENTS .= "<label for=\"alignedseq$count\">$AlignedSeq</label>\n";
	$count++;
}
$PAGE_CONTENTS .= "<br /><br />\n";
$PAGE_CONTENTS .= "<input type=\"submit\" value=\"Display Aligned/Computed Sequences for Download\" />\n";
$PAGE_CONTENTS .= "</form>\n";
$PAGE_CONTENTS .= "<br /><br /><br />\n";

$PAGE_CONTENTS .= "<h3 class=\"bottommargin1\">STEP 3c: Select and click to display formatted Genome Annotations</h3>\n";
$PAGE_CONTENTS .= "<form action=\"${CGIPATH}formatReader.pl\" method=\"post\">\n";
$PAGE_CONTENTS .= "<input type=\"hidden\" name=\"program\" value=\"xGDBtoGenBank\" />\n";
$PAGE_CONTENTS .= "<input type=\"hidden\" name=\"xGDB\" value=\"$xGDB\" />\n";
$PAGE_CONTENTS .= "<input type=\"hidden\" name=\"id\" value=\"$id\" />\n";
$PAGE_CONTENTS .= "<input type=\"hidden\" name=\"l_pos\" value=\"$l_pos\" />\n";
$PAGE_CONTENTS .= "<input type=\"hidden\" name=\"r_pos\" value=\"$r_pos\" />\n";
$PAGE_CONTENTS .= "<input type=\"hidden\" name=\"DBpath\" value=\"$DBpath\" />\n";
$count = 0;
foreach $GeneModel (@GeneModels){
	$PAGE_CONTENTS .= "<input type=\"radio\" name=\"format\" value=\"$GeneModel\" id=\"genemodel$count\" />\n";
	$PAGE_CONTENTS .= "<label for=\"genemodel$count\">$GeneModel</label>\n";
	$count++;
}
$PAGE_CONTENTS .= "<br /><br />\n";
$PAGE_CONTENTS .= "<input type=\"submit\" value=\"Display Formatted Genome Annotations for Download\" />\n";
$PAGE_CONTENTS .= "</form>\n";

}# ends the portion of page that is only printed if genomic region is possible

$cgi_paramHR->{headHR}    = {-cookie=>[$sCookie]};
$cgi_paramHR->{htmlHR}    = {-title=>"${SITENAMEshort} Query:Download",
			     -script=>[{-src=>"${JSPATH}BRview.js"}]
			    };
$cgi_paramHR->{main}      = $PAGE_CONTENTS;

$GDBpage->printXGDB_page($cgi_paramHR);

exit;
