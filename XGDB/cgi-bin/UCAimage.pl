#!/usr/bin/perl
use GSQDB;
use CGI ":all";

## GLOBAL/COOKIE VALUES
do 'SITEDEF.pl';
do 'getPARAM.pl';

my $imgW = param('imgWidth');
$cgi_paramHR->{imgW} = $imgW;
$cgi_paramHR->{trackORDER} = $DBver[$cgi_paramHR->{dbid}]->{ucaORD};
$cgi_paramHR->{trackVISIBLE} =  $DBver[$cgi_paramHR->{dbid}]->{ucaVIS};

my $db = new GSQDB($cgi_paramHR);
my ($pgsstatHR,$exstatHR,$instatHR,$qseqAR,$gapped_gseg,$regionHTML) = $db->getUCAimage($cgi_paramHR);
print header();
print $regionHTML;
