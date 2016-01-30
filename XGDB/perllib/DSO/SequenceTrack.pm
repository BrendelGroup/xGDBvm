package SequenceTrack;
use base "Locus";

do 'SITEDEF.pl';

use GeneView;
use CGI ':all';

sub whatami {
  my $self = shift;
  $self->SUPER::whatami();
  print "SequenceTrack:";
}

sub _init {
  my $self = shift;

  $self->SUPER::_init(@_);
}

sub search_by_ID {
  my $self = shift;
  my ($id) = @_;
  my ( $field, $msg, $res_href, $sth, $sth2 );

  $id = $self->{VALIDATE_ID}->($id) if ( exists( $self->{VALIDATE_ID} ) );

  $self->{dbh}->{FetchHashKeyName} = 'NAME_lc';

  $sth = $self->{dbh}->prepare_cached( $self->{seqQUERY} );
  $sth->execute($id);
  $res_href = $sth->fetchrow_hashref("NAME_lc");
  if ( keys %$res_href ) {
    foreach $field ( keys %$res_href ) {
      $self->{$field} = $res_href->{$field};
    }

    if ( exists( $self->{chrDESC_QUERY} ) ) {
      $sth2 = $self->{dbh}->prepare_cached( $self->{chrQUERY} );
      $sth2->execute( $res_href->{gi} );
      $self->{chrLOCI_href} = $sth2->fetchall_hashref('uid');
    }

    if ( exists( $self->{gsegDESC_QUERY} ) ) {
      $sth2 = $self->{dbh}->prepare_cached( $self->{gsegQUERY} );
      $sth2->execute( $res_href->{gi} );
      $self->{gsegLOCI_href} = $sth2->fetchall_hashref('uid');
    }

    $sth2->finish();
  } else {
    return ( 0, $msg );
  }

  $sth->finish();

  return ( keys( %{ $self->{chrLOCI_href} } ) + keys( %{ $self->{gsegLOCI_href} } ), $msg );
}

sub selectRECORD {
  my $self = shift;
  my ($argHR) = @_;
  my ( $type, $record );

  ## Possible inputs to obtain record in order of preference (chrUID,gsegUID,gi,null)

  if ( exists( $argHR->{chrUID} ) ) {
    if ( !exists( $self->{chrLOCI_href}->{ $argHR->{chrUID} } ) ) {
      my $sth = $self->{dbh}->prepare_cached( $self->{chrUID_QUERY} );
      $sth->execute( $argHR->{chrUID} );
      my @ary = $sth->fetchrow_array();
      if ( scalar(@ary) ) {
        $self->search_by_ID( $ary[0] );
      } else {
        return undef;    ## this is an invalid est_good_pgs uid
      }
      $sth->finish();
    }
    $record = $self->{chrLOCI_href}->{ $argHR->{chrUID} };
    $type   = 'chrUID';
  } elsif ( exists( $argHR->{gsegUID} ) ) {
    if ( !exists( $self->{gsegLOCI_href}->{ $argHR->{gsegUID} } ) ) {
      my $sth = $self->{dbh}->prepare_cached( $self->{gsegUID_QUERY} );
      $sth->execute( $argHR->{gsegUID} );
      my @ary = $sth->fetchrow_array();
      if ( scalar(@ary) ) {
        $self->search_by_ID( $ary[0] );
      } else {
        return undef;    ## this is an invalid gseg_est_good_pgs uid
      }
      $sth->finish();
    }
    $record = $self->{gsegLOCI_href}->{ $argHR->{gsegUID} };
    $type   = 'gsegUID';
  } else {
    if ( exists( $argHR->{gi} ) ) {
      if ( ( !exists( $self->{gi} ) ) || ( $self->{gi} ne $argHR->{gi} ) ) {
        $self->search_by_ID( $argHR->{gi} );
      }
    }
    ## Get values using the first cognate locus (chr,gseg)
    my ($recordHR);
    if ( ( exists( $self->{chrLOCI_href} ) ) && ( keys %{ $self->{chrLOCI_href} } ) ) {
      $type = 'chrUID';
      foreach $recordHR ( sort _by_CCLR values %{ $self->{chrLOCI_href} } ) {
        $record = $recordHR if ( !defined($record) );
        if ( $recordHR->{iscognate} eq 'True' ) {
          $record = $recordHR;
          last;
        }
      }
    } elsif ( ( exists( $self->{gsegLOCI_href} ) ) && ( keys %{ $self->{gsegLOCI_href} } ) ) {
      $type = 'gsegUID';
      foreach $recordHR ( sort _by_CCLR values %{ $self->{gsegLOCI_href} } ) {
        $record = $recordHR if ( !defined($record) );
        if ( $recordHR->{iscognate} eq 'True' ) {
          $record = $recordHR;
          last;
        }
      }
    } else {
      return undef;
    }
  }

  $argHR->{gseg_gi} = $record->{gseg_gi} if ( exists( $record->{gseg_gi} ) );

  return ( $type, $record );
}

sub showRECORD {
  my $self = shift;
  my ($argHR) = @_;

  exists( $argHR->{selectedRECORD} ) || ( @$argHR{ 'recordTYPE', 'selectedRECORD' } = $self->selectRECORD($argHR) );

  my $recordINFO    = $self->showRECORD_INFO( $argHR, $argHR->{selectedRECORD} );
  my $structIMG     = $self->showSTRUCT($argHR);
  my $chr_lociTABLE = $self->showEXTENDED_LOCI_TABLE($argHR);
  my $bac_lociTABLE = $self->showEXTENDED_LOCI_TABLE($argHR, 'BAC');

  my $lociTABLES = '';
  $lociTABLES .= "<div style='margin:0px; padding:2px; width:1000px; max-height:250px; overflow:auto; border:none'>$chr_lociTABLE</div>\n" if ( $chr_lociTABLE ne '' );
  $lociTABLES .= "<div style='margin:0px; padding:2px; width:1000px; max-height:250px; overflow:auto; border:none;'>$bac_lociTABLE</div>\n"    if ( $bac_lociTABLE ne '' );

  my $helpId = (exists($self->{helpfile}) && -r "${HELPDIR}$self->{helpfile}.inc.php")?$self->{helpfile}:
		(-r "${HELPDIR}$self->{trackname}.inc.php")? $self->{trackname}:
		(-r "${HELPDIR}$self->{DSOname}.inc.php")?$self->{DSOname}:'sequence_record_help';

  ## layout page
  my $PAGE_CONTENTS = <<END_OF_PAGE;
<h1>$self->{trackname} Sequence Record  <img id='${helpId}' title='Sequence Record View Help' class='xgdb-help-button' src='/XGDB/images/help-icon.png' alt='?' /></h1>\n
<div class="record_section">
$recordINFO<br />
</div>
<div class="record_section">
<h2>Structure: <span class="heading">Click to view in Genome Context</span></h2>
<a class="indent1" href="$region_link">$structIMG</a>
</div>
<div class="record_section">
</div>

$lociTABLES
END_OF_PAGE

  ## Adjust header start/end (l_pos,r_pos) to region local to selected record
  $self->setRegionLocal($argHR);

  return ( { -title => "${SITENAMEshort} $self->{trackname}:$self->{gi}", -bgcolor => "#FFFFFF" }, $PDjscript, $PAGE_CONTENTS );
}

sub _STANDARD_RECORD_INFO {
  my $self = shift;
  my ( $argHR, $recordHR ) = @_;

  my $toolHR = $self->_STANDARD_TOOL_URLS(@_);

  $self->{description} =~ s/^\s+//;
  my $formated_seq = $self->{seq};
  $formated_seq =~ s/(.{70})/$1\n/g;

  my $exLinkHR    = $self->getExternalURLS(@_);
  my $exLinkTable = "<tr>\n";
  my ( $exLinkID, $x ) = ( '', 0 );
  foreach $exLinkID ( sort { return $a cmp $b; } keys %{$exLinkHR} ) {
    $x++;
    $exLinkTable .= "</tr><tr>\n" if ( ( $x % 10 ) == 0 );
    $exLinkTable .= "<td class='exURL'>$exLinkHR->{$exLinkID}</td>\n";
  }
  $exLinkTable .= "</tr>";

  my $border_color = ( exists( $self->{primaryColor} ) ) ? $self->{primaryColor} : "blue";
  my $genomic_source =
      ( exists( $argHR->{chrUID} ) ) ? "Chromosome $argHR->{chr} <span style='font-size:9px; color:red;'>[ " . $DBver[ $self->{db_id} ]->{DBtag} . " ]</span>"
    : ( exists( $argHR->{gsegUID} ) ) ? "${LATINORGN} Segment\| $recordHR->{gseg_gi} \|"
    : "<span style='color:red;'>!! Undefined Genomic Source !!</span>";

  return <<END_OF_INFO;
<table id="gdb_record"  style="margin:1px; width:700px; border:2px solid $border_color;">
<tr>
<td style="text-align:right; font-size:12px;"><b>ID:</b></td><td style="text-align:left;">$self->{gi}</td>
<td style="text-align:right; font-size:12px;"><b>Accession:</b></td><td style="text-align:left;">$self->{acc}</td></tr>
<tr style="vertical-align:top;">
<td style="text-align:right; font-size:12px;"><b>Description:</b></td>
<td colspan="3"><textarea readonly="readonly" rows="2" style="width:600px;">$self->{description}</textarea></td></tr>
<tr style="vertical-align:top;">
<td style="text-align:right; font-size:12px;"><b>Sequence:<br /><span style="font-size:9px; font-weight:normal;">$toolHR->{'xgdb-FASTA'}</span></b></td>
<td colspan="3" style="width:600px;"><textarea readonly="readonly" rows="4" style="width:600px;">$formated_seq</textarea><br />
<table align="right"><tr><td style="font-size:9px;">$toolHR->{'xgdb-BLAST'}</td></tr></table>
<table align="right"><tr><td style="font-size:9px;">$toolHR->{'allxgdb-BLAST'}</td></tr></table>
</td>
</tr>
<tr style="vertical-align:top;">
<td style="text-align:right; font-size:12px;"><b>Alignment:</b></td>
<td colspan="3" style="text-align:left;">$genomic_source
<textarea readonly="readonly" rows="4" style="width:600px;">( $recordHR->{pgs} )</textarea><br />

</td>
</tr>
<tr>
<td>
</td>
<td>
$toolHR->{'xgdb-REGION'}
</td>
<td colspan="4" style='text-align:left; padding-left:5px;'>
	<table align="right">
	<tr>
	<td style="font-size:9px;">
	$toolHR->{'xgdb-GSQ'}
	</td>
	</tr>
	</table>
</td>
</tr>
</table>
END_OF_INFO

}

sub _STANDARD_EXTERNAL_URLS {
  my $self = shift;
  my ( $argHR, $recordHR ) = @_;

  my $ncbiLink = 'http://www.ncbi.nlm.nih.gov:80/entrez/query.fcgi?cmd=Retrieve&db=nucleotide&dopt=GenBank&list_uids=';

  return { "NCBI" => a( { href => "${ncbiLink}" . $self->{gi}, title => "Show GenBank Record"  }, "\@ GenBank" ) };
}

sub _STANDARD_TOOL_URLS {
  my $self = shift;
  my ( $argHR, $recordHR ) = @_;

  my $genomicSRC = ( exists( $argHR->{gsegUID} ) ) ? $self->{gsegSRC} : "GENOME";    ### KLUDGE use resid for genomic source ie BAC in future
  my $region_link = $self->getRegionLink( $argHR, $recordHR );
  my ( $gseg_l, $gseg_r ) = $recordHR->{pgs} =~ /^(\d+).*?(\d+)$/;
  return {
           "xgdb-FASTA" => a( { href => "${CGIPATH}returnFASTA.pl?db=" . $self->{blast_db} . "&dbid=" . $self->{db_id} . "&hits=" . $self->{gi} . ":0:0", title => "Show FASTA Sequence"  }, "Retrieve FASTA" ),
           "xgdb-GSQ"   =>
             a( { href => "${CGIPATH}getGSQ.pl?gsegSRC=" . $genomicSRC . "&dbid=" . $self->{db_id} . "&resid=" . $self->{resid} . "&pgs_uid=" . $argHR->{selectedRECORD}->{uid}, title => "Show GeneSeqer Alignment"  }, "GeneSeqer Alignment <a title='Key to the GSQ Output File' class='image-button help_link' id='GSQoutput:600:620'>Key to Scores</a>" ),
           "xgdb-BLAST"         => a( { href => "${CGIPATH}blastGDB.pl?db=" . $self->{blast_db} . "&dbid=" . $self->{db_id} . "&hits=" . $self->{gi} . ":0:0",         title => "Blast against ${SITENAMEshort}"      }, "BLAST \@ ${SITENAMEshort}" ),
           "allxgdb-BLAST"         => a( { href => "${CGIPATH}blastAllGDB.pl?db=" . $self->{blast_db} . "&dbid=" . $self->{db_id} . "&geneId=" . $self->{gi} ,         title => "Blast against All GDB"      }, "BLAST \@ All GDB" ),
           "xgdb-BLAST-Protein" => a( { href => "${CGIPATH}blastGDB.pl?db=" . $self->{blast_db} . "&name=" . $self->{gi} . "&program=blastp" . "&seq=" . $self->{seq}, title => "Blast against ${SITENAMEshort}"      }, "BLAST \@ ${SITENAMEshort}" ),
	"allxgdb-BLAST-Protein" => a( { href => "${CGIPATH}blastAllGDB.pl?db=" . $self->{blast_db} . "&name=" . $self->{gi} . "&program=blastp" . "&seq=" . $self->{seq}, title => "Blast against All GDB"      }, "BLAST \@ All GDB" ),
           "xgdb-REGION"        => a( { href => $region_link,                                                                                                          title => "Show in Genomic Context", class=>"xgdb_button colorB4 largerfont",             }, "View in Genome Browser" ),
           "xgdb-GTH"           => a(
                            {
				target =>'_blank', 
                              href        => "/cgi-bin/GenomeThreader/gth.cgi?DNAid=" . $argHR->{gseg_gi} . "&DNAstart=" . $gseg_l . "&DNAend=" . $gseg_r . "&PROTEINid=" . $recordHR->{gi} . "&PROTEINseq=" . $self->{seq},
                              title => "Show in Genomic Threader Alignment"
                            },
                            "GenomeThreader <a title='Key to the GTH Output File' class='image-button help_link' id='GTHoutput:600:680'>Key to Scores</a>"
           )
  };
}

sub showEXTENDED_LOCI_TABLE {
  my $self = shift;
  my ( $argHR, $gCONTEXT ) = @_;

  my $x = 0;
  my $gsrc = ( defined($gCONTEXT) ) ? $gCONTEXT : "chr";
  $gCONTEXT = "CHR" if ( !defined($gCONTEXT) );
  @rows = (th({-align=>'center',-style=>"vertical-align:middle;"},['Entry',($gsrc ne 'chr')?"gi":"Chr",'Strand','Left','Right','Sim','Cov','Structure','Splice Site Distribution']));
  $gsrc = ( $gsrc eq 'BAC' ) ? "gseg" : lc($gsrc);    #### kludge for now

  if ( ( exists( $self->{"${gsrc}LOCI_href"} ) ) && ( keys %{ $self->{"${gsrc}LOCI_href"} } ) ) {
    foreach $recordHR ( sort _by_CCLR values %{ $self->{"${gsrc}LOCI_href"} } ) {
      $maxLENGTH = ( ( $recordHR->{r_pos} - $recordHR->{l_pos} ) > $maxLENGTH ) ? ( $recordHR->{r_pos} - $recordHR->{l_pos} ) : $maxLENGTH;
    }
    $scale  = int( $maxLENGTH / 275 ) + 1;
    $scale2 = int( ( length( $self->{seq} ) + 50 ) / 300 ) + 1;

    foreach $recordHR ( sort SequenceTrack::_by_CCLR values %{ $self->{"${gsrc}LOCI_href"} } ) {
      $x++;
      $record_link = $self->getRecordLink( $argHR, $recordHR, $gCONTEXT );
      $region_link = $self->getRegionLink( $argHR, $recordHR, $gCONTEXT );
      if ( $argHR->{selectedRECORD} == $recordHR ) {
        push(
              @rows,
              td(
                  { style => 'border:1px solid #545454; vertical-align:middle;' },
                  [ $x, a( { href => $region_link, style => "color:green;" }, exists( $recordHR->{chr} ) ? $recordHR->{chr} : $recordHR->{gseg_gi} ), @$recordHR{ 'g_o', 'l_pos', 'r_pos', 'sim', 'cov' }, $self->showSTR_TD( $recordHR, $scale ), $self->showSP_TD( $recordHR, $scale2 ) ]
              )
        );
      } else {
        push(
              @rows,
              td(
                  { style => 'background:#FFFFFF; vertical-align:middle;' },
                  [
                    a( { href => $record_link, style => "color:$self->{primaryColor};" }, $x ),
                    a( { href => $region_link, style => "color:green;" }, exists( $recordHR->{chr} ) ? $recordHR->{chr} : $recordHR->{gseg_gi} ),
                    @$recordHR{ 'g_o', 'l_pos', 'r_pos', 'sim', 'cov' },
                    $self->showSTR_TD( $recordHR, $scale ),
                    $self->showSP_TD( $recordHR, $scale2 )
                  ]
              )
        );
      }
    }
  }

  $gsrc = ( $gsrc eq 'chr' ) ? "Chromosomal" : uc($gCONTEXT);
  $clone_gsrc = ($gsrc eq 'BAC')?"BAC/Scaffold/Clone":$gsrc;
  return  ($#rows)?"<table id='loci_table'>\n" . caption("<img id='sequence_record_loci_help' title='Loci View Help' class='xgdb-help-button' src='/XGDB/images/help-icon.png' alt='?' /> $clone_gsrc Loci for $self->{trackname} : " . $self->{gi}) . Tr({-align=>'center',-valign=>'top'},\@rows) . "</table><br />" : '';

}

sub showSTR_TD {
  my $self = shift;
  my ( $recordHR, $scale ) = @_;

  my $stINFO = $self->structINFO( 'chrUID', $recordHR );
  my @pgs = @$stINFO[ 2 .. $#$stINFO ];
  if ( $pgs[0] > $pgs[$#pgs] ) {
    ## reverse strand PGS
    for ( my $y = 0 ; $y <= $#pgs ; $y++ ) {
      $pgs[$y] = ( $stINFO->[2] + $stINFO->[$#stINFO] ) - $pgs[$y];
    }
  }
  my $imgfn = "$self->{trackname}_$self->{db_id}_$stINFO->[0]sc${scale}.png";

  if ( !-e "${TMPDIR}${imgfn}" ) {
    my $Simg = new GeneView( 305, 21, $pgs[0], $pgs[$#pgs], 1, $scale );
    $Simg->setLabelOn(0);
    $Simg->addGene( $stINFO->[1], @pgs );
    $Simg->drawPNG("${TMPDIR}${imgfn}");
  }

  return img( { -name => "sc${stINFO->[0]}", -align => 'center', -src => $DIR . $imgfn, -width => 305, -height => 21, -border => 0 } );
}

sub showSP_TD {
  my $self = shift;
  my ( $recordHR, $scale ) = @_;

  my $stINFO = $self->structINFO( 'chrUID', $recordHR );
  my @pgs = @$stINFO[ 2 .. $#$stINFO ];
  if ( $pgs[0] > $pgs[$#pgs] ) {
    ## reverse strand PGS
    for ( my $y = 0 ; $y <= $#pgs ; $y++ ) {
      $pgs[$y] = ( $stINFO->[2] + $stINFO->[$#stINFO] ) - $pgs[$y];
    }
  }
  my $imgfn = "$self->{trackname}_$self->{db_id}_$stINFO->[0]sp${scale}.png";

  if ( !-e "${TMPDIR}${imgfn}" ) {
    my $Simg = new GeneView( 305, 21, $pgs[0], $pgs[$#pgs], 1, $scale );
    $Simg->setLabelOn(0);
    $Simg->showSplicePattern( $stINFO->[1], @pgs );
    $Simg->drawPNG("${TMPDIR}${imgfn}");
  }

  return img( { -name => "sc${stINFO->[0]}", -align => 'center', -src => $DIR . $imgfn, -width => 305, -height => 21, -border => 0 } );
}

sub getIMAP_TV {
  my $self = shift;
  my ( $argHR, $imapHR, $pgsstatHR, $exstatHR, $instatHR ) = @_;

  my $maphtml = "";
  my $script  = "";
  my $linkF   = "${CGIPATH}returnFASTA.pl?";
  my ( $resID, $uid, $coordAR, $x, $y );
  foreach $dso ( keys %$imapHR ) {
    ( $resID, $uid ) = $dso =~ /(\d+)_(\d+)/;
    my $linkGR = $self->getRecordLink( $argHR, { uid => $uid } );
    $coordAR = $imapHR->{$dso}[1];
    $y       = 0;
    for ( $x = 2 ; $x <= $#$coordAR ; $x += 2 ) {
      $y++;
      $maphtml .= "<area shape=\"rect\" coords='$coordAR->[$x],$coordAR->[0],$coordAR->[$x+1],$coordAR->[1]' href=\"#\" onclick=\"return !seqMenu('${resID}_$uid',event);\" onmouseover=\"mo(0,'${dso}',$y);\" onmouseout=\"mo(-1,'out',-1);\" />\n";
      if ( ( $x + 2 ) < $#$coordAR ) {    ## make intron area
        $maphtml .= "<area shape=\"rect\" coords='$coordAR->[$x+1],$coordAR->[0],$coordAR->[$x+2],$coordAR->[1]' href=\"#\" onclick=\"return !seqMenu('${resID}_$uid',event);\" onmouseover=\"mo(1,'${dso}',$y);\" onmouseout=\"mo(-1,'out',-1);\" />\n";
      }
    }

    $script .=
        "structXPosL['${resID}_$uid'] = "
      . ( $coordAR->[2] ) . ";\n"
      . "structWid['${resID}_$uid'] = "
      . abs( $coordAR->[2] - $coordAR->[$#$coordAR] ) . ";\n"
      . "structYPos['${resID}_$uid'] = "
      . ( ( $coordAR->[0] ) ) . ";\n"
      . "smAddMenu('${resID}_$uid','$uid',1);\n"
      . "smAddRow('${resID}_$uid','FASTA','${linkF}resid=$resID&chrUID=$uid'); \n"
      . "smAddRow('${resID}_$uid','Get Record','${linkGR}');\n";

  }
  $script = "<script>\n$script<\/script>\n";
  return $script . $maphtml;
}

sub getIMAP_UCA {
  my $self = shift;
  my ( $argHR, $imapHR, $pgsstatHR, $exstatHR, $instatHR ) = @_;
  my $direction = 0;
  my $maphtml = "";
  my ( $resID, $uid, $coordAR, $x, $y );
  foreach $dso ( keys %$imapHR ) {
    ( $resID, $uid ) = $dso =~ /(\d+)_(\d+)/;
    $coordAR = $imapHR->{$dso}[1];
    $y       = 0;
    my @fullstruct = ();
    for ( $x = 0 ; $x <= $#$coordAR ; $x += 2 ) {
      if ( !exists( $exstatHR->{ $dso . "_" . $y } ) ) {
        $y++;
        next;
      }
# VB We'll need the exonstr just as defined shortly ...
# jfd added direction variable to pass to javascript within the map links
      $exonstr = $exstatHR->{ $dso . "_" . $y }[1] . "  " . $exstatHR->{ $dso . "_" . $y }[2];
      if ($exstatHR->{ $dso . "_" . $y}[1] > $exstatHR->{$dso . "_" . $y}[2] ) {
          $direction = 1;
      } else {
        if ($exstatHR->{ $dso . "_" . $y}[1] > $exstatHR->{$dso .	"_" . $y}[2] ) {
           $direction = 0;
        }
      }
      $exonpair = min( $exstatHR->{ $dso . "_" . $y }[1], $exstatHR->{ $dso . "_" . $y }[2] ) . "," . max( $exstatHR->{ $dso . "_" . $y }[1], $exstatHR->{ $dso . "_" . $y }[2] );

# VB Here we check that the exon table derived exonstr is also in the pgs string; only then do we link the corresponding exon glyph in the plot.
#
      if (@{$pgsstatHR->{ $dso  }}[7] =~ $exonstr) {
        $maphtml .= "<area shape=\"rect\" coords=\"$coordAR->[$x],$coordAR->[0],$coordAR->[$x+1],$coordAR->[1]\" href=\"javascript:SelectExonGlyph($exonpair);\" onclick=\"javascript:isShift(event,$exonpair, $direction);\" 
/>\n";
        $fullstruct[ ++$#fullstruct ] = $exstatHR->{ $dso . "_" . $y }[1] . ".." . $exstatHR->{ $dso . "_" . $y }[2];
      }
      else {
        $x -= 2;
      }
      $y++;
    }
    $labelAR = $imapHR->{$dso}[0];

    $maphtml .= "<area shape=\"rect\" coords=\"$labelAR->[0],$labelAR->[1],$labelAR->[2],$labelAR->[3]\" href=\"javascript:SelectID('" . join( ",", @fullstruct ) . "');\" onclick=\"javascript:isShiftID(event,'" . join( ",", @fullstruct) . "', $direction);\" />\n";
  }
  return $maphtml;
}

sub _addPGS2VIEW {
  my $self = shift;
  my ( $recordHR, $view, $startY ) = @_;

  my $stINFO = $self->structINFO( 'pgs', $recordHR );
  $stINFO->[1]{startHeight} = $startY if ( defined($startY) );
  return $view->addGene( @$stINFO[ 1 .. $#$stINFO ] );
}

sub getTRACKCELL {
  my $self = shift;
  my ( $argHR, $imgfn ) = @_;
  my ( $html, $color, $name, $tcNameMenuHTML, $op1classes, $op2classes );

  $name  = $self->{trackname};
  $color = $self->{primaryColor};
  $html  = '&nbsp;';

  $op1classes = $op2classes = 'cth-action xgdb-track-option';

  if(exists($argHR->{trackPREFS}) && exists($argHR->{trackPREFS}->[$self->{resid}]) && 
	exists($argHR->{trackPREFS}->[$self->{resid}]->{selectedImageOption}) && ($argHR->{trackPREFS}->[$self->{resid}]->{selectedImageOption} eq 'op2')){
    $op2classes = 'cth-action xgdb-track-option current';
  }else{
    $op1classes = 'cth-action xgdb-track-option current';
  }

  $tcNameMenuHTML = <<END_OF_CTRL;
<ul class='cth-name-menu sf-menu'>
  <li class='cth-name'>$name<ul>
    <li>Track Options<ul>
      <li id='op1' class='$op1classes'>Show All</li>
      <li id='op2' class='$op2classes'>Cognate Only</li>
    </ul></li>
  </ul></li>
</ul>

END_OF_CTRL

  return ( $html, $color, $tcNameMenuHTML );
}

sub drawREGION {
  my $self = shift;
  my ( $argHR, $img_paramHR, $imgfn ) = @_;
  my ( $link, $imgW, $imgH, $stINFO, $defL, $imgHTML, $initIMG );
  my ( $view_IM,  $view,    $puid );
  my ( $view2_IM, $view2,   $imgfn2 );
  my ( $recAR,    $labelAR, $PrecAR, $PlabelAR, $rec2AR, $label2AR, %UIDused );

  $imgW    = exists( $argHR->{imgW} )       ? $argHR->{imgW}       : 600;
  $imgH    = exists( $argHR->{imgH} )       ? $argHR->{imgH}       : 30;
  $initIMG = exists( $argHR->{initialIMG} ) ? $argHR->{initialIMG} : "";

  $view = new GeneView( $imgW, $imgH, $argHR->{l_pos}, $argHR->{r_pos}, 1 );
  $view->setLabelOn(1);
  $view->setFontSize( $argHR->{'fontSize'} ) if ( exists( $argHR->{'fontSize'} ) );
  $view_IM = "<map name=\"$self->{trackname}_IM\">\n";

  ## view2 is for the cognate only display
  $imgfn2 = "cognate_" . $imgfn;
  $view2 = new GeneView( $imgW, $imgH, $argHR->{l_pos}, $argHR->{r_pos}, 1 );
  $view2->setLabelOn(1);
  $view2->setFontSize( $argHR->{'fontSize'} ) if ( exists( $argHR->{'fontSize'} ) );
  $view2_IM = "<map name=\"cognate_$self->{trackname}_IM\">\n";

  $prevUID  = -1;
  $prevUID2 = -1;
  %UIDused  = ();
print STDERR "[SequenceTrack::drawREGION] WARNING!! $self->{trackname} ($argHR->{gseg_gi} $argHR->{chr} : $argHR->{l_pos} .. $argHR->{r_pos}) >> " . scalar(values %{ $self->{pgsREGION_href} }) . " features to draw \n" if(scalar(values %{ $self->{pgsREGION_href} }) > 200);
  foreach $recordHR ( sort _by_ClonePairLR values %{ $self->{pgsREGION_href} } ) {
    next if ( exists( $UIDused{ $recordHR->{uid} } ) );

    $UIDused{ $recordHR->{uid} } = 1;
    $defL = CGI::unescapeHTML( CGI::unescape( $recordHR->{description} ) );
    $defL =~ s/\'/\\\'/g;
    $defL =~ s/\"/\\\'/g;
    $defL =~ s/\r//g;       ## Get rid of any pesky carriage returns
    $defL =~ s/\n/\\n/g;    ## Escape the newline so that HTML works

    $link = $self->getRecordLink( $argHR, $recordHR );
    ( $labelAR, $recAR ) = $self->_addPGS2VIEW( $recordHR, $view );
    $view_IM .= "<area shape=\"rect\" coords='" . join( ',', @$recAR[ 2, 0, $#$recAR, 1 ] ) . "' href=\"${link}\"  onmouseover=\"showDef('$defL');\" onmouseout=\"hideDef();\">\n";

    if ( $recordHR->{iscognate} eq 'True' ) {
      ( $label2AR, $rec2AR ) = $self->_addPGS2VIEW( $recordHR, $view2 );
      $view2_IM .= "<area shape=\"rect\" coords='" . join( ',', @$rec2AR[ 2, 0, $#$rec2AR, 1 ] ) . "' href=\"${link}\"  onmouseover=\"showDef('$defL');\" onmouseout=\"hideDef();\">\n";
    }

    if ( exists( $recordHR->{pairuid} ) && ( $puid = ( $recordHR->{pairuid} =~ /:(\d+)$/ ) ? $1 : $recordHR->{pairuid} ) ) {
      if ( exists( $self->{pgsREGION_href}->{$puid} ) ) {
        ## Deal with the clone paired EST now as opposed to later ##
        $UIDused{$puid} = 1;
        $defL = $self->{pgsREGION_href}->{$puid}->{description};
        $defL =~ s/\'/\\\'/g;
        $defL =~ s/\"/\\\'/g;
        $defL =~ s/\r//g;       ## Get rid of any pesky carriage returns
        $defL =~ s/\n/\\n/g;    ## Escape the newline so that HTML works

        $link = $self->getRecordLink( $argHR, $self->{pgsREGION_href}->{$puid} );
        ( $PlabelAR, $PrecAR ) = $self->_addPGS2VIEW( $self->{pgsREGION_href}->{$puid}, $view, $recAR->[0] );
        $view_IM .= "<area shape=\"rect\" coords='" . join( ',', @$PrecAR[ 2, 0, $#$PrecAR, 1 ] ) . "' href=\"${link}\"  onmouseover=\"showDef('$defL');\" onmouseout=\"hideDef();\">\n";
        $view->drawPair( Locus::min( Locus::min( $PrecAR->[2], $recAR->[2] ), Locus::min( $PrecAR->[$#$PrecAR], $recAR->[$#$recAR] ) ),
                         Locus::min( $PrecAR->[0], $recAR->[0] ),
                         Locus::max( Locus::max( $PrecAR->[2], $recAR->[2] ), Locus::max( $PrecAR->[$#$PrecAR], $recAR->[$#$recAR] ) ),
                         Locus::max( $PrecAR->[1], $recAR->[1] ), 'green' );

        if ( $recordHR->{iscognate} eq 'True' ) {
          ( $PlabelAR, $PrecAR ) = $self->_addPGS2VIEW( $self->{pgsREGION_href}->{$puid}, $view2, $rec2AR->[0] );
          $view2_IM .= "<area shape=\"rect\" coords='" . join( ',', @$PrecAR[ 2, 0, $#$PrecAR, 1 ] ) . "' href=\"${link}${puid}\"  onmouseover=\"showDef('$defL');\" onmouseout=\"hideDef();\">\n";
          $view2->drawPair( Locus::min( Locus::min( $PrecAR->[2], $rec2AR->[2] ), Locus::min( $PrecAR->[$#$PrecAR], $rec2AR->[$#$rec2AR] ) ),
                            Locus::min( $PrecAR->[0], $rec2AR->[0] ),
                            Locus::max( Locus::max( $PrecAR->[2], $rec2AR->[2] ), Locus::max( $PrecAR->[$#$PrecAR], $rec2AR->[$#$rec2AR] ) ),
                            Locus::max( $PrecAR->[1], $rec2AR->[1] ), 'green' );
        }
      }
    }

  }

  $view_IM  .= "</map>\n";
  $view2_IM .= "</map>\n";

  $imgHTML = img(
                  {
		    id     => 'op1',
                    src    => "${DIR}${imgfn}",
                    usemap => "#$self->{trackname}_IM",
                    border => 0,
		    class  => (exists($argHR->{trackPREFS}) && 
				exists($argHR->{trackPREFS}->[$self->{resid}]) &&
        			exists($argHR->{trackPREFS}->[$self->{resid}]->{selectedImageOption}) && 
				($argHR->{trackPREFS}->[$self->{resid}]->{selectedImageOption} eq 'op2')) ?
					"xgdb-track-image-option":"xgdb-track-image-current",
                    %$img_paramHR
                  }
  		) . "\n" . img(
		  {
		    id     => 'op2',
                    src    => "${DIR}cognate_${imgfn}",
                    usemap => "#cognate_" . $self->{trackname} . "_IM",
                    border => 0,
		    class  => (exists($argHR->{trackPREFS}) &&
                                exists($argHR->{trackPREFS}->[$self->{resid}]) &&
                                exists($argHR->{trackPREFS}->[$self->{resid}]->{selectedImageOption}) &&
                                ($argHR->{trackPREFS}->[$self->{resid}]->{selectedImageOption} eq 'op2')) ?
                                        "xgdb-track-image-current":"xgdb-track-image-option",
                    %$img_paramHR
                  }
                );

  $view->drawPNG( $TMPDIR . $imgfn );
  $view2->drawPNG( $TMPDIR . $imgfn2 );

  return ( $view_IM . $view2_IM . $imgHTML, "${DIR}${imgfn}", "$self->{trackname}_IM" );
}

sub drawCombinedImage {
  my $self = shift;
  my ( $view, $startY ) = @_;
  my ( $puid, $recordHR, $stINFO, $bottom, $labelAR, $recAR, $PlabelAR, $PrecAR, %imap, %UIDused );

  $prevUID = -1;
  $bottom  = 0;
  %UIDused = ();
  foreach $recordHR ( sort _by_ClonePairLR values %{ $self->{pgsREGION_href} } ) {
    next if ( exists( $recordHR->{pairuid} ) && ( exists( $UIDused{ $recordHR->{uid} } ) ) );
    $UIDused{ $recordHR->{uid} } = 1;
    $stINFO = $self->structINFO( 'pgs', $recordHR );
    $stINFO->[1]{startHeight} = $startY;
    ( $labelAR, $recAR ) = $view->addGene( @$stINFO[ 1 .. $#$stINFO ] );
    $imap{ $self->{resid} . "_" . $recordHR->{uid} } = [ $labelAR, $recAR ];
    if ( exists( $recordHR->{pairuid} ) && ( ($puid) = $recordHR->{pairuid} =~ /:(\d+)$/ ) ) {
      if ( exists( $self->{pgsREGION_href}->{$puid} ) ) {
        $UIDused{$puid} = 1;
        ( $PlabelAR, $PrecAR ) = $self->_addPGS2VIEW( $self->{pgsREGION_href}->{$puid}, $view, $recAR->[0] );
        $imap{ $self->{resid} . "_" . $puid } = [ $PlabelAR, $PrecAR ];
        $view->drawPair( Locus::min( Locus::min( $PrecAR->[2], $recAR->[2] ), Locus::min( $PrecAR->[$#$PrecAR], $recAR->[$#$recAR] ) ),
                         Locus::min( $PrecAR->[0], $recAR->[0] ),
                         Locus::max( Locus::max( $PrecAR->[2], $recAR->[2] ), Locus::max( $PrecAR->[$#$PrecAR], $recAR->[$#$recAR] ) ),
                         Locus::max( $PrecAR->[1], $recAR->[1] ), 'green' );
        $bottom = Locus::max( $PrecAR->[1], $recAR->[1] ) if ( Locus::max( $PrecAR->[1], $recAR->[1] ) > $bottom );
      } else {
        $bottom = $recAR->[1] if ( $recAR->[1] > $bottom );
      }
    } else {
      $bottom = $recAR->[1] if ( $recAR->[1] > $bottom );
    }
  }
  return ( \%imap, $bottom );
}

sub structINFO {
  my $self = shift;
  my ( $type, $record ) = @_;
  my ( $c, $c_a, $c_s, $c_d, $label, @pgs );

  return undef if ( !( defined($record) && exists( $record->{uid} ) ) );

  $c = $c_a = $c_s = $c_d = ( ( $record->{iscognate} ne 'True' ) && ( exists( $self->{secondaryColor} ) ) ) ? $self->{secondaryColor} : ( exists( $self->{primaryColor} ) ) ? $self->{primaryColor} : 'red';

  if ( exists( $record->{type} ) ) {
    $c_a = $c_d = $self->{LblColor_3i} if ( $record->{type} eq 'T' );    ## 3' EST
    $c_s = $c_d = $self->{LblColor_5i} if ( $record->{type} eq 'F' );    ## 5' EST
  } elsif ( exists( $self->{type} ) ) {
    $c_a = $c_d = $self->{LblColor_3i} if ( $self->{type} eq 'T' );      ## 3' EST
    $c_s = $c_d = $self->{LblColor_5i} if ( $self->{type} eq 'F' );      ## 5' EST
  }

  $label = ( exists( $record->{gi} ) ) ? $record->{gi} : $self->{gi};

  @pgs = split( /[^\d]+/, $record->{pgs} );

  my $glyphHR = {label => $label, color => $c, arrowColor => $c_a, startColor => $c_s, dotColor => $c_d};

  $self->_setFadeStruct($glyphHR,$record,\@pgs);

  return [ "${type}$record->{uid}", $glyphHR, @pgs ];
}

sub _setFadeStruct {
  my $self = shift;
  my ($glyphHR, $recordHR, $pgsAR) = @_;
  
  return undef if(!(exists($recordHR->{seq}) && exists($recordHR->{pgs_lpos}) && exists($recordHR->{pgs_rpos}))); 
 
  my $fadeAt = exists($self->{alignmentFadesAt})?$self->{alignmentFadesAt}:20;
  if(min($recordHR->{pgs_lpos},$recordHR->{pgs_rpos}) >= $fadeAt){
    $glyphHR->{fadeStart} = (exists ($self->{fadeStart_primaryColor}))?$self->{fadeStart_primaryColor}
                                :(exists($self->{fade_primaryColor}))?$self->{fade_primaryColor}
                                :(exists($self->{fadeColor}))?$self->{fadeColor}:'#DCDCDC';
  }
  if(max($recordHR->{pgs_lpos},$recordHR->{pgs_rpos}) <= (length($recordHR->{seq}) - $fadeAt)){
    $glyphHR->{fadeEnd} = (exists ($self->{fadeEnd_primaryColor}))?$self->{fadeEnd_primaryColor}
                                :(exists($self->{fade_primaryColor}))?$self->{fade_primaryColor}
                                :(exists($self->{fadeColor}))?$self->{fadeColor}:'#DCDCDC';
  }
  $glyphHR->{fadeBoth}=1 if(exists($glyphHR->{fadeStart}) && exists($glyphHR->{fadeEnd}));

  return $glyphHR;
}

sub getLOCI {
  my $self = shift;
  my ($argHR) = @_;
  my ( $recordHR, $hitlist, $link );

  exists( $argHR->{selectedRECORD} ) || ( @$argHR{ 'recordTYPE', 'selectedRECORD' } = $self->selectRECORD($argHR) );

  $hitlist = [];
  if ( ( exists( $self->{chrLOCI_href} ) ) && ( keys %{ $self->{chrLOCI_href} } ) ) {
    foreach $recordHR ( values %{ $self->{chrLOCI_href} } ) {
      $link = $self->getRegionLink( $argHR, $recordHR, "CHR" );
      push( @$hitlist, [ $recordHR->{chr}, $recordHR->{l_pos}, $self->{primaryColor}, $link ] );
    }
  }
  ## add gseg entries with no chr positions??

  return $hitlist;
}

sub getMULTILOCI {
  my $self = shift;
  my ($argHR) = @_;
  my ( $recordHR, $hitlist, $link );

  $hitlist = exists( $argHR->{LOCIhitlist} ) ? $argHR->{LOCIhitlist} : [];
  if ( ( exists( $self->{chrMULTILOCI_href} ) ) && ( keys %{ $self->{chrMULTILOCI_href} } ) ) {
    foreach $recordHR ( values %{ $self->{chrMULTILOCI_href} } ) {
      $link = $self->getRegionLink( $argHR, $recordHR, "CHR" );
      push( @$hitlist, [ $recordHR->{chr}, $recordHR->{l_pos}, $self->{primaryColor}, $link ] );
    }
  }
  ## add gseg entries with no chr positions??

  return $hitlist;
}

sub showMULTILOCI_TABLE {
  my $self = shift;
  my ($argHR) = @_;
  my ( $recordHR, $x, $y, $z, $record_link, $region_link, $currentGI, @MLrows, @rows );

  $x = 0;
  $y = 1;
  $z = 0;
  if ( ( exists( $self->{chrMULTILOCI_href} ) ) && ( keys %{ $self->{chrMULTILOCI_href} } ) ) {
    @MLrows = ( th( { style => "text-align:center; border:0;" }, [ 'Entry', 'Chr', 'Strand', 'Left', 'Right', 'Sim', 'Cov', 'Cognate?' ] ) );
    foreach $recordHR ( sort _by_ICCLR values %{ $self->{chrMULTILOCI_href} } ) {
      $record_link = $self->getRecordLink( $argHR, $recordHR, "CHR" );
      $region_link = $self->getRegionLink( $argHR, $recordHR, "CHR" );
      if ( $recordHR->{gi} ne $currentGI ) {
        push( @MLrows, td( { colspan => 8, style => "background:#DCDCDC; color:#808000; text-align:left; border:0;" }, [ $self->{trackname} . ": gi-" . $recordHR->{gi} ] ) );
        $y = 1;
        $x++;
      }
      push( @MLrows, td( { style => "text-align:center;" }, [ a( { href => $record_link, style => "color:$self->{primaryColor};" }, "$x-$y" ), a( { href => $region_link, style => "color:green;" }, $recordHR->{chr} ), @$recordHR{ 'e_o', 'l_pos', 'r_pos', 'sim', 'cov', 'iscognate' } ] ) );
      $y++;
      $z++;
      $currentGI = $recordHR->{gi};
    }
    ## Still need to deal with gseg entries
  }

  unshift( @MLrows, td( { colspan => 8, style => "background:$self->{primaryColor}; color:#FFFFFF; text-align:left; border:0;" }, [ strong( $self->{trackname} . " ($x sequences / $z Loci)" ) ] ) );

  return table( { width => 500, border => 1, valign => 'top' }, Tr( \@MLrows ) ) . "\n";
}

sub _parse_DAS_FEATURES {
  my ( $self, $reqHR, $pgsHRAR, $segFeatHR ) = @_;

  #
  # Expected Data Objects
  # $pgsHR = {gi,exon_num,exon_start,exon_stop,score,pgs_uid }
  # $pgsHR = {gi,intron_num,intron_start,intron_stop,donor_score,acceptor_score,pgs_uid}
  #
  # segFeatHR = {id,start,stop,xID,xStart,xStop,version,label}
  #

  my $featLIST = [];
  $self->checkDASTYPES( $reqHR->{'type'} ) if ( exists( $reqHR->{'type'} ) );
  my $coordTrans = $segFeatHR->{start} - $segFeatHR->{xStart};

  foreach my $pgsHR (@$pgsHRAR) {
    if ( ( exists( $self->{'das_supported_types'}->{'expressed_sequence_match'} ) && $self->{'das_supported_types'}->{'expressed_sequence_match'}->{typelist} ) && exists( $pgsHR->{'exon_start'} ) ) {
      $featLIST->[ scalar(@$featLIST) ] = {
        'id' => join( ":", ( 'expressed_sequence_match', $self->{db_id}, $self->{resid}, $pgsHR->{'gi'}, $pgsHR->{'exon_num'} ) ),
        'type_id'      => 'expressed_sequence_match',
        'start' => $coordTrans + min( $pgsHR->{'exon_start'}, $pgsHR->{'exon_stop'} ),
        'end'   => $coordTrans + max( $pgsHR->{'exon_start'}, $pgsHR->{'exon_stop'} ),
        'score' => $pgsHR->{'score'},
        'orientation' => ( $pgsHR->{'exon_start'} < $pgsHR->{'exon_stop'} ) ? '+' : '-',
        'target_id' => $pgsHR->{'gi'},
        'target_start'    => $pgsHR->{'target_start'},
        'target_stop'     => $pgsHR->{'target_stop'},
        'group_id'        => $pgsHR->{'gi'},
        'group_label'     => $pgsHR->{'gi'},
        'method_id'    => exists( $self->{'das_supported_types'}->{'expressed_sequence_match'}->{'method'} ) ? $self->{'das_supported_types'}->{'expressed_sequence_match'}->{'method'}:
         			exists( $self->{'das_defaults'}->{'method'} ) ? $self->{'das_defaults'}->{'method'}:'geneseqer_spliced_alignment',
        'method_label'    => exists( $self->{'das_supported_types'}->{'expressed_sequence_match'}->{'method_label'} ) ? $self->{'das_supported_types'}->{'expressed_sequence_match'}->{'method_label'}:
                                exists( $self->{'das_defaults'}->{'method_label'} ) ? $self->{'das_defaults'}->{'method_label'}:'GeneSeqer spliced alignment',
        'group_type'      => exists( $self->{'das_supported_types'}->{'expressed_sequence_match'}->{'group_type'} ) ? $self->{'das_supported_types'}->{'expressed_sequence_match'}->{'group_type'}:
                                exists( $self->{'das_defaults'}->{'group_type'} ) ? $self->{'das_defaults'}->{'group_type'}:'expressed_sequence_alignment',
        'group_link_href' => $rootPATH . $self->getRecordLink( {}, { 'uid' => $pgsHR->{'pgs_uid'} }, ( exists( $self->{'chrVIEWABLE'} ) && $self->{'chrVIEWABLE'} ) ? 'CHR' : 'BAC' )                                              ## wow what a kludge
      };
      $featLIST->[ $#$featLIST ]->{'note'} = "Feature translated from $segFeatHR->{xID} using ($segFeatHR->{id}:$segFeatHR->{start},$segFeatHR->{stop} = $segFeatHR->{xID}:$segFeatHR->{xStart},$segFeatHR->{xStop})" if($segFeatHR->{start} != $segFeatHR->{xStart});
      $featLIST->[$#$featLIST]->{'type_category'} = &{$self->{'MOD_DAS_SET_FeatureTypeCategory'}}($pgsHR) if(exists($self->{'MOD_DAS_SET_FeatureTypeCategory'}));
      $featLIST->[$#$featLIST]->{'group_label'} = &{$self->{MOD_DAS_SET_GroupLabel}}($pgsHR,$featLIST->[$#$featLIST]) if(exists($self->{MOD_DAS_SET_GroupLabel}));

    } elsif ( ( exists( $pgsHR->{'intron_start'} ) ) ) {
      if ( exists( $self->{'das_supported_types'}->{'five_prime_splice_site'} ) && $self->{'das_supported_types'}->{'five_prime_splice_site'}->{typelist} ) {
        $featLIST->[ scalar(@$featLIST) ] = {
          'id' => join( ":", ( 'five_prime_splice_site', $self->{db_id}, $self->{resid}, $pgsHR->{'gi'}, $pgsHR->{'intron_num'} ) ),
          'type_id'         => 'five_prime_splice_site',
          'start'           => $coordTrans + $pgsHR->{'intron_start'},
          'end'             => $coordTrans + $pgsHR->{'intron_start'},
          'score'           => $pgsHR->{'donor_score'},
          'group_id'        => $pgsHR->{'gi'},
          'group_label'     => $pgsHR->{'gi'},
        'method_id'    => exists( $self->{'das_supported_types'}->{'five_prime_splice_site'}->{'method'} ) ? $self->{'das_supported_types'}->{'five_prime_splice_site'}->{'method'}:
         			exists( $self->{'das_defaults'}->{'method'} ) ? $self->{'das_defaults'}->{'method'}:'geneseqer_spliced_alignment',
        'method_label'    => exists( $self->{'das_supported_types'}->{'five_prime_splice_site'}->{'method_label'} ) ? $self->{'das_supported_types'}->{'five_prime_splice_site'}->{'method_label'}:
                                exists( $self->{'das_defaults'}->{'method_label'} ) ? $self->{'das_defaults'}->{'method_label'}:'GeneSeqer spliced alignment',
        'group_type'      => exists( $self->{'das_supported_types'}->{'five_prime_splice_site'}->{'group_type'} ) ? $self->{'das_supported_types'}->{'five_prime_splice_site'}->{'group_type'}:
                                exists( $self->{'das_defaults'}->{'group_type'} ) ? $self->{'das_defaults'}->{'group_type'}:'expressed_sequence_alignment',
          'group_link_href' => $rootPATH . $self->getRecordLink( {}, { 'uid' => $pgsHR->{'pgs_uid'} }, ( exists( $self->{'chrVIEWABLE'} ) && $self->{'chrVIEWABLE'} ) ? 'CHR' : 'BAC' )                                          ## wow what a kludge
        };
        $featLIST->[ $#$featLIST ]->{'note'} = "Feature translated from $segFeatHR->{xID} using ($segFeatHR->{id}:$segFeatHR->{start},$segFeatHR->{stop} = $segFeatHR->{xID}:$segFeatHR->{xStart},$segFeatHR->{xStop})" if($segFeatHR->{start} != $segFeatHR->{xStart});
	$featLIST->[$#$featLIST]->{'type_category'} = &{$self->{'MOD_DAS_SET_FeatureTypeCategory'}}($pgsHR) if(exists($self->{'MOD_DAS_SET_FeatureTypeCategory'}));
        $featLIST->[$#$featLIST]->{'group_label'} = &{$self->{MOD_DAS_SET_GroupLabel}}($pgsHR,$featLIST->[$#$featLIST]) if(exists($self->{MOD_DAS_SET_GroupLabel}));
      }
      if ( exists( $self->{'das_supported_types'}->{'three_prime_splice_site'} ) && $self->{'das_supported_types'}->{'three_prime_splice_site'}->{typelist} ) {
        $featLIST->[ scalar(@$featLIST) ] = {
          'id' => join( ":", ( 'three_prime_splice_site', $self->{db_id}, $self->{resid}, $pgsHR->{'gi'}, $pgsHR->{'intron_num'} ) ),
          'type_id'         => 'three_prime_splice_site',
          'start'           => $coordTrans + $pgsHR->{'intron_stop'},
          'end'             => $coordTrans + $pgsHR->{'intron_stop'},
          'score'           => $pgsHR->{'acceptor_score'},
          'group_id'        => $pgsHR->{'gi'},
          'group_label'     => $pgsHR->{'gi'},
        'method_id'    => exists( $self->{'das_supported_types'}->{'three_prime_splice_site'}->{'method'} ) ? $self->{'das_supported_types'}->{'three_prime_splice_site'}->{'method'}:
         			exists( $self->{'das_defaults'}->{'method'} ) ? $self->{'das_defaults'}->{'method'}:'geneseqer_spliced_alignment',
        'method_label'    => exists( $self->{'das_supported_types'}->{'three_prime_splice_site'}->{'method_label'} ) ? $self->{'das_supported_types'}->{'three_prime_splice_site'}->{'method_label'}:
                                exists( $self->{'das_defaults'}->{'method_label'} ) ? $self->{'das_defaults'}->{'method_label'}:'GeneSeqer spliced alignment',
        'group_type'      => exists( $self->{'das_supported_types'}->{'three_prime_splice_site'}->{'group_type'} ) ? $self->{'das_supported_types'}->{'three_prime_splice_site'}->{'group_type'}:
                                exists( $self->{'das_defaults'}->{'group_type'} ) ? $self->{'das_defaults'}->{'group_type'}:'expressed_sequence_alignment',
          'group_link_href' => $rootPATH . $self->getRecordLink( {}, { 'uid' => $pgsHR->{'pgs_uid'} }, ( exists( $self->{'chrVIEWABLE'} ) && $self->{'chrVIEWABLE'} ) ? 'CHR' : 'BAC' )                                            ## wow what a kludge
        };
        $featLIST->[ $#$featLIST ]->{'note'} = "Feature translated from $segFeatHR->{xID} using ($segFeatHR->{id}:$segFeatHR->{start},$segFeatHR->{stop} = $segFeatHR->{xID}:$segFeatHR->{xStart},$segFeatHR->{xStop})" if($segFeatHR->{start} != $segFeatHR->{xStart});
	$featLIST->[$#$featLIST]->{'type_category'} = &{$self->{'MOD_DAS_SET_FeatureTypeCategory'}}($pgsHR) if(exists($self->{'MOD_DAS_SET_FeatureTypeCategory'}));
        $featLIST->[$#$featLIST]->{'group_label'} = &{$self->{MOD_DAS_SET_GroupLabel}}($pgsHR,$featLIST->[$#$featLIST]) if(exists($self->{MOD_DAS_SET_GroupLabel}));
      }
    }
    
  }
  return ( scalar(@$featLIST) ) ? $featLIST : undef;
}

sub _by_ClonePairLR {
  my $a_clone;
  my $b_clone;
  ($a_clone) = $a->{pairuid} =~ /^([^:]+)/ if ( exists( $a->{pairuid} ) );
  ($b_clone) = $b->{pairuid} =~ /^([^:]+)/ if ( exists( $b->{pairuid} ) );
  return ( defined($b_clone) <=> defined($a_clone) || ( $a->{l_pos} <=> $b->{l_pos} ) || ( $b->{r_pos} <=> $a->{r_pos} ) );
}

sub _by_ICCLR {
  my $aCOG       = ( exists( $a->{iscognate} ) && defined( $a->{iscognate} ) ) ? $a->{iscognate} : "False";
  my $bCOG       = ( exists( $b->{iscognate} ) && defined( $b->{iscognate} ) ) ? $b->{iscognate} : "False";
  my $aGenomicID = ( exists( $a->{chr} )       && defined( $a->{chr} ) )       ? $a->{chr}       : ( exists( $a->{gseg_gi} ) && defined( $a->{gseg_gi} ) ) ? $a->{gseg_gi} : 0;
  my $bGenomicID = ( exists( $b->{chr} )       && defined( $b->{chr} ) )       ? $b->{chr}       : ( exists( $b->{gseg_gi} ) && defined( $b->{gseg_gi} ) ) ? $b->{gseg_gi} : 0;
  return ( ( $a->{gi} <=> $b->{gi} ) || ( $aCOG cmp $bCOG ) || ( $aGenomicID <=> $bGenomicID ) || ( $a->{l_pos} <=> $b->{l_pos} ) || ( $b->{r_pos} <=> $a->{r_pos} ) );
}

sub _by_CCLR {
  my $aCOG       = ( exists( $a->{iscognate} ) && defined( $a->{iscognate} ) ) ? $a->{iscognate} : "False";
  my $bCOG       = ( exists( $b->{iscognate} ) && defined( $b->{iscognate} ) ) ? $b->{iscognate} : "False";
  my $aGenomicID = ( exists( $a->{chr} )       && defined( $a->{chr} ) )       ? $a->{chr}       : ( exists( $a->{gseg_gi} ) && defined( $a->{gseg_gi} ) ) ? $a->{gseg_gi} : 0;
  my $bGenomicID = ( exists( $b->{chr} )       && defined( $b->{chr} ) )       ? $b->{chr}       : ( exists( $b->{gseg_gi} ) && defined( $b->{gseg_gi} ) ) ? $b->{gseg_gi} : 0;
  return ( ( $aCOG cmp $bCOG ) || ( $aGenomicID <=> $bGenomicID ) || ( $a->{l_pos} <=> $b->{l_pos} ) || ( $b->{r_pos} <=> $a->{r_pos} ) );
}

sub min { return ( $_[0] < $_[1] ) ? $_[0] : $_[1]; }

sub max { return ( $_[0] > $_[1] ) ? $_[0] : $_[1]; }

1;

