
<div class="dialogcontainer">
	<h2>Change MySQL Password</h2>
<hr class="featuredivider" />
	<p><span  class="heading"><b >Navigation:</b> Manage &rarr; Admin &rarr; Set Up Passwords </span></p>
	<p><b>Purpose:</b> This option allows you to set a custom password for MySQL</p>

     <p><b>Why do this?</b> xGDBvm scripts use this password (as <b>gdbuser</b>) behind the scenes to read/write data from tables.  Since this VM is distributed as an ISO, the MySQL password is the same for all instances, and it is discovered by anyone downloading an ISO. Your data will be more secure against hacking mischief (*) with a unique MySQL password.</p>

	<h3 class="topmargin1">2. Change default MySQL password</h3>
	<ul class="bullet1">
		  <li> Enter a new password twice, then click <b>Update</b> button at right. </li>
		  <li> You can change this password more than once if need be. </li>
		  <li>NOTE: You will not need to use this password unless you want to access databases on your VM manually through a MySQL client.</li>
		  <li> If you need access to the MySQL root password, you can use your server root privileges to reset it to whatever you like (see wiki for details)</li>
		</ul>		

	<p class="smallerfont">(*) Note that access to xGDBvm's MySQL server is also restricted by default to <b>localhost</b> (i.e. no remote access is possible), an additional security feature.</p>

			<span class="heading normalfont linkback"> <a class="smallerfont" href="/XGDB/help/admin_gdb.php#admin_setup">View this in Help Context</a> (admin_gdb.php/admin_setup)</span>
	
</div>

