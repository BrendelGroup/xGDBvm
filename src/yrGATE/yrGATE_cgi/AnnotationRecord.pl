#!/usr/bin/perl -I/xGDBvm/src/yrGATE /xGDBvm/src/yrGATE/yrGATE_cgi
use CGI ":all";
#jfdenton added these lines for bug580 (broken getRecord links from yrGATE annotations)
$gdb = url_param('GDB');  #grab this from the url to construct paths
require '/xGDBvm/data/'. $gdb . '/conf/yrGATE_conf.pl'; # in /yrGATE/conf_XxGDB/
require '/xGDBvm/src/yrGATE/yrGATE_cgi/yrGATE_functions.pl';

$PRM->{USERid} = &{$GV->{getUserIdFunction}};
# no edit link for PlantGDB implementation because virtual does not pass cookie, thus session
loadUCA();
print header();
#NOTE - need to figure out how to load yrGATE.css. Stopgap is to load it for ALL of xGDB. - JD 8-2-10

print printTitle("Gene Annotation Record", "yrgate_anno_record",0,0);

## the if statement is commented out until we can figure out how to read USERid... JPD 10-4-11
#if (($PRM->{status} eq "ACCEPTED") || ($PRM->{owner} ne '' && $PRM->{owner} eq $PRM->{USERid})){

  #$txt = printEditLink(); ## this should be deleted...
  $txt .= printDetail();
  print "$txt"; #JD I can't pinpoint the two <br> tags between header and text, so this margin is a stopgap -JD
#}else{
#  print "<p>You currently do not have permission to access this record.<br />  If this is a 'saved' annotation, please use the yrGATE Annotation Account Page to access this record.</p>";
#}

;
