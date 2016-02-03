
<div class="dialogcontainer">
	<h2>File Permissions</h2>
	<p> xGDBvm must be able to read and copy your input data to a "scratch" directory for processing. In some cases, your data files may have inadequate permissions to allow this.</p>
	
			<p>In your GDB Configuration -> Input/Output -> Input Data Directory listing, the <span class='warning'>permissions</span> flag indicates that the Web server does not have permission to read one or more input files.</p>

	<h3>To correct permissions problems:</h3>
	<ul class="bullet1 indent2">
		<li>Open a shell window (e.g. in iPlant Atmosphere, or via ssh to your xGDBvm instance) and type the following:</li>
		<li>
		<br />
			 <span class='plaintext largerfont'>$ cd /xGDBvm/data/[myInputDirectory]/</span>
			 <br />
			 <span class='plaintext largerfont'>$ ls -la</span>
		</li>
 		<li>You will see a list of all input files with their permissions listed on the left, e.g. </li>
 		<li style="list-style:none">
 		<span class="plaintext largerfont"> -rw-------. [etc.] </span>
 		</li>
 		<li>Now type the following for each file flagged as inadequate read permission (meaning the third-to-last character is not 'r')</li>
 		<li style="list-style:none">
			 <span class='plaintext largerfont'>$ chmod a+r [myFileWithInadequatePermissions]</span>
		</li>
		<li>Now show list of files again:</li>
 		<li style="list-style:none">
			 <br />
			 <span class='plaintext largerfont'>$ ls -la</span>
		</li>
 		<li>The new file list should show correct read permissions ('r') in the last triplet, e.g.</li>
 		<li style="list-style:none">
 		 <span class="plaintext largerfont"> -rw----r--. [etc.] </span>
 		 </li>
        <li>Return to your GDB Config page and refresh. The Input File List should now show no permissions flag</li>
	</ul>
			<span class="heading normalfont linkback"> <a class="smallerfont" href="/XGDB/help/create_gdb.php#config_data_permissions">View this in Help Context</a> (create_gdb.php/config_data_permissions)</span>
</div>
