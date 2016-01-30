
<div class="dialogcontainer">
	<h2 class="bottommargin1">Pipeline Error 10.04</h2>
	
	 
	<h3>Sequence ID mismatch in protein spliced alignment table </h3>

	<ul class="bullet1 indent2">
		<li>The Protein spliced alignment table <b>gseg_pep_good_pgs</b> contains identifiers for both protein and scaffold sequence, and these identifiers must be the SAME as those used in the <b>gseg</b> and <b>pep</b> tables.
</li>
		<li>xGDBvm has determined that there is a <b>mismatch</b> in one of these identifiers, which will prevent data from displaying properly in your new genome browser.</li>
		<li>For example, you may have converted scaffold identifiers in the fasta file (~gdna.fa) to <span class="plaintext">e.g. >scaff_001</span>, but in your GenomeThreader run (~prot.gth) you used their original GeneBank IDs (e.g. <span class="plaintext">>gi|7846234</span>).</li>
		<li>Or, alternatively, you may have used distinct <b>protein</b> sequence identifiers at some point</li>
		<li>A third possibility is that one of the sequence datasets used for spliced alignment contained <b>extra sequences</b> not present in the fasta dataset that was provided in the input diretory</li>
	</ul>
	<h3>To correct this problem:</h3>
    <ol class="orderedlist1">
        <li>Check the GenomeThreader output file (~prot.gth) and sequence files (~gdna.fa and ~prot.fa) to identify which IDs are mismatched.</li>
        <li> Re-run the GenomeThreader spliced alignment output using correct IDs, or carry out an ID substitution (search and replace) in the ~.gth file.</li>
        <li>Re-run the pipeline in <b>Update</b> mode, or <b>Drop</b> the GDB and start over with the corrected data files</li>
    </ol>
</div>
