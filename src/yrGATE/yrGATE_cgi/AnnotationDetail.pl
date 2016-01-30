#!/usr/bin/perl

require 'yrGATE_conf.pl'; # in /yrGATE/conf_XxGDB/
require 'yrGATE_functions.pl';

$PRM->{USERid} = &{$GV->{getUserIdFunction}};
# no edit link for PlantGDB implementation because virtual does not pass cookie, thus session
loadUCA();
print header();
#$PageTitle="yrGATE: Gene Annotation Record";
#do '/Product/yrGATE/yrGATE_cgi/header.pl';

print "
<html>
<head>
<title>yrGATE: Annotation Account</title>
<meta http-equiv='content-type' content='text/html;charset=utf-8' />
<link href='/XGDB/javascripts/jquery/themes/base/ui.all.css' type='text/css' rel='stylesheet' />
<link type='text/css' rel='stylesheet' href='/css/superfish.css' media='screen' />
<link type='text/css' rel='stylesheet' href='$GV->{HTMLPATH}yrGATE.css' />
<link type='text/css' rel='stylesheet' href='/XGDB/css/plantgdb.css' />

<script type='text/javascript' src='$GV->{JSPATH}AnnotationTool.js'></script>
<script type='text/javascript' src='$GV->{JSPATH}utility.js'></script>
<script type='text/javascript' src='$GV->{JSPATH}popup.js'></script>

<script type='text/javascript' src='/XGDB/javascripts/jquery/jquery-1.3.2.js'></script>
<script type='text/javascript' src='/javascript/superfish.js'></script>
<script type='text/javascript' src='/XGDB/javascripts/jquery/ui/ui.core.js'></script>
<script type='text/javascript' src='/XGDB/javascripts/jquery/ui/ui.sortable.js'></script>
<script type='text/javascript' src='/XGDB/javascripts/jquery/ui/ui.draggable.js'></script>
<script type='text/javascript' src='/XGDB/javascripts/jquery/ui/ui.resizable.js'></script>
<script type='text/javascript' src='/XGDB/javascripts/jquery/ui/ui.dialog.js'></script>
<script type='text/javascript' src='/XGDB/javascripts/jquery/ui/effects.core.js'></script>
<script type='text/javascript' src='/XGDB/javascripts/jquery/ui/effects.highlight.js'></script>
<script type='text/javascript' src='/XGDB/javascripts/jquery/external/bgiframe/jquery.bgiframe.js'></script>
<script type='text/javascript' src='/XGDB/javascripts/default_xgdb.js'></script>
</head>
<body class=\"maintT\">
<div id=\"maincontents\">


";

print printTitle("Gene Annotation Record", "yrgate_anno_record","<span class='bold indent'>Contents:</span> <span class='info'><b>Annotation details</b></span>",0,1);

if ($PRM->{owner} eq $PRM->{USERid} || $PRM->{status} eq "ACCEPTED"){


  #$txt = printEditLink();
  $txt .= printDetail();
  print "$txt";
}else{
  print "<p>You currently do not have permission to access this record.<br />  If this is a 'saved' annotation, please use the yrGATE Annotation Account Page to access this record.</p>";
}

print printFooter() . "</div></body></html>";
