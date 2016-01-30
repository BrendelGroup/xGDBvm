#!/usr/bin/perl
#use strict "vars";

# work in progress: this script is to list users and their private groups if any, and allow the admin user to administrate individual users (add, delete groups).

use vars qw(
$GV
$GVportal
$PRM
@modes
$DBH
$zeroPos
$UCAcgiPATH
$IMAGEDIR
$GENSCAN_speciesModel
);

require 'yrGATE_conf.pl';
require 'yrGATE_functions.pl';

use HTML::Entities;

&{$GV->{InitFunction}};

$PRM->{USERid} = &{$GV->{getUserIdFunction}};
$PRM->{owner}  = param('owner') ? param('owner') : $PRM->{USERid}; # ?

if(!$PRM->{USERid}){
  ## Request user login for annotation creation
  bailOut("You must <a href=\"/yrGATE/$GV->{dbTitle}/login.pl\">log in</a> before using this tool. $GV->{dbTitle}");
}
my $isAdmin = getUserGroup($PRM->{USERid});

if ($isAdmin){  # only display page for admins
  my $ownedRef = getAdminOwnership();


# build the AdminGroups table
  $sql = "select a.user_name, a.fullname, a.email, a.account_type,b.status, group_concat(concat(b.private_group, ' ', b.status, ' (', b.gdb, ')') separator '<br />') as groups, a.uid from users as a left join user_group as b on a.user_name=b.user group by a.user_name";
  $USERGROUP_ref = $GV->{ADBH}->selectall_arrayref($sql);

  my $page = printTitle("User Administration","admin_group_view","<span class='bold indent'>Contents:</span> <span class='heading'>$GV->{dbTitle} All Users and Database Status",1,1);

  my $table = "<table id='myTable' class='mainT admin' border='1' width='1000px'>
  <thead><tr class='headRow'><th>User</th><th>Full Name</th><th>email</th><th>yrgATE Status</th><th>Groups Status</th><th>User Groups</th><th>uid</th></tr></thead>\n";
  
  for (my $i=0;$i<scalar(@$USERGROUP_ref);$i++){
    my ($user,$fullname,$email,$account,$status,$groups,$uid) = @{$USERGROUP_ref->[$i]};
    
	my $UCAtablerow = "<tr><td><a href='$GV->{CGIPATH}AdminGroupUpdate.pl?uid=$uid'>$user</a></td><td>$fullname</td><td>$email</td><td >$account</td><td>$status</td><td stile=\"width:100px\"><p class=\"wwbw\"> $groups</p></td><td>$uid</td></tr>";
	$table .= $UCAtablerow;
  }
  
  $table .= "</table>\n";

  $page .= $table;

print header(-expires=>'now');

$HTML_head = <<END_OF_HEAD;
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" lang="en-US" xml:lang="en-US">
<head>
<title>Admin Users</title>
<meta http-equiv='content-type' content='text/html;charset=utf-8' />
<link type='text/css' rel='stylesheet' href='/css/superfish.css' media='screen' />
<link type='text/css' rel='stylesheet' href='$GV->{HTMLPATH}yrGATE.css' />
<link type='text/css' rel='stylesheet' href='/css/plantgdb.css' />
<script type='text/javascript' src='/javascript/jquery.js'></script>
 <style type='text/css'>
   a#admin_users {font-weight:bold; color: white; background: #177C6C; padding:5px 4px 6px 4px; border: none;}
 </style>
<script type="text/javascript" src="/javascript/jquery.tablesorter.js"></script>
<script type='text/javascript' src='/javascript/superfish.js'></script>
<script type='text/javascript' src='/javascript/default.js'></script>

</head>

<body class='mainT'">
<form name='tFrm' method='post' action="$GV->{CGIPATH}AdminAnnotation.pl">
<input type='hidden' name='mode' value='' />$mode
END_OF_HEAD

print $HTML_head;

print $page;
print "<input type='submit' value='Reload Page' /><br /><input type='hidden' name='openV' value='$openV' />";
print "</form>".printFooter()."</body></html>";

}else{
    print header(-expires=>'now');
    print "Action not allowed.";
}

disconnectDB();
