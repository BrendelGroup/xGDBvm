#!/usr/bin/perl

use CGI ":all";
use PLGDB;
use TRACK;

do 'SITEDEF.pl';

print header;
print start_html("Sequence Retrieval Sysem");

$database = $DBver[$#DBver]->{DB};

if ((defined param('file'))&&(defined param('seqId'))) {
  my $file     = param('file');
  my $seqId    = param('seqId');

  # Check parameters
  my $guard_error  = 0;
  my $guard_option = 0;
  if ($seqId eq "") {
    print "<b>Please choose at least one identifier. Thanks.</b><br>";
    $guard_error = 1;
  }
  if (defined param("5_prime")) {
    $guard_option = 1;
  }
  if (defined param("3_prime")) {
    $guard_option = 1;
  }
  if (defined param("allIntrons")) {
    $guard_option = 1;
  }
  if (defined param("allExons")) {
    $guard_option = 1;
  }
  if (defined param("entireUnspliced")) {
    $guard_option = 1;
  }
  if (defined param("entireAligned")) {
    $guard_option = 1;
  }
  if (defined param("entireTranslated")) {
    $guard_option = 1;
  }
  if (defined param("flankStart")) {
    $guard_option = 1;
  }
  if (defined param("fullRegion")) {
    $guard_option = 1;
  }
  if (defined param("fullQuery")) {
    $guard_option = 1;
  }
  if (defined param("allExonsQuery")) {
    $guard_option = 1;
  }
  if (defined param("transSeqQuery")) {
    $guard_option = 1;
  }
  if ($guard_option eq "0") {
    print "<b>Please choose at least one option, such as 5'region or First intron. Thanks.</b><br>\n";
  }
  if (($guard_error eq "1")||($guard_option eq "0")) {
    print end_html();
    exit;
  }

  # Load input
  my %hash    = ();
  my @tmpBLK  = split(/\(A\)/,$seqId);
  my @entryGI = ();
  my ($keyId, $gi, $chr, $ori, $start, $end, $align, $CDSstart, $CDSstop, $trackIndex);
  for (my $i=0; $i<=$#tmpBLK; $i++) {
    $hash{$tmpBLK[$i]}=1;
  }
  open(IN,"$TMPDIR/$file")||die ":$!";
  while (<IN>) {
    chomp;
    if (/value\=(\S+)/) {
      $line  = $_;
      $keyId = $1;
      if (defined $hash{$keyId}) {
        ($gi, $chr, $start, $end) = split(/\|/,$keyId);
        $line =~/align\=(\S*)/;       $align      = $1;
        $line =~/trackIndex\=(\S+)/;  $trackIndex = $1;
        $line =~/CDSstart\=(\S*)/;    $CDSstart   = $1;
        $line =~/CDSstop\=(\S+)/;     $CDSstop    = $1;
        push @entryGI, {keyId=>$keyId, GI=>$gi, START=>$start, END=>$end, CHR=>$chr, align=>$align, trackIndex=>$trackIndex, CDSstart=>$CDSstart, CDSstop=>$CDSstop}; 
      }
    }
  }
  close(IN)||die ":$!";

  # Load chromosome keywords (CHR-Based only)
  if (defined $DBver[$#DBver]->{genomeST}) {  
    $genome_id = $GDB; # Global variable
    $genome_id =~s/GDB$/genome/i;
    my $titles = `grep ">" $BLAST_DB{"$genome_id"}[1]`;
    my @tmpTitleARY = split(/\n/,$titles);
    my $firstname;
    @titleARY = (); # Global array
    for (my $i=0; $i<=$#tmpTitleARY; $i++) {
      if ($tmpTitleARY[$i]=~/^\>(\S+)/) {
        $firstname = $1;
        $firstname =~s/\|/\\\|/g;
        $firstname =~s/\>/\\\>/g;
        $firstname =~s/\;/\\\;/g;
        $firstname =~s/\,/\\\,/g;
        $firstname =~s/\</\\\</g;
        $firstname =~s/\"/\\\"/g;
        $firstname =~s/\(/\\\(/g;
        $firstname =~s/\)/\\\)/g;
        $firstname =~s/\*/\\\*/g;
        $firstname =~s/\%/\\\%/g;
        $firstname =~s/\`/\\\`/g;
        $firstname =~s/\$/\\\$/g;
        $firstname =~s/\#/\\\#/g;
        push(@titleARY,$firstname);
      }
    }
  }

  # Find the right table to exclude neighbor genes
  my %DEFAULT_DSO = TRACK::DEFAULT_DSO_TABLE();
  $exclude_info_table = $DEFAULT_DSO{"GBKgaeval"}; # Global variable
  my @trackORDIdx = split(/\,/, $DBver[$#DBver]->{trackORD});
  for (my $i=0; $i<=$#trackORDIdx; $i++) {
    if (${$DBver[$#DBver]->{tracks}}[$trackORDIdx[$i]]->{DSOname} eq "GBKgaeval") { # Stop
      if (defined ${$DBver[$#DBver]->{tracks}}[$trackORDIdx[$i]]->{db_table}) {
        $exclude_info_table = ${$DBver[$#DBver]->{tracks}}[$trackORDIdx[$i]]->{db_table};
      }
      else {
          $exclude_info_table = $DEFAULT_DSO{"GBKgaeval"};
      }
      last;
    }
    elsif (${$DBver[$#DBver]->{tracks}}[$trackORDIdx[$i]]->{DSOname} eq "GBKann") { # Change at first, and keep searching for "GBKgaeval"
      if (defined ${$DBver[$#DBver]->{tracks}}[$trackORDIdx[$i]]->{db_table}) {
        $exclude_info_table = ${$DBver[$#DBver]->{tracks}}[$trackORDIdx[$i]]->{db_table};
      }
      else {
          $exclude_info_table = $DEFAULT_DSO{"GBKann"};
      }
      next;
    }
  }

  # Retrieve sequences
  $dbh = DBI->connect("DBI:mysql:$database:$DB_HOST", $DB_USER, $DB_PASSWORD);
  if (param("outOrder") eq "opOrder") {
    #(1) 5' sequences from genome
    if ((defined param("5_prime"))&&(param("5_prime") eq "on")) {
      for (my $i=0; $i<=$#entryGI; $i++) {
        fivePrime($entryGI[$i]);
      }
    }
    #(2) 3' sequences from genome
    if ((defined param("3_prime"))&&(param("3_prime") eq "on")) {
      for (my $i=0; $i<=$#entryGI; $i++) {
        threePrime($entryGI[$i]);
      }
    }
    #(3) All Exons from genome
    if ((defined param("allExons"))&&(param("allExons") eq "on")) {
      for (my $i=0; $i<=$#entryGI; $i++) {
        allExons($entryGI[$i]);
      }
    }
    #(4) All Introns from genome
    if ((defined param("allIntrons"))&&(param("allIntrons") eq "on")) {
      for (my $i=0; $i<=$#entryGI; $i++) {
        allIntrons($entryGI[$i]);
      }
    }
    #(5) Entire transcript region, unspliced [exons & introns] (+1 to end)
    if ((defined param("entireUnspliced"))&&(param("entireUnspliced") eq "on")) {
      for (my $i=0; $i<=$#entryGI; $i++) {
        entireUnspliced($entryGI[$i]);
      }
    }
    #(6) Entire transcript region, spliced & aligned [cDNA] (+1 to end)
    if ((defined param("entireAligned"))&&(param("entireAligned") eq "on")) {
      for (my $i=0; $i<=$#entryGI; $i++) {
        entireAligned($entryGI[$i]);
      }
    }
    # Blah
    #(7) Entire translated region, spliced & aligned [Annotated gene only]
    if (defined (param("entireTranslated"))&&(param("entireTranslated") eq "on")) {
      for (my $i=0; $i<=$#entryGI; $i++) {
        entireTranslated($entryGI[$i]);
      }
    }
    # Blah
    #(8) Flank region of translation start site (ATG)
    if (defined (param("flankStart"))&&(param("flankStart") eq "on")) {
      for (my $i=0; $i<=$#entryGI; $i++) {
        flankStart($entryGI[$i]);
      }
    }
    #(9) Entire region as a single FASTA file (unspliced, including any specified 5' or 3' sequence)
    if (defined (param("fullRegion"))&&(param("fullRegion") eq "on")) {
      for (my $i=0; $i<=$#entryGI; $i++) {
        fullUnspiced($entryGI[$i]);
      }
    }
    # From Queries
    #(10) Entire query sequence
    if (defined (param("fullQuery"))&&(param("fullQuery") eq "on")) {
      for (my $i=0; $i<=$#entryGI; $i++) {
        fullQuery($entryGI[$i]);
      }
    }
    #(11) All exons from queries
    if (defined (param("allExonsQuery"))&&(param("allExonsQuery") eq "on")) {
      for (my $i=0; $i<=$#entryGI; $i++) {
        allExonsQuery($entryGI[$i]);
      }
    }
    #(12) Entire translated region [Annotated gene only]
    if (defined (param("transSeqQuery"))&&(param("transSeqQuery") eq "on")) {
      for (my $i=0; $i<=$#entryGI; $i++) {
        transSeqQuery($entryGI[$i]);
      }
    }
  }
  elsif (param("outOrder") eq "giOrder") {
    for (my $i=0; $i<=$#entryGI; $i++) {
      #(1) 5' sequences from genome
      if ((defined param("5_prime"))&&(param("5_prime") eq "on")) {
        fivePrime($entryGI[$i]);
      }
      #(2) 3' sequences from genome
      if ((defined param("3_prime"))&&(param("3_prime") eq "on")) {
        threePrime($entryGI[$i]);
      }
      #(3) All Exons from genome
      if ((defined param("allExons"))&&(param("allExons") eq "on")) {
        allExons($entryGI[$i]);
      }
      #(4) All Introns from genome
      if ((defined param("allIntrons"))&&(param("allIntrons") eq "on")) {
        allIntrons($entryGI[$i]);
      }
      #(5) Entire transcript region, unspliced [exons & introns] (+1 to end)
      if ((defined param("entireUnspliced"))&&(param("entireUnspliced") eq "on")) {
        entireUnspliced($entryGI[$i]);
      }
      #(6) Entire transcript region, spliced & aligned [cDNA] (+1 to end)
      if ((defined param("entireAligned"))&&(param("entireAligned") eq "on")) {
        entireAligned($entryGI[$i]);
      }
      # Blah
      #(7) Entire translated region, spliced & aligned [Annotated gene only]
      if (defined (param("entireTranslated"))&&(param("entireTranslated") eq "on")) {
        entireTranslated($entryGI[$i]);
      }
      # Blah
      #(8) Flank region of translation start site (ATG)
      if (defined (param("flankStart"))&&(param("flankStart") eq "on")) {
        flankStart($entryGI[$i]);
      }
      #(9) Entire region as a single FASTA file (unspliced, including any specified 5' or 3' sequence)
      if (defined (param("fullRegion"))&&(param("fullRegion") eq "on")) {
        fullUnspiced($entryGI[$i]);
      }
      # From Queries
      #(10) Entire query sequence
      if (defined (param("fullQuery"))&&(param("fullQuery") eq "on")) {
        fullQuery($entryGI[$i]);
      }
      #(11) All exons from queries
      if (defined (param("allExonsQuery"))&&(param("allExonsQuery") eq "on")) {
        allExonsQuery($entryGI[$i]);
      }
      #(12) Entire translated region [Annotated gene only]
      if (defined (param("transSeqQuery"))&&(param("transSeqQuery") eq "on")) {
        transSeqQuery($entryGI[$i]);
      }
    }
  }
  else {
    print "<b>Please choose at least one option of output order</b><br>\n";
    print end_html();
    exit;
  }
  $dbh->disconnect();

  # Print error information;
  print "<br>";
  for (my $i=0; $i<=$#error_info; $i++) {
    print $error_info[$i]."<br>\n";
  }
}
else {
  print  "Please choose correct parameters. Thanks.";
}
print end_html;
#===========================================================
#                 Main Function Completed
#===========================================================
#(1) 5' sequences from genome
sub fivePrime {
  my $entryGI = shift;
  my $title = "Putative_".$database."_5_prime_of_".$entryGI->{GI};
  my @block = split(/\|/,$entryGI->{align});
  my ($times, $ori) = ($block[0]>$block[1])?(1, "r"):(-1, "f");
  my ($bgn_modified, $end_modified);
  if (($entryGI->{CHR} eq "")||($entryGI->{START} eq "")||($entryGI->{END} eq "")) {
    push(@error_info, "$entryGI->{GI} cannot be mapped onto the genome.");
  }
  elsif ((defined param("5_ReBgn"))&&(defined param("5_ReEnd"))&&(param("5_ReBgn") > param("5_ReEnd"))) {
    $bgn_modified = $block[0] + param("5_ReBgn")*$times;
    $end_modified = $block[0] + param("5_ReEnd")*$times;
    if ((defined param("5_neighbor"))&&(param("5_neighbor") eq "on")) {
      ($bgn_modified, $end_modified) = ExNeighbor($entryGI->{GI},$bgn_modified,$end_modified,$entryGI->{CHR},$ori,$database);
    }
    if (($bgn_modified eq "X")&&($end_modified eq "X")) {
      push(@error_info, "Putative 5 prime of $entryGI->{GI} is covered by adjacent genes.");
    }
    else {
      retrieveSeq($bgn_modified, $end_modified, $entryGI->{CHR}, $database, $title);
    }
  }
  else {
    push(@error_info, "Please choose correct 5'prime position of $entryGI->{GI}.");
  }
}
#===========================================================
#(2) 3' sequences from genome
sub threePrime{
  my $entryGI = shift;
  my $title = "Putative_".$database."_3_prime_of_".$entryGI->{GI};
  my @block = split(/\|/,$entryGI->{align});
  my ($times, $ori) = ($block[0]>$block[1])?(1, "r"):(-1, "f");
  my ($bgn_modified, $end_modified);
  if (($entryGI->{CHR} eq "")||($entryGI->{START} eq "")||($entryGI->{END} eq "")) {
    push(@error_info, "$entryGI->{GI} cannot be mapped onto the genome.");
  }
  elsif ((defined param("3_ReBgn"))&&(defined param("3_ReEnd"))&&(param("3_ReBgn") < param("3_ReEnd"))) {
    $bgn_modified = $block[$#block] - param("3_ReBgn")*$times;
    $end_modified = $block[$#block] - param("3_ReEnd")*$times;
    if ((defined param("3_neighbor"))&&(param("3_neighbor") eq "on")) {
      ($bgn_modified, $end_modified) = ExNeighbor($entryGI->{GI},$bgn_modified,$end_modified,$entryGI->{CHR},$ori,$database);
    }
    if (($bgn_modified eq "X")&&($end_modified eq "X")) {
      push(@error_info, "Putative 3_prime of $entryGI->{GI} is covered by adjacent genes.");
    }
    else {
      retrieveSeq($bgn_modified, $end_modified, $entryGI->{CHR}, $database, $title);
    }
  }
  else {
    push(@error_info, "Please choose correct 3' prime position of $entryGI->{GI}.");
  }
}
#===========================================================
#(3) All Exons from genome
sub allExons {
  my $entryGI = shift;
  my $title;
  my @block = split(/\|/,$entryGI->{align});
  if (($entryGI->{CHR} eq "")||($entryGI->{START} eq "")||($entryGI->{END} eq "")) {
    push(@error_info, "$entryGI->{GI} cannot be mapped onto the genome.");
  }
  else {
    for (my $i=0; $i<=$#block; $i+=2) {
      $title = "Putative_".$database."_No".($i/2+1)."_exon_of_".$entryGI->{GI};
      retrieveSeq($block[$i], $block[$i+1], $entryGI->{CHR}, $database, $title);
    }
  }
}
#===========================================================
#(4) All Introns from genome
sub allIntrons {
  my $entryGI = shift;
  my $title;
  my @block = split(/\|/,$entryGI->{align});
  my $time = ($block[0]>$block[1])?1:(-1);
  my ($bgn_modified, $end_modified);
  if (($entryGI->{CHR} eq "")||($entryGI->{START} eq "")||($entryGI->{END} eq "")) {
    push(@error_info, "$entryGI->{GI} cannot be mapped onto the genome.");
  }
  elsif ($#block > 1) {
    for (my $i=1; $i<=$#block-1; $i+=2) {
      $title = "Putative_".$database."_No".(($i+1)/2)."_intron_of_".$entryGI->{GI};
      $bgn_modified = $block[$i]   - $times;
      $end_modified = $block[$i+1] + $times;
      retrieveSeq($bgn_modified, $end_modified, $entryGI->{CHR}, $database, $title);
    }
  }
  else {
    push(@error_info, "NO information to support 1st intron of $entryGI->{GI}.");
  }
}
#===========================================================
#(5) Entire transcript region, unspliced [exons & introns] (+1 to end)
sub entireUnspliced {
  my $entryGI = shift;
  my $title;
  my @block = split(/\|/,$entryGI->{align});
  if (($entryGI->{CHR} eq "")||($entryGI->{START} eq "")||($entryGI->{END} eq "")) {
    push(@error_info, "$entryGI->{GI} cannot be mapped onto the genome.");
  }
  else {
    $title = "Putative_".$database."_entire_unspliced_region_of_".$entryGI->{GI};
    retrieveSeq($block[0], $block[$#block], $entryGI->{CHR}, $database, $title);
  }
}
#===========================================================
#(6) Entire transcript region, spliced & aligned [cDNA] (+1 to end)
sub entireAligned {
  my $entryGI = shift;
  my $title;
  my @block = split(/\|/,$entryGI->{align});
  if (($entryGI->{CHR} eq "")||($entryGI->{START} eq "")||($entryGI->{END} eq "")) {
    push(@error_info, "$entryGI->{GI} cannot be mapped onto the genome.");
  }
  else {
    $title = "Putative_".$database."_entire_spliced_region_of_".$entryGI->{GI};
    retrieveSeq(@block, $entryGI->{CHR}, $database, $title);
  }
}
#===========================================================
#(7) Entire translated region, spliced & aligned [Annotated gene only]
sub entireTranslated {
  my $entryGI = shift;
  my $title;
  my @block = split(/\|/,$entryGI->{align});
  if (($entryGI->{CHR} eq "")||($entryGI->{START} eq "")||($entryGI->{END} eq "")) {
    push(@error_info, "$entryGI->{GI} cannot be mapped onto the genome.");
  }
  elsif (($entryGI->{CDSstart} eq "")||($entryGI->{CDSstop} eq "")) {
    push(@error_info, "$entryGI->{GI} has no CDS information.");
  }
  elsif (($entryGI->{CDSstart}-$block[0])*($entryGI->{CDSstart}-$block[$#block]) >0) {
    push(@error_info, "$entryGI->{GI} has no or error CDS information.");
  }
  elsif (($entryGI->{CDSstop}-$block[0])*($entryGI->{CDSstop}-$block[$#block]) >0) {
    push(@error_info, "$entryGI->{GI} has no or error CDS information.");
  }
  else {
    $title = "Putative_".$database."_entire_translated_region_of_".$entryGI->{GI};
    my @leftBLK = ();
    $guard = 0;
    for (my $i=0; $i<=$#block-1; $i+=2) {
      if ($guard eq "0") {
        if (($entryGI->{CDSstart}-$block[$i])*($entryGI->{CDSstart}-$block[$i+1])<=0) {
          $guard = 1;
          push(@leftBLK, $entryGI->{CDSstart});
          push(@leftBLK, $block[$i+1]);
        }
      }
      else {
        push(@leftBLK, $block[$i]);
        push(@leftBLK, $block[$i+1]);
      }
    }
    @block = @leftBLK;
    @leftBLK = ();
    $guard = 0;
    for (my $i=0; $i<=$#block-1; $i+=2) {
      if ($guard eq "0") {
        if (($entryGI->{CDSstop}-$block[$i])*($entryGI->{CDSstop}-$block[$i+1])<=0) {
          $guard = 1;
          push(@leftBLK, $block[$i]);
          push(@leftBLK, $entryGI->{CDSstop});
        }
        else {
          push(@leftBLK, $block[$i]);
          push(@leftBLK, $block[$i+1]);
        }
      }
    }
    retrieveSeq(@leftBLK, $entryGI->{CHR}, $database, $title);
  }
}
#===========================================================
# Blah
#(8) Flank region of translation start site (ATG)
sub flankStart {
  my $entryGI = shift;
  my $title;
  my @block = split(/\|/,$entryGI->{align});
  if (($entryGI->{CHR} eq "")||($entryGI->{START} eq "")||($entryGI->{END} eq "")) {
    push(@error_info, "$entryGI->{GI} cannot be mapped onto the genome.");
  }
  elsif (($entryGI->{CDSstart} eq "")||($entryGI->{CDSstop} eq "")) {
    push(@error_info, "$entryGI->{GI} has no CDS information.");
  }
  elsif (($entryGI->{CDSstart}-$block[0])*($entryGI->{CDSstart}-$block[$#block]) >0) {
    push(@error_info, "$entryGI->{GI} has error CDS information.");
  }
  else {
    my ($times, $ori) = ($block[0]>$block[1])?(1, "r"):(-1, "f");
    if ((defined param("flankintron"))&&(param("flankintron") eq "includeIntron")) {
      $title = "Putative_".$database."_flank_region_of_".$entryGI->{GI}."_TCss (Include Intron)";
      my $bgn_modified  = $entryGI->{CDSstart} + param("flankReBgn")*$times;
      my $end_modified  = $entryGI->{CDSstart} - (param("flankReEnd")-1)*$times;
      retrieveSeq($bgn_modified, $end_modified, $entryGI->{CHR}, $database, $title);
    }
    elsif ((defined param("flankintron"))&&(param("flankintron") eq "excludeIntron")) {
      $title = "Putative_".$database."_flank_region_of_".$entryGI->{GI}."_TCss (Exclude Intron)";
      my $cdsIndex;
      for (my $i=0; $i<=$#block; $i+=2) {
        if (($entryGI->{CDSstart}-$block[$i])*($entryGI->{CDSstart}-$block[$i+1]) <= 0) {
          $cdsIndex = $i;
          last;
        }
      }

      # Forward
      my @prefixARY = ();
      my $prefixGuard = 0;
      if (($entryGI->{CDSstart} eq $block[$cdsIndex])&&($cdsIndex ne "0")) {
        @prefixARY = @block[0..($cdsIndex-1)];
      }
      elsif (($entryGI->{CDSstart} eq $block[$cdsIndex])&&($cdsIndex eq "0")) {
        push(@prefixARY,$entryGI->{CDSstart});
      }
      else {
        @prefixARY = (@block[0..$cdsIndex], ($entryGI->{CDSstart}-1));
      }
      my @prefixBLK = ();
      for (my $i=$#prefixARY-1; $i>=0; $i-=2) {
        $prefixGuard += abs($prefixARY[$i+1]-$prefixARY[$i])+1;
        if ($prefixGuard >= param("flankReBgn")) {
          my $tmp = $prefixARY[$i] - ($prefixGuard-param("flankReBgn"))*$times;
          @prefixBLK = ($tmp,$prefixARY[$i+1], @prefixBLK);
          last;
        }
        else {
          @prefixBLK = ($prefixARY[$i],$prefixARY[$i+1], @prefixBLK);
        }
      }
      if ($prefixGuard < param("flankReBgn")) {
        my $bgn_modified  = $prefixARY[0] + 1*$times;
        my $end_modified  = $prefixARY[0] + (param("flankReBgn")-$prefixGuard)*$times;
        @prefixBLK = ($end_modified,$bgn_modified, @prefixBLK);
      }

      # Backward (To be done)
      my @surfixARY = ();
      my $surfixGuard = 0;
      if (($entryGI->{CDSstart} eq $block[$cdsIndex+1])&&(($cdsIndex+1) ne $#block)) {
        @surfixARY = @block[($cdsIndex+2)..$#block];
      }
      elsif (($entryGI->{CDSstart} eq $block[$cdsIndex+1])&&(($cdsIndex+1) eq $#block)) {
        push(@surfixARY, $entryGI->{CDSstart});
      }
      else {
        @surfixARY = ($entryGI->{CDSstart}, @block[($cdsIndex+1)..$#block]);
      }
      my @surfixBLK = ();
      for (my $i=0; $i<=$#surfixARY; $i+=2) {
        $surfixGuard += abs($surfixARY[$i+1]-$surfixARY[$i])+1;
        if ($surfixGuard >= param("flankReEnd")) {
          my $tmp = $surfixARY[$i+1] + ($surfixGuard-param("flankReEnd"))*$times;
          @surfixBLK = ($surfixARY[$i],$tmp, @surfixBLK);
          last;
        }
        else {
          @surfixBLK = ($surfixARY[$i],$surfixARY[$i+1], @surfixBLK);
        }
      }
      if ($surfixGuard < param("flankReEnd")) {
        my $bgn_modified  = $surfixARY[$#surfixARY] + 1*$times;
        my $end_modified  = $surfixARY[$#surfixARY] + (param("flankReEnd")-$surfixGuard)*$times;
        @surfixBLK = ($end_modified,$bgn_modified, @surfixBLK);
      }
      my @allBLK = (@prefixBLK, @surfixBLK);
      retrieveSeq(@allBLK, $entryGI->{CHR}, $database, $title);
    }
    else {
      push(@error_info, "$entryGI->{GI} has error flankintron parameter.");
    }
  }
}
#===========================================================
# Blah
#(9) Entire region as a single FASTA file (unspliced, including any specified 5' or 3' sequence)
sub fullUnspiced {
  my $entryGI = shift;
  my $title = "Putative_".$database."_entire_unspliced_region_of_".$entryGI->{GI}." (with flank)";
  my @block = split(/\|/,$entryGI->{align});
  my ($times, $ori) = ($block[0]>$block[1])?(1, "r"):(-1, "f");
  my ($bgn_modified, $end_modified);

  if (($entryGI->{CHR} eq "")||($entryGI->{START} eq "")||($entryGI->{END} eq "")) {
    push(@error_info, "$entryGI->{GI} cannot be mapped onto the genome.");
  }
  else {
    $bgn_modified = $block[0] + param("fullReBgn")*$times;
    $end_modified = $block[$#block] - param("fullReEnd")*$times;
    if (($entryGI->{CHR} eq "")||($entryGI->{START} eq "")||($entryGI->{END} eq "")) {
      push(@error_info, "$entryGI->{GI} cannot be mapped onto the genome.");
    }
    if ((defined param("full_neighbor"))&&(param("full_neighbor") eq "on")) {
      ($bgn_modified, $end_modified) = ExNeighbor($entryGI->{GI},$bgn_modified,$end_modified,$entryGI->{CHR},$ori,$database);
    }
    if (($bgn_modified eq "X")&&($end_modified eq "X")) {
      push(@error_info, "Putative full unspliced of $entryGI->{GI} is covered by adjacent genes.");
    }
    else {
      retrieveSeq($bgn_modified, $end_modified, $entryGI->{CHR}, $database, $title);
    }
  }
}
#===========================================================
# From Queries
#(10) Entire query sequence
sub fullQuery {
  my $entryGI = shift;
  my $trackIndex = $entryGI->{trackIndex};
  my $DSOname    = ${$DBver[$#DBver]->{tracks}}[$trackIndex]->{DSOname};
  if (($DSOname eq "GBKann")||($DSOname eq "GBKgaeval")||($DSOname eq "TIGRtu")||($DSOname eq "TIGRgaeval")) {
    entireAligned($entryGI);
  }
  else {
    my ($qrySEQ, ) = QRYSEQ($entryGI);
    # Output seq
    print "<pre class=\"normal\">\n";
    print ">$entryGI->{GI}\n";
    for (my $i=0; ;$i++) {
      my $line = substr($qrySEQ,$i*60,60);
      if (length($line) < 60) {
        print "$line\n";
        last;
      }
      else {
        print "$line\n";
      }
    }
    print "</pre>\n";
  }
}
#===========================================================
# From Queries
#(11) All exons from queries
sub allExonsQuery {
  my $entryGI = shift;
  my $trackIndex = $entryGI->{trackIndex};
  my $DSOname    = ${$DBver[$#DBver]->{tracks}}[$trackIndex]->{DSOname};
  if (($DSOname eq "GBKann")||($DSOname eq "GBKgaeval")||($DSOname eq "TIGRtu")||($DSOname eq "TIGRgaeval")) {
    allExons($entryGI);
  }
  else {
    my ($qrySEQ, $model) = QRYSEQ($entryGI);
    my $title;
    my @block = split(/\|/,$model);
    print "<pre class=\"normal\">\n";
    if (($entryGI->{CHR} eq "")||($entryGI->{START} eq "")||($entryGI->{END} eq "")) {
      push(@error_info, "$entryGI->{GI} cannot be mapped onto the genome.");
    }
    else {
      for (my $i=0; $i<=$#block; $i+=2) {
        $title = "Putative_No".($i/2+1)."_exon_of_".$entryGI->{GI}." (from Qry)";
        my $exonSeq;
        if ($DSOname eq "GSEG") {
          my $modBLK = ($block[$i] eq "0")?"0":($block[$i]-1);
          $exonSeq = substr($qrySEQ, $modBLK, $block[$i+1]-$block[$i]+1);
        }
        else {
          $exonSeq = substr($qrySEQ, $block[$i]-1, $block[$i+1]-$block[$i]+1);
        }
        print ">".$title."\n";
        for (my $i=0; ;$i++) {
          my $line = substr($exonSeq,$i*60,60);
          if (length($line) < 60) {
            print "$line\n";
            last;
          }
          else {
            print "$line\n";
          }
        }
        print "\n";
      }
    }
    print "</pre>\n";
  }
}
#===========================================================
# From Queries (To be updated)
#(12) Entire translated region [Annotated gene only]
sub transSeqQuery {
  my $entryGI = shift;
  entireTranslated($entryGI);
#  my ($qrySEQ, $model, $CDSstart, $CDSstop) = TRACK::TRANSEQ($entryGI->{GI},$entryGI->{trackIndex});
#  print ...
}
#=================================================
# ExNeighbor($entryGI->{GI},$bgn_modified,$end_modified,$entryGI->{CHR},$ori,$database)
sub ExNeighbor {
  my $geneId = shift;
  my $begin  = shift;
  my $end    = shift;
  my $chr    = shift;
  my $ori    = shift;
  my $GENOME_TYPE = (defined $DBver[$#DBver]->{genomeST})?("CHR-Based"):("BAC-Based");

  my ($db_table, $select_part);
  # Take "DSOname => GBKgaeval" as the standard to judge adjacent genes
  if ($GENOME_TYPE eq "CHR-Based") {
    $db_table = "chr_".$exclude_info_table;
    $select_part = "geneId, chr,     strand, l_pos, r_pos from $db_table where chr=\'$chr\' and strand=\'$ori\' and ((l_pos<=$begin and r_pos>=$begin) or (l_pos<=$end and r_pos>=$end) or (l_pos>=$begin and r_pos<=$end))";
  }
  else {
    $db_table = "gseg_".$exclude_info_table;
    $select_part = "geneId, gseg_gi, strand, l_pos, r_pos from $db_table a left join gseg_type b on a.gseg_gi=b.gi where gseg_gi=\'$chr\' and strand=\'$ori\' and ((l_pos<=$begin and r_pos>=$begin) or (l_pos<=$end and r_pos>=$end) or (l_pos>=$begin and r_pos<=$end))";
  }

  my ($modBegin, $modEnd) = ($ori eq "f")?($begin, $end):($end, $begin);

  $sth = $dbh->prepare("select $select_part;");
  $sth->execute();

  #geneId, chr, strand, l_pos, r_pos, gene_structure, description, note
  while (@tmpARY = $sth->fetchrow_array()) {
    if (checkAltSpicing($tmpARY[0], $geneId) eq "1") {
      next;
    }
    if (($tmpARY[3]<$modBegin)&&($tmpARY[4]>$modEnd)) {
      $modBegin = "X";
      $modEnd   = "X";
      last;
    }
    elsif (($tmpARY[3]<$modBegin)&&($tmpARY[4]<$modEnd)) {
      $modBegin = $tmpARY[4]+1;
    }
    elsif (($tmpARY[3]>$modBegin)&&($tmpARY[4]>$modEnd)) {
      $modEnd = $tmpARY[3]-1;
    }
    elsif (($tmpARY[3]>$modBegin)&&($tmpARY[4]>$modEnd)) {
      $modEnd = $tmpARY[3]-1;
    }
  }
  $sth->finish();
  ($ori eq "f")?return($modBegin, $modEnd):return($modEnd, $modBegin);
}
#=================================================
sub checkAltSpicing {
  my $first  = shift;
  my $second = shift;
  $first =($first =~/^(\S+)\.\d+/)?$1:$first;
  $second=($second=~/^(\S+)\.\d+/)?$1:$second;
  ($first eq $second)?(return 1):(return 0);
}
#=================================================
sub retrieveSeq {
  # Input format change
  # NEW: bgn_1 end_1 bgn_2 end_2 ... chr annotation
  # OLD: bgn end chr annotation
  # retrieveSeq($bgn_modified, $end_modified, $entryGI->{CHR}, $database, $title);
  my @block = @_;
  my $start;
  my $end;
  my $ori = ($block[0]<$block[1])?1:(-1);
  my $ann        = pop(@block);
  my $database   = pop(@block);
  my $chromosome = pop(@block);
  my $all_seq    = "";

  # Find chromosome
#  my $length     = 1000000;  
#  my $seqPath    = $DATADIR."/GENOME/";
  my $genomeType = (defined $DBver[$#DBver]->{genomeST})?"CHR-Based":"BAC-Based";
  
  if ($ori eq "-1") {
    @block = reverse(@block);
  }

  my $tmp = "";

  if ($genomeType eq "CHR-Based") {
    # Load sequences with fastacmd;
    my $single_seq;
    for (my $j=0; $j<=$#block; $j+=2) {
      $tmp .= $block[$j]."..".$block[$j+1].";";
      $single_seq = `$FASTACMD -d $BLAST_DB{"$genome_id"}[1] -s $titleARY[($chromosome-1)] -L $block[$j],$block[$j+1]`;
      my @tmpARY = split(/\n/, $single_seq);
      for (my $s=0; $s<=$#tmpARY; $s++) {
        chomp($tmpARY[$s]);
        if ($tmpARY[$s]=~/^\>/) {
          next;
        }
        else {
          $all_seq = $all_seq.$tmpARY[$s];
        }
      }
    }
    $tmp =~s/\;$//;

#    for (my $j=0; $j<=$#block; $j+=2) {
#      $start = $block[$j];
#      $end   = $block[$j+1];
#      if ($ori eq "-1") {
#        $tmp  = $end."..".$start.";".$tmp; 
#      }
#      else {
#        $tmp .= ";".$start."..".$end;
#      }
#      # Find positions
#      $startNumBt = int($start/$length);
#      $startNumIn = $start%$length;
#      
#      $endNumBt   = int($end/$length);
#      $endNumIn   = $end%$length;
#    
#      $targetSeq = "";
#      if ($startNumBt < $endNumBt) {    # In two or more fragment
#        for ($i = $startNumBt; $i <= $endNumBt; $i++) {
#          $sequence  = "";
#          $temp1 = $i * $length;
#          $temp2 = ($i + 1)*$length;
#          open(IN,"$seqPath/$chromosome/$chromosome.$temp1.$temp2")||die ":$!";
#          while (<IN>) {
#            chomp;
#            if (/^\>/) {
#              next;
#            }
#            else {
#              $sequence .= $_;
#            }
#          }
#          close(IN)||die ":$!";
#          if ($i eq $startNumBt) {
#            $targetSeq = substr($sequence, $startNumIn-1, length($sequence) - $startNumIn);
#          }
#          elsif ($i eq $endNumBt) {
#            $tempSeq   = substr($sequence, 0, $endNumIn);
#            $targetSeq .= $tempSeq;
#          }
#          else {
#            $targetSeq .= $sequence;
#          }
#        }
#      }
#      elsif ($startNumBt eq $endNumBt) {  # In one fragment
#        $sequence  = "";
#        $temp1 = $endNumBt * $length;
#        $temp2 = ($endNumBt + 1)*$length;
#        $filename = "$seqPath/$chromosome/$chromosome.$temp1.$temp2";
#        open(IN,"$filename")||print "Cannot open files $filename";
#        while (<IN>) {
#          chomp;
#          if (/^\>/) {
#            next;
#          }
#          else {
#            $sequence .= $_;
#          }
#        }
#        close(IN)||die ":$!";
#        $targetSeq = substr($sequence, $startNumIn-1, $endNumIn - $startNumIn + 1);
#      }
#      else {
#        print "Error in positions.\n";
#        exit;
#      }
#      $all_seq .= $targetSeq;
#    }
  }
  else {
# Load from text file;
#    $sequence = "";
#    open(IN,"$seqPath/$chromosome")||next;
#    while (<IN>) {
#      chomp;
#      if (/^\>/) {
#        next;
#      }
#      else {
#        $sequence .= $_;
#      }
#    }
#    close(IN)||die ":$!";

# Load from MySQL database;
    my $sth = $dbh->prepare("select seq from gseg where gi=\"$chromosome\";");
    $sth->execute();
    while (@tmpARY = $sth->fetchrow_array()) {
      $sequence = $tmpARY[0];
    }
    $sth->finish();

    my $single_seq;
    for (my $j=0; $j<=$#block; $j+=2) {
      $tmp .= $block[$j]."..".$block[$j+1].";";
      $single_seq = substr($sequence, $block[$j]-1, $block[$j+1] - $block[$j] + 1);
      $all_seq    = $all_seq.$single_seq;
    }
    $tmp =~s/\;$//;
  }

  # Output seq
  print "<pre class=\"normal\">\n";
  $tmp =~s/^\;//g;  $tmp =~s/\;$//g;
  print ">$ann\t$chromosome\t$tmp\n";
  if ($ori eq "-1") {
    $all_seq = reverse($all_seq);
    $all_seq = uc($all_seq);
    $all_seq =~tr/ATGC/TACG/;
  }
  for ($i=0; ;$i++) {
    $line = substr($all_seq,$i*60,60);
    if (length($line) < 60) {
      print "$line\n";
      last;
    }
    else {
      print "$line\n";
    }
  }
  print "</pre>\n";
}
#===========================================================
# RETURN QRY_SEQ & MODEL SECTION
#===========================================================
sub QRYSEQ {
  my $entryGI    = shift;
  my %DEFAULT_DSO = TRACK::DEFAULT_DSO_TABLE();
  my $trackIndex = $entryGI->{trackIndex};
  my $db_table   = (defined ${$DBver[$#DBver]->{tracks}}[$trackIndex]->{db_table})?${$DBver[$#DBver]->{tracks}}[$trackIndex]->{db_table}:$DEFAULT_DSO{${$DBver[$#DBver]->{tracks}}[$trackIndex]->{DSOname}};
  my $GENOME_TYPE = (defined $DBver[$#DBver]->{genomeST})?("CHR-Based"):("BAC-Based");
  my $DSOname     = ${$DBver[$#DBver]->{tracks}}[$trackIndex]->{DSOname};
  if ($DSOname eq "GSEG") {
    my $sequence;
    if ($entryGI->{CHR} eq "") {  # NO HITS
      my $sth = $dbh->prepare("select seq from $db_table where id=\"$entryGI->{GI}\";");
      $sth->execute();
      while (@tmpARY = $sth->fetchrow_array()) {
        $sequence = $tmpARY[0];
      }
      $sth->finish();
      return ($sequence, "");
    }
    else {
      my $sth = $dbh->prepare("select seq, FRAG_lpos, FRAG_rpos from $db_table a left join gseg_$db_table b on a.uid=b.FRAG_uid where a.id=\"$entryGI->{GI}\" and b.SCAF_lpos=$entryGI->{START} and b.SCAF_rpos=$entryGI->{END};");
      $sth->execute();
      my @array = ();
      while (@tmpARY = $sth->fetchrow_array()) {
        $sequence = $tmpARY[0];
        push(@array, $tmpARY[1]);
        push(@array, $tmpARY[2]);
      }
      $sth->finish();
      return ($sequence, join("|",@array));
    }
  }
  else {
    my ($join_table, $exon_table, $sequence);
    if ($GENOME_TYPE eq "CHR-Based") {
      $join_table = "${db_table}_good_pgs";
      $exon_table = $join_table."_exons";
    }
    else {
      $join_table = "gseg_${db_table}_good_pgs";
      $exon_table = $join_table."_exons";
    }
#push @entryGI, {keyId=>$keyId, GI=>$gi, START=>$start, END=>$end, CHR=>$chr, align=>$align, trackIndex=>$trackIndex, CDSstart=>$CDSstart, CDSstop=>$CDSstop}; 
    if ($entryGI->{CHR} eq "") {  # NO HITS
      my $sth = $dbh->prepare("select seq from $db_table a left join $join_table b on a.gi=b.gi where a.gi=$entryGI->{GI};");
      $sth->execute();
      while (@tmpARY = $sth->fetchrow_array()) {
        $sequence = $tmpARY[0];
      }
      $sth->finish();
      return ($sequence, "");
    }
    else {
      my $sth = $dbh->prepare("select seq, pgs_start, pgs_stop from $db_table a left join $join_table b on a.gi=b.gi left join $exon_table c on b.uid=c.pgs_uid where a.gi=$entryGI->{GI} and l_pos=$entryGI->{START} and r_pos=$entryGI->{END};");
      $sth->execute();
      my @array = ();
      while (@tmpARY = $sth->fetchrow_array()) {
        $sequence = $tmpARY[0];
        push(@array, $tmpARY[1]);
        push(@array, $tmpARY[2]);
      }
      $sth->finish();
      return ($sequence, join("|",@array));
    }
  }
}
