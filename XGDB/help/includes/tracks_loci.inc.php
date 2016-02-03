<div class="dialogcontainer">

	<h2>Gene Models (Tabular View)</h2>
<hr class="featuredivider" />

<p>This page displays either precomputed or CpGAT-derived gene predictions, organized by locus and listed in order of position on each genome segement. Metadata include description, EST/cDNA coverage, GAEVAL quality scores, and yrGATE community annotations (if any). Use the <b>filter</b> options or <b>search</b> box to narrow results. Download search results by clicking <i>Download .csv</i>.</p>

<h3>(1) Select Track</h3>
	<ul class="bullet1 indent2">
	    <li>xGDBm displays up to two Gene Model tracks: <span style="background-color:blue; color:white">Gene Models (from GFF3)</span> and <span style="background-color:fuchsia; color:white">Gene Models (from CpGAT)</span>. Users can also configure additional tracks manually (see Wiki)</li>
		<li>To view a different Gene Prediction dataset, select its Track Name from the <b>Dropdown menu</b> </li>
		<li>After selection, the Track Name is displayed against a colored background that matches the track color</li>
	</ul>
<h3>(2) Use Search and Filters to drill down to keywords or regions of interest:</h3>
	<ul class="bullet1 indent2">
		<li><b>Search</b> by Locus ID, Genome Region (scaffold:from..to), Scaffold ID, Description, mRNA Length </li>
		<li><b>Filter</b> by Coverage Score, Integrity Score, yrGATE Status</li>
		<li>Searches and Filters are Boolean (AND).</li>
	</ul>

<h3>(3) Columns, left to right:</h3>
	<ul class="bullet1 indent2">
		<li><b>Locus ID:</b> The ID assigned to this locus. Click to search for all transcripts with this locus ID.</li>
		<li><b>Genome View:</b> Click to view this locus in genome context.</li>
		<li><b># Transcripts</b> The number of gene models annotated at this locus.</li>
		<li><b>Span/Max Intron Count/</b> These data represent maximal result over all transcripts at that locus.</li>
		<li><b>Locus Description/Gene:</b> Data taken from column 8 of the GFF table, representing gene description (if any).</li>
		<li><b>Gene Structure Annotation Project:</b> Loci assigned to a pathway, function, phenotype or other category. You can filter by project using the dropdown.</li>
		<li><b>Coverage/Integrity:</b> Averages of coverage by evidence alignments (EST, cDNA) and their degree of support for models(s) at this locus. (See <a class="help_style" title="GAEVAL Help" href="/XGDB/help/gaeval.php">GAEVAL</a> for details)</li>
		<li><b>Anno Count/Annotation Class/Gene Product:</b>Number of yrGATE annotations at this locus, their class, and yrGATE gene product (if any). (See <a class="help_style" title="yrGATE Help" href="/XGDB/help/yrgate.php">yrGATE help</a> for details)</li>
		<li><b>Annotation Status:</b> pending or published. If published, click <img src="/XGDB/images/commcentral.gif" alt="commcentral link" /> to go to Community Central.</li>
		<li><b>Annotate it!</b>: Click <img src="/XGDB/images/annotate.gif" alt="annotate link" />  to annotate this locus using yrGATE.</li>
	</ul>
	
				<span class="heading normalfont linkback"> <a class="smallerfont" href="/XGDB/help/feature_tracks.php#tracks_loci">View this in Help Context</a> (locus_tables.php/tracks_loci)</span>
</div>
