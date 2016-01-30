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


my @statusArr = ('ACCEPTED');
my $sql = "SELECT uid,geneId,modDate,status,USERid,chr,l_pos,r_pos,proteinSeq,organism,dbName,dbVer,LEFT(geneAliases, 20),LEFT(proteinAliases,20),category,working_group FROM user_gene_annotation WHERE status='ACCEPTED' AND dbName = '$GV->{dbTitle}' ORDER BY status, ";

# sort field; limited to one field
my $s = param('sort');
my ($field,$dir) = $s =~ /(\w+)(\W*)/;
if ($field eq ""){
  $s = " modDate DESC ";
}else{
  $s = ($dir eq "!") ? " $field DESC " : " $field ";
}
$s = ($field.$dir eq "region!") ? " CAST(chr AS UNSIGNED) DESC, r_pos DESC " : ($field eq "region") ? " CAST(chr AS UNSIGNED), r_pos " :  $s;

$sql .= $s;

my $UCAref = $GV->{ADBH}->selectall_arrayref($sql);
my $table = recordTable($UCAref,\@statusArr,$s,'CommunityCentral.pl');

$page = "Community Annotations<br />$table";

print header();
print "
<html>
<head>
	<title>yrGATE: Community Annotation Central</title>
</head>

<body>

$table

".printFooter()."
</body>
</html>";

disconnectDB();
