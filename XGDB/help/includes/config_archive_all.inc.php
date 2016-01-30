
<div class="dialogcontainer">
	<h2 class="bottommargin1">Archive All GDB</h2>
	<p>
	    <img id='button_archive_all' style='margin-bottom: -5px' src='/XGDB/help/images/button_archive_all.gif' alt='Archive All' />
	saves a copy of all GDB data and configurations on this xGDBvm to a special Archive directory on your <span class="plaintext">/xGDBvm/data</span> volume.
	<br />. Use <b>'Restore'</b> to reverse the process and recreate your entire xGDBvm.
	<br /> You can also archive a single GDB; see 
        <a href="/XGDB/help/create_gdb.php#config_archive">
            Archive GDB
        </a>
	</p>
	<h3>To Archive:</h3> 
	<ul class="bullet1">
        <li>
            Browse to the '<i>Archive / Restore </i>' or  '<i>List All Configured </i>'  page, displaying a list of all GDB on this instance.
        </li>
        <li>
            Click the <b>'Archive All GDB'</b> button at upper right.
        </li>
        <li>
            In response to  <b>'Do you really want to archive?'</b>, click <b>'Yes'</b>.
        </li>
        <li>
            Archiving can take some time, so refrain from making additional changes in the meantime.
        </li>
        <li>
            When completed, all GDB will appear with an <img style="margin-bottom:-4px"  alt="" src="/XGDB/images/archive_all.png" /> <b>Archive All Date</b> time stamp.
        </li>
        <li>
            Archived data are stored under <span class="plaintext">/xGDBvm/data/ArchiveAll/</span> on your <span class="plaintext">/xGDBvm/data</span> (e.g attached volume, if mounted).
        </li>
    </ul>
<p>PLEASE NOTE:</p>
<ul class="bullet1">
	<li>You can create additional GDB, or update current ones after archiving, but be aware that the new data will not be part of the archive unless you repeat the process.</li>
	<li>Repeating the <b>Archive All</b> process will overwrite any outdated data in the existing Archive</li>
</ul>
	<span class="heading normalfont linkback"> <a class="smallerfont" href="/XGDB/help/create_gdb.php#config_archive_all">View this in Help Context</a> (create_gdb.php/config_archive_all)</span>
</div>
