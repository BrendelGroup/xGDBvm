#!/usr/bin/perl -w

package TRACK;

use Switch;
do 'SITEDEF.pl';
# This package deals with track related functions

#===========================================================
# MySQL select SECTION
#===========================================================
#CHR-based : BAC-based
#GI|GI : GI|ACC : TEXT|DES : TEXT|NOTE : LOCUS
#"CDNApgs"
#"ESTpgs"
#"PEPpgs"
#"PROBE"
#"GSEG"
#"GBKann"
#"GBKgaeval"
#"TIGRtu"
#"TIGRgaeval"
#"UCAann"
#===========================================================
# Input: $qryMethod; $table; @qryWords
#        $qryMethod; GI/TEXT/LOCUS
sub QRY_MySQL {
#  my $qryMethod  = "GI|GI"; #GI|GI : GI|ACC : TEXT : LOCUS
#  my $trackIndex = 8;
#  my @qryWords   = ("120481492", "420481492");

  my $qryMethod  = shift; #GI|GI : GI|ACC : TEXT : LOCUS
  my $trackIndex = shift;
  my @qryWords   = @_;

  my %DEFAULT_DSO = DEFAULT_DSO_TABLE();
  my $db_table = (defined ${$DBver[$#DBver]->{tracks}}[$trackIndex]->{db_table})?${$DBver[$#DBver]->{tracks}}[$trackIndex]->{db_table}:$DEFAULT_DSO{${$DBver[$#DBver]->{tracks}}[$trackIndex]->{DSOname}};
  my $DSOname   = ${$DBver[$#DBver]->{tracks}}[$trackIndex]->{DSOname};

  my ($select_part, $where_part, $qry_command);

  # yrGate
  if ($DSOname eq "UCAann") {
    $select_part = "select geneId, chr, strand, l_pos, r_pos, gene_structure, description, comment, CDSstart, CDSstop from $db_table where ";
       if ($qryMethod eq "GI|GI")  { $where_part = GI_ONLY("geneId", @qryWords);}
    elsif ($qryMethod eq "TEXT")   { $where_part = DESCRIPTION_ONLY("description", @qryWords);}
    elsif ($qryMethod eq "LOCUS")  { $where_part = LOCUS_ONLY("chr", "l_pos", "r_pos", @qryWords);}
    else {
    }
    $qry_command = $select_part.$where_part." and status = \"ACCEPTED\" order by geneId ASC;";
  }
  # BAC-Based
  elsif ($DSOname eq "CDNApgs") {
    $select_part = "select a.gi, acc, gseg_gi, G_O, sim, cov, l_pos, r_pos, pgs, description from $db_table a left join gseg_${db_table}_good_pgs b on a.gi=b.gi where ";
       if ($qryMethod eq "GI|GI")  { $where_part = GI_ONLY("a.gi", @qryWords);}
    elsif ($qryMethod eq "GI|ACC") { $where_part = ACC_ONLY("acc", @qryWords);}
    elsif ($qryMethod eq "TEXT")   { $where_part = DESCRIPTION_ONLY("description", @qryWords);}
    elsif ($qryMethod eq "LOCUS")  { $where_part = LOCUS_ONLY("gseg_gi", "l_pos", "r_pos", @qryWords);}
    else  {}
    $qry_command = $select_part.$where_part." order by a.gi ASC, sim DESC, cov DESC;";
  }
  elsif ($DSOname eq "ESTpgs") {
    $select_part = "select a.gi, acc, gseg_gi, G_O, sim, cov, l_pos, r_pos, pgs, description from $db_table a left join gseg_${db_table}_good_pgs b on a.gi=b.gi where ";
       if ($qryMethod eq "GI|GI")  { $where_part = GI_ONLY("a.gi", @qryWords);}
    elsif ($qryMethod eq "GI|ACC") { $where_part = ACC_ONLY("acc", @qryWords);}
    elsif ($qryMethod eq "TEXT")   { $where_part = DESCRIPTION_ONLY("description", @qryWords);}
    elsif ($qryMethod eq "LOCUS")  { $where_part = LOCUS_ONLY("gseg_gi", "l_pos", "r_pos", @qryWords);}
    else  {}
    $qry_command = $select_part.$where_part." order by a.gi ASC, sim DESC, cov DESC;";
  }
  elsif ($DSOname eq "PEPpgs") {
    $select_part = "select a.gi, acc, gseg_gi, G_O, sim, cov, l_pos, r_pos, pgs, description from $db_table a left join gseg_${db_table}_good_pgs b on a.gi=b.gi where ";
       if ($qryMethod eq "GI|GI")  { $where_part = GI_ONLY("a.gi", @qryWords);}
    elsif ($qryMethod eq "GI|ACC") { $where_part = ACC_ONLY("acc", @qryWords);}
    elsif ($qryMethod eq "TEXT")   { $where_part = DESCRIPTION_ONLY("description", @qryWords);}
    elsif ($qryMethod eq "LOCUS")  { $where_part = LOCUS_ONLY("gseg_gi", "l_pos", "r_pos", @qryWords);}
    else  {}
    $qry_command = $select_part.$where_part." order by a.gi ASC, sim DESC, cov DESC;";
  }
  elsif ($DSOname eq "GBKgaeval") {
    $db_table = "gseg_".$db_table;
    $select_part = "select geneId, gseg_gi, strand, l_pos, r_pos, gene_structure, description, note, CDSstart, CDSstop from $db_table a where ";
       if ($qryMethod eq "GI|GI")  { $where_part = GENEID_ONLY("geneId", @qryWords);             }
    elsif ($qryMethod eq "TEXT")   { $where_part = DESCRIPTION_AND_NOTE("description", "note", @qryWords);}
    elsif ($qryMethod eq "LOCUS")  { $where_part = LOCUS_ONLY("gseg_gi","l_pos", "r_pos", @qryWords);          }
    else  {}
    $qry_command = $select_part.$where_part." order by geneId ASC;";
  }
  else {
  }
  return $qry_command;
}
#=================================================
# Input: $qryIndex
sub QRY_SAMPLE {
  my $trackIndex = shift;

  my %DEFAULT_DSO = TRACK::DEFAULT_DSO_TABLE();
  my $db_table  = (defined ${$DBver[$#DBver]->{tracks}}[$trackIndex]->{db_table})?${$DBver[$#DBver]->{tracks}}[$trackIndex]->{db_table}:$DEFAULT_DSO{${$DBver[$#DBver]->{tracks}}[$trackIndex]->{DSOname}};
  my $DSOname   = ${$DBver[$#DBver]->{tracks}}[$trackIndex]->{DSOname};
  my $GENOME_TYPE = (defined $DBver[$#DBver]->{genomeST})?("CHR-Based"):("BAC-Based");

  my $select_part = "";
  if ($DSOname eq "UCAann") {
    my $yrGATE_dbname = ${$DBver[$#DBver]->{tracks}}[$trackIndex]->{DB};
    $select_part = "select DISTINCT geneId from $db_table where dbname = \"$yrGATE_dbname\" and status = \"ACCEPTED\" limit 0,2;";
  }
  # BAC-Based
  elsif ($DSOname eq "CDNApgs") {
    $select_part = "select DISTINCT a.gi, acc from $db_table a left join gseg_${db_table}_good_pgs b on a.gi=b.gi limit 0,2;";
  }
  elsif ($DSOname eq "ESTpgs") {
    $select_part = "select DISTINCT a.gi, acc from $db_table a left join gseg_${db_table}_good_pgs b on a.gi=b.gi limit 0,2;";
  }
  elsif ($DSOname eq "PEPpgs") {
    $select_part = "select DISTINCT a.gi, acc from $db_table a left join gseg_${db_table}_good_pgs b on a.gi=b.gi limit 0,2;";
  }
  elsif (($GENOME_TYPE eq "BAC-Based")&&($DSOname eq "GBKann")) {
    $db_table = "gseg_".$db_table;
    $select_part = "select DISTINCT geneId from $db_table a left limit 0,2;";
  }
  elsif ($DSOname eq "GBKgaeval") {
    $db_table = "gseg_".$db_table;
    $select_part = "select DISTINCT geneId from $db_table a limit 0,2;";
  }
  return $select_part;
}
#=================================================
# WHERE_PART
sub DESCRIPTION_ONLY {
  my $description = shift;
  my @qryWords = @_;
  my $qryHandle = "$description like '%".join("%' AND $description like '%",@qryWords)."%'";
  return $qryHandle;
}
sub DESCRIPTION_AND_NOTE {
  my $description = shift;
  my $note        = shift;
  my @qryWords = @_;
  my $qryHandle;
  for (my $i=0; $i<=$#qryWords; $i++) {
    $qryHandle .= "($note like \"%$qryWords[$i]%\" or $description like \"%$qryWords[$i]%\") and";
  }
  $qryHandle=~s/\s*and$//;
  return $qryHandle;
}
sub GI_ONLY {
  my $gi     = shift;
  my @qWords = @_;
  my $qryHandle = "";
  my $tmpString;
  for (my $i=0; $i<=$#qWords; $i++) {
    if($qWords[$i]=~/((\(\.\))|(\(\_\)))/) { # 2 Steps: 1) Substitution; 2) Like
      $tmpString = $qWords[$i];
      $tmpString =~s/((\(\.\))|(\(\_\)))/_/g;
      $tmpString =~s/\*/%/g;
      $qryHandle .= "$gi like \'$tmpString\' OR ";
    }
    elsif ($qWords[$i]=~/[\*\%]/) {      # 1 Step:  1) Like
      $tmpString = $qWords[$i];
      $tmpString =~s/\*/%/g;
      $qryHandle .= "$gi like \'$tmpString\' OR ";
    }
    else {
      $qryHandle .= "$gi=\'$qWords[$i]\' OR ";
    }
  }
  $qryHandle =~s/OR\s*$//;
  return $qryHandle;
#  return "$gi='".join("' OR $gi='",@qWords)."'";
}
sub ACC_ONLY {
  my $acc    = shift;
  my @qWords = @_;
  my $qryHandle = "";
  my $tmpString;
  for (my $i=0; $i<=$#qWords; $i++) {
    if($qWords[$i]=~/((\(\.\))|(\(\_\)))/) { # 2 Steps: 1) Substitution; 2) Like
      $tmpString = $qWords[$i];
      $tmpString =~s/((\(\.\))|(\(\_\)))/_/g;
      $tmpString =~s/\*/%/g;
      $qryHandle .= "$acc like \'$tmpString\' OR ";
    }
    elsif ($qWords[$i]=~/[\*\%]/) {      # 1 Step:  1) Like
      $tmpString = $qWords[$i];
      $tmpString =~s/\*/%/g;
      $qryHandle .= "$acc like \'$tmpString\' OR ";
    }
    else {
      $qryHandle .= "$acc=\'$qWords[$i]\' OR ";
    }
  }
  $qryHandle =~s/OR\s*$//;
  return $qryHandle;
#  return "$acc='".join("' OR $acc='",@qWords)."'";
}
sub GENEID_ONLY {
  my $geneId = shift;
  my @qWords = @_;
  my $qryHandle = "";
  my $tmpString;
  for (my $i=0; $i<=$#qWords; $i++) {
    if($qWords[$i]=~/((\(\.\))|(\(\_\)))/) { # 2 Steps: 1) Substitution; 2) Like
      $tmpString = $qWords[$i];
      $tmpString =~s/((\(\.\))|(\(\_\)))/_/g;
      $tmpString =~s/\*/%/g;
      $qryHandle .= "$geneId like \'$tmpString\' OR ";
    }
    elsif ($qWords[$i]=~/[\*\%]/) {      # 1 Step:  1) Like
      $tmpString = $qWords[$i];
      $tmpString =~s/\*/%/g;
      $qryHandle .= "$geneId like \'$tmpString\' OR ";
    }
    else {
      $qryHandle .= ($qWords[$i]=~/\./)?"$geneId=\'$qWords[$i]\' OR ":"$geneId=\'$qWords[$i]\' OR $geneId like \'$qWords[$i].%\' OR ";
    }
  }
  $qryHandle =~s/OR\s*$//;
  return $qryHandle;
}
sub LOCUS_ONLY {
  my $chr     = shift;
  my $l_pos   = shift;
  my $r_pos   = shift;
  my @qryInfo = @_;
     $qryInfo[0]=~s/\|[\+\-]$//g;
  return "$chr=\'$qryInfo[0]\' and (($l_pos<=$qryInfo[1] and $r_pos>=$qryInfo[1]) or ($l_pos<=$qryInfo[2] and $r_pos>=$qryInfo[2]) or ($l_pos>=$qryInfo[1] and $r_pos<=$qryInfo[2]))";
}
#=================================================
sub DEFAULT_DSO_TABLE {
  my %DEFAULT_DSO = (
       "CDNApgs" => 'cdna',      # CLASS I
       "ESTpgs"  => 'est',       # CLASS I
       "PEPpgs"  => 'pep',       # CLASS I
       "PROBE"   => 'probe',     # CLASS I
       "Marker"  => 'marker',    # NONE
       "BAC"     => 'gseg',      # CLASS II
       "GSEG"    => 'gseg',      # CLASS II
       "GBKann"     => 'gene_annotation',  # CLASS III
       "GBKgaeval"  => 'gene_annotation',  # CLASS III
       "TIGRtu"     => 'chr_tigr_tu',      # CLASS III
       "TIGRgaeval" => 'chr_tigr_tu',      # CLASS III
       "UCAann"     => 'user_gene_annotation',  # NONE
  );
  return %DEFAULT_DSO;
}
#===========================================================
# Hidden Button SECTION
#===========================================================
sub hideButton {
  my $dbTBParam  = shift;
  my @track    = split(/\|/,$dbTBParam);
  my $button;
  my ($trackVar, $if_part, $javascript, $trackUniform);
  for (my $i=0; $i<=$#track; $i++) {
    my $trackname = simpleName(${$DBver[$#DBver]->{tracks}}[$track[$i]]->{trackname});
    $button   .= "\n<input type=\"button\" name=\"buttonTrack\" onClick='this.value=setToggleRows(\"alignTable\", \"$trackname\")'    value=\"Hide $trackname\">";
    $trackVar .= "var track$track[$i] = true;\n";
    $trackUniform .= "    track$track[$i] = trackAll;\n";
    $if_part  .= "
  if (seqType == \"$trackname\") {
    hide = track$track[$i];
    track$track[$i] = !track$track[$i];
    returnVar=(hide)?\"Show $trackname\":\"Hide $trackname\";
  }";
  }

  $javascript = "
<script type=\"text/javascript\">
var hide = true;
$trackVar
var trackAll = true;
function setToggleRows(tableId, seqType) {
  var returnVar = \"\";
$if_part
  tbl = document.getElementById(tableId);
  var len = tbl.rows.length;
  for (i=1 ; i< len; i++){
    var x = tbl.rows[i].cells;
    if(x[0].innerHTML == seqType) {
      tbl.rows[i].style.display=(hide)?\"none\":\"\";
      tbl.rows[i+1].style.display=(hide)?\"none\":\"\";
      tbl.rows[i+2].style.display=(hide)?\"none\":\"\";
      i = i+2;
    }
  }

  if (seqType == \"FULL_TRACK\") {  //***
    full_tracks = document.getElementsByName(\"buttonTrack\");
    hide = trackAll;
    trackAll = !trackAll;
$trackUniform
    for (i=0; i< full_tracks.length; i++) {
      if (trackAll) {
        full_tracks[i].value = full_tracks[i].value.replace(\"Show\", \"Hide\");
      } else {
        full_tracks[i].value = full_tracks[i].value.replace(\"Hide\", \"Show\");
      }
    }
    returnVar=(hide)?\"Show ALL\":\"Hide ALL\";
    for (i=2 ; i< len; i++){
      tbl.rows[i].style.display=(hide)?\"none\":\"\";
    }
  }
  return returnVar;
}
//--></script>
  ";
  $button .= "<input type=\"button\" onclick=\"this.value=setToggleRows('alignTable', 'FULL_TRACK')\" value=\"Hide ALL\"/>\n";
  $button .= "<br>\n";
  return $javascript."\n".$button;
}
#===========================================================
# Retrieve Button SECTION
#===========================================================
sub SeqRetrButton {
  my $file     = shift;
  my $option   = "
      <input type=\"hidden\" name=\"file\" value=$file>
      <input type=\"hidden\" name=\"seqId\" value=\"\">
      <div align=left>
        <table align=left>
          <tr>
            <td colspan=2><h2>SEQUENCE RETRIEVAL <br /><span class=\"heading\">This tool retrieves sequences from your choice of IDs, with options for including upstream/downstream, spliced/unspliced regions.<br />[<a href=\"modelLegend.cgi\" target=\"_blank\">View a Pictogram Describing Options</a>]</h2> 
            <br />
            1) Select one or more retrieval options below <br />
            2) Select one or more sequence ID(s) in Results using checkboxes<br />
            3) Click \"Retrieve FASTA\"
         </td>
          </tr>
          <tr>
            <td colspan=2><b>Output ordered <input type=radio name=outOrder value=opOrder checked>by OPTION or <input type=radio name=outOrder value=giOrder>by GI</b></td>
          </tr>


          <tr>
            <td><input type=checkbox name=5_prime></td>
            <td>5\' region</td>
          </tr>
          <tr>
            <td></td>
            <td>[Retrieve from:-<input type=text size=3 name=5_ReBgn value=200>bp to -<input type=text size=3 name=5_ReEnd value=1>bp]</td>
          </tr>
          <tr>
            <td></td>
            <td>[<input type=checkbox name=5_neighbor checked>Exclude neighboring gene seq.]</td>
          </tr>
          <tr>
            <td><input type=checkbox name=3_prime></td>
            <td>3\' region</td>
          </tr>
          <tr>
            <td></td>
            <td>[Retrieve from:end+<input type=text size=3 name=3_ReBgn value=1>bp to end+<input type=text size=3 name=3_ReEnd value=200>bp]</td>
          </tr>
          <tr>
            <td></td>
            <td>[<input type=checkbox name=3_neighbor checked>Exclude neighboring gene seq.]</td>
          </tr>
          <tr>
            <td><input type=checkbox name=allExons></td>
            <td>All exons</td>
          </tr>
          <tr>
            <td><input type=checkbox name=allIntrons></td>
            <td>All introns</td>
          </tr>
          <tr>
            <td><input type=checkbox name=entireUnspliced></td>
            <td>Entire transcript region, unspliced [exons & introns] (+1 to end)</td>
          </tr>
          <tr>
            <td><input type=checkbox name=entireAligned></td>
            <td>Entire transcript region, spliced & aligned [cDNA] (+1 to end)</td>
          </tr>
          <tr>
            <td><input type=checkbox name=entireTranslated></td>
            <td>Entire translated region, spliced & aligned [Annotated gene only]</td>
          </tr>
          <tr>
            <td><input type=checkbox name=flankStart></td>
            <td>Flanking region of translation start site (ATG)</td>
          </tr>
          <tr>
            <td></td>
            <td><input type=radio name=flankintron value=includeIntron checked>Include Intron&nbsp&nbsp&nbsp<input type=radio name=flankintron value=excludeIntron>Exclude Intron</td>
          </tr>
          <tr>
            <td></td>
            <td>[Retrieve from:-<input type=text size=3 name=flankReBgn value=200>bp to <input type=text size=3 name=flankReEnd value=3>bp]</td>
          </tr>
          <tr>
            <td><input type=checkbox name=fullRegion></td>
            <td>Entire region as a single FASTA file (unspliced, including any specified 5' or 3' sequence)</td>
          </tr>
          <tr>
            <td></td>
            <td>[Retrieve from:-<input type=text size=3 name=fullReBgn value=200>bp to end+<input type=text size=3 name=fullReEnd value=200>bp]</td>
          </tr>
          <tr>
            <td></td>
            <td>[<input type=checkbox name=full_neighbor checked>Exclude neighboring gene seq.]</td>
          </tr>

          <tr>
            <td colspan=2><b>Retrieve sequences from original queries</b></td>
          </tr>
          <tr>
            <td><input type=checkbox name=fullQuery></td>
            <td>Entire query sequence</td>
          </tr>
          <tr>
            <td><input type=checkbox name=allExonsQuery></td>
            <td>All exons</td>
          </tr>
          <tr>
            <td><input type=checkbox name=transSeqQuery></td>
            <td>Entire translated region [Annotated gene only]</td>
          </tr>

          <tr>
            <td colspan=2><input value=\"Retrieve FASTA\" type=\"submit\" onClick=\'multiRev(\"\\seqRetrieval.pl\")\'><span class=\"heading\"> Remember to select sequences below!</span></td>
          </tr>
        </table>
      </div>
";
  return $option;
}
#===========================================================
# HTML Table output SECTION
#===========================================================
sub htmlTbElement {
  my $trackIndex = shift;
  if ((!(defined $trackIndex))||($trackIndex eq "")) {   # Table title
    my $SEARCHDIR = ${CGIPATHs}."/search.pl";
    my $title = "
    <h1 class='bottommargin1'>Search ID/Keyword - Results <img id='fullsearch_results' title='Search ID/Keyword Help' class='xgdb-help-button' src='/XGDB/images/help-icon.png' alt='?' />
        <span class='heading'>&nbsp;&nbsp;[<a title='Clear this search and start a new query' href='$SEARCHDIR'>Search Again</a>]</span>
    </h1>
  <tr align='center'>
    <th align='center' rowspan='2' width='45'>Record Type <br /><span class=\"smallerfont\">(Click to Select)</span></th>
    <th rowspan='2' width='20'><input type='checkbox' name='CheckAll' onclick='checkAll(document.guiFORM.CheckAll)'></th>
    <th width='100'>Sequence ID <br /><span class=\"smallerfont\">(Click to view Record)</span)</th>
    <th width='70'>Chr/Gseg</th>
    <th width='50'>Sim</th>
    <th width='50'>Begin</th>
    <th rowspan='2'>Alignment to Genome <br /><span class=\"smallerfont\">(Click to view in Genome Context)</span)</th>
  </tr>
  <tr align='center'>
    <th>Accession</th>
    <th>Strand</th>
    <th>Coverage</th>
    <th>End</th>
  </tr>
";
    return($title);
  }

  my $qryType     = shift; # TEXT OR GI
  my $highlight   = shift;
     $highlight   =~s/[\%\*]/.*/g;
     $highlight   =~s/\(\_\)/./g;
     $highlight   =~s/\(\.\)/./g;
  my @elementInfo = @_;
  my $GENOME_TYPE = (defined $DBver[$#DBver]->{genomeST})?("CHR-Based"):("BAC-Based");
  my ($inputType, $color);
  $inputType = simpleName(${$DBver[$#DBver]->{tracks}}[$trackIndex]->{trackname});
  $color     = ${$DBver[$#DBver]->{tracks}}[$trackIndex]->{primaryColor};

  my ($note, $desc, $align, $gi, $CDSstart, $CDSstop);
  my ($checkboxName, $modelCELL, $line_1, $line_2, $line_3);
  my $DSOname = ${$DBver[$#DBver]->{tracks}}[$trackIndex]->{DSOname};

# select geneId, chr, strand, l_pos, r_pos, gene_structure, description, note, CDSstart, CDSstop
  if (($DSOname eq "GBKann")||($DSOname eq "GBKgaeval")||($DSOname eq "TIGRtu")||($DSOname eq "TIGRgaeval")||($DSOname eq "UCAann")) {
    $CDSstop  = pop(@elementInfo);
    $CDSstart = pop(@elementInfo);
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
    if ($qryType eq "GI") {
      $elementInfo[0]=~s/^($highlight)(\.\d+)*$/\<FONT style\=\"BACKGROUND-COLOR\: yellow\"\>$1\<\/FONT\>$2/gi;  # gi
    }
    elsif($qryType eq "TEXT") {
      $note=~s/($highlight)/\<FONT style\=\"BACKGROUND-COLOR\: yellow\"\>$1\<\/FONT\>/gi;  # gi
      $desc=~s/($highlight)/\<FONT style\=\"BACKGROUND-COLOR\: yellow\"\>$1\<\/FONT\>/gi;  # acc
    }

    $checkboxName = $gi."|".$elementInfo[1]."|".$elementInfo[3]."|".$elementInfo[4];

    my ($dbid, $chr, $l_pos, $r_pos) = ($#DBver, $elementInfo[1], ($elementInfo[3]-500), ($elementInfo[4]+500));
    if ($GENOME_TYPE eq "CHR-Based") {
      $modelCELL    = "<a title=\"View genome context for this sequence\" href=\"getRegion.pl?dbid=$dbid;chr=$chr;l_pos=$l_pos;r_pos=$r_pos\" target=\"findRegion:$gi\"><img src=\"singleSEQ.cgi?color=$color&align=$align&CDSstart=$CDSstart&CDSstop=$CDSstop\"></a>";
    }
    else {
      $modelCELL    = "<a title=\"View genome context for this sequence\" href=\"getGSEG_Region.pl?dbid=$dbid;gseg_gi=$chr;bac_lpos=$l_pos;bac_rpos=$r_pos\" target=\"findRegion:$gi\"><img src=\"singleSEQ.cgi?color=$color&align=$align&CDSstart=$CDSstart&CDSstop=$CDSstop\"></a>";
    }

    $line_1 = "<td>$elementInfo[1]</td><td></td><td>$elementInfo[3]</td><td rowspan=2>$modelCELL</td>";
    $line_2 = "<td></td><td>$elementInfo[2]</td><td></td><td>$elementInfo[4]</td>";
    $line_3 = ($DSOname eq "UCAann")?"<td colspan=5>$desc</td>":"<td colspan=4>$desc</td><td>$note</td>";
  }
# select a.gi, acc, gseg_gi, G_O, sim, cov, l_pos, r_pos, pgs, description
  elsif (($DSOname eq "CDNApgs")||($DSOname eq "ESTpgs")||($DSOname eq "PEPpgs")||($DSOname eq "PROBE")) {
    $desc  = pop(@elementInfo);
    $align = pop(@elementInfo);
    $align =~s/[\,\s]+/\|/g;
    $gi    = $elementInfo[0];
    if ($qryType eq "GI") {
      $elementInfo[0]=~s/^($highlight)(\.\d+)*$/\<FONT style\=\"BACKGROUND-COLOR\: yellow\"\>$1\<\/FONT\>/gi;  # gi
      $elementInfo[1]=~s/^($highlight)(\.\d+)*$/\<FONT style\=\"BACKGROUND-COLOR\: yellow\"\>$1\<\/FONT\>/gi;  # acc
    }
    elsif($qryType eq "TEXT") {
      $desc=~s/($highlight)/\<FONT style\=\"BACKGROUND-COLOR\: yellow\"\>$1\<\/FONT\>/gi;  # gi
    }

    $modelCELL = ""; # Initialize it so Apache stops complaining.
    $checkboxName = $gi."|".$elementInfo[2]."|".$elementInfo[6]."|".$elementInfo[7];

    my ($dbid, $chr, $l_pos, $r_pos);
#    $modelCELL = ($align eq "")?"No alignment to the genome":"<a href=\"findRegion.pl?id=$gi\" target=\"findRegion:gi\"><img src=\"singleSEQ.cgi?color=$color&align=$align\"></a>";
    if ($align eq "") {
      $modelCELL = "No alignment to the genome";
    }
    elsif ($GENOME_TYPE eq "CHR-Based") {
      ($dbid, $chr, $l_pos, $r_pos) = ($#DBver, $elementInfo[2], ($elementInfo[6]-500), ($elementInfo[7]+500));
      $modelCELL    = "<a title=\"View genome context for this sequence\" href=\"getRegion.pl?dbid=$dbid;chr=$chr;l_pos=$l_pos;r_pos=$r_pos\" target=\"findRegion:$gi\"><img src=\"singleSEQ.cgi?color=$color&align=$align\"></a>";
    }
    else {
      ($dbid, $chr, $l_pos, $r_pos) = ($#DBver, $elementInfo[2], ($elementInfo[6]-500), ($elementInfo[7]+500));
      $modelCELL    = "<a title=\"View genome context for this sequence\" href=\"getGSEG_Region.pl?dbid=$dbid;gseg_gi=$chr;bac_lpos=$l_pos;bac_rpos=$r_pos\" target=\"findRegion:$gi\"><img src=\"singleSEQ.cgi?color=$color&align=$align\"></a>";
    }

    $line_1 = "<td>$elementInfo[2]</td><td>$elementInfo[4]</td><td>$elementInfo[6]</td><td rowspan=2>$modelCELL</td>";
    $line_2 = "<td>$elementInfo[1]</td><td>$elementInfo[3]</td><td>$elementInfo[5]</td><td>$elementInfo[7]</td>";
    $line_3 = "<td colspan=5>$desc</td>";
  }
# select a.id, a.acc, c.gi, b.G_O, SCAF_lpos, SCAF_rpos, a.description 
  elsif ($DSOname eq "GSEG") {
    $desc  = pop(@elementInfo);
    my $rpos = pop(@elementInfo);
    my $lpos = pop(@elementInfo);
    $align = $lpos."|".$rpos;
    $gi    = $elementInfo[0];
    if ($qryType eq "GI") {
      $elementInfo[0]=~s/^($highlight)(\.\d+)*$/\<FONT style\=\"BACKGROUND-COLOR\: yellow\"\>$1\<\/FONT\>/gi;  # gi
      $elementInfo[1]=~s/^($highlight)(\.\d+)*$/\<FONT style\=\"BACKGROUND-COLOR\: yellow\"\>$1\<\/FONT\>/gi;  # acc
    }
    elsif($qryType eq "TEXT") {
      $desc=~s/($highlight)/\<FONT style\=\"BACKGROUND-COLOR\: yellow\"\>$1\<\/FONT\>/gi;  # gi
    }

    $checkboxName = $gi."|".$elementInfo[2]."|".$lpos."|".$rpos;
    $modelCELL = ""; # Initialize it so Apache stops complaining.
#    $modelCELL = ($rpos eq "")?"No alignment to the genome":"<a href=\"findRegion.pl?id=$gi\" target=\"findRegion:gi\"><img src=\"singleSEQ.cgi?color=$color&align=$align\"></a>";
    my ($dbid, $chr, $l_pos, $r_pos);
    if ($rpos eq "") {
      $modelCELL = "No alignment to the genome";
    }
    elsif ($GENOME_TYPE eq "CHR-Based") {
      ($dbid, $chr, $l_pos, $r_pos) = ($#DBver, $elementInfo[2], ($lpos-500), ($rpos+500));
      $modelCELL    = "<a title=\"View genome context for this sequence\" href=\"getRegion.pl?dbid=$dbid;chr=$chr;l_pos=$l_pos;r_pos=$r_pos\" target=\"findRegion:$gi\"><img src=\"singleSEQ.cgi?color=$color&align=$align\"></a>";
    }
    else {
      ($dbid, $chr, $l_pos, $r_pos) = ($#DBver, $elementInfo[2], ($lpos-500), ($rpos+500));
      $modelCELL    = "<a title=\"View genome context for this sequence\" href=\"getGSEG_Region.pl?dbid=$dbid;gseg_gi=$chr;bac_lpos=$l_pos;bac_rpos=$r_pos\" target=\"findRegion:$gi\"><img src=\"singleSEQ.cgi?color=$color&align=$align\"></a>";
    }

    $line_1 = "<td>$elementInfo[2]</td><td></td><td>$lpos</td><td rowspan=2>$modelCELL</td>";
    $line_2 = "<td>$elementInfo[1]</td><td>$elementInfo[3]</td><td></td><td>$rpos</td>";
    $line_3 = "<td colspan=5>$desc</td>";
  }
  else {
  }

  my $recLine = "value=".$checkboxName." align=".$align." trackIndex=".$trackIndex." CDSstart=".$CDSstart." CDSstop=".$CDSstop."\n";
  my $tbLine  = "
  <tr align='center'>
    <td rowspan='3'>".$inputType."</td>
    <td rowspan='3'><input type='checkbox' value=".$checkboxName." name=\"CheckAll\"></td>
    <td><a title=\"Display genome record page for this sequence\" href=\"findRecord.pl?id=".$gi."\" target=\"findRecord:".$gi."\">".$elementInfo[0]."</a></td>
    ".$line_1."
  </tr>
  <tr align='center'>
    ".$line_2."
  </tr>
  <tr>
    ".$line_3."
  </tr>
";
  return($tbLine, $recLine);
}

#===========================================================
# CHECK TEXT STRING SECTION
#===========================================================
sub getMySQLString {
  my $trackIndex = shift;
  my @sqlReturn  = @_;
  my $string;
  my $DSOname   = ${$DBver[$#DBver]->{tracks}}[$trackIndex]->{DSOname};
  if (($DSOname eq "GBKann")||($DSOname eq "GBKgaeval")||($DSOname eq "TIGRtu")||($DSOname eq "TIGRgaeval")||($DSOname eq "UCAann")) {
    $string = $sqlReturn[$#sqlReturn-3]." ".$sqlReturn[$#sqlReturn-2];
  }
  elsif (($DSOname eq "CDNApgs")||($DSOname eq "ESTpgs")||($DSOname eq "PEPpgs")||($DSOname eq "PROBE")||($DSOname eq "GSEG")) {
    $string = $sqlReturn[$#sqlReturn];
  }
  else {
    $string = join(" ", @sqlReturn);
  }
  return $string;
}
#===========================================================
# RETURN LOCUS SEARCH KEY & VALUES SECTION
#===========================================================
sub locusKeyAndValue {
  my $trackIndex = shift;
  my @sqlReturn  = @_;
  my $DSOname    = ${$DBver[$#DBver]->{tracks}}[$trackIndex]->{DSOname};
  my ($grpKey, $locusStart, $locusEnd);
  if (($DSOname eq "GBKann")||($DSOname eq "GBKgaeval")||($DSOname eq "TIGRtu")||($DSOname eq "TIGRgaeval")||($DSOname eq "UCAann")) {
    $grpKey = ($sqlReturn[2] eq "f")?($sqlReturn[1]."|+"):($sqlReturn[1]."|-");
    ($locusStart, $locusEnd) = ($sqlReturn[3], $sqlReturn[4]);
  }
  elsif (($DSOname eq "CDNApgs")||($DSOname eq "ESTpgs")||($DSOname eq "PEPpgs")||($DSOname eq "PROBE")) {
    $grpKey = $sqlReturn[2]."|".$sqlReturn[3];
    ($locusStart, $locusEnd) = ($sqlReturn[6], $sqlReturn[7]);
  }
  elsif ($DSOname eq "GSEG") {
    $grpKey = $sqlReturn[2]."|".$sqlReturn[3];
    ($locusStart, $locusEnd) = ($sqlReturn[4], $sqlReturn[5]);
  }
  else {
  }
  return ($grpKey, $locusStart, $locusEnd);
}
#===========================================================
# RETURN GI_ID SECTION
#===========================================================
sub recordID {
  my $trackIndex = shift;
  my @sqlReturn  = @_;
  my $DSOname    = ${$DBver[$#DBver]->{tracks}}[$trackIndex]->{DSOname};
  if (($DSOname eq "CDNApgs")||($DSOname eq "ESTpgs")||($DSOname eq "GSEG")) {
    return($sqlReturn[0], $sqlReturn[1]);
  }
  else {
    return($sqlReturn[0]);
  }
}
1;
#===========================================================
sub simpleName {
  my $input  = shift;
  my $prefix = $SITENAMEshort;
     $prefix =~s/GDB$//;
  my $output;
  if ($input=~/^$prefix\-/) {
    $output = $';
  } 
  elsif ($input eq "yrGATE Annotations") {
    $output = "yrGATE";
  }
  else {
    $output = $input;
  }
  $output =~s/\s+/\_/g;
  return $output;
}
