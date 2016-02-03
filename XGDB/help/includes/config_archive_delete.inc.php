
<div class="dialogcontainer">
	<h2 class="bottommargin1">Archive / Restore / Delete / Drop GDB</h2>
<p>The <i>Manage</i> &rarr; <i>Config/Create</i> &rarr; <a href="/XGDB/conf/archive.php">Archive/Delete</a> page displays all GDB with buttons for various actions (see below). MOST ACTIONS ARE NOT REVERSIBLE, SO USE CARE!</p>

		<p class="indent2"><span class="warning">Make sure you have enough <b>disk space</b> on <span class="plaintext">/xGDBvm/data/</span> to accomodate an archive. See <a href="/XGDB/conf/volumes.php">Data Volumes</a>.</span></p>


<h3>Actions affecting All GDB</h3>
<ul class="bullet1 indent2">
			<li> <b>Delete All GDB</b>: Delete all <span class="plaintext">GDBnnn</span> and their configurations. Archives (if any) are retained.  NOT REVERSIBLE! </li>
			<li> <b>Archive All GDB</b>: Create an archive package on your attached storage (<span class="plaintext">/xGDBvm/data/ArchiveAll/</span>), for use as a backup or to share. </li>
			<li> <b>Restore All GDB</b>: Restore entire xGDBvm dataset from <span class="plaintext">/xGDBvm/data/ArchiveAll/</span>. Cannot be used if any GDB or configurations are present.</li>
			<li> <b>Delete Archive All</b>: Delete <span class="plaintext">ArchiveAll</span> directory (if it exists). NOT REVERSIBLE! </li>
</ul>
<h3>Actions affecting a single GDB</h3>

<ul class="bullet1 indent2">
			<li> <b>Drop</b>: Remove a <span class="Current">Current</span> GDB's output data and MySQL database, and revert to <span class="Development">Development</span>) status (retains configuration and GDB ID)</li>
			<li> <b>Delete</b>: Delete the last-created GDB (<span class="Current">Current</span> or <span class="Development">Development</span>), its configuration, <b>and</b> its GDB Archive (if present). NOT REVERSIBLE! </li>
			<li><b>Archive</b>: Archive a single GDB to <span class="plaintext">/xGDBvm/data/ArchiveGDB/GDBnnn/</span></li>
			<li> <b>Restore</b>:Restore from GDB archive in <span class="Development">Development</span> mode (recreates the archived GDB)*. </li>
			<li> <b>Delete Archive</b>: Delete a single GDB archive under <span class="plaintext">ArchiveGDB</span> . Use if GDB archive is no longer needed. NOT REVERSIBLE! </li>
			<li> <b>Copy Archive</b>: Copy a single GDB archive under <span class="plaintext">ArchiveGDB</span> to the user's Data Store </li>
</ul>
			<p><span class="tip_style">*To restore from a <b>different</b> GDB archive: Go to the GDB Config Page, click '<b>Edit Config</b>', and select an archive from the <b>Use Archive</b> dropdown.</span></p>

			<span class="heading normalfont linkback"> <a class="smallerfont" href="/XGDB/help/create_gdb.php#config_archive_delete">View this in Help Context</a> (create_gdb.php/config_archive_delete)</span>
</div>
