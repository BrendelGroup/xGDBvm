
<div class="dialogcontainer">
	<h2 class="bottommargin1">Output Data</h2>
	<p>The xGDBvm directory <span class="plaintext largerfont bold">/xGDBvm/data/</span> is the repository for all <b>output data</b> from the GDB pipeline, as well as user annotations, global databases, admin data, and archives. </p>
	<p><span class="warning">IMPORTANT:</span> <span class="plaintext largerfont">/xGDBvm/data/</span> should be mounted to an <a class="help_style" title="see help section with details on EBS output volume" href="/XGDB/help/create_gdb.php#config_output_dir_mount">external volume (block storage device)</a> for most applications. This external mount strategy both increases storage capacity and allows outputs to be preserved in case the xGDBvm VM is wiped out. </p>
    <p>NOTE: For convenience, a "virtual directory", <span class="plaintext largerfont">/xGDBvm/data/</span>, is symbolically linked to <span class="plaintext largerfont">/home/</span>, and thus we often refer to <span class="plaintext largerfont">/xGDBvm/data/</span> as the parent directory for GDB output files (<span class="plaintext largerfont">GDB001</span>, <span class="plaintext largerfont">GDB002</span>, etc.</p>
	<p><b>Output data</b> include the following data types and destinations:</p>
	<ul class="bullet1 indent2" style="list-style: none">
	    <li><span class="largerfont grayfont bold">1)</span> <b>MySQL Databases</b> (both global and GDB-specific), stored under <span class="plaintext largerfont">/xGDBvm/data/mysql/</span></li>
	    <li><span class="largerfont grayfont bold">2)</span> <b>GDB output files</b>, stored under the "virtual" directory <span class="plaintext largerfont">/xGDBvm/data/</span> (which is actually <span class="plaintext largerfont">/home/</span>)
            <ul class="bullet1">
                <li>Web configuration files for each GDB under e.g. <span class="plaintext largerfont">/xGDBvm/data/GDB001/conf/</span></li>
                <li>Pipeline log files for each GDB under e.g. <span class="plaintext largerfont">/xGDBvm/data/GDB001/logs/</span></li>
                <li>Blast indices for each GDB under e.g. <span class="plaintext largerfont">/xGDBvm/data/GDB001/data/BLAST/</span></li>
                <li>Original input files for each GDB under e.g. <span class="plaintext largerfont">/xGDBvm/data/GDB001/data/download/</span></li>
                <li>Intermediate data files in several directories under e.g. <span class="plaintext largerfont">/xGDBvm/data/GDB001/data/</span></li>
            </ul>
        </li>
	    <li><span class="largerfont grayfont bold">3)</span><b>GDB Archives</b> (user-created) are also stored under the "virtual" directory <span class="plaintext largerfont">/xGDBvm/data/</span>:
	        <ul class="bullet1">
	            <li>Individual GDB archives under <span class="plaintext largerfont">/xGDBvm/data/ArchiveGDB/</span> </li>
	            <li>"All GDB" archives under <span class="plaintext largerfont">/xGDBvm/data/ArchiveAll/</span></li>
	        </ul>
	    </li>
    </ul>
	<p>Using output files as <b>inputs</b>:</p>
	<ul class="bullet1 indent2">
		<li>Output data files follow the same <a title="Detailed file format and naming conventions" href="/XGDB/conf/data.php">filename conventions</a> as input data files, with the addition of a GDB tag, e.g. <span class="plaintext largerfont">GDB001tsa.gsq</span> (GeneSeqer output for TSA)</li>
		<li>This means you can use certain output files such as the above as <b>input files</b> to re-create the same spliced alignments in a new GDB </li>
	</ul>				

			<span class="heading normalfont linkback"> <a class="smallerfont" href="/XGDB/help/create_gdb.php#config_output_dir">View this in Help Context</a> (create_gdb.php/config_output_dir)</span>
</div>

