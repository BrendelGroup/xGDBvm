package GenomeSegmentTrack;
use base "Locus";

do 'SITEDEF.pl';

use GeneView;
use CGI ':all';

sub whatami{
  my $self = shift;
  $self->SUPER::whatami();
  return "GenomeSegmentTrack:";
}

sub _init{
  my $self = shift;

  $self->SUPER::_init(@_);
  $self->{xDAS_list_ep_AVAILABLE} = 1;

}

sub xDAS_list_ep{
  my $self = shift;
  my ($argHR) = @_;

  my $ret = '';

  my $EP_QUERY = exists($self->{xDAS_ep_query})?$self->{xDAS_ep_query}:"SELECT gi,length(seq) FROM $self->{db_table}";

  my $sth = $self->{dbh}->prepare_cached($EP_QUERY);
  $sth->execute();
  my $resAR = $sth->fetchall_arrayref();
  for(my$x=0; $x<=$#$resAR; $x++){
    my @ids = @{$resAR->[$x]};
    my $len = pop(@ids);
    foreach $id (@ids){
      next if($id eq '');
      $ret .= "<SEGMENT id=\"$id\" start=\"1\" stop=\"$len\" size=\"$len\" orientation=\"+\">$id</SEGMENT>\n";
    }
  }
  return "$ret";
}

sub getMENU{
  my $self = shift;
  my ($argHR) = @_;
  my ($sth,$label);

  my $CGI_param_name = exists($argHR->{MENU_CGI_ID})?$argHR->{MENU_CGI_ID}:"gseg_gi";
  my $initialGSEG = exists($argHR->{GSEGinitial})?$argHR->{GSEGinitial}:
		    exists($argHR->{$CGI_param_name})?$argHR->{$CGI_param_name}:undef;
  my $prefLabel = (exists($self->{prefLabel}))?$self->{prefLabel}:'uid';
  $self->{dbh}->{FetchHashKeyName} = 'NAME_lc';
  $sth = $self->{dbh}->prepare_cached($self->{SQL_BASE});
  $sth->execute();
  my $membersHR = $sth->fetchall_hashref($prefLabel);
  my $valueAR = []; 
  my %labelHASH = ();
  foreach $label (sort keys %$membersHR){
    push (@$valueAR,$membersHR->{$label}{gi});
    $labelHASH{$membersHR->{$label}{gi}}=$label;
  }

  return CGI::popup_menu(-name    => $CGI_param_name,
			 -default => $initialGSEG,
			 -force   => 1,
			 -values  => $valueAR,
			 -labels  => \%labelHASH,
			);
}

sub search_by_ID{
  my $self = shift;
  my ($id) = @_;
  my ($field,$msg,$res_href,$sth);

  $id = $self->{VALIDATE_ID}->($id) if(exists($self->{VALIDATE_ID}));

  my ($chrLOCI,$gsegLOCI) = (0,0);
  $self->{dbh}->{FetchHashKeyName} = 'NAME_lc';
  if(exists($self->{gsegQUERY})){
    $sth = $self->{dbh}->prepare_cached($self->{gsegQUERY});
    $sth->execute($id);
    $self->{gsegLOCI_href} = $sth->fetchall_hashref("uid");
    if(keys %{$self->{gsegLOCI_href}}){
      ($res_href) =  values %{$self->{gsegLOCI_href}};
      foreach $field (keys %$res_href){
	## Dump the first hits general fields into the DSO properties
	## This is a kludge: need to use recordHR and selectedRECORD
	$self->{$field} = $res_href->{$field};
      }
      $gsegLOCI = scalar(keys(%{$self->{gsegLOCI_href}}));
    }
    $sth->finish();
  }
  if(exists($self->{seqQUERY})){
    $sth = $self->{dbh}->prepare_cached($self->{seqQUERY});
    $sth->execute($id);
    $self->{chrLOCI_href} = $sth->fetchall_hashref("uid");
    if(keys %{$self->{chrLOCI_href}}){
      ($res_href) =  values %{$self->{chrLOCI_href}};
      foreach $field (keys %$res_href){
	## Dump the first hits general fields into the DSO properties
	## This is a kludge: need to use recordHR and selectedRECORD
	$self->{$field} = $res_href->{$field};
      }
      $chrLOCI = scalar(keys(%{$self->{chrLOCI_href}}));
    }
    $sth->finish();
  }

  return ($chrLOCI,$gsegLOCI);
}

sub selectRECORD{
  my $self = shift;
  my ($argHR) = @_;
  my ($record,$type);

  $self->{dbh}->{FetchHashKeyName} = 'NAME_lc';
  my $id = exists($argHR->{gi})?$argHR->{gi}:
	   exists($argHR->{id})?$argHR->{id}:
           exists($argHR->{geneid})?$argHR->{geneid}:
	   undef;

  $id = $self->{VALIDATE_ID}->($id) if(exists($self->{VALIDATE_ID}));
  if(exists($argHR->{chrUID})){ ##NB: EVENTUALLY THIS WILL HAVE TO BE EXTENDED TO SEARCH ALL LOCI CONTEXTS - NOT JUCT pchr/gseg
    if((!exists($self->{gi}))||($self->{gi} ne $argHR->{chrUID})){
      $sth = $self->{dbh}->prepare_cached($self->{chrUID_QUERY});
      $sth->execute($argHR->{chrUID});
      $self->{chrLOCI_href} = $sth->fetchall_hashref("uid");
      $sth->finish();
      if((exists($self->{chrLOCI_href})) && scalar(keys(%{$self->{chrLOCI_href}}))){
	$record = $self->{chrLOCI_href}->{$argHR->{chrUID}};
      }else{
	return undef; ## nothing found by search
      }
    }
    $type = 'chrUID';
  }elsif(exists($argHR->{gsegUID})){
    if((!exists($self->{gi}))||($self->{gi} ne $argHR->{gsegUID})){
      $sth = $self->{dbh}->prepare_cached($self->{gsegUID_QUERY});
	eval {
		$sth->bind_param (1,$argHR->{gsegUID});
      $sth->execute();
      $self->{gsegLOCI_href} = $sth->fetchall_hashref("uid");
      $sth->finish();
	};
      if((exists($self->{gsegLOCI_href})) && scalar(keys(%{$self->{gsegLOCI_href}}))){
	$record = $self->{gsegLOCI_href}->{$argHR->{gsegUID}};
      }else{
	return undef; ## nothing found by search
      }
    }
    $type = 'gsegUID';
  }elsif(defined($id)){
    $self->search_by_ID($id);

        ## Get values using the first cognate locus (chr,gseg)
    my ($recordHR);
    if((exists($self->{chrLOCI_href}))&&(keys %{$self->{chrLOCI_href}})){
      $type = 'chrUID';
      foreach $recordHR(sort _by_CCLR values %{$self->{chrLOCI_href}}){
	$record = $recordHR if(!defined($record));
	if($recordHR->{iscognate} eq 'True'){
	  $record = $recordHR;
	  last;
	}
      }
    }elsif((exists($self->{gsegLOCI_href}))&&(keys %{$self->{gsegLOCI_href}})){
      $type = 'gsegUID';
      foreach $recordHR (sort _by_CCLR values %{$self->{gsegLOCI_href}}){
	$record = $recordHR if(!defined($record));
	if($recordHR->{iscognate} eq 'True'){
	  $record = $recordHR;
	  last;
	}
      }
    }else{
      return undef;
    }
  }
  return ($type,$record);
}

sub drawCombinedImage{
  my $self = shift;
  my ($view,$startY) = @_;
  my ($prevUID,$puid,$recordHR,$stINFO,$bottom,$recAR,%imap);

  $prevUID = -1; $bottom = 0;
  foreach $recordHR (sort _by_CCLR values %{$self->{pgsREGION_href}}){
    $stINFO = $self->structINFO('pgs',$recordHR);
    $stINFO->[1]{startHeight} = $startY;
    ($labelAR,$recAR) = $view->addGseg(@$stINFO[1..$#$stINFO]);
    $imap{$self->{resid} . "_" . $recordHR->{uid}} = [$labelAR,$recAR];
    $bottom = $recAR->[1] if($recAR->[1] > $bottom);
  }
  return (\%imap,$bottom);
}

sub showRECORD{
  my $self = shift;
  my ($argHR) = @_;

  exists($argHR->{selectedRECORD}) || (@$argHR{'recordTYPE','selectedRECORD'} = $self->selectRECORD($argHR));

  my $recordINFO      = $self->showRECORD_INFO($argHR,$argHR->{selectedRECORD});
  my $structIMG       = $self->showSTRUCT($argHR);
  my $chr_lociTABLE   = $self->showEXTENDED_LOCI_TABLE($argHR);
  my $bac_lociTABLE   = $self->showEXTENDED_LOCI_TABLE($argHR,'BAC');

  my $lociTABLES = '';
  $lociTABLES .= "<DIV style='margin:0; padding:0px; width:1000px; max-height:250px; overflow:auto; border:1px solid darkblue;'>$chr_lociTABLE</DIV>\n" if($chr_lociTABLE ne '');
  $lociTABLES .= "<DIV style='margin:0; padding:0px; width:1000px; max-height:250px; overflow:auto; border:1px solid khaki;'>$bac_lociTABLE</DIV>\n" if($bac_lociTABLE ne '');

  my $id = exists($argHR->{selectedRECORD}->{id})?$argHR->{selectedRECORD}->{id}:
           exists($argHR->{selectedRECORD}->{gi})?$argHR->{selectedRECORD}->{gi}:
	   exists($argHR->{selectedRECORD}->{geneid})?$argHR->{selectedRECORD}->{geneid}:
	   "unknownID";

  my $helpId = (exists($self->{helpfile}) && -r "${HELPDIR}$self->{helpfile}.inc.php")?$self->{helpfile}:
                (-r "${HELPDIR}$self->{trackname}.inc.php")? $self->{trackname}:
                (-r "${HELPDIR}$self->{DSOname}.inc.php")?$self->{DSOname}:'genome_segment_record_help';


  ## layout page
  my $PAGE_CONTENTS = <<END_OF_PAGE;
<h1>$self->{trackname} Record <img id='${helpId}' title='Genomic Segment Record View Help' class='xgdb-help-button' src='/XGDB/images/help-icon.png' alt='?' /></h1>
$recordINFO<br />
$structIMG<br /><br />
$lociTABLES
END_OF_PAGE

  ## Adjust header start/end (l_pos,r_pos) to region local to selected record
  $self->setRegionLocal($argHR);

  return ({-title=>"${SITENAMEshort} $self->{trackname}:${id}",-bgcolor=>"#FFFFFF"},$PDjscript,$PAGE_CONTENTS);
}

sub _STANDARD_RECORD_INFO{
  my $self= shift;
  my ($argHR,$recordHR) = @_;

  my $toolHR = $self->_STANDARD_TOOL_URLS(@_);

  $recordHR->{description} =~ s/^\s+//;
  my $formated_seq = $recordHR->{seq};
  $formated_seq =~ s/(.{70})/$1\n/g;

  my $exLinkHR = $self->getExternalURLS(@_);
  my $exLinkTable = "<tr>\n";
  my ($exLinkID,$x) = ('',0);
  foreach $exLinkID ( sort {return $a cmp $b;} keys %{$exLinkHR}){
    $x++;
    $exLinkTable .= "</tr><tr>\n" if(($x % 10)==0);
    $exLinkTable .= "<td class='exURL'>$exLinkHR->{$exLinkID}</td>\n";
  }
  $exLinkTable .= "</tr>";

  my $border_color = exists($self->{primaryColor})?$self->{primaryColor}:"blue";
  my $genomic_source = exists($argHR->{chrUID})?"Chr " . ($recordHR->{chr}) . " <span style='font-size:8px; color:red;'>[ " . $DBver[$self->{db_id}]->{DBtag} . " ]</span>":
                       exists($argHR->{gsegUID})?"${LATINORGN} BAC gi\| $recordHR->{gseg_gi} \|":
      "<span style='color:red;'>!! Undefined Genomic Source !!</span>";
	
  my $id = exists($argHR->{selectedRECORD}->{id})?$argHR->{selectedRECORD}->{id}:
           exists($argHR->{selectedRECORD}->{gi})?$argHR->{selectedRECORD}->{gi}:
	   exists($argHR->{selectedRECORD}->{geneid})?$argHR->{selectedRECORD}->{geneid}:
		exists($argHR->{id})?$argHR->{id}:
	   "unknownID";
  my $acc = exists($recordHR->{acc})?$recordHR->{acc}:
            "unknownACC";
  my $seqBOXES = '';

  return <<END_OF_INFO;
<table id="gdb_record" style="margin:1px; width:700px; border:2px solid $border_color;">
<tr>
<td style="text-align:right; font-size:12px;"><strong>$self->{trackname} gi:</strong></td><td style="text-align:left;">${id}</td>
<td style="text-align:right; font-size:12px;"><strong>Accession:</strong></td><td style="text-align:left;">${acc}</td></tr>
<tr style="vertical-align:top;">
<td style="text-align:right; font-size:12px;"><strong>Description:</strong></td>
<td COLSPAN=3><TEXTAREA READONLY ROWS=2 style="width:600px;">$recordHR->{description}</TEXTAREA></td>
</tr>
<tr style="vertical-align:top;">
<td style="text-align:right; font-size:12px;"><strong>Nucleotide <br />Sequence:<br /><span style="font-size:9px; font-weight:normal;">$toolHR->{'xgdb-FASTA'}</span></strong></td>
<td COLSPAN=3 style="width:600px;"><TEXTAREA READONLY ROWS=2 style="width:600px;">$formated_seq</TEXTAREA><br />
<table ALIGN="left"><tr><td style="font-size:9px;">$toolHR->{'xgdb-BLAST'}</td></tr></table>
<table ALIGN="right"><tr><td style="font-size:9px;">$toolHR->{'allxgdb-BLAST'}</td></tr></table>
</td>
</tr>
<tr>
<td COLSPAN=4 style='text-align:left; padding-left:5px; padding-top:10px;'>
<!-- table style='text-align:left;'>
<caption style='white-space:nowrap; text-align:left; font-size: 12px; font-weight:bold'>Additional resource links:</caption>
$exLinkTable
</table -->
</td>
</tr>
</table>
END_OF_INFO

}

sub _STANDARD_EXTERNAL_URLS{
  my $self= shift;
  my ($argHR,$recordHR) = @_;

  my $ncbiLink='http://www.ncbi.nlm.nih.gov:80/entrez/query.fcgi?cmd=Retrieve&db=nucleotide&dopt=GenBank&list_uids=';

  return { "NCBI" => a({href=>"${ncbiLink}" . $self->{gi},title =>"Show GenBank Record"},"\@ GenBank") };
}

sub _STANDARD_TOOL_URLS{
  my $self= shift;
  my ($argHR,$recordHR) = @_;

  my $region_link = $self->getRegionLink($argHR,$recordHR); ## link to chr/gseg context
  my $toolHR = { "xgdb-REGION" => a({href=>$region_link,title =>"Show in Genomic Context"},"Genome Browser")
	       };
  my $id = exists($argHR->{selectedRECORD}->{gi})?$argHR->{selectedRECORD}->{gi}:
	   exists($argHR->{selectedRECORD}->{id})?$argHR->{selectedRECORD}->{id}:
           exists($argHR->{selectedRECORD}->{geneid})?$argHR->{selectedRECORD}->{geneid}:
	   "unknownID";

  $toolHR->{"xgdb-FASTA"} = a({href=>"${CGIPATH}returnFASTA.pl?db=" . $self->{"blast_db"} . "&dbid=" . $self->{db_id} . "&hits=${id}:0:0",title =>"Show FASTA Sequence"},"Retrieve FASTA") if(exists($self->{"blast_db"}));
  $toolHR->{"xgdb-BLAST"} = a({href=>"${CGIPATH}blastGDB.pl?db=" . $self->{"blast_db"} . "&dbid=" . $self->{db_id} . "&hits=${id}:0:0",title =>"Blast against ${SITENAMEshort}"},"BLAST \@ ${SITENAMEshort}") if(exists($self->{"blast_db"}));
  $toolHR->{"allxgdb-BLAST"} = a({href=>"${CGIPATH}blastAllGDB.pl?db=" . $self->{"blast_db"} . "&dbid=" . $self->{db_id} . "&geneId=${id}",title =>"Blast against All_GDB"},"BLAST \@ All_GDB") if(exists($self->{"blast_db"}));

  return $toolHR;
}

sub showEXTENDED_LOCI_TABLE{
  my $self = shift;
  my ($argHR,$gCONTEXT) = @_;


  my $x=0;
  my $gsrc = (defined($gCONTEXT))?$gCONTEXT:"Chr";
  $gCONTEXT = "Chr" if (!defined($gCONTEXT));
  @rows = (th({-align=>'center',-style=>"vertical-align:middle;"},['Entry',$self->{trackname} . ' Left',$self->{trackname} . ' Right','Orientation',($gsrc ne 'Chr')?"$gsrc gi":"Chr","${gsrc} Left","${gsrc} Right"]));
  $gsrc = ($gsrc eq 'BAC')?"gseg":lc($gsrc); #### kludge for now

  if((exists($self->{"${gsrc}LOCI_href"}))&&(keys %{$self->{"${gsrc}LOCI_href"}})){
    foreach $recordHR (sort _by_CCLR values %{$self->{"${gsrc}LOCI_href"}}){
      $x++;
      $record_link = $self->getRecordLink($argHR,$recordHR,$gCONTEXT);
      $region_link = $self->getRegionLink($argHR,$recordHR,$gCONTEXT);
      if($argHR->{selectedRECORD} == $recordHR){
	push(@rows,td({style=>'border:1px solid red; vertical-align:middle;'},
		      [$x,
		       @$recordHR{'FRAG_lpos','FRAG_rpos','G_O'},
		       a({href=>$region_link,style=>"color:green;"},exists($recordHR->{chr})?$recordHR->{chr}:$recordHR->{gseg_gi}),
		       @$recordHR{'SCAF_lpos','SCAF_rpos'},
		      ]
		     ));
      }else{
	push(@rows,td({style=>'background:#FFFFFF; vertical-align:middle;'},
		       [a({href=>$record_link,style=>"color:$self->{primaryColor};"},$x),
		       @$recordHR{'FRAG_lpos','FRAG_rpos','G_O'},
		       a({href=>$region_link,style=>"color:green;"},exists($recordHR->{chr})?$recordHR->{chr}:$recordHR->{gseg_gi}),
		       @$recordHR{'SCAF_lpos','SCAF_rpos'},
		      ]
		     ));
      }
    }
  }

  $gsrc = ($gsrc eq 'chr')?"Chromosomal":uc($gCONTEXT);
  my $id = $self->{gi} || $self->{id} || $argHR->{selectedRECORD}->{gi} || $argHR->{selectedRECORD}->{id} || $argHR->{gi} || $argHR->{id} || "unknownID";

  return  ($#rows)?"<table border=1 style='width:970px;'>\n" . caption("$gsrc Loci for $self->{trackname} : " . ${id}) . Tr({-align=>'center',-valign=>'top'},\@rows) . "</table><br />" : '';

}

sub showSTRUCT{
  my $self = shift;
  my ($argHR,$paramHR) = @_;
  $paramHR = {} if(!defined($paramHR));

  exists($argHR->{selectedRECORD}) || ( @$argHR{'recordTYPE','selectedRECORD'} = $self->selectRECORD($argHR) );

  my $stINFO = $self->structINFO(@$argHR{'recordTYPE','selectedRECORD'});

  return undef if(!defined($stINFO)); ## NO STRUCTURE INFO FOUND

  my $imgfn="$self->{trackname}_$self->{db_id}_$stINFO->[0]st.png";

  ## Draw image
  my ($x1,$x2);
  if((exists($self->{hideFlankingRegionGlyph}) && ($self->{hideFlankingRegionGlyph})) || ($argHR->{selectedRECORD}->{frag_rpos} > length($argHR->{selectedRECORD}->{seq}))){
    $x1 = Locus::min($stINFO->[3],$stINFO->[4]);
    $x2 = Locus::max($stINFO->[3],$stINFO->[4]);
  }else{
    $x1 = Locus::min($stINFO->[2],$stINFO->[$#$stINFO]);
    $x2 = Locus::max($stINFO->[2],$stINFO->[$#$stINFO]);
  }
  my $view = new GeneView(700,50,$x1,$x2 + 20,1);
  $view->setLabelOn(1);
  $view->setFontSize($argHR->{'fontSize'}) if(exists($argHR->{'fontSize'}));
  $view->{showGsegFlank} = ((exists($self->{hideFlankingRegionGlyph}) && ($self->{hideFlankingRegionGlyph})) || ($argHR->{selectedRECORD}->{frag_rpos} > length($argHR->{selectedRECORD}->{seq})))?0:1;
  $view->addGseg(@$stINFO[1..$#$stINFO]);
  $view->drawPNG($TMPDIR.$imgfn);

  return img({-name=>'struct',-align=>'center',-src=>$DIR.$imgfn,-width=>700,-height=>50,-border=>1,%$paramHR});
}

sub _by_CCLR{
  my $aCOG = (exists($a->{iscognate}) && defined($a->{iscognate}))? $a->{iscognate} : "False";
  my $bCOG = (exists($b->{iscognate}) && defined($b->{iscognate}))? $b->{iscognate} : "False";
  my $aGenomicID = (exists($a->{chr}) && defined($a->{chr}))? $a->{chr}:(exists($a->{gseg_gi}) && defined($a->{gseg_gi}))?$a->{gseg_gi}:0;
  my $bGenomicID = (exists($b->{chr}) && defined($b->{chr}))? $b->{chr}:(exists($b->{gseg_gi}) && defined($b->{gseg_gi}))?$b->{gseg_gi}:0;
  my $Aleft = (exists($a->{SCAF_lpos}) && defined($a->{SCAF_lpos}))?$a->{SCAF_lpos} : (exists($a->{l_pos}) && defined($a->{l_pos}))?$a->{l_pos}:0;
  my $Bleft = (exists($b->{SCAF_lpos}) && defined($b->{SCAF_lpos}))?$b->{SCAF_lpos} : (exists($b->{l_pos}) && defined($b->{l_pos}))?$b->{l_pos}:0;
  my $Aright = (exists($a->{SCAF_rpos}) && defined($a->{SCAF_rpos}))?$a->{SCAF_rpos} : (exists($a->{r_pos}) && defined($a->{r_pos}))?$a->{r_pos}:0;
  my $Bright = (exists($b->{SCAF_rpos}) && defined($b->{SCAF_rpos}))?$b->{SCAF_rpos} : (exists($b->{r_pos}) && defined($b->{r_pos}))?$b->{r_pos}:0;

  return (
	  ($aCOG cmp $bCOG) ||
	  ($aGenomicID     <=> $bGenomicID)     ||
	  ($Aleft <=> $Bleft)     ||
	  ($Aright <=> $Bright)
	 );
}

1;
