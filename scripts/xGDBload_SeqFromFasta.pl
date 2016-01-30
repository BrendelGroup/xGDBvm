#!/usr/bin/perl

my $USAGE = <<ENDUSAGE;
$0 TableName FASTA_sequenceFile
:: This script creates insert statements to populate an xGDB sequence
table given a sequence files in FASTA format.
ENDUSAGE

if(scalar(@ARGV) < 2){ die $USAGE; }

$TABLE = shift;

while($_ = <>){
  chomp;
  if(/^>/){
    if(defined($gi)){
      $seq =~ s/\s//g;
      chomp($desc);
      $gi = "'$gi'" if ($gi !~ /^\d+$/);
	#$gi=~ s/chr//g;
      $desc =~ s/'/\\'/g;
	if (description=~ /clone\s+(\S+)\s+/){
		$clone=$1;
	}
      print "INSERT INTO $TABLE SET gi=$gi,acc='$acc',locus='$locus',version=$ver,description='$desc',seq='$seq'";
      if(defined $clone){ print ",clone='$clone'"; }
      print ";\n";
      undef($clone);
    }
    
    ($gi,$acc,$locus,$ver,$desc,$seq) = (0,'NULL','NULL',0,'','');

    if(/^>gi\|(\d+)\|gb\|([^\|]+)\|([^\s\|]*)\S*\s*([^\n]*)/){ #e.g. >gi|392873228|gb|JK990684.1|JK990684 46MJK02.10 WSSP Wolffia australiana cDNA library
      $gi = $1; 
      $acc = $2;
      $locus = $3;
      $desc = $4;
    }elsif(/^>gi\|(\d+)([^\n]*)/){ #e.g. >gi|123456
		$gi = $1;
		$acc = $gi;
		$locus =$gi;
		$desc = '';
	}elsif(/^>gi\|(\d+)\|dbj\|([^\|]+)\|([^\s\|]*)\S*\s*([^\n]*)/){
	$gi = $1;
      $acc = $2;
      $locus = $3;
      $desc = $4;

	}elsif(/^>gi\|(\d+)\|ref\|([^\|]+)\|\S*\s*([^\n]*)/){ 	#gi|58585104|ref|NP_001011578.1|
	$gi = $1;
      $acc = $2;
      $locus = $1;
      $desc = $3;
	}elsif(/^>gnl\|[^\|]+\|(\S+)\s*([^\n]*)/){ 	# >gnl|Amel|GB10002-PA  Description
		$gi = $1;
		$acc = $gi;
		$locus =$gi;
		$desc = $2;
    }elsif(/^>lcl\|([^\|\s]+)\S*\s+([^\n]*)/){
      $locus = $1;
      $desc = $2;
      $gi = $locus;
    }elsif(/^>(\S+)\|\s*(.*)/){ #e.g. >Medtr4g098190.1| Cupin chr04_pseudomolecule_IMGAG_V3
		$gi = $1;
		$desc = $2;
	}elsif(/^>(\S+)\s+(.*)/){ #e.g. >Medtr4g098190.1 Cupin chr04_pseudomolecule_IMGAG_V3
		$gi = $1;
		$desc = $2;

	}elsif(/^>(\S+)([^\n]*)/){ #e.g. >Medtr4g098190.1
		$gi = $1;
		$acc = $gi;
		$locus =$gi;
		$desc = '';
	}
    # The following statement assumes that any ID containing a period is formatted $accession.$version.
    # This has caused me so much headache, I can't believe I waited until now to look into the issue.
    # As of Jun 25 2013, I declare the following statement DEPRECATED! Daniel S. Standage
    # ($acc,$ver) = split(/\./,$acc) if($acc =~ /\./);
  }else{
    $seq .= $_;
  }
}
if(defined($gi)){
  $seq =~ s/\s//g;
  chomp($desc);
  $gi = "'$gi'" if ($gi !~ /^\d+$/);
	#$gi=~ s/chr//g;
  $desc =~ s/'/\\'/g;
	if (description=~ /clone\s+(\S+)\s+/){
                $clone=$1;
        }
  print "INSERT INTO $TABLE SET gi=$gi,acc='$acc',locus='$locus',version=$ver,description='$desc',seq='$seq'";
  if(defined $clone){ print ",clone='$clone'"; }
  print ";\n";
}
