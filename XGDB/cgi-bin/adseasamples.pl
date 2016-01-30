#!/usr/bin/perl -w

# Ver1.0
# By Hong Lu @ 2008-06-06
# Email: luhong@iastate.edu
# Description: 
#   This program will load SITEDEF.pl information and enter MySQL database, such as ATGDB164
#   By the order in SITEDEF(trackORD), output sample's id.

use GSQDB;
use GDBgui;
use CGI ":all";
use DBI;
use PLGDB;
use TRACK;

do 'SITEDEF.pl';

my $GDBpage = new GDBgui();

my $PAGE = "<table border><tr><th colspan=3>$LATINORGN Sample Input</th></tr>";
### SAMPLES BEGIN
my $dbh   = DBI->connect("DBI:mysql:$DBver[$#DBver]->{DB}:$DB_HOST", $DB_USER, $DB_PASSWORD);
my $GENOME_TYPE = (defined $DBver[$#DBver]->{genomeST})?("CHR-Based"):("BAC-Based");
my $trackORD    = $DBver[$#DBver]->{trackORD};
my @trackBLK    = split(/\,/,$trackORD);

my %DEFAULT_DSO = TRACK::DEFAULT_DSO_TABLE();

my $sth;
for (my $i=0; $i<=$#trackBLK; $i++) {
  my $DSOname   = ${$DBver[$#DBver]->{tracks}}[$trackBLK[$i]]->{DSOname};
  my $trackname = ${$DBver[$#DBver]->{tracks}}[$trackBLK[$i]]->{trackname};
  my $db_table  = (defined ${$DBver[$#DBver]->{tracks}}[$trackBLK[$i]]->{db_table})?${$DBver[$#DBver]->{tracks}}[$trackBLK[$i]]->{db_table}:$DEFAULT_DSO{${$DBver[$#DBver]->{tracks}}[$trackBLK[$i]]->{DSOname}};
  my $bgcolor   = ${$DBver[$#DBver]->{tracks}}[$trackBLK[$i]]->{primaryColor};
  # Filter
  if ((${$DBver[$#DBver]->{tracks}}[$trackBLK[$i]]->{chrVIEWABLE} ne "1")&&($GENOME_TYPE eq "CHR-Based")) {
    next;
  }
  if ((${$DBver[$#DBver]->{tracks}}[$trackBLK[$i]]->{BACVIEWABLE} ne "1")&&($GENOME_TYPE eq "BAC-Based")) {
    next;
  }
  if ($DSOname eq "UCAann") {
    next;
  }
  # CHR-Based
  if (($GENOME_TYPE eq "CHR-Based")&&($DSOname eq "CDNApgs")) {
    $select_part = "select DISTINCT a.gi, acc from $db_table a left join ${db_table}_good_pgs b on a.gi=b.gi where chr is not NULL limit 0,2;";
  }
  elsif (($GENOME_TYPE eq "CHR-Based")&&($DSOname eq "ESTpgs")) {
    $select_part = "select DISTINCT a.gi, acc from $db_table a left join ${db_table}_good_pgs b on a.gi=b.gi where chr is not NULL limit 0,2;";
  }
  elsif (($GENOME_TYPE eq "CHR-Based")&&($DSOname eq "PEPpgs")) {
    $select_part = "select DISTINCT a.gi from $db_table a left join ${db_table}_good_pgs b on a.gi=b.gi where chr is not NULL limit 0,2;";
  }
  elsif (($GENOME_TYPE eq "CHR-Based")&&($DSOname eq "PROBE")) {
    $select_part = "select DISTINCT a.gi from $db_table a left join ${db_table}_good_pgs b on a.gi=b.gi where chr is not NULL limit 0,2;";
  }
  elsif (($GENOME_TYPE eq "CHR-Based")&&($DSOname eq "GBKann")) {
    $db_table = "chr_".$db_table;
    $select_part = "select DISTINCT geneId from $db_table where chr is not NULL limit 0,2;";
  }
  elsif (($GENOME_TYPE eq "CHR-Based")&&($DSOname eq "GBKgaeval")) {
    $db_table = "chr_".$db_table;
    $select_part = "select DISTINCT geneId from $db_table where chr is not NULL limit 0,2;";
  }
  elsif (($GENOME_TYPE eq "CHR-Based")&&($DSOname eq "TIGRtu")) {
    $select_part = "select DISTINCT geneId from $db_table where chr is not NULL limit 0,2;";
  }
  elsif (($GENOME_TYPE eq "CHR-Based")&&($DSOname eq "TIGRgaeval")) {
    $select_part = "select DISTINCT geneId from $db_table where chr is not NULL limit 0,2;";
  }
  # BAC-Based
  elsif (($GENOME_TYPE eq "BAC-Based")&&($DSOname eq "CDNApgs")) {
    $select_part = "select DISTINCT a.gi, acc from $db_table a left join gseg_${db_table}_good_pgs b on a.gi=b.gi left join gseg_type c on b.gseg_gi=c.gi where c.type!='replaced' limit 0,2;";
  }
  elsif (($GENOME_TYPE eq "BAC-Based")&&($DSOname eq "ESTpgs")) {
    $select_part = "select DISTINCT a.gi, acc from $db_table a left join gseg_${db_table}_good_pgs b on a.gi=b.gi left join gseg_type c on b.gseg_gi=c.gi where c.type!='replaced' limit 0,2;";
  }
  elsif (($GENOME_TYPE eq "BAC-Based")&&($DSOname eq "PEPpgs")) {
    $select_part = "select DISTINCT a.gi, acc from $db_table a left join gseg_${db_table}_good_pgs b on a.gi=b.gi left join gseg_type c on b.gseg_gi=c.gi where c.type!='replaced' limit 0,2;";
  }
  elsif (($GENOME_TYPE eq "BAC-Based")&&($DSOname eq "PROBE")) {
    $select_part = "select DISTINCT a.gi, acc from $db_table a left join gseg_${db_table}_good_pgs b on a.gi=b.gi left join gseg_type c on b.gseg_gi=c.gi where c.type!='replaced' limit 0,2;";
  }
  elsif (($GENOME_TYPE eq "BAC-Based")&&($DSOname eq "GSEG")) {
    $select_part = "select DISTINCT a.id, a.acc from $db_table a left join gseg_$db_table b on a.uid=b.FRAG_uid left join gseg c on b.SCAF_uid=c.uid left join gseg_type d on c.gi=d.gi where d.type!='replaced' and SCAF_lpos is not NULL limit 0,2;";
  }
  elsif (($GENOME_TYPE eq "BAC-Based")&&($DSOname eq "GBKann")) {
    $db_table = "gseg_".$db_table;
    $select_part = "select DISTINCT geneId from $db_table a left join gseg_type b on a.gseg_gi=b.gi where b.type!='replaced' limit 0,2;";
  }
  elsif (($GENOME_TYPE eq "BAC-Based")&&($DSOname eq "GBKgaeval")) {
    $db_table = "gseg_".$db_table;
    $select_part = "select DISTINCT geneId from $db_table a left join gseg_type b on a.gseg_gi=b.gi where b.type!='replaced' limit 0,2;";
  }
  elsif (($GENOME_TYPE eq "BAC-Based")&&($DSOname eq "TIGRtu")) {
    $select_part = "select DISTINCT geneId from $db_table a left join gseg_type b on a.gseg_gi=b.gi where b.type!='replaced' limit 0,2;";
  }
  elsif (($GENOME_TYPE eq "BAC-Based")&&($DSOname eq "TIGRgaeval")) {
    $select_part = "select DISTINCT geneId from $db_table a left join gseg_type b on a.gseg_gi=b.gi where b.type!='replaced' limit 0,2;";
  }
  else {
  }
  $sth = $dbh->prepare($select_part);
  $sth->execute();

  my @GI  = ();
  my @ACC = ();
  while (@tmpARY = $sth->fetchrow_array()) {
    if ($#tmpARY eq "0") {
      push(@GI, $tmpARY[0]);
    }
    else {
      push(@GI,  $tmpARY[0]);
      push(@ACC, $tmpARY[1]);
    }
  }
  if (($DSOname eq "CDNApgs")||($DSOname eq "ESTpgs")||($DSOname eq "GSEG")) {
    $PAGE .="<tr><th rowspan=2 bgcolor=$bgcolor><font color=white>".PLGDB::simpleName($trackname)."</font></th><th bgcolor=$bgcolor><font color=white>GI</font></th><td align=center>".join("<br>", @GI)."</td></tr>";
    $PAGE .="<tr><th bgcolor=$bgcolor><font color=white>ACC</font></th><td align=center>".join("<br>", @ACC)."</td></tr>";
  }
  else {
    $PAGE .="<tr><th colspan=2 bgcolor=$bgcolor><font color=white>".PLGDB::simpleName($trackname)."</font></th><td align=center>".join("<br>", @GI)."</td></tr>";
  }
  $sth->finish();
}
$dbh->disconnect();

$PAGE .= "<tr><th colspan=2>Text Description</th><td align=center>\"ankyrin repeat domains\"<br>\"unknown protein\"<br>\"Leucine Rich Repeat\"<br>\"kinase domain\"</td></tr>";
$PAGE .= "</table>";
### SAMPLES END
$cgi_paramHR->{headHR}    = {-cookie=>[$sCookie]};
$cgi_paramHR->{htmlHR}    = {-title=>"${SITENAMEshort} Query:$cgi_paramHR->{searchSTR}",
                             -script=>[{-src=>"${JSPATH}SRview.js"}]
                            };
$cgi_paramHR->{main}      = $PAGE;


$GDBpage->printXGDB_page($cgi_paramHR);

