#!/usr/bin/perl -I/

use CGI qw/:standard :html escapeHTML sub/;

use vars qw(
$GV
$DBH
$PRM
);


do 'SITEDEF.pl';
do 'AnnoPipe_conf.pl';

my $xGDB = param('xgdbFlag');



my $ufname = param('ufname');
my $CpGATparameter = param('CpGATparameter');
my $PDB = param('pdb');
my $TDB = param('tdb');
my $rrate = param('rrate');
my $xgdbFlag = param('xgdbFlag');
my $DefaultFlag = param('DefaultFlag');
my $t = localtime();
my $DeleteFlag=param('DeleteFlag');
my $log='';



if ($DeleteFlag){
	my $ufname = param('ufname');
	system("mysql -pxgdb -u gdbuser $xGDB <$ufname.Delete.sql");

        print ("Location:$GV->{CGIPATH}xGDB_CpGATDelete.pl\n\n");
        exit;
}
#jfdenton modified the tmp paths here (june-2013)

my $Die_Signal;
if ($ufname =~ /CpGAT\-(\d+)\//){
        my $tmp=$1;
        $log = "/xGDBvm/tmp/" . ${xGDB} . "/CpGAT/CpGAT-".$1."/Procedure.LOG";
        print STDERR $log;
	$Die_Signal = "/xGDBvm/tmp/". ${xGDB} . "/CpGAT/CpGAT-".$1."/Die.Signal";
}
# if output file exists e.g. /xGDBvm/tmp/GDB007/CpGAT/CpGAT-1399467004/scaff_28153from1to90000.filtered.gff3
if (-s "$ufname" ){
#system("/xGDBvm/scripts/GFF_to_XGDB_CpGAT.pl $ufname");
#system("mysql -pxgdb -u gdbuser $xGDB <$ufname.INSERT.sql");

print ("Location:$GV->{CGIPATH}xGDB_CpGATOut.pl?ufname=$ufname&amp;pdb=$PDB&amp;tdb=$TDB&amp;CpGATparameter=$CpGATparameter&amp;xgdbFlag=$xgdbFlag&amp;DefaultFlag=$DefaultFlag&amp;GDB=$xgdbFlag\n\n");
  exit;
}
if (-s $Die_Signal){
	
	print STDERR "KKKKKKKKKKKKKKKKKKKKKKKKKKKK $Die_Signal\n";
		print header();
		print start_html();	
		print "<PRE>";
		print "Your CpGAT job completed the following steps:<br />"; 
		print `cat $log`;
		print "</PRE>";
		print "<PRE>";
		print "Your process could not complete because the following error:<br />";
		print `cat $Die_Signal`;
		print "</PRE>";
		print end_html;
}else{
print header(-Refresh=>"$rrate;URL= $GV->{CGIPATH}xGDBwatch-CpGAT.cgi?ufname=$ufname&amp;pdb=$PDB&amp;tdb=$TDB&amp;rrate=$rrate&amp;CpGATparameter=$CpGATparameter&amp;xgdbFlag=$xgdbFlag&amp;DefaultFlag=$DefaultFlag&amp;GDB=$xgdbFlag");


print start_html("CpGAT Output");

print h3("Your CpGAT job is underway.
	  The page will automatically refresh every", $rrate,
	 " seconds until the job completes. For more frequent updates
	  click the `Reload' button of your browser. Last update: ",
	 $t, "local time.");
print "&nbsp;", p;
print "<PRE>";
print `cat $log`;
print "<BR><BR><BR>";
print "</PRE>"; 
print hr;
print h3("Your CpGAT job is underway.
	  The page will automatically refresh every", $rrate,
	 " seconds until the job completes. For more frequent updates
	  click the `Reload' button of your browser. Last update: ",
	 $t, "local time.");
print end_html();
}
