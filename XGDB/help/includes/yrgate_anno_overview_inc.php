
<div class="dialogcontainer">
	<h2>Annotation in a nutshell:</h2>
	<hr class="featuredivider" />

<h3> A) Big Four questions you are trying to address.</h3>
<ul class="bullet1">
<li> 1) Does the alignment evidence support the published model or suggest an alternative structure?</li>
<li> 2) Does the model have a reasonable ORF (that spans most of the exons)</li>
<li> 3) Does the ORF translation have a top blastp hit from within the insect (or other invertebrate) world, suggesting it is protein coding?</li>
<li> 4) Does the blastp result suggest the gene model is complete (sufficient in length to encode a full length protein)
<ul>
<li>
-i.e. do the blastp query and target have similar protein length and match at similar amino acid numbers
</ul>
</li>
</ul>
<li>And after all that, does the model still look "reasonable" as a protein coding gene?</li>
</ul>

<h3> B) Things to remember :</h3>
<ul class="bullet1">
<li> 1) Never use an alignment fragment (one lacking an intron-exon junction) to represent a full exon.</li>
<li> 2) Pay attention to direction of transcription (the arrow should point from start (green) to stop (red) end of your model.</li>
<li> 3) Use the description field as a place to justify your annotation decision, and provide enough information so the the reviewer doesn't need to re-blast the ORF to figure out what's going on. </li>
<li> 4) Despite 3), never paste in a full blast output into the description field. Take the essential information (hit length, match from - to - % identity), copy/paste or type it in.</li>
</ul>
<h3> C) About the annotation classes, here are the criteria for choosing a class:</h3>
<ul class="bullet1">
<li> Is my structure identical to the published (blue) model? => Confirm Existing
<li> Is my structure identical in ORF (start-stop positions identical, all coding exons identical) but have longer or shorter 5' or 3' UTR? => Extend/Trim Existing
<li> Does my structure encode a distinct ORF from the published model it is being compared to? => IMPROVE Existing
<li> Does my structure encode a ALTERNATIVE ORF, in addition to the canonical one at this locus? => Transcript Variant
<li> Does my structure represent a new locus not previously annotated (perhaps due to split of single model into two loci)? => New Locus
<li> Does my analysis suggest the published model is incorrect or incomplete, but there is not enough evidence to suggest a better one? =? NOT RESOLVED
<li> Does my analysis suggest this published model is not a real gene => Recommend Delete		</ul>	
</ul>
</div>
