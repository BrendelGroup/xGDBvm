<div class="dialogcontainer">
	<h2 class="bottommargin1">Archive GDB</h2>
	<p><b>Archive</b> saves a copy of GDB data and configurations to a special Archive directory under <span class="plaintext">/xGDBvm/data/</span>. 
	We recommend doing this before carrying out a GDB Update, in case things go awry. In that case you can <b>'Drop'</b> the GDB and then use <b>'Restore'</b> to recreate the archived GDB. You can also archive ALL GDB at once; see <a href="/XGDB/help/create_gdb.php#config_archive_all">Archive All</a></p>
	<p> <b> To Archive a GDB:</b>:</p> 
	<ul class="bullet1 indent2">
		<li><b>Method 1:</b> Browse to the <b>Configuration</b> page of any GDB (Left menu &rarr; Manage Configured &rarr; GDB ID) and click <i>Data Process Options...</i> button.</li>
		<li><b>Method 2:</b> Navigate to the <a href="/XGDB/conf/archive.php">Archive / Delete </a> page and find your GDB in the appropriate table row.</li>
		<li>Next click the <i>Archive GDB</i> button to initiate the process</li>
		<li>In response to <b>'Do you really want to archive?'</b>, click <b>'Yes'</b>.</li>
		<li>The GDB will be <span class="Locked">Locked</span> during copying. The process can take some time, but you can click the <i>Refresh</i> button to update status.</li>
		<li>When completed, your GDB will appear with an <img style="margin-bottom:-4px"  alt="" src="/XGDB/images/archive.png" /> <b>Archive Date</b> time stamp.</li>
		<li>Archived data is stored in the directory <span class="plaintext">/xGDBvm/data/ArchiveGDB/</span> (i.e. on your attached volume, if mounted).</li>
		<li>Alternatively, use the  page to archive or restore one or more GDB</li>
	</ul>
<p>PLEASE NOTE:</p>
<ul class="bullet1 indent2">
	<li>You can update this GDB, or add to configuration metadata after archiving, but be aware that the new data will not be part of the archive unless you repeat the process.</li>
	<li>Repeating the <b>Archive</b> process for this GDB will <span class="bold alertnotice">overwrite the existing Archive directory!</span>. To save an older archive, first copy it to your Data Store (see <a href="/XGDB/help/create_gdb.php#config_copy_archive">Copy Archive</a>)</li>
	<li>To <b>Restore an Archive</b>, you must either create a new GDB or drop a current one. Refer to <a href="/XGDB/help/create_gdb.php#config_restore">Restore Archive</a> for details</li> 
</ul>
			<span class="heading normalfont linkback"> <a class="smallerfont" href="/XGDB/help/create_gdb.php#config_archive">View this in Help Context</a> (create_gdb.php/config_archive)</span>
</div>
