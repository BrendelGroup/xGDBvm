<div class="feature" id="transcr">
	 
			<h2 class="bottommargin1">B. What types of sequence (transcript, protein) should I use to align to my genome?</h2>
			
			<p>Use the decision tree below to help you decide what data to use to build a genome annotation. File <span class="plaintext largerfont">naming conventions</span> are in parentheses, where <span class="plaintext largerfont bold">~</span> indicates user's prefix.</p>
			
			<ol class="directorylist topmargin1 bottommargin1">
			
				<li>
				<span class="alertnotice bold">1. I have pre-computed RNA and/or protein spliced alignments for my genome</span>
					<ul class="">
						<li>
							<b>YES</b>: Great! Use as input data: 1) GeneSeqer and/or GenomeThreader output files appropriately named (e.g. <span class="plaintext largerfont">~est.gsq</span>) ; 2) the corresponding raw data sequence files in fasta format, appropriately named (e.g. <span class="plaintext largerfont">~est.fa</span>).
						</li>
						<li>
							<b>NO</b>: No problem, xGDBvm will run the spliced alignment on appropriate data types. Move to option 2.
						</li>
					</ul>
				</li>
				<li>
				<span class="alertnotice bold">2. Short reads available for my species?</span>
					<ul class="">
						<li>
							<b>YES</b>: Not usable currently, but short read assemblies OK; move to option 2.
						</li>
						<li>
							<b>NO</b>: OK, you need to find other data types. Go to option 2.
						</li>
					</ul>
				</li>
				<li>
				<span class="alertnotice bold">3. Short read assemblies available for my species?</span>
					<ul class="condensed">
						<li>
							<b>YES</b>: Use them as TSA type <sup>1</sup> (<span class="plaintext largerfont">~tsa.fa</span>) type.
						</li>
						<li>
							<b>NO</b>: OK, you need to find other data types. Go to option 4.
						</li>
					</ul>
				</li>
				<li>
				<span class="alertnotice bold">4. Abundant EST available for my species and/or one closesly related to mine?</span>
					<ul class="condensed">
						<li>
							<b>YES</b>: Use them as data type EST (<span class="plaintext largerfont">~est.fa</span>).
						</li>
						<li>
							<b>NO</b>: OK, you need to find other data types. Go to option 5.
						</li>
					</ul>
				</li>
				<li>
				<span class="alertnotice bold">5. Abundant cDNA available for my species and/or one closesly related to mine?</span>
					<ul class="condensed">
						<li>
							<b>YES</b>: Use them as data type cDNA  (<span class="plaintext largerfont">~cdna.fa</span>).
						</li>
						<li>
							<b>NO</b>: OK, you need to find other data types. Go to option 6.
						</li>
					</ul>
				</li>
				<li>
				<span class="alertnotice bold">6. Transcript Sequence Assembly (TSA) available for my species or closely related one?</span>
					<ul class="condensed">
						<li>
							<b>YES</b>: Use them as data type TSA (<span class="plaintext largerfont">~tsa.fa</span>) or  EST (<span class="plaintext largerfont">~est.fa</span>)<sup>1</sup>
						</li>
						<li>
							<b>NO</b>: If no other transcript types are available, your best bet is one or more related-species protein datasets (option 7).
						</li>
					</ul>
				</li>
				<li>
				<span class="alertnotice bold">7. Protein sequences from a closely-related model species available?</span>
					<ul class="condensed">
						<li>
							<b>YES</b>: Great! These are a useful supplement (or substitute) to a transcript dataset for modeling genes.  Format them as data type Protein (<span class="plaintext largerfont">~prot.fa</span>)
						</li>
						<li>
							<b>NO</b>: If no other data types are available, you can consider using proteins from even a more distantly-related model species or even a combination of species protein datasets.
						</li>
					</ul>
				</li>
			</ol>
			
<p><span class="heading smallerfont linkback"> <a class="smallerfont" href="/XGDB/help/create_gdb.php#config_data_decisions-transcr">View this in Help Context</a> (create_gdb.php/config_data_decisions-transcr)</span></p>

</div>
