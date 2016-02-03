<?php
$PageTitle = 'Community Annotation - Overview';
$pgdbmenu = 'Annotation';
$submenu= 'Annotation';
$leftmenu = 'Annotation';
$bckgrnd_class='anno';
include 'sitedef.php';
include($XGDB_HEADER);
?>

        <div id="leftcolumncontainer">
			<div class="minicolumnleft">
				<?php include_once("/xGDBvm/src/yrGATE/leftmenu.inc.php"); ?>
			</div>
		</div>
        <div id="maincontentscontainer" class="threecolumn">
            <div id="maincontents">
                <h1 class="anno">
                   Getting Started: Community Annotation
                </h1>
                <p>
                    xGDBvm facilitates the curation and correction of
                    gene models through <b>Community Annotation</b>
                    tools, available for all <a href="/XGDB/genomes.php">Genome Browsers</a> you create. </p>
                    <p>The system consists of the <a title="Overview of the yrGATE tool" href="/src/yrGATE/overview.php">yrGATE </a> annotation tool for
                    fast editing of gene models, <a class="help_style" href="/XGDB/help/community_central.php">Community Central</a> for managing annotations, and <a class="help_style" href="/XGDB/help/gaeval.php">GAEVAL</a>  tables showing gene models most
                    in need of improvement.
                </p>
                <h2 class="topmargin2">To get started:</h2> 

                <ol class="bullet1">
                <!--li>Optionally, go through the <a title="Annotation for Amateurs Tutorial" href="/tutorial/annotatemodule/">Annotation Tutorial</a> or check out our <a href="/help/anno.php">Help Pages</a>. Or, click to view a brief <b>video tutorial:</b> QuickTime <a title="Annotating gene structure using yrGATE" class="video-button qtvideo" id="yrGATE_MtGDB6"></a>&nbsp;Flash <a title="Annotating gene structure using yrGATE" class='flvideo-button flvideo' id='7858561'></a>&nbsp;</li-->
                    <li>Choose a genome to annotate, and navigate to its home page using the dropdown menus or the <a href="/XGDB/genomes.php">Genome Browser Portal</a>;</li>
                    <li>If you do not have an account, <b>register</b> using the link in upper left of any GDB home page</li>
                    <li>Find a region to annotate in the genome browser, and select "Analysis Tools &rarr; yrGATE" to launch yrGATE;</li>
                    <li>Follow instructions to create a gene model annotation and click "Submit". You will receive a confirmatory email, and the new model will be displayed in your genome browser; </li>
                    <li>You or another administrator will need to curate your annotation for it to be viewed by all users. You will receive a new email upon curation.</li>
                    <li>You can view your submitted, accepted, and rejected annotations for each genome database under Community Central, accessible from the GDB left menu bar.</li>
                    </ol>
				<h2 class="topmargin2">View Annotations - Current GDB <span class="heading"> - click to view annotations or log in to your User account</span></h2>
										<?php asort($xGDB);
						foreach ($xGDB as $keys=>$value){
						echo "<div class=\"big_button\"><a  class=\"xgdb_button colorGreen1\" href=\"/yrGATE/$value/CommunityCentral.pl\">$value &nbsp;&nbsp; Community Central</a></div>";
					}?>
				
                <h2 class="topmargin2">See Also:</h2> 
					<ul class="bullet1">
						<li><a href="/XGDB/help/video_tutorials.php#annotation"><img class='nudge2' src='/XGDB/images/video_blue35px.png' /> Video Tutorials</a> - brief videos covering yrGATE Annotation</li>
						<li><a class="help_style" href="/XGDB/help/yrgate.php">Using yrGATE</a> - How to annotate genes</li>
						<li><a class="help_style" href="/XGDB/help/community_central.php">Using Community Central</a> - Manage your annotations</li>
						<li><a class="help_style" href="/XGDB/help/gaeval.php">Using GAEVAL</a> - Gene quality scores help you spot "problematic" gene models  </li>
					</ul>
                <h1 class="topmargin2 bottommargin2 anno">More Useful Information</h1>

                 <div id="maincontentsleft">
                    <div class="feature">
                        <h2>
                            The yrGATE Annotation Tool
                        </h2>
                        <hr class="featuredivider" />
                        <div class="description showhide">
                            yrGATE (<u>Y</u>our <u>G</u>enome
                            <u>A</u>nnotation <u>T</u>ool for
                            <u>E</u>ukaryotes) is an online tool for
                            inspecting and correcting erroneous gene
                            models, based on evidence alignment data
                            (cDNA, EST, protein). Any registered user
                            can create a Community Annotation account
                            and learn to annotate genes. Visit
                            Annotation Central to view previous
                            users&#39; annotations, or create a new
                            account and start adding your own!
                            <ul class="menulist topmargin1">
                        </div><!--end showhide-->
                    </div><!--end feature div-->
                    <div class="feature">
                        <h2>
                            Example of a yrGATE Annotation
                        </h2>
                        <hr class="featuredivider" />
                        <img alt="annotation example image" src=
                        "/XGDB/images/annotate_example.gif" width="100%" />

						<p><b>UCA-At2g42245:</b></p>
                        <p>
                            The User Contributed Annotation (green gene
                            structure) to the left shows how a user of
                            AtGDB has provided an updated annotation.
                            This annotation explains the inconsistancy
                            of the current gene models with the spliced
                            alignment of ESTs and cDNAs in this region.
                        </p>
                    </div>
                </div><!--end maincontentsleft-->
                <!--Right Column-->
                <div id="maincontentsright">
                    <div class="feature">
                        <h2>
                            Problematic Gene Models (GAEVAL)
                        </h2>
                        <hr class="featuredivider" />
                        <div class="description showhide">
                            <p>The GAEVAL (<u>G</u>enome <u>A</u>nnotation
                            <u>EVAL</u>uation) system identifies
                            potentially erroneous or incomplete gene
                            models based on conflicts with evidence
                            alignments, and presents the results in
                            tabular form. The GAEVAL scripts are automatically run with each new genome, as long as the appropriate data types are present.
                            </p>
                            <p> See <a href="/src/GAEVAL/docs">GAEVAL Documentation</a></p>
                        </div><!--end showhide div-->
                    </div><!-- end feature div-->
                    <div class="feature">
                        <h2>
                            GAEVAL Classes
                        </h2>
                        <hr class="featuredivider" />
<P>                            GAEVAL categories describe the type of
                            incongruity detected: Alternative Splicing,
                            Alternative Transcript Termination, Gene
                            Fission/Fusion, or Erroneous Overlap.

                                </p>
                                    <b>GAEVAL Categories and
                                    Descriptions </b>
                                </p>
                                <table class="featuretable smallerfont striped" summary="Problematic gene models by category and links to the appropriate help pages">
                                <thead>
                                        <tr class="shade">
                                            <th scope="col">
                                                Type
                                            </th>
                                            <th scope="col">
                                                Description
                                            </th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <tr>
                                            <td>
												Alternative Splicing
                                            </td>
                                            <td align="left">
                                                Splicing pattern
                                                different from the one
                                                specified by gene model
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>
												Alternative
                                                Transcript Termination
                                            </td>
                                            <td align="left">
                                                Evidence transcripts
                                                differ in 3&#39; end
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>
													Gene
                                                Fission
                                            </td>
                                            <td align="left">
                                                Two gene models appear
                                                to refer to the same
                                                transcript
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>
												Gene
                                                Fusion
                                            </td>
                                            <td align="left">
                                                A single gene model
                                                appears to refer to two
                                                or more distinct
                                                transcripts
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>
												Erroneous Gene Overlap
                                            </td>
                                            <td align="left">
                                                Overlap is not
                                                supported by transcript
                                                evidence
                                            </td>
                                        </tr>
                                    </tbody>
                                </table>

                    </div><!-- end feature div-->
                    <!--div class="feature">
                        <h2>
                            Annotation Support
                        </h2>
                        <hr class="featuredivider" />
                        <div class="description showhide">
                            If you are a beginning annotator, check out
                            our tutorials which take you throught the
                            annnotation process step by step. Our
                            Annotation Guide provides comprehensive
                            information about the annotation tools and
                            methodologies at PlantGDB.
                            <ul class="bullet1 topmargin1">
                                <li>
                                    <a title="Annotation for Amateurs Tutorial"
                                    href="/tutorial/annotatemodule/">
                                    Annotation Tutorial</a>
                                </li>
                                <li>
                                    <a title="A comprehensive guide to annotation at PlantGDB"
                                    href="/help/anno.php">Annotation
                                    Help Pages</a>
                                </li>
                            </ul>
                        </div>
                    </div--><!--end feature div-->
                    <!--div class="feature">
                        <h2>
                            Community Annotation resources
                        </h2>
                        <hr class="featuredivider" />
                    </div--><!-- end feature div-->
                </div><!--end maincontentsright-->
                <h2 style="clear:both">
                    References
                </h2>
                <ul class="contentslist">
                    <li>Wilkerson, M.D., Schlueter, S.D. &amp; Brendel,
                    V. (2006) <b>yrGATE: a web-based gene-structure
                    annotation tool for the identification and
                    dissemination of eukaryotic genes.</b> <i>Genome
                    Biol.</i> <b>7</b>, R58.
					[ <a href="http://www.ncbi.nlm.nih.gov/entrez/query.fcgi?cmd=Retrieve&amp;db=PubMed&amp;dopt=Citation&amp;list_uids=16859520">PubMed ID: 16859520</a>]</li>
                    
                    <li>Schlueter, S.D., Wilkerson, M.D., Huala, E.,
                    Rhee, S.Y. &amp; Brendel, V. (2005)
                    <b>Community-based gene structure annotation for
                    the Arabidopsis thaliana genome.</b> <i>Trends
                    Plant Sci.</i> 10, 9-14.
					[ <a href="http://www.ncbi.nlm.nih.gov/entrez/query.fcgi?cmd=Retrieve&amp;db=PubMed&amp;dopt=Citation&amp;list_uids=15642518">PubMed ID: 15642518</a>]</li>
                </ul>
            </div><!--end maincontents-->
        </div><!--end maincontentscontainer-->
	<?php include($XGDB_FOOTER); ?>
	</div><!--end pagewidth-->
	</div><!--end innercontainer-->
</div><!--end outercontainer-->
</body>
</html>







