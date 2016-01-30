#! /usr/bin/perl -w

## Author: Gordon Bean
## Date: June 21, 2006
##
## Purpose: Split large files into smaller, more manageable ones
## Updated Jon Duvick
## Date: Oct 2, 2012
## Add parameter to allow external processing

use strict;
my $binDIR='/usr/local/bin/';
# Variables
my $seqHeader = "";		#The current sequence header
my $sequence = "";		#The current sequence
my $seqLength = 0.0;		#The current sequence length in Mb
my $curFileLength = 0.0;	#The current file length in Mbases
my $fileCount = 1;		#The count of output files made
my $filename;			#The name of the input file
my $maxLength;			#The specified max file length in Mbases
my $wasSeq = 0;			#Flag for sequence construction
my $genomeFile;			#query file for GeneSeqer
my $WorkPath;
my $xGDB = 'GDB000';
my $TypeTag;
my $RNAFastaType = '';    #D or d according to header type
my $DNAFastaType = '';    #L or l according to header typen(under development)
my $GSQparameter;
my $GeneSeqer='/usr/local/bin/GeneSeqer';
#Initiate command-line variables
if ($ARGV[0] ne \0 && $ARGV[1] != \0 && $ARGV[2] ne \0 && $ARGV[3] ne \0 ) { 	#The correct number of parameters were given
	$filename = $ARGV[0];
	$maxLength = $ARGV[1];
	$genomeFile = $ARGV[2];
	$GSQparameter = $ARGV[3];
	if ($maxLength !~ /\d+/) {				#Check for correct type: numeric
		print "Second parameter must be numeric!\n";
		exit;
	}
}

#under development - to identify scaffold FASTA header type. - JDuvick 7-6-12
#if ($filename =~ /(\/xGDBvm\/data\/scratch\/GDB\d\d\d\/data\/GSQ\/SCFDIR\/GDB\d\d\dscaffold)/{
#
#my $top = `head -1 $filename`;
#	if ($top =~ /^>gi\|\d+/){ #test for GenBank gi format
#while (<$top>) {
#			$DNAFastaType = '-l ';
#			print "GenBank formatted transcripts";
#		}elsif($top =~ /^>\S+/){ #test for non-GenBank gi format 
#			$DNAFastaType = '-L ';
#			print "non-GenBank formatted transcripts";
#		}
#	}
#}

open my $file, '<', "$genomeFile"; 
my $firstLine = <$file>; 
		if ($DNAFastaType eq '' && $firstLine =~ /^>gi\|\d+/)  { #test for GenBank gi format if not already set
			$DNAFastaType = '-l ';
			print "GenBank formatted genome";
		}elsif($DNAFastaType eq '' && $firstLine =~ /^>\S+/){ #test for non-GenBank gi format if not already set
			$DNAFastaType = '-L ';
			print "non-GenBank formatted genome";
		}else{
		$DNAFastaType = '-L ';
		}
close $file;

if ($filename =~ /(\/xGDBvm\/data\/scratch\/)(GDB\d\d\d)/){ # scratch directory
$WorkPath = $1.$2;
$xGDB=$2;
}
if ($filename =~ /(\/xGDBvm\/data\/)(GDB\d\d\d)/){ # data output directory (currently addGSEG uses this)
$WorkPath = $1.$2;
$xGDB=$2;
}

if ($filename =~ /est/){
	$TypeTag = 'est';
}elsif ($filename =~ /cdna/){
        $TypeTag = 'cdna';
}elsif ($filename =~ /tsa/){ # changed from 'put' on 4/25/13 to synch with file naming updates in xGDB_Procedure.sh
        $TypeTag = 'tsa';
}
my $DB = "$filename$fileCount";
#Open input file
open (IN, "<$filename");

#Open first output file
open (OUT, ">$filename$fileCount");
	
while (<IN>) {			#Major loop: iterates through all lines of IN
		#print "line: $_";
		#exit;
		
		if ($RNAFastaType eq '' && $_ =~ /^>gi\|\d+/)  { #test for GenBank gi format if not already set
			$RNAFastaType = '-d ';
			print "GenBank formatted transcripts";
		}elsif($RNAFastaType eq '' && $_ =~ /^>\S+/){ #test for non-GenBank gi format if not already set
			$RNAFastaType = '-D ';
			print "non-GenBank formatted transcripts";
		}
		
	if ($_ =~ /^[>;\s]/) {	#Gets header and comments -> $seqHeader
		if ($wasSeq) {
			$wasSeq = 0;
			printToFile();
		} 

		$seqHeader .= $_;	#Captures entire line, including white space
		next;
	}
	elsif ($_ =~ /(\w+)/) {	#Gets just the sequence, no whitespace
		$sequence .=  $&;
		$wasSeq = 1;
		next;
	}
	else {
		print "I don't know how the code got here.  lineIn did not match pattern.\n";
		exit;
	}
}
#Print OUT final sequence and close final file
printToFile();
print "File: $filename$fileCount"." created. Length: $curFileLength Mb\n";
close OUT;
#open (OUT1, ">${filename}DB");
#print OUT1 "$DB";
my @dblist= split (/ /,$DB);
foreach my $db (@dblist){
		system ("$binDIR/MakeArray $db");
}
#if ($filename =~ /put/){ # deprecated via test for GenBank gi format
#	$DB = "-D ".$DB
#}else{
#	$DB = "-d ".$DB
#}
#$DB = "-D ".$DB; # debug
$DB = $RNAFastaType.$DB;
$DB =~ s/\n//;
my $command ="$GeneSeqer $DB $GSQparameter -o ${WorkPath}/data/GSQ/GSQOUT/${xGDB}{$TypeTag}.gsq $DNAFastaType $genomeFile";
#print STDERR "WWWWWWWWWWWWWWWWWWWWWWWWWWWW $command\n";
system ("$GeneSeqer $DB $GSQparameter -o ${WorkPath}/data/GSQ/GSQOUT/${xGDB}${TypeTag}.gsq $DNAFastaType $genomeFile");

sub printToFile {
	$seqLength = length($sequence)/1000000.0;
	if ($seqLength > $maxLength) {
		print "The sequence is greater than the maximum specified!\nYou must specify a larger file length!\n";
		close OUT;
		exit;
	}
		#print "seqLength: $seqLength\t";
		#print "curFileLength: $curFileLength\n";
	if ( ($seqLength + $curFileLength) > $maxLength) {	#If maxLength will be exceeded, close current outFile and and open a new one.
		close OUT;
		print "File: $filename$fileCount"." created. Length: $curFileLength Mb\n";
		$curFileLength = 0.0;
		$fileCount++;
		open (OUT, ">$filename$fileCount");
		$DB .= " $filename$fileCount";
	}
	
	#Write sequence to file and update $curFileLength
	print OUT "$seqHeader$sequence\n";
	#print "$seqHeader$sequence\n";
	$curFileLength += $seqLength;	
	$sequence = "";
	$seqHeader = "";
}

sub short {
	my ($file) = @_;
	$file =~ /(\w+)/;
	return $&;
}