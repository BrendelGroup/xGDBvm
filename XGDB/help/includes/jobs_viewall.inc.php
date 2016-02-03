
<div class="dialogcontainer">
	<h2 class="bottommargin1">List All Jobs</h2>
						 	<p>This table lists <b>Standalone</b> and <b>Pipeline</b> HPC jobs, their status and job details. <span class="warning">iPlant login is required for certain actions</span></p>
							<p><b>Navigation</b>: 'Manage' -> 'Remote Jobs' -> 'List All Jobs' </p>
							<ul class="bullet1 indent2">
							    <li>Use radio buttons to filter by <b>job status</b>, or <b>search</b> for job ID/GDB ID in upper right</li>
				 				<li>Use the <b>Job Actions</b> column for the following tasks ( <span class="warning">iPlant login required</span>):
				 				<ul class="bullet1">
				 				    <li>Update job status by clicking <span class="update_status linkcolor">Update</span> in the appropriate table cell.<br />
				 					On successful completion, status should be <span class="job_archiving_finished">FINISHED</span>.</li>
				 				    <li>Click <span class="count_entries linkcolor">Count </span> to return <b>number of spliced alignments</b> in output file.</li>
								    <li>For any Standalone job involving your own data, click <span class="copy_to_input linkcolor">Copy</span> to copy the HPC output file to your configured Input Data Directory </li>
								</ul>
								</li>
					 			<li>Delete Job List entries (all or a subset) using the 'Remove Selected' button, which removes ALL SHOWING records</li>
					 			<li>Removing Job Records DOES NOT affect the Job itself; however, don't remove a job record if the pipeline for that job is still running.</li>
					 		</ul>
					 		<p>To <b>terminate</b> (stop) a job, use either xGDBvm's <a href="/XGDB/jobs/manage.php">Manage</a> page or the <a href="https://foundation.iplantcollaborative.org/iplant-test/">Foundation API</a></p>
					        <p>To <b>delete</b> (remove) a completed job you <b>must</b> use the the <a href="https://foundation.iplantcollaborative.org/iplant-test/">Foundation API</a></p>
					        
<span class="heading normalfont linkback"> <a class="smallerfont" href="/XGDB/help/remote_jobs.php#jobs_viewall">View this in Help Context</a> (remote_jobs/jobs_viewall)</span>

</div>
