<div class="dialogcontainer">

	<h2>Feature Tracks: Integrity Score (gene predictions)</h2>
<hr class="featuredivider" />

<p><b>Integrity Score</b> is evaluated by estimating the level of annotation support which is required to provide a structure unlikely to be significantly altered by reannotation with available evidence.  (<a target="_blank" href="/src/GAEVAL/docs/integrity.html">See details here</a>)  The score here is an average across all gene models at this locus. </p>
<p>The Integrity Score is computed by the <a target="_blank" href="/XGDB/help/gaeval.php">GAEVAL</a> system for gene quality analysis. See also <b>Coverage Score</b></p>
	<ul class="bullet1 indent2"> 
		<li>An Integrity Score that matches Coverage indicates perfect congruence with evidence</li>
		<li>An Integrity score lower than Coverage indicates some degree of incongruence between alignment evidence and the annotated model.</li>
		<li>An Integrity score higher than Coverage indicates that the annotated model exons extend beyond available evidence.</li>
		<li>If Coverage is high (e.g. &gt;0.90) and Integrity is low (e.g &lt;0.75), then the model is a good candidate for closer evaluation and possible re-annotation.</li>
		<li>Integrity between 0.5 and 0.75 (if coverage >0.9) will be colored <span style="color:#B100BF">violet</span>; less than 0.5 <span style="color:red">red</span></li>
	</ul>

<p>Use the 'Integrity Score' filter to select all entries above or below the threshold selected in the dropdown.</p>

			<span class="heading normalfont linkback"> <a class="smallerfont" href="/XGDB/help/feature_tracks.php#tracks_loci_integrity">View this in Help Context</a> (feature_tracks.php/tracks_loci_integrity)</span>
</div>