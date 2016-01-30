<div class="dialogcontainer">
<h2 class="bottommargin1"> File formats required for input data: <span class="heading">See also Help topic: <a href="/XGDB/help/input_output.php">Inputs - Outputs</a></span></h2>

    <h3 class="topmargin1">1. FASTA FILES (transcripts, related species proteins, genome segments):</h3>
            <ul class="menulist">
                <li><b>Header format:</b>
 <span class="plaintext normalfont"><span class="alertnotice">>ID</span>[no spaces]<span class="alertnotice">| Optional Description </span></span></li>
    <li><b>File Naming Convention</b> 
      <span class="plaintext normalfont indent2">[my_identifier][<span class="alertnotice">type</span>]<span class="alertnotice">.fasta</span>
    </span>
where [<span class="alertnotice">type</span>] is one of the following:<span class="plaintext normalfont"><span class="alertnotice">
	est   cdna   put 
	protein
	scaffold</span>
   EXAMPLE: MySpecies_<span class="alertnotice">est.fasta</span>
    </span>
     </li>
</ul>
<h3 class="topmargin1">2. ANNOTATION (GFF3) FILES:</h3>
        <ul class="menulist">
            <li>Must be in <a href="http://www.sequenceontology.org/gff3.shtml">GFF3</a> format, with genome segment IDs that match IDs in the <b>scaffold</b> file</li>
            <li><b>Filename</b> must be as follows: <pre class="indent2">[my_identifier]<span class="alertnotice">.gff</span></pre> or <pre class="indent2">[my_identifier]<span class="alertnotice">.gff3</span></pre></li>
        </ul>
<h3 class="topmargin1">3. GFF3 File Type (select from Configuration options)</h3>
        <ul class="menulist">
                    <li> <b>'Standard':</b> [default] formatted similar to the CpGAT tool output (UTRs explicitly defined)</li>
                    <li> <b>'Other':</b> format with UTRs implicitly defined by CDS coordinates</li>
        </ul>
<h3 class="topmargin1">4. SPLICED-ALIGNMENT FILES:</h3>

<?php include_once('/xGDBvm/XGDB/help/includes/formats_splicealign.inc.php'); ?>

<h3 class="topmargin1">EXAMPLES:</h3>

<p>Below are filenames appropriate for an input dataset:</p>
<pre class="normal">
	Rc_4scaff_GDBcdna.fasta
	my.gff
	Rc_4scaff_GDBscaffold.fasta
	Rc_4scaff_GDBput.fasta
	Rc_4scaff_GDBprotein.fasta
	gsq.ESTresult
	gsq.PUTresult
	gsq.CDNAresult
	gth.PEPresult

</pre>

			<span class="heading normalfont linkback"> <a class="smallerfont" href="/XGDB/help/create_gdb.php#config_formats">View this in Help Context</a> (create_gdb.php/config_formats)</span>

				 </div>
