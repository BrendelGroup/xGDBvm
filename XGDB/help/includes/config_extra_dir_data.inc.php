
<div class="dialogcontainer">
	<h2 class="bottommargin1">GDB directories not associated with Current GDB under <span class="plaintext normalfont">/xGDBvm/data/</span> </h2>
	<p>This error message means that the GDB directory indicated is not assigned to any <span class="Current">Current</span> GDB. xGDBvm creates a subdirectory (GDB001, GDB002, etc) under <span class="plaintext normalfont"> /xGDBvm/data/</span>, but only for each genome completed or in process.</p>
	<p>This may have happened under one of the following scenarios:</p>
	
	<ul class="bullet1">
        <li>
            If the storage volume attached to '/xGDBvm/data/' was previously mounted to a different xGDBvm, then one or more of its GDB data directories may still be present.
        </li>
        <li>
            The GDB in question could actually be 
            <span class="Current">Current</span> 
            (i.e. has output data and is viewable) but is flagged incorrectly as 
            <span class="Development">Development</span>
            due to a data process error.
        </li>
        <li>
            The GDB in question could have been dropped (reverted to 
            <span class="Development">Development</span>
            status) but its GDB directory was not removed due to a glitch in the pipeline.
        </li>
	</ul>
<p>In any case, the presence of extraneous directories could interfere with xGDBvm pipeline function and/or overwrite data files. If unsure how to proceed, consider renaming the rogue directory until you figure out what is going on. If this is a legitimate GDB directory for this VM but it has incorrect status, you may need to update Genomes.xGDB_Log and set Status='Current'.</p>
			<span class="heading normalfont linkback"> <a class="smallerfont" href="/XGDB/help/create_gdb.php#config_extra_dir_data">View this in Help Context</a> (create_gdb.php/config_extra_dir_data)</span>


</div>
