
<div class="dialogcontainer">
<h2 class="bottommargin1">To configure and run remote HPC jobs on xGDBvm,</h2>


			</p>
										
			<h3>1. Make sure your VM is correctly configured</h3>
		<ul class="bullet1 indent1">
                    <li>The VM must be configured for access to the remote computing API and HPC apps under <i>'Manage'</i> &rarr; <i>'Remote Jobs'</i> :</li>
				<ul class="bullet1 indent1">
					<li>See <a href="/XGDB/jobs/configure.php">Configure API</a> for Agave API path (base URL, API version) used to send and receive job information and authentication</li>
					<li>See <a href="/XGDB/jobs/apps.php">Configure Apps</a> to configure App IDs for the GeneSeqer and GenomeThreader apps that will be launched to run the HPC job</li>
				</ul>
			</li>
			<li>Your VM <b>must</b> be mounted to your <b>iPlant Data Store</b> through a mount point at <span class="plaintext largerfont">/xGDBvm/input/</span>.
				<ul class="bullet1 indent1">
					<li>For mount status, visit ç&rarr; <i>'<a href="/XGDB/conf/volumes.php">Storage Volumes</a>'</i> </li>
					<li>For mounting instructions see <a href="http://goblinx.soic.indiana.edu/wiki/doku.php?id=user_instructions#mount_data_store_input">xGDBm Wiki:User Instructions:Mount Data Store</a> or <a href="/0README-iPlant"><span class="plaintext largerfont">/xGDBvm/0README-iPlant</span></a></li>
				</ul>
			</li>
			<li>For GenomeThreader (protein) spliced alignments, the <b>GTH license key</b> must be present at <span class="plaintext largerfont">/xGDBvm/input/keys/</span>
				<ul class="bullet1 indent1">
					<li>Navigate to <i>'Manage'</i> &rarr; <i>'Configure/Create'</i> &rarr; <i>'<a href="/XGDB/conf/licenses.php">License keys</a>'</i> for details</li>
					<li>A temporary license may be available for testing purposes</li>
				</ul>
			</li>
			<li>If you want to be notified when jobs are initiated/completed, navigate to <i>'Admin'</i> &rarr; <i>'<a href="/admin/email.php">Set Up Admin Email</a>'</i> and enter an email address.</li>
		</ul>
			<h3>2. Get authorized and authenticated</h3>
		<ul class="bullet1 indent1">
			<li>To submit jobs, you must first load user-specific authorization keys to this VM (a one-time operation).  
				<ul class="bullet1 indent1">
					<li>Navigate to <i>'Manage'</i> &rarr; <i>'Remote Jobs'</i> &rarr; <i>'<a href="/XGDB/jobs/login.php#auth">Get Authorization Keys</a>'</i></li>
					<li>Enter your iPlant credentials. If accepted, your <span class="checked">username</span> should appear on the list. You can now log in at any time to submit remote jobs on this VM.</li>
				</ul>
			</li>
			<li>Log in using your iPlant credentials.  
				<ul class="bullet1 indent1">
					<li>Navigate to <i>'Manage'</i> &rarr; <i>'Remote Jobs'</i> &rarr; <i>'<a href="/XGDB/jobs/userlogin.php#login">Authenticate User</a>'</i> and log in.</li>
					<li>Once logged in you can submit remote jobs, either as standalone or pipeline processes, for the lifespan of the login (currently set at 4 hr).</li>
					<li>If your login expires, use the 'Refresh' option to restart the clock on your login.</li>
				</ul>
			</li>
		</ul>
			<h3>3. Configure a GDB, get your data in place</h3>
		<ul class="bullet1 indent1">
			<li>Configure a <b><span class="Development">'Development'</span>-status GDB</b> using <i>'Manage'</i> &rarr; <i>'<a href="/XGDB/conf/index.php/">Configure/Create</a>'.</i>
				<ul class="bullet1 indent1">
					<li>You need to do this regardless of whether you intend to run a pipeline process or a standalone job.</li>
					<li>If this is your first remote job, we recommend starting with one or more <b>example datasets</b>, e.g. <a href="/XGDB/conf/new.php?example=8">Example 8</a> or <a href="/XGDB/conf/new.php?example=9">Example 9</a>, which are pre-configured for testing GeneSeqer and GenomeThreader remote processing, respectively.</li>
				</ul>
				</li>
			</ul>
			<ul class="bullet1 indent1">
				<li>If using your own data, you will be placing <a title="View Data Requirements for xGDBvm" href="/XGDB/conf/data.php">correctly-named input data files</a> in a directory on your DataStore, just as you would normally do for a GDB pipeline process. </li>
				<li>Validate your data using the 'Data Process Options' &rarr; 'Validate files' function on the GDB Config page, and correct any problems flagged. This is a critical step that will save you headaches down the road.</li>
			</ul>
			
			<h3>4. Submit the job or pipeline process</h3>
		<ul class="bullet1 indent1">
			<li>To run a <b>standalone</b> HPC job, after configuring a GDB for the correct inputs:
				<ul class="bullet1 indent1">
					<li> Navigate to <i>'Manage'</i> &rarr; <i>'Remote Jobs'</i> &rarr; <i>'<a href="/XGDB/jobs/submit.php">Submit</a>'</i>. Select your configured GDB ID from the dropdown, and click 'Select GDB'</li>
					<li> Scroll down to the GeneSeqer or GenomeThreader submission form, and follow instructions to validate inputs (if not already done), and modify any defaults.</li>
					<li> xGDBvm will try to estimate processing time based on the size of your input file and the number of processors selected.</li>
					<li> Select an App ID appropriate for your genome and segmentation Select a Maximum Time that is larger than your estimated running time.</li>
					<li> Click 'Submit job' to initiate job submission. After a pause while files are transferred on your VM, you will see a submission screen with information including submitted variables, a job name (based on your GDB config name) and a job ID (a unique identifier).</li>
					<li> Monitor job progress using <i>'Manage'</i> &rarr; <i>'Remote Jobs'</i> &rarr; <i>'<a href="/XGDB/jobs/jobs.php">List All Jobs</a>'</i>, or <i>'Manage'</i> &rarr; <i>'Remote Jobs'</i> &rarr; <i>'<a href="/XGDB/jobs/manage.php">Manage Jobs</a></i> </li>
					<li> When your job status is FINISHED, click the 'Count' button to return the number of alignments in the output file. If the number is close to your expectation, you can proceed; otherwise you will need to find the error and resubmit.</li>
					<li> Use the 'Copy' button to copy the outputs to your input directory if you want to use them in a later pipeline process. This process both copies and validates the output file in its new location.</li>
				</ul>
			</li>
			<li>To run <b>pipeline-integrated</b> HPC jobs, after configuring a GDB for the correct inputs:</li>
				<ul class="bullet1 indent1">
					<li>Go to <i>'Manage'</i> &rarr; <i>'Configure/Create'</i> &rarr; <i>'<a href="/XGDB/conf/view.php">GDB Conf</a>' (i.e. your GDB config page)</i>
					<li>Make sure the 'Remote' Option is selected for GeneSeqer and/or GenomeThreader.</li>
					<li>Follow instructions to validate inputs (if not already done), check predicted outputs, modify any defaults, and submit your pipeline job.</li>
					<li>The pipeline script will automatically submit your inputs for remote processing when appropriate, and it will retrieve and process outputs as part of its workflow (currently, only one remote job can be processed at a time)</li>
					<li>You can monitor progress using the Pipeline Procedure Log, or at <i>'Manage'</i> &rarr; <i>'Remote Jobs'</i> &rarr; <i>'<a href="/XGDB/jobs/jobs.php">List All Jobs</a>'</i> once the job is submitted.</li>
				</ul>
			</li>

		</ul>
			<h3>5. Troubleshooting and managing outputs</h3>
		<ul class="bullet1 indent1">
			<li>Job status, error messages, and job actions for each job can be found at <i>'Manage'</i> &rarr; <i>'Remote HPC'</i> &rarr; <i>'<a href="/XGDB/jobs/jobs.php">List All Jobs</a></i>'
				<ul class="bullet1 indent1">
					<li>Click on color-coded 'STATUS' (e.g. FAILED) to view an explanation and possible remedies, or refer to <a class="help_style" href="/XGDB/help/remote_jobs.php#status_troubleshoot">Help Pages - Job Status</a>.</li>
					<li>Errors related to the job submission process will be displayed in the right column. This may be an indication of incorrect configuration</li>
					<li>The remote HPC server may be down for maintenance or repair, resulting stalled queues or failed submission.  </li>
					<li> Use the 'Copy' button to copy the outputs to your input directory if you want to use them in a later pipeline process.</li>
					<li> You can STOP running jobs and DELETE completed or stopped jobs using the appropriate button. Deleted jobs can be cleared from the table using the REMOVE button.</li>
				</ul>
			</li>
			<li>To run <b>pipeline-integrated</b> HPC jobs,  after configuring a GDB for the correct inputs:
				<ul class="bullet1 indent1">
					<li> Go to <i>'Manage'</i> &rarr; <i>'Configure/Create'</i> &rarr; <i>'<a href="/XGDB/conf/view.php">GDB Conf</a>' (i.e. your GDB config page)</i>
					<li>Make sure the 'Remote' Option is selected GeneSeqer and/or GenomeThreader. </li>
					<li>Follow instructions to validate inputs (if not already done), check predicted outputs, modify any defaults, and submit your pipeline job.</li>
					<li>Monitor job progress and evaluate output using <i>'Manage'</i> &rarr; <i>'Remote Jobs'</i> &rarr; <i>'<a href="/XGDB/jobs/jobs.php">List All Jobs</a>'</i> </li>
					<li> You can STOP running jobs and DELETE completed or stopped jobs using the appropriate button. Deleted jobs can be cleared from the table using the REMOVE button.</li>
				</ul>
			</li>

		</ul>
<span class="heading normalfont linkback"> <a class="smallerfont" href="/XGDB/help/remote_jobs.php#jobs_overview">View this in Help Context</a> (remote_jobs/jobs_overview)</span>
</div>
