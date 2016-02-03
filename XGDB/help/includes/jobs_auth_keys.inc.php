
<div class="dialogcontainer">
<h2 class="bottommargin1">Authorize (Get Keys) / Log In</h2>

			<p>xGDBvm-iPlant uses <b>OAuth2</b> for access to GeneSeqer / GenomeThreader at remote HPC facilities. Valid iPlant credentials (username/password) are required.</p>
			<p>You must first register this VM as a <b>Client App</b> using your iPlant credentials, which will load a set of <b>authorization keys</b> to the VM*. Once these are loaded, you can then submit your user/password to obtain access to HPC job functions for a limited span. To register and obtain keys:</p>
			<ol class="orderedlist1 indent2">
			<li>Navigate to <i>'Manage' -> 'Remote Jobs' -> '<a href="/XGDB/jobs/userlogin.agave.php">Authorize / Log In</a>'</i></li>
			<li>Under 'Get Authorization Keys', view list of usernames who have loaded keys</li>
			<li>If your username is not there, enter it in the entry box and click 'Get Keys'</li>
			<li>Once authorized, your username should appear. You can now <b>log in</b> using the username/password dialog on the same page.</li>
			<li>You should only need to get Authorization Keys	 ONCE on this VM, but if you create a new VM you will need to repeat the process.</li>
			</ol>
			<p>* Note: each iPlant user on this VM must <b>independently</b> register the VM and load their own set of authorization keys.</p>

<span class="heading normalfont linkback"> <a class="smallerfont" href="/XGDB/help/jobs_auth_keys.inc.php#jobs_auth_keys">View this in Help Context</a> (remote_jobs/jobs_auth_keys)</span>

</div>
