#!/usr/bin/perl
# watch-gs.cgi
# Last update: October 23, 2002 (VB)
# Last update: Feb 10,2003 (Dong). 1. replace all the old deepc2 path into PlantGDB path; 2. rename it to PlantGDBwatch-gs.cgi
# Last update: May 6, 2003 (VB): added "egrep -v" filter to pull out non-functional links

use CGI qw/:standard :html escapeHTML sub/;
do 'sitedef.pl';
#my $PLANTGDB_CGIDIR="/DATA/SANDBOX/annfu/PlantGDB/cgi-bin/";
my $TmpDir = $PLANTGDB_TMPDIR;
my $ufname = param('ufname');
my $rrate  = param('rrate');
my $t = localtime();

if ( !(-e "${TmpDir}tmp-$ufname/running-gs-$ufname")  &&
      (-e "${TmpDir}tmp-$ufname/gs_sorted-output-${ufname}.html")) {
  print ("Location:$SERVER${PLANTGDB_WEBROOTURL}tmp/PlantGDB/tmp-$ufname/gs_sorted-output-$ufname"."_top.html\n\n");
  exit;
}
print header(-Refresh=>"$rrate;URL= ${PLANTGDB_WEBCGIURL}GeneSeqer/PlantGDBwatch-gs.cgi?ufname=$ufname&rrate=$rrate");
print start_html("GeneSeqer Output");

system("${PLANTGDB_CGIDIR}GeneSeqer/xgs-sum ${TmpDir}tmp-$ufname/gs_output-$ufname > ${TmpDir}tmp-$ufname/gs_summary-$ufname");


print h3("This page displays the current partial output of your job.
	  The page will automatically refresh every", $rrate,
	 " seconds until the job completes. For more frequent updates
	  click the `Reload' button of your browser. Last update: ",
	 $t, "local time.");
print "&nbsp;", p;
print "<pre>";
print `cat ${TmpDir}tmp-$ufname/gs_summary-$ufname`;
print "<br><br><br>";
print `cat ${TmpDir}tmp-$ufname/gs_output-$ufname | egrep -v "Scroll down to"`;
print "</pre>";
print hr;
print h3("This page displays the current partial output of your job.
	  The page will automatically refresh every", $rrate,
	 " seconds until the job completes. For more frequent updates
	  click the `Reload' button of your browser. Last update: ",
	 $t, "local time.");
print end_html();
