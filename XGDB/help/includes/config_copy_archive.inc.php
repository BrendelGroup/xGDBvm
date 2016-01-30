<div class="dialogcontainer">
	<h2 class="bottommargin1">Copy Archive to Data Store</h2>
	<p>This action copies a GDB archive to your <b>Data Store</b> volume, for sharing or additional insurance against data loss. 
	We recommend doing this after archiving your GDB Update, in case things go awry with your attached volume. In that case you can copy the archive back to /xGDBvm/data/ArchiveGDB/ and then use <b>'Restore'</b> to recreate the archived GDB.
	<p> <b> To Copy a GDB archive</b>:</p> 
	<ul class="bullet1 indent2">
	<li> Navigate to the <a href="/XGDB/conf/archive.php">Archive / Delete </a> page
	<li>Click the <i>Copy </i> button in the appropriate column/row.</li>
	<li>In response to  <b>'Do you really want to copy archive?'</b>, click <b>'Yes'</b>.</li>
	<li>The GDB will be <span class="Locked">Locked</span> during copying. The process can take some time, but you can click the <i>Refresh</i> button to update status.</li>
	<li>When completed, a <span class="checked"></span> Checkmark will indicate that the archive copy is current (based on file time stamp).</li>
	<li>Archive copy is stored under the VM directory <span class="plaintext">/xGDBvm/input/archive/</span> </li>
	<li>This maps to <span class="plaintext">/iplant/home/[username]/archive/</span> on your Data Store (if attached).</li>
	<li>The GDB's Pipeline Procedure log and ArchiveGDB log will be updated.</li>
</ul>
<p>PLEASE NOTE:</p>
<ul class="bullet1 indent2">
	<li>If you re-<b>Archive</b> your GDB, the Data Store copy will no longer be current. </li>
	<li>To indicate this, the  <span class="checked"></span> Checkmark will disappear.</li>
	<li>Simply repeat the steps above to create a copy of the current archive</li>
	<li><b>NOTE:</b> Archives copied to the Data Store do <b>NOT</b> overwrite old copies, so you will need to manage them there</li>
</ul>
	<p> <b> To Restore an Archive</b>: See see <a href="/XGDB/help/create_gdb.php#config_restore">Restore</a></p> 

			<span class="heading normalfont linkback"> <a class="smallerfont" href="/XGDB/help/create_gdb.php#config_copy_archive">View this in Help Context</a> (create_gdb.php/config_copy_archive)</span>


</div>
