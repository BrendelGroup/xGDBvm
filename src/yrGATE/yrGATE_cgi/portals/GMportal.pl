#!/usr/bin/perl -I/xGDBvm/src/yrGATE/yrGATE_cgi/
# yrGATE portal for GENMARK

use LWP::Simple;
use CGI ":all";
use LWP::UserAgent;
use HTTP::Request::Common qw(POST);

require 'yrGATE_conf.pl';
require 'yrGATE_functions.pl';

$seq = param("GenomeSequence");
$start = param("start");


print STDERR $seq;
if ($seq eq "" or $start eq ""){
    bailOut("GeneMark portal.  No genome sequence defined.");
}
print header();
print "<html><head><title>yrGATE Portal to GeneMark<\/title><\/head>

<body>

<table width='100%' cellspacing='0'>
<tr><td bgcolor='orange'></td><td bgcolor='orange'><span style='font-family:Arial;font-weight:bold;font-size:24px'>yrGATE Portal to GeneMark</span></td></tr>
<tr><td width='100' valign='top' bgcolor='orange'><span style='font-family:Arial;font-weight:bold;font-size:12px'>
scroll down to results and <br>
click on yellow buttons to add exons</span><br>
<\/td>

<td><a href='http://opal.biology.gatech.edu/GeneMark/' target=_new>GeneMark<\/a><br>";

$link = "http://opal.biology.gatech.edu/GeneMark/eukhmm.cgi?.cgifields=org&.cgifields=protein&.cgifields=pdf&.cgifields=postscript&.cgifields=gmlst";

my $ua = LWP::UserAgent->new(ssl_opts=>{verify_hostname=>0},);

        my %tags = ();
        $tags{'sequence'} = $seq;
        $tags{'org'} = (param('org')) ? param('org') : $portalvar->{GENEMARK_speciesmodel};
        $tags{'seq_file'} = "";
        $tags{'pdf'} = 1;
        $tags{'Action'} = "Start GeneMark.hmm";
        $tags{'gmlst'} = 1;


        my $resp = $ua->request(
                POST $link,
                Content_Type  => 'form-data',
                Content       => [ %tags ]
        );

        $page1 .= $resp->error_as_HTML unless $resp->is_success;

        if ($resp->is_success){
          $page1 .= $resp->content();
        }else{
          $page1 = "Portal currently unavailable. Please try again later.";
        }


$page1 =~ s/^.+body bgcolor="white">//si;
$page1 =~ s/METHOD="POST"/method="post" action="GMportal.pl"/i;
$page1 =~ s/<a href="eukhmm.cgi.+?Reload this page.+?>//i;
$page1 =~ s/href="/target=_new href="http:\/\/opal.biology.gatech.edu\/GeneMark\//gi;  # links
$page1 =~ s/Input Sequence.+?Sequence File upload.+?<select/Species: <select/si;
$page1 =~ s/<tr.+?MAXLENGTH=80>.+border=0>//i;
$page1 =~ s/<textarea/<input type=hidden/i;
$page1 =~ s/ROWS.+?62>/value="/i;
$page1 =~ s/<\/textarea>/" >/i;
$page1 =~ s/<p><\/font><tr>.+?<\/tr>.*?<tr>.+?<\/tr>//si;
$page1 =~ s/<input.+?Default">/<input type=hidden name='seq' value='$seq'><input type=hidden value=$start name='start'>/i;
$page1 =~ s/<br><br>Sequence://i;
$page1 =~ s/<img.+?>//gi;
$page1 =~ s/Web.+?maintainer\.//si;
$page1 =~ s/Go.+?<\/a>//sig;

#$page1 =~ s/Start GeneMark.hmm/Re-run GeneMark with different species model/is;

## insert interface back to yrGATE
($data_table) = $page1 =~ /(Predicted.+?<\/pre>)/si;
@exons = $data_table =~ /\d+\s+\d+\s+.\s+\w+\s+\d+\s+\d+\s+\d+\s+\d+\s+\d+/g;
$data_table = "Predicted genes/exons

Gene Exon Strand Exon           Exon Range     Exon      Start/End
  #    #         Type                         Length       Frame

";
for ($i=0;$i<scalar(@exons);$i++){
  ($c1,$c2) = $exons[$i] =~ /\w+\s+(\d+)\s+(\d+)/;
  $c1a = $c1 + $start -1 ;
  $c2a = $c2 + $start -1 ;
  $exons[$i] =~ s/$c1/$c1a/;
  $exons[$i] =~ s/$c2/$c2a/;
  #$data_table .= $exons[$i]." <input type='button' style='background-color:yellow' value='Add Exon to Annotation' onclick='opener.GraphicExonSelect($c1a,$c2a)'>\n";
  $data_table .= $exons[$i]." <input type='button' style='background-color:yellow' value='Add Exon to Annotation' onclick='opener.addUDE($c1a,$c2a,\"GeneMarkHMM\",\"\")'>\n"; 
}
$data_table .= "<\/pre>";

$page1 =~ s/Predicted.+?<\/pre>/$data_table/si;

($data_table) = $page1 =~ /(GENEMARK PREDICTIONS.+?<hr>)/si;  # for seoncd table
@exons = $data_table =~ /\d+\s+\d+\s+\w+\s+\w+\s+\d+\s+\d+\.\d+/g;
($data_table) = $page1 =~ /(GENEMARK PREDICTIONS.+?-+\n.+?-+\s+-+\s+-+\s+-+)/si;
$data_table .= "\n";
for ($i=0;$i<scalar(@exons);$i++){
  ($c1,$c2) = $exons[$i] =~ /^(\d+)\s+(\d+)/;
  $c1a = $c1 + $start -1;
  $c2a = $c2 + $start -1;
  $exons[$i] =~ s/$c1/$c1a/;
  $exons[$i] =~ s/$c2/$c2a/;
  ($score) = $exons[$i] =~  /fr\s+\d+\s+(\d\.\d+)/;
  #$data_table .= $exons[$i]." <input type='button' style='background-color:yellow' value='Add Exon to Annotation' onclick='opener.GraphicExonSelect($c1a,$c2a)'>\n";
  $data_table .= $exons[$i]." <input type='button' style='background-color:yellow' value='Add Exon to Annotation' onclick='opener.addUDE($c1a,$c2a,\"GeneMark\",\"$score\")'>\n";
}

$page1 =~ s/GENEMARK PREDICTIONS.+?<hr>/$data_table<\/pre><hr>/si;
$page1 =~ s/<\/body>/<\/td><\/tr><\/table><\/body>/i;

## add yrGATE parameters to form
$page1 =~ s/<\/form>/<input type='hidden' name='start' value='$start'><input type='hidden' name='GenomeSequence' value='$seq'><\/form>/si;


if (length($seq) > 400000){
  print "Sequence too large for GeneMark portal.";
}else{
  print $page1;
}
