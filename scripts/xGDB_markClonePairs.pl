#!/usr/bin/perl -w
use DBI;

%flags = @ARGV;

$TABLE   = "est";
$GSQTABLE= "gseg_est_good_pgs";
$DB_NAME = "xGDBtmp";
$HOST    = "localhost";
$DB_USER = "BGlab";
$DB_PASS = "";

if(exists $flags{"-T"}){
  $TABLE = $flags{"-T"};
}
if(exists $flags{"--Table"}){
  $TABLE = $flags{"--Table"};
}
if(exists $flags{"-G"}){
  $GSQTABLE = $flags{"-G"};
}
if(exists $flags{"--GSQTable"}){
  $GSQTABLE = $flags{"--GSQTable"};
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
my %attr = (PrintError=>0,RaiseError=>1);
my $dbh = DBI->connect($dsn,$user,$pass,\%attr);

print STDERR "$dsn\n$TABLE\n$GSQTABLE\n$user\n$pass\n";


my $GENEGAP = 6000;


my $FPC_hr = $dbh->selectall_hashref("SELECT clone,gi from $TABLE where (clone != '')&&(type = 'F') ORDER BY clone,length(seq)",'clone',{FetchHashKeyName=>'NAME_lc'});
my $TPC_hr = $dbh->selectall_hashref("SELECT clone,gi from $TABLE where (clone != '')&&(type = 'T') ORDER BY clone,length(seq)",'clone',{FetchHashKeyName=>'NAME_lc'});

foreach $clone (keys %{$TPC_hr}){
  if(exists($FPC_hr->{$clone})){
    if(@res = &markpairs($clone,$FPC_hr->{$clone}{gi},$TPC_hr->{$clone}{gi})){
      for(my $x=0; $x <= $#res; $x++){
	print "$res[$x];\n" if(exists($flags{"--stdout"}));
	$dbh->do($res[$x]) if(exists($flags{"--loadDB"}));
      }
    }
  }
}

$dbh->disconnect();



############################3
sub markpairs{
  my ($clone,$FPgi,$TPgi) = @_;
  
  my($r,$r2,$x,$y,$i,$j,$ref,$ref2,$sqlCMD,@pair53,@SQL);
	if ($GSQTABLE =~ /gseg/){
  $ref  = $dbh->selectall_arrayref("select uid,sim,cov,gseg_gi,l_pos,r_pos,isCognate from $GSQTABLE where gi = $FPgi");
  $ref2 = $dbh->selectall_arrayref("select uid,sim,cov,gseg_gi,l_pos,r_pos,isCognate from $GSQTABLE where gi = $TPgi");
	}else{
$ref  = $dbh->selectall_arrayref("select uid,sim,cov,chr,l_pos,r_pos,isCognate from $GSQTABLE where gi = $FPgi");
  $ref2 = $dbh->selectall_arrayref("select uid,sim,cov,chr,l_pos,r_pos,isCognate from $GSQTABLE where gi = $TPgi");
	}
  $r=(!defined($ref) ? 0 : scalar (@{$ref}));
  $r2=(!defined($ref2) ? 0 : scalar (@{$ref2}));
  for($i=0;$i<$r;$i++){
    for($j=0;$j<$r2;$j++){
      if((${$ref->[$i]}[3] eq ${$ref2->[$j]}[3]) && ((max(${$ref->[$i]}[4],${$ref2->[$j]}[4]) - min(${$ref->[$i]}[5],${$ref2->[$j]}[5])) <= $GENEGAP) && (${$ref->[$i]}[6] eq ${$ref2->[$j]}[6])){
        $pair53[$i][$j] = max(${$ref->[$i]}[4],${$ref2->[$j]}[4]) - min(${$ref->[$i]}[5],${$ref2->[$j]}[5]);
      }else{
        $pair53[$i][$j] = ($GENEGAP+10);
      }
    }
  }
  for($i=0;$i<$r;$i++){
    $x = $GENEGAP+1;
    $y = -10;
    for($j=0;$j<$r2;$j++){
      if($pair53[$i][$j] < $x){
	$x = $pair53[$i][$j];
	$y = $j;
      }
    }
    if($x != ($GENEGAP+1)){
      for($j=0;$j<$r;$j++){
	if($pair53[$j][$y] < $x){
	  #there is a better pair using the same 3' alignment
	  $y = -10;
	  last;
	}
      }
      if($y != -10){
	# we've got a pair
	push(@SQL,"UPDATE $GSQTABLE SET pairUID=\"${clone}:" . $ref2->[$y]->[0] . "\" where uid=" . $ref->[$i]->[0],
		"UPDATE $GSQTABLE SET pairUID=\"${clone}:"  . $ref->[$i]->[0] . "\" where uid=" . $ref2->[$y]->[0]);
	
      }
    }
  }
  return (@SQL);
}

sub max{
  my($p1,$p2)=@_;
  return ($p1 > $p2)?$p1:$p2;
} 

sub min{
  my($p1,$p2)=@_;
  return ($p1 < $p2)?$p1:$p2;
}
