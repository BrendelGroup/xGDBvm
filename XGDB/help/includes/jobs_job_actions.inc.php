
<div class="dialogcontainer">
	<h2 class="bottommargin1">Job Actions (Jobs Table)</h2>
						 	<p>These buttons allow users to manage, query or copy a submitted job, using the Agave API. <i>NOTE: For HPC server-related actions (*), user must be <b>logged in</b></i>. </p>
						 	<p>First, navigate to 'Manage' &rarr; 'Remote Jobs' &rarr; 'List All Jobs' and select a job from the table list. Then click the appropriate button:</p>
				 			<ul class="bullet1 indent2">
										<li><span class="bold alertnotice">STOP JOB*</span> - Stop (terminate) a currently running <b>Job</b>. No outputs will be returned.</li>
										<li><span class="bold alertnotice">DELETE JOB*</span> - Delete a STOPPED OR FINISHED job from the server. This DOES NOT affect any archived outputs on your DataStore</li>
										<li><span class="bold linkcolor">COUNT</span> - Counts the number of GSQ or GTH alignment in an ARCHIVED and FINISHED job output file and returns value to this table. May take a few minutes for large files.</li>
										<li><span class="bold linkcolor">COPY</span> - For Standalone jobs only, this command  <b>copies</b> the GSQ or GTH output file to your currently-configured <b>Input Data Directory</b> (on DataStore). This process also <b>renames</b> the file and <b>validates</b> the output, so it is ready to use in a pipeline process. May take a few minutes for large files.</li>
										<li class="italic">You can also <b>remove</b> an unwanted record from this table by clicking the 'X' in column 1. This will not affect any job archives or server information, but you will no longer be able to carry out any actions, e.g. DELETE, COPY, etc.</li>
									</ul>
<p>NOTE: Some job actions are also available under 'Manage' &rarr; 'Remote Jobs' &rarr; 'Manage Jobs' </p>
<span class="heading normalfont linkback"> <a class="smallerfont" href="/XGDB/help/remote_jobs.php#jobs_job_actions">View this in Help Context</a> (remote_jobs/jobs_job_actions)</span>

</div>
