<div class="dialogcontainer"  id="filename_requirements" >
	<h2 class="bottommargin1">Duplicate IDs or Mixed Headers (multi-file)</h2>

<p>xGDBvm's <b>validation</b> script will evaluate the contents of multiple files of the same type (est, cdna, etc) to detect problems that would be only be evident when files are combined.</p>
<ul class="bullet1 indent2">
   <li>For example, if you provided two <b>est</b> files as input:
   	 <ul class="bullet1 indent2">
		<li><span class="plaintext">Best.est.fa</span> </li>
		<li><span class="plaintext">Other.est.fa</span></li>
	</ul>
	</li>
	<li>xGDBvm will combine (cat together) these files for processing, since they will both contribute to the same feature track.</li>
	<li>However, if they each contain one or more overlapping ID's, the data cannot be loaded or processed.</li>
	<li>Likewise, if one file has ncbi (GenBank)-style headers and the other simple headers, the data may not be processed correctly.</li>
</ul>

<h3>Multiple File Errors</h3>
<ul class="bullet1 indent2">
	<li>Any same-type <b>fasta</b> files with duplicate IDs or mixture of different header types will be flagged with <span class="warning">ERROR message</span></li>
	<li>If this error is displayed you will need to examine the file contents carefully and eliminate duplicates and/or standardize header types</li>
	<li>When finished, re-run the validation process to determine if the problem is resolved.</li>
</ul>


	<span class="heading normalfont linkback"> <a class="smallerfont" href="/XGDB/help/create_gdb.php#config_file_duplicates_error">View this in Help Context</a> (create_gdb.php/config_file_duplicates_error)</span>
 </div>
