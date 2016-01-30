#!/usr/bin/perl

package SeqUtils;

use Exporter;

@ISA=('Exporter');  # Inherit from Exporter
@EXPORT = qw(revcmp fastaOut max min dna2pro);

my %aaCodon=(     "ttt","f","ttc","f","tta","l","ttg","l",
                  "ctt","l","ctc","l","cta","l","ctg","l",
                  "att","i","atc","i","ata","i","atg","m",
                  "gtt","v","gtc","v","gta","v","gtg","v",
                  "tct","s","tcc","s","tca","s","tcg","s",
                  "cct","p","ccc","p","cca","p","ccg","p",
                  "act","t","acc","t","aca","t","acg","t",
                  "gct","a","gcc","a","gca","a","gcg","a",
                  "tat","y","tac","y","taa","*","tag","*",
                  "cat","h","cac","h","caa","q","cag","q",
                  "aat","n","aac","n","aaa","k","aag","k",
                  "gat","d","gac","d","gaa","e","gag","e",
                  "tgt","c","tgc","c","tga","*","tgg","w",
                  "cgt","r","cgc","r","cga","r","cgg","r",
                  "agt","s","agc","s","aga","r","agg","r",
                  "ggt","g","ggc","g","gga","g","ggg","g"
            );



sub revcmp{
    my($seq)=@_;
    $seq=reverse($seq);
    $seq=~ tr/atucg[^atucg]/taagcn/;
    return $seq;
} 

  
sub fastaOut{
    my ($fh,$title,$seq,$width)=@_;
    my $i;
    
    # may need error message
    return if( !defined($fh) || $seq eq "");

    my $seqLen=length($seq);
    
    print $fh ">".$title . "\n";
    for($i=0;$i<$seqLen-$width;$i+=$width){
            print $fh substr($seq,$i,$width)."\n";
    }
    print $fh substr($seq,$i)."\n\n" if($i<$seqLen);
} 

# unfinished 
sub translate{
        
        my($seq,$titile)=@_;
        
        my ($i,$title);
        my ($protein,$codon)=("","");
        
        LOOP: for(my $frame=0;$frame<3;$frame++){
                $protein="";
                #print $seq."\n";
                for($i=0+$frame;$i<length($seq)-2;$i+=3){
                 $codon=substr($seq,$i,3);
                         if($codon =~ /[^atcg]/ ){
                $protein=$protein."x";
                 }else{
                                next LOOP if($aaCodon{$codon} eq '*');
                $protein=$protein.$aaCodon{$codon};
                 }
                }
                print ">$title\n";
                formatOut(60,$protein);
        }
}

sub dna2pro{
        
    my($seq,$frame)=@_;

    my ($i);
    my ($protein,$codon)=("","");
    
    for($i=0+$frame;$i<length($seq)-2;$i+=3){
        $codon=substr($seq,$i,3);
        if($codon =~ /[^atcg]/ ){
            $protein.="x";
        }else{
            $protein.=$aaCodon{$codon};
        }
    }
    return $protein;
    
}


sub max{
    
    my ($a,$b)=@_;
    if($a>$b){
            return $a;
    }else{
            return $b;
    }
}

sub min{
    
    my ($a,$b)=@_;
    if($a<$b){
            return $a;
    }else{
            return $b;
    }
}



1;
