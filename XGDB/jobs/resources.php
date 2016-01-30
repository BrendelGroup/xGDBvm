<?php
#error_reporting(E_ALL & ~E_NOTICE); //disable undeclared variable error
session_start();

####### Token lifespan and logout  ########

if (isset($_SESSION['token']) && $_SESSION['http_code']=="200")// successful login has already occurred
	{
	$expires=$_SESSION['expires']; //time when token expires
	$issued=$_SESSION['issued'];
	$lifespan=$_SESSION['lifespan'];
	$http_code=$_SESSION['http_code'];
	$username=$_SESSION['username'];
	$token=$_SESSION['token'];
	$now=date("U");
//	$expires=$issued+30; //debug only
	if($expires<$now)
		{
		$login_id=$_SESSION['login_id']; //return to the GDB that was originally used for login.
		header("Location: logout.php?id=$login_id&amp;msg=expired&amp;redirect=index"); //come back to this page
		}
	}

date_default_timezone_set("$TIMEZONE"); // from sitedef.php

#### Defaults
	$global_DB1= 'Genomes';
	$global_DB2= 'Admin';
	$PageTitle = 'HPC Job Resources';
	$pgdbmenu = 'Manage';
	$submenu1 = 'Jobs-Resources';
	$submenu2 = 'Jobs-Resources';
	$leftmenu='Jobs-Resources';
	include('sitedef.php');
	include($XGDB_HEADER);
	include_once('/xGDBvm/XGDB/phplib/db.inc.php');
	include_once('/xGDBvm/XGDB/jobs/login_functions.inc.php');
 	include_once('/xGDBvm/XGDB/jobs/jobs_functions.inc.php'); #common functions required in this script
 	$inputDir=$XGDB_INPUTDIR; # 1-26-15   e.g. /xGDBvm/input/xgdbvm/
	$dataDir=$XGDB_DATADIR; # 1-26-15 e.g. /xGDBvm/data/
	$inputDirRoot=$XGDB_INPUTDIR_ROOT; # 1-26-16 J Duvick This is the top level path, e.g. /xGDBvm/input/

	$dbpass=dbpass();
		$db = mysql_connect("localhost", "gdbuser", $dbpass);
	if(!$db)
	{
		echo "Error: Could not connect to database!";
		exit;
	}
		mysql_select_db("$global_DB1");


	$conditional_gdb=!isset($_SESSION['gdbid'])?"display_off":""; // hide this feature if no id has been edited already
	$conditional_login=!isset($_SESSION['token'])?"display_off":""; // hide this feature if user not logged in
	$username = isset($_SESSION['username'])?$_SESSION['username']:"";
	$expires = isset($_SESSION['expires'])?$_SESSION['expires']:"";
	$auth_url = isset($_SESSION['auth_url'])?$_SESSION['auth_url']:"";
	$time_left=$expires-time();
	$time_left=seconds_to_time($time_left);//login_functions.inc.php; calculates d-h-m-s from seconds
	$time_left=$time_left['time'];
	
	## Query database for jobs config status
	

## Get most recent GSQ URL (if any) from database; set update/insert depending on whether prev value exists

	$gsq_query="SELECT uid,gsq_url, gsq_software, gsq_job_time, gsq_proc, gsq_update from $global_DB2.admin where gsq_url !='' order by uid DESC limit 0,1";
	$get_gsq_record = $gsq_query;
	$check_get_gsq_record = mysql_query($get_gsq_record);
	$gsq_result = $check_get_gsq_record;
	$gsq=mysql_fetch_array($gsq_result);
	$gsq_url=$gsq['gsq_url'];
	$gsq_software=$gsq['gsq_software'];
	$gsq_job_time=($gsq['gsq_job_time']=="")?"12:00:00":$gsq['gsq_job_time'];
	$gsq_proc=($gsq['gsq_proc']=="")?$gsq_proc_default:$gsq['gsq_proc'];
	$gsq_update=$gsq['gsq_update'];
	$gsq_message=($gsq_url=="")?"<span class=\"warning indent2\">no GSQ job URL has been added </span>":"<span class=\"checked indent2\">GSQ job changed to Software=$gsq_software, URL= $gsq_url, job time=$gsq_job_time, $gsq_proc threads on $gsq_update </span>";
	$gsq_command=($gsq_update=="")?"insert":"update";

## Get most recent GTH URL (if any) from database; set update/insert depending on whether prev value exists

	$gth_query="SELECT uid,gth_url, gth_software, gth_job_time, gth_proc, gth_update from $global_DB2.admin where gth_url !='' order by uid DESC limit 0,1";
	$get_gth_record = $gth_query;
	$check_get_gth_record = mysql_query($get_gth_record);
	$gth_result = $check_get_gth_record;
	$gth=mysql_fetch_array($gth_result);
	$gth_url=$gth['gth_url'];
	$gth_software=$gth['gth_software'];
	$gth_job_time=($gth['gth_job_time']=="")?"12:00:00":$gth['gth_job_time'];
	$gth_proc=($gth['gth_proc']=="")?$gth_proc_default:$gth['gth_proc'];
	$gth_update=$gth['gth_update'];
	$gth_message=($gth_url=="")?"<span class=\"warning indent2\">no GTH job URL has been added </span>":"<span class=\"checked indent2\">GTH job changed to Software=$gth_software, URL= $gth_url, job time=$gth_job_time, $gth_proc threads  on $gth_update </span>";
	$gth_command=($gth_update=="")?"insert":"update";



    ### Directory Mount Status ###
    # data directory:/data/ ($dir1)
     $dir1_status="";
    if (file_exists("/xGDBvm/admin/iplant")) { // xGDBvm-iPlant only
       $dir1="/xGDBvm/data/"; // TODO: move to sitedef.php
       $df_dir1=df_available($dir1); // check if /data/ directory is externally mounted (returns array)
        $devloc=str_replace("/","\/",$EXT_MOUNT_DIR); // read from device location stored in /xGDBvm/admin/devloc via sitedef.php
        $dir1_mount=(preg_match("/$devloc/", $df_dir1[0]))?"<span class=\"checked_mount\">Ext vol mounted</span>":"<span class=\"lightgrayfont\">Ext vol not mounted</span>"; //flag for dir1 mount
        $dir1_status="<span class=\"normalfont \" style=\"font-weight:normal\"><a class='help-button' title='Mount status of /xGDBvm/data/' id='config_input_ebs'> $dir1_mount </a></span>";
    }

    # data store directory:/input/ ($dir2)
     $dir2_status="";
    if (file_exists("/xGDBvm/admin/iplant")) { // xGDBvm-iPlant only
        $dir2="$inputDirRoot"; // TODO: move to sitedef.php
        $df_dir2=df_available($dir2); // check if /input/ directory is fuse-mounted (returns array)
        $dir2_dropdown=($df_dir2[0]=="fuse"  || $df_dir2[0]=="irodsFs")?"/xGDBvm/input/":""; //only show input dir if fuse-mounted
        $dir2_mount=($df_dir2[0]=="fuse" || $df_dir2[0]=="irodsFs")?"<span class=\"checked_mount nowrap\">DataStore mounted</span>":"<span class=\"lightgrayfont\">DataStore not mounted</span>"; //flag for dir2 mount (Data Store) top of form
        $mount_status_alert=($df_dir2[0]=="fuse" || $df_dir2[0]=="irodsFs")?"<span class=\"checked nowrap\">DataStore mounted</span>":"<span class=\"warning\">DataStore not mounted</span>"; //more intrusive flag
        $dir2_status="<span class=\"normalfont \" style=\"font-weight:normal\"><a class='help-button' title='Mount status of $inputDirRoot' id='config_input_irods'> $dir2_mount </a></span>";
   }

	#### Validate presence of GTH Key (required for remote GTH) ###

	$validate_gth=validate_dir($KEY_SOURCE_DIR, $GENOMETHREADER_KEY, "GenomeThreader License Key", "present", "missing");
	$gth_valid=$validate_gth[0]; $gth_class=$validate_gth[1];
	$gth_valid_message="<span class=\"$gth_class\">GTH license ${gth_valid}</span> <img id='jobs_gth_license' title='GenomeThreader License - Help' class='help-button nudge3 smallerfont' src='/XGDB/images/help-icon.png' alt='?' />";
	

	## Set messages
	
		?>
		

			<div id="leftcolumncontainer">
				<div class="minicolumnleft">
					<?php include_once("/xGDBvm/XGDB/jobs/leftmenu.inc.php"); ?>
				</div>
			</div>
			<div id="maincontentscontainer" class="twocolumn overflow configure">
				<div id="maincontents">	
<?php
 
				echo "
				<div class=\"bottommargin1\"> 
					<table width=\"100%\">
                            <colgroup>
                                <col width =\"65%\" />
                                <col width =\"35%\" style=\"background-color: #EEE\"  />
                            </colgroup>	
                            <tr>
                            <td>
                                <h1 class=\"jobs\"> <img alt=\"\" src=\"/XGDB/images/remote_compute.png\" /> Remote Jobs: <i>Estimate Resources</i></h1>
                                <span class=\"normalfont\" style=\"font-weight:normal\">&nbsp; $dir1_status  &nbsp; $dir2_status </span>
                            </td>
                            <td class=\"$conditional_login smallerfont\" style=\"padding:10px; border: 1px solid #AAA\"> 
                                <span class=\"checked smallerfont\">\"$username\" </span>is authorized at $auth_url
                                (token expires in <span class=\"alertnotice\">$time_left</span>)
                                <span class=\"smallerfont\"><a title=\"log out of this authorization session\" href=\"/XGDB/jobs/logout.php?id=$ID&amp;msg=logout&amp;redirect=index\">(logout)</a></span>
                                <br />
                                $gth_valid_message
                                
                            </td>
                        </tr>
                    </table>
                </div>";


?>
						<div class="feature">
                        <h2>Introduction</h2>
						<p> HPC uses multiple simultaneous process ('threads') to speed processing. For spliced alignment to genome, alignments are independent of each other so the <b>genome sequence</b> can be split into smaller units for separate processing, with the intermediate outputs combined at finish. For some programs, <a href="http://en.wikipedia.org/wiki/Message_Passing_Interface">MPI</a> (Message Passing Interface) allows coordinated processing of subsets of query sequence across multiple threads. 
						</p>
						<p>
						GeneSeqer and GenomeThreader use different <b>splitting strategies</b> and they also use different processor architectures (see <a href="#ProgramsParameters">Programs and Parameters</a> table below for details).
						Briefly, for <b>GeneSeqer-MPI</b> the genome is split into a few subfiles and the query (transcript) file is split into many subfiles whose analysis and output is coordinated by MPI for each genome subfile; for <b>GenomeThreader</b> the genome is split into many subfiles but the query (protein) file is not split but rather duplicated for analysis against each genome subfile.
						<p>Your task will be to configure your HPC job to execute <b>as efficiently as practicable</b> within the allowable job window at TACC (maximum of 24 hr). </p>
						<p>The <a href="#Guidelines">Guidelines</a> below outline a strategy for doing this; refer to <a href="#Programs">Programs and Parameters</a> for HPC details;  learn <a href="#Monitor">how to monitor job progress</a>; and study the <a href="#Examples">Benchmark Examples</a> for real-life estimates for your job. More information on the HPC servers accessible from iPlant can be found in TACC's <a href="https://www.tacc.utexas.edu/user-services/user-guides/">User Guide</a></p>
						</p>
						</div>
						<div class="feature">
                        <h2>Guidelines</h3>
						<p>Genome inputs vary in size, complexity and distribution of scaffold sizes.  You can optimize your HPC job by selecting the appropriate <b>number of threads</b> and <b>maximum compute time</b> for GeneSeqer and/or GenomeThreader. Once selected these parameters can be modified as required on the <a href=\"/XGDB/jobs/configure.php\">Configure</a> page, and also at run-time for <a href="/XGDB/jobs/submit.php">standalone</a> jobs. 
Here are some guidelines to selecting the correct HPC resources (number of threads, Compute Time) for your particular genome:</p>
						
								<ol class="orderedlist1 indent2">
									<li>First consider your overall genome <b> size distribution</b>. This will dictate how the genome can be split up for optimal processing efficiency (since for a give split size, the more even the distribution of sizes, the faster the processing)</li>
										<ul class="bullet1 indent2">
											<li><b>Example 1</b>: A "finished" genome with 9 large superscaffolds (or pseudomolecules) and 500 smaller scaffolds can be split into a maximum of 10 roughly similar-sized subfiles (since subdividing a single scaffold is not possible). Smaller splits are possible (e.g. 8 subfiles) at the expense of having a larger maximum subfile size.
											</li>
											<li><b>Example 2</b>: A "draft" genome with 7500 smaller, size-distributed scaffolds can be split up into 2, 4, 8, 12, 24, or even more subfiles.
											</li>
										</ul>
									<li>Based on this analysis, select the "Number of Threads" for your job using the <i>Jobs</i> &rarr; <i>Configure</i> page. For the <b>Examples 1 and 2</b> above:</li>
										<ul class="bullet1 indent2">
											<li>GeneSeqer configured with <b>16 threads</b> would use 2, 8-core processors, each handling half of the genome files and distributing query sequence analysis across 8 cores; 24 threads would use 3 processors each handling 1/3 of the genome, and so on with increasing efficiency (reduced job time).
											</li>
											<li>GenomeThreader configured with 12 threads would use <b>10 of the 12 available cores</b> (from 2 hex-core processors) to process 10 genome subfiles. For <b>Example 1</b>, no further efficiency could be gained due to the uneven size distribution, but for <b>Example 2</b>, additional processors (resulting in 18, 24, 30, etc., threads) would likely lead to increasing efficiency.
											</li>
										</ul>
									<li>Next consider the genome's <b>overall size:</b> together with your split strategy: the larger the genome (for a given split), the longer the processing time. Compare your setup to the <a href="#Benchmarks">Benchmark Examples Table</a> below to determine likely completion time.
										<ul class="bullet1 indent2">
											<li>If you know about how long a job should take, and are running it as part of a <b>GDB pipeline</b> by setting a <b>conservative (short) processing time</b> you will insure that if something goes wrong your job will not waste resources if unattended and the xGDBvm pipeline can continue.
											</li>
											<li>For untested genomes you may want to set a comfortably <b>long processing time</b> (up to the 24 hr hard maximum), during which you can monitor the process and terminate it if indeed there is a problem.
											</li>
										</ul>
									</li>
									<li>The number (density) of potential alignments is another factor to consider, independent of the genome and query size.
										<ul class="bullet1 indent2">
											<li>A query set of highly similar transcript sequences (e.g. the same species) will have a greater probability of one or more significant matches and will take longer to process than a dataset from a related species.
											</li>
											<li>A genome and/or query dataset including <b>low complexity sequences</b> will produce a high density of alignments and may prevent the job from finishing (see next item)
											</li>
										</ul>
									</li>
									<li>Finally, make sure your input file is appropriately <b>repeat masked</b>:
										<ul class="bullet1 indent2">
											<li>For GeneSeqer, <b>hard masking</b> (using 'N') is HIGHLY RECOMMENDED; otherwise you are likely to use up significant computing resources with highly repeated alignments.
											</li>
											<li>For GenomeThreader, repeat masking is usually optional, but make sure you use hard masking with 'N' and NOT 'X' as a character (GenomeThreader does not recognize 'X' at a nucleotide position).
											</li>
										</ul>
									</li>
								</ol>

						</div>
						<div class="feature" id="Programs">
                        <h2> HPC Programs and Parameters</h3>
						<p><a href="https://github.com/BrendelGroup/GeneSeqer/blob/master/0README">GeneSeqer-MPI</a> is used for spliced alignment of transcript (EST, cDNA or TSA) to genome using the <a href="https://www.tacc.utexas.edu/user-services/user-guides/stampede-user-guide">Stampede</a> server at TACC. 
						MPI handles the distribution of analyses across cores.  With 8 cores per processor and 2 processors per node on Stampede, the "processing unit" is 16 cores corresponding to a genome split of 2.
						<br />
						<a href="http://www.genomethreader.org/">GenomeThreader</a> is used for spliced alignment of protein sequences (back-translated) to genomic DNA on <a href="https://www.tacc.utexas.edu/user-services/user-guides/lonestar-user-guide">Lonestar</a>. Since MPI is not available, query sequences are copied to multiple nodes which are managed by TACC's load balancing software.
                        With 6 cores per processor and 2 processors per node on Lonestar, the basic computational "unit" is 12 threads corresponding to a genome split of 12. 
                        </p>
						<div class="indent2"><table class="featuretable topmargin2">
						<caption style="font-weight:bold; text-align:left" class="bottommargin1">Current user-configurable parameters are in <span class="alertnotice bold">red</span>. These can be modified from the <a href=\"/XGDB/jobs/configure.php\">Configure</a> page</caption>
						<colgroup>
							<col width="10%" />
							<col width="15%" />
							<col width="10%" />
							<col width="25%" />
							<col width="5%" />
							<col width="5%" />
							<col width="10%" />
							<col width="5%" />
							<col width="5%" />
					
						</colgroup>
						<tr style="text-align: center" class="reverse_1 bold">
							<th>TACC Server
							</th>
							<th>Program
							</th>
							<th>Version Currently Configured
							</th>
							<th>Processor Architecture
							</th>
							<th>Threads Per Processor Pair
							</th>
							<th>Threads Currently Configured
							</th>
							<th>Current Genome Sequence Split
							</th>
							<th>Query Sequence Split
							</th>
							<th>Memory Configured per Thread
							</th>
							<th>Max Processing Time (h)
							</th>
							
						</tr>
						<tr style="text-align: center" >
							<td><a href="https://www.tacc.utexas.edu/user-services/user-guides/stampede-user-guide">Stampede (TACC)</a>
							</td>
							<td><a href="https://github.com/BrendelGroup/GeneSeqer/blob/master/0README">GeneSeqer-MPI</a>
							</td>
							<td class="alertnotice bold"><?php echo $gsq_software ?>
							</td>
							<td>2 8-core Xeon E5 processors with 32GB/node
							</td>
							<td>2 x 8 = 16
							</td>
							<td class="alertnotice bold"><?php echo $gsq_proc ?>
							</td>
							<td>number of processors/8 <br />(<span class="alertnotice bold"><?php echo $gsq_proc/8 ?></span> files)
							</td>
							<td> 30 MB chunks
							</td>
							<td class="alertnotice bold">2 MB
							</td>
							<td class="alertnotice bold"><?php echo $gsq_job_time ?>
							</td>
						</tr>
					    <tr style="text-align: center">
							<td><a href="https://www.tacc.utexas.edu/user-services/user-guides/lonestar-user-guide">Lonestar (TACC)</a>
							</td>
							<td><a href="http://www.genomethreader.org/">GenomeThreader</a>
							</td>
							<td class="alertnotice bold"><?php echo $gth_software ?>
							</td>
							<td>2 Hex-core Xeon 5680 processors
							</td>
							<td>2 x 6 = 12
							</td>
							<td class="alertnotice bold"><?php echo $gth_proc ?>
							</td>
							<td>nubmer of threads<br /> (<span class="alertnotice bold"><?php echo $gth_proc ?> </span>files)
							</td>
							<td>none
							</td>
							<td  class="alertnotice bold">2 MB
							</td>
							<td class="alertnotice bold"><?php echo $gth_job_time ?>
							</td>
						</tr>
						</table>
						</div>
					</div><!-- end feature-->
					<div class="feature" id="Monitor">
                        <h2 class="topmargin1"> How to monitor job progress</h3>
						<p>The <a href="/XGDB/jobs/jobs.php">xGDBvm Job List</a> page displays all jobs submitted from this VM, and you can monitor status by clicking <img src="/XGDB/images/update_arrow.png" /> in the appropriate column. iPlant's Foundation API allows you to monitor job progress in more detail and view intermediate files using <a href="https://foundation.iplantcollaborative.org/iplant-test/">Foundation API page</a>. You will need to log in with your iPlant ID, and then open the 'Jobs' section and click the 'Magnifying Glass' to view output files.</p>
						<p>When your job completes, the output date are archived on your Data Store in the following path: <span class="plaintext">/username/archive/jobs/job-12345-job_name/</span>. For pipeline jobs, the output is automatically copied to the scratch directory for further processing. In addition, on the <a href="/XGDB/jobs/jobs.php">xGDBvm Job List</a> page you can <img src="/XGDB/images/count_magnify.png" /> <b>count</b> any job's output and even <img src="/XGDB/images/copy_to_input.png" /> <b>copy</b> it to your input directory. 
						</p>
					</div>
	            <div class="feature" id="Examples" >
                    <h2 class="topmargin1 bottommargin1">Benchmarking Examples</h2>
                    <p>Study the examples listed below to determine what parameters to set to insure that your job will be completed within the time window.</p>
                            <div class="indent2">
                                <div class="feature" id="geneseqer1">			
                                                <?php include_once("/xGDBvm/XGDB/help/includes/jobs_gsq_examples.inc.php"); ?>
                                </div>
                            </div>
                            <div class="indent2">
                                <div class="feature" id="genomethreader1">			
                                                <?php include_once("/xGDBvm/XGDB/help/includes/jobs_gth_examples.inc.php"); ?>
                                </div>

                            </div><!--end indent2-->		
   					</div>
 
					</div><!--end maincontentsfull-->
				  <div style="clear:both; float:right">
							<a href="http://validator.w3.org/check?uri=referer"><img
							  src="http://www.w3.org/Icons/valid-xhtml10" alt="Valid XHTML 1.0 Transitional" height="15" width="44" /></a>
				  </div>						
				</div><!--end maincontentscontainer-->
				</div><!--pagewidth-->

				<?php include($XGDB_FOOTER); ?>
			</div><!--end innercontainer-->
		</div><!--end outercontainer-->
	</body>
</html>