<div class="feature" id="anno">

	<h2 class="bottommargin1">C. How should I select genome annotation data (if available)?</h2>
		
		<p>Use the decision tree below to help you make sure your genome annotation data is appropriate for xGDBvm. File <span class="plaintext largerfont">naming conventions</span> are in parentheses, where <span class="plaintext largerfont bold">~</span> indicates user's prefix.</p>
		
		<ol class="directorylist bottommargin1 topmargin1">
			<li>
			<span class="alertnotice bold">1. I have a set of pre-computed gene model annotations </span>
				<ul class="">
					<li>
						<b>YES</b>: Include them (in GFF3 format) with your input data. Make sure segment IDs match your genome fasta file IDs (e.g. <span class="plaintext largerfont">scaff_1</span>). Move to <b>option 2</b>.
					</li>
					<li>
						<b>NO</b>: No problem, Move to option 3.
					</li>
				</ul>
			</li>
			<li>
			<span class="alertnotice bold">2. I have a set of descriptions for each gene model in the above file</span>
				<ul class="condensed">
					<li>
						<b>YES</b>: You can include them as a tab-delimited table (<b>ID</b> -tab- <b>Description</b>; <span class="plaintext largerfont">~annot.desc.txt</span>). Move to <b>option 3</b>.
					</li>
					<li>
						<b>NO:</b> No problem, you can still upload the GFF3 file and add descriptions later if possible, using xGDBvm's Update feature.
					</li>
				</ul>
			</li>
			<li>				 			
			<span class="alertnotice bold">3. My genome is full of low complexity regions (repeated sequences; transposons).</span>
				<ul class="">
					<li>
						<b>YES, but it is not repeat-masked</b>: You may want to include a <b>repeat mask dataset</b> with your genome data, and select <b>Repeat Masking</b> in your configuration file. The annotation pipeline will create a repeat masked version of the genome that will be used for GeneSeqer spliced alignment of transcripts.
					</li>
					<li>
						<b>No</b>: No problem, you are ready to go.
					</li>
				</ul>
			</li>
		</ol>
<p><span class="heading smallerfont linkback"> <a class="smallerfont" href="/XGDB/help/create_gdb.php#config_data_decisions-anno">View this in Help Context</a> (create_gdb.php/config_data_decisions-anno)</span></p>
	</div>