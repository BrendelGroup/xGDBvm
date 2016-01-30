#!/usr/bin/perl
 # check login & database connection

use CGI ":all";
use DBI;
do 'ATDB_SITEDEF.pl';
do 'ATDB_getPARAM.pl';

%attr = (PrintError=>0,RaiseError=>0);
$ATdbh = DBI->connect("DBI:mysql:ATGDB5:localhost","BGlabs","",\%attr);


$outputTXT = "";

# get genes from checkbox
@pvar = param;

for ($k=0;$k<scalar(@pvar);$k++){
    if ($pvar[$k] =~ /geneId/){
      ($gid) = $pvar[$k] =~ /geneId(.+)/;
      $genes[++$#genes] = $gid;
    }
}


# accepts array of geneIds for UCA
$query = "select geneId,gene_structure,chr,CDSstart,CDSstop from user_gene_annotation";
$ref = $ATdbh->selectall_hashref($query,'geneId');

for (my $g=0;$g<scalar(@genes);$g++){
$k = $genes[$g];
$info = $$ref{$k}{'gene_structure'};
$chr = $$ref{$k}{'chr'};
$cds_start = $$ref{$k}{'CDSstart'};
$cds_end = $$ref{$k}{'CDSstop'};

$RoutputTXT .= "\n>$k\n";
$PoutputTXT .= "\n>$k\n";

# open Genome Sequence File
open(SR,$LIBRARY_SEQUENCE_REPOSITORY_FILE[$dbid]) || die "cannot open genome file";

 #mRNA sequence
  if ($info ne ""){

  $mRNAseqf = "";
  my @coordpairs = $info =~ /\d+\.\.\d+/g;
  $seq = "";
  my @coords, $newseq;
  for (my $i=0;$i<scalar(@coordpairs);$i++){
    @coords = split /\.\./, $coordpairs[$i];
    seek(SR,($genomeST[$dbid]->{$chr} + $coords[0]-1 ),0);
    read(SR,$newseq, $coords[1]-$coords[0]+1);
    $seq .= $newseq;
  }
  close SR;
  if ($info =~ /complement/){
      $seq = reverse $seq;
      $seq =~ tr/ACGT/TGCA/;
  }
  my $lines=0,$mRNAseqf = "";
  $lines = int length($seq)/60;
  for ($ip=0;$ip<$lines;$ip++){
    $mRNAseqf .= substr($seq,60*$ip,60)."\n";
  }
  $mRNAseqf .= substr($seq,60*$ip,length($seq)-60*$ip);
  $RoutputTXT .= $mRNAseqf."\n";

  }
  # protein sequence
      %codon = (
    'TCA' => 'S',    # Serine
    'TCC' => 'S',    # Serine
    'TCG' => 'S',    # Serine
    'TCT' => 'S',    # Serine
    'TTC' => 'F',    # Phenylalanine
    'TTT' => 'F',    # Phenylalanine
    'TTA' => 'L',    # Leucine
    'TTG' => 'L',    # Leucine
    'TAC' => 'Y',    # Tyrosine
    'TAT' => 'Y',    # Tyrosine
    'TAA' => '*',    # Stop
    'TAG' => '*',    # Stop
    '---' => '-',    # In-frame gap
    '...' => '_',    # In-frame gap
    'NNN' => 'N',	 # UNK
    '???' => '?',    # UNK
    'TGC' => 'C',    # Cysteine
    'TGT' => 'C',    # Cysteine
    'TGA' => '*',    # Stop
    'TGG' => 'W',    # Tryptophan
    'CTA' => 'L',    # Leucine
    'CTC' => 'L',    # Leucine
    'CTG' => 'L',    # Leucine
    'CTT' => 'L',    # Leucine
    'CCA' => 'P',    # Proline
    'CCC' => 'P',    # Proline
    'CCG' => 'P',    # Proline
    'CCT' => 'P',    # Proline
    'CAC' => 'H',    # Histidine
    'CAT' => 'H',    # Histidine
    'CAA' => 'Q',    # Glutamine
    'CAG' => 'Q',    # Glutamine
    'CGA' => 'R',    # Arginine
    'CGC' => 'R',    # Arginine
    'CGG' => 'R',    # Arginine
    'CGT' => 'R',    # Arginine
    'ATA' => 'I',    # Isoleucine
    'ATC' => 'I',    # Isoleucine
    'ATT' => 'I',    # Isoleucine
    'ATG' => 'M',    # Methionine
    'ACA' => 'T',    # Threonine
    'ACC' => 'T',    # Threonine
    'ACG' => 'T',    # Threonine
    'ACT' => 'T',    # Threonine
    'AAC' => 'N',    # Asparagine
    'AAT' => 'N',    # Asparagine
    'AAA' => 'K',    # Lysine
    'AAG' => 'K',    # Lysine
    'AGC' => 'S',    # Serine
    'AGT' => 'S',    # Serine
    'AGA' => 'R',    # Arginine
    'AGG' => 'R',    # Arginine
    'GTA' => 'V',    # Valine
    'GTC' => 'V',    # Valine
    'GTG' => 'V',    # Valine
    'GTT' => 'V',    # Valine
    'GCA' => 'A',    # Alanine
    'GCC' => 'A',    # Alanine
    'GCG' => 'A',    # Alanine
    'GCT' => 'A',    # Alanine
    'GAC' => 'D',    # Aspartic Acid
    'GAT' => 'D',    # Aspartic Acid
    'GAA' => 'E',    # Glutamic Acid
    'GAG' => 'E',    # Glutamic Acid
    'GGA' => 'G',    # Glycine
    'GGC' => 'G',    # Glycine
    'GGG' => 'G',    # Glycine
    'GGT' => 'G',    # Glycine
    );

  if ($cds_start ne "" and $cds_end ne "" and $info ne ""){
    %xlist = ();
    $clist = $tlist = "";
    my @exonpairs = $info =~ /\d+\.\.\d+/g;
    for (my $ep=0;$ep<scalar(@exonpairs);$ep++){
      my @ecoords = split /\.\./, $exonpairs[$ep];
      for (my $epc=$ecoords[0];$epc<=$ecoords[1];$epc++){
	  $clist .= "$epc,";
	  $tlist .= keys(%xlist).",";
	  $xlist{$epc} = keys(%xlist);
      }
    }
    if ($info =~ /complement/){
      @tempArr1 = split /\,/, $clist;
      @tempArr2 = split /\,/, $tlist;
      %xlist = ();
      for (my $s=0;$s<scalar(@tempArr1);$s++){
        $xlist{$tempArr1[$s]} = $tempArr2[$#$tempArr2 - $s];
      }
    }
    $proteinseqn = substr($seq,$xlist{$cds_start},($xlist{$cds_end}-$xlist{$cds_start}));
     # $proteinseqf = "$cds_start,$cds_end sds $proteinseqn";
    $proteinseq = $proteinseqf = "";
    for (my $cc=0;$cc<length($proteinseqn)/3;$cc++){
      $proteinseq .= $codon{substr($proteinseqn,3*$cc,3)};
    }
    $lines = int length($proteinseq)/60;
    for ($ip=0;$ip<$lines;$ip++){
     $proteinseqf .= substr($proteinseq,60*$ip,60)."\n";
    }
    $proteinseqf .= substr($proteinseq,60*$ip,length($proteinseq)-60*$ip);
    #$proteinseqf .= "\n $xlist{$cds_start} $xlist{$cds_end}";
     $PoutputTXT .= $proteinseqf."\n";
  }



} # end genes loop
print header();
print "<html><body><pre>";
print "OsGDB User Contributed Annotations for $cgi_paramHR->{USERid}\n-------------------------------------------------------------------------------------\n";

if (param('exportType') eq "RFSA"){
    print $RoutputTXT;
}elsif(param('exportType') eq "PFSA"){
    print $PoutputTXT;
}elsif(param('exportType') eq "GFF"){
    print "not available yet";
}
print "</pre></body></html>";
