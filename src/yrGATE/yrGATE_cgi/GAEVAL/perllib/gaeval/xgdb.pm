package gaeval::xgdb;

use base gaeval;

use Storable qw(dclone); ## Used to clone the ISO data structures

sub init_self {
  my $self = shift;

  print STDERR "&init_self [gaeval_annotation.pm]\n" if(exists($self->{DEBUG_list_subs}));

  delete($self->{ann_DBdata});
  delete($self->{annIsoforms});
  delete($self->{ann_STRUCTURE});
  delete($self->{bc_PGS});
  delete($self->{nc_PGS});
  delete($self->{bn_PGS});
  delete($self->{nn_PGS});
  delete($self->{BC_MATCHES});
  delete($self->{BCBN_MATCHES});
  delete($self->{BCNC_MATCHES});
  delete($self->{BCNN_MATCHES});

  return;
}

sub loadANN{
  my $self = shift;
  my ($annUID) = @_;

  print STDERR "&loadANN [gaeval_annotation.pm]\n" if(exists($self->{DEBUG_list_subs}));

  return if((exists($self->{ann_DBdata}))&&($self->{ann_DBdata}->{uid} == $annUID)); 

  my $annINFO_QUERY = qq{Select * from $self->{db_table} WHERE (uid = ?)};

  $self->init_self();

  my $sth = $self->{dbh}->prepare($annINFO_QUERY);
  $sth->execute($annUID);
  $self->{ann_DBdata} = $sth->fetchrow_hashref('NAME_lc');
  
  my $annINFO = $self->{ann_DBdata}->{gene_structure};
  $annINFO =~ s/^\D+//;
  $annINFO =~ s/\D+$//;
  my @annSTR = split(/\D+/,$annINFO);
  @annSTR = sort {return $a <=> $b;} @annSTR;
  $self->{ann_STRUCTURE} = [@annSTR];

  my $CDSlpos = gaeval::min($self->{ann_DBdata}->{cdsstart},$self->{ann_DBdata}->{cdsstop});
  my $CDSrpos = gaeval::max($self->{ann_DBdata}->{cdsstart},$self->{ann_DBdata}->{cdsstop});
  $self->{cds_STRUCTURE} = [$CDSlpos];
  $self->{five_prime_UTR} = [];
  $self->{three_prime_UTR} = [];
  for(my $x=0; $x<=$#annSTR; $x++){
    if($annSTR[$x] < $CDSlpos){
      if($self->{ann_DBdata}->{strand} eq 'f'){
	push(@{$self->{five_prime_UTR}}, $annSTR[$x]);
      }else{
	push(@{$self->{three_prime_UTR}}, $annSTR[$x]);
      }
    }elsif(($annSTR[$x] == $CDSlpos)&&(!$x)){
      next;
    }elsif(($annSTR[$x] == $CDSrpos)&&($x == $#annSTR)){
      next;
    }elsif(($annSTR[$x] >= $CDSlpos)&&($annSTR[$x] <= $CDSrpos)){
      push(@{$self->{cds_STRUCTURE}}, $annSTR[$x]);
    }elsif($annSTR[$x] > $CDSrpos){
      if($self->{ann_DBdata}->{strand} eq 'f'){
	push(@{$self->{three_prime_UTR}}, $annSTR[$x]);
      }else{
	push(@{$self->{five_prime_UTR}}, $annSTR[$x]);
      }
    }
  }
  push(@{$self->{cds_STRUCTURE}},$CDSrpos);
  if($self->{ann_DBdata}->{strand} eq 'f'){
    if(scalar(@{$self->{five_prime_UTR}})){
      push(@{$self->{five_prime_UTR}}, $CDSlpos);
    }
    if(scalar(@{$self->{three_prime_UTR}})){
      unshift(@{$self->{three_prime_UTR}}, $CDSrpos);
    }  
  }else{
    if(scalar(@{$self->{five_prime_UTR}})){
      unshift(@{$self->{five_prime_UTR}}, $CDSrpos);
    }
    if(scalar(@{$self->{three_prime_UTR}})){
      push(@{$self->{three_prime_UTR}}, $CDSlpos);
    }
  }
  

  $sth->finish();
  
  return;
}

sub loadISO{
  my $self = shift;
  my ($annUID) = @_;

  print STDERR "&loadISO [gaeval_annotation.pm]\n" if(exists($self->{DEBUG_list_subs}));

  my $pgsINFO_QUERY = qq{SELECT ISO.uid as iso_uid, ISO.annUID, ISO.pgsUID, ISO.score, ISO.multi,
			 ISO.intron_confirmed, ISO.intron_additional, ISO.intron_alternative, 
			 ISO.intron_conflicting, ISO.annotation_coverage, ISO.pgs_coverage,
			 PGS.G_O, PGS.pgs };
  
  my ($sth,$indx,$tmp,$x,$INFO,@STR);

  if(! exists($self->{bc_PGS})){
    $indx=0;
    for($x=0;$x<=$#{$self->{GAEVAL_ISO_TABLES}};$x++){
      $sth = $self->{dbh}->prepare($pgsINFO_QUERY . " FROM $self->{GAEVAL_ISO_TABLES}->[$x]->{ISO_TBL} as ISO, $self->{GAEVAL_ISO_TABLES}->[$x]->{PGS_TBL} as PGS WHERE (ISO.pgsUID = PGS.uid)&&(ISO.annUID = $annUID)&&(ISO.best >= 1)&&(ISO.isCognate = 1)");
      $sth->execute();
      while($tmp = $sth->fetchrow_hashref('NAME_lc')){
	$self->{bc_PGS}->[$indx] = $tmp;
	$INFO = $self->{bc_PGS}->[$indx]->{pgs};
	$INFO =~ s/^\D+//;
	$INFO =~ s/\D+$//;
	@STR = split(/\D+/,$INFO);
	@STR = sort {return $a <=> $b;} @STR;
	$self->{bc_PGS}->[$indx]->{pgs_STRUCTURE} = [@STR];
	$self->{bc_PGS}->[$indx]->{GAEVAL_ISO_TBL} = $x;
	$indx++;
      }
    }
  }
    
  if(! exists($self->{nc_PGS})){
    $indx=0;
    for($x=0;$x<=$#{$self->{GAEVAL_ISO_TABLES}};$x++){
      $sth = $self->{dbh}->prepare($pgsINFO_QUERY . " FROM $self->{GAEVAL_ISO_TABLES}->[$x]->{ISO_TBL} as ISO, $self->{GAEVAL_ISO_TABLES}->[$x]->{PGS_TBL} as PGS WHERE (ISO.pgsUID = PGS.uid)&&(ISO.annUID = $annUID)&&(ISO.best = 0)&&(ISO.isCognate = 1)");
      $sth->execute();
      while($tmp = $sth->fetchrow_hashref('NAME_lc')){
	$self->{nc_PGS}->[$indx] = $tmp;
	$INFO = $self->{nc_PGS}->[$indx]->{pgs};
	$INFO =~ s/^\D+//;
	$INFO =~ s/\D+$//;
	@STR = split(/\D+/,$INFO);
	@STR = sort {return $a <=> $b;} @STR;
	$self->{nc_PGS}->[$indx]->{pgs_STRUCTURE} = [@STR];
	$self->{nc_PGS}->[$indx]->{GAEVAL_ISO_TBL} = $x;
	$indx++;
      }
    }
  }

  if(! exists($self->{bn_PGS})){ 
    $indx=0;
    for($x=0;$x<=$#{$self->{GAEVAL_ISO_TABLES}};$x++){
      $sth = $self->{dbh}->prepare($pgsINFO_QUERY . " FROM $self->{GAEVAL_ISO_TABLES}->[$x]->{ISO_TBL} as ISO, $self->{GAEVAL_ISO_TABLES}->[$x]->{PGS_TBL} as PGS WHERE (ISO.pgsUID = PGS.uid)&&(ISO.annUID = $annUID)&&(ISO.best >= 1)&&(ISO.isCognate = 0)");
      $sth->execute();
      while($tmp = $sth->fetchrow_hashref('NAME_lc')){
	$self->{bn_PGS}->[$indx] = $tmp;
	$INFO = $self->{bn_PGS}->[$indx]->{pgs};
	$INFO =~ s/^\D+//;
	$INFO =~ s/\D+$//;
	@STR = split(/\D+/,$INFO);
	@STR = sort {return $a <=> $b;} @STR;
	$self->{bn_PGS}->[$indx]->{pgs_STRUCTURE} = [@STR];
	$self->{bn_PGS}->[$indx]->{GAEVAL_ISO_TBL} = $x;
	$indx++;
      }
    }
  }
    
  if(! exists($self->{nn_PGS})){ 
    $indx=0;
    for($x=0;$x<=$#{$self->{GAEVAL_ISO_TABLES}};$x++){
      $sth = $self->{dbh}->prepare($pgsINFO_QUERY . " FROM $self->{GAEVAL_ISO_TABLES}->[$x]->{ISO_TBL} as ISO, $self->{GAEVAL_ISO_TABLES}->[$x]->{PGS_TBL} as PGS WHERE (ISO.pgsUID = PGS.uid)&&(ISO.annUID = $annUID)&&(ISO.best = 0)&&(ISO.isCognate = 0)");
      $sth->execute();
      while($tmp = $sth->fetchrow_hashref('NAME_lc')){
	$self->{nn_PGS}->[$indx] = $tmp;
	$INFO = $self->{nn_PGS}->[$indx]->{pgs};
	$INFO =~ s/^\D+//;
	$INFO =~ s/\D+$//;
	@STR = split(/\D+/,$INFO);
	@STR = sort {return $a <=> $b;} @STR;
	$self->{nn_PGS}->[$indx]->{pgs_STRUCTURE} = [@STR];
	$self->{nn_PGS}->[$indx]->{GAEVAL_ISO_TBL} = $x;
	$indx++;
      }
    }
  }

  return;
}

sub eval_annotation_support{
  ## returns values corresponding to how well an annotation is supported by current PGSs
  my $self = shift;
  my($annUID) = @_;

  print STDERR "&eval_annotation_support [gaeval_annotation.pm]\n" if(exists($self->{DEBUG_list_subs}));

  return if(exists($self->{BC_MATCHES})&&(exists($self->{ann_DBdata}))&&($self->{ann_DBdata}->{uid} == $annUID));

  my($indx,$annLENGTH);
  $self->loadANN($annUID);
  $self->loadISO($annUID);

  $annLENGTH = 0;
  for($indx=0;$indx < $#{$self->{ann_STRUCTURE}};$indx+=2){
    $annLENGTH += ($self->{ann_STRUCTURE}->[$indx + 1] -$self->{ann_STRUCTURE}->[$indx]); 
  }
  ## re-STRmatch all ISO-PGSs to determine annotation support (BC,BC+BN,BC+NC,BC+NN)
  $self->{BC_MATCHES} = {};
  if(exists($self->{bc_PGS}) && scalar(@{$self->{bc_PGS}})){
    foreach $ISO_href (@{$self->{bc_PGS}}){
      $self->STRmatch($self->{ann_STRUCTURE},$ISO_href->{pgs_STRUCTURE},$self->{BC_MATCHES},$self->{ann_DBdata},$ISO_href);
    }
    $self->{BC_MATCHES}->{EXON_coverage} = $self->calc_coverage($self->{ann_STRUCTURE},$self->{BC_MATCHES}->{ISO_EXON_coverage}) / $annLENGTH;
    ($self->{BC_MATCHES}->{BOUND_5prime},$self->{BC_MATCHES}->{BOUND_3prime}) = $self->calc_bounds($self->{ann_STRUCTURE},$self->{BC_MATCHES}->{ISO_EXON_coverage},$self->{ann_DBdata}->{strand});
  }

  $self->{BCBN_MATCHES} = dclone($self->{BC_MATCHES});
  if(exists($self->{bn_PGS}) && scalar(@{$self->{bn_PGS}})){
    foreach $ISO_href (@{$self->{bn_PGS}}){
      $self->STRmatch($self->{ann_STRUCTURE},$ISO_href->{pgs_STRUCTURE},$self->{BCBN_MATCHES},$self->{ann_DBdata},$ISO_href);
    }
    $self->{BCBN_MATCHES}->{EXON_coverage} = $self->calc_coverage($self->{ann_STRUCTURE},$self->{BCBN_MATCHES}->{ISO_EXON_coverage}) / $annLENGTH;
    ($self->{BCBN_MATCHES}->{BOUND_5prime},$self->{BCBN_MATCHES}->{BOUND_3prime}) = $self->calc_bounds($self->{ann_STRUCTURE},$self->{BCBN_MATCHES}->{ISO_EXON_coverage},$self->{ann_DBdata}->{strand});
  }
  
  $self->{BCNC_MATCHES} = dclone($self->{BC_MATCHES});
  if(exists($self->{nc_PGS}) && scalar(@{$self->{nc_PGS}})){
    foreach $ISO_href (@{$self->{nc_PGS}}){
      $self->STRmatch($self->{ann_STRUCTURE},$ISO_href->{pgs_STRUCTURE},$self->{BCNC_MATCHES},$self->{ann_DBdata},$ISO_href);
    }
    $self->{BCNC_MATCHES}->{EXON_coverage} = $self->calc_coverage($self->{ann_STRUCTURE},$self->{BCNC_MATCHES}->{ISO_EXON_coverage}) / $annLENGTH;
    ($self->{BCNC_MATCHES}->{BOUND_5prime},$self->{BCNC_MATCHES}->{BOUND_3prime}) = $self->calc_bounds($self->{ann_STRUCTURE},$self->{BCNC_MATCHES}->{ISO_EXON_coverage},$self->{ann_DBdata}->{strand});
  }
  
  $self->{BCNN_MATCHES} = dclone($self->{BC_MATCHES});
  if(exists($self->{nn_PGS}) && scalar(@{$self->{nn_PGS}})){
    foreach $ISO_href (@{$self->{nn_PGS}}){
      $self->STRmatch($self->{ann_STRUCTURE},$ISO_href->{pgs_STRUCTURE},$self->{BCNN_MATCHES},$self->{ann_DBdata},$ISO_href);
    }
    $self->{BCNN_MATCHES}->{EXON_coverage} = $self->calc_coverage($self->{ann_STRUCTURE},$self->{BCNN_MATCHES}->{ISO_EXON_coverage}) / $annLENGTH;
    ($self->{BCNN_MATCHES}->{BOUND_5prime},$self->{BCNN_MATCHES}->{BOUND_3prime}) = $self->calc_bounds($self->{ann_STRUCTURE},$self->{BCNN_MATCHES}->{ISO_EXON_coverage},$self->{ann_DBdata}->{strand});
  }
  
  return;
}

sub _AMBboundary{
  my $self = shift;
  my ($annUID) = @_;

  print STDERR "&CFD_AMBboundary [gaeval_annotation.pm]\n" if(exists($self->{DEBUG_list_subs}));

  $self->loadANN($annUID);
  $self->eval_annotation_support($annUID);
  $self->gather_isoforms($annUID);

  my $aoaINFO_hr = {};
  my $gsegID_SQL = (exists($self->{ann_DBdata}->{chr}))?"chr = $self->{ann_DBdata}->{chr}":"gseg_gi = $self->{ann_DBdata}->{gseg_gi}";
  my ($annNAME) = $self->{ann_DBdata}->{geneid} =~ /^([^\.]+)/;
  my $olapWHERE = "WHERE (ISO.annUID = $annUID) && (ISO.uid != ISO2.uid) && (ISO.score = 8) && (ISO2.score = 8) && ((PGS.l_pos > ANN.l_pos )&&(PGS.l_pos > OA.l_pos)&&(PGS.r_pos < ANN.r_pos)&&(PGS.r_pos < OA.r_pos))";
    
  ## Check to see if any overlapping LOCAL annotations provide ambiguous boundary extensions
  for(my $s=0;$s<=$#{$self->{GAEVAL_ISO_TABLES}};$s++){
    $resAR = $self->{dbh}->selectall_arrayref("select OA.uid,OA.geneId,OA.gene_structure,ISO.pgsUID, PGS.gi, PGS.l_pos, PGS.r_pos from $self->{GAEVAL_ISO_TABLES}->[$s]->{ISO_TBL} as ISO JOIN $self->{GAEVAL_ISO_TABLES}->[$s]->{ISO_TBL} as ISO2 USING (pgsUID) JOIN $self->{GAEVAL_ISO_TABLES}->[$s]->{PGS_TBL} as PGS ON (ISO.pgsUID = PGS.uid) JOIN $self->{db_table} as ANN ON (ISO.annUID = ANN.uid) JOIN $self->{db_table} as OA ON (ISO2.annUID = OA.uid) $olapWHERE");
    if(scalar(@{$resAR})){ ## overlap either end
      for(my $x=0; $x<=$#$resAR; $x++){
	if(!exists($self->{annIsoforms}->{LOCAL}->{$resAR->[$x][0]})){
	  $aoaINFO_hr->{AMB_annotations} = {} if(!exists($aoaINFO_hr->{AMB_annotations}));
	  if(exists($aoaINFO_hr->{AMB_annotations}->{$resAR->[$x][0]})){
	    $aoaINFO_hr->{AMB_annotations}->{$resAR->[$x][0]}->{AmbISO}->{$self->{GAEVAL_ISO_TABLES}->[$s]->{PGS_TBL}} = {} if(!exists($aoaINFO_hr->{AMB_annotations}->{$resAR->[$x][0]}->{AmbISO}->{$self->{GAEVAL_ISO_TABLES}->[$s]->{PGS_TBL}}));
	    $aoaINFO_hr->{AMB_annotations}->{$resAR->[$x][0]}->{AmbISO}->{$self->{GAEVAL_ISO_TABLES}->[$s]->{PGS_TBL}}->{$resAR->[$x][3]} = {gi=>$resAR->[$x][4],lpos=>$resAR->[$x][5],rpos=>$resAR->[$x][6]};
	  }else{
	    $aoaINFO_hr->{AMB_annotations}->{$resAR->[$x][0]} = {OAgeneId => $resAR->[$x][1],OAgene_structure => $resAR->[$x][2],AmbISO => {$self->{GAEVAL_ISO_TABLES}->[$s]->{PGS_TBL} => {$resAR->[$x][3] => {gi=>$resAR->[$x][4],lpos=>$resAR->[$x][5],rpos=>$resAR->[$x][6]}}}}
	  }
	}
      }
    }
  }
  
  return $aoaINFO_hr;
}

sub _altSplicing{
  ## Checks an annotation for documented, undocumented, & unsupported alternative splicing
  my $self = shift;
  my ($annUID) = @_;

  print STDERR "&CFD_altSplicing [gaeval_annotation.pm]\n" if(exists($self->{DEBUG_list_subs}));

  my $asiINFO_hr = {};

  $self->loadANN($annUID);
  $self->eval_annotation_support($annUID);
  $self->gather_isoforms($annUID);

  my $gsegID_SQL = (exists($self->{ann_DBdata}->{chr}))?"chr = $self->{ann_DBdata}->{chr}":"gseg_gi = $self->{ann_DBdata}->{gseg_gi}";

  my ($ASItype,$intSTR,$Ilft,$Irgt,$resAR);
  foreach $ASItype (('INTRONS_alternative','INTRONS_additional','INTRONS_conflicting')){
    foreach $intSTR (keys %{$self->{BCNC_MATCHES}->{$ASItype}}){
      ($Ilft,$Irgt) = split(':',$intSTR);
      
      ## Capture PGS info for all ISOs contributing to this intron classification
      $asiINFO_hr->{$intSTR}->{$ASItype}->{ISO_PGS} = $self->{BCNC_MATCHES}->{$ASItype}->{$intSTR};

      ## Score the reliability of the property
       $asiINFO_hr->{$intSTR}->{$ASItype}->{score} = scalar(@{$asiINFO_hr->{$intSTR}->{$ASItype}->{ISO_PGS}});

      ## Check for documented introns in local annotation source
      $resAR = $self->{dbh}->selectall_arrayref("select uid,geneId,gene_structure from $self->{db_table} " .
						"where (($gsegID_SQL)&&(uid != $annUID)&&(l_pos <= $Ilft)&&(r_pos >= $Irgt)" .
						"&&((gene_structure RLIKE '${Ilft},$Irgt' )||(gene_structure RLIKE '${Irgt},$Ilft' )))");
      $asiINFO_hr->{$intSTR}->{$ASItype}->{documented}->{LOCAL} = $resAR if(scalar(@{$resAR}));

      ## Check for documented introns in external Annotation Sources
      if(exists($self->{GAEVAL_ANN_TABLES})){
	for(my $indx=0;$indx <= $#{$self->{GAEVAL_ANN_TABLES}};$indx++){
	  next if($self->{GAEVAL_ANN_TABLES}->[$indx]->{ANN_TBL} eq $self->{db_table});
	  next if($self->{GAEVAL_ANN_TABLES}->[$indx]->{dsn} eq $self->{dsn});
	  $self->{GAEVAL_ANN_TABLES}->[$indx]->{dbh} = DBI->connect($self->{GAEVAL_ANN_TABLES}->[$indx]->{dsn,dbUSER,dbPASS},{ RaiseError => 1 }) if(!exists($self->{GAEVAL_ANN_TABLES}->[$indx]->{dbh}));
	  my $SQL = (exists($self->{GAEVAL_ANN_TABLES}->[$indx]->{ANNselect}))?$self->{GAEVAL_ANN_TABLES}->[$indx]->{ANNselect}:
	    "select uid,geneId,gene_structure,l_pos,r_pos,strand from $self->{GAEVAL_ANN_TABLES}->[$INDX]->{ANN_TBL}";
	  my $SQLcond = exists($self->{GAEVAL_ANN_TABLES}->[$indx]->{ANN_conditional})?$self->{GAEVAL_ANN_TABLES}->[$indx]->{ANN_conditional}:"";
	  $resAR = $self->{GAEVAL_ANN_TABLES}->[$indx]->{dbh}->selectall_arrayref($SQL . "where (($gsegID_SQL)&&(l_pos <= $Ilft)&&(r_pos >= $Irgt)&&((gene_structure RLIKE '${Ilft},$Irgt' )||(gene_structure RLIKE '${Irgt},$Ilft'))) ${SQLcond}");
	  $asiINFO_hr->{$intSTR}->{$ASItype}->{documented}->{$self->{GAEVAL_ANN_TABLES}->[$indx]->{ANN_TBL}} = $resAR if(scalar(@{$resAR}));
	}
      }
    }
  }

  ## Check for erroneously supported AltSpl (I.E. look for non-cognate ISO support)
  foreach $intSTR (keys %{$self->{BCNC_MATCHES}->{INTRONS_conflicting}}){
    if(exists($self->{BCNC_MATCHES}->{INTRONS_unsupported}->{$intSTR})){
      if(exists($self->{BCBN_MATCHES}->{INTRONS_confirmed}->{$intSTR})){
	$asiINFO_hr->{$intSTR}->{INTRONS_erroneous}->{ISO_PGS}->{BCBN_MATCHES} = $self->{BCBN_MATCHES}->{INTRONS_confirmed}->{$intSTR};
      }
      if(exists($self->{BCNN_MATCHES}->{INTRONS_confirmed}->{$intSTR})){
	$asiINFO_hr->{$intSTR}->{INTRONS_erroneous}->{ISO_PGS}->{BCNN_MATCHES} = $self->{BCBN_MATCHES}->{INTRONS_confirmed}->{$intSTR};
      }
    }
  }

  ## Compare annotation isoforms for documented AltSpl
  my %intronHASH = ();
  foreach my $ANNsrc (keys %{$self->{annIsoforms}}){
    %intronHASH = (%{$self->{BC_MATCHES}->{INTRONS_confirmed}},%{$self->{BC_MATCHES}->{INTRONS_unsupported}});
    foreach my $annIso (keys %{$self->{annIsoforms}->{$ANNsrc}}){
      foreach $intSTR (keys %{ $self->{annIsoforms}->{$ANNsrc}->{$annIso}->{intronHASH}}){
	delete($intronHASH{$intStr})if(exists($intronHASH{$intStr}));
      }
      foreach $intSTR (keys %intronHASH){
	my $Itype = (exists($self->{BC_MATCHES}->{INTRONS_confirmed}->{$intSTR}))?'confirmed':'unsupported';
	if(exists($asiINFO_hr->{$intSTR}->{INTRONS_alt_isoform}->{$Itype}->{$ANNsrc})){
	  push(@{$asiINFO_hr->{$intSTR}->{INTRONS_alt_isoform}->{$Itype}->{$ANNsrc}},$self->{annIsoforms}->{$ANNsrc}->{$annIso});
	}else{
	  $asiINFO_hr->{$intSTR}->{INTRONS_alt_isoform}->{$Itype}->{$ANNsrc} = [$self->{annIsoforms}->{$ANNsrc}->{$annIso}];
	}
      }
    }
  }

  return $asiINFO_hr;
}

sub _complexMRNA{ ## Includes fusion (pos. polycistronic), and fission (pos. alternative C/P site) events
  my $self = shift;
  my ($annUID) = @_;
  my ($cps,$strand,$CPS_DIFF_condition,$CPS_DIFF_CP_condition);

  print STDERR "&CFD_complexMRNA [gaeval_annotation.pm]\n" if(exists($self->{DEBUG_list_subs}));

  $self->loadANN($annUID);
  $self->gather_isoforms($annUID);
  
  my $cmINFO_hr = {CPSITES=>{}};
  my $MAX_CPS_divergence = 150; 
  my $MIN_CPS_groupsize = 2;

  #### [Future Additions]
  #### Check SAGE/MPSS tags for 3' group boundary
  #### Check ORF of fusion events to subclassify into (non/polycistronic)
  #### Check transcription initiation site prediction/identifier (reverseSAGE/reverseMPSS)
  #### Check translation inititation site prediction/identifier


  ## Check 3' TRANSCRIPT groups to determine Cleavage PolyA Site
  $strand = ($self->{ann_DBdata}->{strand} eq 'f')?2:1;
  if($self->group_TPS($cmINFO_hr->{CPSITES},$self->gather_TPS($annUID),$strand,$MAX_CPS_divergence,$MIN_CPS_groupsize)){
    foreach $cps (keys %{$cmINFO_hr->{CPSITES}}){

      ## Compare annotation isoforms for CPS documentation
      foreach my $ANNsrc (keys %{$self->{annIsoforms}}){
	foreach my $annIso (keys %{$self->{annIsoforms}->{$ANNsrc}}){
	  my $annIso_hr = $self->{annIsoforms}->{$ANNsrc}->{$annIso};
	  if(($annIso_hr->{strand} eq 'f')&&(abs($cps - $annIso_hr->{r_pos}) <= $MAX_CPS_divergence)||
	     ($annIso_hr->{strand} eq 'r')&&(abs($cps - $annIso_hr->{l_pos}) <= $MAX_CPS_divergence)){
	    $cmINFO_hr->{CPSITES}->{$cps}->{documented} = {} if(!exists($cmINFO_hr->{CPSITES}->{$cps}->{documented}));
	    $cmINFO_hr->{CPSITES}->{$cps}->{documented}->{$ANNsrc} = {} if(!exists($cmINFO_hr->{CPSITES}->{$cps}->{documented}->{$ANNsrc}));
	    $cmINFO_hr->{CPSITES}->{$cps}->{documented}->{$ANNsrc}->{$annIso} = $annIso_hr;
	  }
	}
      }

      if($self->{ann_DBdata}->{strand} eq 'f'){
	$CPS_DIFF_condition = "&& ($cps >= PGS.l_pos) && ($cps <= (PGS.r_pos - $MAX_CPS_divergence))";
	$CPS_DIFF_CP_condition = "&& ($cps >= PGS.l_pos) && ($cps <= (PGS2.r_pos - $MAX_CPS_divergence))";
      }else{
	$CPS_DIFF_condition = "&& (PGS.r_pos >= $cps) && ($cps >= (PGS.l_pos + $MAX_CPS_divergence))";
	$CPS_DIFF_CP_condition = "&& (PGS2.r_pos >= $cps) && ($cps >= (PGS2.l_pos + $MAX_CPS_divergence))";
      }
      
      for(my $x=0;$x<=$#{$self->{GAEVAL_ISO_TABLES}};$x++){
	## Check PGS-ISOs for single contiguous transcriptional unit
	my $resHR = $self->{dbh}->selectall_hashref("SELECT ISO.pgsUID,PGS.l_pos,PGS.r_pos,ISO.score FROM $self->{GAEVAL_ISO_TABLES}->[$x]->{ISO_TBL} as ISO JOIN $self->{GAEVAL_ISO_TABLES}->[$x]->{PGS_TBL} as PGS ON (ISO.pgsUID = PGS.uid) WHERE (ISO.annUID = $annUID) $CPS_DIFF_condition","pgsUID",{FetchHashKeyName => 'NAME_lc'});
	if(keys %$resHR){ $cmINFO_hr->{CPSITES}->{$cps}->{transcript_extensions} = $resHR;  }
	
	## Check clone pair ISOs for single contiguous transcriptional unit
	if(exists($self->{GAEVAL_ISO_TABLES}->[$x]->{_HAS_CLONEPAIRS}) && ($self->{GAEVAL_ISO_TABLES}->[$x]->{_HAS_CLONEPAIRS})){
	  $resHR = $self->{dbh}->selectall_hashref("select PGS.gi as leftEvidence,PGS2.gi as rightEvidence,PGS.l_pos,PGS2.r_pos FROM  $self->{GAEVAL_ISO_TABLES}->[$x]->{ISO_TBL} as ISO JOIN $self->{GAEVAL_ISO_TABLES}->[$x]->{PGS_TBL} as PGS ON (ISO.pgsUID = PGS.uid) JOIN $self->{GAEVAL_ISO_TABLES}->[$x]->{PGS_TBL} as PGS2 ON (PGS2.uid = PGS.pairUID) where (annUID = $annUID)&&(PGS.l_pos < PGS2.l_pos) $CPS_DIFF_CP_condition","leftEvidence",{FetchHashKeyName => 'NAME_lc'});
	  if(keys %$resHR){ $cmINFO_hr->{CPSITES}->{$cps}->{clonepair_extensions} = $resHR;  }
	  
	}
      }
      
      ## Assign Fission/AltCPS
      if((($self->{ann_DBdata}->{strand} eq 'f')&&(abs($self->{ann_DBdata}->{r_pos} - $cps) >= $MAX_CPS_divergence))||
	 (($self->{ann_DBdata}->{strand} eq 'r')&&(abs($self->{ann_DBdata}->{l_pos} - $cps) >= $MAX_CPS_divergence))){
	if((($self->{ann_DBdata}->{l_pos} < $cps)&&($self->{ann_DBdata}->{r_pos} > $cps))&&
	   (!exists($cmINFO_hr->{CPSITES}->{$cps}->{transcript_extensions}))&&(!exists($cmINFO_hr->{CPSITES}->{$cps}->{clonepair_extensions}))){
	  $cmINFO_hr->{CM_Fission} = {} if(!exists($cmINFO_hr->{CM_Fission}));
	  $cmINFO_hr->{CM_Fission}->{$cps} = $cmINFO_hr->{CPSITES}->{$cps};
	}else{
	  $cmINFO_hr->{CM_AltCPS} = {} if(!exists($cmINFO_hr->{CM_AltCPS}));
	  $cmINFO_hr->{CM_AltCPS}->{$cps} = $cmINFO_hr->{CPSITES}->{$cps};
	}
      }else{
	$cmINFO_hr->{CM_MainCPS} = {} if(!exists($cmINFO_hr->{MainCPS}));
	$cmINFO_hr->{CM_MainCPS}->{$cps} = $cmINFO_hr->{CPSITES}->{$cps};
      }

    }
  }

  for(my $x=0;$x<=$#{$self->{GAEVAL_ISO_TABLES}};$x++){
    ## Check multi-hit PGS-ISOs for fusion events
    my $resHR = $self->{dbh}->selectall_hashref("SELECT ISO.uid, ISO.annUID, ISO.pgsUID, PGS.gi as pgsGI, NIA.geneId, NIA.gene_structure, NIA.l_pos, NIA.r_pos FROM $self->{GAEVAL_ISO_TABLES}->[$x]->{ISO_TBL} as ISO JOIN $self->{GAEVAL_ISO_TABLES}->[$x]->{ISO_TBL} as ISO2 ON (ISO.pgsUID = ISO2.pgsUID) JOIN $self->{GAEVAL_ISO_TABLES}->[$x]->{PGS_TBL} as PGS ON ( PGS.uid = ISO.pgsUID) JOIN $self->{db_table} as NIA ON (ISO.annUID = NIA.uid) WHERE (ISO.uid != ISO2.uid)&&(ISO2.annUID = $annUID)&&(ISO2.multi = 1)&&(ISO.isCognate = 1)&&((ISO.intron_confirmed >= 1)||(ISO.annotation_coverage >= 0.5))&&(ISO2.isCognate = 1)&&((ISO2.intron_confirmed >= 1)||(ISO2.annotation_coverage >= 0.5))","uid",{FetchHashKeyName => 'NAME_lc'});
    foreach my $annHR (values %$resHR){
      next if(exists($self->{annIsoforms}->{LOCAL}->{$annHR->{annUID}}));
      $annHR->{GAEVAL_TABLES} = $self->{GAEVAL_ISO_TABLES}->[$x];
      $cmINFO_hr->{CM_Fusion} = {} if(!exists($cmINFO_hr->{CM_Fusion}));
      $cmINFO_hr->{CM_Fusion}->{$annHR->{annUID}} = {geneid => $annHR->{geneId}} if(!exists($cmINFO_hr->{CM_Fusion}->{$annHR->{annUID}}));
      $cmINFO_hr->{CM_Fusion}->{$annHR->{annUID}}->{PGS_bridged} = [] if(!exists($cmINFO_hr->{CM_Fusion}->{$annHR->{annUID}}->{PGS_bridged}));
      push(@{$cmINFO_hr->{CM_Fusion}->{$annHR->{annUID}}->{PGS_bridged}},$annHR);
      $cmINFO_hr->{CM_Fusion}->{$annHR->{annUID}}->{lpos} = (exists($cmINFO_hr->{CM_Fusion}->{$annHR->{annUID}}->{lpos}))?gaeval::min($cmINFO_hr->{CM_Fusion}->{$annHR->{annUID}}->{lpos},$annHR->{l_pos}):gaeval::min($annHR->{l_pos},$self->{ann_DBdata}->{l_pos});
      $cmINFO_hr->{CM_Fusion}->{$annHR->{annUID}}->{rpos} = (exists($cmINFO_hr->{CM_Fusion}->{$annHR->{annUID}}->{rpos}))?gaeval::max($cmINFO_hr->{CM_Fusion}->{$annHR->{annUID}}->{rpos},$annHR->{r_pos}):gaeval::max($annHR->{r_pos},$self->{ann_DBdata}->{r_pos});
    }

    if(exists($self->{GAEVAL_ISO_TABLES}->[$x]->{_HAS_CLONEPAIRS}) && ($self->{GAEVAL_ISO_TABLES}->[$x]->{_HAS_CLONEPAIRS})){
      ## Check clone pair ISOs for fusion events
      $resHR = $self->{dbh}->selectall_hashref("SELECT ISO.uid, ISO.annUID, ISO.pgsUID as s_pgsUID, ISO2.pgsUID as p_pgsUID, PGS.gi as sGI, PGS2.gi as pGI, NIA.geneId, NIA.gene_structure, NIA.l_pos, NIA.r_pos FROM $self->{GAEVAL_ISO_TABLES}->[$x]->{ISO_TBL} as ISO2 JOIN $self->{GAEVAL_ISO_TABLES}->[$x]->{PGS_TBL} as PGS2 ON (ISO2.pgsUID = PGS2.uid) JOIN $self->{GAEVAL_ISO_TABLES}->[$x]->{PGS_TBL} as PGS ON (PGS2.pairUID = PGS.uid) JOIN $self->{GAEVAL_ISO_TABLES}->[$x]->{ISO_TBL} as ISO ON (ISO.pgsUID = PGS.uid) JOIN $self->{db_table} as NIA ON (ISO.annUID = NIA.uid) WHERE (ISO2.annUID = $annUID)&&(ISO.annUID != ISO2.annUID)&&(ISO.isCognate = 1)&&(ISO2.isCognate = 1)&&((ISO.best > 0)||(ISO.intron_confirmed > 0)||(ISO.annotation_coverage >= 0.5))&&((ISO2.best > 0)||(ISO2.intron_confirmed > 0)||(ISO2.annotation_coverage >= 0.5))","uid",{FetchHashKeyName => 'NAME_lc'});
      foreach my $annHR (values %$resHR){
	next if(exists($self->{annIsoforms}->{LOCAL}->{$annHR->{annUID}}));
	$annHR->{GAEVAL_TABLES} = $self->{GAEVAL_ISO_TABLES}->[$x];
	$cmINFO_hr->{CM_Fusion} = {} if(!exists($cmINFO_hr->{CM_Fusion}));
	$cmINFO_hr->{CM_Fusion}->{$annHR->{annUID}} = {geneid => $annHR->{geneId}} if(!exists($cmINFO_hr->{CM_Fusion}->{$annHR->{annUID}}));
	$cmINFO_hr->{CM_Fusion}->{$annHR->{annUID}}->{CP_bridged} = [] if(!exists($cmINFO_hr->{CM_Fusion}->{$annHR->{annUID}}->{CP_bridged}));
	push(@{$cmINFO_hr->{CM_Fusion}->{$annHR->{annUID}}->{CP_bridged}},$annHR);
	$cmINFO_hr->{CM_Fusion}->{$annHR->{annUID}}->{lpos} = (exists($cmINFO_hr->{CM_Fusion}->{$annHR->{annUID}}->{lpos}))?gaeval::min($cmINFO_hr->{CM_Fusion}->{$annHR->{annUID}}->{lpos},$annHR->{l_pos}):gaeval::min($annHR->{l_pos},$self->{ann_DBdata}->{l_pos});
	$cmINFO_hr->{CM_Fusion}->{$annHR->{annUID}}->{rpos} = (exists($cmINFO_hr->{CM_Fusion}->{$annHR->{annUID}}->{rpos}))?gaeval::max($cmINFO_hr->{CM_Fusion}->{$annHR->{annUID}}->{rpos},$annHR->{r_pos}):gaeval::max($annHR->{r_pos},$self->{ann_DBdata}->{r_pos});
      }
    }
  }

  return $cmINFO_hr;
}

sub gather_isoforms{
  my $self = shift;
  my ($annUID) = @_;
  my $annINFO_hr = {LOCAL=>{}};
  my $aiINFO_hr = {};

  my $MIN_ISOFORM_OVERLAP = 1000;

  $self->loadANN($annUID);
  return $self->{annIsoforms} if (exists($self->{annIsoforms}));
  my $gsegID_SQL = (exists($self->{ann_DBdata}->{chr}))?"chr = $self->{ann_DBdata}->{chr}":"gseg_gi = $self->{ann_DBdata}->{gseg_gi}";
  
  my ($in);
  $annINFO_hr->{LOCAL}->{$self->{ann_DBdata}->{uid}} = {intronHASH => {}};
  my $str = $self->{ann_DBdata}->{gene_structure};
  $str =~ s/^\D+//;
  $str =~ s/\D+$//;
  $str =~ s/,+/:/g;
  my @introns = split(/[\s\.]+/,$str);
  foreach $in (@introns){
    $annINFO_hr->{LOCAL}->{$self->{ann_DBdata}->{uid}}->{intronHASH}->{$in} = 1;
  }

  ## Local annotation isoforms
  my $resAR = $self->{dbh}->selectall_arrayref("select uid,geneId,gene_structure,l_pos,r_pos,strand from $self->{db_table} where (($gsegID_SQL)&&(uid != $annUID)&&(l_pos <= $self->{ann_DBdata}->{r_pos})&&(r_pos >= $self->{ann_DBdata}->{l_pos}))");
  foreach my $annAR (@$resAR){
    $annINFO_hr->{LOCAL}->{$annAR->[0]} = {intronHASH =>{}};
    $str = $annAR->[2];
    $str =~ s/^\D+//;
    $str =~ s/\D+$//;
    $str =~ s/,+/:/g;
    @introns = split(/[\s\.]+/,$str);
    foreach $in (@introns){
      $annINFO_hr->{LOCAL}->{$annAR->[0]}->{intronHASH}->{$in} = 1;
      if((!exists($aiINFO_hr->{LOCAL}) || !exists($aiINFO_hr->{LOCAL}->{$annAR->[0]})) && 
	 (exists($annINFO_hr->{LOCAL}->{$annUID}->{intronHASH}->{$in}) ||
	  ((gaeval::min($self->{ann_DBdata}->{r_pos},$annAR->[4]) - gaeval::max($self->{ann_DBdata}->{l_pos},$annAR->[3])) > $MIN_ISOFORM_OVERLAP))){
	$aiINFO_hr->{LOCAL} = {} if(!exists($aiINFO_hr->{LOCAL}));
	$aiINFO_hr->{LOCAL}->{$annAR->[0]} = {geneid=>$annAR->[1],gene_structure=>$annAR->[2],
					    l_pos=>$annAR->[3],r_pos=>$annAR->[4],strand=>$annAR->[5],
					    intronHASH=>$annINFO_hr->{LOCAL}->{$annAR->[0]}->{intronHASH}
					   };
      }
    }
  }

  ## External annotation isoforms
  if(exists($self->{GAEVAL_ANN_TABLES})){
    for(my $indx=0;$indx <= $#{$self->{GAEVAL_ANN_TABLES}};$indx++){
      next if($self->{GAEVAL_ANN_TABLES}->[$indx]->{ANN_TBL} eq $self->{db_table});
      next if($self->{GAEVAL_ANN_TABLES}->[$indx]->{dsn} eq $self->{dsn});
      $self->{GAEVAL_ANN_TABLES}->[$indx]->{dbh} = DBI->connect($self->{GAEVAL_ANN_TABLES}->[$indx]->{dsn,dbUSER,dbPASS},{ RaiseError => 1 }) if(!exists($self->{GAEVAL_ANN_TABLES}->[$indx]->{dbh}));
      my $SQL = (exists($self->{GAEVAL_ANN_TABLES}->[$indx]->{ANNselect}))?$self->{GAEVAL_ANN_TABLES}->[$indx]->{ANNselect}:
	"select uid,geneId,gene_structure,l_pos,r_pos,strand from $self->{GAEVAL_ANN_TABLES}->[$INDX]->{ANN_TBL}";
      my $SQLcond = exists($self->{GAEVAL_ANN_TABLES}->[$indx]->{ANN_conditional})?$self->{GAEVAL_ANN_TABLES}->[$indx]->{ANN_conditional}:"";
      $resAR = $self->{GAEVAL_ANN_TABLES}->[$indx]->{dbh}->selectall_arrayref("$SQL where (($gsegID_SQL)&&(l_pos <= $self->{ann_DBdata}->{r_pos})&&(r_pos >= $self->{ann_DBdata}->{l_pos})) ${SQLcond}");
      foreach my $annAR (@$resAR){
	$annINFO_hr->{$self->{GAEVAL_ANN_TABLES}->[$INDX]->{ANN_TBL}} = {} if(!exists($annINFO_hr->{$self->{GAEVAL_ANN_TABLES}->[$INDX]->{ANN_TBL}}));
	$annINFO_hr->{$self->{GAEVAL_ANN_TABLES}->[$INDX]->{ANN_TBL}}->{$annAR->[0]} = {intronHASH =>{}};
	$str = $annAR->[2];
	$str =~ s/^\D+//;
	$str =~ s/\D+$//;
	$str =~ s/,+/:/g;
	@introns = split(/\s+/,$str);
	foreach $in (@introns){
	  $annINFO_hr->{$self->{GAEVAL_ANN_TABLES}->[$INDX]->{ANN_TBL}}->{$annAR->[0]}->{intronHASH}->{$in} = 1;
	  if((!exists($aiINFO_hr->{$self->{GAEVAL_ANN_TABLES}->[$INDX]->{ANN_TBL}}) || 
	      !exists($aiINFO_hr->{$self->{GAEVAL_ANN_TABLES}->[$INDX]->{ANN_TBL}}->{$annAR->[0]})) && 
	     (exists($annINFO_hr->{LOCAL}->{$annUID}->{intronHASH}->{$in}) ||
	      ((gaeval::min($self->{ann_DBdata}->{r_pos},$annAR->[4]) - gaeval::max($self->{ann_DBdata}->{l_pos},$annAR->[3])) > $MIN_ISOFORM_OVERLAP))){
	    $aiINFO_hr->{$self->{GAEVAL_ANN_TABLES}->[$INDX]->{ANN_TBL}} = {} if(!exists($aiINFO_hr->{$self->{GAEVAL_ANN_TABLES}->[$INDX]->{ANN_TBL}}));
	    $aiINFO_hr->{$self->{GAEVAL_ANN_TABLES}->[$INDX]->{ANN_TBL}}->{$annAR->[0]} = {geneid=>$annAR->[1],gene_structure=>$annAR->[2],
										       l_pos=>$annAR->[3],r_pos=>$annAR->[4],strand=>$annAR->[5],
										       intronHASH=>$annINFO_hr->{$self->{GAEVAL_ANN_TABLES}->[$INDX]->{ANN_TBL}}->{$annAR->[0]}->{intronHASH}
										      };
	  }
	}
      }
    }
  }
  
  return $self->{annIsoforms} = $aiINFO_hr;
}

sub gather_TPS{
  my $self = shift;
  my ($annUID) = @_;

  print STDERR "&gather_TPS [gaeval_annotation.pm]\n" if(exists($self->{DEBUG_list_subs}));

  my ($resAR,@tps,$sqlcmd);
  for($x=0;$x<=$#{$self->{GAEVAL_ISO_TABLES}};$x++){
#    $sqlcmd = "SELECT PGS.gi, PGS.l_pos, PGS.r_pos FROM $self->{GAEVAL_ISO_TABLES}->[$x]->{ISO_TBL} as ISO JOIN $self->{GAEVAL_ISO_TABLES}->[$x]->{PGS_TBL} as PGS ON (ISO.pgsUID = PGS.uid) JOIN  $self->{GAEVAL_ISO_TABLES}->[$x]->{SEQ_TBL} as SEQ ON (PGS.gi = SEQ.gi) WHERE(ISO.annUID = $annUID)&&(ISO.best >= 1)&&(ISO.isCognate = 1) ";
    $sqlcmd = "SELECT PGS.gi, PGS.l_pos, PGS.r_pos FROM $self->{GAEVAL_ISO_TABLES}->[$x]->{ISO_TBL} as ISO JOIN $self->{GAEVAL_ISO_TABLES}->[$x]->{PGS_TBL} as PGS ON (ISO.pgsUID = PGS.uid) JOIN  $self->{GAEVAL_ISO_TABLES}->[$x]->{SEQ_TBL} as SEQ ON (PGS.gi = SEQ.gi) WHERE(ISO.annUID = $annUID)&&(ISO.isCognate = 1) ";
    $sqlcmd .= (exists($self->{GAEVAL_ISO_TABLES}->[$x]->{TPS_conditional}))?$self->{GAEVAL_ISO_TABLES}->[$x]->{TPS_conditional}:"&&((SEQ.type = 'T')||(SEQ.type = 'B'))";
    $resAR = $self->{dbh}->selectall_arrayref($sqlcmd);
    push(@tps,@$resAR);
  }

  return \@tps;
}

1;

