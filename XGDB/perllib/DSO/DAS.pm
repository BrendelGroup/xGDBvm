package DAS;
use base "Locus";

do 'SITEDEF.pl';

use GeneView;
use CGI ':all';    ## prbly could get rid of this easily

sub _init {
  my $self = shift;
  $self->SUPER::_init(@_);

}

sub queryREGION {
  my $self = shift;
  my ( $argHR, $img_paramHR ) = @_;
  my ( $imgfn, $DASquery );
  my ( $imgHTML, $imgNAME, $imgIMAP );
  my ( $tcHTML,  $tcCOLOR, $tcNAME );

  if ( exists( $argHR->{altCONTEXT} ) && ( $argHR->{altCONTEXT} eq "BAC" ) && exists( $argHR->{l_pos} ) && exists( $argHR->{r_pos} ) ) {
    $imgfn = "$self->{trackname}_$self->{db_id}_gseg" . join( '-', @$argHR{ 'gseg_gi', 'l_pos', 'r_pos', 'fontSize', 'imgW' } ) . "GC.png";
    $DASquery = "features?segment=" . $self->xID( $argHR->{'gseg_gi'} ) . ":$argHR->{l_pos},$argHR->{r_pos}";
  } elsif ( exists( $argHR->{chr} ) && exists( $argHR->{l_pos} ) && exists( $argHR->{r_pos} ) ) {
    $imgfn = "$self->{trackname}_$self->{db_id}_chr" . join( '-', @$argHR{ 'chr', 'l_pos', 'r_pos', 'fontSize', 'imgW' } ) . "GC.png";
    $DASquery = "features?segment=" . $self->xID( $argHR->{'chr'} ) . ":$argHR->{l_pos},$argHR->{r_pos}";
  } else {
    return undef;
  }

  require LWP::UserAgent;
  require XML::Simple;

  my $ua = LWP::UserAgent->new();
  my $xp = XML::Simple->new();

  $self->{DASservice} .= "/" if(exists($self->{DASservice}) && ($self->{DASservice} !~ /\/$/));
#<DEBUG>#print STDERR "[DAS.pm::queryREGION] Accessing DAS service $self->{DASservice}$self->{DASdsn}\n";

  ####!!!!! Need to play nice if server doesn't send a stylesheet #####
  #my $test_response = $ua->get( $self->{DASservice} . $self->{DASdsn} . "/stylesheet" );
  #print STDERR $test_response->is_error() . " <<< " . $test_response->content();

  my $response = $ua->get( $self->{DASservice} . $self->{DASdsn} . "/" . $DASquery )->content();
  $argHR->{'dasFeatures'} = $xp->XMLin( $response, KeyAttr => { GROUP => "+id" }, ForceArray => [ 'FEATURE', 'GROUP' ] ) if($response =~ /<feature/i);
#<DEBUG>#print STDERR "[DAS.pm::queryREGION] DAS Features successfully parsed\n";

  $response = $ua->get( $self->{DASservice} . $self->{DASdsn} . "/stylesheet" )->content();
  $argHR->{'dasStyle'} = $xp->XMLin( $response, ForceArray => [ 'CATEGORY', 'TYPE' ] ) if($response =~ /<stylesheet/i);
#<DEBUG>#print STDERR "[DAS.pm::queryREGION] DAS Stylesheet successfully parsed\n";

  ( $imgHTML, $imgNAME, $imgIMAP ) = $self->drawREGION( $argHR, $img_paramHR, $imgfn );
  ( $tcHTML, $tcCOLOR, $tcNAME ) = $self->getTRACKCELL( $argHR, $imgfn );

  return ( $tcNAME, $tcCOLOR, $tcHTML, $imgHTML, $imgNAME, $imgIMAP );
}

sub drawREGION {
  my $self = shift;
  return $self->drawDASREGION(@_);
}

sub getTRACKCELL {
  my $self = shift;
  my ( $argHR, $imgfn ) = @_;
  my ( $html, $color, $name );

  my ($stdcheck) = ('checked');

  $name  = $self->{trackname};
  $color = $self->{primaryColor};
  $html  = "<img id='$self->{resid}' class='cth-button xgdb-track-delete' src='${IMAGEDIR}xgdb-delete.png'>";

  return ( $html, $color, $name );
}

sub xID {    ## Translate segment IDs / entry points into preferred aliases
  my $self = shift;
  my ($id) = @_;

  return $id;
}

1;
