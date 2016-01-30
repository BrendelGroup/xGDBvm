#!/usr/bin/perl
use vars qw($ua $SITENAMEshort $IMAGEDIR $mousex_ref $GSEG_SRC @DBver);

use GSQDB;
use CGI ":all";

## GLOBAL/COOKIE VALUES
do 'SITEDEF.pl';
do 'getPARAM.pl';
do 'sniff.pl';
### browser sniff redirect
if ($ua eq "bad"){
#    print header;
    print "Location: showClusterFlat.pl";
    exit();
}

my $onLoad     = "";
my $srcSwitch  = "";
if (!exists($cgi_paramHR->{imgW})){
  $onLoad = " onLoad='setIMGW();'";
  $srcSwitch = "src='${HTMLSTAT}blank.html' !";
  goto PRINT_FRAMESET;
}

$cgi_paramHR->{gsegSRC} = $GSEG_SRC if(exists($cgi_paramHR->{altCONTEXT}) && ($cgi_paramHR->{altCONTEXT} !~ /chr/i)); ## Kludge for genomic source defined in SITEDEF.pl
exists($cgi_paramHR->{dbid}) || ($cgi_paramHR->{dbid} = $#DBver);

my $db = new GSQDB($cgi_paramHR);
my $GDB=$DBver[$#DBver]->{DB};
my ($pgsstatHR,$exstatHR,$instatHR,$qseqAR,$gapped_gseg,$regionHTML) = $db->getRegionDetails($cgi_paramHR); 


########################## Region Graphic Frame (clgraph) ###############################

my $graphHTML = <<END_graph;
<html><head><title>Transcript View</title>
<script type="text/javascript" src="${JSPATH}TV_graph.js"></script>
<script type="text/javascript" src="${JSPATH}jsgraphics.js"></script>
<script type="text/javascript" src="${JSPATH}TV_menus.js"></script>
<script type="text/javascript" src="${JSPATH}utility.txt"></script>
<script type="text/javascript" src="${JSPATH}popup.txt"></script>
<style>
  DIV#scrollMarker {position:absolute; top:0px; left:20px; height:275px; width:10px; padding:0px; margin:0px; border:solid 2px #00FF00; border-bottom:none;}
  DIV#scrollDIV { position:absolute; top:275px; left:0px; height:25px; width:100%; padding:0px; margin:0px;}
  body {margin:0px; padding:0px;}
.smRow a{ COLOR: blue; text-decoration: none; font-family:verdana, arial;font-size:10px;padding:3px}
.smRow a:hover {color:white}
.smTitle {color:white;text-decoration:underline;font-family:verdana, arial;font-size:10px;background:gray;}
.sm { POSITION: absolute; VISIBILITY: hidden; BACKGROUND-COLOR: lightblue; LAYER-BACKGROUND-COLOR: lightblue; width: 150; BORDER-LEFT: 1px solid gray; BORDER-TOP: 1px solid gray; BORDER-BOTTOM: 1px solid gray; BORDER-RIGHT: 1px solid gray; z-index: 10 }
.Loadingpopup { POSITION: absolute; VISIBILITY: hidden; left: 300px; top: 100px; font-family:Arial; font-size: 14px; BACKGROUND-COLOR: brown;BACKGROUND-IMAGE: url('${IMAGEDIR}yellow_stucco.gif'); LAYER-BACKGROUND-COLOR: yellow; width: 200px; height:100px; BORDER-LEFT: 1px solid black; BORDER-TOP: 1px solid black; BORDER-BOTTOM: 3px solid black; BORDER-RIGHT: 3px solid black; PADDING: 3px; z-index: 10 }
.seqHLc { POSITION: absolute; VISIBILITY: hidden; BORDER-LEFT: 2px dashed #094a72; BORDER-TOP: 2px dashed #094a72; BORDER-BOTTOM: 2px dashed #094a72; BORDER-RIGHT: 2px dashed #094a72; width: 100px; height:10px; z-index: 10 }
</style>

<script>
smAddMenu(0,"32","32",1);
smAddRow(0,"FASTA","showFASTA.html");
smAddRow(0,"Get Rec","GR.html");

</script>

</head><body onresize="changeObjectVisibility('LoadingPopUp', 'visible');">
<DIV onclick='event.cancelBubble = true;' class=sm id=seqMenu>
<table width="100%" cellpadding=0 cellspacing=0>
<tr class=smTitle><td id=seqMenuTitle></td><td align=right><a class=closeLink href='#' onclick='hideCurrentPopup(); return false;' style='color:black;font-weight:bold;text-decoration:none;'>X</a></td></tr>
<tr><td class=smRow id=seqMenuRow0></td></tr>
<tr><td class=smRow id=seqMenuRow1></td></tr>
<tr><td class=smRow id=seqMenuRow2></td></tr>
<tr><td class=smRow id=seqMenuRow3></td></tr>
<tr><td class=smRow id=seqMenuRow4></td></tr>
<tr><td class=smRow id=seqMenuRow5></td></tr>
<tr><td class=smRow id=seqMenuRow6></td></tr>
<tr><td class=smRow id=seqMenuRow7></td></tr>
<tr><td class=smRow id=seqMenuRow8></td></tr>
<tr><td class=smRow id=seqMenuRow9></td></tr>
<tr><td class=smRow id=seqMenuRow10></td></tr>
</table>
</DIV>
<div class=seqHLc id=seqHL> 
</div>
<div onclick='event.cancelBubble = true;' class=Loadingpopup id=LoadingPopUp>
<center>
<font id=message>Optimizing Image <br> Please wait</font>
</center>
</div>

<div id='tview_div' style='height:300px;overflow:auto;'>
$regionHTML
</div>
<DIV ID='scrollMarker' onClick='scrollTo(parseFloat($mousex_ref));'></DIV>
<DIV id='scrollDIV'></DIV>
<script>
<!--
var jg = new jsGraphics('scrollDIV');
jg.setColor('\#00ff00');
jg.setStroke(2);
-->
</script>
</body></html>
END_graph

open(CLF,">${TMPDIR}CL${$}_graph.html");
print CLF $graphHTML; 
close(CLF);




######################## GENOME NAME Frame (clgenomename) ##########################################
open(CLF,">${TMPDIR}CL${$}_genomename.html");
my $gSRC = (exists($cgi_paramHR->{altCONTEXT}))?"$cgi_paramHR->{altCONTEXT} gi|$cgi_paramHR->{gseg_gi}|":"Chromosome $cgi_paramHR->{chr}";
my $namehtml = <<END_OF_NAMEHTML;
<html>
<head><style>body {margin:0px; padding:0px;}</style></head>
<body>
<font color=black style="font-size:12px" face=Courier>${gSRC}</font>
</body>
</html>
END_OF_NAMEHTML

print CLF $namehtml;
close(CLF);


################################ Genomic Sequence Frame (clgenomeseq) ##############################
open(CLF,">${TMPDIR}CL${$}_genomeseq.html");

my $gseqhtml = <<END_OF_GSEQ;
<html><head>
<script type="text/javascript" src="${JSPATH}TV_genomeseq.js"></script>
<STYLE>
body { margin:0px; padding:0px; }
DIV#gSeq{ padding:0px 5px; margin:0px; white-space:nowrap; color:black; font:normal 14px Courier,monotype; vertical-align:top; }
</STYLE>
</head>
<body>
END_OF_GSEQ

$gseqhtml .= "<DIV id='gseq'>";
$gseqhtmlI = "";
while(length($gapped_gseg) > 1000){
  $gseqhtmlI .= "<u>" . substr($gapped_gseg,0,1000) . "</u>";
  substr($gapped_gseg,0,1000) = "";
}
if(length($gapped_gseg)){
  $gseqhtmlI .= "<u>" . substr($gapped_gseg,0,1000) . "</u>";
}
$gseqhtml .= $gseqhtmlI;
$gseqhtml .= <<END_OF_GSEQ2;
</DIV>
</body>
</html>
END_OF_GSEQ2

print CLF $gseqhtml;
close(CLF);


######################## NAMESG Frame (clqnames) ##########################################
open(CLF,">${TMPDIR}CL${$}_qnames.html");

print(CLF 
      "<html><head><style>body {margin:0px; padding:0px;} \n
  DIV.nSeq {padding:0px 5px; margin:1px 0px; white-space:nowrap; font:normal 14px Courier,monotype;}\n
  </style>
  </head><body>");

for($x=0;$x<=$#$qseqAR;$x++){
  print(CLF
	"<DIV ID='$$qseqAR[$x][0]s' class='nSeq'>",
	"<font style='color:$$qseqAR[$x][5];cursor:pointer' onClick=\"top.frames[2].focusStruct('$$qseqAR[$x][0]');\" onMouseOver=\"top.frames[2].focusStruct('$$qseqAR[$x][0]');\" onmouseout=\"top.frames[2].unfocusStruct();\">$$qseqAR[$x][1]</font>",
	"</DIV>\n");

	#"<tr ID='$$qseqAR[$x][0]s'><td nowrap>",
	#"<font color='$$qseqAR[$x][5]' style=\"font-size:14px;\" face=\"Courier\">$$qseqAR[$x][1]</font>",
	#"</td></tr>\n");
}

print CLF "<DIV ID='spacer' class='nSeq'><BR><BR><BR></DIV>\n";
print CLF '</body></html>';
close(CLF);


######################## Query Sequences Frame (clqseq) ##########################################
open(CLF,">${TMPDIR}CL${$}_qseq.html");

print(CLF
      "<html><head>\n",
      "<script type=\"text/javascript\" src=\"${JSPATH}TV_qseq.js\"></script>\n",
      "<STYLE>\n",
      "body {margin:0px; padding:0px;}\n",
      "DIV.qSeq {padding:0px 5px; margin:1px 0px; white-space:nowrap; color:black; font:normal 14px Courier,monotype;}\n",
      "</STYLE>\n",
      "</head>",
      "<body leftmargin=0 topmargin=0 marginwidth=0 marginheight=0>",
      "<form name='seqsform' method=post>",
     );
my $maxLength = 0;
for($x=0;$x<=$#$qseqAR;$x++){
  print(CLF
	"\n<DIV CLASS='qSeq' id='$$qseqAR[$x][0]'>");

  while(length($$qseqAR[$x][2]) > 1000){
    my $len = 1000;
    while(!((substr($$qseqAR[$x][2],($len-1),1) eq '_') ||
	    (substr($$qseqAR[$x][2],($len-1),1) eq 'A') ||
	    (substr($$qseqAR[$x][2],($len-1),1) eq 'T') ||
	    (substr($$qseqAR[$x][2],($len-1),1) eq 'C') ||
	    (substr($$qseqAR[$x][2],($len-1),1) eq 'G') ||
	    (substr($$qseqAR[$x][2],($len-1),1) eq ';') ||
	    (substr($$qseqAR[$x][2],($len-1),1) eq '>'))){
      $len--;
    }
    my $seqFrag = substr($$qseqAR[$x][2],0,$len);
    $seqFrag =~ s/(_+)/\<font color='white'\>$1\<\/font\>/;
    print(CLF "<span>$seqFrag</span>");
    substr($$qseqAR[$x][2],0,$len) = '';
  }
  if(length($$qseqAR[$x][2])){
    my $seqFrag = substr($$qseqAR[$x][2],0,1000);
    $seqFrag =~ s/(_+)/\<font color='white'\>$1\<\/font\>/;
    print(CLF "<span>$seqFrag</span>");
  }
  $maxLength = ($maxLength > length($$qseqAR[$x][2])) ? $maxLength : length($$qseqAR[$x][2]);
  print(CLF
	"</DIV>\n",
	"<input type=hidden name='$$qseqAR[$x][0]start' value='$$qseqAR[$x][3]'>\n",
	"<input type=hidden name='$$qseqAR[$x][0]stop' value='$$qseqAR[$x][4]'>\n");
}
print(CLF
     "<DIV class='qSeq' id='widthSpacer' style='color:white;'>",
     $gseqhtmlI,
     "</DIV>");
print(CLF
      "</form>",
      end_html());
close(CLF);


############################## Main frameset layout ##############################################

PRINT_FRAMESET:
### Kludge to grow/shrink the width of the query sequence identifer/names frame ####
my $qnameFrameWidth = (defined($transcriptViewQueryNameFrameWidth))?$transcriptViewQueryNameFrameWidth:125;
#########

my $INFOjs = "\n<script language='Javascript'>\n";
foreach $pgsID (keys %$pgsstatHR){
  $pgsstatHR->{$pgsID}[6] =~ s/\'/\\\'/g;
  $INFOjs .= ("var GSQ${pgsID} = new Array ('" . join("','",@{$pgsstatHR->{$pgsID}}[0..6]) . "');\n");
}
foreach $pgsID (keys %$exstatHR){
  $INFOjs .= ("var GSQex${pgsID} = new Array ('" . join("','",@{$exstatHR->{$pgsID}}) . "');\n");
}
foreach $pgsID (keys %$instatHR){
  $INFOjs .= ("var GSQin${pgsID} = new Array ('" . join("','",@{$instatHR->{$pgsID}}) . "');\n");
}
$INFOjs .= "</script>\n";

my $imgwidth = (exists($cgi_paramHR->{imgW}))?$cgi_paramHR->{imgW}:600;
my $FRAMEhtml = <<END_OF_FRAMEHTML;
<INPUT type='hidden' name='imgW' value=${imgwidth}>
<frameset rows="70,300,20,*" frameborder=0 onresize="setIMGW();" $onLoad>
  <frame name="clinfo" ${srcSwitch}src="${HTMLSTAT}CL_info.php?GDB=$GDB" scrolling=no marginheight=0 marginwidth=0 noresize> 
  <frameset cols="${qnameFrameWidth},*" frameborder=0>
     <frame name="clinfoPlus" ${srcSwitch}src="${HTMLSTAT}CL_infoPlus.php?GDB=$GDB" scrolling=no marginheight=0 marginwidth=0 noresize>
     <frame name="clgraph" ${srcSwitch}src="${DIR}CL${$}_graph.html" scrolling=no marginheight=0 marginwidth=0 noresize>
  </frameset>
  <frameset cols="${qnameFrameWidth},*" frameborder=0>
     <frame name="clgenomename" ${srcSwitch}src="${DIR}CL${$}_genomename.html" scrolling=no marginheight=0 marginwidth=0 noresize>
     <frame name="clgenomeseq" ${srcSwitch}src="${DIR}CL${$}_genomeseq.html" scrolling=no marginheight=0 marginwidth=0 noresize>
  </frameset>
  <frameset cols="${qnameFrameWidth},*" frameborder=0>
    <frame name="clqnames" ${srcSwitch}src="${DIR}CL${$}_qnames.html" scrolling=no marginheight=0 marginwidth=0>
    <frame name="clqseq" ${srcSwitch}src="${DIR}CL${$}_qseq.html" scrolling=auto marginheight=0 marginwidth=0>
  </frameset>
</frameset>
END_OF_FRAMEHTML

print(header,
      "<HTML><HEAD>",
      title("Transcript View - $SITENAMEshort"),
      "<script type=\"text/javascript\"  src=\"${JSPATH}TV_main.js\"></script>",
      $INFOjs,
      "</HEAD>\n$FRAMEhtml   </html>"
     );






