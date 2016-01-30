#!/usr/bin/perl
package GenomeData;

use strict; 
use FileHandle;

use SeqUtils;


# Constants & Variables
my $DEBUG=0;


############################## Constructor ################################

# Assume that the genome have been processed as pure sequence data, such as:
# at1, at2, ..., at5

# Constructor: $orgm,$chrNum,$dir
sub new {

    my ($class,@param) = @_;
    my $self = {};
    bless $self, ref($class) || $class;
    
    $self->_initialize(@param);
    return $self;
}



sub _initialize{
    my $self = shift;
    my ($orgm,$chrNum,$dir)=@_;
    my ($i,$fh);
    
    $self->{'organism'}= $orgm;
    $self->{'chr num'}=$chrNum;
    $self->{'directory'}=$dir;
    
    my @fhList=();
    my @chrLen=();
    
    for($i=0;$i<$chrNum;$i++){
        $fh=new FileHandle($dir.$orgm.($i+1)) or 
            die "Cannot open file ".$dir.$orgm.($i+1);
        $chrLen[$i]=(stat($fh))[7];
        push @fhList,$fh;
    }
    
    $self->{'file handle'}=\@fhList;
    $self->{'chr length'}=\@chrLen;
}      



sub retSeq{
    my $self= shift;
    my ($chrNum,@regList)=@_;
    my $exon;
    my $strand=($regList[0]>$regList[@regList-1])?1:0;
    
    @regList=reverse(@regList) if($strand);
    $regList[0]=&max($regList[0],1);
    $regList[@regList-1]= &min($regList[@regList-1],
        ${$self->{'chr length'}}[$chrNum-1]);
    if($regList[@regList-1]<$regList[0]){
        print "\nWrong region: ($regList[0]  $regList[@regList-1])\n";
        return "" ;
    }
    my($beg,$end,$seq)=(0,0,"");
    while(@regList){
	$beg=shift(@regList);
	$end=shift(@regList);
	#print "$beg\t$end\n";
        if($end < $beg){
            print "\nWrong cds err: ($beg > $end)\n";
            return "";
        }
        $exon="";
        seek(${$self->{'file handle'}}[$chrNum-1],$beg-1,0);
        read(${$self->{'file handle'}}[$chrNum-1],$exon,$end-$beg+1);

	#print "Exon $exonLen: $exon\n";
	#&formatOut(50,$exon);
	$seq=$seq.$exon;
    }
    $seq=&revcmp($seq) if($strand);
    return $seq;
}

sub clean{
    my $self=shift;
    
    my @fhList=@{$self->{'file handle'}};
    my $fh;
    foreach $fh (@fhList){
        close $fh;
    }
}



sub DESTROY{
    #do nothing    
}    

##################### End of Package #########################
1;
