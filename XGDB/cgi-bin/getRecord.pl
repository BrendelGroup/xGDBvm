#!/usr/bin/perl
use GSQDB;
use CGI ':all';
use GDBgui;

do 'SITEDEF.pl';
do 'getPARAM.pl';

my $db = new GSQDB($cgi_paramHR);
my $GDBpage = new GDBgui();

#### $cgi_paramHR parameters are from getPARAM.pl
my ($htmlHR,$jscriptCODE,$PAGE) = $db->showRECORD($cgi_paramHR);

$cgi_paramHR->{headHR}    = {-cookie=>[$sCookie]};
$cgi_paramHR->{htmlHR}    = {-script=>[{-src=>"${JSPATH}RECORDview.js"}],
			     %$htmlHR
};
$cgi_paramHR->{main}      = $PAGE;


$GDBpage->printXGDB_page($cgi_paramHR);
