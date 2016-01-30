#!/usr/bin/perl
use GSQDB;
use CGI qw/:standard/;

do 'SITEDEF.pl';

print header(); # or print "Content-type: text/html\n\n";
my $GDB = new GSQDB();
my ($seqAR,$mod_result);

my $db   = param('db');
my $dbid = defined(param('dbid'))? param('dbid') : -1;
my @hits = param('hits');
my @h = split(/\:/,param('hits'));
my $noData = 1;
my $noDownload = 0;
if(scalar(@hits)){
  $seqAR = $GDB->getSequence($db,$dbid,\@hits);
  $mod_result = join('',@$seqAR);
  $output = "/xGDBvm/tmp/" . $xGDB . "/" . $db . $h[0] . "-From" . $h[1] . "-To" . $h[2] . ".gdna";
  print STDERR "jjjjjjj $output jjjjjj\n";
  open (MYFILE, ">$output") or die("Error");
  print MYFILE "$mod_result";
}else{
  $mod_result = "No sequences were selected. Please use the 'Select All' button or the individual check boxes to select sequences to display.";
}
close (MYFILE);
if ($noData) {
        $noDownload = 1;
        print MYFILE "$seqType does not exist in the selected region.\n";
        print MYFILE "Please select a different sequence type to view.\n";
}
if (!$noDownload) {
        print "<a title=\"Click here to save file or open it with another program\" href=\"/XGDB/cgi-bin/forceDownload.pl?inputFile=$output\"><b>Download</b></a>\n";
}


#open (OUTPUT, "<$output") or die("Error");
print (start_html(-title=>'Selected Sequences',
                  -bgcolor=>'#FFFFFF'),
       pre($mod_result),
       end_html
      );
#print "<pre class=\"normal\">\n";
#while (<OUTPUT>) {
#        print "$_";
#}
#print "</pre>\n";
#print "</body></html>\n";

close (OUTPUT);
