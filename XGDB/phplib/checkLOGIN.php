<?php

session_name('PlantGDB-phpsessid');
session_start(); // session for login
if(isset($_SESSION["yrGATElogin"])){
  $cgi_paramHR["USERid"] = $_SESSION["yrGATElogin"];
  $cgi_paramHR["USERsession"] = $_SESSION["USERsessionCGI"];
  $cgi_paramHR["USERfname"] = "";
  $cgi_paramHR["maintain"] = 0;
}

?>
