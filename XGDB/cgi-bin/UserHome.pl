#!/usr/bin/perl
use CGI ":all";

do 'SITEDEF.pl';
do 'getPARAM.pl';


$link = $ucaPATH."AnnotationAccount.pl";
#print header;
print redirect($link);

