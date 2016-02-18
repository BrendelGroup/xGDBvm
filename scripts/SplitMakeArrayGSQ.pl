#! /usr/bin/perl -w
#
# SplitMakeArrayGSQ.pl
#   - script invoked by xGDB_Procedure.sh to split a transcript file into smaller chunks,
#     run MakeArray, and launch GeneSeqer or (if the machine has more than 1 processor) GeneSeqerMPI

use strict;
my $binDIR='/usr/local/bin/';

# Set $np to the number of processors on the machine:
#
my $np = `cat /proc/cpuinfo | grep processor | wc -l`;
chomp $np;

# Variables
#
my $seqHeader = "";		#The current sequence header
my $sequence = "";		#The current sequence
my $seqLength = 0.0;		#The current sequence length in Mb
my $curFileLength = 0.0;	#The current file length in Mb
my $fileCount = 1;		#The count of output files made
my $filename;			#The name of the input file
my $maxLength;			#The specified maximal file length in Mb
my $wasSeq = 0;			#Flag for sequence construction
my $genomeFile;			#query file for GeneSeqer
my $WorkPath;
my $xGDB = 'GDB000';
my $TypeTag;
my $RNAFastaType = '';		#D or d according to header type
my $DNAFastaType = '';		#L or l according to header typen(under development)
my $GeneSeqer = '';
my $GSQparameters;

if ($np > 1) {
 	$GeneSeqer = "/usr/lib64/openmpi/bin/mpirun -np $np /usr/local/bin/GeneSeqerMPI";
} else {
	$GeneSeqer = "/usr/local/bin/GeneSeqer";
}

# Read command-line arguments:
#
if ($ARGV[0] ne \0 && $ARGV[1] != \0 && $ARGV[2] ne \0 && $ARGV[3] ne \0 ) { 	#The correct number of parameters were given
	$filename = $ARGV[0];
	$maxLength = $ARGV[1];
	$genomeFile = $ARGV[2];
	$GSQparameters = $ARGV[3];
	if ($maxLength !~ /\d+/) {				#Check for correct type: numeric
		print "Second parameter must be numeric!\n";
		exit;
	}
}

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

# Split input transcript file into smaller chunks:
#
if ($filename =~ /est/){
	$TypeTag = 'est';
}elsif ($filename =~ /cdna/){
        $TypeTag = 'cdna';
}elsif ($filename =~ /tsa/){ # changed from 'put' on 4/25/13 to synch with file naming updates in xGDB_Procedure.sh
        $TypeTag = 'tsa';
}
my $DB = "$filename$fileCount";

open (IN, "<$filename");
open (OUT, ">$filename$fileCount");
	
while (<IN>) {

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

printToFile();
print "File: $filename$fileCount"." created. Approximate cumulative length: %6.2f Mb\n", $curFileLength;
close OUT;

# Invoke MakeArray to prepare transcript index files:
#
my @dblist= split (/ /,$DB);
foreach my $db (@dblist){
	system ("$binDIR/MakeArray $db");
}

$DB = $RNAFastaType.$DB;
$DB =~ s/\n//;

# Run GeneSeqer(MPI):
#
my $command ="$GeneSeqer $DB $GSQparameters -O ${WorkPath}/data/GSQ/GSQOUT/${xGDB}${TypeTag}.gsq $DNAFastaType $genomeFile";
system($command);


# Functions:
#
sub printToFile {
	$seqLength = length($sequence)/1000000.0;
	if ( $curFileLength > 0.0  &&  ($seqLength + $curFileLength) > $maxLength) {	#If maxLength will be exceeded, close current outFile and and open a new one.
		close OUT;
		print "File: $filename$fileCount"." created. Length: $curFileLength Mb\n";
		$curFileLength = 0.0;
		$fileCount++;
		open (OUT, ">$filename$fileCount");
		$DB .= " $filename$fileCount";
	}
	
	#Write sequence to file and update $curFileLength
	#
	print OUT "$seqHeader$sequence\n";
	$curFileLength += $seqLength;
	$sequence = "";
	$seqHeader = "";
}

sub short {
	my ($file) = @_;
	$file =~ /(\w+)/;
	return $&;
}
