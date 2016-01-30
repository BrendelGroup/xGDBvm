#!/usr/bin/perl

format AlignBlock =
@<<<<<<<<<< @<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< @>>>>>>>>>>
$name,$buf,$cnt
.

use GSQDB;
use CGI ":all";
use DBI;


## GLOBAL VALUES
do 'SITEDEF.pl';

$~ = AlignBlock;

$script = url();
($script) = ($script =~ /(http.*)/);


$frame = path_info();
$frame =~ s\^/\\;

($dbid       = param('dbid')) || ($dbid = $#DB);
($chromosome = param('CHR')) || ($chromosome = 1);
($start      = param('LFT')) || ($start = 1258400);
($end        = param('RGT')) || ($end = 1261500);
if($start > $end){($start,$end) = ($end,$start);}

($centerREG  = param('CENTER')) || ($centerREG = ($start==1258400)?1259200:$start);
($contig     = param('CTG')) || ($contig = "chr_${chromosome}_${start}_${end}");
#($view       = param('VIEW')) || ($frame = 0);
$GBKtrans    = param('TRAN');
$contigHTML  = CGI->escape($contig);

# TEST Parameters
#$chromosome = 4;
#$start = 4740000;
#$end   = 4742500;
#$GBKtrans   = "17694";



## connect to DB
my $dsn = "DBI:mysql:$DB[$dbid]:$DB_HOST";
my $user = $DB_USER;
my $pass = $DB_PASSWORD;
my %attr = (PrintError=>0,RaiseError=>0);
my $dbh = DBI->connect($dsn,$user,$pass,\%attr);
my ($sequence,$descriptions,$Tseq,$GBKid,$Tstart,$Tort)= GetGenomeSeq($dbh);
my $QarrayRef = GetQuerySeqs($dbh);
$dbh->disconnect();


while(length($sequence) > 0){
  $buf = substr($sequence,0,60);
  substr($sequence,0,60) = '';
  $cnt = $buf =~ tr/[ATCGN]//;
  $buf =~ s/(.{10})/$1 /g;
  $name = "AtCHR${chromosome}";
  $start += $cnt;
  $cnt  = $start - 1;
  write;
  if($GBKtrans){
    $buf = substr($Tseq,0,60);
    substr($Tseq,0,60) = '';
    if($buf =~ /\S/){
      $cnt = $buf =~ tr/[ATCGN]//;
      $buf =~ s/(.{10})/$1 /g;
      $name = $GBKid;
      $Tstart += $cnt * $Tort;
      $cnt  = $Tstart - $Tort;
      write;
    }
  }
  for($x=0;$x<=$#$QarrayRef;$x++){
    $buf = substr($QarrayRef->[$x]->[1],0,60);
    substr($QarrayRef->[$x]->[1],0,60)='';
    if($buf =~ /\S/){
      $cnt = $buf =~ tr/[ATCGN]//;
      $buf =~ s/(.{10})/$1 /g;
      $name = $QarrayRef->[$x]->[0];
      $QarrayRef->[$x]->[2] += $cnt * $QarrayRef->[$x]->[3];
      $cnt = $QarrayRef->[$x]->[2] - $QarrayRef->[$x]->[3];
      write;
    }
  }
  print "\n";
}

sub max{ return (($_[0] > $_[1])?$_[0]:$_[1]);}
sub min{ return (($_[0] < $_[1])?$_[0]:$_[1]);}

sub abs_numerically{
  my($n1,$n2) = ($a,$b);
  $n1 = ($n1>0)? $n1 : -$n1;
  $n2 = ($n2>0)? $n2 : -$n2;
  return $n1<=>$n2;
}

sub REVCOMP{
  my($seq) = @_;
  my(@tmpSeq);
  @tmpSeq = split(//,$seq);
  @tmpSeq = reverse(@tmpSeq);
  $seq = join("",@tmpSeq);
  $seq =~ tr/a-z/A-Z/;
  $seq =~ tr/ACTG/TGAC/;
  return $seq;
}

sub GetGenomeSeq{
  my($dbh) = @_;
  my($seq,$desc,$sth,$x,@ary,@Lgaps,@qDESC,@qNAME);
  my($GBKid,$GBKinfo,$Tseq,$ORT,$structINFO,@stINFO);

  ## Hardcoded chromosome sequence start file positions##
  ## the hash table %genomeST can be found in SITEDEF.pl

  open(SR,$LIBRARY_SEQUENCE_REPOSITORY_FILE[$dbid]) || return undef;
  seek(SR,($genomeST[$dbid]->{$chromosome} + min($start,$end)-1),0);
  read(SR,$seq,(max($end,$start)-min($end,$start))+1);
  close(SR);

  if($GBKtrans){
    ($GBKid,$GBKinfo) = GetTRANSinfo($GBKtrans);
    if($GBKinfo =~ /^([cj]).*\(<*([0-9\.,<>]+)/){
      ($ORT,$structINFO) = ($1,$2);
    }else{
      ($structINFO) = $GBKinfo =~ /<*([0-9\.,<>]+)/;
    }
    $structINFO =~ s/[\.,<>]+/ /g;
    @stINFO = split(/\s+/,$structINFO);
    $Tseq = " " x ($stINFO[0] - $start);
    my $j=0;
    for($j=0;$j<=$#stINFO;$j+=2){
      $Tseq .= substr($seq,($stINFO[$j] - $start),($stINFO[$j+1] - $stINFO[$j] + 1));
      if($j+2 < $#stINFO){
	$Tseq .= "." x ($stINFO[$j+2] - $stINFO[$j+1] - 1);
      }
    }
  }


  # Query for EST alignment information given libSeq and Region bounds
  $sth = $dbh->prepare("select a.Lgaps,e.description,e.gi from matches as m,alignments as a,sequences as s,est as e where (m.alignID = a.alignID)&&(s.seqID = m.queryID)&&(e.gi = s.name)&&(m.type = \"C\")&&(m.score1 >= 0.8)&&(m.score2 >= 0.8)&&(m.libID=${chromosome})&&(least(m.start,m.stop) >= $start)&&(greatest(m.start,m.stop) <= $end)");
  $sth->execute();
  $x=0;
  while(@ary = $sth->fetchrow_array()){
      $Lgaps[$x] = $ary[0];
      $qDESC[$x] = $ary[1];
      $qNAME[$x] = $ary[2];
      $x++;
  }

  ## combine all alignment induced gaps for the library sequence
  my($rec,%Lgaps_QS,%Lgaps_all,$gapStart);
  foreach $rec (@Lgaps){
      %Lgaps_QS = split(/:/,$rec);
      foreach $gapStart (keys %Lgaps_QS){
	  if(! exists($Lgaps_all{$gapStart})){
	      $Lgaps_all{$gapStart} = $Lgaps_QS{$gapStart};
	  }elsif($Lgaps_QS{$gapStart} > $Lgaps_all{$gapStart}){
	      $Lgaps_all{$gapStart} = $Lgaps_QS{$gapStart};
	  }
      }
  }

  ## produce combined-gap library sequence
  foreach $gapStart (reverse sort abs_numerically keys %Lgaps_all){
    substr($seq,($gapStart - $start)+1,0) = "-" x $Lgaps_all{$gapStart};
    if($GBKtrans){
      if($gapStart <= $stINFO[$#stINFO]){
	if(substr($Tseq,($gapStart - $start)+1,1) ne "."){
	  if($gapStart <= $stINFO[0]){
	    substr($Tseq,($gapStart - $start)+1,0) = " " x $Lgaps_all{$gapStart};
	  }else{
	    substr($Tseq,($gapStart - $start)+1,0) = "-" x $Lgaps_all{$gapStart};
	  }
	}
      }
    }
  }

  ## Add intron indicators for transcript sequence
  if($GBKtrans){
    if($ORT eq "c"){
      $Tseq =~ s/\./</g;
      $Tort = -1;
      $Tstart = $Tseq =~ tr/[ATCGN]//;
    }else{
      $Tseq =~ s/\./>/g;
      $Tort = 1;
      $Tstart = 1;
    }
  }

  $desc = "";
  for($x=0;$x<=$#qNAME;$x++){
      $desc .= "var gi$qNAME[$x] = \"       >>>>>    $qDESC[$x]\";\n";
  }

  return ($seq,$desc,$Tseq,$GBKid,$Tstart,$Tort);
}

sub GetTRANSinfo{
  my($seqUID) = @_;
  my $uidQuery=qq{
		select m.geneId,m.gene_structure
		from chr_gene_annotation as m
		where m.uid=$seqUID
	       };

  my $db  = new GSQDB();
  $ref = $db->query($dbid,$uidQuery);
  return @{$ref->[0]};
}

sub GetQuerySeqs{
  my($dbh) = @_;

  my(@tmp,@Gtmp,$seq,$sth,$x,$ary_ref);
  $sth = $dbh->prepare("select m.Qstart,m.Qstop,m.start,m.stop,a.Lgaps,a.Qgaps,s.name,m.Qont,e.seq from matches as m,alignments as a,sequences as s,est as e where (m.type = \"C\")&&(m.libID=${chromosome})&&(m.alignID = a.alignID)&&(s.seqID = m.queryID)&&(e.gi = s.name)&&(m.score1 >= 0.8)&&(m.score2 >= 0.8)&&(least(m.start,m.stop) >= $start)&&(greatest(m.start,m.stop) <= $end)");
  $sth->execute();
  $x=0;

  my(@QStart,@QStop,@LQstart,@LQend,@Lgaps,@Qgaps,@Qname,$Qont,@Qseq);
  while($ary_ref = $sth->fetchrow_arrayref()){
    ($QStart[$x],$QStop[$x],$LQstart[$x],$LQend[$x],$Lgaps[$x],$Qgaps[$x],$Qname[$x],$Qont,$Qseq[$x]) = @$ary_ref;
    if($Qont eq "-"){
      $Qseq[$x] = REVCOMP($Qseq[$x]);
    }
    $Qseq[$x] = substr($Qseq[$x],(min($QStart[$x],$QStop[$x])-1),(max($QStart[$x],$QStop[$x]) - min($QStart[$x],$QStop[$x]) + 1));
    $x++;
  }

  ## DO IT AGAIN FOR CDNA 
  $sth = $dbh->prepare("select m.Qstart,m.Qstop,m.start,m.stop,a.Lgaps,a.Qgaps,s.name,m.Qont,e.seq from matches as m,alignments as a,sequences as s,cdna as e where (m.type = \"C\")&&(m.libID=${chromosome})&&(m.alignID = a.alignID)&&(s.seqID = m.queryID)&&(e.gi = s.name)&&(m.score1 >= 0.8)&&(m.score2 >= 0.8)&&(least(m.start,m.stop) >= $start)&&(greatest(m.start,m.stop) <= $end)");
  $sth->execute();

  while($ary_ref = $sth->fetchrow_arrayref()){
    ($QStart[$x],$QStop[$x],$LQstart[$x],$LQend[$x],$Lgaps[$x],$Qgaps[$x],$Qname[$x],$Qont,$Qseq[$x]) = @$ary_ref;
    if($Qont eq "-"){
      $Qseq[$x] = REVCOMP($Qseq[$x]);
    }
    $Qseq[$x] = substr($Qseq[$x],(min($QStart[$x],$QStop[$x])-1),(max($QStart[$x],$QStop[$x]) - min($QStart[$x],$QStop[$x]) + 1));
    $x++;
  }


  ## combine all alignment induced gaps for the library sequence
  my($rec,%Lgaps_QS,%Lgaps_all,$gapStart);
  foreach $rec (@Lgaps){
    %Lgaps_QS = split(/:/,$rec);
    foreach $gapStart (keys %Lgaps_QS){
      if(! exists($Lgaps_all{$gapStart})){
        $Lgaps_all{$gapStart} = $Lgaps_QS{$gapStart};
      }elsif($Lgaps_QS{$gapStart} > $Lgaps_all{$gapStart}){
        $Lgaps_all{$gapStart} = $Lgaps_QS{$gapStart};
      }
    }
  }

  ## produce combined-gap library sequence
  if(open(SR,$LIBRARY_SEQUENCE_REPOSITORY_FILE[$dbid])){
    seek(SR,($genomeST[$dbid]->{$chromosome} + min($start,$end)-1),0);
    read(SR,$seq,(max($end,$start)-min($end,$start))+1);
    close(SR);
    foreach $gapStart (reverse sort abs_numerically keys %Lgaps_all){
      substr($seq,($gapStart - $start)+1,0) = "-" x $Lgaps_all{$gapStart};
    }
    @Gtmp = split("",$seq);
  }else{
    undef($seq);
  }

  ## Postion annotate genome gap starts
  my(%GStart);
  my $PreGaps = 0;
  foreach $gapStart (sort abs_numerically keys %Lgaps_all){
    $GStart{$gapStart} = $gapStart + $PreGaps;
    $PreGaps += $Lgaps_all{$gapStart};
  }

  ## Produce combined-gap query sequence
  my(@results,%Qgaps,$add,$offset,$Qlength,$intronSYMBOL);
  for($x=0;$x<=$#Qseq;$x++){
    %Qgaps = split(/:/,$Qgaps[$x]);
    %Lgaps_QS = split(/:/,$Lgaps[$x]);
    foreach $gapStart (reverse sort abs_numerically keys %Qgaps){
      if($gapStart > 0){ #true gaps are >0 introns are <0
        substr($Qseq[$x],($gapStart - $QStart[$x])+1,0) = "-" x $Qgaps{$gapStart};
      }else{
        substr($Qseq[$x],((-$gapStart) - $QStart[$x])+1,0) = "." x $Qgaps{$gapStart};
      }
    }
    $Qseq[$x] =~ tr/a-z/A-Z/;

    ## deal with reverse complement for crick strand
    if($LQstart[$x] > $LQend[$x]){
      $Qseq[$x] = REVCOMP($Qseq[$x]);
    }

    ## add padding to the left of sequence if needed
    $add = (min($LQstart[$x],$LQend[$x]) - $start);
    foreach (sort abs_numerically keys %Lgaps_all){
      if($_ <= min($LQstart[$x],$LQend[$x])){
        $add += $Lgaps_all{$_};
      }else{
        last;
      }
    }
    if($add){ 
      substr($Qseq[$x],0,0) = " " x $add;
      $offset = $add;
    }else{ $offset = 0; }

    ## add library gaps from other sequences into query
    foreach $gapStart (sort abs_numerically keys %Lgaps_all){
      if($gapStart > min($LQstart[$x],$LQend[$x])){
        if($gapStart < max($LQstart[$x],$LQend[$x])){
	  if(! exists $Lgaps_QS{$gapStart}){
	    substr($Qseq[$x],$GStart{$gapStart} - $start + 1,0) = "-" x $Lgaps_all{$gapStart};
	  }elsif($add = $Lgaps_all{$gapStart} - $Lgaps_QS{$gapStart}){
	    substr($Qseq[$x],($GStart{$gapStart} - $start + 1 + ($Lgaps_all{$gapStart} - $add)),0) = "-" x $add;
	  }
        }else{
	  last;
        }
      }
    }

    ## Calculate sequence length
    @tmp = split("",$Qseq[$x]);
    $Qlength = scalar(@tmp);


    ## colorize differences bettween genome and query sequences
#    if(defined $seq){
#      for($z=$#tmp;$z>=0;$z--){
#	if($tmp[$z] eq "."){
#	  next;
#	}elsif($tmp[$z] eq " "){
#	  last;
#	}elsif($tmp[$z] ne $Gtmp[$z]){
#	  substr($Qseq[$x],$z,1) = "<FONT color='#FF0000'>$tmp[$z]</FONT>";
#	}
#      }
#    }

    ## alter how introns appear in html
    $intronSYMBOL = ($LQstart[$x] < $LQend[$x]) ? ">":"<";
    $Qseq[$x] =~ s/\./$intronSYMBOL/g;

    ## sending starting position and orientation
    $offset = ($LQstart[$x] < $LQend[$x])? $QStart[$x]:$QStop[$x];
    $ORT = ($LQstart[$x] > $LQend[$x])?-1:1;

    push(@results,[$Qname[$x],$Qseq[$x],$offset,$ORT]);
  }
   
  return \@results;
}

sub GetQueryStats{
  my($dbh) = @_;

  my($desc,$sth,$sth2,$ary_ref,$ary_ref2);
  $desc="";
  $sth = $dbh->prepare("select m.alignID,s.name,m.score1,m.score2,m.start,m.stop from matches as m,sequences as s where (s.seqID = m.queryID)&&(m.libID=${chromosome})&&(m.type = \"C\")&&(m.score1 > 0.8)&&(m.score2 > 0.8)&&(least(m.start,m.stop) >= $start)&&(greatest(m.start,m.stop) <= $end)");
  $sth->execute();
  
  my($aid,$gi,$sim,$cov,$lft,$rgt);
  my($Enum,$Els,$Ele,$Eqs,$Eqe,$Eqsim);
  my($Nnum,$Nls,$Nle,$Nd,$Nds,$Na,$Nas,$loci);
  while($ary_ref = $sth->fetchrow_arrayref()){
      ($aid,$gi,$sim,$cov,$lft,$rgt) = @$ary_ref;
      $sim = sprintf("% .3f",$sim);
      $cov = sprintf("% .3f",$cov);
      $desc .= "var SIM$gi = $sim;\nvar COV$gi = $cov;\nvar START$gi = $lft;\nvar END$gi = $rgt;\n";
      
      $sth2 = $dbh->prepare("select num,Lstart,Lstop,Qstart,Qstop,score from exons where alignID = $aid");
      $sth2->execute();
      while($ary_ref2 = $sth2->fetchrow_arrayref()){
	  ($Enum,$Els,$Ele,$Eqs,$Eqe,$Eqsim) = @$ary_ref2;
	  $desc .= "var GS${gi}X$Enum = $Els;\nvar GE${gi}X$Enum = $Ele;\nvar QS${gi}X$Enum = $Eqs;\nvar QE${gi}X$Enum = $Eqe;\nvar QSim${gi}X$Enum = $Eqsim;\n";
      }
      
      $sth2 = $dbh->prepare("select num,Lstart,Lstop,Dscore,Dsim,Ascore,Asim from introns where alignID = $aid"); 
#      $sth2 = $dbh->prepare("select num,Lstart,Lstop,Dscore,Ascore from introns where alignID = $aid");

      $sth2->execute();
      while($ary_ref2 = $sth2->fetchrow_arrayref()){
	  ($Nnum,$Nls,$Nle,$Nd,$Nds,$Na,$Nas) = @$ary_ref2;
#	  ($Nnum,$Nls,$Nle,$Nd,$Na) = @$ary_ref2; $Nds=0.0; $Nas=0.0;
	  $desc .= "var GS${gi}N$Nnum = $Nls;\nvar GE${gi}N$Nnum = $Nle;\nvar DScore${gi}N$Nnum = $Nd;\nvar DSim${gi}N$Nnum = $Nds;\nvar AScore${gi}N$Nnum = $Na;\nvar ASim${gi}N$Nnum = $Nas;\n";
      }
      
      $sth2 = $dbh->prepare("select count(*) from matches as m,sequences as s where (s.name = \"$gi\")&&(m.queryID = s.seqID)&&(m.score1 >= 0.8)&&(m.score2 >= 0.8)");
      $sth2->execute();
      while($ary_ref2 = $sth2->fetchrow_arrayref()){
	  ($loci) = @$ary_ref2;
      }
      $desc .= "var ALT${gi} = $loci;\n";
  }

  return $desc;
}


