#!/usr/bin/perl
use CGI ":all";

use vars qw(
$GV
	    );
do 'yrGATE_conf.pl';
do 'dasFunctions.pl';

my $type = param("type");
my $source = param("source");
my $site = param("site");
my $num = param("num");
my @list;
my $das;

if ($site ne "" and $source ne ""){
    $das = connectDAS($site,$source);
}
if ($type eq "Site"){
  @list = getDasSites();
}elsif($type eq "Source" and $site ne ""){
  @list = getDasSources($site);
}elsif($type eq "Feat" and $site ne "" and $source ne ""){
  @list = getDasFeatures($das);
}elsif($type eq "EP" and $source ne ""){
  @list = getDasEntryPoints($das);
}else{
  print header();
  print "Please select information that is required for this selection, such as a server selection before a data source selection, and a data server selection before a feature or segment selection.";
  exit();
}

print header();
print "<html><body onLoad='window.focus();'>";
for (my $i=0;$i<scalar(@list);$i++){
  print "<a href=# onClick=\"opener.document.forms.selFrm['$type' + '$num'].value= '$list[$i]';window.close();\">$list[$i]</a><br>";
}
print "</body></html>";
