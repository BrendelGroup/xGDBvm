<?php
error_reporting(E_ALL & ~E_NOTICE); //disable undeclared variable error
session_start();

	$global_DB= 'Genomes';
	$PageTitle = 'xGDBvm Data Requirements';
	$pgdbmenu = 'Manage';
	$submenu1 = 'Config-Home';
	$submenu2 = 'Config-Data';
	$submenu = 'Data';
	$leftmenu='Config-Data';
	$warning_msg='';
	include('sitedef.php');
	include($XGDB_HEADER);
	include_once(dirname(__FILE__).'/conf_functions.inc.php');
	include_once(dirname(__FILE__).'/validate.php');
	include_once('/xGDBvm/XGDB/phplib/db.inc.php');
	
	$dbpass=dbpass();

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
									<h1 class="configure darkgrayfont"><img alt="" src="/XGDB/images/configure.png" /> Data Requirements </h1>
							<div class="feature">									
<h2 class="bottommargin1 topmargin2">Input Data Files</h2>
                                <div class="featurediv">
									<p><span class="heading">Follow the guidelines below to prepare your input data for processing. See <a href="/XGDB/conf/datatypes.php">Data Sources</a> if unsure what data types to use for your GDB.</span></p>						
										<ol class="orderedlist1 indent2">
											<li>Prepare your <b>Input data</b> with the following <b>standardized filenames</b> (see  <a href="#data">data</a> and <a href="#filenames">filename</a> sections below for detailed requirements):
												<ul class="bullet1">
													<li>Genome: <span class="plaintext highlight"> ~gdna.fa, ~gdna.rm.fa</span></li>
													<li>Transcript: <span class="plaintext highlight"> ~est.fa, ~cdna.fa, ~tsa.fa</span>; Related-species protein: <span class="plaintext highlight">~prot.fa</span></li>
													<li>GeneSeqer output: <span class="plaintext highlight"> ~est.gsq, ~cdna.gsq, ~tsa.gsq</span>; GenomeThreader output: <span class="plaintext highlight"> ~prot.gth</span></li>
													<li>Annotation: <span class="plaintext highlight"> ~annot.gff3, ~cpgat.gff3</span>; Transcript: <span class="plaintext highlight"> ~annot.mrna.fa, ~cpgat.mrna.fa, ~tsa.fa</span>; Translation: <span class="plaintext highlight"> ~annot.pep.fa, ~cpgat.pep.fa</span></li>
													<li>Annotation descriptions: <span class="plaintext highlight"> ~annot.desc.txt, ~cpgat.desc.txt</span></li>
												</ul>
											</li>
											<li>Prepare any <b>Reference File(s)</b> using the standard <span class="plaintext highlight">~.fa</span> suffix (they will go in <b>designated directories</b> apart from your inputs)
												<ul class="bullet1">
													<li>Reference Protein Dataset: <span class="plaintext highlight">~.fa</span> (for CpGAT gene prediction option)</li>
													<li>Repeat Mask Library:  <span class="plaintext highlight">~.fa</span> (for Repeat Mask option)</li>
												</ul>
											</li>
											<li>Deposit <b>Input data</b> files in a <b>single directory</b> (e.g. <span class="plaintext">MyInputs</span>), directly under <span class="plaintext">/xGDBvm/input/xgdbvm/</span>. Depending on your setup:
											<ul class="bullet1">
											    <li>If <b>iPlant Data Store</b> is mounted to <span class="plaintext">/xGDBvm/input/xgdbvm/</span>, use the Discovery Environment <a href="http://preview.iplantcollaborative.org/de/?type=data">Data Tool</a> to create a subdirectory on your <b>Data Store home</b>, e.g. <span class="plaintext">/username/myInputs/</span>) and upload your input data there.</li>
											    <li>Otherwise, use <span class="plaintext">SCP</span> or other file transfer method to deposit all files in a <b>single directory </b> under <span class="plaintext">/xGDBvm/input/xgdbvm/</span>. </li>
											</ul>
											</li>
											<li>Deposit your <b>Reference File(s)</b> in respective <b>designated directories</b> that were pre-configured on the attached storage:
												<ul class="bullet1">
											 		<li><span class="plaintext">/xGDBvm/input/xgdbvm/referenceprotein/</span> </li>
											 		<li><span class="plaintext">/xGDBvm/input/xgdbvm/repeatmask/</span></li>
											 	</ul>
											 </li>
											<li>You will specify the <b>input data path</b> ( e.g. <span class="plaintext">/xGDBvm/input/xgdbvm/myInputs/</span>) and <b>Reference File path(s)</b> in your <a href="/XGDB/conf/new.php">GDB Configuration</a>.</li>
										    <li>xGDBvm will list <span class="checked">valid filenames</span> and project <span class= "normalfont bold" style="color: orange">expected outputs</span> after you have saved your configuration. Check to insure all expected files and outputs are on the list.</li>
											<li><b>Validate all inputs</b> by clicking '<i>Data Process Options</i>' and then '<i>Validate My Input Files</i>'. When complete, status will be displayed as <span class="contentsvalid">  valid</span>; <span class="contentsnotvalid"> not valid</span>; or <span class="contentsnoteval"> not checked</span>. </li>
											<li>Finally, before proceeding, visit <a href="/XGDB/conf/volumes.php">Data Volumes</a> to check mount status and storage capacity of your <span class="plaintext">/xGDBvm/input/xgdbvm/</span> directory</li>
										</ol>
							</div>
										<hr />
							<div class="feature">									
											<p class="indent2"> <span class="tip_style">&nbsp; FASTA headers should be either <b>GenBank</b> or <b>Simple</b> format. Also, avoid <b>special characters</b> in ID or description.</span></p>
											<ul class="bullet1 indent2">
												<li><span class="plaintext">>gi|123456|gb|A12345|description</span></li> 
												<li><span class="plaintext">>A123456 description</span></li>
											</ul>
											<p class="indent2"> <span class="tip_style">&nbsp; Make sure all IDs are <b>UNIQUE</b> within a data type. Otherwise, data will not be loaded</span></p>
											<p class="indent2"> <span class="tip_style">&nbsp; Where different file types refer to the same sequence (e.g. transcript IDs in GFF3 and fasta), the IDs <b>MUST MATCH!</b></span></p>
											<p class="indent2"> <span class="tip_style">&nbsp; Multiple files of the same type are acceptable; they will be concatenated together for data processing</span></p>
											<p class="indent2"> <span class="tip_style">&nbsp; Make sure that your files have <b>appropriate permissions</b> -- xGDBvm must be able to read and copy the files.</span></p>
								</div>
							</div>
							<div class="feature" id="data">
							<?php include_once("/xGDBvm/XGDB/help/includes/config_data_requirements.inc.php"); ?>
							</div>	
							<div class="feature" id="filenames">
							<?php include_once("/xGDBvm/XGDB/help/includes/config_file_names.inc.php"); ?>
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
