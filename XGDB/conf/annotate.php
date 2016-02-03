<?php
error_reporting(E_ALL & ~E_NOTICE); //disable undeclared variable error
session_start();

	$global_DB= 'Genomes';
	$PageTitle = 'Annotation Guidelines';
	$pgdbmenu = 'Manage';
	$submenu1 = 'Config-Home';
	$submenu2 = 'Config-Annotate';
	$submenu = 'Data';
	$leftmenu='Config-Annotate';
	$warning_msg='';
	include('sitedef.php');
	include($XGDB_HEADER);
include_once(dirname(__FILE__).'/conf_functions.inc.php');
include_once(dirname(__FILE__).'/validate.php');
include_once('/xGDBvm/XGDB/phplib/db.inc.php');
$dbpass=dbpass();
#$ExtraHeadInfo = "
#</script>
#<script language=\"javascript\" type=\"text/javascript\" src=\"/XGDB/javascripts/fillFields.js\">
#</script>
#"; //testing J Duvick 9/3/12


	$db = mysql_connect("localhost", "gdbuser", $dbpass);
	if(!$db)
	{
		echo "Error: Could not connect to database!";
		exit;
	}
	mysql_select_db("$global_DB");
	$error = $_GET['error'];
	
	?>
						<div id="leftcolumncontainer">
							<div class="minicolumnleft">
							<?php include_once("/xGDBvm/XGDB/conf/leftmenu.inc.php"); ?>
							</div>
						</div>
							<div id="maincontentscontainer" class="twocolumn overflow configure">
								<div id="maincontentsfull" class="configure">
									<h1 class="configure darkgrayfont"><img alt="" src="/XGDB/images/configure.png" /> Annotate your Genome <img id='config_annotate_guidelines' title='Here you can learn best way to annotate your genome. Click ? for details.' class='help-button nudge1' src='/XGDB/images/help-icon.png' alt='?' /></h1>
							<div class="feature">									
<h2 class="bottommargin1 topmargin2">Genome Annotation Methods</h2>
                                <div class="featurediv">
									<p>xGDBvm can predict gene structures for any genome or genome region, using the <a href="/XGDB/help/cpgat.php">CpGAT</a> tool. CpGAT combines spliced alignment evidence with <i>ab initio</i> gene models to create a set of <b>full length and near-full-length transcripts and splicing isoforms</b>, optionally filtered against a <b>reference protein</b> dataset supplied by the user.</p>
									<p>Other standalone annotation pipelines are publicly available, including <a href="http://www.yandell-lab.org/software/maker.html">Maker</a> and <a href="http://www.yandell-lab.org/software/maker-p.html">Maker-P</a> <i>(see also <a href="http://www.nature.com/nrg/journal/v13/n5/fig_tab/nrg3174_T1.html">this table</a> from Yandell &amp; Ence
Nature Reviews Genetics 13, 329-342 (May 2012))</i>. 
									If you have access and/or expertise in one of these systems, you could take spliced alignment output from xGDBvm as input for the annotation pipeline, and then upload the output (as a GFF3 table) to xGDBvm.
									</p>
									<p>Here, however, we focus on annotation options within xGDBvm.</p>
									<h2 class="topmargin1">Genome annotation with xGDBvm</h2>
									<p>Whole genome annotation can be time consuming, especially as parallel processing is not available at this time for CpGAT. You have two options: </p>
									<ol class="orderedlist1 indent2">
									<li><b>Align first, CpGAT later</b>: 
										<ul class="bullet1 indent2">
											<li>Run the xGDBvm pipeline to generate protein and/or transcript <b>spliced alignments</b> without CpGAT (taking advantage of <a href="/XGDB/jobs/resources.php">remote HPC</a> where applicable)</li>
											<li>Then then select one or more regions for annotation via the <b>CpGAT region tool</b> (click the 'Annotate &rarr; CpGAT' button in the Genome Context View submenu).</li>
											<li>You can inspect the GFF3 output and, if desired, click to upload it as a temporary <span class="user_color">User Track</span> track, or alternatively as a full-fledged <span class="cpgat_color">CpGAT track</span> .</li>
										</ul>
										</li>
									<li><b>Align &amp; CpGAT together:</b> 
										<ul class="bullet1 indent2">
											<li>Run the xGDBvm pipeline with the 'Predict Genes? Y' option. CpGAT will be run automatically on each genome segment in turn, after all spliced alignment processing is complete.</li>
											<li>The output will appear on completion as a  <span class="cpgat_color">CpGAT track</span>, with GAEVAL gene quality scores on each.</li>
											<li>Note that for large genomes, CpGAT annotation can take a week or more on a typical VM.</li>
										</ul>
										</li>
									</ol>
									<p class="indent2"><span class="tip_style">The 'Align First' option is preferred as a start, especially if you are uncertain of the gene density and/or the optimal parameters to use. You can experiment in a small region and then expand it as desired.</span></p> 
									<p class="indent2"><span class="tip_style">You may want to use the 'Align &amp; CpGAT' option if you know what to expect in terms of quality and duration of analysis for your genome.</span></p>
									<p>Both options require some careful consideration of your requirements for stringency, use of reference protein datasets, as well as for repeat masking. See below for details:</p> 
									<h2 class="topmargin1">Factors to consider:</h2>
								<ol class="orderedlist1 indent2">
									<li>First consider </li>
										<ul class="bullet1 indent2">
											<li><b>Example 1</b>: 
											</li>
											<li><b>Example 2</b>:
											</li>
										</ul>
									<li>Based on this analysis, </li>
										<ul class="bullet1 indent2">
											<li>.test
											</li>
											<li>test
											</li>
										</ul>
									<li>Next consider 
										<ul class="bullet1 indent2">
											<li>If you know about 
											</li>
											<li>For untested genomes y
											</li>
										</ul>
									</li>
									<li>The number (density) of potential alignments is another factor to consider, independent of the genome and query size.
										<ul class="bullet1 indent2">
											<li>related species.
											</li>
											<li>A genome an
											</li>
										</ul>
									</li>
									<li>Finally, make sure your input file is appropriately <b>repeat masked</b>:
										<ul class="bullet1 indent2">
											<li>For.
											</li>
											<li>For 
											</li>
										</ul>
									</li>
								</ol>


										<hr />
<h2 class="bottommargin1 topmargin2">Guidelines for Reference Protein Datasets</h2>
													<p class="indent1"> <span class="tip_style">&nbsp;The xGDBvm wiki outlines a strategy for<a href="http://goblinx.soic.indiana.edu/wiki/doku.php?id=uniref"> retrieving a taxonomically relevant dataset from UniProt</a></p>
													<p class="indent1"> <span class="tip_style">&nbsp;Reference Protein Datasets must be in <b>FASTA</b> format and free of duplicate IDs. Avoid <b>special characters</b> in ID or description.</span></p>
													<p class="indent1"> <span class="tip_style">&nbsp; It is best to deposit your Reference Protein dataset in its own directory on your Data Store. You will need to enter its complete path in your GDB configuration, e.g.:</p>

													<ul class="bullet1 indent2">
													    <li><span class="plaintext">/xGDBvm/data/path/my_referenceprotein.fasta</span></li> 
													</ul>
	
								</div>
							</div>
							<div class="feature" id="filenames">
							</div>	
							</div><!--end maincontents-->
						  <div style="clear:both; float:right">
							<a href="http://validator.w3.org/check?uri=referer"><img
							  src="http://www.w3.org/Icons/valid-xhtml10" alt="Valid XHTML 1.0 Transitional" height="15" width="44" /></a>
						  </div>						
						</div><!--end maincontentscontainer-->
						<div id="rightcolumncontainer">
						</div><!--end rightcolumncontainer-->
			<?php include($XGDB_FOOTER); ?>
		</div></div></div>
	</body>
</html>
