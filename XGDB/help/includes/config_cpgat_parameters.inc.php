
<div class="dialogcontainer">
	<h2 class="bottommargin1">CpGAT Parameters - Configuration Page </h2>
	<p class="topmargin1"><b>NOTE:</b> Use only if <b>Run CpGAT? Yes</b> is selected under <b>Input Data</b></p>

	<h3 class="topmargin1">CpGAT Parameters options</h3>
	
	<p class="topmargin1"><b>Reference Protein Index File and Path</b> (required) - a path that points to a <b>NCBI blast</b> index of a reference dataset (e.g. from UniRef90 viridiplantae)</p>
				<ul class="bullet1">
					<li>(if none is designated, CpGAT will use a default index of 'core' eukaryotic proteins)</li>
				</ul>
	<p> <b>Repeat Dataset Index</b> (optional) - a path that points to a .fasta file containing a repeat masking dataset</p>
			
	<p class="topmargin1"><b><i>Ab initio</i> Genefinders</b>: as a supplement to evidence-based models, one or more of these can be selected:</p>
	
		<ul class="bullet1">
			<li>BGF  (Skip)  -or- select species model  - See <a href="http://tlife.fudan.edu.cn/bgf">BGF website</a> for details </li>
			<li>Augustus (Skip)  -or- select species model - See<a href="http://augustus.gobics.de/">Augustus website</a> for details</li>
			<li>GeneMark: (Skip)  -or- select species model - See<a href="http://exon.biology.gatech.edu/">GeneMark website</a> for details</li>
		</ul>
		
	<p class="topmargin1"><b>Additional Options:</b> for further refinement of output</p>
		<ul class="bullet1">
			<li>Skip Mask: No/Yes - skip masking step prior to <i>Ab initio</i> run</li>
			<li>Relax UniRef: No/Yes  - don't require UniRef (or other reference dataset) hit to call gene model</li>
			<li>Skip PASA: No/Yes - Skip <a href="http://pasa.sourceforge.net/">PASA</a> aggregation of variants, to avoid potentially artifactual splice variants</li>
			<li>Filter Genes: No/Yes - Load only gene models with support from Reference Protein dataset</li>
		</ul>
			<span class="heading normalfont linkback"> <a class="smallerfont" href="/XGDB/help/create_gdb.php#config_cpgat_parameters">View this in Help Context</a> (create_gdb.php/config_cpgat_parameters)</span>


</div>
