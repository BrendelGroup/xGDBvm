
<div class="dialogcontainer">
	<h2 class="bottommargin1">The xGDBvm Pipeline</h2>
		 
	<p>The xGDBvm pipeline can be launched from the <b>Config</b> page of any <span class="Development">DEVELOPMENT</span> status GDB that has been correctly and completely configured (including correct input <a href="/XGDB/help/create_gdb.php#config_file_names_brief"> filenames and permissions</a>).</p>
	<p>Clicking <img src="/XGDB/help/images/button_dp_opt.gif" alt="data process options"/> &rarr;  <img src="/XGDB/help/images/button_create_db.gif" alt="create" /> starts the process.</p>
	<p> At that point the GBS status is changed to <span class="Locked"> LOCKED</span>, and no other pipeline processes can be initiated until completion.</p>
	<p>The pipeline consists of a shell script that initiates a series of computational steps based on user input data. The process, once launched, proceeds automaticaly and logs each step in a  <a href="/XGDB/help/create_gdb.php#config_pipeline_procedure_log">Procedure Log</a> and (if CpGAT is run) a <a href="/XGDB/help/create_gdb.php#config_pipeline_cpgat_log">CpGAT Log</a>. Any pipeline <b>ERRORS</b> are also logged in a separate <a href="/XGDB/help/create_gdb.php#config_pipeline_error_log">Error Log</a></p>

	<p>The Pipeline will :</p>
	<ul class="bullet1 indent2">
		<li>Create BLAST indices for all input FASTA data</li>
		<li>Repeat mask genome (if requested)</li>
		<li>Upload any precomputed data provided (gff3, spliced alignment, descriptions)</li>
		<li>Run transcript spliced-alignments (GeneSeqer) - EST, cDNA, TSA</li>
		<li>Run protein spliced-alignments (GenomeThreader)</li>
		<li>Run CpGAT Gene Prediction (optional)</li>
		<li>Run GAEVAL for any annotations</li>
	</ul>
	
	<p>On completion of the pipeline, GDB Status is changed to <span class="Current">CURRENT</span>, and the new GDB is added to the <i>'View'</i> menu. </p>
	
			<p><span class="heading normalfont linkback"> <a class="smallerfont" href="/XGDB/help/create_gdb.php#config_pipeline_overview">View this in Help Context</a> (create_gdb.php/pipeline_overview)</span></p>
</div>