#!/usr/bin/perl
use DBI;
#########################################################################
# This script requires $TABLE to have the following fields:             #
#    << gi, uid, sim, cov, isCognate >>                                 #
#########################################################################

%flags = @ARGV;

$TABLE   = "cdna_good_pgs";
$DB_NAME = "xGDBtmp";
$HOST    = "localhost";
$DB_USER = "sds";
$DB_PASS = "";

if(exists $flags{"-T"}){
  $TABLE = $flags{"-T"};
}
if(exists $flags{"--Table"}){
  $TABLE = $flags{"--Table"};
}
if(exists $flags{"-D"}){
  $DB_NAME = $flags{"-D"};
}
if(exists $flags{"--DataBase"}){
  $DB_NAME = $flags{"--DataBase"};
}
if(exists $flags{"-H"}){
  $HOST = $flags{"-H"};
}
if(exists $flags{"--Host"}){
  $HOST = $flags{"--Host"};
}
if(exists $flags{"-U"}){
  $DB_USER = $flags{"-U"};
}
if(exists $flags{"--User"}){
  $DB_USER = $flags{"--USER"};
}
if(exists $flags{"-P"}){
  $DB_PASS = $flags{"-P"};
}
if(exists $flags{"--Password"}){
  $DB_PASS = $flags{"--Password"};
}

my $dsn = "DBI:mysql:${DB_NAME}:$HOST";
my $user = $DB_USER;
my $pass = $DB_PASS;
my %attr = (PrintError=>0,RaiseError=>0);
my $dbh = DBI->connect($dsn,$user,$pass,\%attr);

my $setupSQL = "UPDATE $TABLE set isCognate='True'";
$dbh->do($setupSQL);
my $giSQL = "SELECT gi from $TABLE group by gi having count(gi) > 1 order by gi";
my $sth = $dbh->prepare($giSQL);
$sth->execute();
my $lociSQL = "SELECT uid,sim,cov from $TABLE where gi = ?";
my $sth2= $dbh->prepare($lociSQL);
my $aref = $sth->fetchall_arrayref();
for(my $i=0;$i<scalar(@{$aref});$i++){
  if(($i % 1000) == 0){
    print STDERR "working on sequence $i of " . scalar(@{$aref}) . "\n";
  }
  %loc = ();
  $ugi = ${$aref->[$i]}[0];
  $high = 0.5;
  $sth2->execute($ugi);
  $qref = $sth2->fetchall_arrayref();
  for($x=0;$x<scalar(@{$qref});$x++){
     $uid = ${$qref->[$x]}[0];
     $sim = ${$qref->[$x]}[1];
     $cov = ${$qref->[$x]}[2];
     $loc{$uid} = $sim * $cov;
     $high=(($sim * $cov) > $high)?($sim * $cov):$high;
  }
  foreach $uid (keys %loc){
    if(($loc{$uid} + 0.015) > $high){
      $cognateSQL = "update $TABLE set isCognate='True' where uid = $uid";
      $dbh->do($cognateSQL);
    }else{
      $cognateSQL = "update $TABLE set isCognate='False' where uid = $uid";
      $dbh->do($cognateSQL);
    }
  }
}

$sth->finish();
$sth2->finish();
$dbh->disconnect();
