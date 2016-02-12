
<div class="dialogcontainer">
	<h2>Input and Output Volumes</h2>
	    <p>On xGDBvm, you deposit <b>Input</b> files under <span class="plaintext">/xGDBvm/input/xgdbvm/</span>, and <b>Output</b> data appear under <span class="plaintext">/xGDBvm/data/</span>. </p>
	    <p>On xGDBvm-<b>iPlant</b>, these paths are actually <b>mounted</b> to your iPlant <b>Data Store</b> and to an Atmosphere <b>block storage volume</b>, respectively, during the VM configuration process.</p>
	    <p><b>Mount status</b> is indicated on Configuration and Jobs pages: <span class="checked_mount">Mounted</span> or <span class="warning">Not Mounted</span>. Mount status can also be confirmed by checking under <a href="/XGDB/conf/volumes.php">Data Volumes</a>.
 </p>
	    <p>It's acceptable to use xGDBvm without one or both of these volume mounts, but be aware that:</p>
	    <ul class="bullet1 indent2">
	    <li>Your input and/or output data storage space will be limited to what is available on the VM</li>
	    <li>You will not be able to use <a href="/XGDB/help/remote_jobs.php">remote HPC</a> facilities without first mounting your <b>DataStore</b></li>
	    <li>If the VM becomes corrupted or otherwise unavailable, you may lose your output data.</li>
	    </ul>
	    <p><b>To mount or re-mount a volume:</b></p>
					<ul class="bullet1 indent2 bottommargin2">
							<li>
								<span class="plaintext highlight">/xGDBvm/input/</span>: First make sure IRODS is initiated using <span class="plaintext">$ iinit</span>. Then mount your Data Store using the shell command <span class="plaintext">$ mount-datastore</span>
							</li>
							<li>
								<span class="plaintext highlight">/xGDBvm/data/</span>: First <b>attach</b> a Volume to your VM using the Atmosphere Control Panel.  Then mount the External Volume using the shell command <span class="plaintext">$ mount-volume</span>
							</li>
					</ul>
		
		<p>You can also refer to <a href="/0README-iPlant"><span class="plaintext largerfont">/xGDBvm/0README-iPlant</span></a> or visit the <a href="http://goblinx.soic.indiana.edu/wiki/doku.php?id=user_instructions">xGDBvm wiki</a> for detailed instructions.</p>	
		
			<span class="heading normalfont linkback"> <a class="smallerfont" href="/XGDB/help/create_gdb.php#config_volumes">View this in Help Context</a> (create_gdb.php/config_volumes)</span>

</div>
