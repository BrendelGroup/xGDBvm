<div class="dialogcontainer">
	<h2>Set Password for administrative pages</h2>
<hr class="featuredivider" />
	<p><span  class="heading"><b >Navigation:</b> Manage &rarr; Admin &rarr; Set Up Passwords </span></p>
	<p><b>Purpose:</b> This option allows you to password-protect the <a href="/admin/index.php"><i>Admin</i></a>,  <a href="/XGDB/conf/index.php"><i>Create/Manage</i></a>, and <a href="/XGDB/jobs/index.php"><i>Jobs</i></a> sections of your xGDBvm instance.</p>
    <p><b>Why do this?</b> Since data can be modified or deleted using scripts accessible on these pages, you may well want to limit access to them (see NOTE below).</p>
    	<ul class="bullet1">
		  <li>With this option a username <b>('admin')</b> and password are required on first accessing menu items under <a href="/admin/index.php"><i>Admin</i></a>,  <a href="/XGDB/conf/index.php"><i>Create/Manage</i></a>, and <a href="/XGDB/jobs/index.php"><i>Jobs</i></a> (uses .htaccess).</li>
		  <li> Enter a new password twice, then click <b>Update</b> button at right. You will then be asked to log in to the restricted page using these credentials.
				<ul class="bullet1">
				  <li> Your web browser should cache the password so you will not need to re-enter when you navigate away from/back to these pages </li>
				  <li> If you are working on a shared computer, make sure you quit out of your web browser at the end of the session.</li>
				</ul>
		  </li>
		  <li> You may change password more than once if necessary</li>
		  <li> You can remove password protection by clicking <b>Remove</b> button</li>
	</ul>

    <p><b>NOTE:</b> This option is NOT RECOMMENDED if you are also password-protecting the entire xGDBvm website. The two password dialogs can get annoying. If you need two levels of protection, we recommend you use vpn to limit access to the web pages.</p>

		<span class="heading normalfont linkback"> <a class="smallerfont" href="/XGDB/help/admin_gdb.php#admin_adminpass">View this in Help Context</a> (admin_gdb.php/admin_adminpass)</span>
	
</div>

