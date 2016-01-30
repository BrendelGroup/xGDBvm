<?php
	$PageTitle = 'Genome Tracks';
	$pgdbmenu = 'Help';
	$submenu= 'TracksHelp';
	$leftmenu = 'TracksHelp';
	include '/xGDBvm/XGDB/phplib/sitedef.php';
	include('/xGDBvm/XGDB/phplib/header.php');
?>
				<div id="leftcolumncontainer">
					<div class="minicolumnleft">
						<?php include_once("/xGDBvm/XGDB/help/leftmenu.inc.php"); ?>
					</div>
				</div>
				<div id="maincontentscontainer" class="threecolumn">
					<div id="maincontents" class="help">
						<h1 id="heading" class="help_style bottommargin2"><img alt="" src="/XGDB/images/circle_help.png" />&nbsp;Feature Track Tables</h1>

						<div class="helpsection">
                        <p><b>Feature Track Tables</b> are searchable tables for each track type, arranged in genome order, along with information about each locus/alignment. Available from the GDB Left Menu under <i>'Feature Tracks' &rarr; <b>'Gene Predictions (Loci)'</b>, <b>'Aligned Proteins'</b>,  <b>'Aligned Transcripts'</b></i></p>
                        </div>

							<div class="helpsection" id="contents">
							<h2 class="help" id="contents_heading">Contents</h2>
											<!--Contents-->	
								<ul class="contentslist">
									<li><b>Genome Track Tables </b>
										<ul class="bullet1">
											<li><a href="#tracks_loci">Gene Predictions (Loci)</a></li>
											<li><a href="#tracks_proteins">Aligned Proteins</a></li>
											<li><a href="#tracks_transcripts">Aligned Transcripts</a></li>
										</ul>
									</li>
									<li><b>Gene Prediction Table - Features</b>
										<ul class="bullet1">
											<li><a href="#tracks_loci_search">Search</a></li>
											<li><a href="#tracks_loci_coverage">Coverage</a></li>
											<li><a href="#tracks_loci_integrity">Integrity</a></li>
											<li><a href="#tracks_loci_yrgate_status">yrGATE status</a></li>
										</ul>
									</li>
									<li><b>Aligned Proteins and Transcripts Tables - Features</b>
										<ul class="bullet1">
											<li><a href="#tracks_search">Search</a></li>
											<li><a href="#tracks_scaffolds">Scaffold</a></li>
											<li><a href="#tracks_copynum">Copy Number</a></li>
											<li><a href="#tracks_similarity">Similarity</a></li>
											<li><a href="#tracks_coverage">Coverage</a></li>
										</ul>
									</li>
								</ul>
						</div>

						<div class="helpsection">
							<h2 class="help">Genome Tracks</h2>
							<div class="feature" id="tracks_loci">
								<?php include('/xGDBvm/XGDB/help/includes/tracks_loci.inc.php'); ?>
									<a class="smallerfont indent2" href="#heading">[top]</a>
							</div>
							<div class="feature" id="tracks_proteins">
								<?php include('/xGDBvm/XGDB/help/includes/tracks_proteins.inc.php'); ?>
									<a class="smallerfont indent2" href="#heading">[top]</a>
							</div>
							<div class="feature" id="tracks_transcripts">
								<?php include('/xGDBvm/XGDB/help/includes/tracks_transcripts.inc.php'); ?>
									<a class="smallerfont indent2" href="#heading">[top]</a>
							</div>
						</div>
						<div class="helpsection">
							<h2 class="help">Gene Predictions Table - Features</h2>
							<div class="feature" id="tracks_loci_search">
								<?php include('/xGDBvm/XGDB/help/includes/tracks_loci_search.inc.php'); ?>
									<a class="smallerfont indent2" href="#heading">[top]</a>
							</div>
							<div class="feature" id="tracks_loci_coverage">
								<?php include('/xGDBvm/XGDB/help/includes/tracks_loci_coverage.inc.php'); ?>
									<a class="smallerfont indent2" href="#heading">[top]</a>
							</div>
							<div class="feature" id="tracks_loci_integrity">
								<?php include('/xGDBvm/XGDB/help/includes/tracks_loci_integrity.inc.php'); ?>
									<a class="smallerfont indent2" href="#heading">[top]</a>
							</div>
							<div class="feature" id="tracks_loci_yrgate_status">
								<?php include('/xGDBvm/XGDB/help/includes/tracks_loci_yrgate_status.inc.php'); ?>
									<a class="smallerfont indent2" href="#heading">[top]</a>
							</div>
						</div>
						<div class="helpsection">
							<h2 class="help">Aligned Proteins and Transcripts Tables - Features</h2>
							<div class="feature" id="tracks_search">
								<?php include('/xGDBvm/XGDB/help/includes/tracks_search.inc.php'); ?>
									<a class="smallerfont indent2" href="#heading">[top]</a>
							</div>
							<div class="feature" id="tracks_scaffolds">
								<?php include('/xGDBvm/XGDB/help/includes/tracks_scaffold.inc.php'); ?>
									<a class="smallerfont indent2" href="#heading">[top]</a>
							</div>
							<div class="feature" id="tracks_integrity">
								<?php include('/xGDBvm/XGDB/help/includes/tracks_similarity.inc.php'); ?>
									<a class="smallerfont indent2" href="#heading">[top]</a>
							</div>
							<div class="feature" id="tracks_coverage">
								<?php include('/xGDBvm/XGDB/help/includes/tracks_coverage.inc.php'); ?>
									<a class="smallerfont indent2" href="#heading">[top]</a>
							</div>
						</div>
					</div><!--end maincontents-->
						  <div style="clear:both; float:right">
							<a href="http://validator.w3.org/check?uri=referer"><img
							  src="http://www.w3.org/Icons/valid-xhtml10" alt="Valid XHTML 1.0 Transitional" height="15" width="44" /></a>
						  </div>						
				</div><!--end maincontentscontainer-->
				<?php include('/xGDBvm/XGDB/phplib/footer.php'); ?>
			</div><!--end pagewidth-->
		</div><!--end innercontainer-->
	</div><!--end outercontainer-->
	</body>
	</html>
