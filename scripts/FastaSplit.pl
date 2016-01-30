#!/usr/bin/perl -w 

open(FILE, "$ARGV[0]") || die ("can not open input");
while(<FILE>){
 if(/>(\S+)/){
	my $gi = $1;
	open(OUT, ">$ARGV[1]/$gi.fsa") || die("Cannot output $gi.fsa");
 }
 print OUT;

}
close(FILE);
