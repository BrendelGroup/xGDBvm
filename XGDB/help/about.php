<?php
	$PageTitle = 'About';
	$pgdbmenu = 'Help';
	$submenu = 'About';
	$leftmenu='About';
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
		
			<h1 class="topmargin1 bottommargin1">About xGDBvm</h1>

				<p>	xGDBvm is being developed as part of an <a title="view NSF grant page"  href="http://128.150.4.107/awardsearch/showAward.do?AwardNumber=1126267">NSF-funded project (IOS-1126267)</a> to develop robust genome annotation methods, tools, and
				 standard training sets for the plethora of plant genomes currently or soon to be sequenced. The project goal is to develop an integrated plant genome annotation system (IPGA).
				</p>
				
				<p>xGDBvm was adapted from the xGDB platform and tools that are maintained at <a href="http://plantgdb.org">plantgdb.org</a>. Our current implementation of xGDBvm is under development for iPlant's <a href="http://www.iplantcollaborative.org/discover/atmosphere">Atmosphere</a> cloud service infrastructure, as a virtual server platform for use by the research community.</p>

				<p>xGDBvm is currently in prototype stage. Please contact us if you would like more information.</p>
				
					<h2 class="topmargin1 bottommargin1">Who we are</h2>
					
						<h3 class="topmargin1 bottommargin1 indent1">xGDBvm Development</h3>
									<ul class="menulist bottommargin1">
										<li> - Volker Brendel (PI, Indiana University) </li>
										<li> - Jon Duvick (Senior Personnel, Iowa State University)</li>
									</ul>
						
						<h3 class="topmargin1 bottommargin1 indent1">IPGA Project Co-PIs</h3>
									<ul class="menulist bottommargin1">
										<li> - Karin Dorman (Co-PI, Iowa State University)</li>
										<li> - Shailesh Lal (Co-PI, Oakland University)</li>
										<li> - Yasser El-Manzalawi (Senior Personnel, Iowa State University)</li>
									</ul>
						<h3 class="topmargin1 bottommargin1 indent1">Collaborators:</h3>
						
						<p>See <a href="/XGDB/help/acknowledgments.php">Acknowledgments</a>.</p>
						
					<h2 class="topmargin1 bottommargin1">References</h2>
					
					<ol class="referencelist">
											
						<li>Schlueter S.D., Wilkerson M.D., Dong Q., &amp; Brendel V.
							(2006) <b>xGDB: open-source computational infrastructure for the
							integrated evaluation and analysis of genome features.</b>
							<i>Genome Biol.</i> <b>7</b>(11): R111. [<a href=
							"http://www.ncbi.nlm.nih.gov/entrez/query.fcgi?cmd=Retrieve&amp;db=PubMed&amp;dopt=Citation&amp;list_uids=17116260">PubMed
							ID: 17116260</a>] [<a href=
							"http://genomebiology.com/2006/7/11/R111">online article</a>]</li>
							
						<li>Wilkerson, M.D., Schlueter, S.D. &amp; Brendel, V. (2006)
							<b>yrGATE: a web-based gene-structure annotation tool for the
							identification and dissemination of eukaryotic genes.</b> <i>Genome
							Biol.</i> <b>7</b>, R58. [<a href=
							"http://www.ncbi.nlm.nih.gov/entrez/query.fcgi?cmd=Retrieve&amp;db=PubMed&amp;dopt=Citation&amp;list_uids=16859520">PubMed
							ID: 16859520</a>]</li>
											
											
					</ol>
					
					
					<h2 class="topmargin1 bottommargin1">Other Resources</h2>
					
								<ul class="menulist bottommargin2">
									<li><a href="/XGDB/help/acknowledgments.php">Acknowledgments</a></li>
									<li><a href="http://brendelgroup.org/">Brendel Group</a></li>
									<li id="nsf" class="last"><a href="http://www.nsf.gov/" title="National Science Foundation">NSF</a></li>
								</ul>
								
			</div><!--end maincontentsfull-->
			</div><!--end maincontentscontainer-->
		<?php include($XGDB_FOOTER); ?>
		</div><!--end pagewidth-->
	</div><!--end innercontainer-->
</div><!--end outercontainer-->
</body>
</html>
