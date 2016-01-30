<div class="dialogcontainer">
	<h2 class="bottommargin1">Repeat Mask Library</h2>
	
	<p> You may specify a path to a custom Repeat Mask library that will be used to mask the genome using Vmatch, prior to spliced alignment with GeneSeqer.  (You must also click 'Repeat Mask Genome? Yes' to run this option.)
		
	<ul class="bullet1 indent2">
		<li>
			Default (under 'examples') is the <a title="MIPS Plant Group" href="http://mips.helmholtz-muenchen.de/plant/cgenomics.jsp">mips_REdat</a>, a public collection of plant repeated sequences.
		</li>
		<li>
			For best results, use a repeat mask dataset tailored to your genome taxonomy, e.g. from <a href="http://www.girinst.org/server/RepBase/index.php">RepBase</a> (registration required).
		</li>
		</ul>
		
	<h3>How to include a custom Repeat Mask index:</h3>
	
	<ul class="bullet1 indent2">
		<li>
			Obtain a suitable <b>repeat mask dataset</b> (FASTA-formatted, with only [ATGC] alphabet; any prefix but must have standardized suffix ".fa"), e.g. <span class="plaintext largerfont">myRepeatFile.fa </span>
		</li>
		<li>
			 Upload to your iPlant Data Store's '<span class="plaintext largerfont">repeatmask</span>' directory (<span class="plaintext largerfont">/home/myusername/repeatmask/ </span>; if not present, create it at the top directory level) 
		</li>
		<li>
			When you configure your GDB, this file will appear in the 'Repeat Mask Index' dropdown, e.g.  <span class="plaintext largerfont">/xGDBvm/input/repeatmask/myRepeatFile.fa </span>
		</li>
		<li>
			After selecting and saving your configuration, this file should appear under the validation dropdown "Index Files".
		</li>
	</ul>
	
 <p>NOTE: xGDBvm will create a feature track based on N-masked regions including the outcome of repeat masking:</p>
	<ul class="bullet1 indent2">
    <li>'unknown bases' (i.e. a string of N's present before repeat masking) are grey</li>
    <li>'masked bases' (i.e. a string of N's present only after repeat masking) are orange</li>
	</ul>
<span class="heading normalfont linkback"> <a class="smallerfont" href="/XGDB/help/create_gdb.php#config_repmask_file">View this in Help Context</a> (create_gdb.php/config_repmask_file)</span>

</div>

