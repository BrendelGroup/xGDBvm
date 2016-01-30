#!/usr/bin/perl
# watch-gs.cgi
# Last update: October 23, 2002 (VB)
# Last update: Feb 10,2003 (Dong). 1. replace all the old deepc2 path into PlantGDB path; 2. rename it to PlantGDBwatch-g16, 2009 (Ann Fu)s.cgi
# Last update: May 6, 2003 (VB): added "egrep -v" filter to pull out non-functional links
# November 16, 2009 (Ann Fu): Copy of this script for refactored BLAST output management.

use CGI qw/:standard :html escapeHTML sub/;
do 'SITEDEF.pl';
my $TmpDir = $TMPDIR;
my $BlastOutput = param('BlastOutput');
my $DB = param('db');
my $rrate = param('rrate');
my $t = localtime();

if (-s "$BlastOutput"){
print ("Location:$SERVER${CGIPATH}/XGDBblastOut.pl?BlastOutput=$BlastOutput&db=$DB\n\n");
  exit;
}
print header(-Refresh=>"$rrate;URL= ${CGIPATH}/XGDBwatch-blast.cgi?BlastOutput=$BlastOutput&db=$DB&rrate=$rrate");
print start_html("Blast Output");


print h3("Your BLAST job is underway.
	  The page will automatically refresh every", $rrate,
	 " seconds until the job completes. For more frequent updates
	  click the 'Reload' button of your browser. <br /> Last update: ",
	 $t, "local time.");
print "&nbsp;", p;
print "<PRE>";
print "<BR><BR><BR>";
print "</PRE>";
print end_html();
