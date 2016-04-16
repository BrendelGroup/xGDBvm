<?php
	$PageTitle = 'Videos';
	$pgdbmenu = 'Help';
	$submenu = 'Videos';
	$leftmenu='Videos';
	$global_DB= 'Genomes';
	include("sitedef.php");
	include($XGDB_HEADER);
?>


		<div id="leftcolumncontainer">

		</div>

		<div id="maincontentscontainer" class="onecolumn">
		<div id="maincontentsfull" style="overflow:auto">
		
			<h1 class="topmargin1 bottommargin1" id="heading"><img class="nudge2" src="/XGDB/images/video_blue.png"/> Video Tutorials <span class="heading"> <a href="/index.php">(Home Page)</a> </span>	<span class="heading"> <a href="/XGDB/help/index.php">(Help Overview)</a></span>
</h1>

				<p>
					xGDBvm is a rich environment for creating and analyzing genome displays. The video tutorials on this page, organized into functional sections and workflows, will guide you through the basics in a series of brief videos.
				</p>


<div class="feature">
<h2 class="indent1">Administrator videos</h2>		

		<p class="indent2 topmargin1 bottommargin1"><a title='Video is also available at https://youtu.be/Kcuy-3IZJ_E' class='xgdb_button smallerfont ytvideo-button video  xgdb_button colorGR3 video-button-gr' id='create_example_gdb' name='Kcuy-3IZJ_E'>Video </a> 1. xGDBvm: An Overview | <a href="http://goblinx.soic.indiana.edu/wiki/doku.php?id=tutorials:overview">Transcript</a></p>
		<p class="indent2 topmargin1 bottommargin1"><a title='Video is also available at http://www.youtube.com/watch?v=3KL9ceP11yo' class='xgdb_button smallerfont ytvideo-button video  xgdb_button colorGR3 video-button-gr' id='create_example_gdb' name='3KL9ceP11yo'>Video </a> 2. Configure a new VM | <a href="http://goblinx.soic.indiana.edu/wiki/doku.php?id=tutorials:configure_vm">Transcript</a></p>
		<p class="indent2 topmargin1 bottommargin1"><a title='Video is also available at https://www.youtube.com/watch?v=Pv58RNHDwIA' class='xgdb_button smallerfont ytvideo-button video  xgdb_button colorGR3 video-button-gr' id='create_example_gdb' name='Pv58RNHDwIA'>Video</a> 3. Test your new xGDBvm instance with sample data | <a href="http://goblinx.soic.indiana.edu/wiki/doku.php?id=tutorials:test_vm_with_sample_data">Transcript</a></p>
<!--		<p class="indent2 topmargin1 bottommargin1">4. Prepare your input data for xGDBvm: <a href="">Video</a> | <a href="http://goblinx.soic.indiana.edu/wiki/doku.php?id=tutorials:prepare_input_data">Transcript</a></p>
		<p class="indent2 topmargin1 bottommargin1">5. Create a genome annotation based on your own data: <a href="">Video</a> | <a href="http://goblinx.soic.indiana.edu/wiki/doku.php?id=tutorials:configure_new_gdb">Transcript</a></p>
		<p class="indent2 topmargin1 bottommargin1">6. Use High Performance Compute option: <a href="">Video</a> | <a href="http://goblinx.soic.indiana.edu/wiki/doku.php?id=tutorials:high_performance_compute">Transcript</a></p>
		<p class="indent2 topmargin1 bottommargin1">7. Evaluate xGDBvm output: <a href="">Video</a> | <a href="http://goblinx.soic.indiana.edu/wiki/doku.php?id=tutorials:high_performance_compute">Transcript</a></p>
-->
</div>
<div class="feature" id="annotation">
	<h2 class="topmargin2 bottommargin1 indent1">yrGATE Annotation <span class="heading"><a href="#heading">(top)</a> ; <a href="/XGDB/help/index.php">Help Overview</a></span></h2>
<hr class="featuredivider" />
<div class="indent1">
<?php require('/xGDBvm/XGDB/help/includes/annotation_tutorials.inc.php'); ?>
</div>
</div>
			
			</div><!--end maincontentsfull-->
			</div><!--end maincontentscontainer-->
		<?php include($XGDB_FOOTER); ?>
		</div><!--end pagewidth-->
	</div><!--end innercontainer-->
</div><!--end outercontainer-->
</body>
</html>
