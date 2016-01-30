
<div class="dialogcontainer">
	<h2 class="bottommargin1">Delete All GDB</h2>
	<p>This action <span class="alertnotice bold">irreversibly deletes</span> ALL GDB output directories and ALL database tables for this xGDBvm. It does NOT delete the archives found under <span class="plaintext normalfont">/xGDBvm/data/ArchiveAllGDB/</span></p>

    <ul class="bullet1 indent2">
        <li>Use this option <b>ONLY</b> if you want to <b>completely start over</b> with this xGDBvm cloud instance and don't want to save any configurations or output data.</li>
        <li>This action will NOT affect your <b>input data</b> files or other data stored on your attached volume <b>UNLESS YOU HAVE A DIRECTORY NAMED GDB001 to GDB999</b> at the top level.</li>
        <li>If you want to save any output GDB data stored under /xGDBvm/GDB00x/data/, <b>move</b> or <b>rename</b> the files prior to using the 'Delete All GDB' option</li>
        <li>You can also create a GDB archive using <a class="help_style" href="/XGDB/help/create_gdb.php#config_archive_all">Archive All</a>, that can be restored at a later time if desired.</li>
	</ul>
	
	<p><b>* NOTE:</b> Archived data created using the <b>'Archive All GDB'</b> option will <b>NOT</b> be deleted with 'Delete all GDB'.</p>

			<span class="heading normalfont linkback"> <a class="smallerfont" href="/XGDB/help/create_gdb.php#config_delete_all">View this in Help Context</a> (create_gdb.php/config_delete_all)</span>
</div>
