<?php
// Note: this file breaks when viewed standalone, because variables from /phplib/sitedef.php and /XxGDB/conf/SITEDEF.php are not loaded.
?>

<div class="dialogcontainer">

	<h1><span class="species"><?php echo $LATINORGN; ?></span> Genome:<span class="heading"> &nbsp;&nbsp;&nbsp; See also <a title="Help &amp; Tutorials" href="/help/#genomebrowsers">Help &amp; Tutorials</a> including video demos</span></h1>

	<hr class="featuredivider" />
		<ul class="bullet1 topmargin1">
			<li><b>To browse <?php echo $SITENAMEshort; ?>, </b>
				<ul>
					<li>select a Chromosome # and Start/End coordinates above and click "Go".</li>
					<li>Or click <a title="Genome Context View for Region" href="/<?php echo $SITENAMEshort; ?>/cgi-bin/getRegion.pl?dbid=0&amp;chr=<?php echo $DBver[max(array_keys($DBver))][defaultChr]; ?>&amp;bac_lpos=<?php echo $DBver[0][defaultL_pos]; ?>&amp;bac_rpos=<?php echo $DBver[max(array_keys($DBver))][defaultR_pos]; ?>">View a sample region...</a>.
					</li>
				</ul>
			</li>
			<li><b>To search,</b>
				<ul>
					<li>enter an ID in the Search box and choose "Genome" (loads a context view) or "Records" (loads a sequence record).</li>
					<li>For multiple ID search, keyword search, and to download upstream/downstream or intron only sequences, click <a title="Advanced Search Tool" href="/<?php echo $SITENAMEshort; ?>/cgi-bin/search.pl"> Search ID/Keyword</a> on left sidebar</li>
					<li>To download all sequence from a genomic region, click <a title="Download from Region" href="/<?php echo $SITENAMEshort; ?>/cgi-bin/downloadGDB.pl">Download from Region"</a></li>
					<li>To download ALL data used to create <?php echo $SITENAMEshort; ?>, click <a href="<?php echo $Xx; ?>/XGDB/phplib/download.php?GDB=Zm">Download All</a>.</li>
				</ul>
			</li>
			<li><b>To access tools,</b>
				<ul>
					<li>Use links in left sidebar to access other resources and tools for analyzing the <span class="species"><?php echo $LATINORGN; ?></span> genome.</li>
					<li>Note that tools can also be accessed from a Genome Context view submenu - in this case they will use the current genome region for analysis. In contrast, the left sidebar tools are "generic" (meaning you have to specify the genome region).</li>
				</ul>
			</li>
			<li><b>To annotate a gene,</b>
				<ul>
					<li>Browse to the region of the gene of interest, and click "Annotate this region"</li>
					<li>A list of Problematic Gene Models (GAEVAL table) is available from the left sidebar.</li>
					<li>For more information on gene annotation, visit Help &amp; Tutorials page or links on this page under "Gene Structure Annotation".</li>
				</ul>
			</li>
			<li><b>To view/search splice-aligned proteins, </b>
				<ul>
					<li>Select Protein Alignment Table from the left sidbar. This opens a searchable, ordered list with links to multigenome alignment tools.</li>
				</ul>
			</li>
			<li><b>For more information on <?php echo $SITENAMEshort; ?>,</b>
				<ul>
					<li>Check under each topic on the browser home page (click "More about..." to view additional information for each topic)</li>
					<li>For sources and methods for <?php echo $SITENAMEshort; ?>, visit <a href="/XGDB/phplib/resource.php?GDB=<?php echo $GDBprefix; ?>">Data &amp; Methods</a> page.</li>
					<li> For detailed descriptions of all genome browser features, visit the <a title="xGDB Help Pages" href="/help/xgdb.php">Genome Browser Help Pages</a>.</li>
				</ul>
			</li>
			<li>If you have any questions or experience problems using <?php echo $SITENAMEshort; ?>, please use our feedback link at upper right to send us a note. Thanks!</li>
		</ul>
</div>
