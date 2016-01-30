#!/usr/bin/perl


use Bio::SeqFeature::Generic;
use Bio::Graphics;
use Bio::Graphics::Feature;
use GD;
use strict vars;
use vars qw(
%EV
$start
$end
$segment
$length
$GV
$PRM
);

require 'das_scripts/dasFunctions.pl';
require 'yrGATE_functions.pl';

sub returnImageMap{

my $segment = $PRM->{chr};
my $start = $PRM->{start};
my $end = $PRM->{end};

my $length = $end-$start;

#do 'gffParse.pl';

# define panel
my $margin = 10;
 my $panel = Bio::Graphics::Panel->new(
                                      -length    => $length,
				      -offset    => $start,
 				      -key_style => 'between', # labels for sequences
 				      -width     => $PRM->{imgWidth} - 2*$margin,
 				      -pad_left  => $margin,
 				      -pad_right => $margin,
 				      );

;


# add scale to image

   my $rulerScale = Bio::SeqFeature::Generic->new(-start=>$start,-end=>$end);
   $panel->add_track($rulerScale,
                     -glyph   => 'arrow',
                     -tick    => 2,
                     -fgcolor => 'black',
                     -double  => 2,
		     -label =>1
                    );


### per track

my %FullStructs = ();

my %DAScolors ;#= dasColors();

for my $seqType (sort keys %EV){
my @geneFeats = ();
my @seqLabels = ();
my $color = $EV{$seqType}->{color};
for my $seqId (keys %{$EV{$seqType}}){
    if ($seqId eq "color"){
	next;
    }
  my $strand = $EV{$seqType}->{$seqId}->{strand};
  my @exons = keys(%{$EV{$seqType}->{$seqId}->{exons}});

 @exons = ($strand == 1) ? sort by_coord @exons : reverse sort by_coord @exons; 


 my @exonFeats = ();
  for (my $j=0;$j<scalar(@exons);$j++){
    my ($start,$stop) = $exons[$j] =~ /(\d+)\.\.(\d+)/;
    $exonFeats[++$#exonFeats] = Bio::Graphics::Feature->new(-start=>min($start,$stop),-stop=>max($start,$stop),-type=>'exon', -name=>$seqId."_idToExon_".$exons[$j], -label=>'yes', -strand=>$strand);

    $FullStructs{$seqId} .= (($FullStructs{$seqId} eq "") ? "" : ",")."$start  $stop";
    
  }  
  $geneFeats[++$#geneFeats] = Bio::Graphics::Feature->new(-segments=>\@exonFeats,-type=>'gene',-name=>"$seqId",-label=>"$seqId");
  $seqLabels[++$#seqLabels] = $seqId;
}

$panel->add_track(\@geneFeats, -glyph => 'transcript2',-bgcolor => $color, -fgcolor => $color, -label=>1,-box_subparts=>1);

}


### per track


### image map
my @boxes = $panel->boxes();
my $imgMAP = "<map name='eMap'>";
my %imgMAPlabeled;
for (my$i=0;$i<scalar(@boxes);$i++){
    my $obj = $boxes[$i][0];
    my ($seqId,$exon) = split /\_idToExon\_/, $obj->display_name;
    $exon =~ s/\.\./\,/;
    if ($exon ne ""){
    $imgMAP .= "<area shape='rect' coords='$boxes[$i][1],$boxes[$i][2],$boxes[$i][3],$boxes[$i][4]' href='javascript:GraphicExonSelect($exon);'>\n";
    if (!$imgMAPlabeled{$seqId}){
      my $LabelWidth = gdMediumBoldFont->width * (length($seqId)-1);
      my $LabelHeight = gdMediumBoldFont->height;
      my @sFS = split /\,/, $FullStructs{$seqId};  
      $imgMAP .= "<area shape='rect' coords='$boxes[$i][1],".($boxes[$i][2]-$LabelHeight).",".($boxes[$i][1]+$LabelWidth).",".($boxes[$i][4]-$LabelHeight)."' href='javascript:SelectStruct(\"".join(",",@sFS)."\");'>\n";
      $imgMAPlabeled{$seqId}++;
    }
    }

}
$imgMAP .= "</map>";

### scale and label width
my $scale;


my $imageFileName = "$PRM->{chr}.$PRM->{start}.$PRM->{end}.png";
open (OF, ">$GV->{tempImageDir}$imageFileName") || bailOut("cannot open >$GV->{tempImageDir}$imageFileName");
print OF $panel->png();
close OF;

my $str = "<img src='$GV->{tempImageWebDir}$imageFileName' useMap=\"#eMAP\" class=mainTable id='ePlotImage'>$imgMAP";

return $str;
}

1;
