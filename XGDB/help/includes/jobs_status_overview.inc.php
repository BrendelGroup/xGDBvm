
<div class="dialogcontainer">
	<h2 class="bottommargin1 indent2">Overview</h2>
						 	<p>xGDBvm can query the remote HPC server and return current job status, from 'Pending' through to 'Archiving_Finished'.</p>
				 			<ul class="bullet1 indent2">
					 			<li>If your job status indicates a problem, see below for some troubleshooting tips</li>
					 		</ul>
					 		<ul class="bottommargin12 indent2">
								<li>PENDING 	Job accepted and queued for submission.</li>
								<li>STAGING_INPUTS 	Transferring job input data to execution system</li>
								<li>CLEANING_UP 	Job completed execution</li>
								<li>ARCHIVING 	Transferring job output to archive system</li>
								<li>STAGING_JOB 	Job inputs staged to execution system</li>
								<li>FINISHED 	Job complete</li>
								<li>KILLED 	Job execution killed at user request</li>
								<li>FAILED 	Job failed</li>
								<li>STOPPED 	Job execution intentionally stopped</li>
								<li>RUNNING 	Job started running</li>
								<li>PAUSED 	Job execution paused by user</li>
								<li>QUEUED 	Job successfully placed into queue</li>
								<li>SUBMITTING 	Preparing job for execution and staging binaries to execution system</li>
								<li>STAGED 	Job inputs staged to execution system</li>
								<li>PROCESSING_INPUTS 	Identifying input files for staging</li>
								<li>ARCHIVING_FINISHED 	Job archiving complete</li>
								<li>ARCHIVING_FAILED 	Job archiving failed</li>
							</ul>
					 		
								<p>NOTE: You can also visit The iPlant Foundation API <a href="https://foundation.iplantcollaborative.org/iplant-test/" class="">Test Application: Job Service</a> (login required). From this window you can view job status, view job details, or stop/delete a currently running job.</p>

<span class="heading normalfont linkback"> <a class="smallerfont" href="/XGDB/help/remote_jobs.php#jobs_status_overview">View this in Help Context</a> (remote_jobs/jobs_status_overview
</div>
