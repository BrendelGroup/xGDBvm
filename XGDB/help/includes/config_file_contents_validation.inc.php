<div class="dialogcontainer"  id="filename_requirements" >
	<h2 class="bottommargin1"> File Contents Validation</h2>

<p>xGDBvm will <b>validate</b> the contents of each correctly-named file in the Input, Reference Protein and Repeat Mask directories.</p>
<ul class="bullet1 indent2">
	<li>For <b>fasta</b>-formatted files, the script will enumerate sequences and size distribution, N-masking and X-masking, check header format, flag duplicate IDs and illegal header tabs</li>
	<li>For <b>other</b> file types (gff3, gsq, gth, or txt files), the script will parse and count entries according to the expected format and flag files that have no recognized content.</li>
	<li>Validation results are <b>saved</b> (based on unique filename-size-date combination), so evaluation only need be done once unless the file is modified</li>
</ul>


<h3 class="topmargin1 bottommargin1">Validation Status (Input file list):</h3>
<ul class="bullet1 indent2">
    <li>Files <span class="filevalid">valid</span>, <span class="filenotvalid">invalid</span>, and <span class="filenoteval">not yet evaluated</span>  are displayed for Inputs, Reference Protein File, and Repeat Mask Library. Click to display hidden list for each input type.</li>
    <li>Files can be validated one at a time by clicking a file's <img class="nudge3" alt="blue" src="/XGDB/images/information.png" /> icon. The resulting popup shows information about the file, its contents and format. Validation result is shown, and data are saved to a database.</li>
	<li>Results (after screen refresh) are color-coded: <img class="nudge3" alt="green" src="/XGDB/images/information_green.png" /> valid; <img class="nudge3" alt="red" src="/XGDB/images/information_red.png" /> invalid; <img class="nudge3" alt="blue" src="/XGDB/images/information.png" /> not evaluated</li>
    <li>To validate <b>all files</b> in the Input directory <b>at the same time</b> , use '<i>Data Process Options...</i>' (see below).</li>
</ul>

<h3 class="topmargin2 bottommargin1">To validate all files in the Input directory (and Reference Files):</h3>
	
	<ol class="indent1 orderedlist1">
		<li>Navigate to the GDB Config page (must be <span class="Development">Development</span> status)</li>
		<li>Click '<i>Data Process Options...</i>' button </li>
		<li>Click '<i>Validate My Input Files</i>' button</li>
		<li>The GDB will be  <span class="Locked">Locked</span> until the process completes (up to several minutes)</li>
		<li>Refresh screen to update status</li>
		<li>When complete, the validation status (<img class="nudge3" alt="green" src="/XGDB/images/information_green.png" /> or <img class="nudge3" alt="red" src="/XGDB/images/information_red.png" />) is displayed inline with each file in the Input and Reference lists (see above)</li>
	</ol>

<p class="topmargin1"><b>NOTE:</b> the validation feature (for individual files only) is also available on the <b>Submit Jobs</b> page, and for GDB output files on the <b>Download</b> page.</p>

	<span class="heading normalfont linkback"> <a class="smallerfont" href="/XGDB/help/create_gdb.php#config_file_validation">View this in Help Context</a> (create_gdb.php/config_file_validation)</span>
 </div>
