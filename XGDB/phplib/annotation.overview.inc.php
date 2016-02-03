
	<h1>Community Annotation - Overview</h1>

	<p>
		<span class="species"><?php echo $LATINORGN; ?></span> gene models can often be improved and expanded by taking into account EST and cDNA evidence-based alignment. <?php echo $SITENAMEshort; ?> facilitates the curation and correction of gene models through <strong>Community Annotation</strong>. Our system consists of the online annotation tool yrGATE (see below left), plus tables showing gene models most in need of improvement (below right).
	</p>

<!--Genomic Segments--><div id="maincontentsleft">

	<div class="feature">
	<h2>Community Annotation Using yrGATE</h2>
	<p>
	The yrGATE (<u>Y</u>our <u>G</u>enome <u>A</u>nnotation <u>T</u>ool for <u>E</u>ukaryotes) is an online tool for inspecting and correcting erroneous gene models, based on evidence alignment data (cDNA, EST, protein). Any registered user can create a Community Annotation account and learn to annotate genes. Visit Annotation Central to view previous users' annotations, or create a new account and start adding your own!
	</p>
	<div class="featurelist_ends top"><span class="tl2"></span><span class="tr2"></span></div><!-- rounded ends-->
	<div class="featurelist">
		<ul>
			<li><a title="Overview of the yrGATE annotation Tool" href="/prj/yrGATE/">yrGATE Overview</a></li>
			<li><a href="<?php echo $ucaPATH; ?>/CommunityCentral.pl" target= "_new" title="Community Annotation Central">Annotation Central</a></li>
			<li><a href="javascript:doRegister('<?php echo $ucaPATH; ?>userRegister.pl');">Create a new account</a></li>
		</ul>
	</div>
	<div class="featurelist_ends bottom"><span class="bl2"></span><span class="br2"></span></div><!-- rounded ends-->
	</div><!--end feature div-->

	<div class="feature">
		<h2>Example of a yrGATE Annotation</h2>
		<br />
			<img alt="annotation example image" src="/images/annotate_example.gif" width="100%">
			<p>
				<a href="<?php echo $CGIPATH; ?>getRegion.pl?dbid=0&amp;chr=2&amp;l_pos=17603963&amp;r_pos=17606215"> <b>UCA-At2g42245:</b></a><br />
				The User Contributed Annotation (green gene structure) to the left shows how a user of AtGDB
				has provided an updated annotation. This annotation explains the inconsistancy of the current
				gene models with the spliced alignment of ESTs and cDNAs in this region.</p>
			</div>
		</div><!--end maincontentsleft-->

<!--Right Column--><div id="maincontentsright">

	<div class="feature">
	<h2>GAEVAL (<u>G</u>enome <u>A</u>nnotation <u>EVAL</u>uation) Tables</h2>
	<br />
	<div class="description showhide">
	The GAEVAL system identifies potentially erroneous gene models, based on conflicts with evidence alignments (cDNAs, EST, proteins). The results are presented in tabular form with links to the yrGATE community annotation tool, so users can rapidly identify genes in need of annotation.  See link below for <?php echo $SITENAMEshort; ?> GAEVAL table.<a title="Show additional sequence information directly below this link" class="label" style="cursor:pointer"> More...</a>
		<div class="more_hidden hidden">
	<p><b>GAEVAL Categories and Totals for <?php echo $SITENAMEshort; ?> (with links to GAEVAL Help Page descriptions)</b></p>
		<table class="featuretable" summary="Problematic gene models by category and links to the appropriate GAEVAL tables">
		<thead>
			<tr class="shade">
				<th scope="col">Type</th>
				<th scope="col">Description</th>
				<th scope="col">Count</th>
			</tr>
		</thead>
		<tbody>
			<tr>
				<td><a title="Help for this item" href="/help/anno.php#AltSplice">Alternative Splicing</a></th>
				<td align="left">Splicing pattern different from the one specified by gene model</td>
				<td align="right"><a title="GAEVAL tables for this Category" href="/XGDB/phplib/GAEVAL.php?list=MWuca_AltS&amp;GDB=At" target="_blank">45,000</a></td>
			</tr>
			<tr>
				<td><a title="Help for this item" href="/help/anno.php#AltTransTerm">Alternative Transcript Termination</a></th>
				<td align="left">Evidence transcripts differ in 3' end</td>
				<td align="right"><a title="GAEVAL tables for this Category" href="/XGDB/phplib/GAEVAL.php?list=MWuca_AltCPS&amp;GDB=At" target="_blank">65,000</a></td>
			</tr>
			<tr>
				<td><a title="Help for this item" href="/help/anno.php#GeneAnnoFission">Gene Fission</a></th>
				<td align="left">Two gene models appear to refer to the same transcript</td>
				<td align="right"><a title="GAEVAL tables for this Category" href="/XGDB/phplib/GAEVAL.php?list=MWuca_Fis&amp;GDB=At" target="_blank">65,000</a></td>
			</tr>
			<tr>
				<td><a title="Help for this item" href="/help/anno.php#GeneAnnoFusion">Gene Fusion</a></th>
				<td align="left">A single gene model appears to refer to two or more distinct transcripts</td>
				<td align="right"><a title="GAEVAL tables for this Category" href="/XGDB/phplib/GAEVAL.php?list=MWuca_Fus&amp;GDB=At" target="_blank">65,000</a></td>
			</tr>
			<tr>
				<td><a title="Help for this item" href="/help/anno.php#GeneAnnoFusion">Erroneous Gene Overlap</a></th>
				<td align="left">Overlap is not supported by transcript evidence</td>
				<td align="right"><a title="GAEVAL tables for this Category" href="/XGDB/phplib/GAEVAL.php?list=MWuca_AmbOlap&amp;GDB=At" target="_blank">65,000</a></td>
			</tr>
		</tbody>
	</table>


	</div><!--end of hidden div-->
	</div><!--end showhide div-->
	<div class="featurelist_ends top"><span class="tl2"></span><span class="tr2"></span></div><!-- rounded ends-->
	<div class="featurelist">
		<ul>
		<li><a href="/XGDB/phplib/GAEVAL.php?GDB=<?php echo $GDBprefix; ?>">GAEVAL@<?php echo $SITENAMEshort ?></a></li>
			<li><a title="GAEVAL Table" href="/XGDB/phplib/GAEVAL.php?GDB=<?php echo $GDBprefix; ?>">Problematic Gene Models</a></li>
			<li><a title="GAEVAL Help Pages" href="/help/anno.php#GAEVAL">GAEVAL Help</a></li>
		</ul>
	</div>
	<div class="featurelist_ends bottom"><span class="bl2"></span><span class="br2"></span></div><!-- rounded ends-->
	</div><!--end feature div-->
	<div class="feature">
	<h2>Tutorials</h2>
	<p>If you are a beginning annotator, check out our tutorials which take you throught the annnotation process step by step. Our Annotation Guide provides comprehensive information about the annotation tools and methodologies at PlantGDB.</p>
	<div class="featurelist_ends top"><span class="tl2"></span><span class="tr2"></span></div><!-- rounded ends-->
	<div class="featurelist">
		<ul>
			<li><a title="Annotation for Amateurs Tutorial" href="/tutorial/annotatemodule/">Annotation Tutorial</a></li>
			<li><a title="A comprehensive guide to annotation at PlantGDB" href="/help/anno.php">Annotation Guide</a></li>
			<li><a title="A tutorial on how to use the GeneSeqer spliced alignment tool" href="/tutorial/GSannotation/">GeneSeqer Tutorial</A></li>
		</ul>
	</div>
	<div class="featurelist_ends bottom"><span class="bl2"></span><span class="br2"></span></div><!-- rounded ends-->
	</div><!--end feature div-->
	
	<div class="feature">
	<h2>Community Annotation resources</h2>
	<p>Other projects related to Community Annotation.</p>
	<div class="featurelist_ends top"><span class="tl2"></span><span class="tr2"></span></div><!-- rounded ends-->
		<div class="featurelist">
		<ul>
			<li><a href="/PGROP/">Internships &amp; Outreach</A></li>
		</ul>
		</div>
	<div class="featurelist_ends bottom"><span class="bl2"></span><span class="br2"></span></div><!-- rounded ends-->
	</div><!-- end feature div-->

	
	</div><!--end feature div-->
</div><!--end maincontentsright-->


<h2 style="clear:both">References</h2>
<ul class="contentslist">
   <li>Wilkerson, M.D., Schlueter, S.D. &amp; Brendel, V. (2006) <strong>yrGATE: a web-based gene-structure annotation tool for the identification and dissemination of eukaryotic genes.</strong> <em>Genome Biol.</em> <strong>7</strong>, R58. [<a href="http://www.ncbi.nlm.nih.gov/entrez/query.fcgi?cmd=Retrieve&amp;db=PubMed&amp;dopt=Citation&amp;list_uids=16859520">PubMed ID: 16859520</a>]
   </li>

   <li>Schlueter, S.D., Wilkerson, M.D., Huala, E., Rhee, S.Y. &amp; Brendel, V. (2005) <strong>Community-based gene structure annotation for the Arabidopsis thaliana genome.</strong> <em>Trends Plant Sci.</em> 10, 9-14. [<a href="http://www.ncbi.nlm.nih.gov/entrez/query.fcgi?cmd=Retrieve&amp;db=PubMed&amp;dopt=Citation&amp;list_uids=15642518">PubMed ID: 15642518</a>]
   </li>
</ul>

