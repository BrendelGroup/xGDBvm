#! /usr/bin/perl -w

my $USAGE = <<ENDUSAGE;
$0 [-t TableName] GFF_File(s)
:: This script creates insert statements to populate an to populate an xGDB
gene_annotation table given the GFF format file.
ENDUSAGE

# Get TableName
my @GFFfiles = ();
my $table    = "gseg_gene_annotation";
for ( $x = 0 ; $x <= $#ARGV ; $x++ ) {
    if ( $ARGV[$x] eq '-t' ) {
        $table = $ARGV[ $x + 1 ];
        $x++;
    }
    else {
        push( @GFFfiles, $ARGV[$x] );
    }

}

# Declare variables for the gseg_gene_annotation table.
my (
    $geneId,   $chr,            $strand,        $l_pos,
    $r_pos,    $gene_structure, $description,   $note,
    $CDSstart, $CDSstop,        $transcript_id, $source,
    $type,     $score,          $phase,         $attributes,
    $tmpl_pos, $tmpr_pos,       $CDS,           $UTR
);
my $tmpchr;
my $geneType = "";

# Flag non-protein-coding (npc) gene types by label:
my %npcGeneOfType;
my @npcGeneType = (
    'miRNA',        'tRNA', 'snoRNA',                 'ncRNA',
    'mRNA_TE_gene', 'rRNA', 'pseudogenic_transcript', 'snRNA'
);
foreach (@npcGeneType) {
    $npcGeneOfType{$_} = 1;
}

# Create arrays for CDS, CDS_UTR, CDS_Exon; create sorted arrays for these
my @CDSarray            = ();
my @CDS_UTRarray        = ();
my @CDS_Exonarray       = ();
my @sortedCDS_UTRarray  = ();
my @sortedCDSarray      = ();
my @sortedCDS_Exonarray = ();
$description = "";
$note        = "";
my $locus_id = '';

#
my $flagNewGene = 0
  ; # Set this flag to 0 so that the lines following the first "mRNA" (or other gene tag) are read properly.
my $flagALLDONE;

# Default for whether UTR is explicitly specified: NO
$UTR = "NO";

# Read file and split 9 columns: tmpchr, source, type, tmpl_pos, tmpr_pos, tmpstrand, phase, attributes
FILELOOP:
foreach $INFILE (@GFFfiles) {
    open( FILE, "$INFILE" ) || die("Cannot open $ARGV[0]");
    $flagALLDONE = 0;
    $flagNewGene = 0;
    while (<FILE>) {
        if ( $_ =~ /^#/  ||  $_ =~ /^$/) { next; }
        (
            $tmpchr, $source,    $type,  $tmpl_pos, $tmpr_pos,
            $score,  $tmpstrand, $phase, $attributes
        ) = split( /\t/, $_ );

        # Assign f or r strand:
        if ( $tmpstrand eq '+' ) {
            $tmpstrand = 'f';
        }
        else {
            $tmpstrand = 'r';
        }

        # Match column 3 to "mRNA" or another previously-defined non-mRNA type
        if ( $type eq 'mRNA' or exists $npcGeneOfType{$type} ) {
          FINISHUP:
            $CDSstart = 0;
            $CDSstop  = 0;
            if ($flagNewGene) {
               # A new gene description segment is initiated.  Finish up the previous one:
                my $even_oddFlag = 1;
                my @WorkingArray = ();

                my @sortedWorkingArray = ();
                my $tmpCDS1;
                if ( $#CDS_Exonarray > -1 && $UTR eq "NO" ) {
                    foreach $tmpCDS1 (@CDS_Exonarray) {
                        push( @WorkingArray, $tmpCDS1 );
                    }
                }
                else {
                    foreach $tmpCDS1 (@CDS_UTRarray) {
                        push( @WorkingArray, $tmpCDS1 );
                    }
                }
                @sortedWorkingArray = sort { $a <=> $b } @WorkingArray;
                foreach my $tmpCDS (@sortedWorkingArray) {
                    if ( $even_oddFlag eq 1 ) {
                        if ( !$gene_structure ) {
                            $gene_structure = $tmpCDS . "..";
                            $even_oddFlag   = 0;
                        }
                        else {
                            $gene_structure =
                              $gene_structure . "," . $tmpCDS . "..";
                            $even_oddFlag = 0;
                        }
                    }
                    else {
                        $gene_structure = $gene_structure . $tmpCDS;
                        $even_oddFlag   = 1;
                    }
                }

                if ( $#CDSarray > -1 ) {
                  @sortedCDSarray = sort { $a <=> $b } @CDSarray;
                  if ( $strand eq 'f' ) {
                    $CDSstart = $sortedCDSarray[0];
                    $CDSstop  = $sortedCDSarray[$#sortedCDSarray];
                    if ( $CDSstart eq $l_pos ) {
                        if ( $CDSstop eq $r_pos ) {
                            $gene_structure =~ s/(\d+)$/\&gt\;$1/;
                            $gene_structure =
                              "join(&lt;" . $gene_structure . ")";
                        }
                        else {
                            $gene_structure =
                              "join(&lt;" . $gene_structure . ")";
                        }
                    }
                    else {
                        if ( $CDSstop eq $r_pos ) {
                            $gene_structure =~ s/(\d+)$/\&gt\;$1/;
                            $gene_structure = "join(" . $gene_structure . ")";
                        }
                        else {
                            $gene_structure = "join(" . $gene_structure . ")";
                        }
                    }
                  }
                  else {
                    $CDSstop  = $sortedCDSarray[0];
                    $CDSstart = $sortedCDSarray[$#sortedCDSarray];
                    if ( $CDSstop eq $l_pos ) {
                        if ( $CDSstart eq $r_pos ) {
                            $gene_structure =~ s/(\d+)$/\&gt\;$1/;
                            $gene_structure =
                              "complement(join(&lt;" . $gene_structure . "))";
                        }
                        else {
                            $gene_structure =
                              "complement(join(&lt;" . $gene_structure . "))";
                        }
                    }
                    else {
                        if ( $CDSstart eq $r_pos ) {
                            $gene_structure =~ s/(\d+)$/\&gt\;$1/;
                            $gene_structure =
                              "complement(join(" . $gene_structure . "))";
                        }
                        else {
                            $gene_structure =
                              "complement(join(" . $gene_structure . "))";
                        }
                    }
                }
              }
              else {
                $CDSstart = 0;
                $CDSstop  = 0;
              }
              print
"INSERT into $table (geneId,gseg_gi,strand,l_pos,r_pos,gene_structure,description,note,CDSstart,CDSstop,transcript_id,locus_id) VALUES ('$geneId','$chr','$strand',$l_pos,$r_pos,'$gene_structure','$description','$note',$CDSstart,$CDSstop,'$transcript_id','$locus_id');\n";
              $gene_structure = "";
              @CDSarray       = ();
              @CDS_UTRarray   = ();
              @CDS_Exonarray  = ();
              if ($flagALLDONE) { next FILELOOP; }
            }

            # Set flagNewGene to 1 (the previous gene having been processed)
            $flagNewGene = 1;
            $strand      = $tmpstrand;
            $l_pos       = $tmpl_pos;
            $r_pos       = $tmpr_pos;

            if (   $attributes =~ /ID=(\S+?);/i
                || $attributes =~ /mRNA\s+([0-9]{5}\.m[0-9]{6});/i )
            {
                $transcript_id = $1;
                $description   = $attributes;
                $description =~ s/\s+$//g;
                $description =~ s/"/ /g;
                $description =~ s/'/prime/g;
                $note = $description;
            }
            $geneType = $type;
            $geneId   = $transcript_id;
            if (   $attributes =~ /Parent=(\S+?);/
                || $attributes =~ /Parent=(\S+)/ )
            {
                $locus_id = $1;
            }
            else {
                $locus_id = $geneId;
            }
            $chr = $tmpchr;
        }
        elsif ($type =~ m/UTR/i) {
            $UTR = 'YES';
            if ( $#CDS_UTRarray == -1 ) {
                push( @CDS_UTRarray, $tmpl_pos );
                push( @CDS_UTRarray, $tmpr_pos );
            }
            else {
                my $lastR = pop(@CDS_UTRarray);
                if ( $lastR < $tmpr_pos ) {
                    if ( $lastR == $tmpl_pos - 1 ) {
                        push( @CDS_UTRarray, $tmpr_pos );
                    }
                    else {
                        push( @CDS_UTRarray, $lastR );
                        push( @CDS_UTRarray, $tmpl_pos );
                        push( @CDS_UTRarray, $tmpr_pos );
                    }
                }
                else {
                    my $lastL = pop(@CDS_UTRarray);
                    if ( $lastL == $tmpr_pos + 1 ) {
                        push( @CDS_UTRarray, $lastR );
                        push( @CDS_UTRarray, $tmpl_pos );
                    }
                    elsif ( $lastR == $tmpr_pos + 1 ) {
                        push( @CDS_UTRarray, $lastL );
                        push( @CDS_UTRarray, $tmpl_pos );
                    }
                    else {
                        push( @CDS_UTRarray, $lastL );
                        push( @CDS_UTRarray, $lastR );
                        push( @CDS_UTRarray, $tmpl_pos );
                        push( @CDS_UTRarray, $tmpr_pos );
                    }
                }
            }
        }
        elsif ($type =~ /exon/
            or $type =~ /pseudogenic_exon/
            or exists $npcGeneOfType{$geneType} )
        {
            push( @CDS_Exonarray, $tmpl_pos );
            push( @CDS_Exonarray, $tmpr_pos );
        }
        elsif ($type =~ /CDS/) {
            push( @CDSarray, $tmpl_pos );
            push( @CDSarray, $tmpr_pos );
            if ( $#CDS_UTRarray == -1 ) {
                push( @CDS_UTRarray, $tmpl_pos );
                push( @CDS_UTRarray, $tmpr_pos );
            }
            else {
                my $lastR = pop(@CDS_UTRarray);
                if ( $lastR < $tmpr_pos ) {
                    if ( $lastR == $tmpl_pos - 1 ) {
                        push( @CDS_UTRarray, $tmpr_pos );
                    }
                    else {
                        push( @CDS_UTRarray, $lastR );
                        push( @CDS_UTRarray, $tmpl_pos );
                        push( @CDS_UTRarray, $tmpr_pos );
                    }
                }
                else {
                    my $lastL = pop(@CDS_UTRarray);
                    if ( $lastL == $tmpr_pos + 1 ) {
                        push( @CDS_UTRarray, $lastR );
                        push( @CDS_UTRarray, $tmpl_pos );
                    }
                    else {
                        push( @CDS_UTRarray, $lastL );
                        push( @CDS_UTRarray, $lastR );
                        push( @CDS_UTRarray, $tmpl_pos );
                        push( @CDS_UTRarray, $tmpr_pos );
                    }
                }
            }
        }
        if ( eof(FILE) ) {   # finish up if input file ends with a non-comment, non-empty line
            $flagALLDONE = 1;
            goto FINISHUP;
        }
    }
    if ( eof(FILE) ) {   # finish up if input file ends with a ^# or empty line
        $flagALLDONE = 1;
        goto FINISHUP;
    }
}
