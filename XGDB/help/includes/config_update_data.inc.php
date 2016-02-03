
<div class="dialogcontainer">
	<h2 class="bottommargin1">Update Data Files</h2>
	<p>Update data files should be placed in the directory specified under 'Update Data Path' configuration. Read carefully about <a target="_blank" title="Detailed file format and naming conventions (click ? to open new web page)" href="/XGDB/help/create_gdb.php#config_file_names">filename conventions</a> and make sure each file is named appropriately; otherwise data will not be processed.</p>
	
<p>Update data and actions include:</p>
	<ol class="bullet1 indent2">
	<li>Genome sequence (append)</li>
	<li>EST, cDNA, or transcript sequence assembly (TSA) sequence (append or replace/new)</li>
	<li>Related-species proteins (append or replace/new)</li>
	<li>Precomputed spliced alignment output files for the above (append or replace/new)</li>
	<li>Precomputed gene model annotations (.gff3 file) and their transcripts and translations (append or replace/new)</li>
	<li>Text file of <b>gene model IDs and descriptions</b> (tab-delimited ) -- specify precomputed models or CpGAT-derived models</li>
	</ol>

	<p>All <b>update data</b> will be copied to a <b>computation directory</b> for processing, and <b>output data</b> (including BLAST indices and alignment output files) will be written to a <b>GDB data directory</b> on your external data volume.</p>

			<span class="heading normalfont linkback"> <a class="smallerfont" href="/XGDB/help/create_gdb.php#config_update_data">View this in Help Context</a> (create_gdb.php/config_update_data)</span>
</div>

