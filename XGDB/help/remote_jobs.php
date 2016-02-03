<?php
	$PageTitle = 'Remote Jobs - Help';
	$pgdbmenu = 'Help';
	$submenu1= 'Remote_Jobs';
	$submenu2= 'Remote_Jobs';
	$leftmenu = 'Remote_Jobs';
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
					<h1 id="heading" class="help_style bottommargin2"><img alt="" src="/XGDB/images/circle_help.png" />&nbsp;Remote HPC Jobs</h1>

						<div class="helpsection">
						<p><b>Remote HPC</b> (high performance computing) is an option for running certain xGDBvm-iPlant pipeline processes on a high performance computing cluster such as TACC (Texas Advanced Computing Center). This <b>Help page</b> contains detailed instructions for: configuring remote HPC, preparing data, running standalone or pipeline jobs, and viewing/managing jobs. You can also click <i>'Manage'</i> &rarr; <i>'Remote Jobs'</i> &rarr; <i>'<a href="/XGDB/jobs/index.agave.php">-Getting Started-</a>'</i> and work through the menu pages listed there.</p>
                        </div>

					<div class="helpsection" id="contents">
					<!--Contents-->
					<h2 id="contents_heading" class="help">Overview</h2>
						<ul class="contentslist">
						    <li><b>Requirements</b>
						        <ul class="bullet1">
							        <li><a href="#jobs_overview">Overview/Requirements</a></li>
						        </ul>
						    </li>
						<li><b>HPC Apps available</b>
						<ul class="bullet1">
							<li><a href="#jobs_geneseqer">GeneSeqer</a></li>
							<li><a href="#jobs_genomethreader">GenomeThreader</a></li>
						</ul>
						</li>
						<li><b>Prepare for Remote Jobs</b>
						<ul class="bullet1">
							<li><a href="#jobs_gdb_configure">Create a GDB Configuration</a></li>
							<li><a href="#jobs_configure_defaults">Configure API</a></li>
							<li><a href="#jobs_configure_apps">Configure Apps</a></li>
							<li><a href="#jobs_auth_keys">Authentication Keys</a></li>
							<li><a href="#jobs_authenticate">Login</a></li>
							<li><a href="#jobs_refresh_token">Refresh token</a></li>
							<li><a href="#gth_license">GenomeThreader License</a></li>
						</ul>
						</li>
						<li><b>Submit Remote Jobs</b>
						<ul class="bullet1">
							<li><a href="#jobs_standalone">Standalone </a></li>
							<li><a href="#jobs_pipeline">Pipeline-associated</a></li>
						</ul>
						</li>
						<li><b>Manage Jobs</b>
						<ul class="bullet1">
							<li><a href="#jobs_job_id">The Job ID </a></li>
							<li><a href="#jobs_viewall">List all Jobs </a></li>
							<li><a href="#jobs_status_check">Check Job Status </a></li>
							<li><a href="#jobs_job_actions">Job Actions (Table) </a></li>
							<li><a href="#jobs_delete">Delete (Stop) Jobs </a></li>
						</ul>
						</li>
						<li><b>Job Status- troubleshooting</b>
						<ul class="bullet1">
							<li><a href="#jobs_status_overview">Overview</a></li>
							<li><a href="#jobs_status_pending">PENDING</a></li>
							<li><a href="#jobs_status_queued">QUEUED </a></li>
							<li><a href="#jobs_status_staged">STAGED</a></li>
							<li><a href="#jobs_status_processing_inputs">PROCESSING_INPUTS</a></li>
							<li><a href="#jobs_status_no_output">No_output</a></li>
							<li><a href="#jobs_status_archiving_finished">ARCHIVING_FINISHED</a></li>
							<li><a href="#jobs_status_finished">FINISHED</a></li>
						</ul>
						</li>
						</ul>
					</div> <!-- End Contents -->
					<hr class="featuredivider" />
					
<!-- Help section includes (main setion) -->	

					<div class="helpsection" id="overview">
						<h2 id="requirements" class="help">Overview / Requirements</h2>
						<div class="feature" id="jobs_overview">
							<?php include('/xGDBvm/XGDB/help/includes/jobs_overview.inc.php'); ?>
							<a class="smallerfont indent2" href="#heading">[top]</a>
						</div>
					</div>
					<div class="helpsection" id="overview">
						<h2 id="requirements" class="help">Apps available for HPC</h2>
						<div class="feature" id="jobs_geneseqer">
							<?php include('/xGDBvm/XGDB/help/includes/jobs_geneseqer.inc.php'); ?>
							<a class="smallerfont indent2" href="#heading">[top]</a>
						</div>
						<div class="feature" id="jobs_genomethreader">
							<?php include('/xGDBvm/XGDB/help/includes/jobs_genomethreader.inc.php'); ?>
							<a class="smallerfont indent2" href="#heading">[top]</a>
						</div>
					</div>
					<div class="helpsection" id="prepare">
				        <h2 id="configure" class="help">Prepare for Remote Jobs</h2>
						<div class="feature" id="jobs_gdb_configure">
							<?php include('/xGDBvm/XGDB/help/includes/jobs_gdb_configure.inc.php'); ?>
							<a class="smallerfont indent2" href="#heading">[top]</a>
						</div>
						<div class="feature" id="jobs_configure_defaults">
							<?php include('/xGDBvm/XGDB/help/includes/jobs_configure_defaults.inc.php'); ?>
							<a class="smallerfont indent2" href="#heading">[top]</a>
						</div>
						<div class="feature" id="jobs_configure_apps">
							<?php include('/xGDBvm/XGDB/help/includes/jobs_configure_apps.inc.php'); ?>
							<a class="smallerfont indent2" href="#heading">[top]</a>
						</div>
						<div class="feature" id="jobs_auth_keys">
							<?php include('/xGDBvm/XGDB/help/includes/jobs_auth_keys.inc.php'); ?>
							<a class="smallerfont indent2" href="#heading">[top]</a>
						</div>
						<div class="feature" id="jobs_authenticate">
							<?php include('/xGDBvm/XGDB/help/includes/jobs_authenticate.inc.php'); ?>
							<a class="smallerfont indent2" href="#heading">[top]</a>
						</div>
						<div class="feature" id="jobs_refresh_token">
							<?php include('/xGDBvm/XGDB/help/includes/jobs_refresh_token.inc.php'); ?>
							<a class="smallerfont indent2" href="#heading">[top]</a>
						</div>
						<div class="feature" id="gth_license">
							<?php include('/xGDBvm/XGDB/help/includes/jobs_gth_license.inc.php'); ?>
							<a class="smallerfont indent2" href="#heading">[top]</a>
						</div>
					</div>
					<div class="helpsection" id="standalone">
				        <h2 id="submit" class="help">Submit Remote Jobs</h2>
						<div class="feature" id="jobs_standalone">
							<?php include('/xGDBvm/XGDB/help/includes/jobs_standalone.inc.php'); ?>
							<a class="smallerfont indent2" href="#heading">[top]</a>
						</div>
						<div class="feature" id="jobs_pipeline">
							<?php include('/xGDBvm/XGDB/help/includes/jobs_pipeline.inc.php'); ?>
							<a class="smallerfont indent2" href="#heading">[top]</a>
						</div>
					</div>
					<div class="helpsection" id="manage">
				        <h2 id="manage_remote" class="help">Manage Remote Jobs</h2>
						<div class="feature" id="jobs_job_id">
							<?php include('/xGDBvm/XGDB/help/includes/jobs_job_id.inc.php'); ?>
							<a class="smallerfont indent2" href="#heading">[top]</a>
						</div>
						<div class="feature" id="jobs_viewall">
							<?php include('/xGDBvm/XGDB/help/includes/jobs_viewall.inc.php'); ?>
							<a class="smallerfont indent2" href="#heading">[top]</a>
						</div>
						<div class="feature" id="jobs_status_check">
							<?php include('/xGDBvm/XGDB/help/includes/jobs_status_check.inc.php'); ?>
							<a class="smallerfont indent2" href="#heading">[top]</a>
						</div>
						<div class="feature" id="jobs_job_actions">
							<?php include('/xGDBvm/XGDB/help/includes/jobs_job_actions.inc.php'); ?>
							<a class="smallerfont indent2" href="#heading">[top]</a>
						</div>
						<div class="feature" id="jobs_delete">
							<?php include('/xGDBvm/XGDB/help/includes/jobs_delete.inc.php'); ?>
							<a class="smallerfont indent2" href="#heading">[top]</a>
						</div>
					</div>
					<div class="helpsection" id="status">
				        <h2 id="status_troubleshoot" class="help">Job Status - troubleshooting</h2>
						<div class="feature" id="jobs_status_overview">
							<?php include('/xGDBvm/XGDB/help/includes/jobs_status_overview.inc.php'); ?>
							<a class="smallerfont indent2" href="#heading">[top]</a>
						</div>
						<div class="feature" id="jobs_status_pending">
							<?php include('/xGDBvm/XGDB/help/includes/jobs_status_pending.inc.php'); ?>
							<a class="smallerfont indent2" href="#heading">[top]</a>
						</div>
						<div class="feature" id="jobs_status_queued">
							<?php include('/xGDBvm/XGDB/help/includes/jobs_status_queued.inc.php'); ?>
							<a class="smallerfont indent2" href="#heading">[top]</a>
						</div>
						<div class="feature" id="jobs_status_processing_inputs">
							<?php include('/xGDBvm/XGDB/help/includes/jobs_status_processing_inputs.inc.php'); ?>
							<a class="smallerfont indent2" href="#heading">[top]</a>
						</div>
						<div class="feature" id="jobs_status_staged">
							<?php include('/xGDBvm/XGDB/help/includes/jobs_status_staged.inc.php'); ?>
							<a class="smallerfont indent2" href="#heading">[top]</a>
						</div>
						<div class="feature" id="jobs_status_no_output">
							<?php include('/xGDBvm/XGDB/help/includes/jobs_status_no_output.inc.php'); ?>
							<a class="smallerfont indent2" href="#heading">[top]</a>
						</div>
						<div class="feature" id="jobs_status_archiving_finished">
							<?php include('/xGDBvm/XGDB/help/includes/jobs_status_archiving_finished.inc.php'); ?>
							<a class="smallerfont indent2" href="#heading">[top]</a>
						</div>
						<div class="feature" id="jobs_status_finished">
							<?php include('/xGDBvm/XGDB/help/includes/jobs_status_finished.inc.php'); ?>
							<a class="smallerfont indent2" href="#heading">[top]</a>
						</div>
					</div>
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
