#!/usr/bin/perl
use CGI qw/header/;
use GSQDB;

do 'SITEDEF.pl';
do 'getPARAM.pl';

my $db=new GSQDB($cgi_paramHR);

$cgi_paramHR->{GSEGresid} = exists($cgi_paramHR->{GSEGresid})?$cgi_paramHR->{GSEGresid}:
                            defined($DEFAULT_GSEG_RESID)?$DEFAULT_GSEG_RESID:0;
print header . $db->getGsegMenu($cgi_paramHR);
