#!/usr/bin/perl
## Updated 2/19/16 
##SYNTAX
print("Usage: ./$0 <unmasked_file> <masked_file> <sql_output> <fasta_output> <base>\n");

open (RAW, "$ARGV[0]") or die("Error: $!. File: $ARGV[0]");
open (MASK, "$ARGV[1]") or die("Error: $!. File: $ARGV[1]");
open (OUT, ">$ARGV[2]") or die("Error: $!. File: $ARGV[2]");
open (FAS, ">$ARGV[3]") or die("Error: $!. File: $ARGV[3]");

##Strategy: Open both files. Seperate out the segments based on the > sign.
##Extract the gi number from the first line.
##Merge the rest of the string into a single line.
##Run ~/X+/g and get the indicies. Note the indices.
##Obtain the substring, and construct the SQL queries

##1. Strategy: Open both files. Seperate out the segments based on the > sign.
$sep = $/;
$/ = '>'; ## this is now the line separator

##Think about it
##seek(RAW, SEEK_SET, 1);

my $gi_line = "";
my $gi_line2="";
my $line2 = "";
my $seq1="";
my $seq2="";
my $subseq1="";
my $subseq2="";
my $start = 0;
my $M = 0;  ## Masking ID, e.g. "M1"
my $valid ="F";
my $heading = "";
my $masked = "";
my $rawfile=$ARGV[0];
my $maskfile=$ARGV[1];
my $base=$ARGV[4];
my $isMask;

while (<MASK>)
{
    chomp $_; ## get rid of the first ">"
    my $line1 = $_;  # fasta header plus fasta sequence for the current record.
    $line1 = ">".$line1; # reconstruct the fasta header.
    my $length = length($line1);

    if (@pieces=($line1 =~ /^>gi\|(\d+?)\|(.*?)\n.+/))
    {  ## regex for a GenBank fasta header with line feed, e.g. >gi|12345|gb|ABC123| This is description\n
    ##TODO: Set the gi, and other details from this.
        $gi_line = ">gi|".$pieces[0].$pieces[1];
        $gi = $pieces[0];
        $desc = $pieces[1];
        $M = 0; # first sequence, closest to header.
        $valid="T";
        $heading="GenBank";
        
#      print "gi=$gi; gi_line=$gi_line; desc=$desc; M=$M; heading=$heading; length=$length; line1=$line1;\n";
    }
    elsif(@pieces=($line1 =~ /^>(\S+?)\s+(.+?)\n.*?/)) #
    {  ## regex for a non-GenBank fasta header with description and line feed, e.g. >scaff_12345 This is description\n
    
       ## >NW_003307545.1 Volvox carteri f. nagariensis unplaced genomic scaffold VOLCAscaffold_1, whole genome shotgun sequence
        $gi_line = ">".$pieces[0].$pieces[1];
        $gi = $pieces[0];
        $desc = $pieces[1];
        $M = 0;
        $valid="T";
        $heading="simple with description";
#       print "gi=$gi;  gi_line=$gi_line; desc=$desc; M=$M; heading=$heading; line1=$line1\n";
    }
    elsif(@pieces=($line1 =~ /^>(\S+?)\n.*/))
    {  ## regex for a non-GenBank fasta header with no description and line feed, e.g. >scaff_12345\n
        $gi_line = ">".$pieces[0].$pieces[1];
        $gi = $pieces[0];
        $desc = "";
        $M = 0;
        $valid="T";
        $heading="simple with no description";
#      print "gi=$gi;  gi_line=$gi_line; desc=$desc; M=$M;  heading=$heading; line1=$line1\n";
    }
    else
    {
    print "Error: This unmasked fasta header cannot be read. line1=$line1\n";
        $valid="F";
    }

    ## assign line1 to the sequence (non-header) portion of the line.
    $seq1 = substr($line1, length($gi_line) + 1, length($line1) - length($gi));
    $seq1_stripped = $seq1;
    $seq1_stripped =~ s/\n//g; ## strip linefeeds
#    print "seq1_stripped=$seq1_stripped\n\n";


    if($valid eq "T")
    {
        #Search the MASK string for sequences of X+
        ##Record the matches, and construct the SQL statements.
        while ($seq1_stripped =~ /(${base}+)/g) 
        {
            $M = $M + 1;
            print $-[0]." ".$+[0]."\n";
            $lpos = $-[0] + 1;
            $rpos = $+[0];
            $subseq1=`/usr/local/bin/blastdbcmd -db $rawfile -entry $gi -range ${lpos}-${rpos} -outfmt %s`;
            if($subseq1 =~ /(\S+)\n/)
            {
              $subseq1 = $1;
            }
            #$seq=chomp($seq);

            $subseq2=`/usr/local/bin/blastdbcmd -db $maskfile -entry $gi -range ${lpos}-${rpos} -outfmt %s`;
            if($subseq2 =~ /(\S+)\n/)
            {
              $subseq2 = $1;
            }
            if($subseq1 eq $subseq2) # was already N-string
            {
              $isMask="False";
              $maskType="Unknown bases";
            }
            else
            {
              $isMask="True";
              $maskType="Repeat Masked Region";
            }
              printsql($gi, $M, $desc, $subseq1, $lpos, $rpos, $isMask, $maskType);
#       print "gi=$gi, M=$M, desc=$desc, seq=$seq, lpos=$lpos, rpos=$rpos\n\n";
        }
        $start = tell MASK;  ## NEW START, from where the pointer was, includes line feeds.
        print "NEW START=$start\n\n";
    }
}

close MASK;
close OUT;
close FAS;

sub printsql() {
    ($gi, $M, $desc, $seq, $lpos, $rpos, $isMask) = @_;
    $maskgi = $gi.".M".$M;
    $sql = "INSERT into mask set gi=\"$maskgi\", description=\"$maskType from $lpos to $rpos in $gi; $desc\",seq=\"$seq\";\n\n";
    $pgsstart = $lpos;
    $pgsend = $rpos;
    $sql = $sql."INSERT into gseg_mask_good_pgs set gi=\"$maskgi\",gseg_gi=\"$gi\",pgs_lpos=1,pgs_rpos=".length($seq).",l_pos=$pgsstart,r_pos=$pgsend,pgs=\"$pgsstart $pgsend\",isCognate=\"$isMask\";\n\n";
    $fasta = ">".$maskgi."\n".$seq."\n";
    print OUT $sql;
    print FAS $fasta;
}
