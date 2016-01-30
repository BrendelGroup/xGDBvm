package GSEG;
use base "GenomeSegmentTrack";

do 'SITEDEF.pl';

use DBI;
use CGI ":all";

sub _init{
  my $self = shift;

  $self->SUPER::_init(@_);

  $self->{sequenceTYPE}  = 'gDNA';

  $self->{db_table} = (exists($self->{db_table})) ? $self->{db_table} : 'gseg';
  $self->{trackname} = (exists($self->{trackname}))? $self->{trackname}: 'GSEG';

  my $DB_TABLE = $self->{db_table};


  if(exists($self->{chrVIEWABLE}) && $self->{chrVIEWABLE}){
    #$self->{SQL_BASE}        = qq{SELECT  t1.uid, t1.id as id, t1.acc, t1.clone, t1.version, t1.description, t1.seq,t2.G_O, t2.SCAF_lpos, t2.SCAF_rpos, t2.FRAG_lpos, t2.FRAG_rpos, t3.gi as gseg_gi FROM ${DB_TABLE} as t1 INNER JOIN chr_${DB_TABLE} as t2 ON (t1.uid = t2.FRAG_uid) INNER JOIN gseg as t3 ON (t3.uid = t2.SCAF_uid)};
    $self->{SQL_BASE}        = qq{SELECT  t1.uid, t1.id as id, t1.acc, t1.clone, t1.version, t1.description, t1.seq,t2.G_O, t2.SCAF_lpos, t2.SCAF_rpos, t2.FRAG_lpos, t2.FRAG_rpos, t2.SCAF_uid as gseg_gi FROM ${DB_TABLE} as t1 INNER JOIN chr_${DB_TABLE} as t2 ON (t1.uid = t2.FRAG_uid)};

    $self->{seqQUERY}         = qq{$self->{SQL_BASE} WHERE (?) IN (t1.id,t1.acc,t1.clone) };
    $self->{chrREGION_QUERY}  = qq{$self->{SQL_BASE} WHERE (t2.SCAF_uid = ?)&&(t2.SCAF_rpos > ?)&&(t2.SCAF_lpos < ?) };
    $self->{chrDESC_QUERY}    = qq{$self->{SQL_BASE} WHERE MATCH (t1.description) AGAINST ( ? IN BOOLEAN MODE) };
    $self->{chrUID_QUERY}     = qq{$self->{SQL_BASE} WHERE (FRAG_uid = ?)};
  }

  if((exists($self->{BACVIEWABLE}) && $self->{BACVIEWABLE}) || $self->{gsegSRC}){
    $self->{gsegSQL_BASE}    = qq{SELECT  t1.uid, t1.id as id, t1.acc, t1.clone, t1.version, t1.description, t1.seq,t2.G_O, t2.SCAF_lpos, t2.SCAF_rpos, t2.FRAG_lpos, t2.FRAG_rpos, t3.gi as gseg_gi FROM ${DB_TABLE} as t1 INNER JOIN gseg_${DB_TABLE} as t2 ON (t1.uid = t2.FRAG_uid) INNER JOIN gseg as t3 ON (t3.uid = t2.SCAF_uid) };

    $self->{gsegREGION_QUERY} = qq{$self->{gsegSQL_BASE} WHERE (t3.gi = ?)&&(SCAF_rpos > ?)&&(SCAF_lpos < ?) };
    $self->{gsegDESC_QUERY}   = qq{$self->{gsegSQL_BASE} WHERE MATCH (t1.description) AGAINST ( ? IN BOOLEAN MODE) };
    $self->{gsegQUERY}        = qq{$self->{gsegSQL_BASE} WHERE (?) IN (t1.id,t1.acc,t1.clone) };
    $self->{gsegUID_QUERY}    = qq{$self->{gsegSQL_BASE} WHERE (FRAG_uid = ?)};
  }

  $self->{MULTI_ID_QUERY} = sub {
    my ($BASE,$idlist) = @_;
    return $BASE . "WHERE (id IN ($idlist))||(acc IN ($idlist))||(clone IN ($idlist))";
  };

}

sub drawCombinedImage{
  my $self = shift;
  my ($view,$startY) = @_;
  my ($prevUID,$puid,$recordHR,$stINFO,$bottom,$recAR,%imap);

  $prevUID = -1; $bottom = 0;
  foreach $recordHR (sort _by_LR values %{$self->{pgsREGION_href}}){
    $stINFO = $self->structINFO('pgs',$recordHR);
    $stINFO->[1]{startHeight} = $startY;
    $view->{showGsegFlank} = ((exists($self->{hideFlankingRegionGlyph}) && ($self->{hideFlankingRegionGlyph})) || ($recordHR->{frag_rpos} > length($recordHR->{seq})))?0:1;
    ($labelAR,$recAR) = $view->addGseg(@$stINFO[1..$#$stINFO]);
    $imap{$self->{resid} . "_" . $recordHR->{uid}} = [$labelAR,$recAR];
    $bottom = $recAR->[1] if($recAR->[1] > $bottom);
  }
  return (\%imap,$bottom);
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
  $view_IM = "<map name=\"$self->{trackname}_IM\">\n";

  foreach $recordHR (sort _by_LR values %{$self->{pgsREGION_href}}){
    $stINFO = $self->structINFO('pgs',$recordHR);
    $defL   = $recordHR->{description};
    $defL =~ s/\'/\\\'/g;
    $defL =~ s/\"/\\\'/g;
    $defL =~ s/\r//g;  ## Get rid of any pesky carriage returns
    $defL =~ s/\n/\\n/g; ## Escape the newline so that HTML works

    $link = $self->getRecordLink($argHR,$recordHR);
    $view->{showGsegFlank} = ((exists($self->{hideFlankingRegionGlyph}) && ($self->{hideFlankingRegionGlyph})) || ($recordHR->{frag_rpos} > length($recordHR->{seq})))?0:1;
    ($labelAR,$recAR) = $view->addGseg(@$stINFO[1..$#$stINFO]);
    $view_IM .= "<area shape=\"rect\" coords='".join(',',@$recAR[2,0,$#$recAR,1])."' href=\"${link}\"  onmouseover=\"showDef('$defL');\" onmouseout=\"hideDef();\">\n";
  }
  $view_IM  .= "</map>\n";

  $imgHTML = img({src    => "${DIR}${initIMG}${imgfn}",
		  usemap => "#${initIMG}$self->{trackname}_IM",
		  border => 0,
		  %$img_paramHR});

  $view->drawPNG($TMPDIR.$imgfn);

  return ($view_IM.$imgHTML,"${DIR}${initIMG}${imgfn}","${initIMG}$self->{trackname}_IM");
}

sub draw_GSEG_RULER{
  my $self = shift;
  my ($argHR,$img_paramHR,$imgfn,$link) = @_;
  my ($imgW,$imgH,$stINFO,$defL,$imgHTML,$initIMG);
  my ($view_IM,$view);
  my ($view2_IM,$view2,$imgfn2);
  my ($labelAR,$recAR,$label2AR,$rec2AR);


  $imgW    = exists($argHR->{imgW})?$argHR->{imgW}:600;
  $imgH    = exists($argHR->{imgH})?$argHR->{imgH}:30;
  $initIMG = exists($argHR->{initialIMG})?$argHR->{initialIMG}:"";

  $view = new GeneView($imgW,$imgH,$argHR->{l_pos},$argHR->{r_pos},1);
  $view->setLabelOn(1);
  $view->setFontSize($argHR->{'fontSize'}) if(exists($argHR->{'fontSize'}));
  $view_IM = "<map name=\"$self->{trackname}_IM\">\n";

  $self->loadREGION($argHR) || return undef;

  foreach $recordHR (sort _by_CLR values %{$self->{pgsREGION_href}}){
    $link = defined($link)?$link : $self-> getRecordLink($argHR,$recordHR,'NOCONTEXT');
    $stINFO = ["$recordHR->{id}",
	       {label=>$recordHR->{clone},
                color=>$self->{primaryColor},
                leftColor=>$self->{primaryColor},
                rightColor=>$self->{primaryColor}
               },
	       0,
	       $self->min($recordHR->{olap_lstart},$recordHR->{olap_rstop}),
	       $self->max($recordHR->{olap_lstart},$recordHR->{olap_rstop}),
	       length($recordHR->{seq})
	      ];
    $defL   = $recordHR->{description};
    $defL =~ s/\'/\\\'/g;
    $defL =~ s/\"/\\\'/g;
    $defL =~ s/\r//g;  ## Get rid of any pesky carriage returns
    $defL =~ s/\n/\\n/g; ## Escape the newline so that HTML works

    $view->{showGsegFlank} = ((exists($self->{hideFlankingRegionGlyph}) && ($self->{hideFlankingRegionGlyph})) || ($recordHR->{frag_rpos} > length($recordHR->{seq})))?0:1;
    ($labelAR,$recAR) = $view->addGseg(@$stINFO[1..$#$stINFO]);
    $view_IM .= "<area shape=\"rect\" coords='".join(',',@$recAR[2,0,$#$recAR,1])."' href=\"${link}\"  onmouseover=\"showDef('$defL');\" onmouseout=\"hideDef();\">\n";
  }
  $view_IM  .= "</map>\n";

  $imgHTML = img({src    => "${DIR}${initIMG}${imgfn}",
		  usemap => "#${initIMG}$self->{trackname}_IM",
		  border => 0,
		  %$img_paramHR});

  $view->drawPNG($TMPDIR.$imgfn);

  return ($view_IM.$imgHTML,"${DIR}${initIMG}${imgfn}","${initIMG}$self->{trackname}_IM");
}

sub structINFO{
  my $self = shift;
  my ($type,$record) = @_;
  my ($c,$c_a,$c_s,$c_d,$label,@pgs);

  return undef if(!(defined($record) && exists($record->{uid})));

#### What happens for gseg without SCAF coords???

  $c = $c_l = $c_r = $self->{primaryColor};

  $label = (exists($record->{clone})&&($record->{clone} ne ''))?$record->{clone}:(exists($record->{id}))?$record->{id}:$self->{id};

  if($record->{g_o} eq '+'){
    @pgs = (($record->{scaf_lpos} - $record->{frag_lpos} + 1),$record->{scaf_lpos},$record->{scaf_rpos},($record->{scaf_rpos} + (length($record->{seq}) - $record->{frag_rpos})));
  }else{
    @pgs = (($record->{scaf_rpos} + $record->{frag_lpos}  - 1),$record->{scaf_rpos},$record->{scaf_lpos},($record->{scaf_lpos} - (length($record->{seq}) - $record->{frag_rpos})));
  }

  return ["$record->{id}",
	  {label=>$label,color=>$c,leftColor=>$c_l,rightColor=>$c_r},
	  @pgs];
}

sub getLOCI{
  my $self = shift;
  my ($argHR) = @_;
  my ($recordHR,$hitlist,$link);

  exists($argHR->{selectedRECORD}) || ( @$argHR{'recordTYPE','selectedRECORD'} = $self->selectRECORD($argHR) );

  $hitlist = [];
  if((exists($self->{chrLOCI_href}))&&(keys %{$self->{chrLOCI_href}})){
    foreach $recordHR (values %{$self->{chrLOCI_href}}){
      $link = "${CGIPATH}getRegion.pl?chr=$recordHR->{chr}&l_pos=" . ($recordHR->{l_pos} - 500) . "&r_pos=" .($recordHR->{r_pos} + 500) ; ## link to chr/gseg context ?
      push(@$hitlist,[$recordHR->{chr},$recordHR->{l_pos},$self->{primaryColor},$link]);
    }
  }
  ## add gseg entries with no chr positions??

  return $hitlist;
}

sub getMULTILOCI{
  my $self = shift;
  my ($argHR) = @_;
  my ($recordHR,$hitlist,$link);

  $hitlist = exists($argHR->{LOCIhitlist}) ? $argHR->{LOCIhitlist} : [];
  if((exists($self->{chrMULTILOCI_href}))&&(keys %{$self->{chrMULTILOCI_href}})){
    foreach $recordHR (values %{$self->{chrMULTILOCI_href}}){
      $link = "${CGIPATH}getRegion.pl?chr=$recordHR->{chr}&l_pos=" . ($recordHR->{l_pos} - 500) . "&r_pos=" .($recordHR->{r_pos} + 500) ; ## link to chr/gseg context
      push(@$hitlist,[$recordHR->{chr},$recordHR->{l_pos},$self->{primaryColor},$link]);
    }
  }
  ## add gseg entries with no chr positions??

  return $hitlist;
}

#sub showLOCI_TABLE{
#  my $self = shift;
#  my ($argHR) = @_;
#  my ($recordHR,$x,$record_link,$region_link,@rows);

#  exists($argHR->{selectedRECORD}) || ( @$argHR{'recordTYPE','selectedRECORD'} = $self->selectRECORD($argHR) );

#  $x=0;
#  @rows = (th({-align=>'center'},['Entry','Chr','Left','Right']));
#  if((exists($self->{chrLOCI_href}))&&(keys %{$self->{chrLOCI_href}})){
#    foreach $recordHR (sort _by_CLR values %{$self->{chrLOCI_href}}){
#      $x++;
#      $record_link = "${CGIPATH}getRecord.pl?resid=$self->{resid}&chrUID=$recordHR->{gi}"; ## link to individual record
#      $region_link = "${CGIPATH}getRegion.pl?chr=$recordHR->{chr}&l_pos=" . ($recordHR->{l_pos} - 500) . "&r_pos=" .($recordHR->{r_pos} + 500) ; ## link to chr/gseg context
#      if($argHR->{selectedRECORD} == $recordHR){
#	push(@rows,td({style=>'color:#FF0000;'},[$x,a({href=>$region_link,style=>"color:green;"},$recordHR->{chr}),
#						 @$recordHR{'l_pos','r_pos'}]
#		     ));
#      }else{
#	push(@rows,td([a({href=>$record_link,style=>"color:red;"},$x),a({href=>$region_link,style=>"color:green;"},$recordHR->{chr}),
#		       @$recordHR{'l_pos','r_pos'}]
#		     ));
#      }
#    }
#  }
#  ## Still need to deal with gseg entries

#  return  caption("Genomic Location of BAC: gi | $self->{gi} |") . Tr({-align=>'center',-valign=>'top'},\@rows);
#}

sub showMULTILOCI_TABLE{
  my $self = shift;
  my ($argHR) = @_;
  my ($recordHR,$x,$y,$z,$record_link,$region_link,$currentGI,@MLrows,@rows);

  $x=0;$y=1;$z=0;
  if((exists($self->{chrMULTILOCI_href}))&&(keys %{$self->{chrMULTILOCI_href}})){
    @MLrows = (th({style=>"text-align:center; border:0;"},['Entry','Chr','Left','Right']));
    foreach $recordHR (sort _by_ICLR values %{$self->{chrMULTILOCI_href}}){
      $record_link = $self->getRecordLink($argHR,$recordHR,"CHR");
      $region_link = $self->getRegionLink($argHR,$recordHR,"CHR");
      if($recordHR->{gi} ne $currentGI){
	push(@MLrows,td({colspan=>8,style=>"background:#DCDCDC; color:#808000; text-align:left; border:0;"},["BAC: gi | $recordHR->{gi} | acc | $recordHR->{acc} | clone | $recordHR->{clone} |"]));
	$y=1;$x++;
      }
      push(@MLrows,td({style=>"text-align:center;"},[a({href=>$record_link,style=>"color:$self->{primaryColor};"},"$x-$y"),a({href=>$region_link,style=>"color:green;"},$recordHR->{chr}),@$recordHR{'l_pos','r_pos'}]));
      $y++;$z++;
      $currentGI = $recordHR->{gi};
    }
    ## Still need to deal with gseg entries
  }

  unshift(@MLrows,td({colspan=>8,style=>"background:$self->{primaryColor}; color:#FFFFFF; text-align:left; border:0;"},[strong("BACs ($x sequences / $z Loci)")]));

  return table({width=>500,border=>1,valign=>'top'},Tr(\@MLrows)) . "\n";
}

sub _by_LR{
  return (
	  ($a->{scaf_lpos}     <=> $b->{scaf_lpos})     ||
	  ($b->{scaf_rpos}     <=> $a->{scaf_rpos})
	 );
}

sub _by_ICLR{
  return (
	  ($a->{gi}        <=> $b->{gi})        ||
	  ($a->{chr}       <=> $b->{chr})       ||
	  ($a->{l_pos}     <=> $b->{l_pos})     ||
	  ($b->{r_pos}     <=> $a->{r_pos})
	 );
}



1;
