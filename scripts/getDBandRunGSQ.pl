#! /usr/bin/perl -w

## Author: Gordon Bean
## Date: June 21, 2006
##
## Purpose: Split large files into smaller, more manageable ones

use strict;
my $binDIR='/xGDBvm/bin/';
# Variables
my $filename;			#The name of the input file
my $genomeFile;			#query file for GeneSeqer
my $WorkPath;
my $xGDB = 'GDB000';
my $TypeTag;
my $GSQparameter;
#Initiate command-line variables
if ($ARGV[0] ne \0 && $ARGV[1] ne \0 && $ARGV[2] ne \0) { 	#The correct number of parameters were given
	$filename = $ARGV[0];
	$genomeFile = $ARGV[1];
	$GSQparameter = $ARGV[2];
}
###/xGDBvm/data/GDB002/data/GENESEQER/MRNADIR/GDB002est
if ($filename =~ /(\/xGDBvm\/INSTANCES\/)(GDB\d\d\d)/){
$WorkPath = $1.$2;
$xGDB=$2;
}
my $DB = "";
print STDERR " HHHHHH $WorkPath HHHHH $xGDB\n";
my $MRNAdataPath = $WorkPath."/data/GENESEQER/MRNADIR/";
my $PUTdataPath = $WorkPath."/data/GENESEQER/PUTDIR/";
#Open input file
if ($filename =~ /est$/){
	print STDERR "NNNNNNNNNN $filename \n";
	opendir (DIR, $MRNAdataPath) || die "can't opendir $MRNAdataPath: $!";
	my @filelist=readdir(DIR);
	$DB = "-d ";
	foreach my $file (@filelist) {
		print STDERR "NNNNNNNNNN $file \n";
		if ( $filename =~ /est$/ and $file =~ /est(\d+)$/){
			$DB = $DB." ${filename}$1";
			$TypeTag='est';
		}elsif ( $filename =~ /cdna$/ and $file =~ /cdna(\d+)$/){
			$DB = $DB." $filename.$1";
			$TypeTag='cdna';
		}
	}
}elsif ($filename =~ /put$/){
	opendir (DIR, $PUTdataPath) || die "can't opendir $PUTdataPath: $!";
	my @filelist=readdir(DIR);
	$DB = "-D ";
	foreach my $file (@filelist) {
                if ($file =~ /put(\d+)$/){
			$TypeTag='put';
                	$DB = $DB." $filename.$1";
        	}
	}
}
$DB =~ s/\n//;
my $command ="/xGDBvm/bin/GeneSeqer -$DB $GSQparameter -o ${WorkPath}/data/GENESEQER/GSQOUT/gsq.${xGDB}$TypeTag -L $genomeFile";
print STDERR "WWWWWWWWWWWWWWWWWWWWWWWWWWWW $command\n";
system ("/xGDBvm/bin/GeneSeqer $DB $GSQparameter -o ${WorkPath}/data/GENESEQER/GSQOUT/gsq.${xGDB}$TypeTag -L $genomeFile");
