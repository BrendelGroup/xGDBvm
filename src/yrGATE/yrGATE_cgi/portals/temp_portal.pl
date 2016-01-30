#!/usr/bin/perl
# yrGATE portal for template

use LWP::Simple;
use CGI ":all";
use LWP::UserAgent;
use HTTP::Request::Common qw(POST);

require 'yrGATE_conf.pl';

$seq = param("GenomeSequence");
$start = param("start");

print header();

if ($seq eq ""){
    print "No genome sequence defined.";
    exit;
}

print "<html><head><title>yrGATE Portal to Template Portal<\/title><\/head>
<body>

<form name='templateportal' method='post'>
<table width='100%' cellspacing='0'>
<tr><td bgcolor='orange'></td><td bgcolor='orange'><span style='font-family:Arial;font-weight:bold;font-size:24px'>yrGATE Portal to </span></td></tr>
<tr><td width='100' valign='top' bgcolor='orange'><span style='font-family:Arial;font-weight:bold;font-size:12px'>
click on yellow buttons to add exons<br>
<!-- portal parameters-->
</select>
</span>
<input type='hidden' name='GenomeSequence' value='$seq'>
<input type='hidden' name='start' value='$start'>
<!-- end portal parameters>
<\/td>

<!--# portal begin-->
<td>";


$data_table .= $start."  ".($start+30)."<input type='button' style='background-color:yellow' value='Add Exon to Annotation' onClick='opener.addUDE($start,$start+30,\"template portal\",0)'>\n";


print "$data_table </td></tr></table></body></html>";
