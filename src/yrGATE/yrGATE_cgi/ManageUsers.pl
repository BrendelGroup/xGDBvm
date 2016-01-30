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
  $sql = "select a.user_name, a.fullname, a.email, a.account_type,b.status, b.private_group, b.gdb, group_concat(distinct concat(b.private_group, ' ', b.status, ' (', b.gdb, ')') separator '<br />') as groups, a.uid, count(c.USERid) as count, modDate, max(modDate) as date from users as a left join user_group as b on a.user_name=b.user left join user_gene_annotation as c on a.user_name=c.USERid group by a.user_name";
  
  
######TETSTING Search Form Variables
my $search_field_user = param('search_field');
my $search_term_user = param('search_term');
my $page_params = "";
if ($search_field_user ne "" && $search_term_user ne ""){
  $page_params = "search_field=$search_field_user&amp;search_term=$search_term_user";
}

my $page_link_minus_search = "";
  $page_link_minus_search = "<a href='$GV->{CGIPATH}AdminGroupView.pl'>[Remove Filter]</a>";

if ($search_field_user eq "user_name"){
  $sql .= " HAVING user_name LIKE '%$search_term_user%'";
  $search_summary = "Searching by <span class=\"attention_text bold\">Username</span>, filter: <span class=\"attention_text bold\">$search_term_user</span>. $page_link_minus_search";
} elsif ($search_field_user eq "fullname"){
  $sql .= " HAVING fullname LIKE '%$search_term_user%'";
  $search_summary = "Searching by <span class=\"attention_text bold\">fullname</span>, filter: <span class=\"attention_text bold\">$search_term_user</span>. $page_link_minus_search";
} elsif ($search_field_user eq "email"){
  $sql .= " HAVING email LIKE '%$search_term_user%'";
  $search_summary = "Searching by <span class=\"attention_text bold\">email</span>, filter: <span class=\"attention_text bold\">$search_term_user</span>. $page_link_minus_search";
} elsif ($search_field_user eq "account type"){
  $sql .= " HAVING account_type LIKE '%$search_term_user%'";
  $search_summary = "Searching by <span class=\"attention_text bold\">yrGATE status</span>, filter: <span class=\"attention_text bold\">$search_term_user</span>. $page_link_minus_search";

} elsif ($search_field_user eq "status"){
  $sql .= " HAVING status LIKE '%$search_term_user%'";
  $search_summary = "Searching by <span class=\"attention_text bold\">Groups status</span>, filter: <span class=\"attention_text bold\">$search_term_user</span>. $page_link_minus_search";

} elsif ($search_field_user eq "private_group"){
  $sql .= " HAVING private_group LIKE '%$search_term_user%'";
  $search_summary = "Searching by <span class=\"attention_text bold\">Working group</span>, filter: <span class=\"attention_text bold\">$search_term_user</span>. $page_link_minus_search";
} elsif ($search_field_user eq "gdb group"){
  $sql .= " HAVING gdb LIKE '%$search_term_user%'";
  $search_summary = "Searching by <span class=\"attention_text bold\">XxGDB Group</span>, filter: <span class=\"attention_text bold\">$search_term_user</span>. $page_link_minus_search";
} elsif ($search_field_user eq "uid"){
  $sql .= " HAVING uid = $search_term_user";
  $search_summary = "Searching by <span class=\"attention_text bold\">uid</span>, filter: <span class=\"attention_text bold\">$search_term_user</span>. $page_link_minus_search";
} elsif ($search_field_user eq "count greater than"){
  $sql .= " HAVING count(USERid) > $search_term_user";
  $search_summary = "Searching by <span class=\"attention_text bold\">count</span>, filter: <span class=\"attention_text bold\">$search_term_user</span>. $page_link_minus_search";
} elsif ($search_field_user eq "count less than"){
  $sql .= " HAVING count(USERid) < $search_term_user";
  $search_summary = "Searching by <span class=\"attention_text bold\">count</span>, filter: <span class=\"attention_text bold\">$search_term_user</span>. $page_link_minus_search";
} elsif ($search_field_user eq "date after"){
  $sql .= " HAVING max(modDate) > '$search_term_user'";
  $search_summary = "Searching by <span class=\"attention_text bold\">date_after</span>, filter: <span class=\"attention_text bold\">$search_term_user</span>. $page_link_minus_search";
} elsif ($search_field_user eq "date before"){
  $sql .= " HAVING modDate < '$search_term_user'";
  $search_summary = "Searching by <span class=\"attention_text bold\">date_before</span>, filter: <span class=\"attention_text bold\">$search_term_user</span>. $page_link_minus_search";
} elsif ($search_field_user eq "All Fields"){
  $sql .= " HAVING (user_name LIKE '%$search_term_user%' OR fullname LIKE '%$search_term_user%' OR email LIKE '%$search_term_user%' OR account_type LIKE '%$search_term_user%' OR status LIKE '%$search_term_user%' OR groups LIKE '%$search_term_user%' OR uid = $search_term_user')";
  $search_summary = "Searching by <span class=\"attention_text bold\">All Fields</span>, filter: <span class=\"attention_text bold\">$search_term_user</span>. $page_link_minus_search";
}

######END TESTING  
  
############### Using the sort mechanism from CommunityCentral.pl:

# sort field; limited to one field
# "desc" must be uppercase, or yrGATE_functions must be modified!
my $s = param('sort');
my ($field,$dir) = $s =~ /(\w+)(\W*)/; #field name followed by /or not "!"
if ($field eq ""){
  $s = " ORDER BY a.uid  "; #important! spaces before and after
}else{
  $s = ($dir eq "!") ? " ORDER BY $field DESC " : " ORDER BY $field "; #important! space before; case must match in-table case
}

$sql .= $s;


  $USERGROUP_ref = $GV->{ADBH}->selectall_arrayref($sql);

  my $page = printTitle("User Administration","yrgate_admin_group_view","<span class='bold indent'>Contents:</span> <span class='heading'>All yrGATE Users and Database Status</span><span class='heading indent'><a href='$GV->{CGIPATH}AdminAnnotation.pl'>[return to Aministrate Annotations]</a></span>",1,1);
  $page .= "
  <form action='$GV->{CGIPATH}AdminGroupView.pl' name='tFrm' method='get'>
<table>
<tr>
 	<td width='300px' style='padding:0 0 0 20px; border: 0'>
		Search:
			<select name='search_field'>
				<option value='All Fields'>All Fields</option>
				<option value='user_name'>Username</option>
				<option value='fullname'>Full Name</option>
				<option value='email'>email</option>
				<option value='account type'>yrGATE Status</option>
				<option value='status'>Groups Status</option>
				<option value='private_group'>Working Group</option>
				<option value='gdb group'>XxGDB</option>
				<option value='uid'>UID</option>
				<option value='count greater than'>Count &gt; </option>
				<option value='count less than'>Count &lt; </option>
				<option value='date after'>Date after (yyyy-mm-dd)</option>
				<option value='date before'>Date before</option>
			</select>
		for <input type='text' size='20' name='search_term' value='$search_term' />
		<input type='submit' value='Search' />
	</td>
	<td width='400px' style=\"border:0\">$search_summary</td>
</tr>
</table>";

  my $table = "<table id='myTable' class='striped' border='1' width='1000px'>";
  $table .= "<thead><tr class='headRow'>";
  ################## testing the sort by user_name. Borrowed from yrGATE_functions.pl 1238 ff. Doesn't work yet.
  $table .= ($s =~ /user_name DESC/) ? "<th title=\"Annotation Owner. Click ID to view user record; click header to sort \"><a href=\"$GV->{CGIPATH}AdminGroupView.pl?sort=user_name\">User</a></th>":"<th title=\"Annotation Owner. Click ID to view user record; click header to sort \"><a href=\"$GV->{CGIPATH}AdminGroupView.pl?sort=user_name!\">User</a></th>";
  $table .= ($s =~ /fullname DESC/) ? "<th title=\"Full Name. Click ID to view user record; click header to sort \"><a href=\"$GV->{CGIPATH}AdminGroupView.pl?sort=fullname\">Full Name</a></th>":"<th title=\"Full Name. Click ID to view user record; click header to sort \"><a href=\"$GV->{CGIPATH}AdminGroupView.pl?sort=fullname!\">Full Name</a></th>";
  $table .= "<th>email</th>";
  $table.= "<th>yrgATE Status</th>";
  $table .= "<th>Groups Status</th>";
  $table .= "<th>Working Groups</th>";
  $table .= ($s =~ /uid DESC/) ? "<th title=\"User ID. Click ID to view user record; click header to sort \"><a href=\"$GV->{CGIPATH}AdminGroupView.pl?sort=uid\">UID</a></th>":"<th title=\"User ID. Click ID to view user record; click header to sort \"><a href=\"$GV->{CGIPATH}AdminGroupView.pl?sort=uid!\">UID</a></th>";
  $table .= ($s =~ /count DESC/) ? "<th title=\"Annotation Count for this user. Click ID to view user record; click header to sort \"><a href=\"$GV->{CGIPATH}AdminGroupView.pl?sort=uid!\">Annotation Count</a></th>":"<th title=\"Annotation Count for this user. Click ID to view user record; click header to sort \"><a href=\"$GV->{CGIPATH}AdminGroupView.pl?sort=count!\">Annotation Count</a></th>";
  $table .= ($s =~ /modDate DESC/) ? "<th title=\"User ID. Click ID to view user record; click header to sort \"><a href=\"$GV->{CGIPATH}AdminGroupView.pl?sort=modDate\">Most Recent</a></th>":"<th title=\"User ID. Click ID to view user record; click header to sort \"><a href=\"$GV->{CGIPATH}AdminGroupView.pl?sort=modDate!\">Most Recent</a></th>";
  $table .= "</tr></thead>\n";
  
  for (my $i=0;$i<scalar(@$USERGROUP_ref);$i++){
    my ($user,$fullname,$email,$account,$status, $private_group, $gdb, $groups,$uid, $anno_count, $mod_date, $date) = @{$USERGROUP_ref->[$i]};
    
	my $UCAtablerow = "<tr><td><a href='$GV->{CGIPATH}AdminGroupUpdate.pl?uid=$uid'>$user</a></td><td>$fullname</td><td>$email</td><td >$account</td><td>$status</td><td style=\"width:100px\"><p class=\"wwbw\"> $groups</p></td><td>$uid</td><td align=\"center\">$anno_count</td><td>$date</td></tr>";
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
<link href='/XGDB/javascripts/jquery/themes/base/ui.all.css' type='text/css' rel='stylesheet' />
<link type='text/css' rel='stylesheet' href='/css/superfish.css' media='screen' />
<link type='text/css' rel='stylesheet' href='$GV->{HTMLPATH}yrGATE.css' />
<link type='text/css' rel='stylesheet' href='/css/plantgdb.css' />
<style type='text/css'>
   a#admin_anno {font-weight:normal; color: white; background: #177C6C; padding:5px 4px 6px 4px; border: none;}
</style>

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

<body class='mainT'">

END_OF_HEAD

print $HTML_head;

print $page;
print "<input type='submit' value='Reload Page' /><br /><input type='hidden' name='openV' value='$openV' />";
print "<span class='heading'>$sql</span>";
print "</form>".printFooter()."</body></html>";

}else{
    print header(-expires=>'now');
    print "Action not allowed.";
}

disconnectDB();
