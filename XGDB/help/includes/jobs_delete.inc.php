
<div class="dialogcontainer">
	<h2 class="bottommargin1">To terminate a currently-running remote job:</h2>
					 		<p> Jobs will terminate automatically if their time exceeds the requested time (typcially 12 hr, depending on what was set up under Jobs -> <a href="/XGDB/jobs/configure.php">Configure for HPC</a>. If you need to terminate the job sooner than this, do the following:</p>
							<ul class="bullet1 indent2">
								<li> Select 'Manage' -> 'Remote Jobs' -> '<a href="/XGDB/jobs/jobs.php">Job List</a>' to view remote job list. For jobs in progress, click  <input value="STOP JOB" type="submit" /> button to terminate the remote job </li>
								<li> -or- Select 'Manage' -> 'Remote Jobs' -> '<a href="/XGDB/jobs/process.php#kill">Submit Jobs</a>', scroll down to 'Terminate Job', and select job ID from the dropdown.</li>
						<li>If this is a pipeline remote job, the pipeline should automatically detect your action and skip to the next step. Go to the <a href="/XGDB/conf/viewall.php"> GDB config </a> page, and click 'Logfile' and view progress to confirm this.</li>
							<li> If necessary, you can Abort the pipeline run as well. On the  <a href="/XGDB/conf/viewall.php"> GDB config </a> click 'Data Process Options' button, and select 'Abort GDB'; click to confirm. This will return the GDB configuration to <span class="Development">Development</span> status and remove any output data. You are now able to try again with different parameters.</li>
							</ul>

<span class="heading normalfont linkback"> <a class="smallerfont" href="/XGDB/help/remote_jobs.php#jobs_delete">View this in Help Context</a> (remote_jobs/jobs_delete)</span>

</div>
