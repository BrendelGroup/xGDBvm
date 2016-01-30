<?php
if(empty($PARAM_H)){
  if(empty($SITEDEF_H)){require('SITEDEF.php');}

  // Currently not reading or establishing $cgi_paramHR associative array from CGI session store
  $cgi_paramHR = array();

  if(empty($LOGIN_H)){require('checkLOGIN.php');}

  $PARAM_H = 1;
}

?>
