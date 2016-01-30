#!/usr/bin/perl
#modified by ZmDB/PlantGDB staffs from original Lincoln Stein's Blast used at CSHL
#Last modified by Qunfeng: query by GI or Acc or GSScontigID
# $Id: PlantGDBblast,v 1.2 2008/01/29 15:45:30 plantgdb Exp $

use CGI qw/:standard :html escapeHTML sub/;
use IO::File;
do 'AnnoPipe_conf.pl';
my $ufname=param('ufname');
my $XGDB=$GV->{dbTitle};
my $DBname=$GV->{dbName};
print header();
print start_html();
print    h1('CpGAT Results');
print "<pre>";
	 print "<b>The annotations from ($ufname.Delete.sql), $GV->{dbTitle} $GV->{dbName} have been deleted.</b><br />";
print "</pre>";
print end_html;
