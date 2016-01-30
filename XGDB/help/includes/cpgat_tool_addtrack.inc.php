<div class="dialogcontainer">
	<h2 class="bottommargin1">CpGAT Tool: Append or Create Track</h2>
	<p>This features lets you upload your region annotation to a CpGAT track</p>
	<p> <b> To try out this feature</b>:</p> 
	<ol class="orderedlist1 indent2">
		<li>Run Example 3 under Manage->Configure->Create New GDB (or use your own GDB data and region)</li>
		<li>Go to the 'default region' (or any genic region) in your GDB genome browser</li>
		<li>Select Annotate->CpGAT in the orange dropdown menu</li>
		<li>The genomic region should load. Run region CpGAT tool using defaults</li>
		<li>On the CpGAT output page, select any of the buttons under option 2 (append) or option 3 (replace)</li>
		<li>As a result, the script should redirect to the Config page for that GDB </li>
		<li>Now then following 'Update Mode' configuration should be in place:
			<ul class="bullet1 indent2">
				<li>Update='checked'</li>
				<li>Update Action= 'Append' or 'Replace' CpGAT models (depending on which button you selected earlier)</li>
				<li>Update Path = <span class="plaintext">/xGDBvm/tmp/GDBnnn/CpGAT/CpGAT-123456/update/</span> where '123456' is an integer time stamp identifying the unique directory.</li>
				<lli>There should be 3 update files listed in the "Update" dropdown</li>
		</ul>
		</li>Click Data Process Options -> Update GDBnnn Database" to run the Update pipeline and add or replace CpGAT models.</li>
		<li>When complete, return to genome context view to see the added CpGAT models (violet track glyph)</li>
		<li>You can repeat the process to add more annotations or replace the current ones</li>
	</ol>
			<span class="heading normalfont linkback"> <a class="smallerfont" href="/XGDB/help/cpgat.php#cpgat_tool_addtrack">View this in Help Context</a> (create_gdb.php/cpgat_tool_addtrack)</span>
</div>
