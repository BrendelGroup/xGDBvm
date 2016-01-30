#!/usr/bin/perl -w
#use strict "vars";

use CGI ":all";
#require 'yrGATE_functions.pl';
require 'yrGATE_conf.pl';

use vars qw(
$PRM
$UCAcgiPATH
$GV
$GVportal
@modes
$DBH
$zeroPos
$IMAGEDIR
$GENSCAN_speciesModel
);

print STDERR "TRYING TO WRITE TO FILE!!!!!!\n";

my $gdb = $GV->{dbTitle};


my $cgi = CGI->new;
print $cgi->header;

my $string = $cgi->param("myGFF");

open (FILE, ">", "/xGDBvm/tmp/". $gdb . "/yourStrux.gff") || die "Could not open: $!";
print FILE $string;
close FILE;
