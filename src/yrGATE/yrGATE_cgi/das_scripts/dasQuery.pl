#!/usr/bin/perl

use Bio::Das;

sub queryDASevidence_genomeSequence{
    # this function sets the genome sequence, $PRM->{GenomeSequence}, and evidence data , $evidenceHashRef
    # DAS features (of groups) that overlap the region, are retrieved
    #    The full structure of a group is needed for the evidence plot, (for visual presentation of structures that extend outside of the window, and for selecting the whole structure by clicking on the label)
    #    Comment: DAS servers (ucsc, wormbase) do not currently support the retrieve by group_id component
    #    Solution: The segment range is increased by $padd.  Does not guarantee a range for all structures.  Exception is a structure that has a feature beyond $padd of range

    my $padd = 0;
    $PRM->{GenomeSequence} = "";
    my @crows = dasCookie();
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

    my @exon_features;
    # features 
    for (my $i=1;$i<scalar(@crows);$i++){
        @fields = split /-:-/, $crows[$i];
	$db = Bio::Das->new($fields[1] => $fields[2]);
	$segment = $db->segment(-name=>$PRM->{chr},-start=>$PRM->{start}-$padd,-end=>$PRM->{end}+$padd);
	@exon_features  = (@exon_features,$segment->overlapping_features(-type=>[$fields[3]]));     
	 
    }

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
  my %evidenceHash;
  $evidenceHashRef = getExons(\@evidenceArr,\%evidenceHash);
  return $evidenceHashRef;
}


1;
