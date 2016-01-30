<?php
/*

Common functions for locus display tables.
Used in:
	/XGDB/phplib/DisplayLoci.php

*/

/**
* Timing function
* @return float current time
*/
function microtime_float()
{
	return array_sum(explode(' ',microtime()));
}

//get project names and build dropdown; assign selected. Note: projects not implemented currently.
	function project_dropdown($Project, $GDB, $gene_table){
		echo "<option value=\"no filter\">- no filter -</option>";
		$projectQuery="select distinct c.project, count(b.locus_id) as project_count from ".$GDB.".gseg_".$gene_table."_annotation as a join ".$GDB.".gdb_projects as b on (a.locus_id=b.locus_id) join yrgate.projects as c on b.project_uid=c.uid group by b.project_name";
		$get_projects = $projectQuery;
		$check_get_projects = mysql_query($get_projects);
		$project_count = mysql_num_rows($check_get_projects);
		$project_data = mysql_fetch_array($check_get_projects);
		$ProjectDisplay="";
#		mysql_data_seek($check_get_projects,0);
		while ($project_data = mysql_fetch_array($check_get_projects)) {
		$ProjectSelect = $project_data['project'];
		if($ProjectSelect == $Project){//display current project in dropdown
			$SelectedCurrent='selected=\"selected\"';
			}else{
			$SelectedCurrent='';
		}
		$ProjectDisplay = $project_data['project'].' ('.$project_data['project_count'].')';
				echo "<option $SelectedCurrent value=\"$ProjectSelect\">$ProjectDisplay</option>\n\n";
			}
		if($Project == 'no project'){//special case - want loci w/ no project
			$SelectedCurrent='selected=\"selected\"';
			}else{
			$SelectedCurrent='';
		}
			echo "<option $SelectedCurrent value=\"no project\">- no project -</option>\n\n";
		}

function active_search($srch_num, $passed_num){ //dark font and highlighted bckgd for active search items
	$class = ($srch_num == $passed_num) ? 'normalfont selected' : 'not_selected';
	echo $class;
	}

function status_dropdown($Status){//yrGATE status build dropdown; compare to session value to assign selected
		echo "	
		<option value=\"no filter\">- no filter -</option>";
$Stat_Sel = compare_status('accepted', $Status);
		echo "<option $Stat_Sel value=\"accepted\">ACCEPTED</option>";
$Stat_Sel = compare_status('pending', $Status);
		echo "<option $Stat_Sel value=\"pending\">PENDING</option>";
$Stat_Sel = compare_status('all', $Status);
		echo "<option $Stat_Sel value=\"all\">ALL</option>";
$Stat_Sel = compare_status('none', $Status);
		echo "<option $Stat_Sel value=\"none\">NONE</option>";		}
		
function compare_status($this_status, $Status){ //called by status_dropdown 
		if($this_status == $Status ){
			$Sel='selected=\"selected\"';
			}else{
			$Sel='';
			}
		return $Sel;
}


function integrity_dropdown($Integ){//integrity build dropdown; compare to session value to assign selected
		echo "<option value=\"no filter\">- no filter -</option>";
$Integ_Sel = compare_status('lt.99', $Integ);
		echo "<option $Integ_Sel value=\"lt.99\">less than .99</option>";
$Integ_Sel = compare_status('lt.90', $Integ);
		echo "<option $Integ_Sel value=\"lt.90\">less than .90</option>";
$Integ_Sel = compare_status('lt.75', $Integ);
		echo "<option $Integ_Sel value=\"lt.75\">less than .75</option>";
$Integ_Sel = compare_status('lt.50', $Integ);
		echo "<option $Integ_Sel value=\"lt.50\">less than .50</option>";
$Integ_Sel = compare_status('gt.99', $Integ);
		echo "<option $Integ_Sel value=\"gt.99\">greater than .99</option>";		
$Integ_Sel = compare_status('gt.95', $Integ);
		echo "<option $Integ_Sel value=\"gt.95\">greater than .95</option>";
$Integ_Sel = compare_status('gt.75', $Integ);
		echo "<option $Integ_Sel value=\"gt.75\">greater than .75</option>";
$Integ_Sel = compare_status('gt.50', $Integ);
		echo "<option $Integ_Sel value=\"gt.50\">greater than .50</option>";

		}
		
function compare_integ($this_integ, $Integ){ //called by integrity dropdown 
		if($this_status == $Integ ){
			$Sel='selected=\"selected\"';
			}else{
			$Sel='';
			}
		return $Sel;
}

function coverage_dropdown($Cover){//coverage build dropdown; compare to session value to assign selected
		echo "	
		<option value=\"no filter\">- no filter -</option>";
$Cover_Sel = compare_status('gt.99', $Cover);
		echo "<option $Cover_Sel value=\"gt.99\">greater than .99</option>";
$Cover_Sel = compare_status('gt.90', $Cover);
		echo "<option $Cover_Sel value=\"gt.90\">greater than .90</option>";
$Cover_Sel = compare_status('gt.75', $Cover);
		echo "<option $Cover_Sel value=\"gt.75\">greater than .75</option>";
$Cover_Sel = compare_status('gt.50', $Cover);
		echo "<option $Cover_Sel value=\"gt.50\">greater than .50</option>";
$Cover_Sel = compare_status('gt.00', $Cover);
		echo "<option $Cover_Sel value=\"gt.00\">greater than 0</option>";
$Cover_Sel = compare_status('lt.99', $Cover);
		echo "<option $Cover_Sel value=\"lt.99\">less than .99</option>";
$Cover_Sel = compare_status('lt.90', $Cover);
		echo "<option $Cover_Sel value=\"lt.90\">less than .90</option>";
$Cover_Sel = compare_status('lt.75', $Cover);
		echo "<option $Cover_Sel value=\"lt.75\">less than .75</option>";
$Cover_Sel = compare_status('lt.50', $Cover);
		echo "<option $Cover_Sel value=\"lt.50\">less than .50</option>";
$Cover_Sel = compare_status('eq0', $Cover);
		echo "<option $Cover_Sel value=\"eq0\">equal to 0</option>";
		}
		
function compare_cover($this_cover, $Cover){ //called by coverage dropdown 
		if($this_status == $Cover ){
			$Sel='selected=\"selected\"';
			}else{
			$Sel='';
			}
		return $Sel;
}


function search_dropdown($Field){//search build dropdown; compare to session value to assign selected
$Srch_Sel = compare_field('anything', $Field);
		echo "<option $Srch_Sel value=\"anything\">ID or Description</option>";
$Srch_Sel = compare_field('locus_id', $Field);
		echo "<option $Srch_Sel value=\"locus_id\"> Locus ID</option>";
$Srch_Sel = compare_field('gseg_gi', $Field);
		echo "<option $Srch_Sel value=\"gseg_gi\">Scaffold</option>";
$Srch_Sel = compare_field('scaff_from_to', $Field);
		echo "<option $Srch_Sel value=\"scaff_from_to\"> Scaff:From..To</option>";
$Srch_Sel = compare_field('length_gte', $Field);
		echo "<option $Srch_Sel value=\"length_gte\"> Gene Length (kb) &#62;&#61;</option>";
$Srch_Sel = compare_field('transcript_count_gte', $Field);
		echo "<option $Srch_Sel value=\"transcript_count_gte\"> Transcript Count &#62;&#61;</option>";
$Srch_Sel = compare_field('introns_between', $Field);
		echo "<option $Srch_Sel value=\"introns_between\"> Intron Count=x-y or z</option>";
$Srch_Sel = compare_field('project_name', $Field);
		echo "<option $Srch_Sel value=\"project_name\"> Annotation Project</option>";
$Srch_Sel = compare_field('annotation_class', $Field);
		echo "<option $Srch_Sel value=\"annotation_class\"> yrGATE Anno Class</option>";
$Srch_Sel = compare_field('GSeqEdits', $Field);
		echo "<option $Srch_Sel value=\"GSeqEdits\"> Genome Edits</option>";
$Srch_Sel = compare_field('geneId', $Field);
		echo "<option $Srch_Sel value=\"geneId\"> yrGATE Anno ID</option>";
$Srch_Sel = compare_field('proteinId', $Field);
		echo "<option $Srch_Sel value=\"proteinId\"> yrGATE Gene Product</option>";
		echo "<option value=\"no filter\">- no filter -</option>";
}



function compare_field($this_field, $Field){ //called by search dropdown
		if($this_field == $Field ){
			$Sel1='selected=\"selected\"';
			}else{
			$Sel1='';
			}
		return $Sel1;
}


function compare_check($this_search, $search){
		if($this_search == $search ){
			$checked='checked';
			}else{
			$checked='';
			}
		return $checked;
}

//parse annotation classes and assign icon(s) based on what's in group_concat(class)  NEEDS FIXING! should use $status_class accepted or pending.
function assign_icon_class($anno_class, $status, $edits) {
		$src="/XGDB/images/";
		if($status != "ACCEPTED" && $status != "PENDING"){ //as defined in the mysql query logic. Other option is "".
		return false;
		}else{
			if($status == "ACCEPTED"){
				$nc="";
				}else{
				$nc="_nc";//choose faded image if not curated (nc)
				}
		$impr_src=$src."improve".$nc.".gif";
		$ext_src=$src."extend".$nc.".gif";
		$conf_src=$src."confirm".$nc.".gif";
		$var_src=$src."add".$nc.".gif";
		$del_src=$src."delete".$nc.".gif";
		$notres_src=$src."notresolv".$nc.".gif";
		$ed_src=$src."edit".$nc.".gif";
		$img_class='yr_img';
		$alt="";
		$imgs="";
	  	if(preg_match('/^.*(Impr)(ove).*/i', $anno_class, $alt )){
			$imgs .="<img title='$alt[1]$alt[2] existing annotation' class='$img_class' src='$impr_src' alt='$alt[1]' />";
			}else{
			$imgs .="";
			}
	  	if(preg_match('/^.*(Ext)(end or Trim).*/i', $anno_class, $alt )){
			$imgs .="<img title='$alt[1]$alt[2] existing annotation' class='$img_class' src='$ext_src' alt='$alt[1]' />";
			}else{
			$imgs .="";
			}
		if(preg_match('/^.*(Conf)(irm).*/i', $anno_class, $alt )){
			$imgs .="<img title='$alt[1]$alt[2] existing annotation' class='$img_class' src='$conf_src' alt='$alt[1]' />";
			}else{
			$imgs .="";
			}
	  	if(preg_match('/^.*(Var)(iant).*/i', $anno_class, $alt )){
			$imgs .="<img title='$alt[1]$alt[2] existing annotation' class='$img_class' src='$var_src' alt='$alt[1]' />";
			}else{
			$imgs .="";
			}
	  	if(preg_match('/^.*(Del)(ete).*/i', $anno_class, $alt )){
			$imgs .="<img title='$alt[1]$alt[2] existing annotation' class='$img_class' src='$del_src' alt='$alt[1]' />";
			}else{
			$imgs .="";
			}
	  	if(preg_match('/^.*(Not Res)(olved).*/i', $anno_class, $alt )){
			$imgs .="<img title='$alt[1]$alt[2] existing annotation' class='$img_class' src='$notres_src' alt='$alt[1]' />";
			}else{
			$imgs .="";
			}
		if(preg_match('/[0-9]+.*/', $edits)){
			$imgs .="<img title='genome edit(s): $edits' class='$img_class' src='$ed_src' alt='edits' />";
			}else{
			$imgs .="";
			}
		return $imgs;
	}
}
//Check if user owns any annos, assign icon (not currently working)

	function check_user($users, $this_user) { 
		if(preg_match('/.*[, ^]${this_user}[, $].*/', $users)){
			$usr ='<img title= \"$this_user\" src=\"/XGDB/images/user.gif\" alt=\"user\" />';
			}else{
			$usr ="";
			return $usr;
		}
	}
?>
