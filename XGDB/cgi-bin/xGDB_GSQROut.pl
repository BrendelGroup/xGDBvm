#!/usr/bin/perl -I/xGDBvm/XGDB/perllib -I/xGDBvm/XGDB/perllib/DSO -I/xGDBvm/INSTANCES/
#modified by ZmDB/PlantGDB staffs from original Lincoln Stein's Blast used at CSHL
#Last modified by Qunfeng: query by GI or Acc or GSScontigID
# $Id: PlantGDBblast,v 1.2 2008/01/29 15:45:30 plantgdb Exp $


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

my $ufname=param('ufname');
my $dbArray_Protein = param('pdb');
my $dbArray_TRANSCRIPT = param('tdb');
my $CpGATparameter = param('CpGATparameter');
my $xgdbFlag = param('xgdbFlag');
my $DefaultFlag = param('DefaultFlag');
my @dbArray_Protein = split (/ /,$dbArray_Protein);
my @dbArray_TRANSCRIPT = split (/ /,$dbArray_TRANSCRIPT);
#my $XGDB=$GV->{dbTitle};
my $xGDB=$xgdbFlag;
my $DBname=$GV->{dbName};

my $db=new GSQDB($cgi_paramHR);
my $GDBpage = new GDBgui();

$cgi_paramHR->{altCONTEXT} = "BAC";
my $contextDIV=$db->AddTrackBotton($cgi_paramHR);
#my $contextDIV=$db->getContextRulerHeaderCtrlDIV($cgi_paramHR);
#my $contextDIV=$db->showREGION($cgi_paramHR);

my $filePre=$1 if ($ufname=~ /(\S+)\.filtered\.gff/);
my $DNA_id=$filePre;
my ($gseg_gi,$l_pos,$r_pos);
$DNA_id =~ s/^.*\///;
$DNA_id =~ s/\.[^\.]+$//;
if ($DNA_id =~ /(\S+)from(\d+)to(\d+)/){
        $gseg_gi=$1;
        $l_pos=$2;
        $r_pos=$3;
}
open(FILE, "$ufname") || die("Cannot open $ufname");
open(OUT,">$ufname.upload");
while(<FILE>){	
	if ($_ =~ /^#/ or $_ =~/^\s+/){
		print OUT "$_";
	}else{
        ($tmpchr,$source,$type,$tmpl_pos,$tmpr_pos,$score,$tmpstrand,$phase,$attributes) = split(/\t/, $_);
	$tmpchr=$gseg_gi;
	#$tmpl_pos = $tmpl_pos + $l_pos -1;
	#$tmpr_pos = $tmpr_pos + $l_pos -1;
	print OUT "$tmpchr\t$source\t$type\t$tmpl_pos\t$tmpr_pos\t$score\t$tmpstrand\t$phase\t$attributes";
	}
}
if ($DefaultFlag){
	$CpGATparameter =~ s/-gth\s+\S+//;
	 $PAGE_CONTENTS .= "<p><b>You have selected the following CpGAT parameters:</b><br />";
            $PAGE_CONTENTS .= "<i>$CpGATparameter</i><br />";
	$PAGE_CONTENTS .= "<p><b>You have selected the evidence alignments from: $xgdbFlag</b><br />";
}else{
        $PAGE_CONTENTS .= "<b>You have selected the following protein databases:</b><br />";
	foreach my $dbArraymember (@dbArray_Protein){
		 my @files=split(/\//,$dbArraymember);
                my $file = $files[$#files];
            $PAGE_CONTENTS .= "<i>$file</i><br />";

        }
	$PAGE_CONTENTS .= "<p><b>You have selected the following transcript databases:</b><br />";
	foreach my $dbArraymember (@dbArray_TRANSCRIPT){
		my @files=split(/\//,$dbArraymember);
		my $file = $files[$#files];
            $PAGE_CONTENTS .= "<i>$file</i><br />";
        }
	$PAGE_CONTENTS .= "<p><b>You have selected the following CpGAT parameters:</b><br />";
            $PAGE_CONTENTS .= "<i>$CpGATparameter</i><br /><br />";
                #print br();
}
$PAGE_CONTENTS .= "<b>Click below to view CpGAT output files:</b><br />";
$PAGE_CONTENTS .= "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Formats include <b>fasta</b> (.gene, .CDS, or .pep),  <b>gff3</b> (.gb.gff3, .gff3), <b>gbrowse upload</b> (.gb.txt), and <b>xGDB</b> (.sql)<br />";
$PAGE_CONTENTS .= "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; NOTE: <b>\".unfiltered.\"</b> files include <i>ab inito</i> models lacking UniRef90 hits (if any).<br />";
$PAGE_CONTENTS .= "<pre>";
$filePre= $filePre ."?*";
my @files=qx(ls $filePre);

#jfdenton modified the file collection loop to include rootPath

foreach (@files) {
        my $path=$rootPATH;
	my $file=$_;
	$file =~ s/\/xGDBvm\///;
        $file = $path . $file;
	my @lables=split(/\//,$file);
	my $lable = $lables[$#lables];
        print STDERR $file;
	if ($lable =~ /Delete/){
	 }else{
	  $PAGE_CONTENTS .= "<a href=\"$file\">$lable</i></a>";
	}
}
$PAGE_CONTENTS .= "</pre>";
if ($gseg_gi && $l_pos && $r_pos){
$PAGE_CONTENTS .= "<b>Your genome region is $gseg_gi:$l_pos..$r_pos<br />";
$PAGE_CONTENTS .= "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<a title=\"Click here to view in genome browser page (opens a new web page)\" target=\"_blank\" href=\"$GV->{CGIPATH}getGSEG_Region.pl?gseg_gi=$gseg_gi&bac_lpos=$l_pos&bac_rpos=$r_pos\">Click to view genome context</a><br /><br />";
}

$PAGE_CONTENTS .= "<input type=\"hidden\" name=\"ufname\" value=\"$ufname\" />\n<br /><br />";
$PAGE_CONTENTS .= "<br />
$contextDIV
<br /><br />";
$cgi_paramHR->{headHR}    = {-cookie=>[$sCookie]};
$cgi_paramHR->{htmlHR}    = {-title=>"${SITENAMEshort} CpGAT Output",
			     -script=>[
				  {-src=>"${JSPATH}dynamicWindow.js"},
				  {-src=>"${JSPATH}sortable_context_region.js"},
					{-src=>"${JSPATH}ajaxfileupload.js"},
				],
			    };
$cgi_paramHR->{main}      = $PAGE_CONTENTS;
$GDBpage->printXGDB_page($cgi_paramHR);
#print "</orm>";

