<div class="dialogcontainer">
	<h2 class="bottommargin1">Manage GDB Archive</h2>
	<p>The Manage &rarr; Config/Create &rarr; <b>Archive/Delete</b> page includes actions for archiving, restoring or copying all GDB on this VM.</p> 
	<ul class="bullet1 indent2">
		<li><b>Archive:</b> Click to create an archived copy of a GDB, which will be saved to a file under <span class="plaintext">/xGDBvm/data/ArchiveGDB/</span>
		<ul class="bullet1 indent2">
		<li>Note that only ONE archive is saved; the previous one is automatically deleted (see Copy command below)</li>
		</ul>
		</li>
		<li><b>Restore:</b> Click to restore from an archived copy of a GDB. This option only available where GDB Status=<span class="Development">Development</span></li>
		<li><b>Delete:</b> Click to delete a GDB archive.</li>
		<li><b>Copy:</b> Click to copy a GDB archive to your Date Store (if mounted). The copy will be saved to a file under <span class="plaintext">/xGDBvm/input/archive/</span>, which maps to your iPlant Data Store <span class="plaintext">/iplant/user_home/archive/</span>
		<ul class="bullet1 indent2">
		<li>If the Data Store copy is current, there will be a green <span class="checked"></span> checkmark next to the button</li>
		<li>Note that archive copies are NOT overwritten, so you can save multiple archives on your Data Store</li>
		</ul>
		</li>
	</ul>
				<span class="heading normalfont linkback"> <a class="smallerfont" href="/XGDB/help/create_gdb.php#config_manage_archive">View this in Help Context</a> (create_gdb.php/config_manage_archive)</span>
</div>
