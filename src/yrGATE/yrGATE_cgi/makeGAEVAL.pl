#!/usr/bin/perl -w
use strict;
use CGI ":all";
use URI::Escape;
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

require 'yrGATE_conf.pl';

my $gdb = $GV->{dbTitle};

print "Content-Type: text/html\n\n";
##perl GAEVAL/xGAEVAL.pl --clean_db --GFF ./GAEVAL/examples/example1.gff3
#my @args = ("--clean_db","--GFF=/xGDBvm/tmp/GDB001/yourStrux.gff");
#system($^X, "GAEVAL/xGAEVAL.pl",@args);

my $result = qx(/usr/bin/perl GAEVAL/xGAEVAL.pl --clean_db --GFF=/xGDBvm/tmp/$gdb/yourStrux.gff);

##print "Result: $result";

my @lines = split(/\n/m, $result);

my $size = scalar @lines;
##print "The total size is " .$size;
for(my $i=0;$i<$size;$i++) {
if(@lines[$i] =~ /Integrity Score|Exon Sequence Coverage/) {
	print "@lines[$i]\n";
	}
}
