<?php
	$PageTitle = 'xGDBvm - Virtual Genome Environment';
	$pgdbmenu = 'Help';
	$submenu1= 'Overview';
	$submenu2= 'Overview';
	$leftmenu = 'Overview';
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
						<h1 id="heading" class="help_style bottommargin2"><img alt="" src="/XGDB/images/circle_help.png" />&nbsp;xGDBvm Overview: Features, Navigation, Troubleshooting</h1>
						<div class="helpsection" id="contents">
						<!--Contents-->
						<h2 id="contents_heading" class="help">Contents</h2>
							<h3 class="topmargin1 bottommargin1 indent1">What is xGDBvm</h3>
							<ul class="bullet1">
								<li><a href="#xgdbvm_scope">Scope and functions</a></li>
								<li><a href="#xgdbvm_vm">Using a virtual maching</a></li>
								<li><a href="#xgdbvm_using">Using xGDBvm</a></li>
							</ul>
							<h3 class="topmargin1 bottommargin1 indent1">Setting Up</h3>
							<ul class="bullet1">
								<li><a href="#xgdbvm_setup">Initial Setup</a></li>
								<li><a href="#xgdbvm_data">Data Preparation</a></li>
							</ul>
							<h3 class="topmargin1 bottommargin1 indent1">Getting around xGDBvm</h3>
							<ul class="bullet1">
								<li><a href="#xgdbvm_menus">Menus and Functions</a></li>
								<li><a href="#xgdbvm_manage">Manage</a></li>
								<li><a href="#xgdbvm_view">View</a></li>
								<li><a href="#xgdbvm_annotate">Annotate</a></li>
							</ul>
						</div> <!-- End Contents -->
						<hr class="featuredivider" />
	<!-- Help section includes (main setion) -->				
						<div class="helpsection" id="overview">
						<h2 id="overview_heading" class="help">What is xGDBvm?</h2>
							<div class="feature" id="xgdbvm_scope">
								<?php include('/xGDBvm/XGDB/help/includes/xgdbvm_scope.inc.php'); ?>
								<a class="smallerfont indent2" href="#heading">[top]</a>
							</div>
							<div class="feature" id="xgdbvm_vm">
								<?php include('/xGDBvm/XGDB/help/includes/xgdbvm_vm.inc.php'); ?>
								<a class="smallerfont indent2" href="#heading">[top]</a>
							</div>
							<div class="feature" id="xgdbvm_using">
								<?php include('/xGDBvm/XGDB/help/includes/xgdbvm_using.inc.php'); ?>
								<a class="smallerfont indent2" href="#heading">[top]</a>
							</div>
						</div>
						<div class="helpsection" id="setup">
					<h2 id="setup_heading" class="help">Setting Up</h2>
							<div class="feature" id="xgdbvm_setup">
								<?php include('/xGDBvm/XGDB/help/includes/xgdbvm_setup.inc.php'); ?>
								<a class="smallerfont indent2" href="#heading">[top]</a>
							</div>
							<div class="feature" id="xgdbvm_data">
								<?php include('/xGDBvm/XGDB/help/includes/xgdbvm_data.inc.php'); ?>
								<a class="smallerfont indent2" href="#heading">[top]</a>
							</div>
						</div>
						<div class="helpsection" id="getting_around">
					<h2 id="getting_around_heading" class="help">Getting Around xGDBvm</h2>
							<div class="feature" id="xgdbvm_menus">
								<?php include('/xGDBvm/XGDB/help/includes/xgdbvm_menus.inc.php'); ?>
								<a class="smallerfont indent2" href="#heading">[top]</a>
							</div>
							<div class="feature" id="xgdbvm_manage">
								<?php include('/xGDBvm/XGDB/help/includes/xgdbvm_manage.inc.php'); ?>
								<a class="smallerfont indent2" href="#heading">[top]</a>
							</div>
							<div class="feature" id="xgdbvm_view">
								<?php include('/xGDBvm/XGDB/help/includes/xgdbvm_view.inc.php'); ?>
								<a class="smallerfont indent2" href="#heading">[top]</a>
							</div>
							<div class="feature" id="xgdbvm_annotate">
								<?php include('/xGDBvm/XGDB/help/includes/xgdbvm_annotate.inc.php'); ?>
								<a class="smallerfont indent2" href="#heading">[top]</a>
							</div>
						</div><!--end helpsection-->
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
