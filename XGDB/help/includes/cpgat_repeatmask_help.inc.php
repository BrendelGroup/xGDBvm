
<div class="dialogcontainer">
	<h2 class="bottommargin1">CpGAT- Repeat Mask Index</h2>
	<ul class="bullet1">
		<li>
			A <a href="http://www.vmatch.de/">Vmatch</a>-indexed repeat dataset that is optionally employed by CpGAT for masking genomic regions prior to <i>ab initio</i> gene finder analysis
		</li>
		<li>
			Default is <a title="MIPS Plant Group" href="http://mips.helmholtz-muenchen.de/plant/cgenomics.jsp">repeatLib/mips_REdat_4.3_rptmsk.lib</a>, a collection of plant repeated sequences.
		</li>
		<li>
			For best results, use a repeat mask dataset tailored to your genome taxonomy, e.g. <a href="http://www.girinst.org/server/RepBase/index.php">RepBase</a> (registration required).
		</li>
	</ul>
	<h3>How to configure a custom Repeat Mask index:</h3>
	<ul class="bullet1">
		<li>
			Download a <b>repeat mask dataset</b> (FASTA-formatted) to your attached storage device in a directory, e.g. /xGDBvm/data/MyData/Repeat/
		</li>
		<li>
			Create a Vmatch index in the same directory as the primary file, using the <i>mkvtree</i> command, as follows:
		</li>
	
		<pre class="normal bold topmargin">

[my@vm]$ /usr/local/bin/mkvtree
  -db <span class="alertnotice">myRepMask.fasta<span> -dna -pl -allout  -v
		</pre>
		<li>
			Enter the complete path to the Repeat Mask Index in the Configuration page. INCLUDE COMPLETE FILE PATH AND FILENAME, similar to the example below:
		</li>

 
  <pre class="normal bold topmargin1 bottommargin1">/xGDBvm/data/MyData/Repeat/<span class="alertnotice">myRepeatMask.fasta</span></pre>


		<li>
			After saving your configuration, click on the path to confirm that it is correct (it will be hyperlinked).
		</li>
	</ul>
</div>
