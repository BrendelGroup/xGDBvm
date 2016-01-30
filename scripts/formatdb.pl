#!/usr/bin/perl -w

# usage: ####.$ScriptDIR/formatdb.pl $tmpWorkDATA/data/BLAST/

use strict;
use warnings;

opendir(my $DIR, "$ARGV[0]") or die("error: cannot open directory '". $ARGV[0] ."' $!");
my @FASTAfiles = readdir($DIR);
closedir($DIR);
# open(my $LOG, ">", "myErroLOG"); 6/14/15
foreach my $FASTAfile (@FASTAfiles)
{
  my $seqfile = $ARGV[0] ."/". $FASTAfile;
  my @pep_suffixes = ("pep.fa", "prot.fa");
  my $dbtype = "nucl";
  foreach my $suffix(@pep_suffixes)
  {
    if($seqfile =~ m/$suffix$/)
    {
      $dbtype = "prot";
    }
  }

  my $error = system("/usr/local/bin/makeblastdb -in $seqfile -dbtype $dbtype -parse_seqids -out $seqfile");
  if ($error)
  {
    print LOG "$error\t$FASTAfile\n";
  }	
}

print STDERR "makeblastdb.pl done!\n";


