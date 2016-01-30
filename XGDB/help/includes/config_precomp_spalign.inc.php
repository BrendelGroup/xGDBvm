<div class="dialogcontainer">
	<h2 class="bottommargin1">Pre-computed spliced alignments</h2>

<p>xGDBvm will parse and upload precomputed spliced-alignment outputs created using GeneSeqer/GenomeThreader if output files are included along with FASTA sequence file in the <b>Input Data Directory</b></p>

<p><b>Filenames</b> must be as follows, for EST, cDNA, TSA (transcript assembly) and Protein (related species proteins) data types: </p>

<h3>For GeneSeqer output:</h3>		

<ul class="bullet1">
	<li><span class="plaintext largerfont">~est.gsq </span> and <span class="plaintext largerfont">~est.fa </span></li>
	<li><span class="plaintext largerfont">~cdna.gsq </span> and <span class="plaintext largerfont">~cdna.fa</span></li>
	<li><span class="plaintext largerfont">~tsa.gsq </span> and <span class="plaintext largerfont">~tsa.gsq </span></li>
</ul>
    
<h3>For GenomeThreader output:</h3>
<ul class="bullet1">
	<li><span class="plaintext largerfont">~prot.gth </span> and <span class="plaintext largerfont">~prot.gth </span></li>
</ul>

<p class="warning">Make sure sequence IDs match between the two file types.</p>

<p><span class="tip_style">See also <a href="/XGDB/conf/data.php">Data Requirements</a> page for complete details on file formats. </span></p>

	<span class="heading normalfont linkback"> <a class="smallerfont" href="/XGDB/help/create_gdb.php#config_precomp_spalign">View this in Help Context</a> (create_gdb.php/config_precomp_spalign)</span>


</div>
