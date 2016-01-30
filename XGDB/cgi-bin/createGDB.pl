#!/usr/bin/perl
use CGI ":all";
$ID=param('ID');
$ID="00".$ID if ($ID<10);
$ID="0".$ID if ($ID<100);
$GDBid="GDB".$ID;
$Org="Test org";

system ("/xGDBvm/scripts/xGDB_Procedure.sh $GDBid $Org $ID");
