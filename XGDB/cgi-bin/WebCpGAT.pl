#!/usr/bin/perl -I/xGDBvm/XGDB/perllib/ -I/xGDBvm/XGDB/perllib/DSO/ -I/xGDBvm/XGDB/css -I/xGDBvm/src/yrGATE/ -I/xGDBvm/XGDB/javascripts -I/xGDBvm/XGDB/javascripts/jquery -I/xGDBvm/scripts -I/xGDBvm/XGDB/cgi-bin
# AnnoPipe.pl - A web-based front end for Annotation pipeline
# Last update: Feb 26, 2010 (Ann Fu)


use CGI ":all";
use GSQDB;
use GDBgui;

$gdb = url_param('GDB');  #grab this from the url to construct paths

#use strict vars;
use vars qw(
$GV
$DBH
$PRM
);

# jfd paths for CpGat from yrgate portal else from genome browser
if ($gdb ne "") {
  do '/xGDBvm/data/' . $gdb . '/conf/SITEDEF.pl';
#  do '/xGDBvm/XGDB/perllib/GDBgui.pm';
#  do '/xGDBvm/XGDB/perllib/getPARAM.pl';
  do '/xGDBvm/data/' . $gdb . '/conf/AnnoPipe_conf.pl';
} else {
  do 'SITEDEF.pl';
#  do 'GDBgui.pm';
#  do 'getPARAM.pl';
  do 'AnnoPipe_conf.pl';
}

$cgi_paramHR->{altCONTEXT} = "BAC";
my $GDB = new GSQDB($cgi_paramHR); # required for correct header formatting
my $GDBpage = new GDBgui();

# added 3-29-14 Get mysql password
$dbpass='';
open FILE, "/xGDBvm/admin/dbpass";
while ($line=<FILE>){
$dbpass= $line;
}



#CGI parameters
#if ($xGDB eq "GDB###") {
  #$xGDB = $GV->{dbTitle};
#}


my $dos2unix="/usr/bin/dos2unix";

# my $nomask = param('_nomask');
my $nomask = "T";
my $FLcDNAlist = param('_FLcDNAlist');
my $relax = param('_relax');
my $nopasa = param('_nopasa');
my $gth = param('_gth');
my $RepDB = param('_repdb');
my $RefProtDB = param('_refprotdb');
my $bgf = param('_bgf');
my $augustus = param('_augustus');
my $genemark = param('_genemark');
my $noblast = param('_noblast');
my $nobgf = param('_nobgf');
my $noaugustus = param('_noaugustus');
my $nogenemark = param('_nogenemark');
my $PDB = param('PROTEINfile');
my $TDB = param('TRANSCRIPTfile');
my (@CpGATparameter, $CpGATparameter);

if(!defined $relax){
         $relax = 'F';
 }else{
 $CpGATparameter = "-relax $relax";
 push(@CpGATparameter,$CpGATparameter);
}
if(!defined $nomask){
         $nomask = 'F';
 }else{
 $CpGATparameter = "-nomask $nomask";
 push(@CpGATparameter,$CpGATparameter);
}
if(!defined $nopasa){
         $nopasa = 'F';
 }else{
 $CpGATparameter = "-nopasa $nopasa";
 push(@CpGATparameter,$CpGATparameter);
}
if(!defined $gth){
         $gth = 'undefined';
}
	$CpGATparameter = "-gth $gth";
push(@CpGATparameter,$CpGATparameter);
if(!defined $bgf){
         $bgf = 'maize';
 }
 if(!defined $nobgf){
 
 $CpGATparameter = "-bgf $bgf";
 push(@CpGATparameter,$CpGATparameter);
 }
 
 if(!defined $augustus){
         $augustus = 'maize';
 }
  if(!defined $noaugustus){
  
 $CpGATparameter = "-augustus $augustus";
 push(@CpGATparameter,$CpGATparameter);
 }
 if(!defined $genemark){
         $genemark = 'corn';
 }
  if(!defined $nogenemark){
 $CpGATparameter = "-genemark $genemark";
 push(@CpGATparameter,$CpGATparameter);
 }
 if(!defined $noblast){
         $noblast = 'F';
 }else{
 $CpGATparameter = "-noblast $noblast";
 push(@CpGATparameter,$CpGATparameter);
}
$CpGATparameter = join(' ', @CpGATparameter);
my $DNA = param('DNA');
my $uploadDNAfile = param('uploadDNAfile') ;
my $Species = param('Species');
my $Submit = param('Submit');
my $DefaultFlag=param('DefaultFlag');
my $DNAid = param('DNAid');
my $DNAstart = param('DNAstart');
my $DNAend = param('DNAend');

if ($DNAid && $DNAstart && $DNAend){
$PRM->{gseg_gi}=$DNAid;
$PRM->{start}=$DNAstart;
$PRM->{end}=$DNAend;
} else {
 $DNAid = url_param('dnaID');
 $DNAstart = url_param('start');
 $DNAend = url_param('end');

 $PRM->{gseg_gi}=$DNAid;
 $PRM->{start}=$DNAstart;
 $PRM->{end}=$DNAend;
}

## create page
my ($PAGE_CONTENTS,$seq,$msg);
my $DNAseq;
if ($xGDB && $DNAstart && $DNAend) {
	my $range=$DNAstart.'-'.$DNAend;
	$DNAseq = qx(/usr/local/bin/blastdbcmd -db /xGDBvm/data/${xGDB}/data/BLAST/${xGDB}gdna.fa -entry $DNAid -range $range > /xGDBvm/tmp/${xGDB}CpGATtmp);
        open(my $FILE, "<", "/xGDBvm/tmp/${xGDB}CpGATtmp") or die("Error: could not open ${xGDB}CpGATtmp");
        $DNAseq = "";
        while(<$FILE>)
        {
          chomp();
          $DNAseq .= "$_\n";
        }
	$DNA = "$DNAseq";
	$DNA =~ s/:/from/g;
	$DNA =~ s/-/to/g;
}
###############################
###  main code starts here  ###
###############################
if (!$Submit){

	$PAGE_CONTENTS = "
	<div id=\"cpgat_contents\"> 
	
	<h1 class=\"bottommargin1\">CpGAT - A Comprehensive Pipeline for Genome Annotation</h1>
		<p>
			<b>CpGAT</b> is a comprehensive tool for annotating genomic regions up to 500 kilobases.
			CpGAT uses <a href=\"http://evidencemodeler.sourceforge.net/\">EVM</a> (EVidence Modeler) to evaluate <a href=\"http://www.genomthreader.org\">GenomeThreader</a> protein/transcript spliced alignments together with <i>ab initio</i> gene finder results (<a href=\"http://tlife.fudan.edu.cn/bgf\">BGF</a>, <a href=\"http://exon.biology.gatech.edu/\">GeneMark</a>, and <a href=\"http://augustus.gobics.de/\"> Augustus</a>).
			 In addition, some <a href=\"http://pasa.sourceforge.net/\">PASA</a> functions are used to aggregate splice variant models. Output file formats include <b>GFF3</b>, <b>Gbrowse text</b>, and <b>FASTA</b> (transcript, CDS and translation). 
			 The gene models are also displayed in the xGDBvm genome browser and yrGATE annotation tool.
		</p>
		<div class=\"description showhide topmargin1 bottommargin1\" style=\"clear:none\">
		<p title=\"Show CpGAT help information directly below this link\" class=\"label largerfont\" style=\"cursor:pointer\">How to use this tool (click for more info)...</p>
			<div class=\" hidden\">
			
			 <a title='CpGAT Schema' class='image-button help_link' id='CpGAT_Schema:800:680'>Click to view CpGAT Schema</a>
			 
				<p><b>Selecting input sequence:</b> Genome sequence is automatically uploaded from genome browsers; alternatively, paste or upload genomic sequence (up to 500 kb). Next, select or upload any combination of protein/transcript datasets for spliced-alignment. Finally, select splice models and any additional options, and click <b>Submit</b>. Sequences must be provided in <b>FASTA format</b>.</p>
				
				<p><b>Output</b>: CpGAT may take 2-5 minutes or more to process data, depending on the genome region size and number and size of datasets chosen. When complete, a CpGAT <b>output window</b> will display links to output files in various formats: GFF3, Gbrowse upload, and FASTA. Refresh your genome browser window to view new annotation tracks (listed under User_Auto_Annotation). To remove CpGAT tracks, click <i>Delete Annotation</i> from the output window, and refresh your genome browser again.</p>
			
				<p><b>Reference/Masking Data Sources:</b> The splice-aligned exon ORFs are evaluated for similarity to a reference dataset you select (such as <i>vs.</i> <a href=\"http://www.uniprot.org/uniref/?query=identity%3a0.9+taxonomy%3a33090\">UniRef 90 Viridiplantae</a>) using blastx prior to EVM. Genome sequence is n-masked for GenomeThreader analysis and <i>ab inito</i> gene finding using <a href=\"http://maize.jcvi.org/repeat_db.shtml\">TIGR4.0</a> and <a href=\"http://mips.helmholtz-muenchen.de/plant/genomes.jsp\">MIPS-REdat</a> masking libraries.</p>
				<p>User Parameter Options</p>
				<ul class=\"bullet1	\">
							 <li><b>Skip Mask:</b>  Skip repeat mask for GenomeThreader spliced alignments</li>
							 <li><b>Relax UniRef:</b> Relax requirement for UniRef blast hit for GenomeThreader output</li>
							 <li><b>Skip PASA:</b> Skip pasa_cpp step to avoid potentially artifactual splice variants</li>
							 <li><b>Skip BLAST:</b> Skip transcript/genome BLAST (Default=T because datasets already splice-aligned)</li>
				</ul>
			</div><!--end of hidden div-->
		</div><!--end showhide div-->
		<p><b>See <a href=\"/XGDB/help/cpgat.php#regiontool\">CpGAT Help Page</a> for details on how to use this tool.</b></p>
		<br />
		<hr class=\"featuredivider\" />
    ";
$PAGE_CONTENTS .= "<form action=\"${CGIPATH}WebCpGAT.pl\" method=\"post\">\n";
    $PAGE_CONTENTS .= "</p><br />";

    my $DNAbox;
    if(defined $DNA){
	print STDERR "MMMMMMMMMMMMMMMMM $DNA";
	$DNAbox = textarea(-name=>'DNA',-rows=>10,-cols=>80, -value=>$DNA);
    }else{
	$DNAbox = textarea(-name=>'DNA',-rows=>10,-cols=>80);
    }

	my $PROTEINbox = textarea(-name=>'PROTEINfile',-rows=>1,-cols=>80, value=>'');
	my $TRANSCRIPTbox = textarea(-name=>'TRANSCRIPTfile',-rows=>1,-cols=>80, value=>'');
	my $REPEATbox = textarea(-name=>'_repdb',-rows=>1,-cols=>80, value=>'/xGDBvm/examples/repeatmask/Rc_28153_Repeats.fa');
	my $REF_PROTEINbox = textarea(-name=>'_refprotdb',-rows=>1,-cols=>80, value=>'/xGDBvm/examples/referenceprotein/cegma_core.fa');
    $PAGE_CONTENTS .= "<p><span class=\"showhide_style highlight\">Step 1:</span> If not autofilled, paste <b>genomic DNA</b> sequences here:</p><p class=\"indent2\">$DNAbox</p>";
    my $DNAupload = textarea(-name=>'uploadDNAfile', -rows=>1,-cols=>80);
    $PAGE_CONTENTS .= "<p>...<b>or</b> upload genomic sequences from local file: </p><p class=\"indent2\">$DNAupload<br /></p>";
    $PAGE_CONTENTS .= "<p><span class=\"showhide_style highlight\">Step 2: </span>To use <b>custom protein and/or transcript files, uncheck this box</b> <input type='checkbox'  checked='checked'  name='DefaultFlag' value='On'> and specify files / settings below. Otherwise, <b>skip to step 3.</b>";
    $PAGE_CONTENTS .= "<br /><p class=\"indent2\"><b>protein</b> file: $PROTEINbox<br /></p>";
    $PAGE_CONTENTS .= "<p <p class=\"indent2\"><b>transcript</b> file: $TRANSCRIPTbox</p>";
    $PAGE_CONTENTS .= "<p class=\"indent2\">Select <b>splice site model</b> for optional protein/transcript spliced alignment:</p>";
    $PAGE_CONTENTS .= "<p class=\"hover_pointer bold indent2\" title=\"GenomeThreader is used to splice-align protein/transcript to the genome\">GenomeThreader:</span>&nbsp;";
    $PAGE_CONTENTS .= "<select  name=\"_gth\">\n";
    $PAGE_CONTENTS .= "<option value=\"undefined\">undefined</option>\n";
    #$PAGE_CONTENTS .= "<option value=\"maize\">maize</option>\n";
    $PAGE_CONTENTS .= "<option value=\"rice\">rice</option>\n";
    $PAGE_CONTENTS .= "<option value=\"medicago\">Medicago</option>\n";
    $PAGE_CONTENTS .= "<option value=\"arabidopsis\">Arabidopsis</option>\n";
    $PAGE_CONTENTS .= "</select></p>";

    $PAGE_CONTENTS .= '<br />';
    $PAGE_CONTENTS .= "<p><span class=\"showhide_style highlight\">Step 3:</span> (optional) </b> select a <b>repeat mask file</b> </p><p class=\"indent2\">$REPEATbox</p><br />";
    $PAGE_CONTENTS .= "<p><span class=\"showhide_style highlight\">Step 4:</span> Select species model for <i>ab initio</i> gene finders, or check box to skip:</p>";
	$PAGE_CONTENTS .= '<br />';
    $PAGE_CONTENTS .= "<span class=\"hover_pointer bold\" title=\"BGF is an ab initio genefinder tool\">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;BGF:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span>";
    $PAGE_CONTENTS .= "<select name=\"_bgf\">\n";
    $PAGE_CONTENTS .= "<option value=\"maize\">maize</option>\n";
    $PAGE_CONTENTS .= "<option value=\"rice\">rice</option>\n";
    $PAGE_CONTENTS .= "<option value=\"Arabidopsis\">Arabidopsis</option>\n";
    $PAGE_CONTENTS .= "<option value=\"soybean\">soybean</option>\n";
    $PAGE_CONTENTS .= "</select> <span class=\"hover_pointer bold	\" title=\"Skip BGF GeneFinder\">&nbsp;Skip BGF:</span>&nbsp;<input type='checkbox' name='_nobgf' value=\"T\"></p>\n";
    $PAGE_CONTENTS .= "<span class=\"hover_pointer bold\" title=\"Augustus is an ab initio genefinder tool\">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Augustus:</span>&nbsp;&nbsp;";
    $PAGE_CONTENTS .= "<select name=\"_augustus\">\n";
    $PAGE_CONTENTS .= "<option value=\"maize\">maize</option>\n";
    $PAGE_CONTENTS .= "<option value=\"arabidopsis\">Arabidopsis</option>\n";
    $PAGE_CONTENTS .= "<option value=\"galdieria\">Galdieria (alga)</option>\n";
    $PAGE_CONTENTS .= "<option value=\"tomato\">tomato</option>\n";
    $PAGE_CONTENTS .= "<option value=\"chlamydomonas\">Chlamydomonas</option>\n";
    $PAGE_CONTENTS .= "</select><span class=\"hover_pointer bold	\" title=\"Skip Augustus GeneFinder\">&nbsp;Skip Augustus:</span>&nbsp;<input type='checkbox' name='_noaugustus' value=\"T\"></p>";
    $PAGE_CONTENTS .= "<span class=\"hover_pointer bold\" title=\"GeneMark is an ab initio genefinder tool\">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;GeneMark:&nbsp;&nbsp;</span>";
    $PAGE_CONTENTS .= "<select name=\"_genemark\">\n";
    $PAGE_CONTENTS .= "<option value=\"corn\">maize</option>\n";
    $PAGE_CONTENTS .= "<option value=\"o_sativ\">rice</option>\n";
    $PAGE_CONTENTS .= "<option value=\"m_truncatula\">Medicago</option>\n";
    $PAGE_CONTENTS .= "<option value=\"a_thaliana\">Arabidopsis</option>\n";
    $PAGE_CONTENTS .= "<option value=\"c_reinhardtii\">Chlamydomonas</option>\n";
    $PAGE_CONTENTS .= "<option value=\"barley\">barley</option>\n";
    $PAGE_CONTENTS .= "<option value=\"wheat\">wheat</option>\n";
    $PAGE_CONTENTS .= "</select><span class=\"hover_pointer bold	\" title=\"Skip GeneMark GeneFinder\">&nbsp;Skip GeneMark:</span>&nbsp;<input type='checkbox' name='_nogenemark' value=\"T\"></p>\n";
    $PAGE_CONTENTS .= '<br />';
	$PAGE_CONTENTS .= "<p><span class=\"showhide_style highlight\">Step 5:</span> Specify additional CpGAT options. <i>(hover for description)</i>:</p>";
$PAGE_CONTENTS .= "<table style=\"margin-left:30px\" cellpadding='10'>
                <tr align=\"left\">
                 <th align=\"left\" ><span class=\"hover_pointer\" title=\"Skip repeat mask for GenomeThreader spliced alignments (default since GTH already run). Note ab initios will still use masking if provided\">&nbsp;Skip Mask:</span></th><td><input type='checkbox' checked='checked' name='_nomask' value=\"T\"> &nbsp;&nbsp;</td>
                 <th align=\"left\">&nbsp;<span class=\"hover_pointer\" title=\"Relax requirement for UniRef blast hit for GenomeThreader output\">Relax UniRef:</span></th><td><input type='checkbox' checked='checked' name='_relax' value=\"T\">&nbsp;&nbsp;</td>
                 <th align=\"left\">&nbsp<span class=\"hover_pointer\" title=\"Skip PASA step to avoid potentially artifactual splice variants\">Skip PASA:</span></th><th align=\"left\"></th><td><input type='checkbox' name='_nopasa' check=\"\" value=\"F\">&nbsp;&nbsp;</td>
                <th align=\"left\">&nbsp;<span class=\"hover_pointer\" title=\"Skip transcript/genome BLAST (default since spliced alignment already done)\">Skip BLAST:</span></th><td><input type='checkbox' checked='checked' name='_noblast'  value=\"T\">&nbsp;&nbsp;</td>
                </tr></table>";
    $PAGE_CONTENTS .= '<br />';
    $PAGE_CONTENTS .= "<p><span class=\"showhide_style highlight\">Step 6:</span> Select a reference protein dataset: $REF_PROTEINbox</p><br />";

#    $PAGE_CONTENTS .= "<p><span class=\"showhide_style highlight\">Step 7:</span> Select or create a project track to display these annotations in ".$xGDB." (optional).</p>";
#    $PAGE_CONTENTS .= "<input type=\"text\" name=\"GFFproject\" id=\"GFFproject\" size=30 class=\"ajaxParam\" />"; ###placeholder for additional content from xGDBparseGFF.pl 
    $PAGE_CONTENTS .= "<br /><p><span class=\"showhide_style highlight\">Step 7:</span>";
	$PAGE_CONTENTS .= "&nbsp; Click to submit your CpGAT run: <input type=\"submit\" value=\"Submit\" name=\"Submit\"/><input type=\"reset\" value=\"Reset\" name=\"Reset\"/>
	</p>
	<br />
	</div><!-- end of cpgat_contents div-->";
	#$PAGE_CONTENTS .= "<input type=\"button\" value=\"Submit\" name=\"Submit\" onclick=\"submitTo('${CGIPATH}WebCpGAT.pl');\"/>\n";
	#$cgi_paramHR->{headHR}    = {-cookie=>[$sCookie]};
$cgi_paramHR->{htmlHR}    = {-title=>"CpGAT Inputs-${SITENAMEshort}",
                             -style=>[{-src=>"/XGDB/css/plantgdb.css"}],
                             -style=>[{-src=>"/XGDB/css/superfish.css"}],
                             -style=>[{-src=>"/src/yrGATE/yrGATE.css"}],
                             -style=>[{-src=>"/XGDB/javascripts/jquery/themes/base/ui.all.css"}],
                             -style=>[{-src=>"/XGDB/css/sortable_context_region.css"}],
                             -style=>[{-src=>"/XGDB/css/GDBstyle.css"}],
                             -script=>[{-src=>"${JSPATH}BRview.js"}],
                             -script=>[{-src=>"${JSPATH}superfish.js"}],
                             -script=>[{-src=>"${JSPATH}XGDBheader.js"}],
                             -script=>[{-src=>"${JSPATH}hoverIntent.js"}],
                             -script=>[{-src=>"${JSPATH}default_xgdb.js"}],
                             -script=>[{-src=>"${JSPATH}jquery/jquery-1.3.2.js"}],
                             -script=>[{-src=>"${JSPATH}jquery/ui/ui.core.js"}],
                             -script=>[{-src=>"${JSPATH}jquery/ui/ui.sortable.js"}],
                             -script=>[{-src=>"${JSPATH}jquery/ui/ui.draggable.js"}],
                             -script=>[{-src=>"${JSPATH}jquery/ui/ui.resizable.js"}],
                             -script=>[{-src=>"${JSPATH}jquery/ui/ui.dialog.js"}],
                             -script=>[{-src=>"${JSPATH}jquery/ui/effects.core.js"}],
                             -script=>[{-src=>"${JSPATH}jquery/ui/effects.highlight.js"}],
                             -script=>[{-src=>"${JSPATH}jquery/external/bgiframe/jquery.bgiframe.js"}],

                            };
$cgi_paramHR->{main}      = $PAGE_CONTENTS;

$GDBpage->printXGDB_page($cgi_paramHR);


exit;
}else{
	print header();
	$PageTitle = "CpGAT";
	my $DNA = param('DNA');
        my $uploadDNAfile = param('uploadDNAfile');
	my $DNA_ID;
       
    	if ($DNA =~ /\|(\S+)from(\d+)to(\d+)/){
                $PRM->{gseg_gi}=$1;
		$PRM->{start}=$2;
		$PRM->{end}=$3;
		$DNAid="$PRM->{gseg_gi}"."from"."$PRM->{start}"."to"."$PRM->{end}";
	print STDERR "YOU am here kkkkkkkkkkkkkkkkk $PRM->{gseg_gi} jjjjjj $PRM->{start} lllllll $PRM->{end} \n";
	} 
        my $timestamp = int(time());
        my $outDIR = "/xGDBvm/tmp/";
        $outDIR .= $xGDB."/CpGAT/";
        print STDERR "***\n";
        print STDERR $outDIR;
        if ((-e $outDIR)==0) {
            system("mkdir $outDIR");
        }
    	#$outDIR .= $GV->{ResultTMP}."CpGAT-$timestamp"; ResultTMP bad
        $outDIR .= "CpGAT-$timestamp";
        my $blastDIR = "$outDIR/BLAST";
        my $vmatchDIR = "$outDIR/VMATCH";
    	system("mkdir $outDIR");
    	system("chmod 777 $outDIR");
    	system("mkdir $blastDIR");
    	system("chmod 777 $blastDIR");
    	system("mkdir $vmatchDIR");
    	system("chmod 777 $vmatchDIR");
	system("touch $outDIR/Procedure.LOG");
	open(OUT, ">$outDIR/$DNAid.fsa") || die ("Cannot open output to write DNA");
        if($uploadDNAfile){#have upload file
        my $tempSeq = "";
        while(<$uploadDNAfile>){
                $tempSeq .= $_;
		if ($_ =~ />(\S+)\s+/){
			$DNA_ID=$1;
		}
        }
        print OUT $tempSeq;
	}else{
	$DNA =~ s/lcl\|//g;
	print OUT $DNA;
	system "$dos2unix $outDIR/$DNAid.fsa";
	}
        close(OUT);
 
     my $RepDBFile;
	 my $RepDBParameter;
	   if($RepDB ne ""){
	   	  if ($RepDB =~ /^\S+\/(\S+)$/){
          $RepDBFile=$1;
	      system("cp $RepDB $vmatchDIR");
	      $vmatchindex = "/usr/local/bin/mkvtree -db ${vmatchDIR}/$RepDBFile -dna -pl -allout";
	      system("$vmatchindex");
	      print STDERR "I am here vmatchindex wwwwwwwwwwwwwwwwwwwwwwww $vmatchindex \n";
	      $RepDBParameter = "-repdb ${vmatchDIR}/$RepDBFile";
	      $CpGATparameter=$RepDBParameter." ".$CpGATparameter;
	   }
	}
 
    my $RefProtFile;
	my $RefProtParameter;
	if($RefProtDB ne ""){
	   	if ($RefProtDB =~ /^\S+\/(\S+)$/){
        $RefProtFile=$1;
	    system("cp $RefProtDB $blastDIR");
	    $blastindex = "/usr/local/bin/makeblastdb -in $blastDIR/$RefProtFile -dbtype prot -parse_seqids";
	    system("$blastindex");
	    print STDERR "I am here blastindex wwwwwwwwwwwwwwwwwwwwwwww $blastindex \n";
	    $RefProtParameter = "-refprotdb ${blastDIR}/$RefProtFile";
	    $CpGATparameter=$RefProtParameter." ".$CpGATparameter;
	  }
    } 

	my $command;
        if ($DefaultFlag eq 'On'){
	open(OUT, ">$outDIR/${DNAid}.mRNAgth.tab");
	print STDERR "I am here kkkkkkkkkkkkkkkkk $PRM->{gseg_gi} jjjjjj $PRM->{start} lllllll $PRM->{end} \n";
		system("touch $outDIR/${DNAid}.mRNAgth.tab");
		system("touch $outDIR/${DNAid}.protgth.tab");
		my $query=qx(echo "select * from gseg_est_good_pgs where gseg_gi = '$PRM->{gseg_gi}' &&(r_pos <= $PRM->{end})&&(r_pos>=$PRM->{start})" | mysql -p${dbpass} -ugdbuser $xGDB -N);
		print OUT $query;
		$query=qx(echo "select * from gseg_cdna_good_pgs where gseg_gi = '$PRM->{gseg_gi}' &&(r_pos <= $PRM->{end})&&(r_pos>=$PRM->{start})" | mysql -p${dbpass} -ugdbuser $xGDB -N);
		print OUT $query;
		$query=qx(echo "select * from gseg_put_good_pgs where gseg_gi = '$PRM->{gseg_gi}' &&(r_pos <= $PRM->{end})&&(r_pos>=$PRM->{start})" | mysql -p${dbpass} -ugdbuser $xGDB -N);
		print OUT $query;
		close(OUT);
		open(OUT, ">$outDIR/${DNAid}.protgth.tab");
		$query=qx(echo "select * from gseg_pep_good_pgs where gseg_gi = '$PRM->{gseg_gi}' &&(r_pos <= $PRM->{end})&&(r_pos>=$PRM->{start})" | mysql -p${dbpass} -ugdbuser $xGDB -N);
		print OUT $query;
		close(OUT);
                system ("cut -d\"\t\" -f2 $outDIR/${DNAid}.mRNAgth.tab>$outDIR/${DNAid}_v_mRNAs.list");
                system ("cut -d\"\t\" -f2 $outDIR/${DNAid}.protgth.tab>$outDIR/${DNAid}_v_Peps.list");
        $command = "/xGDBvm/src/CpGAT/fct/cpgat.xgdb.pl -o $outDIR -i $outDIR/${DNAid}.fsa -trans $outDIR/${DNAid}.mRNAgth.tab -prot $outDIR/${DNAid}.protgth.tab $CpGATparameter -nogth T -config_file /xGDBvm/src/CpGAT/CpGAT.conf >& $outDIR/$DNAid.err";
        }else{
	my $err = qx(/usr/local/bin/makeblastdb -in $TDB -dbtype nucl -parse_seqids -out ${blastDIR}transcripts.fa);
	$err = qx(/usr/local/bin/makeblastdb -in $PDB -dbtype prot -parse_seqids -out ${blastDIR}/proteins.fa);
        $command = "/xGDBvm/src/CpGAT/fct/cpgat.pl -o $outDIR -i $outDIR/$DNAid.fsa -trans ${blastDIR}/transcripts.fa -prot ${blastDIR}/proteins.fa $CpGATparameter -config_file /xGDBvm/src/CpGAT/CpGAT.conf >& $outDIR/$DNAid.err";
        }
        print "<pre>CpGAT command: $command</pre>";
	print STDERR "my comannd: gggggggggggggggggggg $command\n";
        system("( $command ) >/dev/null 2>&1 &");
        my $rrate=15;
        $ufname=$outDIR . "/". $DNAid .".filtered.gff3";
        my $url;
        $url = "$GV->{CGIPATH}xGDBwatch-CpGAT.cgi?ufname=$ufname&amp;pdb=$PDB&amp;tdb=$TDB&amp;rrate=$rrate&amp;xgdbFlag=$xGDB&amp;DefaultFlag=$DefaultFlag&amp;RefProtDB=$RefProtDB&amp;CpGATparameter=$CpGATparameter";
        my $process;
        print "<p>The above command is running. When it finishes, you will be automatically redirected to result page at <a href=\"$GV->{CGIPATH}xGDB_CpGATOut.pl?ufname=$ufname&amp;pdb=$PDB&tdb=$TDB&amp;xgdbFlag=$xgdbFlag&amp;CpGATparameter=$CpGATparameter\">$ufname</a></p>";
        print "<p> Performing CpGAT ...";
        print STDERR "$GV->{CGIPATH}xGDB_CpGATOut.pl?ufname=ufname&amp;pdb=$PDB&amp;tdb=$TDB&amp;xgdbFlag=$xgdbFlag&amp;CpGATparameter=$CpGATparameter\">$ufname</a></p>";
        while(!defined $process || $process =~ /\w/){
                $process = qx(ps -ef | grep 'CpGAT-$timestamp' |grep -v 'grep');
        print ".";
        }
        print "</p>
        <script type=\"text/javascript\">
    //<![CDATA[
        window.location = \"$GV->{CGIPATH}xGDBwatch-CpGAT.cgi?ufname=$ufname&amp;pdb=$PDB&amp;tdb=$TDB&amp;rrate=$rrate&amp;xgdbFlag=$xGDB&RefProtDB=$RefProtDB&amp;CpGATparameter=$CpGATparameter\"
    //]]>
    </script>
        ";
print end_html;
}

