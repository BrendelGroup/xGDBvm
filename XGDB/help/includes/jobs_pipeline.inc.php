
<div class="dialogcontainer">
	<h2 class="bottommargin1">To run remote HPC job(s) as part of the GDB pipeline:</h2>
	    <ul class="bullet1 nobullet">
            <li><b>1.</b> If not done so, check your VM's configuration:
                <ul class="bullet1 indent2">
                    <li>The VM must be configured for access to the remote computing API and HPC apps --check under <a href="/XGDB/jobs/configure.php">Configure API</a> and <a href="/XGDB/jobs/apps.php">Configure Apps</a></li>
                    <li>Your iPlant Data Store must be correctly mounted to the VM --see help section <a href="/XGDB/help/create_gdb.php#config_input_datastore">Input Data: iPlant DataStore</a> </li>
                </ul>
            </li>
			<li><b>2.</b> If not done so, complete the authorization process on the '<a href="/XGDB/jobs/login.php">Authorize / Log In</a>' page.
				<ul class="bullet1 indent2">
					<li>This VM must first be <b>registered</b> using your iPlant username/password in order to obtain your OAuth credentials. This is a one-time operation for any VM user.</li>
					<li>You will then be able to <b>authenticate</b> using your username/password and obtain a limited-span access token on the same page, allowing you to submit a job.</li>
					<li>Your access token can also be <b>refreshed</b> on this page.</li>
				</ul>
			</li>
            <li><b>3.</b> Create a 'New GDB' configuration under xGDBvm's  <a href="/XGDB/conf/new.php">Create New GDB</a>, or edit an  <a href="/XGDB/conf/viewall.php">existing GDB Configuration</a> (Status='Development'). Fill out all required information including a path to your input data:
                <ul class="bullet1 indent2">
                   <li>Your <b>input data directory</b> should be on your iPlant DataStore home directory (mounted to <span class="plaintext">/xGDBvm/input/</span>)</li>
                   <li>Make sure your data files are <a href="/XGDB/conf/data.php">properly named</a> and <span class="checked">validated</span> on the Configuration page</li>
                   <li>Make sure to select the <i>Comp Resources=<b>Remote</b></i> option under GeneSeqer and/or GenomeThreader.</li>
                </ul>
            </li>
			<li><b>4.</b> Now <i>Save</i> your GDB configuration. If not already logged in, the page will prompt you to <b>Log In</b> using your iPlant credentials. </li>
			<li><b>5.</b> Return to your saved configuration, and <b>Initiate</b> your pipeline job by clicking buttons <i>'Data Process Options'</i> and then <i>'Create GDB'</i>. The VM is now <span class="Locked">Locked</span> until pipeline finishes.</li>
			<li><b>6.</b> Check <a href="/XGDB/jobs/jobs.php">Job List</a> for job status. </li>
            <li><b>7.</b> The pipeline will submit a separate remote HPC job for each transcript (EST, cDNA, TSA) or protein dataset in your input directory. </li>
			<li><b>8.</b> Any additional HPC jobs will be assigned a new job ID and processed after the previous one is completed. Once all remote HPC jobs are completed, outputs will be further processed by the pipeline.</li>
            <li><b>9.</b> A copy of each HPC output data file will be retained in your DataStore home directory under <span class="plaintext">../archive/jobs</span>, e.g.
					 	<ul class="bullet1 indent2">
					 		<li> <span class="plaintext">../archive/jobs/job-0001424630343236-5056a550b8-0001-007/GSQOUTPUT/estGDB001.gsq</span> (GeneSeqer)</li>
							<li> <span class="plaintext">../archive/jobs/job-0001424630343236-5056a550b8-0001-007/pepGDB001.gth</span> (GenomeThreader)</li>
						</ul>
			</li>
            <li><b>10.</b> Output files are also archived in the GDB output directory and can be downloaded by navigating to the <i>Resources &rarr; Data Download</i> section of your GDB</li>
            <li><b>11.</b> Any pipeline or HPC compute errors will be logged in the <b>Pipeline</b> Log file accessible from the Config page or the <i>Resources &rarr; Pipeline Logs</i> section of your GDB</li>
        </ul>
<span class="heading normalfont linkback"> <a class="smallerfont" href="/XGDB/help/remote_jobs.php#jobs_pipeline">View this in Help Context</a> (remote_jobs/jobs_pipeline)</span>
</div>
