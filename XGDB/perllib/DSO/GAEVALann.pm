package GAEVALann;
use base "AnnotationTrack";
use base gaeval::xgdb;

do 'SITEDEF.pl';

use DBI;
use CGI ":all";
use GD;

sub _init{
  my $self = shift;

  $self->SUPER::_init(@_);

  $self->{_HAS_FLAGS} = 1;
  $self->{GAEVAL_ANN_TBL} = (exists($self->{GAEVAL_ANN_TBL}))?$self->{GAEVAL_ANN_TBL}:'gaeval_annotation';
  $self->{GAEVAL_ANNselect} = (exists($self->{GAEVAL_ANNselect}))?$self->{GAEVAL_ANNselect}:'select uid,gene_structure,gseg_gi,l_pos,r_pos FROM $self->{GAEVAL_ANN_TBL} ORDER BY gseg_gi,l_pos,r_pos';
  $self->{GAEVAL_SUPPORT_TBL} = (exists($self->{GAEVAL_SUPPORT_TBL}))?$self->{GAEVAL_SUPPORT_TBL}:$self->{GAEVAL_ANN_TBL} . "_support";
  $self->{GAEVAL_PROPERTIES_TBL} = (exists($self->{GAEVAL_PROPERTIES_TBL}))?$self->{GAEVAL_PROPERTIES_TBL}:$self->{GAEVAL_ANN_TBL} . "_properties";
  $self->{GAEVAL_FLAGS_TBL} = (exists($self->{GAEVAL_FLAGS_TBL}))?$self->{GAEVAL_FLAGS_TBL}:$self->{GAEVAL_ANN_TBL} . "_flags";

}

sub showGaevalReport{
  my $self = shift;
  my($argHR) = @_;

  exists($argHR->{selectedRECORD}) || (@$argHR{'recordTYPE','selectedRECORD'} = $self->selectRECORD($argHR));
  my $recordHR = $argHR->{selectedRECORD};


  #### Summary table
  my @IMGflag = ("<img class='DOCtype' alt='none' title='No Incongruence' src='${IMAGEDIR}Flags/null.png'>",
		 "<img class='DOCtype' alt='undoc' title='Undocumented Incongruence' src='${IMAGEDIR}Flags/xmark.png'>",
		 "<img class='DOCtype' alt='iso' title='Isoform Documented Incongruence' src='${IMAGEDIR}Flags/lmark.png'>",
		 "<img class='DOCtype' alt='undoc_iso' title='Undocumented & Isoform Documented Incongruence' src='${IMAGEDIR}Flags/xlmark.png'>",
		 "<img class='DOCtype' alt='uca' title='User Annotated Incongruence' src='${IMAGEDIR}Flags/umark.png'>",
		 "<img class='DOCtype' alt='undoc_uca' title='Undocumented & User Annotated Incongruence' src='${IMAGEDIR}Flags/xumark.png'>",
		 "<img class='DOCtype' alt='iso_uca' title='Isoform Documented and User Annotated Incongruence' src='${IMAGEDIR}Flags/lumark.png'>",
		 "<img class='DOCtype' alt='undoc_iso_uca' title='Undocumented, Isoform Documented, and User Annotated Incongruence' src='${IMAGEDIR}Flags/xlumark.png'>");
  my $pcov = int($recordHR->{exon_coverage} * 100);
  my $b5 = ($recordHR->{bound_5prime} < 0)?(-1 * $recordHR->{bound_5prime}):"";
  my $b3 = ($recordHR->{bound_3prime} < 0)?(-1 * $recordHR->{bound_3prime}):"";

  my $AStype = 0;
  $AStype += 1 if(($recordHR->{as_addintron} && !$recordHR->{as_addintron_doc})||($recordHR->{as_altintron} && !$recordHR->{as_altintron_doc})||($recordHR->{as_conintron} && !$recordHR->{as_conintron_doc}));
  $AStype += 2 if(($recordHR->{as_addintron} && ($recordHR->{as_addintron_mindoc} < 0))||($recordHR->{as_altintron} && ($recordHR->{as_altintron_mindoc} < 0))||($recordHR->{as_conintron} && ($recordHR->{as_conintron_mindoc} < 0)));
  $AStype += 4 if(($recordHR->{as_addintron} && ($recordHR->{as_addintron_maxdoc} > 0))||($recordHR->{as_altintron} && ($recordHR->{as_altintron_maxdoc} > 0))||($recordHR->{as_conintron} && ($recordHR->{as_conintron_maxdoc} > 0)));

  my $ATtype = 0;
  $ATtype += 1 if($recordHR->{cm_altcps} && !$recordHR->{cm_altcps_doc});
  $ATtype += 2 if($recordHR->{cm_altcps} && ($recordHR->{cm_altcps_mindoc} < 0));
  $ATtype += 4 if($recordHR->{cm_altcps} && ($recordHR->{cm_altcps_maxdoc} > 0));

  my $FItype = 0;
  $FItype += 1 if($recordHR->{cm_fission} && !$recordHR->{cm_fission_doc});
  $FItype += 2 if($recordHR->{cm_fission} && ($recordHR->{cm_fission_mindoc} < 0));
  $FItype += 4 if($recordHR->{cm_fission} && ($recordHR->{cm_fission_maxdoc} > 0));

  my $FUtype = 0;
  $FUtype += 1 if($recordHR->{cm_fusion} && !$recordHR->{cm_fusion_doc});
  $FUtype += 2 if($recordHR->{cm_fusion} && ($recordHR->{cm_fusion_mindoc} < 0));
  $FUtype += 4 if($recordHR->{cm_fusion} && ($recordHR->{cm_fusion_maxdoc} > 0));

  my $EOtype = 0;
  $EOtype += 1 if($recordHR->{ae_amboverlap} && !$recordHR->{ae_amboverlap_doc});
  $EOtype += 2 if($recordHR->{ae_amboverlap} && ($recordHR->{ae_amboverlap_mindoc} < 0));
  $EOtype += 4 if($recordHR->{ae_amboverlap} && ($recordHR->{ae_amboverlap_maxdoc} > 0));

  #### Structure Image
  my $structIMG  = $self->showSTRUCT($argHR);

  #### Full Report
  $self->eval_annotation_support($recordHR->{uid});
  $self->eval_incongruence($recordHR->{uid});

  @introns = sort {return $a <=> $b;} (keys %{$self->{BC_MATCHES}->{INTRONS_confirmed}},keys %{$self->{BC_MATCHES}->{INTRONS_unsupported}});
  @introns = reverse @introns if($self->{ann_DBdata}->{strand} eq 'r');
  my %INposition=();
  my $INSUP_list = "";
  for(my $x=0;$x<=$#introns;$x++){
    $INposition{$introns[$x]} = $x + 1;
    $li = <<END;
<li><img src='${IMAGEDIR}GDBmenuArrow2.png' class='menubutton' id='IN${x}closed' onclick='openMENU("IN${x}");'>
<img src='${IMAGEDIR}GDBmenuArrow.png' class='menubutton' id='IN${x}open' onclick='closeMENU("IN${x}");' style='display:none;'>Intron
END
    my($donor,$acceptor) = split(":",$introns[$x]);
    $donor++;$acceptor--;
    ($donor,$acceptor) = ($acceptor,$donor) if($self->{ann_DBdata}->{strand} eq 'r');
    if(exists($self->{BC_MATCHES}->{INTRONS_confirmed}->{$introns[$x]})){
      my %iseGI = ();
      $INSUP_list .= $li . ($x + 1) . " [ $donor .. $acceptor ]( " . scalar(@{$self->{BC_MATCHES}->{INTRONS_confirmed}->{$introns[$x]}}) . " ISE alignments )\n<ul class='INgroup' id='IN${x}options'>\n";
      foreach my $ise (sort {return ($a->{GAEVAL_ISO_TBL} <=> $b->{GAEVAL_ISO_TBL})||($a->{gi} <=> $b->{gi});} @{$self->{BC_MATCHES}->{INTRONS_confirmed}->{$introns[$x]}}){
	$INSUP_list .= "<li>ISE: <a href='${CGIPATH}findRecord.pl?id=$ise->{gi}'>$ise->{gi}</a> ( " . $DBver[$self->{db_id}]->{tracks}->[$self->{GAEVAL_ISO_TABLES}->[$ise->{GAEVAL_ISO_TBL}]->{RESID}]->{trackname} . " )</li>";
	$iseGI{$ise->{gi}} = 1;
      }
      foreach my $nonise (sort {return ($a->{GAEVAL_ISO_TBL} <=> $b->{GAEVAL_ISO_TBL})||($a->{gi} <=> $b->{gi});} @{$self->{BCNC_MATCHES}->{INTRONS_confirmed}->{$introns[$x]}}){
	$INSUP_list .= "<li>Non-ISE: <a href='${CGIPATH}findRecord.pl?id=$ise->{gi}'>$nonise->{gi}</a> ( " . $DBver[$self->{db_id}]->{tracks}->[$self->{GAEVAL_ISO_TABLES}->[$nonise->{GAEVAL_ISO_TBL}]->{RESID}]->{trackname} . " )</li>" if(!exists($iseGI{$nonise->{gi}}));
      }
      $INSUP_list .= "</ul></li>\n";
    }elsif(exists($self->{BCNC_MATCHES}->{INTRONS_confirmed}->{$introns[$x]})){
      $INSUP_list .= $li . ($x + 1) . " [ $donor .. $acceptor ]( " . scalar(@{$self->{BCNC_MATCHES}->{INTRONS_confirmed}->{$introns[$x]}}) . " Non-ISE alignments )\n<ul class='INgroup' id='IN${x}options'>\n";
      foreach my $nonise (sort {return ($a->{GAEVAL_ISO_TBL} <=> $b->{GAEVAL_ISO_TBL})||($a->{gi} <=> $b->{gi});} @{$self->{BCNC_MATCHES}->{INTRONS_confirmed}->{$introns[$x]}}){
	$INSUP_list .= "<li>Non-ISE: <a href='${CGIPATH}findRecord.pl?id=$ise->{gi}'>$nonise->{gi}</a> ( " . $DBver[$self->{db_id}]->{tracks}->[$self->{GAEVAL_ISO_TABLES}->[$nonise->{GAEVAL_ISO_TBL}]->{RESID}]->{trackname} . " )</li>";
      }
      $INSUP_list .= "</ul></li>\n";
    }else{
      $INSUP_list .= "<li style='color:red;'><img src='${IMAGEDIR}GDBmenuArrow2.png' class='menubutton' id='IN${x}closed' style='margin-right:14px; visibility:hidden;'>Intron " . ($x + 1) . " [ $donor .. $acceptor ]( Unsupported )</li>\n";
    }

  }



  my $ALTSP_list = "";
  if(keys %{$self->{asiINFO}}){
    $ALTSP_list .= <<END;
<li><img src='${IMAGEDIR}GDBmenuArrow2.png' class='menubutton' id='ASclosed' onclick='openMENU("AS");'>
<img src='${IMAGEDIR}GDBmenuArrow.png' class='menubutton' id='ASopen' onclick='closeMENU("AS");' style='display:none;'>Alternative Splicing
END
    $ALTSP_list .= "( " . keys(%{$self->{asiINFO}}) . " Incongruent Introns )\n<ul class='ASgroup' id='ASoptions'>\n";

    my $x=0;my %inDOC=();
    foreach my $intStr (sort {return $a<=>$b;} keys %{$self->{asiINFO}}){
      my $intron_source='annINTRON';
      my($donor,$acceptor) = split(':',$intStr);
      $donor++; $acceptor--;
      ($donor,$acceptor) = ($acceptor,$donor) if($self->{ann_DBdata}->{strand} eq 'r');
      my $formated_intron = exists($INposition{$intStr})?"Intron $INposition{$intStr} [ $donor .. $acceptor ]":"$donor .. $acceptor";
      my %INC = ();
      my @ASintTYPE=();
      if(exists($self->{asiINFO}->{$intStr}->{INTRONS_alt_isoform})){
	$INC{Isoform} = {iso=>[]};
	my $isoIntHR = exists($self->{asiINFO}->{$intStr}->{INTRONS_alt_isoform}->{confirmed})?
	  $self->{asiINFO}->{$intStr}->{INTRONS_alt_isoform}->{confirmed}:
	    exists($self->{asiINFO}->{$intStr}->{INTRONS_alt_isoform}->{unsupported})?
	      $self->{asiINFO}->{$intStr}->{INTRONS_alt_isoform}->{unsupported}:{};
	foreach my $isoSRC (sort {return ($a eq 'LOCAL')?-1:($b eq 'LOCAL')?1:($a cmp $b);} keys %$isoIntHR){
	  foreach my $isoHR (sort {return ($a->{geneid} cmp $b->{geneid});} @{$isoIntHR->{$isoSRC}}){
	    my $src = ($isoSRC eq 'LOCAL')?" ( $self->{trackname} ) ":'';
	    push(@{$INC{Isoform}->{iso}},"<li>" . $isoHR->{geneid} . "${src}</li>");
     	}
    }
      }
      if(exists($self->{asiINFO}->{$intStr}->{INTRONS_alternative})){
	$INC{Alternative} = {iso=>[]}; $inDOC{alt} = 0; $intron_source='predictedINTRON';
	foreach my $isoHR (sort {return $a->{gi}<=>$b->{gi};} @{$self->{asiINFO}->{$intStr}->{INTRONS_alternative}->{ISO_PGS}}){
	  push(@{$INC{Alternative}->{iso}},"<li>$isoHR->{gi}</li>");
	}
	if(exists($self->{asiINFO}->{$intStr}->{INTRONS_alternative}->{documented})&& keys%{$self->{asiINFO}->{$intStr}->{INTRONS_alternative}->{documented}}){
	  $INC{Alternative}->{doc} = [];
	  $inDOC{alt} += 2 if(exists($self->{asiINFO}->{$intStr}->{INTRONS_alternative}->{documented}->{LOCAL}));
	  $inDOC{alt} += 4 if(!exists($self->{asiINFO}->{$intStr}->{INTRONS_alternative}->{documented}->{LOCAL})||(keys%{$self->{asiINFO}->{$intStr}->{INTRONS_alternative}->{documented}} > 1));
	  my $isoIntHR = $self->{asiINFO}->{$intStr}->{INTRONS_alternative}->{documented};
	  foreach my $isoSRC (sort {return ($a eq 'LOCAL')?-1:($b eq 'LOCAL')?1:($a cmp $b);} keys %$isoIntHR){
	    foreach my $isoAR (sort {return ($a->[1] cmp $b->[1]);} @{$isoIntHR->{$isoSRC}}){
	      my $src = ($isoSRC eq 'LOCAL')?" ( $self->{trackname} ) ":'';
	      push(@{$INC{Alternative}->{doc}},"<li>" . $isoAR->[1] . "${src}</li>");
	    }
	  }
	}else{
	  $inDOC{alt} = 1;
	}
      }
      if(exists($self->{asiINFO}->{$intStr}->{INTRONS_additional})){
	$INC{Additional} = {iso=>[]}; $inDOC{add} = 0; $intron_source='predictedINTRON';
	foreach my $isoHR (sort {return $a->{gi}<=>$b->{gi};} @{$self->{asiINFO}->{$intStr}->{INTRONS_additional}->{ISO_PGS}}){
	  push(@{$INC{Additional}->{iso}},"<li>$isoHR->{gi}</li>");
	}
	if(exists($self->{asiINFO}->{$intStr}->{INTRONS_additional}->{documented})&& keys%{$self->{asiINFO}->{$intStr}->{INTRONS_additional}->{documented}}){
	  $INC{Additional}->{doc} = [];
	  $inDOC{add} += 2 if(exists($self->{asiINFO}->{$intStr}->{INTRONS_additional}->{documented}->{LOCAL}));
	  $inDOC{add} += 4 if(!exists($self->{asiINFO}->{$intStr}->{INTRONS_additional}->{documented}->{LOCAL})||(keys%{$self->{asiINFO}->{$intStr}->{INTRONS_additional}->{documented}} > 1));
	  my $isoIntHR = $self->{asiINFO}->{$intStr}->{INTRONS_additional}->{documented};
	  foreach my $isoSRC (sort {return ($a eq 'LOCAL')?-1:($b eq 'LOCAL')?1:($a cmp $b);} keys %$isoIntHR){
	    foreach my $isoAR (sort {return ($a->[1] cmp $b->[1]);} @{$isoIntHR->{$isoSRC}}){
	      my $src = ($isoSRC eq 'LOCAL')?" ( $self->{trackname} ) ":'';
	      push(@{$INC{Additional}->{doc}},"<li>" . $isoAR->[1] . "${src}</li>");
	    }
	  }
	}else{
	  $inDOC{add} = 1;
	}
      }
      if(exists($self->{asiINFO}->{$intStr}->{INTRONS_conflicting})){
	$INC{Conflicting} = {iso=>[]};
	foreach my $isoHR (sort {return $a->{gi}<=>$b->{gi};} @{$self->{asiINFO}->{$intStr}->{INTRONS_conflicting}->{ISO_PGS}}){
	  push(@{$INC{Conflicting}->{iso}},"<li>$isoHR->{gi}</li>");
	}
      }
      if(exists($self->{asiINFO}->{$intStr}->{INTRONS_erroneous})){
	$INC{Erroneous} = {iso=>[]};
	foreach my $isoHR (sort {return $a->{gi}<=>$b->{gi};} (@{$self->{asiINFO}->{$intStr}->{INTRONS_erroneous}->{ISO_PGS}->{BCBN_MATCHES}},@{$self->{asiINFO}->{$intStr}->{INTRONS_erroneous}->{ISO_PGS}->{BCNN_MATCHES}})){
	  push(@{$INC{Erroneous}->{iso}},"<li>$isoHR->{gi}</li>");
	}
      }


      $inDOC{main} = 0;
      $inDOC{main} = 1 if(($inDOC{alt}==1)||($inDOC{add}==1));
      $inDOC{main} = 2 if(($inDOC{alt}==2)||($inDOC{add}==2));
      $inDOC{main} = 3 if(($inDOC{alt}==3)||($inDOC{add}==3));
      $inDOC{main} = 4 if(($inDOC{alt}==4)||($inDOC{add}==4));
      $inDOC{main} = 5 if(($inDOC{alt}==5)||($inDOC{add}==5));
      $inDOC{main} = 6 if(($inDOC{alt}==6)||($inDOC{add}==6));
      $ALTSP_list .= <<END;
<li><img src='${IMAGEDIR}GDBmenuArrow2.png' class='menubutton' id='AS_INC${x}closed' onclick='openMENU("AS_INC${x}");'>
<img src='${IMAGEDIR}GDBmenuArrow.png' class='menubutton' id='AS_INC${x}open' onclick='closeMENU("AS_INC${x}");' style='display:none;'>
END
      $ALTSP_list .= "<span class='${intron_source}'>$IMGflag[$inDOC{main}]$formated_intron</span> ( " . join(' | ',sort {return $a cmp $b;} keys %INC) . " )\n<ul class='LISTgroup' id='AS_INC${x}options'>\n";

      if(exists($INC{Alternative}->{doc})){
	$ALTSP_list .= <<END;
<li><img src='${IMAGEDIR}GDBmenuArrow2.png' class='menubutton' id='AS_DOC${x}closed' onclick='openMENU("AS_DOC${x}");'>
<img src='${IMAGEDIR}GDBmenuArrow.png' class='menubutton' id='AS_DOC${x}open' onclick='closeMENU("AS_DOC${x}");' style='display:none;'>
This intron is DOCUMENTED by
END
	$ALTSP_list .= (scalar(@{$INC{Alternative}->{doc}})) . " alternative isoforms. <ul class='TERMINALgroup' id='AS_DOC${x}options'>\n";
	$ALTSP_list .= join("\n",@{$INC{Alternative}->{doc}}) . "</ul></li>\n";
      }
      if(exists($INC{Additional}->{doc})){
	$ALTSP_list .= <<END;
<li><img src='${IMAGEDIR}GDBmenuArrow2.png' class='menubutton' id='AS_DOC${x}closed' onclick='openMENU("AS_DOC${x}");'>
<img src='${IMAGEDIR}GDBmenuArrow.png' class='menubutton' id='AS_DOC${x}open' onclick='closeMENU("AS_DOC${x}");' style='display:none;'>
This intron is DOCUMENTED by
END
	$ALTSP_list .= (scalar(@{$INC{Additional}->{doc}})) . " alternative isoforms. <ul class='TERMINALgroup' id='AS_DOC${x}options'>\n";
	$ALTSP_list .= join("\n",@{$INC{Additional}->{doc}}) . "</ul></li>\n";
      }
      if(exists($self->{asiINFO}->{$intStr}->{INTRONS_alternative})){
	$ALTSP_list .= <<END;
<li><img src='${IMAGEDIR}GDBmenuArrow2.png' class='menubutton' id='AS_ALT${x}closed' onclick='openMENU("AS_ALT${x}");'>
<img src='${IMAGEDIR}GDBmenuArrow.png' class='menubutton' id='AS_ALT${x}open' onclick='closeMENU("AS_ALT${x}");' style='display:none;'>
This intron is supported by 
END
	$ALTSP_list .= (scalar(@{$INC{Alternative}->{iso}})) . " evidence alignments. <ul class='TERMINALgroup' id='AS_ALT${x}options'>\n";
	$ALTSP_list .= join("\n",@{$INC{Alternative}->{iso}}) . "</ul></li>\n";
      }
      if(exists($self->{asiINFO}->{$intStr}->{INTRONS_conflicting})){
	$ALTSP_list .= <<END;
<li><img src='${IMAGEDIR}GDBmenuArrow2.png' class='menubutton' id='AS_CON${x}closed' onclick='openMENU("AS_CON${x}");'>
<img src='${IMAGEDIR}GDBmenuArrow.png' class='menubutton' id='AS_CON${x}open' onclick='closeMENU("AS_CON${x}");' style='display:none;'>
This intron conflicts with 
END
	$ALTSP_list .= (scalar(@{$INC{Conflicting}->{iso}})) . " evidence alignments. <ul class='TERMINALgroup' id='AS_CON${x}options'>\n";
	$ALTSP_list .= join("\n",@{$INC{Conflicting}->{iso}}) . "</ul></li>\n";
      }
      if(exists($self->{asiINFO}->{$intStr}->{INTRONS_additional})){
	$ALTSP_list .= <<END;
<li><img src='${IMAGEDIR}GDBmenuArrow2.png' class='menubutton' id='AS_ADD${x}closed' onclick='openMENU("AS_ADD${x}");'>
<img src='${IMAGEDIR}GDBmenuArrow.png' class='menubutton' id='AS_ADD${x}open' onclick='closeMENU("AS_ADD${x}");' style='display:none;'>
This intron is supported by
END
	$ALTSP_list .= (scalar(@{$INC{Additional}->{iso}})) . " evidence alignments. <ul class='TERMINALgroup' id='AS_ADD${x}options'>\n";
	$ALTSP_list .= join("\n",@{$INC{Additional}->{iso}}) . "</ul></li>\n";
      }
      if(exists($self->{asiINFO}->{$intStr}->{INTRONS_erroneous})){
	$ALTSP_list .= <<END;
<li><img src='${IMAGEDIR}GDBmenuArrow2.png' class='menubutton' id='AS_ERR${x}closed' onclick='openMENU("AS_ERR${x}");'>
<img src='${IMAGEDIR}GDBmenuArrow.png' class='menubutton' id='AS_ERR${x}open' onclick='closeMENU("AS_ERR${x}");' style='display:none;'>
This intron is based on non-cognate evidence. <ul class='TERMINALgroup' id='AS_ERR${x}options'>
END
	$ALTSP_list .= join("\n",@{$INC{Erroneous}->{iso}}) . "</ul></li>\n";
      }
      if(exists($self->{asiINFO}->{$intStr}->{INTRONS_alt_isoform})){
	$ALTSP_list .= <<END;
<li><img src='${IMAGEDIR}GDBmenuArrow2.png' class='menubutton' id='AS_ISO${x}closed' onclick='openMENU("AS_ISO${x}");'>
<img src='${IMAGEDIR}GDBmenuArrow.png' class='menubutton' id='AS_ISO${x}open' onclick='closeMENU("AS_ISO${x}");' style='display:none;'>
This intron is NOT present in
END
	$ALTSP_list .= (scalar(@{$INC{Isoform}->{iso}})) . " alternative isoforms. <ul class='TERMINALgroup' id='AS_ISO${x}options'>\n";
	$ALTSP_list .= join("\n",@{$INC{Isoform}->{iso}}) . "</ul></li>\n";
      }

      $ALTSP_list .= "</ul></li>\n";
      $x++;
    }
    $ALTSP_list .= "</ul></li>\n";
  }



  my $CMRNA_list = "";
  if(exists($self->{cmINFO}->{CM_AltCPS}) && keys(%{$self->{cmINFO}->{CM_AltCPS}})){
    $CMRNA_list .= <<END;
<li><img src='${IMAGEDIR}GDBmenuArrow2.png' class='menubutton' id='CM_CPSclosed' onclick='openMENU("CM_CPS");'>
<img src='${IMAGEDIR}GDBmenuArrow.png' class='menubutton' id='CM_CPSopen' onclick='closeMENU("CM_CPS");' style='display:none;'>
Alternative Transcript Termination
END
    $CMRNA_list .= "( " . scalar(keys(%{$self->{cmINFO}->{CM_AltCPS}})) . " sites )\n<ul class='LISTgroup' id='CM_CPSoptions'>";
    foreach $CPS (sort {return $a<=>$b;} keys(%{$self->{cmINFO}->{CM_AltCPS}})){
      my $DOC = 0;
      $DOC += 1 if(!exists($self->{cmINFO}->{CM_AltCPS}->{$CPS}->{documented}));
      $DOC += 2 if(exists($self->{cmINFO}->{CM_AltCPS}->{$CPS}->{documented}) && exists($self->{cmINFO}->{CM_AltCPS}->{$CPS}->{documented}->{LOCAL}));
      $DOC += 4 if(exists($self->{cmINFO}->{CM_AltCPS}->{$CPS}->{documented}) && (!exists($self->{cmINFO}->{CM_AltCPS}->{$CPS}->{documented}->{LOCAL}) || (keys(%{$self->{cmINFO}->{CM_AltCPS}->{$CPS}->{documented}}) > 1)));
      $CMRNA_list .= <<END;
<li><img src='${IMAGEDIR}GDBmenuArrow2.png' class='menubutton' id='CM_CPS${CPS}closed' onclick='openMENU("CM_CPS${CPS}");'>
<img src='${IMAGEDIR}GDBmenuArrow.png' class='menubutton' id='CM_CPS${CPS}open' onclick='closeMENU("CM_CPS${CPS}");' style='display:none;'>
$IMGflag[$DOC] Termination Site: <span style='color:red;'>$CPS</span>
<ul class='LISTgroup' id='CM_CPS${CPS}options'>
END
      if($DOC > 1){
	$CMRNA_list .= <<END;
<li><img src='${IMAGEDIR}GDBmenuArrow2.png' class='menubutton' id='CM_TPEGdoc${CPS}closed' onclick='openMENU("CM_TPEGdoc${CPS}");'>
<img src='${IMAGEDIR}GDBmenuArrow.png' class='menubutton' id='CM_TPEGdoc${CPS}open' onclick='closeMENU("CM_TPEGdoc${CPS}");' style='display:none;'>
This site is documented in
END
        my @docAnn = ();
        foreach my $SRC (sort {return ($a eq 'LOCAL')?-1:($b eq 'LOCAL')?1:($a cmp $b);} keys(%{$self->{cmINFO}->{CM_AltCPS}->{$CPS}->{documented}})){
	  foreach my $annHR (sort {return $a->{geneid} cmp $b->{geneid};} values(%{$self->{cmINFO}->{CM_AltCPS}->{$CPS}->{documented}->{$SRC}})){
	    push(@docAnn,"<li>geneID: $annHR->{geneid}</li>");
	  }
	}
	$CMRNA_list .= "<span style='color:green;'>" . scalar(@docAnn) . "</span> annotation isoforms\n";
	$CMRNA_list .= "<ul class='TERMINALgroup' id='CM_TPEGdoc${CPS}options'>\n";
	$CMRNA_list .= join("\n",@docAnn) . "\n</ul></li>\n";
      }

      $CMRNA_list .= <<END;
<li><img src='${IMAGEDIR}GDBmenuArrow2.png' class='menubutton' id='CM_TPEG${CPS}closed' onclick='openMENU("CM_TPEG${CPS}");'>
<img src='${IMAGEDIR}GDBmenuArrow.png' class='menubutton' id='CM_TPEG${CPS}open' onclick='closeMENU("CM_TPEG${CPS}");' style='display:none;'>
This cleavage / polyadenylation site is supported by 
END
      $CMRNA_list .= "<span style='color:red;'>" . scalar(@{$self->{cmINFO}->{CM_AltCPS}->{$CPS}->{TPS}}) . "</span> three-prime evidence alignments\n";
      $CMRNA_list .= "<ul class='TERMINALgroup' id='CM_TPEG${CPS}options'>\n";
      foreach $tpeaAR (sort {return $a->[0]<=>$b->[0];} @{$self->{cmINFO}->{CM_AltCPS}->{$CPS}->{TPS}}){
	$CMRNA_list .= "<li>gi-$tpeaAR->[0]</li>\n";
      }
      $CMRNA_list .= "</ul></li>\n</ul></li>\n";
    }
    $CMRNA_list .= "</ul></li>\n";
  }



  if(exists($self->{cmINFO}->{CM_Fission}) && keys(%{$self->{cmINFO}->{CM_Fission}})){
    $CMRNA_list .= <<END;
<li><img src='${IMAGEDIR}GDBmenuArrow2.png' class='menubutton' id='CM_FISclosed' onclick='openMENU("CM_FIS");'>
<img src='${IMAGEDIR}GDBmenuArrow.png' class='menubutton' id='CM_FISopen' onclick='closeMENU("CM_FIS");' style='display:none;'>
Annotation Fission
END
    $CMRNA_list .= "( " . scalar(keys(%{$self->{cmINFO}->{CM_Fission}})) . " sites )\n<ul class='LISTgroup' id='CM_FISoptions'>";
    foreach $FIS (sort {return $a<=>$b;} keys(%{$self->{cmINFO}->{CM_Fission}})){
      my $DOC = 0;
      $DOC += 1 if(!exists($self->{cmINFO}->{CM_Fission}->{$FIS}->{documented}));
      $DOC += 2 if(exists($self->{cmINFO}->{CM_Fission}->{$FIS}->{documented}) && exists($self->{cmINFO}->{CM_Fission}->{$FIS}->{documented}->{LOCAL}));
      $DOC += 4 if(exists($self->{cmINFO}->{CM_Fission}->{$FIS}->{documented}) && (!exists($self->{cmINFO}->{CM_Fission}->{$FIS}->{documented}->{LOCAL}) || (keys(%{$self->{cmINFO}->{CM_Fission}->{$FIS}->{documented}}) > 1)));
      $CMRNA_list .= <<END;
<li><img src='${IMAGEDIR}GDBmenuArrow2.png' class='menubutton' id='CM_FIS${FIS}closed' onclick='openMENU("CM_FIS${FIS}");'>
<img src='${IMAGEDIR}GDBmenuArrow.png' class='menubutton' id='CM_FIS${FIS}open' onclick='closeMENU("CM_FIS${FIS}");' style='display:none;'>
$IMGflag[$DOC] Fission Site: <span style='color:red;'>$FIS</span>
<ul class='LISTgroup' id='CM_FIS${FIS}options'>
END
      if($DOC > 1){
	$CMRNA_list .= <<END;
<li><img src='${IMAGEDIR}GDBmenuArrow2.png' class='menubutton' id='CM_FisTPEGdoc${FIS}closed' onclick='openMENU("CM_FisTPEGdoc${FIS}");'>
<img src='${IMAGEDIR}GDBmenuArrow.png' class='menubutton' id='CM_FisTPEGdoc${FIS}open' onclick='closeMENU("CM_FisTPEGdoc${FIS}");' style='display:none;'>
This site is documented in
END
        my @docAnn = ();
        foreach my $SRC (sort {return ($a eq 'LOCAL')?-1:($b eq 'LOCAL')?1:($a cmp $b);} keys(%{$self->{cmINFO}->{CM_Fission}->{$FIS}->{documented}})){
	  foreach my $annHR (sort {return $a->{geneid} cmp $b->{geneid};} values(%{$self->{cmINFO}->{CM_Fission}->{$FIS}->{documented}->{$SRC}})){
	    push(@docAnn,"<li>geneID: $annHR->{geneid}</li>");
	  }
	}
	$CMRNA_list .= "<span style='color:green;'>" . scalar(@docAnn) . "</span> annotations\n";
	$CMRNA_list .= "<ul class='TERMINALgroup' id='CM_FisTPEGdoc${FIS}options'>\n";
	$CMRNA_list .= join("\n",@docAnn) . "\n</ul></li>\n";
      }

      $CMRNA_list .= <<END;
<li><img src='${IMAGEDIR}GDBmenuArrow2.png' class='menubutton' id='CM_FisTPEG${FIS}closed' onclick='openMENU("CM_FisTPEG${FIS}");'>
<img src='${IMAGEDIR}GDBmenuArrow.png' class='menubutton' id='CM_FisTPEG${FIS}open' onclick='closeMENU("CM_FisTPEG${FIS}");' style='display:none;'>
This fission site is supported by 
END
      $CMRNA_list .= "<span style='color:red;'>" . scalar(@{$self->{cmINFO}->{CM_Fission}->{$FIS}->{TPS}}) . "</span> three-prime evidence alignments\n";
      $CMRNA_list .= "<ul class='TERMINALgroup' id='CM_FisTPEG${FIS}options'>\n";
      foreach $tpeaAR (sort {return $a->[0]<=>$b->[0];} @{$self->{cmINFO}->{CM_Fission}->{$FIS}->{TPS}}){
	$CMRNA_list .= "<li>gi-$tpeaAR->[0]</li>\n";
      }
    }
    $CMRNA_list .= "</ul></li>\n</ul></li>\n</ul></li>\n";
  }




  if(exists($self->{cmINFO}->{CM_Fusion}) && keys(%{$self->{cmINFO}->{CM_Fusion}})){
    $CMRNA_list .= <<END;
<li><img src='${IMAGEDIR}GDBmenuArrow2.png' class='menubutton' id='CM_FUSclosed' onclick='openMENU("CM_FUS");'>
<img src='${IMAGEDIR}GDBmenuArrow.png' class='menubutton' id='CM_FUSopen' onclick='closeMENU("CM_FUS");' style='display:none;'>
Annotation Fusion
END
    $CMRNA_list .= "( " . scalar(keys(%{$self->{cmINFO}->{CM_Fusion}})) . " sites )\n<ul class='LISTgroup' id='CM_FUSoptions'>";
    my $x=0;
    foreach $fannHR (sort {return $a->{geneid} cmp $b->{geneid};} values(%{$self->{cmINFO}->{CM_Fusion}})){
      my $pgsDefAR = exists($fannHR->{PGS_bridged})?$fannHR->{PGS_bridged}:[];
      my $cpDefAR = exists($fannHR->{CP_bridged})?$fannHR->{CP_bridged}:[];
      my $DOC = 0;
      $DOC += 1 if(!exists($fannHR->{documented}));
      $DOC += 2 if(exists($fannHR->{documented}) && exists($fannHR->{documented}->{LOCAL}));
      $DOC += 4 if(exists($fannHR->{documented}) && (!exists($fannHR->{documented}->{LOCAL}) || (keys(%{$fannHR->{documented}}) > 1)));
      $CMRNA_list .= <<END;
<li><img src='${IMAGEDIR}GDBmenuArrow2.png' class='menubutton' id='CM_FUS${x}closed' onclick='openMENU("CM_FUS${x}");'>
<img src='${IMAGEDIR}GDBmenuArrow.png' class='menubutton' id='CM_FUS${x}open' onclick='closeMENU("CM_FUS${x}");' style='display:none;'>
$IMGflag[$DOC] $fannHR->{geneid}
END
      $CMRNA_list .= "( ";
      $CMRNA_list .= scalar(@$pgsDefAR) . " bridging alignments " if(scalar(@$pgsDefAR));
      $CMRNA_list .= scalar(@$pgsDefAR)? "| " . scalar(@$cpDefAR) . " bridging clonepairs ": scalar(@$cpDefAR) . " bridging clonepairs " if(scalar(@$cpDefAR));
      $CMRNA_list .= " )\n<ul class='LISTgroup' id='CM_FUS${x}options'>\n";

      if($DOC > 1){
	$CMRNA_list .= <<END;
<li><img src='${IMAGEDIR}GDBmenuArrow2.png' class='menubutton' id='CM_FUS${x}DOCclosed' onclick='openMENU("CM_FUS${x}DOC");'>
<img src='${IMAGEDIR}GDBmenuArrow.png' class='menubutton' id='CM_FUS${x}DOCopen' onclick='closeMENU("CM_FUS${x}DOC");' style='display:none;'>
This fusion is documented in
END
        my @docAnn = ();
        foreach my $SRC (sort {return ($a eq 'LOCAL')?-1:($b eq 'LOCAL')?1:($a cmp $b);} keys(%{$fannHR->{documented}})){
	  foreach my $annHR (sort {return $a->{geneid} cmp $b->{geneid};} values(%{$fannHR->{documented}->{$SRC}})){
	    push(@docAnn,"<li>geneID: $annHR->{geneid}</li>");
	  }
	}
	$CMRNA_list .= "<span style='color:green;'>" . scalar(@docAnn) . "</span> annotations\n";
	$CMRNA_list .= "<ul class='TERMINALgroup' id='CM_FUS${x}DOCoptions'>\n";
	$CMRNA_list .= join("\n",@docAnn) . "\n</ul></li>\n";

      }
      if(scalar(@$pgsDefAR)){
	$CMRNA_list .= <<END;
<li><img src='${IMAGEDIR}GDBmenuArrow2.png' class='menubutton' id='CM_FUS${x}PGSclosed' onclick='openMENU("CM_FUS${x}PGS");'>
<img src='${IMAGEDIR}GDBmenuArrow.png' class='menubutton' id='CM_FUS${x}PGSopen' onclick='closeMENU("CM_FUS${x}PGS");' style='display:none;'>
Evidence alignments bridging these annotations
<ul class='TERMINALgroup' id='CM_FUS${x}PGSoptions'>
END
        foreach $pgsHR (sort {return $a->{pgsgi} <=> $b->{pgsgi};} @$pgsDefAR){
	  $CMRNA_list .= "<li>$pgsHR->{pgsgi}</li>\n";
	}
	$CMRNA_list .= "</ul></li>\n";
      }
      if(scalar(@$cpDefAR)){
	$CMRNA_list .= <<END;
<li><img src='${IMAGEDIR}GDBmenuArrow2.png' class='menubutton' id='CM_FUS${x}CPclosed' onclick='openMENU("CM_FUS${x}CP");'>
<img src='${IMAGEDIR}GDBmenuArrow.png' class='menubutton' id='CM_FUS${x}CPopen' onclick='closeMENU("CM_FUS${x}CP");' style='display:none;'>
Clonepairs bridging these annotations
<ul class='TERMINALgroup' id='CM_FUS${x}CPoptions'>
END
        foreach $cpHR (sort {return $a->{pgsgi} <=> $b->{pgsgi};} @$cpDefAR){
	  $CMRNA_list .= "<li>$cpHR->{pgi} -- $cpHR->{sgi}</li>\n";
	}
	$CMRNA_list .= "</ul></li>\n";
      }

      $CMRNA_list .= "</ul></li>\n";
      $x++;
    }

    $CMRNA_list .= "</ul></li>\n";
  }



  my $EOLAP_list = "";
  if(exists($self->{aoaINFO}->{AMB_annotations}) && keys(%{$self->{aoaINFO}->{AMB_annotations}})){
    $EOLAP_list = <<END;
<li><img src='${IMAGEDIR}GDBmenuArrow2.png' class='menubutton' id='EOclosed' onclick='openMENU("EO");'>
<img src='${IMAGEDIR}GDBmenuArrow.png' class='menubutton' id='EOopen' onclick='closeMENU("EO");' style='display:none;'>
Erroneous Annotation Extension & Overlap <ul class='EOgroup' id='EOoptions'>
END
    my $x=0;
    foreach $oaHR (sort {return $a->{OAgeneId} cmp $b->{OAgeneId};} values %{$self->{aoaINFO}->{AMB_annotations}}){
      $EOLAP_list .= <<END;
<li><img src='${IMAGEDIR}GDBmenuArrow2.png' class='menubutton' id='OA${x}closed' onclick='openMENU("OA${x}");'>
<img src='${IMAGEDIR}GDBmenuArrow.png' class='menubutton' id='OA${x}open' onclick='closeMENU("OA${x}");' style='display:none;'>
Overlaping Annotation: $oaHR->{OAgeneId}
<ul class='LISTgroup' id='OA${x}options'>
<li><img src='${IMAGEDIR}GDBmenuArrow2.png' class='menubutton' id='OA${x}_ERRclosed' onclick='openMENU("OA${x}_ERR");'>
<img src='${IMAGEDIR}GDBmenuArrow.png' class='menubutton' id='OA${x}_ERRopen' onclick='closeMENU("OA${x}_ERR");' style='display:none;'>
Incongruent Evidence
END
      my @AmbISE=();
      foreach $PGStable (keys %{$oaHR->{AmbISO}}){
	foreach $AmbISE_HR (values %{$oaHR->{AmbISO}->{$PGStable}}){
	  push(@AmbISE,"<li>$AmbISE_HR->{gi}</li>");
	}
      }

      $EOLAP_list .= "( " . scalar(@AmbISE) . " Ambiguous ISEs )\n<ul class='TERMINALgroup' id='OA${x}_ERRoptions'>\n";
      $EOLAP_list .= join("\n",@AmbISE);
      $EOLAP_list .= "\n</ul></li>\n</ul></li>\n";
      $x++;
    }
    $EOLAP_list .= "</ul></li>\n"
  }



  my $page = <<END_OF_PAGE;
<STYLE>
table#flags { background:#F0F8FF; border:2px dotted maroon; }
div.GAEVAL { width:700px; text-align:center; margin:5px; }
div#GAEVALsummary .color { color:$self->{primaryColor}; }
div#GAEVALsummary img { padding:2px; }
div#GAEVALsummary th { font:bold 12px monotype; padding:2px 4px; }
div#GAEVALsummary td { font:normal 12px monotype; padding:2px; text-align:center; border:1px dotted blue;}
UL#GAEVALreport { text-align:left; list-style:none; padding:0px; }
IMG#ISopen, UL.ISgroup, UL.ASgroup, UL.EOgroup, UL.LISTgroup, IMG#IAclosed { display:none; }
UL.ISgroup, UL.IAgroup, UL.ASgroup, UL.EOgroup, UL.LISTgroup { background:lightblue; padding-left:5px; list-style:none; }
UL.ASgroup, UL.EOgroup, UL.LISTgroup { background:#DCDCDC; }
UL.TERMINALgroup, UL.INgroup { background:tomato; display:none; }
UL.ASgroup IMG.DOCtype { height:15px; margin:1px;}

SPAN.annINTRON { color:blue; }
SPAN.annINTRON IMG.DOCtype { display:none; }
IMG.menubutton { width:10px; margin:0px 10px 4px 0px; vertical-align:text-bottom; background:lightgrey; border:2px inset lightgrey; }
</STYLE>

<div class='GAEVAL' id='GAEVALsummary'>
<h2>$self->{trackname} GAEVAL Report: <span class='color'>$recordHR->{geneid}</span></h2>
<table align='center' id='flags'>
<tr><th>GeneId</th>
<th><img alt='Upstream Extension' title='Upstream Extension' src='${IMAGEDIR}Flags/UTR5_add.png'></th>
<th>5&apos;UTR</th><th>CDS</th><th>3&apos;UTR</th>
<th><img alt='Downstream Extension' title='Downstream Extension' src='${IMAGEDIR}Flags/UTR3_add.png'></th>
<th>%coverage</th><th>Introns Confirmed</th><th>Introns Unsupported</th>
<th><img alt='Alternative Splicing' title='Alternative Splicing' src='${IMAGEDIR}Flags/AltStr.png'></th>
<th><img alt='Alternative Transcriptional Termination' title='Alternative Transcriptional Termination' src='${IMAGEDIR}Flags/ATTgene.png'></th>
<th><img alt='Annotation Spliting / Fission' title='Annotation Spliting / Fission' src='${IMAGEDIR}Flags/SplitGene.png'></th>
<th><img alt='Annotation Merger / Fusion' title='Annotation Merger / Fusion' src='${IMAGEDIR}Flags/MergeGene.png'></th>
<th><img alt='Erroneous Annotation Overlap' title='Erroneous Annotation Overlap' src='${IMAGEDIR}Flags/AmbOlap.png'></th>
</tr>
<tr><td><a href='${CGIPATH}getRecord.pl?dbid=$self->{db_id}&resid=$self->{resid}&$argHR->{recordTYPE}=$recordHR->{uid}'>$recordHR->{geneid}</a></td>
<td>$b5</td>
<td>$recordHR->{utr5_size}</td>
<td>$recordHR->{cds_size}</td>
<td>$recordHR->{utr3_size}</td>
<td>$b3</td>
<td>${pcov}%</td>
<td>$recordHR->{introns_confirmed}</td>
<td>$recordHR->{introns_unsupported}</td>
<td>$IMGflag[$AStype]</td><td>$IMGflag[$ATtype]</td><td>$IMGflag[$FItype]</td><td>$IMGflag[$FUtype]</td><td>$IMGflag[$EOtype]</td>
</tr>
</table>
</div>
$structIMG
<div class='GAEVAL'>
<ul id='GAEVALreport'>
<li><img src='${IMAGEDIR}GDBmenuArrow2.png' class='menubutton' id='ISclosed' onclick='openMENU("IS");'>
<img src='${IMAGEDIR}GDBmenuArrow.png' class='menubutton' id='ISopen' onclick='closeMENU("IS");'>Intron Support
<ul class='ISgroup' id='ISoptions'>
$INSUP_list
</ul>
</li>
<li><img src='${IMAGEDIR}GDBmenuArrow2.png' class='menubutton' id='IAclosed' onclick='openMENU("IA");'>
<img src='${IMAGEDIR}GDBmenuArrow.png' class='menubutton' id='IAopen' onclick='closeMENU("IA");'>Incongruency Analysis
<ul class='IAgroup' id='IAoptions'>
$ALTSP_list
$CMRNA_list
$EOLAP_list
</ul>
</li>
</ul>
</div>

END_OF_PAGE

  return ({'-script'=>[{-src=>"${JSPATH}GAEVALquery.js"}]},$page);
}

sub drawStar{
  my($img,$x,$y,$c) = @_;
  my $poly = new GD::Polygon;
  $poly->addPt($x,$y);
  $poly->addPt($x-1,$y+2);
  $poly->addPt($x,$y+4);
  $poly->addPt($x+1,$y+2);
  $img->filledPolygon($poly,$c);

}

sub drawSupportFlag{
  my $self = shift;
  my ($recordHR) = @_;

  my $imgpath = $TMPDIR . $self->{GAEVAL_ANN_TBL} . "_" . $recordHR->{uid} . ".png";
  my $imgDesc = '';

  my $img = new GD::Image(20,20);
  my $white  = $img->colorAllocate(255,255,255);
  my $black  = $img->colorAllocate(0,0,0);
  my $maroon = $img->colorAllocate(128,0,0);
  my $gold   = $img->colorAllocate(255,215,0);

  if($recordHR->{introns_confirmed} + $recordHR->{introns_unsupported}){
    my $label = $recordHR->{introns_confirmed};
    my $halflen = int((gdTinyFont->width)*length($label)/2);
    $img->string(gdTinyFont,(10 - $halflen),0,$label,$maroon);
    $label = ($recordHR->{introns_confirmed} + $recordHR->{introns_unsupported});
    $halflen = int((gdTinyFont->width)*length($label)/2);
    $img->string(gdTinyFont,(10 - $halflen),11,$label,$black);
    $imgDesc .= "This annotation has " . $recordHR->{introns_confirmed} . " of " . ($recordHR->{introns_confirmed} + $recordHR->{introns_unsupported}) . " introns confirmed by evidence alignments.";
    $starHEIGHT = 7;
  }else{
    my $label = int($recordHR->{exon_coverage} * 100) . "%";
    my $halflen = int((gdTinyFont->width)*length($label)/2);
    $img->string(gdTinyFont,(10 - $halflen),4,$label,$maroon);
    $starHEIGHT = 12;
  }
  $imgDesc .= int($recordHR->{exon_coverage} * 100) . "% of the annotated sequence is confirmed by isoform specific expressed evidence.";
  $imgDesc .= "The total length of this Annotation is " . ($recordHR->{utr5_size} + $recordHR->{cds_size} + $recordHR->{utr3_size}) . " bases (5\\\`UTR|CDS|3\\\'UTR) (" . $recordHR->{utr5_size} . "|" . $recordHR->{cds_size} . "|" . $recordHR->{utr3_size} . ").";

#  my $stars = int(($recordHR->{integrity} - 0.5)*10)+1;
#  $stars = ($stars > 0)?$stars:0;
#  drawStar($img,0,0,$gold) if($stars >= 1);
#  drawStar($img,17,0,$gold) if($stars >= 2);
#  drawStar($img,0,15,$gold) if($stars >= 3);
#  drawStar($img,17,15,$gold) if($stars >= 4);
#  drawStar($img,9,$starHEIGHT,$gold) if($stars >= 5);

  open(IMG,"> $imgpath");
  binmode IMG;
  print IMG $img->png;
  close IMG;

  $self->{curImgDesc} = $imgDesc;

  return ($imgpath,$imgDesc);
}

sub flagINFO{
  my $self= shift;
  my ($recordHR,$URL) = @_;

  my ($supImg,$supDesc) = $self->drawSupportFlag($recordHR);
  my @img = ($supImg);
  my @imgDesc = ($supDesc); 
  if(($recordHR->{as_addintron} && !$recordHR->{as_addintron_doc})||($recordHR->{as_altintron} && !$recordHR->{as_altintron_doc})||($recordHR->{as_conintron} && !$recordHR->{as_conintron_doc})){
    push(@img,$GAEVAL_FLAGS->{altspl}->{filepath});
    push(@imgDesc,$GAEVAL_FLAGS->{altspl}->{description});
  }
  if($recordHR->{cm_altcps} && !$recordHR->{cm_altcps_doc}){
    push(@img,$GAEVAL_FLAGS->{altcps}->{filepath});
    push(@imgDesc,$GAEVAL_FLAGS->{altcps}->{description});
  }
  if($recordHR->{cm_fission} && !$recordHR->{cm_fission_doc}){
    push(@img,$GAEVAL_FLAGS->{fis}->{filepath});
    push(@imgDesc,$GAEVAL_FLAGS->{fis}->{description}) ;
  }
  if($recordHR->{cm_fusion} && !$recordHR->{cm_fusion_doc}){
    push(@img,$GAEVAL_FLAGS->{fus}->{filepath});
    push(@imgDesc,$GAEVAL_FLAGS->{fus}->{description}) ;
  }
  if($recordHR->{ae_amboverlap} && !$recordHR->{ae_amboverlap_doc}){
    push(@img,$GAEVAL_FLAGS->{eolap}->{filepath});
    push(@imgDesc,$GAEVAL_FLAGS->{eolap}->{description}) ;
  }

  return({'url'=>$URL,
	  'l_pos'=>$recordHR->{l_pos},'r_pos'=>$recordHR->{r_pos}},\@img,\@imgDesc);
}

sub getFlagURL{
  my $self = shift;
  my ($argHR,$recordHR,$gContext) = @_;

  my $gsrc = defined($gCONTEXT)?($gCONTEXT eq 'BAC')?"gseg" :
    ($gCONTEXT eq 'CHR')?"chr":$gCONTEXT :
      exists($argHR->{altCONTEXT})?($argHR->{altCONTEXT} eq 'BAC')?"gseg":
	($argHR->{altCONTEXT} =~ /chr/i)?'chr':$argHR->{altCONTEXT} : 
	  exists($argHR->{gsegUID})?"gseg":"chr";

  return "${CGIPATH}GAEVALreport.pl?dbid=$self->{db_id}&resid=$self->{resid}&${gsrc}UID=$recordHR->{uid}";
}

sub showRECORD{
  my $self= shift;
  my ($argHR) = @_;

  exists($argHR->{selectedRECORD}) || (@$argHR{'recordTYPE','selectedRECORD'} = $self->selectRECORD($argHR));
  my $recordHR = $argHR->{selectedRECORD};

  my @IMGflag = ("<img alt='none' title='No Incongruence' src='${IMAGEDIR}Flags/null.png'>",
		 "<img alt='undoc' title='Undocumented Incongruence' src='${IMAGEDIR}Flags/xmark.png'>",
		 "<img alt='iso' title='Isoform Documented Incongruence' src='${IMAGEDIR}Flags/lmark.png'>",
		 "<img alt='undoc_iso' title='Undocumented & Isoform Documented Incongruence' src='${IMAGEDIR}Flags/xlmark.png'>",
		 "<img alt='uca' title='User Annotated Incongruence' src='${IMAGEDIR}Flags/umark.png'>",
		 "<img alt='undoc_uca' title='Undocumented & User Annotated Incongruence' src='${IMAGEDIR}Flags/xumark.png'>",
		 "<img alt='iso_uca' title='Isoform Documented and User Annotated Incongruence' src='${IMAGEDIR}Flags/lumark.png'>",
		 "<img alt='undoc_iso_uca' title='Undocumented, Isoform Documented, and User Annotated Incongruence' src='${IMAGEDIR}Flags/xlumark.png'>");
  my $pcov = int($recordHR->{exon_coverage} * 100);
  my $b5 = ($recordHR->{bound_5prime} < 0)?(-1 * $recordHR->{bound_5prime}):"";
  my $b3 = ($recordHR->{bound_3prime} < 0)?(-1 * $recordHR->{bound_3prime}):"";

  my $AStype = 0;
  $AStype += 1 if(($recordHR->{as_addintron} && !$recordHR->{as_addintron_doc})||($recordHR->{as_altintron} && !$recordHR->{as_altintron_doc})||($recordHR->{as_conintron} && !$recordHR->{as_conintron_doc}));
  $AStype += 2 if(($recordHR->{as_addintron} && ($recordHR->{as_addintron_mindoc} < 0))||($recordHR->{as_altintron} && ($recordHR->{as_altintron_mindoc} < 0))||($recordHR->{as_conintron} && ($recordHR->{as_conintron_mindoc} < 0)));
  $AStype += 4 if(($recordHR->{as_addintron} && ($recordHR->{as_addintron_maxdoc} > 0))||($recordHR->{as_altintron} && ($recordHR->{as_altintron_maxdoc} > 0))||($recordHR->{as_conintron} && ($recordHR->{as_conintron_maxdoc} > 0)));

  my $ATtype = 0;
  $ATtype += 1 if($recordHR->{cm_altcps} && !$recordHR->{cm_altcps_doc});
  $ATtype += 2 if($recordHR->{cm_altcps} && ($recordHR->{cm_altcps_mindoc} < 0));
  $ATtype += 4 if($recordHR->{cm_altcps} && ($recordHR->{cm_altcps_maxdoc} > 0));

  my $FItype = 0;
  $FItype += 1 if($recordHR->{cm_fission} && !$recordHR->{cm_fission_doc});
  $FItype += 2 if($recordHR->{cm_fission} && ($recordHR->{cm_fission_mindoc} < 0));
  $FItype += 4 if($recordHR->{cm_fission} && ($recordHR->{cm_fission_maxdoc} > 0));

  my $FUtype = 0;
  $FUtype += 1 if($recordHR->{cm_fusion} && !$recordHR->{cm_fusion_doc});
  $FUtype += 2 if($recordHR->{cm_fusion} && ($recordHR->{cm_fusion_mindoc} < 0));
  $FUtype += 4 if($recordHR->{cm_fusion} && ($recordHR->{cm_fusion_maxdoc} > 0));

  my $EOtype = 0;
  $EOtype += 1 if($recordHR->{ae_amboverlap} && !$recordHR->{ae_amboverlap_doc});
  $EOtype += 2 if($recordHR->{ae_amboverlap} && ($recordHR->{ae_amboverlap_mindoc} < 0));
  $EOtype += 4 if($recordHR->{ae_amboverlap} && ($recordHR->{ae_amboverlap_maxdoc} > 0));


  my($htmlHR,$jscript,$content) = $self->SUPER::showRECORD(@_);
  my $reportURL = $self->getFlagURL($argHR,$recordHR);

  $content .= <<END_OF_GAEVAL_SUMMARY;
<style type='text/css'>
table#Ghead { width:700px; margin:0px; padding:2px; background:#DCDCDC; }
div#GAEVALsummary { width:700px; text-align:center; border:2px dotted maroon; }
div#GAEVALsummary th { font:bold 12px monotype; padding:2px 4px; }
div#GAEVALsummary td { font:normal 12px monotype; padding:2px; text-align:center; border:1px dotted blue;}
table#flags th { width:30px; }
</style>

<div id='GAEVALsummary'>
<table id='Ghead'>
<td style='text-align:left; font:bold 18px monotype; border:none;'>GAEVAL Summary</td>
<td style='width:100px; font:normal 10px sans-serif; border:none; '>
<a style="text-decoration:none;" href='$reportURL'><img src='${IMAGEDIR}Flags/gaeval.png' style='margin-bottom:2px;'><br />Full Report</a></td>
</table>
<table align='center' id='flags'>
<tr>
<th><img alt='Upstream Extension' title='Upstream Extension' src='${IMAGEDIR}Flags/UTR5_add.png' /></th>
<th><img alt='Downstream Extension' title='Downstream Extension' src='${IMAGEDIR}Flags/UTR3_add.png' /></th>
<th><img alt='Alternative Splicing' title='Alternative Splicing' src='${IMAGEDIR}Flags/AltStr.png' /></th>
<th><img alt='Alternative Transcriptional Termination' title='Alternative Transcriptional Termination' src='${IMAGEDIR}Flags/ATTgene.png' /></th>
<th><img alt='Annotation Spliting / Fission' title='Annotation Spliting / Fission' src='${IMAGEDIR}Flags/SplitGene.png' /></th>
<th><img alt='Annotation Merger / Fusion' title='Annotation Merger / Fusion' src='${IMAGEDIR}Flags/MergeGene.png' /></th>
<th><img alt='Erroneous Annotation Overlap' title='Erroneous Annotation Overlap' src='${IMAGEDIR}Flags/AmbOlap.png' /></th>
<th rowspan="3"></th>
</tr>
<tr><td>$b5</td><td>$b3</td><td>$IMGflag[$AStype]</td><td>$IMGflag[$ATtype]</td><td>$IMGflag[$FItype]</td><td>$IMGflag[$FUtype]</td><td>$IMGflag[$EOtype]</td></tr>
</table>
<table align='center'>
<tr>
	<th>5&apos;UTR</th><th>CDS</th><th>3&apos;UTR</th><th>%coverage</th><th>Introns Confirmed</th><th>Introns Unsupported</th>
</tr>
<tr>
	<td>$recordHR->{utr5_size}</td><td>$recordHR->{cds_size}</td><td>$recordHR->{utr3_size}</td><td>${pcov}%</td><td>$recordHR->{introns_confirmed}</td><td>$recordHR->{introns_unsupported}</td>
</tr>
</table>
</div>

END_OF_GAEVAL_SUMMARY

  return ($htmlHR,$jscript,$content);
}

$GAEVAL_FLAGS = {'altspl'=>{'filepath'   =>"${ABS_IMAGEDIR}Flags/AltStr.png",
			    'description'=>"This gene model appears to contain expressed sequence alignment(s) which suggest an ALTERNATIVE STRUCTURE that has yet to be represented.",
			   },
		 'altcps'=>{'filepath'   =>"${ABS_IMAGEDIR}Flags/ATTgene.png",
			    'description'=>"An alternative transcriptional termination site may be available to this gene model.",
			   },
		 'fis'=>{'filepath'   =>"${ABS_IMAGEDIR}Flags/SplitGene.png",
			 'description'=>"This gene model appears to be the CONCATENATED product of more than one gene.",
			},
		 'fus'=>{'filepath'   =>"${ABS_IMAGEDIR}Flags/MergeGene.png",
			 'description'=>"This gene model appears to be TRUNCATED. Sequence alignment evidence suggests the merger of this gene model with an adjacent gene model.",
			},
		 'eolap'=>{'filepath'   =>"${ABS_IMAGEDIR}Flags/AmbOlap.png",
			   'description'=>"The annotated UTR for this gene model overlaps with an adjacent gene model. This may cause a falsely extended UTR due to the ambiguous assignment of sequences within the overlapping region.",
			  }
		};


1;
