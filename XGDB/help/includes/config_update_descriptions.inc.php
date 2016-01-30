
<div class="dialogcontainer">
	<h2 class="bottommargin1">Update Descriptions</h2>
	<p>Your GDB's gene annotation data may benefit from the inclusion of a gene description for each ID (e.g. top blast hit). </p>
	<p>Using xGDBvm's <b>Update</b> feature, a <b>Description</b> file can be uploaded to either <b>precomputed</b> or <b>CpGAT-derived</b> annotations. This information is displayed with each gene model and in the Locus table.</p>
	
<h3 class="topmargin1">1) Create a Description file:</h3>

	<ol class="bullet1">
	<li>Create a two-column, tab-delimited file consisting of ID - Description for each gene model</li>
	<li>Gene Model ID must correspond to ID displayed in the corresponding annotation track; description should be text-only, no tabs</li>
	<li>Name the Description file according to the convention: <span class="alertnotice">~annot.desc.txt</span> (see also <a target="_blank" title="Detailed file format and naming conventions (click ? to open new web page)" href="/XGDB/help/create_gdb.php#config_file_names">filename conventions</a>)</li>
	<li>Note that any existing descriptions will be replaced by the above</li>
	</ol>
	
<h3>2) Upload your Description file:</h3>

	<ol class="bullet1">
	<li>Place the file in an Update directory under <span class="plaintext">/xGDBvm/input/</span> (ideally, NOT the same as your Input data directory).</li>
	<li>Click 'Edit Configuration' on your GDB's configuration page</li>
	<li>Under the 'Update Data' heading, click 'Yes' for 'Update this GDB?' and enter the Update Data Path</li>
	<li>Under 'Add Descriptions' select either <b>Precomputed</b> or <b>CpGAT</b> annotations</li>
	<li>If you are updating other features at the same time, make sure all files are in the same Update directory</li>
	<li>'Save' your configuration and the click 'Data Process Options...' &rarr; 'Update GDB'</li>
	</ol>

			<span class="heading normalfont linkback"> <a class="smallerfont" href="/XGDB/help/create_gdb.php#config_update_descriptions">View this in Help Context</a> (create_gdb.php/config_update_descriptions)</span>
</div>

