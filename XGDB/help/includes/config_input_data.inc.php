
<div class="dialogcontainer">
	<h2 class="bottommargin1">Input Data</h2>
	<p>Input data files should be placed in the directory specified under 'Input Data Path' configuration. Read carefully about <a target="_blank" title="Detailed file format and naming conventions (click ? to open new web page)" href="/XGDB/conf/data.php">data requirements</a> and make sure each file is named appropriately; otherwise data will not be processed.</p>
	
<p class="bold">Input data may include:</p>
	<ol class="orderedlist1 indent2">
	<li>Genome sequence (fasta-formatted; required): <span class="plaintext">~gdna.fa</span></li>
	<li>EST, cDNA, or transcript sequence assembly (TSA) sequence for spliced alignment (fasta; optional): <span class="plaintext">~est.fa</span>, <span class="plaintext">~cdna.fa</span>, <span class="plaintext">~tsa.fa</span></li>
	<li>Related-species proteins for spliced alignment (fasta; optional):<span class="plaintext">~prot.fa</span></li>
	<li>Precomputed spliced alignment output files for the above (if available; will shorten process time): <span class="plaintext">~est.gsq</span>, <span class="plaintext">~cdna.gsq</span>, <span class="plaintext">~tsa.gsq</span>, <span class="plaintext">~prot.gth</span></li>
	<li>Precomputed gene model annotations (.gff3 file) and their transcripts and translations (fasta files): <span class="plaintext">~annot.gff3</span>, <span class="plaintext">~annot.mrna.fa</span>, <span class="plaintext">~annot.pep.fa</span></li>
	<li>Precomputed CpGAT gene model annotations (.gff3 file) and their transcripts and translations (fasta files): <span class="plaintext">~cpgat.gff3</span>, <span class="plaintext">~cpgat.mrna.fa</span>, <span class="plaintext">~cpgat.pep.fa</span></li>
	<li>Text file with <b>gene model IDs and descriptions</b> (tab-delimited ) for the above:<span class="plaintext">~annot.desc.txt</span> or <span class="plaintext">~cpgat.desc.txt</span></li>
	</ol>

	<p>All <b>input data</b> will be copied to a <b>scratch directory</b> for processing, and <b>output data</b> (including BLAST indices and alignment output files) will be written to a <b>GDB data directory</b> on your external data volume.
	See <a target="_blank" title="Detailed information on xGDBvm data volumes (click ? to open new web page)" href="/XGDB/conf/volumes.php">data volumes</a> for details</p>

			<span class="heading normalfont linkback"> <a class="smallerfont" href="/XGDB/help/create_gdb.php#config_input_data">View this in Help Context</a> (create_gdb.php/config_input_data)</span>
</div>

