#!/usr/bin/perl -w
#use strict "vars";

use CGI ":all";
#require 'yrGATE_functions.pl';
#require 'yrGATE_conf.pl';

use vars qw(
$PRM
$UCAcgiPATH
$GV
$GVportal
@modes
$DBH
$zeroPos
$IMAGEDIR
$GENSCAN_speciesModel
);

require 'yrGATE_conf.pl';
#require 'yrGATE_functions.pl';

my $gdb = $GV->{dbTitle};
my $cgi = CGI->new;
print $cgi->header;

$PRM->{info} = $cgi->param("exons");
$PRM->{strand} = $cgi->param("strand");
$PRM->{start} = $cgi->param("start");
$PRM->{end} = $cgi->param("end");
$PRM->{GSeqEdits} = $cgi->param("edits");
$PRM->{cds_start} = $cgi->param("cdsStart");
$PRM->{cds_end} = $cgi->param("cdsEnd");
$PRM->{owner} = $cgi->param("owner");
$PRM->{createTime} = $cgi->param("createTime");
my $tmpElist = "";
open (ELIST, "/xGDBvm/tmp/$gdb/elist_$PRM->{createTime}");
while(read(ELIST, $file_contents, 1024)) {
   $tmpElist .= $file_contents;
}
close (ELIST);
$PRM->{Elist} = $tmpElist;

my $txt = yrgateToGFF3();

open (FILE, ">", "/xGDBvm/tmp/". $gdb . "/yourStrux.gff") || die "Could not open: $!";
print FILE "#gff-version 3\n";
print FILE $txt;
close FILE;


sub yrgateToGFF3{
#GFF3 format defined at http://song.sourceforge.net/gff3.shtml
#[seqid] [source] [type] [start] [end] [score] [strand] [phase] [attributes]
#attributes = id,name,alias,parent,target,note,Dbxref,Evidence_for,Organism,Substituted_sequence,Inserted_sequence
#   Evidence_for,Organism is novel attribute for yrGATE GFF export
#types = gene,mRNA,exon,CDS,region,insertion,deletion,substitution

#my ($local_uidRef) = @_;

my $fields_legal_regex = "[a-zA-Z0-9. :^*$@!+_?-]";
my $seqid_legal_regex = "[a-zA-Z0-9.:^*$@!+_?-|]";

#my %local_uid = %$local_uidRef;
my @gff;

my $strand = ($PRM->{strand} eq "1") ? "+" : "-";

my $seq_id = $PRM->{'chr'};

# sequence edits
if ($PRM->{GSeqEdits}){
    # add note to GFF file
    $gff[++$#gff] = ["\#note: the genome segment for the following gene annotation has been edited"];
    $gff[++$#gff] = ["\#note: see /yrGATE/genome_edits.txt for further description"];


    #my $region_id = "region".(($local_uid{'region'}) ? $local_uid{'region'}++ : 1);
    my $region_id = "region1";
    my $region_attrib = "ID=$region_id;Name=$region_id;Organism=$PRM->{organism};Submitted_by=$PRM->{USERid}";
    # start is always 1 of edited regions
    $gff[++$#gff] = [escape_fields($PRM->{'chr'},'yrGATE','region','1',$PRM->{end},'.',$strand,'.',$region_attrib)];
    $seq_id = $region_id;
    my @edits = split /\n/, $PRM->{GSeqEdits};
    my $num = 0;
    for my $i (@edits){
            $num = $num + 1;
	    #chop $i; # ^M character
	    my @f = split /\,/, $i;
	    $f[2] =~ s/\W//; # any trailing characters
	    my $edit_type = ($f[1] eq "change") ? "substitution" : ($f[1] eq "insert") ? "insertion" : "deletion";
	    # start = end,  except insertions greater than length 1
  	    my $edit_length = (length($f[2]) > 1 and $edit_type eq "substitution") ? length($f[2]) : 0;
            my $edit_id = "sequence_edit".$num;
	    #my $edit_id = "sequence_edit".(($local_uid{'edit'}) ? $local_uid{'edit'}++ : 1);
	    my $edit_attrib = "ID=$edit_id;Name=$edit_id;Parent=$region_id;";
	    if ($edit_type eq "insertion"){
		$edit_attrib .= "Inserted_sequence=$f[2];";
	    }elsif($edit_type eq "substitution"){
		$edit_attrib .= "Substituted_sequence=$f[2];";
	    }
	    $gff[++$#gff] = [escape_fields($region_id,'yrGATE',$edit_type,$f[0],($f[0]+$edit_length),'.',$strand,'.',$edit_attrib)];
    }
}



#my $gene_id = "gene".( ($local_uid{'gene'}++ == 0) ? 1 : $local_uid{'gene'});
my $gene_id = "gene1";
my $mRNA_id = "mRNA1";

$PRM->{owner} = 'yrGATE';

my $gene_attrib = "ID=$gene_id;Name=$PRM->{'chr'};Organism=$gdb;Submitted_by=$PRM->{owner}";
my $mRNA_attrib = "ID=$mRNA_id;Parent=$gene_id;Name=$PRM->{'chr'}";
my $min = $PRM->{end};
my $max = $PRM->{start};

if($PRM->{cds_start} eq "") {
   $PRM->{cds_start} = $min;
}
if($PRM->{cds_end} eq "") {
   $PRM->{cds_end} = $max;
}
my @exons = $PRM->{info} =~ /\d+\.\.\d+/g;
for my $i (@exons){
    my ($start,$end) = split /\.\./, $i;
    if ($start < $min) {
        $min = $start;
    }
    if ($end > $max) {
        $max = $end;
    }
}

$gff[++$#gff] = [escape_fields(1,'.','gene',$min,$max,'.',$strand,'.',$gene_attrib)];
$gff[++$#gff] = [escape_fields(1,'.','mRNA',$min,$max,'.',$strand,'.',$mRNA_attrib)];


#jfd commented the below, added the above to adjust gene start, stop
#$gff[++$#gff] = [escape_fields($seq_id,'yrGATE','gene',$PRM->{start},$PRM->{end},'.',$strand,'.',$gene_attrib)];

my %exon_idHash;
# add sequence edits


# for exons
#my @exons = $PRM->{info} =~ /\d+\.\.\d+/g;

my @CDSgff;
my $extra = 0; # first CDS has phase 0
my $num = 0;
for my $i (@exons){
    $num = $num + 1;
    my ($start,$end) = split /\.\./, $i;
    #my $exon_id = "exon".( ($local_uid{'exon'}++ == 0) ? 1 : $local_uid{'exon'});
    my $exon_id = "exon".$num;
    $exon_idHash{"$start..$end"} = $exon_id;
    my $exon_attrib = "Parent=$mRNA_id";
    $gff[++$#gff] = [escape_fields(1,'.','exon',$start,$end,'.',$strand,'.',$exon_attrib)];
    # if CDS overlap
    if (min($PRM->{cds_start},$PRM->{cds_end}) <= $end && max($PRM->{cds_start},$PRM->{cds_end}) >= $start){
        #my $cds_id = "CDS".( ( $local_uid{'cds'}++ == 0 ) ? 1 : $local_uid{'cds'} );
        my $cds_id = "cds1";
	my $cds_attrib = "ID=$cds_id;Parent=$mRNA_id";

	my $cds_start = (min($PRM->{cds_start},$PRM->{cds_end}) <= $start) ? $start : min($PRM->{cds_start},$PRM->{cds_end});
	my $cds_end = ( max($PRM->{cds_start},$PRM->{cds_end}) <= $end) ? max($PRM->{cds_start},$PRM->{cds_end}) :  $end;

	$CDSgff[++$#CDSgff] = [escape_fields(1,'.','CDS',$cds_start,$cds_end,'.',$strand,$extra,$cds_attrib)];

        $extra =  3 - ( $cds_end - $cds_start + 1 - $extra) % 3;  # bases remaining for last codon

        if ($extra == 3){
	    $extra = 0;
	}
    }
}
push @gff,@CDSgff;

if (1){
# add exon_origins
my $num = 0;
my $cDNA_num = 0;
my $est_num = 0;
my $put_num = 0;
my $cDNA_id = {};
my $est_id = {};  #hash table [name] => index
my $put_id = {};
my $cds_id = {};
my @cDNA_set = (); #array storing GFF line of same type
my @est_set = ();
my @put_set = ();

my @evidence = split /<newline>/, $PRM->{Elist};
for my $i (@evidence){
    $num = $num + 1;
    my $index;
    my $ev_id;
    my $ev_attrib;
    my ($start,$end,$method,$score,$dbName,$name,$direct,$ref_url) = split /\s/, $i;
    #my $ev_id = "evidence".(($local_uid{'ev'}++ == 0) ? $local_uid{'ev'}++: $local_uid{'ev'});	
    if($method eq "GeneSeqer_cDNA") {
       if(exists $cDNA_id{$name}) {
          $index = $cDNA_id{$name};
       } else {
       # new cDNA occur
          $index = ++$cDNA_num;
          $cDNA_id{$name} = $index;
       }
       $ev_attrib = "ID=cDNA$index;Name=$name";
       $cDNA_set[++$#cDNA_set] = [escape_fields(1,'.',$method,min($start,$end),max($start,$end),$score,$direct,'.',$ev_attrib)];

    } elsif($method eq "GeneSeqer_EST") {
       if(exists $est_id{$name}) {
          $index = $est_id{$name};
       } else {
       # new EST occur
          $index = ++$est_num;
          $est_id{$name} = $index;
       }
       $ev_attrib = "ID=EST$index;Name=$name";
       $est_set[++$#est_set] = [escape_fields(1,'.',$method,min($start,$end),max($start,$end),$score,$direct,'.',$ev_attrib)];

    } elsif($method eq "GeneSeqer_PUT") {
       if(exists $put_id{$name}) {
          $index = $put_id{$name};
       } else {
           $index = ++$put_num;
           $put_id{$name} = $index;
       }
       $ev_attrib = "ID=PUT$index;Name=$name";
       $put_set[++$#put_set] = [escape_fields(1,'.',$method,min($start,$end),max($start,$end),$score,$direct,'.',$ev_attrib)];

    } else { #all tags should be dealed above, this part should never be executed
       $ev_id = "evidence".$num;
       $ev_attrib = "ID=$ev_id;Evidence_for=".$exon_idHash{min($start,$end)."..".max($start,$end)}.";";
       $gff[++$#gff] = [escape_fields($seq_id,$dbName,$method,min($start,$end),max($start,$end),$score,'.','.',$ev_attrib)];

    }
}
my $tag;
foreach $tag (@est_set) {
   $gff[++$#gff] = $tag;
}
foreach $tag (@put_set) {
   $gff[++$#gff] = $tag;
}
foreach $tag (@cDNA_set) {
   $gff[++$#gff] = $tag;
}
}
my $gff3;
for my $j (@gff){
    $gff3 .= join("\t",@$j)."\n";
}
#was returning \%local_uid, now just $gff3
#$PRM->{GFFOUT} = $gff3;
return $gff3;
#return ($gff3,\%local_uid);
}

sub escape_fields{
    # escapes fields for gff3
    my @fields = @_;
    my @escaped_fields = @fields;
    return @fields;
}


sub min{
  my ($a,$b) = @_;
  if ($a > $b){
    return $b;
  }else{
    return $a;
  }
}
sub max{
  my ($a,$b) = @_;
  if ($a < $b){
    return $b;
  }else{
    return $a;
  }
}

