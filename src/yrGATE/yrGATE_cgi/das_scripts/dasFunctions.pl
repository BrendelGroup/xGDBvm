#!/usr/bin/perl

use Bio::Das;

require 'yrGATE_functions.pl';

my @dasSites = ("http://www.wormbase.org/db/das",
		"http://genome.cse.ucsc.edu/cgi-bin/das",
		"http://ensembl.gsc.riken.go.jp/cgi-bin/das",
		"http://supfam.org/SUPERFAMILY/cgi-bin/das",
		"http://www.tigr.org/docs/tigr-scripts/tgi/das",
		"http://servlet.sanger.ac.uk:8080/das"
	      );

sub lookUpLink{
  my ($id,$num,$page) = @_;
  my $str = "<input type=\"button\" class=\"ll\" onclick=\"lookUp(event,'$id',$num);\" value=\"look up\">";
  return $str;
}

sub getDasSites{
  return @dasSites;
}

sub getDasSources{
  my ($source) = @_;
  my $das = Bio::Das->new($source);
  my @sources = $das->sources;
  #my @desc = $das->description;
  #my %descHash;
    for (my $j=0;$j<scalar(@sources);$j++){
      my ($dsn) = $sources[$j] =~ /\/([^\/]+?)$/;
      $sources[$j] = $dsn;
      #$descHash{$dsn} = $desc[$j];
    }
  return @sources;
}

sub connectDAS{
   my ($source,$dsn) = @_;
   my $das = Bio::Das->new($source);
   $das->dsn($dsn);
   return $das;
}

sub getDasEntryPoints{
   my ($dasDB) = @_;
   my @entryPoints = $dasDB->entry_points;
   for (my $i=0;$i<scalar(@entryPoints);$i++){
       $entryPoints[$i] =~ s/\:.+//;
   }
   return @entryPoints;
}


sub getDasFeatures{
   my ($dasDB) = @_;
   my @featTypes = $dasDB->types;
   return @featTypes;
}

sub writeSelFeatures{
   my ($dasDB,$sels) = @_;
}

sub dasCookie{
  my $cookie = cookie("DASsel");
  my @rows = split /-!-/, $cookie;
  return @rows;
}

sub dasColors{
  my %DAScolors = ();
  my @rows = dasParam();
  for (my $i=1;$i<scalar(@rows);$i++){
    my @fields = split /-:-/, $rows[$i];
    $DAScolors{$fields[3]} = $fields[4]; # one color per feature type, different sources with same feature not distinguished by color
  }
  return %DAScolors;
}

sub dasParam{
  # chr, start, end parameters
    my @crows;
 
  if ($PRM->{dasCookie}){
        @crows = split /-!-/, $PRM->{dasCookie};
  }elsif ( 0 && $PRM->{uid} && $GV->{login_required}){ # if loaded from database
	loadUCA();
	@crows = split /-!-/, $PRM->{dasCookie};
  }else{
        @crows = dasCookie();
  }

  if (scalar(@crows)>0){
      my @fields = split /-:-/, $crows[0];
      $GV->{specieName} = "$fields[2]";
      #$GV->{dbTitle} = "$fields[1]"."\/$fields[2]";
      if (!$PRM->{chr}){
	  $PRM->{chr} = $fields[3];
	  $PRM->{start} = $fields[4];
	  $PRM->{end} = $fields[5];
      }
  }

  return @crows;
}


sub queryDASevidence_genomeSequence{
    # this function sets the genome sequence, $PRM->{GenomeSequence}, and evidence data , $evidenceHashRef
    # DAS features (of groups) that overlap the region, are retrieved
    #    The full structure of a group is needed for the evidence plot, (for visual presentation of structures that extend outside of the window, and for selecting the whole structure by clicking on the label)
    #    Comment: DAS servers (wormbase) do not currently support the retrieve by group_id component
    #    Solution: The segment range is increased by $padd.  Does not guarantee a range for all structures.  Exception is a structure that has a feature beyond $padd of range
    my %evidenceHash;
    my $evidenceHashRef = \%evidenceHash;
    my $padd = 50000;
    $PRM->{GenomeSequence} = "";
    my @crows = dasParam();
    my %DAScolors = dasColors();
    # entry point sequence
    if (scalar(@crows) == 0){
		bailOut("Please set a preference cookie to use this tool.");
    }
    my @fields = split /-:-/, $crows[0];
    my $db = Bio::Das->new($fields[1] => $fields[2]);
    my $segment = $db->segment(-name=>$PRM->{chr},-start=>$PRM->{start},-end=>$PRM->{end});
    $PRM->{GenomeSequence} = $segment->seq;
    $PRM->{GenomeSequence} =~ tr/atcg/ATCG/;


    # features 
    for (my $i=1;$i<scalar(@crows);$i++){
        my @exon_features;
        @fields = split /-:-/, $crows[$i];
	$db = Bio::Das->new($fields[1] => $fields[2]);
	$segment = $db->segment(-name=>$PRM->{chr},-start=>$PRM->{start}-$padd,-end=>$PRM->{end}+$padd);
	@exon_features  = (@exon_features,$segment->overlapping_features(-type=>[$fields[3]]));
print STDERR "$fields[1] $fields[2] $#exon_features\n";
my ($seqID,$seqStart,$seqEnd,$seqScore,$seqLink);
my @evidenceArr;
my %exonCount;
for (my $i=0;$i<scalar(@exon_features);$i++){
    $seqID = $exon_features[$i]->display_name;
    $seqStart = $exon_features[$i]->start;
    $seqEnd = $exon_features[$i]->end;
    $seqScore = $exon_features[$i]->score;
    $seqLink = $exon_features[$i]->link;
    $seqMethod = $exon_features[$i]->type;
    $seqStrand = $exon_features[$i]->orientation;
    $seqStrand = ($seqStrand eq "+") ? 1 : ($seqStrand eq "-") ? -1 : 0;
    #[gi],[unique record id],[genome start position],[genome stop position],[score],[exon number]
    # add link field
    $evidenceArr[++$#evidenceArr] = ['elegans',$seqMethod,$seqID,$seqID,$seqStart,$seqEnd,$seqScore,$exonCount{$seqID}++,$seqLink,$seqStrand,$seqMethod,$DAScolors{$seqMethod}];
}
  $evidenceHashRef = getExons(\@evidenceArr,$seqMethod,"$DAScolors{$seqMethod}",$evidenceHashRef);

}


  return $evidenceHashRef;
}

1;
