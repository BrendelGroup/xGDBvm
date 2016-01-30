<?php
$pgdbmenu = 'Annotation';
$leftmenu='yrGATE_Overview';
$submenu = 'yrGATE_Overview';
include 'sitedef.php';
include 'db_def.php';
$bckgrnd_class='anno';
$SeqDisplay=1;
include $XGDB_HEADER;
?>

	<div id="leftcolumncontainer">
		<div class="minicolumnleft">
			<?php include_once(dirname(__FILE__) . '/leftmenu.inc.php'); ?> 
		</div>
	</div>
	<div id="maincontentscontainer" class="threecolumn">
	<div id="maincontentsfull">
				<a href="/src/yrGATE/images/EvidencePlot.jpg"><img title="Click to Enlarge" src="/src/yrGATE/images/EvidencePlot.jpg" alt="yrgate evidence plot" class="thumbnail_4" /></a>
		<h1>yrGATE - a tool for gene structure annotation</h1>

		<p>
			"...
			<u>y</u>ou<u>r</u> 
			<u>G</u>ene structure 
			<u>A</u>nnotation 
			<u>T</u>ool for 
			<u>E</u>ukaryotes"</p>

	 
	<h2>What is yrGATE?</h2>
		<p>
			yrGATE is a web based gene-structure annotation tool for the identification and dissemination of eukaryotic genes. Annotators can evaluate gene evidence graphically <b>(see figure)</b> to create gene structure annotations. Administrators curate the submitted annotations into published gene sets. yrGATE is appropriate for annotating emerging genomes and correcting inaccurate published annotations. yrGATE is portable and supports different input and output formats. <b>SEE ALSO:</b> <a href="/yrGATE/">Community Annotation Overview</a>.
		</p>
		
		<h2>yGATE for Community Gene Structure Annotation</h2>
 		<p>User-generated annotations can complement automated pipelines by correcting errors and incorporating new alignment evidence to improve the overall annotation quality. yrGATE is an excellent tool for community annotation projects, as it is universally available (web browser-based) and can take advantage of the latest data through the real-time annotation tool CpGAT.</p>  

	 

		<h2>yrGATE Implementation at PlantGDB</h2>
		<p>yrGATE is available for all PlantGDB genome browsers. Use the <i>Genome</i> tab at the top of this page to launch a browser, and then click "Community Annotation" on the left menubar. Or, go to the <a href="/prj/GenomeBrowser/">Genome Browser</a> overview page and select "Community Annotation" for the species of interest.</p>

		
		<h2>Using yrGATE at PlantGDB</h2>
			 <p>Visit the <a title="Help and Tutorials Overview page" href="/help/">Help and Tutorals</a> page for more information and options.<br />
			 For a quick view of yrGATE in action, click below to see a video demo, <b>"Using yrGATE to annotate genes"</b>.</p>
				<ul class="menulist">
					<li><a title="View with Quicktime" class="video-button qtvideo" id="yrGATE_MtGDB6">Quicktime</a></li>
					<li><a title="View with Flash (hosted by Vimeo)" class="flvideo-button flvideo" id="7858561">Flash</a></li>
				</ul>			 

		<h2 class="topmargin1">Availability</h2>

		<p>The yrGATE software package is freely available for academic purposes and can be downloaded from the 
			<a href="http://brendelgroup.org/bioinformatics2go/yrGATE.php">Brendel Group website</a>.
			A license is required for commercial use.
			<a href="mailto:mwilkers@iastate.edu">Email the author</a> if you need additional information on installing and using yrGATE.
		</p>

		<p>(c) yrGATE 2006-2013</p>

		</div><!--end maincontentsfull-->
	</div><!--end maincontentscontainer-->
	<?php include($XGDB_FOOTER); ?>
	</div><!--end pagewidth-->
</div><!--end innercontainer-->
</div><!--end outercontainer-->
</body>
</html>

