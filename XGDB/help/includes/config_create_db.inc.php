
<div class="dialogcontainer">
	<h2 class="bottommargin1">Create Database</h2>
	
	<p><img id='button_create_db' style='margin-bottom: -5px' src='/XGDB/help/images/button_create_db.gif' alt='Create DB' /> initiates the xGDBvm pipeline to create a <b> new xGDBvm database and genome browser </b></p>

	<h3>To create a genome database:</h3> 
	
	<ul class="bullet1 indent2">
        <li>Make sure GDB configuration is correct, including input data path. Edit if necessary.</li>
        <li>Place all necessary data files, correctly named, in the input directory you specified on your attached volume.</li>
        <li>Click <i>'Data Process Options' &rarr; 'Create New GDBnnn Database'</i> to start pipeline. Status is updated to <span class="Locked">Locked</span> to indicate the proces is underway.</li>
         <li>You can monitor the process under <i>'View/Edit Configured'</i>, by refreshing your web browser. Once complete, the GDB status will be changed to <span class="Current">'Current'</span>.</li>
         <li>Once complete (from minutes to many hours, depending on genome size and number of alignments), the new genome will added to the Genomes menu. </li>
         <li>Click <i>'Cancel'</i> to return to configuration view.</li>
	</ul>
	<h3>Computation and Data Output</h3>
	<ul class="bullet1 indent2">
		<li>When you click 'Create' or 'Update', the pipeline copies files from the Input directory for processing, and also creates a new GDB directory on your EBS storage, e.g. <span class="plaintext normalfont">/xGDBvm/data/GDB001/ </span></li>
		<li>All output data files and intermediate files are stored in a subdirectory on your attached volume under <span class="plaintext normalfont">/xGDBvm/data/GDB001/data/</span> Input FASTA files, concatenated by type and renamed according to our schema, are placed there as well.</li>
		<li>A new MySQL database (named 'GDB001' , etc.) is created for access by the genome browser. All MySQL load scripts are also saved under <span class="plaintext normalfont">/xGDBvm/data/GDB001/data/MySQL/</span></li>
		<li>When the pipeline is complete (several minutes to several hours, depending on size of the dataset), the Status will be updated to <span class="Current">Current</span></li>
		<li>The new GDB will now appear in the list of genome browsers ('View GDB ->Genome Browsers') and the dropdown main menu under 'Genomes'.</li>
	</ul>
	
			<span class="heading normalfont linkback"> <a class="smallerfont" href="/XGDB/help/create_gdb.php#config_create_db">View this in Help Context</a> (config_create_db.php/config_create_db)</span>

</div>
