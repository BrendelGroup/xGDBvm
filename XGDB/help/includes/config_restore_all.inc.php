
<div class="dialogcontainer">
	<h2 class="bottommargin1">Restore All GDB</h2>
	<p><b>'Restore All'</b> retrieves previously-archived data from your attached storage volume and recreates an entire xGDBvm on an 'empty' cloud instance.</p>

<p>IMPORTANT NOTES:</p>
<ul class="bullet1 indent2">
	<li>The starting xGDBvm <i>must be empty</i> for this option to be used. You can start with a new xGDBvm instance, or use <a class="help_style" href="/XGDB/help/create_gdb.php#config_delete_all">Delete All</a> to remove all GDB first.</li>
	<li>You must have a volume with the desired archive under <br /><span class="plaintext largerfont">/xGDBvm/data/ArchiveAll/</span></li>
	<li>If any other <b>'GDB001, GDBO02',</b> etc., directories are present on the attached data volume, they will be moved (renamed) to 'GDB001.user, GDB002.user', etc.</li>
</ul>
	
	<p> <b> To Restore an All GDB Archive</b>:</p> 
<ul class="bullet1 indent2">
	
	<li>Start with an empty xGDBvm (no GDB configured or created) and make sure the apropriate ArchiveAll directory is mounted under <span class="plaintext largerfont">/xGDBvm/data/ArchiveAll/</span></li>
	<li>On the <i>List All Configured</i> or <i>Archive/Delete</i> page, click the <b>'Restore All GDB'</b> button. </li>
	<li>In response to <b>'Do you really want to restore?'</b>, click <b>'Yes'</b> </li>
	<li>Restoring can take some time, so refrain from making additional changes in the meantime.</li>
	<li>When completed, all GDB from the archive will be displayed, and a <img style="margin-bottom:-4px"  alt="" src="/XGDB/images/restored_all.png" /> <b>Restore All Date</b> time stamp will be added.</li>
 	<li>You may re-archive your xGDBvm at a later time, overwriting any old data in the <span class="plaintext largerfont">/xGDBvm/data/ArchiveAll/</span> directory.</li>
</ul>

			<span class="heading normalfont linkback"> <a class="smallerfont" href="/XGDB/help/create_gdb.php#config_restore_all">View this in Help Context</a> (create_gdb.php/config_restore_all)</span>

</div>
