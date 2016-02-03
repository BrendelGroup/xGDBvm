
<div class="dialogcontainer">
	<h2 class="bottommargin1">Repeat Mask this Genome?</h2>
	
	<p>Select this option to <b>mask</b> repeated regions of your input genome via <a href="http://www.vmatch.de/">Vmatch</a> software and a user-provided Repeat Mask Library file. This is highly recommended for larger genomes known to contain a high repeat or transposon content. </p>
	
		<ul class="bullet1 indent2">
			<li>You will need to designate a <b>Repeat Library</b>, a fasta (~.fa) file containing a repeat masking dataset</li>
			<li>The <b>Repeat Library</b> is placed in a standard directory: <span class="plaintext">/xGDBvm/input/repeatmask/</span> (which for iPlant users is Data Store home: <span class="plaintext">/home/username/repeatmask/</span>.</li>
			<li> Masked bases are replaced with "N" in the output genome file.</li>
			<li> After the pipeline is completed, the repeat masked regions will be displayed as a separate track (orange for repeat masked regions) in the genome browser.</li>
			<li> The repeat-masked genome (<span class="plaintext">GDB001gdna.rm.fa</span>), masked regions (<span class="plaintext">GDB001mask.fa</span>), and the masking library will be indexed for BLAST and available for download, along with other output data</li>
		</ul>
	
	<p>The resulting repeat-masked version of your genome may be utilized in two distinct pipeline processes, depending on what options you select:</b>
	<ol class="orderedlist1 indent2">
		<li>
			GeneSeqer spliced alignment (when using option <b>Repeat Mask: Yes</b>)
		</li>
		<li>
			CpGAT <i>ab initio</i> gene finder analysis (when using option <b>Skip Mask: No</b>)
		</li>
	</ol>
	
	
	<p class="bottommargin1"><span class="tip_style"></span>NOTE: as an alternative to the above, you can provide a <b>pre-masked genome</b> (named as <span class="plaintext"> ~gdna.rm.fa</span>) along with the unmasked genome (<span class="plaintext">~gdna.fa</span>) as input. This will bypass the Vmatch repeat masking step.</p>


			<span class="heading normalfont linkback"> <a class="smallerfont" href="/XGDB/help/create_gdb.php#config_repmask_option">View this in Help Context</a> (create_gdb.php/config_repmask_option)</span>


</div>
