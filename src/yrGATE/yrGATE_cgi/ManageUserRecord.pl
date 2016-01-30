#!/usr/bin/perl

require 'yrGATE_conf.pl'; # in /yrGATE/conf_XxGDB/
require 'yrGATE_functions.pl';

$PRM->{USERid} = &{$GV->{getUserIdFunction}};
# no edit link for PlantGDB implementation because virtual does not pass cookie, thus session
print header();
print "
<html>
<head>
<title>yrGATE: Admin Group Account</title>
<meta http-equiv='content-type' content='text/html;charset=utf-8' />
<link href='/XGDB/javascripts/jquery/themes/base/ui.all.css' type='text/css' rel='stylesheet' />
<link type='text/css' rel='stylesheet' href='/css/superfish.css' media='screen' />
<link type='text/css' rel='stylesheet' href='$GV->{HTMLPATH}yrGATE.css' />
<link type='text/css' rel='stylesheet' href='/css/plantgdb.css' />

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


my $isAdmin = getUserGroup($PRM->{USERid});

if ($isAdmin){  # only display page for admins
# user field; 
my $uid = param('uid');
my $dbname = $GV->{dbTitle};
my $sql = "select a.uid, a.user_name, group_concat(b.private_group) as groups, b.gdb from users as a, user_group as b where a.user_name=b.user and a.uid=$uid and b.gdb='$dbname' group by b.user";
my @arr = $GV->{LDBH}->selectrow_array($sql);
my $sql = "select user_name from users where uid=$uid";
my $groups = $arr[2];
my @arr2 = $GV->{LDBH}->selectrow_array($sql);
my $user = $arr2[0];
my $txt =<<END_TXT;
<h1 class="topmargin2">User Record for $dbname</h1>

<div class="annofeature">

<table class='mainT' style='max-width:900px'>
<tr class='headRow'>
<th>uid</th><th>Username</th><th>Groups</th>

</tr>

<tr class='recordRow'>

<td>$uid</td><td>$user</td><td>$groups</td>

</tr>
</table>
</div>

END_TXT

  print "$txt";
}else{
  print "<p>You currently do not have permission to access this page, $PRM->{USERid}.</p>";
}

print printFooter() . "</div></body></html>";
