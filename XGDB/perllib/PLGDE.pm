#!/usr/bin/perl -w
package PLGDE;

do 'SITEDEF.pl';

use DBI;
use Switch;

# Input:  $BatchText;
# Output: $textStr; $giStr;
sub InputAnalysis {
  my $BatchText = shift;
  my @TextLine  = split(/\n/,$BatchText);
  my @quota;
  my $textStr; my $giStr;
  for (my $i=0; $i<=$#TextLine; $i++) {
    @quota = ();
    while ($TextLine[$i]=~/\"/g) {
      push(@quota, length($`));
    }
    my $start = ($#quota%2 eq "1")?($#quota-1):($#quota-2);
    my @tmp="";
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

# Input:  $databases; table; $qryText; $searchMethod[Overlap or NOT]
# Output: HTML table; @lostAndFound

sub qryDBbyText {
  my $database = shift;
  my $tmpTB    = shift;
  my $BatchText    = shift;
  my $searchMethod = shift;
  my @lostAndFound = ();

  my $sth;
  my $optTBContent  = htmlTbElement();
  my $optTmpContent = "";
  my ($optTBEach, $optTmpEach);
  my @table    = split(/\|/,$tmpTB);
#  my $DB_HOST  = "sunx4600uno.gdcb.iastate.edu";
  my $dbh = DBI->connect("DBI:mysql:$database:$DB_HOST", $DB_USER, $DB_PASSWORD);

  my %TEXT_FOUND = ();
  my $MAX_OUTPUT   = 50;

  my @qryLine = split(/\n+/,$BatchText);
  my @tmp_highlight = queryLineElements($BatchText);
  my $highlight = join("|", @tmp_highlight);

  # Basic Search by Text
  for (my $j=0; $j<=$#qryLine; $j++) {
    my @qryWords = queryLineElements($qryLine[$j]);
    my $count_OUTPUT = 0;

    # Defined for coord search
    %hash_GROUP = ();
    my $grpKey;

    for (my $i=0; $i<=$#table; $i++) {
      my ($seqInfo, $hitInfo, $selectedItem) = tbInfo($database, $table[$i]);
      my $qryHandle = "";

      if ($table[$i] eq "6") { # chr_gene_annotation;
        for (my $k=0; $k<=$#qryWords; $k++) {
          $qryHandle .= "(note like \"%$qryWords[$k]%\" or description like \"%$qryWords[$k]%\") and";
        }
        $qryHandle=~s/\s*and$//;
        $sth = $dbh->prepare("select $selectedItem from $seqInfo where ($qryHandle);");
      }
      else {
        $qryHandle = "description like '%".join("%' AND description like '%",@qryWords)."%'";
        $sth = $dbh->prepare("select $selectedItem from $seqInfo s left join $hitInfo p on s.gi=p.gi where ($qryHandle) order by sim DESC, cov DESC;");
      }
      $sth->execute();

      while (@tmpARY = $sth->fetchrow_array()) {
        my $checkString = ($table[$i] eq "6")?($tmpARY[6]." ".$tmpARY[7]):$tmpARY[9];
        if (checkMySQLReturn($checkString, @qryWords) eq "1") {    # For the problem, we want "P2 gene", but get "NTP2 gene";
          $count_OUTPUT++;
          if ($count_OUTPUT eq $MAX_OUTPUT) {
            last;
          }
        }
        else {
          next;
        }    
        
        # To prevent duplicate result.
        (defined $TEXT_FOUND{$tmpARY[0]})?(next):($TEXT_FOUND{$tmpARY[0]} = 1);

        # Search Desc Directly
        if ($searchMethod eq "1") {
          ($optTBEach, $optTmpEach) = htmlTbElement($table[$i],"text",$highlight,@tmpARY);
          $optTBContent  .= $optTBEach;
          $optTmpContent .= $optTmpEach;
        }
        # Search Coord
        elsif ($searchMethod eq "0") {
          # (1-5) s.gi, acc, chr, G_O, sim, cov, l_pos, r_pos, pgs, description
          # (6)   geneId, chr, strand, l_pos, r_pos, gene_structure, description, note
          $grpKey = ($table[$i] eq "6")?(($tmpARY[2] eq "f")?($tmpARY[1]."|+"):($tmpARY[1]."|-")):($tmpARY[2]."|".$tmpARY[3]);
          if (defined $hash_GROUP{$grpKey}) {
            $hash_GROUP{$grpKey} = ($table[$i] eq "6")?sortPOS($hash_GROUP{$grpKey}, $tmpARY[3], $tmpARY[4]):sortPOS($hash_GROUP{$grpKey}, $tmpARY[6], $tmpARY[7]);
          }
          else {
            $hash_GROUP{$grpKey} = ($table[$i] eq "6")?"$tmpARY[3] $tmpARY[4]":"$tmpARY[6] $tmpARY[7]";
          }
        }
      }
      $sth->finish();
    }

    if ($count_OUTPUT eq "0") { push(@lostAndFound, $qryLine[$j]); }

    # Extended Search by Text 
    if ($searchMethod eq "0") {
      # Search extend to other seq type;
      foreach $grpKey (sort keys(%hash_GROUP)) {
        my @grpFrag = split(/\s+/,$hash_GROUP{$grpKey});
        for (my $m=0; $m<=$#grpFrag; $m+=2) {
          for ($i=0; $i<=$#table; $i++) {
            my ($seqInfo, $hitInfo, $selectedItem) = tbInfo($database, $table[$i]);
            my @tmp = split(/\|/,$grpKey);
            my $qryHandle;
            if ($selectedItem=~/gseg\_gi/) {
              $qryHandle =  "gseg_gi=\'$tmp[0]\' and ((l_pos<=$grpFrag[$m] and r_pos>=$grpFrag[$m]) or (l_pos<=$grpFrag[$m+1] and r_pos>=$grpFrag[$m+1]) or (l_pos>=$grpFrag[$m] and r_pos<=$grpFrag[$m+1]))";
            }
            else {
              $qryHandle =  "chr=\'$tmp[0]\' and ((l_pos<=$grpFrag[$m] and r_pos>=$grpFrag[$m]) or (l_pos<=$grpFrag[$m+1] and r_pos>=$grpFrag[$m+1]) or (l_pos>=$grpFrag[$m] and r_pos<=$grpFrag[$m+1]))";
            }

            if ($table[$i] eq "6") {
              $sth = $dbh->prepare("select $selectedItem from $seqInfo where $qryHandle;");
            }
            else {
              $sth = $dbh->prepare("select $selectedItem from $seqInfo s left join $hitInfo p on s.gi=p.gi where $qryHandle order by sim DESC limit 0,20;");
            }
            $sth->execute();
            while (@tmpARY = $sth->fetchrow_array()) {
              ($optTBEach, $optTmpEach) = htmlTbElement($table[$i],"text",$highlight,@tmpARY);
              $optTBContent  .= $optTBEach;
              $optTmpContent .= $optTmpEach;
            }
            $sth->finish();
          }
        }
      }
    }
  }
  $dbh->disconnect();
  my $optLostContent .= lostList(@lostAndFound);
  return($optTBContent,$optLostContent, $optTmpContent);
}

sub checkMySQLReturn {
  my $checkString = shift;
  my @qryWords    = @_;
  for (my $i=0; $i<=$#qryWords; $i++) {
    unless (($checkString=~/^$qryWords[$i]/i)||($checkString=~/[\s+\,\.\:\;\"\'\{\(]$qryWords[$i]/i)) { return 0; }
  }
  return 1;
}

# select s.gi, acc, chr, G_O, sim, cov, l_pos, r_pos, pgs, description from est s left join est_good_pgs p on s.gi=p.gi where s.gi='19868695';
sub qryDBbyGI {
  my $database = shift;
  my $tmpTB    = shift;
  my $giInput  = shift;
  my $searchMethod = shift;
  my @lostAndFound = ();

  my $sth;
  my $optTBContent  = htmlTbElement();
  my $optTmpContent = "";
  my ($optTBEach, $optTmpEach);
  my @table    = split(/\|/,$tmpTB);
#  my $DB_HOST  = "sunx4600uno.gdcb.iastate.edu";
  my $dbh = DBI->connect("DBI:mysql:$database:$DB_HOST", $DB_USER, $DB_PASSWORD);

  my @qWords    = split(/[\s\,\;]+/, $giInput);
  my $highlight = join("|", @qWords); 
  %hash_GROUP   = ();
  my $grpKey;

  %FOUND = ();
  for (my $i=0; $i<=$#table; $i++) {
    my ($seqInfo, $hitInfo, $selectedItem) = tbInfo($database, $table[$i]);
    if ($table[$i] eq "6") {  # GeneBank Search
      if ($#qWords >= 0) {  
        my $qryHandle = "";
        for (my $j=0; $j<=$#qWords; $j++) {
          $qryHandle .= ($qWords[$j]=~/\./)?"geneId=\'$qWords[$j]\' OR ":"geneId=\'$qWords[$j]\' OR geneId like \'$qWords[$j].%\' OR ";
        }
        $qryHandle =~s/OR\s*$//;

        $sth = $dbh->prepare("select $selectedItem from $seqInfo where ($qryHandle);");
        $sth->execute();
        while (@tmpARY = $sth->fetchrow_array()) {
          if ($searchMethod eq "1") {
            ($optTBEach, $optTmpEach) = htmlTbElement($table[$i],"gi",$highlight,@tmpARY);
            $optTBContent  .= $optTBEach;
            $optTmpContent .= $optTmpEach;
          }
          else {
            $grpKey = ($tmpARY[2] eq "f")?($tmpARY[1]."|+"):($tmpARY[1]."|-");
            if (defined $hash_GROUP{$grpKey}) {
              $hash_GROUP{$grpKey} = sortPOS($hash_GROUP{$grpKey}, $tmpARY[3], $tmpARY[4]);
            }
            else {
              $hash_GROUP{$grpKey} = "$tmpARY[3] $tmpARY[4]";
            }
          }
          detectFound($tmpARY[0],@qWords);
        }
        $sth->finish();
        @qWords = CLEANqWords(@qWords);
      }
    }
    else {   # Other Search  [joint table]
      if ($#qWords >= 0) {
        my $qryHandle_1 = "s.gi='".join("' OR s.gi='",@qWords)."'";
        $sth = $dbh->prepare("select $selectedItem from $seqInfo s left join $hitInfo p on s.gi=p.gi where ($qryHandle_1) order by s.gi ASC, sim DESC, cov DESC;");
        $sth->execute();
        while (@tmpARY = $sth->fetchrow_array()) {
          if (($searchMethod eq "1") or ($tmpARY[6] eq "")) {
            ($optTBEach, $optTmpEach) = htmlTbElement($table[$i],"gi",$highlight,@tmpARY);
            $optTBContent  .= $optTBEach;
            $optTmpContent .= $optTmpEach;
          }
          else {
            $grpKey = ($tmpARY[2]."|".$tmpARY[3]);
            if (defined $hash_GROUP{$grpKey}) {
              $hash_GROUP{$grpKey} = sortPOS($hash_GROUP{$grpKey}, $tmpARY[6], $tmpARY[7]);
            }
            else {
              $hash_GROUP{$grpKey} = "$tmpARY[6] $tmpARY[7]";
            }
          }
          if ($table[$i] ne "5") {
            detectFound($tmpARY[0],@qWords);
            detectFound($tmpARY[1],@qWords);
          }
        }
        $sth->finish();
        @qWords = CLEANqWords(@qWords);
      }

      if ($#qWords >= 0) {
        my $qryHandle_2 = "s.acc='".join("' OR s.acc='",@qWords)."'";
        $sth = $dbh->prepare("select $selectedItem from $seqInfo s left join $hitInfo p on s.gi=p.gi where ($qryHandle_2) order by s.gi ASC, sim DESC, cov DESC;");
        $sth->execute();
        while (@tmpARY = $sth->fetchrow_array()) {
          if (($searchMethod eq "1") or ($tmpARY[6] eq "")) {
            ($optTBEach, $optTmpEach) = htmlTbElement($table[$i],"gi",$highlight,@tmpARY);
            $optTBContent  .= $optTBEach;
            $optTmpContent .= $optTmpEach;
          }
          else {
            $grpKey = ($tmpARY[2]."|".$tmpARY[3]);
            if (defined $hash_GROUP{$grpKey}) {
              $hash_GROUP{$grpKey} = sortPOS($hash_GROUP{$grpKey}, $tmpARY[6], $tmpARY[7]);
            }
            else {
              $hash_GROUP{$grpKey} = "$tmpARY[6] $tmpARY[7]";
            }
          }
          if ($table[$i] ne "5") {
            detectFound($tmpARY[0],@qWords);
            detectFound($tmpARY[1],@qWords);
          }
        }
        $sth->finish();
        @qWords = CLEANqWords(@qWords);
      }
    }
  }
  @lostAndFound = @qWords;

  # Extended search (Coord)
  if ($searchMethod eq "0") {
    # Search extend to other seq type;
    foreach $grpKey (sort keys(%hash_GROUP)) {
      my @grpFrag = split(/\s+/,$hash_GROUP{$grpKey});
      for (my $m=0; $m<=$#grpFrag; $m+=2) {
        for ($i=0; $i<=$#table; $i++) {
          my ($seqInfo, $hitInfo, $selectedItem) = tbInfo($database, $table[$i]);
          my @tmp = split(/\|/,$grpKey);
          my $qryHandle;
          if ($selectedItem=~/gseg\_gi/) {
            $qryHandle =  "gseg_gi=\'$tmp[0]\' and ((l_pos<=$grpFrag[$m] and r_pos>=$grpFrag[$m]) or (l_pos<=$grpFrag[$m+1] and r_pos>=$grpFrag[$m+1]) or (l_pos>=$grpFrag[$m] and r_pos<=$grpFrag[$m+1]))";
          }
          else {
            $qryHandle =  "chr=\'$tmp[0]\' and ((l_pos<=$grpFrag[$m] and r_pos>=$grpFrag[$m]) or (l_pos<=$grpFrag[$m+1] and r_pos>=$grpFrag[$m+1]) or (l_pos>=$grpFrag[$m] and r_pos<=$grpFrag[$m+1]))";
          }
          if ($table[$i] eq "6") {
            $sth = $dbh->prepare("select $selectedItem from $seqInfo where $qryHandle;");
          }
          else {
            $sth = $dbh->prepare("select $selectedItem from $seqInfo s left join $hitInfo p on s.gi=p.gi where $qryHandle order by s.gi ASC, sim DESC, cov DESC;");
          }
          $sth->execute();
          while (@tmpARY = $sth->fetchrow_array()) {
            ($optTBEach, $optTmpEach) = htmlTbElement($table[$i],"gi",$highlight,@tmpARY);
            $optTBContent  .= $optTBEach;
            $optTmpContent .= $optTmpEach;
          }
          $sth->finish();
        }
      }
    }
  }

  $dbh->disconnect();
  my $optLostContent .= lostList(@lostAndFound);
  return($optTBContent, $optLostContent, $optTmpContent);
}


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

sub queryLineElements {
  my $qryLine = shift;
     $qryLine =~s/^\s*\"//;
     $qryLine =~s/\"\s*$//;
  my @eachString = split(/\"[\s\,]+\"/,$qryLine);
  return(@eachString);
}


sub tbInfo {
  my $database = shift;
  my $tableNum = shift;
  my $type     = (defined $DBver[$#DBver]->{genomeST})?"0":"1";
  if ($type eq "0") {
    return(tbInfoDetail($database,$tableNum,"chr"));
  }
  elsif ($type eq "1") {
    return(tbInfoDetail($database,$tableNum,"gseg"));
  }
}

sub tbInfoDetail {
  my $database    = shift;
  my $tableNum    = shift;
  my $tbStructure = shift;
  my $selectedItem;
  if ($tbStructure eq "chr") {
    if ($tableNum eq "6") {
      $selectedItem = "geneId, chr, strand, l_pos, r_pos, gene_structure, description, note";
      if (($database=~/ATGDB/)||($database=~/OSGDB/)) {
        return("chr_tigr_tu", "",$selectedItem);
      } 
      else {
        return("chr_gene_annotation", "",$selectedItem);
      }
    }
    $selectedItem = "s.gi, acc, chr, G_O, sim, cov, l_pos, r_pos, pgs, description";
    switch($tableNum) {
      case "1" {return("est",   "est_good_pgs",  $selectedItem);} # est
      case "2" {return("cdna",  "cdna_good_pgs", $selectedItem);} # cdna
      case "3" {return("put",   "put_good_pgs",  $selectedItem);} # put
      case "4" {return("probe", "probe_good_pgs",$selectedItem);} # probe
      case "5" {return("pep",   "pep_good_pgs",  $selectedItem);} # pep
    }
  }
  elsif ($tbStructure eq "gseg") {
    if ($tableNum eq "6") {
      $selectedItem = "geneId, gseg_gi, strand, l_pos, r_pos, gene_structure, description, note";
      return("gseg_gene_annotation", "",$selectedItem);
    }
    $selectedItem = "s.gi, acc, gseg_gi, G_O, sim, cov, l_pos, r_pos, pgs, description";
    switch($tableNum) {
      case "1" {return("est",   "gseg_est_good_pgs",  $selectedItem);} # est
      case "2" {return("cdna",  "gseg_cdna_good_pgs", $selectedItem);} # cdna
      case "3" {return("put",   "gseg_put_good_pgs",  $selectedItem);} # put
      case "4" {return("probe", "gseg_probe_good_pgs",$selectedItem);} # probe
      case "5" {return("pep",   "gseg_pep_good_pgs",  $selectedItem);} # pep
    }
  }
}


sub htmlTbElement {
  my $tableNum = shift;
  if ($tableNum eq "") {   # Table title
    my $title = "
  <tr align=center>
    <th rowspan=2 width=45>Type</th>
    <th rowspan=2 width=20><input type=\"checkbox\" name=\"CheckAll\" onClick=\"checkAll(document.guiFORM.CheckAll)\"></th>
    <th width=85>Gi</th>
    <th width=70>Chr/Gseg</th>
    <th width=50>Sim</th>
    <th width=50>Begin</th>
    <th rowspan=2>Alignment</th>
  </tr>
  <tr align=center>
    <th>Acc</th>
    <th>Ori</th>
    <th>Cov</th>
    <th>End</th>
  </tr>
";
    return($title);
  }

  my $qryType     = shift; # text OR gi
  my $highlight   = shift;
  my @elementInfo = @_;
  my ($inputType, $color);
  switch ($tableNum) {
    case "1" {($inputType, $color) = ("est",   "red");      } # est
    case "2" {($inputType, $color) = ("cdna",  "lightBlue");} # cdna
    case "3" {($inputType, $color) = ("put",   "fireBrick");} # put
    case "4" {($inputType, $color) = ("probe", "purple");   } # probe
    case "5" {($inputType, $color) = ("pep",   "black");    } # pep
    case "6" {($inputType, $color) = ("geneId","blue");     } # geneBank
  }

  my ($note, $desc, $align, $gi);
  my ($checkboxName, $modelCELL, $line_1, $line_2, $line_3);
  if ($tableNum eq "6") {
    $note   = pop(@elementInfo);
    $desc   = pop(@elementInfo);
    my $alignTmp  = pop(@elementInfo);
    my $alignPOS  =($alignTmp=~/complement\((\S*)\)/)?$1:$alignTmp;
       $alignPOS  =($alignPOS=~/join\((\S*)\)/)?$1:$alignPOS;
       $alignPOS  =~s/\&[gl]t\;//g;
       $alignPOS  =~s/[\(\)]//g;
       $alignPOS  =~s/[\>\<]//g;
    my @alignBlk  = split(/[\.\,]+/, $alignPOS);
    $align = ($alignTmp=~/complement/)?(join("|",reverse(@alignBlk))):(join("|",@alignBlk));
    $gi    = $elementInfo[0];
    if ($qryType eq "gi") {
      $elementInfo[0]=~s/^($highlight)(\.\d+)*$/\<FONT style\=\"BACKGROUND-COLOR\: yellow\"\>$1\<\/FONT\>$2/gi;  # gi
    }
    elsif($qryType eq "text") {
      $note=~s/($highlight)/\<FONT style\=\"BACKGROUND-COLOR\: yellow\"\>$1\<\/FONT\>/gi;  # gi
      $desc=~s/($highlight)/\<FONT style\=\"BACKGROUND-COLOR\: yellow\"\>$1\<\/FONT\>/gi;  # acc
    }

    $checkboxName = $gi."|".$elementInfo[1]."|".$elementInfo[3]."|".$elementInfo[4];
    $modelCELL    = "<a href=\"findRegion.pl?id=$gi\" target=\"findRegion:$gi\"><img src=\"singleSEQ.cgi?color=$color&align=$align\"></a>";

    $line_1 = "<td>$elementInfo[1]</td><td></td><td>$elementInfo[3]</td><td rowspan=2>$modelCELL</td>";
    $line_2 = "<td></td><td>$elementInfo[2]</td><td></td><td>$elementInfo[4]</td>";
    $line_3 = "<td colspan=4>$desc</td><td>$note</td>";
  }
  else {
    $desc  = pop(@elementInfo);
    $align = pop(@elementInfo);
    $align =~s/[\,\s]+/\|/g;
    $gi    = $elementInfo[0];
    if ($qryType eq "gi") {
      $elementInfo[0]=~s/^($highlight)(\.\d+)*$/\<FONT style\=\"BACKGROUND-COLOR\: yellow\"\>$1\<\/FONT\>/gi;  # gi
      $elementInfo[1]=~s/^($highlight)(\.\d+)*$/\<FONT style\=\"BACKGROUND-COLOR\: yellow\"\>$1\<\/FONT\>/gi;  # acc
    }
    elsif($qryType eq "text") {
      $desc=~s/($highlight)/\<FONT style\=\"BACKGROUND-COLOR\: yellow\"\>$1\<\/FONT\>/gi;  # gi
    }

    $checkboxName = $gi."|".$elementInfo[2]."|".$elementInfo[6]."|".$elementInfo[7];
    $modelCELL = ($align eq "")?"No alignment to the genome":"<a href=\"findRegion.pl?id=$gi\" target=\"findRegion:gi\"><img src=\"singleSEQ.cgi?color=$color&align=$align\"></a>";

    $line_1 = "<td>$elementInfo[2]</td><td>$elementInfo[4]</td><td>$elementInfo[6]</td><td rowspan=2>$modelCELL</td>";
    $line_2 = "<td>$elementInfo[1]</td><td>$elementInfo[3]</td><td>$elementInfo[5]</td><td>$elementInfo[7]</td>";
    $line_3 = "<td colspan=5>$desc</td>";
  }

  my $recLine = "value=".$checkboxName." align=".$align."\n";
  my $tbLine  = "
  <tr align=\"center\">
    <td rowspan=\"3\">".$inputType."</td>
    <td rowspan=\"3\"><input type=\"checkbox\" value=".$checkboxName." name=\"CheckAll\" /></td>
    <td><a href=\"findRecord.pl?id=".$gi."\" target=\"findRecord:".$gi."\">".$elementInfo[0]."</a></td>
    ".$line_1."
  </tr>
  <tr align=center>
    ".$line_2."
  </tr>
  <tr>
    ".$line_3."
  </tr>
";
  return($tbLine, $recLine);
}

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

sub detectFound {
  my $retroId = shift;
  my @block   = @_;
  for (my $i=0; $i<=$#block; $i++) {
    if (($retroId=~/^$block[$i]$/i)||($retroId=~/^$block[$i]\./i)) {
      $FOUND{$block[$i]} = 1;
    }
  }
}

# Delete @qWords found to speed up search function
# %FOUND [global]
# Input:  @qWords
# Output: @qWords
sub CLEANqWords {
  my @qWords     = @_;
  my @qWordsLeft = ();
  for (my $j=0; $j<=$#qWords; $j++) {
    unless(defined $FOUND{$qWords[$j]}) {
      push(@qWordsLeft, $qWords[$j]);
    }
  }
  return @qWordsLeft;
}

# Input:  Table information; Search Method[Overlap OR Not]
# Output: Button HTML
sub hideButton {
  my $dbTBParam  = shift;
  my $searchType = shift;
  my @tbParam    = split(/\|/,$dbTBParam);
  my $button;
  for (my $i=0; $i<=$#tbParam; $i++) {
    if ($tbParam[$i] eq "1") { $button .= "\n<input type=\"button\" onClick='this.value=setToggleRows(\"alignTable\", \"est\")'    value=\"Hide EST\" />";  }
    if ($tbParam[$i] eq "2") { $button .= "\n<input type=\"button\" onClick='this.value=setToggleRows(\"alignTable\", \"cdna\")'   value=\"Hide cDNA\" />"; }
    if ($tbParam[$i] eq "3") { $button .= "\n<input type=\"button\" onClick='this.value=setToggleRows(\"alignTable\", \"put\")'    value=\"Hide PUT\" />";  }
    if ($tbParam[$i] eq "4") { $button .= "\n<input type=\"button\" onClick='this.value=setToggleRows(\"alignTable\", \"probe\")'  value=\"Hide Probe\" />";}
    if ($tbParam[$i] eq "5") { $button .= "\n<input type=\"button\" onClick='this.value=setToggleRows(\"alignTable\", \"pep\")'    value=\"Hide Protein\" />";  }
    if ($tbParam[$i] eq "6") { $button .= "\n<input type=\"button\" onClick='this.value=setToggleRows(\"alignTable\", \"geneId\")' value=\"Hide Gene_Ann\" />";  }
  }
  $button .= "<br>\n";
  return $button;
}

sub SeqRetrButton {
  my $file     = shift;
  my $database = shift;
  my $option   = "
      <input type=\"hidden\" name=\"file\" value=$file />
      <input type=\"hidden\" name=\"seqId\" value=\"\" />
      <input type=\"hidden\" name=\"database\" value=$database />
      <div align=left>
        <table class=\"PLGDEunknownTable\" align=left>
          <tr>
            <td><input type=\"checkbox\" name=\"5_primer\" /></td>
            <td>5\' region</td>
          </tr>
          <tr>
            <td></td>
            <td>[Retrieve from:-<input type=\"text\" size=\"3\" name=\"5_ReBgn\" value=\"200\" />bp to -<input type=\"text\" size=\"3\" name=\"5_ReEnd\" value=\"1\" />bp]</td>
          </tr>
          <tr>
            <td></td>
            <td>[<input type=\"checkbox\" name=\"5_neighbor\" checked=\"checked\" />Exclude neighboring gene seq.]</td>
          </tr>
          <tr>
            <td><input type=\"checkbox\" name=\"firstExon\" /></td>
            <td>All exons</td>
          </tr>
          <tr>
            <td><input type=\"checkbox\" name=\"firstIntron\" /></td>
            <td>All introns</td>
          </tr>
          <tr>
            <td><input type=\"checkbox\" name=\"entireUnspliced\" /></td>
            <td>Entire transcript region, unspliced (+1 to end)</td>
          </tr>
          <tr>
            <td><input type=\"checkbox\" name=3\"_primer\" /></td>
            <td>3\' region</td>
          </tr>
          <tr>
            <td></td>
            <td>[Retrieve from:end+<input type=\"text\" size=\"3\" name=\"3_ReBgn\" value=\"1\" />bp to end+<input type=\"text\" size=\"3\" name=\"3_ReEnd\" value=\"200\" />bp]</td>
          </tr>
          <tr>
            <td></td>
            <td>[<input type=\"checkbox\" name=\"3_neighbor\" checked=\"checked\" />Exclude neighboring gene seq.]</td>
          </tr>
          <tr>
            <td><input type=\"checkbox\" name=\"fullUnspiced\" /></td>
            <td>Entire region as a single FASTA file (unspliced, including any specified 5' or 3' sequence)</td>
          </tr>
          <tr>
            <td></td>
            <td>[Retrieve from:-<input type=\"text\" size=\"3\" name=\"fullReBgn\" value=\"200\" />bp to end+<input type=\"text\" size=\"3\" name=\"fullReEnd\" value=\"200\" />bp]</td>
          </tr>
          <tr>
            <td></td>
            <td>[<input type=\"checkbox\" name=\"full_neighbor\" checked=\"checked\" />Exclude neighboring gene seq.]</td>
          </tr>
          <tr>
            <td><input type=\"checkbox\" name=\"entireAligned\" /></td>
            <td>Original aligned transcript (+1 to end)</td>
          </tr>
          <tr>
            <td></td>
            <td><input value=\"Retrieve FASTA\" type=\"submit\" onClick=\'multiRev(\"\\seqRetrieval.pl\")\'></td>
          </tr>
        </table>
      </div>
";
  return $option;
}
1;

