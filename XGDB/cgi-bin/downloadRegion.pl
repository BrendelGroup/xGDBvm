#!/usr/bin/perl

# use strict;
use CGI ":all";
use CGI ':standard';
use CGI::Carp qw(fatalsToBrowser);

use GSQDB;
use GDBgui;

do 'SITEDEF.pl';
do 'GDBgui.pl';
do 'getPARAM.pl';

use Text::Wrap;

use Bio::Perl;
use Bio::SeqIO;
use DBI;
print header(); # or print "Content-type: text/html\n\n";

my $db = new GSQDB($cgi_paramHR);

# Assigns the user-specified values to variables. Sanitize them too (3/16/15)
# See description of inputs above for more info.
my $xGDB = ( param('xGDB') =~ /^[0-9A-Za-z]*$/ )? param('xGDB'):"xGDB_error";
my $DB = ( param('DB') =~ /^[0-9A-Za-z]*$/ )? param('DB'):"DB_error";
my $id = ( param('id') =~ /^[A-Za-z0-9\_\.\|-]*$/ )? param('id'):"id_error";
my $L_pos = ( param('l_pos') =~ /^[0-9]+$/ )? param('l_pos'):"l_pos_error";
my $R_pos = ( param('r_pos') =~ /^[0-9]+$/ )? param('r_pos'):"r_pos_error";
my $DBpath = ( param('DBpath') =~ /^[A-Za-z0-9\/\_-]*$/ )? param('DBpath'):"DBpath_error"; # directory path.
my $seqType = ( param('type') =~ /^[A-Za-z\(\)\s-]*$/ )? param('type'):"type_error"; # a string describing the sequence type. May have parenthesis, dash, white space

# $L_pos must be to the left of, or smaller than, $R_pos.
# If it is not, then an error message is displayed.
if ($L_pos >= $R_pos) {
    print "Error: The value of the leftmost position, $L_pos, must be smaller than the value of the rightmost position, $R_pos.\n";
    exit (1);
}

# Calculates the length, in bp, of the sequence.
my $size = $R_pos - $L_pos + 1;

# Connect to the MySQL server.
# added 3-16-15 Get mysql password
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
my $TABLE ='';

if (!$seqType){
	$seqType="EST";
}

my $noData = 1;
my $noDownload = 0;

# Select needed information from database.
my $output;

$Text::Wrap::columns = 81;
#print STDERR "jjjjjjjjjjjjjjjjjj $xGDB\n";
if ($seqType eq 'EST'){
	my $query = "SELECT a.gi,b.seq from gseg_est_good_pgs as a,est as b where a.gi=b.gi and a.gseg_gi='$id' and a.l_pos>=$L_pos and a.r_pos<=$R_pos";
	$sth = $dbh->prepare($query);
    	$sth->execute();
	$output = "/xGDBvm/tmp/$xGDB/" . $xGDB . $id . "-From" . $L_pos . "-To" . $R_pos . ".est";
	#system ("rm -rf $output");
	open (MYFILE, ">$output") or die("Error");
	while(my @ary = $sth->fetchrow_array()){
		$noData = 0;
		my $ID = $ary[0];
		my $Seq = $ary[1];
		print MYFILE ">$ID\n";
		print MYFILE wrap("","","$Seq");
		print MYFILE "\n";
	}
} elsif ($seqType =~ m/Query-Protein/) {
	my $query = "SELECT a.gi,b.seq from gseg_pep_good_pgs as a,pep as b where a.gi=b.gi and a.gseg_gi='$id' and a.l_pos>=$L_pos and a.r_pos<=$R_pos";
	$sth = $dbh->prepare($query);
	$sth->execute();
	$output = "/xGDBvm/tmp/$xGDB/" . $xGDB . $id . "-From" . $L_pos . "-To" . $R_pos . "." .protein;
	open (MYFILE, ">$output") or die("Error");
	while(my @ary = $sth->fetchrow_array()){
		$noData = 0;
		my $ID = $ary[0];
		my $Seq = $ary[1];
		print MYFILE ">$ID\n";
               	print MYFILE wrap("","","$Seq");
               	print MYFILE "\n";
	}
} elsif ($seqType =~ m/GSEG/) {
	my $query = "SELECT gi,substring(seq,$L_pos,$R_pos) from gseg where gi='$id'";
        $sth = $dbh->prepare($query);
        $sth->execute();
        $output = "/xGDBvm/tmp/$xGDB/" . $xGDB . $id . "-From" . $L_pos . "-To" . $R_pos . "." .gdna;
        open (MYFILE, ">$output") or die("Error");
        while(my @ary = $sth->fetchrow_array()){
                $noData = 0;
                my $ID = $ary[0];
                my $Seq = $ary[1];
                print MYFILE ">$ID\n";
                print MYFILE wrap("","","$Seq");
                print MYFILE "\n";
        }
} elsif ($seqType eq 'cDNA') {
	my $query = "SELECT a.gi,b.seq from gseg_cdna_good_pgs as a,cdna as b where a.gi=b.gi and a.gseg_gi='$id' and a.l_pos>=$L_pos and a.r_pos<=$R_pos";
	$sth = $dbh->prepare($query);
	$sth->execute();
	$output = "/xGDBvm/tmp/$xGDB/" . $xGDB . $id . "-From" . $L_pos . "-To" . $R_pos . ".cdna";
        open (MYFILE, ">$output") or die("Error");
	while(my @ary = $sth->fetchrow_array()){
		$noData = 0;
		my $ID = $ary[0];
		my $Seq = $ary[1];
		print MYFILE ">$ID\n";
                print MYFILE wrap("","","$Seq");
                print MYFILE "\n";
	}
} elsif ($seqType eq 'TSA') {
	my $query = "SELECT a.gi,b.seq from gseg_put_good_pgs as a,put as b where a.gi=b.gi and a.gseg_gi='$id' and a.l_pos>=$L_pos and a.r_pos<=$R_pos";
	$sth = $dbh->prepare($query);
	$sth->execute();
	$output = "/xGDBvm/tmp/$xGDB/" . $xGDB . $id . "-From" . $L_pos . "-To" . $R_pos . ".put";
        open (MYFILE, ">$output") or die("Error");
	while(my @ary = $sth->fetchrow_array()){
		$noData = 0;
		my $ID = $ary[0];
		my $Seq = $ary[1];
                print MYFILE ">$ID\n";
                print MYFILE wrap("","","$Seq");
                print MYFILE "\n";
	}
} elsif ($seqType eq 'Gene Models (mRNA)') {
	my $query = "SELECT geneId,transcript_id,strand,gene_structure from gseg_gene_annotation where gseg_gi='$id' and l_pos>=$L_pos and r_pos<=$R_pos UNION SELECT geneId,transcript_id,strand,gene_structure from gseg_cpgat_gene_annotation where gseg_gi='$id' and l_pos>=$L_pos and r_pos<=$R_pos";                
	$sth = $dbh->prepare($query);
        $sth->execute();
	my (@geneIds,@strands,@geneStructures);
        my @geneModSeqs;
	while (my @ary = $sth -> fetchrow_array()) {
                if ($ary[1] eq "") {
                        push (@geneIds,$ary[0]); #use geneId if transcript_id is blank
                } else {
                        push (@geneIds,$ary[1]);
                }
                push (@strands,$ary[2]);
                push (@geneStructures,$ary[3]);
        }
	$query = "SELECT geneId,strand,gene_structure from user_gene_annotation where dbName='$xGDB' and gseg_gi='$id' and l_pos>=$L_pos and r_pos<=$R_pos and status='ACCEPTED'";
	$sth = $dbh->prepare($query);
        $sth->execute();
	while (my @ary = $sth -> fetchrow_array()) {
                push (@geneIds,$ary[0]);
                push (@strands,$ary[1]);
                push (@geneStructures,$ary[2]);
        }
	for (my $i = 0; $i < $#geneIds+1; $i++) {
                $noData = 0;
                my @exonSeqs;
                my @exons;
                if ($geneStructures[$i] =~ /,/) {
                        @exons = split (/,/,$geneStructures[$i]);
                } else {
                        $exons[0] = $geneStructures[$i];
                }
                my $exon;
                my $count = 0;
                foreach $exon (@exons) {
                        $exon =~ s/&lt;//;
                        $exon =~ s/&gt;//;
                        $exon =~ s/(\w+\()+//;
                        $exon =~ s/\)+$//;
                        my $seq;
                        if ($exon =~ /(\d+)\.\.(\d+)/) {
                                my $start = $1;
                                my $end = $2;
                                $seq = GetQuerySeqs($DBpath,$id,$start,$end,$xGDB);
                        }
                        push (@exonSeqs,$seq);
                }
                my $geneModSeq;
		for (my $j = 0; $j < $#exonSeqs + 1; $j++) {
                        $geneModSeq .= $exonSeqs[$j];
                }
                # If the strand is reversed, must take the reverse
                # complement of the sequence
                if ($strands[$i] eq 'r') {
                        $geneModSeq = reverse($geneModSeq);
                        $geneModSeq =~ tr/ACGTacgt/TGCAtgca/;
                }
                push (@geneModSeqs, $geneModSeq);
        }

        $output = "/xGDBvm/tmp/$xGDB/" . $xGDB . $id . "-From" . $L_pos . "-To" . $R_pos . ".gdna";
        open (MYFILE, ">$output") or die("Error");
	for (my $j = 0; $j < $#geneIds+1; $j++) {
                my $ID = $geneIds[$j];
                my $sequence = $geneModSeqs[$j];
                print MYFILE ">$ID\n";
                print MYFILE wrap("","","$sequence");
                print MYFILE "\n";
        }
} elsif ($seqType eq 'Gene Models (Protein)') {
	my $query = "SELECT gseg_gi,geneId,transcript_id,strand,l_pos,r_pos,CDSstart,CDSstop,gene_structure from gseg_gene_annotation where gseg_gi='$id' and l_pos>=$L_pos and r_pos<=$R_pos UNION SELECT gseg_gi,geneId,transcript_id,strand,l_pos,r_pos,CDSstart,CDSstop,gene_structure from gseg_cpgat_gene_annotation where gseg_gi='$id' and l_pos>=$L_pos and r_pos<=$R_pos";
                $sth = $dbh->prepare($query);
                $sth->execute();
		my (@gis_chrs,@geneIds,@strands,@l_poss,@r_poss,@CDSStarts,@CDSStops,@geneStructures);
        my @geneModSeqs;
		while (my @ary = $sth -> fetchrow_array()) {
                        push (@gis_chrs,$ary[0]);
                        if ($ary[2] eq "") {
                                                push (@geneIds,$ary[1]); #use geneId if transcript_id is blank
                        } else {
                                push (@geneIds,$ary[2]);
                        }
                        push (@strands,$ary[3]);
                        push (@l_poss,$ary[4]);
                        push (@r_poss,$ary[5]);
                        push (@CDSStarts,$ary[6]);
                        push (@CDSStops,$ary[7]);
                        push (@geneStructures,$ary[8]);
        	}
	$query = "SELECT chr,geneId,strand,l_pos,r_pos,CDSstart,CDSstop,gene_structure,status from user_gene_annotation where dbName='$xGDB' and gseg_gi='$id' and l_pos>=$L_pos and r_pos<=$R_pos and status='ACCEPTED'";
	$sth = $dbh->prepare($query);
        $sth->execute();
	while (my @ary = $sth -> fetchrow_array()) {
                        push (@gis_chrs,$ary[0]);
                        push (@geneIds,$ary[1]);
                        push (@strands,$ary[2]);
                        push (@l_poss,$ary[3]);
                        push (@r_poss,$ary[4]);
                        push (@CDSStarts,$ary[5]);
                        push (@CDSStops,$ary[6]);
                        push (@geneStructures,$ary[7]);
        }
	for (my $a = 0; $a < $#geneIds+1; $a++) {
                $noData = 0;
                my @exonSeqs;
                my @exons;
                if ($geneStructures[$a] =~ /,/) {
                        @exons = split (/,/,$geneStructures[$a]);
                } else {
                        $exons[0] = $geneStructures[$a];
                }
                my $exon;
                my $count = 0;
                foreach $exon (@exons) {
                        $exon =~ s/&lt;//;
                        $exon =~ s/&gt;//;
                        $exon =~ s/(\w+\()+//;
                        $exon =~ s/\)+$//;
                }
		# Assign to $min the smaller of $CDSStart
                # and $CDSStop, and assign to $max the larger.
                my ($min, $max);
                if ($strands[$a] eq 'f') {
                        $min = $CDSStarts[$a];
                        $max = $CDSStops[$a];
                } else {
                        $min = $CDSStops[$a];
                        $max = $CDSStarts[$a];
                }

		my $flag = 0;
                foreach $exon (@exons) {
                        my ($start, $end);
                        if ($exon =~ /(\d+)\.\.(\d+)/) {
                                $start = $1;
                                $end = $2;
                        }
                        if (!$flag) {
                                if ($min <= $end) {
                                        if ($max > $end) {
                                                # Condition: the right endpt of the CDS is located
                                                # to the right of the right endpt of the exon
                                                if ($min >= $start) {
                                                        # This exon includes the left endpoint
                                                        # of the CDS, but not the right endpoint
                                                        $start = $min;

                                                        # else: This exon includes neither endpoint of
                                                        # the CDS, but is within the range of the CDS.
                                                        # So, do nothing.
                                                } elsif ($min == $end) {
                                                        $start = $end;
                                                }
                                        } else {
                                                # Condition: the right endpt of the CDS is located
                                                # to the left of the right endpoint of the exon
                                                if ($min < $start and $max >= $start) {
                                                        # This exon includes the right endpt
                                                        # of the CDS, but not the left endpt
                                                        $end = $max;
                                                        $flag = 1;
                                                } elsif ($min >= $start) {
                                                        # This exon includes both endpoints of the CDS
                                                        $start = $min;
                                                        $end = $max;
                                                        $flag = 1;
                                                }
                                        }
                                my $seq = GetQuerySeqs($DBpath,$id,$start,$end,$xGDB);
                                push (@exonSeqs,$seq);
                                }
                        }
                }
                my $geneModSeq;
		for (my $i = 0; $i < $#exonSeqs + 1; $i++) {
                        $geneModSeq .= $exonSeqs[$i];
                }
                # If the strand is reversed, must take the reverse
                # complement of the sequence
                if ($strands[$a] eq 'r') {
                        $geneModSeq = reverse($geneModSeq);
                        $geneModSeq =~ tr/ACGTacgt/TGCAtgca/;
                }
                        push (@geneModSeqs, $geneModSeq);
                        $num++;
        }

        $output = "/xGDBvm/tmp/$xGDB/" . $xGDB . $id . "-From" . $L_pos . "-To" . $R_pos . ".pep";
        open (MYFILE, ">$output") or die("Error");
        for (my $i = 0; $i < $num; $i++) {
                        my $ID = $geneIds[$i];
                        my $proteinSeq = Bio::Perl::translate_as_string($geneModSeqs[$i]);
                        print MYFILE ">$ID\n";
                        print MYFILE wrap("","","$proteinSeq");
                        print MYFILE "\n";
	}	
} else {
	$output = "/xGDBvm/tmp/$xGDB/" . $xGDB . $id . "-From" . $L_pos . "-To" . $R_pos . ".fa"; 
	open (MYFILE, ">$output") or die("Error");
	$noData = 1;
	#do nothing
}



if ($noData) {
	$noDownload = 1;
	print MYFILE "$seqType does not exist in the selected region, or incorrect parameters (id=$id, xGDB=$xGDB, L_pos=$L_pos, R_pos=$R_pos, start=$start, end=$end).\n";
	print MYFILE "Please select a different sequence type to view.\n";
}
close (MYFILE);

if (!$noDownload) {
	print "<a title=\"Click here to save file or open it with another program\" href=\"/XGDB/cgi-bin/forceDownload.pl?inputFile=$output\"><b>Download</b></a>\n";
}
open (OUTPUT, "<$output") or die("Error");
print "<pre class=\"normal\">\n";
while (<OUTPUT>) {
	print "$_";
}
print "</pre>\n";
print "</body></html>\n";

close (OUTPUT);

# Retrieves a pre-defined segment of a specific
# nucleotide sequence. This information is needed
# for the GenBank format, but is not provided in
# the PlantGDB database.
sub GetQuerySeqs {
	my ($DBpath,$id,$start,$end,$xGDB) = @_;
	my $DB=$DBpath."$xGDB".gdna.".fa"; # corrected from 'scaffold' on 3/16/15
	my $range="$start"."-"."$end";
	my $cmd="/usr/local/bin/blastdbcmd -db $DB -entry $id -range $range";
	my $seq = qx(/usr/local/bin/blastdbcmd -db $DB -entry $id -range $range);
	#print STDERR "BBBBBBBBBBBBBBBBBBBB $cmd \n";
	my @list = split(/\n/,$seq);
	shift(@list);
	$seq = join('',@list);
	return $seq;
}
