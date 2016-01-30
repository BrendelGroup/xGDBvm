#! /usr/bin/perl
# updated 2-27-14 J Duvick
# This script DELETES all existing GDB ID-named ('GDBnnn') directories from /xGDBvm/data, /xGDBvm/tmp, /xGDBvm/data/ArchiveGDB, /xGDBvm/data/ArchiveAllGDB
# It also truncates the xGDB_Log table and admin_session table
# It is invoked when the user wants to "start over"
# It does NOT truncate the yrgate "users" database table or the Admin.jobs table
# USE WITH CAUTION and remind users of the consequences.
my $xGDB;
my $dbpass;
my $outputDir="/xGDBvm/data";
my $tmpDir="/xGDBvm/tmp";
my $archiveDir="/xGDBvm/data/ArchiveGDB";
my $archiveAllDir="/xGDBvm/data/ArchiveAllGDB";

# added 11-12-12
$dbpass='';
open FILE, "/xGDBvm/admin/dbpass";
while ($line=<FILE>){
$dbpass= $line;
}
my $count = qx(echo "select count(*) from xGDB_Log" |mysql -p$dbpass -u gdbuser -N Genomes);

$count =~ s/\n$//;
while ($count){
	$xGDB = "GDB00".$count if $count <10;
	$xGDB = "GDB0".$count if $count >=10;
#	my $return= qx(/xGDBvm/scripts/DropGDB.sh $xGDB $count);
my $return =qx(rm -rf $outputDir/$xGDB);
my $return =qx(rm -rf $tmpDir/$xGDB);
my $return =qx(rm -rf $archiveDir/$xGDB);
my $return =qx(rm -rf $archiveDir/ArchiveGDB.log);
my $return =qx(echo "DROP DATABASE IF EXISTS $xGDB"|mysql -p$dbpass -u gdbuser Genomes);

	$count--;
}
my $return =qx(echo "truncate table xGDB_Log"|mysql -p$dbpass -u gdbuser Genomes);
#my $return =qx(echo "truncate table jobs"|mysql -p$dbpass -u gdbuser Admin);
my $return =qx(echo "truncate table admin_session"|mysql -p$dbpass -u gdbuser yrgate);
my $return =qx(echo "delete from tables_priv where Db like 'GDB%'"|mysql -p$dbpass -u gdbuser mysql);

my $return =qx(cd $archiveAllDir);
my $GDBdirs=qx(ls -d GDB[0-9][0-9][0-9]); # e.g. "GDB001  GDB002"
my $return =qx(rm -rf $GDBdirs);
my $return =qx(rm -rf $archiveAllDir/ArchiveAllGDB.log);
my $return =qx(rm -rf $archiveAllDir/Genomes.sql);
my $return =qx(rm -rf $archiveAllDir/yrgate.sql);