#!/usr/bin/perl

use CGI ":all";
use GSQDB;
use GDBgui;
use PLGDB;
use TRACK;
use DBI;

do 'SITEDEF.pl';
do 'getPARAM.pl';

my $GDBpage = new GDBgui();

my $PAGE;

my $GENOME_TYPE = (defined $DBver[$#DBver]->{genomeST})?("CHR-Based"):("BAC-Based");
if((param('idSUB') eq 'Search')&&(param('BatchFile') || param('BatchText'))){
  #########################################
  ## create page using identifier search ##
  #########################################
  my $BatchText;
  my $link_to_this_page = "idSUB=Search";
  my $db = new GSQDB($cgi_paramHR);

  if($BatchFile = param('BatchFile')){
    while(<$BatchFile>){
      $BatchText .= $_;
    }
  }
  if(param('BatchText')){$BatchText = param('BatchText');}
  my $tmpBatchText = $BatchText;
  $tmpBatchText =~s/\n/%7c%7c%7c/g;
  $tmpBatchText =~s/\s/%20/g;
  $tmpBatchText =~s/\"/%22/g;
  $tmpBatchText =~s/\,/%2c/g;
  $tmpBatchText =~s/\;/%3b/g;
  $tmpBatchText =~s/\|/%7c/g;
  $link_to_this_page .= "&BatchText=$tmpBatchText";

  @qWords = split(/[\s,]+/,$BatchText);

  if(param('SeqOnly') ne "ON") {
    $link_to_this_page .= "&SeqOnly=OFF";
    my $MAX_GI_ONLY  = 300;
    my $MAX_GI_LOCUS = 30;
  # Hong's function
    my ($textInput, $giInput, $gi_num) = PLGDB::InputAnalysis($BatchText);
    if(scalar(@qWords) == 0){
      $PAGE = "<h2>You must enter an Identifier or a Keyword upon which to search</h2>\n";
    }
    elsif (($textInput=~/^\s*$/)&&($giInput=~/^[\s\,\;]*$/)) {
      $PAGE = "<h2>You must enter an Identifier or a Keyword upon which to search</h2>\n";
    }
    elsif (($gi_num > $MAX_GI_ONLY)||(($gi_num > $MAX_GI_LOCUS)&&(param('overlapSEQ') eq "ON"))) {
      $PAGE  = "<h2>You may enter at most $MAX_GI_ONLY  Identifiers or Keywords upon which to search</h2>\n";
      $PAGE .= "<h2>$MAX_GI_LOCUS at most with option \"Return all sequences that overlap query sequence coordinates\"</h2>\n";
    } else {
      # Load parameters
      my $trackORD = $DBver[$#DBver]->{trackORD};
      my @trackBLK = split(/\,/,$trackORD);
      my @trackSEL = ();
      for (my $i=0; $i<=$#trackBLK; $i++) {
        my $DSOname   = ${$DBver[$#DBver]->{tracks}}[$trackBLK[$i]]->{DSOname};
        my $trackname = ${$DBver[$#DBver]->{tracks}}[$trackBLK[$i]]->{trackname};
        if ((${$DBver[$#DBver]->{tracks}}[$trackBLK[$i]]->{chrVIEWABLE} ne "1")&&($GENOME_TYPE eq "CHR-Based")) {
          next;
        }
        if ((${$DBver[$#DBver]->{tracks}}[$trackBLK[$i]]->{BACVIEWABLE} ne "1")&&($GENOME_TYPE eq "BAC-Based")) {
          next;
        }
        if ($DSOname eq "DAS") {
          next;
        }
        my $tmpName = "track$trackBLK[$i]";
        if ((param($tmpName) eq "ON")||(param($tmpName) eq "on")) {
          push(@trackSEL, $trackBLK[$i]);
          $link_to_this_page .= "&$tmpName=ON";
        }
      }

      my $dbTBParam  = join("|",@trackSEL);
      my $searchType = (param('overlapSEQ') eq "ON")?"0":"1";
      $link_to_this_page = (param('overlapSEQ') eq "ON")?($link_to_this_page."&overlapSEQ=ON"):($link_to_this_page."&overlapSEQ=OFF");
      $PAGE = "<table width=\"98%\"><tr valign=\"top\"><td>";
      $PAGE .= "<div class=\"description showhide topmargin1\">
      <p title=\"Show additional genome information directly below this link\" class=\"label largerfont\" style=\"cursor:pointer\">Filter search results:</p>
        <div class=\"more_hidden hidden\">
        <span class=\"heading\">Click button(s) to hide one or more types, e.g. <i>Hide EST</i></span><br \><br \>";
      $PAGE.= TRACK::hideButton($dbTBParam);
      $PAGE.="</div></div></td>";

      $PAGE .= "<td><nobr><h3 align=right><a href=\"$CGIPATHs/search.pl?$link_to_this_page\" right=\"\"><span class=\"heading\">Link to this Results Page</span></a></h3></nobr></td></tr></table>";

      my $qryAlignGI;    my $qryLostGI;    my $qryTmpGI;
      my $qryAlignText;  my $qryLostText;  my $qryTmpText;

      my $date = `date`;
         $date =~s/\s+/\_/g;
         $date =~s/\://g;
      my $rand = int(rand(1000000000));
      my $randFile = $date.$rand;

      $PAGE .= "\n<table id=\"optionsTable\" width=\"98%\">\n  <tr>\n    <td>";
      $PAGE .= "<div class=\"description  showhide topmargin1\"><p title=\"Show additional genome information directly below this link\" class=\"label largerfont\" style=\"cursor:pointer\">Retrieve Sequences:</p>
        <div class=\"more_hidden hidden\">";
      $PAGE .= TRACK::SeqRetrButton($randFile);

      $PAGE .= "<td>
      </td></tr></table>";


      # Gi search
      unless ($giInput=~/^[\s\,\;]*$/){
        ($qryAlignGI,   $qryLostGI,   $qryTmpGI)   = PLGDB::qryDBbyGI($dbTBParam,$giInput, $searchType);
      }
      # Text search
      unless ($textInput=~/^\s*$/) {
        ($qryAlignText, $qryLostText, $qryTmpText) = PLGDB::qryDBbyText($dbTBParam,$textInput, $searchType); 
      }

      # Print tmp alignment file
      open(OUT,">$TMPDIR/$randFile")||die ":$!";
      print OUT $qryTmpGI.$qryTmpText;
      close(OUT)||die ":$!";

      $PAGE .= "\n<table border=\"1\" width=\"98%\" id=\"alignTable\">$qryAlignGI$qryAlignText</table>\n";
      $PAGE .= "\n<table id=\"optionsTable\" width=\"98%\">\n  <tr>\n    <td>";
#      $PAGE .= TRACK::SeqRetrButton($randFile);
      if (($qryLostGI eq "")&&($qryLostText eq "")) {
        $PAGE .= "    </td>\n    <td align=\"left\" valign=\"top\"><br /><b>Query Sequences Not Found:</b><br />None\n    </td>\n  </tr>\n</table>";
      } else {
        $PAGE .= "    </td>\n    <td align=\"left\" valign=\"top\"><br /><b>Query Sequences Not Found:</b><br />$qryLostGI$qryLostText\n    </td>\n  </tr>\n</table>";
      }
    }
  } else {
  # Shannon's function
    if(($BatchText =~ /^[~<>+-]/)||($BatchText =~ /\s[~<>+-]/)||($BatchText =~ /\w\*\s/)||($BatchText =~ /[\")(]/)){
      print STDERR "[search.pl] Shortcutting to the Description Search";
      goto DESC_SEARCH;
    }

    if(scalar(@qWords) == 0){
      $PAGE = "<h2>You must enter an Identifier or a Keyword upon which to search</h2>\n";
    } 
    elsif(scalar(@qWords) == 1){
      ($resid,$UIDtype,$uid) = $db->findRECORD({gi=>$qWords[0]});
      if(defined($resid)){
        print redirect("${CGIDIR}getRecord.pl?dbid=$cgi_paramHR->{dbid}&resid=${resid}&${UIDtype}=${uid}");
        exit 1;
      } else{
        goto DESC_SEARCH;
      }
    } else{
      ($chrHitCNT,$gsegHitCNT) = $db->search_by_MULTIID(\@qWords);
      if($chrHitCNT){
        ($lociMAP,$lociTABLE) = $db->showMULTILOCUS();
        $PAGE = "<br /><br /><br />$lociMAP <br /><br /> $lociTABLE <br />";
      }
      elsif(!defined($lociMAP)){      
        DESC_SEARCH:
        ($chrHitCNT,$gsegHitCNT) = $db->search_by_Desc(\@qWords);
        if($chrHitCNT){
          ($lociMAP,$lociTABLE) = $db->showMULTILOCUS();
          $PAGE_CONTENTS = "<br /><h2>Features found using <span style=\"color:green;\">" . join(' ',@qWords) . "</span></h2><br /><br />$lociMAP <br /><br /> $lociTABLE <br />";
        } else{
          $PAGE_CONTENTS = "<br /><h2>No results were found using <span style=\"color:green;\">" . join(' ',@qWords) . "</span></h2>";
        }
      }
    }
  }
}else{
  #########################
  # create query page     #
  #########################
  # track index
  my $trackStr;
  my $trackORD = $DBver[$#DBver]->{trackORD};
  my @trackBLK = split(/\,/,$trackORD);

  # SAMPLE PAGE
  my $PAGE_SAMPLE = "  <div class=\"showhide topmargin1 indent1\" >
      &nbsp;&nbsp;&nbsp;&nbsp;<p class=\"label\" style=\"cursor:pointer\">Sample Input <span class=\"heading\">(Click to view...)</span> </p>
      <div class=\"news_hidden hidden bottommargin1\">
      <p>Below are valid classes and identifiers for $xGDB. Copy an ID and use it for a test search.</p>
  <table class=\"SampleTable\" border=\"1\"><tr><th colspan=\"3\">$LATINORGN Sample Input</th></tr>";
  my $dbh   = DBI->connect("DBI:mysql:$DBver[$#DBver]->{DB}:$DB_HOST", $DB_USER, $DB_PASSWORD);
  my $sth;

  for (my $i=0; $i<=$#trackBLK; $i++) {
    my $DSOname   = ${$DBver[$#DBver]->{tracks}}[$trackBLK[$i]]->{DSOname};
    my $trackname = ${$DBver[$#DBver]->{tracks}}[$trackBLK[$i]]->{trackname};

    my $bgcolor   = ${$DBver[$#DBver]->{tracks}}[$trackBLK[$i]]->{primaryColor};
    
    if ((${$DBver[$#DBver]->{tracks}}[$trackBLK[$i]]->{chrVIEWABLE} ne "1")&&($GENOME_TYPE eq "CHR-Based")) {
      next;
    }
    if ((${$DBver[$#DBver]->{tracks}}[$trackBLK[$i]]->{BACVIEWABLE} ne "1")&&($GENOME_TYPE eq "BAC-Based")) {
      next;
    }
    if ($DSOname eq "DAS") {
      next;
    }

    # Checkbox

    $trackStr .= "<span class=\"trackCheck\" style=\"background:".$bgcolor."\"><input type=\"checkbox\" name=\"track$trackBLK[$i]\" checked=\"checked\" />&nbsp;".TRACK::simpleName($trackname)."</span><br />\n";
    # Sample
    if ((defined ${$DBver[$#DBver]->{tracks}}[$trackBLK[$i]]->{DB})||(defined ${$DBver[$#DBver]->{tracks}}[$trackBLK[$i]]->{DBhost})||(defined ${$DBver[$#DBver]->{tracks}}[$trackBLK[$i]]->{DBuser})||(defined ${$DBver[$#DBver]->{tracks}}[$trackBLK[$i]]->{DBpass})) {
      $dbh->disconnect();
      my ($tmp_db, $DBhost, $DBuser, $DBpass);
      $tmp_db = ${$DBver[$#DBver]->{tracks}}[$trackBLK[$i]]->{DB};
      $DBhost  = (defined ${$DBver[$#DBver]->{tracks}}[$trackBLK[$i]]->{DBhost})?(${$DBver[$#DBver]->{tracks}}[$trackBLK[$i]]->{DBhost}):$DB_HOST;
      $DBuser  = (defined ${$DBver[$#DBver]->{tracks}}[$trackBLK[$i]]->{DBuser})?(${$DBver[$#DBver]->{tracks}}[$trackBLK[$i]]->{DBuser}):$DB_USER;
      $DBpass  = (defined ${$DBver[$#DBver]->{tracks}}[$trackBLK[$i]]->{DBpass})?(${$DBver[$#DBver]->{tracks}}[$trackBLK[$i]]->{DBpass}):$DB_PASSWORD;
      $dbh   = DBI->connect("DBI:mysql:$tmp_db:$DBhost", $DBuser, $DBpass);
    }
    my $select_part = TRACK::QRY_SAMPLE($trackBLK[$i]);
    $sth = $dbh->prepare($select_part);
    $sth->execute();
    my @GI  = ();
    my @ACC = ();
    while (@tmpARY = $sth->fetchrow_array()) {
      if ($#tmpARY eq "0") {
        push(@GI, $tmpARY[0]);
      } else {
        push(@GI,  $tmpARY[0]);
        push(@ACC, $tmpARY[1]);
      }
    }
    if (($DSOname eq "CDNApgs")||($DSOname eq "ESTpgs")||($DSOname eq "GSEG")) {
      if (($ACC[0] eq "")&&($ACC[1] eq "")) {
        $PAGE_SAMPLE .="<tr><th bgcolor=\"$bgcolor\"><font style=\"color:white\">".TRACK::simpleName($trackname)."</font></th><th bgcolor=\"$bgcolor\"><font style=\"color:white\">GI</font></th><td align=\"center\">".join("<br />", @GI)."</td></tr>";
      } else {
        $PAGE_SAMPLE .="<tr><th rowspan=\"2\" bgcolor=\"$bgcolor\"><font style=\"color:white\">".TRACK::simpleName($trackname)."</font></th><th bgcolor=\"$bgcolor\"><font style=\"color:white\">GI</font></th><td align=\"center\">".join("<br />", @GI)."</td></tr>";
        $PAGE_SAMPLE .="<tr><th bgcolor=\"$bgcolor\"><font style=\"color:white\">ACC</font></th><td align=\"center\">".join("<br />", @ACC)."</td></tr>";
      }
    } else {
      $PAGE_SAMPLE .="<tr><th colspan=\"2\" bgcolor=\"$bgcolor\"><font style=\"color:white\">".TRACK::simpleName($trackname)."</font></th><td align=\"center\">".join("<br />", @GI)."</td></tr>";
    }
    $sth->finish();
    # Return to Default
    if ((defined ${$DBver[$#DBver]->{tracks}}[$trackBLK[$i]]->{DB})||(defined ${$DBver[$#DBver]->{tracks}}[$trackBLK[$i]]->{DBhost})||(defined ${$DBver[$#DBver]->{tracks}}[$trackBLK[$i]]->{DBuser})||(defined ${$DBver[$#DBver]->{tracks}}[$trackBLK[$i]]->{DBpass})) {
      $dbh->disconnect();
      $dbh = DBI->connect("DBI:mysql:$DBver[$#DBver]->{DB}:$DB_HOST", $DB_USER, $DB_PASSWORD);
    }
  }
  $dbh->disconnect();
  $PAGE_SAMPLE .= "<tr><th colspan=\"2\">Text Description</th><td align=\"center\">\"your search term(s) in quotes\"</td></tr>";
  $PAGE_SAMPLE .= "</table></div></div>";

  # Print
  my $examples = (defined($EXAMPLE_SEARCH_IDS))?$EXAMPLE_SEARCH_IDS:"GI_number Accession Locus";
  $PAGE = "<h1 class=\"bottommargin1\">Search ".$xGDB." <img id='genome_advancedsearch' title='Advanced Search Help' class='xgdb-help-button' src='/XGDB/images/help-icon.png' alt='?' />
<span class=\"heading\"> &nbsp; Batch retrieval of aligned sequences or gene models; optionally download flanking genomic sequence. </span></h1>"; # Title
  $PAGE .=<<BORDER_TABLE;
<table id="searchTable" width="95%">
  <tr>
    <td valign="top">
BORDER_TABLE

  $trackStr .= "<input type=\"button\" name=\"CheckTrack\" id=\"CheckTrackControl\" onclick=\"checkTrack('".$trackORD."')\" value=\"Uncheck ALL\"/>\n";
  $PAGE .= table({-class=>'searchTable',-align=>'center',-border=>'0',-width=>'100%'},
      Tr({-valign=>'top'},
         td({-align=>'left',-valign=>'top'},
           '<h2>Enter Query Terms: </h2>
           <div class="description showhide">
           <p style="cursor: pointer"><span class="heading">(Click for examples...)</span></p>
			   <div class="hidden">
				   <p>
				   <b>Text search:</b> "phospholipase C" (use quotes)<br />
				   <b>Multiple query items:</b> Separate items with a space (for boolean AND), or line feed (for boolean OR)<br />
				   <b>Wild card:</b> use % or * . <b>Examples:</b> AC%035 or AC*035 <br />
				   <b>Single-character wild card:</b> use (.) or (_). Examples: AC3(.)035 or AC3(_)035 <br />
				   <span class="heading">See also comprehensive data type examples below - click on  <i>Sample Input</i></span>
				    </p>
			   </div>
           </div>')),
         Tr({-valign=>'top'},
           td(textarea(-name=>'BatchText', -class=>'DataEntry', -rows=>4,-cols=>70,-wrap=>'virtual') . br . br .
           
           strong("Or upload a list: ") .
           filefield(-name=>'BatchFile',-size=>30)
        )
      ),
      Tr({-valign=>'top'},
         td({-align=>'left',-valign=>'top', -class=>'bold'},'Initiate search:',
           submit(-name=>'idSUB',-value=>'Search') 
         )
      ),
      Tr({-valign=>'top'},
         td({-align=>'left',-valign=>'top'},
'<div class="description showhide"><p style="cursor: pointer;" class="label">...Or limit search scope <span class="heading">(Click for options...)</span> </p><div class="hidden">', '<b>De-select unneeded data types:</b> <br />', $trackStr ,'</div></div>'        )
      ),
      Tr({-valign=>'top'},
         td({-align=>'left',-valign=>'top'},'<h2>Retrieval options:</h2><br />',
           checkbox('overlapSEQ',0,'ON',' Return all sequences that overlap query sequence coordinates'),
         )
      ),      Tr({-valign=>'top'},
         td({-align=>'left',-valign=>'top'},
           checkbox('SeqOnly',0,'ON',' Retrieve Sequence Record (NOTE: Single Query ID Only)'),
         )
      ),
      
    );

  $PAGE .=$PAGE_SAMPLE;
  
  $PAGE .=<<BORDER_TABLE;
    </td>
  </tr>
</table>
BORDER_TABLE


  $PAGE .=<<BORDER_TABLE;

    </div><!--end of hidden div-->
        </div><!--end showhide div-->
BORDER_TABLE
}

$cgi_paramHR->{headHR}    = {-cookie=>[$sCookie]};
$cgi_paramHR->{htmlHR}    = {-title=>"${SITENAMEshort} Query:$cgi_paramHR->{searchSTR}",
                             -script=>[{-src=>"${JSPATH}SRview.js"}]
                            };
$cgi_paramHR->{main}      = $PAGE;


$GDBpage->printXGDB_page($cgi_paramHR);

