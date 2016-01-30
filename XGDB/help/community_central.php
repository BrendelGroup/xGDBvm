<?php
	$PageTitle = 'Community Central';
	$pgdbmenu = 'Help';
	$submenu1= 'CommCentralhelp';
	$submenu2= 'CommCentralhelp';
	$leftmenu = 'CommCentralhelp';
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
						<h1 id="heading" class="help_style bottommargin2"><img alt="" src="/XGDB/images/circle_help.png" />&nbsp;Using Community Central</i></h1>
						
						<div class="helpsection">
						<p>The <b>Community Central</b> pages display curated annotations for each GDB that were created using the yrGATE tool (see <a class="help_style" href="/XGDB/help/yrgate.php">yrGATE</a>), as well as resources for registered annotators and curators.</p>
						
						</div>

						<div class="helpsection" id="contents">
							<h2 class="help" id="contents_heading">Contents</h2>
											<!--Contents-->	
								<ul class="contentslist">
									<li><b>What is Community Central?</b>
										<ul class="bullet1">
											<li><a href="#comm_central_overview">Overview</a></li>
											<li><a href="#comm_central_my">My Annotations</a></li>
										</ul>
									</li>
									<li><b>Managing Annotations</b>
										<ul class="bullet1">
											<li><a href="#comm_central_using">Using Community Central List</a></li>
											<li><a href="#comm_central_manage">Managing My Annotations</a></li>
											<li><a href="#comm_central_curate">Curated Annotations</a></li>
										</ul>
									</li>
								</ul>
						</div>
						<div class="helpsection">
							<h2 class="help">What is Community Central?</h2>
							<div class="feature"  id="comm_central" >
								<?php include('/xGDBvm/XGDB/help/includes/comm_central.inc.php'); ?>
									<a class="smallerfont indent2" href="#heading">[top]</a>
							</div>
						</div>
						<div class="helpsection">
							<h2 class="help">Using Community Central</h2>
							<div class="feature" id="comm_central_using">
								<?php include('/xGDBvm/XGDB/help/includes/comm_central_using.inc.php'); ?>
									<a class="smallerfont indent2" href="#heading">[top]</a>
							</div>
							<div class="feature" id="comm_central_manage">
								<?php include('/xGDBvm/XGDB/help/includes/comm_central_manage.inc.php'); ?>
									<a class="smallerfont indent2" href="#heading">[top]</a>
							</div>
							<div class="feature"  id="comm_central_curate" >
								<?php include('/xGDBvm/XGDB/help/includes/comm_central_curate.inc.php'); ?>
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
