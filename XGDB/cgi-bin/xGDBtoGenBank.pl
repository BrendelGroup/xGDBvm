#!/usr/bin/perl
###################################################################
#
# Purpose: 
#     To extract information from the xGDBvm MySQL database
#     about both GenBank and yrgate gene annotations located
#     within a particular region of an xGDB, and then convert that
#     information into GenBank format by using BioPerl modules.
#
# Usage: $0 $xGDB $DB $id $L_pos $R_pos $DBpath
#     All of these listed inputs are required.
#
# Where:
#     $xGDB
#        The name of the xGDB to which the gene annotation(s) belong,
#        for example AtGDB.
#     $DB
#        The database in which the information about the gene
#        annotation(s) are stored, for example ATGDB165.
#     $id
#        The id of the BAC segment or of the chromosome, depending
#        on which type the gene annotation(s) belong to.
#     $L_pos
#        The position of the BAC segment/chromosome where the
#        left-most point of the viewing frame from which the gene
#        annotation(s) are to be selected is located.
#     $R_pos
#        The position of the BAC segment/chromosome where the
#        right-most point of the viewing frame from which the gene
#        annotation(s) are to be selected is located.
#     $DBpath
#        The path to the location in the computer where the
#        nucleotide sequences for the database are stored. The
#        nucleotide sequence of the gene annotation can then be
#        obtained from this location.
#
###################################################################

#use strict; #$cgi_paramHR doesn't work if you uncomment this
use CGI ":all";
use CGI ':standard';
use CGI::Carp qw(fatalsToBrowser);
use GSQDB;
use GDBgui;

do 'SITEDEF.pl';
do 'GDBgui.pl';
do 'getPARAM.pl';

use Bio::SeqIO;
use Bio::SeqFeature::Generic;
use Bio::Annotation::Comment;
use Bio::Annotation::Collection;
use Bio::Location::Split;
use DBI;
print header(); # or print "Content-type: text/html\n\n";

my $db = new GSQDB($cgi_paramHR);

# Assigns the user-specified values to variables.
# See description of inputs above for more info.
my $xGDB = ( param('xGDB') =~ /^[0-9A-Za-z]*$/ )? param('xGDB'):"xGDB_error";
my $id = ( param('id') =~ /^[A-Za-z0-9\_\.\|-]*$/ )? param('id'):"id_error";
my $L_pos = ( param('l_pos') =~ /^[0-9]+$/ )? param('l_pos'):"l_pos_error";
my $R_pos = ( param('r_pos') =~ /^[0-9]+$/ )? param('r_pos'):"r_pos_error";
my $DBpath = ( param('DBpath') =~ /^[A-Za-z0-9\/\_-]*$/ )? param('DBpath'):"DBpath_error"; # directory path.
my $ExportType = ( param('Type') =~ /^[A-Za-z\(\)\s-]*$/ )? param('Type'):"Type_error"; # a string describing the sequence type. May have 

# $L_pos must be to the left of, or smaller than, $R_pos.
# If it is not, then an error message is displayed.
if ($L_pos >= $R_pos) {
    print "Error: The value of the leftmost position, $L_pos, must be smaller than the value of the rightmost position, $R_pos.\n";
    exit (1);
}

# Calculates the length, in bp, of the sequence.
my $size = $R_pos - $L_pos + 1;

# Determines whether database is BAC-based or chr-based.
# $type is set to either 'BAC' or 'chr'
# (Non-dynamic procedure is a commented-out portion of
# downloadRegion.pl)

# Calculates the length, in bp, of the sequence.
my $size = $R_pos - $L_pos + 1;

# Connect to the MySQL server.
# added 5-19-15 Get mysql password
my $dbpass='';
open FILE, "/xGDBvm/admin/dbpass";
while ($line=<FILE>){
$dbpass= $line;
}

my $DB_HOST = 'localhost';
my $dsn = "DBI:mysql:$xGDB:$DB_HOST";
my $user = 'gdbuser';
my $pass = $dbpass;
my %attr = (PrintError => 0, RaiseError => 0);
my $dbh = DBI->connect($dsn,$user,$pass,\%attr) or die $DBI::errstr;
my $sth;

# Select needed information from database.
    my $query = "SELECT gseg_gi,geneId,strand,l_pos,r_pos,CDSstart,CDSstop,gene_structure from gseg_gene_annotation where gseg_gi='$id' and l_pos>=$L_pos and r_pos<=$R_pos";
	print STDERR "HHHHHHHHHHHH GGGGGGGGGGG $query\n";
    $sth = $dbh->prepare($query) or die "Couldn't prepare statement: " . $dbh->errstr;
    $sth->execute() or die "Couldn't execute statement: " . $sth->errstr;

# Retrieves nucleotide sequence of segment.
my ($seq_obj,$seq,$strand);
    $seq = GetQuerySeqs($DBpath,$id,$L_pos,$R_pos);
    $seq_obj = Bio::Seq->new(-display_id => "$id", -seq => $seq);

# Creates sequence feature.
my $feat = new Bio::SeqFeature::Generic(-start => 1, -end => $size, -primary => 'source');
$seq_obj->add_SeqFeature($feat);

# Creates comment for GenBank format.
my $comment = Bio::Annotation::Comment->new;
    $comment->text("This genome sequence is from $xGDB, with a sequence ID of $id. The sequence region is from $L_pos to $R_pos");

my $coll = new Bio::Annotation::Collection;
$coll->add_Annotation('comment',$comment);
$seq_obj->annotation($coll);

my $ary_ref;
my ($gseg_gi,$chr,$geneId,$l_pos,$r_pos,$CDSStart,$CDSStop,$GeneStructure);

while ($ary_ref = $sth -> fetchrow_arrayref()) {
        # For BAC-based databases, assign variables
        # to values extracted from the database.
        ($gseg_gi,$geneId,$strand,$l_pos,$r_pos,$CDSStart,$CDSStop,$GeneStructure) = @$ary_ref;
    # Shift the endpoints of CDS and segment to the
    # new frame, which sets $L_pos as 1.
    $CDSStart = $CDSStart - $L_pos + 1;
    $CDSStop = $CDSStop - $L_pos + 1;
    $l_pos = $l_pos - $L_pos + 1;
    $r_pos = $r_pos - $L_pos + 1;

    # Assigns identification for forward nucleotide
    # strand (1) and reverse strand (-1).
    if ($strand eq 'f') {
        $strand = 1;
    } elsif ($strand eq 'r') {
        $strand = -1;
    }

    # Creates gene feature.
    my $gene = new Bio::SeqFeature::Generic(-start => $l_pos, -end =>$r_pos, -strand => $strand,
-primary => 'gene', -tag => { locus_tag => "$geneId"});
    $seq_obj->add_SeqFeature($gene);

    # Extracts exon information from the $GeneStructure
    # variable, which contains information from the database.
    my @exons;
    if ($GeneStructure =~ /,/) {
        @exons = split (/,/,$GeneStructure);
    } else {
        $exons[0] = $GeneStructure;
    }

    my $splitlocation = new Bio::Location::Split();
    my $exon;
    foreach $exon (@exons) {
        # Removes extra details from the items in @exons
        # so that all that is left is ####..####, where
        # each pair of ####'s indicate the starting and ending
        # postions of each particular exon.
        $exon =~ s/&lt;//;
        $exon =~ s/&gt;//;
        $exon =~ s/(\w+\()+//;
        $exon =~ s/\)+$//;
        # Creates mRNA feature.
        if ($exon =~ /(\d+)\.\.(\d+)/) {
            my $start = $1 - $L_pos + 1;
            my $end = $2 - $L_pos + 1;
            $splitlocation->add_sub_Location(new Bio::Location::Simple(-start => $start, -end => $end, -strand => $strand));
        }
    }

    my ($min,$max);
    # Assign to $min the smaller of $CDSStart
    # and $CDSStop, and assign to $max the larger.
    if ($strand == 1) {
        $min = $CDSStart;
        $max = $CDSStop;
    } else {
        $min = $CDSStop;
        $max = $CDSStart;
    }

    # Creates CDS feature.
    my $flag = 0;
    my $splitlocationCDS = new Bio::Location::Split();
    foreach $exon (@exons) {
        my ($start, $end);
        if ($exon =~ /(\d+)\.\.(\d+)/) {
            $start = $1 - $L_pos + 1;
            $end = $2 - $L_pos + 1;
        }
        if (!$flag) {
            # Checks to make sure that the exon from
            # $start to $end is not outside the range
            # of the CDS, or else it will not be added.
            if ($min < $end) {
                if ($max > $end) {
                    # Condition: the right endpoint of the CDS is located
                    # to the right of the right endpoint of the exon.
                    if ($min >= $start) {
                        # This exon includes the left endpoint
                        # of the CDS, but not the right endpoint.
                        $splitlocationCDS->add_sub_Location(new Bio::Location::Simple(-start => $min, -end => $end, -strand => $strand));
                    } else {
                        # This exon includes neither endpoint of
                        # the CDS, but is within the range of the CDS.
                        $splitlocationCDS->add_sub_Location(new Bio::Location::Simple(-start => $start, -end => $end, -strand => $strand));
                    }
                } else {
                    # Condition: the right endpoint of the CDS is located
                    # to the left of the right endpoint of the exon.
                    if ($min < $start and $max > $start) {
                        # This exon includes the right endpoint
                        # of the CDS, but not the left endpoint.
                        $splitlocationCDS->add_sub_Location(new Bio::Location::Simple(-start => $start, -end => $max, -strand => $strand));
                        $flag = 1;
                    } elsif ($min >= $start) {
                        # This exon includes both endpoints of the CDS.
                        $splitlocationCDS->add_sub_Location(new Bio::Location::Simple(-start => $min, -end => $max, -strand => $strand));
                        $flag = 1;
                    }
                }
            }
        }
    }
    # Adds the mRNA and CDS features.
    my $mRNA = new Bio::SeqFeature::Generic (-location => $splitlocation, -strand => $strand, -primary => 'mRNA', -tag => {locus_tag => "$geneId"});
    $seq_obj->add_SeqFeature($mRNA);
    my $CDS = new Bio::SeqFeature::Generic (-location => $splitlocationCDS, -strand => $strand, -primary => 'CDS', -tag => {locus_tag => "$geneId"});
    $seq_obj->add_SeqFeature($CDS);
}


# Determines whether any accepted yrgate user-created gene annotations
# are present in the range from $L_pos to $R_pos.
# If there are any, they are then selected from the database
# using $sth3.
my $sth2;
my $query2 = "SELECT count(*) from user_gene_annotation where dbName='$xGDB' and chr='$id' and l_pos>$L_pos and r_pos<$R_pos and status='ACCEPTED'";
$sth2 = $dbh->prepare($query2) or die "Couldn't prepare statement: " . $dbh2->errstr;
$sth2->execute() or die "Couldn't execute statement: " . $sth2->errstr;

if ($sth2->fetchrow_array()) {
    # Selects information from the database.
    my $sth3;
    my $query3 = "SELECT gseg_gi,geneId,strand,l_pos,r_pos,CDSstart,CDSstop,gene_structure,status from user_gene_annotation where dbName='$xGDB' and gseg_gi='$id' and l_pos>$L_pos and r_pos<$R_pos and status='ACCEPTED'";
    $sth3 = $dbh->prepare($query3) or die "Couldn't prepare statement: " . $dbh2->errstr;
    $sth3->execute() or die "Couldn't execute statement: " . $sth3->errstr;

    # Assign variables to values extracted from the database.
    my $ary_ref2;
    my ($gseg_gi,$chr,$geneId,$l_pos,$r_pos,$CDSStart,$CDSStop,$GeneStructure);
    while ($ary_ref2 = $sth3->fetchrow_arrayref()) {
        ($chr,$geneId,$strand,$l_pos,$r_pos,$CDSStart,$CDSStop,$GeneStructure) = @$ary_ref2;
        # Shift the endpoints of CDS and segment to the
        # new frame, which sets $L_pos as 1.
        $CDSStart = $CDSStart - $L_pos + 1;
        $CDSStop = $CDSStop - $L_pos + 1;
        $l_pos = $l_pos - $L_pos + 1;
        $r_pos = $r_pos - $L_pos + 1;

        # Assigns identification for forward nucleotide
        # strand (1) and reverse strand (-1).
        if ($strand eq 'f') {
            $strand = 1;
        } elsif($strand eq 'r') {
            $strand = -1;
        }

        # Creates gene feature.
        my $gene2 = new Bio::SeqFeature::Generic(-start => $l_pos, -end =>$r_pos, -strand => $strand, -primary => 'gene', -tag => { locus_tag => "$geneId"});
        $seq_obj->add_SeqFeature($gene2);

        # Extracts exon information from the $GeneStructure
        # variable, which contains information from the database.
        my @exons2;
        if ($GeneStructure =~ /,/) {
            @exons2 = split (/,/,$GeneStructure);
        } else {
            $exons2[0] = $GeneStructure;
        }

        my $splitlocation = new Bio::Location::Split();
        my $exon2;
        foreach $exon2 (@exons2) {
            # Removes extra details from the items in @exons
            # so that all that is left is ####..####, where
            # each pair of ####'s indicate the starting and ending
            # postions of each particular exon.
            $exon2 =~ s/&lt;//;
            $exon2 =~ s/&gt;//;
            $exon2 =~ s/(\w+\()+//;
            $exon2 =~ s/\)+$//;
            # Describes the structure of the mRNA.
            if ($exon2 =~ /(\d+)\.\.(\d+)/) {
                my $start = $1 - $L_pos + 1;
                my $end = $2 - $L_pos + 1;
                $splitlocation->add_sub_Location(new Bio::Location::Simple(-start => $start, -end => $end, -strand => $strand));
            }
        }

        my ($min,$max);
        # Assign to $min the smaller of $CDSStart
        # and $CDSStop, and assign to $max the larger.
        if ($strand == 1) {
            $min = $CDSStart;
            $max = $CDSStop;
        } else {
            $min = $CDSStop;
            $max = $CDSStart;
        }

        # Creates CDS feature.
	my $flag = 0;
        my $splitlocationCDS = new Bio::Location::Split();
        foreach $exon2 (@exons2) {
            my ($start, $end);
            if ($exon2 =~ /(\d+)\.\.(\d+)/) {
                $start = $1 - $L_pos + 1;
                $end = $2 - $L_pos + 1;
            }
            if (!$flag) {
                # Checks to make sure that the exon from
                # $start to $end is not outside the range
                # of the CDS, or else it will not be added.
                if ($min < $end) {
                    if ($max > $end) {
                        # Condition: the right endpoint of the CDS is located
                        # to the right of the right endpoint of the exon.
                        if ($min >= $start) {
                            # This exon includes the left endpoint
                            # of the CDS, but not the right endpoint.
                            $splitlocationCDS->add_sub_Location(new Bio::Location::Simple(-start => $min, -end => $end, -strand => $strand));
                        } else {
                            # This exon includes neither endpoint of
                            # the CDS, but is within the range of the CDS.
                            $splitlocationCDS -> add_sub_Location(new Bio::Location::Simple(-start => $start, -end => $end, -strand => $strand));
                            # print "Continue: Exon contains neither endpt.\n";
                        }
                    } else {
                        # Condition: the right endpoint of the CDS is located
                        # to the left of the right endpoint of the exon.
                        if ($min < $start and $max > $start) {
                            # This exon includes the right endpoint
                            # of the CDS, but not the left endpoint.
                            $splitlocationCDS -> add_sub_Location(new Bio::Location::Simple(-start => $start, -end => $max, -strand => $strand));
                            $flag = 1;
                            # print "Done: Exon contains right endpt.\n";
                        } elsif ($min >= $start) {
                            # This exon includes both endpoints of the CDS.
                            $splitlocationCDS -> add_sub_Location(new Bio::Location::Simple(-start => $min, -end => $max, -strand => $strand));
                            $flag = 1;
                            # print "Done: Exon contains right and left endpts.\n";
                        }
                    }
                }
            }
        }
        # Adds the mRNA and CDS features.
        my $mRNA = new Bio::SeqFeature::Generic (-location => $splitlocation, -strand => $strand, -primary => 'mRNA', -tag => {locus_tag => "$geneId"});
        $seq_obj -> add_SeqFeature($mRNA);
        my $CDS = new Bio::SeqFeature::Generic (-location => $splitlocationCDS, -strand => $strand, -primary => 'CDS', -tag => {locus_tag => "$geneId"});
        $seq_obj -> add_SeqFeature($CDS);
    }
} else {
    # Prints "none found" if there are no yrgate
    # gene models in the region.
    # print "none found\n";
}

print "<html><body>\n";

my $output;
my $tmp;
if (!$ExportType){
$ExportType="GenBank";
}
if ($ExportType eq "GenBank") {
    # Outputs GenBank formatted gene annotations to
    # output file under directory /xGDBvm/tmp/Region/------.gb.
    $output = "/xGDBvm/tmp/$xGDB/" . $xGDB . $id . "-From" . $L_pos . "-To" . $R_pos . ".gbk";
    #system ("rm -rf $output");
    my $io = Bio::SeqIO -> new(-format => 'GenBank', -file => ">$output");
    $io -> write_seq($seq_obj);
} elsif ($ExportType eq "EMBL") {
    # Outputs EMBL formatted gene annotations to
    # output file under directory /xGDBvm/tmp/$xGDB/------.dat
    $output = "/xGDBvm/tmp/$xGDB/" . $xGDB . $id . "-From"  . $L_pos . "-To" . $R_pos . ".dat";
    #system ("rm -rf $output");
    my $io = Bio::SeqIO -> new(-format => 'EMBL', -file => ">$output");
    $io -> write_seq($seq_obj);
} elsif ($ExportType eq "FASTA") {
    # Outputs FASTA formatted gene annotations to
    # output file under directory /xGDBvm/tmp/Region/------.
    $output = "/xGDBvm/tmp/$xGDB/" . $xGDB . $id . "-From" . $L_pos . "-To" . $R_pos . ".fa";
    #system ("rm -rf $output");
    my $io = Bio::SeqIO -> new(-format => 'FASTA', -file => ">$output");
    $io -> write_seq($seq_obj);
} elsif ($ExportType eq "XML") {
    # Outputs TinySeq XML formatted gene annotations to
    # output file under directory /xGDBvm/tmp/Region/------.dtd
    $tmp ="/xGDBvm/tmp/$xGDB/" . $xGDB . $id . "-From" . $L_pos . "-To" . $R_pos . ".gbk";
    $output = "/xGDBvm/tmp/$xGDB/" . $xGDB . $id . "-From" . $L_pos . "-To" . $R_pos . ".xml";
    #system ("rm -rf $tmp");
    #system ("rm -rf $output");
    my $io = Bio::SeqIO -> new(-format => 'GenBank', -file => ">$tmp");
    $io -> write_seq($seq_obj);
    #system ("/xGDBvm/XGDB/cgi-bin/genbank2chaos.pl $tmp >$output");

    # $output = "/xGDBvm/tmp/$xGDB/" . $xGDB . $id . "-From" . $L_pos . "-To" . $R_pos . ".dtd";
    # system ("rm -rf $output");
    # my $io = Bio::SeqIO -> new(-format => 'TinySeq', -file => ">$output");
    # $io -> write_seq($seq_obj);
} elsif ($ExportType eq "GFF") {
	$tmp = "/xGDBvm/tmp/$xGDB/" . $xGDB . $id . "-From" . $L_pos . "-To" . $R_pos . ".gbk";    
	#system ("rm -rf $tmp");
    my $io = Bio::SeqIO -> new(-format => 'GenBank', -file => ">$tmp");
    $io -> write_seq($seq_obj);
	$output = "/xGDBvm/tmp/$xGDB/" . $xGDB . $id . "-From" . $L_pos . "-To" . $R_pos . ".gff";
	system ("gzip $tmp");
	#system ("rm -rf $output");
	system ("/usr/bin/bp_genbank2gff3.pl ${tmp}.gz -o /xGDBvm/tmp/$xGDB/");
}
	
my $URL = $output;
if ($URL =~ /\/xGDBvm(\S+)/){
	$URL=$1;
}
print "<a title=\"Click here to save file or open it with another program\" href=\"/XGDB/cgi-bin/forceDownload.pl?inputFile=$output\"><b>Download</b></a>\n";
open (MYFILE, "<$output");
print "<pre>\n";
while (<MYFILE>) {
    print "$_";
}
print "</pre>\n";
print "</body></html>\n";

close MYFILE;

# Retrieves a pre-defined segment of a specific
# nucleotide sequence. This information is needed
# for the GenBank format, but is not provided in
# the PlantGDB database.
sub GetQuerySeqs {
    my ($DBpath,$id,$L_pos,$R_pos) = @_;
	my $DB = $DBpath.$xGDB.'gdna.fa';
	my $range="$L_pos"."-"."$R_pos";
	 my $seq = qx(/usr/local/bin/blastdbcmd -db $DB -entry $id -range $range);
    my @list = split(/\n/,$seq);
    shift(@list);
    $seq = join('',@list);
    return $seq;
}

# This subroutine expects a commented description
# block at the beginning of the script. It will
# display all text beginning from a "Purpose:" tag
# to the next line matching the /^##/regexp.
# Script name references may be made using "$0"
# to eliminate the need to update the description
# block everytime the script name changes.
sub usage {
    my $me = $0;
    $me =~ s/.*\///g;

    open (ME, "$0");
    my $inUsage;

    while (<ME>) {
        $inUsage = 1 if (/^# *Purpose:/i);
        if ($inUsage) {
            last if /^##/;
            s/\$0/$me/;
            s/^# ?//g;
            print STDERR;
        }
    }
    close (ME);
    exit (1);
}

