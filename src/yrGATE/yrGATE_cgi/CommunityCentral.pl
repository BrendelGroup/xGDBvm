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

require 'yrGATE_conf.pl';      # /yrGATE/conf_XxGDB/yrGATE_conf.pl
require 'yrGATE_functions.pl';

&{$GV->{InitFunction}};

if (!$GV->{login_required} && $GV->{dasInput}){
    print redirect("das_scripts/dasSelect.pl");
}

my $db_ver = "";
my $limit_db_ver = "";
if (param('db_ver') ne ""){
	$db_ver = param('db_ver');
	$limit_db_ver = "AND dbVer = '$db_ver'";
}

my @statusArr = ('ACCEPTED');
my $sql = "SELECT uid,geneId,locusId,transcriptId, modDate,status,USERid,chr,l_pos,r_pos,proteinSeq,GSeqEdits,organism,dbName,dbVer,LEFT(geneAliases, 20),LEFT(proteinId,20),annotation_class,category,working_group, description FROM user_gene_annotation WHERE status='ACCEPTED' AND dbName = '$GV->{dbTitle}' $limit_db_ver";
# Following line, if used in place of previous, will display full names instead of nicknames (logins).
#  my $sql = "SELECT uga.uid,geneId,locusId,modDate,status,users.fullname,chr,l_pos,r_pos,proteinSeq,GSeqEdits,organism,dbName,dbVer,LEFT(geneAliases, 20),LEFT(proteinId,20),annotation_class,category,working_group, description FROM user_gene_annotation AS uga, users WHERE uga.USERid = users.user_name AND status='ACCEPTED' AND dbName = '$GV->{dbTitle}' $limit_db_ver";

# Search Form Variables
my $search_field_user = param('search_field');
$search_field_user =~ s/[^A-Za-z0-9\s-_]//g; # 2/25/15 JPD
my $search_term_user = param('search_term');
$search_term_user =~ s/[^A-Za-z0-9\s\.-_:]//g; # 2/25/15 JPD
my $page_params = "";
if ($search_field_user ne "" && $search_term_user ne ""){
  $page_params = "search_field=$search_field_user&amp;search_term=$search_term_user";
}

my $page_link_minus_search = "";
if ($db_ver ne ""){
  $page_link_minus_search = "<a href='$GV->{CGIPATH}CommunityCentral.pl?db_ver=$db_ver'> Remove Filter </a>"
} else {
  $page_link_minus_search = "<a href='$GV->{CGIPATH}CommunityCentral.pl?sort=modDate!'>[Remove Filter]</a>";
}

if ($search_field_user eq "annotator"){
  $sql .= " AND USERid LIKE '%$search_term_user%'";
  $search_summary = "Searching by <span class=\"attention_text bold\">Annotator</span>, filter: <span class=\"attention_text bold\">$search_term_user</span>. $page_link_minus_search";
} elsif ($search_field_user eq "id"){
  $sql .= " AND geneId LIKE '%$search_term_user%'";
  $search_summary = "Searching by <span class=\"attention_text bold\">Annotation ID</span>, filter: <span class=\"attention_text bold\">$search_term_user</span>. $page_link_minus_search";
} elsif ($search_field_user eq "class"){
  $sql .= " AND annotation_class LIKE '%$search_term_user%'";
  $search_summary = "Searching by <span class=\"attention_text bold\">Annotation Class</span>, filter: <span class=\"attention_text bold\">$search_term_user</span>. $page_link_minus_search";
} elsif ($search_field_user eq "locus"){
  $sql .= " AND locusId LIKE '%$search_term_user%'";
  $search_summary = "Searching by <span class=\"attention_text bold\">Locus ID</span>, filter: <span class=\"attention_text bold\">$search_term_user</span>. $page_link_minus_search";
} elsif ($search_field_user eq "transcript"){
  $sql .= " AND transcriptId LIKE '%$search_term_user%'";
  $search_summary = "Searching by <span class=\"attention_text bold\">Transcript ID</span>, filter: <span class=\"attention_text bold\">$search_term_user</span>. $page_link_minus_search";
} elsif ($search_field_user eq "gene"){
  $sql .= " AND geneAliases LIKE '%$search_term_user%'";
  $search_summary = "Searching by <span class=\"attention_text bold\">Gene Alias</span>, filter: <span class=\"attention_text bold\">$search_term_user</span>. $page_link_minus_search";
} elsif ($search_field_user eq "protein"){
  $sql .= " AND proteinId LIKE '%$search_term_user%'";
  $search_summary = "Searching by <span class=\"attention_text bold\">Protein Product</span>, filter: <span class=\"attention_text bold\">$search_term_user</span>. $page_link_minus_search";
} elsif ($search_field_user eq "category"){
  $sql .= " AND category LIKE '%$search_term_user%'";
  $search_summary = "Searching by <span class=\"attention_text bold\">Category</span>, filter: <span class=\"attention_text bold\">$search_term_user</span>. $page_link_minus_search";
} elsif ($search_field_user eq "working_group"){
  $sql .= " AND working_group LIKE '%$search_term_user%'";
  $search_summary = "Searching by <span class=\"attention_text bold\">Working Group</span>, filter: <span class=\"attention_text bold\">$search_term_user</span>. $page_link_minus_search";
} elsif ($search_field_user eq "dbVer"){
  $sql .= " AND dbVer = '$search_term_user'";
  $search_summary = "Searching by <span class=\"attention_text bold\">DB version</span>, filter: <span class=\"attention_text bold\">$search_term_user</span>. $page_link_minus_search";
} elsif ($search_field_user eq "description"){
  $sql .= " AND description LIKE '%$search_term_user%'";
  $search_summary = "Searching by <span class=\"attention_text bold\">Description</span>, filter: <span class=\"attention_text bold\">$search_term_user</span>. $page_link_minus_search";
} elsif ($search_field_user eq "all"){
  $sql .= " AND (USERid LIKE '%$search_term_user%' OR locusId LIKE '%$search_term_user%' OR geneAliases LIKE '%$search_term_user%' OR proteinId LIKE '%$search_term_user%' OR category LIKE '%$search_term_user%' OR working_group LIKE '%$search_term_user%' OR description LIKE '%$search_term_user%' OR geneId LIKE '%$search_term_user%' OR annotation_class LIKE '%$search_term_user%')";
  $search_summary = "Searching by <span class=\"attention_text bold\">All</span>, filter: <span class=\"attention_text bold\">$search_term_user</span>. $page_link_minus_search";
}
$sql .= " ORDER BY status, ";

# sort field; limited to one field
# "desc" must be uppercase, or yrGATE_functions must be modified!
my $s = param('sort');
my ($field,$dir) = $s =~ /(\w+)(\W*)/;
if ($field eq ""){
  $s = " modDate desc ";
}else{
  $s = ($dir eq "!") ? " $field desc " : " $field ";
}
$s = ($field.$dir eq "region!") ? " CAST(chr AS UNSIGNED) desc, r_pos desc " : ($field eq "region") ? " CAST(chr AS UNSIGNED), r_pos " :  $s;

$sql .= $s;

my $dbver_sql = "SELECT DISTINCT dbVer FROM user_gene_annotation WHERE status='ACCEPTED' AND dbName = '$GV->{dbTitle}'";

my $dbver_array = $GV->{ADBH}->selectall_arrayref($dbver_sql);
my $dbverCount = scalar(@$dbver_array);
my $dbver_link_list = "";
if ($dbverCount > 1){
  $dbver_link_list .= "<span class='info'></span> | ";
  for (my $i=0;$i<$dbverCount;$i++){ # Change 1 to 0 if we want to allow them to choose nothing
    my ($dbver) = @{$dbver_array->[$i]};
    if ($dbver ne $db_ver){
      if ($page_params ne ""){
        $dbver_link_list .= "<a href='$GV->{CGIPATH}CommunityCentral.pl?sort=modDate!&amp;db_ver=$dbver&amp;$page_params' title='Display only database version $dbver annotations'>$dbver</a> | ";
      } else {
        $dbver_link_list .= "<a href='$GV->{CGIPATH}CommunityCentral.pl?sort=modDate!&amp;db_ver=$dbver' title='Display only database version $dbver annotations'>$dbver</a> | ";
      }
    } else {
      $dbver_link_list .= "<span class='attention_text bold' title='Currently displaying only version $dbver annotations'>$dbver</span> | ";
    }
  }
  $dbver_link_list .= "<span> <img id='yrgate_version-filter_help' style=\"margin-bottom:-3px\" src='/XGDB/images/help-icon.png' alt='?' title='What is the deal with versions?' class='xgdb-help-button' style='margin-bottom:1px' /> </span>";


  $search_summary .= "<span> | DB Version: </span> $dbver_link_list";
    if (param('db_ver') ne ""){
	  $search_summary .= "<a href='$GV->{CGIPATH}CommunityCentral.pl?sort=modDate!&amp;$page_params'>Show All </a>";
  } else {

  }
}


my $UCAref = $GV->{ADBH}->selectall_arrayref($sql);
my $table = recordTable($UCAref,\@statusArr,$s,'CommunityCentral.pl','community',$db_ver);

##$subscription = "<span class='info indent'><img src=\"/XGDB/images/feed-icon-14x14.png\" alt=\"Atom Feed\" height=\"14\" width=\"14\" /><a title=\"Create a newsfeed of $GV->{dbTitle} community annotations for your favorite newsreader\" href=\"/site/yrgate_new_annotations.php?GDB=$GV->{dbTitle}\"> Subscribe</a></span>";

$titleHead .= printTitle("Community Annotation Central ($GV->{dbTitle})","yrgate_comm_central", "<span class='bold indent'>Contents:</span><span class='info'> All $GV->{dbTitle} curated annotations </span>",1,1, "CommunityCentral.pl");

$page = "$titleHead<br />Community Annotations<br />$table";

my $download .= "<b>Download: </b>";
$download .= "<span class=\"navlink\"><a $linkTarget href='$GV->{CGIPATH}AnnotationExport.pl?amt=all&amp;html=1&amp;format=fasta&amp;html=1&amp;seqType=n'>Nucleotide FASTA</a>&nbsp;&nbsp; <a  href='$GV->{CGIPATH}AnnotationExport.pl?amt=all&amp;html=1&amp;format=fasta&amp;html=1&amp;seqType=p' class='nbsp'>Protein FASTA</a>&nbsp;&nbsp;<a href='$GV->{CGIPATH}AnnotationExport.pl?amt=all&amp;html=1&amp;format=gff3&amp;html=1' class='nbsp'>GFF3</a></span><br /><br />
<span class='citation'> Please cite Wilkerson et al. (2006) <i>Genome
	Biol.</i> <b>7</b>, R58. <a href=
	'http://www.ncbi.nlm.nih.gov/pmc/articles/PMC1779557/?tool=pubmed'>
	PMC1779557</a></span>";



my $parent_fresh = (param('login') or param('logout')) ? "<script type=\"text/javascript\">top.opener.location.href = top.opener.location.href;</script>" : "";  # refreshes parent window

#if ($ENV{'SERVER_NAME'} =~ m/zone/) { # Serve up XML on zones for better development practices. BREAKS SEVERAL JAVASCRIPTS JD TURNED OFF 
#	print header(-type=>'application/xhtml+xml', -charset=>'utf-8', -expires=>'now');
#} else { # Serve normally (HTML) elsewhere.
	print header(-expires=>'now');
#}

print "<!DOCTYPE html PUBLIC '-//W3C//DTD XHTML 1.0 Transitional//EN' 'http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd'>
<html xmlns='http://www.w3.org/1999/xhtml' xml:lang='en'>
<head>
<title>yrGATE: Community Annotation Central</title>
<meta http-equiv='content-type' content='text/html;charset=utf-8' />
<link href='/XGDB/javascripts/jquery/themes/base/ui.all.css' type='text/css' rel='stylesheet' />
<link type='text/css' rel='stylesheet' href='/XGDB/css/superfish.css' media='screen' />
<link type='text/css' rel='stylesheet' href='$GV->{HTMLPATH}yrGATE.css' />
<link type='text/css' rel='stylesheet' href='/XGDB/css/plantgdb.css' />
<style type='text/css'>
   a#comm_central {font-weight:normal; color: white; background: #08508E; padding:5px 4px 6px 4px; border: none;}
</style>

<script type='text/javascript' src='$GV->{JSPATH}AnnotationTool.js'></script>
<script type='text/javascript' src='$GV->{JSPATH}utility.js'></script>
<script type='text/javascript' src='$GV->{JSPATH}popup.js'></script>

<script type='text/javascript' src='/XGDB/javascripts/jquery/jquery-1.3.2.js'></script>
<script type='text/javascript' src='/XGDB/javascripts/superfish.js'></script>
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

<body class='mainT'>
$parent_fresh
<form class=\"annotation_form\" action='$GV->{CGIPATH}CommunityCentral.pl' name='tFrm' method='get'>
$titleHead
<div style=\"clear:both\">
<table>
<tr>
 	<td width='300px' style='padding:0 0 0 20px; border: 0'>
		Search:
			<select name='search_field'>
				<option value='all'>All Fields</option>
				<option value='id'>Annotation ID</option>
				<option value='class'>Annotation Class</option>
				<option value='annotator'>Annotator</option>
				<option value='locus'>Locus ID</option>
				<option value='transcript'>Transcript ID</option>
				<option value='gene'>Gene Alias</option>
				<option value='protein'>Protein Product</option>
				<option value='category'>Project</option>
				<option value='description'>Description</option>
				<option value='working_group'>Working Group</option>
				<option value='dbVer'>DB version</option>
			</select>
		for <input type='text' size='20' name='search_term' value='$search_term' />
		<input type='submit' value='Search' />
		<input type='hidden' name='db_ver' value='$db_ver' />
		<!--a id='download_csv' href='$GV->{CGIPATH}CommunityCentral_csv-export.pl'>Download CSV</a-->
	</td>
	<td width='300px' style=\"border:0\">$search_summary</td>
	<td width='200px' style='border: 0; padding:0 0 0 20px'>
		$download
	</td>
</tr>
</table>
</div>
$table

</form>
						  <div style=\"clear:both; float:right\">
							<a href=\"http://validator.w3.org/check?uri=referer\"><img
							  src=\"http://www.w3.org/Icons/valid-xhtml10\" alt=\"Valid XHTML 1.0 Transitional\" height=\"15\" width=\"44\" /></a>
						  </div>						

".printFooter()."
</body>
</html>";

disconnectDB();
