<?php
session_start();

	$PageTitle = 'Troubleshooting';
	$pgdbmenu = 'Help';
	$submenu= 'CreateManage';
	$leftmenu = 'Troubleshoot';
	include '/xGDBvm/XGDB/phplib/sitedef.php';
	include('/xGDBvm/XGDB/phplib/header.php');
?>
		<div id="leftcolumncontainer">
			<div class="minicolumnleft">
				<?php include_once("/xGDBvm/XGDB/conf/leftmenu.inc.php"); ?>
			</div>
		</div>
			<div id="maincontentscontainer" class="threecolumn">
				<div id="maincontents" class="help">
			
				<h1 id="heading" class="help_style bottommargin1" ><img alt="" src="/XGDB/images/circle_help.png" />
					&nbsp; Troubleshooting Guide<span class="heading">
				</h1>
			
					<div class="helpsection" id="contents">
						<h2 class="help">Contents</h2>
						<!--Contents-->					
						<ul class="contentslist">
							<li><b>Data Volumes</b>
								<ul class="bullet1">
									<li><a href="#trouble_datastore_disconnected">My Data Store is no longer connected</a></li>
								</ul>
							</li>
							<li><b>Licenses</b>

							</li>
							<li><b>Pipeline Process</b>
								<ul class="bullet1">
									<li><a href="#trouble_pipeline_error_list">Pipeline Error Log (list)</a></li>
								</ul>
							</li>
						</ul>
					</div>
					<div class="helpsection">
							<h2 class="help">Data Volumes</h2>
							<div class="feature" id="trouble_datastore_disconnected">
								<?php include('/xGDBvm/XGDB/help/includes/trouble_datastore_disconnected.inc.php'); ?>
										<a class="smallerfont indent2" href="#heading">[top]</a>
							</div>
					</div>
					<div class="helpsection">
						<h2 class="help">Licenses</h2>
							
					</div>
					<div class="helpsection">
						<h2 class="help">Pipeline</h2>
							<div class="feature" id="trouble_pipeline_error_list">
								<?php include('/xGDBvm/XGDB/help/includes/trouble_pipeline_error_list.inc.php'); ?>
										<a class="smallerfont indent2" href="#heading">[top]</a>
							</div>								
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
