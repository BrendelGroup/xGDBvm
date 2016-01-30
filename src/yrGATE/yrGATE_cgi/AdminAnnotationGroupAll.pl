#!/usr/bin/perl
#use strict "vars";

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
my $isGroupAdmin = getWorkingGroupAdmin($PRM->{USERid});

if ($isGroupAdmin){  # only display page for admins
  my $geneId = param('mode'); # geneId to checkout
  my $uid = param('uid'); # uid to return


  if ($geneId){
    $openV = param('openV');
    #check out annotation
    $sql = "insert into admin_session (USERid,uid,checked_out_date,dbName) VALUES ('$PRM->{USERid}','$geneId',now(),'$GV->{dbTitle}')";
    $GV->{LDBH}->do($sql);
  }
  my $ownedRef = getAdminOwnership();
  if ($$ownedRef{$uid} eq  $PRM->{USERid}){
    $sql = "update admin_session set returned = 1 where uid = $uid and USERid = '$PRM->{USERid}'";
    $GV->{LDBH}->do($sql);
    $ownedRef = getAdminOwnership(); # new ownership
  }

# build the AdminGroupAnnotation table (load only records for which this user has user_group ADMIN status)
$sql = "SELECT uid,dbName,geneId,locusId,modDate,status,USERid,chr,l_pos,r_pos,dbVer,working_group FROM user_gene_annotation WHERE status != 'SAVED' AND working_group IN (SELECT private_group FROM user_group WHERE user='$PRM->{USERid}' and status='ADMIN') ORDER BY status, modDate DESC, dbName";

  $UCAref = $GV->{ADBH}->selectall_arrayref($sql);

  for (my $i=0;$i<scalar(@$UCAref);$i++){
    my ($uid,$dbname,$geneId,$locusId,$modDate,$status,$owner,$chr,$start,$end,$dbVer,$working_group) = @{$UCAref->[$i]};
#    my $UCAtablerow = "<td>$owner</td><td>$modDate</td><td>(&{$GV->{GenomeContextLinkFunction}}($chr,$start,$end,$dbVer))</td><td>$$ownedRef{$uid}";

	#the following is used to highlight annotation records modified in the last 7 days - JPD.
	use Time::Local;
	my $time = timelocal(localtime);
	my @mt = $modDate =~ /(\d+)-(\d+)-(\d+)\s(\d+):(\d+):(\d+)/;
	use POSIX qw(strtod);
	my $sec= strtod($mt[5]);
	my $min = strtod($mt[4]);
	my $hours = strtod($mt[3]);
	my $day = strtod($mt[2]);
	my $month = strtod($mt[1])-1;
	my $year = strtod($mt[0]);
	my $mod_time = timelocal($sec, $min, $hours, $day, $month, $year);
	my $diff=$time-$mod_time;
	my $recentClass="";
	if ($diff < 60*60*24*7){ # 7 days expressed in seconds
	$recentClass="recent_anno $status";
	}

    if (!$$ownedRef{$uid}){
      push(@{$statusHash{$status}},"<tr class= \"$recentClass\"><td>$uid</td><td>$dbname</td><td><a class=\"link_text hover_pointer bold\" target=\"_blank\" onclick=\"checkout('$uid');\">$geneId</a></td><td>$locusId</td><td>$owner</td><td>$working_group</td><td>$dbVer</td><td>$modDate</td><td><a class='hidelinkicon' target='_blank' href='".encode_entities(&{$GV->{GenomeContextLinkAllFunction}}($dbname,$chr,$start,$end,$dbVer))."'>$dbname $chr $start $end</a></td><td>$$ownedRef{$uid}</td></tr>");
    }elsif ($$ownedRef{$uid} eq $PRM->{USERid}){
      push(@{$statusHash{$status}},"<tr class= \"$recentClass\"><td>$uid</td><td>$dbname</td><td><a class=\"link_text hover_pointer\" target=\"_blank\" onclick=\"checkout('$uid');\">$geneId</a></td><td>$locusId</td><td>$owner</td><td>$working_group</td><td>$dbVer</td><td>$modDate</td><td><a target='_blank' href='".encode_entities(&{$GV->{GenomeContextLinkAllFunction}}($dbname,$chr,$start,$end,$dbVer))."'>$chr $start $end</a></td><td>$$ownedRef{$uid}<br /><a href='${rootPATH}${CGIPATH}AdminAnnotationGroupAll.pl?uid=$uid&amp;return=1'>Return Annotation</a></td></tr>");
    }else{
      push(@{$statusHash{$status}},"<tr class= '$recentClass checked'><td>$uid</td><td>$dbname</td><td>$geneId</td><td>$locusId</td><td>$owner</td><td>$working_group</td><td>$dbVer</td><td>$modDate</td><td><a class=\"link_text hover_pointer\" target='_blank' href='".encode_entities(&{$GV->{GenomeContextLinkAllFunction}}($dbname,$chr,$start,$end,$dbVer))."'>$chr $start $end</a></td><td>$$ownedRef{$uid}</td></tr>");
    }
  }

##Get working_groups for display at top of the form
my @WorkGroup_Array;
$sql = "SELECT distinct working_group FROM user_gene_annotation WHERE status != 'SAVED' AND dbName = '$GV->{dbTitle}' AND working_group IN (SELECT private_group FROM user_group WHERE (gdb='$GV->{dbTitle}'or gdb='ALL') and user='$PRM->{USERid}' and status='ADMIN')";
my $WorkGroupCount = $GV->{LDBH}->selectall_arrayref($sql);
     for (my $i=0;$i<scalar(@$WorkGroupCount);$i++){ 
 		my ($WorkGroup) = @{$WorkGroupCount->[$i]};
			push @WorkGroup_Array, $WorkGroup;
		 }
   local $"=',';
   my $WorkGroups;
   $WorkGroups =  "@WorkGroup_Array";
  my $page = printTitle("Private Group Admininstration (ALL Genomes)","yrgate_admin-group_anno","<span class='bold indent'>Contents:</span> <span class='info'>ALL GENOME annotations administered by $PRM->{USERid} ($WorkGroups)</span><a class='indent' href='$GV->{CGIPATH}AdminAnnotationGroup.pl'>View $GV->{dbTitle} only</a>",1,1,"AdminAnnotationGroupAll.pl");

  my $status = '';

  my $table = "<table class='mainT admin' border='1'><thead><tr class='headRow'><th>UID</th><th>dbName</th><th>Annotation ID<br /><span class='smaller_white'>(click to check out)</span></th><th>Locus ID</th><th>Owner</th><th>Working_Group</th><th>dbVer</th><th>Last Modified</th><th>Chromosome / Location</th><th>Checked out by Admin?</th></tr></thead>\n";
  
  foreach $status (sort {return $b cmp $a} keys %statusHash){
  
  	    my $trClass = 'catRow'.$status;
	    $table.= "<tr class='catRow bold hover_pointer $trClass'><td colspan='10' id=\"$status\">$status </td></tr>\n";
    $table .= join("\n", @{$statusHash{$status}});
  }
  $table .= "</table>\n";

  $page .= $table;

#if ($ENV{'SERVER_NAME'} =~ m/zone/) { # Serve up XML on zones for better development practices. Commented out for now. breaks javascript.
#	print header(-type=>'application/xhtml+xml', -charset=>'utf-8', -expires=>'now');
#} else { # Serve normally (HTML) elsewhere.
	print header(-expires=>'now');
#}


$HTML_head = <<END_OF_HEAD;
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" lang="en-US" xml:lang="en-US">
<head>
<title>yrGATE Administration Tool: Annotation Check Out Page</title>
<meta http-equiv='content-type' content='text/html;charset=utf-8' />
<link href='/XGDB/javascripts/jquery/themes/base/ui.all.css' type='text/css' rel='stylesheet' />
<link type='text/css' rel='stylesheet' href='/css/superfish.css' media='screen' />
<link type='text/css' rel='stylesheet' href='$GV->{HTMLPATH}yrGATE.css' />
<link type='text/css' rel='stylesheet' href='/css/plantgdb.css' />

<script type='text/javascript' src='$GV->{JSPATH}AnnotationTool.js'></script>
<script type='text/javascript' src='$GV->{JSPATH}utility.js'></script>
<script type='text/javascript' src='$GV->{JSPATH}popup.js'></script>
 <style type='text/css'>
   a#group_admin_anno {font-weight:normal; color: white; background: #08508E; padding:5px 4px 6px 4px; border: none;}
 </style>
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

<script type="text/javascript">
/* <![CDATA[ */

function checkout(id){
   Sname = id;
   illChar = new RegExp("[-_\s\.]","g");
   Sname = Sname.replace(illChar,"");
   document.forms.tFrm.mode.value = id;
   document.forms.tFrm.openV.value = 1;
   document.forms.tFrm.submit();
   return;
}

function openANN(){
   if (document.forms.tFrm.openV.value == 1){
     document.forms.tFrm.openV.value = 0;
     window.open("$GV->{CGIPATH}AnnotationTool.pl?uid=" + '$geneId', 'UCA' + '$geneId', 'resizable=yes,screenX=100,screenY=100,top=100,left=100,toolbar=no,status=yes,scrollbars=yes,location=yes,menubar=no,directories=no');
   }
}
/* ]]> */
</script>
</head>

<body class='mainT' onload="openANN();">
<form name='tFrm' method='post' action="$GV->{CGIPATH}AdminAnnotationGroupAll.pl">
<input type='hidden' name='mode' value='' />$mode
END_OF_HEAD

print $HTML_head;

print $page;
print "<input type='submit' value='Reload Page' /><br /><input type='hidden' name='openV' value='$openV' />";
print "</form>".printFooter()."</body></html>";

}else{
	if ($ENV{'SERVER_NAME'} =~ m/zone/) { # Serve up XML on zones for better development practices.
		print header(-type=>'application/xhtml+xml', -charset=>'utf-8', -expires=>'now');
	} else { # Serve normally (HTML) elsewhere.
		print header(-expires=>'now');
	}

    print "Action not allowed.";
}

disconnectDB();
