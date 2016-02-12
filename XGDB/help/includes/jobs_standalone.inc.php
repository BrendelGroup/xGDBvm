
<div class="dialogcontainer">
	<h2 class="bottommargin1">To submit a "standalone" HPC job using xGDBvm:</h2>
	                <ul class="bullet1 nobullet">
          	  <li><b>1.</b> If not done so, check your VM's configuration:
						<ul class="bullet1 indent2">
						    <li>This VM must be fully configured for access to Agave API's and have valid GeneSeqer and/or GenomeThreader <b>App ID's</b> --check under 'Manage' &rarr; 'Remote Jobs' &rarr; '<a href="/XGDB/jobs/configure.agave.php">Configure for HPC</a>'</li>
						    <li>Visit <a title="View Discovery Environment at iPlant" target="_blank" href="https://de.iplantcollaborative.org/de/">Discovery Environment </a> for list of all Apps</li>
	                        <li>Your <b>iPlant Data Store</b> must be mounted to the VM for data I/O--see help section under 'Create a GDB', entitled '<a href="/XGDB/help/create_gdb.php#config_volumes">Configure Volumes</a>' </li>
						</ul>
						</li>
	                <li><b>2.</b> If not done so, complete the Authorization / Log In process on the 'Manage' &rarr; 'Remote Jobs' &rarr; '<a href="/XGDB/jobs/userlogin.agave.php">Authorize / Log In</a>' page.
                    <li><b>3.</b> Create a 'New GDB' configuration under xGDBvm's 'Manage' &rarr; 'Config/Create' &rarr; <a href="/XGDB/conf/new.php">Create New GDB</a>, or edit an <a href="/XGDB/conf/viewall.php">existing GDB</a> (Status='Development'). Fill out all required information including a path to your input data:
	                	<ul class="bullet1 indent2">
	                	    <li><span class="warning">NOTE: you MUST configure a GDB in order to use the <a href="/XGDB/jobs/submit.agave.php">Submit Jobs</a> (standalone) page in xGDBvm</span></li>
                            <li>The <b>input data directory</b> should be under your iPlant DataStore home/xgdbvm/ directory, accessible on the VM as <span class="plaintext">/xGDBvm/input/xgdbvm/MyInputs/</span>)</li>
						   <li> Make sure your input data files are <a href="/XGDB/conf/data.php">properly named</a> and <span class="checked">valid</span> <img class="nudge3" alt="i" src="/XGDB/images/information_green.png" /> on the Configuration page</li>
	  					    <li>You do NOT need to select the <i>Remote</i> option under GeneSeqer or GenomeThreader, since you are not running the pipeline at this time.</li>
                        </ul>
                        </li>
	                <li><b>4.</b>  On the 'Manage' &rarr; 'Remote Jobs' &rarr; '<a href="/XGDB/jobs/submit.agave.php">Submit Jobs</a>' page, select your <b>GDB ID</b> (e.g. GDB001) from the dropdown</li>
	                <li><b>5.</b>  On the Job Submission form (GSQ or GTH), follow stepwise instruction to confirm that your inputs are correctly configured, validated, and can be processed in the alloted time.</li>
					<li><b>6.</b>  Click <i>'Submit GSQ/GTH Job'</i>, which creates a <b>job id</b> and submits your data to the designated HPC cluster using iPlant <a href="http://agaveapi.co/">Agave</a> APIs.</li>
					<li><b>7.</b>  An email will be sent to the <b>Admin email</b> (if configured) at the start of job processing and also when processing is complete.</li>
					<li><b>8.</b>  Use the 'Manage' &rarr; 'Remote Jobs' &rarr; <a href="/XGDB/jobs/jobs.agave.php">List all Jobs</a>'  or '<a href="/XGDB/jobs/manage.agave.php">Manage Jobs</a>' page to check job status, or to stop or delete a job. 
					 	<ul class="bullet1 indent2">
					 	    <li>Changes in job status (from PENDING through FINISHED) are reported automatically to your VM a they occur.</li>
					 	    <li>Refresh the 'Job List' page to view latest status and time stamp for each job in progress. Click any Status to view an explanation and troubleshooting tips.</li>
					 	    <li>You can also request current status for any job on the '<a href="/XGDB/jobs/manage.agave.php">Manage Jobs</a>' page.</li>
							<li>If something went wrong with a submitted job, use the 'Stop Job' feature to terminate a job process (available on both Manage Jobs and Job List pages).</li>
					 		<li>You can also click 'Delete' to remove a Stopped or Finished job from the HPC server's listings. This is an irreversible action.</li>
					 		<li>Finally, you can remove jobs from xGDBvm's job listing by means of the check box to the left of each row. </li>
						</ul> 
					</li>
					<li><b>9.</b>  Output data are deposited on your DataStore under <span class="plaintext">../archive/jobs/</span> with filenames according to xGDBvm conventions, e.g.
					 	<ul class="bullet1 indent2 nobullet">
					 		<li> <span class="plaintext">../archive/jobs/job-0001424630343236-5056a550b8-0001-007/estGDB001.gsq</span> (GeneSeqer) for EST spliced alignments;</li>
							<li> <span class="plaintext">../archive/jobs/job-0001424641367123-5056a550b8-0001-007/protGDB001.gth</span> (GenomeThreader) for protein spliced alignments.</li>
						</ul>
					
					<li><b>10.</b>  After successful completion, action buttons in the '<a href="/XGDB/jobs/jobs.agave.php">List all Jobs</a>' table can help you manage your output files:
					 	<ul class="bullet1 indent2 nobullet">
					 		<li>Click 'Count' to automatically determine number of spliced alignments in the archived output file. The number will be reported in the same table cell.</li>
							<li>Click 'Copy' to copy the archived output file over to your data input file at e.g. <span class="plaintext">/xGDBvm/data/Myinputs/</span>. Once copied over, the file is ready to be used in a GDB pipeline process.</li>
						</ul> 
						</li>
					 </li>
                </ul>
<span class="heading normalfont linkback"> <a class="smallerfont" href="/XGDB/help/remote_jobs.php#jobs_standalone">View this in Help Context</a> (remote_jobs/jobs_standalone)</span>

</div>
