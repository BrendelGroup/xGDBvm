
<div class="dialogcontainer">

	<h2><a href="#yrgate_annotation_mistakes">Common annotation mistakes</a></h2>
<hr class="featuredivider" />
		<h3>You will probably make one or more of these mistakes if you are just starting out!</h3>

		<ul class="bullet1 indent1">
				<li><b>Truncated Exons:</b> Make sure each non-terminal exon of your model contains a valid splice junction at both ends. If you join a truncated exon to another exon, you are creating an artifact!
					<img class="helpfigure" src="/XGDB/help/images/yrgate_trunc_exon.png" style="width:40%" alt="yrgate truncated exon image" />
				</li>
				<li><b>Where's the ORF??</b> Don't forget to use the ORF finder, unless you are annotating a noncoding RNA!</li>
				<li><b>Case of the missing Start/Stop:</b> Be careful that the ORF you choose includes BOTH a start (M) and stop codon (*). Otherwise it is not valid, even though the structure image will contain start/stop glyphs.</li>
				<li><b>Missing the "Big Picture":</b> It's easy to annotate a structure without noticing there are evidence alignments or gene models extending out of range. Time to zoom out and get the full picture using use "Change Location" button.</li>
				<li><b>Where's the Evidence?</b> Don't use exons from a non-evidence source (e.g. published annotation) if the same exons exist in an evidence alignment, as no alignment scores are associated with these. They will simply appear as coordinates under "User Defined Exons". You may use them if no evidence is available and they support a reasonable structure, of course.</li>
				<li><b>Longer is (usually) better:</b> Look for the longest 5' or 3' evidence at a locus and include it in your model if it is otherwise congruent. <b>Exception:</b> if you have reason to think a certain alternative transcription start site is associated with a particular structure, use it instead but state the reason in your description. See also the next tip:</li>
				<li><b>Misjudging the 5' end:</b> Often ESTs are not full-length w/ respect to the 5' end of a transcript; use them with caution for 5' terminal exons, unless you have abundant evidence. See next tip:</li> 
				<li><b>Blastp is your friend!</b> Don't forget to blast your ORF against GenBank NR. It's two clicks away! If the blastp result suggests your predicted protein is less than full length, look for more evidence alignments (mRNA or protein) or gene model exons upstream. If there are none, use one of the <i>ab initio</i> Gene Finder portals to identify additional exons.</li>
				<li><b>It's not me it's the genome:</b> If you can't find a good ORF with a well-supported structure, don't forget to consider genome sequence error as a factor. You can view the alignments at base-pair level to detect such errors, and the Genome Sequence Edit tool provides a means to correct them.</li>

		</ul>
<span class="heading normalfont linkback"> <a class="smallerfont" href="/XGDB/help/yrgate.php#yrgate_annotation_mistakes">View this in Help Context</a> (yrgate/yrgate_annotation_mistakes)</span>
</div>

