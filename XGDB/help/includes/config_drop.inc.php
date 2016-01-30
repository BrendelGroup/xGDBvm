
<div class="dialogcontainer">
	<h2 class="bottommargin1">Drop GDB</h2>
	<p><b>Dropping</b> a <span class="Current">Current</span> GDB removes all data tables and reverts it to <span class="Development">Development</span> status, allowing you to start over.</p>
	<p class="topmargin1 bottommargin2">To Drop a GDB, click the <img id='button_drop' style='margin-bottom: -5px' src='/XGDB/help/images/button_drop.gif' alt='Drop Database' /> button (in <span class="options_mode">Options Mode</span>).</p> 
	<p>Or, navigate to <i>Manage</i> &rarr; <i>Config/Create</i> &rarr; <a href="/XGDB/conf/archive.php">Archive/Delete</a> which lists all GDB and provides data actions including <i>Drop</i>.</p>
	<ul class="bullet1 indent2">
        <li>Note that this action will PERMANENTLY remove the data for this genome. It WILL NOT affect your input data, however.</li>
        <li>After a GDB is dropped, its GDB ID and configuration are retained, so you can re-use or modify the configuration as desired.</li>
        <li>You can re-create a GDB by one of several methods:
            <ol class="orderedlist1">
                <li>Simply <b>re-run</b> the data pipeline by selecting <i>Config</i> &rarr; <i>Data Process Options</i> &rarr; <i>Create New GDB</i>, perhaps after modifying its configuration parameters (<i>Config</i> &rarr; <i>Edit Configuration</i>).</li>
                <li>Reload the GDB from its <b>Archive</b> by selecting <i>Config</i> &rarr; <i>Data Process Options</i> &rarr; <i>Restore from Archive</i> </li>
                <li>Reload the GDB from a <b>different GDB</b> <b>Archive</b> by selecting <i>Config</i> &rarr; <i>Edit Configuration</i> &rarr; <i>Use GDB Archive</i> (Select from Dropdown), and then following Step 2 above</li>
            </ol>
        </li>
        <li>Click "Cancel" to return to configuration view</li>
	</ul>
	
			<span class="heading normalfont linkback"> <a class="smallerfont" href="/XGDB/help/create_gdb.php#config_drop_option">View this in Help Context</a> (create_gdb.php/config_drop_option)</span>

</div>
