#!/usr/bin/perl
package GSQDB;

use GeneSeqerSequence;

do 'SITEDEF.pl';
do 'xGDB_SUPPORTED_COLORS.pl';

use GenomeView;
use CGI ':all';
use IO::File;

use DBI;

sub new {
  my $class   = shift;
  my ($argHR) = @_;
  my $self    = {};
  $self->{dbid} = ( exists( $argHR->{dbid} ) ) ? $argHR->{dbid} : $#DBver;
  bless $self, ref($class) || $class;
  return $self;
}

sub _initDSO {
  my $self = shift;
  my ( $rsc, $prop, $trackrsc, %DSOprop );
  foreach $rsc (@_) {
    if ( ( !defined( $self->{resourceOBJ}->[$rsc] ) ) && ( defined( $DBver[ $self->{dbid} ]->{tracks}->[$rsc] ) ) ) {
      $trackrsc = $DBver[ $self->{dbid} ]->{tracks}->[$rsc];
      eval "require DSO::$trackrsc->{DSOname}";

      %DSOprop        = ();
      $DSOprop{db_id} = $self->{dbid};
      $DSOprop{resid} = $rsc;

      foreach $prop ( keys %$trackrsc ) {
        $DSOprop{$prop} = $trackrsc->{$prop};
      }

      $DSOprop{db_host}     = ( exists( $trackrsc->{DBhost} ) ) ? $trackrsc->{DBhost} : ( exists( $DBver[ $self->{dbid} ]->{DBhost} ) ) ? $DBver[ $self->{dbid} ]->{DBhost} : $DB_HOST;
      $DSOprop{db_user}     = ( exists( $trackrsc->{DBuser} ) ) ? $trackrsc->{DBuser} : ( exists( $DBver[ $self->{dbid} ]->{DBuser} ) ) ? $DBver[ $self->{dbid} ]->{DBuser} : $DB_USER;
      $DSOprop{db_password} = ( exists( $trackrsc->{DBpass} ) ) ? $trackrsc->{DBpass} : ( exists( $DBver[ $self->{dbid} ]->{DBpass} ) ) ? $DBver[ $self->{dbid} ]->{DBpass} : $DB_PASSWORD;
      $DSOprop{db_name}     = ( exists( $trackrsc->{DB} ) )     ? $trackrsc->{DB}     : $DBver[ $self->{dbid} ]->{DB};
      $DSOprop{dsn} = "DBI:mysql:$DSOprop{db_name}:$DSOprop{db_host}";

##!#!#!#! move this into object level init
      $DSOprop{dbh} = DBI->connect( $DSOprop{dsn}, $DSOprop{db_user}, $DSOprop{db_password}, { RaiseError => 1 } );
##
      $self->{resourceOBJ}->[$rsc] = $trackrsc->{DSOname}->new(%DSOprop);
    }
  }
}

sub _init_external_DSO {
  my $self = shift;
  my ($rsc,$trackrsc) = @_;

  if( !defined( $self->{resourceOBJ}->[$rsc] )){
    eval "require DSO::$trackrsc->{DSOname}";

    %DSOprop        = ();
    $DSOprop{db_id} = $self->{dbid};
    $DSOprop{resid} = $rsc;

    foreach $prop ( keys %$trackrsc ) {
      $DSOprop{$prop} = $trackrsc->{$prop};
    }

    $self->{resourceOBJ}->[$rsc] = $trackrsc->{DSOname}->new(%DSOprop);
  }
}

sub _initALL_DSO {
  my $self = shift;
  $self->_initDSO( 0 .. $#{ $DBver[ $self->{dbid} ]->{tracks} } );
}

sub getDSO {
  my $self = shift;
  my ($argHR) = @_;
  exists( $argHR->{resid} ) || return undef;
  $self->_initDSO( $argHR->{resid} );    ## init DSO for this resource if needed
  return $self->{resourceOBJ}->[ $argHR->{resid} ];
}

sub mergeDynamicDSO {
  my $self = shift;
  my ($argHR,$user_tracks) = @_;

  return 1 if(! (defined($user_tracks) && scalar(@$user_tracks)));

  my @defaultORD = split(',',$DBver[$self->{dbid}]->{trackORD});
  my $rsc = scalar(@defaultORD);
  foreach $trackrsc (@$user_tracks){
    $self->_init_external_DSO($rsc,$trackrsc);
    $rsc++;
  }
}

sub search_by_ID {
  ## unique value lookup
  my $self = shift;
  my ($id) = @_;
  my ( $rsc, $found, $search_path, $results );
  for ( $rsc = 0 ; $rsc < scalar( @{ $DBver[ $self->{dbid} ]->{tracks} } ) ; $rsc++ ) {
    $self->_initDSO($rsc);
    if ( defined( $self->{resourceOBJ}->[$rsc] ) ) {
      ( $found, $search_path ) = $self->{resourceOBJ}->[$rsc]->search_by_ID($id);
      if ($found) {
        return $self->{resourceOBJ}->[$rsc]->showRECORD();
      } else {
        $results .= $search_path;
      }
    }
  }
  return ( undef, $results );
}

sub search_by_MULTIID {
  ## multiple value lookup
  my $self = shift;
  my ($IDaref) = @_;
  my ( $rsc, $tmpc, $tmpg );
  my ( $chrHITCNT, $gsegHITCNT ) = ( 0, 0 );

  for ( $rsc = 0 ; $rsc < scalar( @{ $DBver[ $self->{dbid} ]->{tracks} } ) ; $rsc++ ) {
    $self->_initDSO($rsc);
    if ( defined( $self->{resourceOBJ}->[$rsc] ) ) {
      ( $tmpc, $tmpg ) = $self->{resourceOBJ}->[$rsc]->load_multiID($IDaref);
    }
    $chrHITCNT  += $tmpc;
    $gsegHITCNT += $tmpg;
  }
  return ( $chrHITCNT, $gsegHITCNT );
}

sub search_by_Desc {
  my $self = shift;
  my ($descAR) = @_;
  my ( $rsc, $tmpc, $tmpg );
  my ( $chrHITCNT, $gsegHITCNT ) = ( 0, 0 );

  $self->_initALL_DSO();
  for ( $rsc = 0 ; $rsc < scalar( @{ $DBver[ $self->{dbid} ]->{tracks} } ) ; $rsc++ ) {
    if ( defined( $self->{resourceOBJ}->[$rsc] ) ) {
      ( $tmpc, $tmpg ) = $self->{resourceOBJ}->[$rsc]->search_by_description($descAR);
    }
    $chrHITCNT  += $tmpc;
    $gsegHITCNT += $tmpg;
  }
  return ( $chrHITCNT, $gsegHITCNT );
}

sub findRECORD {
  ## unique value lookup
  my $self = shift;
  my ($argHR) = @_;
  my ( $rsc, $UIDtype, $uid );
  for ( $rsc = 0 ; $rsc < scalar( @{ $DBver[ $self->{dbid} ]->{tracks} } ) ; $rsc++ ) {
    $self->_initDSO($rsc);
    if ( defined( $self->{resourceOBJ}->[$rsc] ) ) {
      ( $UIDtype, $uid ) = $self->{resourceOBJ}->[$rsc]->findRECORD($argHR);
      if ( defined($UIDtype) ) {
        return ( $rsc, $UIDtype, $uid );
      }
    }
  }
  return undef;
}

####Ann added for find version if acc 7/27/09##############
sub findVersion {
  ## unique value lookup
  my $self = shift;
  my ($argHR) = @_;
  my ( $rsc, $UIDtype, $version );
  for ( $rsc = 0 ; $rsc < scalar( @{ $DBver[ $self->{dbid} ]->{tracks} } ) ; $rsc++ ) {    $self->_initDSO($rsc);
    if ( defined( $self->{resourceOBJ}->[$rsc] ) ) {
      ( $UIDtype, $version ) = $self->{resourceOBJ}->[$rsc]->findVersion($argHR);
      if ( defined($UIDtype) ) {
        return ( $rsc, $UIDtype, $version );
      }
    }
  }
  return undef;
}
sub findREGION {
  ## unique value lookup
  my $self = shift;
  my ($argHR) = @_;
  my ( $rsc, $type, $chr, $lpos, $rpos, $url );
  for ( $rsc = 0 ; $rsc < scalar( @{ $DBver[ $self->{dbid} ]->{tracks} } ) ; $rsc++ ) {
    $self->_initDSO($rsc);
    if ( defined( $self->{resourceOBJ}->[$rsc] ) ) {
      ( $type, $chr, $lpos, $rpos, $url ) = $self->{resourceOBJ}->[$rsc]->findREGION($argHR);
      return $url if ( defined($url) );
    }
  }
  return undef;
}

sub showGSQ {
  my $self = shift;
  my ($argHR) = @_;
  exists( $argHR->{resid} ) || return undef;
  $self->_initDSO( $argHR->{resid} );    ## init DSO for this resource if needed
  return $self->{resourceOBJ}->[ $argHR->{resid} ]->getGSQresults($argHR);
}

sub getGsegMenu {
  my $self = shift;
  my ($argHR) = @_;
  exists( $argHR->{GSEGresid} ) || return undef;
  $self->_initDSO( $argHR->{GSEGresid} );
  ### should check to see if this is a GSEG track before requesting listing
  ### Might be able to check for existance of getMENU() function!!!
  return $self->{resourceOBJ}->[ $argHR->{GSEGresid} ]->getMENU($argHR);
}

sub getRegionDetails {
  my $self = shift;
  my ($argHR) = @_;

  my ( $pgsstatHR, $exstatHR, $instatHR, $lgapsHR, $imgHTML ) = $self->getGSQ_REGION( $argHR, "getIMAP_TV" );
  my $gSRC = ( exists( $argHR->{gsegSRC} ) ) ? "$argHR->{gseg_gi}:$argHR->{gsegSRC}" : "$argHR->{chr}:GENOME";
  my $gapped_gseg = GeneSeqerSequence::_getGappedGenomeSeq( $argHR->{dbid}, $gSRC, $argHR->{l_pos}, $argHR->{r_pos}, "+", $lgapsHR );
  my $trackORDER   = exists( $argHR->{trackORDER} )   ? [ split( ',', $argHR->{trackORDER} ) ]   : [ 2, 1, 0 ];
  my $trackVISIBLE = exists( $argHR->{trackVISIBLE} ) ? [ split( ',', $argHR->{trackVISIBLE} ) ] : [ 1, 1, 1 ];
  my $gCONTEXT = ( exists( $argHR->{altCONTEXT} ) ) ? $argHR->{altCONTEXT} : "chr";
  my @qseq = ();
  foreach $rsc (@$trackORDER) {
    if ( $trackVISIBLE->[$rsc] ) {
      next if ( ( !exists( $self->{resourceOBJ}->[$rsc]->{"${gCONTEXT}VIEWABLE"} ) ) || ( $self->{resourceOBJ}->[$rsc]->{"${gCONTEXT}VIEWABLE"} == 0 ) );
      if ( exists( $self->{resourceOBJ}->[$rsc]->{gsqATYPE} ) ) {
        my $tmp = $self->{resourceOBJ}->[$rsc]->getGSQ_aSeqs( $argHR, $lgapsHR, $gapped_gseg );
        push( @qseq, @$tmp );
      } else {    ## still a viewable sequence (annotation perhaps)
      }
    }
  }
  return ( $pgsstatHR, $exstatHR, $instatHR, \@qseq, $gapped_gseg, $imgHTML );
}

sub getUCAimage {
  my $self = shift;
  my ($argHR) = @_;

  my ( $pgsstatHR, $exstatHR, $instatHR, $lgapsHR, $imgHTML ) = $self->getGSQ_REGION( $argHR, "getIMAP_UCA" );
  return ( $pgsstatHR, $exstatHR, $instatHR, undef, undef, $imgHTML );
}

sub getGSQ_REGION {
  my $self = shift;
  my ( $argHR, $DSO_IMAP_FUNCTION ) = @_;
  my ( $trackORDER, $trackVISIBLE, $rsc, $tmp, $lgapsHR, $startY );
  my ( $pgsstatHR, $exstatHR, $instatHR );

  my $gCONTEXT = ( exists( $argHR->{altCONTEXT} ) ) ? $argHR->{altCONTEXT} : "chr";

  require GeneView;
  $imgW   = exists( $argHR->{imgW} ) ? $argHR->{imgW} : 600;
  $imgfn  = "tv$$.png";
  $startY = 15;
  my $view = new GeneView( $imgW, 100, $argHR->{l_pos}, $argHR->{r_pos}, 0 );
  $view->setFontSize( $argHR->{'fontSize'} ) if ( exists( $argHR->{'fontSize'} ) );

  $trackORDER   = exists( $argHR->{trackORDER} )   ? [ split( ',', $argHR->{trackORDER} ) ]   : [ 2, 1, 0 ];
  $trackVISIBLE = exists( $argHR->{trackVISIBLE} ) ? [ split( ',', $argHR->{trackVISIBLE} ) ] : [ 1, 1, 1 ];
  $lgapsHR      = {};
  $pgsstatHR    = {};
  $exstatHR     = {};
  $instatHR     = {};

  foreach $rsc (@$trackORDER) {
    if ( $trackVISIBLE->[$rsc] ) {
      $self->_initDSO($rsc);
      if ( defined( $self->{resourceOBJ}->[$rsc] ) ) {
        next if ( ( !exists( $self->{resourceOBJ}->[$rsc]->{"${gCONTEXT}VIEWABLE"} ) ) || ( $self->{resourceOBJ}->[$rsc]->{"${gCONTEXT}VIEWABLE"} == 0 ) );
        $self->{resourceOBJ}->[$rsc]->loadREGION($argHR);
        if ( exists( $self->{resourceOBJ}->[$rsc]->{gsqATYPE} ) ) {
          ## THIS IS A GeneSeqer DATA SOURCE
          $tmp       = $self->{resourceOBJ}->[$rsc]->getGSQ_pgsStats($argHR);
          $pgsstatHR = { %$pgsstatHR, %$tmp };
          $tmp       = $self->{resourceOBJ}->[$rsc]->getGSQ_exStats($argHR);
          $exstatHR  = { %$exstatHR, %$tmp };
          $tmp       = $self->{resourceOBJ}->[$rsc]->getGSQ_inStats($argHR);
          $instatHR  = { %$instatHR, %$tmp };

          $self->{resourceOBJ}->[$rsc]->combineLGAPS( $argHR, $lgapsHR );
        } else {
          ## see if DSO provides access to standard info
          if ( $tmp = $self->{resourceOBJ}->[$rsc]->get_pgsStats($argHR) ) {
            $pgsstatHR = { %$pgsstatHR, %$tmp };
          }
          if ( $tmp = $self->{resourceOBJ}->[$rsc]->get_exStats($argHR) ) {
            $exstatHR = { %$exstatHR, %$tmp };
          }
          if ( $tmp = $self->{resourceOBJ}->[$rsc]->get_inStats($argHR) ) {
            $instatHR = { %$instatHR, %$tmp };
          }

        }

        ## Draw combined image & return imap hash
        ( $imapHR, $startY ) = $self->{resourceOBJ}->[$rsc]->drawCombinedImage( $view, $startY );
        $startY += 20;    ## Allow vertical margin between DSOs
        $imapHTML .= $self->{resourceOBJ}->[$rsc]->$DSO_IMAP_FUNCTION( $argHR, $imapHR, $pgsstatHR, $exstatHR, $instatHR );
      }
    }
  }
  $view->drawPNG( $TMPDIR . $imgfn );
  $imgHTML = <<END_OF_IMG;
<script>
var structXPosL = new Object();
var structYPos = new Object();
var structWid = new Object();
</script>
<map name='tvmap'>
${imapHTML}
</map>
<img src='${DIR}$imgfn' id='tview' usemap='#tvmap' border='0' />
END_OF_IMG

  return ( $pgsstatHR, $exstatHR, $instatHR, $lgapsHR, $imgHTML );
}

sub showRECORD {
  my $self = shift;
  my ($argHR) = @_;
  exists( $argHR->{resid} ) || return undef;
  $self->_initDSO( $argHR->{resid} );    ## init DSO for this resource if needed
  return $self->{resourceOBJ}->[ $argHR->{resid} ]->showRECORD($argHR);
}

sub showREGION {
  my ($self,$argHR) = @_;
  my ( $rsc, $imgW, $trackORDER, $contextDIV, $inlineJS );
  my ( $tcNAME, $tcCOLOR, $tcHTML, $imgHTML );

  require GeneView;
  $imgW = exists( $argHR->{imgW} ) ? $argHR->{imgW} : 600;

  $trackORDER   = exists( $argHR->{trackORDER} )   ? [ split( ',', $argHR->{trackORDER} ) ]   : [ 3, 2, 1, 0 ];

  $contextDIV = "<div class='context_region'>  <!-- Context region div START -->\n";

  $inlineJS = <<END_OF_JS;
	\$('#wsize_$argHR->{wsize}').addClass('current');
	\$('#fontSize_$argHR->{fontSize}').addClass('current');
END_OF_JS

  if ( !exists( $argHR->{altCONTEXT} ) || ( $argHR->{altCONTEXT} =~ /^chr$/i ) ) {
    my $rulerfn = "ruler$$.png";
    my $viewruler = new GeneView( $imgW, 35, $argHR->{l_pos}, $argHR->{r_pos}, 0 );
    $viewruler->setFontSize( $argHR->{'fontSize'} ) if ( exists( $argHR->{'fontSize'} ) );
    $viewruler->drawPNG( $TMPDIR . $rulerfn );
    $inlineJS .= <<END_OF_JS;
	\$(".context_region").bind('sortupdate',function(event,ui) {
		var sortOrder = \$(".context_region").sortable('toArray').join();
		\$.get('${CGIPATH}xGDBupdateSession.pl',{'track-reorder':sortOrder});
	});
END_OF_JS

    $header = $self->getContextRulerHeaderCtrlDIV($argHR);
    $contextDIV .= "\t<div class='context_ruler'>\n\t\t<div class='context_ruler_header'>\n\t\t\t${header}\n\t\t</div>\n\t\t<div class='context_track_image'>\n\t\t\t<img src='${DIR}${rulerfn}' />\n\t\t</div>\n\t</div>\n";
  }
  $self->_initALL_DSO();
#<DEBUG>#print STDERR "[GSQDB.pm::showREGION] preparing to draw tracks with trackORDER = " . join(',',@$trackORDER) . "\n";
  foreach $rsc (@$trackORDER) {
#<DEBUG>
#	print STDERR "[GSQDB.pm::showREGION] rsc => $rsc \n";
    if ( defined( $self->{resourceOBJ}->[$rsc] ) ) {
      if ( exists( $argHR->{altCONTEXT} ) && ( $argHR->{altCONTEXT} !~ /^chr$/i ) ) {
        if ( $self->{resourceOBJ}->[$rsc]->{DSOname} eq $argHR->{altCONTEXT} ) {
          my $imgfn = "GSEGruler_$self->{dbid}_" . join( '-', @$argHR{ 'gseg_gi', 'l_pos', 'r_pos', 'fontSize', 'imgW' } ) . "_GC.png";
          ( $imgHTML, $imgNAME, $imgIMAP ) = $self->{resourceOBJ}->[$rsc]->draw_GSEG_RULER( $argHR, { name => "GSEGimage" }, $imgfn, undef );
    	  $inlineJS .= <<END_OF_JS;
	\$(".context_region").bind('sortupdate',function(event,ui) {
		var sortOrder = "${rsc}," + \$(".context_region").sortable('toArray').join();
		\$.get('${CGIPATH}xGDBupdateSession.pl',{'track-reorder':sortOrder});
	});
END_OF_JS

    	  $header = $self->getContextRulerHeaderCtrlDIV($argHR);
    	  $contextDIV .= "\t<div id='$rsc' class='context_ruler'>\n\t\t<div class='context_ruler_header'>\n\t\t\t${header}\n\t\t</div>\n\t\t<div class='context_track_image'>\n\t\t\t${imgHTML}\n\t\t</div>\n\t</div>\n";
        }
        next if ( ( !exists( $self->{resourceOBJ}->[$rsc]->{ $argHR->{altCONTEXT} . "VIEWABLE" } ) ) || ( $self->{resourceOBJ}->[$rsc]->{ $argHR->{altCONTEXT} . "VIEWABLE" } == 0 ) );
      } else {
        next if ( ( !exists( $self->{resourceOBJ}->[$rsc]->{chrVIEWABLE} ) ) || ( $self->{resourceOBJ}->[$rsc]->{chrVIEWABLE} == 0 ) );
      }

      ( $tcNAME, $tcCOLOR, $tcHTML, $imgHTML, $imgNAME, $imgIMAP ) = $self->{resourceOBJ}->[$rsc]->queryREGION( $argHR, { name => "image${x}" } );
      $tcCOLOR = $self->getRGB_color($SUPPORTED_COLORS{$tcCOLOR});

      my $trackToggleClass = 'cth-toggle';
      my $trackHeaderToggleClass = 'context_track_header';
      my $trackInitStyle   = '';

      if(exists($argHR->{trackPREFS}) &&
	exists($argHR->{trackPREFS}->[$rsc]) &&
	exists($argHR->{trackPREFS}->[$rsc]->{toggled}) &&
	$argHR->{trackPREFS}->[$rsc]->{toggled}){
		$trackHeaderToggleClass = 'context_track_header toggle-up';
		$trackToggleClass = 'cth-toggle toggle-up';
		$trackInitStyle = "style='display:none;'";
	}

      $contextDIV .= <<END_OF_CONTENT;
	<div id='$rsc' class='context_track'>
		<div class='$trackHeaderToggleClass' style='display:block;'>
			<div class='$trackToggleClass'>&nbsp;</div>
			<div class='cth-track-name' style='display:inline;'>$tcNAME</div>
			<div style='display:inline;'>$tcHTML</div>
		</div>
		<div class='context_track_image' ${trackInitStyle}>
			${imgHTML}
		</div>
	</div>

END_OF_CONTENT

    }
  }
  $contextDIV .= "<script type='text/javascript'>\n$inlineJS</script>\n</div> <!-- Context region div END -->\n";

  return $contextDIV;
}

sub getContextRulerHeaderCtrlDIV{
  my ($self,$argHR) = @_;
  my $ctrl='';
 
  $ctrl .= <<END_OF_CTRL;
<input type="text" name="fontSize" value="$argHR->{fontSize}" class='debug' />
END_OF_CTRL


 # do 'xgdb-custom-browser-menu.pl'; # 4-30-14 JPD
  my $menuAR = $self->stdContextRulerHeaderCtrlMenu($argHR);
	#$menuAR->[1]->{menu}->[0]->{attrHR}->{onclick} = "showAltTRANS();";
  #&customizeCRHmenu($menuAR,$argHR) if(defined(&customizeCRHmenu));
  my $menuHTML = $self->createMenuHTML({id => "CRHmenu", class => "sf-menu xgdb-menu"},$menuAR);

  my $buttonAR = [];
  #&customizeCRHbuttons($buttonAR,$argHR) if(defined(&customizeCRHbuttons));
  my $buttonHTML = $self->createMenuHTML({id => "CRHbuttons", class => "sf-menu xgdb-crh-button"},$buttonAR);

  my $coord_ctrl = <<END_OF_CTRL;

<div id='CRH_coord_ctrl' style='min-width: 100px'>
<ul id='title' class='sf-menu'>
<li class=" nowrap largerfont bold" style="width:160px; background: white; color:#E87C00; margin: 2px 0 0 5px; border:none">Genome region: <img id='genome_submenu' class='xgdb-help-button' src='/XGDB/images/help-icon.png' alt='?' /> &nbsp;</li>
</ul>
<img border='0'  title = 'Jump left by half a span' class='CTR_ctrl' style='vertical-align:middle; float:left;' src="${GUIPATH}CRNAVleft.png" onmouseover="this.src='${GUIPATH}CRNAVleftmo.gif'" onmouseout="this.src='${GUIPATH}CRNAVleft.png'" onclick="jumpLEFT();">
<ul id='zoom_menu' class='sf-menu CTR_ctrl'>
  <li class='ui-corner-all'>Zoom
    <ul>
      <li id='wsize_0' onclick='setWINDOW(0);'>1 kb</li>
      <li id='wsize_1' onclick='setWINDOW(1);'>2 kb</li>
      <li id='wsize_2' onclick='setWINDOW(2);'>5 kb</li>
      <li id='wsize_3' onclick='setWINDOW(3);'>10 kb</li>
      <li id='wsize_4' onclick='setWINDOW(4);'>20 kb</li>
      <li id='wsize_5' onclick='setWINDOW(5);'>50 kb</li>
      <li id='wsize_6' onclick='setWINDOW(6);'>100 kb</li>
      <li id='wsize_7' onclick='setWINDOW(7);'>150 kb</li>
    </ul>
  </li>
</ul>
<img border='0'  title = 'Jump right by half a span' class='CTR_ctrl' style='vertical-align:middle;' src="${GUIPATH}CRNAVright.png" onmouseover="this.src='${GUIPATH}CRNAVrightmo.gif'" onmouseout="this.src='${GUIPATH}CRNAVright.png'" onclick="jumpRIGHT();">
</div>
END_OF_CTRL

  $ctrl .= <<END_OF_CTRL;

$coord_ctrl

$menuHTML

$buttonHTML

<div id='addTrackDialog' title='Add a Feature Track'></div>

END_OF_CTRL

}

sub createMenuHTML {
  my ($self,$menuAttrHR,$menuAR) = @_;
  my $menuHTML = "";

  for( my $ndx=0; $ndx <= $#$menuAR; $ndx++){
    my $menuHR = $menuAR->[$ndx];
    my $menuId = exists($menuAttrHR->{id})?$menuAttrHR->{id}:"rootMenu";
    if(exists($menuHR->{menu})){
      my $submenuId = exists($menuHR->{menu_id})?$menuHR->{menu_id}:"${menuId}_${ndx}";
      $menuHR->{content} .= "\n" . $self->createMenuHTML({id => $submenuId},$menuHR->{menu});  
    }
    $menuHTML .= (exists($menuHR->{attrHR}))? exists($menuHR->{content})? li($menuHR->{attrHR},$menuHR->{content}) : li($menuHR->{attrHR},'') :
                                              exists($menuHR->{content})? li($menuHR->{content}) : li(''); 
    $menuHTML .= "\n";
  }
  return ul($menuAttrHR,"\n$menuHTML") . "\n";
}

sub stdContextRulerHeaderCtrlMenu {
  my ($self,$argHR) = @_;

#print STDERR ">> $argHR->{gseg_acc} \n";
 my $mySRC = ($argHR->{altCONTEXT} eq 'BAC')? $GSEG_SRC : $SRC; 
 my $myType = ($argHR->{altCONTEXT} eq 'BAC')? 'BAC' : 'chr'; 
  my $segment = ($argHR->{altCONTEXT} eq 'BAC')? $argHR->{gseg_gi} : $argHR->{chr};
  #$segment = ($argHR->{altCONTEXT} eq 'BAC')? $argHR->{acc} : $argHR->{chr};
  $GSEG_SRC = (defined($GSEG_SRC))? $GSEG_SRC : "GENOME";
  return [
		{	content => "<a> Annotate </a>",
			attrHR => { class => "ui-corner-top" },
			menu_id => "annotate_menu",
			menu    => [
			        { attrHR => { onclick => "doAnnotation('$myType','$mySRC');" }, content => "<a title=\"Re-annotate this region using yrGATE Annotation Tool\">yrGATE</a>" },
				#{
                                #content => "<a target='_blank' href='${GSQwebpath}&DNAid=$segment&DNAstart=$argHR->{l_pos}&DNAend=$argHR->{r_pos}'>GeneSeqer</a>"
                                #},
				{
					content => "<a title='Annotate this region using the CpGAT tool' target='_blank' href='${CGIPATH}WebCpGAT.pl?DNAid=$segment&DNAstart=$argHR->{l_pos}&DNAend=$argHR->{r_pos}'>CpGAT</a>"
					},
			        {
			        content => "<a  title='Splice align a protein dataset to this genome region using GenomeThreader'  target='_blank' href='${GTHwebpath}&DNAid=$segment&DNAstart=$argHR->{l_pos}&DNAend=$argHR->{r_pos}'>GenomeThreader</a>"
			        },
			           ],
		},
		{	content => "<a> BLAST</a>",
			attrHR => { class => "ui-corner-top" },
			menu_id => "blast_menu",
			menu    => [
			            {	
					content => "<a href='${CGIPATH}blastGDB.pl?db=$GSEG_SRC&dbid=$argHR->{dbid}&hits=${segment}:$argHR->{l_pos}:$argHR->{r_pos}'>BLAST $xGDB</a>"
			            },
			            
					{ content => "<a href='${CGIPATH}blastAllGDB.pl?db=$GSEG_SRC&dbid=$argHR->{dbid}&hits=${segment}:$argHR->{l_pos}:$argHR->{r_pos}'>BLAST all GDBs</a>"
			            },			            
			           ],
		},
		{	content => "<a>Download</a>",
			attrHR => { class => "ui-corner-top" },
			menu_id => 'download_menu',
			menu => [
			{content => "<a title='Download FASTA sequence or annotation data from this region' href='${CGIPATH}downloadGDB.pl?db=$GSEG_SRC&dbid=$argHR->{dbid}&hits=${segment}:$argHR->{l_pos}:$argHR->{r_pos}'>Sequence Data</a>"},
			],
		},
#{content => "<span class='bold' style='font-size:14px; border:1px white'>&nbsp; &nbsp; Configure: &nbsp;</span>", attrHR => { style => "border:none; background-color:white" },
#		},
		
		
		{	content => "<a> Format</a>",
			attrHR => { class => "ui-corner-top" },
			menu_id => 'configure_menu',
			menu    => [

#				    {	attrHR  => {	onclick => "" },
#					content => "<a title='Remove CpGAT track permanently' href='${CGIPATH}getRegion.pl?dbid=$argHR->{dbid}&gseg_gi=$segment&l_pos=$argHR->{l_pos}&r_pos=$argHR->{r_pos}&CpGATFlag=1'>Remove CpGAT</a>",
#			            }, 
				    {	content => "<a>Font Size</a>",
					menu_id => 'font_size_menu',
					menu    => [
						    {	attrHR  => {	id=>'fontSize_1', onclick => "document.guiFORM.fontSize.value=1; document.guiFORM.submit();",
							           },
							content => "<a><img src='${IMAGEDIR}font1.png'> Tiny</a>",
					            },
						    {	attrHR  => {	id=>'fontSize_2',onclick => "document.guiFORM.fontSize.value=2; document.guiFORM.submit();",
							           },
							content => "<a><img src='${IMAGEDIR}font2.png'> Small</a>",
					            },
						    {	attrHR  => {	id=>'fontSize_3',onclick => "document.guiFORM.fontSize.value=3; document.guiFORM.submit();",
							           },
							content => "<a><img src='${IMAGEDIR}font3.png'> Medium</a>",
					            },
						    {	attrHR  => {	id=>'fontSize_4',onclick => "document.guiFORM.fontSize.value=4; document.guiFORM.submit();",
							           },
							content => "<a><img src='${IMAGEDIR}font4.png'> Large</a>",
					            },
					           ],
			            },
				#    {	attrHR  => {	class => "ui-state-disabled" },
				#	content => "<a>Show Grid</a>"
			        #    },
			],
		},

		{	content => "<a> Add Track</a>",
			attrHR => { class => "ui-corner-top" },
			menu_id => 'configure_menu',
			menu    => [
				    {	attrHR  => {	onclick => "\$('\#addTrackDialog').dialog('open');" },
					content => "<a>from GFF3</a>",
			            },

				    {	attrHR  => {	onclick => "\$('\#addTrackDialog').dialog('open');" },
					content => "<a>from DAS</a>",
			            },
#				    {	attrHR  => {	onclick => "" },
#					content => "<a title='Remove CpGAT track permanently' href='${CGIPATH}getRegion.pl?dbid=$argHR->{dbid}&gseg_gi=$segment&l_pos=$argHR->{l_pos}&r_pos=$argHR->{r_pos}&CpGATFlag=1'>Remove CpGAT</a>",
#			            }, 

				#    {	attrHR  => {	class => "ui-state-disabled" },
				#	content => "<a>Show Grid</a>"
			        #    },
			],
		},
		{	content => "<a> Nucleotide Level </a>",
			attrHR => { class => "ui-corner-top" },
			menu_id => "view_menu",
			menu    => [
			            {	attrHR  => {	onclick => "showAltTRANS();" },
					content => "<a> Show Clusters</a>", ### need to do something about showAltTRANS/showTRANS redundancy ###
			            },
			           ],
		},
	
	 ];
}

sub AddTrackBotton{
        my ($self,$argHR) = @_;
        my $ctrl='';

        $ctrl .= <<END_OF_CTRL;
        <input type="text" name="fontSize" value="$argHR->{fontSize}" class='debug' />
END_OF_CTRL
#        do 'xgdb-custom-browser-menu.pl';
        my $menuAR = $self->AddTrackMenu($argHR);
        my $menuHTML = $self->createMenuHTML({id => "CRHmenu", class => "sf-menu xgdb-menu"},$menuAR);
        my $buttonAR = [];
        my $buttonHTML = $self->createMenuHTML({id => "CRHbuttons", class => "sf-menu xgdb-crh-button"},$buttonAR);
        $ctrl .= <<END_OF_CTRL;
        $menuHTML
        $buttonHTML
        <div id='addTrackDialog' title='Add a Feature Track'></div>
END_OF_CTRL

}
sub AddTrackMenu {
        my ($self,$argHR) = @_;
                return [
                                    {   attrHR  => {    onclick => "\$('\#addTrackDialog').dialog('open');", class => "button_rounded"},
                                        content => "<a>Add User Track</a>",
                                    },
                ];
}

sub getRGB_color {
  my $self = shift;
  my ($colorAR) = @_;
  my $hex = "#";
  for(my $x=0;$x<3;$x++){
    my $tmp=sprintf("%lx",$colorAR->[$x]);
    $hex .= ($tmp eq '0')?'00':$tmp;
  }
  return $hex;
}

sub showSTRUCT {
}

sub showMULTILOCUS {
## Assumes each OBJ defines a $self-{chrMULTILOCI_href} containing pertinent records
  my $self = shift;
  my ($argHR) = @_;
  my ( $rscORDER, $rsc, $tmp, $hitlist, @MLTableCol );
  my ( $mlociMapInfo, $mlociTableInfo );

  $rscORDER = exists( $argHR->{rscORDER} ) ? [ split( ',', $argHR->{rscORDER} ) ] : [ 0 .. $#{ $self->{resourceOBJ} } ];

  $hitlist = [];
  foreach $rsc (@$rscORDER) {
    if ( defined( $self->{resourceOBJ}->[$rsc] ) ) {
      $self->{resourceOBJ}->[$rsc]->getMULTILOCI( { LOCIhitlist => $hitlist } );
      $tmp = $self->{resourceOBJ}->[$rsc]->showMULTILOCI_TABLE($argHR);
      if (    ( length( $MLTableCol[0] ) < ( 0.5 * length( $MLTableCol[1] ) ) )
           || ( ( length( $MLTableCol[0] ) + length($tmp) ) < ( 1.25 * length( $MLTableCol[1] ) ) ) )
      {
        $MLTableCol[0] .= $tmp;
      } else {
        $MLTableCol[1] .= $tmp;
      }
    }
  }

  $mlociMapInfo = $self->showHITMAP( $#DB, $hitlist, { align => 'center' } );
  $mlociTableInfo = table( Tr( { valign => 'top' }, [ td( \@MLTableCol ) ] ) );

  return ( $mlociMapInfo, $mlociTableInfo );
}

sub showHITMAP {
  ##$$ NEED TO ALTER FN TO ALLOW CGI ARGS FOR AREA AND IMG TAGS
  my $self = shift;
  my ( $dbID, $hitLIST, $imgPHR ) = @_;

  my $imgMapInfo = "\n" . '<map name="map_HM">' . "\n";
  my $view = new GenomeView( 350, 225, $DBver[$dbID]->{chrSIZE}, $DBver[$dbID]->{centLOC} );
  my ( $j, @rect );
  for ( $j = 0 ; $j <= $#$hitLIST ; $j++ ) {
    ## my ($pCHR,$lpos,$color,$link) = @{$hitLIST->[$j]}
    @rect = $view->addRect( @{ $hitLIST->[$j] }[ 0 .. 2 ] );

    $imgMapInfo .= '<area shape="rect" coords="' . join( ',', @rect ) . '" href="' . $hitLIST->[$j]->[3] . '" />' . "\n";
  }
  my $imgfn = "tmp${$}HM" . '.png';
  $view->drawPNG( $TMPDIR . $imgfn );
  $imgMapInfo .= "</map>\n" . img( { align => 'left', width => 350, height => 225, src => "${DIR}${imgfn}", usemap => '#map_HM', %$imgPHR } );

  return $imgMapInfo;
}

#######################################################################
#######################################################################

sub validateLOGIN {
  my ( $self, $Lid, $pwd ) = @_;
  my %attr = ( PrintError => 0, RaiseError => 0 );
  my $ANNdbh   = DBI->connect( $USER_AUTH_DB, $USER_AUTH_USER, $USER_AUTH_PASS, \%attr );
  my $SQLquery = "SELECT ACCgroup FROM users WHERE (USERid = \"$Lid\") && (Upass = \"$pwd\")";

  my $sth = $ANNdbh->prepare($SQLquery);
  $sth->execute();
  my @arr = $sth->fetchrow_array();
  if ( scalar(@arr) ) {
    $rtv = $arr[0];
  } else {
    $rtv = -1;    # no entry with this user pass combo
  }
  print STDERR "$ANNdsn\n$SQLquery\n";
  $sth->finish();
  $ANNdbh->disconnect();
  return $rtv;
}

sub retrieveUser {
  my ( $self, $type, $value ) = @_;
  my %attr = ( PrintError => 0, RaiseError => 0 );
  my $ANNdbh = DBI->connect( $USER_AUTH_DB, $USER_AUTH_USER, $USER_AUTH_PASS, \%attr );
  my $SQLquery = "";
  if ( $type == 0 ) {
    $SQLquery = "SELECT USERid,Upass,email FROM users WHERE (USERid = \"$value\")";
  } elsif ( $type == 1 ) {
    $SQLquery = "SELECT USERid,Upass,email FROM users WHERE (email = \"$value\")";
  }
  my $sth = $ANNdbh->prepare($SQLquery);
  $sth->execute();
  my @arr = $sth->fetchrow_array();
  if ( scalar(@arr) ) {
    my $msg = "A request has been made from the $SITENAMEshort webservice to retrieve the login information associated with this email address.\n\n";
    $msg .= "LOGIN: $arr[0] \nPASSWORD: $arr[1]\n";
    my $TMP_FILE = tmpnam( 'tmpLOGIN', '.req' );
    open( TMP, ">$TMP_FILE" );
    print TMP "$msg\n\n";
    close(TMP);
    my $SYScmd = "mail -s $SITENAMEshort login information $arr[2] < $TMP_FILE";
    `$SYScmd`;
    unlink $TMP_FILE;
    $rtv = 1;
  } else {
    $rtv = 0;    # no entry with this value
  }
  return $rtv;
}

sub isAdmin {
  my ( $self, $Lid ) = @_;
  my %attr = ( PrintError => 0, RaiseError => 0 );
  my $ANNdbh   = DBI->connect( $USER_AUTH_DB, $USER_AUTH_USER, $USER_AUTH_PASS, \%attr );
  my $SQLquery = "SELECT ACCgroup FROM users WHERE (USERid = \"$Lid\")";
  my $sth      = $ANNdbh->prepare($SQLquery);
  $sth->execute();
  my @arr = $sth->fetchrow_array();
  if ( ( scalar(@arr) ) && ( $arr[0] eq 'ADMIN' ) ) {
    return 1;
  } else {
    return 0;
  }
}

sub registerUSER {
  my ( $self, $Lid, $pwd, $email, $phone, $fullname ) = @_;
  my %attr = ( PrintError => 0, RaiseError => 0 );
  my $ANNdbh    = DBI->connect( $USER_AUTH_DB, $USER_AUTH_USER, $USER_AUTH_PASS, \%attr );
  my $SQLquery  = "SELECT APPcount FROM users WHERE (USERid = \"$Lid\")";
  my $SQLquery2 = "SELECT APPcount FROM users WHERE (email = \"$email\")";
  my $sth       = $ANNdbh->prepare($SQLquery);
  $sth->execute();
  my @arr = $sth->fetchrow_array();
  $sth = $ANNdbh->prepare($SQLquery2);
  $sth->execute();
  my @arr2 = $sth->fetchrow_array();

  if ( scalar(@arr) ) {
    $rtv = 0;    #login id already taken
  } elsif ( scalar(@arr2) ) {
    $rtv = -1;    #email taken
  } else {
    $SQLquery = "INSERT INTO users VALUES (\"$Lid\",\"$pwd\",0,\"$email\",\"$phone\",\"$fullname\",\"USER\")";
    $ANNdbh->do($SQLquery);
    $rtv = 1;
  }
  $sth->finish();
  $ANNdbh->disconnect();
  return $rtv;
}

sub updateUSER {
  my ( $self, $Lid, $pwd, $email, $phone, $fullname ) = @_;
  my %attr = ( PrintError => 0, RaiseError => 0 );
  my $ANNdbh   = DBI->connect( $USER_AUTH_DB, $USER_AUTH_USER, $USER_AUTH_PASS, \%attr );
  my $SQLquery = "SELECT APPcount FROM users WHERE (USERid != \"$Lid\")&&(email = \"$email\")";
  my $sth      = $ANNdbh->prepare($SQLquery);
  $sth->execute();
  my @arr = $sth->fetchrow_array();
  if ( ($email) && ( scalar(@arr) ) ) {
    $rtv = 0;    #email not unique to this user
  } else {
    $SQLquery = "UPDATE users SET ";
    if ($pwd) {
      $SQLquery .= "Upass=\"$pwd\",";
    }
    if ($email) {
      $SQLquery .= "email=\"$email\",";
    }
    if ($phone) {
      $SQLquery .= "phone=\"$phone\",";
    }
    if ($fullname) {
      $SQLquery .= "fullname=\"$fullname\",";
    }
    chop($SQLquery);
    $SQLquery .= " WHERE (USERid = \"$Lid\")";
    $ANNdbh->do($SQLquery);
    $ANNdbh->disconnect();
    $rtv = 1;
  }
  return $rtv;
}

#######################################################################
#######################################################################
sub checkSegment {
  my $self = shift;
  my ($id,$start,$stop,$featReqHR) = @_;

  if ( !exists( $self->{primaryDBH} ) ) {
    my $pDBNAME = $DBver[ $self->{dbid} ]->{DB};
    my $pDBHOST = exists( $DBver[ $self->{dbid} ]->{DBhost} ) ? $DBver[ $self->{dbid} ]->{DBhost} : $DB_HOST;
    my $pDBUSER = exists( $DBver[ $self->{dbid} ]->{DBuser} ) ? $DBver[ $self->{dbid} ]->{DBuser} : $DB_USER;
    my $pDBPASS = exists( $DBver[ $self->{dbid} ]->{DBpass} ) ? $DBver[ $self->{dbid} ]->{DBpass} : $DB_PASSWORD;

    $self->{primaryDBH} = DBI->connect( "DBI:mysql:${pDBNAME}:${pDBHOST}", $pDBUSER, $pDBPASS, { PrintError => 0, RaiseError => 0 } );
  }

  my  $xID_HR = (defined($start))?
	$self->{primaryDBH}->selectall_hashref("SELECT xID,start,stop FROM segments WHERE (alias LIKE \"$id\")&&(start <= $stop) && (stop >= $start)","xID") :
	$self->{primaryDBH}->selectall_hashref("SELECT xID,start,stop FROM segments WHERE (alias LIKE \"$id\")","xID");

  #### !!!!!
  ## also check the GSEG DSO's for segment ids (non-aliases)
  if(!defined($xID_HR) || !scalar(keys(%$xID_HR))){ ##!#!#!#!##!!##!##!#!#!#!
    $xID_HR = {$id => { xID => $id, start=>1, stop=>$stop}};
  }
  #### !!!!!

  if(!defined($xID_HR) || !scalar(keys(%$xID_HR))){ 
    push( @{ $featReq->{'segment'} }, { 'id' => $segid, 'start' => $start, 'stop' => $stop, 'UNKNOWN_SEGMENT' => 1 } );
    return 0;
  }

  $featReqHR->{'segment'} = [] if(!exists($featReqHR->{'segment'}));
  foreach my $xID ( keys(%$xID_HR)){
    my $xStart = $start - $xID_HR->{$xID}->{start} + 1;
    my $xStop = $stop - $xID_HR->{$xID}->{start} + 1;
    push( @{ $featReqHR->{'segment'} }, { 'id' => $id, 'start' => $start, 'stop' => $stop, 'xID' => $xID, 'xStart'=>$xStart, 'xStop'=>$xStop, 'version' => '1.0', 'label' => $xID } );

#<DEBUG>#  print STDERR "$id : $start : $stop : $xID : $xStart : $xStop \n";
  }

  return ( scalar(keys(%$xID_HR)) );
}

sub getSequence {
  my ( $self, $db, $dbid, $seqAR ) = @_;
  my ( $indx, %seqs, @SeqResults );

  $dbid = $#DBver if ( $dbid < 0 );

  if ( $db eq 'GENOME' ) {
    open( SR, $DBver[$dbid]->{seqFILE} ) || return undef;
    for ( my $x = 0 ; $x <= $#$seqAR ; $x++ ) {
      my ( $chr, $lft, $rgt ) = $seqAR->[$x] =~ /^([^:]*):(\d+):(\d+)/;
      if ( $chr =~ /.*chr(\d+)/ ) { $chr = $1; }
      seek( SR, ( $DBver[$dbid]->{genomeST}->[ ( $chr - 1 ) ] + $lft - 1 ), 0 );
      read( SR, $seqs, $rgt - $lft + 1 );
      $seqs =~ s/(.{70})/$1\n/g;
      $indx = defined($#SeqResults) ? ( $#SeqResults + 1 ) : 0;
      $SeqResults[$x] = ">${LATINORGN} chromosome $chr $DBver[$dbid]->{DBtag} bases $lft - $rgt\n$seqs";
    }
    close(SR);
  } else {
	my $tmpfn = "${TMPDIR}tmp$$" . '.lst';
    open( TMP, ">$tmpfn" ) || die;
    foreach ( sort { return $a cmp $b; } @{$seqAR} ) {
      if ( /^([^:]*:\d+:\d+):(\d+):(\d+)/ or /^([^:]*):(\d+):(\d+)/ ) {
        $seqs{$1} = ( $2 == 0 ) ? ( $3 == 0 ) ? [ 0, 0 ] : [ 1, $3 ] : [ $2, $3 ];
        print TMP $1 . "\n";
      } else {
        $seqs{$_} = [ 0, 0 ];
        print TMP $_ . "\n";
      }
    }
    close TMP;
#	my $cmd = $FASTACMD . " -d $BLAST_DB{$db}->[1] -i $tmpfn";
	my $cmd = "/usr/local/bin/blastdbcmd -db $BLAST_DB{$db}->[1] -entry_batch $tmpfn";
       print STDERR "lkkkkkkkkkkkkkkkkkkkk $cmd kkkkkkkkk\n";
       $seqs = `$cmd`;

    @results = split( /^>/, $seqs );
    foreach (@results) {
      if ( $_ ne '' ) {
        $indx = defined($#SeqResults) ? ( $#SeqResults + 1 ) : 0;
        @line = split( '\n', $_ );
        $processed = 0;
        foreach $seqid ( split( /[\s\|]/, $line[0] ) ) {
	print STDERRO "$seqid MMMMMMMM \n";
          if ( exists( $seqs{$seqid} ) ) {
            if ( $seqs{$seqid}->[0] == 0 ) {
              $SeqResults[$indx] = ">$_";
            } else {
              $lineLength = length( $line[1] );
              $sequence = join( '', @line[ 1 .. $#line ] );
              $sequence =~ s/\s+//g;
              $mod_seq = substr( $sequence, ( $seqs{$seqid}->[0] - 1 ), ( $seqs{
$seqid}->[1] - $seqs{$seqid}->[0] + 1 ) );
              $mod_seq =~ s/(.{$lineLength})/$1\n/g;
	$region = "(bases $seqs{$seqid}->[0] - $seqs{$seqid}->[1])";
              $line[0] =~ s/^(\S+)/>$1 $region/;
              $SeqResults[$indx] = "$line[0]\n$mod_seq";
            }
            $processed = 1;
          }
        }

        # print STDERR "[GSQDB::getSequence] ERROR with $line[0]\n" if(! $processed);
      }
    }
  }
  return \@SeqResults;
}

sub doBLASTcomparePrompt {
  my ( $self, $seq ) = @_;
  my $name   = '';
  my $evalue = '1e-20';    #added by usha
  if ( $seq =~ /^>([^\n]*)/ ) { $name = $1; }

  my $PAGE =
"<h1>Compare BLAST Searca</h1>"   . p('1. Select BLAST program and database:')
    . table( { -class => 'gdb_blast' },
             TR( { -align => 'left' }, th('Query name (optional)'), th('Program'), th('Database') ),
             TR(
                 td(
                     textfield(
                                -name  => 'name',
                                -value => $name
                     )
                 ),
                 td(
                     popup_menu(
                                 -name    => 'program',
                                 -value   => [qw/blastn blastp blastx tblastn/],
                                 -default => 'blastn'
                     )
                 )
	),
		TR(
		),
		TR( { -align => 'left' }, th('DBtype'), th('peptide DB'), th('nucleotide DB'),th('genome DB')),
		TR(
		td(
                        radio_group(
                                -name => 'DBtype',
                                -values => ['peptide','transcript','genome'],
                                -default => 'transcript'
                        )
                ),
		td(
                        popup_menu(
                                 -name    => 'PDB',
                                 -value   => [keys %COMPARE_PDB],
                                 -default => 'ATpep'
                        )
                   ),
		td(
                        popup_menu(
                                 -name    => 'TDB',
                                 -value   => [keys %COMPARE_TDB],
                                 -default => 'ATcds'
                        )
                    ),
		td(
                        popup_menu(
                                 -name    => 'genomeDB',
                                 -value   => [keys %COMPARE_genomeDB],
                                 -default => 'ATgenome'
                        )
                    ) 
	),
    )
    . p('2. Paste query sequence (raw or FASTA format):')
    . br;    ##Labels for DB description - Usha
  if ($seq) {
    $PAGE .= textarea( -name => 'sequence', -align => 'left', -rows => 8, -cols => 80, -wrap => 'virtual', -value => $seq ) . br;
  } else {
    $PAGE .= textarea( -name => 'sequence', -align => 'left', -rows => 8, -cols => 80, -wrap => 'virtual' ) . br;
  }
  $PAGE .= p("Or upload query sequence: ") . filefield( -name => 'upload', -size => 40, class => 'inputBox' ) . p("E-value for Blast ") . textfield( -name => 'evalue', -value => $evalue ) . br .    #added by usha
    submit( -name => 'runBLAST', -value => 'Run BLAST' ) . reset();
  return $PAGE;
}

sub doBLASTprompt {
  my ( $self, $seq ) = @_;
  my $name   = '';
  my $evalue = '1e-20';    #added by usha
  if ( $seq =~ /^>([^\n]*)/ ) { $name = $1; }

  my $PAGE =
"<h1>BLAST Search</h1>"   . p('1. Select BLAST program and database:')
    . table( { -class => 'gdb_blast' },
             TR( { -align => 'left' }, th('Query name (optional)'), th('Program'), th('Database') ),
             TR(
                 td(
                     textfield(
                                -name  => 'name',
                                -value => $name
                     )
                 ),
                 td(
                     popup_menu(
                                 -name    => 'program',
                                 -value   => [qw/blastn blastp blastx tblastn/],
                                 -default => 'blastn'
                     )
                 ),
                 td(
                     popup_menu(
                                 -name    => 'db',
                                 -value   => [ keys %BLAST_DB ],
                                 -default => 'ATest',
                                 -labels  => \%BLAST_DB_DESC
                     )
                 )
             ),
    )
    . p('2. Paste query sequence (raw or FASTA format):')
    . br;    ##Labels for DB description - Usha
  if ($seq) {
    $PAGE .= textarea( -name => 'sequence', -align => 'left', -rows => 8, -cols => 80, -wrap => 'virtual', -value => $seq ) . br;
  } else {
    $PAGE .= textarea( -name => 'sequence', -align => 'left', -rows => 8, -cols => 80, -wrap => 'virtual' ) . br;
  }
  $PAGE .= p("Or upload query sequence: ") . filefield( -name => 'upload', -size => 40, class => 'inputBox' ) . p("E-value for Blast ") . textfield( -name => 'evalue', -value => $evalue ) . br .    #added by usha
    submit( -name => 'runBLAST', -value => 'Run BLAST' ) . reset();
  return $PAGE;
}

sub doBLAST {
  my $self = shift;
  my ( $sequence, $name, $program, $db, $evalue ) = @_;                                                                                                                                         #$evalue added by usha
  my %BLAST_OPTS = (
                     'blastn'  => [qw/-progress 2 -filter dust/],
                     'tblastn' => [qw/-progress 2 -filter seg/],
  );
  my $JSCRIPT = <<END;
<script type="text/javascript">
/* <![CDATA[ */
  function check(field,checkflag) {
    if (checkflag == "  Select All  ") {
      if (!field.length) {
	field.checked = true;
      }
      else {
	for (i = 0; i < field.length; i++) {
	  field[i].checked = true;
	}
      }
      checkflag = " Unselect All ";
      return " Unselect All ";
    }
    else {
      if (!field.length) {
	field.checked = false;
      }
      else {
	for (i = 0; i < field.length; i++) {
	  field[i].checked = false;
	}
      }
      checkflag = "  Select All  ";
      return "  Select All  ";
    }
  }
  function showFASTA(DB) {
    Hlink = "${CGIPATH}returnFASTA.pl?db=" + DB;
    Qnum = 1;
    while(eval("document.guiFORM.hits" + Qnum)){
      HitLIST = eval("document.guiFORM.hits" + Qnum);
      if (!HitLIST.length) {
        Hlink = Hlink + "&hits=" + HitLIST.value;
      }else{
        for(x=0;x<HitLIST.length;x++) {
	  if(HitLIST[x].checked){
	    Hlink = Hlink + "&hits=" + HitLIST[x].value;
	  }
        }
      }
      Qnum++;
    }
    window.open(Hlink,'640x480','toolbar=no,status=yes,scrollbars=yes,location=no,menubar=yes,directories=no,width=640,height=480');
  }
/* ]]> */
</script>
END

  local (*B);
  my $TMP_FILE = tmpnam( $program, '.fasta' );
  to_fasta( $TMP_FILE, $sequence, $name );
	my $TMP_DB;
	print STDERR "LLLLLLLLLLLLLLLL $db\n";
	print STDERR "LLLLLLLLLLLLLLLL $COMPARE_PDB{$db}\n";
	if (defined $BLAST_DB{$db}->[1]){
		$TMP_DB=$BLAST_DB{$db}->[1];
	}elsif(exists $COMPARE_PDB{$db}){
	
		$TMP_DB=$COMPARE_PDB{$db};
	}elsif(exists $COMPARE_TDB{$db}){
		$TMP_DB=$COMPARE_TDB{$db};
	}elsif(exists $COMPARE_genomeDB{$db}){
		$TMP_DB=$COMPARE_genomeDB{$db};
	}

$BLAST="/usr/local/bin/".$program;
$filter = ($program  eq "blastn")?"-dust":"-seg"; # filter parameter
$task = ($program  eq "blastx" || $program  eq "tblastn")?"":"-task ".$program;  # no 'task' parameter for blastx or tblastn
  my $cmd = sprintf( "%s %s -db %s -query %s -evalue %s -show_gis -html $filter no", $BLAST, $task, $TMP_DB, $TMP_FILE, $evalue );

print STDERR "LLLLLLLLLLLLLLLL MMMMMMMMMMMMM $cmd\n";
  open( B, "-|" ) || do { exec($cmd) && die "Couldn't exec: $!"; };
  my $result = $JSCRIPT
    . "<h1>BLAST Results</h1>"
    . "<div id=\"blastresults\">"
    . hidden( -name => 'db', -value => "$db", -override => 1 );

  # print out the top boilerplate
  $| = 1;
  my $Qnum = 0;
  while ( $_ = B->getline ) {
    $adjustedLine = &addLink( $_, $Qnum );
    $result .= $adjustedLine;
    if ( ( !$selectableResults ) && ( $adjustedLine =~ /TYPE=\"checkbox\"/ ) ) {
      $selectableResults = 1;
      $result =~ s/<!-- SELECTION TOOLS QUERY $Qnum -->/<!-- SELECTION TOOLS QUERY $Qnum -->\n$tools/;
    }

    # The Qnum scalar in the  following is used to take care of hits resulting from multiple query inputs
    if (/^Searching\.+done/) {
      $Qnum++;
      $selectableResults = 0;
      $result .= "\n<!-- SELECTION TOOLS QUERY $Qnum -->\n";
      $tools = '<input type="button" name="selection' . $Qnum . '" value="  Select All  " onclick="this.value=check(this.form.hits' . $Qnum . ',this.value)" />' . button( -name => "retrieve$Qnum", -value => "Display selected hits in FASTA format", -onclick => "showFASTA('${db}');" );
    }
  }
  STDOUT->flush;
  unlink $TMP_FILE;
  close B;
  $result .= "</div>";

  return $result;
}

# replace the link for gi to queryID and build link for SQ;
sub addLink {
  my ( $line, $QN ) = @_;
  my ($link);
  my $id;
  my $ESTLINK = "${CGIPATH}findRecord.pl?id=";
  my $PUTLINK = "/search/display/data.php?Seq_ID=";

  if ( $line =~ /^<.*>gi\|(\d+)\|/ ) {
    $link = '"' . $ESTLINK . $1 . '"';
    $id   = $1;
    $line =~ s/<a href[^>]*>/<input type=\"checkbox\" name=\"hits${QN}\" value=\"${id}\"><a href=$link>/;

  } elsif ( $line =~ /gi\|(\d+)\|/ ) {
    $link = '"' . $ESTLINK . $1 . '"';
    $line =~ s/a href[^>]*>/a href=$link>/;

  } elsif ( $line =~ /^(At\dg\S+)/ ) {
    my $geneId = $1;
    ($id) = $geneId =~ /(At\dg\d{5})/;
    $link = "<input type=\"checkbox\" name=\"hits${QN}\" value=\"${id}\" /><a href=\"${gsqpLink}${id}\">$geneId</a>";
    $line =~ s/$geneId/$link/;

  } elsif ( $line =~ /(At\dg[0-9.]+)/ ) {
    my $geneId = $1;
    ($id) = $geneId =~ /(At\dg\d{5})/;
    $link = "\"${gsqpLink}${id}\"";
    $line =~ s/a name = ${geneId}\s*>\s*<\/a>/a name=${geneId} href=$link>/;
  } elsif ( $line =~ (/^PUT(.*?)<\/a>\s+/) ) {
    $id     = "PUT" . $1;
    $geneId = $id;
    $link   = "<input type=\"checkbox\" name=\"hits${QN}\" value=\"${id}\" /><a href=\"$PUTLINK${id}\">$geneId</a>";
    $line =~ s/$geneId/$link/;
  }
  return $line;
}

sub to_fasta {
  my ( $tmp, $sequence, $name ) = @_;
  my ($seq);

  my $file = IO::File->new(">$tmp") || AceError("Couldn't open temporary file for writing sequence: $!");

  while ( $sequence =~ m|>([^\n]+)\n([^>]+)|g ) {
    $name = $1;
    $seq  = $2;
    $seq =~ tr/a-zA-Z//cd;
    $seq =~ s/(.{80})/$1\n/g;
    print $file ">$name\n$seq\n";
  }
  if ( !( $sequence =~ /^>/ ) ) {
    $sequence =~ tr/a-zA-Z//cd;
    $sequence =~ s/(.{80})/$1\n/g;
    print $file '>Untitled Sequence submitted by ' . remote_host() . "\n$sequence\n";
  }
  $file->close();
  return " ";
}

sub tmpnam {
  my ( $TMPNAM, $suffix ) = @_;
  while (1) {
    my $tmpfile = "$TMPDIR/${$}" . $TMPNAM++ . $suffix;
    return $tmpfile if IO::File->new( $tmpfile, O_EXCL | O_CREAT );
  }
}


# end of package;
1;
