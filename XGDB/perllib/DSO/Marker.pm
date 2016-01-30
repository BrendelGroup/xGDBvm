package Marker;
use base "Locus";

use CGI "img";

do 'SITEDEF.pl';

sub _init{
  my $self = shift;

  $self->SUPER::_init(@_);

  $self->{db_table}  = (exists($self->{db_table})) ? $self->{db_table} : 'marker';
  $self->{trackname} = (exists($self->{trackname}))? $self->{trackname}: 'Marker';

  my $DB_TABLE = $self->{db_table};

   $self->{seqQUERY}    = qq{SELECT c.gi,c.acc,c.version,c.description,c.seq FROM ${DB_TABLE} as c WHERE (?) IN (c.gi,c.acc) };

  if(exists($self->{chrVIEWABLE}) && $self->{chrVIEWABLE}){
    $self->{SQL_BASE}         = qq{SELECT uid,id,gseg_uid,G_O,length,l_pos,r_pos,mismatch,sim FROM ${DB_TABLE} };

    $self->{chrREGION_QUERY}  = qq{$self->{SQL_BASE} WHERE (0) };
    $self->{chrDESC_QUERY}    = qq{$self->{SQL_BASE} WHERE (0) };
    $self->{chrUID_QUERY}     = qq{SELECT id FROM ${DB_TABLE} WHERE (uid=?) };
    $self->{chrQUERY}    = qq{SELECT p.uid,p.gseg_uid,p.E_O,p.sim,p.cov,p.G_O,p.chr,p.l_pos,p.r_pos,p.pgs,p.isCognate,p.gi FROM ${DB_TABLE}_good_pgs as p WHERE (p.gi=?) };
  }

  if((exists($self->{BACVIEWABLE}) && $self->{BACVIEWABLE}) || $self->{gsegSRC}){
    $self->{gsegSQL_BASE}     = qq{SELECT uid,id,gseg_uid,G_O,length,l_pos,r_pos,sim,description FROM ${DB_TABLE} };

    $self->{gsegREGION_QUERY} = qq{$self->{gsegSQL_BASE} WHERE (gseg_uid=?)&&(r_pos>=?)&&(l_pos<=?) };
    $self->{gsegDESC_QUERY}   = qq{$self->{gsegSQL_BASE} WHERE (0) };
    $self->{gsegUID_QUERY}    = qq{SELECT id FROM ${DB_TABLE} WHERE (uid=?) };
    $self->{gsegQUERY}   = qq{SELECT gp.uid,gp.E_O,gp.sim,gp.cov,gp.gseg_gi,gp.G_O,gp.l_pos,gp.r_pos,gp.pgs,gp.isCognate,gp.mergeNOTE,gp.gi FROM gseg_${DB_TABLE}_good_pgs as gp WHERE (gp.gi=?) };
  }

  $self->{MULTI_ID_QUERY} = sub {
    my ($BASE,$idlist) = @_;
    return $BASE . "WHERE (c.gi IN ($idlist))||(acc IN ($idlist))||(clone IN ($idlist))";
  };

}

sub drawREGION{
  my $self = shift;
  my ($argHR,$img_paramHR,$imgfn) = @_;
  my ($link,$imgW,$imgH,$stINFO,$defL,$imgHTML,$initIMG);
  my ($view_IM,$view,$labelAR,$recAR);

  $imgW    = exists($argHR->{imgW})?$argHR->{imgW}:600;
  $imgH    = exists($argHR->{imgH})?$argHR->{imgH}:30;
  $initIMG = exists($argHR->{initialIMG})?$argHR->{initialIMG}:"";

  $view = new GeneView($imgW,$imgH,$argHR->{l_pos},$argHR->{r_pos},1);
  if(($argHR->{r_pos} - $argHR->{l_pos}) <= 250){
    $view->setLabelOn(1);
    $view->setFontSize($argHR->{'fontSize'}) if(exists($argHR->{'fontSize'}));
  }else{
    $view->setLabelOn(0);
  }

  $view_IM = "<map name=\"$self->{trackname}_IM\">\n";

  foreach $recordHR (sort _by_CLR values %{$self->{pgsREGION_href}}){
    $stINFO = $self->structINFO($recordHR);
    $defL   = CGI::unescapeHTML(CGI::unescape($recordHR->{description}));
    $defL =~ s/\'/\\\'/g;
    $defL =~ s/\"/\\\'/g;
    $defL =~ s/\r//g;  ## Get rid of any pesky carriage returns
    $defL =~ s/\n/\\n/g; ## Escape the newline so that HTML works
    $link = $self->getRecordLink($argHR,$recordHR);
    ($labelAR,$recAR) = $view->addMarker(@$stINFO[1..$#$stINFO]);
    $view_IM .= "<area shape=\"rect\" coords='".join(',',@$recAR[2,0,$#$recAR,1])."' href=\"${link}\"  onmouseover=\"showDef('$defL');\" onmouseout=\"hideDef();\">\n";
  }

  $view_IM  .= "</map>\n";

  $imgHTML = img({src    => "${DIR}${initIMG}${imgfn}",
		  usemap => "#${initIMG}$self->{trackname}_IM",
		  border => 0,
		  %$img_paramHR});

  $view->drawPNG($TMPDIR.$imgfn);

  return ($view_IM . $imgHTML,"${DIR}${initIMG}${imgfn}","${initIMG}$self->{trackname}_IM");
}

sub drawCombinedImage{
  my $self = shift;
  my ($view,$startY) = @_;

  my ($recordHR,$stINFO,$bottom,$labelAR,$recAR,%imap);

  foreach $recordHR (sort _by_CLR values %{$self->{pgsREGION_href}}){
    $stINFO = $self->structINFO($recordHR);
    $stINFO->[1]{startHeight} = $startY;
    ($labelAR,$recAR) = $view->addMarker(@$stINFO[1..$#$stINFO]);
    $imap{$self->{resid} . "_" . $recordHR->{uid}} = [$labelAR,$recAR];
    $bottom = $recAR->[1] if($recAR->[1] > $bottom);
  }

  return (\%imap,$bottom);
}



sub structINFO{
  my $self = shift;
  my ($recordHR,$argHR) = @_;
  my ($c,$c_a,$c_s,$c_d,$label,$str,@pgs);

  return undef if(!(defined($recordHR) && exists($recordHR->{uid})));

  $c = $c_a = $c_s = $c_d = exists($self->{primaryColor})?$self->{primaryColor}:"grey";

  $label = exists($recordHR->{label})?$recordHR->{label}:
           exists($recordHR->{id})?$recordHR->{id}:
	   exists($self->{id})?$self->{id}:"unknownID";

  @pgs = ($recordHR->{l_pos},$recordHR->{r_pos});
  @pgs = reverse @pgs if($recordHR->{strand} eq '-');

  return ["$recordHR->{uid}",
	  {label=>$label,color=>$c,arrowColor=>$c_a,startColor=>$c_s,dotColor=>$c_d,drawArrowhead=>1},
	  @pgs];
}

sub _by_CLR{
  my $aGenomicID = (exists($a->{chr}) && defined($a->{chr}))? $a->{chr}:(exists($a->{gseg_gi}) && defined($a->{gseg_gi}))?$a->{gseg_gi}:(exists($a->{gseg_uid}) && defined($a->{gseg_uid}))?$a->{gseg_uid}:0;
  my $bGenomicID = (exists($b->{chr}) && defined($b->{chr}))? $b->{chr}:(exists($b->{gseg_gi}) && defined($b->{gseg_gi}))?$b->{gseg_gi}:(exists($a->{gseg_uid}) && defined($a->{gseg_uid}))?$a->{gseg_uid}:0;
  return (
	  ($aGenomicID     <=> $bGenomicID)     ||
	  ($a->{l_pos}     <=> $b->{l_pos})     ||
	  ($b->{r_pos}     <=> $a->{r_pos})
	 );
}


1;
