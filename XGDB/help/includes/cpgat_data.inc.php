
<div class="dialogcontainer">
	<h2 class="bottommargin1">Input Data for CpGAT</h2>
<p>CpGAT uses three types of input data, specified in the GDB configuration:</p>

<ul class="bullet1">
	<li><b>Spliced-alignment data</b> from transcripts and related-species proteins (from xGDB pipeline or user-provided), used to compute initial evidence models</li>
	<li><b>Genomic DNA, masked using a repeat mask dataset</b> (default or user-provided), used to compute <i>ab initio</i> gene models via three distinct prediction programs.</li>
	<li> A <b>reference protein blast index</b> (default or user-provided), used to evaluate CpGAT gene models and provide a high quality set of predicted genes.</li>
</ul>
<p>In addition, the user can specify various <b>input parameters</b> for the above computations, and/or <b>skip</b> certain analysis steps.</p>
</div>
