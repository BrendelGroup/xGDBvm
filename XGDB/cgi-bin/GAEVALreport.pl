#!/usr/bin/perl
use GSQDB;
use CGI ':all';
use GDBgui;

do 'SITEDEF.pl';
do 'getPARAM.pl';

my $db = new GSQDB($cgi_paramHR);
my $GDBpage = new GDBgui();
	
my ($htmlHR,$jscriptCODE,$PAGE) ;

#### $cgi_paramHR parameters are from getPARAM.pl
my $GAEVALann = $db->getDSO($cgi_paramHR); 
if($GAEVALann && $GAEVALann->can('showGaevalReport')){
  ($htmlHR,$PAGE) = $GAEVALann->showGaevalReport($cgi_paramHR);
}else{
  $htmlHR = {};
  $PAGE = "<H2>GAEVAL reports are currently unavailable for this resource</h2>";
}

$cgi_paramHR->{headHR}    = {-cookie=>[$sCookie]};
$cgi_paramHR->{htmlHR}    = {-script=>[{-src=>"${JSPATH}RECORDview.js"}],%$htmlHR};
$cgi_paramHR->{main}      = $PAGE;

$GDBpage->printXGDB_page($cgi_paramHR);
