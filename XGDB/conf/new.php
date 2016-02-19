<?php
#error_reporting(E_ALL & ~E_NOTICE); //disable undeclared variable error
session_start();
$VM=`uname -n|cut -d "." -f 1`; # identifies this VM 
$VM=preg_replace( "/\r|\n/", "", $VM ); // strip line feed
$global_DB= 'Genomes';
$PageTitle = 'xGDBvm Create New';
$pgdbmenu = 'Manage';
$submenu1 = 'Config-Home';
$submenu2 = 'Config-New';
$leftmenu='Config-Add';
include('sitedef.php');
include($XGDB_HEADER);
include_once(dirname(__FILE__).'/validate.php');
include_once(dirname(__FILE__).'/conf_functions.inc.php');
include_once('/xGDBvm/XGDB/phplib/db.inc.php');

$inputDir=$XGDB_INPUTDIR; # 1-26-16 J Duvick: the symlinked input directory, e.g. /xGDBvm/input/xgdbvm/
$dataDir=$XGDB_DATADIR; # 1-26-16 J Duvick:  the symlinked data output directory, e.g. /xGDBvm/data/

$dbpass=dbpass();
	$db = mysql_connect("localhost", "gdbuser", $dbpass);
	if(!$db)
	{
		echo "Error: Could not connect to database!";
		exit;
	}
date_default_timezone_set("$TIMEZONE");

## Defaults
	$font_display="xgdb_new";
	$Input_Data_Path="/xGDBvm/input/xgdbvm/";
	$GFF_Type="CpGAT"; 
	$Genome_Type="Scaffold";
	$CPGATparameter="";
	$CpGAT_ReferenceProt_File ="/xGDBvm/examples/referenceprotein/cegma_core.fa";
	$RepeatMask_File="/xGDBvm/examples/repeatmask/mipsREdat_9.3p_ALL.fasta"; 
	$view_button="display_on";//
	$save_button =" &nbsp;&nbsp;&nbsp; Save New &nbsp;&nbsp;&nbsp;"; // save button
	$display_load_archive=""; // display 'Load Archive' button and dropdown
	
	global $DBname,$Organism,$Common_Name,$Create_Date,$Input_Data_Path,$Status,$Genome_Type,$Genome_Source,$Genome_Source_Link;
	global $Genome_Comments,$Genome_Version,$Genome_Count,$Chromosome_Count,$Unlinked_Chromosome_Count,$Scaffold_Count;
	global $BAC_Count,$GeneModel_Version,$GeneModel_Source,$GeneModel_Link,$GeneModel_Comments;
	global $EST_Align_sp,$EST_Align_Version,$EST_Align_Comments,$cDNA_Align_sp,$cDNA_Align_Version,$cDNA_Align_Comments;
	global $PUT_Align_sp,$PUT_Align_Version,$PUT_Align_Comments,$Prot_Align_sp,$Prot_Align_Comments,$Prot_Align_Version;
	global $Default_GSEG,$Default_lpos,$Default_rpos,$yrGATE_Reference,$GFF_Type,$Update_Status,$Update_Data_Path;
	global $Update_Data_EST,$Update_Data_cDNA,$Update_Data_TrAssembly,$Update_Data_Protein,$Update_Data_GSEG;
	global $Update_Data_GeneModel,$Update_Descriptions,$Update_Date,$Species_Model,$Alignment_Stringency;
	global $Gth_Species_Model,$Update_Comments,$CpGAT_Status,$CpGAT_ReferenceProt_File,$RepeatMask_File;
	global $CpGAT_BGF,$CpGAT_Augustus,$CpGAT_GeneMark,$CpGAT_Skip_Mask,$CpGAT_Relax_UniRef;
	global $CpGAT_Skip_PASA,$CpGAT_Filter_Genes,$Update_Data_CpGAT,$RepeatMask_Status,$GSQ_CompResources,$GTH_CompResources;

### get Admin's yrgate email address , if any. NOTE:  NOT YET TESTED!!! ###



$get_yrgate_email="SELECT uid, yrgate_admin_email from Admin.admin where yrgate_admin_email !='' order by uid ASC limit 0,1";
		 $mysql_get_yrgate_email= mysql_query($get_yrgate_email); 
			while($data_get_yrgate_email = mysql_fetch_array($mysql_get_yrgate_email)){
			$yrGATE_Admin_Email=$data_get_yrgate_email['yrgate_admin_email'];
		}


#Get Example data, if any (two-column format; see http://www.homeandlearn.co.uk/php/php10p7.html)
    $get_example=isset($_GET['example'])?$_GET['example']:"";
	if ($get_example !="")
	{
		$ID = intval($get_example); 
		$view_button = ($ID=='All')?"display_off":""; //Hide 'Save' button unless an individual example has been selected    			
		if($ID > 0 && $ID<12)
		{
		$filename = "/xGDBvm/examples/example".$ID."/GenomesExample".$ID.".txt";
		$data=get_example_data($filename); #get array of example data (conf_functions.inc.php)


//      note array starts with $data[0] which is example number, not needed for MySQL

				$DBname=$data["DBname"];
				$Organism=$data["Organism"];
				$Common_Name=$data["Common_Name"];
				$Create_Date=$data["Create_Date"]; 
				$Input_Data_Path=$data["Input_Data_Path"];
				$Status=$data["Status"];
				$Genome_Type=$data["Genome_Type"];
				$Genome_Source=$data["Genome_Source"]; 
				$Genome_Source_Link=$data["Genome_Source_Link"];
				$Genome_Comments=$data["Genome_Comments"];
				$Genome_Version=$data["Genome_Version"]; 
				$Genome_Count=$data["Genome_Count"];
				$Chromosome_Count=$data["Chromosome_Count"];
				$Unlinked_Chromosome_Count=$data["Unlinked_Chromosome_Count"];
				$Scaffold_Count=$data["Scaffold_Count"];
				$BAC_Count=$data["BAC_Count"];
				$GeneModel_Version=$data["GeneModel_Version"];
				$GeneModel_Source=$data["GeneModel_Source"];
				$GeneModel_Link=$data["GeneModel_Link"];
				$GeneModel_Comments=$data["GeneModel_Comments"];
				$EST_Align_sp=$data["EST_Align_sp"];
				$EST_Align_Version=$data["EST_Align_Version"];
				$EST_Align_Comments=$data["EST_Align_Comments"];
				$cDNA_Align_sp=$data["cDNA_Align_sp"];
				$cDNA_Align_Version=$data["cDNA_Align_Version"];
				$cDNA_Align_Comments=$data["cDNA_Align_Comments"];
				$PUT_Align_sp=$data["PUT_Align_sp"];
				$PUT_Align_Version=$data["PUT_Align_Version"];
				$PUT_Align_Comments=$data["PUT_Align_Comments"];
				$Prot_Align_sp=$data["Prot_Align_sp"];       
				$Prot_Align_Comments=$data["Prot_Align_Comments"];
				$Prot_Align_Version=$data["Prot_Align_Version"];
				$Default_GSEG=$data["Default_GSEG"];
				$Default_lpos=$data["Default_lpos"];
				$Default_rpos=$data["Default_rpos"];
				$yrGATE_Reference=$data["yrGATE_Reference"];
				$GFF_Type=$data["GFF_Type"];
				$Update_Status=$data["Update_Status"];
				$Update_Data_Path=$data["Update_Data_Path"];
				$Update_Data_EST=$data["Update_Data_EST"];
				$Update_Data_cDNA=$data["Update_Data_cDNA"];
				$Update_Data_TrAssembly=$data["Update_Data_TrAssembly"];
				$Update_Data_Protein=$data["Update_Data_Protein"];
				$Update_Data_GSEG=$data["Update_Data_GSEG"];
				$Update_Data_GeneModel=$data["Update_Data_GeneModel"];
				$Update_Descriptions=$data["Update_Descriptions"];
				$Update_Date=$data["Update_Date"];
				$Species_Model=$data["Species_Model"];
				$Alignment_Stringency=$data["Alignment_Stringency"];
				$Gth_Species_Model=$data["Gth_Species_Model"];	
				$Update_Comments=$data["Update_Comments"];
				$CpGAT_Status=$data["CpGAT_Status"];
				$CpGAT_ReferenceProt_File=$data["CpGAT_ReferenceProt_File"];
				$RepeatMask_File=$data["RepeatMask_File"];
				$CpGAT_BGF=$data["CpGAT_BGF"];
				$CpGAT_Augustus=$data["CpGAT_Augustus"];
				$CpGAT_GeneMark=$data["CpGAT_GeneMark"];
				$CpGAT_Skip_Mask=$data["CpGAT_Skip_Mask"];
				$CpGAT_Relax_UniRef=$data["CpGAT_Relax_UniRef"];
				$CpGAT_Skip_PASA=$data["CpGAT_Skip_PASA"];
				$CpGAT_Filter_Genes=$data["CpGAT_Filter_Genes"];
				$Update_Data_CpGAT=$data["Update_Data_CpGAT"];
				$RepeatMask_Status=$data["RepeatMask_Status"];
				$GSQ_CompResources=$data["GSQ_CompResources"];
				$GTH_CompResources=$data["GTH_CompResources"];
		}


		$heading_text ="  New GDB Configuration: Example Dataset ${ID}";
		$save_text="<p class=\"instruction bottommargin2\">Click 'Save' to proceed with Example $ID. You may also <a href='/XGDB/conf/new.php'>clear the form</a> and enter your own genome information &amp; data path </p> <p><a href='/XGDB/conf/new.php?example=All'>View All Examples Again</a> &nbsp; | &nbsp; <a href=\"/XGDB/conf/new.php\">Hide Examples</a></p>";

#### For loading example options, we want to display example text and save button text based on ID submitted ####
		$text=get_example_text($ID, $save_text);# get example text and button info depending on ID chosen (conf_functions.inc.php)
		$Example_Text=$text[0];
		$save_button=$text[1];

		$heading_text ="Configure New GDB: Examples";
		$instructions_text= "$Example_Text";	
	}
	else
	{ // no GET ID in force
		
		$heading_text ="Configure New GDB ";
		$instructions_text="<p class=\"instruction\"> Enter configuration details below. Note required fields (<span class=\"required\"></span>). Then click 'Save' to proceed to the next step, or <a href='/XGDB/conf/new.php'>Cancel</a> to clear form.</p>
		
		<p class=\"instruction\"><span class=\"tip_style\">Tip:  Try creating a GDB using one of our <a class= 'long xgdb_button colorR6 ' href='/XGDB/conf/new.php?example=All'>Example Datasets.</a> </span><img id='config_examples' title='Configure: Example Datasets' class='help-button  nudge2' src='/XGDB/images/help-icon.png' alt='?' /></p>";
		}


########## flag any extraneous GDB in /data/ or /INSTANCES/ and if so create warning text

$extra_data=checkExtra("data"); //flag any extraneous GDB in data 
if(!empty($extra_data)){
	foreach($extra_data as $data_item){
		$extra_data_list.= "$data_item ";
		}
		
	$extra_data_msg= "<div class=\"warningcontainer $warning\"><span class=\"warning normalfont\">Warning! The GDB directory or directories below, found under <a href=\"$dataDir\">$dataDir</a>, is not associated with any <span class=\"Current\">Current</span> GDB.  Please rename or delete before proceeding:
	&rarr; <a id='config_extra_dir_data' title='Click for more info' class='help-button link'>Click for more information </a> </span>
	<pre class=\"large topmargin1\">
	$extra_data_list
	</pre></div>";
$instructions_text.="$extra_data_msg";
	}
		
####### Set dropdown and radio button values and defaults based on Example data (if any) ###

#General#
$checked="checked=\"checked\"";
$selected="selected=\"selected\"";
$GFF_CpGAT_checked = ($GFF_Type == "CpGAT")? $checked:"";
$GFF_Other_checked = ($GFF_Type == "Other")? $checked:"";
$GType_Scaff_selected = ($Genome_Type == "Scaffold")? $selected :"";
$GType_Chr_selected = ($Genome_Type == "Chromosome")? $selected :"";
$GType_BAC_selected = ($Genome_Type == "BAC")? $selected :"";
$GType_ChrScaff_selected = ($Genome_Type == "Chromosome/Scaffold")? $selected :"";
$GType_BACScaff_selected = ($Genome_Type == "BAC/Scaffold")? $selected :"";

#GSQ_RepeatMask
$RepeatMask_no_checked =($RepeatMask_Status == "")? $checked:"";
$RepeatMask_yes_checked =($RepeatMask_Status == "Yes")? $checked:"";

#CompRes
$GSQ_External_checked =($GSQ_CompResources == "Remote")? $checked:"";
$GSQ_Internal_checked =($GSQ_CompResources == "")? $checked: ($GSQ_Internal_checked = ($GSQ_CompResources == "Local")? $checked:""); #default or currently assigned value (e.g. from loaded example);
$GTH_External_checked =($GTH_CompResources == "Remote")? $checked:"";
$GTH_Internal_checked =($GTH_CompResources == "")? $checked: ($GTH_Internal_checked = ($GTH_CompResources == "Local")? $checked:""); #default or currently assigned value (e.g. from loaded example);

#Spliced Alignment#
$maize_checked = ($Species_Model == "")? $checked : ($maize_checked = ($Species_Model == "maize")? $checked:""); #default or currently assigned value (e.g. from loaded example)
$rice_checked = ($Species_Model == "rice")? $checked :"";
$Arabidopsis_checked = ($Species_Model == "Arabidopsis")? $checked :"";
$Medicago_checked = ($Species_Model == "Medicago")? $checked :"";
$Fruitfly_checked = ($Species_Model == "Drosophila")? $checked : "";


$Strict_Stringency_checked = ($Alignment_Stringency == "")? $checked : ($Strict_Stringency_checked = ($Alignment_Stringency == "Strict")? $checked:""); #default or currently assigned value
$Moderate_Stringency_checked = ($Alignment_Stringency == "Moderate")? $checked :"";
$Low_Stringency_checked = ($Alignment_Stringency == "Low")? $checked :"";

$gth_maize_checked = ($Gth_Species_Model == "")? $checked : ($gth_maize_checked = ($Gth_Species_Model == "maize")? $checked:""); #default or currently assigned value
$gth_rice_checked = ($Gth_Species_Model == "rice")? $checked :"";
$gth_arabidopsis_checked = ($Gth_Species_Model == "arabidopsis")? $checked :"";
$gth_medicago_checked = ($Gth_Species_Model == "medicago")? $checked :"";
$gth_drosophila_checked = ($Gth_Species_Model == "drosophila")? $checked : "";

#CpGAT
$CpGAT_Status_no_checked =($CpGAT_Status == "")? $checked:"";
$CpGAT_Status_yes_checked =($CpGAT_Status == "Yes")? $checked:"";

#yrGATE_Reference (which gene model dataset to use as reference in yrGATE)
$yrGATE_Ref_pre_checked = ($yrGATE_Reference == "")? $checked : ($yrGATE_Ref_pre_checked = ($yrGATE_Reference == "Precomputed")? $checked:""); #default or currently assigned value
$yrGATE_Ref_cpgat_checked =($yrGATE_Reference == "CpGAT")? $checked:"";

$Skip_BGF_checked = ($CpGAT_BGF == "Skip")? $checked :"";
$Arabidopsis_BGF_checked = ($CpGAT_BGF == "Arabidopsis")? $checked :"";
$Fruitfly_BGF_checked = ($CpGAT_BGF == "")? $checked : ($Fruitfly_BGF_checked = ($CpGAT_BGF == "Fruitfly")? $checked: "");;
$maize_BGF_checked = ($CpGAT_BGF == "")? $checked:""; #default or currently assigned value
$rice_BGF_checked = ($CpGAT_BGF == "rice")? $checked :"";
$Silkworm_BGF_checked = ($CpGAT_BGF == "Silkworm")? $checked :"";
$soybean_BGF_checked = ($CpGAT_BGF == "soybean")? $checked :"";

$Skip_Augustus_checked = ($CpGAT_Augustus == "Skip")? $checked :"";
$arabidopsis_Augustus_checked = ($CpGAT_Augustus == "arabidopsis")? $checked :"";
$chlamydomonas_Augustus_checked = ($CpGAT_Augustus == "chlamydomonas")? $checked :"";
$fly_Augustus_checked = ($CpGAT_Augustus == "fly")? $checked : ($fly_Augustus_checked = ($CpGAT_Augustus == "fly")? $checked:"");;
$maize_Augustus_checked = ($CpGAT_Augustus == "")? $checked:""; #default or currently assigned value
$tomato_Augustus_checked = ($CpGAT_Augustus == "tomato")? $checked :"";

$Skip_GeneMark_checked = ($CpGAT_GeneMark == "Skip")? $checked :"";
$a_thaliana_GeneMark_checked = ($CpGAT_GeneMark == "a_thaliana")? $checked :"";
$barley_GeneMark_checked = ($CpGAT_GeneMark == "barley")? $checked :"";
$c_reinhardtii_GeneMark_checked = ($CpGAT_GeneMark == "c_reinhardtii")? $checked :"";
$d_melanogaster_GeneMark_checked = ($CpGAT_GeneMark == "d_melanogaster")? $checked :"";
$corn_GeneMark_checked = ($CpGAT_GeneMark == "")? $checked : ($corn_GeneMark_checked = ($CpGAT_GeneMark == "corn")? $checked:""); #default or currently assigned value
$m_truncatula_GeneMark_checked = ($CpGAT_GeneMark == "m_truncatula")? $checked :"";
$o_sativa_GeneMark_checked = ($CpGAT_GeneMark == "o_sativa")? $checked :"";
$wheat_GeneMark_checked = ($CpGAT_GeneMark == "wheat")? $checked :"";


$CpGAT_Skip_Mask_yes_checked = ($CpGAT_Skip_Mask == "")? $checked : ($CpGAT_Skip_Mask_yes_checked = ($CpGAT_Skip_Mask == "Yes")? $checked:""); #default or currently assigned value
$CpGAT_Skip_Mask_no_checked = ($CpGAT_Skip_Mask == "No")? $checked :"";
$CpGAT_Relax_UniRef_no_checked = ($CpGAT_Relax_UniRef == "")? $checked : ($CpGAT_Relax_UniRef_no_checked = ($CpGAT_Relax_UniRef == "No")? $checked:""); #default or currently assigned value
$CpGAT_Relax_UniRef_yes_checked = ($CpGAT_Relax_UniRef == "Yes")? $checked :"";
$CpGAT_Skip_PASA_no_checked = ($CpGAT_Skip_PASA == "")? $checked : ($CpGAT_Skip_PASA_no_checked = ($CpGAT_Skip_PASA == "No")? $checked:""); #default or currently assigned value
$CpGAT_Skip_PASA_yes_checked = ($CpGAT_Skip_PASA == "Yes")? $checked : "";
$CpGAT_Filter_Genes_no_checked = ($CpGAT_Filter_Genes == "")? $checked : ($CpGAT_Filter_Genes_no_checked = ($CpGAT_Filter_Genes == "No")? $checked:""); #default or currently assigned value
$CpGAT_Filter_Genes_yes_checked = ($CpGAT_Filter_Genes == "Yes")? $checked :"";


# data directory:/data/ ($dir1)
$dir1_dropdown="$dataDir"; // 1-26-16

if (file_exists("/xGDBvm/admin/iplant")) { // xGDBvm-iPlant only
    $df_dir1=df_available($dir1_dropdown); // check if /data/ directory is externally mounted (returns array)
    $dir1_mount=(preg_match("/\/dev\/$EXT_MOUNT_DIR/", $df_dir1[0]))?"<span class=\"checked_mount\">Ext vol mounted</span>":"<span class=\"lightgrayfont\">Ext vol not mounted</span>"; //flag for dir1 mount
    $devloc=str_replace("/","\/",$EXT_MOUNT_DIR); // read from device location stored in /xGDBvm/admin/devloc via sitedef.php
    $dir1_mount=(preg_match("/$devloc/", $df_dir1[0]))?"<span class=\"checked_mount\">Ext vol mounted</span>":"<span class=\"lightgrayfont\">Ext vol not mounted</span>"; //flag for dir1 mount
    }
# data input directory: e.g. /input/xgdbvm/ ($dir2)
$dir2_dropdown="$inputDir"; // 1-26-16
if (file_exists("/xGDBvm/admin/iplant")) { // xGDBvm-iPlant only
    $df_dir2=df_available($dir2_dropdown); // check if /input/ directory is fuse-mounted (returns array)
#    $dir2_dropdown=($df_dir2[0]=="fuse"  || $df_dir2[0]=="irodsFs")?"$dir2_dropdown":""; //only show input dir if fuse-mounted DISABLED THIS REQUIREMENT 4/16/2014
    $dir2_mount=($df_dir2[0]=="fuse" || $df_dir2[0]=="irodsFs")?"<span class=\"checked_mount\">DataStore mounted</span>":"<span class=\"lightgrayfont\">DataStore not mounted</span>"; //flag for dir1 mount
    }
$dir3_dropdown="/xGDBvm/examples/";    // TODO: move to sitedef.php

$input_dirlist=dirlist_dropdown("", $dir2_dropdown, $dir3_dropdown, "$Input_Data_Path");//build dropdown for input dir(s). Note that access to dir1_dropdown (under /xGDBvm/data) is DISABLED -- this parameter is not sent.

# display mount status (iPlant only)
$dir1_status=(file_exists("/xGDBvm/admin/iplant"))?"<span class=\"normalfont\" style=\"font-weight:normal\">&nbsp; &nbsp;<a class='help-button' title='Mount status of $dataDir' id='config_input_ebs'>  $dir1_mount </a></span>":"";
$dir2_status=(file_exists("/xGDBvm/admin/iplant"))?"<span class=\"normalfont\" style=\"font-weight:normal\">&nbsp; &nbsp;<a class='help-button' title='Mount status of /xGDBvm/input/' id='config_input_input'> $dir2_mount </a></span>":"";

# repeat mask directory
$dir4_dropdown="$inputDir/repeatmask/";
$dir5_dropdown="/xGDBvm/examples/repeatmask/";
$repmask_dirlist=filelist_dropdown($dir4_dropdown,  $dir5_dropdown, "$RepeatMask_File");//build dropdown for input dir(s), to include /xGDBvm/input (preferred) or /xGDBvm/data 

# reference protein directory and files
$dir6_dropdown="$inputDir/referenceprotein/";
$dir7_dropdown="/xGDBvm/examples/referenceprotein/";
$refprot_dirlist=filelist_dropdown($dir6_dropdown,  $dir7_dropdown, "$CpGAT_ReferenceProt_File");//build dropdown for reference protein dir(s)

# archive directory list (top of form, conditional, allows user to load an archive config set) #
$archive_dirlist=archive_dir_dropdown($dataDir, "ArchiveGDB"); # updated 1-28-16 to include dataDir param
#$display_load_archive=($archive_dirlist=="" || $_GET['example'])?display_off:""; // conditional display
$display_load_archive=($archive_dirlist=="" || $get_example!="")?"display_off":""; // don't display archive list if it doesn't exist or if examples are being viewed

$display_block = "
<div class=\"description\">
    <form method=\"post\" action=\"/XGDB/conf/load_archive.exec.php\" name=\"load_archive\" class=\"styled\">
    <input type=\"hidden\" name=\"action\" value=\"new_load_archive\" /> 
        <table width=\"100%\" class=\"bottommargin2\">
            <tr>
                <td valign=\"middle\" align=\"left\" width=\"50%\">
                    <h1 class=\"configure $font_display \">
                        <img alt=\"?\" src=\"/XGDB/images/configure.png\" /> $heading_text <img id='config_new' title='Search Help' class='help-button' alt=\"\" src='/XGDB/images/help-icon.png' /> 	
                </h1>
        
                </td>
                <td align=\"left\" width=\"30%\">
                    <select name=\"file\" style=\"max-width:300px\" class=\"$display_load_archive\">
                        $archive_dirlist
                    </select>
                </td>
                <td align=\"right\" width=\"15%\">
                    <input id=\"load_archive\" class=\"submit cancel_style $view_button $display_load_archive\" type=\"submit\" value=\"&nbsp;&nbsp;Load Archive&nbsp;&nbsp;\"  onclick=\"return confirm('Really load this GDB archive configuration? It may take some time for large datasets. Then you will need to select Data Process Options -> Restore from Archive to complete the process.')\" />
                </td>
                <td valign=\"middle\" width=\"4%\" align=\"left\">
                         &nbsp;<img src='/XGDB/images/help-icon.png' id='config_new_from_archive' alt='save help' title='Search Help' class='help-button nudge2 $display_load_archive $view_button' />&nbsp;
                </td>
            </tr>
            <tr>
                <td>
                    <span class=\"normalfont indent1\" style=\"font-weight:normal\"><a title=\"See more about data volumes\" href=\"/XGDB/conf/volumes.php\"></a>$dir1_status  $dir2_status</span>
                </td>
            </tr>
        </table>
    </form>
</div>

<form method=\"post\" name=\"add_record\" action=\"/XGDB/conf/add.php\" class=\"styled\">
    <div class=\"gdb_examples description\">
    <table id=\"save_and_submit\" style=\"font-size:12px\" class=\"bottommargin1\" width=\"100%\">
        <tr>
            <td style=\"padding:10px\">$instructions_text
            </td>
            <td valign=\"middle\"> <!-- note: hidden parameters for update examples; these variable do not appear in the new.php interface -->
                <input class=\"submit styled save_style $view_button\" type=\"submit\" name=\"submit\" id=\"save\" value=\"$save_button \" /> 
                <input type=\"hidden\" name=\"Update_Status\" value=\"$Update_Status\" /><!-- to load example update data not shown on this page -->
                <input type=\"hidden\" name=\"Update_Data_Path\" value=\"$Update_Data_Path\" />
                <input type=\"hidden\" name=\"Update_Data_EST\" value=\"$Update_Data_EST\" />
                <input type=\"hidden\" name=\"Update_Data_cDNA\" value=\"$Update_Data_cDNA\" />
                <input type=\"hidden\" name=\"Update_Data_TrAssembly\" value=\"$Update_Data_TrAssembly\" />
                <input type=\"hidden\" name=\"Update_Data_Protein\" value=\"$Update_Data_Protein\" />
                <input type=\"hidden\" name=\"Update_Data_GSEG\" value=\"$Update_Data_GSEG\" />
                <input type=\"hidden\" name=\"Update_Data_GeneModel\" value=\"$Update_Data_GeneModel\" />
                <input type=\"hidden\" name=\"Update_Data_CpGAT\" value=\"$Update_Data_CpGAT\" />
                <input type=\"hidden\" name=\"Update_Comments\" value=\"$Update_Comments\" />
            </td>
            <td valign=\"middle\" width=\"4%\" align=\"left\">
                 &nbsp;<img src='/XGDB/images/help-icon.png' id='config_new_save' alt='save help' title='Search Help' class='help-button nudge2 $view_button' />&nbsp;
             </td>
        </tr>
        
    </table>
    </div>
    
    <div id=\"general_information\" class=\"description \">
        <fieldset class=\"topmargin1 bottommargin1 New xgdb_log\">
        <legend class=\"new_gdb\"> &nbsp;<b>General Information:</b></legend>
            <table class=\"xgdb_log new_record\" border=\"0\" style=\"font-size:12px\" width=\"95%\" >
                <colgroup>
                    <col width =\"25%\" />
                    <col width =\"75%\" />
                </colgroup>
                <tbody>
                    <tr>
                        <td>
                            <span class=\"tip required\" title=\"(Required) A unique name to identify this database (15 character max). \">
                                Unique Database Name:
                            </span>
                        </td>
                        <td>
                            <input name=\"DBname\" size=\"75\" value=\"$DBname\" /><span class=\"heading\"></span> 
                        </td>
                    </tr>
                    <tr>
                        <td>
                            <span class=\"tip required\" title=\"(Optional) Example: Ricinus communis\">
                                Organism 
                            </span>
                        </td>
                        <td>
                            <input class=\"italic\" name=\"Organism\" size=\"25\" value=\"$Organism\" /> 
                        </td>
                    </tr>
                    <tr>
                        <td>
                            <span class=\"tip\" title=\"(optional) Type common name for this organism. \">
                                Common Name
                            </span>
                        </td>
                        <td>   
                            <input name=\"Common_Name\" size=\"25\" value=\"$Common_Name\" />
                        </td>
                    </tr>
                    <tr>
                        <td>
                            Genome Type
                        </td>
                        <td >
                                <select name=\"Genome_Type\">
                                    <option $GType_Scaff_selected>Scaffold</option>
                                    <option $GType_Chr_selected>Chromosome</option>
                                    <option $GType_ChrScaff_selected>Chromosome/Scaffold</option>
                                    <option $GType_BAC_selected>BAC</option>
                                    <option $GType_BACScaff_selected>BAC/Scaffold</option>
                                </select>
                        </td>
                    </tr>
                </tbody>
            </table>
        </fieldset>
    </div><!-- end general_information-->
    
    <div id = \"input_data\" class=\"description \">
        <fieldset  class=\"topmargin1 bottommargin1 New xgdb_log\">
        <legend class=\"new_gdb\"> &nbsp;<b>Input Data:</b>&nbsp; <img  id='config_input_data' title='Search Help' class='help-button nudge2' src='/XGDB/images/help-icon.png' alt='?' /></legend>
            <div class=\"bottommargin1\">
                            <p class=\"instruction\">
                                        Place all input data files in the Input Data Directory you specify below.<br /> 
                                        <span class=\"heading indent1\"><b>Required</b>: <a id='config_data_decisions-gdna' title='Choosing genome data' class=\"help-button link\">Genome</a>,  <a id='config_data_decisions-transcr' title='Choosing transcript data' class=\"help-button link\">Transcript and/or Protein</a></span><br />
                                        <span class=\"heading indent1\"><b>Optional</b>: <a id='config_data_decisions-anno' title='Choosing annotation data' class=\"help-button link\">Gene predictions</a></span>
                            <br />
                                <b>YOUR DATA FILES MUST HAVE VALID FILENAMES</b> -- See <a id='config_file_names_brief' title='Search Help' class='help-button link' style='text-decoration:underline' > Filename Requirements</a>  or refer to <a title=\"Comprehensive table of data naming conventions; opens a new web page\" target=\"_blank\" href=\"/XGDB/conf/data.php\">Data Requirements</a> page for details.
                            </p>
            </div>
        
        <table class=\"xgdb_log new_record\" border=\"0\" style=\"font-size:12px\" width=\"95%\" >
            <colgroup>
                <col width =\"25%\" />
                <col width =\"75%\" />
            </colgroup>
            <tbody>
                <tr>
                    <td><span class=\"tip required nowrap\" title=\"(Required) Path to the directory containing your input data\">Input Data Directory <img id='config_input_dir' title='Search Help' class='help-button  nudge2' src='/XGDB/images/help-icon.png' alt='?' /></span></td>
                    <td>
                            <span class=\"nowrap\"><select name=\"Input_Data_Path\">
                                $input_dirlist
                            </select> </span>
                    </td>
                </tr>
            </tbody>
        </table>
        </fieldset>
        </div>
        
        <div id=\"geneseqer\" class=\"description \">
            <fieldset  class=\"topmargin1 bottommargin1 New xgdb_log\">
            <legend class=\"new_gdb\"> &nbsp;<b>Transcript Spliced Alignment</b> <span class=\"heading\"> (GeneSeqer) </span> &nbsp;</legend>
            <div class=\"bottommargin1\"><span class=\"heading \"> This process will run <b>automatically</b> if <span class=\"plaintext\"> ~est.fa</span>, <span class=\"plaintext\">~cdna.fa</span> or <span class=\"plaintext\">~tsa.fa</span> files are provided. Repeat masking is advised for large genomes. </span><br />
            <span class=\"heading iplant\">iPlant users can select <a class=\"help_style\" href=\"/XGDB/help/remote_jobs.php\">'Remote'</a> resources for faster analysis (login and other configuration required)</span>
            </div>
            <table class=\"xgdb_log new_record\" border=\"0\" style=\"font-size:12px\" width=\"95%\">
                <colgroup>
                    <col width =\"25%\" />
                    <col width =\"75%\" />
                </colgroup>
                <tbody>
                <tr>
                    <td>
                        GSQ Compute Resources &nbsp; <img id='config_comp_res_gsq' title='Search Help' class='help-button' src='/XGDB/images/help-icon.png' alt='?' />
                    </td>
                    <td class=\"entry normalfont\"  align = \"left\"> 
                            <input title =\"GSQinternal\" style=\"cursor:pointer\"  type=\"radio\" $GSQ_Internal_checked name=\"GSQ_CompResources\" value=\"Local\"  /> Local &nbsp; &nbsp;
                            <input title =\"GSQexternal\" style=\"cursor:pointer\"  type=\"radio\"  $GSQ_External_checked  name=\"GSQ_CompResources\"  value=\"Remote\" /> Remote
                    </td>
                </tr>
                <tr>
                    <td>
                        <span class=\"tip\" title=\"Species model for GeneSeqer alignments. Default='Arabidopsis'.\">
                            GSQ Species Model
                        </span>
                    </td>
                    <td class=\"entry\"  align = \"left\" >
                            <input title =\"maize\" style=\"cursor:pointer\"  type=\"radio\" $maize_checked name=\"Species_Model\" value=\"maize\"  /> maize  &nbsp; &nbsp;
                            <input title =\"other\" style=\"cursor:pointer\"  type=\"radio\"  $Arabidopsis_checked  name=\"Species_Model\" value=\"Arabidopsis\" /> Arabidopsis &nbsp; &nbsp;
                            <input title =\"rice\" style=\"cursor:pointer\"  type=\"radio\" $rice_checked name=\"Species_Model\" value=\"rice\" /> rice  &nbsp; &nbsp;	
                            <input title =\"medicago\" style=\"cursor:pointer\"  type=\"radio\" $Medicago_checked name=\"Species_Model\" value=\"Medicago\" /> Medicago
                            <input title =\"drosophila\" style=\"cursor:pointer\"  type=\"radio\" $Fruitfly_checked name=\"Species_Model\" value=\"Drosophila\" /> Drosophila
                    </td>
                </tr>
                <tr>
                    <td>
                        <span class=\"tip\" title=\"Stringency for GeneSeqer alignment. Default='Strict'.\">
                            GSQ Alignment Stringency
                        </span>
                    </td>
                    <td class=\"entry\"  align = \"left\" >
                            <input title =\"strict\" style=\"cursor:pointer\"  type=\"radio\"  $Strict_Stringency_checked name=\"Alignment_Stringency\" value=\"Strict\" /> Strict &nbsp; &nbsp;
                            <input title =\"moderate\" style=\"cursor:pointer\"  type=\"radio\" $Moderate_Stringency_checked name=\"Alignment_Stringency\" value=\"Moderate\" /> Moderate &nbsp; &nbsp;
                            <input title =\"low\" style=\"cursor:pointer\"  type=\"radio\"  $Low_Stringency_checked name=\"Alignment_Stringency\" value=\"Low\" /> Low &nbsp; &nbsp;
                    </td>
                </tr>
                <tr>
                    <td>
                        <span class=\"tip\" title=\"Click Yes to mask repeat sequence in genome sequence prior to GeneSeqer spliced alignment.\">
                            Repeat mask genome?
                        </span>  &nbsp;
                            <img id='config_repmask_option' alt='cpgat' title='Configure: Repeat Mask Option Help' class='help-button  nudge2' src='/XGDB/images/help-icon.png' />
                    </td>
                    <td class=\"entry\"  align = \"left\" >
                            <input title =\"GSQ_Repeat_no\" style=\"cursor:pointer\"  type=\"radio\"  $RepeatMask_no_checked  name=\"RepeatMask_Status\" value=\"\" /> No &nbsp;
                            &nbsp;<input title =\"GSQ_Repeat_yes\" style=\"cursor:pointer\"  type=\"radio\" $RepeatMask_yes_checked  name=\"RepeatMask_Status\" value=\"Yes\" /> Yes &nbsp;&nbsp;(if Yes, specify <b>Repeat Mask index</b> below, or leave blank to use default index)
                    </td>
                </tr>
                <tr>
                    <td>
                        <span class=\"tip\" title=\"Specificy Vmatch-indexed Repeat Mask file, used by ab initio genefinders.\">
                            Repeat Mask Index:
                        </span> &nbsp;
                            <img id='config_repmask_file' title='Configure: Repeat Mask Index Help' class='help-button  nudge2' src='/XGDB/images/help-icon.png' alt='?' />
                    </td>
					<td>
						<select name=\"RepeatMask_File\">
							$repmask_dirlist
						</select>
                    </td>
                </tr>
            </tbody>
        </table>
        </fieldset>
    </div><!-- end geneseqer-->
    
    <div id=\"genomethreader\" class=\"description \">
        <fieldset  class=\"topmargin1 bottommargin1 New xgdb_log\">
        <legend class=\"new_gdb\"> &nbsp;<b>Protein Spliced Alignment</b> <span class=\"heading\"> (GenomeThreader) </span> &nbsp;
        </legend>
        <div class=\"bottommargin1\"><span class=\"heading \"> This process will run <b>automatically</b> if <span class=\"plaintext\"> ~prot.fa</span> files are provided. Repeat masking is not used for protein alignments. </span><br />
            <span class=\"heading iplant\">iPlant users can select <a class=\"help_style\" href=\"/XGDB/help/remote_jobs.php\">'Remote'</a> resources for faster analysis (login and other configuration required)</span>
        </div>
        <table class=\"xgdb_log new_record\" border=\"0\" style=\"font-size:12px\" width=\"95%\">
            <colgroup>
                <col width =\"25%\" />
                <col width =\"75%\" />
            </colgroup>
            <tbody>
            <tr>
                <td>GTH Compute Resources &nbsp; <img id='config_comp_res_gth' title='Search Help' class='help-button' src='/XGDB/images/help-icon.png' alt='?' /></td>
                <td class=\"entry normalfont\"  align = \"left\"> 
                        <input title =\"GTHinternal\" style=\"cursor:pointer\" class=\"normalfont\" type=\"radio\" $GTH_Internal_checked name=\"GTH_CompResources\" value=\"Local\"  /> Local &nbsp; &nbsp;
                        <input title =\"GTHexternal\" style=\"cursor:pointer\" class=\"normalfont\" type=\"radio\"  $GTH_External_checked  name=\"GTH_CompResources\"  value=\"Remote\" /> Remote
                </td>
            </tr>
            <tr>
    
                <td><span class=\"tip\" title=\"Species model for GenomeThreader alignments. Default='arabidopsis'\">GTH Species Model </span></td>
                <td class=\"entry\"  align = \"left\" >
                        <input title =\"maize\" style=\"cursor:pointer\"  type=\"radio\" $gth_maize_checked name=\"Gth_Species_Model\" value=\"maize\"  /> maize  &nbsp; &nbsp;
                        <input title =\"other\" style=\"cursor:pointer\"  type=\"radio\" $gth_arabidopsis_checked  name=\"Gth_Species_Model\" value=\"arabidopsis\" /> arabidopsis &nbsp; &nbsp;
                        <input title =\"rice\" style=\"cursor:pointer\"  type=\"radio\" $gth_rice_checked name=\"Gth_Species_Model\" value=\"rice\" /> rice  &nbsp; &nbsp;	
                        <input title =\"medicago\" style=\"cursor:pointer\"  type=\"radio\" $gth_medicago_checked name=\"Gth_Species_Model\" value=\"medicago\" /> medicago
                        <input title =\"fruitfly\" style=\"cursor:pointer\"  type=\"radio\" $gth_drosophila_checked name=\"Gth_Species_Model\" value=\"drosophila\" /> drosophila
                </td>
            </tr>
        </tbody>
    </table>
    </fieldset>
    </div>
    <div class=\"description\" id=\"cpgat\">
        <fieldset  class=\"topmargin1 bottommargin1 New xgdb_log\">
    <legend class=\"new_gdb\"> Gene Prediction  <span class=\"heading\"> (CpGAT)</span> &nbsp;<img id='config_cpgat_parameters' alt='cpgat' title='Configure: CpGAT Parameters Help' class='help-button  nudge2' src='/XGDB/images/help-icon.png' /> </legend>
        <div class=\"bottommargin1\"><span class=\"heading\"> Optional - requires transcript spliced alignments (see above) and reference proteins (see below). </span></div>
    
        <table class=\"xgdb_log new_record\" border=\"0\" style=\"font-size:12px\" width=\"95%\">
        <colgroup>
                    <col width =\"25%\" />
                    <col width =\"75%\" />
        </colgroup>
        <tbody>
    
            <tr>
                <td><span class=\"tip largerfont\" title=\"Click Yes to run CpGAT annotation tool to create gene structure models based on alignment evidence and ab initio genefinders.\">Predict Genes? </span>  &nbsp;<img id='config_cpgat_option' alt='cpgat' title='Configure: CpGAT Option Help' class='help-button  nudge2' src='/XGDB/images/help-icon.png' /></td>
                <td class=\"entry\"  align = \"left\" >
                        <input title =\"CpGAT_Status\" style=\"cursor:pointer\"  type=\"radio\"  $CpGAT_Status_no_checked  name=\"CpGAT_Status\" value=\"\" /> No &nbsp;
                        &nbsp;<input title =\"CpGAT_Status\" style=\"cursor:pointer\"  type=\"radio\" $CpGAT_Status_yes_checked  name=\"CpGAT_Status\" value=\"Yes\" /> Yes &nbsp;&nbsp; (if Yes, specify <b>Reference Protein Library</b>)
                </td>
            </tr>
            <tr>
                <td class=\"indent2 subhead\" colspan=\"2\" style=\"background:#FFF\">Reference Protein Library:</td>

            </tr>
            <tr>
                <td>
                    <span class=\"tip\" title=\"Specify Reference Protein Blast Library (used by CpGAT for best hit analysis).\">
                        Reference Protein Library: 
                        </span>
                        &nbsp;<img id='config_cpgat_refprotein' title='Configure: CpGAT Reference Protein Library Help' class='help-button  nudge2' src='/XGDB/images/help-icon.png' alt='?' />
                </td>
                <td class=\"entry\">
				<select name=\"CpGAT_ReferenceProt_File\">
					$refprot_dirlist
			   </select>	
			   </td>
            </tr>		
            <tr>
                <td class=\"indent2 subhead\" colspan=\"2\" style=\"background:#FFF\"><i>Ab initio</i> Genefinders: <img id='config_cpgat_genefinders' title='Ab initio genefinders (click for more info)' class='help-button' src='/XGDB/images/help-icon.png' alt='?' /></td>
            </tr>
            <tr>
                <td class=\"indent1\">BGF:</td>
                <td class=\"entry\"  align = \"left\" >
                        <input title =\"skip\" style=\"cursor:pointer\"  type=\"radio\"  $Skip_BGF_checked   name=\"CpGAT_BGF\" value=\"Skip\" /> (Skip) &nbsp;
                        <input title =\"Arabidopsis\" style=\"cursor:pointer\"  type=\"radio\"   $Arabidopsis_BGF_checked name=\"CpGAT_BGF\" value=\"Arabidopsis\"  /> Arabidopsis  &nbsp;
                        <input title =\"Fruitfly\" style=\"cursor:pointer\"  type=\"radio\"   $Fruitfly_BGF_checked name=\"CpGAT_BGF\" value=\"Fruitfly\"  /> Fruitfly  &nbsp; 
                        <input title =\"maize\" style=\"cursor:pointer\"  type=\"radio\"  $maize_BGF_checked   name=\"CpGAT_BGF\" value=\"maize\" /> maize &nbsp;
                        <input title =\"rice\" style=\"cursor:pointer\"  type=\"radio\"   $rice_BGF_checked name=\"CpGAT_BGF\" value=\"rice\" /> rice &nbsp;
                        <input title =\"Silkworm\" style=\"cursor:pointer\"  type=\"radio\"   $Silkworm_BGF_checked name=\"CpGAT_BGF\" value=\"Silkworm\"  /> Silkworm  &nbsp; 
                        <input title =\"soybean\" style=\"cursor:pointer\"  type=\"radio\"   $soybean_BGF_checked name=\"CpGAT_BGF\" value=\"soybean\"  /> soybean  &nbsp; 
                    </td>
            </tr>
            <tr>
                <td class=\"indent1\">Augustus:</td>
                <td class=\"entry\"  align = \"left\" >
                        <input title =\"Skip\" style=\"cursor:pointer\"  type=\"radio\"  $Skip_Augustus_checked  name=\"CpGAT_Augustus\" value=\"Skip\" /> (Skip) &nbsp;
                        <input title =\"arabidopsis\" style=\"cursor:pointer\"  type=\"radio\"   $arabidopsis_Augustus_checked name=\"CpGAT_Augustus\" value=\"arabidopsis\"  /> arabidopsis  &nbsp;
                        <input title =\"chlamydomonas\" style=\"cursor:pointer\"  type=\"radio\"   $chlamydomonas_Augustus_checked name=\"CpGAT_Augustus\" value=\"chlamydomonas\"  /> chlamydomonas  &nbsp; 
                        <input title =\"fly\" style=\"cursor:pointer\"  type=\"radio\"   $fly_Augustus_checked name=\"CpGAT_Augustus\" value=\"fly\"  /> fly  &nbsp; 
                        <input title =\"maize\" style=\"cursor:pointer\"  type=\"radio\"  $maize_Augustus_checked name=\"CpGAT_Augustus\" value=\"maize\" /> maize &nbsp;
                        <input title =\"tomato\" style=\"cursor:pointer\"  type=\"radio\"    $tomato_Augustus_checked name=\"CpGAT_Augustus\" value=\"tomato\" /> tomato &nbsp;
                    </td>
            </tr>
            <tr>
                <td class=\"indent1\">GeneMark:</td>
                <td class=\"entry\"  align = \"left\" >
                        <input title =\"Skip\" style=\"cursor:pointer\"  type=\"radio\"  $Skip_GeneMark_checked  name=\"CpGAT_GeneMark\" value=\"Skip\" /> (Skip) &nbsp;
                        <input title =\"a_thaliana\" style=\"cursor:pointer\"  type=\"radio\" $a_thaliana_GeneMark_checked  name=\"CpGAT_GeneMark\" value=\"a_thaliana\"  /> a_thaliana  &nbsp;
                        <input title =\"c_reinhardtii\" style=\"cursor:pointer\"  type=\"radio\"  $c_reinhardtii_GeneMark_checked  name=\"CpGAT_GeneMark\" value=\"c_reinhardtii\" /> c_reinhardtii &nbsp;
                        <input title =\"corn\" style=\"cursor:pointer\"  type=\"radio\"  $corn_GeneMark_checked  name=\"CpGAT_GeneMark\" value=\"corn\" /> corn &nbsp;
                        <input title =\"d_melanogaster\" style=\"cursor:pointer\"  type=\"radio\"  $d_melanogaster_GeneMark_checked  name=\"CpGAT_GeneMark\" value=\"d_melanogaster\" /> d_melanogaster &nbsp;
                        <input title =\"o_sativa\" style=\"cursor:pointer\"  type=\"radio\"  $o_sativa_GeneMark_checked  name=\"CpGAT_GeneMark\" value=\"o_sativa\" /> o_sativa &nbsp;
                        <input title =\"m_truncatula\" style=\"cursor:pointer\"  type=\"radio\" $m_truncatula_GeneMark_checked  name=\"CpGAT_GeneMark\" value=\"m_truncatula\"  /> m_truncatula  &nbsp;
                        <input title =\"barley\" style=\"cursor:pointer\"  type=\"radio\" $barley_GeneMark_checked  name=\"CpGAT_GeneMark\" value=\"barley\"  /> barley  &nbsp;
                        <input title =\"wheat\" style=\"cursor:pointer\"  type=\"radio\" $wheat_GeneMark_checked  name=\"CpGAT_GeneMark\" value=\"wheat\"  /> wheat  &nbsp;
                </td>
            </tr>
            <tr>
                <td class=\"indent2 subhead\" colspan=\"2\" style=\"background:#FFF\">CpGAT Options:</td>
            </tr>
            <tr>
                <td class=\"indent1\">Skip Mask:<img id='config_cpgat_option_skipmask' title='Do NOT mask genome before ab inito gene prediction (click for more info)' class='help-button' src='/XGDB/images/help-icon.png' alt='?' /></td>
                <td class=\"entry\"  align = \"left\" >
                        <input title =\"none\" style=\"cursor:pointer\"  type=\"radio\"  $CpGAT_Skip_Mask_no_checked   name=\"CpGAT_Skip_Mask\" value=\"\" /> No &nbsp;
                        &nbsp;<input title =\"Skip Repeat Mask for GTH\" style=\"cursor:pointer\"  type=\"radio\"  $CpGAT_Skip_Mask_yes_checked  name=\"CpGAT_Skip_Mask\" value=\"Yes\" /> Yes &nbsp; &nbsp; (if No, specify <b>Repeat Mask Index</b> above, or leave blank to use default)
                    </td>
            </tr>
            <tr>
                <td class=\"indent1\">Relax UniRef: <img id='config_cpgat_option_relaxuniref' title='Allow gene models with no blast support from RefProt (click for more info)' class='help-button' src='/XGDB/images/help-icon.png' alt='?' /></td>
                <td class=\"entry\"  align = \"left\" >
                        <input title =\"none\" style=\"cursor:pointer\"  type=\"radio\"  $CpGAT_Relax_UniRef_no_checked   name=\"CpGAT_Relax_UniRef\" value=\"\" /> No &nbsp;
                        &nbsp;<input title =\"Relax Requirement for UniRef Blast Hit for GTH Output\" style=\"cursor:pointer\"  type=\"radio\"  $CpGAT_Relax_UniRef_yes_checked  name=\"CpGAT_Relax_UniRef\" value=\"Yes\" /> Yes
                    </td>
            </tr>
            <tr>
                <td class=\"indent1\">Skip PASA: <img id='config_cpgat_option_skippasa' title='Allow gene models with no blast support from RefProt (click for more info)' class='help-button' src='/XGDB/images/help-icon.png' alt='?' /></td>
                <td class=\"entry\"  align = \"left\" >
                        <input title =\"none\" style=\"cursor:pointer\"  type=\"radio\"  $CpGAT_Skip_PASA_no_checked name=\"CpGAT_Skip_PASA\" value=\"\" /> No &nbsp;
                        &nbsp;<input title =\"Relax Requirement for UniRef Blast Hit for GTH Output\" style=\"cursor:pointer\"  type=\"radio\"  $CpGAT_Skip_PASA_yes_checked  name=\"CpGAT_Skip_PASA\" value=\"Yes\" /> Yes
                </td>
            </tr>
            <tr class=\"$cpgat_row_hide\">
                <td class=\"indent2 subhead\" colspan=\"2\" style=\"background:#EEE\">
                    Track Options:
                </td>
            </tr>
            <tr>
                <td class=\"indent1\">
					Filter Genes:  <img id='config_cpgat_filtergenes' title='Load ONLY genes with transcript evidence (click for more info)' class='help-button' src='/XGDB/images/help-icon.png' alt='?' />
                </td>
                <td class=\"entry\"  align = \"left\" >
                        <input title =\"none\" style=\"cursor:pointer\"  type=\"radio\"  $CpGAT_Filter_Genes_no_checked  name=\"CpGAT_Filter_Genes\" value=\"\" /> No &nbsp;
                        &nbsp;<input title =\"Relax Requirement for UniRef Blast Hit for GTH Output\" style=\"cursor:pointer\"  type=\"radio\"  $CpGAT_Filter_Genes_yes_checked  name=\"CpGAT_Filter_Genes\" value=\"Yes\" /> Yes
                    </td>
            </tr>
            </tbody>
    </table>
    </fieldset>
    </div>
    
    <div class=\"description\" id=\"other\">
        <fieldset  class=\"topmargin1 bottommargin1 New xgdb_log\">
        <legend class=\"new_gdb\"> &nbsp;<b>Other Settings</b> <span class=\"heading\"> (Display and yrGATE defaults for this genome)</span> &nbsp;</legend>
        <table class=\"xgdb_log new_record\" border=\"0\" style=\"font-size:12px\" width=\"95%\">
            <colgroup>
                <col width =\"25%\" />
                <col width =\"75%\" />
            </colgroup>
            <tbody>
                <tr>
                    <td>
                        Default Genome Segment: &nbsp;<img id='config_default_display' title='Configure: Default Region - Help' class='help-button  nudge2' src='/XGDB/images/help-icon.png' alt='?' />
                    </td>
                    <td>
                        <input name=\"Default_GSEG\" size=\"15\" value=\"$Default_GSEG\" />
                    </td>
                </tr>
                <tr>
                    <td class=\"indent2\" >
                        Default Left Coordinate:
                    </td>
                    <td>
                        <input name=\"Default_lpos\" size=\"10\" value=\"$Default_lpos\" />
                    </td>
                </tr>
                <tr>
                    <td  class=\"indent2\">
                        Default Right Coordinate:
                    </td>
                    <td>
                        <input name=\"Default_rpos\" size=\"10\" value=\"$Default_rpos\" />
                    </td>
                </tr>
                <tr>
                    <td>
                        <span class=\"tip\" title=\"Click CpGAT to use as yrGATE reference annotation.\">
                            yrGATE Ref. Annotation 
                        </span>  &nbsp;
                            <img id='config_yrgate_ref' title='Configure: yrGATE Reference Anno Help' class='help-button  nudge2' src='/XGDB/images/help-icon.png' alt='?' />
                    </td>
                    <td>
                        <span class=\"entry\">
                            <input title =\"yrGATE_Ref_pre\" style=\"cursor:pointer\"  type=\"radio\"  $yrGATE_Ref_pre_checked  name=\"yrGATE_Reference\" value=\"Precomputed\" /> Precomputed &nbsp;
                            <input title =\"yrGATE_Ref_cpgat\" style=\"cursor:pointer\"  type=\"radio\" $yrGATE_Ref_cpgat_checked  name=\"yrGATE_Reference\" value=\"CpGAT\" /> CpGAT &nbsp;&nbsp;
                        </span>
                    </td>
                </tr>				
            </tbody>
        </table>
        </fieldset>
    </div>    
    <div class=\"description showhide\">
        <p title=\"Show additional genome information (dropdown)\" class=\"label\" style=\"cursor:pointer\">Genome Information (optional; click to view)...</p>
        <div class=\"more_hidden hidden\">
            <fieldset  class=\"topmargin1 bottommargin1 New xgdb_log\">
            <legend class=\"new_gdb\"> &nbsp;<b>Genome :</b> <span class=\"heading\">(Optional)</span></legend>
            <table class=\"xgdb_log new_record\" border=\"0\" style=\"font-size:12px\" width=\"95%\">
                <colgroup>
                    <col width =\"25%\" />
                    <col width =\"75%\" />
                    </colgroup>
                <tbody>
                    <tr><td>Genome Version:</td><td width=\"25\"><input name=\"Genome_Version\" size=\"9\" value=\"$Genome_Version\" /></td>
                    </tr>
                    <tr><td>Genome Source:</td><td width=\"25\"><input name=\"Genome_Source\" size=\"25\" value=\"$Genome_Source\" /></td>
                    </tr>
                    <tr><td>Genome Link:</td><td width=\"25\"><input name=\"Genome_Source_Link\" size=\"50\" value=\"$Genome_Source_Link\" /></td>
                    </tr>
                    <tr><td>Genome Comments</td><td width=\"300\"><textarea class=\"data_entry smallerfont\" rows=\"1\" name=\"Genome_Comments\" cols=\"75\">$Genome_Comments</textarea></td>
                    </tr>
                </tbody>
            </table>
            </fieldset>	
            
            <fieldset  class=\"topmargin1 bottommargin1 New xgdb_log\">
            <legend class=\"new_gdb\"> &nbsp;<b>Genome Segments:</b><span class=\"heading\"> (record number of segments expected, and type)</span></legend>
            <table class=\"xgdb_log new_record\" border=\"0\" style=\"font-size:12px\" width=\"95%\">
                <colgroup>
                    <col width =\"25%\" />
                    <col width =\"75%\" />
                    </colgroup>
                <tbody>
                    <tr><td>Total Genome Segments:</td><td width=\"25\"><input name=\"Genome_Count\" size=\"5\" value=\"$Genome_Count\" /></td></tr>
                    <tr><td class=\"indent3\">(Pseudo)chromosomes:</td><td width=\"25\"><input name=\"Chromosome_Count\" size=\"5\" value=\"$Chromosome_Count\" /></td></tr>
                    <tr><td class=\"indent3\">Unlinked Chromosomes:</td><td width=\"25\"><input name=\"Unlinked_Chromosome_Count\" size=\"5\" value=\"$Unlinked_Chromosome_Count\" /></td></tr>
                    <tr><td class=\"indent3\">Scaffolds:</td><td width=\"25\"><input name=\"Scaffold_Count\" size=\"5\" value=\"$Scaffold_Count\" /></td></tr>
                    <tr><td class=\"indent3\">BACs:</td><td width=\"25\"><input name=\"BAC_Count\" size=\"5\" value=\"$BAC_Count\" /></td></tr>
                </tbody>
            </table>
            </fieldset>	
            
            <fieldset  class=\"topmargin1 bottommargin1 New xgdb_log\">
            <legend class=\"new_gdb\"> &nbsp;<b>Gene Models:</b> <span class=\"heading\">(Optional)</span></legend>
            <table class=\"xgdb_log new_record\" border=\"0\" style=\"font-size:12px\" width=\"95%\">
                <colgroup>
                    <col width =\"25%\" />
                    <col width =\"75%\" />
                    </colgroup>
                <tbody>
                    <tr><td>Gene Model Version:</td><td><input name=\"GeneModel_Version\" size=\"9\" value=\"$GeneModel_Version\" /></td></tr>
                    <tr><td>Gene Model Source:</td><td><input name=\"GeneModel_Source\" size=\"25\" value=\"$GeneModel_Source\" /></td></tr>
                    <tr><td>Gene Model Link:</td><td><input name=\"GeneModel_Link\" size=\"50\" value=\"$GeneModel_Link\" /></td></tr>
                    <tr><td>GeneModel Comments</td><td width=\"300\"><textarea class=\"data_entry smallerfont\" rows=\"1\" name=\"GeneModel_Comments\" cols=\"75\">$GeneModel_Comments</textarea></td></tr>
                </tbody>
            </table>
            </fieldset>	
            
            <fieldset  class=\"topmargin1 bottommargin1 New xgdb_log\">
            <legend class=\"new_gdb\"> &nbsp;<b>Transcript Spliced Alignments:</b> <span class=\"heading\">(Optional)</span></legend>
            <table class=\"xgdb_log new_record\" border=\"0\" style=\"font-size:12px\" width=\"95%\">
                <colgroup>
                    <col width =\"25%\" />
                    <col width =\"75%\" />
                    </colgroup>
                <tbody>
                    <tr><td>Aligned EST Species:</td><td><input name=\"EST_Align_sp\" size=\"50\" value=\"$EST_Align_sp\" /></td></tr>
                    <tr><td>Aligned EST Version:</td><td><input name=\"EST_Align_Version\" size=\"15\" value=\"$EST_Align_Version\" /></td></tr>
                    <tr><td>Aligned EST Comments:</td><td width=\"300\"><textarea class=\"data_entry smallerfont\" rows=\"1\" name=\"EST_Align_Comments\" cols=\"75\">$EST_Align_Comments</textarea></td></tr>
                    <tr><td>Aligned cDNA Species:</td><td><input name=\"cDNA_Align_sp\" size=\"50\" value=\"$cDNA_Align_sp\" /></td></tr>
                    <tr><td>Aligned cDNA Version:</td><td><input name=\"cDNA_Align_Version\" size=\"15\" value=\"$cDNA_Align_Version\" /></td></tr>
                    <tr><td>Aligned cDNA Comments:</td><td width=\"300\"><textarea class=\"data_entry smallerfont\" rows=\"1\" name=\"cDNA_Align_Comments\" cols=\"75\">$cDNA_Align_Comments</textarea></td></tr>
                    <tr><td>Aligned TSA<span class=\"heading\">*</span> Species:</td><td><input name=\"cDNA_Align_sp\" size=\"50\" value=\"$PUT_Align_sp\" /></td></tr>
                    <tr><td>Aligned TSA<span class=\"heading\">*</span> Version:</td><td><input name=\"PUT_Align_Version\" size=\"15\" value=\"$PUT_Align_Version\" /></td></tr>
                    <tr><td>Aligned TSA<span class=\"heading\">*</span> Comments:</td><td width=\"300\"><textarea class=\"data_entry smallerfont\" rows=\"1\" name=\"PUT_Align_Comments\" cols=\"75\">$PUT_Align_Comments</textarea></td></tr>
                </tbody>
            </table>
                                <span class=\"heading\">*TSA = Transcript Sequence Assembly</span>
            </fieldset>
            
            <fieldset  class=\"topmargin1 bottommargin1 New xgdb_log\">
            <legend class=\"new_gdb\"> &nbsp;<b>Protein Spliced Alignments:</b>  <span class=\"heading\">(Optional)</span></legend>
            <table class=\"xgdb_log new_record\" border=\"0\" style=\"font-size:12px\" width=\"95%\">
                <colgroup>
                    <col width =\"25%\" />
                    <col width =\"75%\" />
                </colgroup>
                <tbody>
                    <tr><td>Species:</td><td><input name=\"Prot_Align_sp\" size=\"50\" value=\"$Prot_Align_sp\" /></td></tr>
                    <tr><td>Version:</td><td><input name=\"Prot_Align_Version\" size=\"15\" value=\"$Prot_Align_Version\" /></td></tr>
                    <tr><td>Comments:</td><td width=\"300\"><textarea class=\"data_entry smallerfont\" rows=\"1\" name=\"Prot_Align_Comments\" cols=\"45\">$Prot_Align_Comments</textarea></td></tr>
                </tbody>
            </table>
            </fieldset>
            </div><!--end of hidden div-->
    </div><!--end showhide div-->
</form>
";
	?>
	
		<div id="leftcolumncontainer">
			<div class="minicolumnleft">
			<?php include_once("/xGDBvm/XGDB/conf/leftmenu.inc.php"); ?>
			</div>
		</div>
			<div id="maincontentscontainer" class="twocolumn configure">
				<div id="maincontents" class="configure">
				<?php
					echo $display_block;
				?>
				<p />
			</div><!--end maincontentsfull-->
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
