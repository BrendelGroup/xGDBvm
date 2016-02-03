<?php
/*

Common functions for DisplayProteins.php.


J Duvick. 2011-12-30 Updated 7-8-2013
*/

/**
* Timing function
* @return float current time
*/
function microtime_float()
{
	return array_sum(explode(' ',microtime()));
}

//get project names and build dropdown; assign selected 
	function gseg_dropdown($GSEG, $GDB, $table_core){
		echo "<option value=\"no filter\">- no filter -</option>";
		$gsegQuery="select distinct gseg_gi, count(gi) as prot_count from ".$GDB.".gseg_".$table_core."_good_pgs group by gseg_gi";
		$get_gseg = $gsegQuery;
		$check_get_gseg = mysql_query($get_gseg);
		$gseg_count = mysql_num_rows($check_get_gseg);
		$gseg_data = mysql_fetch_array($check_get_gseg);
		$GsegDisplay="";
		mysql_data_seek($check_get_gseg,0);
		while ($gseg_data = mysql_fetch_array($check_get_gseg)) {
		$gsegelect = $gseg_data['gseg_gi'];
		if($gsegelect == $GSEG){//display current project in dropdown
			$SelectedCurrent='selected=\"selected\"';
			}else{
			$SelectedCurrent='';
		}
		$GsegDisplay = $gseg_data['gseg_gi'].' ('.$gseg_data['prot_count'].')';
				echo "<option $SelectedCurrent value=\"$gsegelect\">$GsegDisplay</option>\n\n";
			}
		}

function active_search($srch_num, $passed_num){ //dark font and highlighted bckgd for active search items
	$class = ($srch_num == $passed_num) ? 'normalfont selected' : 'not_selected';
	echo $class;
	}

function copynumber_dropdown($CopyNum){//copy number build dropdown; compare to session value to assign selected
		echo "<option value=\"no filter\">- no filter -</option>";
$CopyNum_Sel = compare_copynum('eq_1', $CopyNum);
		echo "<option $CopyNum_Sel value=\"eq_1\">exactly 1</option>";
$CopyNum_Sel = compare_copynum('eq_2', $CopyNum);
		echo "<option $CopyNum_Sel value=\"eq_2\">exactly 2</option>";
$CopyNum_Sel = compare_copynum('eq_3', $CopyNum);
		echo "<option $CopyNum_Sel value=\"eq_3\">exactly 3</option>";
$CopyNum_Sel = compare_copynum('gt_1', $CopyNum);
		echo "<option $CopyNum_Sel value=\"gt_1\">greater than 1</option>";
$CopyNum_Sel = compare_copynum('gt_2', $CopyNum);
		echo "<option $CopyNum_Sel value=\"gt_2\">greater than 2</option>";		
$CopyNum_Sel = compare_copynum('gt_3', $CopyNum);
		echo "<option $CopyNum_Sel value=\"gt_3\">greater than 3</option>";
$CopyNum_Sel = compare_copynum('gt_10', $CopyNum);
		echo "<option $CopyNum_Sel value=\"gt_10\">greater than 10</option>";
$CopyNum_Sel = compare_copynum('gt_20', $CopyNum);
		echo "<option $CopyNum_Sel value=\"gt_20\">greater than 20</option>";

		}
		
function compare_copynum($this_copynum, $CopyNum){ //called by similarity dropdown 
		if($this_copynum == $CopyNum ){
			$Sel='selected=\"selected\"';
			}else{
			$Sel='';
			}
		return $Sel;
}


function similarity_dropdown($Similar){//similarity build dropdown; compare to session value to assign selected
		echo "<option value=\"no filter\">- no filter -</option>";
$Similar_Sel = compare_similar('lt.99', $Similar);
		echo "<option $Similar_Sel value=\"lt.99\">less than .99</option>";
$Similar_Sel = compare_similar('lt.95', $Similar);
		echo "<option $Similar_Sel value=\"lt.95\">less than .95</option>";
$Similar_Sel = compare_similar('lt.90', $Similar);
		echo "<option $Similar_Sel value=\"lt.90\">less than .90</option>";
$Similar_Sel = compare_similar('lt.75', $Similar);
		echo "<option $Similar_Sel value=\"lt.75\">less than .75</option>";
$Similar_Sel = compare_similar('gt.99', $Similar);
		echo "<option $Similar_Sel value=\"gt.99\">greater than .99</option>";		
$Similar_Sel = compare_similar('gt.95', $Similar);
		echo "<option $Similar_Sel value=\"gt.95\">greater than .95</option>";
$Similar_Sel = compare_similar('gt.90', $Similar);
		echo "<option $Similar_Sel value=\"gt.90\">greater than .90</option>";
$Similar_Sel = compare_similar('gt.75', $Similar);
		echo "<option $Similar_Sel value=\"gt.75\">greater than .75</option>";

		}
		
function compare_similar($this_similar, $Similar){ //called by similarity dropdown 
		if($this_similar == $Similar ){
			$Sel='selected=\"selected\"';
			}else{
			$Sel='';
			}
		return $Sel;
}

function coverage_dropdown($Cover){//coverage build dropdown; compare to session value to assign selected
		echo "	
		<option value=\"no filter\">- no filter -</option>";
$Cover_Sel = compare_cover('gt.99', $Cover);
		echo "<option $Cover_Sel value=\"gt.99\">greater than .99</option>";
$Cover_Sel = compare_cover('gt.90', $Cover);
		echo "<option $Cover_Sel value=\"gt.90\">greater than .90</option>";
$Cover_Sel = compare_cover('gt.75', $Cover);
		echo "<option $Cover_Sel value=\"gt.75\">greater than .75</option>";
$Cover_Sel = compare_cover('lt.99', $Cover);
		echo "<option $Cover_Sel value=\"lt.99\">less than .99</option>";
$Cover_Sel = compare_cover('lt.90', $Cover);
		echo "<option $Cover_Sel value=\"lt.90\">less than .90</option>";
$Cover_Sel = compare_cover('lt.75', $Cover);
		echo "<option $Cover_Sel value=\"lt.75\">less than .75</option>";
		}
		
function compare_cover($this_cover, $Cover){ //called by coverage dropdown 
		if($this_cover == $Cover ){
			$Sel='selected=\"selected\"';
			}else{
			$Sel='';
			}
		return $Sel;
}


function search_dropdown($Field){//search build dropdown; compare to session value to assign selected
$Srch_Sel = compare_field('anything', $Field);
		echo "<option $Srch_Sel value=\"anything\"> Any ID or Description</option>";
$Srch_Sel = compare_field('protein_id', $Field);
		echo "<option $Srch_Sel value=\"protein_id\"> Protein ID</option>";
$Srch_Sel = compare_field('gseg_gi', $Field);
		echo "<option $Srch_Sel value=\"gseg_gi\">Scaffold ID</option>";
$Srch_Sel = compare_field('description', $Field);
		echo "<option $Srch_Sel value=\"description\"> Description</option>";
$Srch_Sel = compare_field('scaff_from_to', $Field);
		echo "<option $Srch_Sel value=\"scaff_from_to\"> Scaff:From..To</option>";
$Srch_Sel = compare_field('length_gte', $Field);
		echo "<option $Srch_Sel value=\"length_gte\"> mRNA len &#62;&#61;</option>";

		echo "<option value=\"no filter\">- clear search -</option>";
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

?>
