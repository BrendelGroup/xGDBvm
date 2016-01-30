
<div class="dialogcontainer">
	<h2 class="bottommargin1">Input Data: Mount iPlant Data Store</h2>
	<p><b>xGDBvm-iPlant</b> users can mount their <a href="https://data.iplantcollaborative.org/">iPlant Data Store</a> to <span class="plaintext normalfont">/xGDBvm/input/</span>, as source of input data and a data bridge for <a title="Detailed instructions for remote HPC" href="/XGDB/help/remote_jobs.php">remote HPC jobs</a>. Mounting utilizes the <a href="https://www.irods.org/index.php/iRODS_FUSE">IRODS FUSE</a> protocol.</p>
	<ul class="bullet1 indent2">
	    <li> Mounting requires shell access to your VM. Type ''$ quickstart'' or follow the steps in <span class="plaintext">/xGDBvm/<a title="Detailed instructions for attaching Data Store" href="/0README-iPlant">0README-iPlant</a></span> to log in to IRODS and mount your Data Store to <span class="plaintext normalfont">/xGDBvm/input/</span>.</li>
	    <li> Once mounted your <span class="plaintext normalfont">/iPlant/home/[username]/</span> directory can be accessed on your VM as <span class="plaintext normalfont">/xGDBvm/input/</span> </li>
	    <li> You can now use the <a href="http://preview.iplantcollaborative.org/de/?type=data">Discovery Environment</a> tools or <a href="https://pods.iplantcollaborative.org/wiki/display/DS/Using+iCommands">icommands</a> to copy your input data to a subdirectory that xGDBvm can access. </li>
	    <li> You will specify this as the input directory in the "Configure New GDB" &rarr; "Input Data Dir" dropdown</li>
		<li> NOTE: Mounting your Data Store to <span class="plaintext normalfont">/xGDBvm/input/</span> is <b>REQUIRED</b> if remote HPC resources will be used, since TACC cannot access the xGDBvm instance directly.</li>
		</li>
	</ul>
	
	<p> See also the iPlant wiki for details: <a href="https://pods.iplantcollaborative.org/wiki/display/DS/Data+Store+Quick+Start"> Data Store Quick Start</a>;  <a href="https://pods.iplantcollaborative.org/wiki/display/DS/Storing+and+Accessing+Your+Data+in+the+Data+Store">Storing and Accessing Your Data</a> </p>

			<span class="heading normalfont linkback"> <a class="smallerfont" href="/XGDB/help/create_gdb.php#config_input_datastore">View this in Help Context</a> (create_gdb.php/config_input_datastore)</span>

</div>

