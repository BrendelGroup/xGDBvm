#!/usr/bin/perl

# use CGI qw(:standard :html -debug);
use CGI ":all";

use GSQDB;
use GDBgui;

do 'SITEDEF.pl';
do 'GDBgui.pl';
do 'getPARAM.pl';

use DBI;

my $url;
if (param('program')=~ /downloadGDB/) {
	$url = &download_GDB;
	print "Location: $url\n\n";
}elsif (param('program')=~ /downloadRegion/) {
	$url = &download_region;
	print "Location: $url\n\n";
}elsif (param('program')=~ /xGDBtoGenBank/) {
	$url = &change_format;
	print "Location: $url\n\n";
}

sub download_GDB { # whitelisting 5/19/15
#	my $db = param('db');
	my $db = ( param('db') =~ /^[0-9A-Za-z]*$/ )? param('db'):"db_error";
#	my $dbid = param('dbid');
	my $dbid = ( param('dbid') =~ /^[A-Za-z0-9\_\.\|-]*$/ )? param('dbid'):"dbid_error"; # configured so empty argument is accepted
#	my $id = param('id');
	my $id = ( param('id') =~ /^[A-Za-z0-9\_\.\|-]*$/ )? param('id'):"id_error"; # configured so empty argument is accepted
	my $l_pos = param('l_pos');
	$l_pos =~ s/\s+$//;
	$l_pos = ($l_pos =~ /^[0-9]*$/ )? $l_pos:"l_pos_error";
	my $r_pos = param('r_pos');
	$r_pos =~ s/\s+$//;
	$r_pos = ($r_pos =~ /^[0-9]*$/ )? $r_pos:"r_pos_error";
	my $hit = "$id:$l_pos:$r_pos";
#	my $DB = param('xGDB');
	my $DB = ( param('xGDB') =~ /^[0-9A-Za-z]*$/ )? param('xGDB'):"xGDB_error";
	my $err = 0;

	# Connect to the MySQL server.
	# added 3-16-15 Get mysql password
	my $dbpass='';
	open FILE, "/xGDBvm/admin/dbpass";
	while ($line=<FILE>){
	$dbpass= $line;
	}
	my $DB_HOST = 'localhost';
	my $dsn = "DBI:mysql:$DB:$DB_HOST";
	my $user = 'gdbuser';
	my %attr = (PrintError => 0, RaiseError => 0);
	my $dbh = DBI->connect($dsn,$user,$dbpass,\%attr) or die $DBI::errstr;
	my $sth;

		my $query = "SELECT length(seq) from gseg where gi='$id'";
		print STDERR "kkkkkkkkkkkkkkkkkkkk $query\n";
		$sth = $dbh->prepare($query);
		$sth->execute();
		
		my $size;
		my $noData = 0;
		while(my @ary = $sth->fetchrow_array()){
			$size = $ary[0];
		}
		if (!$size) {
			$noData = 1;
		}
		if (!($id =~ /^\S+$/) || !($r_pos =~ /^\d+$/) || !($l_pos =~ /^\d+$/)) {
			$err = 1;
		} elsif ($r_pos < $l_pos) {
			$err = 2;
		} elsif ($noData) {
			$err = 3;
		} elsif ($l_pos < 0 || $l_pos > $size || $r_pos < 0 || $r_pos > $size) {
			$err = 4;
		}
	
	if ($err) {
		my $link = "${CGIPATH}downloadGDB.pl?db=$db&dbid=$dbid&hits=$hit&error=$err";
	} else {
		my $link = "${CGIPATH}downloadGDB.pl?db=$db&dbid=$dbid&hits=$hit";
	}
}

sub download_region {
	my $xGDB = ( param('xGDB') =~ /^[0-9A-Za-z]*$/ )? param('xGDB'):"xGDB_error";
	my $myDB = ( param('myDB') =~ /^[0-9A-Za-z]*$/ )? param('myDB'):"myDB_error";
	my $id = ( param('id') =~ /^[A-Za-z0-9\_\.\|-]*$/ )? param('id'):"id_error"; # 
	my $l_pos = ($l_pos =~ /^[0-9]*$/ )? param('l_pos'):"l_pos_error";
	my $r_pos = ($r_pos =~ /^[0-9]*$/ )? param('r_pos'):"r_pos_error";
	my $DBpath = ( param('DBpath') =~ /^[A-Za-z0-9\/\_-]*$/ )? param('DBpath'):"DBpath_error"; #
	my $sequence = ( param('sequence') =~ /^[A-Za-z\(\)\s-]*$/ )? param('sequence'):"sequence_error"; # Sequence type (e.g. EST); parenthesis dash and whitespace allowed
	my $seqType;
	if (param('GSEGflag')){
		$seqType = 'GSEG';
	}else{
		$seqType = $sequence;	
	}

	my $link = "${CGIPATH}downloadRegion.pl?xGDB=$xGDB&DB=$myDB&id=$id&l_pos=$l_pos&r_pos=$r_pos&DBpath=$DBpath&type=$seqType";
}

sub change_format {
	my $xGDB = ( param('xGDB') =~ /^[0-9A-Za-z]*$/ )? param('xGDB'):"xGDB_error";
	my $id = ( param('id') =~ /^[A-Za-z0-9\_\.\|-]*$/ )? param('id'):"id_error"; # configured so empty argument is accepted
	my $l_pos = ($l_pos =~ /^[0-9]*$/ )? param('l_pos'):"l_pos_error";
	my $r_pos = ($r_pos =~ /^[0-9]*$/ )? param('r_pos'):"r_pos_error";
	my $DBpath = ( param('DBpath') =~ /^[A-Za-z0-9\/\_-]*$/ )? param('DBpath'):"DBpath_error"; #
	my $format = ( param('format') =~ /^[0-9A-Za-z]*$/ )? param('format'):"format_error";

	my $link = "${CGIPATH}xGDBtoGenBank.pl?xGDB=$xGDB&id=$id&l_pos=$l_pos&r_pos=$r_pos&DBpath=$DBpath&Type=$format";
}
