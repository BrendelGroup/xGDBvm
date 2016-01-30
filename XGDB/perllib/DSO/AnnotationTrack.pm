package AnnotationTrack;
use base "Locus";

do 'SITEDEF.pl';

use GeneView;
use CGI ':all';

sub whatami{
  my $self = shift;
  $self->SUPER::whatami();
  print "AnnotationTrack:";
}

sub _init{
  my $self = shift;

#<DEBUG># print STDERR "[Annotation::_init] $self->{trackname}\n";

  $self->{'MOD_DAS_SET_FeatureTypeCategory'} = $self->_makeClosure(sub{return "Gene Model";}) if(!exists($self->{'MOD_DAS_SET_FeatureTypeCategory'}));

  $self->SUPER::_init(@_);
}

sub selectRECORD{
  my $self = shift;
  my ($argHR) = @_;
  my ($type,$record);

  ## Possible inputs to obtain record in order of preference (chrUID,gsegUID,gi,null)

  if(exists($self->{chrVIEWABLE}) && $self->{chrVIEWABLE} && exists($argHR->{chrUID})){
    if(!exists($self->{chrLOCI_href}->{$argHR->{chrUID}})){
      my $sth = $self->{dbh}->prepare_cached($self->{chrUID_QUERY});
      $sth->execute($argHR->{chrUID});
      my @ary = $sth->fetchrow_array();
      if(scalar(@ary)){
	$self->search_by_ID($ary[0]);
      }else{
	return undef; ## this is an invalid chr annotation uid
      }
      $sth->finish();
    }
    $record = $self->{chrLOCI_href}->{$argHR->{chrUID}};
    $type = 'chrUID';
  }elsif(exists($self->{BACVIEWABLE}) && $self->{BACVIEWABLE} && exists($argHR->{gsegUID})){
    if(!exists($self->{gsegLOCI_href}->{$argHR->{gsegUID}})){
      my $sth = $self->{dbh}->prepare_cached($self->{gsegUID_QUERY});
      $sth->execute($argHR->{gsegUID});
      my @ary = $sth->fetchrow_array();
      if(scalar(@ary)){
	$self->search_by_ID($ary[0]);
      }else{
	return undef; ## this is an invalid gseg annotation uid
      }
      $sth->finish();
    }
    $record = $self->{gsegLOCI_href}->{$argHR->{gsegUID}};
    $type = 'gsegUID';
  }elsif(exists($argHR->{geneid})){
    if((!exists($self->{geneid}))||($self->{geneid} ne $argHR->{geneid})){
      $self->search_by_ID($argHR->{geneid});
      if(keys %{$self->{chrLOCI_href}}){
	$type = 'chrUID';
	($record) = values %{$self->{chrLOCI_href}};
      }elsif(keys %{$self->{gsegLOCI_href}}){
	$type = 'gsegUID';
	($record) = values %{$self->{gsegLOCI_href}};
      }
    }
  }elsif(exists($argHR->{gi})){ ##GSQDB findREGION Kludge
    if((!exists($self->{geneid}))||($self->{geneid} ne $argHR->{gi})){
      $self->search_by_ID($argHR->{gi});
      if(keys %{$self->{chrLOCI_href}}){
	$type = 'chrUID';
	($record) = values %{$self->{chrLOCI_href}};
      }elsif(keys %{$self->{gsegLOCI_href}}){
	$type = 'gsegUID';
	($record) = values %{$self->{gsegLOCI_href}};
      }
    }
  }else{
    return (undef,undef);
  }

  return ($type,$record);
}

sub showRECORD{
  my $self = shift;
  my ($argHR) = @_;

  exists($argHR->{selectedRECORD}) || (@$argHR{'recordTYPE','selectedRECORD'} = $self->selectRECORD($argHR));

  my $recordINFO      = $self->showRECORD_INFO($argHR,$argHR->{selectedRECORD});
  #my $structIMG       = $self->showSTRUCT($argHR); # original
  my $structIMG       = $self->showSTRUCT($argHR,{-width=>600,-height=>100}); # dhrasmus, at sds's suggestion

  my $helpId = (exists($self->{helpfile}) && -r "${HELPDIR}$self->{helpfile}.inc.php")?$self->{helpfile}:
                (-r "${HELPDIR}$self->{trackname}.inc.php")? $self->{trackname}:
                (-r "${HELPDIR}$self->{DSOname}.inc.php")?$self->{DSOname}:'annotation_record_help';

  ## layout page
  my $PAGE_CONTENTS = <<END_OF_PAGE;
<h1 class="bottommargin1">$self->{trackname} Annotation Record &nbsp;<img id='${helpId}' title='Sequence Record View Help' class='xgdb-help-button' src='/XGDB/images/help-icon.png' alt='?' /><span class=\"heading\"> click for explanation</span></h1>\n

<div class="record_section">
	$recordINFO<br />
</div>
<div class="record_section">
	<h2>Structure:</h2>
	<div class="record_section">
		<ul id="CRHbuttons" class="sf-menu xgdb-crh-button sf-js-enabled sf-shadow" style="padding:20px 10px 0 0">
			<li onclick="doAnnotation('BAC','$SRC');" title="Open yrGATE tool for gene structure annotation" class="ui-corner-all"><a>Annotate This Locus!</a>
			</li>&nbsp;<img style='width:16px'; id='annotate_this_help' title='Annotation Button Help' class='xgdb-help-button' src='/XGDB/images/help-icon.png' alt='?' />
		</ul>
	</div>
		<a class="indent1">$structIMG</a>

</div>
END_OF_PAGE

  ## Adjust header start/end (l_pos,r_pos) to region local to selected record
  $self->setRegionLocal($argHR);

  return ({-title=>"${SITENAMEshort} $self->{trackname}:$self->{geneID}",-bgcolor=>"#FFFFFF"},$PDjscript,$PAGE_CONTENTS);
}

sub _STANDARD_RECORD_INFO{
  my $self= shift;
  my ($argHR,$recordHR) = @_;

  my $toolHR = $self->_STANDARD_TOOL_URLS(@_);

  $recordHR->{description} =~ s/^\s+//;

  my $exLinkHR = $self->getExternalURLS(@_);
  my $exLinkTable = "<TR>\n";
  my ($exLinkID,$x) = ('',0);
  foreach $exLinkID ( sort {return $a cmp $b;} keys %{$exLinkHR}){
    $x++;
    $exLinkTable .= "</TR><TR>\n" if(($x % 10)==0);
    $exLinkTable .= "<TD class='exURL'>$exLinkHR->{$exLinkID}</TD>\n";
  }
  $exLinkTable .= "</TR>";

  my $border_color = (exists($self->{primaryColor}))?$self->{primaryColor}:"blue";
	my $Linkid = $recordHR->{gseg_gi}||$argHR->{gseg_gi};
  my $genomic_source = (exists($argHR->{chrUID}))?"Chr " . ($recordHR->{chr}) . " <SPAN STYLE='font-size:10px; color:red;'>[ " . $DBver[$self->{db_id}]->{DBtag} . " ]</SPAN>":
    (exists($argHR->{gsegUID}))?"${LATINORGN} Segment\| $Linkid \|":
      "<SPAN STYLE='color:red;'>!! Undefined Genomic Source !!</SPAN>";
  my $id = ($recordHR->{transcript_id} =~ /^GeneID:(\d+)/)? $1 : 
    ($recordHR->{transcript_id} ne '')?$recordHR->{transcript_id}:
      ($recordHR->{geneid} ne '')?$recordHR->{geneid}:'unknown';

  my $seqBOXES = '';
  my $seqHR = $self->getSequenceFromBLAST($recordHR->{geneid});
  if(scalar(@{$seqHR->{'blast_db_mrna'}})){
    my @seqlines = split("\n",$seqHR->{'blast_db_mrna'}->[0]);
    my ($formated_seq) = join('',@seqlines[1..$#seqlines]);
    $formated_seq =~ s/\s+//g;
    $formated_seq =~ s/(.{70})/$1\n/g;
    $seqBOXES .= <<END_OF_SEQBOX;
<TR STYLE="vertical-align:top;">
<TD STYLE="text-align:right; font-size:12px;"><STRONG>mRNA <BR>Sequence:<BR><SPAN STYLE="font-size:9px; font-weight:normal;">$toolHR->{'xgdb-FASTA_mrna'}</SPAN></STRONG></TD>
<TD COLSPAN=3 STYLE="width:600px;"><TEXTAREA READONLY ROWS=2 STYLE="width:600px;">$formated_seq</TEXTAREA><BR>
<TABLE ALIGN="right"><TR><TD STYLE="font-size:9px;">$toolHR->{'xgdb-BLAST_mrna'}</TD></TR></TABLE>
<TABLE ALIGN="right"><TR><TD STYLE="font-size:9px;">$toolHR->{'allxgdb-BLAST_mrna'}</TD></TR></TABLE>
</TD>
</TR>
END_OF_SEQBOX
  }

  if(scalar(@{$seqHR->{'blast_db_cds'}})){
    my @seqlines = split("\n",$seqHR->{'blast_db_cds'}->[0]);
    my ($formated_seq) = join('',@seqlines[1..$#seqlines]);
    $formated_seq =~ s/\s+//g;
    $formated_seq =~ s/(.{70})/$1\n/g;
    $seqBOXES .= <<END_OF_SEQBOX;
<TR STYLE="vertical-align:top;">
<TD STYLE="text-align:right; font-size:12px;"><STRONG>CDS <BR>Sequence:<BR><SPAN STYLE="font-size:9px; font-weight:normal;">$toolHR->{'xgdb-FASTA_cds'}</SPAN></STRONG></TD>
<TD COLSPAN=3 STYLE="width:600px;"><TEXTAREA READONLY ROWS=2 STYLE="width:600px;">$formated_seq</TEXTAREA><BR>
<TABLE ALIGN="right"><TR><TD STYLE="font-size:9px;">$toolHR->{'xgdb-BLAST_cds'}</TD></TR></TABLE>
<TABLE ALIGN="right"><TR><TD STYLE="font-size:9px;">$toolHR->{'allxgdb-BLAST_cds'}</TD></TR></TABLE>
</TD>
</TR>
END_OF_SEQBOX
  }

  if(scalar(@{$seqHR->{'blast_db_peptide'}})){
    my @seqlines = split("\n",$seqHR->{'blast_db_peptide'}->[0]);
    my ($formated_seq) = join('',@seqlines[1..$#seqlines]);
    $formated_seq =~ s/\s+//g;
    $formated_seq =~ s/(.{70})/$1\n/g;
    $seqBOXES .= <<END_OF_SEQBOX;
<TR STYLE="vertical-align:top;">
<TD STYLE="text-align:right; font-size:12px;"><STRONG>CDS <BR>Translation:<BR><SPAN STYLE="font-size:9px; font-weight:normal;">$toolHR->{'xgdb-FASTA_peptide'}</SPAN></STRONG></TD>
<TD COLSPAN=3 STYLE="width:600px;"><TEXTAREA READONLY ROWS=5 STYLE="width:600px;">$formated_seq</TEXTAREA><BR> 
<TABLE ALIGN="right"><TR><TD STYLE="font-size:9px;">$toolHR->{'xgdb-BLAST_peptide'}</TD></TR></TABLE>
<TABLE ALIGN="right"><TR><TD STYLE="font-size:9px;">$toolHR->{'allxgdb-BLAST_peptide'}</TD></TR></TABLE>
</TD>
</TR>
END_OF_SEQBOX
  }

  return <<END_OF_INFO;
<table id="gdb_record" STYLE="margin:1px; width:700px; border:2px solid $border_color;">
	<tr>
		<td style="text-align:right; font-size:12px;"><strong>ID:</strong></td><td style="text-align:left;">$recordHR->{geneid}</td>
		<td style="text-align:right; font-size:12px;"><strong>Transcript ID:</strong></td><td style="text-align:left;">$recordHR->{transcript_id}</td>
	</tr>
	<tr style="vertical-align:top;">
		<td style="text-align:right; font-size:12px;"><strong>Description:</strong></td>
		<td colspan=3><textarea readonly rows=8 STYLE="width:600px;">$recordHR->{description}</textarea></td></tr>
	<tr style="vertical-align:top;">
		<td style="text-align:right; font-size:12px;"><strong>Note:</strong></td>
		<td colspan=3><textarea readonly rows=4 STYLE="width:600px;">$recordHR->{note}</textarea></td></tr>
		$seqBOXES
	<tr style="vertical-align:top;">
		<td style="text-align:right; font-size:12px;"><strong>Annotated <BR>Structure:<BR></strong>
		</td>
		<td colspan=3  STYLE="text-align:left; vertical-align:top;">
			<table border=0 style='padding:0px; margin:0px; vertical-align:top; width:600px;'>
				<tr style='font-size:12px;'>
					<td>$genomic_source</td>
					<td style='font-weight:bold; text-align:right;'>Start Codon:</td><td>$recordHR->{cdsstart}</td>
					<td style='font-weight:bold; text-align:right;'>Stop Codon:</td><td>$recordHR->{cdsstop}</td>
				</tr>
			</table>
		<textarea readonly rows=4 style="width:600px;">$recordHR->{gene_structure}</textarea>
		<br />
		<table ALIGN="right"><tr><td style="font-size:9px;">$toolHR->{'xgdb-GSQ'}</td></tr></table>
		</td>
	</tr>
	<tr>
		<td colspan=4 style='text-align:left; padding-left:5px; padding-top:10px;'>
			<!-- table style='text-align:left;'>
				<caption style='white-space:nowrap; text-align:left; font-size: 12px'><strong>Additional resource links:</strong></caption>
				$exLinkTable
			</table-->
		</td>
	</tr>
	<tr>
		<td>
		</td>
		<td>
		<SPAN STYLE="font-size:12px; font-weight:normal;">
			$toolHR->{'xgdb-REGION'}
		</SPAN>
		</td>
	</tr>
</table>

END_OF_INFO

}

sub _STANDARD_EXTERNAL_URLS{
  my $self= shift;
  my ($argHR,$recordHR) = @_;

  my $ncbiLink="http://www.ncbi.nlm.nih.gov/entrez/query.fcgi?db=gene&cmd=retrieve&dopt=graphics&list_uids=";
  my $id = ($recordHR->{transcript_id} =~ /^GeneID:(\d+)/)? $1 : $recordHR->{transcript_id};

  return { "NCBI" => a({href=>"${ncbiLink}" . $id ,title=>"Show GenBank Gene Record"},"\@ GenBank") };
}

sub _STANDARD_TOOL_URLS{
  my $self= shift;
  my ($argHR,$recordHR) = @_;

  my $region_link = $self->getRegionLink($argHR,$recordHR); ## link to chr/gseg context
  my $toolHR = { "xgdb-REGION" => a({href=>$region_link, class=>"xgdb_button colorB4 largerfont", title=>"Show in Genomic Context"},"View in Genome Browser")
	       };
  my $BDB = '';
  foreach $BDB ('','_mrna','_cds','_peptide'){
    $toolHR->{"xgdb-FASTA${BDB}"} = a({href=>"${CGIPATH}returnFASTA.pl?db=" . $self->{"blast_db${BDB}"} . "&dbid=" . $self->{db_id} . "&hits=" . $recordHR->{geneid} .":0:0",title=>"Show FASTA Sequence"},"Retrieve FASTA") if(exists($self->{"blast_db${BDB}"}));
    $toolHR->{"xgdb-BLAST${BDB}"} = a({href=>"${CGIPATH}blastGDB.pl?db=" . $self->{"blast_db${BDB}"} . "&dbid=" . $self->{db_id} . "&hits=" . $recordHR->{geneid} .":0:0",title=>"Blast against ${SITENAMEshort}"},"BLAST \@ ${SITENAMEshort}") if(exists($self->{"blast_db${BDB}"}));
    $toolHR->{"allxgdb-BLAST${BDB}"} = a({href=>"${CGIPATH}blastAllGDB.pl?db=" . $self->{"blast_db${BDB}"} . "&dbid=" . $self->{db_id} . "&geneId=" . $recordHR->{geneid},title=>"Blast against All GDB"},"BLAST \@ All GDB") if(exists($self->{"blast_db${BDB}"}));
  };

  return $toolHR;
}

sub structINFO{
  my $self = shift;
  my ($type,$record,$argHR) = @_;
  my ($c,$c_a,$c_s,$c_d,$label,$str,@pgs);
  
  return undef if(!(defined($record) && exists($record->{uid})));
  #the old way, before color coding  $c = $c_a = $c_s = $c_d = $self->{primaryColor};
  $name  = $self->{trackname};

  if ($name =~ /yrGATE/) { # JPD modified 10-31-13
    $color = $self->{colorHASH}{$self->{dbh}->selectrow_array("select Annotation_Class from user_gene_annotation WHERE (uid=$record->{uid})")};
    if ($color eq "") {$color = $self->{primaryColor};}
  } else { $color = $self->{primaryColor}; }

  $c = $c_a = $c_s = $c_d = $color;

  $label = (exists($record->{geneid}))?$record->{geneid}:$self->{geneid};

 
  ($str) = $record->{gene_structure} =~ /^\D*(.*)/;
  @pgs = split(/[^\d]+/,$str);

  if($record->{strand} eq 'r'){
    @pgs = reverse @pgs;
  }

  return ["${type}$record->{uid}",
	  {label=>$label,color=>$c,arrowColor=>$c_a,startColor=>$c_s,dotColor=>$c_d,drawArrowhead=>1},
	  @pgs];
}

sub drawCombinedImage{
  my $self = shift;
  my ($view,$startY) = @_;
  my ($prevUID,$puid,$recordHR,$stINFO,$bottom,$recAR,%imap);

  $prevUID = -1; $bottom=0;
  foreach $recordHR (sort _by_CLR values %{$self->{pgsREGION_href}}){
    $stINFO = $self->structINFO('pgs',$recordHR);
    $stINFO->[1]{startHeight} = $startY;
    ($labelAR,$recAR) = $view->addGene(@$stINFO[1..$#$stINFO]);
    $view->addCDS($recAR->[0],$recordHR->{cdsstart},$recordHR->{cdsstop});
    $imap{$self->{resid} . "_" . $recordHR->{uid}} = [$labelAR,$recAR];
    $bottom = $recAR->[1] if($recAR->[1] > $bottom);
  }
  return (\%imap,$bottom);
}

sub getTRACKCELL {
  #jfdenton1
  my $self = shift;
  my ( $argHR, $imgfn ) = @_;
  my ( $html, $color, $name, $tcNameMenuHTML, $op1classes, $op2classes );

  $name  = $self->{trackname};
  $color = $self->{primaryColor};
  $html  = '&nbsp;';
  if ($name eq "yrGATE_Annotations") {
    $color = $self->{colorHASH}{$self->{dbh}->selectrow_array('select Annotation_Class from user_gene_annotation', undef, @params)};
  } else { $color = $self->{primaryColor}; }

  $op1classes = $op2classes = 'cth-action xgdb-track-option';
  if(exists($argHR->{trackPREFS}) && exists($argHR->{trackPREFS}->[$self->{resid}]) &&
        exists($argHR->{trackPREFS}->[$self->{resid}]->{selectedImageOption}) && ($argHR->{trackPREFS}->[$self->{resid}]->{selectedImageOption} eq 'op1')){
    $op1classes = 'cth-action xgdb-track-option current';
  }else{
    $op2classes = 'cth-action xgdb-track-option current';
  }

##jd, trying to add help to track menu, using the default_xgdb.js function that loads an image-based help window.
  my $helpId = (exists($self->{helpfile}) && -r "${HELPDIR}$self->{helpfile}.inc.php")?$self->{helpfile}:
                (-r "${HELPDIR}$self->{trackname}.png")? $self->{trackname}:
                (-r "${HELPDIR}$self->{DSOname}.png")?$self->{DSOname}:'XGDB_Glyphs.png'; 

  $tcNameMenuHTML = <<END_OF_CTRL;
<ul class='cth-name-menu sf-menu'>
  <li class='cth-name'>$name<ul>
    <li><a title='Key to the Glyph Images used for this track:' class='image-button' id='${helpId}'>Track Information</a></li>
    <li>Track Options<ul>
      <li id='op1' class='$op1classes'>Show GAEVAL flags</li>
      <li id='op2' class='$op2classes' style='z-index:1'>Hide GAEVAL flags</li>
    </ul></li>
  </ul></li>
</ul>

END_OF_CTRL

  return ( $html, $color, $tcNameMenuHTML );
}

sub drawREGION{
  my $self = shift;
  my ($argHR,$img_paramHR,$imgfn) = @_;
  my ($link,$imgW,$imgH,$stINFO,$defL,$imgHTML,$initIMG);
  my ($view_IM,$view);
  my ($view2_IM,$view2,$imgfn2);
  my ($labelAR,$recAR,$label2AR,$rec2AR);

  $imgW    = exists($argHR->{imgW})?$argHR->{imgW}:600;
  $imgH    = exists($argHR->{imgH})?$argHR->{imgH}:30;
  $initIMG = exists($argHR->{initialIMG})?$argHR->{initialIMG}:"";
 
  $view = new GeneView($imgW,$imgH,$argHR->{l_pos},$argHR->{r_pos},1);
  $view->setLabelOn(1);
  $view->setFontSize($argHR->{'fontSize'}) if(exists($argHR->{'fontSize'}));
  $view_IM = "<MAP NAME=\"$self->{trackname}_IM\">\n";
  
  ## view2 is for the flags display
  $imgfn2 = "flagged_" . $imgfn;
  $view2 = new GeneView($imgW,$imgH,$argHR->{l_pos},$argHR->{r_pos},1);
  $view2->setFontSize($argHR->{'fontSize'}) if(exists($argHR->{'fontSize'}));
  $view2->setLabelOn(1);
  $view2_IM = "<MAP NAME=\"flagged_$self->{trackname}_IM\">\n";

  foreach $recordHR (sort _by_CLR values %{$self->{pgsREGION_href}}){
    $stINFO = $self->structINFO('pgs',$recordHR);
    $defL   = CGI::unescapeHTML(CGI::unescape($recordHR->{description}));
    $defL =~ s/\'/\\\'/g;
    $defL =~ s/\"/\\\'/g;
    $defL =~ s/\r//g;  ## Get rid of any pesky carriage returns
    $defL =~ s/\n/\\n/g; ## Escape the newline so that HTML works
    $link = $self->getRecordLink($argHR,$recordHR);
    ($labelAR,$recAR) = $view->addGene(@$stINFO[1..$#$stINFO]);
    $view->addCDS($recAR->[0],$recordHR->{cdsstart},$recordHR->{cdsstop});
    $view_IM .= "<AREA SHAPE=\"RECT\" COORDS=\"".join(',',@$recAR[2,0,$#$recAR,1])."\" HREF=\"${link}\"  onmouseover=\"showDef('$defL');\" onmouseout=\"hideDef();\">\n";

    if(exists($self->{_HAS_FLAGS}) && $self->{_HAS_FLAGS}){## if has flags draw flags
      my($fmap)=$view2->addFLAGS($self->flagINFO($recordHR,$self->getFlagURL($argHR,$recordHR)));
      $view2_IM .= "$fmap \n";
    }
    ($label2AR,$rec2AR) = $view2->addGene(@$stINFO[1..$#$stINFO]);
    $view2->addCDS($rec2AR->[0],$recordHR->{cdsstart},$recordHR->{cdsstop});
    $view2_IM .= "<AREA SHAPE=\"RECT\" COORDS=\"".join(',',@$rec2AR[2,0,$#$recAR,1])."\" HREF=\"${link}\"  onmouseover=\"showDef('$defL');\" onmouseout=\"hideDef();\">\n";
  }
  
  $view_IM  .= "</MAP>\n";
  $view2_IM .= "</MAP>\n";

  $imgHTML = img({id     => 'op1',
                  src    => "${DIR}flagged_${imgfn}",
                  usemap => "#flagged_$self->{trackname}_IM",
                  border => 0,
                  class  => (exists($argHR->{trackPREFS}) &&
                                exists($argHR->{trackPREFS}->[$self->{resid}]) &&
                                exists($argHR->{trackPREFS}->[$self->{resid}]->{selectedImageOption}) &&
                                ($argHR->{trackPREFS}->[$self->{resid}]->{selectedImageOption} eq 'op1')) ?
                                        "xgdb-track-image-current":"xgdb-track-image-option",
                  %$img_paramHR})
	     . "\n" . 
	     img({id     => 'op2',
                  src    => "${DIR}${imgfn}",
                  usemap => "#$self->{trackname}_IM",
                  border => 0,
                  class  => (exists($argHR->{trackPREFS}) &&
                                exists($argHR->{trackPREFS}->[$self->{resid}]) &&
                                exists($argHR->{trackPREFS}->[$self->{resid}]->{selectedImageOption}) &&
                                ($argHR->{trackPREFS}->[$self->{resid}]->{selectedImageOption} eq 'op1')) ?
                                        "xgdb-track-image-option":"xgdb-track-image-current",
                  %$img_paramHR});
  
  $view->drawPNG($TMPDIR.$imgfn);
  $view2->drawPNG($TMPDIR.$imgfn2);
  
  return ($view_IM.$view2_IM.$imgHTML,"${DIR}${initIMG}${imgfn}","${initIMG}$self->{trackname}_IM");
}

sub getLOCI{
  my $self = shift;
  my ($argHR) = @_;
  my ($recordHR,$hitlist,$link);
  
  $hitlist = [];
  if((exists($argHR->{LOCI_href}))&&(keys %{$argHR->{LOCI_href}})){
    foreach $recordHR (values %{$argHR->{LOCI_href}}){
      $link    = "${CGIPATH}getRegion.pl?chr=$recordHR->{chr}&l_pos=" . ($recordHR->{l_pos} - 500) . "&r_pos=" .($recordHR->{r_pos} + 500) ; ## link to chr/gseg context ?
      push(@$hitlist,[$recordHR->{chr},$recordHR->{l_pos},$self->{primaryColor},$link]);
    }
  }
  ## add gseg entries with no chr positions??

  return $hitlist;
}

sub showLOCI_TABLE{
  my $self = shift;
  my ($argHR) = @_;
  my ($recordHR,$x,$strand,$record_link,$region_link,@rows);

  exists($argHR->{selectedRECORD}) || ($argHR->{selectedRECORD} = "");
  
  $x=0;
  @rows = (th({-align=>'center'},['Entry','Chr','Strand','Left','Right','CDS start','CDS stop']));
  if((exists($argHR->{LOCI_href}))&&(keys %{$argHR->{LOCI_href}})){
    foreach $recordHR (sort _by_CLR values %{$argHR->{LOCI_href}}){
      $x++;
      $strand=(($recordHR{strand} eq 'f')||($recordHR{strand} eq '+'))?'+':'-';
      $record_link = "${CGIPATH}getRecord.pl?resid=$self->{resid}&chrUID=$recordHR->{uid}"; ## link to individual record
      $region_link = "${CGIPATH}getRegion.pl?chr=$recordHR->{chr}&l_pos=" . ($recordHR->{l_pos} - 500) . "&r_pos=" .($recordHR->{r_pos} + 500) ; ## link to chr/gseg context
      if($argHR->{selectedRECORD} == $recordHR){
	push(@rows,td({style=>'color:#FF0000;'},[$x,a({href=>$region_link,style=>"color:green;"},$recordHR->{chr}),
						 $strand,@$recordHR{'l_pos','r_pos','CDSstart','CDSstop'}]
		     ));
      }else{
	push(@rows,td([a({href=>$record_link,style=>"color:$self->{primaryColor};"},$x),a({href=>$region_link,style=>"color:green;"},$recordHR->{chr}),
		       $strand,@$recordHR{'l_pos','r_pos','CDSstart','CDSstop'}]
		     ));
      }
    }
  }
  ## Still need to deal with gseg entries

  return  caption("Genomic Loci for $self->{trackname}: gi-" . $self->{geneid}) . Tr({-align=>'center',-valign=>'top'},\@rows);
}

sub getMULTILOCI{
  my $self = shift;
  my ($argHR) = @_;
  my ($recordHR,$hitlist,$link);
  
  $hitlist = exists($argHR->{LOCIhitlist}) ? $argHR->{LOCIhitlist} : [];
  if((exists($self->{chrMULTILOCI_href}))&&(keys %{$self->{chrMULTILOCI_href}})){
    foreach $recordHR (values %{$self->{chrMULTILOCI_href}}){
      $link = "${CGIPATH}getRegion.pl?chr=$recordHR->{chr}&l_pos=" . ($recordHR->{l_pos} - 500) . "&r_pos=" .($recordHR->{r_pos} + 500) ; ## link to chr/gseg context ?
      push(@$hitlist,[$recordHR->{chr},$recordHR->{l_pos},$self->{primaryColor},$link]);
    }
  }
  ## add gseg entries with no chr positions??

  return $hitlist;
}

sub showMULTILOCI_TABLE{
  my $self = shift;
  my ($argHR) = @_;
  my ($recordHR,$x,$y,$z,$strand,$record_link,$region_link,$currentGI,@MLrows,@rows);

  $x=0;$y=1;$z=0;
  if((exists($self->{chrMULTILOCI_href}))&&(keys %{$self->{chrMULTILOCI_href}})){
    @MLrows = (th({style=>"text-align:center; border:0;"},['Entry','Chr','Strand','Left','Right','Start Codon','Stop Codon']));
    foreach $recordHR (sort _by_ICLR values %{$self->{chrMULTILOCI_href}}){
      $strand=(($recordHR{strand} eq 'f')||($recordHR{strand} eq '+'))?'+':'-';
      $record_link = $self->getRecordLink($argHR,$recordHR,"CHR");
      $region_link = $self->getRegionLink($argHR,$recordHR,"CHR");
      if($recordHR->{geneid} ne $currentGI){
	push(@MLrows,td({colspan=>7,style=>"background:#DCDCDC; color:#808000; text-align:left; border:0;"},["$self->{trackname}: geneID-" . $recordHR->{geneid}]));
	$y=1;$x++;
      }
      push(@MLrows,td({style=>"text-align:center;"},[a({href=>$record_link,style=>"color:$self->{primaryColor};"},"$x-$y"),a({href=>$region_link,style=>"color:green;"},$recordHR->{chr}),$strand,@$recordHR{'l_pos','r_pos','cdsstart','cdsstop'}]));
      $y++;$z++;
      $currentGI = $recordHR->{geneid};
    }
    ## Still need to deal with gseg entries
  }
  
  unshift(@MLrows,td({colspan=>7,style=>"background:$self->{primaryColor}; color:#FFFFFF; text-align:left; border:0;"},[strong("$self->{trackname} ($x loci / $z models)")]));

  return table({width=>500,border=>1,valign=>'top'},Tr(\@MLrows)) . "\n";
}

sub _parse_DAS_FEATURES {
  my ( $self, $reqHR, $annHRAR, $segFeatHR ) = @_;

#<DEBUG># print STDERR "[Annotation::_parse_DAS_FEATURES] $self->{trackname}\n";

  #
  # $annHR = {uid,geneid,chr,strand,l_pos,r_pos,gene_structure,description,comment,cdsstart,cdsstop,status,moddate,genealiases,proteinaliases,proteinid,owner,evidence}
  #
  # segFeatHR = {id,start,stop,xID,xStart,xStop,version,label}
  #

  my $featLIST = [];
  $self->checkDASTYPES( $reqHR->{'type'} ) if ( exists( $reqHR->{'type'} ) );

  my $coordTrans = $segFeatHR->{start} - $segFeatHR->{xStart};

  foreach my $annHR (@$annHRAR) {
#<DEBUG>#   print STDERR (join("\n",keys %$annHR) . "\n\n");
    my $gstr = $annHR->{gene_structure};
    $gstr =~ s/[^\d\.,]//g;
    my $exonCNT=0;
    foreach my $exon (split(',',$gstr)){
      my($a,$b) = split(/\.+/,$exon);
      my $Ftype='';
      $exonCNT++;
      if( !$annHR->{cdsstart} || ($annHR->{cdsstart} eq 'NULL')){ ## all exons must be treated the same >> default to 'exon' type if supported
	if(exists( $self->{'das_supported_types'}->{'exon'}) && $self->{'das_supported_types'}->{'exon'}->{typelist} ){
                $Ftype = 'exon';
        }
      }elsif(($annHR->{strand} eq 'f')&&($b >= $annHR->{cdsstart})&&($a < $annHR->{cdsstart})){ ## CDSstart occurs within this exon
	if((exists($self->{'das_supported_types'}->{'five_prime_coding_exon_noncoding_region'}) && $self->{'das_supported_types'}->{'five_prime_coding_exon_noncoding_region'}->{typelist})&&
                ((exists($self->{'das_supported_types'}->{'five_prime_coding_exon_coding_region'}) && $self->{'das_supported_types'}->{'five_prime_coding_exon_coding_region'}->{typelist}) ||
                 (exists( $self->{'das_supported_types'}->{'coding_exon'}) && $self->{'das_supported_types'}->{'coding_exon'}->{typelist} ) ||
                 (exists( $self->{'das_supported_types'}->{'exon'}) && $self->{'das_supported_types'}->{'exon'}->{typelist} ))){

           $Ftype='five_prime_coding_exon_noncoding_region';
           $featLIST->[ scalar(@$featLIST) ] = { ## Coding region
                'id' => join( ":", ( $Ftype, $self->{db_id}, $self->{resid},$annHR->{uid},$exonCNT)),
                'type_id'      => $Ftype,
                'start' => $coordTrans + $a,
                'end'   => $coordTrans + $annHR->{cdsstart} - 1,
                'score' => 1,
                'orientation' => ($annHR->{gene_structure} =~ /comp/i)?'-':'+',
                'group_id'        => $annHR->{uid},
                'group_label'     => $annHR->{geneid},
                'method_id'    => exists( $self->{'das_supported_types'}->{$Ftype}->{'method'} ) ? $self->{'das_supported_types'}->{$Ftype}->{'method'}:
                                        exists( $self->{'das_defaults'}->{'method'} ) ? $self->{'das_defaults'}->{'method'}:'third_party_annotation',
                'method_label'    => exists( $self->{'das_supported_types'}->{$Ftype}->{'method_label'} ) ? $self->{'das_supported_types'}->{$Ftype}->{'method_label'}:
                                        exists( $self->{'das_defaults'}->{'method_label'} ) ? $self->{'das_defaults'}->{'method_label'}:'Third-party Annotation',
                'group_type'      => exists( $self->{'das_supported_types'}->{$Ftype}->{'group_type'} ) ? $self->{'das_supported_types'}->{$Ftype}->{'group_type'}:
                                        exists( $self->{'das_defaults'}->{'group_type'} ) ? $self->{'das_defaults'}->{'group_type'}:'gene',
                'group_link_href' => $rootPATH . $self->getRecordLink( {}, { 'uid' => $annHR->{'uid'} }, ( exists( $self->{'chrVIEWABLE'} ) && $self->{'chrVIEWABLE'} ) ? 'CHR' : 'BAC' )
           };
	   $featLIST->[ $#$featLIST ]->{'note'} = "Feature translated from $segFeatHR->{xID} using ($segFeatHR->{id}:$segFeatHR->{start},$segFeatHR->{stop} = $segFeatHR->{xID}:$segFeatHR->{xStart},$segFeatHR->{xStop})" if($segFeatHR->{start} != $segFeatHR->{xStart});
	   $featLIST->[$#$featLIST]->{'type_category'} = &{$self->{MOD_DAS_SET_FeatureTypeCategory}}($annHR,$featLIST->[$#$featLIST]) if(exists($self->{MOD_DAS_SET_FeatureTypeCategory}));
	   $featLIST->[$#$featLIST]->{'group_label'} = &{$self->{MOD_DAS_SET_GroupLabel}}($annHR,$featLIST->[$#$featLIST]) if(exists($self->{MOD_DAS_SET_GroupLabel}));

           if(exists($self->{'das_supported_types'}->{'five_prime_coding_exon_coding_region'}) && $self->{'das_supported_types'}->{'five_prime_coding_exon_coding_region'}->{typelist}){
                $Ftype = 'five_prime_coding_exon_coding_region';
           }elsif(exists( $self->{'das_supported_types'}->{'coding_exon'}) && $self->{'das_supported_types'}->{'coding_exon'}->{typelist} ){
                $Ftype = 'coding_exon';
           }elsif(exists( $self->{'das_supported_types'}->{'exon'}) && $self->{'das_supported_types'}->{'exon'}->{typelist} ){
                $Ftype = 'exon';
           }    
           $a = $annHR->{cdsstart};
	}elsif(exists( $self->{'das_supported_types'}->{'exon'}) && $self->{'das_supported_types'}->{'exon'}->{typelist} ){
                $Ftype = 'exon';
        }

	if(($b > $annHR->{cdsstop})&&($a <= $annHR->{cdsstop})){ ## Both CDSstart and CDSstop occur within this exon
	  if(($Ftype ne 'exon') &&
                ((exists($self->{'das_supported_types'}->{'three_prime_coding_exon_noncoding_region'}) && $self->{'das_supported_types'}->{'three_prime_coding_exon_noncoding_region'}->{typelist}) ||
                 (exists( $self->{'das_supported_types'}->{'noncoding_exon'}) && $self->{'das_supported_types'}->{'noncoding_exon'}->{typelist} ) ||
                 (exists( $self->{'das_supported_types'}->{'exon'}) && $self->{'das_supported_types'}->{'exon'}->{typelist} ))){

             $featLIST->[ scalar(@$featLIST) ] = { ## Coding region
                'id' => join( ":", ( $Ftype, $self->{db_id}, $self->{resid},$annHR->{uid},$exonCNT)),
                'type_id'      => $Ftype,
                'start' => $coordTrans + $a,
                'end'   => $coordTrans + $annHR->{cdsstop},
                'score' => 1,
                'orientation' => ($annHR->{gene_structure} =~ /comp/i)?'-':'+',
                'group_id'        => $annHR->{uid},
                'group_label'     => $annHR->{geneid},
                'method_id'    => exists( $self->{'das_supported_types'}->{$Ftype}->{'method'} ) ? $self->{'das_supported_types'}->{$Ftype}->{'method'}:
                                        exists( $self->{'das_defaults'}->{'method'} ) ? $self->{'das_defaults'}->{'method'}:'third_party_annotation',
                'method_label'    => exists( $self->{'das_supported_types'}->{$Ftype}->{'method_label'} ) ? $self->{'das_supported_types'}->{$Ftype}->{'method_label'}:
                                        exists( $self->{'das_defaults'}->{'method_label'} ) ? $self->{'das_defaults'}->{'method_label'}:'Third-party Annotation',
                'group_type'      => exists( $self->{'das_supported_types'}->{$Ftype}->{'group_type'} ) ? $self->{'das_supported_types'}->{$Ftype}->{'group_type'}:
                                        exists( $self->{'das_defaults'}->{'group_type'} ) ? $self->{'das_defaults'}->{'group_type'}:'gene',
                'group_link_href' => $rootPATH . $self->getRecordLink( {}, { 'uid' => $annHR->{'uid'} }, ( exists( $self->{'chrVIEWABLE'} ) && $self->{'chrVIEWABLE'} ) ? 'CHR' : 'BAC' )
             };
             $featLIST->[ $#$featLIST ]->{'note'} = "Feature translated from $segFeatHR->{xID} using ($segFeatHR->{id}:$segFeatHR->{start},$segFeatHR->{stop} = $segFeatHR->{xID}:$segFeatHR->{xStart},$segFeatHR->{xStop})" if($segFeatHR->{start} != $segFeatHR->{xStart});
             $featLIST->[$#$featLIST]->{'type_category'} = &{$self->{MOD_DAS_SET_FeatureTypeCategory}}($annHR,$featLIST->[$#$featLIST]) if(exists($self->{MOD_DAS_SET_FeatureTypeCategory}));
	     $featLIST->[$#$featLIST]->{'group_label'} = &{$self->{MOD_DAS_SET_GroupLabel}}($annHR,$featLIST->[$#$featLIST]) if(exists($self->{MOD_DAS_SET_GroupLabel}));

             if(exists($self->{'das_supported_types'}->{'three_prime_coding_exon_noncoding_region'}) && $self->{'das_supported_types'}->{'three_prime_coding_exon_noncoding_region'}->{typelist}){
                $Ftype = 'three_prime_coding_exon_noncoding_region';
             }elsif(exists( $self->{'das_supported_types'}->{'noncoding_exon'}) && $self->{'das_supported_types'}->{'noncoding_exon'}->{typelist} ){
                $Ftype = 'noncoding_exon';
             }elsif(exists( $self->{'das_supported_types'}->{'exon'}) && $self->{'das_supported_types'}->{'exon'}->{typelist} ){
                $Ftype = 'exon';
             }
             $a = $annHR->{cdsstop} + 1;
          }elsif(exists( $self->{'das_supported_types'}->{'exon'}) && $self->{'das_supported_types'}->{'exon'}->{typelist} ){
                $Ftype = 'exon';
          }
	}
      }elsif(($annHR->{strand} eq 'f')&&($b > $annHR->{cdsstop})&&($a <= $annHR->{cdsstop})){ ## CDSstop occurs within this exon
	 if((exists($self->{'das_supported_types'}->{'three_prime_coding_exon_coding_region'}) && $self->{'das_supported_types'}->{'three_prime_coding_exon_coding_region'}->{typelist})&&
		((exists($self->{'das_supported_types'}->{'three_prime_coding_exon_noncoding_region'}) && $self->{'das_supported_types'}->{'three_prime_coding_exon_noncoding_region'}->{typelist}) ||
		 (exists( $self->{'das_supported_types'}->{'noncoding_exon'}) && $self->{'das_supported_types'}->{'noncoding_exon'}->{typelist} ) ||
		 (exists( $self->{'das_supported_types'}->{'exon'}) && $self->{'das_supported_types'}->{'exon'}->{typelist} ))){

	   $Ftype='three_prime_coding_exon_coding_region';
	   $featLIST->[ scalar(@$featLIST) ] = { ## Coding region
                'id' => join( ":", ( $Ftype, $self->{db_id}, $self->{resid},$annHR->{uid},$exonCNT)),
                'type_id'      => $Ftype,
                'start' => $coordTrans + $a,
                'end'   => $coordTrans + $annHR->{cdsstop},
                'score' => 1,
                'orientation' => ($annHR->{gene_structure} =~ /comp/i)?'-':'+',
                'group_id'        => $annHR->{uid},
                'group_label'     => $annHR->{geneid},
                'method_id'    => exists( $self->{'das_supported_types'}->{$Ftype}->{'method'} ) ? $self->{'das_supported_types'}->{$Ftype}->{'method'}:
                                        exists( $self->{'das_defaults'}->{'method'} ) ? $self->{'das_defaults'}->{'method'}:'third_party_annotation',
                'method_label'    => exists( $self->{'das_supported_types'}->{$Ftype}->{'method_label'} ) ? $self->{'das_supported_types'}->{$Ftype}->{'method_label'}:
                                        exists( $self->{'das_defaults'}->{'method_label'} ) ? $self->{'das_defaults'}->{'method_label'}:'Third-party Annotation',
                'group_type'      => exists( $self->{'das_supported_types'}->{$Ftype}->{'group_type'} ) ? $self->{'das_supported_types'}->{$Ftype}->{'group_type'}:
                                        exists( $self->{'das_defaults'}->{'group_type'} ) ? $self->{'das_defaults'}->{'group_type'}:'gene',
                'group_link_href' => $rootPATH . $self->getRecordLink( {}, { 'uid' => $annHR->{'uid'} }, ( exists( $self->{'chrVIEWABLE'} ) && $self->{'chrVIEWABLE'} ) ? 'CHR' : 'BAC' )
           };
	   $featLIST->[ $#$featLIST ]->{'note'} = "Feature translated from $segFeatHR->{xID} using ($segFeatHR->{id}:$segFeatHR->{start},$segFeatHR->{stop} = $segFeatHR->{xID}:$segFeatHR->{xStart},$segFeatHR->{xStop})" if($segFeatHR->{start} != $segFeatHR->{xStart});
	   $featLIST->[$#$featLIST]->{'type_category'} = &{$self->{MOD_DAS_SET_FeatureTypeCategory}}($annHR,$featLIST->[$#$featLIST]) if(exists($self->{MOD_DAS_SET_FeatureTypeCategory}));
	   $featLIST->[$#$featLIST]->{'group_label'} = &{$self->{MOD_DAS_SET_GroupLabel}}($annHR,$featLIST->[$#$featLIST]) if(exists($self->{MOD_DAS_SET_GroupLabel}));

	   if(exists($self->{'das_supported_types'}->{'three_prime_coding_exon_noncoding_region'}) && $self->{'das_supported_types'}->{'three_prime_coding_exon_noncoding_region'}->{typelist}){
		$Ftype = 'three_prime_coding_exon_noncoding_region';
	   }elsif(exists( $self->{'das_supported_types'}->{'noncoding_exon'}) && $self->{'das_supported_types'}->{'noncoding_exon'}->{typelist} ){
		$Ftype = 'noncoding_exon';
	   }elsif(exists( $self->{'das_supported_types'}->{'exon'}) && $self->{'das_supported_types'}->{'exon'}->{typelist} ){
		$Ftype = 'exon';
	   }
	   $a = $annHR->{cdsstop} + 1;
	}elsif(exists( $self->{'das_supported_types'}->{'exon'}) && $self->{'das_supported_types'}->{'exon'}->{typelist} ){
                $Ftype = 'exon';
        }
      }elsif(($annHR->{strand} eq 'r')&&($b >= $annHR->{cdsstop})&&($a < $annHR->{cdsstop})){ ## 
        if((exists($self->{'das_supported_types'}->{'three_prime_coding_exon_noncoding_region'}) && $self->{'das_supported_types'}->{'three_prime_coding_exon_noncoding_region'}->{typelist})&&
                ((exists($self->{'das_supported_types'}->{'three_prime_coding_exon_coding_region'}) && $self->{'das_supported_types'}->{'three_prime_coding_exon_coding_region'}->{typelist}) ||
                 (exists( $self->{'das_supported_types'}->{'coding_exon'}) && $self->{'das_supported_types'}->{'coding_exon'}->{typelist} ) ||
                 (exists( $self->{'das_supported_types'}->{'exon'}) && $self->{'das_supported_types'}->{'exon'}->{typelist} ))){

           $Ftype='three_prime_coding_exon_noncoding_region';
           $featLIST->[ scalar(@$featLIST) ] = { ## Coding region
                'id' => join( ":", ( $Ftype, $self->{db_id}, $self->{resid},$annHR->{uid},$exonCNT)),
                'type_id'      => $Ftype,
                'start' => $coordTrans + $a,
                'end'   => $coordTrans + $annHR->{cdsstop} - 1,
                'score' => 1,
                'orientation' => ($annHR->{gene_structure} =~ /comp/i)?'-':'+',
                'group_id'        => $annHR->{uid},
                'group_label'     => $annHR->{geneid},
                'method_id'    => exists( $self->{'das_supported_types'}->{$Ftype}->{'method'} ) ? $self->{'das_supported_types'}->{$Ftype}->{'method'}:
                                        exists( $self->{'das_defaults'}->{'method'} ) ? $self->{'das_defaults'}->{'method'}:'third_party_annotation',
                'method_label'    => exists( $self->{'das_supported_types'}->{$Ftype}->{'method_label'} ) ? $self->{'das_supported_types'}->{$Ftype}->{'method_label'}:
                                        exists( $self->{'das_defaults'}->{'method_label'} ) ? $self->{'das_defaults'}->{'method_label'}:'Third-party Annotation',
                'group_type'      => exists( $self->{'das_supported_types'}->{$Ftype}->{'group_type'} ) ? $self->{'das_supported_types'}->{$Ftype}->{'group_type'}:
                                        exists( $self->{'das_defaults'}->{'group_type'} ) ? $self->{'das_defaults'}->{'group_type'}:'gene',
                'group_link_href' => $rootPATH . $self->getRecordLink( {}, { 'uid' => $annHR->{'uid'} }, ( exists( $self->{'chrVIEWABLE'} ) && $self->{'chrVIEWABLE'} ) ? 'CHR' : 'BAC' )
           };
	   $featLIST->[ $#$featLIST ]->{'note'} = "Feature translated from $segFeatHR->{xID} using ($segFeatHR->{id}:$segFeatHR->{start},$segFeatHR->{stop} = $segFeatHR->{xID}:$segFeatHR->{xStart},$segFeatHR->{xStop})" if($segFeatHR->{start} != $segFeatHR->{xStart});
	   $featLIST->[$#$featLIST]->{'type_category'} = &{$self->{MOD_DAS_SET_FeatureTypeCategory}}($annHR,$featLIST->[$#$featLIST]) if(exists($self->{MOD_DAS_SET_FeatureTypeCategory}));
	   $featLIST->[$#$featLIST]->{'group_label'} = &{$self->{MOD_DAS_SET_GroupLabel}}($annHR,$featLIST->[$#$featLIST]) if(exists($self->{MOD_DAS_SET_GroupLabel}));

           if(exists($self->{'das_supported_types'}->{'three_prime_coding_exon_coding_region'}) && $self->{'das_supported_types'}->{'three_prime_coding_exon_coding_region'}->{typelist}){
                $Ftype = 'three_prime_coding_exon_coding_region';
           }elsif(exists( $self->{'das_supported_types'}->{'coding_exon'}) && $self->{'das_supported_types'}->{'coding_exon'}->{typelist} ){
                $Ftype = 'coding_exon';
           }elsif(exists( $self->{'das_supported_types'}->{'exon'}) && $self->{'das_supported_types'}->{'exon'}->{typelist} ){
                $Ftype = 'exon';
           }    
           $a = $annHR->{cdsstop};
	}elsif(exists( $self->{'das_supported_types'}->{'exon'}) && $self->{'das_supported_types'}->{'exon'}->{typelist} ){
                $Ftype = 'exon';
        }
	
	if(($b > $annHR->{cdsstart})&&($a <= $annHR->{cdsstart})){ ##
	  if(($Ftype ne 'exon')&&
                ((exists($self->{'das_supported_types'}->{'five_prime_coding_exon_noncoding_region'}) && $self->{'das_supported_types'}->{'five_prime_coding_exon_noncoding_region'}->{typelist}) ||
                 (exists( $self->{'das_supported_types'}->{'noncoding_exon'}) && $self->{'das_supported_types'}->{'noncoding_exon'}->{typelist} ) ||
                 (exists( $self->{'das_supported_types'}->{'exon'}) && $self->{'das_supported_types'}->{'exon'}->{typelist} ))){

             $featLIST->[ scalar(@$featLIST) ] = { ## Coding region
                'id' => join( ":", ( $Ftype, $self->{db_id}, $self->{resid},$annHR->{uid},$exonCNT)),
                'type_id'      => $Ftype,
                'start' => $coordTrans + $a,
                'end'   => $coordTrans + $annHR->{cdsstart},
                'score' => 1,
                'orientation' => ($annHR->{gene_structure} =~ /comp/i)?'-':'+',
                'group_id'        => $annHR->{uid},
                'group_label'     => $annHR->{geneid},
                'method_id'    => exists( $self->{'das_supported_types'}->{$Ftype}->{'method'} ) ? $self->{'das_supported_types'}->{$Ftype}->{'method'}:
                                        exists( $self->{'das_defaults'}->{'method'} ) ? $self->{'das_defaults'}->{'method'}:'third_party_annotation',
                'method_label'    => exists( $self->{'das_supported_types'}->{$Ftype}->{'method_label'} ) ? $self->{'das_supported_types'}->{$Ftype}->{'method_label'}:
                                        exists( $self->{'das_defaults'}->{'method_label'} ) ? $self->{'das_defaults'}->{'method_label'}:'Third-party Annotation',
                'group_type'      => exists( $self->{'das_supported_types'}->{$Ftype}->{'group_type'} ) ? $self->{'das_supported_types'}->{$Ftype}->{'group_type'}:
                                        exists( $self->{'das_defaults'}->{'group_type'} ) ? $self->{'das_defaults'}->{'group_type'}:'gene',
                'group_link_href' => $rootPATH . $self->getRecordLink( {}, { 'uid' => $annHR->{'uid'} }, ( exists( $self->{'chrVIEWABLE'} ) && $self->{'chrVIEWABLE'} ) ? 'CHR' : 'BAC' )
             };
             $featLIST->[ $#$featLIST ]->{'note'} = "Feature translated from $segFeatHR->{xID} using ($segFeatHR->{id}:$segFeatHR->{start},$segFeatHR->{stop} = $segFeatHR->{xID}:$segFeatHR->{xStart},$segFeatHR->{xStop})" if($segFeatHR->{start} != $segFeatHR->{xStart});
             $featLIST->[$#$featLIST]->{'type_category'} = &{$self->{MOD_DAS_SET_FeatureTypeCategory}}($annHR,$featLIST->[$#$featLIST]) if(exists($self->{MOD_DAS_SET_FeatureTypeCategory}));
	     $featLIST->[$#$featLIST]->{'group_label'} = &{$self->{MOD_DAS_SET_GroupLabel}}($annHR,$featLIST->[$#$featLIST]) if(exists($self->{MOD_DAS_SET_GroupLabel}));

             if(exists($self->{'das_supported_types'}->{'five_prime_coding_exon_noncoding_region'}) && $self->{'das_supported_types'}->{'five_prime_coding_exon_noncoding_region'}->{typelist}){
                $Ftype = 'five_prime_coding_exon_noncoding_region';
             }elsif(exists( $self->{'das_supported_types'}->{'noncoding_exon'}) && $self->{'das_supported_types'}->{'noncoding_exon'}->{typelist} ){
                $Ftype = 'noncoding_exon';
             }elsif(exists( $self->{'das_supported_types'}->{'exon'}) && $self->{'das_supported_types'}->{'exon'}->{typelist} ){
                $Ftype = 'exon';
             }
             $a = $annHR->{cdsstart} + 1;
          }elsif(exists( $self->{'das_supported_types'}->{'exon'}) && $self->{'das_supported_types'}->{'exon'}->{typelist} ){
                $Ftype = 'exon';
          }
	}
      }elsif(($annHR->{strand} eq 'r')&&($b > $annHR->{cdsstart})&&($a <= $annHR->{cdsstart})){ ## 
         if((exists($self->{'das_supported_types'}->{'five_prime_coding_exon_coding_region'}) && $self->{'das_supported_types'}->{'five_prime_coding_exon_coding_region'}->{typelist})&&
                ((exists($self->{'das_supported_types'}->{'five_prime_coding_exon_noncoding_region'}) && $self->{'das_supported_types'}->{'five_prime_coding_exon_noncoding_region'}->{typelist}) ||
                 (exists( $self->{'das_supported_types'}->{'noncoding_exon'}) && $self->{'das_supported_types'}->{'noncoding_exon'}->{typelist} ) ||
                 (exists( $self->{'das_supported_types'}->{'exon'}) && $self->{'das_supported_types'}->{'exon'}->{typelist} ))){

           $Ftype='five_prime_coding_exon_coding_region';
           $featLIST->[ scalar(@$featLIST) ] = { ## Coding region
                'id' => join( ":", ( $Ftype, $self->{db_id}, $self->{resid},$annHR->{uid},$exonCNT)),
                'type_id'      => $Ftype,
                'start' => $coordTrans + $a,
                'end'   => $coordTrans + $annHR->{cdsstart},
                'score' => 1,
                'orientation' => ($annHR->{gene_structure} =~ /comp/i)?'-':'+',
                'group_id'        => $annHR->{uid},
                'group_label'     => $annHR->{geneid},
                'method_id'    => exists( $self->{'das_supported_types'}->{$Ftype}->{'method'} ) ? $self->{'das_supported_types'}->{$Ftype}->{'method'}:
                                        exists( $self->{'das_defaults'}->{'method'} ) ? $self->{'das_defaults'}->{'method'}:'third_party_annotation',
                'method_label'    => exists( $self->{'das_supported_types'}->{$Ftype}->{'method_label'} ) ? $self->{'das_supported_types'}->{$Ftype}->{'method_label'}:
                                        exists( $self->{'das_defaults'}->{'method_label'} ) ? $self->{'das_defaults'}->{'method_label'}:'Third-party Annotation',
                'group_type'      => exists( $self->{'das_supported_types'}->{$Ftype}->{'group_type'} ) ? $self->{'das_supported_types'}->{$Ftype}->{'group_type'}:
                                        exists( $self->{'das_defaults'}->{'group_type'} ) ? $self->{'das_defaults'}->{'group_type'}:'gene',
                'group_link_href' => $rootPATH . $self->getRecordLink( {}, { 'uid' => $annHR->{'uid'} }, ( exists( $self->{'chrVIEWABLE'} ) && $self->{'chrVIEWABLE'} ) ? 'CHR' : 'BAC' )
           };
	   $featLIST->[ $#$featLIST ]->{'note'} = "Feature translated from $segFeatHR->{xID} using ($segFeatHR->{id}:$segFeatHR->{start},$segFeatHR->{stop} = $segFeatHR->{xID}:$segFeatHR->{xStart},$segFeatHR->{xStop})" if($segFeatHR->{start} != $segFeatHR->{xStart});
	   $featLIST->[$#$featLIST]->{'type_category'} = &{$self->{MOD_DAS_SET_FeatureTypeCategory}}($annHR,$featLIST->[$#$featLIST]) if(exists($self->{MOD_DAS_SET_FeatureTypeCategory}));
	   $featLIST->[$#$featLIST]->{'group_label'} = &{$self->{MOD_DAS_SET_GroupLabel}}($annHR,$featLIST->[$#$featLIST]) if(exists($self->{MOD_DAS_SET_GroupLabel}));

           if(exists($self->{'das_supported_types'}->{'five_prime_coding_exon_noncoding_region'}) && $self->{'das_supported_types'}->{'five_prime_coding_exon_noncoding_region'}->{typelist}){
                $Ftype = 'five_prime_coding_exon_noncoding_region';
           }elsif(exists( $self->{'das_supported_types'}->{'noncoding_exon'}) && $self->{'das_supported_types'}->{'noncoding_exon'}->{typelist} ){
                $Ftype = 'noncoding_exon';
           }elsif(exists( $self->{'das_supported_types'}->{'exon'}) && $self->{'das_supported_types'}->{'exon'}->{typelist} ){
                $Ftype = 'exon';
           }
           $a = $annHR->{cdsstart} + 1;
	}elsif(exists( $self->{'das_supported_types'}->{'exon'}) && $self->{'das_supported_types'}->{'exon'}->{typelist} ){
                $Ftype = 'exon';
        }
      }elsif((($annHR->{strand} eq 'f')&&($b < $annHR->{cdsstart}))||(($annHR->{strand} eq 'r')&&($a > $annHR->{cdsstart}))){
        if(exists( $self->{'das_supported_types'}->{'five_prime_noncoding_exon'}) && $self->{'das_supported_types'}->{'five_prime_noncoding_exon'}->{typelist} ){
		$Ftype = 'five_prime_noncoding_exon';
        }elsif(exists( $self->{'das_supported_types'}->{'noncoding_exon'}) && $self->{'das_supported_types'}->{'noncoding_exon'}->{typelist} ){
		   $Ftype='five_prime_coding_exon_coding_region';
		   $featLIST->[ scalar(@$featLIST) ] = { ## Coding region
			'id' => join( ":", ( $Ftype, $self->{db_id}, $self->{resid},$annHR->{uid},$exonCNT)),
			'type_id'      => $Ftype,
			'start' => $coordTrans + $a,
			'end'   => $coordTrans + $annHR->{cdsstart},
			'score' => 1,
			'orientation' => ($annHR->{gene_structure} =~ /comp/i)?'-':'+',
			'group_id'        => $annHR->{uid},
			'group_label'     => $annHR->{geneid},
                	'method_id'    => exists( $self->{'das_supported_types'}->{$Ftype}->{'method'} ) ? $self->{'das_supported_types'}->{$Ftype}->{'method'}:
                       	                 	exists( $self->{'das_defaults'}->{'method'} ) ? $self->{'das_defaults'}->{'method'}:'third_party_annotation',
                	'method_label'    => exists( $self->{'das_supported_types'}->{$Ftype}->{'method_label'} ) ? $self->{'das_supported_types'}->{$Ftype}->{'method_label'}:
                                        	exists( $self->{'das_defaults'}->{'method_label'} ) ? $self->{'das_defaults'}->{'method_label'}:'Third-party Annotation',
                	'group_type'      => exists( $self->{'das_supported_types'}->{$Ftype}->{'group_type'} ) ? $self->{'das_supported_types'}->{$Ftype}->{'group_type'}:
                                        	exists( $self->{'das_defaults'}->{'group_type'} ) ? $self->{'das_defaults'}->{'group_type'}:'gene',
			'group_link_href' => $rootPATH . $self->getRecordLink( {}, { 'uid' => $annHR->{'uid'} }, ( exists( $self->{'chrVIEWABLE'} ) && $self->{'chrVIEWABLE'} ) ? 'CHR' : 'BAC' )
		   };
	   	   $featLIST->[ $#$featLIST ]->{'note'} = "Feature translated from $segFeatHR->{xID} using ($segFeatHR->{id}:$segFeatHR->{start},$segFeatHR->{stop} = $segFeatHR->{xID}:$segFeatHR->{xStart},$segFeatHR->{xStop})" if($segFeatHR->{start} != $segFeatHR->{xStart});
	 	   $featLIST->[$#$featLIST]->{'type_category'} = &{$self->{MOD_DAS_SET_FeatureTypeCategory}}($annHR,$featLIST->[$#$featLIST]) if(exists($self->{MOD_DAS_SET_FeatureTypeCategory}));
	           $featLIST->[$#$featLIST]->{'group_label'} = &{$self->{MOD_DAS_SET_GroupLabel}}($annHR,$featLIST->[$#$featLIST]) if(exists($self->{MOD_DAS_SET_GroupLabel}));

		   if(exists($self->{'das_supported_types'}->{'five_prime_coding_exon_noncoding_region'}) && $self->{'das_supported_types'}->{'five_prime_coding_exon_noncoding_region'}->{typelist}){
			$Ftype = 'five_prime_coding_exon_noncoding_region';
		   }elsif(exists( $self->{'das_supported_types'}->{'noncoding_exon'}) && $self->{'das_supported_types'}->{'noncoding_exon'}->{typelist} ){
			$Ftype = 'noncoding_exon';
		   }elsif(exists( $self->{'das_supported_types'}->{'exon'}) && $self->{'das_supported_types'}->{'exon'}->{typelist} ){
			$Ftype = 'exon';
		   }
		   $a = $annHR->{cdsstart} + 1;
		}elsif(exists( $self->{'das_supported_types'}->{'exon'}) && $self->{'das_supported_types'}->{'exon'}->{typelist} ){
			$Ftype = 'exon';
		}
	      }elsif((($annHR->{strand} eq 'f')&&($b < $annHR->{cdsstart}))||(($annHR->{strand} eq 'r')&&($a > $annHR->{cdsstart}))){
		if(exists( $self->{'das_supported_types'}->{'five_prime_noncoding_exon'}) && $self->{'das_supported_types'}->{'five_prime_noncoding_exon'}->{typelist} ){
			$Ftype = 'five_prime_noncoding_exon';
		}elsif(exists( $self->{'das_supported_types'}->{'noncoding_exon'}) && $self->{'das_supported_types'}->{'noncoding_exon'}->{typelist} ){
		$Ftype = 'noncoding_exon';
        }elsif(exists( $self->{'das_supported_types'}->{'exon'}) && $self->{'das_supported_types'}->{'exon'}->{typelist} ){
		$Ftype = 'exon';
	}
      }elsif((($annHR->{strand} eq 'f')&&($a > $annHR->{cdsstop}))||(($annHR->{strand} eq 'r')&&($b < $annHR->{cdsstop}))){ 
        if(exists( $self->{'das_supported_types'}->{'three_prime_noncoding_exon'}) && $self->{'das_supported_types'}->{'three_prime_noncoding_exon'}->{typelist} ){
                $Ftype = 'three_prime_noncoding_exon';
        }elsif(exists( $self->{'das_supported_types'}->{'noncoding_exon'}) && $self->{'das_supported_types'}->{'noncoding_exon'}->{typelist} ){
                $Ftype = 'noncoding_exon';
        }elsif(exists( $self->{'das_supported_types'}->{'exon'}) && $self->{'das_supported_types'}->{'exon'}->{typelist} ){
                $Ftype = 'exon';
        }
      }else{ 
        if(exists( $self->{'das_supported_types'}->{'coding_exon'}) && $self->{'das_supported_types'}->{'coding_exon'}->{typelist} ){
                $Ftype = 'coding_exon';
        }elsif(exists( $self->{'das_supported_types'}->{'exon'}) && $self->{'das_supported_types'}->{'exon'}->{typelist} ){
                $Ftype = 'exon';
        }
      }
      if($Ftype ne ''){
         $featLIST->[ scalar(@$featLIST) ] = {
                'id' => join( ":", ( $Ftype, $self->{db_id}, $self->{resid},$annHR->{uid},$exonCNT)),
                'type_id'      => $Ftype,
                'start' => $coordTrans + $a,
                'end'   => $coordTrans + $b,
                'score' => 1,
                'orientation' => ($annHR->{gene_structure} =~ /comp/i)?'-':'+',
                'group_id'        => $annHR->{uid},
                'group_label'     => $annHR->{geneid},
                'method_id'    => exists( $self->{'das_supported_types'}->{$Ftype}->{'method'} ) ? $self->{'das_supported_types'}->{$Ftype}->{'method'}:
                                        exists( $self->{'das_defaults'}->{'method'} ) ? $self->{'das_defaults'}->{'method'}:'third_party_annotation',
                'method_label'    => exists( $self->{'das_supported_types'}->{$Ftype}->{'method_label'} ) ? $self->{'das_supported_types'}->{$Ftype}->{'method_label'}:
                                        exists( $self->{'das_defaults'}->{'method_label'} ) ? $self->{'das_defaults'}->{'method_label'}:'Third-party Annotation',
                'group_type'      => exists( $self->{'das_supported_types'}->{$Ftype}->{'group_type'} ) ? $self->{'das_supported_types'}->{$Ftype}->{'group_type'}:
                                        exists( $self->{'das_defaults'}->{'group_type'} ) ? $self->{'das_defaults'}->{'group_type'}:'gene',
                'group_link_href' => $rootPATH . $self->getRecordLink( {}, { 'uid' => $annHR->{'uid'} }, ( exists( $self->{'chrVIEWABLE'} ) && $self->{'chrVIEWABLE'} ) ? 'CHR' : 'BAC' )
         };
         $featLIST->[ $#$featLIST ]->{'note'} = "Feature translated from $segFeatHR->{xID} using ($segFeatHR->{id}:$segFeatHR->{start},$segFeatHR->{stop} = $segFeatHR->{xID}:$segFeatHR->{xStart},$segFeatHR->{xStop})" if($segFeatHR->{start} != $segFeatHR->{xStart});
	 $featLIST->[$#$featLIST]->{'type_category'} = &{$self->{MOD_DAS_SET_FeatureTypeCategory}}($annHR,$featLIST->[$#$featLIST]) if(exists($self->{MOD_DAS_SET_FeatureTypeCategory}));
	 $featLIST->[$#$featLIST]->{'group_label'} = &{$self->{MOD_DAS_SET_GroupLabel}}($annHR,$featLIST->[$#$featLIST]) if(exists($self->{MOD_DAS_SET_GroupLabel}));
      }

    } 
  }

  return ( scalar(@$featLIST) ) ? $featLIST : undef;
}


#### SORT ROUTINES

sub _by_ICLR{
  my $aGenomicID = (exists($a->{chr}))?$a->{chr}:(exists($a->{gseg_gi}))?a->{gseg_gi}:0;
  my $bGenomicID = (exists($b->{chr}))?$b->{chr}:(exists($b->{gseg_gi}))?$b->{gseg_gi}:0;
  return (
	  ($a->{geneid}    <=> $b->{geneid})    ||
	  ($aGenomicID     <=> $bGenomicID)     ||
	  ($a->{l_pos}     <=> $b->{l_pos})     ||
	  ($b->{r_pos}     <=> $a->{r_pos})
	 );
}

sub _by_CLR{
  my $aGenomicID = (exists($a->{chr}))?$a->{chr}:(exists($a->{gseg_gi}))?a->{gseg_gi}:0;
  my $bGenomicID = (exists($b->{chr}))?$b->{chr}:(exists($b->{gseg_gi}))?$b->{gseg_gi}:0;
  return (
	  ($aGenomicID     <=> $bGenomicID)     ||
	  ($a->{l_pos}     <=> $b->{l_pos})     ||
	  ($b->{r_pos}     <=> $a->{r_pos})
	 );
}

sub _by_CCLR{
  return (
#	  ($a->{iscognate} cmp $b->{iscognate}) ||
	  ($a->{chr}       <=> $b->{chr})       ||
	  ($a->{l_pos}     <=> $b->{l_pos})     ||
	  ($b->{r_pos}     <=> $a->{r_pos})
	 );
}



#### MISC subs

sub getSEQS{
print STDERR "DEPRECATED FUNCTION AnnotationTrack::getSEQS accessed!\n";

  my ($self,$chr,$info,$cds_start,$cds_end) = @_;
  my ($mRNAseqf, $proteinseqf, $proteinseq, $proteinseqn, $seq, $tlist, $newseq, $lines);
  my @coordpairs;
  my @ecoords;
  my $clist;
  my @exonpairs;
  if ($info ne ""){  

  open(SR,$DBver[$#DBver]->{seqFILE}) || die "[XGDB::AnnotationTrack] ERROR: cannot open genome sequence file!";
  $mRNAseqf = "";
  @coordpairs = $info =~ /\d+\.\.\d+/g;
  $seq = "";
  @coords =();
  $newseq = "";
  for (my $i=0;$i<scalar(@coordpairs);$i++){
    @coords = split /\.\./, $coordpairs[$i];
    seek(SR,($DBver[$#DBver]->{genomeST}->[$chr-1] + $coords[0]-1 ),0);
    read(SR,$newseq, $coords[1]-$coords[0]+1);
    $seq .= $newseq;
  }
  close SR;
  if ($info =~ /complement/){
      $seq = reverse $seq;
      $seq =~ tr/ACGT/TGCA/;
  }
  my $lines=0,$mRNAseqf = "";
  $lines = int length($seq)/40;
  my $ip;
  for ($ip=0;$ip<$lines;$ip++){
    $mRNAseqf .= substr($seq,40*$ip,40)."\n";
  }
  $mRNAseqf .= substr($seq,40*$ip,length($seq)-40*$ip);
  }
   # protein sequence
     my %codon = (
    'TCA' => 'S',    # Serine
    'TCC' => 'S',    # Serine
    'TCG' => 'S',    # Serine
    'TCT' => 'S',    # Serine
    'TTC' => 'F',    # Phenylalanine
    'TTT' => 'F',    # Phenylalanine
    'TTA' => 'L',    # Leucine
    'TTG' => 'L',    # Leucine
    'TAC' => 'Y',    # Tyrosine
    'TAT' => 'Y',    # Tyrosine
    'TAA' => '*',    # Stop
    'TAG' => '*',    # Stop
    '---' => '-',    # In-frame gap
    '...' => '_',    # In-frame gap
    'NNN' => 'N',    # UNK
    '???' => '?',    # UNK
    'TGC' => 'C',    # Cysteine
    'TGT' => 'C',    # Cysteine
    'TGA' => '*',    # Stop
    'TGG' => 'W',    # Tryptophan
    'CTA' => 'L',    # Leucine
    'CTC' => 'L',    # Leucine
    'CTG' => 'L',    # Leucine
    'CTT' => 'L',    # Leucine
    'CCA' => 'P',    # Proline
    'CCC' => 'P',    # Proline
    'CCG' => 'P',    # Proline
    'CCT' => 'P',    # Proline
    'CAC' => 'H',    # Histidine
    'CAT' => 'H',    # Histidine
    'CAA' => 'Q',    # Glutamine
    'CAG' => 'Q',    # Glutamine
    'CGA' => 'R',    # Arginine
    'CGC' => 'R',    # Arginine
    'CGG' => 'R',    # Arginine
    'CGT' => 'R',    # Arginine
    'ATA' => 'I',    # Isoleucine
    'ATC' => 'I',    # Isoleucine
    'ATT' => 'I',    # Isoleucine
    'ATG' => 'M',    # Methionine
    'ACA' => 'T',    # Threonine
    'ACC' => 'T',    # Threonine
    'ACG' => 'T',    # Threonine
    'ACT' => 'T',    # Threonine
    'AAC' => 'N',    # Asparagine
    'AAT' => 'N',    # Asparagine
    'AAA' => 'K',    # Lysine
    'AAG' => 'K',    # Lysine
    'AGC' => 'S',    # Serine
    'AGT' => 'S',    # Serine
    'AGA' => 'R',    # Arginine
    'AGG' => 'R',    # Arginine
    'GTA' => 'V',    # Valine
    'GTC' => 'V',    # Valine
    'GTG' => 'V',    # Valine
    'GTT' => 'V',    # Valine
    'GCA' => 'A',    # Alanine
    'GCC' => 'A',    # Alanine
    'GCG' => 'A',    # Alanine
    'GCT' => 'A',    # Alanine
    'GAC' => 'D',    # Aspartic Acid
    'GAT' => 'D',    # Aspartic Acid
    'GAA' => 'E',    # Glutamic Acid
    'GAG' => 'E',    # Glutamic Acid
    'GGA' => 'G',    # Glycine
    'GGC' => 'G',    # Glycine
    'GGG' => 'G',    # Glycine
    'GGT' => 'G',    # Glycine
    );

  if ($cds_start ne "" and $cds_end ne ""){
    %xlist = ();
    $clist = $tlist = "";
    @exonpairs = $info =~ /\d+\.\.\d+/g;
    for (my $ep=0;$ep<scalar(@exonpairs);$ep++){
      @ecoords = split /\.\./, $exonpairs[$ep];
      for (my $epc=$ecoords[0];$epc<=$ecoords[1];$epc++){
	  $clist .= "$epc,";
	  $tlist .= keys(%xlist).",";
	  $xlist{$epc} = keys(%xlist);
      }
    }
    if ($info =~ /complement/){
      @tempArr1 = split /\,/, $clist;
      @tempArr2 = split /\,/, $tlist;
      %xlist = ();
      for (my $s=0;$s<scalar(@tempArr1);$s++){
        $xlist{$tempArr1[$s]} = $tempArr2[$#$tempArr2 - $s];
      }
    }
    $proteinseqn = substr($seq,$xlist{$cds_start},($xlist{$cds_end}-$xlist{$cds_start}));
     # $proteinseqf = "$cds_start,$cds_end sds $proteinseqn";
    $proteinseq = $proteinseqf = "";
    for (my $cc=0;$cc<length($proteinseqn)/3;$cc++){
      $proteinseq .= $codon{substr($proteinseqn,3*$cc,3)};
    }
    $lines = int length($proteinseq)/40;
    my $ip;
    for ($ip=0;$ip<$lines;$ip++){
     $proteinseqf .= substr($proteinseq,40*$ip,40)."\n";
    }
    $proteinseqf .= substr($proteinseq,40*$lines,length($proteinseq)-40*$lines);

  }
if ($proteinseqf ne ""){
  $proteinseqf = "$proteinseqf";
}else{
  $proteinseqf = "No protein coding region defined.";
}
  my $tRF = [$mRNAseqf,$proteinseqf];
  return $tRF;
}

sub get_exStats{
  my $self = shift;
  my ($argHR) = @_;
  my ($uid,$str,$recordHR,%STATS);

  $self->loadREGION($argHR) if((defined($argHR))&&(!exists($self->{pgsREGION_href})));
  if((exists($self->{pgsREGION_href}))&&(keys(%{$self->{pgsREGION_href}}))){
    foreach $uid (keys %{$self->{pgsREGION_href}}){
      $recordHR = $self->{pgsREGION_href}{$uid};
      $str = $recordHR->{gene_structure};
      $str =~ s/^\D+//;
      @coords = split(/\D+/,$str);
      @coords = reverse @coords if($recordHR->{gene_structure} =~ /comp/i);
      my $y = 0;
      my $cds_pos = 1;
      for(my $x=0; $x<$#coords; $x+=2){
	$y++;
	my $exSize = Locus::max($coords[$x],$coords[$x+1]) - Locus::min($coords[$x],$coords[$x+1]) + 1;
	$STATS{$self->{resid} . '_' . $uid . '_' . $y} = [$y,$coords[$x],$coords[$x+1],$cds_pos,$cds_pos + $exSize,'NA'];
	$cds_pos += ($exSize + 1);
      }
    }
  }else{return undef;}

  return \%STATS;
}

sub get_inStats{
  my $self = shift;
  my ($argHR) = @_;
  my ($uidlist,$statQUERY,$sth,$rowHR,%STATS);

  $self->loadREGION($argHR) if((defined($argHR))&&(!exists($self->{pgsREGION_href})));
  if((exists($self->{pgsREGION_href}))&&(keys(%{$self->{pgsREGION_href}}))){
    foreach $uid (keys %{$self->{pgsREGION_href}}){
      $recordHR = $self->{pgsREGION_href}{$uid};
      $str = $recordHR->{gene_structure};
      $str =~ s/^\D+//;
      @coords = split(/\D+/,$str);
      @coords = reverse @coords if($recordHR->{gene_structure} =~ /comp/i);
      my $delta = ($recordHR->{gene_structure} =~ /comp/i)? -1 : 1;
      my $y = 0;
      for(my $x=1; $x<$#coords; $x+=2){
	$y++;
	$STATS{$self->{resid} . '_' . $uid . '_' . $y} = [$y,($coords[$x] + $delta),($coords[$x+1] - $delta),'NA','NA','NA','NA'];
      }
    }
  }else{return undef;}

  return \%STATS;
}


1;
