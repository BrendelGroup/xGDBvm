<?php
	$PageTitle = 'xGDBvm - Virtual Genome Environment';
	$pgdbmenu = 'Help';
	$submenu1= 'GAEVALhelp';
	$submenu2= 'GAEVALhelp';
	$leftmenu = 'GAEVALhelp';
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
			
				<h1 id="heading" class="help_style bottommargin2"><img alt="" src="/XGDB/images/circle_help.png" />&nbsp;Using GAEVAL</i></h1>
			
				<p>See also <a href="/src/GAEVAL/docs/index.html">GAEVAL Documentation</a> </p>
			
					<!--Contents-->
					<div class="helpsection" id="contents">
					<h2 id="contents_heading" class="help topmargin1 bottommargin1">Contents</h2>
						<ul class="bullet1">
							<li><a href="#gaeval_overview">What is GAEVAL?</a></li>
							<li><a href="#gaeval_table">GAEVAL Analysis of Transcripts</a></li>
							<li><a href="#">(tbd)</a></li>
							<li><a href="#">(tbd)</a></li>
							<li><a href="#">(tbd)</a></li>
						</ul>
					</div>
					<div class="helpsection">
							<h2 class="help">Overview</h2>
						<div class="feature" id="gaeval_overview">		
							<?php include('/xGDBvm/XGDB/help/includes/gaeval_overview.inc.php'); ?>
							<a class="smallerfont indent2" href="#heading">[top]</a>
						</div>
						<div class="feature" id="gaeval_table">
							<?php include('/xGDBvm/XGDB/help/includes/gaeval_table.inc.php'); ?>
							<a class="smallerfont indent2" href="#heading">[top]</a>
						</div>
					</div>
				 </div><!--end maincontents-->
			</div><!--end maincontentscontainer-->
			<?php include('/xGDBvm/XGDB/phplib/footer.php'); ?>
		</div><!--end pagewidth-->
	</div><!--end innercontainer-->
</div><!--end outercontainer-->
</body>
</html>
