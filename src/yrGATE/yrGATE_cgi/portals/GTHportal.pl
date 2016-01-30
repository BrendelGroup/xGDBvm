#!/usr/bin/perl -I/xGDBvm/XGDB/perllib/ -I/xGDBvm/XGDB/perllib/DSO -I/xGDBvm/src/yrGATE/yrGATE_cgi/
# yrGATE portal for template

#use LWP::Simple;
use CGI ":all";
use LWP::UserAgent;
use HTTP::Request::Common qw(POST);

require 'yrGATE_conf.pl';
require 'yrGATE_functions.pl';
require 'GSQDB.pm';
require 'GDBgui.pm';
do 'SITEDEF.pl';


#global variables
my $BSSMDIR = "/usr/local/bin/bssm";
#my $GDB= new GSQDB($cgi_paramHR);
#my $GDBpage = new GDBgui();

my $FastaFormat = a({-href=>'http://www.ncbi.nlm.nih.gov/BLAST/fasta.html'}, 'FASTA format');
my $gth = "/usr/local/bin/gth";

#CGI parameters
my $GDBname = param('GDB');
$xGDB = param('GDB');

# Determines whether database is BAC-based or chr-based,
# depending on whether $DB is included in @bac or @chr.
my $DNA = param('DNA');
my $DNAfile = param('DNAfile') ;
my $PROTEIN = param('PROTEIN');
my $PROTEINfile = param('PROTEINfile');
my $TRANSCRIPT = param('TRANSCRIPT');
my $TRANSCRIPTfile = param('TRANSCRIPTfile');
my $Species = param('Species');
my $Submit = param('Submit');
#for accepting DNA as gi ****Secret function****
my $DNAid = param('DNAid');
my $DNAstart = param('DNAstart');
my $DNAend = param('DNAend');
my $PROTEINid = param('PROTEINid');
my $PROTEINseq = param('PROTEINseq');

my $DNAseq;
my $range;
my $DNAlength;
my $command ="echo \"select length(seq) from gseg where gi='$DNAid'\"|mysql -pxgdb -u gdbuser $xGDB -N";
print STDERR "jjjjjjjjjjjj $command\n";
$DNAlength = qx(echo "select length(seq) from gseg where gi='$DNAid'" |mysql -pxgdb -u gdbuser $xGDB -N);
$DNAlength =~ s/\n//;
print STDERR "$xGDB $DNAlength jjjjjjjjjjjjjjjjjjjjjj \n";

if ($xGDB && $DNAid && $DNAstart && $DNAend ) {
	$range=$DNAstart.'-'.$DNAend;
	if ($DNAlength < $DNAend){
		$range=$DNAstart.'-'.$DNAlength;
	}
	$DNAseq = qx(/usr/local/bin/blastdbcmd -db /xGDBvm/data/${xGDB}/data/BLAST/${xGDB}scaffold -entry $DNAid -range $range);
	$DNA = "$DNAseq";
}else{
	$DNAseq = &FASTAseq($DNAid);

	shift @DNAseqs;
	my @DNAseqs = split(/\n/, $DNAseq);
	$DNAseq = join('', @DNAseqs);
	$DNAseq =~ s/\W+//g;

	if($DNAstart>$DNAend){
		my $tmp = $DNAstart;
		$DNAstart = $DNAend;
		$DNAend = $tmp;
	}
	my $skip = $DNAstart - 1;
	my $len = $DNAend - $DNAstart + 1;
	if($DNAid && $DNAstart && $DNAend){
		$DNA = substr($DNAseq, $skip, $len);
		$DNA = ">$DNAid\n$DNA";
	}
}
if($PROTEINid && $PROTEINseq){
    $PROTEIN = ">$PROTEINid\n$PROTEINseq\n";
}

###############################
###  main code starts here  ###
###############################

if($DNAfile){#have upload file
        my $tempSeq = "";
        while(<$DNAfile>){
                $tempSeq .= $_;
        }
        $DNA = $tempSeq;
}
if($PROTEINfile){#have upload file
        my $tempSeq = "";
        while(<$PROTEINfile>){
                $tempSeq .= $_;
        }
        $PROTEIN = $tempSeq;
}
if($TRANSCRIPTfile){#have upload file
        my $tempSeq = "";
        while(<$TRANSCRIPTfile>){
                $tempSeq .= $_;
        }
        $TRANSCRIPT = $tempSeq;
}


## create page

my ($PAGE_CONTENTS,$seq,$msg);
print STDERR "$xGDB ggggggggggggggggggggmmmmmmmmmmmmmmmm \n";
if(!$Submit){
    &DisplayForm($xGDB,$Species, $DNA, $PROTEIN, $TRANSCRIPT);
}else{
	$xGDB = "GDB001";
    &Search($xGDB,$Species, $DNA, $PROTEIN, $TRANSCRIPT);
}

sub DisplayForm{
    my ($xGDB,$Species, $DNA, $PROTEIN, $TRANSCRIPT) = @_;
    $PAGE_CONTENTS .= "<script type=\"text/javascript\">
           //<![CDATA[
    function exampleDisplay (form) {
       form.DNA.value=\">gi48374974 BAC 
fragment\\nAACTGCACGCTGTAGCCATCCACCCTACCATTTTATCAACAGAACAAGATAATCTCAACCGTTGCAAGAG\\nTCATGCATGCACTATGGTTGAAGCATGATAAAAGGAACTACATACCATTGCTGAATTTTTCTAAACTCTG\\nACAGTACAGGATAGATGTTTTCGAAGGCAGTGTAGGTCTCCTCTCTCACCTACAAACAATGGAGTATGAA\\nATGAAGGGAAAAGAGAAGCAAATGGCGGTATTATTAAGCATGTGCAAGAAGAAATGACGACTAACCTTTG\\nCTCCAGTCAAAACAATCTTGCCTGAAACAAAAATTAAAAGAACAATCTTTGGTTGTTTCATCCGATAGAT\\nAAGGCCAGGAAAGAGTTCTGGTTCGTACTATAAAACAAATGAAAAATGTCATTATCCAAGAATGCAGACA\\nAAAAGGGTAAAAGAATTACTGTGGTGATAAAATAAACCATCCTTGGACATACACTTGAGAAGGCACCATG\\nAGAATATGCAAGGCCCTCAAGCCTAATTGGAAACTTGACATCACAAGAGCCAACAATATTCTGAATCTTA\\nAAATCCTGGCTTAGAACAGCAACTTAGCAACTGATGTACATATTGTTCAAAGAACAGGTCAATGTACACA\\nAGTATGAAAAAGTTACCTTAAACTTAGCTGGAAAACCAAGTTTCTGAATAATGCGGGCATACTGGAAATA\\nCAGACAAGTGTTATAATGCAGAAGCCTCTCCGTAAACTAGATCCAACTTAAATAAAATGATATCAAGCCA\\nTATCACACCTTCCTTGCTGCAAGCTTGGATTGCTGTTCACTCTTCGCTCCAGTACATACCTAGAAAATTA\\nCGGGCCACTTGTTTCAGCACTACAACACTTATGATGGGTTGATACAAGATTGTAGTTTTATATGAAAGAA\\nATGCAGTTCTAACTTTTTCATTTGGAAGAGAAGTATTGATGCATCAATGCATTAAACCAATATTTAATAT\\nGACAACCAAGAAAGTCTAGATTACTGAAGATATTGATAAAAACAAAATCCCAAGTAAACACCCACCGTGA\\nTATATCAACTGGTAAGGAAAACATAGATTTTCCTAGTGTAGGCTACAGAGGGTAAGAACGTTATTCTTCA\\nATACTTGATGATTGAGAGGTAGATTGGGACACAGCAAAAACAGATCAAATCTCACGTAGGCCACATGTGC\\nAACAATAATTTGATGTCAATAAATTTAATAGAAGGGAAATTCTGCCACCAAAAGTAAGCAAATCCTTGAA\\nAATTGACAGTATAAGAGAAGACATTGATGACATACCATTTTACCCGATGCAAATATCAGTGCTGTGGTTT\\nTGGGTTCTCTTATTCTCATGATGACTGCAGCAAAACGCTGTTTACAGATAAAAGGGTCAAGATAAAAATA\\nTAATAATAGAGAGAAAACTTAGCAAAAACCAGCATGTGACATTATATCATTATCATCATAACTGAGAAAG\\nACTGCATTCAATAGAATGCCCTAAGAGCAAGCAAGTCATATAGAAGCTGAAAATTTGTCGAAGAATATTG\\nTGGTTATTCACAGATATGAGCATGCAGCTGGTTCAAAATTAACCACACACATCTCATATGCCAGGCCATC\\nCAAGCACAAAGTTATTTGAACACCGACAAGATTGCACATCATTACAAAGGAAAAAGGATCAACATGTGTT\\nGTATATCCATGAAATCATATGCTAGATACAACCACCAGGAAATACCGTACAAAGCCATTGCTTTGAGATA\\nATCAGTATACCTTTGGGTTATACTCCGCATTTCGTGCTTGCAAAGCTATTGCTTTGAGGTCAAGTTTACA\\nATCCAAATTAACTGTTGATACGATATTCCTGTCATGAAAAAATGACATCACATCAAGCAGACAATGATTG\\nAAGAACTTCAGTAAACATGTGAATTTTGTTTTGTAAAAGCAACATATGATTCTTATTGTAAGTTTTTAGC\\nATTGTAGGGACACTACAAAATGATTTTCATCATTCCTTTTCATATGATATGCGTGCTATTAATTTCTTGT\\nTCCTGCCAATTTCCAACATGTACAAAACTACAAATCATAATAAATGTAAGACTATCATTCAAGATAACCT\\nACATTATAATGGTTGGATCATAAAAAGTTTTGTATCAAAGTCATTTCAGGACTCGTTGTGGCACTAATAA\\nGCAAATAGCACTTAAATCCCACACGAAGTTGAAATCTCCTGTAGATTTTTTACCTAAATCATAATAAAAA\\nATCTTTCACAAAAACCAGTCCCTTAGGTTGCTTTTGGTTTGGACACTAAGTAGGATGGAATGGTCATGTC\\nCCTATTTTTTGGGCGGAATTGACCCAGCTCTTGTTTGGTTGGAGGGATATGTCCATTCCAATTTTTGTTT\\nAGTTTGAAGGATTTGGTGGGATGAAACCAGCTGGTGTATTAATGCCACCATGGCACCACCAGCCATTGTC\\nTCTACACCTATCCTTGTTGCCTTCTTCGTGTGAGCAAAGCCTGATTTTCAA\";

      form.PROTEIN.value=\">gi78708692 Transcription factor TFIID protein\\nMAAAAVDPMALGLGTSGGGGGGESAVGGDGAEPVDLVEHPSGIVPTLQNIVSTVNLDCRLDLKKIALQAR\\nNAEYNPKRFAAVIMRIRDPKTTALIFASGKMVCTGAKSEDHSKLAARKYARIVQKLGFPAKFKDFKIQNI\\nVGSCDVKFPIRLEGLAYSHGAFSSYEPELFPGLIYRMKQPKIVLLIFVSGKIVLTGAKYRKEIYAAFENM\\nFPVLTEYRKTQQR\";

      form.TRANSCRIPT.value=\">gi28985581 maize EST 
sequence\\nTTTTTTTTTTTTTTTTCGGGGCAAAATTTTATCTACTCTTGTTAGCACTTGACTCAAGTTAACGCTGCAA\\nCCACATGGGAGAAGCACGTACCCTTCAGTTCACACAAACTACTCAAACTGAGACATGATGTGGGGCGTCC\\nGTGTTCACCAAGGCCTACCCAAATGGATGAACTCGACATGTCCACCAGTTACCACAGCAAGCCCACCCAA\\nTACTGACAGACCGCGGCTCACAGAGATTACAGGATGCTATAAGTTCCGCCAGACTTTTATGTACATTTAG\\nAATTCATGGTCACACGAGAATCCTCGAGGAAGCTTGTAATTTGAAGAACGTGACCTTCACATCACATGTC\\nATCATTGCTGAATTTTTCTAAACTCTGACAGTACAGGATAGATGTTTTCGAAGGCAGTGTAGGTCTCCTC\\nTCTCACCTTTGCTCCAGTCAAAACAATCTTGCCTGAAACAAAAATTAAAAGAACAATCTTTGGTTGTTTC\\nATCCGATAGATAAGGCCAGGAAAGAGTTCTGGTTCGTAACTTGAGAAGGCACCATGAGAATATGCAAGGC\\nCCTCAAGCCTAATTGGAAACTTGACATCACAAGAGCCAACAATATTCTGAATCTTAAAATCCTTAAACTT\\nAGCTGGAAAACCAAGTTTCTGAATAATGCGGGCATACTTCCTTGCTGCAAGCTTGGATTGCTGTTCACTC\\nTTCGCTCCAGTACATACCATTTTA\";
     }
	//]]>
    </script>";
	$PAGE_CONTENTS .= "<h1 class=\"bottommargin1\">GenomeThreader</h1>\n";
        $PAGE_CONTENTS .= "<div style=\"margin-left:2em; clear:right\">\n";
        $PAGE_CONTENTS .= "<div style=\"width: 650px\"><p><b>The GenomeThreader server allows you to perform spliced alignment of protein or EST/cDNA sequences to genomic DNA. Please follow
the steps below. <b>Sequences must be provided in $FastaFormat</b>.";
    $PAGE_CONTENTS .= '<p>';
	$PAGE_CONTENTS .= start_multipart_form();
        $PAGE_CONTENTS .= "<form action=\"${CGIPATH}GenomeThreader.pl\" method=\"post\">\n";
        $PAGE_CONTENTS .= '<input type="button" name="examplebutton" value="Try an example" onclick="exampleDisplay(this.form)" />';
    my $DNAbox;
    if(defined $DNA){
        $DNAbox = textarea(-name=>'DNA',-rows=>2,-cols=>80, -value=>$DNA);
    }else{
        $DNAbox = textarea(-name=>'DNA',-rows=>2,-cols=>80);
    }
    $PAGE_CONTENTS .= "<b>Step 1:</b> Paste <b>genomic DNA</b> sequences here:<br />$DNAbox<br />";
    my $DNAupload = filefield(-name=>'DNAfile', -size=>40);
    $PAGE_CONTENTS .= "<br /><b>or</b> upload genomic sequences from $DNAupload<br /></p>";

    $PAGE_CONTENTS .= '<p>';
    my $PROTEINbox;
    if(defined $PROTEIN){
        $PROTEINbox = textarea(-name=>'PROTEIN',-rows=>2,-cols=>80, -value=>$PROTEIN);
    }else{
        $PROTEINbox = textarea(-name=>'PROTEIN',-rows=>2,-cols=>80);
    }
    $PAGE_CONTENTS .= "<b>Step 2:</b> If you want to match the above genomic DNA against <b>protein</b> sequences, paste protein sequences here:<br />$PROTEINbox<br />";
    my $PROTEINupload = filefield(-name=>'PROTEINfile', -size=>40);
    $PAGE_CONTENTS .= "<br /><b>or</b> upload proteins from $PROTEINupload<br /></p>";

    $PAGE_CONTENTS .= '<p>';
    my $TRANSCRIPTbox;
    if(defined $TRANSCRIPT){
        $TRANSCRIPTbox = textarea(-name=>'TRANSCRIPT',-rows=>2,-cols=>80, -value=>$TRANSCRIPT);
    }else{
        $TRANSCRIPTbox = textarea(-name=>'TRANSCRIPT',-rows=>2,-cols=>80);
    }
    $PAGE_CONTENTS .= "<b>Step 3:</b>If you want to match the above genomic DNA against <b>EST/cDNA</b> sequences, paste EST/cDNA sequences here:<br />$TRANSCRIPTbox<br />";
    my $TRANSCRIPTupload = filefield(-name=>'TRANSCRIPTfile', -size=>40);
    $PAGE_CONTENTS .= "<br /><b>or</b> upload EST/cDNA from $TRANSCRIPTupload<br /></p>";

    $PAGE_CONTENTS .= '<p>';
    $PAGE_CONTENTS .= "<b>Step 4:</b> Select a splice site model: ";
    $PAGE_CONTENTS .= "<select name=\"Species\">\n";
    if(defined $Species){
	$PAGE_CONTENTS .= "<option value=\"$Species\">$Species</option>\n";
    }else{
	$PAGE_CONTENTS .= "<option value=\"maize\">maize</option>\n";
        $PAGE_CONTENTS .= "<option value=\"rice\">rice</option>\n";
        $PAGE_CONTENTS .= "<option value=\"medicago\">Medicago</option>\n";
        $PAGE_CONTENTS .= "<option value=\"arabidopsis\">Arabidopsis</option>\n";
        $PAGE_CONTENTS .= "<option value=\"yeast\">yeast</option>\n";
        $PAGE_CONTENTS .= "<option value=\"rat\">rat</option>\n";
        $PAGE_CONTENTS .= "<option value=\"mouse\">mouse</option>\n";
        $PAGE_CONTENTS .= "<option value=\"chicken\">chicken</option>\n";
        $PAGE_CONTENTS .= "<option value=\"human\">human</option>\n";
        $PAGE_CONTENTS .= "<option value=\"drosophila\">Drosophila</option>\n";
        $PAGE_CONTENTS .= "<option value=\"nematode\">nematode</option>\n";
        $PAGE_CONTENTS .= "<option value=\"aspergillus\">Aspergillus</option>\n";
	$PAGE_CONTENTS .= "<option value=\"undefined\">undefined</option>\n";
    }
    $PAGE_CONTENTS .= "</select></p>\n";

    $PAGE_CONTENTS .= '<p>';
    $PAGE_CONTENTS .= "<b>Step 5:</b> ";
	$PAGE_CONTENTS .= submit(-name=>'Submit', -value=>'Submit');
        $PAGE_CONTENTS .= "&nbsp; or &nbsp;";
        $PAGE_CONTENTS .= reset(-name=>'Reset', -value=>'Reset');
    $PAGE_CONTENTS .= endform;
	$PAGE_CONTENTS .=  "</p></div><!--end maincontents --></div><!--end maincontentscontainer -->";
}

sub Search{

    my ($xGDB, $Species, $DNA, $PROTEIN, $TRANSCRIPT) = @_;
	print STDERR "hhhhhhhh $xGDB kkklllllkkkkklllll \n";
    if($DNA !~ />/ || ($PROTEIN =~ /\w/ && $PROTEIN !~ />/) || ($TRANSCRIPT =~ /\w/ && $TRANSCRIPT !~ />/)){
        $PAGE_CONTENTS .=  '<h3 class="warning">At least one of your sequences is NOT in the FASTA format!</h3>';
        exit;
    }
    my $timestamp = int(time());
    #print STDERR "PLANTGDB_TMPDIR=$PLANTGDB_TMPDIR\n";
    my $outDIR = "/xGDBvm/tmp/$xGDB/gth-$timestamp";
    system("mkdir $outDIR");

    open(OUT, ">$outDIR/DNA.fsa") || die ("Cannot open output to write DNA");
    print OUT $DNA;
    close(OUT);
    open(OUT, ">$outDIR/Protein.fsa") || die ("Cannot open output to write Protein");
    print OUT $PROTEIN;
    close(OUT);
    open(OUT, ">$outDIR/Transcript.fsa") || die ("Cannot open output to write Transcript");
    print OUT $TRANSCRIPT;
    close(OUT);

    my $command = " /usr/local/bin/gth -genomic $outDIR/DNA.fsa ";
    $command .= " -protein $outDIR/Protein.fsa " if($PROTEIN =~ /\w/);
    $command .= " -cdna $outDIR/Transcript.fsa " if($TRANSCRIPT =~ /\w/);
    if($Species eq "undefined"){
        $command .= " -o $outDIR/gth_output.txt ";
    }else{
        $command .= " -species $Species -o $outDIR/gth_output.txt ";
    }
    $PAGE_CONTENTS .= "<pre>GenomeThreader command: $command</pre>";
	print STDERR "ZZZZZZZZZZZZZZZZ $command \n";
    #system("( $command ) >/dev/null 2>&1 &");
	$BSSMDIR = "/usr/local/bin/bssm";
    system("export BSSMDIR=\"/usr/local/bin/bssm\";export GTHDATADIR=\"/usr/local/bin/gthdata\";$command");
    my $process;
    $PAGE_CONTENTS .= "<p>The above command is running. When it finishes, you will be automatically redirected to result page at <a href=$SERVER/tmp/$xGDB/gth-$timestamp/gth_output.txt\">$SERVER/tmp/$xGDB/gth-$timestamp/gth_output.txt</a></p>";
    $PAGE_CONTENTS .= "<p>Performing alignment ...";
    while(!defined $process || $process =~ /\w/){
        $process = qx(ps -ef | grep 'gth-$timestamp' | grep -v 'grep');
        $PAGE_CONTENTS .= ".";
    }
    $PAGE_CONTENTS .= "</p>
    <script type=\"text/javascript\">
    //<![CDATA[
    	window.location = \"$SERVER/tmp/$xGDB/gth-$timestamp/gth_output.txt\"
    //]]>
    </script>
	";
}

$cgi_paramHR->{headHR}    = {-cookie=>[$sCookie]};
$cgi_paramHR->{htmlHR}    = {-title=>"${SITENAMEshort} GenomeThreader",
                             -script=>[{-src=>"${JSPATH}BRview.js"}],
                             -style=>[{-src=>'/src/yrGATE/yrGATE.css'}],};
#                            
#$cgi_paramHR->{main}      = $PAGE_CONTENTS;
#$GDBpage->printXGDB_page($cgi_paramHR);
print header();
print "<!DOCTYPE html PUBLIC '-//W3C//DTD XHTML 1.0 Transitional//EN' 'http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd'>
<html xmlns='http://www.w3.org/1999/xhtml' xml:lang='en'>
<head><title>yrGATE Portal to Genome Threader<\/title>
<link href='/XGDB/css/plantgdb.css' type='text/css' rel='stylesheet'>";
print '<link rel="stylesheet" type="text/css" href="/src/yrGATE/yrGATE.css" />';
print '</head>';
print $PAGE_CONTENTS;

sub FASTAseq{
	my $SeqID = shift;
	my $fasta = 0;
	$fasta = qx($PLANTGDB_GETFASTA $SeqID);
	my $PLANTGDB_XGETNCBIFASTA = '/Product/cgi-bin/search/xgetNCBIfasta';
	unless($fasta){
        #if the sequence is not available from PlantGDB, try NCBI
        #print STDERR "PLANTGDB_XGETNCBIFASTA=$PLANTGDB_XGETNCBIFASTA\n";
        $fasta = qx($PLANTGDB_XGETNCBIFASTA $SeqID);
	}
	return $fasta;
}

