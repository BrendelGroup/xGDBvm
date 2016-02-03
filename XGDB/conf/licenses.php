<?php
error_reporting(E_ALL & ~E_NOTICE); //disable undeclared variable error
session_start();

####### Set POST validation variable for this browser session #######

$valid_post = hash('sha512', mt_rand()*time()); # insure POST identity
$_SESSION['valid'] = $valid_post;

$global_DB= 'Genomes';
$PageTitle = 'xGDBvm Licenses';
$pgdbmenu = 'Manage';
$submenu1 = 'Config-Home';
$submenu2 = 'Config-Licenses';
$leftmenu='Config-Licenses';
$warning_msg='';
include_once('sitedef.php');
include_once($XGDB_HEADER);
include_once(dirname(__FILE__).'/conf_functions.inc.php');
include_once(dirname(__FILE__).'/validate.php');
include_once('/xGDBvm/XGDB/phplib/db.inc.php');

$inputDir=$XGDB_INPUTDIR; # 1-26-16 J Duvick
$dataDir=$XGDB_DATADIR; # 1-26-16 J Duvick

$dbpass=dbpass();

$db = mysql_connect("localhost", "gdbuser", $dbpass);
if(!$db)
{
    echo "Error: Could not connect to database!";
    exit;
}
mysql_select_db("$global_DB");
$error = $_GET['error'];

# Validate license keys (conf_functions.inc.php validate_dir($dir, $target, $description, $present, $absent)
$validate_gm=validate_dir($GENEMARK_KEY_DIR, $GENEMARK_KEY, "GeneMark License Key", "installed", "not installed");
$gm_valid=$validate_gm[0]; $gm_class=$validate_gm[1];
$validate_gth=validate_dir($GENOMETHREADER_KEY_DIR, $GENOMETHREADER_KEY, "GenomeThreader License Key", "installed", "not installed");
$gth_valid=$validate_gth[0]; $gth_class=$validate_gth[1];
$validate_vm=validate_dir($VMATCH_KEY_DIR, $VMATCH_KEY, "Vmatch License Key","installed", "not installed");
$vm_valid=$validate_vm[0]; $vm_class=$validate_vm[1];

# Get license details from datastore-cached keys

$gth_datastore = read_license_contents("$inputDir/keys/gth.lic");
$gth_ds_error = $gth_datastore[0];
$gth_ds_expiry = $gth_datastore[5];

$vm_datastore = read_license_contents("$inputDir/keys/vmatch.lic");
$vm_ds_error = $vm_datastore[0];
$vm_ds_expiry = $vm_datastore[5];

# Get license details from VM-installed keys and flag if of out date

global $gth_out_of_date, $vm_out_of_date;

if($gth_valid=="installed")
{
    $gth_installed = read_license_contents("${GENOMETHREADER_KEY_DIR}/${GENOMETHREADER_KEY}");
    $gth_inst_error = $gth_installed[0];
    $gth_inst_expiry = $gth_installed[5];
    $gth_out_of_date = ($gth_ds_expiry > $gth_inst_expiry)?"<span class=\"alertnotice\"> but is out of date!</span>":" and is up to date";
}
if($vm_valid=="installed")
{
    $vm_installed = read_license_contents("${VMATCH_KEY_DIR}/${VMATCH_KEY}");
    $vm_error = $vm_installed[0];
    $vm_inst_expiry = $vm_installed[5];
    $vm_out_of_date = ($vm_ds_expiry > $vm_inst_expiry)?"<span class=\"alertnotice\"> but out of date!</span>":" and is up to date";
}

# Construct form buttons

$gth_button=
"
                    <span class=\"\">
                    <form method=\"post\" action=\"/XGDB/conf/key_exec.php\" class=\"styled topmargin1\">
                        <input type=\"hidden\" name=\"action\" value=\"gth\" />
                        <input type=\"hidden\" name=\"valid\" value=\"$valid_post\" />
                        <input type=\"hidden\" name=\"redirect\" value=\"licenses\" />
                        <input style=\"width:200px\" id=\"keys1\" class=\"  submit\"  type=\"submit\" value=\"(Re)Install GTH Key\" onclick=\"return confirm('Really install? (make sure file is in place)')\" />
                    </form>
                    </span>

";

$vm_button=
"
                    <span class=\"\">
                    <form method=\"post\" action=\"/XGDB/conf/key_exec.php\" class=\"styled topmargin1\">
                        <input type=\"hidden\" name=\"action\" value=\"vm\" />
                        <input type=\"hidden\" name=\"valid\" value=\"$valid_post\" />
                        <input type=\"hidden\" name=\"redirect\" value=\"licenses\" />
                        <input style=\"width:200px\" id=\"keys2\" class=\"  submit\"  type=\"submit\" value=\"(Re)Install Vmatch Key\" onclick=\"return confirm('Really install? (make sure file is in place)')\" />
                    </form>
                    </span>
";

$gm_button=
"
                    <span class=\"\">
                    <form method=\"post\" action=\"/XGDB/conf/key_exec.php\" class=\"styled topmargin1\">
                        <input type=\"hidden\" name=\"action\" value=\"gm\" />
                        <input type=\"hidden\" name=\"valid\" value=\"$valid_post\" />
                        <input type=\"hidden\" name=\"redirect\" value=\"licenses\" />
                        <input style=\"width:200px\" id=\"keys3\" class=\"  submit\"  type=\"submit\" value=\"(Re)Install GeneMark Key\" onclick=\"return confirm('Really install? (make sure file is in place)')\" />
                    </form>
                    </span>

";

$no_file_text="<b>To (re)install:</b> Place license key file on your data volume under <span class=\"plaintext\">$inputDir/keys/</span>. 'Install' button will appear";

## from sitedef.php
$gm_key=$GENEMARK_KEY; //e.g. ".gm_key";
$gm_key_alt=str_replace('.','', $gm_key); // e.g. "gm_key"
$gth_key=$GENOMETHREADER_KEY; //e.g. "gth.lic";
$vm_key=$VMATCH_KEY; //e.g. "vmatch.lic";

# valid paths
$gm_path="$inputDir/keys/$gm_key";
$gm_path_alt="$inputDir/keys/$gm_key_alt";
$gth_path="$inputDir/keys/$gth_key";
$vm_path="$inputDir/keys/$vm_key";

#button or text (displayed below)
$gm_validate=(file_exists($gm_path) || file_exists($gm_path_alt))?$gm_button:$no_file_text;
$gth_validate=(file_exists($gth_path))?$gth_button:$no_file_text;
$vm_validate=(file_exists($vm_path))?$vm_button:$no_file_text;


	?>
                    <div id="leftcolumncontainer">
                        <div class="minicolumnleft">
                        <?php include_once("/xGDBvm/XGDB/conf/leftmenu.inc.php"); ?>
                        </div>
                    </div>
                        <div id="maincontentscontainer" class="twocolumn overflow configure">
                            <div id="maincontentsfull" class="configure">
                                    <h1 class="configure bottommargin1"><img alt="" src="/XGDB/images/configure.png" /> License Keys <img id='config_licenses' title='Check status &amp; install software licenses Click ? for details.' class='help-button nudge1' src='/XGDB/images/help-icon.png' alt='?' /></h1>
                                     <h2 class="bottommargin1">xGDBvm includes software that requires end user licenses; status indicated below</h2>
                                <div class="featurediv">
                                     <p>If keys are not installed, you can obtain and install them:</p>
                                     <ul class="bullet1 indent2">
                                    <li>See links below or visit <a href="http://goblinx.soic.indiana.edu/wiki/doku.php?id=licenses">Wiki: Licenses</a> to obtain <b>license key files</b> (named as below).</li>
                                    <li>Upload each license key file to the 'keys' directory in your Data Store (which must be mounted to this VM). 
                                    	<ul class="bullet1">
                                    		<li>Navigate to the iPlant Discovery Environment <a href="http://preview.iplantcollaborative.org/de/?type=data">Data Tool</a>. </li>
                                    		<li>Click the <b>keys</b> directory under your username directory and then click 'Upload'.</li>
                                   	</ul>
                                    </li>
                                    <li>If correct key file is uploaded, an 'Install' button will be visible below for each key. Click each in turn to install on your VM.</li>
                                    <li>Be sure to note license <b>expiration date</b>, and re-install as necessary before expiry date is passed</li>
                                </ul>
                            </div>
                            <div class="feature" id="gth">
                                        <h2 class="topmargin1 bottommmargin1"><b>GenomeThreader</b> spliced alignment software</h2>
                                            <ul class="featurelist indent2">
                                                <li><b>Preloaded:</b>This VM includes a free license to use GenomeThreader for up to 1 year (non-commercial use only).
                                     <li><b>Expiry:</b> <?php echo $gth_ds_expiry; echo $gth_ds_error; ?></li>
                                                <li><b>Source:</b>
                                                        Gordon Gremme at <a title="GenomeThreader license" href="http://www.genomethreader.org/cgi-bin/download.cgi">http://www.genomethreader.org/cgi-bin/download.cgi</a> 
                                                </li>
                                                <li><b>License Install Path:</b>
                                                    <span class="plaintext largerfont">
                                                        <?php echo "$GENOMETHREADER_KEY_DIR<span class='alertnotice'>$GENOMETHREADER_KEY</span>" ?> 
                                                    </span>
                                                </li>
                                                <li><span class="<?php echo $gth_class ?>">
                                                    GenomeThreader License Key is <?php echo $gth_valid ?> on this VM <?php echo $gth_out_of_date ?>
                                                </span>
                                                </li>
                                                <li>
                                    <?php echo $gth_validate ?> 
                                                </li>
                                            </ul>
                                        </div>
                                        <div class="feature" id="vm">
                                       <h2 class="topmargin1 bottommmargin1"><b>Vmatch</b> sequence analysis software</h2>
                                            <ul class="featurelist indent2">
                                                <li><b>Preloaded:</b>This VM includes a free license to use Vmatch for up to 1 year (non-commercial use only).
                                                <li><b>Expiry:</b> <?php echo $vm_ds_expiry; echo $vm_ds_error; ?></li>
                                                 <li><b>Source:</b>
                                                        Gordon Gremme at <a title="Vmatch license" href="http://www.vmatch.de/Vmatchlic.pdf">http://www.vmatch.de/Vmatchlic.pdf</a> 
                                                </li>
                                               <li><b>License Install Path:</b>
                                                    <span class="plaintext largerfont">
                                                        <?php echo "$VMATCH_KEY_DIR<span class='alertnotice'>$VMATCH_KEY</span>" ?> 
                                                    </span>
                                                </li>
                                                <li><span class="<?php echo $vm_class ?>" >
                                                    Vmatch License Key is <?php echo $vm_valid ?> on this VM <?php echo $vm_out_of_date ?>
                                                </span>
                                                </li>
                                                 <li>
                                    <?php echo $vm_validate ?>
                                                </li>
                                             </ul>
                                        </div>
                                        <div class="feature" id="gm">
                                        <h2 class="topmargin1 bottommmargin1"><b>GeneMark</b> de novo genefinder software</h2>
                                            <ul class="featurelist indent2">
                                                <li><b>Source:</b>
                                                     <a title="GeneMark home page" href="http://exon.biology.gatech.edu/">http://exon.biology.gatech.edu</a>
                                                </li>
                                                 <li><b>License:</b>
                                                        Obtained from Mark Borodovsky at <a title="GeneMark license" href="http://exon.gatech.edu/license_download.cgi">http://exon.gatech.edu/license_download.cgi</a> 
                                                </li>
                                                <li><b>License Install Path:</b>
                                                    <span class="plaintext largerfont">
                                                        <?php echo "$GENEMARK_KEY_DIR<span class='alertnotice'>$GENEMARK_KEY</span>" ?> 
                                                    </span>
                                                </li>
                                                <li><span class="<?php echo $gm_class ?>">
                                                    GeneMark License Key is <?php echo $gm_valid ?> on this VM
                                                </span>
                                                </li>
                                                <li>
                                    <?php echo $gm_validate ?>
                                                </li>
                                              </ul>
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
