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

	
		<ul class="menulist bottommargin2">
			<li>xGDBvm was developed by the <a href="http://www.brendelgroup.org">Brendel Group</a> with support from the USA National Science Foundation Plant Genome Research Projects grant <a title="view NSF grant page"  href="http://128.150.4.107/awardsearch/showAward.do?AwardNumber=1126267">DBI 1126267</a>.</li>
			<li>The underlying code was adapted from the xGDB platform and tools originally implemented at <a href="http://plantgdb.org">plantgdb.org</a>.</li>
			<li>xGDBvm is written in <a href="https://www.perl.org">Perl</a> and <a href="php.net">PHP</a> and relies on the following Javascript tools and libraries: <a href="http://jquery.com">JQuery</a>,<a href="http://jqueryui.com">JQuery UI</a>, and <a href="http://users.tpg.com.au/j_birch/plugins/superfish/">Superfish by Joel Birch</a></li>
			<li>Some of the icons are from the Silk icon set at <a href="http://www.famfamfam.com/lab/icons/silk/">famfamfam.com</a> </li>
			<li>For more information on xGDBvm configuration, software, and architecture, visit the <a href="http://goblinx.soic.indiana.edu/wiki/doku.php">wiki</a></li>
		</ul>


					</div><!--end maincontentsfull-->
			</div><!--end maincontentscontainer-->
		<?php include($XGDB_FOOTER); ?>
		</div><!--end pagewidth-->
	</div><!--end innercontainer-->
</div><!--end outercontainer-->
</body>
</html>
