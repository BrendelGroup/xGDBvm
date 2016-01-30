#!/usr/bin/perl
use CGI ":all";
use GSQDB;
use GDBgui;

do 'SITEDEF.pl';
do 'GDBgui.pl';
do 'getPARAM.pl';

my $db   = param('db');
my $dbid = defined(param('dbid'))? param('dbid') : -1;
my $query = param('query'); 
my $name = param('name');
my $GDB= new GSQDB($cgi_paramHR);
my $GDBpage = new GDBgui();

## create page
my ($PAGE_CONTENTS,$seq,$msg);

if (param('sequence') && param('runBLAST')=~/BLAST/ ) {
  undef($msg);
  if(((param('program') eq 'blastn')||(param('program') eq 'tblastn'))&&($BLAST_DB{$db}->[0] ne 'nucleotide')){
    $msg = 'The peptide database "'. $db .'" is inappropriate for use with the '. param('program') ." program.\n";
  }elsif(((param('program') eq 'blastp')||(param('program') eq 'blastx'))&&($BLAST_DB{$db}->[0] ne 'peptide')){
    $msg = 'The nucleotide database "'. $db .'" is inappropriate for use with the '. param('program') ." program\n";
  }
  if(defined($msg)){
    my $NUCLEOTIDE_DBS = '';
    my $PEPTIDE_DBS = '';
    foreach $blastDB (keys %BLAST_DB){
      if($BLAST_DB{$blastDB}->[0] eq 'peptide'){
	$PEPTIDE_DBS .= "$blastDB / ";
      }else{
	$NUCLEOTIDE_DBS .= "$blastDB / ";
      }
    }
    $PEPTIDE_DBS =~ s/\s+\/\s+$//;
    $NUCLEOTIDE_DBS =~ s/\s+\/\s+$//;

    $PAGE_CONTENTS = $GDB->doBLASTprompt();
    $PAGE_CONTENTS .= "\n<hr /><p><span class=\"warning\">${msg}</p>
	<p class=\"warning\">Please select a valid database/tool combination as shown below:</p>
	<p><strong>Valid Search Combinations:</strong></p>
	<table class=\"featuretable\">
		<tr>
			<th>Query Sequence</th>
			<th>BLAST Progam</th>
			<th>Database(s)</th>
		</tr>
		<tr><td>nucleotide</td><td>blastn</td>
			<td>${NUCLEOTIDE_DBS}</td>
		</tr>
		<tr><td>nucleotide</td><td>blastx</td><td>${PEPTIDE_DBS}</td></tr>
		<tr><td>peptide</td><td>blastp</td><td>${PEPTIDE_DBS}</td></tr>
		<tr><td>peptide</td><td>tblastn</td><td>${NUCLEOTIDE_DBS}</td></tr>
	</table>\n";
  }else{
    $PAGE_CONTENTS = $GDB->doBLAST( param('sequence'),param('name'),param('program'),param('db'),param('evalue') );#param('evalue') added by usha
  }

}elsif(param('upload')){
  my $uploadFile = param('upload');
  my $tempSeq = "";
  while(<$uploadFile>){
    $tempSeq .= $_;
  }
  $seq = $tempSeq;
  $PAGE_CONTENTS = $GDB->doBLAST( $seq,param('name'),param('program'),param('db'),param('evalue') );

}elsif(defined(param('db'))){
	$seq = param('seq');
	$seq =~ s/(.{70})/$1\n/g;
	if (!$seq){
		my @hits = param('hits');
		$seqAR = $GDB->getSequence($db,$dbid,\@hits);
		$PAGE_CONTENTS = $GDB->doBLASTprompt($seqAR->[0]);
	}else{
		$PAGE_CONTENTS = $GDB->doBLASTprompt($seq);
	}
}else{
  $PAGE_CONTENTS = $GDB->doBLASTprompt();
}


$cgi_paramHR->{headHR}    = {-cookie=>[$sCookie]};
$cgi_paramHR->{htmlHR}    = {-title=>"${SITENAMEshort} BLAST Query",
			     			 -script=>[{-src=>"${JSPATH}BRview.js"}]
			    			};
$cgi_paramHR->{main}      = $PAGE_CONTENTS;


$GDBpage->printXGDB_page($cgi_paramHR);
