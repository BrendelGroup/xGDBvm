#!/usr/bin/env perl
 
# Copyright (c) 2012-2013, Daniel S. Standage <daniel.standage@gmail.com>
#
# Permission to use, copy, modify, and/or distribute this software for any
# purpose with or without fee is hereby granted, provided that the above
# copyright notice and this permission notice appear in all copies.
#
# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
# WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
# MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
# ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
# WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
# ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
# OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 
# Modified for xGDBvm by J. Duvick:
# Option to suppress outfmt when we just want to evaluate
# Prints validation info to logfile and errorfile, including pipeline step

use strict;
use Getopt::Long;
 
# Program usage statement
sub print_usage
{
	my $OUT = shift(@_);
	print $OUT "Usage: $0 [options] sequence.fa
	Options:
	-h|--help print this help message and exit
	--ouput print or skip defline conversion; default is to skip (JPD added)
	--outfile print sequences with converted deflines to the specified file;
	default is the terminal (stdout)
	--outfmt defline format to use when printing validated sequences; valid
	options include the following: 'idonly', 'General', and
	'Local'; default is 'idonly'
	--db the 'General' defline format includes a database name in the
	second field; specify the value to be used when printing
	validated sequences in 'General' format
	--step identifies the xGDBvm pipeline step for inclusion in logfile output
	";
}
 
# NCBI BLAST provides the reference list of valid defline patterns: see "FASTA
# Defline Format" at ftp://ftp.ncbi.nih.gov/blast/documents/formatdb.html.
# We support a subset of these defline patterns.
my $deflines =
{
	'gb\|([^\|]+)\|(\S*)' => "GenBank",
	'emb\|([^\|]+)\|(\S*)' => "EMBL",
	'dbj\|([^\|]+)\|(\S*)' => "DDBJ",
	'sp\|([^\|]+)\|(\S*)' => "SWISS-PROT",
	'pdb\|([^\|]+)\|(\S*)' => "PDB",
	'gnl\|[^\|]+\|(\S+)' => "General",
	'ref\|([^\|]+)\|(\S*)' => "RefSeq",
	'lcl\|(\S+)' => "Local",
	'([^\|\s]+)' => "idonly",
};
my $defline_outformats =
{
	"General" => ">gnl|%s|%s\n",
	"Local" => ">lcl|%s\n",
	"idonly" => ">%s\n",
};
my $idsfound = {};
 
# Parse command line options
my $output = "skip";
my $outfmt = "idonly";
my $db = "";
my $outfilename = "";
my $logfilepath = "";
my $errorfilepath = "";
my $step = "";
GetOptions
(
	"h|help" => sub { print_usage(\*STDOUT); exit(0); },
	"output=s" => \$output,
	"outfmt=s" => \$outfmt,
	"db=s" => \$db,
	"outfile=s" => \$outfilename,
	"logfile=s" => \$logfilepath,
	"errorfile=s" => \$errorfilepath,
	"step=s" => \$step,
);

# Create output stream if desired
my $OUT = \*STDOUT;
if($output eq "print" && $outfilename ne "")
{
	open($OUT, ">", $outfilename);
	unless($OUT)
	{
	printf("error: unable to open output file '%s'\n", $outfilename);
	exit(1);
	}
}
 
# Verify output format
if(defined $defline_outformats->{$outfmt}) # user has requested output in one of the supported formates
{
	if($outfmt eq "General" and $db eq "")
	{
		printf(STDOUT "error: must provide a db value when using output format ".
		"'%s'\n", $outfmt);
		print_usage(\*STDOUT);
		exit(1);
	}
	if($outfmt ne "General" and $db ne "")
	{
		printf(STDOUT "warning: database '%s' ignored when using output format ".
		"'%s'\n", $outfmt);
	}
}
else
{
	printf(STDOUT "error: unsupported output format '%s'\n", $outfmt);
	print_usage(\*STDOUT);
	exit(1);
}
 
# Verify input file
my $infile = shift(@ARGV);
unless($infile)
{
	print(STDOUT "error: must provide an input sequence file\n");
	print_usage(\*STDOUT);
	exit(1);
}
open(my $IN, "<", $infile);
unless($IN)
{
	printf(STDOUT "error: could not open input sequence file '%s'\n", $infile);
	exit(1);
}
 
# Validate deflines, and print if outfile is indicated
my $counts = {};
foreach my $format_name(keys(%$defline_outformats))
{
	$counts->{ $format_name } = 0;
}

## Process lines:
while(my $line = <$IN>)
{
	chomp($line);
	if($line =~ m/^>/)
	{
		my $gi;
		my $idacc;
		my $locus;
		foreach my $defline_format(keys(%$deflines))
		{
			my $format_name = $deflines->{$defline_format};
   			if($line =~ m/^>$defline_format/)
   			{
      			$idacc = $1;
      			$locus = $2;
      			$counts->{ $format_name } += 1;
      			if($idsfound->{$idacc})
      			{
				    if($logfilepath ne "" && $errorfilepath ne "") # print to logfiles
				    {
					   open (LOGFILE, ">>$logfilepath");
					   printf(LOGFILE "  ERROR: found duplicated sequence ID (accession) '%s' in %s (%s)\n", $gi, $idacc, $step);
					   close (LOGFILE); 
					   open (ERRORFILE, ">>$errorfilepath");
					   printf(ERRORFILE "ERROR: found duplicated sequence ID (accession) '%s' in %s (%s)\n", $gi, $idacc, $step);
					   close (ERRORFILE);
				    }
				    else # print to stdout
				    {
					   printf(STDOUT "ERROR: found duplicated sequence ID (accession) '%s' in %s\n", $gi, $idacc);
				    }
   				}
   				$idsfound->{$idacc} = 1;
   				last;
			}
			elsif($line =~ m/^>gi\|(\d+)\|$defline_format/)
			{
   			   $gi = $1;
			   $idacc = $2;
			   $locus = $3;
			   $counts->{ $format_name } += 1;
			   if($idsfound->{$gi}) 
			   {
				  if($logfilepath ne "" && $errorfilepath ne "") # print to logfiles
				  {
					 open (LOGFILE, ">>$logfilepath");
					 printf(LOGFILE "  ERROR: found duplicated sequence ID (gi)'%s' in %s (%s)\n", $gi, $infile, $step);
					 close (LOGFILE); 
					 open (ERRORFILE, ">>$errorfilepath");
					 printf(ERRORFILE "ERROR: found duplicated sequence ID (gi) '%s' in %s (%s)\n", $gi, $infile, $step);
					 close (ERRORFILE);
				  }
				  else # print to STDOUT
				  {
					 printf(STDOUT "ERROR: found duplicated sequence ID (gi) '%s' in %s\n", $gi, $infile);
				  }
			   }
			   $idsfound->{$gi} = 1;
			   last;
			}
		}
		if($idacc)
		{
			my $replace = $idacc;
			$replace .= " locus=$locus" if($locus);
			$replace = "$gi accession=$replace" if($gi);
			$replace = "lcl|$replace" if($outfmt eq "Local");
			$replace = "gnl|$db|$replace" if($outfmt eq "General");
			$line =~ s/>\S+/>$replace/;
		}
		else
		{
		printf(STDOUT "warning: could not validate defline format in '$infile' for : '%s'\n",$line);
		}
	}
	### If print selected, print line from file.
	if($output eq "print")
	{
	printf($OUT "%s\n", $line);
	}
}
# End process lines

# Print report about validated deflines
while(my($format, $format_name) = each(%$deflines))
{
	if($counts->{$format_name} > 0)
	{
		if($logfilepath ne "" && $errorfilepath ne "") # print to logfiles
		{
			open (LOGFILE, ">>$logfilepath");
			printf(LOGFILE "  Detected %d sequences with '%s' defline format\n ",
			$counts->{$format_name}, $format_name);
			# printf(STDOUT "note: validated %d sequences with '%s' defline format\n",
			# $counts->{$format_name}, $format_name);
		 	close (LOGFILE);
		 }
		 else
		 {
			printf(STDOUT "Detected %d sequences with '%s' defline format\n ",
			$counts->{$format_name}, $format_name);
		 }
	}
}