package Locus;

do 'SITEDEF.pl';

use GSQDB;
use GeneView;

use CGI ":all";
use DBI qw(:sql_types);

sub whatami {
  print "Locus:";
}

sub new {    #print STDERR "[Locus.pm :: _new] $self->{trackname} \n";
  my $invocant = shift;
  my $class    = ref($invocant) || $invocant;
  my $self     = {@_};

  bless( $self, $class );
  $self->_init();
  return $self;
}

sub _init {    #print STDERR "[Locus.pm :: _init] $self->{trackname} \n";
  my $self = shift;

  if ( exists( $self->{DSO_MOD} ) ) { _makeCallbackHooks($self); }
  $self->{STD_LINK_NOCONTEXT}   = _makeClosure( $self, '_link_sub' );
  $self->{STD_LINK_CHR}         = _makeClosure( $self, '_link_sub_chr' );
  $self->{STD_LINK_GSEG}        = _makeClosure( $self, '_link_sub_gseg' );
  $self->{STD_REGION_LINK_CHR}  = _makeClosure( $self, '_region_link_chr' );
  $self->{STD_REGION_LINK_GSEG} = _makeClosure( $self, '_region_link_gseg' );
}

sub _link_sub {
  my ( $DSObj, $argHR, $recordHR ) = @_;
  my $dbid = $argHR->{dbid} || $recordHR->{dbid} || $DSObj->{gi};
  my $id = $recordHR->{gi}
    || $recordHR->{id}
    || $recordHR->{geneid}
    || $DSObj->{gi}
    || $DSObj->{id}
    || $DSObj->{geneid}
    || $argHR->{gi}
    || $argHR->{id}
    || $argHR->{geneid}
    || undef;
  return "${CGIPATH}getRecord.pl?dbid=${dbid}&resid=$DSObj->{resid}&id=${id}";
}

sub _link_sub_chr {
  my ( $DSObj, $argHR, $recordHR ) = @_;
  my $dbid = exists( $argHR->{dbid} ) ? $argHR->{dbid} : exists( $recordHR->{dbid} ) ? $recordHR->{dbid} : exists( $DSObj->{dbid} ) ? $DSObj->{dbid} : $#DBver;
  return "${CGIPATH}getRecord.pl?dbid=${dbid};resid=$DSObj->{resid};chrUID=$recordHR->{uid}";
}

sub _link_sub_gseg {
  my ( $DSObj, $argHR, $recordHR ) = @_;
  my $dbid = exists( $argHR->{dbid} ) ? $argHR->{dbid} : exists( $recordHR->{dbid} ) ? $recordHR->{dbid} : exists( $DSObj->{dbid} ) ? $DSObj->{dbid} : $#DBver;
  return "${CGIPATH}getRecord.pl?dbid=${dbid};resid=$DSObj->{resid};gsegUID=$recordHR->{uid}";
}

sub _region_link_chr {
  my ( $DSObj, $argHR, $recordHR ) = @_;
  my $dbid = exists( $argHR->{dbid} ) ? $argHR->{dbid} : exists( $recordHR->{dbid} ) ? $recordHR->{dbid} : exists( $DSObj->{dbid} ) ? $DSObj->{dbid} : $#DBver;
  my $left  = $recordHR->{SCAF_lpos} || $recordHR->{l_pos} || $DSObj->{SCAF_lpos} || $DSObj->{l_pos} || $argHR->{l_pos} || $argHR->{bac_lpos};
  my $right = $recordHR->{SCAF_rpos} || $recordHR->{r_pos} || $DSObj->{SCAF_rpos} || $DSObj->{r_pos} || $argHR->{r_pos} || $argHR->{bac_rpos};
  $left = 501 if ( $left < 501 );
  return "${CGIPATH}getRegion.pl?dbid=${dbid};chr=$recordHR->{chr};l_pos=" . ( $left - 500 ) . ";r_pos=" . ( $right + 500 );
}

sub _region_link_gseg {
  my ( $DSObj, $argHR, $recordHR ) = @_;
  my $dbid = exists( $argHR->{dbid} ) ? $argHR->{dbid} : exists( $recordHR->{dbid} ) ? $recordHR->{dbid} : exists( $DSObj->{dbid} ) ? $DSObj->{dbid} : $#DBver;
  my $left  = $recordHR->{SCAF_lpos} || $recordHR->{l_pos} || $DSObj->{SCAF_lpos} || $DSObj->{l_pos} || $argHR->{l_pos} || $argHR->{bac_lpos};
  my $right = $recordHR->{SCAF_rpos} || $recordHR->{r_pos} || $DSObj->{SCAF_rpos} || $DSObj->{r_pos} || $argHR->{r_pos} || $argHR->{bac_rpos};
  $left = 501 if ( $left < 501 );
  return "${CGIPATH}getGSEG_Region.pl?dbid=${dbid};gseg_gi=$recordHR->{gseg_gi};bac_lpos=" . ( $left - 500 ) . ";bac_rpos=" . ( $right + 500 );
}

sub _makeCallbackHooks {
  my $self = shift;
  %DSO_MODS = ();
  do "$self->{DSO_MOD}";
  foreach $hook ( keys %DSO_MODS ) {
    $self->{$hook} = _makeClosure( $self, $DSO_MODS{$hook} );
  }
}

sub _makeClosure {
  my ( $self, $hook_sub ) = @_;
  return sub { return $self->$hook_sub(@_); };
}

sub showRECORD_INFO {
  my $self = shift;
  return ( exists( $self->{MOD_RECORD_INFO} ) ) ? &{ $self->{MOD_RECORD_INFO} }(@_) : $self->_STANDARD_RECORD_INFO(@_);
}

sub getExternalURLS {
  my $self = shift;
  return ( exists( $self->{MOD_EXTERNAL_LINKS} ) ) ? &{ $self->{MOD_EXTERNAL_LINKS} }(@_) : $self->_STANDARD_EXTERNAL_URLS(@_);
}

sub getRegionLink {
  my $self = shift;
  my ( $argHR, $recordHR, $gCONTEXT ) = @_;
  my $gsrc =
    defined($gCONTEXT)
    ? ( $gCONTEXT eq 'BAC' ) ? "gseg"
    : ( $gCONTEXT eq 'CHR' ) ? "chr"
    : $gCONTEXT
    : exists( $argHR->{altCONTEXT} )
    ? ( $argHR->{altCONTEXT} eq 'BAC' )
    ? "gseg"
    : ( $argHR->{altCONTEXT} =~ /chr/i ) ? 'chr'
    : $argHR->{altCONTEXT}
    : exists( $argHR->{gsegUID} )
    ? "gseg"
    : "chr";

  my $region_linkSUB =
      exists( $self->{"MOD_REGION_LINK_${gsrc}"} )        ? $self->{"MOD_REGION_LINK_${gsrc}"}
    : exists( $self->{MOD_REGION_LINK} )                  ? $self->{MOD_REGION_LINK}
    : exists( $self->{ "STD_REGION_LINK_" . uc($gsrc) } ) ? $self->{ "STD_REGION_LINK_" . uc($gsrc) }
    : $self->{STD_REGION_LINK_CHR};
  return &{$region_linkSUB}( $argHR, $recordHR );
}

sub getRecordLink {
  my $self = shift;
  my ( $argHR, $recordHR, $gCONTEXT ) = @_;
  my $gsrc =
    defined($gCONTEXT)
    ? ( $gCONTEXT eq 'BAC' ) ? "gseg"
    : ( $gCONTEXT eq 'CHR' ) ? "chr"
    : $gCONTEXT
    : exists( $argHR->{altCONTEXT} )
    ? ( $argHR->{altCONTEXT} eq 'BAC' )
    ? "gseg"
    : ( $argHR->{altCONTEXT} =~ /chr/i ) ? 'chr'
    : $argHR->{altCONTEXT}
    : exists( $argHR->{gsegUID} )
    ? "gseg"
    : "chr";

  my $record_linkSUB =
      exists( $self->{"MOD_LINK_${gsrc}"} )        ? $self->{"MOD_LINK_${gsrc}"}
    : exists( $self->{MOD_LINK} )                  ? $self->{MOD_LINK}
    : exists( $self->{ "STD_LINK_" . uc($gsrc) } ) ? $self->{ "STD_LINK_" . uc($gsrc) }
    : $self->{STD_LINK_CHR};
  return &{$record_linkSUB}( $argHR, $recordHR );
}

sub showSTRUCT {    #print STDERR "[Locus.pm :: showSTRUCT] $self->{trackname} \n";
  my $self = shift;
  my ( $argHR, $paramHR ) = @_;
  $paramHR = {} if ( !defined($paramHR) );

  exists( $argHR->{selectedRECORD} ) || ( @$argHR{ 'recordTYPE', 'selectedRECORD' } = $self->selectRECORD($argHR) );

  $paramHR->{'-width'} = 700 if(!exists($paramHR->{'-width'}));
  $paramHR->{'-height'} = 80 if(!exists($paramHR->{'-height'}));
  my $imgfn = "$self->{trackname}_$self->{db_id}_$stINFO->[0]st.png";
  my $imgSrc = $DIR . $imgfn;

  if(exists($self->{useDASstyle}) && $self->{useDASstyle}){
    my $segID = exists($argHR->{selectedRECORD}->{chr})? $argHR->{selectedRECORD}->{chr} : $argHR->{selectedRECORD}->{gseg_gi};
    my $segStart = $argHR->{selectedRECORD}->{l_pos} - 500;
    my $segStop = $argHR->{selectedRECORD}->{r_pos} + 500;

    require XML::Simple;

    my $xp = XML::Simple->new();
    my $response = $self->getDASGFF({ segment=>[$segHR] },
                                    [ $self->parse_DAS_FEATURES({},
                                                                [ $argHR->{selectedRECORD} ],
                                                                {id=>$segID, start=>$segStart, stop=>$segStop , xID=>$segID, xStart=>$segStart, xStop=>$segStop}) 
                                    ]);
    $argHR->{'dasFeatures'} = $xp->XMLin($response, KeyAttr => { GROUP => "+id" }, ForceArray => [ 'FEATURE', 'GROUP' ] );
    my $dasSTYLESHEET =
        ( exists( $xDAS->{$DSN}->{stylesheet} ) && ( -e $xDAS->{$DSN}->{stylesheet} ) ) ? $xDAS->{$DSN}->{stylesheet}
      : ( defined($xDAS_stylesheet) && ( -e $xDAS_stylesheet ) ) ? $xDAS_stylesheet
      : "";
    if ( $dasSTYLESHEET ne "" ) {
      $response = '';
      open( DASST, $dasSTYLESHEET );
      while (<DASST>) { $response .= $_; }
      close(DASST);
      $argHR->{'dasStyle'} = $xp->XMLin( $response, ForceArray => [ 'CATEGORY', 'TYPE' ] ) if($response =~ /<stylesheet/i);
    }

    ($segID, $imgSrc) = $self->drawDASREGION({imgW=>$paramHR->{'-width'}, imgH=>$paramHR->{'-height'}, l_pos=>$segStart, r_pos=>$segStop, hideRuler=>0, dasFeatures=>$argHR->{'dasFeatures'}, dasStyle=>$argHR->{'dasStyle'}},{},$imgfn);
    
  }else{
    my $stINFO = $self->structINFO( @$argHR{ 'recordTYPE', 'selectedRECORD' } );
    return undef if ( !defined($stINFO) );    ## NO STRUCTURE INFO FOUND

    ## Draw image
    my $view = new GeneView( $paramHR->{'-width'}, $paramHR->{'-height'}, Locus::min( $stINFO->[2], $stINFO->[$#$stINFO] ), Locus::max( $stINFO->[2], $stINFO->[$#$stINFO] ) + 20 );
    $view->setLabelOn(0);
    $view->setFontSize( $argHR->{'fontSize'} ) if ( exists( $argHR->{'fontSize'} ) );
    my ( $nullAR, $recAR ) = $view->addGene( @$stINFO[ 1 .. $#$stINFO ] );
    if ( exists( $argHR->{selectedRECORD}->{cdsstart} ) ) {
      $view->addCDS( $recAR->[0], $argHR->{selectedRECORD}->{cdsstart}, $argHR->{selectedRECORD}->{cdsstop} );
    }
    $view->drawPNG( $TMPDIR . $imgfn );
  }

  return img( { -name => 'struct', -align => 'center', -src => $imgSrc, -border => 1, %$paramHR } );
}

sub showLOCI_MAP {    #print STDERR "[Locus.pm :: showLOCI_MAP] $self->{trackname} \n";
  my $self = shift;
  my ($argHR) = @_;

  exists( $argHR->{selectedRECORD} ) || ( @$argHR{ 'recordTYPE', 'selectedRECORD' } = $self->selectRECORD($argHR) );

  my $hitLIST = $self->getLOCI($argHR);
  ## ShowHITMAP however GSQDB(dbid,hitlist) || GenomeView
  return GSQDB->showHITMAP( $self->{db_id}, $hitLIST );
}

sub getLOCI{  ## ABSTRACT FUNCTION PROTOTYPE
  my ($self,$argHR) = @_;
  return exists( $argHR->{LOCIhitlist} ) ? $argHR->{LOCIhitlist} : [];
}

sub setRegionLocal {
  my $self = shift;
  my ($argHR) = @_;

  exists( $argHR->{selectedRECORD} ) || ( @$argHR{ 'recordTYPE', 'selectedRECORD' } = $self->selectRECORD($argHR) );

  ## Adjust header start/end (l_pos,r_pos) to region local to selected record
  if ( exists( $argHR->{selectedRECORD}->{SCAF_lpos} ) || exists( $argHR->{selectedRECORD}->{l_pos} ) ) {
    if ( exists( $argHR->{selectedRECORD}->{chr} ) ) {
      $argHR->{chr} = $argHR->{selectedRECORD}->{chr};
    } elsif ( exists( $argHR->{selectedRECORD}->{gseg_gi} ) ) {
      $argHR->{gseg_gi} = $argHR->{selectedRECORD}->{gseg_gi};
    }
    $argHR->{l_pos} = $argHR->{selectedRECORD}->{SCAF_lpos} || $argHR->{selectedRECORD}->{l_pos};
    $argHR->{l_pos} -= 500;
    $argHR->{l_pos} = 1 if ( $argHR->{l_pos} < 1 );
    $argHR->{r_pos} = $argHR->{selectedRECORD}->{SCAF_rpos} || $argHR->{selectedRECORD}->{r_pos};
    $argHR->{r_pos} += 500;

    return 1;
  }

  return 0;
}

sub findREGION {    #print STDERR "[Locus.pm :: findREGION] $self->{trackname} \n";
  my $self = shift;
  my ($argHR) = @_;

  my ( $type, $recordHR ) = $self->selectRECORD($argHR);
  my $URL = $self->getRegionLink( $argHR, $recordHR, ( $type eq 'chrUID' ) ? 'chr' : 'gseg' );
  if ( $type =~ /^chr/ ) {
    return ( $type, @$recordHR{ 'chr', 'l_pos', 'r_pos' }, $URL );
  } elsif ( $type =~ /gseg/ ) {
    return ( $type, @$recordHR{ 'gseg_gi', 'l_pos', 'r_pos' }, $URL );
  } else {
    return undef;
  }
}

sub findRECORD {    #print STDERR "[Locus.pm :: findRECORD] $self->{trackname} \n";
  my $self = shift;
  my ($argHR) = @_;
  my ( $type, $recordHR ) = $self->selectRECORD($argHR);
  if ( defined($type) ) {
    return ( $type, $recordHR->{uid} );
  } else {
    return undef;
  }
}
####Ann added for find version if acc 7/27/09##############
sub findVersion {    #print STDERR "[Locus.pm :: findID] $self->{trackname} \n";
  my $self = shift;
  my ($argHR) = @_;
  my ( $type, $recordHR ) = $self->selectRECORD($argHR);
  if ( defined($type) ) {
    return ( $type, $recordHR->{version} );
  } else {
    return undef;
  }
}

sub selectRECORD{ ## ABSTRACT FUNCTION PROTOTYPE
  return undef;
}

sub load_multiID {    #print STDERR "[Locus.pm :: load_multiID] $self->{trackname} \n";
  my $self = shift;
  my ($IDaref) = @_;
  my ( $id, @idlist );

  $self->{dbh}->{FetchHashKeyName} = 'NAME_lc';

  foreach $id (@$IDaref) {
    $id = $self->{VALIDATE_ID}->($id) if ( exists( $self->{VALIDATE_ID} ) );
    push( @idlist, "'$id'" ) if ( defined($id) );
  }

  if ( scalar(@idlist) ) {
    if ( exists( $self->{SQL_BASE} ) ) {
      my $sth = $self->{dbh}->prepare( $self->{MULTI_ID_QUERY}->( $self->{SQL_BASE}, join( ',', @idlist ) ) );
      $sth->execute();
      $self->{chrMULTILOCI_href} = $sth->fetchall_hashref('uid');
      $sth->finish();
    }
    if ( exists( $self->{gsegSQL_BASE} ) ) {
      my $sth = $self->{dbh}->prepare( $self->{MULTI_ID_QUERY}->( $self->{gsegSQL_BASE}, join( ',', @idlist ) ) );
      $sth->execute();
      $self->{gsegMULTILOCI_href} = $sth->fetchall_hashref('uid');
      $sth->finish();
    }
  }

  return ( keys( %{ $self->{chrMULTILOCI_href} } ), keys( %{ $self->{gsegMULTILOCI_href} } ) );
}

sub search_by_ID {    #print STDERR "[Locus.pm :: search_by_ID] $self->{trackname} \n";
  my $self = shift;
  my ($id) = @_;
  my ( $field, $msg, $res_href, $sth );

  $id = $self->{VALIDATE_ID}->($id) if ( exists( $self->{VALIDATE_ID} ) );

  $self->{dbh}->{FetchHashKeyName} = 'NAME_lc';

  $msg = "";
  if ( exists( $self->{chrQUERY} ) ) {
    $sth = $self->{dbh}->prepare_cached( $self->{chrQUERY} );
    $sth->execute($id);
    $self->{chrLOCI_href} = $sth->fetchall_hashref('uid');
    $sth->finish();
  }

  if ( exists( $self->{gsegQUERY} ) ) {
    $sth = $self->{dbh}->prepare_cached( $self->{gsegQUERY} );
    $sth->execute($id);
    $self->{gsegLOCI_href} = $sth->fetchall_hashref('uid');
    $sth->finish();
  }

  if ( !( keys( %{ $self->{chrLOCI_href} } ) || keys( %{ $self->{gsegLOCI_href} } ) ) ) {
    return ( 0, $msg );
  }

  return ( keys( %{ $self->{chrLOCI_href} } ) + keys( %{ $self->{gsegLOCI_href} } ), $msg );
}

sub search_by_description {    #print STDERR "[Locus.pm :: search_by_description] $self->{trackname} \n";
  my $self = shift;
  my ($descAR) = @_;
  my ($sth);

  $self->{dbh}->{FetchHashKeyName} = 'NAME_lc';

  if ( exists( $self->{chrDESC_QUERY} ) ) {
    $sth = $self->{dbh}->prepare( $self->{chrDESC_QUERY} );
    $sth->execute( join( ' ', @$descAR ) );
    $self->{chrMULTILOCI_href} = $sth->fetchall_hashref('uid');
    $sth->finish();
  }

  if ( exists( $self->{gsegDESC_QUERY} ) ) {
    $sth = $self->{dbh}->prepare( $self->{gsegDESC_QUERY} );
    $sth->execute( join( ' ', @$descAR ) );
    $self->{gsegMULTILOCI_href} = $sth->fetchall_hashref('uid');
    $sth->finish();
  }

  return ( keys( %{ $self->{chrMULTILOCI_href} } ), keys( %{ $self->{gsegMULTILOCI_href} } ) );
}

sub loadREGION {
  ## THIS SHOULD BE MOVED DOWN A LEVEL AND ABSTRACTED HERE!!!
  my $self = shift;
  my ($argHR) = @_;
  my ($sth);

  $self->{dbh}->{FetchHashKeyName} = 'NAME_lc';

  if ( exists( $argHR->{altCONTEXT} ) && ( $argHR->{altCONTEXT} eq "BAC" ) && exists( $argHR->{l_pos} ) && exists( $argHR->{r_pos} ) ) {

    #<DEBUG># print STDERR "[Locus.pm::loadREGION] $self->{trackname} \n";
    #<DEBUG># print STDERR "[Locus.pm::loadREGION] $self->{gsegREGION_QUERY}\n";
    $sth = $self->{dbh}->prepare_cached( $self->{gsegREGION_QUERY} );
    eval {
      $sth->bind_param( 1, $argHR->{gseg_gi}, SQL_VARCHAR );
      $sth->bind_param( 2, $argHR->{l_pos},   SQL_INTEGER );
      $sth->bind_param( 3, $argHR->{r_pos},   SQL_INTEGER );
      $sth->execute();
      $self->{pgsREGION_href} = $sth->fetchall_hashref('uid');
    };
  } elsif ( exists( $argHR->{'chr'} ) && exists( $argHR->{l_pos} ) && exists( $argHR->{r_pos} ) ) {
    $sth = $self->{dbh}->prepare_cached( $self->{chrREGION_QUERY} );
    eval {
      $sth->bind_param( 1, $argHR->{'chr'}, SQL_VARCHAR );
      $sth->bind_param( 2, $argHR->{l_pos}, SQL_INTEGER );
      $sth->bind_param( 3, $argHR->{r_pos}, SQL_INTEGER );
      $sth->execute();
      $self->{pgsREGION_href} = $sth->fetchall_hashref('uid');
    };
  } else {
    return 0;
  }

  return 1;
}

sub queryREGION {
  my $self = shift;
  my ( $argHR, $img_paramHR ) = @_;
  my ( $imgfn );
  my ( $imgHTML, $imgNAME, $imgIMAP );
  my ( $tcHTML,  $tcCOLOR, $tcNAME );

##DEBUG  print STDERR "[Locus.pm :: queryREGION] $self->{trackname} \n";

  $self->loadREGION($argHR) || return undef;

  if ( exists( $argHR->{altCONTEXT} ) && ( $argHR->{altCONTEXT} eq "BAC" ) && exists( $argHR->{l_pos} ) && exists( $argHR->{r_pos} ) ) {
    $imgfn = "$self->{trackname}_$self->{db_id}_gseg" . join( '-', @$argHR{ 'gseg_gi', 'l_pos', 'r_pos', 'fontSize', 'imgW' } ) . "GC.png";
  } elsif ( exists( $argHR->{chr} ) && exists( $argHR->{l_pos} ) && exists( $argHR->{r_pos} ) ) {
    $imgfn = "$self->{trackname}_$self->{db_id}_chr" . join( '-', @$argHR{ 'chr', 'l_pos', 'r_pos', 'fontSize', 'imgW' } ) . "GC.png";
  } else {
    return undef;
  }

  if(exists($self->{useDASstyle}) && $self->{useDASstyle}){
    ( $imgHTML, $imgNAME, $imgIMAP ) = $self->drawDASLOCAL( $argHR, $img_paramHR, $imgfn );
  }else{
    ( $imgHTML, $imgNAME, $imgIMAP ) = $self->drawREGION( $argHR, $img_paramHR, $imgfn );
  }
  ( $tcHTML, $tcCOLOR, $tcNAME ) = $self->getTRACKCELL( $argHR, $imgfn );

  return ( $tcNAME, $tcCOLOR, $tcHTML, $imgHTML, $imgNAME, $imgIMAP );
}

sub getSequenceFromBLAST {
  my $self = shift;
  my ($id) = @_;

  my $db      = new GSQDB;
  my %seqHASH = ();
  my $BdB     = '';
  $id = $self->{VALIDATE_ID}->($id) if ( exists( $self->{VALIDATE_ID} ) );
  foreach $BdB ( 'blast_db', 'blast_db_nucleotide', 'blast_db_peptide', 'blast_db_mrna', 'blast_db_cds' ) {
    if ( exists( $self->{$BdB} ) ) {
      $seqHASH{$BdB} = $db->getSequence( $self->{$BdB}, $self->{db_id}, [$id] );
    }
  }
  return \%seqHASH;
}

sub getTRACKCELL {
  my $self = shift;
  my ( $argHR, $imgfn ) = @_;
  my ( $html, $color, $name );

  my ($stdcheck) = ('checked');

  $name  = $self->{trackname};
  $color = $self->{primaryColor};
  $html  = '';

  return ( $html, $color, $name );
}

sub getIMAP_TV {
  my $self = shift;
  my ( $argHR, $imapHR, $pgsstatHR, $exstatHR, $instatHR ) = @_;

  my $maphtml = "";
  my ( $resID, $uid, $coordAR, $x, $y );
  foreach $dso ( keys %$imapHR ) {
    ( $resID, $uid ) = $dso =~ /(\d+)_(\d+)/;
    my $link = $self->getRecordLink( $argHR, { uid => $uid } );
    $coordAR = $imapHR->{$dso}[1];
    $y       = 0;
    for ( $x = 2 ; $x <= $#$coordAR ; $x += 2 ) {
      $y++;
      $maphtml .= "<area shape=\"rect\" coords='$coordAR->[$x],$coordAR->[0],$coordAR->[$x+1],$coordAR->[1]' href=\"#\" onmouseover=\"mo(0,'${dso}',$y);\" onmouseout=\"mo(-1,'out',-1);\">\n";
      if ( ( $x + 2 ) < $#$coordAR ) {    ## make intron area
        $maphtml .= "<area shape=\"rect\" coords='$coordAR->[$x+1],$coordAR->[0],$coordAR->[$x+2],$coordAR->[1]' href=\"#\" onmouseover=\"mo(1,'${dso}',$y);\" onmouseout=\"mo(-1,'out',-1);\">\n";
      }
    }

    #$maphtml .= "<area shape=\"rect\" coords='$coordAR->[2],$coordAR->[0],$coordAR->[$#$coordAR],$coordAR->[1]' href=\"${link}\"  target='_blank' onmouseover=\"mo(2,'${dso}',-1);\" onmouseout=\"mo(-1,'out',-1);\">\n";
  }
  return $maphtml;
}

sub getIMAP_UCA {
  my $self = shift;
  my ( $argHR, $imapHR, $pgsstatHR, $exstatHR, $instatHR ) = @_;

  my $maphtml = "";
  my ( $resID, $uid, $coordAR, $x, $y );
  foreach $dso ( keys %$imapHR ) {
    ( $resID, $uid ) = $dso =~ /(\d+)_(\d+)/;
    $coordAR = $imapHR->{$dso}[1];
    $y       = 0;
    my $fullstruct = '';
    for ( $x = 0 ; $x <= $#$coordAR ; $x += 2 ) {
      if ( !exists( $exstatHR->{ $dso . "_" . $y } ) ) {
        $y++;
        next;
      }
      $exonpair = min( $exstatHR->{ $dso . "_" . $y }[1], $exstatHR->{ $dso . "_" . $y }[2] ) . "," . max( $exstatHR->{ $dso . "_" . $y }[1], $exstatHR->{ $dso . "_" . $y }[2] );
      $y++;
      my $exstruct = "addUDE(${exonpair},'$self->{trackname}','$SITENAMEshort --');";
      $maphtml    .= "<area shape=\"rect\" coords=\"$coordAR->[$x],$coordAR->[0],$coordAR->[$x+1],$coordAR->[1]\" href=\"javascript:${exstruct}\" >\n";
      $fullstruct .= $exstruct;
    }
    $labelAR = $imapHR->{$dso}[0];

    $maphtml .= "<area shape=\"rect\" coords=\"$labelAR->[0],$labelAR->[1],$labelAR->[2],$labelAR->[3]\" href=\"javascript:resetMRNA();${fullstruct}\">\n";
  }
  return $maphtml;
}

sub get_pgsStats {
  #### This should probably be moved down a level and Abstracted here!!
  my $self = shift;
  my ($argHR) = @_;
  my ( $uid, $id, $recordHR, %pgsSTATS );

  $self->loadREGION($argHR) if ( ( defined($argHR) ) && ( !exists( $self->{pgsREGION_href} ) ) );
  if ( ( exists( $self->{pgsREGION_href} ) ) && ( keys( %{ $self->{pgsREGION_href} } ) ) ) {
    foreach $uid ( keys %{ $self->{pgsREGION_href} } ) {
      $recordHR = $self->{pgsREGION_href}{$uid};
      $id       =
          ( exists( $recordHR->{gi} ) )
        ? ( exists( $recordHR->{acc} ) ) ? 'gi|' . $recordHR->{gi} . '|gb|' . $recordHR->{acc} : 'gi|' . $recordHR->{gi} . '|'
        : ( exists( $recordHR->{geneid} ) )
        ? 'locus|' . $recordHR->{geneid} . '|'
        : '! unknown id !';
      $pgsSTATS{ $self->{resid} . '_' . $uid } = [ $id, 'NA', 0, 'NA', $recordHR->{l_pos}, $recordHR->{r_pos}, $recordHR->{description} ];
    }
  } else {
    return undef;
  }

  return \%pgsSTATS;

}

sub get_exStats {    ## ABSTRACT FUNCTION PROTOTYPE
  return undef;
}

sub get_inStats {    ## ABSTRACT FUNCTION PROTOTYPE
  return undef;
}

sub drawDASLOCAL {
  my $self = shift;
  my ($argHR, $img_paramHR, $imgfn) = @_;

  require XML::Simple;

  my $dbid = $self->{dbid} || $argHR->{dbid} || $#DBver; 
  my $db = new GSQDB( { dbid => $dbid } );
  my $featSegments = [];
  my $featReq      = {};
  my $gseg = (exists( $argHR->{altCONTEXT} ) && ( $argHR->{altCONTEXT} eq "BAC" ))? $argHR->{gseg_gi} : $argHR->{'chr'}; ###  KLUDGE
  $db->checkSegment($gseg,$argHR->{l_pos},$argHR->{r_pos},$featReq);
  $self->getDASFEATURES($featReq, $featSegments);

  my $xp = XML::Simple->new();
  $argHR->{'dasFeatures'} = $xp->XMLin( $self->getDASGFF($featReq, $featSegments), KeyAttr => { GROUP => "+id" }, ForceArray => [ 'FEATURE', 'GROUP' ] );

  my $dasSTYLESHEET =
      ( exists( $xDAS->{$DSN}->{stylesheet} ) && ( -e $xDAS->{$DSN}->{stylesheet} ) ) ? $xDAS->{$DSN}->{stylesheet}
    : ( defined($xDAS_stylesheet) && ( -e $xDAS_stylesheet ) ) ? $xDAS_stylesheet
    : "";
  if ( $dasSTYLESHEET ne "" ) {
    my $response = '';
    open( DASST, $dasSTYLESHEET );
    while (<DASST>) { $response .= $_; }
    close(DASST);
    $argHR->{'dasStyle'} = $xp->XMLin( $response, ForceArray => [ 'CATEGORY', 'TYPE' ] ) if($response =~ /<stylesheet/i);
  }

  return $self->drawDASREGION( $argHR, $img_paramHR, $imgfn );
}

sub drawDASREGION {
  my $self = shift;
  my ( $argHR, $img_paramHR, $imgfn ) = @_;

  ##########
  ## While DAS has the ability to return multiple segments
  ## We shouldn't ever see more than 1 by the LWP request used in queryREGION()
  ##########
  my $featAR = $argHR->{'dasFeatures'}->{'GFF'}->{'SEGMENT'}->{'FEATURE'};

  my ( $feature, $featGrpType, $group, $groupHRAR, $groupAR, $sCnt );
  my ( $view_IM, $view, $puid );
  my ( $link, $grpLabel, $imgW, $imgH, $stINFO, $defL, $imgHTML, $initIMG );
  my ( $recAR, $labelAR, $PrecAR, $PlabelAR );

  $imgW    = exists( $argHR->{imgW} )       ? $argHR->{imgW}       : 600;
  $imgH    = exists( $argHR->{imgH} )       ? $argHR->{imgH}       : 30;
  $initIMG = exists( $argHR->{initialIMG} ) ? $argHR->{initialIMG} : "";
  my $hideRuler = exists( $argHR->{hideRuler} ) ? $argHR->{hideRuler} : 1;

  $view = new GeneView( $imgW, $imgH, $argHR->{l_pos}, $argHR->{r_pos}, $hideRuler );
  $view->setLabelOn(1);
  $view->setFontSize( $argHR->{'fontSize'} ) if ( exists( $argHR->{'fontSize'} ) );
  $view_IM = "<MAP NAME=\"$self->{trackname}_IM\">\n";

  #### Cluster the features into groups
  $sCnt = 1;
  foreach $feature (@$featAR) {
    if ( exists( $feature->{'GROUP'} ) ) {
      foreach $group ( keys %{ $feature->{'GROUP'} } ) {
        if ( exists( $groupHRAR->{$group} ) ) {
          push( @{ $groupHRAR->{$group}->{'featlist'} }, $feature );
          $groupHRAR->{$group}->{'grpLFT'} = Locus::min( $groupHRAR->{$group}->{'grpLFT'}, Locus::min( $feature->{'START'}, $feature->{'END'} ) );
          $groupHRAR->{$group}->{'grpRGT'} = Locus::max( $groupHRAR->{$group}->{'grpRGT'}, Locus::max( $feature->{'START'}, $feature->{'END'} ) );
        } else {
          $groupHRAR->{$group}->{'featlist'} = [$feature];
          $groupHRAR->{$group}->{'grpLFT'}   = Locus::min( $feature->{'START'}, $feature->{'END'} );
          $groupHRAR->{$group}->{'grpRGT'}   = Locus::max( $feature->{'START'}, $feature->{'END'} );
        }
      }
    } else {
      $groupHRAR->{"singlet${sCnt}"}->{'featlist'} = [$feature];
      $groupHRAR->{"singlet${sCnt}"}->{'grpLFT'}   = Locus::min( $feature->{'START'}, $feature->{'END'} );
      $groupHRAR->{"singlet${sCnt}"}->{'grpRGT'}   = Locus::max( $feature->{'START'}, $feature->{'END'} );
      $sCnt++;
    }
  }

  my ( $glyph, $primaryColor );
  #### Draw each group
  foreach $group (
                   sort { return ( $groupHRAR->{$a}->{'grpLFT'} <=> $groupHRAR->{$b}->{'grpLFT'} ) || ( $groupHRAR->{$b}->{'grpRGT'} <=> $groupHRAR->{$a}->{'grpRGT'} ) || $a cmp $b; }
                   keys %$groupHRAR
                 )
  {
    my $height = undef;
    $PrecAR   = undef;
    $link     = undef;
    $grpLabel = undef;
    $groupAR  = undef;
    foreach $feature ( sort { return ( Locus::min( $a->{'START'}, $a->{'END'} ) <=> Locus::min( $b->{'START'}, $b->{'END'} ) ) || ( Locus::max( $b->{'START'}, $b->{'END'} ) <=> Locus::max( $a->{'START'}, $a->{'END'} ) ); } @{ $groupHRAR->{$group}->{'featlist'} } ) {
      ( $labelAR, $recAR, $glyph ) = $view->addDASfeature( $feature, $argHR->{'dasStyle'}, $height );
      next if ( !defined($labelAR) );

      ## Set the track Primary Color (will be picked up by getTRACKCELL)
      if ( !defined($primaryColor) && defined($glyph) && exists( $glyph->{ join( "", keys(%$glyph) ) }->{'BGCOLOR'} ) ) {
        $self->{'primaryColor'} = $glyph->{ join( "", keys(%$glyph) ) }->{'BGCOLOR'};
      }

      ##!! Should consider seperating individual feature labels from group labels
      ##!! and associating group link with its label need decision logic for this
      if ( !defined($link) || ( $link eq '#' ) ) {
        $link =
            ( exists( $feature->{'GROUP'}->{$group}->{'LINK'}->{'href'} ) ) ? $feature->{'GROUP'}->{$group}->{'LINK'}->{'href'}
          : ( exists( $feature->{'LINK'}->{'href'} ) ) ? $feature->{'LINK'}->{'href'}
          : '#';
      }
      if ( !defined($grpLabel) ) {
        $featGrpType = $feature->{'GROUP'}->{$group}->{'type'};
        $grpLabel    = ( exists( $feature->{'GROUP'}->{$group}->{'label'} ) )
          ? $feature->{'GROUP'}->{$group}->{'label'}
          : ( exists( $feature->{'GROUP'}->{$group}->{'id'} ) ) ? $feature->{'GROUP'}->{$group}->{'id'}
          : undef;
      }

 
      ## SDS 12-17-09 Added mouseover display of DAS Category/Type for each individual feature primarily for debugging purposes ##
      $defL = exists($feature->{'TYPE'}->{'category'}) ? "($feature->{TYPE}->{category}) $feature->{TYPE}->{id}" : "$feature->{TYPE}->{id}";
      $view_IM .= "<AREA SHAPE=\"RECT\" COORDS=\"" . join( ',',@$recAR[ 2, 0, $#$recAR, 1 ]) . "\" HREF=\"${link}\" onmouseover=\"showDef('$defL');\" onmouseout=\"hideDef();\">\n";
      ###SDS###

      ## Ungrouped feature
      if ( !exists( $feature->{'GROUP'} ) ) {
        $groupAR = [ @$recAR[ 2, 0, $#$recAR, 1 ] ];
        next;
      }

      ## Grouped feature
      $height = $recAR->[1];
      $view->addDASgroupConnection( $PrecAR->[3], $recAR->[2], $feature->{'GROUP'}->{$group}->{'type'}, $argHR->{'dasStyle'}, $height ) if ( defined($PrecAR) );
      $view_IM .= "<AREA SHAPE=\"RECT\" COORDS=\"" . join( ',',(@$PrecAR[ 3, 0],@$recAR[ 2, 1 ])) . "\" HREF=\"${link}\">\n";

      ( $PlableAR, $PrecAR ) = ( $labelAR, $recAR );
      if ( !defined($groupAR) ) {
        $groupAR = [ @$recAR[ 2, 0, $#$recAR, 1 ] ];
      } else {
        $groupAR->[2] = $recAR->[$#$recAR];
      }

    }
    my $forceGroupLabel = ( exists( $self->{'forceGroupLabel'} ) ) ? $self->{'forceGroupLabel'} : 0;
    $view->addDASgroupLabel( $featGrpType, $grpLabel, $groupAR, $argHR->{'dasStyle'}, $forceGroupLabel ) if ( defined($grpLabel) );
  }

  $view_IM .= "</MAP>\n";
  $imgHTML = img(
                  {
                    src    => "${DIR}${initIMG}${imgfn}",
                    usemap => "#${initIMG}$self->{trackname}_IM",
                    border => 0,
                    %$img_paramHR
                  }
                );
  $view->drawPNG( $TMPDIR . $imgfn );

  return ( $view_IM . $imgHTML, "${DIR}${initIMG}${imgfn}", "${initIMG}$self->{trackname}_IM" );
}

sub getDASGFF {
  my $self = shift;
  my ($featReq, $featSegments) = @_;

  my $response = "<!DOCTYPE DASGFF SYSTEM \"http://www.biodas.org/dtd/dasgff.dtd\">\n<DASGFF>\n<GFF version=\"1.2\" href=\"$selfURL\">\n";
  for ( my $x = 0 ; $x <= $#$featSegments ; $x++ ) {
    if ( exists( $featReq->{'segment'} ) && defined( $featReq->{'segment'}[$x] ) && exists( $featReq->{'segment'}[$x]->{'id'} ) ) {
      my $id      = $featReq->{'segment'}[$x]->{'id'};
      my $start   = $featReq->{'segment'}[$x]->{'start'};
      my $stop    = $featReq->{'segment'}[$x]->{'stop'};
      my $version = $featReq->{'segment'}[$x]->{'version'};
      my $label   = $featReq->{'segment'}[$x]->{'label'};

      ## CHECK HERE for UNKOWN SEGMENT TO REPORT then iterate to 'next' segment
      if ( exists( $featReq->{'segment'}[$x]->{'UNKNOWN_SEGMENT'} ) ) {
        $response .= "<UNKNOWNSEGMENT id=\"$id\" start=\"$start\" stop=\"$stop\" />\n";
        next;
      }

      $response .= "<SEGMENT id=\"$id\" start=\"$start\" stop=\"$stop\" ";
      $response .= "type=\"" . $featReq->{'segment'}[$x]->{'type'} . "\" " if ( exists( $featReq->{'segment'}[$x]->{'type'} ) );
      $response .= "version=\"$version\" label=\"$label\">\n";
    } else {
      $response .= "<SEGMENT>\n";
    }
    if ( defined( $featSegments->[$x] ) ) {
      foreach my $feat ( sort { $a->{'start'} <=> $b->{'start'} } @{ $featSegments->[$x] } ) {
        $response .= "<FEATURE id=\"" . $feat->{'id'} . "\"";
        $response .= " label=\"" . $feat->{'label'} . "\"" if ( exists( $feat->{'label'} ) );
        $response .= ">\n";

        $response .= "<TYPE id=\"" . $feat->{'type_id'} . "\"";
        $response .= ( exists( $feat->{'type_category'} ) ) ? " category=\"" . $feat->{'type_category'} : " reference=\"no";
        $response .= ( exists( $feat->{'type_label'} ) ) ? "\">" . $feat->{'type_label'} . "</TYPE>\n" : "\"></TYPE>\n";

        $response .= "<METHOD id=\"" . $feat->{'method_id'} . "\">";
        $response .= ( exists( $feat->{'method_label'} ) ) ? $feat->{'method_label'} . "</METHOD>\n" : "</METHOD>\n";

        $response .= "<START>" . $feat->{'start'} . "</START>\n";
        $response .= "<END>" . $feat->{'end'} . "</END>\n";
        $response .= ( exists( $feat->{'score'} ) ) ? "<SCORE>" . $feat->{'score'} . "</SCORE>\n" : "<SCORE>-</SCORE>\n";

        $response .= ( exists( $feat->{'orientation'} ) ) ? "<ORIENTATION>" . $feat->{'orientation'} . "</ORIENTATION>\n" : "<ORIENTATION>0</ORIENTATION>\n";

        $response .= ( exists( $feat->{'phase'} ) ) ? "<PHASE>" . $feat->{'phase'} . "</PHASE>\n" : "<PHASE>-</PHASE>\n";

        $response .= "<NOTE>" . $feat->{'note'} . "</NOTE>\n" if ( exists( $feat->{'note'} ) );

        if ( exists( $feat->{'link_href'} ) ) {
          $response .= "<LINK href=\"" . $feat->{'link_href'} . "\">";
          $response .= ( exists( $feat->{'link_text'} ) ) ? $feat->{'link_text'} . "</LINK>\n" : "</LINK>\n";
        }

        if ( exists( $feat->{'target_id'} ) && ( exists( $feat->{'target_start'} ) ) && ( exists( $feat->{'target_stop'} ) ) ) {
          $response .= "<TARGET id=\"" . $feat->{'target_id'} . "\" start=\"" . $feat->{'target_start'} . "\" stop=\"" . $feat->{'target_stop'} . "\">";
          $response .= ( exists( $feat->{'target_label'} ) ) ? $feat->{'target_label'} . "</TARGET>\n" : "</TARGET>\n";
        }

        if ( exists( $feat->{'group_id'} ) ) {
          $response .= "<GROUP id=\"" . $feat->{'group_id'} . "\"";
          $response .= " label=\"" . $feat->{'group_label'} . "\"" if ( exists( $feat->{'group_label'} ) );
          $response .= " type=\"" . $feat->{'group_type'} . "\"" if ( exists( $feat->{'group_type'} ) );
          $response .= ">\n";
          $response .= "<NOTE>" . $feat->{'group_note'} . "</NOTE>\n" if ( exists( $feat->{'group_note'} ) );
          if ( exists( $feat->{'group_link_href'} ) ) {
            $response .= "<LINK href=\"" . $feat->{'group_link_href'} . "\">";
            $response .= ( exists( $feat->{'group_link_text'} ) ) ? $feat->{'group_link_text'} . "</LINK>\n" : "</LINK>\n";
          }
          $response .= "</GROUP>\n";
        }

        $response .= "</FEATURE>\n";
      }
    }
    $response .= "</SEGMENT>\n";
  }
  $response .= "</GFF>\n</DASGFF>\n";

  return $response;
}

sub getDASFEATURES {
  my $self = shift;
  my ( $reqHR, $resultAR ) = @_;
  $resultAR = [] if ( !defined($resultAR) );
  my ($annotations);
  if ( exists( $reqHR->{'segment'} ) ) {
    for ( my $segNDX = 0 ; $segNDX <= $#{ $reqHR->{'segment'} } ; $segNDX++ ) {
      next if ( exists( $reqHR->{'segment'}[$segNDX]->{'UNKNOWN_SEGMENT'} ) );
      $annotations = $self->load_DAS_REGION( $reqHR->{'segment'}[$segNDX] );
      my $featLIST_aref = $self->parse_DAS_FEATURES( $reqHR, $annotations, $reqHR->{'segment'}[$segNDX]);
      next if ( !defined($featLIST_aref) );
      if ( defined( $resultAR->[$segNDX] ) ) {
        push( @{ $resultAR->[$segNDX] }, @$featLIST_aref );
      } else {
        $resultAR->[$segNDX] = [@$featLIST_aref];
      }
    }
  } else {
    $annotations = $self->load_DAS_REGION( {} );
    my $featLIST_aref = $self->parse_DAS_FEATURES( $reqHR, $annotations, $reqHR->{'segment'}[$segNDX]);
    next if ( !defined($featLIST_aref) );
    if ( defined( $resultAR->[0] ) ) {
      push( @{ $resultAR->[0] }, @$featLIST_aref );
    } else {
      $resultAR->[0] = [@$featLIST_aref];
    }
  }
  return $resultAR;
}

sub load_DAS_REGION {
  my ( $self, $regionHR ) = @_;
  my ( $sth,  $pgs_aref );

  return undef if ( !defined($regionHR) );

  $pgs_aref = [];
  $self->{dbh}->{FetchHashKeyName} = 'NAME_lc';

  if ( exists( $regionHR->{'xStart'} ) && defined( $self->{'dasREGION_QUERY'} ) ) {
    foreach my $dasQuery ( @{ $self->{dasREGION_QUERY} } ) {
      $sth = $self->{dbh}->prepare_cached($dasQuery);
      eval {
        $sth->bind_param( 1, $regionHR->{'xID'} );
        $sth->bind_param( 2, $regionHR->{'xStart'} );
        $sth->bind_param( 3, $regionHR->{'xStop'} );
        $sth->execute();
        push( @$pgs_aref, @{ $sth->fetchall_arrayref( {} ) } );
      };
    }
  } elsif ( exists( $regionHR->{'xID'} ) && defined( $self->{'dasSEGMENT_QUERY'} ) ) {
    foreach my $dasQuery ( @{ $self->{dasSEGMENT_QUERY} } ) {
      $sth = $self->{dbh}->prepare_cached($dasQuery);
      eval {
        $sth->bind_param( 1, $regionHR->{'xID'} );
        $sth->execute();
        push( @$pgs_aref, @{ $sth->fetchall_arrayref( {} ) } );
      };
    }
  } elsif ( defined( $self->{'das_QUERY'} ) ) {
    foreach my $dasQuery ( @{ $self->{das_QUERY} } ) {
      $sth = $self->{dbh}->prepare_cached($dasQuery);
      $sth->execute();
      push( @$pgs_aref, @{ $sth->fetchall_arrayref( {} ) } );
    }
  } else {
    return undef;
  }
  return $pgs_aref;
}

sub parse_DAS_FEATURES {
  my $self = shift;
  return ( exists( $self->{MOD_parse_DAS_FEATURES} ) ) ? &{ $self->{MOD_parse_DAS_FEATURES} }(@_) : $self->_parse_DAS_FEATURES(@_);
}
sub _parse_DAS_FEATURES { return undef; }    ## ABSTRACT FUNCTION PROTOTYPE

sub getDASTYPE_COUNT {
  my $self = shift();

  return 0;
}

sub getDASTYPES {
  my $self = shift;
  my ( $reqHR, $resultAR ) = @_;

  return $resultAR if(!exists($self->{'das_supported_types'}));

  $resultAR = [] if ( !defined($resultAR) );
  if ( exists( $reqHR->{'segment'} ) ) {
    for ( my $segNDX = 0 ; $segNDX <= $#{ $reqHR->{'segment'} } ; $segNDX++ ) {
      next if ( exists( $reqHR->{'segment'}[$segNDX]->{'UNKNOWN_SEGMENT'} ) );
      foreach my $type (keys %{$self->{'das_supported_types'}}){
	my $typeHR = {'id'=>$type };
	$typeHR->{method} = $self->{'das_supported_types'}->{$type}->{'method'} if(exists($self->{'das_supported_types'}->{$type}->{'method'}));
	$typeHR->{category} = $self->{'das_supported_types'}->{$type}->{'category'} if(exists($self->{'das_supported_types'}->{$type}->{'category'}));

	my $showTYPE = ((defined($xDAS_showTypesOutsideSegment) && $xDAS_showTypesOutsideSegment) 
				||(exists($self->{'xDAS_showTypesOutsideSegment'}) && $self->{'xDAS_showTypesOutsideSegment'})
				||(exists($self->{'das_supported_types'}->{$type}->{'xDAS_showTypesOutsideSegment'}) && $self->{'das_supported_types'}->{$type}->{'xDAS_showTypesOutsideSegment'}))
			? 1 : 0;
	if($showTYPE || exists($self->{'das_supported_types'}->{$type}->{'dasTypeQuery'})){
          if(exists($self->{'das_supported_types'}->{$type}->{'dasTypeQuery'}) && !(exists($self->{'das_supported_types'}->{$type}->{'xDAS_showTypesOutsideSegment'}) && $self->{'das_supported_types'}->{$type}->{'xDAS_showTypesOutsideSegment'})){
	    $typeHR->{content} = $self->getDASTYPE_COUNT($self->{'das_supported_types'}->{$type}->{'dasTypeQuery'});
	  }
    	  if ( defined( $resultAR->[$segNDX] ) ) {
            push( @{ $resultAR->[$segNDX] }, $typeHR );
      	  } else {
            $resultAR->[$segNDX] = [$typeHR];
      	  }
	}
      }
    }
  } else {
    foreach my $type (keys %{$self->{'das_supported_types'}}){
      my $typeHR = {'id'=>$type };
      $typeHR->{method} = $self->{'das_supported_types'}->{$type}->{'method'} if(exists($self->{'das_supported_types'}->{$type}->{'method'}));
      $typeHR->{category} = $self->{'das_supported_types'}->{$type}->{'category'} if(exists($self->{'das_supported_types'}->{$type}->{'category'}));

        my $showTYPE = ((defined($xDAS_showTypesOutsideSegment) && $xDAS_showTypesOutsideSegment) 
                                ||(exists($self->{'xDAS_showTypesOutsideSegment'}) && $self->{'xDAS_showTypesOutsideSegment'})
                                ||(exists($self->{'das_supported_types'}->{$type}->{'xDAS_showTypesOutsideSegment'}) && $self->{'das_supported_types'}->{$type}->{'xDAS_showTypesOutsideSegment'}))
                        ? 1 : 0;
        if($showTYPE || exists($self->{'das_supported_types'}->{$type}->{'dasTypeQuery'})){
          if(exists($self->{'das_supported_types'}->{$type}->{'dasTypeQuery'}) && !(exists($self->{'das_supported_types'}->{$type}->{'xDAS_showTypesOutsideSegment'}) && $self->{'das_supported_types'}->{$type}->{'xDAS_showTypesOutsideSegment'})){
            $typeHR->{content} = $self->getDASTYPE_COUNT($self->{'das_supported_types'}->{$type}->{'dasTypeQuery'});
          }
          if ( defined( $resultAR->[$segNDX] ) ) {
            push( @{ $resultAR->[$segNDX] }, $typeHR );
          } else {
            $resultAR->[$segNDX] = [$typeHR];
          }
        }

    }
  }

  return $resultAR;
}

sub checkDASTYPES {
  my $self = shift;
  return ( exists( $self->{MOD_checkDASTYPES} ) ) ? &{ $self->{MOD_checkDASTYPES} }(@_) : $self->_getDASTYPES(@_);
}

sub _checkDASTYPES { ## GENERALIZED FUNCTION PROTOTYPE
  my ( $self, $typeAR ) = @_;
  return 0 if ( !exists( $self->{'das_supported_types'} ) );
  my $typeName = '';
  my $rtv      = 0;
  foreach $typeName ( keys %{ $self->{'das_supported_types'} } ) {
    $self->{'das_supported_types'}->{$typeName}->{typelist} = 0;
  }
  foreach $typeName (@$typeAR) {
    if ( exists( $self->{'das_supported_types'}->{$type} ) ) {
      $self->{'das_supported_types'}->{$typeName}->{typelist} = 1;
      $rtv = 1;
    }
  }
  return $rtv;
}

sub getDASSEGMENT {
  my $self = shift;
  return ( exists( $self->{MOD_DASSEGMENT} ) ) ? &{ $self->{MOD_DASSEGMENT} }(@_) : $self->_getDASSEGMENT(@_);
}

sub _getDASSEGMENT { return undef; }    ## ABSTRACT FUNCTION PROTOTYPE

sub min { return ( $_[0] < $_[1] ) ? $_[0] : $_[1]; }

sub max { return ( $_[0] > $_[1] ) ? $_[0] : $_[1]; }

# end of package;
1;
