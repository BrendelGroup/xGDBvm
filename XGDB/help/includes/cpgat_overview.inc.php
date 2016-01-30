
<div class="dialogcontainer">

	<h2 class="bottommargin1">What is CpGAT? </h2>
		<p>
			<b>CpGAT</b> is a comprehensive tool for annotating genomic sequence. It is implemented in the xGDBvm pipeline as a means of creating a complete genome annotation, from a combination of spliced-alignment evidence and <i>de novo</i> predictions.</p>
			
		<p>
			<b>CpGAT</b> is also available as a "region tool" in any xGDBvm genome browser, to re-annotate regions up to 1 Mb using custom parameters.
		</p>
		<p>	
			CpGAT uses <a target="_blank" href="http://evidencemodeler.sourceforge.net/">EVM</a> (EVidence Modeler) to evaluate <a target="_blank"  href="http://www.genomthreader.org">GenomeThreader</a> and/or <a target="_blank" href=" http://brendelgroup.org/bioinformatics2go/GeneSeqer.php">GeneSeqer</a> protein/transcript spliced alignments together with <i>ab initio</i> gene finder results (<a href="http://tlife.fudan.edu.cn/bgf">BGF</a>, <a href="http://exon.biology.gatech.edu/">GeneMark</a>, and <a href="http://augustus.gobics.de/"> Augustus</a>).
			 In addition, some <a target="_blank" href="http://pasa.sourceforge.net/">PASA</a> functions are used to aggregate splice variant models. Output file formats include <b>GFF3</b>, <b>Gbrowse text</b>, and <b>FASTA</b> (transcript, CDS and translation). 
		</p>
		
		<p><b>CpGAT</b>-derived gene models can be display displayed in the xGDBvm genome browser and yrGATE annotation tool as a separate track. They are also automatially evaluated by the <a href= "/XGDB/help/gaeval.php">GAEVAL</a> sytem and quality scores displayed in the <a href="/XGDB/help/using_gdb.php#AnnoTables">CpGAT Annotation Table</a></p>

			<span class="heading normalfont linkback"> <a class="smallerfont" href="/XGDB/help/cpgat.php#cpgat_overview">View this in Help Context</a> (cpgat.php/cpgat_overview)</span>

</div>
