#!/usr/bin/perl -w

# VER 1.02
# Updated by Hong Lu @ 2008/06/09
# Description:
#  1. Add some colors
#  2. Add CDSstart & CDSstop

# VER 1.03 
# Updated by Hong Lu @ 2008/06/22
# Description:
#   1. Simplify code.

use CGI ":all";
use GD;
use Switch;

my $q = new CGI;
print $q->header( -type => "image/png");

# The only global variable: [$im] 
# 700 x 80
############# Defaults #################
$seqColor = "blue";
$MarginX   =30;
$imgWidth  = 700;
$imgHeight = 122;
# Ruler
$RulerInitY  =10;
$RulerHeight =3;
$LongScaleHeight  = 5;
$ShortScaleHeight = 2;
$ScaleNumHeight   = 20;
($rulerStart, $rulerEnd) = (5500, 7000);
$rulerLength = $rulerEnd - $rulerStart;
# Chr
$chrInitY  = 50;
$chrHeight = 5;
($chrStart, $chrEnd) = ($MarginX, $imgWidth-$MarginX);
# Spliced Exons
$ExonInitY    = 80;
$ExonHeight   = 5;
$IntronHeight = 82.5;
$align    = "6000|6100|6350|6550";
$prefix   = "5500|5700";
$surfix   = "6800|7000";
$CDSstart = 6020;
$CDSstop  = 6500;
@matchTerm = split(/\|/, $align);
# Aligned Exons
$mergeInitY  = 110;
$mergeHeight = 5;
$mergeAlign  = "6150|6450";
$MGstart = 6170;
$MGstop  = 6400;
# Parameters
if (defined param("SELopt")) {
  $highlight = param("SELopt");
}
else {
  $highlight = "NULL";
}
drawFigure();

binmode STDOUT;
print $im->png;
#******************Main Function Finished*******************

#***********************************************************
# http://www.twydiink.com/colortest.htm
sub drawFigure {
  $im = new GD::Image($imgWidth, $imgHeight);
  # allocate some colors
  $white     = $im->colorAllocate(255,255,255);
  $black     = $im->colorAllocate(0,0,0);      
  $blue      = $im->colorAllocate(0,0,255),    # chromosome
  $gray      = $im->colorAllocate(192,192,192),
  $fireBrick = $im->colorAllocate(178,34,34),
  $green     = $im->colorAllocate(0,128,0),
  $lightBlue = $im->colorAllocate(173,216,230),
  $pink      = $im->colorAllocate(255,192,203),
  $purple    = $im->colorAllocate(128,0,128);
  $red       = $im->colorAllocate(255,0,0);
  $hotpink   = $im->colorAllocate(255,105,180);
  $grey      = $im->colorAllocate(128,128,128);
  $indianred = $im->colorAllocate(205,92,92);
  $khaki     = $im->colorAllocate(240,230,140);
  $gold      = $im->colorAllocate(255,215,0);
  $cyan      = $im->colorAllocate(0,255,255);
  $magenta   = $im->colorAllocate(255,0,255);
  $chocolate = $im->colorAllocate(210,105,30);
  $olive     = $im->colorAllocate(128,128,0);
  $aqua      = $im->colorAllocate(0,255,255);
  $brown     = $im->colorAllocate(165,42,42);
  $maroon    = $im->colorAllocate(128,0,0);
  $lime      = $im->colorAllocate(0,255,0);

  # make the background transparent and interlaced
  $im->transparent($white);
  $im->interlaced('true');

  switch ($seqColor) {
    case /^white$/i     {$color = $white;    }
    case /^black$/i     {$color = $black;    }
    case /^blue$/i      {$color = $blue;     }
    case /^fireBrick$/i {$color = $fireBrick;}
    case /^green$/i     {$color = $green;    }
    case /^lightBlue$/i {$color = $lightBlue;}
    case /^pink$/i      {$color = $pink;     }
    case /^purple$/i    {$color = $purple;   }
    case /^red$/i       {$color = $red;      }
    case /^hotpink$/i   {$color = $hotpink;  }
    case /^grey$/i      {$color = $grey;     }
    case /^indianred$/i {$color = $indianred;}
    case /^khaki$/i     {$color = $khaki;    }
    case /^gold$/i      {$color = $gold;     }
    case /^cyan$/i      {$color = $cyan;     }
    case /^magenta$/i   {$color = $magenta;  }
    case /^chocolate$/i {$color = $chocolate;}
    case /^olive$/i     {$color = $olive;    }
    case /^aqua$/i      {$color = $aqua;     }
    case /^brown$/i     {$color = $brown;    }
    case /^maroon$/i    {$color = $maroon;   }
    case /^lime$/i      {$color = $lime;     }
    else                {$color = $pink;}
  }
  drawRuler();
  &drawArrow($chrStart, $chrEnd, $chrInitY, $chrHeight, $gray);
  drawGene($color, $align, $ExonInitY, $ExonHeight, $CDSstart, $CDSstop);
  drawGene($color, $prefix, $ExonInitY, $ExonHeight);
  drawGene($color, $surfix, $ExonInitY, $ExonHeight);
  drawGene($color, $mergeAlign, $mergeInitY, $mergeHeight, $MGstart, $MGstop);
  drawLine(($chrInitY+$chrHeight),5700, $ExonInitY, 5700);
  drawLine(($chrInitY+$chrHeight),6000, $ExonInitY, 6000);
  drawLine(($chrInitY+$chrHeight),6100, $ExonInitY, 6100);
  drawLine(($chrInitY+$chrHeight),6350, $ExonInitY, 6350);
  drawLine(($chrInitY+$chrHeight),6550, $ExonInitY, 6550);
  drawLine(($chrInitY+$chrHeight),6800, $ExonInitY, 6800);
  drawLine(($ExonInitY+$ExonHeight/2),6000, $mergeInitY, 6150);
  drawLine(($ExonInitY+$ExonHeight/2),6100, $mergeInitY, 6250);
  drawLine(($ExonInitY+$ExonHeight/2),6350, $mergeInitY, 6250);
  drawLine(($ExonInitY+$ExonHeight/2),6550, $mergeInitY, 6450);

  $im->string(gdSmallFont, $MarginX, $chrInitY-15,  "Genome", $black);
  $im->string(gdSmallFont, $MarginX, $ExonInitY-20,  "Adjacent gene", $black);

  $tmp_x = $MarginX + ($imgWidth-2*$MarginX)*(6180-$rulerStart)/$rulerLength;
  $im->string(gdSmallFont, $tmp_x, $ExonInitY-20,  "My gene", $black);

  $tmp_x = $MarginX + ($imgWidth-2*$MarginX)*(6810-$rulerStart)/$rulerLength;
  $im->string(gdSmallFont, $tmp_x, $ExonInitY-20,  "Adjacent gene", $black);

  $tmp_x = $MarginX + ($imgWidth-2*$MarginX)*(5870-$rulerStart)/$rulerLength;
  $im->string(gdSmallFont, $tmp_x, $ExonInitY-5,  "Pre-mRNA", $black);

#  $im->string(gdSmallFont, $MarginX, $ExonInitY-15, "Spliced gene", $black);
  my $tmp_x2 = $MarginX + ($imgWidth-2*$MarginX)*(5950-$rulerStart)/$rulerLength;
  $im->string(gdSmallFont, $tmp_x2, $mergeInitY-6, "Spliced-mRNA", $black);

  if ($highlight eq "5_prime|in") {
    my ($tmpStart, $tmpEnd);
    $tmpStart = $MarginX + ($imgWidth-2*$MarginX)*(5600-$rulerStart)/$rulerLength;
    $tmpEnd   = $MarginX + ($imgWidth-2*$MarginX)*(5999-$rulerStart)/$rulerLength;
    &drawArrow($tmpStart, $tmpEnd, $chrInitY, $chrHeight, $hotpink);
  }
  elsif ($highlight eq "5_prime|ex") {
    my ($tmpStart, $tmpEnd);
    $tmpStart = $MarginX + ($imgWidth-2*$MarginX)*(5701-$rulerStart)/$rulerLength;
    $tmpEnd   = $MarginX + ($imgWidth-2*$MarginX)*(5999-$rulerStart)/$rulerLength;
    &drawArrow($tmpStart, $tmpEnd, $chrInitY, $chrHeight, $hotpink);
  }
  elsif ($highlight eq "3_prime|in") {
    my ($tmpStart, $tmpEnd);
    $tmpStart = $MarginX + ($imgWidth-2*$MarginX)*(6551-$rulerStart)/$rulerLength;
    $tmpEnd   = $MarginX + ($imgWidth-2*$MarginX)*(6900-$rulerStart)/$rulerLength;
    &drawArrow($tmpStart, $tmpEnd, $chrInitY, $chrHeight, $hotpink);
  }
  elsif ($highlight eq "3_prime|ex") {
    my ($tmpStart, $tmpEnd);
    $tmpStart = $MarginX + ($imgWidth-2*$MarginX)*(6551-$rulerStart)/$rulerLength;
    $tmpEnd   = $MarginX + ($imgWidth-2*$MarginX)*(6799-$rulerStart)/$rulerLength;
    &drawArrow($tmpStart, $tmpEnd, $chrInitY, $chrHeight, $hotpink);
  }
  elsif ($highlight eq "allExons") {
    my ($tmpStart, $tmpEnd);
    $tmpStart = $MarginX + ($imgWidth-2*$MarginX)*(6000-$rulerStart)/$rulerLength;
    $tmpEnd   = $MarginX + ($imgWidth-2*$MarginX)*(6100-$rulerStart)/$rulerLength;
    &drawArrow($tmpStart, $tmpEnd, $chrInitY, $chrHeight, $hotpink);
    $tmpStart = $MarginX + ($imgWidth-2*$MarginX)*(6350-$rulerStart)/$rulerLength;
    $tmpEnd   = $MarginX + ($imgWidth-2*$MarginX)*(6550-$rulerStart)/$rulerLength;
    &drawArrow($tmpStart, $tmpEnd, $chrInitY, $chrHeight, $hotpink);
  }
  elsif ($highlight eq "allIntrons") {
    my ($tmpStart, $tmpEnd);
    $tmpStart = $MarginX + ($imgWidth-2*$MarginX)*(6101-$rulerStart)/$rulerLength;
    $tmpEnd   = $MarginX + ($imgWidth-2*$MarginX)*(6349-$rulerStart)/$rulerLength;
    &drawArrow($tmpStart, $tmpEnd, $chrInitY, $chrHeight, $hotpink);
  }
  elsif ($highlight eq "entireUnspliced") {
    my ($tmpStart, $tmpEnd);
    $tmpStart = $MarginX + ($imgWidth-2*$MarginX)*(6000-$rulerStart)/$rulerLength;
    $tmpEnd   = $MarginX + ($imgWidth-2*$MarginX)*(6550-$rulerStart)/$rulerLength;
    &drawArrow($tmpStart, $tmpEnd, $chrInitY, $chrHeight, $hotpink);
  }
  elsif ($highlight eq "entireAligned") {
    my ($tmpStart, $tmpEnd);
    $tmpStart = $MarginX + ($imgWidth-2*$MarginX)*(6000-$rulerStart)/$rulerLength;
    $tmpEnd   = $MarginX + ($imgWidth-2*$MarginX)*(6100-$rulerStart)/$rulerLength;
    &drawArrow($tmpStart, $tmpEnd, $chrInitY, $chrHeight, $hotpink);
    $tmpStart = $MarginX + ($imgWidth-2*$MarginX)*(6350-$rulerStart)/$rulerLength;
    $tmpEnd   = $MarginX + ($imgWidth-2*$MarginX)*(6550-$rulerStart)/$rulerLength;
    &drawArrow($tmpStart, $tmpEnd, $chrInitY, $chrHeight, $hotpink);
  }
  elsif ($highlight eq "entireTranslated") {
    my ($tmpStart, $tmpEnd);
    $tmpStart = $MarginX + ($imgWidth-2*$MarginX)*(6020-$rulerStart)/$rulerLength;
    $tmpEnd   = $MarginX + ($imgWidth-2*$MarginX)*(6100-$rulerStart)/$rulerLength;
    &drawArrow($tmpStart, $tmpEnd, $chrInitY, $chrHeight, $hotpink);
    $tmpStart = $MarginX + ($imgWidth-2*$MarginX)*(6350-$rulerStart)/$rulerLength;
    $tmpEnd   = $MarginX + ($imgWidth-2*$MarginX)*(6500-$rulerStart)/$rulerLength;
    &drawArrow($tmpStart, $tmpEnd, $chrInitY, $chrHeight, $hotpink);
  }
  elsif ($highlight eq "flankStart") {
    my ($tmpStart, $tmpEnd);
    $tmpStart = $MarginX + ($imgWidth-2*$MarginX)*(5900-$rulerStart)/$rulerLength;
    $tmpEnd   = $MarginX + ($imgWidth-2*$MarginX)*(6030-$rulerStart)/$rulerLength;
    &drawArrow($tmpStart, $tmpEnd, $chrInitY, $chrHeight, $hotpink);
  }
  elsif ($highlight eq "fullRegion|in") {
    my ($tmpStart, $tmpEnd);
    $tmpStart = $MarginX + ($imgWidth-2*$MarginX)*(5600-$rulerStart)/$rulerLength;
    $tmpEnd   = $MarginX + ($imgWidth-2*$MarginX)*(6900-$rulerStart)/$rulerLength;
    &drawArrow($tmpStart, $tmpEnd, $chrInitY, $chrHeight, $hotpink);
  }
  elsif ($highlight eq "fullRegion|ex") {
    my ($tmpStart, $tmpEnd);
    $tmpStart = $MarginX + ($imgWidth-2*$MarginX)*(5701-$rulerStart)/$rulerLength;
    $tmpEnd   = $MarginX + ($imgWidth-2*$MarginX)*(6799-$rulerStart)/$rulerLength;
    &drawArrow($tmpStart, $tmpEnd, $chrInitY, $chrHeight, $hotpink);
  }
  elsif ($highlight eq "fullQuery") {
    my ($tmpStart, $tmpEnd);
    $tmpStart = $MarginX + ($imgWidth-2*$MarginX)*(6150-$rulerStart)/$rulerLength;
    $tmpEnd   = $MarginX + ($imgWidth-2*$MarginX)*(6450-$rulerStart)/$rulerLength;
    &drawArrow($tmpStart, $tmpEnd, $mergeInitY, $mergeHeight, $hotpink);
  }
  elsif ($highlight eq "allExonsQuery") {
    my ($tmpStart, $tmpEnd);
    $tmpStart = $MarginX + ($imgWidth-2*$MarginX)*(6000-$rulerStart)/$rulerLength;
    $tmpEnd   = $MarginX + ($imgWidth-2*$MarginX)*(6100-$rulerStart)/$rulerLength;
    &drawArrow($tmpStart, $tmpEnd, $ExonInitY, $ExonHeight, $hotpink);
    $tmpStart = $MarginX + ($imgWidth-2*$MarginX)*(6350-$rulerStart)/$rulerLength;
    $tmpEnd   = $MarginX + ($imgWidth-2*$MarginX)*(6550-$rulerStart)/$rulerLength;
    &drawArrow($tmpStart, $tmpEnd, $ExonInitY, $ExonHeight, $hotpink);
  }
  elsif ($highlight eq "transSeqQuery") {
    my ($tmpStart, $tmpEnd);
    $tmpStart = $MarginX + ($imgWidth-2*$MarginX)*(6170-$rulerStart)/$rulerLength;
    $tmpEnd   = $MarginX + ($imgWidth-2*$MarginX)*(6400-$rulerStart)/$rulerLength;
    &drawArrow($tmpStart, $tmpEnd, $mergeInitY, $mergeHeight, $hotpink);
  }
  else {
  }
}
#***********************************************************
sub drawLine {
  my $p1_y  = shift;
  my $p1_x1 = shift;
  my $p2_y  = shift;
  my $p2_x1 = shift;
  my $p1_x2 = $MarginX + ($imgWidth-2*$MarginX)*($p1_x1-$rulerStart)/$rulerLength;
  my $p2_x2 = $MarginX + ($imgWidth-2*$MarginX)*($p2_x1-$rulerStart)/$rulerLength;
  if (int($p1_x2*1000+0.5) eq int($p2_x2*1000+0.5)) {
    $im->line($p1_x2, $p1_y, $p2_x2, $p2_y, $gray);
  }
  else {
    $im->line($p1_x2, $p1_y, $p2_x2, $p2_y, $blue);
  }
}
#***********************************************************
sub drawRuler {
  my $unit;
  if ($rulerLength <1000) {
    $unit = 20;
  } elsif ($rulerLength < 5000) {
    $unit = 100;
  } elsif ($rulerLength < 10000) {
    $unit = 200;
  } else {
    $unit = 1000;
  }

  $im->filledRectangle($MarginX, $RulerInitY, $imgWidth-$MarginX, $RulerInitY+$RulerHeight, $black);
  for (my $i=$rulerStart; $i<=$rulerEnd; $i+=$unit) {
    $scaleX = ($imgWidth-2*$MarginX)*($i-$rulerStart)/$rulerLength;
    if (($i-$rulerStart)%(5*$unit) eq "0") {
      $im->line($MarginX+$scaleX, $RulerInitY+$RulerHeight, $MarginX+$scaleX, $RulerInitY+$RulerHeight+$LongScaleHeight, $black);

      $im->string(gdSmallFont, $MarginX+$scaleX-(gdSmallFont->width)*length($i)/2, $ScaleNumHeight, $i, $black);
    }
    else {
      $im->line($MarginX+$scaleX, $RulerInitY+$RulerHeight, $MarginX+$scaleX, $RulerInitY+$RulerHeight+$ShortScaleHeight, $black);
    }
  }
}
#***********************************************************
sub drawGene {
  my $color      = shift;
  my $align      = shift;
  my $ExonInitY  = shift;
  my $ExonHeight = shift;
  my $CDSstart   = shift;
  my $CDSstop    = shift;
  my @matchTerm  = split(/\|/,$align);
  for (my $i=0; $i<$#matchTerm; $i+=1) {
    $matchTerm[$i]=~s/\D+//g;
    $matchTerm[$i+1]=~s/\D+//g;
    $leftTerm  = $MarginX + ($imgWidth-2*$MarginX)*($matchTerm[$i]-$rulerStart)/$rulerLength;
    $rightTerm = $MarginX + ($imgWidth-2*$MarginX)*($matchTerm[$i+1]-$rulerStart)/$rulerLength;
    if ($i%2 eq "1") {  #intron
      ($leftTerm, $rightTerm) = ($leftTerm<$rightTerm)?($leftTerm, $rightTerm):($rightTerm, $leftTerm);
      $im->line($leftTerm, $IntronHeight, $rightTerm, $IntronHeight, $color);
    }
    else {      # exon;
      if (($i+1) eq $#matchTerm) {  # the last exon
        &drawArrow($leftTerm, $rightTerm, $ExonInitY, $ExonHeight, $color);
      }
      else { 
        ($leftTerm, $rightTerm) = ($leftTerm<$rightTerm)?($leftTerm, $rightTerm):($rightTerm, $leftTerm);
        $im->filledRectangle($leftTerm, $ExonInitY, $rightTerm, $ExonInitY+$ExonHeight-1, $color);
      }
    }
  }
  if ((defined $CDSstart)&&($CDSstart=~/^\d+$/)&&($CDSstart>=$rulerStart)&&($CDSstart<=$rulerEnd)) {
    $X_Term  = $MarginX + ($imgWidth-2*$MarginX)*($CDSstart-$rulerStart)/$rulerLength;
    $poly = new GD::Polygon;
    $poly->addPt($X_Term,   $ExonInitY);
    $poly->addPt($X_Term-4, $ExonInitY-6.9);
    $poly->addPt($X_Term+4, $ExonInitY-6.9);
    $poly->addPt($X_Term,   $ExonInitY);
    $im->filledPolygon($poly,$lime);  
  }
  if ((defined $CDSstop)&&($CDSstop=~/^\d+$/)&&($CDSstop>=$rulerStart)&&($CDSstop<=$rulerEnd)) {
    $X_Term  = $MarginX + ($imgWidth-2*$MarginX)*($CDSstop-$rulerStart)/$rulerLength;
    $poly = new GD::Polygon;
    $poly->addPt($X_Term,   $ExonInitY);
    $poly->addPt($X_Term-4, $ExonInitY-6.9);
    $poly->addPt($X_Term+4, $ExonInitY-6.9);
    $poly->addPt($X_Term,   $ExonInitY);
    $im->filledPolygon($poly,$red);  
  }
}
#***********************************************************
# Locus Input (BLOCK)
# $X_axis; $Y_axis; $color
sub drawCDS {
  my $X_Axis = shift;
  my $Y_Axis = shift;
  my $color  = shift;
  my $poly;
  $poly = new GD::Polygon;
  $poly->addPt($X_Axis,   $Y_Axis);
  $poly->addPt($X_Axis-4, $Y_Axis-6.9);
  $poly->addPt($X_Axis+4, $Y_Axis-6.9);
  $poly->addPt($X_Axis,   $Y_Axis);
  $im->filledPolygon($poly,$color);
}
#***********************************************************
# Locus Input (BLOCK)
# $start; $end; $Y; $heightY; $color;
sub drawArrow {
  my $start = shift; 
  my $end   = shift;
  my $ExonInitY  = shift;
  my $ExonHeight = shift;
  my $color      = shift;
  my $max        = 5;
  $poly = new GD::Polygon;
  if ($start < $end) {  # Positive
    if ($end - $start >= $max) {
      $poly->addPt($start,   $ExonInitY);
      $poly->addPt($end-$max,$ExonInitY);
      $poly->addPt($end-$max,$ExonInitY-2);
      $poly->addPt($end,     $ExonInitY+$ExonHeight/2);
      $poly->addPt($end-$max,$ExonInitY+$ExonHeight+2);
      $poly->addPt($end-$max,$ExonInitY+$ExonHeight);
      $poly->addPt($start,   $ExonInitY+$ExonHeight);
    }
    else {
      $poly->addPt($start,   $ExonInitY-2);
      $poly->addPt($end,     $ExonInitY+$ExonHeight/2);
      $poly->addPt($start,   $ExonInitY+$ExonHeight+2);
    }
  }
  else {    # Negative
    if (abs($end - $start) >= $max) {
      $poly->addPt($start,     $ExonInitY);
      $poly->addPt($end+$max,  $ExonInitY);
      $poly->addPt($end+$max,  $ExonInitY-2);
      $poly->addPt($end,       $ExonInitY+$ExonHeight/2);
      $poly->addPt($end+$max,  $ExonInitY+$ExonHeight+2);
      $poly->addPt($end+$max,  $ExonInitY+$ExonHeight);
      $poly->addPt($start,     $ExonInitY+$ExonHeight);
    }
    else {
      $poly->addPt($start,   $ExonInitY-2);
      $poly->addPt($end,     $ExonInitY+$ExonHeight/2);
      $poly->addPt($start,   $ExonInitY+$ExonHeight+2);
    }
  }
  $im->filledPolygon($poly,$color);  
}

