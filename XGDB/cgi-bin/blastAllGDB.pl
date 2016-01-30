#! /usr/bin/perl
# blastAllGDB.pl - A web-based front end for Blast GDB compare
use CGI ":all";
use GSQDB;
use GDBgui;

do 'SITEDEF.pl';
do 'GDBgui.pl';
do 'getPARAM.pl';

my $GDBpage = new GDBgui();
#CGI parameters
my @dbArray_Protein = param('pdb');
my @dbArray_TRANSCRIPT = param('tdb');
my @dbArray_Genome = param('genomedb');
my @TDB;
my @PDB;
my @GENOMEDB;
my @PRMs;
my $DATADBS="/xGDBvm/data/";
my $DBtype=param('db_type');
my $DB=param(db);
my $geneId = param('geneId');
my $hits = param('hits');
my $chr;
my $l_pos;
my $r_pos;
my $range;
if ($hits =~ /(\S+):(\d+):(\d+)/){
        $chr=$1;
        $l_pos=$2;
        $r_pos=$3;
	$range="$l_pos"."-"."$r_pos";
}

my %SpeciesLabel;
my $DB_HOST = 'localhost';
my $dsn = "DBI:mysql:$xGDB:$DB_HOST";
my $user = 'gdbuser';
my $pass = 'xgdb';
my %attr = (PrintError => 0, RaiseError => 0);
my $dbh = DBI->connect($dsn,$user,$pass,\%attr) or die $DBI::errstr;
my $sth;

my $query = "select ID,DBname from Genomes.xGDB_Log where Status='Current'";
$sth = $dbh->prepare($query);
$sth->execute();
my ($GDB,$ID,$DBname);
while ($ary_ref = $sth -> fetchrow_arrayref()) {
	($ID,$DBname)= @$ary_ref;
	print STDERR "$ID jjjjjjjjjjj $DBname jjjjjjjjjjjjjj\n";	
	$GDB="GDB";
	$GDB=$GDB."00".$ID if ($ID <10);
	$GDB=$GDB."0" .$ID if ($ID <100 && $ID>10);
	$GDB=$GDB .$ID if ($ID <1000 && $ID>100);
	$SpeciesLabel{$GDB}=$DBname;
}
	
my $dos2unix="/usr/bin/dos2unix";
my $SERVER              = "https://" . $ENV{'HTTP_HOST'};
my $PLANTGDB_TMPDIR= $TMPDIR;
my $DBstring;
my $PDBstring;
my $TDBstring;
my $GENOMEDBstring;
foreach my $dbName (@dbArray_Protein){
    push(@PDB,$dbName);
	
}
foreach my $dbName (@dbArray_TRANSCRIPT){
    push(@TDB,$dbName);
}
foreach my $dbName (@dbArray_Genome){
    push(@GENOMEDB,$dbName);
}
my $eValue = param('eValue');
my $JSCRIPT = <<END;
<script type="text/javascript">
/* <![CDATA[ */
var DBflag = "false";
function MYcheckDB(DBlist){
/*	alert(DBlist);*/
        var y=document.getElementById('MYCheckDBControl');
	
        DBarray = DBlist.split(",");
        for (i = 0; i < DBarray.length; i++) {
	DBId = DBarray[i];
	x = document.getElementById(DBId);
		if (DBflag == "true"){
			x.checked = false;
		}else{
			x.checked = true;
		}
	}
	if (DBflag == "true"){
		y.value   = "Select All";
		DBflag = "false";
	}else{
		y.value   = "Unselect All";
                DBflag = "true";
	}
}
	
        /* ]]> */
</script>
END
if(param('eValue')){
  $eValue = param('eValue');
}
my $F = param('F');
my $G = param('G');
my $E = param('E');
my $X = param('X');
my $f = param('f');
my $g = param('g');
my $M = param('M');
my $W = param('W');
my $y = param('y');
my $t = param('t');
my $q = param('q');
my $r = param('r');
my $v = param('v');
my $b = param('b');
my $Q = param('Q');
my $D = param('D');
my $a = param('a');
my $z = param('z');
my $P = param('P');
my $S = param('S');
my $Z = param('Z');
my $n = param('n');
my $w = param('w');

my $program = param('_program');
my $TDB;
my $PDB;
my $GENOMEDB;
my $BLAST_DB;
if(@PDB){
        $PDB = join(' ', @PDB);
}
if(@TDB){
        $TDB = join(' ', @TDB);
}
if(@GDB){
        $GENOMEDB = join(' ', @GENOMEDB);
}
if ($DBtype=~ /Nucleotide/i){
	$BLAST_DB = $TDB;
}elsif($DBtype=~ /Genome/i){
	$BLAST_DB = $GENOMEDB;
}else{
	$BLAST_DB = $PDB;
}
my (@BlastParameter, $BlastParameter);
if(!defined $program){
         $program = 'blastn';
 }
if(!defined $eValue){
         $eValue = '1e-4';
}           
$BlastParameter = "-e $eValue";
push(@BlastParameter,$BlastParameter);
if(!defined $F){
    $F = 'T';
}
$BlastParameter = "-F $F";
push(@BlastParameter,$BlastParameter);
if(defined $G){
        $BlastParameter = "-G $G";
        push(@BlastParameter, $BlastParameter);
}
if(defined $E){
        $BlastParameter = "-E $E";
        push(@BlastParameter, $BlastParameter);
}
if(defined $X){
        $BlastParameter = "-X $X";
        push(@BlastParameter, $BlastParameter);
}
if(defined $f){
        $BlastParameter = "-f $f";
        push(@BlastParameter, $BlastParameter);
}
if(defined $g){
        $BlastParameter = "-g $g";
        push(@BlastParameter, $BlastParameter);
}
if(defined $M){
        $BlastParameter = "-M $M";
        push(@BlastParameter, $BlastParameter);
}
if(defined $W){
        $BlastParameter = "-W $W";
        push(@BlastParameter, $BlastParameter);
}
if(defined $y){
        $BlastParameter = "-y $y";
        push(@BlastParameter, $BlastParameter);
}
if(defined $t){
        $BlastParameter = "-t $t";
        push(@BlastParameter, $BlastParameter);
}
if(defined $q){
        $BlastParameter = "-q $q";
        push(@BlastParameter, $BlastParameter);
}
if(defined $r){
        $BlastParameter = "-r $r";
        push(@BlastParameter, $BlastParameter);
}
if(defined $v){
        $BlastParameter = "-v $v";
        push(@BlastParameter, $BlastParameter);
}
if(defined $b){
        $BlastParameter = "-b $b";
        push(@BlastParameter, $BlastParameter);
}
if(defined $Q){
        $BlastParameter = "-Q $Q";
        push(@BlastParameter, $BlastParameter);
}
if(defined $D){
        $BlastParameter = "-D $D";
        push(@BlastParameter, $BlastParameter);
}
if(defined $a){
        $BlastParameter = "-a $a";
        push(@BlastParameter, $BlastParameter);
}
if(defined $z){
        $BlastParameter = "-z $z";
        push(@BlastParameter, $BlastParameter);
}
if(defined $P){
        $BlastParameter = "-P $P";
        push(@BlastParameter, $BlastParameter);
}
if(defined $S){
        $BlastParameter = "-S $S";
        push(@BlastParameter, $BlastParameter);
}
if(defined $Z){
        $BlastParameter = "-Z $Z";
        push(@BlastParameter, $BlastParameter);
}
if(defined $n){
        $BlastParameter = "-n $n";
        push(@BlastParameter, $BlastParameter);
}
if(defined $w){
        $BlastParameter = "-w $w";
        push(@BlastParameter, $BlastParameter);
}
$BlastParameter = join(' ', @BlastParameter);

my $QuerySequence = param('QuerySequence');
my $uploadDNAfile = param('uploadDNAfile') ;
my $uploadPROTEINfile = param('uploadPROTEINfile');
my $uploadTRANSCRIPTfile = param('uploadTRANSCRIPTfile');
my $uploadGENOMEfile = param('uploadGENOMEfile');
my $Submit = param('Submit');

## create page
my ($PAGE_CONTENTS,$seq,$msg);
my $geneSeq;

my $xGDB =$1 if ($DB=~ /(^GDB\d\d\d)/);
	print STDERR "qqqqqqqqqqqqqq /usr/local/bin/blastdbcmd -db ${DATADIR}$DB -entry $chr -range $range";
if ($xGDB && $geneId) {
	print STDERR "/usr/local/bin/blastdbcmd -db ${DATADIR}$DB -entry $geneId";
    $geneSeq = qx(/usr/local/bin/blastdbcmd -db ${DATADIR}$DB -entry $geneId);
    $QuerySequence = "$geneSeq";
}elsif ($xGDB && $chr) {
	print STDERR "KKKKKKKKKK /usr/local/bin/blastdbcmd -db ${DATADIR}$DB -entry $chr -range $range";
	$geneSeq = qx(/usr/local/bin/blastdbcmd -db ${DATADIR}$DB -entry $chr -range $range);
	$QuerySequence = "$geneSeq";
}
###############################
###  main code starts here  ###
###############################
if (!$Submit){
    do_prompt();
}else{
    do_search( $QuerySequence,$program,$BLAST_DB,$BlastParameter);
}
sub do_prompt {
	$PAGE_CONTENTS ="$JSCRIPT";
    $PAGE_CONTENTS .= "<div id=\"maincontents\"><h1 class=\"bottommargin1\">BlastAllGDB &nbsp; <img id='blastallgdb_help' title='Search Help' class='xgdb-help-button' src='/XGDB/images/help-icon.png' alt='?' /><span class=\"heading\"> - a tool for running BLAST queries across multiple genomes.</span></h1>\n";
    $PAGE_CONTENTS .= "<div style=\"margin-left:2em; clear:right\">";

    $PAGE_CONTENTS .= "<form action=\"${CGIPATH}blastAllGDB.pl\" method=\"post\">\n";

    my $DNAbox;
    if(defined $QuerySequence){
    $DNAbox = textarea(-name=>'QuerySequence',-rows=>4,-cols=>80, -value=>$QuerySequence);
    }else{
    $DNAbox = textarea(-name=>'QuerySequence',-rows=>4,-cols=>80);
    }
    $PAGE_CONTENTS .= "<p><b>Step 1:</b> If not autofilled, paste DNA or Protein sequence(s) here:</p><br />$DNAbox<br />";
    my $DNAupload = filefield(-name=>'uploadDNAfile', -size=>40);
    $PAGE_CONTENTS .= "<p>...<b>or</b> upload genomic sequences from $DNAupload<br /></p>";
    $PAGE_CONTENTS .="<input type='hidden' name='uploadDNAfile' value='uploadDNAfile'>";
    $PAGE_CONTENTS .= "<p><b>Step 2:</b> Select <b>dataset(s)</b> to use for blast, or <b>switch dataset type</b>: <img id='blastallgdb_datasets_help' title='Search Help' class='xgdb-help-button' src='/XGDB/images/help-icon.png' alt='?' /></p>";
        if (param('db_type')){
            $DBtype=param('db_type');
        }else{
             $DBtype='protein';
        }
            my $label ="<p><span class=\"heading indent1\"><b>Dataset type selected: Transcript</b> </span>";
        if ($DBtype =~ /protein/i){
            $label ="<p><span class=\"heading indent1\"><b>Dataset type selected: Protein</b> </span> ";
			
		$PAGE_CONTENTS .="$label <input type=\"submit\" name=\"db_type\" value=\"Switch to Transcript\" /> ";
		$PAGE_CONTENTS .="<input type=\"submit\" name=\"db_type\" value=\"Switch to Genome\" />";
		#$PAGE_CONTENTS .="<input type=\"hidden\" name=\"db_type\" value=\"protein\" /></p> ";
	}elsif ($DBtype =~ /genome/i){
            $label ="<p><span class=\"heading indent1\"><b>Dataset type selected: Genome</b> </span> ";
                        $PAGE_CONTENTS .="$label <input type=\"submit\" name=\"db_type\" value=\"Switch to Protein\" /> ";
                $PAGE_CONTENTS .="<input type=\"submit\" name=\"db_type\"
value=\"Switch to Nucleotide\" /> </p>";
		#$PAGE_CONTENTS .="<input type=\"hidden\" name=\"db_type\" value=\"genome\" /> ";
        }else{
	$PAGE_CONTENTS .="$label <input type=\"submit\" name=\"db_type\" value=\"Switch to Genome\" /> ";
         $PAGE_CONTENTS .="<input type=\"submit\" name=\"db_type\" value=\"Switch to Protein\" >";
		#$PAGE_CONTENTS .="<input type=\"hidden\" name=\"db_type\" value=\"transcript\" /> ";
        }
        if ($DBtype =~ /protein/i){
			$PAGE_CONTENTS .="<p><b>Protein Datasets:</b></p>
			<table id=\"protein_table\" width=\"300px\">
				<col width=\"30%\" style=\"padding-left:5px\"><col width=\"30%\" style=\"padding-left:5px\"><col width=\"30%\" style=\"padding-left:5px\">
					<tr align=\"left\">
						 <th align=\"left\">xGDB</th>
						 <th align=\"left\">GDBname</th>
						 <th align=\"left\">Protein <br /> Dataset&nbsp;&nbsp;</th>
						 <th align=\"left\">Select</th>
					</tr>
					<tr>
					</tr>";
				$PDBstring='';
				foreach my $file (sort keys %SpeciesLabel) {
					my $pref;
					my $valueDB=$SpeciesLabel{$file};
					if ($file =~ /^(GDB\d\d\d)/){
						$pref=$1;
					}
				my $pepfile="${pref}prot";
				$path = "${DATADBS}/".$pref."/data/BLAST/$pepfile";
                $PAGE_CONTENTS .= "<tr align=\"left\">";
                $PAGE_CONTENTS .= "<td>$file</td>";
                $PAGE_CONTENTS .= "<td>$valueDB</td>";
                $PAGE_CONTENTS .= "<td>$pepfile</td>";
               	if (-s $path){
			$PDBstring = $PDBstring.','."$pepfile";
                	$PAGE_CONTENTS .= "<td><input type='checkbox' name='pdb' id=\"$pepfile\" value=\"$path\" ></td><td></td><td></td>";
		}else{
			$PAGE_CONTENTS .="<td></td><td></td><td></td>";
		}
	}
	$PDBstring =~ s/^,//g;
	$PAGE_CONTENTS .= "</tr>";
			$PAGE_CONTENTS .= "</table>";
		my $PROTEINupload = filefield(-name=>'uploadPROTEINfile', -size=>40);
		$PAGE_CONTENTS .= "<br /><p>...<b>or</b> upload proteins from $PROTEINupload<br /></p>";
		$PAGE_CONTENTS .="<input type='hidden' name='uploadPROTEINfile' value='uploadPROTEINfile'>";
    
}elsif($DBtype =~ /genome/i){
	$PAGE_CONTENTS .= "<p><b>Genomic Datasets:</b></p>
	<table id=\"genome_table\" width=\"300px\">
                         <col width=\"30%\" style=\"padding-left:5px\"><col width=\"30%\" style=\"padding-left:5px\"><col width=\"30%\" style=\"padding-left:5px\">
		 <tr align=\"left\">
                        <th align=\"left\">xGDB</th>
                        <th align=\"left\">GDBname</th>
                        <th align=\"left\">Genome/BAC <br /> Dataset&nbsp;&nbsp;</th>
			<th align=\"left\">Select</th>
                 </tr>
		<tr>
                </tr>";
	my $path;
	$GENOMEDBstring='';
    foreach my $file (sort keys %SpeciesLabel) {
        my $pref;
        if ($file =~ /^(GDB\d\d\d)/){
                        $pref=$1;
                }
	my $valueDB=$SpeciesLabel{$file};
	$PAGE_CONTENTS .= "<tr align=\"left\">";
	$PAGE_CONTENTS .= "<td align=\"left\">$file</td>";
	$PAGE_CONTENTS .= "<td align=\"left\">$valueDB</td>";
			
	my $genomefile=$pref."scaffold";
	
	 $path="${DATADBS}/$pref/data/BLAST/".$pref."scaffold";
        if (-s $path){
		$GENOMEDBstring = $GENOMEDBstring.','."$genomefile";
		 $PAGE_CONTENTS .= "<td align=\"left\">$genomefile</td>";
                $PAGE_CONTENTS .= "<td align=\"left\"><input type='checkbox' name='genomedb' id=\"$genomefile\" value=\"$path\" ></td><td></td>";
                }else{
            $PAGE_CONTENTS .="<td></td><td></td>";
        	}
		$GENOMEDBstring =~ s/^,//g;
	$PAGE_CONTENTS .= "</tr>";
	}
	$PAGE_CONTENTS .= "</table>";
	my $GENOMEupload = filefield(-name=>'uploadGENOMEfile', -size=>40);
                $PAGE_CONTENTS .= "<br /><p>...<b>or</b> upload Genomes from $GENOMEupload<br /></p>";
                $PAGE_CONTENTS .="<input type='hidden' name='uploadGENOMEfile' value='uploadGENOMEfile'>";
}else{

    $PAGE_CONTENTS .= '<br />';
        $PAGE_CONTENTS .= "<p><b>Transcript Datasets:</b></p>
        <table id=\"transcript_table\" width=\"300px\">
        <col style=\"padding-left:5px\"><col style=\"padding-left:5px\"><col style=\"padding-left:5px\">
        <tr align=\"left\">
                 <th align=\"center\">xGDB</th>
                 <th align=\"center\">GDBname</th>
                 <th align=\"center\">&nbsp;Transcript/<br />CDS&nbsp;</th>
        	<th align=\"center\">&nbsp;PUT &nbsp;&nbsp;</th>
        	<th align=\"center\">&nbsp;EST &nbsp;&nbsp;</th>
        	<th align=\"center\">&nbsp;cDNA &nbsp;&nbsp;</th>
                 <th align=\"center\"></th>
        </tr>";
        my $path;
	$TDBstring='';
	 my $pref;
    foreach my $file (sort keys %SpeciesLabel) {
        if ($file =~ /^(GDB\d\d\d)/){
                        $pref=$1;
                }
	my $valueDB=$SpeciesLabel{$file};
                $PAGE_CONTENTS .= "<tr align=\"center\">";
        $path="${DATADBS}/".$pref."/data/BLAST/"."${pref}transcript";
	my $cdsfile=$pref."transcript";
	if (-s $path){
	}else{
	$path="${DATADBS}/".$pref."/data/BLAST/"."${pref}cds";
	$cdsfile=$pref."cds";
	}
        $PAGE_CONTENTS .= "<td align=\"center\">$file</td>";
        $PAGE_CONTENTS .= "<td align=\"center\">$valueDB</td>";
        if (-s $path){
		$TDBstring = $TDBstring.','."$cdsfile";
                $PAGE_CONTENTS .= "<td><input type='checkbox' name='tdb' id=\"$cdsfile\" value=\"$path\" >";
		}else{$PAGE_CONTENTS .="<td></td>";}
	my $putfile=$pref."put";
        $path="${DATADBS}/".$pref."/data/BLAST/"."${pref}put";
        if (-s $path){
		print STDERR "PUTS SSSSSSSSSSSSSSSSSSSSSSSSS $path\n";
		$TDBstring = $TDBstring.','."$putfile";
                $PAGE_CONTENTS .= "<td><input type='checkbox' name='tdb' id=\"$putfile\" value=\"$path\" >";
	}else{$PAGE_CONTENTS .="<td></td><td></td><td></td>";}
	$path="${DATADBS}/".$pref."/data/BLAST/"."${pref}est";
		my $estfile=$pref."est";
        if (-s $path){
		print STDERR "ESTS SSSSSSSSSSSSSSSSSSSSSSSSS $path\n";
		$TDBstring = $TDBstring.','."$estfile";
                $PAGE_CONTENTS .= "<td><input type='checkbox' name='tdb' id=\"$estfile\" value=\"$path\" >";
	}else{$PAGE_CONTENTS .="<td></td><td></td><td></td>";}
	$path="${DATADBS}/".$pref."/data/BLAST/"."${pref}cdna";
		my $cdnafile=$pref."cdna";
        if (-s $path){
		print STDERR "CDNAS SSSSSSSSSSSSSSSSSSSSSSSSS $path\n";
		$TDBstring = $TDBstring.','."$cdnafile";
                $PAGE_CONTENTS .= "<td><input type='checkbox' name='tdb' id=\"$cdnafile\" value=\"$path\" ></td><td></td><td></td>";
	}else{$PAGE_CONTENTS .="<td></td><td></td><td></td>";}
                 $PAGE_CONTENTS .= "</tr>";
        }
	$TDBstring =~ s/^,//;
    $PAGE_CONTENTS .= "</table>";
my $TRANSCRIPTupload = filefield(-name=>'uploadTRANSCRIPTfile', -size=>40);
    $PAGE_CONTENTS .= "<p><br /><b>...or</b> upload transcripts from $TRANSCRIPTupload<br /></p>";
        $PAGE_CONTENTS .="<input type='hidden' name='uploadTRANSCRIPTfile' value='uploadTRANSCRIPTfile'>";
} 
	if ($DBtype =~ /protein/i){
		$DBstring=$PDBstring;
	}elsif($DBtype =~ /genome/i){
		$DBstring=$GENOMEDBstring;
	}else{
		$DBstring=$TDBstring;
	}  
	$PAGE_CONTENTS .="<tr><input type=\"button\" name=\"test\" id=\"MYCheckDBControl\" onclick=\"MYcheckDB('".$DBstring."')\" value=\"Select All\" /></tr>"; 
    $PAGE_CONTENTS .= "<p><b>Step 3:</b> Select BLAST program: &nbsp;<img id='blast_programs_help' title='Search Help' class='xgdb-help-button' src='/XGDB/images/help-icon.png' alt='?' /> </p>";
    my $eValueField = textfield(-name=>'eValue', -size=>5, -default=>'1e-4');
    $PAGE_CONTENTS .= "<p>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class=\"hover_pointer bold\" title=\"Blast program \">Program:</span>&nbsp;";
    $PAGE_CONTENTS .= "<select name=\"_program\"></p>";
    $PAGE_CONTENTS .= "<option value=\"blastn\">blastn</option>\n";
    $PAGE_CONTENTS .= "<option value=\"blastp\">blastp</option>\n";
    $PAGE_CONTENTS .= "<option value=\"blastx\">blastx</option>\n";
    $PAGE_CONTENTS .= "<option value=\"tblastn\">tblastn</option>\n";
    $PAGE_CONTENTS .= "</select><p>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<b>E-Value:</b> $eValueField</p>\n";    
    
    $PAGE_CONTENTS .= "<div id=\"quickstart\" class=\"description showhide topmargin1\">
    <a title=\"Advanced Parameters\" style=\"cursor:pointer; margin-left:5px\"><b>Step 4</b> Advanced Parameters (Optional; click to show)</a>
       <div class=\"hidden\" style=\"padding:10px\">
        See 
       <a href=\"http://www.ncbi.nlm.nih.gov/staff/tao/URLAPI/blastall/blastall_node21.html\" target='_blank'>
       description of advanced Blast paramenters at NCBI</a>
       </p>
    <fieldset  style=\"padding:10px\">
            <legend>Advanced Parameters</legend>
        Filter
            <select name=\"F\">
            <option selected=\"selected\" value=\"T\">T</option>
            <option value=\"F\">F</option>
            </select>
        Matrix
                    <select name=\"M\">
                        <option selected=\"selected\" value=\"BLOSUM62\">BLOSUM62</option>
                        <option value=\"BLOSUM45\">BLOSUM45</option>
                        <option value=\"BLOSUM80\">BLOSUM80</option>
                        <option value=\"PAM30\">PAM30</option>

                        <option value=\"PAM70\">PAM70</option>
                    </select>
        Word size
                    <input type=\"text\" name=\"W\" value=\"0\" size=\"1\" />
                    <br />
                    Cost to open a gap
                    <input type=\"text\" name=\"G\" value=\"0\" size=\"1\" />
                    Cost to extend a gap
                    <input type=\"text\" name=\"E\" value=\"0\" size=\"1\" />
                    <br />
        Threshold for extending hits
                    <input type=\"text\" name=\"f\" value=\"0\" size=\"1\" />
                    <br />
        Perform gapped alignment {not availabel with tblastx}
                    <select name=\"g\">
                        <option selected=\"selected\" value=\"T\">T</option>
                        <option value=\"F\">F</option>
                    </select>
                    <br />
        Length of the largest intron allowed in tblastn for linking HSPs
                    <input type=\"text\" name=\"t\" value=\"0\" size=\"1\" />
                    <br />
        X dropoff value for gapped alignment (in bits)
                    <input type=\"text\" name=\"X\" value=\"0\" size=\"1\" />
                    <br />
                X dropoff value for ungapped extensions (in bits)
                    <input type=\"text\" name=\"y\" value=\"0.0\" size=\"2\" />
                    <br />
        Penalty for a nucleotide mismatch (blastn only)
                        <input type=\"text\" name=\"q\" value=\"-3\" size=\"2\" />
                        <br />
        Reward for a nucleotide match (blastn only)
                        <input type=\"text\" name=\"r\" value=\"1\" size=\"2\" />
                        <br />
        Number of database sequences to show one-line descriptions for (V)                        <input type=\"text\" name=\"v\" value=\"500\" size=\"2\" />                        <br />
        Number of database sequence to show alignments for (B)
                        <input type=\"text\" name=\"b\" value=\"250\" size=\"2\" />                        <br />
        Query Genetic code to use
                        <input type=\"text\" name=\"Q\" value=\"1\" size=\"2\" />
                        <br />
                        DB Genetic code (for tblast[nx] only)
                        <input type=\"text\" name=\"D\" value=\"1\" size=\"2\" />
                        <br />
                        Number of processors to use
                        <input type=\"text\" name=\"a\" value=\"1\" size=\"2\" />
                        <br />
                        Effective length of the database (use zero for the real size)
                        <input type=\"text\" name=\"z\" value=\"0\" size=\"2\" />

                        <br />
        0 for multiple hit, 1 for single hit (does not apply to blastn)
                        <input type=\"text\" name=\"P\" value=\"0\" size=\"2\" />
                        <br />
                        Query strands to search against database (for blast[nx], and tblastx)
                        <input type=\"text\" name=\"S\" value=\"3\" size=\"2\" />
                        <br />
                        X dropoff value for final gapped alignment in bits (0.0 invokes default behavior)
     blastn/megablast 50, tblastx 0, all others 25
                        <input type=\"text\" name=\"Z\" value=\"0\" size=\"2\" />
                        <br />

                        MegaBlast search
                        <input type=\"text\" name=\"n\" value=\"F\" size=\"2\" />
                        <br />
                        Frame shift penalty (OOF algorithm for blastx)
                        <input type=\"text\" name=\"w\" value=\"0\" size=\"2\" />
                        <br />";    
        
    $PAGE_CONTENTS .= "</fieldset>";
    $PAGE_CONTENTS .= "</div></div>";
    $PAGE_CONTENTS .= '<br />';
    $PAGE_CONTENTS .= "<p><b>Step 5: </b>";
    $PAGE_CONTENTS .= "<input type=\"submit\" value=\"Submit\" name=\"Submit\"/><input type=\"reset\" value=\"Reset\" name=\"Reset\"/></p></div></div>";
    #$PAGE_CONTENTS .= "<input type=\"button\" value=\"Submit\" name=\"Submit\" onclick=\"submitTo('${CGIPATH}blastAllGDB.pl');\"/>\n";
    $cgi_paramHR->{headHR}    = {-cookie=>[$sCookie]};
$cgi_paramHR->{htmlHR}    = {-title=>"${SITENAMEshort} blastAllGDB",
                             -script=>[{-src=>"${JSPATH}BRview.js"}]
                            };
$cgi_paramHR->{main}      = $PAGE_CONTENTS;
$GDBpage->printXGDB_page($cgi_paramHR);
exit;
}
sub do_search{
    $PageTitle = "blastAllGDB";
    my ($QuerySequence,$program,$BLAST_DB,$BlastParameter) = @_;
        my $DNA_ID;
        if ($QuerySequence =~ /^>lcl\|(\S+)\s/){
                $DNA_ID=$1;
        }
    my @fastacheck = $QuerySequence =~ /^(>)/mg;
        my $fastacheck = @fastacheck;
        if($fastacheck > 100){
                #not a fasta sequence
                print start_html();
                print '<h3 class="warning">Sorry, please reduce number of your query sequences less than 100!</h3>';
                exit;
        }
    
        my $unlinked;
    my $QueryInputFile = int(time()).'blastinputQuery';
        $QueryInputFile = $PLANTGDB_TMPDIR.$QueryInputFile;
        $QueryInputFileTmp = $QueryInputFile."tmp";
    my $BlastOutput = int(time()).'blastoutputQuery';
        $BlastOutput = $PLANTGDB_TMPDIR.$BlastOutput;
    open(OUT, ">$QueryInputFile") || die ("Cannot open output to write $QueryInputFile");
        print OUT $QuerySequence;
    #system "$dos2unix $QueryInputFile >$QueryInputFileTmp";
    #system "mv $QueryInputFileTmp $QueryInputFile"; 
    close(OUT);
    my $blastTable = "        <table border=\"1\">
        <tr>
        <th>blastn</th><td>Compares a nucleotide query sequence against a nucleotide sequence database.</td></tr>
        <tr>
        <th>tblastn</th><td>Compares a protein query sequence against a nucleotide sequence database dynamically translated in all reading frames.</td></tr>
        <tr>
        <th>tblastx</th><td>Compares the six-frame translations of a nucleotide query sequence against the six-frame translations of a nucleotide sequence database. Please note that the tblastx program is computationally intensive.</td></tr>
       <tr>
        <th>blastp</th><td>Compares an amino acid query sequence against a protein sequence database.</td></tr>
       <tr>
        <th>blastx</th><td>Compares a nucleotide query sequence translated in all reading frames against a protein sequence database. You could use this option
to find potential translation products of an unknown nucleotide sequence.</td></tr>

        </table>";
    if($program eq 'blastn' || $program eq 'tblastn' || $program eq 'tblastx'){
        if($BLAST_DB =~ /pep/){
                print header, start_html('BLAST Search on $name');
                print "<h3 class=\"warning\">Sorry, you are trying to use the $program program to query a protein sequence database.
        $program requires to query a nucleotide sequence database (e.g., GSS, EST, PUT, cDNA, STS, HTG).
        See <a href=\"http://www.ncbi.nlm.nih.gov/Education/BLASTinfo/query_tutorial.html#Selecting%20the%20BLAST%20Program\" target=\"_blank\">a synopsis of the various BLAST programs</a> and follow <a href=\"http://www.ncbi.nlm.nih.gov/Education/BLASTinfo/information3.html\" target=\"_blank\">NCBI's BLAST Tutorial</a> for more information.</h3>
        <br />
                $blastTable
        ";
                exit;
        }
        }
    if($program eq 'blastp' || $program eq 'blastx'){
        if($BLAST_DB =~ /transcrip/ || $BLAST_DB =~ /genome/ || $BLAST_DB =~ /put/ || $BLAST_DB =~ /bac/ || $BLAST_DB =~ /est/ || $BLAST_DB =~ /cdna/){
              print header, start_html('BLAST Search on $name');
                print "<h3 class=\"warning\">Sorry, you are trying to use the $program program to query a nucleotide sequence database.
                $program requires to query a protein sequence database.
                See <a href=\"http://www.ncbi.nlm.nih.gov/Education/BLASTinfo/query_tutorial.html#Selecting%20the%20BLAST%20Program\" target=\"_blank\">a synopsis of the various BLAST programs</a> and follow
   <a href=\"http://www.ncbi.nlm.nih.gov/Education/BLASTinfo/information3.html\" target=\"_blank\">NCBI's BLAST Tutorial</a> for more information.
                </h3>
                <br />
                $blastTable";
                exit;
        }
        }
    my @multipeSeqs = split(/>/, $QuerySequence);
    foreach my $seq (@multipeSeqs){
                next unless ($seq =~ /\w/);
                my $tempSeq = ' ';
                my @seqArray = split(/\n/, $seq);
                shift @seqArray; #get rid of title line
                foreach my $seqline (@seqArray){
                        $tempSeq .= $seqline;
                }
                $tempSeq =~ s/\W+//g;
                if($program eq 'blastp' || $program eq 'tblastn'){
                        if(IsDNA($tempSeq)){
                            print header, start_html('BLAST Search on $name');
                                print "<h3 class=\"warning\">Sorry, you are trying to use the $program program to query a protein database with a nucleotide sequence input. $program requires a protein sequnence input. See <a href=\"http://www.ncbi.nlm.nih.gov/Education/BLASTinfo/query_tutorial.html#Selecting%20the%20BLAST%20Program\" target=\"_blank\">a synopsis of the various BLAST programs</a> and follow <a href=\"http://www.ncbi.nlm.nih.gov/Education/BLASTinfo/information3.html\" target=\"_blank\">NCBI's BLAST Tutorial</a> for more information.</h3><br />$blastTable";
                                exit;
            }
                    if($program eq 'blastn' || $program eq 'blastx' || $program eq 'tblastx'){
                            if(!IsDNA($tempSeq)){
                            print header, start_html('BLAST Search on $name');
                                print "<h3 class=\"warning\">Sorry, you are trying to use the $program program to query a nucleotide sequence database with a protein sequence input. $program requires a nucleotide sequence input. See <a href=\"http://www.ncbi.nlm.nih.gov/Education/BLASTinfo/query_tutorial.html#Selecting%20the%20BLAST%20Program\" target=\"_blank\">a synopsis of the various BLAST programs</a> and follow <a href=\"http://www.ncbi.nlm.nih.gov/Education/BLASTinfo/information3.html\" target=\"_blank\">NCBI's BLAST Tutorial</a> for more information.</h3><br />$blastTable";
                                exit;
                }
                    }
        }
    }
    
    my $command;
    my $passDB='';
            foreach my $dbArraymember (@dbArray_Protein){
			#push(@PDB,$dbArraymember);
                $passDB = $passDB . $dbArraymember . ',';
            }
		$PDB = join(' ', @PDB);
		foreach my $dbArraymember (@dbArray_Genome){
			#push(@GENOMEDB,$dbArraymember);
			$passDB = $passDB . $dbArraymember . ',';
		}
		$GENOMEDB = join(' ', @GENOMEDB);
        foreach my $dbArraymember (@dbArray_TRANSCRIPT){
			#push(@TDB,$dbArraymember);
                $passDB = $passDB . $dbArraymember . ',';
        }
	$TDB=join(' ', @TDB);
	print STDERR "$BLAST_DB mmmmmmmmmmmmmmmm $TDB mmmmmmmmmmmmmmmm $GENOMEDB  MMMMMMMMMMMMMMMMMMMMMMMMMMM $PDB kkkkkkkkkkkk $DBtype kkkkkkkkk\n";
	if($TDB){
	$BLAST_DB=$TDB;
	}elsif($GENOMEDB){
	$BLAST_DB=$GENOMEDB;
	}elsif($PDB){
	$BLAST_DB=$PDB;
	}
        $command = "/usr/local/bin/legacy_blast.pl blastall --path /usr/local/bin -p $program -d \"$BLAST_DB\" -i $QueryInputFile -o $BlastOutput";
	print STDERR "jjjjjjjjjjjjj $DBtype jjjjjjjjjjjjj\n"; 
    print STDERR "my comannd: gggggggggggggggggggg $command\n";
        system("( $command ) >/dev/null 2>&1 &");
        my $rrate=15;
    print ("Location:$SERVER${CGIPATH}/XGDBwatch-blast.cgi?BlastOutput=$BlastOutput&rrate=$rrate&db=$passDB\n\n");
    exit;
}

sub IsDNA{
my $seq = shift;
        my $NPCT = 10;  # maximum allowable percent of non [ATCGN] letters in
               # valid nucleotide sequence
               # valid protein sequence
        $seq =~ tr/a-z/A-Z/;         # flatten case
        my $len = length($seq);
        my $type;
       # check if it's nucleotide
        my $iupac = $seq =~ tr/ATCGN\n//c;  # count non-ATCGN characters
        if ($len == 0) { return 1; }
        my $pct = ($iupac / $len) * 100;
        if ($pct >= $NPCT) {
           #$ERR = "Supposed nucleotide sequence contains too many letters not in set [ATCGN]";
            return 0;
        }else{
                return 1;
        }
}
