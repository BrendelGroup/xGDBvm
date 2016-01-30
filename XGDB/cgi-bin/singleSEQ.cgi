#!/usr/bin/perl -w

# VER 1.02
# Updated by Hong Lu @ 2008/06/09
# Description:
#  1. Add some colors
#  2. Add CDSstart & CDSstop

use CGI ":all";
use GD;
use Switch;

my $q = new CGI;
print $q->header( -type => "image/png");

# 700 x 80
############# Defaults #################
$MarginX=30;
#$MarginY=10;
$imgWidth  = 700;
$imgHeight = 52;

$ExonInitY = 40;
$ExonHeight = 5;
$IntronHeight = 42.5;

# Ruler
$RulerInitY  =10;
$RulerHeight =3;
$LongScaleHeight  = 5;
$ShortScaleHeight = 2;
$ScaleNumHeight   = 20;
#########################################

loadParam();

drawFigure();

binmode STDOUT;
print $im->png;
#******************Main Function Finished*******************

#*******************SUB Function Start**********************
sub loadParam {
  $seqColor = param("color");
  $align    = param("align");
  $CDSstart = param("CDSstart");
  $CDSstop  = param("CDSstop");
#  $seqColor = "lightBlue";
#  $align    = "7239|7157|6369|6290";

  @matchTerm = split(/\|/, $align);
  $matchTerm[0]           =~s/\D+//g;
  $matchTerm[$#matchTerm] =~s/\D+//g;
  ($rulerStart, $rulerEnd) = ($matchTerm[0]>$matchTerm[$#matchTerm])?($matchTerm[$#matchTerm], $matchTerm[0]):($matchTerm[0], $matchTerm[$#matchTerm]);
  $rulerStart  = 10*(int($rulerStart/10));
  $rulerEnd    = 10*(int($rulerEnd/10)+1);
  $rulerLength = $rulerEnd - $rulerStart;
}

#***********************************************************
# http://www.twydiink.com/colortest.htm
sub drawFigure {
  $im = new GD::Image($imgWidth, $imgHeight);
  # allocate some colors
  $white     = $im->colorAllocate(255,255,255);
  $black     = $im->colorAllocate(0,0,0);      
  $blue      = $im->colorAllocate(0,0,255),    # chromosome
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
  drawGene();
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
        &drawArrow($leftTerm, $rightTerm);
      }
      else { 
        ($leftTerm, $rightTerm) = ($leftTerm<$rightTerm)?($leftTerm, $rightTerm):($rightTerm, $leftTerm);
        $im->filledRectangle($leftTerm, $ExonInitY, $rightTerm, $ExonInitY+$ExonHeight, $color);
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

sub drawArrow {
  my $start = shift; 
  my $end   = shift;
  my $max   = 5;
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

