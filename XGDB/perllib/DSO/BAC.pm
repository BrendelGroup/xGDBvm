package BAC;
use base "GenomeSegmentTrack";

do 'SITEDEF.pl';

use DBI;
use CGI ":all";

sub hello{
  my $self = shift;
  print "hello I'm a ";
  $self->SUPER::whatami();
  print "$self->{DSOname}\n";
}

sub _init{
  my $self = shift;

  $self->SUPER::_init(@_);

  $self->{sequenceTYPE}  = 'BAC';

  $self->{db_table} = (exists($self->{db_table})) ? $self->{db_table} : 'gseg';
  $self->{trackname} = (exists($self->{trackname}))? $self->{trackname}: 'BAC';

  my $DB_TABLE = $self->{db_table};

  $self->{SQL_BASE}         = qq{SELECT gi as uid,gi,acc,locus,clone,version,description,chr,chr_lpos,chr_lpos as l_pos,chr_rpos,chr_rpos as r_pos,olap_lstart,olap_rstop,seq FROM $DB_TABLE };

  $self->{chrREGION_QUERY}  = qq{$self->{SQL_BASE} WHERE (chr=?)&&(chr_rpos>=?)&&(chr_lpos<=?) };

  $self->{gsegREGION_QUERY} = qq{$self->{SQL_BASE} WHERE ( gi = ? )&&( ? || ? ) };

  $self->{chrDESC_QUERY}    = qq{$self->{SQL_BASE} WHERE MATCH (description) AGAINST ( ? IN BOOLEAN MODE) };

  $self->{seqQUERY}         = qq{$self->{SQL_BASE} WHERE (?) IN (gi,acc,locus,clone) };

  $self->{chrUID_QUERY}     = qq{$self->{SQL_BASE} WHERE (gi = ?)};

  $self->{MULTI_ID_QUERY} = sub {
    my ($BASE,$idlist) = @_;
    return $BASE . "WHERE (gi IN ($idlist))||(acc IN ($idlist))||(locus IN ($idlist))||(clone IN ($idlist))";
  };

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

  foreach $recordHR (sort _by_CCLR values %{$self->{pgsREGION_href}}){
    $stINFO = $self->structINFO('pgs',$recordHR);
    $defL   = CGI::unescapeHTML(CGI::unescape($recordHR->{description}));
    $defL =~ s/\'/\\\'/g;
    $defL =~ s/\"/\\\'/g;
    $defL =~ s/\r//g;  ## Get rid of any pesky carriage returns
    $defL =~ s/\n/\\n/g; ## Escape the newline so that HTML works

    $link = $self->getRecordLink($argHR,$recordHR);
    ($labelAR,$recAR) = $view->addGseg(@$stINFO[1..$#$stINFO]);
    $view_IM .= "<area shape=\"rect\" coords=\"".join(',',@$recAR[2,0,$#$recAR,1])."\" href=\"${link}\"  onmouseover=\"showDef('$defL');\" onmouseout=\"hideDef();\">\n";
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
  $view_IM = "<map name=\"$self->{trackname}_${$}IM\">\n";

  $self->loadREGION($argHR) || return undef;

  foreach $recordHR (sort _by_CCLR values %{$self->{pgsREGION_href}}){
    $link = defined($link)?$link : $self-> getRecordLink($argHR,$recordHR,'NOCONTEXT');
    my $lft = (exists($recordHR->{olap_lstart}) && ($recordHR->{olap_lstart} ne '')) ? $self->min($recordHR->{olap_lstart},$recordHR->{olap_rstop}):1;
    my $rgt = (exists($recordHR->{olap_lstart}) && ($recordHR->{olap_lstart} ne '')) ? $self->max($recordHR->{olap_lstart},$recordHR->{olap_rstop}):length($recordHR->{seq});
    $stINFO = ["$recordHR->{gi}",
	       {label=>$recordHR->{clone},
                color=>$self->{primaryColor},
                leftColor=>$self->{primaryColor},
                rightColor=>$self->{primaryColor}
               },
	       1,$lft,$rgt,length($recordHR->{seq})
	      ];
    $defL   = $recordHR->{description};
    $defL =~ s/\'/\\\'/g;
    $defL =~ s/\"/\\\'/g;
    $defL =~ s/\r//g;  ## Get rid of any pesky carriage returns
    $defL =~ s/\n/\\n/g; ## Escape the newline so that HTML works

    ($labelAR,$recAR) = $view->addGseg(@$stINFO[1..$#$stINFO]);
    $view_IM .= "<area shape=\"rect\" coords=\"".join(',',@$recAR[2,0,$#$recAR,1])."\" href=\"${link}\"  onmouseover=\"showDef('$defL');\" onmouseout=\"hideDef();\">\n";
  }
  $view_IM  .= "</map>\n";

  $imgHTML = img({src    => "${DIR}${initIMG}${imgfn}",
		  usemap => "#${initIMG}$self->{trackname}_${$}IM",
		  border => 0,
		  %$img_paramHR});

  $view->drawPNG($TMPDIR.$imgfn);

  return ($view_IM.$imgHTML,"${DIR}${initIMG}${imgfn}","${initIMG}$self->{trackname}_${$}IM");
}

sub structINFO{
  my $self = shift;
  my ($type,$record) = @_;
  my ($c,$c_a,$c_s,$c_d,$label,@pgs);

  return undef if(!(defined($record) && exists($record->{uid})));

  $c = $c_l = $c_r = $self->{primaryColor};

  $label = (exists($record->{clone}))?$record->{clone}:$self->{gi};

  if($record->{olap_lstart} > $record->{olap_rstop}){
    @pgs = (($record->{chr_rpos} + $record->{olap_rstop} - 1),$record->{chr_rpos},
	    $record->{chr_lpos},($record->{chr_rpos} + $record->{olap_rstop} - length($record->{seq}) - 1),);
  }else{
    @pgs = (($record->{chr_lpos} - $record->{olap_lstart} + 1),$record->{chr_lpos},
	    $record->{chr_rpos},($record->{chr_lpos} - $record->{olap_lstart} + length($record->{seq}) + 1));
  }

  return ["$record->{gi}",
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
#    foreach $recordHR (sort _by_CCLR values %{$self->{chrLOCI_href}}){
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

sub showEXTENDED_LOCI_TABLE{
  my $self = shift;
  my ($argHR,$gCONTEXT) = @_;

  my $x=0;
  my $gsrc = (defined($gCONTEXT))?$gCONTEXT:"Chr";
  $gCONTEXT = "CHR" if (!defined($gCONTEXT));
  @rows = (th({-align=>'center',-style=>"vertical-align:middle;"},['Entry',$self->{trackname} . ' Left',$self->{trackname} . ' Right','Orientation',($gsrc ne 'Chr')?"$gsrc gi":"Chr","${gsrc} Left","${gsrc} Right"]));
  $gsrc = ($gsrc eq 'BAC')?"gseg":lc($gsrc); #### kludge for now

  if((exists($self->{"${gsrc}LOCI_href"}))&&(keys %{$self->{"${gsrc}LOCI_href"}})){
    foreach $recordHR (sort _by_CCLR values %{$self->{"${gsrc}LOCI_href"}}){
      $x++;
      $record_link = $self->getRecordLink($argHR,$recordHR,$gCONTEXT);
      $region_link = $self->getRegionLink($argHR,$recordHR,$gCONTEXT);
      my $FRAG_lpos = min($recordHR->{olap_lstart},$recordHR->{olap_rstop});
      my $FRAG_rpos = max($recordHR->{olap_lstart},$recordHR->{olap_rstop});
      my $ort = ($recordHR->{olap_lstart} > $recordHR->{olap_rstop})?'-':'+';
      if($argHR->{selectedRECORD} == $recordHR){
	push(@rows,td({style=>'border:1px solid red; vertical-align:middle;'},
		      [$x,$FRAG_lpos,$FRAG_rpos,$ort,
		       a({href=>$region_link,style=>"color:green;"},exists($recordHR->{chr})?$recordHR->{chr}:$recordHR->{gseg_gi}),
		       @$recordHR{'l_pos','r_pos'},
		      ]
		     ));
      }else{
	push(@rows,td({style=>'background:#FFFFFF; vertical-align:middle;'},
		       [a({href=>$record_link,style=>"color:$self->{primaryColor};"},$x),
			$FRAG_lpos,$FRAG_rpos,$ort,
		       a({href=>$region_link,style=>"color:green;"},exists($recordHR->{chr})?$recordHR->{chr}:$recordHR->{gseg_gi}),
		       @$recordHR{'l_pos','r_pos'},
		      ]
		     ));
      }
    }
  }

  $gsrc = ($gsrc eq 'chr')?"Chromosomal":uc($gCONTEXT);

  my $id = $self->{gi} || $self->{id} || $argHR->{selectedRECORD}->{gi} || $argHR->{selectedRECORD}->{id} || $argHR->{gi} || $argHR->{id} || "unknownID";

  return  ($#rows)?"<table border=1 style='width:970px;'>\n" . caption("$gsrc Loci for $self->{trackname} : " . ${id}) . Tr({-align=>'center',-valign=>'top'},\@rows) . "</table><br />" : '';

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
sub _by_ICLR{ return ($a->{gi} <=> $b->{gi}) || _by_CCLR($a,$b); }
sub min {return ($_[0]<$_[1])?$_[0]:$_[1];}
sub max {return ($_[0]>$_[1])?$_[0]:$_[1];}


1;
