#!/usr/bin/perl -w
package GeneView;

#use strict;

use FileHandle;
use CGI;
use GD;

do 'SITEDEF.pl';
do 'xGDB_SUPPORTED_COLORS.pl';

############# Defaults #################
my $StartX          = 20;
my $Margin          = 10;
my $LabelHeight     = 4;
my $LabelSpace      = 7;
my $HeightInc       = 150;
my $HalfLabelHeight = $LabelHeight / 2;
my $StartY          = 50;
my $RulerHeight     = 3;
#########################################

############################## Constructor ################################
# new GeneView($imgWidth,$imgHeight,$begPos,$endPos);
sub new {
  my ( $class, @param ) = @_;
  my $self = {};
  bless $self, ref($class) || $class;
  $self->_initialize(@param);
  return $self;
}

sub _initialize {
  my $self = shift;
  my ( $imgWidth, $imgHeight, $begPos, $endPos, $noRULER, $scale ) = @_;

  $noRULER = 0 if ( !defined($noRULER) );

  $self->{'imgWidth'}  = $imgWidth;
  $self->{'imgHeight'} = $imgHeight;
  $self->{'begPos'}    = $begPos;
  $self->{'endPos'}    = $endPos;
  $self->{'gdFont'}    = gdTinyFont;

  # assign some variables for the image;
  my $unit = 1000;
  my $len  = $endPos - $begPos + 1;
  if ( $len < 1000 ) {
    $unit = 10;
  } elsif ( $len < 10000 ) {
    $unit = 100;
  }

  $self->{'img'}        = new GD::Image( $imgWidth, $imgHeight );
  $self->_defColor( $self->{'img'} );

  if ( $noRULER == 1 ) {
    $StartY            = 10;
    $HeightInc         = 1;
    $self->{'zeroPos'} = int($begPos);
    $self->{'seqLen'}  = $endPos - $self->{'zeroPos'} + 1;

    my $ratio = $self->{'seqLen'} / ( $self->{'imgWidth'} - $StartX - 2 * $Margin );
    $ratio = $scale if ($scale);
    $self->{'rulerLen'}   = $self->{'seqLen'} / $ratio;
    $self->{'scale'}      = $self->{'seqLen'} / $self->{'rulerLen'};
    $self->{'currHeight'} = 10;
    $self->{'isLabeled'}  = ( $self->{'scale'} < 100 ) ? 1 : 0;
  } else {
    $self->{'zeroPos'}   = int($begPos);
    $self->{'tickStart'} = ( int( $begPos / $unit ) ) * $unit;
    $self->{'seqLen'}    = $endPos - $self->{'zeroPos'} + 1;

    my $ratio = $self->{'seqLen'} / ( $self->{'imgWidth'} - $StartX - 2 * $Margin );
    $self->{'rulerLen'}   = $self->{'seqLen'} / $ratio + 0.5;
    $self->{'scale'}      = $self->{'seqLen'} / $self->{'rulerLen'};
    $self->{'currHeight'} = 10;
    $self->{'isLabeled'}  = ( $self->{'scale'} < 100 ) ? 1 : 0;
    $self->_drawRuler();
  }

}

sub setFontSize {
  my $self = shift();
  my ($sizeNDX) = @_;
  if ( $sizeNDX == 1 ) {
    $self->{'gdFont'} = gdTinyFont;
  } elsif ( $sizeNDX == 2 ) {
    $self->{'gdFont'} = gdSmallFont;
  } elsif ( $sizeNDX == 3 ) {
    $self->{'gdFont'} = gdLargeFont;
  } elsif ( $sizeNDX == 4 ) {
    $self->{'gdFont'} = gdGiantFont;
  }
}

sub setLabelOn {
  my $self = shift;
  $self->{'isLabeled'} = shift;
}

sub _clear {

  #do nothing
}

#draw the ruler
sub _drawRuler {
  my $self      = shift;
  my $nextPower = 0.001;
  my $MinDist   = 100;
  my $ruler;
  my $im = $self->{'img'};

  # get the resolution of the ruler
  my $minDist = $MinDist * $self->{'scale'};
  while ( $nextPower < $minDist ) {
    $nextPower *= 10;
  }
  if ( $minDist < $nextPower / 5.0 ) {
    $ruler = ( $nextPower + 0.5 ) / 5.0;
  } elsif ( $minDist < $nextPower / 4.0 ) {
    $ruler = ( $nextPower + 0.5 ) / 4.0;
  } elsif ( $minDist < $nextPower / 2 ) {
    $ruler = ( $nextPower + 0.5 ) / 2.0;
  } else {
    $ruler = $nextPower + 0.5;
  }

  $im->filledRectangle( min( $self->_pos2x( $self->{'zeroPos'} ), ( $self->_pos2x( $self->{'tickStart'} ) ) ), $self->{'currHeight'}, $self->_pos2x( $self->{'endPos'} ), $self->{'currHeight'} + $RulerHeight, $self->{'black'} );

  {
    use integer;
    my ( $tick_len, $x_pos, $pos, $i );
    $self->{'currHeight'} += $RulerHeight;

    $ruler = $ruler / 10;
    for ( $pos = $self->{'tickStart'}, $i = 0 ; $pos <= $self->{'endPos'} ; $pos += $ruler, $i++ ) {
      $tick_len = ( $i % 5 == 0 ) ? 6 : 3;
      $x_pos = $self->_pos2x($pos);
      if ( $i % 5 == 0 ) {
        $im->string( $self->{'gdFont'}, $x_pos - ( $self->{'gdFont'}->width ) * length($pos) / 2, $self->{'currHeight'} + 10, $pos, $self->{'black'} );
      }
      $im->line( $x_pos, $self->{'currHeight'}, $x_pos, $self->{'currHeight'} + $tick_len, $self->{'black'} );
    }
  }
}

sub _pos2x {
  my $self = shift;
  my ($pos) = @_;
  return int( ( $pos - $self->{'zeroPos'} ) / $self->{'scale'} + $StartX );
}

sub drawPNG {
  my ( $self, $outfn ) = @_;
  open( IMG, "> $outfn" ) or die "Cannot open file $outfn!"; # If this line fails, make sure to create a directory for your GDB in /tmp! See SubTmpList.readme or search the wiki for SubTmpList.
  binmode IMG;
  print IMG $self->{'img'}->png;
  close IMG;
}

# to find the specified region is occupied or not
sub _isEmpty {
  my $self = shift;
  my ( $x1, $x2, $h ) = @_;
  my $c;

  for ( my $i = $x1 - 15 ; $i <= $x2 + 10 ; $i += 7 ) {
    for ( my $j = $h - $self->{'gdFont'}->height - $LabelSpace ; $j <= $h + $self->{'gdFont'}->height + $LabelSpace ; $j += 2 ) {
      $c = $self->{'img'}->getPixel( $i, $j );
      return 0 if ( $c != $self->{'white'} );
    }
  }
  return 1;
}

sub _defColor {
  my $self = shift;
  my ($img) = @_;
  $self->{'white'} = $img->colorAllocate( 255, 255, 255 );
  $self->{'black'} = $img->colorAllocate( 0,   0,   0 );
  $self->{'red'}   = $img->colorAllocate( 255, 0,   0 );
  $self->{'green'} = $img->colorAllocate( 0,   255, 0 );
  $self->{'blue'}  = $img->colorAllocate( 0,   0,   255 );

  $img->transparent($self->{'white'});
  $img->interlaced('true');

}

sub _GV_addColor {
  my $self = shift;
  my ($colorname) = @_;

  my ($r,$g,$b);
  $colorname = lc($colorname);
  if ( exists( $SUPPORTED_COLORS{$colorname} ) ) {
    return $self->{img}->colorResolve( @{ $SUPPORTED_COLORS{ lc($colorname) } } );
  }elsif($colorname =~ /^\#*([0-9a-f]{2})([0-9a-f]{2})([0-9a-f]{2})$/) {
    ($r,$g,$b) = (hex($1),hex($2),hex($3));
    return $self->{img}->colorResolve($r,$g,$b);
  }elsif($colorname =~ /^\#*([0-9a-f])([0-9a-f])([0-9a-f])$/) {
    ($r,$g,$b) = (hex("$1$1"),hex("$2$2"),hex("$3$3"));
    return $self->{img}->colorResolve($r,$g,$b);
  }else{
    #print STDERR "[GeneView.pm] The color $colorname is NOT SUPPORTED!\n";
	## Allowing this to return the GD image color index pseudo-object!!
    return $colorname;
  }
}

sub _getHeight {
  my $self = shift;
  my ( $x1, $x2, $height ) = @_;
  my $labelSpace  = $LabelSpace;
  my $labelLength = 0;
  $labelSpace += $self->{'gdFont'}->height if ( $self->{'isLabeled'} );

  while ( !$self->_isEmpty( $x1, $x2, $height ) ) {
    $height += $labelSpace;
  }
  if ( $height + $LabelHeight + $labelSpace > $self->{'imgHeight'} ) {

    #$HeightInc = $height;
    #resize the image
    #my $newPicHeight=$self->{'imgHeight'}+$HeightInc;
    my $newPicHeight = $height + $labelSpace + $self->{'gdFont'}->height;
    my $tmpIm = new GD::Image( $self->{'imgWidth'}, $newPicHeight );
    $self->_defColor($tmpIm);
    $tmpIm->copy( $self->{'img'}, 0, 0, 0, 0, $self->{'imgWidth'}, $self->{'imgHeight'} );
    $self->{'img'}       = $tmpIm;
    $self->{'imgHeight'} = $newPicHeight;
  }
  return $height;
}

sub _setGradiant {
  my $self = shift;
  my ($step,$colorL,$colorR) = @_;

  my @ramp =();

  my ($CLr,$CLg,$CLb) = $self->{'img'}->rgb($self->_GV_addColor($colorL));
  my ($CRr,$CRg,$CRb) = $self->{'img'}->rgb($self->_GV_addColor($colorR));

  my $dr = ($CRr - $CLr) / $step;
  my $dg = ($CRg - $CLg) / $step;
  my $db = ($CRb - $CLb) / $step;

  my ($r,$g,$b) = ($CLr,$CLg,$CLb);
  for (my $i=0; $i<$step; $i++){
    @ramp = (@ramp, $self->{img}->colorResolve($r,$g,$b));
    $r += $dr;
    $g += $dg;
    $b += $db;
  }
  $self->{img}->setStyle(@ramp);

  return gdStyled;
}

sub _drawBar {
  my $self = shift;
  my ( $a, $b, $height, $c ) = @_;
  my $x1 = $self->_pos2x($a);
  my $x2 = $self->_pos2x($b);

  return undef if ( ( ( $x1 < 0 ) && ( $x2 < 0 ) ) || ( ( $x1 > $self->{imgWidth} ) && ( $x2 > $self->{imgWidth} ) ) );

  $x2 = $x1 + 2 if ( $x2 - $x1 < 2 );
  {
    use integer;
    $self->{'img'}->filledRectangle( $x1, $height - $HalfLabelHeight, $x2, $height + $HalfLabelHeight, $c );
  }
}

sub _drawStartBar {
  my $self = shift;
  my ( $a, $b, $height, $c, $c_s, $isReversed,$argHR ) = @_;
  my $x1 = $self->_pos2x($a);
  my $x2 = $self->_pos2x($b);

  return undef if ( ( ( $x1 < 0 ) && ( $x2 < 0 ) ) || ( ( $x1 > $self->{imgWidth} ) && ( $x2 > $self->{imgWidth} ) ) );

  if ( $x2 - $x1 < 2 ) {
    $x2 = $x1 + 2;
    use integer;
    $self->{'img'}->filledRectangle( $x1, $height - $HalfLabelHeight, $x2, $height + $HalfLabelHeight, $c_s );
  } elsif (exists($argHR->{'fadeBoth'})) {
    use integer;
    my $xmid = $x1 + (($x2-$x1)/2);
    $self->{'img'}->filledRectangle( $x1, $height - $HalfLabelHeight, $xmid, $height + $HalfLabelHeight, _setGradiant($self,($xmid-$x1+1),$argHR->{'fadeStart'},$c) );
    $self->{'img'}->filledRectangle( $xmid, $height - $HalfLabelHeight, $x2, $height + $HalfLabelHeight, _setGradiant($self,($x2-$xmid+1),$c,$argHR->{'fadeEnd'}) );
  } elsif (exists($argHR->{'fadeStart'})) {
    use integer;
    if($isReversed){
      $self->{'img'}->filledRectangle( $x1, $height - $HalfLabelHeight, $x2, $height + $HalfLabelHeight, _setGradiant($self,($x2-$x1+1),$c,$argHR->{'fadeStart'}) );
    }else{
      $self->{'img'}->filledRectangle( $x1, $height - $HalfLabelHeight, $x2, $height + $HalfLabelHeight, _setGradiant($self,($x2-$x1+1),$argHR->{'fadeStart'},$c) );
    }
  } elsif ($isReversed) {
    use integer;
    $self->{'img'}->filledRectangle( $x2 - 4, $height - $HalfLabelHeight, $x2, $height + $HalfLabelHeight, $c_s );
    $self->{'img'}->filledRectangle( $x1, $height - $HalfLabelHeight, $x2 - 4, $height + $HalfLabelHeight, $c );
  } else {
    use integer;
    $self->{'img'}->filledRectangle( $x1, $height - $HalfLabelHeight, $x1 + 4, $height + $HalfLabelHeight, $c_s );
    $self->{'img'}->filledRectangle( $x1 + 4, $height - $HalfLabelHeight, $x2, $height + $HalfLabelHeight, $c );
  }
}

sub _drawArrow {
  my $self = shift;
  my ( $a, $b, $height, $c, $c_a, $dir, $argHR ) = @_;
  my $x1 = $self->_pos2x($a);
  my $x2 = $self->_pos2x($b);

  return undef if ( ( ( $x1 < 0 ) && ( $x2 < 0 ) ) || ( ( $x1 > $self->{imgWidth} ) && ( $x2 > $self->{imgWidth} ) ) );

  my $poly = new GD::Polygon;

  $x2 = $x1 + 2 if ( $x2 - $x1 < 2 );
  {
    use integer;
    if ($dir) {
      $poly->addPt( $x1, $height );
      $poly->addPt( &max( &min( $x1 + 5, $x2 ), $x1 + 2 ), $height - 5 );
      $poly->addPt( &max( &min( $x1 + 5, $x2 ), $x1 + 2 ), $height + 5 );
      $self->{'img'}->filledPolygon( $poly, exists($argHR->{fadeEnd})?_setGradiant($self,5,$argHR->{'fadeEnd'},$c_a):$c_a );
      if ( $x2 - $x1 > 5 ) {    #draw a bar
        $self->{'img'}->filledRectangle( $x1 + 5, $height - $HalfLabelHeight, $x2, $height + $HalfLabelHeight, exists($argHR->{fadeEnd})?_setGradiant($self,($x2-$x1-4),$argHR->{'fadeEnd'},$c):$c );
      }
    } else {
      $poly->addPt( $x2, $height );
      $poly->addPt( &min( &max( $x1, $x2 - 5 ), $x2 - 2 ), $height - 5 );
      $poly->addPt( &min( &max( $x1, $x2 - 5 ), $x2 - 2 ), $height + 5 );
      $self->{'img'}->filledPolygon( $poly, exists($argHR->{fadeEnd})?_setGradiant($self,2,$c_a,$argHR->{'fadeEnd'}):$c_a );
      if ( $x2 - $x1 > 5 ) {    #draw a bar
        $self->{'img'}->filledRectangle( $x1, $height - $HalfLabelHeight, $x2 - 5, $height + $HalfLabelHeight, exists($argHR->{fadeEnd})?_setGradiant($self,($x2-$x1-4),$c,$argHR->{'fadeEnd'}):$c );
      }
    }
  }
}

sub _drawSEdot {
  my $self = shift;
  my ( $a, $b, $height, $c ) = @_;
  my $x1 = $self->_pos2x($a);
  my $x2 = $self->_pos2x($b);

  return undef if ( ( ( $x1 < 0 ) && ( $x2 < 0 ) ) || ( ( $x1 > $self->{imgWidth} ) && ( $x2 > $self->{imgWidth} ) ) );

  my $mid = ( $x1 + $x2 ) / 2;

  if ( ( ( $mid - 2 ) > 0 ) && ( ( $mid + 2 ) < $self->{'imgWidth'} ) ) {
    $self->{'img'}->filledRectangle( $mid - 2, $height - $HalfLabelHeight, $mid + 2, $height + $HalfLabelHeight, $c );
  }
}

sub drawPair {
  my $self = shift;
  my ( $x1, $h1, $x2, $h2, $color ) = @_;
  my $c = $self->_GV_addColor($color);
  $self->{'img'}->rectangle( $x1 - 2, $h1 + $HalfLabelHeight - 5, $x2 + 2, $h2 - $HalfLabelHeight + 5, $c );
}

sub drawFLAG {
  my ( $self, $FLAG_filename, $x, $y ) = @_;

  open( FLAGfile, "$FLAG_filename" ) || die "couldn't open flag file <$FLAG_filename>\n";
  my $FLAGimg = GD::Image->new(FLAGfile);
  $self->{'img'}->rectangle( $x, $y, $x + 22, $y + 22, $self->_GV_addColor('grey') );
  $self->{'img'}->copy( $FLAGimg, $x + 2, $y + 2, 0, 0, 20, 20 );
  close(FLAGfile);

  return $x + 24;
}

sub descFLAG {
  my ( $self, $FLG_DESC, $oc_url, @coords ) = @_;

  #$FLG_DESC = CGI::escape($FLG_DESC);

  return "<AREA SHAPE=\"RECT\" COORDS=\"" . join( ',', @coords ) . "\" HREF=\"$oc_url\"" . " onmouseover=\"showDef('$FLG_DESC');\"" . " onmouseout=\"showDef('Mouse over for description. Click to retrieve individual record.');\">\n";
}

sub addFLAGS {
  my $self = shift;
  my ( $argHR, $imgAR, $imgDescAR ) = @_;

  my $x1         = $self->_pos2x( $argHR->{l_pos} );
  my $x2         = $self->_pos2x( $argHR->{r_pos} );
  my $initHeight = exists( $argHR->{startHeight} ) ? $argHR->{startHeight} + $HalfLabelHeight : $StartY;
  my $height     = $self->_getHeight( &min( $x1, $x2 ), &max( $x2, $x1 ), $initHeight );
  my $defaultURL = exists( $argHR->{url} ) ? $argHR->{url} : '#';
  my ( $curX, $FLAGdesc, $imap, @props );

  $curX = ( ( $x2 - $x1 ) >= ( scalar(@$imgAR) * 24 ) ) ? $x1 + int( ( ( $x2 - $x1 ) - ( scalar(@$imgAR) * 24 ) ) / 2 ) : $x1;
  for ( my $indx = 0 ; $indx <= $#$imgAR ; $indx++ ) {
    my $url = ( exists( $argHR->{urlAR} ) && exists( $argHR->{urlAR}->[$x] ) ) ? $argHR->{urlAR}->[$x] : $defaultURL;
    last if ( ( $curX + 24 ) > $x2 );
    $curX = $self->drawFLAG( $imgAR->[$indx], $curX, $height - 4 );
    $imap .= $self->descFLAG( $imgDescAR->[$indx], $url, $curX - 24, $height - 6, $curX - 1, $height + 20 );
  }
  return ( $imap, $x1, $height - 6, $x2, $height + 20 );
}

sub addMarker {
  my $self = shift;
  my ( $argHR, @posArray ) = @_;
  my ( $i, $pos, @label );

  my $c   = ( exists( $argHR->{color} ) )      ? $argHR->{color}      : "grey";
  my $c_a = ( exists( $argHR->{arrowColor} ) ) ? $argHR->{arrowColor} : $c;
  my $c_s = ( exists( $argHR->{startColor} ) ) ? $argHR->{startColor} : $c;
  my $c_d = ( exists( $argHR->{dotColor} ) )   ? $argHR->{dotColor}   : $c;

  my $idHalfLen = ( $self->{'isLabeled'} ) ? ( $self->{'gdFont'}->width ) * length( $argHR->{label} ) / 2 : 0;
  my $initHeight = ( exists( $argHR->{startHeight} ) ) ? $argHR->{startHeight} + $HalfLabelHeight : $StartY;

  my $isReversed = ( $posArray[0] > $posArray[$#posArray] ) ? 1 : 0;
  my $x1 = min( max( $self->_pos2x( $posArray[0] ), 0 ), $self->{imgWidth} );
  my $x2 = min( max( $self->_pos2x( $posArray[$#posArray] ), 0 ), $self->{imgWidth} );
  my $mid = ( $x1 + $x2 ) / 2;
  &swap( \$x1, \$x2 ) if $isReversed;

  my $height = $self->_getHeight( &min( $x1, $mid - $idHalfLen ), &max( $x2, $mid + $idHalfLen ), $initHeight );

  $self->{'img'}->line( $x1 + 1, $height, $x2 - 1, $height, $self->_GV_addColor($c) );

  if ( ( $self->{'isLabeled'} ) && ( exists( $argHR->{label} ) ) ) {    #draw ID
    $self->{'img'}->string( $self->{'gdFont'}, $mid - $idHalfLen, $height + $HalfLabelHeight + 5, $argHR->{label}, $self->_GV_addColor('black') );
    @label = ( $mid - $idHalfLen, $height + $HalfLabelHeight + 5, $mid + $idHalfLen, $height + $HalfLabelHeight + 15 );
  } else {
    @label = ( -1, -1, -1, -1 );
  }

  for ( $pos = 0 ; $pos <= $#posArray ; $pos++ ) {
    if ( $posArray[$pos] < $self->{'zeroPos'} ) {
      $posArray[$pos] = $self->_pos2x( $self->{'zeroPos'} );
    } elsif ( $posArray[$pos] > $self->{'endPos'} ) {
      $posArray[$pos] = $self->_pos2x( $self->{'endPos'} );
    } else {
      $posArray[$pos] = $self->_pos2x( $posArray[$pos] );
    }
  }
  return ( [@label], [ $height - $HalfLabelHeight, $height + $HalfLabelHeight, @posArray ] );
}

sub addCDS {
  my ( $self, $startHeight, $cstart, $cend ) = @_;
  my $x1    = $self->_pos2x($cstart);
  my $x2    = $self->_pos2x($cend);
  my $poly  = new GD::Polygon;
  my $poly2 = new GD::Polygon;

  if ( ( $cstart >= $self->{begPos} ) && ( $cstart <= $self->{endPos} ) ) {

    #draw CDS start triangle
    $poly->addPt( $x1,     $startHeight );
    $poly->addPt( $x1 - 2, $startHeight - 5 );
    $poly->addPt( $x1 + 2, $startHeight - 5 );
    $self->{'img'}->filledPolygon( $poly, $self->{'green'} );
  }

  if ( ( $cend >= $self->{begPos} ) && ( $cend <= $self->{endPos} ) ) {

    #draw CDS stop triangle
    $poly2->addPt( $x2,     $startHeight );
    $poly2->addPt( $x2 - 2, $startHeight - 5 );
    $poly2->addPt( $x2 + 2, $startHeight - 5 );
    $self->{'img'}->filledPolygon( $poly2, $self->{'red'} );
  }
}

sub addGseg {
  my $self = shift;
  my ( $argHR, @posArray ) = @_;
  my (@label);

  my $c   = ( exists( $argHR->{color} ) )      ? $argHR->{color}      : "green";
  my $c_l = ( exists( $argHR->{leftColor} ) )  ? $argHR->{leftColor}  : $c;
  my $c_r = ( exists( $argHR->{rightColor} ) ) ? $argHR->{rightColor} : $c;

  my $idHalfLen = ( $self->{'isLabeled'} ) ? ( $self->{'gdFont'}->width ) * length( $argHR->{label} ) / 2 : 0;
  my $initHeight = ( exists( $argHR->{startHeight} ) ) ? $argHR->{startHeight} + $HalfLabelHeight : $StartY;

  my $offset = 0;
  if(!(exists($self->{showGsegFlank}) && $self->{showGsegFlank})){
    $offset = ($posArray[1] > $posArray[0])?$posArray[1] - $posArray[0] : $posArray[0] - $posArray[1];
    @posArray = ($posArray[1],$posArray[2]);
  }

  my $isReversed = ( $posArray[0] > $posArray[$#posArray] ) ? 1 : 0;
  @posArray = reverse @posArray if ($isReversed);
  my $x1 = $self->_pos2x( &max( $posArray[0], $self->{'zeroPos'} ) );
  my $x2 = $self->_pos2x( &min( $posArray[$#posArray], $self->{'endPos'} ) );
  my $mid = ( $x1 + $x2 ) / 2;

  my $height = $self->_getHeight( &min( $x1, $mid - $idHalfLen ), &max( $x2, $mid + $idHalfLen ), $initHeight );
  $height += 8;    ## Adding room for IDs on top

  my $nextPower  = 0.001;
  my $MinDist    = 100;
  my $halfStroke = 1;
  my $ruler;
  my $minDist = $MinDist * $self->{'scale'};
  while ( $nextPower < $minDist ) { $nextPower *= 10; }
  if ( $minDist < $nextPower / 5.0 ) {
    $ruler = ( $nextPower + 0.5 ) / 5.0;
  } elsif ( $minDist < $nextPower / 4.0 ) {
    $ruler = ( $nextPower + 0.5 ) / 4.0;
  } elsif ( $minDist < $nextPower / 2 ) {
    $ruler = ( $nextPower + 0.5 ) / 2.0;
  } else {
    $ruler = $nextPower + 0.5;
  }

  if ( $#posArray > 1 ) {
    if ( $posArray[1] > $self->{'zeroPos'} ) {
      $self->{'img'}->rectangle( $x1, $height - $halfStroke, $self->_pos2x( $posArray[1] ), $height + $HalfLabelHeight, $self->_GV_addColor($c_l) );
    }
    if ( $posArray[2] < $self->{'endPos'} ) {
      $self->{'img'}->rectangle( $self->_pos2x( $posArray[2] ), $height - $halfStroke, $x2, $height + $HalfLabelHeight, $self->_GV_addColor($c_r) );
    }
    $self->{'img'}->filledRectangle( $self->_pos2x( $posArray[1] ), $height - $halfStroke, $self->_pos2x( $posArray[2] ), $height + $halfStroke, $self->_GV_addColor($c) );
  } else {
    $self->{'img'}->filledRectangle( $x1, $height - $halfStroke, $x2, $height + $halfStroke, $self->_GV_addColor($c) );
  }
  {
    use integer;
    my ( $show_coords, $tick_len, $x_pos, $pos, $bpos, $i );
    $ruler = $ruler / 10;
    ## This hides the coords if the drawing is too small unless overridden by argHR!
    $show_coords = ( exists( $argHR->{showCoords} ) ) ? $argHR->{showCoords} : ( ( $posArray[0] + ( 2 * $ruler ) ) < $posArray[$#posArray] );

    for ( $pos = &max( $posArray[0], $self->{'zeroPos'} ), $i = 0 ; $pos <= &min( $posArray[$#posArray], $self->{'endPos'} ) ; $pos += $ruler, $i++ ) {
      $bpos = ($isReversed) ? $posArray[$#posArray] - $pos + 1 : $pos - $posArray[0] + 1;
      $bpos += $offset;
      $tick_len = ( $i % 5 == 0 ) ? $HalfLabelHeight : ( $HalfLabelHeight / 2 );
      $x_pos = $self->_pos2x($pos);
      if ( $show_coords && ( $i % 5 == 0 ) && ( ( $pos + ( 2 * $ruler ) ) < $posArray[$#posArray] ) ) {
        $self->{'img'}->string( $self->{'gdFont'}, $x_pos - ( $self->{'gdFont'}->width ) * length($bpos) / 2, $height + 5, $bpos, $self->_GV_addColor('black') );
      }
      $self->{'img'}->line( $x_pos, $height - $tick_len, $x_pos, $height + $tick_len, $self->_GV_addColor('black') );
    }
    ## Add final tick mark for fully contained structures
    if ( $posArray[$#posArray] < $self->{'endPos'} ) {
      $bpos     = ($isReversed) ? 1 : $posArray[$#posArray] - $posArray[0] + 1;
      $bpos     += $offset;
      $x_pos    = $self->_pos2x( $posArray[$#posArray] );
      $tick_len = $HalfLabelHeight;
      $self->{'img'}->string( $self->{'gdFont'}, $x_pos - ( $self->{'gdFont'}->width ) * length($bpos) / 2, $height + 5, $bpos, $self->_GV_addColor('black') ) if ($show_coords);
      $self->{'img'}->line( $x_pos, $height - $tick_len, $x_pos, $height + $tick_len, $self->_GV_addColor('black') );
    }
  }

  if ( ( $self->{'isLabeled'} ) && ( exists( $argHR->{label} ) ) ) {
    $self->{'img'}->string( $self->{'gdFont'}, $mid - $idHalfLen, $height - $self->{'gdFont'}->height - 5, $argHR->{label}, $self->_GV_addColor('black') );
    @label = ( $mid - $idHalfLen, $height - 10, $mid + $idHalfLen, $height );
  } else {
    @label = ( -1, -1, -1, -1 );
  }

  for ( $pos = 0 ; $pos <= $#posArray ; $pos++ ) {
    if ( $posArray[$pos] < $self->{'zeroPos'} ) {
      $posArray[$pos] = $self->_pos2x( $self->{'zeroPos'} );
    } elsif ( $posArray[$pos] > $self->{'endPos'} ) {
      $posArray[$pos] = $self->_pos2x( $self->{'endPos'} );
    } else {
      $posArray[$pos] = $self->_pos2x( $posArray[$pos] );
    }
  }
  @posArray = reverse @posArray if ($isReversed);
  return ( [@label], [ $height - $HalfLabelHeight, $height + $HalfLabelHeight, @posArray ] );
}

sub addGene {
  my $self = shift;
  my ( $argHR, @posArray ) = @_;
  my ( $i, $pos, @label );

  my $c   = ( exists( $argHR->{color} ) )      ? $argHR->{color}      : "red";
  my $c_a = ( exists( $argHR->{arrowColor} ) ) ? $argHR->{arrowColor} : $c;
  my $c_s = ( exists( $argHR->{startColor} ) ) ? $argHR->{startColor} : $c;
  my $c_d = ( exists( $argHR->{dotColor} ) )   ? $argHR->{dotColor}   : $c;

  my $idHalfLen = ( $self->{'isLabeled'} ) ? ( $self->{'gdFont'}->width ) * length( $argHR->{label} ) / 2 : 0;
  my $initHeight = ( exists( $argHR->{startHeight} ) ) ? $argHR->{startHeight} + $HalfLabelHeight : $StartY;

  my $isReversed = ( $posArray[0] > $posArray[$#posArray] ) ? 1 : 0;
  my $x1 = min( max( $self->_pos2x( $posArray[0] ), 0 ), $self->{imgWidth} );
  my $x2 = min( max( $self->_pos2x( $posArray[$#posArray] ), 0 ), $self->{imgWidth} );
  my $mid = ( $x1 + $x2 ) / 2;
  &swap( \$x1, \$x2 ) if $isReversed;

  my $height = $self->_getHeight( &min( $x1, $mid - $idHalfLen ), &max( $x2, $mid + $idHalfLen ), $initHeight );

  $self->{'img'}->line( $x1 + 1, $height, $x2 - 1, $height, $self->_GV_addColor($c) );
  if ($isReversed) {
    if ( ( $#posArray > 1 ) || ( exists( $argHR->{drawArrowhead} ) ) ) {
      if ( ( $#posArray == 1 ) && ( exists( $argHR->{drawArrowhead} ) ) ) {
        $self->_drawArrow( $posArray[$#posArray], $posArray[ $#posArray - 1 ], $height, $self->_GV_addColor($c), $self->_GV_addColor($c_a), $isReversed, $argHR );
      } else {
        $self->_drawStartBar( $posArray[1], $posArray[0], $height, $self->_GV_addColor($c), $self->_GV_addColor($c_s), $isReversed, $argHR );
        for ( $i = 2 ; $i < @posArray - 2 ; $i += 2 ) {
          $self->_drawBar( $posArray[ $i + 1 ], $posArray[$i], $height, $self->_GV_addColor($c), $argHR );
        }
        $self->_drawArrow( $posArray[$#posArray], $posArray[ $#posArray - 1 ], $height, $self->_GV_addColor($c), $self->_GV_addColor($c_a), $isReversed, $argHR );
      }
    } else {
      $self->_drawStartBar( $posArray[1], $posArray[0], $height, $self->_GV_addColor($c), $self->_GV_addColor($c), $isReversed, $argHR );
      $self->_drawSEdot( $posArray[1], $posArray[0], $height, $self->_GV_addColor($c_d), $argHR );
    }
  } else {
    if ( ( $#posArray > 1 ) || ( exists( $argHR->{drawArrowhead} ) ) ) {
      if ( ( $#posArray == 1 ) && ( exists( $argHR->{drawArrowhead} ) ) ) {
        $self->_drawArrow( $posArray[ $#posArray - 1 ], $posArray[$#posArray], $height, $self->_GV_addColor($c), $self->_GV_addColor($c_a), $isReversed, $argHR );
      } else {
        $self->_drawStartBar( $posArray[0], $posArray[1], $height, $self->_GV_addColor($c), $self->_GV_addColor($c_s), $isReversed, $argHR );
        for ( $i = 2 ; $i < @posArray - 2 ; $i += 2 ) {
          $self->_drawBar( $posArray[$i], $posArray[ $i + 1 ], $height, $self->_GV_addColor($c), $argHR );
        }
        $self->_drawArrow( $posArray[ $#posArray - 1 ], $posArray[$#posArray], $height, $self->_GV_addColor($c), $self->_GV_addColor($c_a), $isReversed, $argHR );
      }
    } else {
      $self->_drawStartBar( $posArray[0], $posArray[1], $height, $self->_GV_addColor($c), $self->_GV_addColor($c), $isReversed, $argHR );
      $self->_drawSEdot( $posArray[0], $posArray[1], $height, $self->_GV_addColor($c_d), $argHR );
    }
  }

  #draw ID
  if ( ( $self->{'isLabeled'} ) && ( exists( $argHR->{label} ) ) ) {
    $self->{'img'}->string( $self->{'gdFont'}, $mid - $idHalfLen, $height + $HalfLabelHeight + 5, $argHR->{label}, $self->_GV_addColor('black') );
    @label = ( $mid - $idHalfLen, $height + $HalfLabelHeight + 5, $mid + $idHalfLen, $height + $HalfLabelHeight + 15 );
  } else {
    @label = ( -1, -1, -1, -1 );
  }

  for ( $pos = 0 ; $pos <= $#posArray ; $pos++ ) {
    if ( $posArray[$pos] < $self->{'zeroPos'} ) {
      $posArray[$pos] = $self->_pos2x( $self->{'zeroPos'} );
    } elsif ( $posArray[$pos] > $self->{'endPos'} ) {
      $posArray[$pos] = $self->_pos2x( $self->{'endPos'} );
    } else {
      $posArray[$pos] = $self->_pos2x( $posArray[$pos] );
    }
  }
  return ( [@label], [ $height - $HalfLabelHeight, $height + $HalfLabelHeight, @posArray ] );
}

sub showSplicePattern {
  my $self = shift;
  my ( $argHR, @cds ) = @_;
  my ( $a, $x, $c, $diff );

  $c = ( exists( $argHR->{color} ) ) ? $argHR->{color} : 'red';

  if ( $cds[0] > $cds[$#cds] ) {
    ## reverse strand PGS
    $a = $cds[0];
    $x = $cds[$#cds];
    for ( my $y = 0 ; $y <= $#cds ; $y++ ) {
      $cds[$y] = ( $a + $x ) - $cds[$y];
    }
  }

  $diff = 0;
  for ( $x = 1 ; $x < $#cds ; $x += 2 ) {
    $diff += ( $cds[ $x + 1 ] - $cds[$x] );
  }

  $self->_drawArrow( $cds[0], ( $cds[$#cds] - $diff ), $StartY, $self->_GV_addColor($c), $self->_GV_addColor($c), 0 );
  $a    = 0;
  $diff = 0;
  for ( $x = 1 ; $x < $#cds ; $x += 2 ) {
    $a = $self->_pos2x( $cds[$x] - $diff );
    $self->{'img'}->filledRectangle( $a, $StartY - $LabelHeight, $a + 2, $StartY + $LabelHeight, $self->_GV_addColor('green') );
    $diff += ( $cds[ $x + 1 ] - $cds[$x] );
  }
}

sub swap {
  my ( $x, $y ) = @_;
  if ( $$x > $$y ) {
    my $temp = $$x;
    $$x = $$y;
    $$y = $temp;
  }
}

sub min { return ( $_[0] < $_[1] ) ? $_[0] : $_[1]; }

sub max { return ( $_[0] > $_[1] ) ? $_[0] : $_[1]; }

sub DESTROY {
  my $self = shift;
  $self->_clear();
}

##################### DAS compatibility ######################
sub addDASfeature {
  my $self = shift;
  my ( $featHR, $styleHR, $height ) = @_;

  my $defaultGLYPH = {
                       'BOX' => {
                                  'HEIGHT'    => 4,
                                  'LABEL'     => 'no',
                                  'FGCOLOR'   => 'black',
                                  'BGCOLOR'   => 'ff6347',
                                  'LINEWIDTH' => 1
                                }
                     };

  my $featCAT  = ( exists( $featHR->{'TYPE'}->{'category'} ) ) ? $featHR->{'TYPE'}->{'category'} : 'default';
  my $featTYPE = ( exists( $featHR->{'TYPE'}->{'id'} ) )       ? $featHR->{'TYPE'}->{'id'}       : 'default';

  my $glyphHR =
      ( exists( $styleHR->{'STYLESHEET'}->{'CATEGORY'}->{$featCAT} ) )
    ? ( exists( $styleHR->{'STYLESHEET'}->{'CATEGORY'}->{$featCAT}->{'TYPE'}->{$featTYPE} ) )
    	? $styleHR->{'STYLESHEET'}->{'CATEGORY'}->{$featCAT}->{'TYPE'}->{$featTYPE}->{'GLYPH'}
    	: ( exists( $styleHR->{'STYLESHEET'}->{'CATEGORY'}->{$featCAT}->{'TYPE'}->{'default'} ) ) 
		? $styleHR->{'STYLESHEET'}->{'CATEGORY'}->{$featCAT}->{'TYPE'}->{'default'}->{'GLYPH'}
    		: $defaultGLYPH
    : ( exists( $styleHR->{'STYLESHEET'}->{'CATEGORY'}->{'default'}->{'TYPE'}->{$featTYPE} ) )
	? $styleHR->{'STYLESHEET'}->{'CATEGORY'}->{'default'}->{'TYPE'}->{$featTYPE}->{'GLYPH'}
	: ( exists( $styleHR->{'STYLESHEET'}->{'CATEGORY'}->{'default'}->{'TYPE'}->{'default'} ) ) 
                ? $styleHR->{'STYLESHEET'}->{'CATEGORY'}->{'default'}->{'TYPE'}->{'default'}->{'GLYPH'}
                :$defaultGLYPH;

  ## calculate pixel coords
  my $x1 = min( max( $self->_pos2x( min( $featHR->{'START'}, $featHR->{'END'} ) ), 0 ), $self->{imgWidth} );
  my $x2 = min( max( $self->_pos2x( max( $featHR->{'START'}, $featHR->{'END'} ) ), 0 ), $self->{imgWidth} );

  $height = $self->_getHeight( $x1, $x2, 10 ) if ( !defined($height) );

  return $self->addDASglyph( $x1, $x2, $height, $featHR, $glyphHR );
}

sub addDASgroupConnection {
  my $self = shift;
  my ( $x1, $x2, $type, $styleHR, $height ) = @_;

  my $defaultGLYPH = {
                       'LINE' => {
                                   'HEIGHT'  => 4,
                                   'LABEL'   => 'no',
                                   'STYLE'   => 'hat',
                                   'FGCOLOR' => 'black',
                                   'BUMP'    => '1'
                                 }
                     };

###!!!!!! Deal with possible multiple context/zoom level glyph stylesheets
  my $glyphHR =
      ( exists( $styleHR->{'STYLESHEET'}->{'CATEGORY'}->{'group'}->{'TYPE'}->{$type} ) ) ? $styleHR->{'STYLESHEET'}->{'CATEGORY'}->{'group'}->{'TYPE'}->{$type}->{'GLYPH'}
    : ( exists( $styleHR->{'STYLESHEET'}->{'CATEGORY'}->{'group'}->{'TYPE'}->{'default'} ) ) ? $styleHR->{'STYLESHEET'}->{'CATEGORY'}->{'group'}->{'TYPE'}->{'default'}->{'GLYPH'}
    : $defaultGLYPH;

  return $self->addDASglyph( min( $x1, $x2 ), max( $x1, $x2 ), $height, {}, $glyphHR );
}

sub addDASgroupLabel {
  my $self = shift;
  my ( $type, $grpLabel, $groupAR, $styleHR, $forceLabel ) = @_;

  ###!!!!!! Deal with possible multiple context/zoom level glyph stylesheets
  my $glyphHR =
      ( exists( $styleHR->{'STYLESHEET'}->{'CATEGORY'}->{'group'}->{'TYPE'}->{$type} ) ) ? $styleHR->{'STYLESHEET'}->{'CATEGORY'}->{'group'}->{'TYPE'}->{$type}->{'GLYPH'}
    : ( exists( $styleHR->{'STYLESHEET'}->{'CATEGORY'}->{'group'}->{'TYPE'}->{'default'} ) ) ? $styleHR->{'STYLESHEET'}->{'CATEGORY'}->{'group'}->{'TYPE'}->{'default'}->{'GLYPH'}
    : undef;

  return undef
    if (
         ( !defined($forceLabel) || !$forceLabel )
         && (    !defined($glyphHR)
              || !$self->{'isLabeled'}
              || ( $glyphHR->{ join( "", keys(%$glyphHR) ) }->{'LABEL'} eq 'no' )
              || ( $glyphHR->{ join( "", keys(%$glyphHR) ) }->{'LABEL'} == 0 ) )
       );

  my $fgcolor =
    ( exists( $glyphHR->{ join( "", keys(%$glyphHR) ) }->{'FGCOLOR'} ) )
    ? $glyphHR->{ join( "", keys(%$glyphHR) ) }->{'FGCOLOR'}
    : 'black';
  {
    use integer;
    my $idHalfLen = ( $self->{'gdFont'}->width ) * length($grpLabel) / 2;
    $self->{'img'}->string( $self->{'gdFont'}, ( ( $groupAR->[0] + $groupAR->[2] ) / 2 ) - $idHalfLen, $groupAR->[3] + $HalfLabelHeight + 5, $grpLabel, $self->_GV_addColor('black') );
    return [ ( ( $groupAR->[0] + $groupAR->[2] ) / 2 ) - $idHalfLen, $groupAR->[3] + $HalfLabelHeight + 5, ( ( $groupAR->[0] + $groupAR->[2] ) / 2 ) + $idHalfLen, $groupAR->[3] + $HalfLabelHeight + 15 ];
  }

}

sub addDASglyph {
  my $self = shift;
  my ( $x1, $x2, $y, $featHR, $glyphHR ) = @_;

  return undef if ( ( ( $x1 < 0 ) && ( $x2 < 0 ) ) || ( ( $x1 > $self->{imgWidth} ) && ( $x2 > $self->{imgWidth} ) ) );

  my ($glyphTYPE) = keys %$glyphHR;
  return ( $glyphTYPE =~ /^ARROW$/i ) ? $self->addDASglyph_arrow(@_)
    : ( $glyphTYPE =~ /^ANCHORED_ARROW$/i ) ? $self->addDASglyph_anchored_arrow(@_)
    : ( $glyphTYPE =~ /^BOX$/i )            ? $self->addDASglyph_box(@_)
    : ( $glyphTYPE =~ /^CROSS$/i )          ? $self->addDASglyph_cross(@_)
    : ( $glyphTYPE =~ /^DOT$/i )            ? $self->addDASglyph_dot(@_)
    : ( $glyphTYPE =~ /^EX$/i )             ? $self->addDASglyph_ex(@_)
    : ( $glyphTYPE =~ /^HIDDEN$/i )         ? undef
    : ( $glyphTYPE =~ /^LINE$/i )           ? $self->addDASglyph_line(@_)
    : ( $glyphTYPE =~ /^SPAN$/i )           ? $self->addDASglyph_span(@_)
    : ( $glyphTYPE =~ /^TEXT$/i )           ? $self->addDASglyph_text(@_)
    : ( $glyphTYPE =~ /^PRIMERS$/i )        ? $self->addDASglyph_primers(@_)
    : ( $glyphTYPE =~ /^TOOMANY$/i )        ? $self->addDASglyph_toomany(@_)
    : ( $glyphTYPE =~ /^TRIANGLE$/i )       ? $self->addDASglyph_triangle(@_)
    : undef;

}

sub addDASglyph_arrow {
  my $self = shift;
  my ( $x1, $x2, $y, $featHR, $glyphHR ) = @_;

  my $height  = ( exists( $glyphHR->{'ARROW'}->{'HEIGHT'} ) )  ? $glyphHR->{'ARROW'}->{'HEIGHT'}  : 4;
  my $fgcolor = ( exists( $glyphHR->{'ARROW'}->{'FGCOLOR'} ) ) ? $glyphHR->{'ARROW'}->{'FGCOLOR'} : 'black';
  my $bgcolor = ( exists( $glyphHR->{'ARROW'}->{'BGCOLOR'} ) ) ? $glyphHR->{'ARROW'}->{'BGCOLOR'} : 'green';
  my $stroke  = ( exists( $glyphHR->{'ARROW'}->{'LINEWIDTH'} ) ) ? $glyphHR->{'ARROW'}->{'LINEWIDTH'} : 1;
  my $parallel =
      ( exists( $glyphHR->{'ARROW'}->{'PARALLEL'} ) )
    ? ( $glyphHR->{'ARROW'}->{'PARALLEL'} =~ /no/i )
    ? 0
    : ( $glyphHR->{'ARROW'}->{'PARALLEL'} =~ /false/i ) ? 0
    : $glyphHR->{'ARROW'}->{'PARALLEL'}
    : 1;

  my $poly = new GD::Polygon;
  {
    use integer;
    if ($parallel) {
      my $mid = $y - ( $height / 2 );
      $poly->addPt( $x1, $mid );
      $poly->addPt( ( $x1 + ( $height / 2 ) ), $y - $height );
      $poly->addPt( $x2 - ( $height / 2 ), $y - $height );
      $poly->addPt( $x2, $mid );
      $poly->addPt( $x2 - ( $height / 2 ), $y );
      $poly->addPt( ( $x1 + ( $height / 2 ) ), $y );
      $poly->addPt( $x1, $mid );
    } else {
      my $mid = ( $x1 + $x2 ) / 2;
      $poly->addPt( $mid, $y - $height );
      $poly->addPt( $x2,  $y - $height + ( $height / 2 ) );
      $poly->addPt( $x2,  $y - ( $height / 2 ) );
      $poly->addPt( $mid, $y );
      $poly->addPt( $x1,  $y - ( $height / 2 ) );
      $poly->addPt( $x1,  $y - $height + ( $height / 2 ) );
      $poly->addPt( $mid, $y - $height );
    }
  }

  $self->{'img'}->filledPolygon( $poly, $self->_GV_addColor($bgcolor) );
  $self->{'img'}->setThickness($stroke);
  $self->{'img'}->openPolygon( $poly, $self->_GV_addColor($fgcolor) );
  $self->{'img'}->setThickness(1);

  return ( 1, [ $y - $height, $y, $x1, $x2 ], $glyphHR );
}

sub addDASglyph_anchored_arrow {
  my $self = shift;
  my ( $x1, $x2, $y, $featHR, $glyphHR ) = @_;

  return undef if ( !exists( $featHR->{'ORIENTATION'} ) );
  return $self->addDASglyph_box( $x1, $x2, $y, $featHR, { 'BOX' => $glyphHR->{'ANCHORED_ARROW'} } ) if ( $featHR->{'ORIENTATION'} eq '0' );

  my $height  = ( exists( $glyphHR->{'ANCHORED_ARROW'}->{'HEIGHT'} ) )  ? $glyphHR->{'ANCHORED_ARROW'}->{'HEIGHT'}  : 4;
  my $fgcolor = ( exists( $glyphHR->{'ANCHORED_ARROW'}->{'FGCOLOR'} ) ) ? $glyphHR->{'ANCHORED_ARROW'}->{'FGCOLOR'} : 'black';
  my $bgcolor = ( exists( $glyphHR->{'ANCHORED_ARROW'}->{'BGCOLOR'} ) ) ? $glyphHR->{'ANCHORED_ARROW'}->{'BGCOLOR'} : 'green';
  my $stroke  = ( exists( $glyphHR->{'ANCHORED_ARROW'}->{'LINEWIDTH'} ) ) ? $glyphHR->{'ANCHORED_ARROW'}->{'LINEWIDTH'} : 1;
  my $parallel =
      ( exists( $glyphHR->{'ANCHORED_ARROW'}->{'PARALLEL'} ) )
    ? ( $glyphHR->{'ANCHORED_ARROW'}->{'PARALLEL'} =~ /no/i )
    ? 0
    : ( $glyphHR->{'ANCHORED_ARROW'}->{'PARALLEL'} =~ /false/i ) ? 0
    : $glyphHR->{'ANCHORED_ARROW'}->{'PARALLEL'}
    : 1;

  my $poly = new GD::Polygon;
  {
    use integer;
    if ($parallel) {
      my $mid = $y - ( $height / 2 );
      if ( $featHR->{'ORIENTATION'} eq '+' ) {
        $poly->addPt( $x1, $y - $height );
        $poly->addPt( ( $x2 - ( $height / 2 ) ), $y - $height );
        $poly->addPt( $x2, $mid );
        $poly->addPt( ( $x2 - ( $height / 2 ) ), $y );
        $poly->addPt( $x1, $y );
        $poly->addPt( $x1, $y - $height );
      } else {
        $poly->addPt( $x1, $mid );
        $poly->addPt( ( $x1 + ( $height / 2 ) ), $y - $height );
        $poly->addPt( $x2, $y - $height );
        $poly->addPt( $x2, $y );
        $poly->addPt( ( $x1 + ( $height / 2 ) ), $y );
        $poly->addPt( $x1, $mid );
      }
    } else {
      my $mid = ( $x1 + $x2 ) / 2;
      if ( $featHR->{'ORIENTATION'} eq '+' ) {
        $poly->addPt( $mid, $y - $height );
        $poly->addPt( $x2,  $y - $height + ( $height / 2 ) );
        $poly->addPt( $x2,  $y );
        $poly->addPt( $x1,  $y );
        $poly->addPt( $x1,  $y - $height + ( $height / 2 ) );
        $poly->addPt( $mid, $y - $height );
      } else {
        $poly->addPt( $x1,  $y - $height );
        $poly->addPt( $x2,  $y - $height );
        $poly->addPt( $x2,  $y - ( $height / 2 ) );
        $poly->addPt( $mid, $y );
        $poly->addPt( $x1,  $y - ( $height / 2 ) );
        $poly->addPt( $x1,  $y );
      }
    }
  }

  $self->{'img'}->filledPolygon( $poly, $self->_GV_addColor($bgcolor) );
  $self->{'img'}->setThickness($stroke);
  $self->{'img'}->openPolygon( $poly, $self->_GV_addColor($fgcolor) );
  $self->{'img'}->setThickness(1);

  return ( 1, [ $y - $height, $y, $x1, $x2 ], $glyphHR );
}

sub addDASglyph_box {
  my $self = shift;
  my ( $x1, $x2, $y, $featHR, $glyphHR ) = @_;

  my $height  = ( exists( $glyphHR->{'BOX'}->{'HEIGHT'} ) )    ? $glyphHR->{'BOX'}->{'HEIGHT'}    : 4;
  my $fgcolor = ( exists( $glyphHR->{'BOX'}->{'FGCOLOR'} ) )   ? $glyphHR->{'BOX'}->{'FGCOLOR'}   : 'black';
  my $bgcolor = ( exists( $glyphHR->{'BOX'}->{'BGCOLOR'} ) )   ? $glyphHR->{'BOX'}->{'BGCOLOR'}   : 'green';
  my $stroke  = ( exists( $glyphHR->{'BOX'}->{'LINEWIDTH'} ) ) ? $glyphHR->{'BOX'}->{'LINEWIDTH'} : 1;
  {
    use integer;
    $self->{'img'}->filledRectangle( $x1, $y - $height, $x2, $y, $self->_GV_addColor($bgcolor) );
    $self->{'img'}->setThickness($stroke);
    $self->{'img'}->rectangle( $x1, $y - $height, $x2, $y, $self->_GV_addColor($fgcolor) );
    $self->{'img'}->setThickness(1);
  }

  return ( 1, [ $y - $height, $y, $x1, $x2 ], $glyphHR );
}

sub addDASglyph_cross {
  my $self = shift;
  my ( $x1, $x2, $y, $featHR, $glyphHR ) = @_;

  my $height  = ( exists( $glyphHR->{'CROSS'}->{'HEIGHT'} ) )  ? $glyphHR->{'CROSS'}->{'HEIGHT'}  : 4;
  my $fgcolor = ( exists( $glyphHR->{'CROSS'}->{'FGCOLOR'} ) ) ? $glyphHR->{'CROSS'}->{'FGCOLOR'} : 'black';

  {
    use integer;
    my $midX = ( $x1 + $x2 ) / 2;
    $self->{'img'}->line( $midX - ( $height / 2 ), $y - ( $height / 2 ), $midX + ( $height / 2 ), $y - ( $height / 2 ), $self->_GV_addColor($fgcolor) );
    $self->{'img'}->line( $midX, $y - $height, $midX, $y, $self->_GV_addColor($fgcolor) );
  }

  return ( 1, [ $y - $height, $y, $x1, $x2 ], $glyphHR );
}

sub addDASglyph_dot {
  my $self = shift;
  my ( $x1, $x2, $y, $featHR, $glyphHR ) = @_;

  my $height  = ( exists( $glyphHR->{'DOT'}->{'HEIGHT'} ) )  ? $glyphHR->{'DOT'}->{'HEIGHT'}  : 4;
  my $fgcolor = ( exists( $glyphHR->{'DOT'}->{'FGCOLOR'} ) ) ? $glyphHR->{'DOT'}->{'FGCOLOR'} : 'black';
  my $bgcolor = ( exists( $glyphHR->{'DOT'}->{'BGCOLOR'} ) ) ? $glyphHR->{'DOT'}->{'BGCOLOR'} : 'green';

  {
    use integer;
    my $midX = ( $x1 + $x2 ) / 2;
    $self->{'img'}->filledEllipse( $midX, $y - ( $height / 2 ), $height, $height, $self->_GV_addColor($bgcolor) );
    $self->{'img'}->ellipse( $midX, $y - ( $height / 2 ), $height, $height, $self->_GV_addColor($fgcolor) );
  }

  return ( 1, [ $y - $height, $y, $x1, $x2 ], $glyphHR );
}

sub addDASglyph_ex {
  my $self = shift;
  my ( $x1, $x2, $y, $featHR, $glyphHR ) = @_;

  my $height  = ( exists( $glyphHR->{'EX'}->{'HEIGHT'} ) )  ? $glyphHR->{'EX'}->{'HEIGHT'}  : 4;
  my $fgcolor = ( exists( $glyphHR->{'EX'}->{'FGCOLOR'} ) ) ? $glyphHR->{'EX'}->{'FGCOLOR'} : 'black';

  {
    use integer;
    my $midX = ( $x1 + $x2 ) / 2;
    $self->{'img'}->line( $midX - ( $height / 2 ), $y - $height, $midX + ( $height / 2 ), $y, $self->_GV_addColor($fgcolor) );
    $self->{'img'}->line( $midX - ( $height / 2 ), $y, $midX + ( $height / 2 ), $y - $height, $self->_GV_addColor($fgcolor) );
  }

  return ( 1, [ $y - $height, $y, $x1, $x2 ], $glyphHR );
}

sub addDASglyph_line {
  my $self = shift;
  my ( $x1, $x2, $y, $featHR, $glyphHR ) = @_;

  my $height  = ( exists( $glyphHR->{'LINE'}->{'HEIGHT'} ) )  ? $glyphHR->{'LINE'}->{'HEIGHT'}  : 4;
  my $fgcolor = ( exists( $glyphHR->{'LINE'}->{'FGCOLOR'} ) ) ? $glyphHR->{'LINE'}->{'FGCOLOR'} : 'black';
  my $style   = ( exists( $glyphHR->{'LINE'}->{'STYLE'} ) )   ? $glyphHR->{'LINE'}->{'STYLE'}   : 'hat';
  $style = 'hat' if ( $style eq 'intron' );    ## Even ensembl should read the standards doc!!

  if ( $style eq 'hat' ) {
    {
      use integer;
      my $mid = ( $x1 + $x2 ) / 2;
      $self->{'img'}->line( $x1, $y, $mid, $y - $height, $self->_GV_addColor($fgcolor) );
      $self->{'img'}->line( $mid, $y - $height, $x2, $y, $self->_GV_addColor($fgcolor) );
    }
  } elsif ( $style eq 'solid' ) {
    {
      use integer;
      $self->{'img'}->line( $x1, $y - ( $height / 2 ), $x2, $y - ( $height / 2 ), $self->_GV_addColor($fgcolor) );
    }
  } elsif ( $style eq 'dashed' ) {
    {
      use integer;
      $self->{'img'}->setStyle( $self->_GV_addColor($fgcolor), $self->_GV_addColor($fgcolor), gdTransparent, gdTransparent );
      $self->{'img'}->line( $x1, $y - ( $height / 2 ), $x2, $y - ( $height / 2 ), gdStyled );
    }
  }

  return ( 1, [ $y - $height, $y, $x1, $x2 ], $glyphHR );
}

sub addDASglyph_span {
  my $self = shift;
  my ( $x1, $x2, $y, $featHR, $glyphHR ) = @_;

  my $height  = ( exists( $glyphHR->{'SPAN'}->{'HEIGHT'} ) )  ? $glyphHR->{'SPAN'}->{'HEIGHT'}  : 4;
  my $fgcolor = ( exists( $glyphHR->{'SPAN'}->{'FGCOLOR'} ) ) ? $glyphHR->{'SPAN'}->{'FGCOLOR'} : 'black';

  $self->{'img'}->line( $x1, $y - ( $height / 2 ), $x2, $y - ( $height / 2 ), $self->_GV_addColor($fgcolor) );
  $self->{'img'}->line( $x1, $y - $height, $x1, $y, $self->_GV_addColor($fgcolor) );
  $self->{'img'}->line( $x2, $y - $height, $x2, $y, $self->_GV_addColor($fgcolor) );

  return ( 1, [ $y - $height, $y, $x1, $x2 ], $glyphHR );
}

sub addDASglyph_text {
  my $self = shift;
  my ( $x1, $x2, $y, $featHR, $glyphHR ) = @_;

  my $fontsize = ( exists( $glyphHR->{'TEXT'}->{'FONTSIZE'} ) ) ? $glyphHR->{'TEXT'}->{'FONTSIZE'} : ( exists( $glyphHR->{'TEXT'}->{'HEIGHT'} ) ) ? $glyphHR->{'TEXT'}->{'HEIGHT'} : 8;
  my $fgcolor  = ( exists( $glyphHR->{'TEXT'}->{'FGCOLOR'} ) )  ? $glyphHR->{'TEXT'}->{'FGCOLOR'}  : 'black';
  my $font     = ( exists( $glyphHR->{'TEXT'}->{'FONT'} ) )     ? $glyphHR->{'TEXT'}->{'FONT'}     : 'helvetica';
  my $string   = ( exists( $glyphHR->{'TEXT'}->{'STRING'} ) )   ? $glyphHR->{'TEXT'}->{'STRING'}   : 'TEST';
  my $styleAR  = ( exists( $glyphHR->{'TEXT'}->{'STYLE'} ) )    ? $glyphHR->{'TEXT'}->{'STYLE'}    : ['italic'];

  my @bounds = ();
  {
    use integer;
    my $midX = ( $x1 + $x2 ) / 2;
    $self->{'img'}->useFontConfig(1);
    @bounds = GD::Image->stringFT( $self->_GV_addColor($fgcolor), "${font}:" . join( ',', @$styleAR ), $fontsize, 0, 0, 0, $string );
    @bounds = $self->{'img'}->stringFT( $self->_GV_addColor($fgcolor), "${font}:" . join( ',', @$styleAR ), $fontsize, 0, $midX - ( $bounds[2] / 2 ), $y - $fontsize, $string );
  }
  return ( 1, [ $y - $fontsize, $y, $bounds[0], $bounds[4] ], $glyphHR );
}

sub addDASglyph_primers {
  my $self = shift;
  my ( $x1, $x2, $y, $featHR, $glyphHR ) = @_;

  my $height  = ( exists( $glyphHR->{'PRIMERS'}->{'HEIGHT'} ) )  ? $glyphHR->{'PRIMERS'}->{'HEIGHT'}  : 4;
  my $fgcolor = ( exists( $glyphHR->{'PRIMERS'}->{'FGCOLOR'} ) ) ? $glyphHR->{'PRIMERS'}->{'FGCOLOR'} : 'black';
  my $bgcolor = ( exists( $glyphHR->{'PRIMERS'}->{'BGCOLOR'} ) ) ? $glyphHR->{'PRIMERS'}->{'BGCOLOR'} : 'green';
  my $stroke  = ( exists( $glyphHR->{'PRIMERS'}->{'LINEWIDTH'} ) ) ? $glyphHR->{'PRIMERS'}->{'LINEWIDTH'} : 1;

  {
    use integer;
    $self->{'img'}->setThickness($stroke);
    $self->{'img'}->line( $x1, $y - $height, $x1 + ( $height / 2 ), $y - ( $height / 2 ), $self->_GV_addColor($fgcolor) );
    $self->{'img'}->line( $x1, $y, $x1 + ( $height / 2 ), $y - ( $height / 2 ), $self->_GV_addColor($fgcolor) );
    $self->{'img'}->line( $x1 + ( $height / 2 ), $y - ( $height / 2 ), $x2 - ( $height / 2 ), $y - ( $height / 2 ), $self->_GV_addColor($bgcolor) );
    $self->{'img'}->line( $x2, $y - $height, $x2 - ( $height / 2 ), $y - ( $height / 2 ), $self->_GV_addColor($fgcolor) );
    $self->{'img'}->line( $x2, $y, $x2 - ( $height / 2 ), $y - ( $height / 2 ), $self->_GV_addColor($fgcolor) );
    $self->{'img'}->setThickness(1);
  }

  return ( 1, [ $y - $height, $y, $x1, $x2 ], $glyphHR );
}

sub addDASglyph_toomany {
  my $self = shift;
  my ( $x1, $x2, $y, $featHR, $glyphHR ) = @_;

  ## recomended presentation is overlapping boxes >> use 'static y height = 10' BOX glyph
  return $self->addDASglyph_box( $x1, $x2, 10, $featHR, { 'BOX' => $glyphHR->{'TOOMANY'} } );
}

sub addDASglyph_triangle {
  my $self = shift;
  my ( $x1, $x2, $y, $featHR, $glyphHR ) = @_;

  my $height    = ( exists( $glyphHR->{'TRIANGLE'}->{'HEIGHT'} ) )    ? $glyphHR->{'TRIANGLE'}->{'HEIGHT'}    : 4;
  my $fgcolor   = ( exists( $glyphHR->{'TRIANGLE'}->{'FGCOLOR'} ) )   ? $glyphHR->{'TRIANGLE'}->{'FGCOLOR'}   : 'black';
  my $bgcolor   = ( exists( $glyphHR->{'TRIANGLE'}->{'BGCOLOR'} ) )   ? $glyphHR->{'TRIANGLE'}->{'BGCOLOR'}   : 'green';
  my $width     = ( exists( $glyphHR->{'TRIANGLE'}->{'LINEWIDTH'} ) ) ? $glyphHR->{'TRIANGLE'}->{'LINEWIDTH'} : 4;
  my $direction = ( exists( $glyphHR->{'TRIANGLE'}->{'DIRECTION'} ) ) ? $glyphHR->{'TRIANGLE'}->{'DIRECTION'} : 'S';
  my $stroke  = ( exists( $glyphHR->{'TRIANGLE'}->{'LINEWIDTH'} ) ) ? $glyphHR->{'TRIANGLE'}->{'LINEWIDTH'} : 1;

  my $poly = new GD::Polygon;
  {
    use integer;
    my $mid = ( $x1 + $x2 ) / 2;
    if ( $direction =~ /N/i ) {
      $poly->addPt( $mid, $y - $height );
      $poly->addPt( $mid + ( $width / 2 ), $y );
      $poly->addPt( $mid - ( $width / 2 ), $y );
      $poly->addPt( $mid, $y - $height );
    } elsif ( $direction =~ /S/i ) {
      $poly->addPt( $mid - ( $width / 2 ), $y - $height );
      $poly->addPt( $mid + ( $width / 2 ), $y - $height );
      $poly->addPt( $mid, $y );
      $poly->addPt( $mid - ( $width / 2 ), $y - $height );
    } elsif ( $direction =~ /E/i ) {
      $poly->addPt( $mid - ( $width / 2 ), $y - $height );
      $poly->addPt( $mid + ( $width / 2 ), $y - ( $height / 2 ) );
      $poly->addPt( $mid - ( $width / 2 ), $y );
      $poly->addPt( $mid - ( $width / 2 ), $y - $height );
    } elsif ( $direction =~ /W/i ) {
      $poly->addPt( $mid + ( $width / 2 ), $y - $height );
      $poly->addPt( $mid - ( $width / 2 ), $y - ( $height / 2 ) );
      $poly->addPt( $mid + ( $width / 2 ), $y );
      $poly->addPt( $mid + ( $width / 2 ), $y - $height );
    } else {
      return undef;
    }
  }    

  $self->{'img'}->filledPolygon( $poly, $self->_GV_addColor($bgcolor) );
  $self->{'img'}->setThickness($stroke);
  $self->{'img'}->openPolygon( $poly, $self->_GV_addColor($fgcolor) );
  $self->{'img'}->setThickness(1);

  return ( 1, [ $y - $height, $y, $x1, $x2 ], $glyphHR );
}

##################### End of DAS functions ###################

##################### End of Package #########################
1;
