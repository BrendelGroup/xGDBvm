<div class="feature" id="gdna">

		<h2 class="bottommargin1">A. How should I prepare my genome sequence?</h2>
			
			<p>Use the decision tree below to help you make sure your genome sequence is appropriate for xGDBvm.File <span class="plaintext largerfont">naming conventions</span> are in parentheses, where <span class="plaintext largerfont bold">~</span> indicates user's prefix.</p>
			
			<ol class="directorylist bottommargin1 topmargin1">
				<li>
				<span class="alertnotice bold">1. My genome is assembled as pseudochromosomes and/or superscaffolds</span>
					<ul class="">
						<li>
							<b>YES</b>: Great! Format them in one or more <b>fasta</b> files named <span class="plaintext largerfont">~gdna.fa</span> and make sure each chromosome/scaffold has a unique sequence ID such as <span class="plaintext largerfont">>chr1</span> or <span class="plaintext largerfont">>scaff_1</span>. Move to <b>option 3</b>.
						</li>
						<li>
							<b>NO</b>: No problem, Move to option 2.
						</li>
					</ul>
				</li>
				<li>
				<span class="alertnotice bold">2. My genome is assembled as unordered contigs</span>
					<ul class="condensed">
						<li>
							<b>YES</b>: As long as the number of contigs is less than 50,000, you should be OK. Format them in one or more <b>fasta</b> files named <span class="plaintext largerfont">~gdna.fa</span> and use a sequence ID scheme such as <span class="plaintext largerfont">>contig_1</span>. Move to <b>option 3</b>.
						</li>
						<li>
							<b>NO, my genome consists of unassembled data:</b> It will probably not be worth it to annotate it - the fragment size will be too small.
						</li>
					</ul>
				</li>
				<li>				 			
				<span class="alertnotice bold">3. My genome is replete with low complexity regions (repeated sequences; transposons).</span>
					<ul class="">
						<li>
							<b>YES, and it is not repeat-masked</b>: You may want to include a <b>repeat mask dataset</b> with your genome data, and select <b>GeneSeqer Repeat Masking: Yes</b> in your configuration file. The annotation pipeline will create a repeat masked version of the genome that will be used for GeneSeqer spliced alignment of transcripts.
						</li>
						<li>
							<b>YES, but it is already repeat-masked</b>: No problem, as long the sequence is masked with uppercase 'N'. Be sure to name your files as <span class="plaintext largerfont">~gdna.rm.fa</span>
						</li>
					</ul>
				</li>
			</ol>
<p><span class="heading smallerfont linkback"> <a class="smallerfont" href="/XGDB/help/create_gdb.php#config_data_decisions-gdna">View this in Help Context</a> (create_gdb.php/config_data_decisions-gdna)</span></p>
</div>
