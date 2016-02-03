<?php
	$PageTitle = 'Genome Browsers - Help';
	$pgdbmenu = 'Help';
	$submenu= 'ViewGDBhelp';
	$leftmenu = 'ViewGDBhelp';
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
                <h1 id="heading" class="bottommargin2 help_style">
                    <img alt="" src="/XGDB/images/circle_help.png" />&nbsp;Using the Genome Browser<span class="heading"> &nbsp;Browse, Search, Query, Download, Re-Annotate</span>
                </h1>
                <div class="helpsection">
                <p>This <b>Help page</b> contains detailed how-to information on using the <b>xGDBvm genome browser (GDB)</b>: browsing, searching, downloading, or using tools such as BLAST, GenomeThreader, or CpGAT.</p>
                </div>
                <div class="helpsection" id="contents">
                    <!-- table of contents-->
                <h2 class="help" id="contents_heading">Contents</h2>
                    <ul class="contentslist">
                        <li><b>Overview</b>
                            <ul class="bullet1">
                                <li><a href="#genome_overview">Genome Browsers at xGDBvm</a></li>
                                <li><a href="#genome_accessing">Accessing</a></li>
                            </ul>
                        </li>
                        <li><b>Browse</b>
                            <ul class="bullet1">
                                <li><a href="#genome_home">Genome Home Page</a></li>
                                <li><a href="#genome_navigate_hints">Genome Navigation</a></li>
                                <li><a href="#genome_view">Genome Context View</a></li>
                                <li><a href="#genome_submenu">Genome Submenu</a></li>
                                <li><a href="#genome_records">Genome Records</a></li>
                            </ul>
                        </li>
                       <li><b>Feature Tracks (Genome Context View)</b>
                            <ul class="bullet1">
                                <li><a href="#genemodel_track_info">Gene Models</a></li>
                                <li><a href="#genome_transcript_track_info">Aligned Transcripts</a></li>
                                <li><a href="#genome_protein_track_info">Aligned Proteins</a></li>
                                <li><a href="#yrgate_track_info">yrGATE Annotations</a></li>
                            </ul>
                        </li>
                        <li><b>Feature Tracks (Tabular Views)</b>
                            <ul class="bullet1">
                                <li><a href="#tracks_loci">Gene Models Table</a></li>
                                <li><a href="#tracks_proteins">Aligned Proteins Table</a></li>
                                <li><a href="#tracks_transcripts">Aligned Transcripts Table</a></li>
                                <li><a href="#gaeval_table">GAEVAL Table</a></li>
                                <li><a href="#comm_central">yrGATE Annotations (Community Central)</a></li>
                            </ul>
                        </li>
                        <li><b>Search/Retrieve</b>
                            <ul class="bullet1">
                                <li><a href="#genome_quicksearch">Quick Search</a></li>
                                <li><a href="#genome_advancedsearch">By ID/Keyword</a></li>
                                <li><a href="#genome_region_search">By Region</a></li>
                            </ul>
                        </li>
                        <li><b>Alignment Tools</b>
                            <ul class="bullet1">
                                <li><a href="#genome_blastgdb">Blast GDB</a></li>
                                <li><a href="#genome_blastallgdb">Blast All GDB</a></li>
                                <li><a href="#genome_gth">GenomeThreader</a></li>
                            </ul>
                        </li>
                         <li><b>Other Resources</b>
                            <ul class="bullet1">
                                <li><a href="#genome_download_data">Download Data page</a></li>
                            </ul>
                        </li>
                        <li><b>Annotate</b>
                            <ul class="bullet1">
                                <li><a href="#genome_cpgat">CpGAT</a></li>
                                <li><a href="#genome_yrgate">yrGATE</a></li>
                            </ul>
                        </li>
                        <li><b>Customizing</b>
                            <ul class="bullet1">
                                <li><a href="#genome_limit_access">Limiting/Allowing User Access</a></li>
                                <li><a href="#genome_view_default">Set Default Region</a></li>
                                <li><a href="#genome_yrgate_admin">yrGATE Administrator</a></li>
                            </ul>
                        </li>
                        </ul>
                    
                    
                    <!--Content based on includes-->
                    </div>
                    <div class="helpsection">
                        <h2 class="help">Overview</h2>
                            <div class="feature" id="genome_overview">
                                <?php include('/xGDBvm/XGDB/help/includes/genome_overview.inc.php'); ?>
                                <a class="smallerfont indent2" href="#heading">[top]</a>
                            </div>
                            <div class="feature" id="genome_accessing">
                                <?php include('/xGDBvm/XGDB/help/includes/genome_accessing.inc.php'); ?>
                                <a class="smallerfont indent2" href="#heading">[top]</a>
                            </div>
                    </div>
                    <div class="helpsection">
                        <h2 class="help">Browse</h2>
                            <div class="feature" id="genome_home">
                                <?php include('/xGDBvm/XGDB/help/includes/genome_home.inc.php'); ?>
                                <a class="smallerfont indent2" href="#heading">[top]</a>
                            </div>
                            <div class="feature" id="genome_navigate_hints">
                                <?php include('/xGDBvm/XGDB/help/includes/genome_navigate_hints.inc.php'); ?>
                                <a class="smallerfont indent2" href="#heading">[top]</a>
                            </div>
                            <div class="feature" id="genome_view">
                                <?php include('/xGDBvm/XGDB/help/includes/genome_view.inc.php'); ?>
                                <a class="smallerfont indent2" href="#heading">[top]</a>
                            </div>
                            <div class="feature" id="genome_submenu">
                                <?php include('/xGDBvm/XGDB/help/includes/genome_submenu.inc.php'); ?>
                                <a class="smallerfont indent2" href="#heading">[top]</a>
                            </div>
                    </div>
                    <div class="helpsection">
                        <h2 class="help">Feature Tracks (Genome Context View)</h2>
            
                        <div class="feature" id="genemodel_track_info">
                            <?php include('/xGDBvm/XGDB/help/includes/genemodel_track_info.inc.php'); ?>
                            <a class="smallerfont indent2" href="#heading">[top]</a>
                        </div>
                        <div class="feature" id="genome_protein_track_info">
                            <?php include('/xGDBvm/XGDB/help/includes/genome_protein_track_info.inc.php'); ?>
                            <a class="smallerfont indent2" href="#heading">[top]</a>
                        </div>
                        <div class="feature" id="genome_transcript_track_info">
                            <?php include('/xGDBvm/XGDB/help/includes/genome_transcript_track_info.inc.php'); ?>
                            <a class="smallerfont indent2" href="#heading">[top]</a>
                        </div>
                         <div class="feature" id="yrgate_track_info">
                            <?php include('/xGDBvm/XGDB/help/includes/yrgate_track_info.inc.php'); ?>
                            <a class="smallerfont indent2" href="#heading">[top]</a>
                        </div>
                    </div>
                    <div class="helpsection">
                        <h2 class="help">Feature Tracks (Tabular Views)</h2>
            
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
                        <div class="feature" id="comm_central">
                            <?php include('/xGDBvm/XGDB/help/includes/comm_central.inc.php'); ?>
                            <a class="smallerfont indent2" href="#heading">[top]</a>
                        </div>
                        <div class="feature" id="gaeval_table">
                            <?php include('/xGDBvm/XGDB/help/includes/gaeval_table.inc.php'); ?>
                            <a class="smallerfont indent2" href="#heading">[top]</a>
                        </div>
                    </div>
                    <div class="helpsection">
                        <h2 class="help">Search/Retrieve</h2>
                            <div class="feature" id="genome_quicksearch">
                                <?php include('/xGDBvm/XGDB/help/includes/genome_quicksearch.inc.php'); ?>
                            <a class="smallerfont indent2" href="#heading">[top]</a>
                            </div>
                            <div class="feature" id="genome_advancedsearch">
                            <?php include('/xGDBvm/XGDB/help/includes/genome_advancedsearch.inc.php'); ?>
                                <a class="smallerfont indent2" href="#heading">[top]</a>
                            </div>
                            <div class="feature" id="genome_region_search">
                            <?php include('/xGDBvm/XGDB/help/includes/genome_region_search.inc.php'); ?>
                                <a class="smallerfont indent2" href="#heading">[top]</a>
                            </div>
                    </div>
                    <div class="helpsection">
                        <h2 class="help">Alignment Tools</h2>
                    
                        <div class="feature" id="genome_blastgdb">
                            <p>TBD</p>									<a class="smallerfont indent2" href="#heading">[top]</a>
                    
                        </div>
                        <div class="feature" id="genome_blastallgdb">
                            <p>TBD</p>									<a class="smallerfont indent2" href="#heading">[top]</a>
                    
                        </div>
                            <div class="feature" id="genome_gth">
                            <p>TBD</p>							<a class="smallerfont indent2" href="#heading">[top]</a>
                        </div>
                        <div class="feature" id="genome_download">
                            <p>TBD</p>							<a class="smallerfont indent2" href="#heading">[top]</a>
                        </div>
                    </div>
                    <div class="helpsection">
                        <h2 class="help">Other Resources</h2>
                        <div class="feature" id="genome_download_data">
                            <?php include('/xGDBvm/XGDB/help/includes/genome_download_data.inc.php'); ?>
                            <a class="smallerfont indent2" href="#heading">[top]</a>
                        </div>
                    </div>
                    <div class="helpsection">
                        <h2 class="help">Alignment Tools</h2>
                        <div class="feature" id="genome_cpgat">
                            <p>TBD</p>
                            <a class="smallerfont indent2" href="#heading">[top]</a>
                        </div>
                        <div class="feature" id="genome_yrgate">
                            <p>TBD</p>
                            <a class="smallerfont indent2" href="#heading">[top]</a>
                        </div>
                    </div>
                    <div class="helpsection">
                        <h2 class="help">Customizing</h2>
                        <div class="feature" id="genome_limit_access">
                            <p>TBD</p>							<a class="smallerfont indent2" href="#heading">[top]</a>
                        </div>
                        <div class="feature" id="genome_view_default">
                            <?php include('/xGDBvm/XGDB/help/includes/genome_view_default.inc.php'); ?>
                                <a class="smallerfont indent2" href="#heading">[top]</a>
                        </div>
                            <div class="feature" id="genome_yrgate_admin">
                            <p>TBD</p>							<a class="smallerfont indent2" href="#heading">[top]</a>
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
