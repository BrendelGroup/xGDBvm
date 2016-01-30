#!/usr/bin/perl
use LWP::Simple;
use CGI ":all";
use LWP::UserAgent;
use HTTP::Request::Common qw(POST);

$seq = param('mRNAseq');


sub getPage{
        my $ua = LWP::UserAgent->new(agent => '');
        $link = "http://www.ncbi.nlm.nih.gov/gorf/orfig.cgi";
        %tags = ();
        $tags{'SEQUENCE'} = $seq; # only for first load, is reinserted after this page
        $tags{'acc'} = "";
        $tags{'from'} = "";
        $tags{'to'} = "";
        $tags{'gcode'} = 1;
        @args = param();
        if (join('`',@args) =~ /frame/){
          for (my $i=0;$i<param();$i++){
            if ($args[$i] ne "orfsel"){
              $tags{$args[$i]} = param($args[$i]);
              print STDERR "$args[$i] ".param($args[$i]);
            }
          }
          
        }
        
        if(param('orfsel') eq ""){
         # $tags{'submit'} = "OrfFind";
          $tags{'orf1'} = '1';
       # }elsif(param('nosubmit')){
 
        }elsif(param('orfsel')){
          $tags{'orf'.param('orfsel')} = '1';
        }else{
        }
	$tags{'limit'} = 50;
        my $resp = $ua->request(
                POST $link,
                #Content_Type  => 'form-data',
                Content       => [ %tags ]
        );

        $page1 .= $resp->error_as_HTML unless $resp->is_success;

        if ($resp->is_success){
          $page1 .= $resp->content();
        }else{
          $page1 = "Portal currently unavailable. Please try again later.";
        }
    return $page1;
}




$orfpage = getPage();

#if ($orfpage !~ /ORF/i){
#  $tags{"orf".param('orfsel')} = 1;
#  $orfpage = getPage();
#}

my ($frame,$orfsel,$c1,$c2,$exon_length) = $orfpage =~ /(.)\d<\/td><td align=center><input type=image name=orf(\d+) border=0 src=magenta.gif><\/td><td align=right>(\d+)<\/td><td>..<\/td><\/td><td align=right>(\d+)<\/td><\/td><td align=right>(\d+)<\/td>/i;


$orfpage =~ s/orfig.cgi"/ORFportal.pl" name=mainfrm/;

$orfpage =~ s/SRC="/SRC="http:\/\/www.ncbi.nlm.nih.gov\/gorf\//g;

$orfpage =~ s/src="*(\w+).gif"*/src="http:\/\/www.ncbi.nlm.nih.gov\/gorf\/$1.gif"/ig; 

$orfpage =~ s/<body bgcolor=#f0f0f0>//;
#$orfpage =~ s/<input TYPE=submit value=View/<input TYPE=button value=View onClick="OutPortal();"/i;
$orfpage =~ s/<input TYPE=submit value=View/<input TYPE=button value=View onClick="alert('not available through portal');"/i;
$orfpage =~ s/<h1>ORF Finder \(Open Reading Frame Finder\)/<h1><a href="http:\/\/www.ncbi.nlm.nih.gov\/gorf\/" target=_new>ORF Finder \(Open Reading Frame Finder\)<\/a>/i;

$orfpage =~ s/<input TYPE=image border=0 src="http:\/\/www.ncbi.nlm.nih.gov\/gorf\/blast.gif" name="BLAST" align=center>/<a href=#><img border=0 onClick="Blast();" src="http:\/\/www.ncbi.nlm.nih.gov\/gorf\/blast.gif" name="BLAST" align=center><\/a>/i;
$orfpage =~ s/<input TYPE=image border=0 src="\/gorf\/sixframes.gif"/<input TYPE=button onclick="alert\('not available through portal');" border=0 src="\/gorf\/sixframes.gif"/i;
$orfpage =~ s/<input TYPE=submit value=Accept name=accept>//i;
$orfpage =~ s/<input TYPE=image border=0 src=".+?cognitor.gif">//i;
$orfpage =~ s/<input TYPE=image border=0 src=".+?sixframes.gif" name=trall alt="SixFrames">//i;

($p1,$p2) = $orfpage =~ /(.+?<body.+?>)(.+)/s;
$p2 =~ s/<\/body>\n<\/html>//i;

#my ($orfsel) = $link =~ /(orf\d+)\./;
#my ($frame,$orfsel,$c1,$c2) = $orfpage =~ /(.)\d<\/td><td align=center><input type=image name=orf(\d+) border=0 src=http:\/\/www.ncbi.nlm.nih.gov\/gorf\/magenta.gif><\/td><td align=right>(\d+)<\/td><td>..<\/td><\/td><td align=right>(\d+)<\/td>/;  ## changed 11.5.04 NCBI ORF FINDER CODE CHANGED

my ($proteinseq) = $orfpage =~ /seq" VALUE="\n(\w+)/;

if ($frame eq "-"){
$tempv = $c1;
$c1 = $c2;
$c2 = $tempv;
}

if ((($exon_length - 1) > abs($c1 - $c2)) ){ # fixes error in ORF finder program, coordinate is 1 off in first exon when ORF begins at last base of mRNA, reverse direction
    $c1 = ($c1 > $c2) ? ($c1 + 1 ) : $c1;
    $c2 = ($c2 > $c1) ? ($c2 + 1 ) : $c2;
}

my $lines = int length($proteinseq)/60;
my $proteinseqf, $seqf;
for ($ip=0;$ip<$lines;$ip++){
  $proteinseqf .= substr($proteinseq,60*$ip,60)."\\n";
}
$proteinseqf .= substr($proteinseq,60*$ip,length($proteinseq)-60*$ip);
$lines = int length($seq)/60;
for ($ip=0;$ip<$lines;$ip++){
  $seqf .= substr($seq,60*$ip,60)."\\n";
}
$seqf .= substr($seq,60*$ip,length($seq)-60*$ip);

if ($proteinseqf){
$fastaseqs = ">ORF $orfsel protein\n$proteinseqf";
}

$fastaseqs =~ s/\\n/<br>/g;

if (!$c1 or !$c2){
    print header(); print "No Open Reading Frames, or portal is unavailable. Specify a larger mRNA sequence";
    print $orfpage;
    exit;
}

print header();
print $p1;

print "
<!--$orfsel-->
<script>
function chooseORF(){
  opener.document.forms[opener.formName].orfsel.value = '$orfsel';
  opener.setCoords($c1,$c2);
  window.close();
}

function OutPortal(){
  document.forms.mainfrm.action = 'http:\/\/www.ncbi.nlm.nih.gov/gorf/orfig.cgi?&view=View&ff=' + document.forms.mainfrm.ff.options[document.forms.mainfrm.ff.selectedIndex].value;
  window.open('','PortalOut','resizable=yes,screenX=200,screenY=200,top=200,left=200,toolbar=no,status=no,scrollbars=yes,location=yes,menubar=no,directories=no,width=400,height=400');
  document.forms.mainfrm.target = 'PortalOut';
  document.forms.mainfrm.submit();
  document.forms.mainfrm.action = 'ORFportal.pl';
  document.forms.mainfrm.target = '_self';
}
function Blast(){
  blastlink = 'http://www.ncbi.nlm.nih.gov/blast/Blast.cgi?CMD=Web&LAYOUT=TwoWindows&AUTO_FORMAT=Semiauto&ALIGNMENTS=50&ALIGNMENT_VIEW=Pairwise&CDD_SEARCH=on&CLIENT=web&COMPOSITION_BASED_STATISTICS=on&DATABASE=nr&DESCRIPTIONS=100&ENTREZ_QUERY=%28none%29&EXPECT=10&FILTER=L&FORMAT_OBJECT=Alignment&FORMAT_TYPE=HTML&I_THRESH=0.005&MATRIX_NAME=BLOSUM62&NCBI_GI=on&PAGE=Proteins&PROGRAM=blastp&SERVICE=plain&SET_DEFAULTS.x=41&SET_DEFAULTS.y=5&SHOW_OVERVIEW=on&END_OF_HTTPGET=Yes&SHOW_LINKOUT=yes&GET_SEQUENCE=yes&QUERY=$proteinseq&END_OF_HTTPGET=Yes';
  window.open(blastlink,'blastportal','resizable=yes,screenX=200,screenY=200,top=200,left=200,toolbar=no,status=no,scrollbars=yes,location=yes,menubar=no,directories=no,width=400,height=400');
}
<\/script>
";

print "\n
<table width='100%' cellspacing=0 cellpadding=0>
<tr><td bgcolor=orange></td><td bgcolor=orange><font style='font-family:Arial;font-weight:bold;font-size:24px'>yrGATE Portal to NCBI ORF Finder</font></td></tr>
<tr><td width=100 valign=top bgcolor=orange><font style='font-family:Arial;font-weight:bold;font-size:12px'>
<input type=button style='background:yellow;' value='Select ORF for Annotation' onClick='chooseORF();'>
<br><small>(magenta ORF is the current selection)<br><br><br>coordinates of ORF are relative to transcript<\/small></font><br>
<\/td>
";


if (param('nosubmit')){
$p2 =~ s/<input TYPE=hidden name="gi" value="0">/<input TYPE=hidden name="gi" value="0"><input TYPE=hidden name="nosubmit" value="nosubmit">/i;
}

$p2 =~ s/<input TYPE=hidden name="gi" value="0">/<input type=hidden name=orfsel value="$orfsel"><input TYPE=hidden name="gi" value="0">/i;


print "<\/td><td style='padding:10'>";
print $p2;
print '</td></tr></table><pre>FASTA format:'."\n".$fastaseqs.'</pre></body></html>';

