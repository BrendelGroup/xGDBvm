#!/usr/bin/perl -w
#Author: Ann Fu

#use strict;
use CGI ":all";
my $inputFile=param('inputFile');
my $q = CGI->new;
my $FileName = $inputFile;
if ($FileName =~ /\/tmp\/VNTI\/(\S+)/){
	$FileName=$1;
}
elsif ($FileName =~ /\/tmp\/GDB\d\d\d\/(\S+)/){
	$FileName=$1;
}else{
	$FileName="";
	$inputFile="";
}
open(my $DLFILE, '<', "$inputFile");
print $q=header(-typy => 'application/x-download',
		-attachment      => "$FileName",
		'Content-length' => -s "$inputFile",
	);

	binmode $DLFILE;
print while <$DLFILE>;
undef ($DLFILE);

