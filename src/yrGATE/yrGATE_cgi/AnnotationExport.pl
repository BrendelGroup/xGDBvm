#!/usr/bin/perl

require 'yrGATE_conf.pl';
do 'yrGATE_functions.pl';
#&{$GV->{InitFunction}};

my $amt = param("amt");
my $format = param("format");
my $html = param("html");

$PRM->{USERid} = &{$GV->{getUserIdFunction}};


print header();

# header for file
if ($html){
    print "<html><body><pre>\n";
}
if ($format eq "gff3"){
    print "##gff-version 3\n";
}
my %local_uid;
my $local_uidRef = \%local_uid;
my $txt;

$wherec = ($amt eq "all") ? " and dbName='$GV->{dbTitle}' and status = 'ACCEPTED' " : ($amt eq "user") ? " and USERid = '$PRM->{USERid}' " : " and uid = '$PRM->{uid}' ";
$sql = "select uid from user_gene_annotation where dbName='$GV->{dbTitle}' $wherec order by modDate desc";


$ref = $GV->{ADBH}->selectall_arrayref($sql);
for my $i (@$ref){
$PRM->{uid} = $i->[0];
loadUCA();

if ($PRM->{owner}){ # if returned record, loadUCA checks to see if valid user request
    if ($format eq "gff3"){

      ($txt,$local_uidRef) = yrgateToGFF3($local_uidRef);	
      print $txt."\n";
    }elsif($format eq "fasta"){
      print seqToFASTA(param('seqType'));
    }
}elsif($amt ne "all" and $amt ne "user"){
  print "# You currently do not have permission to access this UCA record! Please try again at a later date.\n";
}


}

if ($html){

print "</pre></body></html>\n";
}


disconnectDB();
