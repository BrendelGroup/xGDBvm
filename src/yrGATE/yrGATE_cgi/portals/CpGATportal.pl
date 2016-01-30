#!/usr/bin/perl
# yrGATE portal for template

#use LWP::Simple;
use CGI ":all";
use LWP::UserAgent;
use HTTP::Request::Common qw(POST);

do 'SITEDEF.pl';
require 'yrGATE_conf.pl';
require '../yrGATE_functions.pl';

do 'SITEDEF.pl';

$seq = param("GenomeSequence");
$start = param("start");
$end = param("end");
$chr = param("chr");
my $nomask = param('_nomask');
my $FLcDNAlist = param('_FLcDNAlist');
my $relax = param('_relax');
my $nopasa = param('_nopasa');
my $gth = param('_gth');
my $bgf = param('_bgf');
my $augustus = param('_augustus');
my $genemark = param('_genemark');
my $noblast = param('_noblast');
$xGDB=$GV->{dbTitle};

my $DNAid = $chr;

$DNAid = 'AtChr'. $DNAid if ($xGDB =~ /At/);
$DNAid = 'Bd'. $DNAid if ($xGDB =~ /Bd/);
$DNAid = 'MtChr'. $DNAid if ($xGDB =~ /Mt/);
$DNAid = 'OsChr'. $DNAid if ($xGDB =~ /Os/);
$DNAid = 'PtChr'. $DNAid if ($xGDB =~ /Pt/);
$DNAid = 'VvChr'. $DNAid if ($xGDB =~ /Vv/);
$DNAid = 'SbChr'. $DNAid if ($xGDB =~ /Sb/);
$DNAid = 'LjChr'. $DNAid if ($xGDB =~ /Lj/);
$DNAid = 'chr'. $DNAid if ($xGDB =~ /Zm/);

if ($xGDB =~ /Gm/){
        $DNAid = 'Gm0'. $DNAid if ($DNAid<10);
        $DNAid = 'Gm' . $DNAid if ($DNAid>=10);
}


if ($seq eq ""){
    print "No genome sequence defined.";
    exit;
}
$seq = ">$DNAid"."-"."$start"."-"."$end"."\n"."$seq";

print header();
print "<!DOCTYPE html PUBLIC '-//W3C//DTD XHTML 1.0 Transitional//EN' 'http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd'>
<html xmlns='http://www.w3.org/1999/xhtml' xml:lang='en'>
<head><title>yrGATE Portal to CpGAT<\/title>
<link href='/XGDB/css/plantgdb.css' type='text/css' rel='stylesheet'>
<link href='/src/yrGATE/yrGATE.css' type='text/css' rel='stylesheet'>
</head>

<body>
<div class='sectioncontainer'>

<form name='cpgatportal' action=\"/XGDB/cgi-bin/WebCpGAT.pl?DefaultFlag=On&GDB=$xGDB&dnaID=$DNAid&start=$start&end=$end\" method='post'>

<input type='hidden' name='GDB' value=\"$xGDB\" />

<table width='100%' cellspacing='0'>
<tr><td style='padding:10px;background:orange; width:50%; font-family:Arial;font-weight:bold;font-size:24px'>yrGATE Portal to CpGAT</td>
<td style='padding:10px;background:orange; width:50%; font-family:Arial;font-weight:bold;font-size:12px'>This portal uses EVM and PASA to compute optimal gene models for this genome region, based on pre-computed spliced-alignments (protein, transcript) and output from 3 <i>ab initio</i> genefinders (BGF, Augustus & GeneMark).</td>
</tr>

<td>";
my $PAGE_CONTENTS;
my $DNAbox;
    if(defined $seq){
        $DNAbox = textarea(-name=>'DNA', -rows=>0,-cols=>0, -value=>$seq);
        $PAGE_CONTENTS .="<span class='heading'>NOTE: For full CpGAT options, visit <a href=\"/$xGDB/cgi-bin/WebCpGAT.pl?xgdb=$xGDB&DNAid=$chr&DNAstart=$start&DNAend=$end\" target='_new'>WebCpGAT</a></span>\n";
        $PAGE_CONTENTS .= "<span style=\"visibility:hidden\">$DNAbox</span>";
    }else{
        $DNAbox = textarea(-name=>'DNA',-rows=>2,-cols=>80);
        $PAGE_CONTENTS .= "<div style=\'warning\">Error in DNA sequence upload. Contact PlantGDB</div>";
    }
    $PAGE_CONTENTS .= <<END_OF_PAGE_CONTENTS;
<h2>Instructions:</h2>
<span class="heading">&nbsp;&nbsp;- Select options below and click <b>Submit</b><br /> &nbsp;&nbsp;- Go grab a quick coffee; results may take 2-3 min <br />&nbsp;&nbsp;- Refresh yrGATE window to view gene models
<input type="hidden" name="DefaultFlag" value="On">

<h2 class="topmargin1 bottmmargin1">Splice site model for <i>ab initio</i> gene finders:</h2>
<p>
<span class="hover_pointer bold" title="BGF is an ab initio genefinder tool">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;BGF:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span>
<select name="_bgf">
    <option value="maize">maize</option>
    <option value="rice">rice</option>
    <option value="Arabidopsis">Arabidopsis</option>
</select></p>

<p>
<span class="hover_pointer bold" title="Augustus is an ab initio genefinder tool">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Augustus:</span>&nbsp;&nbsp;
<select name="_augustus">
    <option value="maize">maize</option>
    <option value="arabidopsis">Arabidopsis</option>
    <option value="galdieria">Galdieria (alga)</option>
    <option value="tomato">tomato</option>
    <option value="chlamydomonas">Chlamydomonas</option>
</select></p>

<p>
<span class="hover_pointer bold" title="GeneMark is an ab initio genefinder tool">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;GeneMark:&nbsp;&nbsp;</span>
<select name="_genemark">
<option value="corn">maize</option>
    <option value="o_sativ">rice</option>
    <option value="m_truncatula">Medicago</option>
    <option value="a_thaliana">Arabidopsis</option>
    <option value="c_reinhardtii">Chlamydomonas</option>
    <option value="barley">barley</option>
    <option value="wheat">wheat</option>
    </select></p>

<h2 class="bottmmargin2">Additional options <span class="heading">(hover for description)</span></h2>

<table style="margin: .5em; margin-left:30px" cellpadding="10">
<tr align="left">
	<th align="left" ><span class="hover_pointer" title="Skip repeat mask for GenomeThreader spliced alignments">&nbsp;Skip Mask:</span></th><td><input type="checkbox" name="_nomask" value="T"></td>
	<th align="left">&nbsp;<span class="hover_pointer" title="Relax requirement for UniRef blast hit for GenomeThreader output">Relax UniRef:</span></th><td><input type="checkbox" name="_relax" value="T"></td>
	<th align="left">&nbsp<span class="hover_pointer" title="Skip PASA step to avoid potentially artifactual splice variants">Skip PASA:</span></th><th align="left"></th><td><input type="checkbox" name="_nopasa" value="T"></td>
</tr>
</table>
END_OF_PAGE_CONTENTS

print "$PAGE_CONTENTS";
print submit(-name=>'action',-value=>'Submit'),br,br;
print "</form></table></div></body></html>";
