#!/usr/bin/perl
use Time::Local;
use POSIX qw(strftime);

use vars qw($CGI_PATH $TMP_PATH $BLASTBIN_PATH $CAP3_BIN $FULL_URL $SENDMAIL_BIN $web $roundLimit $adminEmail $roundEvalue $localDB $initEvalue $maxRoundEvalue $greatestmaxBlast $maxHits $maxRoundLimit $maxInitEvalue %init_word_size %init_perc_ident %init_filters %recurs_word_size %recurs_perc_ident %recurs_filters $iPERC_IDENT $iWORD_SIZE $iFILTERS $rPERC_IDENT $rWORD_SIZE $rFILTERS $email);

do "tracembler_header.pl";


sub cleanExit{
    my ($error,$cc,$message,$email,$fh,$html) = @_;
    #print STDERR $message;
    if (-W $fh){
	if ($error==1){
	    print $fh "\n\n".("-"x10)."ERROR".("-"x10)."\n\n";
	}else{
	    print $fh "\n\n".("-"x10)."Tracembler Complete".("-"x10)."\n\n";
	}
	print $fh "$message\n";
	print $fh "end time: ";
	print $fh strftime "%a %b %e %H:%M:%S %Y", localtime;
	if ($html==1){
	    print "</pre>";
	}
	close $fh;
    }
    #print STDERR "cleane $error,$cc,$message,$fh,$html\n";
    #print STDERR "$adminEmail,$adminEmail,$adminEmail,$message,$cc\n";
    if ($error==1){
	send_email($adminEmail,$adminEmail,$adminEmail,"Tracembler error",$message,$cc);
    }elsif($error == 0){
	send_email($email,$adminEmail,$adminEmail,"Result of your Tracembler chromosome walk",$message,$cc);
    }
    exit();
}


sub send_email{
my ($to,$from,$cc,$subject,$message,$ccAdmin) = @_;
open(MAIL, "| $SENDMAIL_BIN -t");
print MAIL "To: $to\n";
print MAIL "From: $from\n";
if($ccAdmin==1){print MAIL "Cc: $from\n";}
print MAIL "Subject: $subject\n\n";
print MAIL "Dear $to:\n\n";
print MAIL $message;
print MAIL "\n-- $from .\n";
close(MAIL);
return;
}


sub check_parameters{
  # verify that passed parameters are with limits specified in header.pl
  if (!defined($roundEvalue) || $roundEvalue > $maxRoundEvalue){
	#print STDERR "round evalue $roundEvalue $maxRoundEvalue";
	return 0;
  } 
	
  if ($initEvalue > $maxInitEvalue){
	#print STDERR "init evalue $initEvalue  $maxInitEvalue";
	return 0;
  }

  if ($maxHits > $greatestmaxBlast){
	#print STDERR "maxHits $maxHits > $greatestmaxBlast";
	return 0;
  }

  if ($roundLimit > $maxRoundLimit){
	#print STDERR "roundlimit $roundLimit > $maxRoundLimit\n";
	return 0;
  }

  # check blast parameters
  my $v=0;
  foreach my $k (keys(%init_perc_ident)){
      if ($iPERC_IDENT eq $k){
	  $v=1;
	  last;
      }
  }

  if ($v==0){
	#print STDERR "initial perc ident $iPERC_IDENT not valid\n";
	return 0;
  }

  $v=0;
  foreach my $k (keys(%init_word_size)){
      if ($iWORD_SIZE eq $k){
	  $v=1;
	  last;
      }
  }

#  if ($v==0){
#        print STDERR "inital word size $iWORD_SIZE not valid\n";
#        return 0;
#  }


  my $v=0;
  my @f = split /\,/, $iFILTERS;
  foreach my $f1 (@f){
  foreach my $k (keys(%init_filters)){
      if ($f1 eq $k){
	  $v++;
      }
  }
  }

  if ($v < scalar(@f)){
    #print STDERR "one of filters $iFILTERS not valid\n";
    return 0;
  } 


  my $v=0;
  foreach my $k (keys(%recurs_perc_ident)){
      if ($rPERC_IDENT eq $k){
	  $v=1;
	  last;
      }
  }

  if ($v==0){
	#print STDERR "recurse perc ident $rPERC_IDENT not valid\n";
	return 0;
  }

  $v=0;
  foreach my $k (keys(%recurs_word_size)){
      if ($rWORD_SIZE eq $k){
	  $v=1;
	  last;
      }
  }

  if ($v==0){
        #print STDERR "recurse word size $rWORD_SIZE not valid\n";
        return 0;
  }


  my $v=0;
  my @f = split /\,/, $rFILTERS;
  foreach my $f1 (@f){
  foreach my $k (keys(%recurs_filters)){
      if ($f1 eq $k){
	  $v++;
      }
  }
  }

  if ($v < scalar(@f)){
    #print STDERR "one of filters $rFILTERS not valid\n";
    return 0;
  } 

  #print STDERR "all parameters valid\n";

  return 1;

}

sub min{
  my ($a,$b) = @_;
  if ($a < $b){
    return $a;
  }else{
    return $b;
  }
}

sub max{
  my ($a,$b) = @_;
  if ($a > $b){
    return $a;
  }else{
    return $b;
  }
}

