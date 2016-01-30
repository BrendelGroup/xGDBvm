#!/usr/bin/perl

use CGI ":all";
use CGI ":standard";
use CGI::Carp qw(fatalsToBrowser);

print header();
print start_html;

my $format = param('format');

print redirect("${CGIPATH}xGDBtoGenBank.pl?xGDB=$xGDB&DB=$myDB&id=$id&l_pos=$cgi_paramHR->{l_pos}&r_pos=$cgi_paramHR->{r_pos}&DBpath=$DBpath2&Type=$format");


print end_html;
