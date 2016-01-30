<div class="dialogcontainer">

     <h2 class="bottommargin1">Search by Region</h2>

	 <p><span class="tip_style"><b>Navigation</b>:</span></p>
	    <ul class="bullet1">
	        <li>From Top menu: <i>GDB Home &rarr; Left Menu &rarr; Search &rarr; By Region</i> (user must supply coordinates) </li>
	        <li>From Genome Context View submenu:  <i>Download &rarr; Sequence Data</i> (loads coordinates from current view)</li>
	    </ul>

		<h3>What it does:</h3> 
		<ul class="bullet1">
		<li>This tool retrieves FASTA-formatted sequences, or GenBank, GFF or EMBL-formatted genome annotations from any genome region specified.</li>
		<li>Results are displayed in a new window, and they can then be downloaded as a text file or copied.</li>
		<li>Note: only a single sequence type (EST, cDNA, etc) can be specified per request.</li>
	</ul>



	<h3 class="topmargin1">STEP 1: ENTER Scaffold ID and Region</h3>
	<ul class="bullet1">
		<li>Specifies region from which sequence will be retrieved. Default is region most recently browsed </li>
		<li>Be sure to specify region first before selecting options below</li>
	</ul>

	<h3 class="topmargin1" >STEP 2a: SELECT Genome from  __ to __:</h3>
	<ul class="bullet1">
		<li>Retrieves genome sequence from the specified range</li>
	</ul>

	<h3 class="topmargin1">STEP 2b: SELECT Aligned/Computed Sequences from __ to __</h3>
	<ul class="bullet1">
		<li>Aligned sequence types depend on the genome but minimally include EST, cDNA, PUT, Protein</li>
		<li>Computed sequence types include published gene models and yrGATE (community) annotations. They can be retrieved as either DNA or as protein translations</li>
		<li>If the aligned sequence is not completely contained within the specified range, it cannot be retrieved. Adjust the range to retrieve any partially contained sequences.</li>
	</ul>

	<h3 class="topmargin1">STEP 2c: SELECT Genome Annotations from __ to __</h3>
	<ul class="bullet1">
		<li>This option retrieves genome annotations as GenBank, GFF3, or EMBL formatted files</li>
		<li>If a gene model is not completely contained within the specified range, it will not be included in the file. Adjust the range to retrieve any partially contained sequences.</li>
	</ul>

			<span class="heading normalfont linkback"> <a class="smallerfont" href="/XGDB/help/genome_browser.php#genome_region_search">View this in Help Context (genome_browser.php/genome_region_search)</a> </span>


</div>
