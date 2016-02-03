<?php
if(empty($SITEDEF_H)){require('SITEDEF.php');}
if(empty($PARAM_H)){require('getPARAM.php');}

if(isset($cgi_paramHR["USERsession"])){
  $cgiSID = $cgi_paramHR["USERsession"];
}elseif(isset($_COOKIE["xGDB-cgisessid"])){
  $cgiSID = $_COOKIE["xGDB-cgisessid"];
}

if(isset($cgiSID)){
  $SSI_QUERYSTRING = "?xGDB-cgisessid=$cgiSID";

## For now we don't want to allow updating of session values from php pages!!!!
##  Instead use ajax request of xGDBupdateSession.pl
#}else{  ####### CREATE AND ISSUE DUMMY SESSION with DEFAULTS to avoid reduntant first entry sessions
#  $SSI_QUERYSTRING = '?SSI_PASSTHROUGH=true';
#  reset($cgi_paramHR);
#  while($element = each($cgi_paramHR)){
#    if(is_scalar($element["value"])){
#      $SSI_QUERYSTRING .= "&" . $element["key"] . "=" . urlencode($element["value"]);
#    }
#  }
}else{
  $SSI_QUERYSTRING = "?NO_SESSION=1";
}

?>
