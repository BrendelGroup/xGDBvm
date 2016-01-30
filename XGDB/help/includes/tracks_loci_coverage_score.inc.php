<div class="dialogcontainer">

	<h2>Feature Tracks: Coverage Score (Gene predictions)</h2>
<hr class="featuredivider" />

<p><b>Coverage Score</b> for gene predictions indicates the degree to which  spliced-alignment evidence (same-species cDNA, EST, TSA) covers a gene model's exon-intron-UTR structure. (<a target="_blank" href="/src/GAEVAL/docs/integrity.html">see details</a>). Coverage scores reported here are an average across all gene models at this locus. </p>
<p>The Coverage Score is computed by the <a target="_blank" href="/XGDB/help/gaeval.php">GAEVAL</a> system for gene quality analysis. See also <b>Integrity Score</b>.</p>

	<ul class="bullet1 indent2">
		<li>A Coverage Score of 1.0 indicates 100% coverage by evidence alignments</li>
		<li>A lower score indicates that some exons of the gene model are are not supported by alignment evidence.</li>
		<li>Note that exons may be supported by other transcript evidence not shown here, and/or by protein evidence which is not considered in calculating coverage.</li>
		<li>If Coverage is high (e.g. &gt;90%) and Integrity is low (e.g &lt;75%), then the model is a good candidate for closer evaluation and possible re-annotation using yrGATE.</li>
		<li>Coverage between 0.5 and 0.75 will be colored <span style="color:#B100BF">violet</span>; less than 0.5 <span style="color:red">red</span>.</li>
	</ul>

<p>Use the 'Coverage Score' filter to select all entries above or below the threshold selected in the dropdown.</p>

				<span class="heading normalfont linkback"> <a class="smallerfont" href="/XGDB/help/feature_tracks.php#tracks_loci_coverage">View this in Help Context</a> (feature_tracks.php/tracks_loci_coverage)</span>
</div>
