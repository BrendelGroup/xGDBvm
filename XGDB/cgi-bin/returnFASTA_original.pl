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
my $db2;
if ($db =~ /^(\S)(\S)/){
  my $L1 = $1;
  my $L2 = $2;
  $L2 =~ tr/A-Z/a-z/;
  $db2 = $L1.$L2;
}

if(scalar(@hits)){
  $seqAR = $GDB->getSequence($db,$dbid,\@hits);
  $mod_result = join('',@$seqAR);
  $output = "/Product/tmp/Region/" . $db2 . $h[0] . "-From" . $h[1] . "-To" . $h[2] . ".gdna";
  open (MYFILE, ">$output") or die("Error");
  print MYFILE "$mod_result";
}else{
  $mod_result = "No sequences were selected. Please use the 'Select All' button or the individual check boxes to select sequences to display.";
}
close (MYFILE);

print "<a title=\"Click here to save file or open it with another program\" href=\"/XGDB/cgi-bin/forceDownload.pl?inputFile=$output\"><b>Download</b></a>\n";

print (start_html(-title=>'Selected Sequences',
		  -bgcolor=>'#FFFFFF'),
       pre($mod_result),
       end_html
      );


