
<div class="dialogcontainer">
	<h2>Compute Resources...</h2>
	<p>Your virtual server may have limited storate capacity and compute power. Larger genome datasets should be directed towards external high performance compute cluster, if configured</p>
	
	<p>Options available</p>
	<ul class="bullet1 indent2">
		<li><b>Internal</b> - (default) data will be copied to the local xGDBvm instance and computations carried out using its processors and disk space</li>
		<li><b>External</b> - data will be copied to an external high performance compute server</li>
	</ul>

 <p>The <b>internal</b> option limits will depend on both your instance size and dataset size.</p>
 
 <p> As a typical example, an iPlant instance of <b>"Large"</b> size (16 gig RAM, 30 gig storage) cannot process a single Arabidopsis chromosome with its full cDNA dataset.</p>
 
			<span class="heading normalfont linkback"> <a class="smallerfont" href="/XGDB/help/create_gdb.php#config_compute_resource">View this in Help Context</a> (create_gdb.php/config_compute_resource)</span>
</div>
