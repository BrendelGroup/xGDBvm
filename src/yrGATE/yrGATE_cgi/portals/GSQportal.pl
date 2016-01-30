#!/usr/bin/perl
#use LWP::Simple;
use LWP::UserAgent;
use CGI ":all";
use HTTP::Request::Common qw(POST);

#$GSQportalpath = "http://www.plantgdb.org/cgi-bin/GeneSeqer/"; # This must be an absolute URL

$GSQportalpath ="/xGDBvm/src/GENESEQER/bin/GeneSeqer/";

require 'yrGATE_conf.pl';
require 'yrGATE_functions.pl';


$portalTitle = "
<table width='100%' cellspacing='0' cellpadding='0'>
<tr bgcolor='orange'>
  <td></td>
  <td><span style='font-family:Arial;font-weight:bold;font-size:24px'>yrGATE Portal to GeneSeqer at PlantGDB</span>
<br>
<span style='font-family:Arial;font-weight:bold;font-size:12px'>
<p>To use:</p>
1. Specify EST database(s).<br>
2. Click 'Submit' and wait for the results to be generated.<br>
3. Select exons by clicking on alignments in the diagram.<br>
</span>
</td></tr>
</table>";

#$portalTitle =~ s/\//\/\//g; # escape backslash for regex


$ua = LWP::UserAgent->new(
      ssl_opts=> {verify_hostname =>0},
    );

#$ua->requests_redirectable([ ]);
%tags = ();
foreach $k (param()){
  $tags{$k} = param($k);
}

$tags{'portal'} = 1;
$tags{'_s'} = $portalvar->{GeneSeqer_speciesmodel};

if (param('RunGSQ')){
  $link = $GSQportalpath."GeneSeqer"; # Changed from: PlantGDBgs.cgi . Needs testing.
  $response = $ua->request(
        POST $link,
        Content_Type  => 'application/x-www-form-urlencoded',
        Content=> [ %tags ]);
$url = $resp->content();
#$url = $response->header('Location');
($qvar) = $url =~ /\?(.+?)$/;


$link = "GSQportal.pl?$qvar";

print STDERR $link;

print redirect($link);


}elsif(param('ufname')){
$link = $GSQportalpath."PlantGDBwatch-gs.cgi?";
$response = $ua->request(
        POST $link,
        Content_Type  => 'application/x-www-form-urlencoded',
        Content=> [ %tags ]);

  $url = $response->header('Location');
  if ($url){
    $url =~ s/\n//g;
    $page = get($url);
    print header;
    $path = $url;
    $path =~ s/\/gs.+?.html//;
    $pathHost = url()."?linkto=";
    $ufname = param('ufname'); # added
    $page =~ s/src="\/GeneSeqer.+?"/bsrc="GSQside.pl?ufname=$ufname"/si;
    $page =~ s/ src="/ src="$path\//gsi;
    $page =~ s/ src="/ src="$pathHost/gsi;
    $page =~ s/bsrc/src/si;
    $page =~ s/<body>/<body>$portalTitle/si;

    print $page;
  }else{
    $link = self_url();
    print header(-Refresh=>param('rrate').";$link");
    $page = $response->content;
    $page =~ s/<body>/<body>$portalTitle/si;
    print $page;
  }

}elsif(param('linkto')){
  $page = get(param('linkto'));

  $page =~ s/src=".GeneSeqer.tooltip.js"/src="\/tool\/GeneSeqer\/tooltip.js"/is;
  $page =~ s/href=".GeneSeqer.tooltip.css"/href="\/tool\/GeneSeqer\/tooltip.css"/is;
  ($dir)= param('linkto') =~ /^(.+?\d\/).+?.html/si;
  $page =~ s/<img SRC="/<img src="$dir/si;
  print header;
  print $page;

}else{ # first run

  $tags{'_gdnap'} = ">SQ;".$PRM->{chr}."_".$PRM->{start}."_".$PRM->{end}."\n".strToFASTA(param('GenomeSequence'));
  $tags{'_l'} = 'FASTA ';
  $link = $GSQportalpath."GeneSeqer"; # was: PlantGDBgs
  $response = $ua->request(
	POST $link,
	Content_Type  => 'application/x-www-form-urlencoded',
	Content=> [ %tags ]);
  $page = $response->content;
  $page =~ s/action=".+?"/action="GSQportal.pl?RunGSQ=Submit"/si;
  $page =~ s/^.+?<head/<html><head/si;
  $page =~ s/<body>/<body>$portalTitle/si;

  print header;
  print $page;
}
