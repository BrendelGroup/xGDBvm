
<div class="dialogcontainer">
<h2 class="bottommargin1">Login/Token Authorization</h2>

			<p>To access remote compute facilities via iPlant requires an authorization <b>token</b>, obtained using a valid iPllant username/password, and valid for a limited time </p>
			<p>xGDBvm-iPlant provides login access to obtain a token, and retains the token in a session variable for its lifespan. During this time you can configure and initiate remote jobs from your xGDBvm instance.</p>
			<ul class="bullet1">
			<li>Make sure the correct authorization URL is in place at <i>'Manage' -> 'Remote Jobs' -> '<a href="/XGDB/jobs/configure.php">Configure for HPC</a>'</i></li>
			<li>If not logged in, any page under <i>'Manage' &rarr; 'Remote Jobs'</i> will display a login entry box, for you to enter your iPlant username/password</li>
			<li>For convenience, the GDB Configuration page will prompt you with a link to the login page, if 'Remote' option has been selected for that GDB</li>
			<li>Once logged in, your authentication status is displayed at top of the page, along with token time remaining.</li>
			<li>For best results, do not close your Web browser once logged in. This will maintain synchronicity between xGDBvm and your iPlant authorization period.</li>
			<li>You can also manage tokens (independent of xGDBvm) using the iPlant <a href="https://foundation.iplantcollaborative.org/iplant-test/">Foundation API test application</a></li>
			</ul>
<span class="heading normalfont linkback"> <a class="smallerfont" href="/XGDB/help/remote_jobs.php#jobs_login_token">View this in Help Context</a> (remote_jobs/jobs_login_token)</span>

</div>
