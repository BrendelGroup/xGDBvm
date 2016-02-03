<div class="dialogcontainer">
	<h2 class="bottmmargin1">Add a custom track</h2>

<hr class="featuredivider" />
	<h3 class="topmargin1">Genome Tracks:</h3>
	<ul class="bullet1 ">
		<li>The user_add_track feaure is accessed from the Genome Context View submenu 'Configure' -> 'Add Track'</li>
		<li>This brings up a dialog box with 'DAS' and 'GFF' tabs.Click the 'GFF' tab </li>
		<li>Click 'Browse' and select a gff file locally: 'Please selected a GFF file to upload: (Max size = 500 KB)'</li>
		<li>Click 'Upload File'. This brings up a new dialog</li>
		<li>The dialog box now shows two additional requests for input 
			<ul class="bullet1">
				<li>'Select or create a project with which to associate these annotations.' Providing a project name allows user to later add GFF data to the same track, by associating it with this project</li>
			</li>'Please verify that the following GFF scaffold assignments are correct.' This allows the script to correctly assign GFF scaffold/bac/chr IDS to those used internally within the xGDB MySQL tables. (Note: if >1 scaffold is represented in the GFF file, the equivalent number of dropdowns will appear).</li>
			</ul>
			</li>
		<li>When the above inputs are complete, click 'Add Track' to complete the process, or 'Cancel' to close dialog and do nothing</li>
		<li>The track will appear with the Project name as the track name </li>
		<li>Click the 'X' to remove track from view. However, track data is currrently retained. In future, a management dialog will handle permanent deletion or re-display).</li>
	</ul>
	
			<span class="heading normalfont linkback"> <a class="smallerfont" href="/XGDB/help/using_gdb.php#genome_user_track">View this in Help Context</a> (create_gdb.php/genome_user_track)</span>

</div>
