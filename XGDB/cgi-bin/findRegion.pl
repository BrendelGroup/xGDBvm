#!/usr/bin/perl
use CGI ":all";
use GSQDB;
use GDBgui;

do 'SITEDEF.pl';
do 'getPARAM.pl';

my $db = new GSQDB($cgi_paramHR);
my $GDBpage = new GDBgui();

my ($PAGE_CONTENTS);
my ($chr,$lpos,$rpos,$url);

my @qWords = split(/[\s,]+/,$cgi_paramHR->{searchSTR});
if(exists($cgi_paramHR->{searchSTR}) && (($cgi_paramHR->{searchSTR} =~ /^[~<>+-]/)||($cgi_paramHR->{searchSTR} =~ /\s[~<>+-]/)||($cgi_paramHR->{searchSTR} =~ /\w\*\s/)||($cgi_paramHR->{searchSTR} =~ /[\")(]/))){
#    print STDERR "[search.pl] Shortcutting to the Description Search";
    goto DESC_SEARCH;
}
push(@qWords,split(/[\s,]+/,$cgi_paramHR->{gi}));
push(@qWords,split(/[\s,]+/,$cgi_paramHR->{acc}));
push(@qWords,split(/[\s,]+/,$cgi_paramHR->{id}));

if(scalar(@qWords) == 0){
  $PAGE_CONTENTS = "<h2>You must enter an Identifier or a Keyword upon which to search</h2>\n";
}elsif(scalar(@qWords) == 1){
  ($url) = $db->findREGION({gi=>$qWords[0]});
  if(defined($url)){
    print redirect($url);
    exit 1;
  }else{
    goto DESC_SEARCH;
  }
}else{

  ($chrHitCNT,$gsegHitCNT) = $db->search_by_MULTIID(\@qWords);
  if($chrHitCNT){
    ($lociMAP,$lociTABLE) = $db->showMULTILOCUS();
    $PAGE_CONTENTS = "<br /><br /><br />$lociMAP <br /><br /> $lociTABLE <br />";
  }elsif(!defined($lociMAP)){

  DESC_SEARCH:
    ($chrHitCNT,$gsegHitCNT) = $db->search_by_Desc(\@qWords);
    if($chrHitCNT){
      ($lociMAP,$lociTABLE) = $db->showMULTILOCUS();
      $PAGE_CONTENTS = "<br /><h2>Features found using <span style='color:green;'>" . join(' ',@qWords) . "</span></h2><br /><br />$lociMAP <br /><br /> $lociTABLE <br />";
    }else{
      $PAGE_CONTENTS = "<br /><h2>No results were found using <span style='color:green;'>" . join(' ',@qWords) . "</span></h2>";
    }
  }
}

$cgi_paramHR->{headHR}    = {-cookie=>[$sCookie]};
$cgi_paramHR->{htmlHR}    = {-title=>"${SITENAMEshort} Query:$cgi_paramHR->{searchSTR}",
			     -script=>[{-src=>"${JSPATH}SRview.js"}]
			    };
$cgi_paramHR->{main}      = $PAGE_CONTENTS;


$GDBpage->printXGDB_page($cgi_paramHR);
