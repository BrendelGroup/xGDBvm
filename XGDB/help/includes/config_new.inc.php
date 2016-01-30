
<div class="dialogcontainer">
	<h2 class="bottommargin1">Configure New GDB</h2>
<hr class="featuredivider" />


<h3>Navigation</h3>
	 <p>Manage &rarr; Configure/Create &rarr; <a href="/XGDB/conf/new.php">Configure New GDB</a> </p>
	 

<h3>Overview</h3>
	<p>Use this page to configure a new genome browser, prior to running the data pipeline. Minimum requirements are a unique name and an input data path. Once you click 'Save', you can then proceed to 'Database Options' where you can initiate the data processing pipeline.</p>

<h3 class="topmargin1">Configuration Sections:</h3>
	<ul class="bullet1 indent2">
		<li><span class="bold">Database: </span> General information for GDB creation goes here</li>
		<li><span class="bold">Input Data: </span> Location of input data files</li>
		<li><span class="bold">Transcript Spliced Alignment and Protein Spliced Alignment</span> 
			<ul class="bullet1 indent1">
				<li> Enter any non-default parameters for GeneSeqer, GenomeThreader spliced alignment</li>
				<li> Select 'Remote Compute' option (if available) to speed processing time via high performance computing (HPC) (see <a href="/XGDB/help/remote_jobs.php">Remote Jobs</a> help).</li>
			</ul>
		</li>
		<li><span class="bold">Gene Prediction:</span> To predict genes using <a href="/XGDB/help/cpgat.php">CpGAT</a> (optional), Choose <i>Predict Genes?</i> Y (default N) and enter any non-default parameters.</li>
		<li><span class="bold">Default Display: </span> enter default display information, e.g. scaff_01 from 1 to 10,000</li>
		<li><span  class="bold">Genome Information (optional)</span>: Enter metadata associated with the sequence data you are using to create the GDB</li>
		</ul>		

	<h3 class="topmargin1">Saving your new GDB</h3>
	<ul class="bullet1 indent2">
		<li>When you click 'Save', your GDB is assigned a unique number (e.g. 'GDB001') and has <span class="Development">Development</span> status until you run the 'Create New GDB' pipeline.</li>
		<li>The new GDB configuration will be listed under the Left Menu -> <a href= "/XGDB/conf/viewall.php">List All Configured</a></li>
		<li>You can now view and edit the new GDB configuration by clicking its ID number </li>
	</ul>
	

	<h3 class="topmargin1">Try the Examples!</h3>
	<ul class="bullet1 indent2">
		<li>Click the <span class="xgdb_button colorR5 smallerfont">'Example Datasets'</span> button, choose an Example dataset, and <i>'Save'</i> it to populate the configuration file</li>
		<li>You can now click <i>'Data Process Options..." &rarr; 'Create New GDB'</i> to create a sample genome browser and database. </li>
	</ul>
	

			<span class="heading normalfont linkback"> <a class="smallerfont" href="/XGDB/help/create_gdb.php#config_new">View this in Help Context</a> (create_gdb.php/config_new)</span>
	
</div>

