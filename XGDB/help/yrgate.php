<?php
	$PageTitle = 'xGDBvm - Virtual Genome Environment';
	$pgdbmenu = 'Help';
	$submenu= 'yrGATEhelp';
	$leftmenu = 'yrGATEhelp';
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
                    
                        <h1 id="heading" class="help_style bottommargin2" ><img alt="" src="/XGDB/images/circle_help.png" />
                            &nbsp;Using yrGATE<span class="heading"> &nbsp;Annotation tool for xGDBvm</span>  &nbsp; &nbsp;<a title='Annotating gene structure using yrGATE' class='xgdb_button smallerfont color2 flvideo-button' id='7858561'>See a Video Demo</a>
                            <a title="Annotating gene structure using yrGATE" class="video-button qtvideo" id="test1">View Quicktime Video</a>
                        </h1>
                                <div class="helpsection">
                                <p>The <a href="/admin/">yrGATE</a> tool is a comprehensive community annotation plaform implemented on xGDBvm. Registered users can correct or verify existing gene models which are then curated and published to the genome browser. All curated annotations are viewable using left menu links to <i>Community Central</i>, which also contains resources for annotators and curators (see <a class="help_style" href="/XGDB/help/community_central.php">Community Central</a> help for details). The information below will help get you started in annotation, but be sure also to check out the <a class="help_style" href="/XGDB/help/video_tutorials.php">Video Tutorials</a> section.</p>
                                
                                </div>
                            <div class="helpsection" id="contents">
                                <h2 class="help">Contents</h2>
                                <!--Contents-->					
                                <ul class="contentslist">
                                    <li><b>Overview</b>
                                        <ul class="bullet1">
                                            <li><a href="#yrgate_newbie_help">For the Newbie</a></li>
                                            <li><a href="#yrgate_tool_help">yrGATE tool</a></li>
                                            <li><a href="#yrgate_annotation_mistakes">Common Annotation Mistakes</a></li>
                                        </ul>
                                    </li>
                                    <li><b>Viewing yrGATE Annotations</b>
                                        <ul class="bullet1">
                                            <li><a href="#yrgate_track_info">yrGATE Track</a></li>
                                        </ul>
                                    </li>
                                    <li><b>Annotator Account</b>
                                        <ul class="bullet1">
                                            <li><a href="#yrgate_registration_help">Registration</a></li>
                                            <li><a href="#yrgate_anno_account">Annotation Account</a></li>
                                            <li><a href="#yrgate_admin_anno">Administrate Annotations</a></li>
                                        </ul>
                                    </li>
                                    <li><b>yrGATE Tool - Sections</b>
                                        <ul class="bullet1">
                                            <li><a href="#yrgate_eplot_help">Evidence Plot</a></li>
                                            <li><a href="#yrgate_eplot_yourstructure">Your Structure</a></li>
                                            <li><a href="#yrgate_eplot_integrity">GAEVAL Score</a></li>
                                            <li><a href="#yrgate_etable_help">Evidence Table</a></li>
                                            <li><a href="#yrgate_orf_finder">ORF Finder</a></li>
                                        </ul>
                                    </li>
                                    <li><b>Curating yrGATE annotations</b>
                                        <ul class="bullet1">
                                            <li><a href="#yrgate_curation">Curation Process</a></li>
                                        </ul>
                                    </li>
                                </ul>
                            </div>
                            <div class="helpsection">
                                    <h2 class="help">Overview</h2>
                                    <div class="feature" id="yrgate_newbie_help">
                                        <?php include('/xGDBvm/XGDB/help/includes/yrgate_newbie_help.inc.php'); ?>
                                                <a class="smallerfont indent2" href="#heading">[top]</a>
                                    </div>
                                    <div class="feature" id="yrgate_tool_help">
                                        <?php include('/xGDBvm/XGDB/help/includes/yrgate_tool_help.inc.php'); ?>
                                                <a class="smallerfont indent2" href="#heading">[top]</a>
                                    </div>
                                    <div class="feature" id="yrgate_annotation_mistakes">
                                        <?php include('/xGDBvm/XGDB/help/includes/yrgate_annotation_mistakes.inc.php'); ?>
                                                <a class="smallerfont indent2" href="#heading">[top]</a>
                                    </div>
                            </div>
                            <div class="helpsection">
                                <h2 class="help">Viewing yrGATE Annotations</h2>
                                    <div class="feature" id="yrgate_track_info">
                                        <?php include('/xGDBvm/XGDB/help/includes/yrgate_track_info.inc.php'); ?>
                                                <a class="smallerfont indent2" href="#heading">[top]</a>
                                    </div>
                            </div>
                            <div class="helpsection">
                                <h2 class="help">Annotator Account</h2>
                                    <div class="feature" id="yrgate_registration_help">
                                        <?php include('/xGDBvm/XGDB/help/includes/yrgate_registration_help.inc.php'); ?>
                                                <a class="smallerfont indent2" href="#heading">[top]</a>
                                    </div>
                                    <div class="feature" id="yrgate_anno_account">
                                        <?php include('/xGDBvm/XGDB/help/includes/yrgate_anno_account.inc.php'); ?>
                                                <a class="smallerfont indent2" href="#heading">[top]</a>
                                    </div>
                                    <div class="feature" id="yrgate_admin_anno">
                                        <?php include('/xGDBvm/XGDB/help/includes/yrgate_admin_anno.inc.php'); ?>
                                                <a class="smallerfont indent2" href="#heading">[top]</a>
                                    </div>
                                        
                            </div>
                            <div class="helpsection">
                                <h2 class="help">yrGATE Tool - Sections</h2>
                                <div class="feature" id="yrgate_eplot_help">
                                    <?php include('/xGDBvm/XGDB/help/includes/yrgate_eplot_help.inc.php'); ?>
                                            <a class="smallerfont indent2" href="#heading">[top]</a>
                                </div>
                                <div class="feature" id="yrgate_eplot_yourstructure">
                                    <?php include('/xGDBvm/XGDB/help/includes/yrgate_eplot_yourstructure.inc.php'); ?>
                                            <a class="smallerfont indent2" href="#heading">[top]</a>
                                </div>
                                <div class="feature" id="yrgate_eplot_integrity">
                                    <?php include('/xGDBvm/XGDB/help/includes/yrgate_eplot_integrity.inc.php'); ?>
                                            <a class="smallerfont indent2" href="#heading">[top]</a>
                                </div>
                                <div class="feature" id="yrgate_etable_help">
                                    <?php include('/xGDBvm/XGDB/help/includes/yrgate_etable_help.inc.php'); ?>
                                            <a class="smallerfont indent2" href="#heading">[top]</a>
                                </div>
                                
                                <div class="feature" id="yrgate_orf_finder">
                                    <?php include('/xGDBvm/XGDB/help/includes/yrgate_orf_finder.inc.php'); ?>
                                            <a class="smallerfont indent2" href="#heading">[top]</a>
                                </div>
                                <div class="feature" id="gene-alias">
                                    <?php include('/xGDBvm/XGDB/help/includes/yrgate_gene-alias_help.inc.php'); ?>
                                            <a class="smallerfont indent2" href="#heading">[top]</a>
                                </div>
                                <div class="feature" id="project">
                                    <?php include('/xGDBvm/XGDB/help/includes/yrgate_project_inc.php'); ?>
                                            <a class="smallerfont indent2" href="#heading">[top]</a>
                                </div>
                    
                                <div class="feature" id="description">
                                    <?php include('/xGDBvm/XGDB/help/includes/yrgate_description.inc.php'); ?>
                                            <a class="smallerfont indent2" href="#heading">[top]</a>
                                </div>
                                <div class="feature" id="genome-edit">
                                    <?php include('/xGDBvm/XGDB/help/includes/yrgate_genome-edits.inc.php'); ?>
                                            <a class="smallerfont indent2" href="#heading">[top]</a>
                                </div>
                                <div class="feature" id="yrgate_id">
                                    <?php include('/xGDBvm/XGDB/help/includes/yrgate_anno-id.inc.php'); ?>
                                            <a class="smallerfont indent2" href="#heading">[top]</a>
                                </div>
                                <div class="feature" id="interpro">
                                    <?php include('/xGDBvm/XGDB/help/includes/yrgate_interproscan_help.inc.php'); ?>
                                            <a class="smallerfont indent2" href="#heading">[top]</a>
                                </div>
                                <div class="feature" id="locus_id">
                                    <?php include('/xGDBvm/XGDB/help/includes/yrgate_locus-id_help.inc.php'); ?>
                                            <a class="smallerfont indent2" href="#heading">[top]</a>
                                </div>
                                <div class="feature" id="manual">
                                    <?php include('/xGDBvm/XGDB/help/includes/yrgate_manual-entry_help.inc.php'); ?>
                                            <a class="smallerfont indent2" href="#heading">[top]</a>
                                </div>
                                <div class="feature" id="new_locus">
                                    <?php include('/xGDBvm/XGDB/help/includes/yrgate_new-locusID_help.inc.php'); ?>
                                            <a class="smallerfont indent2" href="#heading">[top]</a>
                                </div>
                                <div class="feature" id="portal">
                                    <?php include('/xGDBvm/XGDB/help/includes/yrgate_portal_help.inc.php'); ?>
                                            <a class="smallerfont indent2" href="#heading">[top]</a>
                                </div>
                                <div class="feature" id="protein">
                                    <?php include('/xGDBvm/XGDB/help/includes/yrgate_protein_help.inc.php'); ?>
                                            <a class="smallerfont indent2" href="#heading">[top]</a>
                                </div>
                                <div class="feature" id="protein_alias">
                                    <?php include('/xGDBvm/XGDB/help/includes/yrgate_protein-alias_help.inc.php'); ?>
                                            <a class="smallerfont indent2" href="#heading">[top]</a>
                                </div>
                    
                    
                                <div class="feature" id="transcript_id">
                                    <?php include('/xGDBvm/XGDB/help/includes/yrgate_transcript-id_help.inc.php'); ?>
                                            <a class="smallerfont indent2" href="#heading">[top]</a>
                                </div>
                                <div class="feature" id="version_filter">
                                    <?php include('/xGDBvm/XGDB/help/includes/yrgate_version-filter_help.inc.php'); ?>
                                            <a class="smallerfont indent2" href="#heading">[top]</a>
                                </div>
							</div><!-- end helpsection-->
						</div><!--end maincontents-->
					</div><!--end maincontentscontainer-->
			<?php include('/xGDBvm/XGDB/phplib/footer.php'); ?>
		</div><!--end pagewidth-->
	</div><!--end innercontainer-->
</div><!--end outercontainer-->
</body>
</html>
