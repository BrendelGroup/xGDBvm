#!/usr/bin/perl
package GenomeView;

use strict;
use FileHandle;         
use GD;

############# Constants #################
my $StartX=20;
my $Margin=10;    
my $BarHeight=6;
my $HalfBarHeight=$BarHeight/2;
my $StartY=50;
my $EndY=-20;
my $RulerHeight=3;
my $IDHeight=15;
my $ImgHeight=600;
my $UNIT='M';
my $ChrColor='darkgreen';

#rect
my $RectW=3;
my $RectH=2;
my $RectSpace=4;
my $HalfRectH=$RectH/2;

#########################################




############################## Constructor ################################

 

sub new {
 
    my ($class,@param) = @_;
    my $self = {};
    bless $self, ref($class) || $class;
 
    $self->_initialize(@param);
    return $self;
}
 
 
 
sub _initialize{
    my $self = shift;
    my ($imgWidth,$imgHeight,$chrPtr,$cenPtr)=@_;
    #my $imgHeight=$ImgHeight;
    
    $self->{'imgWidth'}= $imgWidth;
    $self->{'imgHeight'}=$imgHeight;
    $self->{'chr'}=$chrPtr;
    $self->{'cen'}=$cenPtr;
    
    my $begPos=1;
    my ($endPos, $tmp)=(-1,-1);
    for(my $i=0;$i<@{$self->{'chr'}};$i++){
        $tmp=${$self->{'chr'}}[$i];
        $endPos=&max($tmp,$endPos);
    }
    
    
    # assign some variables for the image;
    $self->{'begPos'}=$begPos;
    $self->{'endPos'}=$endPos;
    $self->{'zeroPos'}=(int($begPos/1000))*1000; 
    $self->{'seqLen'}=$endPos-$begPos+1;
    my $ratio=$self->{'seqLen'}/($self->{'imgWidth'}-$StartX-2*$Margin);
    $self->{'rulerLen'}=$self->{'seqLen'}/$ratio+0.5;
    $self->{'scale'}=$self->{'seqLen'}/$self->{'rulerLen'};
    $self->{'currHeight'}=10;
    $self->{'img'} = new GD::Image($imgWidth,$imgHeight);
    $self->{'chrSpace'}=($imgHeight-$StartY+$EndY)/(@$chrPtr);
    
    $self->{pairH}=[];
    for(my $i=0;$i<@{$self->{'chr'}};$i++){
        $self->{pairH}->[$i]=$StartY+$self->{'chrSpace'}*($i+1)-30;
    }
    
    #print STDERR "Scale=$self->{'scale'}\n";
    
    $self->_defColor($self->{'img'});
    $self->_drawRuler();     
    $self->drawGenome();
}       

sub _clear{
    #do nothing
}

#draw the ruler
sub _drawRuler{
    my $self= shift;
    
    my $nextPower=0.001;
    my $MinDist=100;
    my $ruler;
    my $im=$self->{'img'};
    
    
    # get the resolution of the ruler
    my $minDist=$MinDist*$self->{'scale'};
    while($nextPower<$minDist){
	    $nextPower*=10;
    }
    if($minDist<$nextPower/5.0){
	    $ruler=($nextPower+0.5)/5.0;
    }elsif($minDist<$nextPower/4.0){
	    $ruler=($nextPower+0.5)/4.0;
    }elsif($minDist<$nextPower/2){
	    $ruler=($nextPower+0.5)/2.0;
    }else{
	    $ruler=$nextPower+0.5;
    }
	
    $im->filledRectangle($self->_pos2x($self->{'zeroPos'}),
        $self->{'currHeight'},$self->_pos2x($self->{'endPos'}),
        $self->{'currHeight'}+$RulerHeight,$self->{'black'});
        
    my $label;
    {use integer;
        my($tick_len,$x_pos,$pos,$i);
        $self->{'currHeight'}+=$RulerHeight;
        $ruler=$ruler/10;
        for($pos=$self->{'zeroPos'},$i=0;$pos<=$self->{'endPos'};
            $pos+=$ruler,$i++){
            $tick_len=($i%5==0)?6:3;
            $x_pos=$self->_pos2x($pos);
            if($UNIT eq 'M' && $pos>1000000){
		    no integer;
		    $label=sprintf("%5.2fM",$pos/1000000.0);
	    }elsif($pos>1000){
		    #no integer;
		    $label=sprintf("%4dK",$pos/1000);
	    }else{
		    $label=sprintf("%d",$pos);
	    }
            if($i%5==0){
                $im->string(gdTinyFont,
                    $x_pos-(gdTinyFont->width)*length($label)/2,
                    $self->{'currHeight'}+10,$label,$self->{'black'});
            }
            $im->line($x_pos,$self->{'currHeight'},$x_pos,
                $self->{'currHeight'}+$tick_len,$self->{'black'});
        }
    }
}

sub _pos2x{
    my $self=shift;
    my($pos)=@_;
    return int(( $pos - $self->{'zeroPos'} )/$self->{'scale'}+ 0.5 + $StartX);
}

sub drawGenome{
    my $self=shift;
    my $currHeight=$StartY;
    for(my $i=0;$i<@{$self->{'chr'}};$i++){
        $currHeight+=$self->{'chrSpace'};
	$self->_drawChr($currHeight,$i,$self->{$ChrColor});
	
    }
}

sub _drawChr{
    my $self=shift;
    my ($height,$ith,$color)=@_;
    
    my $length=${$self->{'chr'}}[$ith];
    my $cenPos=${$self->{'cen'}}[$ith];
    
    my $a=$self->_pos2x(1);
    my $b=$self->_pos2x($cenPos)-4;
    _drawArm($self->{'img'},$a,$b,$height,$color);
    $a=$self->_pos2x($cenPos)+4;
    $b=$self->_pos2x($length);
    _drawArm($self->{'img'},$a,$b,$height,$color);
}

sub _drawArm{
    my($im,$a,$b,$h,$color)=@_;
		
    $im->line($a,$h-$HalfBarHeight,$b,$h-$HalfBarHeight,$color);
    $im->line($a,$h+$HalfBarHeight,$b,$h+$HalfBarHeight,$color);
    $im->arc($a,$h,$BarHeight,$BarHeight,90,270,$color);
    $im->arc($b,$h,$BarHeight,$BarHeight,270,90,$color);
    $im->fill($a+1,$h,$color);
}
sub drawJPG{
    my ($self, $outfn) = @_;
    open (IMG,">$outfn") or die "Cannot open file $outfn!";
    binmode IMG;
    print IMG $self->{'img'}->jpeg(80);
    close IMG;  

}

sub drawPNG{
    my ($self, $outfn) = @_;
    open (IMG,">$outfn") or die "Cannot open file $outfn!";
    binmode IMG;
    print IMG $self->{'img'}->png; 
    close IMG; 

}

sub _defColor{
    my $self = shift;
    my ($img) = @_;
    $self->{'white'}=$img->colorAllocate(255, 255, 255);
    $self->{'black'}=$img->colorAllocate(0, 0, 0);
    $self->{'red'}=$img->colorAllocate(255, 0, 0);
    $self->{'blue'}=$img->colorAllocate(0, 0, 255);
    $self->{'lightblue'}=$img->colorAllocate(173, 216, 246);
    $self->{'green'}=$img->colorAllocate(0, 255, 0);
    $self->{'yellow'}=$img->colorAllocate(255, 255, 0);
    $self->{'gold'}=$img->colorAllocate(255, 215, 0);
    $self->{'khaki'}=$img->colorAllocate(240, 230, 140);
    $self->{'springgreen'}=$img->colorAllocate(0, 255,127);
    $self->{'darkgreen'}=$img->colorAllocate(0, 100, 0);
    $self->{'indiared'}=$img->colorAllocate(205, 92, 92);
    $self->{'peru'}=$img->colorAllocate(205, 133, 63);
    $self->{'orange'}=$img->colorAllocate(255, 222, 0);
    $self->{'hotpink'}=$img->colorAllocate(255, 105, 180);
    $self->{'grey'}=$img->colorAllocate(190, 190, 190);
    $self->{'magenta'}=$img->colorAllocate(255, 0, 255);
}  

sub selectChr{
    my $self=shift;
    my ($ith,@type)=@_;
    
    $self->{'selected'}=$ith-1;
    
    my $a=$self->_pos2x(1);
    my $b=$self->_pos2x(${$self->{'chr'}}[$ith-1]);
    my ($i, $j); 
      
    for($i=0;$i<@type;$i++){
        $self->{$type[$i]}=();
        for($j=$a;$j<=$b;$j++){
            ${$self->{$type[$i]}}[$j]=0;
        }
    }
}

sub addPoint{
    my $self=shift;
    my ($type,$pos)=@_;
    
    ${$self->{$type}}[$self->_pos2x($pos)]++; 
}

sub showPoints{
    my $self=shift;
    my ($fold,$typePtr,$colorPtr)=@_;
    
    my @type=@$typePtr;
    my @color=@$colorPtr;
    
    my $a=$self->_pos2x(1);
    my $b=$self->_pos2x(${$self->{'chr'}}[$self->{'selected'}]);
    my $h=$StartY+($self->{'selected'}+1)*$self->{'chrSpace'};
    #print "a=$a, b=$b, h=$h\n";
    my ($currH,$i,$j,$newH);
    for($i=$a;$i<=$b;$i++){
        $currH=$h-7;
        for($j=0;$j<@type;$j++){
            #print "i=$i, j=$j, value=${$self->{$type[$j]}}[$i]\n";
            next if(${$self->{$type[$j]}}[$i]<=0);
            $newH=$currH-${$self->{$type[$j]}}[$i]/$fold;
            $self->{'img'}->line($i,$currH,$i,$newH,$self->{$color[$j]});
            $currH=$newH-1;
        }      
        
    }
} 
sub loadColors{
    my $self = shift;
    my (@set)= @_;
    
    $self->{userColor}=[];
    for(my $i=0;$i<@set;$i++){
        $self->{userColor}->[$i]=$self->{'img'}->colorAllocate(@{$set[$i]});
    }
}

sub getUserColor{
    my $self = shift;
    my ($x)=@_;
    
    return $self->{userColor}->[$x];
}


sub _getHeight{
    
    my $self = shift;
    my($x1,$x2,$height)=@_;
    
    $height-=$RectSpace while(!$self->_isEmpty($x1,$x2,$height));
    return $height;


}

sub _isEmpty{
    my $self = shift;
    my($x1,$x2,$h)=@_;
    my $c;
    my $i;
    
    for($i=$x1-1;$i<=$x2+1;$i+=2){
        $c= $self->{'img'}->getPixel($i,$h);
        return 0 if($c!=$self->{'white'});
    }
    return 1;
}

sub addRect{
    my $self=shift;
    my ($chr,$lpos,$color)=@_;
    
    my $initHeight=$StartY+$self->{'chrSpace'}*$chr-3;
    my $x1=$self->_pos2x($lpos); 
    my $x2=$x1+$RectW;
    my $height=$self->_getHeight($x1,$x2,$initHeight);
    
    $self->{'img'}->filledRectangle($x1,$height-$HalfRectH+1,$x2,
            $height+$HalfRectH,$self->{$color});
    return ($x1,$height-$HalfRectH+1,$x2,$height+$HalfRectH);
    
}

sub addPair{
    my $self=shift;
    my ($chr,$lpos,$color,$chr2,$lpos2,$color2,$cc)=@_;
    
    my @rect=$self->addRect($chr,$lpos,$color);
    my @rect2=$self->addRect($chr2,$lpos2,$color2);
 
    if($chr!=$chr2){
        $self->{'img'}->line(($rect[0]+$rect[2])/2,($rect[1]+$rect[3])/2,
            ($rect2[0]+$rect2[2])/2,($rect2[1]+$rect2[3])/2,$cc);
    }else{
        my $hh=$self->{pairH}->[$chr-1];
        my ($x1,$h1,$x2,$h2)=(($rect[0]+$rect[2])/2,($rect[1]+$rect[3])/2,
            ($rect2[0]+$rect2[2])/2,($rect2[1]+$rect2[3])/2);
        $self->{'img'}->line($x1,$h1,$x1,$hh,$cc);
        $self->{'img'}->line($x1,$hh,$x2,$hh,$cc);
        $self->{'img'}->line($x2,$hh,$x2,$h2,$cc);
        $self->{pairH}->[$chr-1]-=3;
    }
        
    return (@rect,@rect2);   
}
sub swap{
    my($x,$y)=@_;
    if($$x>$$y){
        my $temp=$$x;
        $$x=$$y;
        $$y=$temp;
    }
} 
sub min {
    my ($a,$b) = @_;
    return ($a < $b) ? ($a) : ($b);
}

sub max {
    my ($a,$b) = @_;
     return ($a > $b) ? ($a) : ($b);
}
            
sub DESTROY {
    my $self=shift;
    $self->_clear();
}   
##################### End of Package #########################
1; 
