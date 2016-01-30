
<div class="dialogcontainer">
		<h2 class="bottommargin1">GDB configuration for HPC Jobs</h2>
<p> A <b>valid GDB configuration</b> is necessary for running Remote jobs either as <b>standalone</b> or as part of an xGDBvm <b>pipeline</b></p>
			<ul class="bullet1" style="list-style-type:none">
				<li><b>1</b>) Prepare your input files <a title="New GDB" href="/XGDB/conf/data.php">(appropriately named)</a> in a designated subdirectory under <span class="plaintext">/xGDBvm/input/</span> (i.e. your attached Data Store)</li>
				<li><b>2</b>) <a title="New GDB" href="/XGDB/conf/new.php">Create</a> or <a title="New GDB" href="/XGDB/conf/new.php">modify</a> a <b>GDB configuration</b> (e.g. <b>GDB001</b>) 
					<ul class="bullet1">
						<li> Select any non-default parameters for GSQ or GTH</li>
						<li> For pipeline jobs only, select  <i>GSQ or GTH Compute = 'Remote'</i> under <b>Transcript</b> and/or <b>Protein Spliced Alignment</b> configuration </li>
						<li> Click '<i>Save</i>' to save the configuration</li>
					</ul>
					</li>

				<li> <b>3</b> <a title="New GDB" href="/XGDB/jobs/configure.php#login">Log in</a> with your iPlant authorization credentials. The login token is good for a limited time span.</li>
				</ul>
		<p>Your VM is now configured to submit spliced alignment jobs to the remote HPC, either as standalone jobs or as part of a GDB pipeline.</p>
<span class="heading normalfont linkback"> <a class="smallerfont" href="/XGDB/help/remote_jobs.php#jobs_configure">View this in Help Context</a> (remote_jobs/jobs_configure)</span>

</div>
