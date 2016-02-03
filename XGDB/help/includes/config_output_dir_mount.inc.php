
<div class="dialogcontainer">
	<h2 class="bottommargin1">Output Directory: External Mount</h2>
	<p><span class="warning">IMPORTANT:</span> For xGDBvm-iPlant users, the output data directory <span class="plaintext largerfont">/xGDBvm/data/</span> should be mounted to an <b>external volume</b> (block storage device) as part of the initial xGDBvm configuration.
	This external mount strategy both increases storage capacity and allows outputs to be preserved in case the xGDBvm VM is wiped out. </p>

    <p><b>Mount status </b> is indicated in the upper left of each GDB configuration page. You can also check mount status and storage capacity by navigating to the <a href="/XGDB/conf/volumes.php">Volumes</a> page under <i>'Admin &rarr; Config/Create &rarr; Data Volumes'</i></p>

    <p>To create, attach, and mount an external drive, do the following:</p>
           <ul class="bullet1 indent2">
                <li>On your Atmosphere control panel, follow instructions to create and attach volume to your VM</li>
                <li>Once attached, you must mount the volume to a location under /dev/. Type $ mount-volume and enter the location (e.g. /dev/vdc).</li>
                <li>Details found under "User Instructions" section in the  <a href="http://goblinx.soic.indiana.edu/wiki/user_instructions">xGDBvm wiki</a></li>
                <li>See also <a href="/0README-iPlant"><span class="plaintext largerfont">/xGDBvm/0README-iPlant</span></a></li>
                <li>The <a href="https://pods.iplantcollaborative.org/wiki/display/atmman/Attaching+a+Volume+to+an+Instance">iPlant Wiki<//a> has general instructions for mounting external volumes</li>
            </ul>

			<span class="heading normalfont linkback"> <a class="smallerfont" href="/XGDB/help/create_gdb.php#config_output_dir_mount">View this in Help Context</a> (create_gdb.php/config_output_dir_mount)</span>

</div>

