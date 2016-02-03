package gaeval::sql;

use base gaeval::xgdb;

use Data::Dumper; ## Used to serialize property data structures

sub PROCHOOK_ANN_UID_LOOP{
  my $self = shift;
  my ($procAR) = @_;

  foreach my $proc (@{$procAR}){ &{$proc}($self); }

}

sub analyze{
  my $self = shift;
  my ($argHR) = @_;

  $self->create_GAEVAL_SUPPORT_TBL();
  $self->create_GAEVAL_PROPERTIES_TBL();
  
  my $uid_aref = $self->{dbh}->selectcol_arrayref("Select uid from $self->{db_table} ORDER by geneId");
  foreach my $x (@{$uid_aref}){
    #print STDERR "working on $x of " . scalar(@{$uid_aref}) . "\n" if(($x > 999)&&(($x % 1000) == 0));
    $self->update_GaevalSupport_TBL($x);
    $self->update_GaevalProperties_TBL($x);

    $self->PROCHOOK_ANN_UID_LOOP($argHR->{ANN_UID_LOOP_PROCS}) if(exists($argHR->{ANN_UID_LOOP_PROCS}));
  }

}

sub initializeDB{
  my $self = shift;
  $self->create_GAEVAL_ANNOTATION_TBL();
  foreach my $ISO_TABLE_HR (@{$self->{GAEVAL_ISO_TABLES}}){
    $self->create_GAEVAL_EVIDENCE_TBL($ISO_TABLE_HR->{SEQ_TBL})if(exists($ISO_TABLE_HR->{SEQ_TBL}));
    $self->create_GAEVAL_ALIGNMENT_TBL($ISO_TABLE_HR->{PGS_TBL})if(exists($ISO_TABLE_HR->{PGS_TBL}));
  }
}

sub create_GAEVAL_ANNOTATION_TBL{
  my $self = shift;
  
  $self->{db_table} = "gaeval_annotation" if(! exists($self->{db_table}));

  my $GAEVAL_ANNOTATION_CREATE_TBL = qq{(
  `uid` int(10) unsigned NOT NULL auto_increment,
  `gseg_gi` int(10) unsigned NOT NULL default '0',
  `geneId` varchar(32) NOT NULL default '',
  `strand` enum('f','r') NOT NULL default 'f',
  `l_pos` int(10) unsigned NOT NULL default '0',
  `r_pos` int(10) unsigned NOT NULL default '0',
  `gene_structure` text NOT NULL,
  `CDSstart` int(20) unsigned default NULL,
  `CDSstop` int(20) unsigned default NULL,
  PRIMARY KEY  (`uid`),
  KEY `chrGAgidIND` (`geneId`),
  KEY `gsegGAchrIND` (`gseg_gi`),
  KEY `chrGAlftIND` (`l_pos`),
  KEY `chrGArgtIND` (`r_pos`)
)};

  $self->{dbh}->do("DROP TABLE IF EXISTS $self->{db_table}");
  return $self->{dbh}->do("CREATE TABLE $self->{db_table} $GAEVAL_ANNOTATION_CREATE_TBL");
}

sub create_GAEVAL_EVIDENCE_TBL{
  my $self = shift;
  my($tablename) = @_;

  my $GAEVAL_EVIDENCE_CREATE_TBL = qq{(
  `gi` int(10) unsigned NOT NULL default '0',
  `acc` varchar(32) NOT NULL default '',
  `locus` varchar(32) default NULL,
  `type` enum('F','T','B','U') default 'U',
  PRIMARY KEY  (`gi`),
  KEY `est_accIND` (`acc`),
  KEY `est_Locus` (`locus`)
)};

  $self->{dbh}->do("DROP TABLE IF EXISTS $tablename");
  return $self->{dbh}->do("CREATE TABLE $tablename $GAEVAL_EVIDENCE_CREATE_TBL");
}

sub create_GAEVAL_ALIGNMENT_TBL{
  my $self = shift;
  my($tablename) = @_;

  my $GAEVAL_ALIGNMENT_CREATE_TBL = qq{(
  `uid` int(10) unsigned NOT NULL auto_increment,
  `gi` int(10) unsigned NOT NULL default '0',
  `gseg_gi` int(10) unsigned NOT NULL default '0',
  `G_O` enum('+','-','?') NOT NULL default '+',
  `l_pos` int(10) unsigned NOT NULL default '0',
  `r_pos` int(10) unsigned NOT NULL default '0',
  `pgs` text NOT NULL,
  `isCognate` enum('True','False') NOT NULL default 'True',
  `pairUID` varchar(50) default NULL,
  PRIMARY KEY  (`uid`),
  KEY `gpiC` (`gseg_gi`),
  KEY `giIND` (`gi`),
  KEY `egpIND_lpos` (`l_pos`),
  KEY `egpIND_rpos` (`r_pos`)
)};

  $self->{dbh}->do("DROP TABLE IF EXISTS $tablename");
  return $self->{dbh}->do("CREATE TABLE $tablename $GAEVAL_ALIGNMENT_CREATE_TBL");
}

sub create_GAEVAL_SUPPORT_TBL{
  my $self = shift;
  
  $self->{GAEVAL_SUPPORT_TBL} = $self->{db_table} . "_gaeval" if (! exists($self->{GAEVAL_SUPPORT_TBL}));

  my $GAEVAL_SUPPORT_CREATE_TBL = qq{(
  `uid` int(11) NOT NULL default '0',
  `integrity` float unsigned default null,
  `introns_confirmed` tinyint(3) unsigned NOT NULL default '0',
  `introns_unsupported` tinyint(3) unsigned NOT NULL default '0',
  `cds_size` int(11) NOT NULL default '0',
  `utr5_size` int(11) NOT NULL default '0',
  `utr3_size` int(11) NOT NULL default '0',
  `bound_5prime` int(11) NOT NULL default '0',
  `bound_3prime` int(11) NOT NULL default '0',
  `exon_coverage` float unsigned NOT NULL default '0',
  `BCBN_introns_confirmed` tinyint(3) unsigned NOT NULL default '0',
  `BCBN_introns_unsupported` tinyint(3) unsigned NOT NULL default '0',
  `BCBN_bound_5prime` int(11) NOT NULL default '0',
  `BCBN_bound_3prime` int(11) NOT NULL default '0',
  `BCBN_exon_coverage` float unsigned NOT NULL default '0',
  `BCNC_introns_confirmed` tinyint(3) unsigned NOT NULL default '0',
  `BCNC_introns_unsupported` tinyint(3) unsigned NOT NULL default '0',
  `BCNC_bound_5prime` int(11) NOT NULL default '0',
  `BCNC_bound_3prime` int(11) NOT NULL default '0',
  `BCNC_exon_coverage` float unsigned NOT NULL default '0',
  `BCNN_introns_confirmed` tinyint(3) unsigned NOT NULL default '0',
  `BCNN_introns_unsupported` tinyint(3) unsigned NOT NULL default '0',
  `BCNN_bound_5prime` int(11) NOT NULL default '0',
  `BCNN_bound_3prime` int(11) NOT NULL default '0',
  `BCNN_exon_coverage` float unsigned NOT NULL default '0',
  UNIQUE KEY `uid` (`uid`),
  KEY `ec1` (`exon_coverage`),
  KEY `ec2` (`BCBN_exon_coverage`),
  KEY `ec3` (`BCNC_exon_coverage`),
  KEY `ec4` (`BCNN_exon_coverage`)
)
};
  ## initialize GAEVAL SUPPORT TABLE
  $self->{dbh}->do("DROP TABLE IF EXISTS $self->{GAEVAL_SUPPORT_TBL}");
  return $self->{dbh}->do("CREATE TABLE $self->{GAEVAL_SUPPORT_TBL} $GAEVAL_SUPPORT_CREATE_TBL");
}
  

sub load_GAEVAL_SUPPORT_TBL{
  my $self = shift;
  
  $self->create_GAEVAL_SUPPORT_TBL();

  my $uid_aref = $self->{dbh}->selectcol_arrayref("Select uid from $self->{db_table} ORDER by uid");
  foreach my $x (@{$uid_aref}){
    #print STDERR "working on $x of " . scalar(@{$uid_aref}) . "\n" if(($x > 999)&&(($x % 1000) == 0));
    &update_GaevalSupport_TBL($self,$x);
  }

  return 1;
}

sub update_GaevalSupport_TBL{
  my $self = shift;
  my ($annUID) = @_;

  print STDERR "&update_GaevalSupport_TBL [gaeval_annotation.pm]\n" if(exists($self->{DEBUG_list_subs}));

  ## Evaluate Annotated Structure
  $self->eval_annotation_support($annUID);

  my $SQL = qq{INSERT INTO $self->{GAEVAL_SUPPORT_TBL} 
	       (uid,integrity,
		introns_confirmed,introns_unsupported,
		cds_size,utr5_size,utr3_size,
		bound_5prime,bound_3prime,exon_coverage,
		BCBN_introns_confirmed,BCBN_introns_unsupported,
		BCBN_bound_5prime,BCBN_bound_3prime,BCBN_exon_coverage,
		BCNC_introns_confirmed,BCNC_introns_unsupported,
		BCNC_bound_5prime,BCNC_bound_3prime,BCNC_exon_coverage,
		BCNN_introns_confirmed,BCNN_introns_unsupported,
		BCNN_bound_5prime,BCNN_bound_3prime,BCNN_exon_coverage
	       )
	      };
  $SQL .= " VALUES ( $annUID,";

  my ($integ,$cds_size,$utr5_size,$utr3_size) = $self->calc_integrity();
  if(defined($integ)){ $SQL .= "'$integ',"; }else{ $SQL .= "null,";  }
  
  if(exists($self->{BC_MATCHES}->{INTRONS_confirmed})){
    $SQL .= scalar(keys(%{$self->{BC_MATCHES}->{INTRONS_confirmed}})) . ",";
    if(exists($self->{BC_MATCHES}->{INTRONS_unsupported})){
      $SQL .=  scalar(keys(%{$self->{BC_MATCHES}->{INTRONS_unsupported}})) . ",";
    }else{ $SQL .= "0,"; }
  }else{ $SQL .= "0," . ((scalar(@{$self->{ann_STRUCTURE}}) / 2) - 1) . ","; }

  $SQL .= "${cds_size},${utr5_size},${utr3_size},";

  if(exists($self->{BC_MATCHES}->{BOUND_5prime})){
    $SQL .= $self->{BC_MATCHES}->{BOUND_5prime} .",";
  }else{ $SQL .= "0,"; }
  
  if(exists($self->{BC_MATCHES}->{BOUND_3prime})){
    $SQL .= $self->{BC_MATCHES}->{BOUND_3prime} . ",";
  }else{ $SQL .= "0,"; }
  
  if(exists($self->{BC_MATCHES}->{EXON_coverage})){
    $SQL .= $self->{BC_MATCHES}->{EXON_coverage} . ",";
  }else{ $SQL .= "0,"; }


  if(exists($self->{BCBN_MATCHES}->{INTRONS_confirmed})){
    $SQL .= scalar(keys(%{$self->{BCBN_MATCHES}->{INTRONS_confirmed}})) . ",";
    if(exists($self->{BCBN_MATCHES}->{INTRONS_unsupported})){
      $SQL .=  scalar(keys(%{$self->{BCBN_MATCHES}->{INTRONS_unsupported}})) . ",";
    }else{ $SQL .= "0,"; }
  }else{ $SQL .= "0," . ((scalar(@{$self->{ann_STRUCTURE}}) / 2) - 1) . ","; }

  if(exists($self->{BCBN_MATCHES}->{BOUND_5prime})){
    $SQL .= $self->{BCBN_MATCHES}->{BOUND_5prime} .",";
  }else{ $SQL .= "0,"; }
  
  if(exists($self->{BCBN_MATCHES}->{BOUND_3prime})){
    $SQL .= $self->{BCBN_MATCHES}->{BOUND_3prime} . ",";
  }else{ $SQL .= "0,"; }
  
  if(exists($self->{BCBN_MATCHES}->{EXON_coverage})){
    $SQL .= $self->{BCBN_MATCHES}->{EXON_coverage} . ",";
  }else{ $SQL .= "0,"; }
  

  if(exists($self->{BCNC_MATCHES}->{INTRONS_confirmed})){
    $SQL .= scalar(keys(%{$self->{BCNC_MATCHES}->{INTRONS_confirmed}})) . ",";
    if(exists($self->{BCNC_MATCHES}->{INTRONS_unsupported})){
      $SQL .=  scalar(keys(%{$self->{BCNC_MATCHES}->{INTRONS_unsupported}})) . ",";
    }else{ $SQL .= "0,"; }
  }else{ $SQL .= "0," . ((scalar(@{$self->{ann_STRUCTURE}}) / 2) - 1) . ","; }

  if(exists($self->{BCNC_MATCHES}->{BOUND_5prime})){
    $SQL .= $self->{BCNC_MATCHES}->{BOUND_5prime} .",";
  }else{ $SQL .= "0,"; }
  
  if(exists($self->{BCNC_MATCHES}->{BOUND_3prime})){
    $SQL .= $self->{BCNC_MATCHES}->{BOUND_3prime} . ",";
  }else{ $SQL .= "0,"; }
  
  if(exists($self->{BCNC_MATCHES}->{EXON_coverage})){
    $SQL .= $self->{BCNC_MATCHES}->{EXON_coverage} . ",";
  }else{ $SQL .= "0,"; }


  if(exists($self->{BCNN_MATCHES}->{INTRONS_confirmed})){
    $SQL .= scalar(keys(%{$self->{BCNN_MATCHES}->{INTRONS_confirmed}})) . ",";
    if(exists($self->{BCNN_MATCHES}->{INTRONS_unsupported})){
      $SQL .=  scalar(keys(%{$self->{BCNN_MATCHES}->{INTRONS_unsupported}})) . ",";
    }else{ $SQL .= "0,"; }
  }else{ $SQL .= "0," . ((scalar(@{$self->{ann_STRUCTURE}}) / 2) - 1) . ","; }

  if(exists($self->{BCNN_MATCHES}->{BOUND_5prime})){
    $SQL .= $self->{BCNN_MATCHES}->{BOUND_5prime} .",";
  }else{ $SQL .= "0,"; }
  
  if(exists($self->{BCNN_MATCHES}->{BOUND_3prime})){
    $SQL .= $self->{BCNN_MATCHES}->{BOUND_3prime} . ",";
  }else{ $SQL .= "0,"; }
  
  if(exists($self->{BCNN_MATCHES}->{EXON_coverage})){
    $SQL .= $self->{BCNN_MATCHES}->{EXON_coverage} . ",";
  }else{ $SQL .= "0,"; }

  chop($SQL);
  $SQL .= " )";
  

  $self->{dbh}->do("DELETE FROM $self->{GAEVAL_SUPPORT_TBL} WHERE uid = $annUID");
  $self->{dbh}->do($SQL);
}  

sub create_GAEVAL_PROPERTIES_TBL{
  my $self = shift;
  
  $self->{GAEVAL_PROPERTIES_TBL} = $self->{db_table} . "_properties" if (! exists($self->{GAEVAL_PROPERTIES_TBL}));

  my $GAEVAL_PROPERTIES_CREATE_TBL = qq{(
  `uid` int(10) unsigned NOT NULL auto_increment,				     
  `annUID` int(10) NOT NULL default '0',
  `property` varchar(32) NOT NULL default 'Unknown',
  `score` float NOT NULL default '0',				   
  `lpos` int(10) NOT NULL default '0',
  `rpos` int(10) NOT NULL default '0',
  `documented` int(10) NOT NULL default '0',
  `data` longblob default NULL,
  PRIMARY KEY `uid` (`uid`),
  KEY `auIND` (`AnnUID`),
  KEY `propIND` (`property`),
  KEY `posIND` (`lpos`,`rpos`)
  )};

  ## initialize GAEVAL SUPPORT TABLE
  $self->{dbh}->do("DROP TABLE IF EXISTS $self->{GAEVAL_PROPERTIES_TBL}");
  return $self->{dbh}->do("CREATE TABLE $self->{GAEVAL_PROPERTIES_TBL} $GAEVAL_PROPERTIES_CREATE_TBL");

}

sub load_GAEVAL_PROPERTIES_TBL{
  my $self = shift;

  $self->create_GAEVAL_PROPERTIES_TBL();

  my $uid_aref = $self->{dbh}->selectcol_arrayref("Select uid from $self->{db_table} ORDER by uid");
  foreach my $x (@{$uid_aref}){
    #print STDERR "working on $x of " . scalar(@{$uid_aref}) . "\n" if(($x > 999)&&(($x % 1000) == 0));
    &update_GaevalProperties_TBL($self,$x);
  }

  return 1;
}

sub update_GaevalProperties_TBL{
  my $self = shift;
  my ($annUID) = @_;
  
  $self->{dbh}->do("DELETE FROM $self->{GAEVAL_PROPERTIES_TBL} WHERE annUID = $annUID");
  my $SQLins = qq{INSERT INTO $self->{GAEVAL_PROPERTIES_TBL} 
		  (uid,annUID,property,score,lpos,rpos,documented,data)
		 };

  ## Check for Alternative Splicing
  my $asiINFO_hr = $self->_altSplicing($annUID);
  $self->{asiINFO} = $asiINFO_hr;
  foreach my $intSTR (keys(%{$asiINFO_hr})){
    my ($lpos,$rpos) = sort {return $a<=>$b;} split(':',$intSTR);
    if(exists($asiINFO_hr->{$intSTR}->{INTRONS_alternative})){
      my $score = $asiINFO_hr->{$intSTR}->{INTRONS_alternative}->{score}; 
      my $doc = (exists($asiINFO_hr->{$intSTR}->{INTRONS_alternative}->{documented}))?(exists($asiINFO_hr->{$intSTR}->{INTRONS_alternative}->{documented}->{LOCAL}))?-1:1:0;
      my $data = Data::Dumper->Dump([$asiINFO_hr->{$intSTR}->{INTRONS_alternative}],['asiINFO_hr->{' . $intSTR . '}->{INTRONS_alternative}']); 
      $self->{dbh}->do("$SQLins VALUES (0,$annUID,'AS_AltIntron',$score,$lpos,$rpos,$doc,\"$data\")");
    }
    if(exists($asiINFO_hr->{$intSTR}->{INTRONS_additional})){
      my $score = $asiINFO_hr->{$intSTR}->{INTRONS_additional}->{score}; 
      my $doc = (exists($asiINFO_hr->{$intSTR}->{INTRONS_additional}->{documented}))?(exists($asiINFO_hr->{$intSTR}->{INTRONS_additional}->{documented}->{LOCAL}))?-1:1:0;
      my $data = Data::Dumper->Dump([$asiINFO_hr->{$intSTR}->{INTRONS_additional}],['asiINFO_hr->{' . $intSTR . '}->{INTRONS_additional}']); 
      $self->{dbh}->do("$SQLins VALUES (0,$annUID,'AS_AddIntron',$score,$lpos,$rpos,$doc,\"$data\")");
    }
    if(exists($asiINFO_hr->{$intSTR}->{INTRONS_conflicting})){
      my $score = $asiINFO_hr->{$intSTR}->{INTRONS_conflicting}->{score}; 
      my $doc = (exists($asiINFO_hr->{$intSTR}->{INTRONS_conflicting}->{documented}))?(exists($asiINFO_hr->{$intSTR}->{INTRONS_conflicting}->{documented}->{LOCAL}))?-1:1:0;
      my $data = Data::Dumper->Dump([$asiINFO_hr->{$intSTR}->{INTRONS_conflicting}],['asiINFO_hr->{' . $intSTR . '}->{INTRONS_conflicting}']); 
      $self->{dbh}->do("$SQLins VALUES (0,$annUID,'AS_ConIntron',$score,$lpos,$rpos,$doc,\"$data\")");
    }
    if(exists($asiINFO_hr->{$intSTR}->{INTRONS_erroneous})){
      my $data = Data::Dumper->Dump([$asiINFO_hr->{$intSTR}->{INTRONS_erroneous}],['asiINFO_hr->{' . $intSTR . '}->{INTRONS_erroneous}']); 
      $self->{dbh}->do("$SQLins VALUES (0,$annUID,'AS_PseudoIntron',1,$lpos,$rpos,0,\"$data\")");
    }
    if(exists($asiINFO_hr->{$intSTR}->{INTRONS_alt_isoform})){
      my $doc = (exists($asiINFO_hr->{$intSTR}->{INTRONS_alt_isoform}->{confirmed}))?(exists($asiINFO_hr->{$intSTR}->{INTRONS_alt_isoform}->{confirmed}->{LOCAL}))?-1:1:0;
      my $data = Data::Dumper->Dump([$asiINFO_hr->{$intSTR}->{INTRONS_alt_isoform}],['asiINFO_hr->{' . $intSTR . '}->{INTRONS_alt_isoform}']); 
      $self->{dbh}->do("$SQLins VALUES (0,$annUID,'AS_AltAnnIntron',1,$lpos,$rpos,$doc,\"$data\")");
    }
  }

  ## Check for complexMRNA
  my $cmINFO_hr = $self->_complexMRNA($annUID);
  $self->{cmINFO} = $cmINFO_hr;
  foreach my $cmPROP ('CM_AltCPS','CM_Fission','CM_MainCPS'){
    foreach my $cps (keys(%{$cmINFO_hr->{$cmPROP}})){
      my $score = exists($cmINFO_hr->{$cmPROP}->{$cps}->{score})?$cmINFO_hr->{$cmPROP}->{$cps}->{score}:1; 
      my $doc = (exists($cmINFO_hr->{$cmPROP}->{$cps}->{documented}))?
	         exists($cmINFO_hr->{$cmPROP}->{$cps}->{documented}->{LOCAL})?-1:1:0;
      my $data = Data::Dumper->Dump([$cmINFO_hr->{$cmPROP}->{$cps}],['cmINFO_hr->{' . $cmPROP .'}->{' . $cps . '}']); 
      $self->{dbh}->do("$SQLins VALUES (0,$annUID,'$cmPROP',$score,$cps,$cps,$doc,\"$data\")");
    }
  }
  foreach my $fusdan (keys(%{$cmINFO_hr->{CM_Fusion}})){
    my $score = exists($cmINFO_hr->{CM_Fusion}->{$fusdan}->{score})?$cmINFO_hr->{CM_Fusion}->{$fusdan}->{score}:1;
    my $doc = exists($cmINFO_hr->{CM_Fusion}->{$fusdan}->{PGS_bridged})?1:0;
    my $lpos = exists($cmINFO_hr->{CM_Fusion}->{$fusdan}->{lpos})?$cmINFO_hr->{CM_Fusion}->{$fusdan}->{lpos}:0;
    my $rpos = exists($cmINFO_hr->{CM_Fusion}->{$fusdan}->{rpos})?$cmINFO_hr->{CM_Fusion}->{$fusdan}->{rpos}:0;
    my $data = Data::Dumper->Dump([$cmINFO_hr->{CM_Fusion}->{$fusdan}],['cmINFO_hr->{CM_Fusion}->{' . $fusdan . '}']);
    $self->{dbh}->do("$SQLins VALUES (0,$annUID,'CM_Fusion',$score,$lpos,$rpos,$doc,\"$data\")");
  }


  ## Check for AMBboundary
  my $aoaINFO_hr = $self->_AMBboundary($annUID);
  $self->{aoaINFO} = $aoaINFO_hr;
  foreach my $aoa (keys(%{$aoaINFO_hr->{AMB_annotations}})){
    my $score = scalar(keys(%{$aoaINFO_hr->{AMB_annotations}}));  #?#
    my ($lpos,$rpos,$doc) = (0,0,0);             #?#
    my $data = Data::Dumper->Dump([$aoaINFO_hr->{AMB_annotations}->{$aoa}],['aoaINFO_hr->{AMB_annotations}->{' . $aoa . '}']); 
    $self->{dbh}->do("$SQLins VALUES (0,$annUID,'AE_AmbOverlap',$score,$lpos,$rpos,$doc,\"$data\")");
  }
}

sub seed_ALL_ISO_TBLS{
  my $self = shift;

  foreach $ISOpair (@{$self->{GAEVAL_ISO_TABLES}}){
    &seed_ISO_TBL($self,$ISOpair);
    &mark_ISO_TBL($self,$ISOpair);
  }

  return 1;
}

sub seed_ISO_TBL{
  my $self = shift;
  my ($ISOpair) = @_;

  my $ISO_CREATE_TBL = qq{(
  `uid` int(10) unsigned NOT NULL auto_increment,
  `annUID` int(10) unsigned NOT NULL default '0',
  `pgsUID` int(10) unsigned NOT NULL default '0',
  `multi` tinyint(4) NOT NULL default '1',
  `best` tinyint(4) NOT NULL default '0',
  `isCognate` tinyint(3) unsigned NOT NULL default '0',
  `score` tinyint(3) unsigned NOT NULL default '0',
  `intron_confirmed` tinyint(3) unsigned default '0',
  `intron_additional` tinyint(3) unsigned default '0',
  `intron_alternative` tinyint(3) unsigned default '0',
  `intron_conflicting` tinyint(3) unsigned default '0',
  `annotation_coverage` float unsigned default '0',
  `pgs_coverage` float unsigned default '0',
  PRIMARY KEY  (`uid`),
  KEY `auidINDX` (`annUID`),
  KEY `puidINDX` (`pgsUID`),
  KEY `scoreINDX` (`score`)
)};

  my ($ANNsth,$ANNaref,$PGSsth,$PGSaref,%MATCHprops);
  my $ANNselect = exists($self->{GAEVAL_ANNselect})?$self->{GAEVAL_ANNselect}:"select uid,gene_structure,gseg_gi,l_pos,r_pos FROM $self->{db_table} ORDER BY gseg_gi,l_pos,r_pos";
  $ANNsth = $self->{dbh}->prepare($ANNselect);
  $ANNsth->execute();
  $ANNaref = $ANNsth->fetchall_arrayref();
  
  ## initialize ISO TABLE
  $self->{dbh}->do("DROP TABLE IF EXISTS $ISOpair->{ISO_TBL}");
  $self->{dbh}->do("CREATE TABLE $ISOpair->{ISO_TBL} $ISO_CREATE_TBL");
  
  my $PGSselect = exists($ISOpair->{PGSselect})?$ISOpair->{PGSselect}:"select uid,pgs,gseg_gi,l_pos,r_pos,isCognate FROM $ISOpair->{PGS_TBL} ORDER BY gseg_gi,l_pos,r_pos";
  $PGSsth = $self->{dbh}->prepare($PGSselect);
  $PGSsth->execute();
  $PGSaref = $PGSsth->fetchall_arrayref();
  
  $PGSindx=0;
 EVAL_ANNOTATION:
  for($ANNindx=0;$ANNindx <= $#$ANNaref;$ANNindx++){
    $annINFO = $ANNaref->[$ANNindx][1];
    $annINFO =~ s/^\D+//;
    $annINFO =~ s/\D+$//;
    @annSTR = split(/\D+/,$annINFO);
    @annSTR = reverse(@annSTR) if($annSTR[0] > $annSTR[1]);
    
    ## backtrack PGSindx to first PGS overlapping ANN (leftmost) IF NEEDED
    while(($PGSindx > 0)&&
	  (($ANNaref->[$ANNindx][2] == $PGSaref->[$PGSindx - 1][2])&&
	   (($ANNaref->[$ANNindx][3] < $PGSaref->[$PGSindx - 1][4])||
	    ($ANNaref->[$ANNindx][3] < $PGSaref->[$PGSindx - 1][6])))){
      $PGSindx--;
    }
    ## advance PGSindx to first PGS overlapping ANN (leftmost) IF NEEDED
    while(($ANNaref->[$ANNindx][2] > $PGSaref->[$PGSindx][2])||
	  (($ANNaref->[$ANNindx][2] == $PGSaref->[$PGSindx][2])
	   &&($ANNaref->[$ANNindx][3] > $PGSaref->[$PGSindx][4]))){
      last EVAL_ANNOTATION if($PGSindx == $#$PGSaref);
      $PGSindx++;
    }
    
    while(($ANNaref->[$ANNindx][2] == $PGSaref->[$PGSindx][2])&&
	  ($ANNaref->[$ANNindx][4] > $PGSaref->[$PGSindx][3])){
      if($ANNaref->[$ANNindx][3] < $PGSaref->[$PGSindx][4]){
	$pgsINFO = $PGSaref->[$PGSindx][1];
	$pgsINFO =~ s/^\D+//;
	$pgsINFO =~ s/\D+$//;
	@pgsSTR = split(/\D+/,$pgsINFO);
	@pgsSTR = reverse(@pgsSTR) if($pgsSTR[0] > $pgsSTR[1]);
	
	delete(@MATCHprops{keys %MATCHprops});
	
	$MATCHscore = $self->STRmatch(\@annSTR,\@pgsSTR,\%MATCHprops);
	if($MATCHscore){ ## MATCHscore = 0 is a case of trimed values overlapping (l_pos & r_pos are based on non-trimed PGS)!!
	  ## MYSQL insert (autoID,annotationUID,pgsUID,0,pgs_isCognate(1|0),Match_Score)
	  $cognate = ($PGSaref->[$PGSindx][5] eq 'True')?1:0;
	  
	  $self->{dbh}->do("INSERT INTO $ISOpair->{ISO_TBL} VALUES (" .
			   join(',',(0,
				     $ANNaref->[$ANNindx][0],
				     $PGSaref->[$PGSindx][0],
				     1,
				     0,
				     $cognate,
				     $MATCHscore,
				     scalar(keys %{$MATCHprops{INTRONS_confirmed}}),
				     scalar(keys %{$MATCHprops{INTRONS_additional}}),
				     scalar(keys %{$MATCHprops{INTRONS_alternative}}),
				     scalar(keys %{$MATCHprops{INTRONS_conflicting}}),
				     $MATCHprops{COVERAGE_annotation},
				     $MATCHprops{COVERAGE_pgs}
				    )) .
			   ")");
	}
      }
      $PGSaref->[$PGSindx][6] = $PGSmax_rpos;
      $PGSmax_rpos = ($PGSaref->[$PGSindx][4] > $PGSmax_rpos)?$PGSaref->[$PGSindx][4]:$PGSmax_rpos;
      last if($PGSindx == $#$PGSaref);
      $PGSindx++;
    }
  }
  $PGSsth->finish();
  $ANNsth->finish();
  
  return 1;
}

sub mark_ISO_TBL{
  my $self = shift;
  my ($ISOpair) = @_;

  ##### Now mark the best ISO to ANNOTATION entries #####
  ## The easy ones
  my $uid_ar = $self->{dbh}->selectcol_arrayref("SELECT uid from $ISOpair->{ISO_TBL} group by pgsUID having count(*) = 1");
  if(scalar(@$uid_ar)){
    for($x=0;$x<($#$uid_ar - 1000);$x+=1000){
      $self->{dbh}->do("UPDATE $ISOpair->{ISO_TBL} SET best = 1, multi = 0 WHERE uid IN (" . join(',',@$uid_ar[$x .. ($x + 1000)]) . ")");
    }
    $self->{dbh}->do("UPDATE $ISOpair->{ISO_TBL} SET best = 1, multi = 0 WHERE uid IN (" . join(',',@$uid_ar[$x .. $#$uid_ar]) . ")");
  }
  
  print STDERR scalar(@{$uid_ar}) . " unique bests reported\n" if(exists($self->{DEBUG_sql})&&$self->{DEBUG_sql});
  
  ## The Not So Easy ones
  $ISO_hr = $self->{dbh}->selectall_hashref("SELECT * from $ISOpair->{ISO_TBL} WHERE (multi = 1)","uid");
  
  if(scalar(keys %$ISO_hr)){
    $ADVANCE = 0;
    @BEST = ();
    @NONBEST = ();
    @NONMATCH = ();
    $cnt=0;
    foreach $ISOuid (sort byPGS_SCORE keys %{$ISO_hr}){
      if(defined($curISO_hr)){
	if(($curISO_hr->{pgsUID} == $ISO_hr->{$ISOuid}->{pgsUID})&& 
	   (($ISO_hr->{$ISOuid}->{score} <=> $curISO_hr->{score}) ||
	    ($curISO_hr->{intron_conflicting} <=> $ISO_hr->{$ISOuid}->{intron_conflicting}) ||
	    ($curISO_hr->{intron_alternative} <=> $ISO_hr->{$ISOuid}->{intron_alternative}) ||
	    ($ISO_hr->{$ISOuid}->{pgs_coverage} <=> $curISO_hr->{pgs_coverage}) ||
	    ($ISO_hr->{$ISOuid}->{annotation_coverage} <=> $curISO_hr->{annotation_coverage})
	   )){
	  $ADVANCE = 1;
	  if(scalar(@BEST)){
	    for($x=0;$x<($#BEST - 1000);$x+=1000){
	      $self->{dbh}->do("UPDATE $ISOpair->{ISO_TBL} SET best = " . scalar(@BEST) . " WHERE uid IN (" . join(',',@BEST[$x .. ($x + 1000)]) . ")");
	    }
	    $self->{dbh}->do("UPDATE $ISOpair->{ISO_TBL} SET best = " . scalar(@BEST) . " WHERE uid IN (" . join(',',@BEST[$x .. $#BEST]) . ")");
	  }
	  $cnt += scalar(@BEST);
	  @BEST = ();
	}elsif($curISO_hr->{pgsUID} != $ISO_hr->{$ISOuid}->{pgsUID}){
	  if(scalar(@BEST)){
	    for($x=0;$x<($#BEST - 1000);$x+=1000){
	      $self->{dbh}->do("UPDATE $ISOpair->{ISO_TBL} SET best = " . scalar(@BEST) . " WHERE uid IN (" . join(',',@BEST[$x .. ($x + 1000)]) . ")");
	    }
	    $self->{dbh}->do("UPDATE $ISOpair->{ISO_TBL} SET best = " . scalar(@BEST) . " WHERE uid IN (" . join(',',@BEST[$x .. $#BEST]) . ")");
	  }
	  $cnt += scalar(@BEST);
	  @BEST = ();
	  $ADVANCE = 0;
	}
	
	if(($ADVANCE)&&($ISO_hr->{$ISOuid}->{pgsUID} = $curISO_hr->{pgsUID})){
	  if($ISO_hr->{$ISOuid}->{score} >= 6){ ## NOT A HORRIBLE MATCH
	    push(@NONBEST,$ISOuid);
	  }else{ ## IS PROBABLY A CHANCE OVERLAP
	    push(@NONMATCH,$ISOuid);
	  }
	  next;
	}
      }
      
      push(@BEST,$ISOuid);
      $curISO_hr = $ISO_hr->{$ISOuid};
    }
    
    if(scalar(@BEST)){
      for($x=0;$x<($#BEST - 1000);$x+=1000){
	$self->{dbh}->do("UPDATE $ISOpair->{ISO_TBL} SET best = " . scalar(@BEST) . " WHERE uid IN (" . join(',',@BEST[$x .. ($x + 1000)]) . ")");
      }
      $self->{dbh}->do("UPDATE $ISOpair->{ISO_TBL} SET best = " . scalar(@BEST) . " WHERE uid IN (" . join(',',@BEST[$x .. $#BEST]) . ")");
    }
    $cnt+=scalar(@BEST);
    print STDERR "$cnt best entries reported from multiple ISO\n" if(exists($self->{DEBUG_sql})&&$self->{DEBUG_sql});

    if(scalar(@NONBEST)){
      for($x=0;$x<($#NONBEST - 1000);$x+=1000){
	$self->{dbh}->do("UPDATE $ISOpair->{ISO_TBL} SET best = 0 WHERE uid IN (" . join(',',@NONBEST[$x .. ($x + 1000)]) . ")");
      }
      $self->{dbh}->do("UPDATE $ISOpair->{ISO_TBL} SET best = 0 WHERE uid IN (" . join(',',@NONBEST[$x .. $#NONBEST]) . ")");
    }
    print STDERR scalar(@NONBEST) . " non-best entries reported\n" if(exists($self->{DEBUG_sql})&&$self->{DEBUG_sql});

    if(scalar(@NONMATCH)){
      for($x=0;$x<($#NONMATCH - 1000);$x+=1000){
	$self->{dbh}->do("UPDATE $ISOpair->{ISO_TBL} SET best = -1 WHERE uid IN (" . join(',',@NONMATCH[$x .. ($x + 1000)]) . ")");
      }
      $self->{dbh}->do("UPDATE $ISOpair->{ISO_TBL} SET best = -1 WHERE uid IN (" . join(',',@NONMATCH[$x .. $#NONMATCH]) . ")");
    }
    print STDERR scalar(@NONMATCH) . " non-match entries reported\n" if(exists($self->{DEBUG_sql})&&$self->{DEBUG_sql});
    
  }
  
  return 1;
}

sub byPGS_SCORE{
  return(($ISO_hr->{$a}->{pgsUID} <=> $ISO_hr->{$b}->{pgsUID}) || 
	 ($ISO_hr->{$b}->{score} <=> $ISO_hr->{$a}->{score}) ||
	 ($ISO_hr->{$a}->{intron_conflicting} <=> $ISO_hr->{$b}->{intron_conflicting}) ||
	 ($ISO_hr->{$a}->{intron_alternative} <=> $ISO_hr->{$b}->{intron_alternative}) ||
	 ($ISO_hr->{$b}->{pgs_coverage} <=> $ISO_hr->{$a}->{pgs_coverage}) ||
	 ($ISO_hr->{$b}->{annotation_coverage} <=> $ISO_hr->{$a}->{annotation_coverage})
	);
}
1;

__END__

=pod

=head1 NAME

gaeval::sql - Use xGDB with gaeval

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 FUNCTION PROTOTYPES

=head2 OBJECT METHODS

  load_GAEVAL_PROPERTIES_TBL()
  load_GAEVAL_SUPPORT_TBL()
  mark_ISO_TBL(\%ISOpair)
  seed_ALL_ISO_TBLS()
  seed_ISO_TBL(\%ISOpair)
  update_GaevalProperties_TBL($annUID)
  update_GaevalSupport_TBL($annUID)

=head2 PRIVATE FUNCTIONS

  byPGS_SCORE()

=head1 METHOD & FUNCTION DESCRIPTIONS

=over

=item byPGS_SCORE --> C<sort byPGS_SCORE keys %$ISO_hr>

This C<sort> function orders Isoform Specific alignment Objects
found in the ISO_hr hash reference based on the following 
order of precedence:
 Increasing Alignment UniqueID 
 Decreasing Gaeval Score 
 Increasing number of Conflicting Introns 
 Increasing number of Alternative Introns
 Decreasing Sequence Coverage 
 Decreasing Annotation Coverage

=item load_GAEVAL_PROPERTIES_TBL

Drops, creates and populates a 
L<gaeval property table|gaeval/"gaeval property table schema"> 
using the table name defined by the 
L<GAEVAL_PROPERTIES_TBL|gaeval/GAEVAL_PROPERTIES_TBL> 
configuration variable or its default value.

=item load_GAEVAL_SUPPORT_TBL

Drops, creates and populates a 
L<gaeval support table|gaeval/"gaeval support table schema"> 
using the table name defined by the 
L<GAEVAL_SUPPORT_TBL|gaeval/GAEVAL_SUPPORT_TBL> 
configuration variable or its default value.

=item mark_ISO_TBL

Mark specific ISOs as best or multiply best with respect to 
a set of annotations.

=item seed_ALL_ISO_TBLS

Loads or refreshes all gaeval ISO tables defined by the
L<GAEVAL_ISO_TABLES|gaeval/GAEVAL_ISO_TABLES> configuration
variable.

=item seed_ISO_TBL

Drops, creates, and populates a single 
L<gaeval ISO table|gaeval/"gaeval ISO table schema"> based on the 
supplied \%ISOpair hashreference.

=item update_GaevalProperties_TBL

Using the annUID a specific annotation found in the 
annotation table defined by the L<db_table|gaeval/db_table> 
configuration variable is evaluated for the following gaeval events.
 Alternative Splicing
 Ambiguous/Unsupported annotation boundaries
 Fusion, Fission, and Complex transcript processing

=item update_GaevalSupport_TBL

Using the annUID a specific annotation found in the 
annotation table defined by the L<db_table|gaeval/db_table> 
configuration variable is evaluated for gene structure annotation
support.



=back

