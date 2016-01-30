#!/usr/bin/perl -w

package PLGDB;

do 'SITEDEF.pl';

#use strict;
use TRACK;
use DBI;
use Switch;

#===========================================================
#  Input: $BatchText;
# Output: $textStr; $giStr; $gi_num
sub InputAnalysis {
  my $BatchText = shift;
     $BatchText =~s/\|{3,}/\n/;
  my @TextLine  = split(/\n/,$BatchText);
  my (@quota, @tmp);
  my ($textStr, $giStr, $qryText);
  for (my $i=0; $i<=$#TextLine; $i++) {
    @quota = ();
    while ($TextLine[$i]=~/\"/g) {
      push(@quota, length($`));
    }
    my $start = ($#quota%2 eq "1")?($#quota-1):($#quota-2);
    @tmp = ();
    for (my $j=$start; $j>=0; $j-=2) {
      $qryText = substr($TextLine[$i],$quota[$j],$quota[$j+1]-$quota[$j]+1, "");
      if ($qryText=~/\w/) {
        push(@tmp, $qryText);
      }
    }
    $textStr .= join(" ",reverse(@tmp))."\n";
    $giStr   .= $TextLine[$i]."\n";
  }
  
  $textStr=~s/^\s+//g;
  $textStr=~s/\s+$//g;
  $giStr =~s/^[\s\,\;]+//g;
  $giStr =~s/[\s\,\;]+$//g;
  my @tmpBLK = split(/[\s\,\;]+/, $giStr);
  my $gi_num = $#tmpBLK + 1;
  return($textStr,$giStr, $gi_num);
}
#===========================================================
# QUERY SECTION
#===========================================================
# Input:  track; $qryText; $searchMethod[Overlap or NOT]
# Output: HTML track;  lostAndFound
sub qryDBbyText {
  # TMP
#  $DB_HOST = "sunx4600uno.gdcb.iastate.edu";
  # CONSTANT VARIABLE
  my $TEXT_MAX_OUTPUT = 100; # In case of searching "the" OR "EST"
  # Input
  my $tmpTrack     = shift;
  my $BatchText    = shift;
  my $searchMethod = shift;
  # Output
  my $optTBContent  = TRACK::htmlTbElement();
  my $optTmpContent = "";
  my ($optTBEach, $optTmpEach);
  # Found OR Lost
  my @lostAndFound = ();
  my %TEXT_FOUND   = ();
  # MySQL
  my ($sth, $is_lost);
  my @track = split(/\|/,$tmpTrack);
  my $dbh   = DBI->connect("DBI:mysql:$DBver[$#DBver]->{DB}:$DB_HOST", $DB_USER, $DB_PASSWORD);
  # Highlight
  my @tmp_highlight = queryLineElements($BatchText);
  my $highlight     = join("|", @tmp_highlight);

  # Defined for coord search
  # Chr|+/-|start|end -> @ary (Track)?
  my %hash_GROUP = ();

  # Basic Search by Text
  my @qryLine = split(/\n+/,$BatchText);
  for (my $j=0; $j<=$#qryLine; $j++) {
    my @qWords = queryLineElements($qryLine[$j]);
    my $count_OUTPUT = 0;
    $is_lost = 1;
    for (my $i=0; $i<=$#track; $i++) {
      $mysql_qry = TRACK::QRY_MySQL("TEXT", $track[$i], @qWords); # Fill Parameters 
      # yrGate: Change DB & Table
      if ((defined ${$DBver[$#DBver]->{tracks}}[$track[$i]]->{DB})||(defined ${$DBver[$#DBver]->{tracks}}[$track[$i]]->{DBhost})||(defined ${$DBver[$#DBver]->{tracks}}[$track[$i]]->{DBuser})||(defined ${$DBver[$#DBver]->{tracks}}[$track[$i]]->{DBpass})) {
        $dbh->disconnect();
        my ($tmp_db, $DBhost, $DBuser, $DBpass);
        $tmp_db = ${$DBver[$#DBver]->{tracks}}[$track[$i]]->{DB};
        $DBhost  = (defined ${$DBver[$#DBver]->{tracks}}[$track[$i]]->{DBhost})?(${$DBver[$#DBver]->{tracks}}[$track[$i]]->{DBhost}):$DB_HOST;
        $DBuser  = (defined ${$DBver[$#DBver]->{tracks}}[$track[$i]]->{DBuser})?(${$DBver[$#DBver]->{tracks}}[$track[$i]]->{DBuser}):$DB_USER;
        $DBpass  = (defined ${$DBver[$#DBver]->{tracks}}[$track[$i]]->{DBpass})?(${$DBver[$#DBver]->{tracks}}[$track[$i]]->{DBpass}):$DB_PASSWORD;
        $dbh   = DBI->connect("DBI:mysql:$tmp_db:$DBhost", $DBuser, $DBpass);
      }

      $sth = $dbh->prepare($mysql_qry);
      $sth->execute();
      
      while (@tmpARY = $sth->fetchrow_array()) {
        # Check the problem, we want "P2 gene", but get "NTP2 gene";
        my $checkString = TRACK::getMySQLString($track[$i], @tmpARY);
        if (checkMySQLString($checkString, @qWords) eq "0") {
          next;
        }
        # Check the problem, BAC was replaced (By MySQL select sentence)
        $is_lost = 0;
        # Check duplicate results
        (defined $TEXT_FOUND{$tmpARY[0]})?(next):($TEXT_FOUND{$tmpARY[0]}=1);
        $count_OUTPUT++;
        if ($count_OUTPUT eq $TEXT_MAX_OUTPUT) {
          last;
        }

        if ($searchMethod eq "1") {    # Search Desc Directly
          ($optTBEach, $optTmpEach) = TRACK::htmlTbElement($track[$i],"TEXT",$highlight,@tmpARY);
          $optTBContent  .= $optTBEach;
          $optTmpContent .= $optTmpEach;
        }
        elsif ($searchMethod eq "0") { # Search Coord
          my ($grpKey, $locusStart, $locusEnd) = TRACK::locusKeyAndValue($track[$i], @tmpARY);
          $hash_GROUP{$grpKey} = (defined $hash_GROUP{$grpKey})?sortPOS($hash_GROUP{$grpKey}, $locusStart, $locusEnd):"$locusStart $locusEnd";
        }
      }
      $sth->finish();
      # yrGate: DB return to default
      if ((defined ${$DBver[$#DBver]->{tracks}}[$track[$i]]->{DB})||(defined ${$DBver[$#DBver]->{tracks}}[$track[$i]]->{DBhost})||(defined ${$DBver[$#DBver]->{tracks}}[$track[$i]]->{DBuser})||(defined ${$DBver[$#DBver]->{tracks}}[$track[$i]]->{DBpass})) {
        $dbh->disconnect();
        $dbh = DBI->connect("DBI:mysql:$DBver[$#DBver]->{DB}:$DB_HOST", $DB_USER, $DB_PASSWORD);
      }
    }
    if ($is_lost eq "1") { push(@lostAndFound, $qryLine[$j]); }
    if ($count_OUTPUT >= $TEXT_MAX_OUTPUT) { push(@lostAndFound, $qryLine[$j]." (Maximal TEXT_OUTPUT:$TEXT_MAX_OUTPUT)"); }
  }
  $dbh->disconnect();

  # Extended Search by Text 
  if ($searchMethod eq "0") {
    ($optTBEach, $optTmpEach) = qryDBbyLocus($tmpTrack, "TEXT", $highlight, %hash_GROUP);
    $optTBContent  .= $optTBEach;
    $optTmpContent .= $optTmpEach;
  }

  my $optLostContent .= lostList(@lostAndFound);
  return($optTBContent,$optLostContent, $optTmpContent);
}
#===========================================================
sub qryDBbyGI {
  # TMP
#  $DB_HOST = "sunx4600uno.gdcb.iastate.edu";
  # Input
  my $tmpTrack     = shift;
  my $BatchGI      = shift;
  my $searchMethod = shift;
  # Output
  my $optTBContent  = TRACK::htmlTbElement();
  my $optTmpContent = "";
  my ($optTBEach, $optTmpEach);
  # Found OR Lost
  my @lostAndFound = ();
  my %GI_FOUND = ();
  # MySQL
  my ($sth, $is_lost, @tmpARY);
  my @track    = split(/\|/,$tmpTrack);
  my $dbh = DBI->connect("DBI:mysql:$DBver[$#DBver]->{DB}:$DB_HOST", $DB_USER, $DB_PASSWORD);
  # Highlight
  # Basic Search by GI
  my @qWords    = split(/[\s\,\;]+/, $BatchGI);
  my $highlight = join("|", @qWords); 
  # Defined for coord search
  my %hash_GROUP = ();

  for (my $i=0; $i<=$#track; $i++) {
    # yrGate: Change DB & Table
    if ((defined ${$DBver[$#DBver]->{tracks}}[$track[$i]]->{DB})||(defined ${$DBver[$#DBver]->{tracks}}[$track[$i]]->{DBhost})||(defined ${$DBver[$#DBver]->{tracks}}[$track[$i]]->{DBuser})||(defined ${$DBver[$#DBver]->{tracks}}[$track[$i]]->{DBpass})) {
      $dbh->disconnect();
      my ($tmp_db, $DBhost, $DBuser, $DBpass);
      $tmp_db = ${$DBver[$#DBver]->{tracks}}[$track[$i]]->{DB};
      $DBhost  = (defined ${$DBver[$#DBver]->{tracks}}[$track[$i]]->{DBhost})?(${$DBver[$#DBver]->{tracks}}[$track[$i]]->{DBhost}):$DB_HOST;
      $DBuser  = (defined ${$DBver[$#DBver]->{tracks}}[$track[$i]]->{DBuser})?(${$DBver[$#DBver]->{tracks}}[$track[$i]]->{DBuser}):$DB_USER;
      $DBpass  = (defined ${$DBver[$#DBver]->{tracks}}[$track[$i]]->{DBpass})?(${$DBver[$#DBver]->{tracks}}[$track[$i]]->{DBpass}):$DB_PASSWORD;
      $dbh   = DBI->connect("DBI:mysql:$tmp_db:$DBhost", $DBuser, $DBpass);
    }

    my $DSOname = ${$DBver[$#DBver]->{tracks}}[$track[$i]]->{DSOname};
    if ($#qWords >= 0) {
      $mysql_qry = TRACK::QRY_MySQL("GI|GI", $track[$i], @qWords);
      $sth = $dbh->prepare(qq{$mysql_qry});
      $sth->execute();
      while (@tmpARY = $sth->fetchrow_array()) {
        if ($searchMethod eq "1") {  # Search Desc Directly
          ($optTBEach, $optTmpEach) = TRACK::htmlTbElement($track[$i],"GI",$highlight,@tmpARY);
          $optTBContent  .= $optTBEach;
          $optTmpContent .= $optTmpEach;
        }
        else {                       # Search Coord
          my ($grpKey, $locusStart, $locusEnd) = TRACK::locusKeyAndValue($track[$i], @tmpARY);
          $hash_GROUP{$grpKey} = (defined $hash_GROUP{$grpKey})?sortPOS($hash_GROUP{$grpKey}, $locusStart, $locusEnd):"$locusStart $locusEnd";
        }
        # Record ID found
        foreach my $foundID (TRACK::recordID($track[$i],@tmpARY)) {
          $GI_FOUND{$foundID} = $track[$i];
          if ($foundID=~/(\S+)\.\d+$/) {
            $GI_FOUND{$1} = $track[$i];
          }
        }
      }
      $sth->finish();
      # Clean ID found in EST/cDNA
      my @qWordsLeft = ();
      for (my $j=0; $j<=$#qWords; $j++) {
        if ((defined $GI_FOUND{$qWords[$j]})&&(($DSOname eq "CDNApgs")||($DSOname eq "ESTpgs")||($DSOname eq "GSEG"))) {
        } else {
          push(@qWordsLeft, $qWords[$j]);
        }
      }
      @qWords = @qWordsLeft;
    }
    # In case of searching for accession #
    if (($#qWords >= 0)&&(($DSOname eq "CDNApgs")||($DSOname eq "ESTpgs")||($DSOname eq "GSEG"))) {
      $mysql_qry = TRACK::QRY_MySQL("GI|ACC", $track[$i], @qWords);
      $sth = $dbh->prepare($mysql_qry);
      $sth->execute();
      while (@tmpARY = $sth->fetchrow_array()) {
        if ($searchMethod eq "1") {  # Search Desc Directly
          ($optTBEach, $optTmpEach) = TRACK::htmlTbElement($track[$i],"GI",$highlight,@tmpARY);
          $optTBContent  .= $optTBEach;
          $optTmpContent .= $optTmpEach;
        }
        else {                       # Search Coord
          my ($grpKey, $locusStart, $locusEnd) = TRACK::locusKeyAndValue($track[$i], @tmpARY);
          $hash_GROUP{$grpKey} = (defined $hash_GROUP{$grpKey})?sortPOS($hash_GROUP{$grpKey}, $locusStart, $locusEnd):"$locusStart $locusEnd";
        }
        # Record ID found
        foreach my $foundID (TRACK::recordID($track[$i],@tmpARY)) {
          $GI_FOUND{$foundID} = $track[$i];
        }
      }
      $sth->finish();
      # Clean ID found in EST/cDNA
      my @qWordsLeft = ();
      for (my $j=0; $j<=$#qWords; $j++) {
        unless((defined $GI_FOUND{$qWords[$j]})&&(($DSOname eq "CDNApgs")||($DSOname eq "ESTpgs")||($DSOname eq "GSEG"))) {
          push(@qWordsLeft, $qWords[$j]);
        }
      }
      @qWords = @qWordsLeft;
    }

    # yrGate: change back to Default
    if ((defined ${$DBver[$#DBver]->{tracks}}[$track[$i]]->{DB})||(defined ${$DBver[$#DBver]->{tracks}}[$track[$i]]->{DBhost})||(defined ${$DBver[$#DBver]->{tracks}}[$track[$i]]->{DBuser})||(defined ${$DBver[$#DBver]->{tracks}}[$track[$i]]->{DBpass})) {
      $dbh->disconnect();
      $dbh = DBI->connect("DBI:mysql:$DBver[$#DBver]->{DB}:$DB_HOST", $DB_USER, $DB_PASSWORD);
    }
  }
  @lostAndFound = ();

  my $wildcard_match = join(";;;", keys(%GI_FOUND));
  my $wildcard_qry;
  for (my $j=0; $j<=$#qWords; $j++) {
    unless(defined $GI_FOUND{$qWords[$j]}) {
      if (($qWords[$j]=~/\%/)||($qWords[$j]=~/\*/)||($qWords[$j]=~/\(\_\)/)||($qWords[$j]=~/\(\.\)/)) {  # Wildcard string
        $wildcard_qry = $qWords[$j];
        $wildcard_qry =~s/[\%\*]/.*/g;
        $wildcard_qry =~s/\(\_\)/./g;
        $wildcard_qry =~s/\(\.\)/./g;
        unless ($wildcard_match=~/$wildcard_qry/) {
          push(@lostAndFound, $qWords[$j]);
        }
      } else {                # Simple string
        push(@lostAndFound, $qWords[$j]);
      }
    }
  }
  $dbh->disconnect();

  # Extended search (Coord)
  if ($searchMethod eq "0") {
    ($optTBEach, $optTmpEach) = qryDBbyLocus($tmpTrack, "GI", $highlight, %hash_GROUP);
    $optTBContent  .= $optTBEach;
    $optTmpContent .= $optTmpEach;
  }
  my $optLostContent .= lostList(@lostAndFound);
  return($optTBContent, $optLostContent, $optTmpContent);
}
#===========================================================
# Input: track, GI/TEXT, $hightlight, %hash
# How to highlight
# chr|+/-|start|end -> resource(track, geneid, start, end)
sub qryDBbyLocus {
  # TMP
#  $DB_HOST = "sunx4600uno.gdcb.iastate.edu";
  my $tmpTrack   = shift;
  my $searchType = shift;
  my $highlight  = shift;
  my %hash_GROUP = @_;

  my $optTBContent  = "";
  my $optTmpContent = "";
  my ($optTBEach, $optTmpEach);

  my @track = split(/\|/,$tmpTrack);
  my $dbh   = DBI->connect("DBI:mysql:$DBver[$#DBver]->{DB}:$DB_HOST", $DB_USER, $DB_PASSWORD);
  # Search extend to other seq type;
  foreach $grpKey (sort keys(%hash_GROUP)) {
    my @grpFrag = split(/\s+/,$hash_GROUP{$grpKey});
    for (my $j=0; $j<=$#grpFrag; $j+=2) {
      for ($i=0; $i<=$#track; $i++) {
        # yrGate: Change DB & Table
        if ((defined ${$DBver[$#DBver]->{tracks}}[$track[$i]]->{DB})||(defined ${$DBver[$#DBver]->{tracks}}[$track[$i]]->{DBhost})||(defined ${$DBver[$#DBver]->{tracks}}[$track[$i]]->{DBuser})||(defined ${$DBver[$#DBver]->{tracks}}[$track[$i]]->{DBpass})) {
          $dbh->disconnect();
          my ($tmp_db, $DBhost, $DBuser, $DBpass);
          $tmp_db = ${$DBver[$#DBver]->{tracks}}[$track[$i]]->{DB};
          $DBhost  = (defined ${$DBver[$#DBver]->{tracks}}[$track[$i]]->{DBhost})?(${$DBver[$#DBver]->{tracks}}[$track[$i]]->{DBhost}):$DB_HOST;
          $DBuser  = (defined ${$DBver[$#DBver]->{tracks}}[$track[$i]]->{DBuser})?(${$DBver[$#DBver]->{tracks}}[$track[$i]]->{DBuser}):$DB_USER;
          $DBpass  = (defined ${$DBver[$#DBver]->{tracks}}[$track[$i]]->{DBpass})?(${$DBver[$#DBver]->{tracks}}[$track[$i]]->{DBpass}):$DB_PASSWORD;
          $dbh   = DBI->connect("DBI:mysql:$tmp_db:$DBhost", $DBuser, $DBpass);
        }

        $mysql_qry = TRACK::QRY_MySQL("LOCUS",$track[$i],$grpKey, $grpFrag[$j], $grpFrag[$j+1]);  # Fill Parameters 
        $sth = $dbh->prepare($mysql_qry);
        $sth->execute();
        while (@tmpARY = $sth->fetchrow_array()) {
          ($optTBEach, $optTmpEach) = TRACK::htmlTbElement($track[$i],$searchType,$highlight,@tmpARY);
          $optTBContent  .= $optTBEach;
          $optTmpContent .= $optTmpEach;
        }
        $sth->finish();
        # yrGate: Change to Default
        if ((defined ${$DBver[$#DBver]->{tracks}}[$track[$i]]->{DB})||(defined ${$DBver[$#DBver]->{tracks}}[$track[$i]]->{DBhost})||(defined ${$DBver[$#DBver]->{tracks}}[$track[$i]]->{DBuser})||(defined ${$DBver[$#DBver]->{tracks}}[$track[$i]]->{DBpass})) {
          $dbh->disconnect();
          $dbh = DBI->connect("DBI:mysql:$DBver[$#DBver]->{DB}:$DB_HOST", $DB_USER, $DB_PASSWORD);
        }
      }
    }
  }
  $dbh->disconnect();
  return ($optTBContent, $optTmpContent);
}
#===========================================================
# Filter gseq_type (type == Replaced)
sub checkMySQLString {
  my $checkString = shift;
  my @qryWords    = @_;
  for (my $i=0; $i<=$#qryWords; $i++) {
    unless (($checkString=~/^$qryWords[$i]/i)||($checkString=~/[\s+\,\.\:\;\"\'\{\(]$qryWords[$i]/i)) { return 0; }
  }
  return 1;
}
#===========================================================
sub sortPOS {
  my $grpPOS = shift;
  my $l_pos  = shift;
  my $r_pos  = shift;
  my @ptPOS  = split(/\s+/,$grpPOS);
  my $l_point; my $r_point;
  for (my $i=0; $i<=$#ptPOS; $i+=1) {
    if ($l_pos < $ptPOS[$i]) { $l_point = $i; }
    if ($r_pos < $ptPOS[$i]) { $r_point = $i; }
  }
  if ($l_pos >= $ptPOS[$#ptPOS]) { $l_point = $#ptPOS+1; }
  if ($r_pos >= $ptPOS[$#ptPOS]) { $r_point = $#ptPOS+1; }

  # In gap region
  if (($l_point eq $r_point)&($l_point%2 eq "0")) {
    my $tmp;
    if ($l_point eq "0") { 
      $tmp = $l_pos." ".$r_pos." ".$grpPOS;
    }
    elsif ($l_point eq ($#ptPOS+1)) {
      $tmp = $grpPOS." ".$l_pos." ".$r_pos;
    }
    else {
      $tmp = join(" ",@ptPOS[0..($l_point-1)])." ".$l_pos." ".$r_pos." ".join(" ",@ptPOS[$l_point..$#ptPOS]);
    }
    return($tmp);
  }
  # Inside
  elsif (($l_point eq $r_point)&($l_point%2 eq "1")) {
    return($grpPOS);
  }
  else {
    if (($l_point%2 eq "0")&&($r_point%2 eq "0")) {
      $grpPOS = join(" ",@ptPOS[0..($l_point-1)])." $l_pos $r_pos ".join(" ",@ptPOS[($r_point)..$#ptPOS]);
      $grpPOS =~s/^\s+//g;
      $grpPOS =~s/\s+$//g;
      return($grpPOS);
    }
    elsif (($l_point%2 eq "0")&&($r_point%2 eq "1")) {
      $grpPOS = join(" ",@ptPOS[0..($l_point-1)])." $l_pos $ptPOS[$r_point] ".join(" ",@ptPOS[($r_point+1)..$#ptPOS]);
      $grpPOS =~s/^\s+//g;
      $grpPOS =~s/\s+$//g;
      return($grpPOS);
    }
    elsif (($l_point%2 eq "1")&&($r_point%2 eq "0")) {
      $grpPOS = join(" ",@ptPOS[0..($l_point-2)])." $ptPOS[$l_point-1] $r_pos ".join(" ",@ptPOS[($r_point)..$#ptPOS]);
      $grpPOS =~s/^\s+//g;
      $grpPOS =~s/\s+$//g;
      return($grpPOS);
    }
    else {
      $grpPOS = join(" ",@ptPOS[0..($l_point-2)])." $ptPOS[$l_point-1] $ptPOS[$r_point] ".join(" ",@ptPOS[($r_point+1)..$#ptPOS]);
      $grpPOS =~s/^\s+//g;
      $grpPOS =~s/\s+$//g;
      return($grpPOS);
    }
  }
}
#===========================================================
sub lostList {
  my @ary = @_;
  if ($#ary < 0) {
    return("");
  } 
  else {
    my $lostHtml = join("<br>", @ary)."<br>";
    return($lostHtml);
  }
}
#===========================================================
sub queryLineElements {
  my $qryLine = shift;
     $qryLine =~s/^\s*\"//;
     $qryLine =~s/\"\s*$//;
  my @eachString = split(/\"[\s\,]+\"/,$qryLine);
  return(@eachString);
}
#===========================================================
1;

