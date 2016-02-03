package gaeval::load;

our(%IDspace,%TYPE,%Progeny,%gsegXref,@EVTYPE,$GAEVAL_ANN_TBL,$GAEVAL_ESOURCE_TBL,$GAEVAL_EVIDENCE_TBL,$UID);

sub loadGFF{
  my ($argHR) = @_;
  return 0 if(!exists($argHR->{GFFfile})||($argHR->{GFFfile} eq ''));
  return -1 if(!open(INF,$argHR->{GFFfile}));

  $argHR->{DBhandle} = '' if(!exists($argHR->{DBhandle}));
  $argHR->{_opt_load_annotation}=1 if(!exists($argHR->{_opt_load_annotation}));
  $argHR->{_opt_load_evidence}=1 if(!exists($argHR->{_opt_load_evidence}));
  $argHR->{_opt_xref_filename}='' if(!exists($argHR->{_opt_xref_filename}));
  $argHR->{_opt_all_evtype}=1 if(!exists($argHR->{_opt_all_evtype}));
  $argHR->{GAEVAL_ANN_TBL}="gaeval_annotation" if(!exists($argHR->{GAEVAL_ANN_TBL}));
  $argHR->{GAEVAL_ESOURCE_TBL}="gaeval_evidence_source" if(!exists($argHR->{GAEVAL_ESOURCE_TBL}));
  $argHR->{GAEVAL_EVIDENCE_TBL}="gaeval_evidence" if(!exists($argHR->{GAEVAL_EVIDENCE_TBL}));
  $argHR->{CUSTOM_EVIDENCE_TYPES}={} if(!exists($argHR->{CUSTOM_EVIDENCE_TYPES}));
  $argHR->{CUSTOM_EVIDENCE_TYPES}={%{$argHR->{CUSTOM_EVIDENCE_TYPES}},match=>1,cDNA_match=>1,EST_match=>1,nucleotide_match=>1,nucleotide_to_protein_match=>1,nucleotide_motif=>1} if($argHR->{_opt_all_evtype});

  load_xref($argHR->{_opt_xref_filename}) if($argHR->{_opt_xref_filename} ne '');

  $UID=0;
  while(<INF>){
    last if((/^\#\#FASTA/)||(/^>/));
    GFF_process($argHR) if(/^\#\#\#/);
    
    next if((/^\s*$/)||(/^\#/));
    GFF_register_entry(GFF_readline($_));
  }
  GFF_process($argHR);
  
  return 1;
}

sub GFF_process {
  my($argHR) = @_;
  
  ## process annotations
  annotation2DB($argHR) if($argHR->{_opt_load_annotation});

  ## process evidence
  match2DB($argHR) if($argHR->{_opt_load_evidence});
  
  %IDspace=();
  %TYPE=();
  %Progeny=();
  $UID=0;

}

sub match2DB {
  my($argHR) = @_;
  if(exists($argHR->{CUSTOM_EVIDENCE_TYPES}->{cDNA_match})){ ## Deal with EST clonepairs
    my %struct = ();
    foreach $ID (keys(%{$TYPE{cDNA_match}})){
      if(exists($Progeny{$ID}) && exists($Progeny{$ID}->{EST_match})){
	## cDNA_match lines that are parents to other lines are used as groups (i.e. EST clonepairs)
	foreach $GFFest (@{$Progeny{$ID}->{EST_match}}){
	  $struct{$GFFest->{attributes}->{ID}} = [] if(!exists($struct{$GFFest->{attributes}->{ID}}));
	  push(@{$struct{$GFFest->{attributes}->{ID}}},$GFFest->{start},$GFFest->{end});
	}
	($curGI,$curLPOS,$curRPOS) = (-1,-1,-1);
	foreach $estID (keys(%struct)){
	  my $gseg_gi = validate_GFFseqid($IDspace{$estID}->[0]->{seqid});
	  my $gi =(exists($IDspace{$estID}->[0]->{attributes}->{Name}))?$IDspace{$estID}->[0]->{attributes}->{Name}:$estID;
	  my $alias = (exists($IDspace{$estID}->[0]->{attributes}->{Alias}))?$IDspace{$estID}->[0]->{attributes}->{Alias}:'';
	  my $type = (exists($IDspace{$estID}->[0]->{attributes}->{end_type}))?$IDspace{$estID}->[0]->{attributes}->{end_type}:exists($IDspace{$estID}->[0]->{attributes}->{full_length_transcript})?'B':'U';
	  my $cognate = (!exists($IDspace{$estID}->[0]->{attributes}->{cognate}))?'True':
	    ($IDspace{$estID}->[0]->{attributes}->{cognate} =~ /t/i)?'True':
	      ($IDspace{$estID}->[0]->{attributes}->{cognate} =~ /f/i)?'False':
		($IDspace{$estID}->[0]->{attributes}->{cognate} == 0)?'False':'True';
	  $gi = validate_GFFseqid($gi);
	  my $g_o =$IDspace{$estID}->[0]->{strand};
	  my @STRUCTURE = sort { return $a <=> $b; } @{$struct{$estID}};
	  my $l_pos = $STRUCTURE[0];
	  my $r_pos = $STRUCTURE[$#STRUCTURE];
	  @STRUCTURE = reverse @STRUCTURE if($g_o eq '-');
	  my $pgs = "";
	  for(my $x=0;$x<$#STRUCTURE;$x+=2){
	    $pgs .= $STRUCTURE[$x] . "  " . $STRUCTURE[$x+1] . ",";
	  }
	  chop($pgs);

	  my $sql = "INSERT INTO $argHR->{GAEVAL_ESOURCE_TBL} (gi,acc,type) VALUES ($gi,'$alias','$type')";
	  if($argHR->{DBhandle} ne ''){ $argHR->{DBhandle}->do($sql); }else{ print "${sql};\n"; }
	  
	  if($curGI == -1){
	    $sql = "INSERT INTO $argHR->{GAEVAL_EVIDENCE_TBL} (uid,gi,gseg_gi,l_pos,r_pos,G_O,pgs,isCognate) VALUES (0,$gi,'$gseg_gi',$l_pos,$r_pos,'$g_o','$pgs','${cognate}')";
	    if($argHR->{DBhandle} ne ''){ $argHR->{DBhandle}->do($sql); }else{ print "${sql};\n"; }
	  }else{
	    $sql = "INSERT INTO $argHR->{GAEVAL_EVIDENCE_TBL} (uid,gi,gseg_gi,l_pos,r_pos,G_O,pgs,isCognate,pairUID) VALUES (0,$gi,'$gseg_gi',$l_pos,$r_pos,'$g_o','$pgs','${cognate}',LAST_INSERT_ID())";
	    if($argHR->{DBhandle} ne ''){ $argHR->{DBhandle}->do($sql); }else{ print "${sql};\n"; }

	    $sql = "UPDATE $argHR->{GAEVAL_EVIDENCE_TBL} SET pairUID = LAST_INSERT_ID() where ( gi = $curGI )&&( l_pos = $curLPOS )&&( r_pos = $curRPOS )";
	    if($argHR->{DBhandle} ne ''){ $argHR->{DBhandle}->do($sql); }else{ print "${sql};\n"; }
	  }

	  ($curGI,$curLPOS,$curRPOS) = ($gi,$l_pos,$r_pos);	  

	  delete($TYPE{EST_match}->{$estID});
	}
      }
    }
  }

  foreach $evtype (keys(%{$argHR->{CUSTOM_EVIDENCE_TYPES}})){
    foreach $ID (keys(%{$TYPE{$evtype}})){
      next if(exists($Progeny{$ID})); ##cDNA_match lines are sometimes used to group EST_matches
     
      my $gseg_gi = validate_GFFseqid($IDspace{$ID}->[0]->{seqid});
      my $gi =(exists($IDspace{$ID}->[0]->{attributes}->{Name}))?$IDspace{$ID}->[0]->{attributes}->{Name}:$ID;
      my $alias = (exists($IDspace{$ID}->[0]->{attributes}->{Alias}))?$IDspace{$ID}->[0]->{attributes}->{Alias}:'';
      my $type = (exists($IDspace{$ID}->[0]->{attributes}->{end_type}))?$IDspace{$ID}->[0]->{attributes}->{end_type}:exists($IDspace{$ID}->[0]->{attributes}->{full_length_transcript})?'B':'U';
      my $cognate = (!exists($IDspace{$ID}->[0]->{attributes}->{cognate}))?'True':
	($IDspace{$ID}->[0]->{attributes}->{cognate} =~ /t/i)?'True':
	  ($IDspace{$ID}->[0]->{attributes}->{cognate} =~ /f/i)?'False':
	    ($IDspace{$ID}->[0]->{attributes}->{cognate} == 0)?'False':'True';
      $gi = validate_GFFseqid($gi);
      my $g_o =$IDspace{$ID}->[0]->{strand};
      
      my @STRUCTURE=();
      foreach $GFFexon (@{$IDspace{$ID}}){
	push(@STRUCTURE,$GFFexon->{start},$GFFexon->{end});
      }
      @STRUCTURE = sort {return $a<=>$b;} @STRUCTURE;
      my $l_pos = $STRUCTURE[0];
      my $r_pos = $STRUCTURE[$#STRUCTURE];
      @STRUCTURE = reverse @STRUCTURE if($g_o eq '-');
      my $pgs = "";
      for(my $x=0;$x<$#STRUCTURE;$x+=2){
	$pgs .= $STRUCTURE[$x] . "  " . $STRUCTURE[$x+1] . ",";
      }
      chop($pgs);
      
      my $sql = "INSERT INTO $argHR->{GAEVAL_ESOURCE_TBL} (gi,acc,type) VALUES ($gi,'$alias','$type')";
      if($argHR->{DBhandle} ne ''){
	$argHR->{DBhandle}->do($sql);
      }else{
	print "${sql};\n";
      }

      $sql = "INSERT INTO $argHR->{GAEVAL_EVIDENCE_TBL} (uid,gi,gseg_gi,l_pos,r_pos,G_O,pgs,isCognate) VALUES (0,$gi,'$gseg_gi',$l_pos,$r_pos,'$g_o','$pgs','${cognate}')";
      if($argHR->{DBhandle} ne ''){
	$argHR->{DBhandle}->do($sql);
      }else{
	print "${sql};\n";
      }
    }
  }

}

sub annotation2DB {
  my($argHR) = @_;
  foreach $ID (keys(%{$TYPE{mRNA}})){
    my $gseg_gi = validate_GFFseqid($IDspace{$ID}->[0]->{seqid});
    my $geneId  =(exists($IDspace{$ID}->[0]->{attributes}->{Name}))?$IDspace{$ID}->[0]->{attributes}->{Name}:$ID;
    my $strand  =($IDspace{$ID}->[0]->{strand} eq '+')?'f':'r';

    my @annSTRUCTURE = ();
    if(exists($Progeny{$ID}->{exon})){
      foreach $GFFexon (@{$Progeny{$ID}->{exon}}){
	push(@annSTRUCTURE,$GFFexon->{start},$GFFexon->{end});
      }
    }else{
      @annSTRUCTURE = ($IDspace{$ID}->[0]->{start},$IDspace{$ID}->[0]->{end});
    }
    @annSTRUCTURE = sort {return $a<=>$b;} @annSTRUCTURE;
    my $gene_structure = ($IDspace{$ID}->[0]->{strand} eq '+')?"join(":"complement(join(";
    for(my $x=0;$x<$#annSTRUCTURE;$x+=2){
      $gene_structure .= $annSTRUCTURE[$x] . ".." . $annSTRUCTURE[$x+1] . ",";
    }
    chop($gene_structure);
    $gene_structure .= ($IDspace{$ID}->[0]->{strand} eq '+')?")":"))";

    my $CDSleft  = $IDspace{$ID}->[0]->{end};
    my $CDSright = -1;
    if(exists($Progeny{$ID}->{CDS})){
      foreach $GFFcds (@{$Progeny{$ID}->{CDS}}){
	$CDSleft = ($GFFcds->{start} < $CDSleft)? $GFFcds->{start} : $CDSleft;
	$CDSright = ($GFFcds->{end} > $CDSright)? $GFFcds->{end} : $CDSright;
      }
    }
    my $CDSstart = ($CDSright == -1)?'NULL':($IDspace{$ID}->[0]->{strand} eq '+')? $CDSleft:$CDSright;
    my $CDSstop  = ($CDSright == -1)?'NULL':($IDspace{$ID}->[0]->{strand} eq '+')? $CDSright:$CDSleft;

    my $sql = "INSERT INTO $argHR->{GAEVAL_ANN_TBL} (uid,gseg_gi,geneId,strand,l_pos,r_pos,gene_structure,CDSstart,CDSstop) VALUES (0,'$gseg_gi','$geneId','$strand',$IDspace{$ID}->[0]->{start},$IDspace{$ID}->[0]->{end},'$gene_structure',$CDSstart,$CDSstop)";
    if($argHR->{DBhandle} ne ''){
      $argHR->{DBhandle}->do($sql);
    }else{
      print "${sql};\n";
    }
  }  
}

sub load_xref {
  my ($XREF) = @_;
  open(INF,$XREF);
  while(<INF>){
    if(/^(\S+)\s+(\S+)\s+(\S+)/){## locus Acc GI
      $gsegXref{$1} = $3;
      $gsegXref{$2} = $3;
    }elsif(/^(\S+)\s+(\S+)/){## Alias GI
      $gsegXref{$1} = $2;
    }
  }
  close(INF);
}

sub validate_GFFseqid {
  my ($id) = @_;
  return $id if($id =~ /^\d+$/);
  
  if(!exists($gsegXref{$id})){
    $gsegXref{$id} = $UID++;
    print STDERR "Gaeval Sources are referenced by numerical id!\n$id is being assigned the gseg_gi $gsegXref{$id}\n";
  }
  return $gsegXref{$id};
}

sub GFF_readline {
  my ($GFFline) = @_;
  chomp($GFFline);
  my @col = split("\t",$GFFline);
  my %att = split(/[=;]/,$col[8]);
  return {seqid  =>$col[0],
	  source =>$col[1],
	  type   =>$col[2],
	  start  =>$col[3],
	  end    =>$col[4],
	  score  =>$col[5],
	  strand =>$col[6],
	  phase  =>$col[7],
	  attributes =>\%att
	 };
}

sub GFF_register_entry {
  my ($GFFentry) = @_;
  
  my $ID=(exists($GFFentry->{attributes}->{ID}))?$GFFentry->{attributes}->{ID}:"__defaultID_".$UID++;

  if(exists($IDspace{$ID})){
    push(@{$IDspace{$ID}},$GFFentry);
  }else{
    $IDspace{$ID} = [$GFFentry];
    if(exists($TYPE{$GFFentry->{type}})){
      if(exists($TYPE{$GFFentry->{type}}->{$ID})){
	$TYPE{$GFFentry->{type}}->{$ID}++
      }else{
	$TYPE{$GFFentry->{type}}->{$ID} = 1;
      }
    }else{
      $TYPE{$GFFentry->{type}} = {$ID=>1};
    }
  }
  if(exists($GFFentry->{attributes}->{Parent})){
    foreach $parent (split(',',$GFFentry->{attributes}->{Parent})){
      if(exists($Progeny{$parent})){
	if(exists($Progeny{$parent}->{$GFFentry->{type}})){
	  push(@{$Progeny{$parent}->{$GFFentry->{type}}},$GFFentry);
	}else{
	  $Progeny{$parent}->{$GFFentry->{type}} = [$GFFentry];
	}
      }else{
	$Progeny{$parent}={$GFFentry->{type} => [$GFFentry]};
      }
    }
  }
}

1;
