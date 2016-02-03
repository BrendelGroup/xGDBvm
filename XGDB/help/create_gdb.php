<?php
session_start();

	$PageTitle = 'Config/Create Help';
	$pgdbmenu = 'Help';
	$submenu1= 'CreateManage';
	$submenu2= 'CreateManage';
	$leftmenu = 'CreateManage';
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
						
							<h1 id="heading" class="help_style bottommargin1">
							<img alt="" src="/XGDB/images/circle_help.png" />&nbsp;Configuring &amp; Creating a Genome Browser

							</h1>

						<div class="helpsection">
						<p>This <b>Help page</b> contains detailed instructions for <b>creating a new GDB (genome data browser)</b> in xGDBvm: preparing data, configuring xGDBvm, running the data pipeline, managing/archiving output.  You can also click <i>Manage &rarr; Config/Create &rarr; <a href="/XGDB/conf/index.php">-Getting Started-</a></i> and work through the menu pages listed there.</p>
                         <p class="bottommargin1">&nbsp;<b>Watch a short video tutorial:</b>
                           <a title='Video is also available at http://www.youtube.com/watch?v=3KL9ceP11yo' class='xgdb_button smallerfont ytvideo-button video  xgdb_button colorB4 video-button-bl video' id='configure_vm' name='3KL9ceP11yo'>
                                 Configure new VM
                            </a>
                            <a title='Video is also available at http://www.youtube.com/watch?v=3KL9ceP11yo' class='xgdb_button smallerfont ytvideo-button video  xgdb_button colorB4 video-button-bl video' id='create_example_gdb' name='bMC_Ayp0BcI'>
                                 Create Genome Browser
                            </a>
                        </p>
						</div>

						<div class="helpsection" id="contents">
							<!--Table of Contents-->
							
							<h2 id="contents_heading" class="help">Contents</h2>
							<ul class="contentslist">
								<li><b>Overview</b>
									<ul class="bullet1">
										<li><a href="#create_overview">Process Overview</a></li>
									</ul>
								</li>
								<li><b>Volumes / Licenses</b>
									<ul class="bullet1">
										<li><a href="#config_volumes">Data Volumes</a></li>
										<li><a href="#config_licenses">License Keys</a></li>
									</ul>
								</li>
								<li><b>Data Sources / Validation</b>
									<ul class="bullet1">
										<li><a href="#config_data_decisions-gdna">Data Sources- Genome</a></li>
										<li><a href="#config_data_decisions-transcr">Data Sources- Transcripts</a></li>
										<li><a href="#config_data_decisions-anno">Data Sources- Annotations</a></li>
										<li><a href="#config_data_requirements">Data Requirements (FASTA)</a></li>
										<li><a href="#config_file_names_brief">Filename Requirements</a></li>
									</ul>
								</li>
								<li><b>Configure</b>
									<ul class="bullet1">
										<li><a href="#config_new">New configuration</a></li>
										<li><a href="#config_new_save">Save configuration</a></li>
										<li><a href="#config_status">Status</a></li>
									</ul>
								</li>
								<li><b>Input Data</b>
									<ul class="bullet1">
										<li><a href="#config_input_data">Input Data</a></li>
										<li><a href="#config_repmask_option">Repeat Mask Genome</a></li>
										<li><a href="#config_input_dir">Input Data Directory</a></li>
										<li><a href="#config_input_datastore">Mount Data Store</a></li>
										<li><a href="#config_input_ebs">Mount EBS</a></li>
										<li><a href="#config_file_name_validation">File Name Validation</a></li>
										<li><a href="#config_file_contents_validation">File Contents Validation</a></li>
										<li><a href="#config_file_duplicates_error">Duplicate ID Error (multi-file)</a></li>
										<li><a href="#config_data_permissions">File Permissions</a></li>
										<li><a href="#config_compute_resource">Compute Resources</a></li>
										<li><a href="#config_cpgat_option">CpGAT Gene Prediction</a></li>
									</ul>
								</li>

								<li><b>Output Data</b>
									<ul class="bullet1">
										<li><a href="#config_output_dir">Output Data Directory</a></li>
										<li><a href="#config_output_dir_mount">Output Directory: External Mount</a></li>
										<li><a href="#config_output_dir_download">Output Directory: Download Data</a></li>
									</ul>
								</li>
								<li><b>Create GDB</b>
									<ul class="bullet1">
										<li><a href="#config_page">Configuration Form</a></li>
										<li><a href="#config_top_menu">Top Menu</a></li>
										<li><a href="#config_edit_mode">Edit Mode</a></li>
										<li><a href="#config_db_options">Data Process Options</a></li>
										<li><a href="#config_create_db">Create Database</a></li>
									</ul>
								</li>
								<li><b>Other Config Options</b>
									<ul class="bullet1">
										<li><a href="#config_default_display">Display Defaults</a></li>
										<li><a href="#config_yrgate_ref">yrGATE Reference Annotation</a></li>
										<li><a href="#config_genome_info">Genome Information</a></li>
									</ul>
								</li>
								<li><b>List All Configured</b>
									<ul class="bullet1">
										<li><a href="#config_viewall">List All Configured</a></li>
										<li><a href="#config_viewall_links">Links to GDB pages</a></li>
									</ul>
								</li>		
								<li><b>Pipeline</b>
									<ul class="bullet1">
										<li><a href="#config_pipeline_overview">Overview</a></li>
										<li><a href="#config_pipeline_procedure_log">Pipeline Procedure Log</a></li>
										<li><a href="#config_pipeline_cpgat_log">CpGAT Log</a></li>
										<li><a href="#config_pipeline_error_log">Error Log</a></li>
									</ul>
								</li>
								<li><b>Update</b>
									<ul class="bullet1">
										<li><a href="#config_update_option">Updating a Database</a></li>
										<li><a href="#config_update_data">Update Data Files</a></li>
									</ul>
								</li>
								<li><b>Drop GDB</b>
									<ul class="bullet1">
										<li><a href="#config_drop">Dropping a Database</a></li>
									</ul>
								</li>
								<li><b>Archive / Restore </b>
									<ul class="bullet1">
										<li><a href="#config_archive_delete">Overview</a></li>
										<li><a href="#config_manage_archive">Manage Archive</a></li>
										<li><a href="#config_archive">Archive One GDB</a></li>
										<li><a href="#config_restore">Restore One GDB</a></li>
										<li><a href="#config_copy_archive">Copy GDB Archive</a></li>
										<li><a href="#config_load_archive">Load Archive from another GDB</a></li>
										<li><a href="#config_archive_all">Archive ALL GDB</a></li>
										<li><a href="#config_restore_all">Restore ALL GDB</a></li>
										<li><a href="#config_delete_archive_all">Delete Archive All</a></li>
										<li><a href="#config_delete_all">Delete ALL GDB</a></li>
									</ul>
								</li>
								<li><b>Delete GDB</b>
									<ul class="bullet1">
										<li><a href="#config_delete_all">Delete ALL GDB</a></li>
										<li><a href="#config_delete_GDB">Delete Most Recent GDB</a></li>
									</ul>
								</li>
								<li><b>Configuration Error/Troubleshooting</b>
									<ul class="bullet1">
										<li><a href="#config_extra_dir_data">Warning: Extra GDB directory under /xGDBvm/data/</a></li>
										<li><a href="#trouble_pipeline_error_list">List of Pipeline Errors</a></li>
									</ul>
								</li>
							</ul>
			
					</div>
			<!-- Content based on include files -->
			
						<div class="helpsection">
							<h2 class="help">Overview</h2>
								<div class="feature" id="create_overview">
									<?php include('/xGDBvm/XGDB/help/includes/create_overview.inc.php'); ?>
										<a class="smallerfont indent2" href="#heading">[top]</a>
								</div>
						</div>
						<div class="helpsection">
							<h2 class="help">Volumes / Licenses</h2>
								<div class="feature" id="config_volumes">
									<?php include('/xGDBvm/XGDB/help/includes/config_volumes.inc.php'); ?>
										<a class="smallerfont indent2" href="#heading">[top]</a>
								</div>
								<div class="feature" id="config_licenses">
									<?php include('/xGDBvm/XGDB/help/includes/config_licenses.inc.php'); ?>
										<a class="smallerfont indent2" href="#heading">[top]</a>
								</div>
						</div>
						
						<div class="helpsection">
							<h2 class="help">Data Sources / Validation</h2>
								<div class="feature" id="config_data_decisions-gdna">
									<?php include('/xGDBvm/XGDB/help/includes/config_data_decisions-gdna.inc.php'); ?>
										<a class="smallerfont indent2" href="#heading">[top]</a>
								</div>
								<div class="feature" id="config_data_decisions-transcr">
									<?php include('/xGDBvm/XGDB/help/includes/config_data_decisions-transcr.inc.php'); ?>
										<a class="smallerfont indent2" href="#heading">[top]</a>
								</div>
								<div class="feature" id="config_data_decisions-anno">
									<?php include('/xGDBvm/XGDB/help/includes/config_data_decisions-anno.inc.php'); ?>
										<a class="smallerfont indent2" href="#heading">[top]</a>
								</div>
								<div class="feature" id="config_file_names_brief">
									<?php include('/xGDBvm/XGDB/help/includes/config_file_names_brief.inc.php'); ?>
										<a class="smallerfont indent2" href="#heading">[top]</a>
								</div>
								<div class="feature" id="config_data_requirements">
									<?php include('/xGDBvm/XGDB/help/includes/config_data_requirements.inc.php'); ?>
										<a class="smallerfont indent2" href="#heading">[top]</a>
								</div>
						</div>
						<div class="helpsection">
							<h2 class="help">Configure</h2>
								<div class="feature" id="config_new">
									<?php include('/xGDBvm/XGDB/help/includes/config_new.inc.php'); ?>
										<a class="smallerfont indent2" href="#heading">[top]</a>
								</div>
								<div class="feature" id="config_new_save">
									<?php include('/xGDBvm/XGDB/help/includes/config_new_save.inc.php'); ?>
										<a class="smallerfont indent2" href="#heading">[top]</a>
								</div>
								<div class="feature" id="config_status">
									<?php include('/xGDBvm/XGDB/help/includes/config_status.inc.php'); ?>
										<a class="smallerfont indent2" href="#heading">[top]</a>
								</div>
						</div>
						<div class="helpsection">
							<h2 class="help">Input Data</h2>
								<div class="feature" id="config_input_data">
									<?php include('/xGDBvm/XGDB/help/includes/config_input_data.inc.php'); ?>
										<a class="smallerfont indent2" href="#heading">[top]</a>
								</div>
								<div class="feature" id="config_repmask_option">
									<?php include('/xGDBvm/XGDB/help/includes/config_repmask_option.inc.php'); ?>
										<a class="smallerfont indent2" href="#heading">[top]</a>
								</div>
								<div class="feature" id="config_input_dir">
									<?php include('/xGDBvm/XGDB/help/includes/config_input_dir.inc.php'); ?>
										<a class="smallerfont indent2" href="#heading">[top]</a>
								</div>
								<div class="feature" id="config_input_datastore">
									<?php include('/xGDBvm/XGDB/help/includes/config_input_datastore.inc.php'); ?>
										<a class="smallerfont indent2" href="#heading">[top]</a>
								</div>
								<div class="feature" id="config_input_ebs">
									<?php include('/xGDBvm/XGDB/help/includes/config_input_ebs.inc.php'); ?>
										<a class="smallerfont indent2" href="#heading">[top]</a>
								</div>
								<div class="feature" id="config_file_name_validation">
									<?php include('/xGDBvm/XGDB/help/includes/config_file_name_validation.inc.php'); ?>
										<a class="smallerfont indent2" href="#heading">[top]</a>
								</div>
								<div class="feature" id="config_file_contents_validation">
									<?php include('/xGDBvm/XGDB/help/includes/config_file_contents_validation.inc.php'); ?>
										<a class="smallerfont indent2" href="#heading">[top]</a>
								</div>
								<div class="feature" id="config_file_duplicates_error">
									<?php include('/xGDBvm/XGDB/help/includes/config_file_duplicates_error.inc.php'); ?>
										<a class="smallerfont indent2" href="#heading">[top]</a>
								</div>
								<div class="feature" id="config_data_permissions">
									<?php include('/xGDBvm/XGDB/help/includes/config_data_permissions.inc.php'); ?>
										<a class="smallerfont indent2" href="#heading">[top]</a>
								</div>
								<div class="feature" id="config_compute_resource">
									<?php include('/xGDBvm/XGDB/help/includes/config_compute_resource.inc.php'); ?>
										<a class="smallerfont indent2" href="#heading">[top]</a>
								</div>
								<div class="feature" id="config_cpgat_option">
									<?php include('/xGDBvm/XGDB/help/includes/config_cpgat_option.inc.php'); ?>
										<a class="smallerfont indent2" href="#heading">[top]</a>
								</div>
						</div>
						<div class="helpsection">
							<h2 class="help">Output Data</h2>
								<div class="feature" id="config_output_dir">
									<?php include('/xGDBvm/XGDB/help/includes/config_output_dir.inc.php'); ?>
										<a class="smallerfont indent2" href="#heading">[top]</a>
								</div>
								<div class="feature" id="config_output_dir_mount">
									<?php include('/xGDBvm/XGDB/help/includes/config_output_dir_mount.inc.php'); ?>
										<a class="smallerfont indent2" href="#heading">[top]</a>
								</div>
								<div class="feature" id="config_output_dir_download">
									<?php include('/xGDBvm/XGDB/help/includes/config_output_dir_download.inc.php'); ?>
										<a class="smallerfont indent2" href="#heading">[top]</a>
								</div>
						</div>
						<div class="helpsection">
							<h2 class="help">Create GDB</h2>
								<div class="feature" id="config_page">
									<?php include('/xGDBvm/XGDB/help/includes/config_page.inc.php'); ?>
										<a class="smallerfont indent2" href="#heading">[top]</a>
								</div>
								<div class="feature" id="config_top_menu">
									<?php include('/xGDBvm/XGDB/help/includes/config_top_menu.inc.php'); ?>
										<a class="smallerfont indent2" href="#heading">[top]</a>
								</div>
								<div class="feature" id="config_edit_mode">
									<?php include('/xGDBvm/XGDB/help/includes/config_edit_mode.inc.php'); ?>
										<a class="smallerfont indent2" href="#heading">[top]</a>
								</div>
								<div class="feature" id="config_db_options">
									<?php include('/xGDBvm/XGDB/help/includes/config_db_options.inc.php'); ?>
										<a class="smallerfont indent2" href="#heading">[top]</a>
								</div>
								<div class="feature" id="config_create_db">
									<?php include('/xGDBvm/XGDB/help/includes/config_create_db.inc.php'); ?>
										<a class="smallerfont indent2" href="#heading">[top]</a>
								</div>	
							</div>
							<div class="helpsection">
							<h2 class="help">Other Configure Options</h2>
								<div class="feature" id="config_default_display">
									<?php include('/xGDBvm/XGDB/help/includes/config_default_display.inc.php'); ?>
										<a class="smallerfont indent2" href="#heading">[top]</a>
								</div>
								<div class="feature" id="config_yrgate_ref">
									<?php include('/xGDBvm/XGDB/help/includes/config_yrgate_ref.inc.php'); ?>
										<a class="smallerfont indent2" href="#heading">[top]</a>
								</div>
								<div class="feature" id="config_genome_info">
									<?php include('/xGDBvm/XGDB/help/includes/config_genome_info.inc.php'); ?>
										<a class="smallerfont indent2" href="#heading">[top]</a>
								</div>
							</div>						
							<div class="helpsection">
							<h2 class="help">List All Configured</h2>
								<div class="feature" id="config_viewall">
									<?php include('/xGDBvm/XGDB/help/includes/config_viewall.inc.php'); ?>
										<a class="smallerfont indent2" href="#heading">[top]</a>
								</div>
								<div class="feature" id="config_viewall_links">
									<?php include('/xGDBvm/XGDB/help/includes/config_viewall_links.inc.php'); ?>
										<a class="smallerfont indent2" href="#heading">[top]</a>
								</div>
							</div>
						<div class="helpsection">
							<h2 class="help">Pipeline</h2>
								<div class="feature" id="config_pipeline_overview">
									<?php include('/xGDBvm/XGDB/help/includes/config_pipeline_overview.inc.php'); ?>
										<a class="smallerfont indent2" href="#heading">[top]</a>
								</div>
								<div class="feature" id="config_pipeline_procedure_log">
									<?php include('/xGDBvm/XGDB/help/includes/config_pipeline_procedure_log.inc.php'); ?>
										<a class="smallerfont indent2" href="#heading">[top]</a>
								</div>
								<div class="feature" id="config_pipeline_cpgat_log">
									<?php include('/xGDBvm/XGDB/help/includes/config_pipeline_cpgat_log.inc.php'); ?>
										<a class="smallerfont indent2" href="#heading">[top]</a>
								</div>
								<div class="feature" id="config_pipeline_error_log">
									<?php include('/xGDBvm/XGDB/help/includes/config_pipeline_error_log.inc.php'); ?>
										<a class="smallerfont indent2" href="#heading">[top]</a>
								</div>
							</div>
							<div class="helpsection">
								<h2 class="help">Update</h2>
									<div class="feature" id="config_update_option">
										<?php include('/xGDBvm/XGDB/help/includes/config_update_option.inc.php'); ?>
											<a class="smallerfont indent2" href="#heading">[top]</a>
									</div>	
									<div class="feature" id="config_update_data">
										<?php include('/xGDBvm/XGDB/help/includes/config_update_data.inc.php'); ?>
											<a class="smallerfont indent2" href="#heading">[top]</a>
									</div>
							</div>
							<div class="helpsection">
								<h2 class="help">Drop GDB</h2>
									<div class="feature" id="config_drop">
										<?php include('/xGDBvm/XGDB/help/includes/config_drop.inc.php'); ?>
											<a class="smallerfont indent2" href="#heading">[top]</a>
									</div>	
							</div>
							<div class="helpsection">
								<h2 class="help">Archive / Restore</h2>
									<div class="feature" id="config_archive_delete">
										<?php include('/xGDBvm/XGDB/help/includes/config_archive_delete.inc.php'); ?>
											<a class="smallerfont indent2" href="#heading">[top]</a>
									</div>	
									<div class="feature" id="config_manage_archive">
										<?php include('/xGDBvm/XGDB/help/includes/config_manage_archive.inc.php'); ?>
											<a class="smallerfont indent2" href="#heading">[top]</a>
									</div>	
									<div class="feature" id="config_archive">
										<?php include('/xGDBvm/XGDB/help/includes/config_archive.inc.php'); ?>
											<a class="smallerfont indent2" href="#heading">[top]</a>
									</div>	
									<div class="feature" id="config_restore">
										<?php include('/xGDBvm/XGDB/help/includes/config_restore.inc.php'); ?>
											<a class="smallerfont indent2" href="#heading">[top]</a>
									</div>
									<div class="feature" id="config_copy_archive">
										<?php include('/xGDBvm/XGDB/help/includes/config_copy_archive.inc.php'); ?>
											<a class="smallerfont indent2" href="#heading">[top]</a>
									</div> 
									<div class="feature" id="config_load_archive">
										<?php include('/xGDBvm/XGDB/help/includes/config_new_from_archive.inc.php'); ?>
										<?php include('/xGDBvm/XGDB/help/includes/config_load_archive.inc.php'); ?>
											<a class="smallerfont indent2" href="#heading">[top]</a>
									</div>
									<div class="feature" id="config_archive_all">
										<?php include('/xGDBvm/XGDB/help/includes/config_archive_all.inc.php'); ?>
											<a class="smallerfont indent2" href="#heading">[top]</a>
									</div>	
									<div class="feature" id="config_restore_all">
										<?php include('/xGDBvm/XGDB/help/includes/config_restore_all.inc.php'); ?>
											<a class="smallerfont indent2" href="#heading">[top]</a>
									</div>
									<div class="feature" id="config_delete_archive_all">
										<?php include('/xGDBvm/XGDB/help/includes/config_delete_archive_all.inc.php'); ?>
											<a class="smallerfont indent2" href="#heading">[top]</a>
									</div>
							</div>
							<div class="helpsection">
								<h2 class="help">Delete GDB</h2>
									<div class="feature" id="config_delete_all">
										<?php include('/xGDBvm/XGDB/help/includes/config_delete_all.inc.php'); ?>
											<a class="smallerfont indent2" href="#heading">[top]</a>
									</div>
									<div class="feature" id="config_delete_GDB">
										<?php include('/xGDBvm/XGDB/help/includes/config_delete_GDB.inc.php'); ?>
											<a class="smallerfont indent2" href="#heading">[top]</a>
									</div>
							</div>
							<div class="helpsection">
								<h2 class="help">Configuration Errors/Troubleshooting</h2>
									<div class="feature" id="config_extra_dir_data">
										<?php include('/xGDBvm/XGDB/help/includes/config_extra_dir_data.inc.php'); ?>
											<a class="smallerfont indent2" href="#heading">[top]</a>
									</div>
									<div class="feature" id="trouble_pipeline_error_list">
										<?php include('/xGDBvm/XGDB/help/includes/trouble_pipeline_error_list.inc.php'); ?>
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
