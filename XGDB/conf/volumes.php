<?php
error_reporting(E_ALL & ~E_NOTICE); //disable undeclared variable error
session_start();
$global_DB= 'Genomes';
$PageTitle = 'xGDBvm Volumes';
$pgdbmenu = 'Manage';
$submenu1 = 'Config-Home';
$submenu2 = 'Config-Volumes';
$leftmenu='Config-Volumes';
$warning_msg='';
include('sitedef.php');
include($XGDB_HEADER);
include_once(dirname(__FILE__).'/conf_functions.inc.php');
include_once(dirname(__FILE__).'/validate.php');
include_once('/xGDBvm/XGDB/phplib/db.inc.php');

$inputDir=$XGDB_INPUTDIR; # 1-26-16 J Duvick
$dataDir=$XGDB_DATADIR; # 1-26-16 J Duvick
$inputDirRoot=$XGDB_INPUTDIR_MOUNT; # correcte 2-2-16 
$dbpass=dbpass();

	$db = mysql_connect("localhost", "gdbuser", $dbpass);
	if(!$db)
	{
		echo "Error: Could not connect to database!";
		exit;
	}
	mysql_select_db("$global_DB");
	$error = $_GET['error'];
	
	
	## calls to conf_functions.inc.php . Returns array ($filesys, $avail, $mount);##
	$path1="/xGDBvm/";
	$df_array1=df_available($path1);
	$filesys1=$df_array1[0];
	$available1=$df_array1[1];
	$gb1=$available1/1000000; 
	$gb1_display=round($gb1, 0); 
	$blocks1=preg_replace('/(?<=\d)(?=(\d\d\d)+$)/', ',', $available1 ); //1 kb blocks
	$mount1=$df_array1[2];
	#$location1="Internal"; deprecated this column 7/15/14 JPD
	
	$path2="/xGDBvm/data/";
	$df_array2=df_available($path2);
	$filesys2=$df_array2[0];
	$available2=$df_array2[1];
	$gb2=$available2/1000000; 
	$gb2_display=round($gb2, 0); 
	$available2=preg_replace('/(?<=\d)(?=(\d\d\d)+$)/', ',', $available2 );
	$data_directory2=data_directory($path2); // list entire directory contents as a string
	$mount2=$df_array2[2];
	#$location2=($filesys1==$filesys2)?"Internal":"External"; // e.g. if /xGDBvm is sda1 and /xGDBvm/data is sda2, then data is external mount
	
	$path_data="/xGDBvm/data/"; // to test if /scratch/ or /mysql/ is externally mounted
	$df_array_data=df_available($path_data);
	$available_data=$df_array_data[1];
	$gb_data=round($available_data/1000000, 3); 
	
	$path3="/xGDBvm/data/scratch/";
	$df_array3=df_available($path3);
	$filesys3=$df_array3[0];
	$available3=$df_array3[1];
	$gb3=$available3/1000000; 
	$gb3_display=round($gb3, 0); 
	$available3=preg_replace('/(?<=\d)(?=(\d\d\d)+$)/', ',', $available3 );
	$data_directory3=data_directory($path3);// list entire directory contents as a string
	$mount3=$df_array3[2];
	#$location3=($filesys3==$filesys1)?"Internal":"External";

	$path4="/xGDBvm/data/mysql/";
	$df_array4=df_available($path4);
	$filesys4=$df_array4[0];
	$available4=$df_array4[1];
	$gb4=$available4/1000000; 
	$gb4_display=round($gb4, 0); 
	$available4=preg_replace('/(?<=\d)(?=(\d\d\d)+$)/', ',', $available4 );
	//$data_directory4=data_directory($path4);// permissions prevents listing
	$mount4=$df_array4[2];
	#$location4=($filesys4==$filesys1)?"Internal":"External";

	$path5="/xGDBvm/data/tmp";
	$df_array5=df_available($path5);
	$filesys5=$df_array5[0];
	$available5=$df_array5[1];
	$gb5=$available5/1000000; 
	$gb5_display=round($gb5, 0); 
	$available5=preg_replace('/(?<=\d)(?=(\d\d\d)+$)/', ',', $available5 );
	$data_directory5=data_directory($path5);// list entire directory contents as a string
	$mount5=$df_array5[2];
	#$location5=($filesys4==$filesys1)?"Internal":"External";

	$path6=$inputDirRoot;
	$df_array6=df_available($path6);
	$filesys6=$df_array6[0];
	$available6=$df_array6[1];
	$gb6=$available6/1000000; 
	$gb6_display=round($gb6, 0); 
	$available6=preg_replace('/(?<=\d)(?=(\d\d\d)+$)/', ',', $available6 );
	$data_directory6=data_directory($path6);// list entire directory contents as a string
	$mount6=$df_array6[2];
	#$location6=($filesys6==$filesys1)?"Internal":"External";
	
## Validate volumes
	$validate_mysql=validate_dir("/xGDBvm/data/", "mysql", "mysql directory", "present", "missing");
	$mysql_valid=$validate_mysql[0]; $mysql_class=$validate_mysql[1];
	$validate_scratch=validate_dir("/xGDBvm/data/", "scratch", "scratch directory", "present", "missing");
	$scratch_valid=$validate_scratch[0]; $scratch_class=$validate_scratch[1];
	$validate_tmp=validate_dir("/xGDBvm/data/", "tmp", "tmp directory", "present", "missing");
	$tmp_valid=$validate_tmp[0]; $tmp_class=$validate_tmp[1];

if (file_exists("/xGDBvm/admin/iplant")) { // xGDBvm-iPlant only
   $devloc=str_replace("/","\/",$EXT_MOUNT_DIR); // read from device location stored in /xGDBvm/admin/devloc via sitedef.php
## Show data mount status of external mount point volume
	$data_mount=(preg_match("/$devloc/", $filesys2))?"mounted":"not mounted"; // 	
	$data_class=(preg_match("/$devloc/", $filesys2))?"mounted":"local";
}

    $input_mount=($mount6=="/xgdb-input")?"mounted":"not mounted";
	$input_class=($input_mount=="mounted")?"mounted":"local"; // css style

	$colors=find_shared_volumes($gb1, $gb2, $gb3, $gb4, $gb5, $gb6, "#FFE3B7", "#C4FFB7", "#B7BFFF", "#F1B7FF", "#C9D9FF", "#5FFCF7"); 
	$color1=$colors[0];
	$color2=$colors[1];
	$color3=$colors[2];
	$color4=$colors[3];
	$color5=$colors[4];
	$color6=$colors[5];

## Get MB totals per data path
	$get_input_mb=get_data_total("Input_Data_Path", $dbpass); // returns ($file_count, $file_size, $n)
	$input_count=$get_input_mb[0];
	$input_mb=$get_input_mb[1];
	$input_gb=$input_mb/1000;
	$gdb_count=$get_input_mb[2]; // total # of databases
	
	$get_update_mb=get_data_total("Update_Data_Path", $dbpass); // returns ($file_count, $file_size, $n)
	$update_count=$get_update_mb[0];
	$update_mb=$get_update_mb[1];
	$update_gb=$update_mb/1000;	
	
	$get_cpgat_mb=get_data_total("CpGAT_ReferenceProt_File", $dbpass); // returns ($file_count, $file_size, $n)
	$cpgat_count=$get_cpgat_mb[0];
	$cpgat_mb=$get_cpgat_mb[1];
	$cpgat_gb=$cpgat_mb/1000;

	$get_rep_mask_mb=get_data_total("RepeatMask_File", $dbpass); // returns ($file_count, $file_size, $n)
	$rep_mask_count=$get_rep_mask_mb[0];
	$rep_mask_mb=$get_rep_mask_mb[1];
	$rep_mask_gb=$rep_mask_mb/1000;

	$count_total= $input_count+$cpgat_count+$update_count+$rep_mask_count;
	$mb_total= $input_mb+$cpgat_mb+$update_mb+$rep_mask_mb;
	$gb_total=$mb_total/1000;
	$gb_total_display=round($gb_total, 4);
			
    $server=`uname -n |cut -d "." -f 1`; # identifies this VM
    $nodematch = "/(.*)\.novalocal/"; // this is an OpenStack thing apparently
	preg_match($nodematch, $server, $matches);
	$server=(isset($matches[1]))?$matches[1]:$server;

	$volume_table=
	"
	<table class=\"featuretable\" style=\"width:90%\">
		<thead>
			<tr class=\"reverse_1\" align='center'>
				<th>
					Directory Name <br /><span style=\"color:#CCC\">(Click for details)</span>
				</th>
				<th>
					Dynamically Written Contents
				</th>
				<th>
					Space Requirement (Option 2)
				</th>
				<th>
					Free Space (GB) on Partition
				</th>
				<th>
					Filesystem 
				</th>
				<th>
					Mounted on 
				</th>
				<! th>
					Volume Location
				</th-->
				<th>
					Directory or Volume Status
				</th>
		</tr>
		</thead>
		<tbody>
			<tr id=\"root\" style=\"background-color:$color1\">
				<td>
					<a href=\"#section1\"><span class=\"plaintext largerfont\">/xGDBvm/</span></a>
				</td>
				<td>
					minimal (standard log files, session variables)
				</td>
				<td align='center' class=\"bold alertnotice\">
					minimal
				</td>
				<td align='center' class=\"bold\">
					$gb1_display
				</td>
				<td>
					'<span class=\"plaintext largerfont\">$filesys1</span>'
				</td>
				<td>
					'<span class=\"plaintext largerfont\">$mount1</span>'
				</td>
				<! td>
					$location1
				</td-->
				<td>
					<span class=\"checked\">present</span>
				</td>
			</tr>
			<tr id=\"input\" style=\"background-color:$color6\">
				<td>
					<a href=\"#section6\"><span class=\"plaintext largerfont\">$inputDir</span></a>
				</td>
				<td>
					Input data (by user); HPC inputs (temporary); HPC job output (archive/jobs) 
				</td>
				<td align='center' class=\"bold alertnotice\">
					1x
				</td>
				<td  align='center' class=\"bold\">
					$gb6_display
				</td>
				<td>
					'<span class=\"plaintext largerfont\">$filesys6</span>'
				</td>
				<td>
					'<span class=\"plaintext largerfont\">$mount6</span>'
				</td>
				<!td>
					$location6
				</td-->
				<td>
					<span class=\"$input_class\">$input_mount</span>
				</td>
			</tr>
			<tr id=\"data\" style=\"background-color:$color2\">
				<td>
					<a href=\"#section2\"><span class=\"plaintext largerfont\">$dataDir</span></a>
				</td>
				<td>
					Output data and copies of input data;
				</td>
				<td align='center'  class=\"bold alertnotice\">
					10x
				</td>
				<td align='center' class=\"bold\">
					$gb2_display
				</td>
				<td>
					'<span class=\"plaintext largerfont\">$filesys2</span>'
				</td>
				<td>
					'<span class=\"plaintext largerfont\">$mount2</span>'
				</td>
				<!td>
					$location2
				</td-->
				<td>
					<span class=\"$data_class\">$data_mount</span>
				</td>
			</tr>
			<tr id=\"scratch\" style=\"background-color:$color3\">
				<td>
					<a href=\"#section3\"><span class=\"plaintext largerfont\">$dataDir/scratch/</span></a>
				</td>
				<td>
					(temporary) copies of input data during pipeline operation
				</td>
				<td align='center'  class=\"bold alertnotice\">
					2x
				</td>
				<td  align='center' class=\"bold\">
					$gb3_display
				</td>
				<td>
					'<span class=\"plaintext largerfont\">$filesys3</span>'
				</td>
				<td>
					'<span class=\"plaintext largerfont\">$mount3</span>'
				</td>
				<!td>
					$location3
				</td-->
				<td>
					<span class=\"$scratch_class\">$scratch_valid</span>
				</td>
			</tr>
			<tr id=\"mysql\" style=\"background-color:$color4\">
				<td>
					<a href=\"#section4\"><span class=\"plaintext largerfont\">$dataDir/mysql/</span></a>
				</td>
				<td>
					MySQL data tables
				</td>
				<td align='center' class=\"bold alertnotice\">
					1x
				</td>
				<td  align='center' class=\"bold\">
					$gb4_display
				</td>
				<td>
					'<span class=\"plaintext largerfont\">$filesys4</span>'
				</td>
				<td>
					'<span class=\"plaintext largerfont\">$mount4</span>'
				</td>
				<!td>
					$location4
				</td-->
				<td>
					<span class=\"$mysql_class\">$mysql_valid</span>
				</td>
			</tr>
			<tr id=\"tmp\" style=\"background-color:$color5\">
				<td>
					<a href=\"#section5\"><span class=\"plaintext largerfont\">$dataDir/tmp/</span></a> 
				</td>
				<td>
					Cached images and data files from web browser activity
				</td>
				<td align='center' class=\"bold alertnotice\">
					1x
				</td>
				<td  align='center' class=\"bold\">
					$gb5_display
				</td>
				<td>
					'<span class=\"plaintext largerfont\">$filesys5</span>'
				</td>
				<td>
					'<span class=\"plaintext largerfont\">$mount5</span>'
				</td>
				<!td>
					$location5
				</td-->
				<td>
					<span class=\"$tmp_class\">$tmp_valid</span>
				</td>
			</tr>
		</tbody>
	</table>
	";
	
	?>
						
						<div id="leftcolumncontainer">
							<div class="minicolumnleft">
							<?php include_once("/xGDBvm/XGDB/conf/leftmenu.inc.php"); ?>
							</div>
						</div>
				
							<div id="maincontentscontainer" class="twocolumn overflow configure">
								<div id="maincontentsfull" class="configure">
									<h1 class="configure bottommargin1"><img alt="" src="/XGDB/images/configure.png" /> Data Volumes on <i><?php echo $server ?></i><img id='config_volumes' title='Here you can confirm the correct data directories. Click ? for details.' class='help-button nudge1' src='/XGDB/images/help-icon.png' alt='?' /></h1>
									<div class="featurediv indent2 topmargin2 bottommargin2" id="volume_table">
									<ul class="bullet1 indent1">
										<li>
								Use the table below to determine if current free space meets your data needs <span class="heading">(Similar colors indicate directories under the same volume)</span>
										</li>
										<li>
										As a rule of thumb, multiply your <b> total GB input data  x 10 </b> to estimate how much free space you will need under <span class="plaintext largerfont">/xGDBvm/data</span> 
                                        </li>
                                        <li>
										<span class="heading">NOTE: </span> There are currently <span class="largerfont alertnotice bold"><?php echo $gb_total_display ?> GB</span> (<?php echo $count_total ?> files, <?php echo $gdb_count ?> <span class="Development">Development</span> GDB) of unprocessed, validated <b>input data</b> files on this xGDBvm.
                                        </li>
									</ul>

									<div class="featurediv bottommargin2">
                                          <div class="description  topmargin1 showhide" style="width:95%"><p title="Show additional genome information directly below this link" class="label" style="cursor:pointer">Learn more about volume capacity...</p>
                                                    <div class="hidden" style="display: none">
                                                    <h3>Web Root <span class="heading">(internal to the VM)</span></h3>
                                                    	<ul class="bullet1 indent2">
                                                                <li>The <span class="plaintext largerfont">/xGDBvm/</span> directory contains the <b>web scripts and certain binaries</b>, and shares the same volume as the VM root directory and the general VM server code.</li>
                                                                <li>Only a few output files are stored on this volume, including session caches, server logs, etc., so capacity requirements are not large.</li>
                                                                <li>The available capacity of this volume depends on the size VM you requested. For xGDBvm we recommend at least <b>80 MB disc</b></li>
                                                        </ul>
                                                    <h3>Inputs <span class="heading">(external mount)</span></h3>
                                                    	<ul class="bullet1 indent2">
                                                                <li>The <span class="plaintext largerfont"><?php echo $inputDir ?></span> directory contains your <b>input directory/files</b> and any reference indices (reference proteins, repeat mask libraries) used by the pipeline for genome annotation.</li>
                                                                <li>It also contains <span class="plaintext largerfont">/keys/</span>, an xGDBvm-configured directory that servers as a repository for your <a href="/XGDB/conf/licenses.php">license keys</a>.</li>
                                                                <li> For iPlant users,<span class="plaintext largerfont"><?php echo $inputDir ?></span> is typically mounted to your <b>Data Store</b> offering almost unlimited storage capacity. The table below will indicate its mount status. However xGDBvm does not use this volume for data outputs.</li>
                                                        </ul>
													<h3>Outputs <span class="heading">(external mount)</span></h3>
														<ul class="bullet1 indent2">
														<li>The <span class="plaintext largerfont">/xGDBvm/data</span>  (=<span class="plaintext largerfont">/xGDBvm/data/</span>) directory stores xGDBvm <b>outputs</b> including: temporary 'scratch' files, output files, database tables, download files, indexes), plus any data archives.</li>
														<li>Several subdirectories <span class="plaintext largerfont">/scratch/</span>, <span class="plaintext largerfont">/mysql/</span>, <span class="plaintext largerfont">/tmp/</span> required for data processing, outputs, and browsing, are created by xGDBvm during the configuration stage. You can check their status in the table below</li>
														<li><span class="plaintext largerfont">/xGDBvm/data</span> must have sufficient disk capacity for all of the above plus any additional GDB you may want to create later. This capacity roughly translates to <b>10X</b> your total input file size, e.g. for 400 MB inputs you would want at least 4 GB capacity.</li>
														<li>Since your VM may have limited storage space, a <b>block storage volume</b> is usually mounted at <span class="plaintext largerfont">/xGDBvm/data/</span> to handle output data. </li>
														<li>The external mount also provides flexibility and data security, since you can unmount and remount it to different VMs, instantly reconstituting the data environment on the associated xGDBvm </li>
														</ul>
                                                        <p><span class="tip_style">For instructions on mounting external volumes (iPlant), see </span> <a href="/0README-iPlant">0README-iPlant</a>,  and <a href="http://goblinx.soic.indiana.edu/wiki/doku.php?id=user_instructions">wiki -user instructions</a>.</p>
                                                    
                                            	</div>
										</div>
									<br />
									<h2 class="bottommargin1"> Data Volumes Table</h2>
									<?php echo $volume_table; ?>

									<p>
										<span class="warning">NOTE: Some FUSE-mounted volumes (e.g. iPlant Datastore) may not report accurate storage capacity</span>
									</p>

									</div>
									
									<h2>More Information</h2>

									<div class="featurediv" id="section1">
										<fieldset class="xgdb_log topmargin2">
										<legend class="conf volumes"><span class="plaintext hugefont">/xGDBvm/</span></legend>
											<h3>Description:</h3>
												<ul class="bullet1">
													<li><span class="plaintext largerfont">/xGDBvm/</span> is created under the root partition of your VM and uses storage space allocated to root.</li>
												</ul>
											<h3>Options:</h3>
		
												<ul class="bullet1 bottmmargin2">
														<li>
															If ALL data processing is to be done locally on the VM then <span class="plaintext largerfont">/xGDBvm/</span> will need sufficient capacity to store both input, output data and MySQL data. Recommended: at least <b>20x</b> your total input data size.
														</li>															<li>
															If <b>input</b>, <b>data</b>, and <b>scratch/mysql</b> directories are all on attached storage volumes, then <span class="plaintext largerfont">/xGDBvm/</span> requires only a modest amount of free space. Recommended: at least <b>500 MB</b>
														</li>
													</ul>
											<h3>Current setup:</h3>
											<?php
											echo "<ul class=\"bullet1 bottommargin1\">";
											echo "<li> <span class=\"plaintext largerfont\">".$path1."</span> is on Filesystem <span class=\"plaintext largerfont\">'".$filesys1."</span>' mounted on '<span class=\"plaintext largerfont\">".$mount1."</span>'</li>";
											echo "<li> <span class=\"plaintext largerfont\">".$path1."</span> has <span class=\"bordergray bold darkgrayfont\">".$gb1."</span> GB (gigabytes) storage available. <b>Please verify that this is sufficient to accommodate your setup.</b></li>";
											echo "</ul>";
														?>
													<p class="instruction">If space is insufficient, re-instantiate the VM with a larger allocation.</p>
											<p class="smallerfont"><a href="#top">Top</a></p>
										</fieldset>
									</div><!--end section1 -->
									
									<div class="featurediv" id="section6">
	
										<fieldset class="xgdb_log topmargin2 bottommargin2">
										<legend class="conf volumes"><span class="plaintext hugefont"><?php echo $inputDirRoot ?></span></legend>
												<p>
													<span class="<?php echo $input_class; ?>">
														input directory is <?php echo $input_mount ?> on this volume.
													</span>
												</p>

											<h3>Description:</h3>
											<ul class="bullet1">
												<li>
													For iPlant users, the <span class="plaintext largerfont">/xGDBvm/input/</span> directory can be mounted to your iPlant Data Store Home directory. When this is done, all directories on your Data Store home will appear as directories under <span class="plaintext largerfont"><?php echo $inputDir ?></span>. Thus the Data Store home becomes the repository for user input data (e.g. <span class="plaintext largerfont">myInputData/</span>. It is also used for data input/output for HPC computing (under <span class="plaintext largerfont">archive/jobs/</span>), and for GDB archives (under <span class="plaintext largerfont">ArchiveGDB_vmName/</span> and <span class="plaintext largerfont">ArchiveAllGDB_vmName/</span>). 
												</li>
												<li>
													See <a href="/0README-iPlant">/xGDBvm/0README-iPlant</a> for instructions on mounting your iPlant Data Store. 
												</li>
    										</ul>	
											<h3>Current setup:</h3>
<?php
	echo "<ul class=\"bullet1 bottommargin1\">";
	echo "<li> <span class=\"plaintext largerfont\">".$path6."</span> is on Filesystem '<span class=\"plaintext largerfont\">".$filesys6."</span>' mounted on '<span class=\"plaintext largerfont\">".$mount6."</span>'</li>";
	echo "<li> This volume has <span class=\"bordergray bold darkgrayfont\">".$gb6."</span> GB (gigabytes) available. Please verify that this is sufficient to accommodate your setup.</li>";
	echo "</ul>";
?>
							<p class="smallerfont"><a href="#top">Top</a></p>						
										</fieldset>
							</div><!-- end section 5 -->

									
									<div class="featurediv" id="section2">
										<fieldset class="xgdb_log topmargin2 bottommargin2">
										<legend class="conf volumes"><span class="plaintext hugefont">/xGDBvm/data/</span></legend>
		
											<h3>Description:</h3>
												<ul class="bullet1 bottmmargin2">
														<li>
															The <span class="plaintext largerfont">/xGDBvm/data/</span> directory on iPlant is mounted to a large data partition.
														</li>
														<li>
															To take advantage of this partition, <span class="plaintext largerfont">/xGDBvm/data/</span>, the repository for xGDBvm outputs, is symlinked to <span class="plaintext largerfont">/xGDBvm/data/</span>
														</li>
														<li> 
															Optionally, the user can mount an external volume device (EBS) to <span class="plaintext largerfont">/xGDBvm/data/</span> to further increase usable disk storage and provide data portability (since the EBS drive can be un-mounted and mounted to a different VM). See <a href="/0README-iPlant">/xGDBvm/0README-iPlant</a> for instructions. 

														</li>
													</ul>
											<h3>Options:</h3>
											<ul class="bullet1 bottmmargin2">
												<li>
													 <span class="plaintext largerfont">/xGDVm/data/</span> will require at least 5x the total size of the input data for ALL GDB, apart from what is required by <span class="plaintext largerfont">/xGDBvm/data/scratch/</span>
												</li>
												<li>
												</li>
											</ul>												
											<h3>Current setup:</h3>
											<?php
											echo "<ul class=\"bullet1 bottommargin1\">";
											echo "<li> <span class=\"plaintext largerfont\">".$path2."</span> is on Filesystem <span class=\"plaintext largerfont\">'".$filesys2."</span>' mounted on '<span class=\"plaintext largerfont\">".$mount2."</span>'</li>";
											echo "<li> <span class=\"plaintext largerfont\">".$path2."</span> has <span class=\"bordergray bold darkgrayfont\">".$gb2."</span> GB (gigabytes) storage available. <b>Please verify that this is sufficient to accommodate your setup.</b></li>";
											echo "</ul>";
														?>
											<p class="instruction">
												If space is insufficient, mount this directory to a larger remote volume.
											</p>
											
											<div class="description topmargin1 showhide"><p title="Show additional directory information directly below this link" class="label" style="cursor:pointer"> Current contents of <span class="plaintext">/xGDBvm/data</span>... </p>
												<div class=" hidden">
													<fieldset class="indent2 topmargin1">
														<legend class="normalfont"><a href="/data/"> /xGDBvm/data </a></legend>												
<pre class="indent2">
<?php
echo  $data_directory2;
?>
</pre>
													</fieldset>													
													</div>
												</div>
													<p class="smallerfont"><a href="#top">Top</a></p>
											</fieldset>
										</div><!-- end section 2 -->
									<div class="featurediv" id="section3">
	
										<fieldset class="xgdb_log topmargin2 bottommargin2">
										<legend class="conf volumes"><span class="plaintext hugefont">/xGDBvm/data/scratch/</span></legend>

												<p>
													<span class="<?php echo $scratch_class; ?>">
														scratch directory is <?php echo $scratch_valid ?> on this volume.
													</span>
												</p>

											<h3>Description:</h3>
											<ul class="bullet1">
												<li>
													<span class="plaintext">/xGDBvm/data/scratch/</span> holds temporary scratch subdirectories created by the pipeline process under e.g. <span class="plaintext largerfont">/xGDBvm/data/scratch/GDB001/</span>
												</li>
												<li>
													Data is copied to the subdirectories for computation, and the GDB subdirectory is removed at the end of pipeline processing.
												</li>
												<li>
													The <span class="plaintext largerfont">/xGDBvm/data/scratch/</span> directory is symbolically linked from <span class="plaintext largerfont">/xGDBvm/scratch/</span> to allow Apache to read/write
												</li>
											</ul>	
											<h3>Options:</h3>
											<ul class="bullet1 bottmmargin2">
													<li>
													 <span class="plaintext largerfont">/xGDBvm/data/scratch/</span> will require at least 5x the total size of the input data for ALL GDB, apart from what is required by <span class="plaintext largerfont">/xGDBvm/data/</span>
													</li>
													<li>
														If this is not available under root, <span class="plaintext largerfont">/xGDBvm/data/scratch/</span> (or <span class="plaintext largerfont">/xGDBvm/data/</span>) <b>should be mounted or symbolically linked to an external volume</b> (see <a href="/wiki/doku.php?id=user_instructions">wiki</a> for details)
													</li>
											</ul>												
											<h3>Current setup:</h3>
											<?php
												echo "<ul class=\"bullet1 bottommargin1\">";
												echo "<li> <span class=\"plaintext largerfont\">".$path3."</span> is on Filesystem '<span class=\"plaintext largerfont\">".$filesys3."</span>' mounted on '<span class=\"plaintext largerfont\">".$mount3."</span>'</li>";
												echo "<li> This volume has <span class=\"bordergray bold darkgrayfont\">".$gb3."</span> GB (gigabytes) available. Please verify that this is sufficient to accommodate your setup.</li>";
												echo "</ul>";
											?>
											<p class="instruction indent2">If space is insufficient, mount this directory to a larger remove volume.</p>

											<div class="description topmargin1 label showhide"><p title="Show additional directory information directly below this link" class="label" style="cursor:pointer"> Current contents of <span class="plaintext"><?php echo $path3 ?></span>...</p>
												<div class=" hidden">
													<fieldset class="indent2 topmargin1">
														<legend class="normalfont"> <span class="plaintext"><?php echo $path3 ?></span></legend>
<pre class="largerfont indent2">
<?php
echo  $data_directory3;
?>
</pre>
										</fieldset>
										</div>
									</div>
							<p class="smallerfont"><a href="#top">Top</a></p>						
								</fieldset>
							</div><!-- end section 3 -->
							
									<div class="featurediv" id="section4">
	
										<fieldset class="xgdb_log topmargin2 bottommargin2">
										<legend class="conf volumes"><span class="plaintext hugefont">/xGDBvm/data/mysql/</span></legend>
												<p>
													<span class="<?php echo $mysql_class; ?>">
														mysql directory is <?php echo $mysql_valid ?> on this volume.
													</span>
												</p>
											<h3>Description:</h3>
											<ul class="bullet1">
												<li>
													The directory <span class="plaintext largerfont">/xGDBvm/data/mysql/</span> is used for MySQL tables and is pre-configured under <span class="plaintext largerfont">/etc/my.cnf</span> (iPlant users need to run a script). 
												</li>
											</ul>	
											<h3>Options:</h3>
											<ul class="bullet1 bottmmargin2">
													<li>
													 <span class="plaintext largerfont">/xGDBvm/data/mysql/</span> will require at least 1.5x the total size of the input data for ALL GDB, apart from what is required by other directories in this list
													</li>
													<li>
														If space is insufficient, you may need to increase the storage capacity of your VM. We don't recommend mounting <span class="plaintext largerfont">/xGDBvm/data/mysql/</span>.
													</li>
											</ul>												
											<h3>Current setup:</h3>
											<?php
												echo "<ul class=\"bullet1 bottommargin1\">";
												echo "<li> <span class=\"plaintext largerfont\">".$path4."</span> is on Filesystem '<span class=\"plaintext largerfont\">".$filesys4."</span>' mounted on '<span class=\"plaintext largerfont\">".$mount4."</span>'</li>";
												echo "<li> This volume has <span class=\"bordergray bold darkgrayfont\">".$gb4."</span> GB (gigabytes) available. Please verify that this is sufficient to accommodate your setup.</li>";
												echo "</ul>";
											?>

									<p class="smallerfont"><a href="#top">Top</a></p>						
										</fieldset>
									</div><!-- end section 4 -->
									<div class="featurediv" id="section5">
										<fieldset class="xgdb_log topmargin2 bottommargin2">
										<legend class="conf volumes"><span class="plaintext hugefont">/xGDBvm/data/tmp</span></legend>
												<p>
													<span class="<?php echo $tmp_class; ?>">
														tmp directory is <?php echo $tmp_valid ?> on this volume.
													</span>
												</p>

											<h3>Description:</h3>
											<ul class="bullet1">
												<li>
													The <span class="plaintext largerfont">/xGDBvm/data/tmp</span> directory contains GDB subdirectories storing cached files generated during Web browsing and ad hoc computation (blast, geneseqer). 
												</li>
												<li>
													If  <span class="plaintext largerfont">/xGDBvm/data/</span> is mounted to an external volume (see above), the tmp directory must be created as detailed in the <a href="/wiki/doku.php?id=user_instructions">wiki</a>. 
												</li>
												<li>
													The <span class="plaintext largerfont">/tmp/</span> directory is usually symbolically linked from <span class="plaintext largerfont">/xGDBvm/tmp/</span> to allow the web server to read/write.
												</li>
											</ul>	
											<h3>Options:</h3>
											<ul class="bullet1 bottmmargin2">
													<li>
													 <span class="plaintext largerfont">/xGDBvm/data/tmp/</span> storage requirements depend on the amount useage of your VM for analysis.
													</li>
													<li>
														We recommend you monitor tmp disk useage over time. There is a script you can run to clean out tmp files (<span class="plaintext largerfont">cleanTmp.pl</span>).
													</li>
											</ul>												
											<h3>Current setup:</h3>
											<?php
												echo "<ul class=\"bullet1 bottommargin1\">";
												echo "<li> <span class=\"plaintext largerfont\">".$path5."</span> is on Filesystem '<span class=\"plaintext largerfont\">".$filesys5."</span>' mounted on '<span class=\"plaintext largerfont\">".$mount5."</span>'</li>";
												echo "<li> This volume has <span class=\"bordergray bold darkgrayfont\">".$gb5."</span> GB (gigabytes) available.</li>";
												echo "</ul>";
											?>
										<div class="description topmargin1 label showhide"><p title="Show additional directory information directly below this link" class="label" style="cursor:pointer"> Current contents of <span class="plaintext"><?php echo $path5 ?></span>...</p>
											<div class=" hidden">
												<fieldset id="tmp_contents" class="indent2 topmargin1">
													<legend class="normalfont"> <span class="plaintext"><?php echo $path5 ?></span></legend>
<pre class="largerfont indent2">
<?php
echo  $data_directory5;
?>
</pre>
												</fieldset>
											</div><!-- end hidden div -->
										</div><!-- end showhide -->				
										<p class="smallerfont"><a href="#top">Top</a></p>						
										</fieldset>
									</div>
									</div><!-- end section 5 -->
						  <div style="clear:both; float:right">
							<a href="http://validator.w3.org/check?uri=referer"><img
							  src="http://www.w3.org/Icons/valid-xhtml10" alt="Valid XHTML 1.0 Transitional" height="15" width="44" /></a>
						  </div>						
						</div><!--end maincontentsfull-->
					</div><!--end maincontentscontainer-->
					<div id="rightcolumncontainer">
				</div><!--end rightcolumncontainer-->
			<?php include($XGDB_FOOTER); ?>
		</div></div></div>
	</body>
</html>
