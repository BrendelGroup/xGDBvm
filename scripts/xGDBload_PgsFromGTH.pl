#! /usr/bin/perl

my $USAGE = <<ENDUSAGE;
$0 [-t TableName] [-x cross-reference] GeneSeqer_flatfile_output
:: This script creates insert statements to populate an xGDB PGS 
table given the standard flatfile output of GeneSeqer.
ENDUSAGE

$table = "pep_good_pgs";
my $STD_CUTOFF = 0.6;

for($x=0;$x<=$#ARGV;$x++){
  if($ARGV[$x] eq '-t'){
    $table = $ARGV[$x + 1];
    $x++;
  }elsif($ARGV[$x] eq '-x'){
    $XREF = $ARGV[$x + 1];
    $x++;
  }elsif($ARGV[$x] eq '-sc'){
    $STD_CUTOFF = $ARGV[$x + 1];
    $x++;
  }elsif($ARGV[$x] eq '-pc'){
    $CUTOFF = $ARGV[$x + 1];
    $x++;
  }else{
    push(@GSQfiles,$ARGV[$x]);
  }
}

if(defined $XREF){
open(INF,$XREF);
while(<INF>){
## locus Acc GI
  if(/(\S+)\s+(\S+)\s+(\S+)/){
    $gsegLOC2GI{$1} = $3;
    $gsegACC2GI{$2} = $3;
  }
}
close(INF);
}

if(scalar(@ARGV) < 1){ die $USAGE; }

foreach $INFILE (@GSQfiles){

$CUR_GSEG='';
$CUR_GSEG_CNT=1;
@exon=();@intron=();@match=();
$preALIGNMENT=1;$inALIGNMENT=0;$alSTAGE=0;
open(INF,$INFILE);
while($_ = <INF>){
 PARSELINE:
  if($inALIGNMENT){
    ## Parse the GeneSeqer sequence alignment
    if((/^\*\*/)||(/^hq/)){
      $preALIGNMENT = 1;$alSTAGE=0;$inALIGNMENT=0;
      goto PARSELINE if(/^hq/);
      PROCESS_MATCH() if((/^\*\*/) && ((($match[0] >= $STD_CUTOFF)&&($match[2] >= $STD_CUTOFF)) || (defined($CUTOFF)&&(($match[0] * $match[2]) >= $CUTOFF))));
      @exon=();@intron=();@match=(); $preALIGNMENT=1;
      next;
    }elsif($alSTAGE == 1){
      if(/^\/\/.*\d+\s+\d+\s+\((\d+).*\)/){
	if($Qintron){ $QintronLength+=$1;}
	else {print "error, check it!\n";}
	$alSTAGE++;
	next;
      }
      if(!(/\w/)){
	$preALIGNMENT = 1;$alSTAGE=0;$inALIGNMENT=0;
	goto PARSELINE if(/^hq/);
	PROCESS_MATCH() if((($match[0] >= $STD_CUTOFF)&&($match[2] >= $STD_CUTOFF)) || (defined($CUTOFF)&&(($match[0] * $match[2]) >= $CUTOFF)));
	@exon=();@intron=();@match=(); $preALIGNMENT=1;
	next;
      }
      ($line,$nextSTART) = /(\D+)\s+(\d+)$/;
      $line =~ s/(.{10})\s/$1/g; ## remove those pesky formating spaces
      $line = substr($line,0,60);
      @lineCHAR = split(//,$line);
      for($x=0;$x<=$#lineCHAR;$x++){
	if($lineCHAR[$x] =~ "-"){
	  if($Lingap){
	    $LgapLength++;
	  }else{
	    $LgapLength = 1;
            $Lingap = 1;
            $LgapSTART = $lCNT;
          }
        }elsif($lineCHAR[$x] =~ /\w/){
          if($Lingap){
            $Lingap=0;
            if($lONT < 0){
	      @LIBgaps = (@LIBgaps,$LgapSTART,$LgapLength);
	    }else{
	      @LIBgaps = (@LIBgaps,$LgapSTART-1,$LgapLength);
	    }
	    $LgapLength=0;
          }
	  $lCNT += $lONT;
        }
      }
      $lCNT = $nextSTART + $lONT;
    }elsif($alSTAGE == $QRYLINE){
      if(/^\/\/.*\d+\s+\d+\s+\((\d+).*\)/){
        if(!$Qintron){
          print "error, check it!\n";}
	$alSTAGE++;
        next;
      }
      ($line,$nextSTART) = /(\D+)\s+(\d+)$/;
      $line =~ s/(.{10})\s/$1/g; ## remove those pesky formating spaces
      $line = substr($line,0,60);
      $line =~ s/\s/:/g; ## colons represent 1st / 3rd codon position in protein alignment files
      @lineCHAR = split(//,$line);
      for($x=0;$x<=$#lineCHAR;$x++){
       	if($lineCHAR[$x] =~ "-"){
	  if($Qintron){## uhoh acceptor site gap
	    if($Qgap_a){
	      $Qgap_aLength++;
	    }else{
	      $Qgap_aLength = 1;
	      $Qgap_a = 1;
	      $Qgap_aSTART = $qCNT+1;
	      $QgapPhase = ($QcodonMarker == 1)?'a':($QcodonMarker == 2)?'b':($QcodonMarker == 0)?'c':'';
	    }
	  }else{
	    if($Qgap){
	      $QgapLength++;
	    }else{
	      $QgapLength = 1;
	      $Qgap = 1;
	      $QgapSTART = $qCNT;
	      $QgapPhase = ($QcodonMarker == 1)?'a':($QcodonMarker == 2)?'b':($QcodonMarker == 0)?'c':'';
	    }
	  }
	  ## The follow assumes that '-' represent indels of amino-acids in the query alignment
	  ##   This should be altered in the future such that indels of single nucleotides/codon positions
	  ##   in the query sequence can be modeled
	  $QcodonMarker = 0; $QgapPhase = '';

        }elsif($lineCHAR[$x] =~ /\./){
	  if($Qintron){
	    $QintronLength++;
	  }else{
	    $QintronLength = 1;
	    $Qintron = 1;
            $QintronSTART = $qCNT;
	    $QintronPhase = ($QcodonMarker == 1)?'a':($QcodonMarker == 2)?'b':($QcodonMarker == 0)?'c':'';
          }

	}elsif($lineCHAR[$x] =~ ":"){
	  $QcodonMarker++;
	}elsif($lineCHAR[$x] =~ /\w/){
          if($Qgap){
	    if($qONT < 0){
	      @QRYgaps = (@QRYgaps,($QgapSTART) . $QgapPhase,$QgapLength);
	    }else{
	      @QRYgaps = (@QRYgaps,($QgapSTART-1) . $QgapPhase,$QgapLength);
	    }
	  }
	  if($Qgap_a){
	    if($qONT < 0){
	      @QRYgaps = (@QRYgaps,($Qgap_aSTART) . $QgapPhase,-($Qgap_aLength));
	    }else{
	      @QRYgaps = (@QRYgaps,($Qgap_aSTART-1) . $QgapPhase,-($Qgap_aLength));
	    }
	  }
	  if($Qintron){
	    if($qONT < 0){
	      @QRYgaps = (@QRYgaps,-($QintronSTART) . $QintronPhase,$QintronLength);
	    }else{
	      @QRYgaps = (@QRYgaps,-($QintronSTART-1) . $QintronPhase,$QintronLength);
	    }
	  }
	  $Qgap = $Qgap_a = 0; $Qintron = 0; $QcodonMarker = 0;
	  $QgapLength = $Qgap_aLength = 0; $QintronLength = 0;
	  $qCNT += $qONT;
        }
      }
      $qCNT = $nextSTART + $qONT;
    }elsif($alSTAGE == ($QRYLINE + 1)){
      $alSTAGE = -1;
    }
    $alSTAGE++;


  }elsif(/hqPGS_\S+\s+\(([^\)]+)/){
    $hqpgs   = $1;

###################################<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
    PROCESS_MATCH() if((($match[0] >= $STD_CUTOFF)&&($match[2] >= $STD_CUTOFF)) ||
                       (defined($CUTOFF)&&(($match[0] * $match[2]) >= $CUTOFF)));
###################################<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
    
    @exon=();@intron=();@match=(); $preALIGNMENT=1;

  }elsif(/^PGS_\S+\s+\(([^\)]+)/){
    $hqpgs   = $1; ## Standard PGS will only be used if no hiqh-quality hq PGS is found

  }elsif(/NOMATCH/){
    @exon=();@intron=();@match=();
    $preALIGNMENT=1;

  }elsif($preALIGNMENT && (/^\s*Exon\s+(\d+)\s+(\d+)\s+(\d+)[^;]+;\s+\S+\s+(\d+)\s+(\d+)[^:]+:\s+([0-9\.-]+)/)){
    $exon[$1-1][0] = $2;
    $exon[$1-1][1] = $3;
    $exon[$1-1][2] = $4;
    $exon[$1-1][3] = $5;
    $exon[$1-1][4] = $6;

  }elsif($preALIGNMENT && (/^\s*Intron\s+(\d+)\s+(\d+)\s+(\d+)[^:]+:\s+(\S+)\s+\(s:\s+([^\)]+)[^:]+:\s+(\S+)\s+\(s:\s+([^\)]+)\)/)){
    ##### Get intron definition from GS alignment WITH splice site similarities!
    $intron[$1-1][0] = $2;
    $intron[$1-1][1] = $3;
    $intron[$1-1][2] = $4;
    $intron[$1-1][3] = $5;
    $intron[$1-1][4] = $6;
    $intron[$1-1][5] = $7;
  
  }elsif($preALIGNMENT && (/^\s*Intron\s+(\d+)\s+(\d+)\s+(\d+)[^:]+:\s+(\S+)[^P]+Pa:\s+(\S+)/)){
    ##### Get intron definition from GS alignment WITHOUT splice site similarities!
    $intron[$1-1][0] = $2;
    $intron[$1-1][1] = $3;
    $intron[$1-1][2] = $4;
    $intron[$1-1][3] = -1;
    $intron[$1-1][4] = $5;
    $intron[$1-1][5] = -1;

  }elsif(/^MATCH\s+(\S+)\s+(\S+)\s+([0-9.]+)\s+(\d+)\s+([0-9.]+)[^PCG]+([PCG])/){
    $gseg = $1;
    $eseq = $2;
    $gsegORT = chop($gseg);
    $eseqORT = chop($eseq);
    $match[0] = $3;
    $match[1] = $4;
    $match[2] = $5;
    $match[3] = $6;
    if($match[3] =~ "P"){ ## P on MATCH line denotes protein alignment
      $QRYLINE = 4;
    }else{
      $QRYLINE = 3;
    }
  }elsif(/^Alignment.*:$/){
    # PROCESS THE ALIGNMENT
    $inALIGNMENT=1;
    @LIBgaps=();@QRYgaps=();
    $lCNT=$exon[0][0];
    $lONT=($lCNT < $exon[$#exon][1])?1:-1;
    $qCNT=$exon[0][2];
    $qONT=($qCNT < $exon[$#exon][3])?1:-1;
    $Lingap=0;$LgapLength=0;
    $Qgap= $Qgap_a = 0; $Qintron = 0; $QcodonMarker = 1;
    $QgapLength = $Qgap_aLength = 0; $QintronLength = 0;
  }

}
close(INF);
}
############ END OF MAIN ############################



sub PROCESS_MATCH {
  
  if($gseg ne $CUR_GSEG){
    print STDERR "Working on GSEG < $INFILE :: $gseg #$CUR_GSEG_CNT >\n";
    $CUR_GSEG = $gseg;
    $CUR_GSEG_CNT++;
  }

  if(exists($gsegACC2GI{$gseg})){
    $gseg_gi = $gsegACC2GI{$gseg};
  }elsif(exists($gsegLOC2GI{$gseg})){
    $gseg_gi = $gsegLOC2GI{$gseg};
  }else{
    $gseg_gi = $gseg;
    #print "WARNING: $gseg used as gseg_gi\n";
  }

  if(!defined($Lgaps = join(":",@LIBgaps))){ $Lgaps = "";}
  if(!defined($Qgaps = join(":",@QRYgaps))){ $Qgaps = "";}
  my $id = ($eseq =~ /^\d+$/)?$eseq:"$eseq";
	if($table =~ /^gseg/){
	#$gseg_gi =~ s/chr//g;
    print("INSERT INTO $table (uid,gi,E_O,sim,mlength,cov,gseg_gi,G_O,l_pos,r_pos,pgs,pgs_lpos,pgs_rpos,gseg_gaps,pgs_gaps) VALUES (0,'$id','$eseqORT',$match[0],$match[1],$match[2],'$gseg_gi','$gsegORT',");
  }else{
	if ($gseg_gi =~ /chrUn/){
		$chr=20;
	}
	if ($gseg_gi =~ /Chr(\d+)$/){
		$chr= $1;
	}
        if ($gseg_gi =~ /MtChr(\d+)$/){
    		$chr=$1;
        }
    print("INSERT INTO $table (uid,gi,E_O,sim,mlength,cov,chr,G_O,l_pos,r_pos,pgs,pgs_lpos,pgs_rpos,gseg_gaps,pgs_gaps) VALUES (0,'$id','$eseqORT',$match[0],$match[1],$match[2],$chr,'$gsegORT',");
  }
  print(min($exon[0][0],$exon[$#exon][1]) . "," . max($exon[0][0],$exon[$#exon][1]) . ",'$hqpgs',",
        min($exon[0][2],$exon[$#exon][3]) . "," . max($exon[0][2],$exon[$#exon][3]) . ",'$Lgaps','$Qgaps');\n");


  $sqlstm = "INSERT INTO ${table}_exons (pgs_uid,num,gseg_start,gseg_stop,pgs_start,pgs_stop,score) VALUES ";
  for($x=0;$x<=$#exon;$x++){     $sqlstm .= "(LAST_INSERT_ID()," . ($x + 1) . ",$exon[$x][0],$exon[$x][1],$exon[$x][2],$exon[$x][3],$exon[$x][4]),";
  }
  chop($sqlstm);
  print "${sqlstm};\n";


  if(scalar(@intron)){     $sqlstm = "INSERT INTO ${table}_introns (pgs_uid,num,gseg_start,gseg_stop,Dscore,Dsim,Ascore,Asim) VALUES ";
    for($x=0;$x<=$#intron;$x++){
      $sqlstm .= "(LAST_INSERT_ID()," . ($x + 1) . ",$intron[$x][0],$intron[$x][1],$intron[$x][2],$intron[$x][3],$intron[$x][4],$intron[$x][5]),";
    }
    chop($sqlstm);
    print "${sqlstm};\n";
  }	
 return 1;
}


sub min {return($_[0]<$_[1])?$_[0]:$_[1];}
sub max {return($_[0]>$_[1])?$_[0]:$_[1];}

