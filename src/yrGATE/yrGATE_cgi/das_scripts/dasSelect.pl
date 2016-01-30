#!/usr/bin/perl

use vars qw(
$GV
	    );

use CGI ":all";

require 'yrGATE_conf.pl';
require 'yrGATE_functions.pl';
require 'dasFunctions.pl';

if (!$GV->{dasInput}){
    bailOut("yrGATE with DAS input is not permitted in this configuration.");
}

my $rows = (param("rows") ne "") ? param("rows") : 10;

my $str;
my $dropcookie;
if (param("mode")){
    if ( param("mode") eq "reset" ){
        $str = "";
        #print header();print "resetet <br />";
    }elsif (param("cook")){
	$str = param("cook");
    }else{
      if (param("Site0") ne "" and param("Source0") ne "" and param("EP0") ne ""){
        $str .= join("-:-",("EP",param("Site0"),param("Source0"),param("EP0"),param("start"),param("end")))."-!-";
      }
      for (my $i=1;$i<$rows;$i++){
        if (param("Site$i") ne "" and param("Source$i") ne "" and param("Feat$i") ne "" and param("Color$i") ne "" ){
          $str .= join("-:-",("DAS$i",param("Site$i"),param("Source$i"),param("Feat$i"),param("Color$i")))."-!-";
        }
      }
    }

    $dropcookie = cookie(-name=>'DASsel',
			-value=>[$str]);
}


my ($newEPSite,$newEPSource,$selEPSite,$newEPSource,@entryPoints, $EPsources, $HTML, $selEPSource, @feats, $start,$end, $newFSite,$newFSource,$selFSite,$Fsources,$cookie);


### former selections
#$cookie = "EP-:-http://www.wormbase.org/db/das-:-elegans-:-I-:-1-:-10000-!-DAS1-:-http://www.wormbase.org/db/das-:-elegans-:-EST_match-!-DAS2-:-http://www.wormbase.org/db/das-:-elegans-:-cDNA_match";


my @srows = ($str ne "" || param("mode") eq "reset") ? split /-!-/, $str : dasCookie();
#my @srows =  split /-!-/, $str;

# print form

my @fields = split /-:-/, $srows[0];
$HTML .= "<h1>yrGATE using DAS sources as input</h1><br />";

$HTML .= "<b>DESCRIPTION</b><p>
This is an example implementation of yrGATE (Wilkerson, M.D, Schlueter, S.D. and Brendel, V., in preparation) that uses
<a href='http://www.biodas.org/wiki/Main_Page'>DAS (Distributed Annotation System)</a> servers to display
genome context and gene structure evidence within that context.
yrGATE is primarily designed for use in a community annotation
setting, where gene annotations are submitted to a community resource for storage, sharing and
critique (e.g., <a href='/yrGATE/AtGDB/CommunityCentral.pl'>AtGDB - Arabidopsis community annotation</a>).";
$HTML .= ($GV->{login_required}) ? "" : "This is a stand-alone implementation of the yrGATE Annotation Tool, which allows gene structure
annotations to be saved locally (rather than at the community resource).

This implemenation also highlights the ability of the tool to use heterogeneous evidence sources.</p>

<br />

<p><b>USAGE</b><p>
<ol>
	<li>Select a Genome Entry Point.  This consists of specifying a DAS Reference Server,
	a Data Source served by the selected server, the Genome Segment (typically, chromosome
	number), and Start and End point on the segment.</li>
	<li>Select the feature tracks you would like to use as evidence.</li>
	<li>Click the 'Store Selections' button to save your selections.</li>
	<li>Click the 'Go to the Annotation Tool' button.</li>
</ol>

To view selection choices, click on the 'look up' buttons to the right of the selection
fields and click on the desired entry to populate the selection field.
From within the Annotation Tool, you can change the region of your selected genome segment.</p><br />

Click on any of these example selections and proceed to Step 4 for illustrations of how to use
this tool.<br /><br />";

$HTML .= "<a href='dasSelect.pl?mode=set&cook=EP-%3A-http%3A%2F%2Fwww.wormbase.org%2Fdb%2Fdas-%3A-elegans-%3A-I-%3A-71000-%3A-81500-%21-DAS1-%3A-http%3A%2F%2Fwww.wormbase.org%2Fdb%2Fdas-%3A-elegans-%3A-EST_match%3ABLAT_EST_BEST-%3A-red-%21-DAS2-%3A-http%3A%2F%2Fwww.wormbase.org%2Fdb%2Fdas-%3A-elegans-%3A-cDNA_match%3ABLAT_mRNA_BEST-%3A-skyblue-%21-DAS3-%3A-http%3A%2F%2Fwww.wormbase.org%2Fdb%2Fdas-%3A-elegans-%3A-exon%3ACoding_transcript-%3A-mediumslateblue-%21-DAS4-%3A-http%3A%2F%2Fgenome.cse.ucsc.edu%2Fcgi-bin%2Fdas-%3A-ce2-%3A-blastHg16KG-%3A-peru-%21-'>Sample C. elegans Chromosome I:71000-81500</a><br />\n";

$HTML .= "<a href='dasSelect.pl?mode=set&cook=EP-%3A-http%3A%2F%2Fgenome.cse.ucsc.edu%2Fcgi-bin%2Fdas-%3A-galGal2-%3A-2-%3A-21993000-%3A-22010000-%21-DAS1-%3A-http%3A%2F%2Fgenome.cse.ucsc.edu%2Fcgi-bin%2Fdas-%3A-galGal2-%3A-est-%3A-crimson-%21-DAS2-%3A-http%3A%2F%2Fgenome.cse.ucsc.edu%2Fcgi-bin%2Fdas-%3A-galGal2-%3A-mrna-%3A-blueviolet-%21-DAS3-%3A-http%3A%2F%2Fgenome.cse.ucsc.edu%2Fcgi-bin%2Fdas-%3A-galGal2-%3A-ensGene-%3A-blue-%21-DAS4-%3A-http%3A%2F%2Fgenome.cse.ucsc.edu%2Fcgi-bin%2Fdas-%3A-galGal2-%3A-bgiGene-%3A-cornflowerblue-%21-'>Sample Chicken Chromosome 2:21993000-22010000</a><br />\n";

$HTML .= "<a href='dasSelect.pl?mode=set&cook=EP-%3A-http%3A%2F%2Fgenome.cse.ucsc.edu%2Fcgi-bin%2Fdas-%3A-galGal2-%3A-2-%3A-21040000-%3A-21070000-%21-DAS1-%3A-http%3A%2F%2Fgenome.cse.ucsc.edu%2Fcgi-bin%2Fdas-%3A-galGal2-%3A-est-%3A-crimson-%21-DAS2-%3A-http%3A%2F%2Fgenome.cse.ucsc.edu%2Fcgi-bin%2Fdas-%3A-galGal2-%3A-mrna-%3A-blueviolet-%21-DAS3-%3A-http%3A%2F%2Fgenome.cse.ucsc.edu%2Fcgi-bin%2Fdas-%3A-galGal2-%3A-ensGene-%3A-blue-%21-DAS4-%3A-http%3A%2F%2Fgenome.cse.ucsc.edu%2Fcgi-bin%2Fdas-%3A-galGal2-%3A-sgpGene-%3A-cornflowerblue-%21-'>Sample Chicken Chromosome 2:21040000-21070000</a><br />";

$HTML .= "<a href='dasSelect.pl?mode=set&cook=EP-%3A-http%3A%2F%2Fgenome.cse.ucsc.edu%2Fcgi-bin%2Fdas-%3A-hg17-%3A-2-%3A-152167362-%3A-152416454-%21-DAS1-%3A-http%3A%2F%2Fgenome.cse.ucsc.edu%2Fcgi-bin%2Fdas-%3A-hg17-%3A-refGene-%3A-blue-%21-DAS2-%3A-http%3A%2F%2Fgenome.cse.ucsc.edu%2Fcgi-bin%2Fdas-%3A-hg17-%3A-mrna-%3A-deepskyblue-%21-'>Sample Human 149 exon gene Chromosome 2</a><br /><br />";

$HTML .= "<br /><b>1. GENOME ENTRY POINT</b><br /><br />";
$HTML .= "Reference Server <input type='text' name='Site0' value='$fields[1]'> ".lookUpLink('Site',0)."<br />Data Source (Genome) <input type='text' name='Source0' value='$fields[2]'> ".lookUpLink('Source',0);
$HTML .= "<br />Genome Segment <input type='text' name='EP0' value='$fields[3]'> ".lookUpLink('EP',0)."<br />Start <input type='text' name='start' value='$fields[4]'><br /> End <input type='text' name='end' value='$fields[5]'><br /><br />";

$HTML .= "\n<b>2. EVIDENCE SOURCES</b><br />
<table class='mainT'><tr><td></td><td>Annotation Server</td><td>Data Source</td><td>Feature Type</td><td>Color</td></tr>\n";

for (my $i=1;$i<scalar(@srows);$i++){
  my @fields = split /-:-/, $srows[$i];
  $HTML .= "<tr><td> $i </td><td><input type='text' name='Site$i' value='$fields[1]'> ".lookUpLink("Site",$i)."</td><td><input type='text' name='Source$i' value='$fields[2]'>".lookUpLink("Source",$i)."</td>";
  $HTML .= "<td><input type='text' name='Feat$i' value='$fields[3]'> ".lookUpLink("Feat",$i)."</td><td> <input type='text' size='10' name='Color$i' value='$fields[4]' onChange='setBColor();' >".lookUpLink("Color",$i)."</td></tr>\n";

}
my $ind = (scalar(@srows)>0) ? scalar(@srows) : 1;
for (my $i=$ind;$i<$rows;$i++){
  $HTML .= "<tr><td> $i </td><td><input type='text' name='Site$i' value=''> ".lookUpLink("Site",$i)."</td><td><input type='text' name='Source$i' value=''> ".lookUpLink("Source",$i)."</td>";
  $HTML .= "<td><input type='text' name='Feat$i' value=''> ".lookUpLink("Feat",$i)."</td><td><input type='text' size='10' name='Color$i' value='' onchange='setBColor();'>".lookUpLink("Color",$i)."</td></tr>\n";
}
$HTML .= "</table>";

### 
$HTML .= "<br /><br />
<b>3. SAVE YOUR SELECTIONS OR RESET:</b>
<input type='hidden' name='mode'> <input type='button' class='ll' style='font-size:14px' onclick=\"document.forms.selFrm.mode.value='set';topLink('dasSelect.pl','_self');\" value='Store Selections'> &nbsp;<input type='button' class='ll' style='font-size:14px' onclick=\"document.forms.selFrm.mode.value='reset';topLink('dasSelect.pl?newload','_self');\" value='Reset'><br /><br />
<b>4. ANNOTATE!</b>
";
$HTML .= "<input type='button' class='ll' style='font-size:16px' onclick=\"topLink('../AnnotationTool.pl','_blank');\" target='_blank' value='Go to the Annotation Tool'>";

    print(header(-cookie=>[$dropcookie]));
print "<html><head>";
print "
            <script src='$GV->{JSPATH}utility.txt'></script>
            <script src='$GV->{JSPATH}popup.txt'></script>
            <script src='$GV->{JSPATH}AnnotationTool.php'></script>

<style>
  .mainT{font-family:Arial;font-size:12px;width:800px}
  .ll {color:white;
	cursor: pointer;
	cursor: hand;
	border: solid 1px black;
	background: olivedrab;
	align: top;
	font-size: 10px;
	text-decoration:none;
      }

   ol {font-weight: bold}
   ol span {font-weight: normal;}

  .bt {background:#FFCC33;font-size:20px;border: outset 3px black}
}
</style>

<script>document.getElementById
function lookUp(event,id,num){
  //obj = document.getElementById(id+num);
  x = event.clientX;
  y = event.clientY;

// in target, open and close  document.getElementById(id).style.background = 'yellow';

  source = (document.forms.selFrm['Source'+num].value) ? document.forms.selFrm['Source'+num].value: '';
  site = (document.forms.selFrm['Site'+ num].value) ? document.forms.selFrm['Site'+ num].value: '';
  if (id == 'Color'){
    page = 'selColor';
  }else{
    page = 'dasLookUp';
  }

  window.open('$GV->{CGIPATH}das_scripts/' + page + '.pl?type=' + id + '&num=' + num +'&source=' + source + '&site=' + site,'lookupwin','resizable=yes,top=' + y +',left=' + x +',toolbar=no,status=no,scrollbars=yes,location=yes,menubar=no,directories=no,width=800,height=300');
  
}

function setBColor(){
  for (var i = 1; i < $rows; i++){
    document.forms.selFrm['Color'+i].style.background = 'white';
    document.forms.selFrm['Color'+i].style.background = document.forms.selFrm['Color'+i].value;
  }
  return;
}

function topLink(link,target){
  document.forms.selFrm.action = link;
  document.forms.selFrm.target = target;
  document.forms.selFrm.submit();
}

</script>
<title>yrGATE with DAS input</title>

</head><body onload='setBColor();' class='mainT'><form method='post' name='selFrm'><input type='hidden' name='imgWidth' value='800'>
";

print $HTML;

print "</form><br /></body></html>";




