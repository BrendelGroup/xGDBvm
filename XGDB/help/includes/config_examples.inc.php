
<div class="dialogcontainer">
	<h2 class="bottommargin1">Example Datasets</h2>
	<p>You can load and process one of several <b>Example</b> datasets in order to test your xGDBvm and get a feel for the pipeline workflow. Each example consists of a pre-configured set of input parameters and a (small) dataset already prepared and named according to xGDBvm's <a title="Detailed file format and naming conventions (click ?)" href="/XGDB/conf/data.php">data conventions</a> .</p>
	
<h3>To run an Example:</h3>
	<ol class="bullet1">
	<li>Navigate to  '<i>Manage &rarr; Config/Create &rarr; Create New GDB</i>'.</li>
	<li>Click the <i>Examples</i> button at the top of the <i>Create New GDB</i> page to view numbered Example options</li>
	<li>Choose an Example for testing. You can always delete it later and/or try a different one*. <span class="tip_style">Suggestion: Try <b>Example 3</b> first as it's very fast due to the use of precomputed spliced alignment inputs.</span></li>
	<li>After you load an Example configuration, click <i>Save</i> to save it. You now have a <span class="Development">Development</span>-configured GDB.</li>
	<li>Scroll down the Configuration page and note the parameters and options that have been filled in. When you create your own GDB you will select any non-defaults yourself</li>
	<li>Note particularly the <b>Input Data Path</b>, which for the Examples will be <span class="plaintext largerfont">/xGDBvm/examples/</span>. When you use your own data the path will be a directory you specify under <span class="plaintext largerfont">/xGDBvm/input/xgdbvm/</span> (i.e. your Data Store, for iPlant users) </li>
	<li>When ready, click <i>'Data Process Options...'</i>. This uncovers all data processing options available for this GDB. </li>
	<li>You should see an orange button, <i>'Create New GDB00n Database'</i>. Click it to initiate the pipeline, which changes status to <span class="Locked">Locked</span>.</li>
	<li>You can monitor pipeline progress in the window, or click the magnifying glass to open a new window showing the complete progress log. Most examples should be complete in less than 5-7 minutes (real-world datasets may take much longer!!)</li>
	<li>At completion of the pipeline, when you refresh the window status will change to <span class="Current">Current</span>. You can view the number of features added to each track by scrolling down to the <i>Input/Output</i> section.</li>
	</ol>

	<p>*If you want to delete this Example and start over, navigate to '<i>Manage &rarr; Config/Create &rarr; Archive/Delete</i>' and click '<i>Delete Most Recent GDB</i>'</p>

			<span class="heading normalfont linkback"> <a class="smallerfont" href="/XGDB/help/create_gdb.php#config_examples">View this in Help Context</a> (create_gdb.php/config_examples)</span>
</div>

