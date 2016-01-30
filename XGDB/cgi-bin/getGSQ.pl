#!/usr/bin/perl
use GSQDB;
use CGI ':all';

do 'SITEDEF.pl';
do 'getPARAM.pl';
do 'GDBgui.pl';

my $db = new GSQDB($cgi_paramHR);
	 
#### $cgi_paramHR parameters are from getPARAM.pl
my ($htmlHR,$PAGE) = $db->showGSQ($cgi_paramHR); 
my %htmlHeadData =(-title   =>"${SITENAMEshort}_GeneSeqer_Alignment",
                   -bgcolor =>"#FFFFFF",
		   %$htmlHR);


print( header(-cookie=>[$sCookie]),
       start_html(%htmlHeadData),
       pre($PAGE),
       end_html());
