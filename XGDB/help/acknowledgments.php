<?php
	$PageTitle = 'Acknowledgments';
	$pgdbmenu = 'Help';
	$submenu = 'Help';
	$leftmenu='Help';
	$global_DB= 'Genomes';
	include("sitedef.php");
	include($XGDB_HEADER);
?>


		<div id="leftcolumncontainer">
			<div class="minicolumnleft">
				<?php include_once("/xGDBvm/XGDB/phplib/leftmenu.inc.php"); ?>
			</div>
		</div>

		<div id="maincontentscontainer" class="twocolumn">
		<div id="maincontentsfull">
		
<h1 class="topmargin1 bottommargin1">Acknowledgments</h1>

	
	<h2>Support</h2>
	
		<p>
			xGDBvm is produced with support from the USA National Science Foundation Plant Genome Research Projects grant <a title="view NSF grant page"  href="http://128.150.4.107/awardsearch/showAward.do?AwardNumber=1126267">DBI 1126267</a>, 'IPGA: Characterization, Modeling, Prediction, and Visualization of the Plant Transcriptome.'
		</p>
		
		<p>See <a href="/XGDB/help/about.php">About</a></p>
	
				
	<h2 class="topmargin1 bottommargin1">Contributions to core software</h2>
	
	<ul class="menulist">
							
		<li>Jinsong Liu - CpaGAT</li>
		<li>Shannon Schlueter - xGDB platform, GAEVAL</li>							
		<li>Matthew Wilkerson - yrGATE platform</li>							
	</ul>
	
	<h2 class="topmargin1 bottommargin1">Collaborators</h2>
	
		<h3 class="topmargin1 bottommargin1	indent1"><a href="http://www.iplantcollaborative.org/">iPlant Collaborative</a></h3>
		
			<ul class="menulist">
									
				<li>Nirav Merchant</li>
				<li>Eric Lyons </li>
				<li>Edwin Skidmore</li>
				<li>etc.</li>
			</ul>
			
	
	<h2 class="topmargin1 bottommargin1">Other Software Packages</h2>
	
		<ul class="menulist bottommargin2">
								
			<li>Augustus</li>
			<li>BGF</li>
			<li>CpGAT</li>
			<li>Dokuwiki</li>
			<li>GeneSeqer</li>
			<li>GenomeThreader</li>
			<li>GeneMark</li>
			<li>PASA</li>
			<li>Solar</li>
										
		</ul>
	

			
			</div><!--end maincontentsfull-->
			</div><!--end maincontentscontainer-->
		<?php include($XGDB_FOOTER); ?>
		</div><!--end pagewidth-->
	</div><!--end innercontainer-->
</div><!--end outercontainer-->
</body>
</html>
