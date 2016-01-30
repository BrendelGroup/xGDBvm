#!/usr/bin/perl
use CGI ":all";
use LWP::Simple;

# frame only function to preserve window references to opener

print header();
$ufname = param('ufname');

# group together all sequences with a given exon, that all are incoporated into evidence for Portal exon selection

#$GSQsumm = "http://www.plantgdb.org/tmp/tmp-$ufname/gs_summary-$ufname";
$GSQsumm = "http://gremlin3dev.gdcb.iastate.edu/tmp/tmp-$ufname/gs_sorted-output-$ufname.html";

$page = get($GSQsumm);
@PGS = $page =~ /PGS.+?\)/g;
%exons = ();
for (my $i=0;$i<scalar(@PGS);$i++){
  @PGSexons = $PGS[$i] =~ /\d+\s\s\d+/g;
#  @PGSexons = ($PGSexons[0] < $PGSexons[1]) ? @PGSexons :($PGSexons[1],$PGSexons[0]) ;
  ($seqID) = $PGS[$i] =~ /_(\d+)[+-]/;
  if ($seqID ne ""){
  for (my $j=0;$j<scalar(@PGSexons);$j++){
    @coords = $PGSexons[$j] =~ /\d+/g;
    $exonT = ($coords[0]<$coords[1]) ? "$coords[0]-$coords[1]":"$coords[1]-$coords[0]" ;
    #$exons{$exonT} .= ($exons{$exonT}) ? ",$seqID" :$seqID ;
    $newE = "http:\/\/www.plantgdb.org\/search\/display\/data.php?Seq_ID=$seqID";
    $exons{$exonT}{$seqID} = $newE ;
  }
  }
}

$exonJscript .= "exons = new Object();\n";
for my $k (keys %exons){
  $joined = "";
  for my $k2 (keys %{$exons{$k}}) {
    $joined .= ($joined eq "") ? $exons{$k}{$k2} : " $exons{$k}{$k2}";
  }
  $exonJscript .= "exons['".$k."'] = '$joined';\n";
}


print "<html><head>
<script>
var frame3orig = top.frame3.location;

$exonJscript

function SelectExon(bk,a,b){
  var newln = frame3orig + '';
  srcArr = newln.split('#');  // if prior bookmarks
  frame3orig = (srcArr.length > 0) ? srcArr[0]:frame3orig;
  var newlink = frame3orig + '#' + bk;
  top.frame3.location.href = newlink;
//  parent.opener.Outside_Add_Exon(a,b,bk);
  a1 = Math.min(a,b); b1 = Math.max(a,b);
  parent.opener.addUDE((a + parseInt(parent.opener.document.forms[parent.opener.formName].RangeStart.value)-1),(b + parseInt(parent.opener.document.forms[parent.opener.formName].RangeStart.value)-1),'GeneSeqer',\"PlantGDB \" +exons[a + '-' + b]);
}

<\/script>
<title><\/title>
<\/head>
<body>
<table width='100%' cellspacing=0 cellpadding=0>
<tr><td bgcolor=orange></td><td bgcolor=orange><font style='font-family:Arial;font-weight:bold;font-size:24px'>yrGATE Portal to GeneSeqer</font></td></tr>
</table>

<p style='font-family:Arial;'>
<br><br>

Click on exons in the graphic to select them for your annotation.<br><br>

The scale of this image and the preview structure in the annotation window do not have the same scale.  However, when you click on the exons they are automatically adjusted to the scale in the Annotation Tool.<br><Br>

<small>
It is recommended that you arrange this window and your annotation window, so they are both viewable at the same time.  This way you can see the
exons as they are added.
</small>

<\/p>
<\/a>
";
print "<\/body><\/html>";
