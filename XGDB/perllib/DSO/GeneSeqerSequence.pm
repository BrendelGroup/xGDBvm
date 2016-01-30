package GeneSeqerSequence;

do 'SITEDEF.pl';
use GSQDB;

my %simAA = (
		'I' => {'V'=>'+'},
		'V' => {'I'=>'+'},
		'N' => {'S'=>'+'},
		'S' => {'N'=>'+'}
	    );

my %codon = (   # updated to include ambiguous bases 7-22-14 JPD

         'TCA' => 'S',    # Serine
         'TCC' => 'S',    # Serine
         'TCG' => 'S',    # Serine
         'TCT' => 'S',    # Serine
         'TCY' => 'S',    # Serine (ambiguous base 3)
         'TCR' => 'S',    # Serine (ambiguous base 3)
         'TCW' => 'S',    # Serine (ambiguous base 3)
         'TCS' => 'S',    # Serine (ambiguous base 3)
         'TCM' => 'S',    # Serine (ambiguous base 3)
         'TCK' => 'S',    # Serine (ambiguous base 3)
         'TCN' => 'S',    # Serine (ambiguous base 3)
         'TCX' => 'S',    # Serine (ambiguous base 3)

         'AGC' => 'S',    # Serine
         'AGT' => 'S',    # Serine
         'AGY' => 'S',    # Serine (ambiguous base 3)
         'AGA' => 'R',    # Arginine
         'AGG' => 'R',    # Arginine
         'AGR' => 'R',    # Arginine (ambiguous base 3)


         'TTC' => 'F',    # Phenylalanine
         'TTT' => 'F',    # Phenylalanine
         'TTY' => 'F',    # Phenylalanine (ambiguous base 3) 

         'TTA' => 'L',    # Leucine
         'TTG' => 'L',    # Leucine
         'TTR' => 'L',    # Leucine (ambiguous base 3)

         'TAC' => 'Y',    # Tyrosine
         'TAT' => 'Y',    # Tyrosine
         'TAY' => 'Y',    # Tyrosine (ambiguous base 3)

         'TAA' => '*',    # Stop
         'TAG' => '*',    # Stop
         'TAR' => '*',    # Stop

         '---' => '-',    # In-frame gap
         '...' => '_',    # In-frame gap
         'NNN' => 'X',	 # UNK was: N (error 7/21/14)
         '???' => 'X',    # UNK

         'TGC' => 'C',    # Cysteine
         'TGT' => 'C',    # Cysteine
         'TGY' => 'C',    # Cysteine (ambiguous base 3)

         'TGA' => '*',    # Stop
         'TGG' => 'W',    # Tryptophan
         'CTA' => 'L',    # Leucine
         'CTC' => 'L',    # Leucine
         'CTG' => 'L',    # Leucine
         'CTT' => 'L',    # Leucine
         'CTY' => 'L',    # Leucine (ambiguous base 3)
         'CTR' => 'L',    # Leucine (ambiguous base 3)
         'CTW' => 'L',    # Leucine (ambiguous base 3)
         'CTS' => 'L',    # Leucine (ambiguous base 3)
         'CTK' => 'L',    # Leucine (ambiguous base 3)
         'CTM' => 'L',    # Leucine (ambiguous base 3)
         'CTN' => 'L',    # Leucine (ambiguous base 3)
         'CTX' => 'L',    # Leucine (ambiguous base 3)

         'CCA' => 'P',    # Proline
         'CCC' => 'P',    # Proline
         'CCG' => 'P',    # Proline
         'CCT' => 'P',    # Proline
         'CCY' => 'P',    # Proline (ambiguous base 3)
         'CCR' => 'P',    # Proline (ambiguous base 3)
         'CCW' => 'P',    # Proline (ambiguous base 3)
         'CCS' => 'P',    # Proline (ambiguous base 3)
         'CCM' => 'P',    # Proline (ambiguous base 3)
         'CCK' => 'P',    # Proline (ambiguous base 3)
         'CCN' => 'P',    # Proline (ambiguous base 3)
         'CCX' => 'P',    # Proline (ambiguous base 3)


         'CAC' => 'H',    # Histidine
         'CAT' => 'H',    # Histidine
         'CAY' => 'H',    # Histidine  (ambiguous base 3)

         'CAA' => 'Q',    # Glutamine
         'CAG' => 'Q',    # Glutamine
         'CAR' => 'Q',    # Glutamine (ambiguous base 3)

         'CGA' => 'R',    # Arginine
         'CGC' => 'R',    # Arginine
         'CGG' => 'R',    # Arginine
         'CGT' => 'R',    # Arginine
         'CGY' => 'R',    # Arginine (ambiguous base 3)
         'CGR' => 'R',    # Arginine (ambiguous base 3)
         'CGW' => 'R',    # Arginine (ambiguous base 3)
         'CGS' => 'R',    # Arginine (ambiguous base 3)
         'CGM' => 'R',    # Arginine (ambiguous base 3)
         'CGK' => 'R',    # Arginine (ambiguous base 3)
         'CGN' => 'R',    # Arginine (ambiguous base 3)
         'CGX' => 'R',    # Arginine (ambiguous base 3)

         'ATA' => 'I',    # Isoleucine
         'ATC' => 'I',    # Isoleucine
         'ATT' => 'I',    # Isoleucine
         'ATM' => 'I',    # Isoleucine (ambiguous base 3)
         'ATY' => 'I',    # Isoleucine (ambiguous base 3)
         'ATH' => 'I',    # Isoleucine (ambiguous base 3)
         'ATW' => 'I',    # Isoleucine (ambiguous base 3)

         'ATG' => 'M',    # Methionine
         'ACA' => 'T',    # Threonine
         'ACC' => 'T',    # Threonine
         'ACG' => 'T',    # Threonine
         'ACT' => 'T',    # Threonine
         'ACY' => 'T',    # Threonine (ambiguous base 3)
         'ACR' => 'T',    # Threonine (ambiguous base 3)
         'ACW' => 'T',    # Threonine (ambiguous base 3)
         'ACS' => 'T',    # Threonine (ambiguous base 3)
         'ACK' => 'T',    # Threonine (ambiguous base 3)
         'ACM' => 'T',    # Threonine (ambiguous base 3)
         'ACN' => 'T',    # Threonine (ambiguous base 3)
         'ACX' => 'T',    # Threonine (ambiguous base 3)

         'AAC' => 'N',    # Asparagine
         'AAT' => 'N',    # Asparagine
         'AAY' => 'N',    # Asparagine (ambiguous base 3)

         'AAA' => 'K',    # Lysine
         'AAG' => 'K',    # Lysine
         'AAR' => 'K',    # Lysine (ambiguous base 3)

         'GTA' => 'V',    # Valine
         'GTC' => 'V',    # Valine
         'GTG' => 'V',    # Valine
         'GTT' => 'V',    # Valine
         'GTY' => 'V',    # Valine (ambiguous base 3)
         'GTR' => 'V',    # Valine (ambiguous base 3)
         'GTW' => 'V',    # Valine (ambiguous base 3)
         'GTS' => 'V',    # Valine (ambiguous base 3)
         'GTM' => 'V',    # Valine (ambiguous base 3)
         'GTK' => 'V',    # Valine (ambiguous base 3)
         'GTN' => 'V',    # Valine (ambiguous base 3)
         'GTX' => 'V',    # Valine (ambiguous base 3)

         'GCA' => 'A',    # Alanine
         'GCC' => 'A',    # Alanine
         'GCG' => 'A',    # Alanine
         'GCT' => 'A',    # Alanine
         'GCY' => 'A',    # Alanine (ambiguous base 3)
         'GCR' => 'A',    # Alanine (ambiguous base 3)
         'GCW' => 'A',    # Alanine (ambiguous base 3)
         'GCS' => 'A',    # Alanine (ambiguous base 3)
         'GCK' => 'A',    # Alanine (ambiguous base 3)
         'GCM' => 'A',    # Alanine (ambiguous base 3)
         'GCX' => 'A',    # Alanine (ambiguous base 3)
         'GCN' => 'A',    # Alanine (ambiguous base 3)

         'GAC' => 'D',    # Aspartic Acid
         'GAT' => 'D',    # Aspartic Acid
         'GAY' => 'D',    # Aspartic Acid (ambiguous base 3)

         'GAA' => 'E',    # Glutamic Acid
         'GAG' => 'E',    # Glutamic Acid
         'GAR' => 'E',    # Glutamic Acid (ambiguous base 3)

         'GGA' => 'G',    # Glycine
         'GGC' => 'G',    # Glycine
         'GGG' => 'G',    # Glycine
         'GGT' => 'G',    # Glycine
         'GGY' => 'G',    # Glycine (ambiguous base 3)
         'GGR' => 'G',    # Glycine (ambiguous base 3)
         'GGW' => 'G',    # Glycine (ambiguous base 3)
         'GGS' => 'G',    # Glycine (ambiguous base 3)
         'GGM' => 'G',    # Glycine (ambiguous base 3)
         'GGK' => 'G',    # Glycine (ambiguous base 3)
         'GGN' => 'G',    # Glycine (ambiguous base 3)
         'GGX' => 'G',    # Glycine (ambiguous base 3)


);


sub getGSQ_aSeqs{
  my $self = shift;
  my ($argHR,$lgapsHR,$gapped_gseg) = @_;
  my $atype   = (exists($self->{gsqATYPE}))?$self->{gsqATYPE}:'C';
  my ($uid,$recordHR,$eSeq,$gapSEQ);
  my (%pgsGAPS,%gsegGAPS);
  my (@seqs);

  $self->loadREGION($argHR) if((defined($argHR))&&(!exists($self->{pgsREGION_href})));
  foreach $uid (keys %{$self->{pgsREGION_href}}){
    $recordHR = $self->{pgsREGION_href}{$uid};
    $eSeq = (($recordHR->{e_o} eq '+')||($atype eq 'P'))?$recordHR->{seq}:&_REVCOMP($recordHR->{seq});
    %pgsGAPS = split(':',$recordHR->{pgs_gaps});
    %gsegGAPS = split(':',$recordHR->{gseg_gaps});
    $gappedSEQ = _getGappedExpressedSequence($eSeq,$recordHR->{pgs_lpos},$recordHR->{pgs_rpos},\%pgsGAPS,$atype);
    $gappedSEQ = ($recordHR->{g_o} eq '+')?$gappedSEQ:($atype eq 'P')?reverse($gappedSEQ):&_REVCOMP($gappedSEQ);
    $gappedSEQ =~ s/\s/_/g;
    $offset = $recordHR->{l_pos} - $argHR->{l_pos};
    if($offset > 0){ ## add padding to the left end of sequence
      foreach $gap (sort abs_numerically keys %$lgapsHR){
	if($gap <= $recordHR->{l_pos}){
	  $offset += $lgapsHR->{$gap};
	}else{
	  last;
	}
      }
      substr($gappedSEQ,0,0) = "_" x $offset;
    }else{ ## sequence needs a trim
      $offset *= -1;
      foreach $gap (sort abs_numerically keys %$lgapsHR){
	if($gap < $argHR->{l_pos}){
	  $offset += $lgapsHR->{$gap};
	}else{
	  last;
	}
      }
      substr($gappedSEQ,0,$offset) = '';
      $offset = 0;
    }

    ## index genome gap starts
    $preGaps = 0;
    foreach $gap (sort abs_numerically keys %$lgapsHR){
      $GStart{$gap} = $gap + $preGaps;
      $preGaps += $lgapsHR->{$gap};
    }
    ## add gseg gaps from other seqs into query
    ## lgapsHR only has 'In View' gaps
    foreach $gap (sort abs_numerically keys %$lgapsHR){
      if($gap > $recordHR->{l_pos}){
	if($gap < $recordHR->{r_pos} and  $gappedSEQ ne ""){
	  if(! exists($gsegGAPS{$gap}) ){
	    substr($gappedSEQ,$GStart{$gap} - $argHR->{l_pos} + 1,0) = '-' x $lgapsHR->{$gap};
	  }elsif($add = ($lgapsHR->{$gap} - $gsegGAPS{$gap}) and  $gappedSEQ ne ""){
  	    substr($gappedSEQ,$GStart{$gap} - $argHR->{l_pos} + 1 + ($lgapsHR->{$gap} - $add),0) = '-' x $add;
	  }
	}else{
	  last;
	}
      }
    }
    ## Trim up sequences extending beyond right boundary
    if(length($gapped_gseg) < length($gappedSEQ)){$gappedSEQ = substr($gappedSEQ,0,length($gapped_gseg));}

    ## Uppercase everything
    $gappedSEQ =~ tr/a-z/A-Z/;

    ## Colorize differences between gseg and query
    for($x=length($gappedSEQ);$x>=0;$x--){
      if(substr($gappedSEQ,$x,1) eq ' '){
	last;
      }elsif(substr($gappedSEQ,$x,1) eq '.'){
	next;
      }elsif(substr($gappedSEQ,$x,1) eq '_'){
	$intron_tmp_html = '_';
	substr($gappedSEQ,$x,1) = $intron_tmp_html;
      }elsif(substr($gappedSEQ,$x,1) ne substr($gapped_gseg,$x,1)){
	substr($gappedSEQ,$x,1) = "<font color='red'>" . substr($gappedSEQ,$x,1) . "</font>";
      }
    }

    ## HTMLize introns
    $intronSYMBOL = ($recordHR->{g_o} eq '+')?"&gt;":"&lt;";
    $gappedSEQ =~ s/\./$intronSYMBOL/g;

    push(@seqs,[$self->{resid} . '_' . $uid,$recordHR->{gi},$gappedSEQ,$offset,length($gappedSEQ),$self->{primaryColor}]);
  }
  return \@seqs;
}

sub getGSQ_pgsStats{
  my $self = shift;
  my ($argHR) = @_;
  my ($uid,$recordHR,%pgsSTATS);

  $self->loadREGION($argHR) if((defined($argHR))&&(!exists($self->{pgsREGION_href})));
  if((exists($self->{pgsREGION_href}))&&(keys(%{$self->{pgsREGION_href}}))){
    foreach $uid (keys %{$self->{pgsREGION_href}}){
      $recordHR = $self->{pgsREGION_href}{$uid};
# VB major change:  we are now also retrieving the pgs field
      $pgsSTATS{$self->{resid} . '_' . $uid} = ['gi|' . $recordHR->{gi} . '|gb|' . $recordHR->{acc},$recordHR->{sim},$recordHR->{mlength},$recordHR->{cov},$recordHR->{l_pos},$recordHR->{r_pos},$recordHR->{description},$recordHR->{pgs}];
    }
  }else{return undef; }

  return \%pgsSTATS;
}

sub getGSQ_exStats{
  my $self = shift;
  my ($argHR) = @_;
  my ($uidlist,$statQUERY,$sth,$rowHR,%STATS);

  $self->loadREGION($argHR) if((defined($argHR))&&(!exists($self->{pgsREGION_href})));
  my $gsrc = (exists($argHR->{altCONTEXT}))?($argHR->{altCONTEXT} eq "BAC")?'gseg':($argHR->{altCONTEXT} =~ /chr/i)?'':$argHR->{altCONTEXT} : '';
  if((exists($self->{pgsREGION_href}))&&(keys(%{$self->{pgsREGION_href}}))){
    $uidlist = join(',',keys(%{$self->{pgsREGION_href}}));
    ($statQUERY) = $self->{"${gsrc}gsqPGS_EX_QUERY"} =~ /^(.*)WHERE/s;
    $statQUERY .= "WHERE pgs_uid IN ($uidlist)";
    $sth = $self->{dbh}->prepare($statQUERY);
    $sth->execute();
    while($rowHR = $sth->fetchrow_hashref()){
      $STATS{$self->{resid} . '_' . $rowHR->{pgs_uid} . '_' . $rowHR->{num}} = [@$rowHR{'num','gseg_start','gseg_stop','pgs_start','pgs_stop','score'}];
    }
  }else{return undef;}

  return \%STATS;
}

sub getGSQ_inStats{
  my $self = shift;
  my ($argHR) = @_;
  my ($uidlist,$statQUERY,$sth,$rowHR,%STATS);

  $self->loadREGION($argHR) if((defined($argHR))&&(!exists($self->{pgsREGION_href})));
  my $gsrc = (exists($argHR->{altCONTEXT}))?($argHR->{altCONTEXT} eq "BAC")?'gseg':($argHR->{altCONTEXT} =~ /chr/i)?'':$argHR->{altCONTEXT} : '';

  if((exists($self->{pgsREGION_href}))&&(keys(%{$self->{pgsREGION_href}}))){
    $uidlist = join(',',keys(%{$self->{pgsREGION_href}}));
    ($statQUERY) = $self->{"${gsrc}gsqPGS_IN_QUERY"} =~ /^(.*)WHERE/s;
    $statQUERY .= "WHERE pgs_uid IN ($uidlist)";
    $sth = $self->{dbh}->prepare($statQUERY);
    $sth->execute();
    while($rowHR = $sth->fetchrow_hashref()){
      $STATS{$self->{resid} . '_' . $rowHR->{pgs_uid} . '_' . $rowHR->{num}} = [@$rowHR{'num','gseg_start','gseg_stop','dscore','dsim','ascore','asim'}];
    }
  }else{return undef;}

  return \%STATS;
}

sub combineLGAPS{
  my $self = shift;
  my ($argHR,$lgapsHR) = @_;
  my ($lpos,$rpos,$uid,$recordHR,$gapStart,%lgaps_QS);
  $lpos = $argHR->{l_pos};
  $rpos = $argHR->{r_pos};
  if(exists($self->{pgsREGION_href})){
    foreach $uid (keys %{$self->{pgsREGION_href}}){
      $recordHR = $self->{pgsREGION_href}{$uid};
      %lgaps_QS = split(':',$recordHR->{gseg_gaps});
      foreach $gapStart (keys %lgaps_QS){
	## Check to see if Library gap falls within view window
	if(($gapStart >= $lpos)&&($gapStart < $rpos)){
	  if(! exists($lgapsHR->{$gapStart})){
	    $lgapsHR->{$gapStart} = $lgaps_QS{$gapStart};
	  }elsif($lgaps_QS{$gapStart} > $lgapsHR->{$gapStart}){
	    $lgapsHR->{$gapStart} = $lgaps_QS{$gapStart};
	  }
	}
      }
    }
  }else{return 0;}
  return 1;
}

sub getGSQresults{
  my $self = shift;
  my ($argHR) = @_;
  my $pgs_uid = (exists($argHR->{pgs_uid}))?$argHR->{pgs_uid}:1;
  my $stype   = (exists($self->{sequenceTYPE}))?$self->{sequenceTYPE}:'EST';
  my $atype   = (exists($self->{gsqATYPE}))?$self->{gsqATYPE}:'C';
  my ($sth,$sth_e,$sth_i,$PGS_href,$exon_aref,$intron_aref);
  my ($GSQfile,$utPGS,$x);

  my $GSsrc = ((!exists($argHR->{gsegSRC}))||($argHR->{gsegSRC} eq 'GENOME'))?"":"gseg"; ###kludge!!!

  $sth = $self->{dbh}->prepare( $self->{"${GSsrc}gsqPGS_QUERY"} );
  $sth->execute($pgs_uid);

  $PGS_href = $sth->fetchrow_hashref('NAME_lc');
  $PGS_href->{seq} = _REVCOMP($PGS_href->{seq}) if($PGS_href->{e_o} eq "-");

  my $gsrcTAG      =((!exists($argHR->{gsegSRC}))||($argHR->{gsegSRC} eq 'GENOME'))?"Chromosome $PGS_href->{chr}":"BAC gi\| $PGS_href->{gseg_gi} \|";
  my $gsrcTAGshort =((!exists($argHR->{gsegSRC}))||($argHR->{gsegSRC} eq 'GENOME'))?"chr$PGS_href->{chr}":"$PGS_href->{gseg_gi}";
  my $gsegID       =((!exists($argHR->{gsegSRC}))||($argHR->{gsegSRC} eq 'GENOME'))?"$PGS_href->{chr}:GENOME" : "$PGS_href->{gseg_gi}:$argHR->{gsegSRC}";

  $GSQfile  = "Query $stype sequence\tXX (FILE: $PGS_href->{gi}" . "$PGS_href->{e_o}])\n\n";
  $GSQfile .= _pprintSEQ($PGS_href->{seq}) . "\n";
  $GSQfile .= "Predicted gene structure (within $gsrcTAG segment $PGS_href->{l_pos} to $PGS_href->{r_pos}):\n\n";

  $sth_e = $self->{dbh}->prepare( $self->{"${GSsrc}gsqPGS_EX_QUERY"} );
  $sth_e->execute($pgs_uid);
  $exon_aref = $sth_e->fetchall_arrayref();

  $sth_i = $self->{dbh}->prepare( $self->{"${GSsrc}gsqPGS_IN_QUERY"} );
  $sth_i->execute($pgs_uid);
  $intron_aref = $sth_i->fetchall_arrayref();

  $utPGS = '';
  for($x=0;$x<$#$exon_aref;$x++){
    $GSQfile .= sprintf(" Exon% 3d  % 10d  % 10d (% 4d n); % 10s  % 10d  % 10d (% 4d n); score: % 5.3f\n",
			$exon_aref->[$x][0],$exon_aref->[$x][1],$exon_aref->[$x][2],
			(max($exon_aref->[$x][2],$exon_aref->[$x][1]) - min($exon_aref->[$x][2],$exon_aref->[$x][1]) + 1),
			$stype,$exon_aref->[$x][3],$exon_aref->[$x][4],($exon_aref->[$x][4] - $exon_aref->[$x][3] + 1),$exon_aref->[$x][5]);
    $utPGS .= "$exon_aref->[$x][1]  $exon_aref->[$x][2],";
    if($stype eq 'C'){
      $GSQfile .= sprintf("  Intron% 3d  % 10d  % 10d (% 4d n); Pd: % 5.3f (s: % 4.2f), Pa: % 5.3f (s: % 4.2f)\n",
			  $intron_aref->[$x][0],$intron_aref->[$x][1],$intron_aref->[$x][2],
			  (max($intron_aref->[$x][2],$intron_aref->[$x][1]) - min($intron_aref->[$x][2],$intron_aref->[$x][1]) + 1),
			  $intron_aref->[$x][3],$intron_aref->[$x][4],$intron_aref->[$x][5],$intron_aref->[$x][6]);
    }else{
      $GSQfile .= sprintf("  Intron% 3d  % 10d  % 10d (% 4d n); Pd: % 5.3f, Pa: % 5.3f\n",
			  $intron_aref->[$x][0],$intron_aref->[$x][1],$intron_aref->[$x][2],
			  (max($intron_aref->[$x][2],$intron_aref->[$x][1]) - min($intron_aref->[$x][2],$intron_aref->[$x][1]) + 1),
			  $intron_aref->[$x][3],$intron_aref->[$x][5]);
    }
  }
  $GSQfile .= sprintf(" Exon% 3d  % 10d  % 10d (% 4d n); % 10s  % 10d  % 10d (% 4d n); score: % 5.3f\n",
		      $exon_aref->[$#$exon_aref][0],$exon_aref->[$#$exon_aref][1],$exon_aref->[$#$exon_aref][2],
		      (max($exon_aref->[$#$exon_aref][2],$exon_aref->[$#$exon_aref][1]) - min($exon_aref->[$#$exon_aref][2],$exon_aref->[$#$exon_aref][1]) + 1),
		      $stype,$exon_aref->[$#$exon_aref][3],
		      $exon_aref->[$#$exon_aref][4],($exon_aref->[$#$exon_aref][4] - $exon_aref->[$#$exon_aref][3] + 1),
		      $exon_aref->[$#$exon_aref][5]);
  $utPGS .= "$exon_aref->[$#$exon_aref][1]  $exon_aref->[$#$exon_aref][2]";

  $GSQfile .= sprintf("\nMATCH   % s %-15s % 5.3f  % 4d % 5.3f  % s\n","${gsrcTAGshort}$PGS_href->{g_o}","$PGS_href->{gi}$PGS_href->{e_o}",$PGS_href->{sim},$PGS_href->{mlength},$PGS_href->{cov},$atype);
  $GSQfile .= "PGS_${gsrcTAGshort}$PGS_href->{g_o}_$PGS_href->{gi}$PGS_href->{e_o}     ($utPGS)\n\nAlignment:\n\n";
  $GSQfile .= _pprintALIGNMENT($self->{db_id},@$PGS_href{'seq','l_pos','r_pos','g_o'},$gsegID,@$PGS_href{'pgs_lpos','pgs_rpos','gseg_gaps','pgs_gaps'},$atype);
  $GSQfile .= "\nhqPGS_${gsrcTAGshort}$PGS_href->{g_o}_$PGS_href->{gi}$PGS_href->{e_o}     ($PGS_href->{pgs})\n";

  return ({-title=>"hqPGS_${gsrcTAGshort}$PGS_href->{g_o}_$PGS_href->{gi}$PGS_href->{e_o}"},$GSQfile);
}


####################################################################
####################################################################

sub _pprintSEQ{
  my($seq) = @_;
  my($frag,$base,$x);

  my $rtv = "";
  $base=1;
  while($frag = substr($seq,$base-1,60)){
    $rtv .= sprintf("% 10d  %-10s %-10s %-10s %-10s %-10s %-10s\n",$base,substr($frag,0,10),substr($frag,10,10),substr($frag,20,10),substr($frag,30,10),substr($frag,40,10),substr($frag,50,10));
    $base+=60;
  }
  return $rtv;
}

sub _pprintALIGNMENT{
  my ($dbid,$eSeq,$gseg_lpos,$gseg_rpos,$G_O,$gsegID,$pgs_lpos,$pgs_rpos,$gseg_gaps,$pgs_gaps,$atype) = @_;
  my ($gsqAlignment,%gsegGAPS,%pgsGAPS);

  ## MAKE gap hashes
  %gsegGAPS = split(':',$gseg_gaps);
  %pgsGAPS  = split(':',$pgs_gaps);

  ## GET gapped genomic sequence
  my $gSeq = _getGappedGenomeSeq($dbid,$gsegID,$gseg_lpos,$gseg_rpos,$G_O,\%gsegGAPS);

  ## GET gapped query sequence
  $eSeq = _getGappedExpressedSequence($eSeq,$pgs_lpos,$pgs_rpos,\%pgsGAPS,$atype);

  my($Mline,$gpSeq,@ls,@qs,$x,$length);

  if($atype eq 'P'){
    ## Get translated genomic peptide
    ($gpSeq,$Mline,$length) = _getTranslatedGenomicAlignment($gSeq,$eSeq);

  }else{
    ## MAKE match (identical,similar) line
    @ls = split(//,$gSeq);
    @qs = split(//,$eSeq);
    $length = @qs; $Mline = '';
    for($x=0;$x<=$#ls;$x++){
      if($ls[$x] eq $qs[$x]){
	$Mline .= "|";
      }else{
	$Mline .= " ";
      }
    }
  }

  ## PRINT it all in GSQ format
  my($base,$frag,$Lcnt,$Qcnt,$Gdir);
  $base = 0; $frag = ""; 
  $Gdir = ($G_O eq '+')?1:-1; 
  $Lcnt = ($G_O eq '+')?$gseg_lpos-1:$gseg_rpos+1; 
  $Qcnt = $pgs_lpos-1;
  while($base < $length){
    $frag = substr($gSeq,$base,60);
    $Lcnt += ($Gdir * ($frag =~ tr/a-zA-Z/a-zA-Z/));
    $gsqAlignment .= sprintf("%-10s %-10s %-10s %-10s %-10s %-10s % 15d\n",
			     substr($gSeq,$base,10),substr($gSeq,$base+10,10),
			     substr($gSeq,$base+20,10),substr($gSeq,$base+30,10),
			     substr($gSeq,$base+40,10),substr($gSeq,$base+50,10),$Lcnt);
    $gsqAlignment .= sprintf("%-10s %-10s %-10s %-10s %-10s %-10s\n",
			     substr($gpSeq,$base,10),substr($gpSeq,$base+10,10),
			     substr($gpSeq,$base+20,10),substr($gpSeq,$base+30,10),
			     substr($gpSeq,$base+40,10),substr($gpSeq,$base+50,10)) if($atype eq 'P');
    $gsqAlignment .= sprintf("%-10s %-10s %-10s %-10s %-10s %-10s\n",
			     substr($Mline,$base,10),substr($Mline,$base+10,10),
			     substr($Mline,$base+20,10),substr($Mline,$base+30,10),
			     substr($Mline,$base+40,10),substr($Mline,$base+50,10));
    $frag = substr($eSeq,$base,60);
    $Qcnt += ($frag =~ tr/a-zA-Z/a-zA-Z/);
    $gsqAlignment .= sprintf("%-10s %-10s %-10s %-10s %-10s %-10s % 15d\n\n",
			     substr($eSeq,$base,10),substr($eSeq,$base+10,10),
			     substr($eSeq,$base+20,10),substr($eSeq,$base+30,10),
			     substr($eSeq,$base+40,10),substr($eSeq,$base+50,10),$Qcnt);
    $base += 60;
  }

  return $gsqAlignment;
}

sub _getGappedGenomeSeq{
  my ($version,$gsegID,$gseg_lpos,$gseg_rpos,$G_O,$gaps_href) = @_;
  my ($genomeSeq,$gapStart,$gsegSRC);

  ($gsegID,$gsegSRC) = split(":",$gsegID);
  $gsegSRC = "GENOME" if(!defined($gsegSRC));

  my $seqAR = GSQDB::getSequence("",$gsegSRC,$version,["${gsegID}:${gseg_lpos}:${gseg_rpos}"]);

  my @seqlines = split("\n",$seqAR->[0]);
  $genomeSeq = join('',@seqlines[1..$#seqlines]);

  ## produce gaped library sequence
  foreach $gapStart (reverse sort abs_numerically keys %$gaps_href){
    substr($genomeSeq,($gapStart - $gseg_lpos)+1,0) = "-" x $gaps_href->{$gapStart};
  }

  $genomeSeq = _REVCOMP($genomeSeq) if($G_O eq '-');
  $genomeSeq =~ tr/a-z/A-Z/;

  return $genomeSeq;
}

sub _getGappedExpressedSequence{
  my ($eSeq,$pgs_lpos,$pgs_rpos,$gaps_href,$atype) = @_;
  my ($gapStart,$geSEQ);

  $geSEQ = substr($eSeq,($pgs_lpos - 1),($pgs_rpos - $pgs_lpos + 1));
  foreach $gapStart (reverse sort abs_numerically keys %$gaps_href){
    my $gapKey = $gapStart;
    if($gapStart =~ /([+-]*\d+)([a-z])$/){
      $gapStart = $1; 
      $phase = $2;
    }elsif($atype eq 'P'){
      $phase = 'GSQ'; ## Kludge to handle GSQ's current AA gap methodology
    }else{
      $phase = '-';
    }
    if($gapStart > 0){ ## gaps > 0 -- introns < 0
      if($gaps_href->{$gapKey} < 0){ ## acceptor site gap
	if($phase eq 'a'){
	  #substr($geSEQ,$gapStart - $pgs_lpos,0) = "-" x abs($gaps_href->{$gapKey}) . " ";
	  substr($geSEQ,$gapStart - $pgs_lpos,0) = " - " x (abs($gaps_href->{$gapKey}) / 3) . " ";
	}elsif($phase eq 'b'){
	  #substr($geSEQ,$gapStart - $pgs_lpos,0) = " " . "-" x abs($gaps_href->{$gapKey});
	  substr($geSEQ,$gapStart - $pgs_lpos,0) = " " . " - " x (abs($gaps_href->{$gapKey}) / 3);
	}elsif($phase eq 'c'){
	  #substr($geSEQ,$gapStart - $pgs_lpos,0) = "-" x abs($gaps_href->{$gapKey}) . "  ";
	  substr($geSEQ,$gapStart - $pgs_lpos,0) = " - " x (abs($gaps_href->{$gapKey}) / 3) . "  ";
	}elsif($phase eq 'GSQ'){
	  substr($geSEQ,$gapStart - $pgs_lpos,0) = "- " . " - " x (abs($gaps_href->{$gapKey}) - 1) . " ";
	}else{
	  substr($geSEQ,$gapStart - $pgs_lpos,0) = "-" x abs($gaps_href->{$gapKey});
	}
      }else{
	if($phase eq 'a'){
	  #substr($geSEQ,$gapStart - $pgs_lpos + 1,0) = " " . "-" x $gaps_href->{$gapKey} . " ";
	  substr($geSEQ,$gapStart - $pgs_lpos + 1,0) =  " " . " - " x ($gaps_href->{$gapKey} / 3) . " ";
	}elsif($phase eq 'b'){
	  #substr($geSEQ,$gapStart - $pgs_lpos + 1,0) = "  " . "-" x $gaps_href->{$gapKey};
	  substr($geSEQ,$gapStart - $pgs_lpos + 1,0) = "  " . " - " x ($gaps_href->{$gapKey} / 3);
	}elsif($phase eq 'c'){
	  #substr($geSEQ,$gapStart - $pgs_lpos + 1,0) = "-" x $gaps_href->{$gapKey} . "  ";
	  substr($geSEQ,$gapStart - $pgs_lpos + 1,0) = " - " x ($gaps_href->{$gapKey} / 3) . "  ";
	}elsif($phase eq 'GSQ'){
	  substr($geSEQ,$gapStart - $pgs_lpos + 1,0) = " " . " - " x $gaps_href->{$gapKey} . " ";
	}else{
	  substr($geSEQ,$gapStart - $pgs_lpos + 1,0) = "-" x $gaps_href->{$gapKey};
	}
      }
    }else{
	if($phase eq 'a'){
	  substr($geSEQ,(-$gapStart) - $pgs_lpos + 1,0) = " " . "." x $gaps_href->{$gapKey} . " ";
	}elsif($phase eq 'b'){
	  substr($geSEQ,(-$gapStart) - $pgs_lpos + 1,0) = "  " . "." x $gaps_href->{$gapKey};
	}elsif($phase eq 'c'){
	  substr($geSEQ,(-$gapStart) - $pgs_lpos + 1,0) = "." x $gaps_href->{$gapKey} . "  ";
	}elsif($phase eq 'GSQ'){
	  substr($geSEQ,(-$gapStart) - $pgs_lpos + 1,0) = " " . "." x $gaps_href->{$gapKey} . " ";
	}else{
	  substr($geSEQ,(-$gapStart) - $pgs_lpos + 1,0) = "." x $gaps_href->{$gapKey};
	}
    }
  }
  $geSEQ =~ tr/a-z/A-Z/;
  if($atype eq 'P'){
    while($geSEQ =~ s/([A-Z])([A-Z])/$1  $2/g){};
    $geSEQ = " $geSEQ" if($geSEQ =~ /^[A-Z]/);
    $geSEQ = "$geSEQ " if($geSEQ =~ /[A-Z]$/);
  }

  return $geSEQ;
}

sub _getTranslatedGenomicAlignment{
  my ($gSeq,$eSeq) = @_;
  my ($gpSeq,$Mline,$length);

  my @gSeqCHAR = split(//,$gSeq);
  my @eSeqCHAR = split(//,$eSeq);
  $length = scalar(@eSeqCHAR);
  for(my $x=0; $x<=$#eSeqCHAR;$x++){
    if(($eSeqCHAR[$x] eq " ")||($eSeqCHAR[$x] eq ".")){
      $gpSeq .= ' ';
      $Mline .= ' ';
    }else{
      ## Need to modify to handle single nucleotide indel '-' in trans-pep-alignment
      ## currently '-' is treated as the entire 3base codon of an amino acid
      for($a=$x-1;$a>=0;$a--){
	last if($eSeqCHAR[$a] eq ' ');
      }
      for($c=$x+1;$c<=$#eSeqCHAR;$c++){
	last if($eSeqCHAR[$c] eq ' ');
      }
      my $codon = $gSeqCHAR[$a] . $gSeqCHAR[$x] . $gSeqCHAR[$c];
      if(exists($codon{$codon})){
	$gpSeq .= $codon{$codon};
	$Mline .= (exists($simAA{$codon{$codon}}) && exists($simAA{$codon{$codon}}->{$eSeqCHAR[$x]}))?$simAA{$codon{$codon}}->{$eSeqCHAR[$x]}
			:($codon{$codon} eq $eSeqCHAR[$x])?'|':' ';
      }else{
	$gpSeq .= '?';
	$Mline .= ' ';
      }
    }
  }

  return ($gpSeq,$Mline,$length);
}

##################################################################
sub max{ return (($_[0] > $_[1])?$_[0]:$_[1]); }
sub min{ return (($_[0] < $_[1])?$_[0]:$_[1]); }
sub abs_numerically{
  my($n1,$n2) = ($a,$b);
  $n1 = ($n1>0)? $n1 : -$n1;
  $n2 = ($n2>0)? $n2 : -$n2;
  return $n1<=>$n2;
}
sub _REVCOMP{
  my($seq) = @_;
  $seq = reverse($seq);
  $seq =~ tr/A-Z/a-z/;
  $seq =~ tr/actgACTG/tgacTGAC/;
  return $seq;
}

1;
