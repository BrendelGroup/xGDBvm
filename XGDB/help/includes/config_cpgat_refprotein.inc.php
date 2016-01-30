<div class="dialogcontainer">
	<h2 class="bottommargin1">CpGAT- Reference Protein Library</h2>
<p>A fasta-formatted list of well-curated proteins from your taxonomic group, used by CpGAT for best hit evaluation.</p>
	<ul class="bullet1 indent2">
		<li>Default is the <a href="http://korflab.ucdavis.edu/Datasets/cegma/index.html#SCT3">CEGMA</a> core protein dataset <b>cegma_core.fasta</b> (1427 proteins).</li>
		<li>For best results, use a custom dataset such as <a href="http://www.uniprot.org/help/uniref">UniRef90</a> tailored to your genome's taxonomic group.</li>
		<li>See the xGDBvm wiki for instructions for <a href="http://goblinx.soic.indiana.edu/wiki/doku.php?id=uniref">downloading a UniRef dataset</a> </li>
	</ul>
	<h3>To specify a Reference Protein dataset:</h3>
	<ul class="bullet1 indent2">
		<li>Download a suitable <b>reference protein dataset</b> (FASTA-formatted)</li>
		<li>Upload to a standard directory: <span class="plaintext normalfont">/xGDBvm/input/<b>referenceprotein</b>/</span>, which for iPlant users is <span class="plaintext normalfont">/home/username/referenceprotein/</span></li>
		<li>Select the filename and path from the dropdown under <b>Gene Prediction: Reference Protein Index</b> on the Configuration page.</li>
		<li>Once you save your Configuration, xGDBvm will validate the filename/path you have entered.</li>
	</ul>
	<span class="heading normalfont linkback"> <a class="smallerfont" href="/XGDB/help/create_gdb.php#config_cpgat_refprotein">View this in Help Context</a> (create_gdb.php/config_cpgat_refprotein)</span>
</div>
