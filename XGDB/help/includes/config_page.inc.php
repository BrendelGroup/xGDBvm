
<div class="dialogcontainer">
	<h2 class="bottommargin1">The Configure/Create Page</h2>
	
	<p><span class="heading"><b>Navigation:</b>	Manage &rarr; Configure/Create &rarr; <a href="/XGDB/conf/new.php">Configure New</a>  [if new GDB]</span></p>
	<p>- or - <span class="heading">Manage &rarr; Configure/Create &rarr; <a href="/XGDB/conf/viewall.php">List all Configured</a> &rarr; [select a GDB]</span></p>
	 
	<h3>Overview</h3>

	<ul class="bullet1">
		<li>The Configuration page is used to review or modify parameters and/or initiate data processing.</li>
		<li>It can also be used to enter metadata about the genome and aligned sequence (data sources, etc.)</li>
		<li>Each GDB configuration is assigned a unique ID, starting with GDB001, GDB002, etc.</li>
		<li><b>Tip:</b> the most recently-accessed configuration will be displayed in the Config/Create left menu bar under <i>List All Configured</i>(e.g. <i>GDB002 Conf</i>)</li>
	</ul>
	
	<h3>Database Options</h3>
	<ul class="bullet1">
		<li>When configuration is complete and saved, click the <img id='button_dp_options' style='margin-bottom: -5px' src='/XGDB/help/images/button_dp_opt.gif' alt='button' /> button at upper right for additional options, depending on status: Create, Drop, or Update. 
			<ul>				 					
				<li>If Status=<span class="Development">Development</span>, you can <b>Create</b> a Genome Browser, or <b>Restore</b> from an archive (if present)</li>
				<li>If Status=<span class="Current">Current</span> you can either <b>Update</b> <b>Drop</b> or <b>Archive</b> a Genome Browser. </li>
				<li>If Status=<span class="Locked">Locked</span> you can <b>Abort</b> data processing, which will also remove any data already processed. </li>
				<li>The <b>Drop</b> option deletes all computed data and lets you start over, whereas <b>Update</b> lets you add or replace some of the computed data</li>
			</ul>
		</li>
	</ul>
	<h3>Edit Configuration</h3>
	<ul class="bullet1">
		<li>Click to edit parameters or metadata. This can be done either before or after GDB creation.</li>
	</ul>
	<h3>Remote (HPC) option</h3>
	<ul class="bullet1">
		<li>If configured, GeneSeqer and/or GenomeThreader spliced alignment may be diverted to a high performance remote processor (HPC)</li>
		<li> Click <b>Remote</b> option in the appropriate configuration section. You will be required to log in with HPC authorization credentials.</li>
	</ul>
	<h3>Update option</h3>
	<ul class="bullet1">
		<li>For any <span class="Current">Current</span> genome browser, you have the option <b>Update</b> (append or replace) any data, rather than start over.</li>
		<li> Click <b>Edit</b> and refer to the 'Database Update' section of the config form for further instructions</li>
	</ul>
	<h3>Computation and Data Output</h3>
	<ul class="bullet1">
		<li>When you click '<span class="Create">Create</span>' or '<span class="Update">Update</span>', the pipeline copies files from the Input directory for processing, and also creates a new GDB directory on your attached storage volume, e.g. <span class="plaintext">/xGDBvm/data/GDB001/ </span></li>
		<li>All output data files and intermediate files are stored in a subdirectory on your volume under <span class="plaintext">/xGDBvm/data/GDB001/data </span> Input FASTA files, concatenated by type and renamed according to our schema, are placed there as well.</li>
		<li>A new MySQL database (named 'GDB001' , etc.) is created for access by the genome browser. All MySQL load scripts are also saved under <span class="plaintext">/xGDBvm/data/GDB001/data/</span></li>
		<li>When the pipeline is complete (several minutes to several hours, depending on size of the dataset), the Status will be updated to <span class="Current">Current</span></li>
		<li>The new GDB will now appear in the list of genome browsers ('View GDB ->Genome Browsers') and the dropdown main menu under 'Genomes'.</li>
		<li>A <b>logfile</b> detailing each step carried out can be accessed from the Configure page or the Genome Browser home page</li>
	</ul>
			<span class="heading normalfont linkback"> <a class="smallerfont" href="/XGDB/help/create_gdb.php#config_page">View this in Help Context</a> (create_gdb.php/config_page)</span>
</div>
