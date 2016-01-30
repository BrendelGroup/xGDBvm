
<div class="dialogcontainer">
	<h2>Compute Resources- GTH</h2>
	<p>By default xGDBvm uses local memory, CPU and disk space for temporary data storage and computation. Your virtual server may have limited storage capacity and/or compute power. Larger genome datasets should therefore be directed towards an external high performance compute cluster, if configured.</p>
	
	<p>Options available for GenomeThreader</p>
	<ul class="bullet1">
		<li><b>Internal</b> - (default) data will be copied to the local xGDBvm instance and computations carried out using its processors and disk space</li>
		<li><b>External</b> - (if configured under <a href="/XGDB/jobs/configure.php#gth">Remote Jobs</a> and user has <a href="/XGDB/jobs/configure.php#auth">Login Credentials</a>) data will be copied to an external high performance compute server, and final output data copied back the xGDBvm local drive</li>
	</ul>

<p>After computation, output data will be copied back to your attached data store; data will also be loaded to the xGDBvm's databases.</p>

 <p>The <b>internal</b> option limits will depend on both your instance size and dataset size.</p>
 
 <p> As a typical example, an iPlant instance of <b>"Large"</b> size (16 gig RAM, 30 gig storage) cannot process a single Arabidopsis chromosome with its full cDNA dataset.</p>
 
 <p class="tip_style">Note: If <b>Remote</b> option is not displayed, your VM may not be correctly configured under <a href="/XGDB/jobs/configure.php">Remote Jobs</a>.</p>
 
			<span class="heading normalfont linkback"> <a class="smallerfont" href="/XGDB/help/create_gdb.php#config_comp_res-gth">View this in Help Context</a> (create_gdb.php/config_comp_res_gth)</span>
</div>
