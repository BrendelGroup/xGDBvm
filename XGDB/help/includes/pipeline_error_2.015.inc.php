
<div class="dialogcontainer">
	<h2 class="bottommargin1">Pipeline Error 2.015</h2>
	
	 
	<h3>Duplicated Sequence ID in fasta file </h3>

	<ul class="bullet1 indent2">
		<li>xGDBvm has determined that there is one or more <b>duplicated sequence</b> in an input fasta file, which will prevent data from displaying properly in your new genome browser.</li>
		<li>This can happen when sequence data are combined from multiple sources</li>
		<li>Alternatively, you may have modified the deflines in a way that inadvertantly truncated part of the defline identifier.</li>
	</ul>
	<h3>To correct this:</h3>
    <ol class="orderedlist1">
        <li>Check the offending file for duplicates and remove them</li>
        <li>Re-run the pipeline in <b>Update</b> mode, or <b>Drop</b> the GDB and start over with the corrected data files</li>
    </ol>
</div>
