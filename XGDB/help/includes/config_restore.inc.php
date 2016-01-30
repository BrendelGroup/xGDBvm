
<div class="dialogcontainer">
	<h2 class="bottommargin1">Restore GDB</h2>
	<p><img id='button_restore' style='margin-bottom: -5px' src='/XGDB/help/images/button_restore.gif' alt='Restore GDB' /> retrieves previously-archived data from your attached storage volume and recreates your GDB. Any existing archive can be used (default is the one with the same name)</p>

<h3>REQUIREMENTS</h3>
<ul class="bullet1 indent2">
    <li>In order to restore an archive to an existing GDB, you must first <a class="help_style" href="/XGDB/help/create_gdb.php#drop">Drop</a> the current GDB. THIS WILL DELETE ALL OUTPUT DATA!!
    	<ul class="bullet1">
    	<li>Alternatively, use a <i>new GDB</i> to load an archive: Select '<i>'Configure New GDB</i>' from the <i>Manage &rarr; Config/Create</i> menu, and select an Archive to load from the dropdown.</li>
	</ul>
	</li>
	<li>You can only restore a GDB that has an <b>Archived</b> date more recent than <i>Restored</i> date (if any).</li>
	<li>You must have a volume (i.e. mounted external volume) with the desired archive under <span class="plaintext">/xGDBvm/data/ArchiveGDB/GDB00x/</span></li>
	<li>Restoring a single GDB from archive does NOT affect any other GDB on the same virtual server.</li>
		</ul>
	
	<h3> To Restore a GDB Archive</h3> 
<ul class="bullet1 indent2">
	<li>In a <span class="Development">Development</span> mode GDB, click <i>'Data Process Options'</i></li>
	<li>If there is a valid Archive, a  <b>'Restore GDBnnn Archive'</b> button will be visible. Click it.
		<ul class="bullet1">
			<li>NOTE: if you have configured to <a href="/XGDB/help/create_gdb.php#config_load_archive">load a DIFFERENT GDB archive</a>, <b>GDBnnn</b> indicates the source archive</li>
		</ul>
	</li>
	<li> In response to  <i>'Do you really want to restore?'</i>, click <i>'Yes'</i></li>
	<li>Restoring can take some time, so refrain from making additional changes in the meantime.</li>
	<li>When completed, the GDB status will be changed to "<span class="Current">Current</span>" and you can now view GDB data.</li>
	<li>Alternatively, use the <a href="/XGDB/conf/archive.php">Archive / Delete </a> page to archive or restore one or more GDB</li>
</ul>



			<span class="heading normalfont linkback"> <a class="smallerfont" href="/XGDB/help/create_gdb.php#config_restore">View this in Help Context</a> (create_gdb.php/config_restore)</span>


</div>
