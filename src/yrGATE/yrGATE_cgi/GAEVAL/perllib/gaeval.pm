package gaeval;
use Data::Dumper;

sub new{
  my ($class,@param) = @_;
  my $self = {};
  bless $self, ref($class) || $class;
  return $self;
}

sub STRmatch{
  ## Returns a score (0-16) associated with the degree of containment of a PGS within a given annotation
  my $self = shift;
  my ($annSTR_ref,$pgsSTR_ref) = @_;

  print STDERR "&STRmatch [gaeval.pm]\n" if(exists($self->{DEBUG_list_subs}));

  ## OPTIONAL FORMAL PARAMETERS
  my $annPROPS_href = ($#_ >= 2)? $_[2]:0;
  my $annINFO_hr    = ($#_ >= 3)? $_[3]:0;
  my $pgsINFO_hr    = ($#_ >= 4)? $_[4]:0;

  my ($confirmSJ,$conflictsSJ,$contained,$additionalSJ) = (0,0,0,0);
  my ($intSTR,$annPOS,$pgsPOS,%annINTRONS);

  return (0) if(!(($annSTR_ref->[0] < $pgsSTR_ref->[$#$pgsSTR_ref])&&($annSTR_ref->[$#$annSTR_ref] > $pgsSTR_ref->[0])));
  $contained = (($annSTR_ref->[0] <= $pgsSTR_ref->[0])&&($annSTR_ref->[$#$annSTR_ref] >= $pgsSTR_ref->[$#$pgsSTR_ref]))?1:0;

  for($annPOS=1;$annPOS<$#$annSTR_ref;$annPOS+=2){
    $annINTRONS{$annSTR_ref->[$annPOS] . ":" . $annSTR_ref->[$annPOS + 1]} = 0;
  }
  for($pgsPOS=1;$pgsPOS<$#$pgsSTR_ref;$pgsPOS+=2){
    $intSTR = $pgsSTR_ref->[$pgsPOS] . ":" . $pgsSTR_ref->[$pgsPOS + 1];
    if(exists($annINTRONS{$intSTR})){
      if($annPROPS_href){ 
	&add_intronPROP($annPROPS_href,"INTRONS_confirmed",$intSTR,$pgsINFO_hr); 
	if((exists($annPROPS_href->{INTRONS_unsupported}))&&(exists($annPROPS_href->{INTRONS_unsupported}->{$intSTR}))){
	  delete $annPROPS_href->{INTRONS_unsupported}->{$intSTR};
	}
      }
      $confirmSJ = 1;
      delete $annINTRONS{$intSTR};
    }else{
      if($annPROPS_href){
	if(($pgsSTR_ref->[$pgsPOS] < $annSTR_ref->[$#$annSTR_ref])&&($pgsSTR_ref->[$pgsPOS + 1] > $annSTR_ref->[0])){
	  &add_intronPROP($annPROPS_href,"INTRONS_alternative",$intSTR,$pgsINFO_hr); 
	}else{
	  &add_intronPROP($annPROPS_href,"INTRONS_additional",$intSTR,$pgsINFO_hr);
	}
      }
      $additionalSJ = 1;
    }
  }

  foreach $intSTR (keys %annINTRONS){
    if($annPROPS_href){
      if((!exists($annPROPS_href->{INTRONS_confirmed}))||(!exists($annPROPS_href->{INTRONS_confirmed}->{$intSTR}))){
	&add_intronPROP($annPROPS_href,"INTRONS_unsupported",$intSTR,$pgsINFO_hr);
      }
    }
    ($donor,$acceptor) = split(':',$intSTR);
    if(($acceptor > $pgsSTR_ref->[0] + 20 )&&($donor <  $pgsSTR_ref->[$#$pgsSTR_ref] - 20)){
      $conflictsSJ = 1;
      &add_intronPROP($annPROPS_href,"INTRONS_conflicting",$intSTR,$pgsINFO_hr) if($annPROPS_href);
    }
  }

  if($annPROPS_href){
    ## Determine exon coverage values!!
    my ($covLENGTH,$annLENGTH,$pgsLENGTH);
    
    $covLENGTH = $self->calc_coverage($annSTR_ref,$pgsSTR_ref);

    if($covLENGTH){
      for($annPOS=0;$annPOS < $#$annSTR_ref;$annPOS+=2){
	$annLENGTH += ($annSTR_ref->[$annPOS + 1] - $annSTR_ref->[$annPOS]);
      }
      for($pgsPOS=0;$pgsPOS < $#$pgsSTR_ref;$pgsPOS+=2){
	$pgsLENGTH += ($pgsSTR_ref->[$pgsPOS + 1] - $pgsSTR_ref->[$pgsPOS]);
      }
      
      $annPROPS_href->{COVERAGE_annotation} =  $covLENGTH / $annLENGTH;
      $annPROPS_href->{COVERAGE_pgs} =  $covLENGTH / $pgsLENGTH;
    }else{
      $annPROPS_href->{COVERAGE_annotation} = 0;
      $annPROPS_href->{COVERAGE_pgs} = 0;
    }

    if(exists($annPROPS_href->{ISO_EXON_coverage})){ 
      $annPOS = 0; $pgsPOS = 0;
      my @newSTR = ();
      my ($rgt);
      while(($annPOS < $#{$annPROPS_href->{ISO_EXON_coverage}})&&($pgsPOS < $#$pgsSTR_ref)){
	if($annPROPS_href->{ISO_EXON_coverage}->[$annPOS] < $pgsSTR_ref->[$pgsPOS]){
	  push(@newSTR,$annPROPS_href->{ISO_EXON_coverage}->[$annPOS]);
	  $rgt = $annPROPS_href->{ISO_EXON_coverage}->[$annPOS + 1];
	}else{
	  push(@newSTR,$pgsSTR_ref->[$pgsPOS]);
	  $rgt = $pgsSTR_ref->[$pgsPOS + 1];
	}
	while((($annPOS + 2) < $#{$annPROPS_href->{ISO_EXON_coverage}})&&($rgt >= $annPROPS_href->{ISO_EXON_coverage}->[$annPOS + 2])){$annPOS+=2;}
	while((($pgsPOS  + 2) < $#$pgsSTR_ref)&&($rgt >= $pgsSTR_ref->[$pgsPOS + 2])){$pgsPOS+=2;}

	if(($annPROPS_href->{ISO_EXON_coverage}->[$annPOS] < $rgt) && ($rgt < $annPROPS_href->{ISO_EXON_coverage}->[$annPOS + 1])){
	  $rgt = $annPROPS_href->{ISO_EXON_coverage}->[$annPOS + 1];
	}elsif(($pgsSTR_ref->[$pgsPOS] < $rgt) && ($rgt < $pgsSTR_ref->[$pgsPOS + 1])){
	  $rgt = $pgsSTR_ref->[$pgsPOS + 1];
	}
	push(@newSTR,$rgt);
	
	$annPOS+=2 if($annPROPS_href->{ISO_EXON_coverage}->[$annPOS] < $rgt);
	$pgsPOS+=2 if($pgsSTR_ref->[$pgsPOS] < $rgt);
      }
      for(;$annPOS <= $#{$annPROPS_href->{ISO_EXON_coverage}};$annPOS++){
	push(@newSTR,$annPROPS_href->{ISO_EXON_coverage}->[$annPOS]);
      }
      for(;$pgsPOS <= $#$pgsSTR_ref;$pgsPOS++){
	push(@newSTR,$pgsSTR_ref->[$pgsPOS]);
      }
      $annPROPS_href->{ISO_EXON_coverage} = [@newSTR];

    }else{
      $annPROPS_href->{ISO_EXON_coverage} = [@$pgsSTR_ref]; 
    }

  }

  return ((8 * $confirmSJ) + (4 - (4 * $conflictsSJ)) + (2 * $contained) + (1 - $additionalSJ) + 1 );
}

sub group_TPS{  ## Returns the number of distinct 3' SEQUENCE groups based on location proximity
  my $self = shift;
  my ($grp_ref,$TPS_aref) = @_; ## $TPS_aref = [[gi,lpos,rpos],...]
  my ($hitCNT,$grpSUM,$x,$y,$z,@maxHIT,@newTPS,@tpsMEM);

  my @strand   = ($#_ >= 2)? ($_[2]):(1,2);
  my $TPGALLOW = ($#_ >= 3)? $_[3]:100;       ## Allowance parameter for TPS clustering by location
  my $MIN_TPG_members = ($#_ >= 4)? $_[4]:2;  ## TPS groups must have this many constituent sequences
 
  while(scalar(@{$TPS_aref})){
    @maxHIT=(0,0,0);
    for($x=0;$x<=$#$TPS_aref;$x++){
      foreach $z (@strand){
	$hitCNT = 0;
        for($y=0;$y<=$#$TPS_aref;$y++){
	  if((max($TPS_aref->[$y]->[$z],$TPS_aref->[$x]->[$z]) - min($TPS_aref->[$y]->[$z],$TPS_aref->[$x]->[$z])) <= $TPGALLOW){
  	    $hitCNT++;
	  }
	}
	if($hitCNT > $maxHIT[0]){
	  $maxHIT[0] = $hitCNT;
	  $maxHIT[1] = $x;
	  $maxHIT[2] = $z;
	}
      }
    }

    $x = $maxHIT[1];
    $z = $maxHIT[2];
    @newTPS = ();
    @tpsMEM = ();
    $grpSUM = 0;
    for($y=0;$y<=$#$TPS_aref;$y++){
      if((max($TPS_aref->[$y]->[$z],$TPS_aref->[$x]->[$z]) - min($TPS_aref->[$y]->[$z],$TPS_aref->[$x]->[$z])) <= $TPGALLOW){
	$grpSUM += $TPS_aref->[$y]->[$z];
        push(@tpsMEM,$TPS_aref->[$y]);
      }else{
	push(@newTPS,$TPS_aref->[$y]);
      }
    }

    ## Only report TPS groups with $MIN_TPG_members
    if(scalar(@tpsMEM) >= $MIN_TPG_members){
      my $TPGavg = int $grpSUM / scalar(@tpsMEM);
      $grp_ref->{$TPGavg}->{TPS}     = [@tpsMEM];
      $grp_ref->{$TPGavg}->{strand}  = ($z == 1)? '-':'+';
    }
    $TPS_aref = [@newTPS];
  }
  
  return keys(%{$grp_ref});
}

sub calc_bounds {
  my $self = shift;
  my ($annSTR_ref,$pgsSTR_ref,$strand) = @_;

  print STDERR "&calc_bound [gaeval.pm]\n" if(exists($self->{DEBUG_list_subs}));

  if(($strand eq 'f')||($strand eq '+')){
    return (($pgsSTR_ref->[0] - $annSTR_ref->[0]),($annSTR_ref->[$#$annSTR_ref] - $pgsSTR_ref->[$#$pgsSTR_ref]));
  }else{
    return (($annSTR_ref->[$#$annSTR_ref] - $pgsSTR_ref->[$#$pgsSTR_ref]),($pgsSTR_ref->[0] - $annSTR_ref->[0]));
  }    

}

sub calc_coverage {
  my $self = shift;
  my ($annSTR_ref,$pgsSTR_ref) = @_;

  print STDERR "&calc_coverage [gaeval.pm]\n" if(exists($self->{DEBUG_list_subs}));

  my ($annPOS,$pgsPOS,$covLENGTH) = (0,0,0);
  # to eliminate overlap situation
  my $formerPOS = 0;
  for($pgsPOS=2;$pgsPOS < $#$pgsSTR_ref;$pgsPOS+=2) {
    if($pgsSTR_ref->[$formerPOS + 1]>$pgsSTR_ref->[$pgsPOS]) {
      my $newEnd = max($pgsSTR_ref->[$formerPOS+1], $pgsSTR_ref->[$pgsPOS+1]);
      $pgsSTR_ref->[$formerPOS+1] = $newEnd;
      splice(@$pgsSTR_ref,$pgsPOS,2);
      $pgsPOS -= 2;
    } 
      $formerPOS = $pgsPOS;
  }

  for($pgsPOS=0;$pgsPOS < $#$pgsSTR_ref;$pgsPOS+=2){
    while(($annPOS)&&($pgsSTR_ref->[$pgsPOS] < $annSTR_ref->[$annPOS - 1])){$annPOS-=2;}
   
     for(;$annPOS < $#$annSTR_ref;$annPOS+=2){
      if(($pgsSTR_ref->[$pgsPOS] < $annSTR_ref->[$annPOS + 1])&&
	 ($pgsSTR_ref->[$pgsPOS + 1] > $annSTR_ref->[$annPOS])){
	$covLENGTH += (min($pgsSTR_ref->[$pgsPOS + 1],$annSTR_ref->[$annPOS + 1]) - max($pgsSTR_ref->[$pgsPOS],$annSTR_ref->[$annPOS]));
      }elsif($annSTR_ref->[$annPOS] > $pgsSTR_ref->[$pgsPOS + 1]){
	last;
      }
    }
  }

  print STDERR "covLength $covLENGTH\n";
  return $covLENGTH;
}
sub calc_size {
  my $self = shift;
  my ($STR_ref) = @_;

  my $size = 0;
  for(my $x=0;$x<$#$STR_ref;$x+=2){
    $size += ($STR_ref->[$x+1] - $STR_ref->[$x]);
  } 
  return $size;
}

sub calc_integrity {
  my $self = shift;
  my ($score);
  
  my $cds_size  = &calc_size($self,$self->{cds_STRUCTURE});
  my $utr5_size = &calc_size($self,$self->{five_prime_UTR});
  my $utr3_size = &calc_size($self,$self->{three_prime_UTR});

  if(exists($self->{BC_MATCHES}->{EXON_coverage})){
    if(keys(%{$self->{BC_MATCHES}->{INTRONS_confirmed}}) + keys(%{$self->{BC_MATCHES}->{INTRONS_unsupported}})){
      $a = (exists($self->{BC_MATCHES}->{INTRONS_confirmed}))?scalar(keys(%{$self->{BC_MATCHES}->{INTRONS_confirmed}})):0;
      $b = (exists($self->{BC_MATCHES}->{INTRONS_unsupported}))?scalar(keys(%{$self->{BC_MATCHES}->{INTRONS_unsupported}})):-1;
      $score = 0.6 * ($a / ($a + $b));
    }else{
      $score = 0.6 * min(1,($cds_size / 400));
    }

    $score += (0.3  * $self->{BC_MATCHES}->{EXON_coverage});
    $score += (0.05 * min(1,($utr5_size / 200)));
    $score += (0.05 * min(1,($utr3_size / 100)));

  }else{ undef $score; }

  return ($score, $cds_size, $utr5_size, $utr3_size);
}

sub add_intronPROP{
  my ($PROPhref,$PROPkey,$INTRONstr,$pgsINFO_hr) = @_;
  if(!exists($PROPhref->{$PROPkey})){    $PROPhref->{$PROPkey} = {};  }
  if(exists($PROPhref->{$PROPkey}->{$INTRONstr})){
    push(@{$PROPhref->{$PROPkey}->{$INTRONstr}},$pgsINFO_hr);
  }else{
    $PROPhref->{$PROPkey}->{$INTRONstr} = [$pgsINFO_hr];
  }
}

sub max{ return ($_[0] > $_[1])?$_[0]:$_[1];}

sub min{ return ($_[0] < $_[1])?$_[0]:$_[1];}

1;
