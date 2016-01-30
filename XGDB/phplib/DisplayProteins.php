<?php
/*

*/
session_start();
if (preg_match('/(GDB\d\d\d)/', $_SERVER['HTTP_REFERER'], $matches))
        $X = $matches[1];
if (preg_match('/(GDB\d\d\d)/',$_REQUEST['GDB'], $matches)) ;
        $X = $matches[1];

if(empty($SITEDEF_H)) { require('/xGDBvm/data/' . $X .'/conf/SITEDEF.php'); }
if(empty($PARAM_H)){require('/xGDBvm/XGDB/phplib/getPARAM.php');}
require_once('/xGDBvm/XGDB/phplib/SSI_GDBprep.php');
virtual("${CGIPATH}SSI_GDBgui.pl/STANDARD_HEADER/$SSI_QUERYSTRING");
require_once('/xGDBvm/XGDB/phplib/DisplayProteins_functions.inc.php');
?>
<?php
$pgdbmenu = "Genomes";
$DBid = $X;
$leftmenu = "AllProteins";
$PageTitle = "All".$DBid.  " Proteins";
$s_track="";

// First create 'track' session ID for the variable that stores which track is in use, or else use current session variable. Session ID must be distinct from DisplayProteins.php and DisplayTranscripts.php

$get_track=isset($_GET['track'])?$_GET['track']:"";

    if(isset($_GET['track']))
    {
        $track_index=intval($_GET['track']);
        
        $s_track = $DBid."pep-track"; 

    	$_SESSION[$s_track] = $track_index;
    }
        else if (isset($_POST['track']))
    {
        $track_index=intval($_POST['track']);
        
        $s_track = $DBid."pep-track"; 

    	$_SESSION[$s_track] = $track_index;
    }
       else if (isset($_SESSION[$s_track]))
    {
        $track_index=$_SESSION[$s_track];
    }  
       else if (!isset($_SESSION[$s_track]))
    {
        $track_index="0";
        $s_track = $DBid."pep-track"; 
    	$_SESSION[$s_track] = "0"; // default to the first track (index 0)
    }
    
// get track table, track name, etc. from SITEDEF.php based on posted value 

$index=intval($track_index); 
$table_core=$PEP[$index]['table'];
$selected_track=$PEP[$index]['track'];
$selected_color=$PEP[$index]['color'];

//Now create session and other variables that retain query results upon page reload and are unique to the track (table), if more than one.
//This prevents session ID collisions when more than one track is being queried in a single browser session.

$sessID=$table_core.$DBid; // a unique ID root for session variables, to include source table (e.g. 'gene')  GDBid ($X), e.g. 'geneGDB007',

//$s_track = $sessID."track";
$s_limit = $sessID."limit";
$s_page = $sessID."page";
$s_query = $sessID."query";


$s_passed = array(); //which post (1, 2, etc)
$s_field = array(); //the query field
$s_word = array(); //the query item
$s_link = array(); //link builder
$n=5;//adjust to match number of simultaneous query sessions
$i=1;
while($i<=$n)//create unique session array names
  {
	$s_passed[$i]=$sessID."passed".$i;
	$s_field[$i]=$sessID."field".$i;
	$s_word[$i]=$sessID."word".$i;
	$s_link[$i]=$sessID."link".$i;
	
  $i++;
  }
$searchDetail=array();//building blocks for query


//Dropdown - choose protein track
$pep_dropdown="";
$display_select="";
if(count($PEP)>1)
{
   $num="";
   $pep_dropdown="<form method=\"post\" name=\"select_track\" action=\"/XGDB/phplib/DisplayProteins.php?GDB=$X\">";
   $pep_dropdown.="<label for=\"select_track\" class=\"normalfont\">Use dropdown to select another dataset: </label>";
   $pep_dropdown.="<select name=\"track\" size=\"1\"  onchange=\"formSubmit('select_track')\">";
   $pep_dropdown .= "<option value=\"\">Select Protein Dataset:</option>\n\n";
  foreach ($PEP as $index=>$track)
  {
      $table_select=$track['table'];
      $track_select=$track['track'];
      $color_select=$track['color'];
      $display_select=$track['display'];
      $display=($display_select==0)?0:1; //defaults to 1
      $num=$index;
      if($display != 0)
      {
        $pep_dropdown .= "<option style=\"color:white; background-color:$color_select\" value=\"$num\">$track_select</option>\n\n";
      }
  }
  $pep_dropdown.="</select></form><br />";
}

//Paging: If a page limit is posted and the posted value does not equal the session value, then update the session variable

	if (isset($_POST['limiter']) && ($_POST['limiter'] != $_SESSION[$s_limit]))
	{
		$_SESSION[$s_limit] = intval($_POST['limiter']);
	}
	if (!isset($_SESSION[$s_limit]))
	{
		$limit = 100;
	}
	else if (isset($_SESSION[$s_limit]))
	{
		$limit = $_SESSION[$s_limit];
	}
	if (!isset($_POST['page']) || (isset($_POST['page']) && $_POST['page'] == 1) || (!isset($_SESSION[$s_page])))
	 {
		$page = 1;
		$start = 0;
	}
	else if (isset($_POST['page']) && $_POST['page'] > 1) 
	{
		$page = intval($_POST['page']);
		$start = (($page * $limit) - ($limit - 0));
	} 
	else if ($_SESSION[$s_page] > 1) 
	{
		$page = $_SESSION[$s_page];
		$start = (($page * $limit) - ($limit - 0));	
	}
	$_SESSION[$s_page] = $page;
	//general listings page


$recordPoint='getGSEG_Region.pl';

$DBtable="gseg_".$table_core."_good_pgs";
include_once('/xGDBvm/XGDB/phplib/db.inc.php');
$dbpass=dbpass();
$link = mysql_pconnect("localhost", "gdbuser", $dbpass) or die(mysql_error());
$dbh = mysql_select_db("$DBid", $link); //

//Core query components (DO NOT CHANGE ORDER)

	$searchCopyNum = "(select count(gi) from ".$DBid.".".$DBtable." where gi=a.gi group by gi)"; //subquery to find copy number each protein

	$searchCore ="select a.uid, a.gseg_gi, a.gi, a.l_pos, a.r_pos, a.sim, a.cov, a.mlength, a.G_O, a.pgs, length(b.seq), b.description, ".$searchCopyNum." as copy_num FROM ".$DBid.".".$DBtable." as a LEFT JOIN ".$DBid.".".$table_core." as b ON (a.gi=b.gi) WHERE 1";
	
	$orderBy=" order by a.gseg_gi, a.l_pos";
		
 	$searchLimit = " limit $start, $limit";

//************ GET functions - generic search case and special cases ***********//

//GET function: search field and searchword (search1)
if(isset($_GET['field']) && isset($_GET['search'])){
$fieldWord=mysql_real_escape_string($_GET['field']);
$searchWord=mysql_real_escape_string($_GET['search']);
		$_SESSION[$s_passed[1]] = 1;
		$_SESSION[$s_field[1]] = $fieldWord; //Add search field to session
		$_SESSION[$s_word[1]] = $searchWord; //add search query word to session
}


//GET function: region (special case for intron range search1)
if(isset($_GET['intron_min']) && isset($_GET['intron_max'])){

$intron_min=mysql_real_escape_string($_GET['intron_min']);
$intron_max=mysql_real_escape_string($_GET['intron_max']);
$rangeGet=$intron_min.'-'.intron_max;
$intronGet='introns_between';

		$_SESSION[$s_passed[1]] = 1;
		$_SESSION[$s_field[1]] = $intronGet; //Add search field to session
		$_SESSION[$s_word[1]] = $rangeGet; //add search query word to session
		$_SESSION[$s_link[1]] ='track='.$track_index.'&amp;intron_min='.$intron_min.'&amp; intron_max='.$intron_max;
}


//GET function: region (special case for chr range search1)
if(isset($_GET['gseg_gi']) && isset($_GET['l_pos']) && isset($_GET['gseg_gi'])){
$dbid=mysql_real_escape_string($_GET['dbid']);
$gseg_gi=mysql_real_escape_string($_GET['gseg_gi']);
$l_pos=mysql_real_escape_string($_GET['l_pos']);
$r_pos=mysql_real_escape_string($_GET['r_pos']);
$rangeGet=$gseg_gi.':'.$l_pos.'..'.$r_pos;
$gsegGet='scaff_from_to';

		$_SESSION[$s_passed[1]] = 1;
		$_SESSION[$s_field[1]] = $gsegGet; //Add search field to session
		$_SESSION[$s_word[1]] = $rangeGet; //add search query word to session
		$_SESSION[$s_link[1]] ='track='.$track_index.'&amp;$gsegGet=$rangeGet';
}

//GET function: id: (special case for search1;)
if(isset($_GET['gi'])){
$gi=mysql_real_escape_string($_GET['gi']);
		$_SESSION[$s_passed[1]] = 1;
		$_SESSION[$s_field[1]] = 'gi'; //Add search field to session
		$_SESSION[$s_word[1]] = $gi; //add search query word to session

}


//GET function: gseg (search2)
if(isset($_GET['gseg_gi'])){
$gseg_name=mysql_real_escape_string($_GET['gseg_gi']);
if($gseg_name !='no_filter'){
		$_SESSION[$s_passed[2]] = 2;
		$_SESSION[$s_field[2]] = 'gseg_gi'; //Add search field to session2
		$_SESSION[$s_word[2]] = $gseg_gi; //add search query word to session2
		}else{
		$_SESSION[$s_field[2]] = $_SESSION[$s_passed[2]] = $_SESSION[$s_word[2]] = "";
	}
}

//GET function: copy number
if(isset($_GET['copy_number'])){
$copy_number=mysql_real_escape_string($_GET['copy_number']);
if($copy_num !='no_filter'){
		$_SESSION[$s_passed[3]] = 3;
		$_SESSION[$s_field[3]] = 'copy_num'; //Add search field to session
		$_SESSION[$s_word[3]] = $copy_number; //add search query word to session
		}else{
		$_SESSION[$s_field[3]] = $_SESSION[$s_passed[3]] = $_SESSION[$s_word[3]] = "";
	}
}

//GET function: similarity
if(isset($_GET['similarity'])){
$similarity=mysql_real_escape_string($_GET['similarity']);
if($similarity !='no_filter'){
		$_SESSION[$s_passed[4]] = 4;
		$_SESSION[$s_field[4]] = 'sim'; //Add search field to session
		$_SESSION[$s_word[4]] = $similarity; //add search query word to session
		}else{
		$_SESSION[$s_field[4]] = $_SESSION[$s_passed[4]] = $_SESSION[$s_word[4]] = "";
	}
}

//GET function: coverage
if(isset($_GET['coverage'])){
$coverage=mysql_real_escape_string($_GET['coverage']);
if($coverage !='no_filter'){
		$_SESSION[$s_passed[5]] = 5;
		$_SESSION[$s_field[5]] = 'coverage'; //Add search field to session
		$_SESSION[$s_word[5]] = $coverage; //add search query word to session
		}else{
		$_SESSION[$s_field[5]] = $_SESSION[$s_passed[5]] = $_SESSION[$s_word[5]] = "";
	}
}
//********1.search**********//

if (isset($_POST['passed']) && $_POST['passed'] == 1) //If search initiated, build query based on posted values.
	{ 
		$p= ($_POST['passed'] == 1) ? 1 : 10;
		$search='search'.$p;
		$searchWord = mysql_real_escape_string(str_replace("*", "", trim($_POST[$search]))); 
		$searchWord = str_replace(",", "", $searchWord); //get rid of commas
		$fieldWord = mysql_real_escape_string($_POST['field']);
		if($fieldWord == 'anything') { //generic search; use all tables; 
				 $searchWord_str = '\''.$searchWord.'\'';
				 $searchWord_wild = '\'%'.$searchWord.'%\'';
				 $searchDetail[$p] = " AND ((a.gseg_gi = $searchWord_str) OR (a.gi LIKE $searchWord_wild) OR (b.description LIKE  $searchWord_wild))";
			}elseif ($fieldWord == 'scaff_from_to') { //parse scaff and coords for search; use = comparator; specify table a for forWord; 
	  	 	 $range_pattern='/(\S+):\s*([0-9]+)[\.\-]+([0-9]+)$/'; //e.g.scaff1:1000..2000 or scaff1:1000-2000
	  	 	 if(preg_match($range_pattern, $searchWord, $matches) == 1 ) {
				  $searchScaff = $matches[1];
				  $searchFrom = $matches[2];
				  $searchTo = $matches[3];
				} else { //show default
					  $searchScaff= 1;
					  $searchFrom=10000;
					  $searchTo=200000;
						}
				$_SESSION[$s_link[$p]] ='scaff='.$searchScaff.'&amp;l_pos='.$searchFrom.'&amp;r_pos='.$searchTo;
				$searchDetail[$p] = " AND a.gseg_gi='$searchScaff' AND a.l_pos> $searchFrom AND a.r_pos< $searchTo";
		    }elseif ($fieldWord == 'introns_between') { //parse scaff and coords for search; use = comparator; specify table a for forWord; 
	  	 	 $range_pattern='/(S\+)\s*\-*\s*([0-9]+){0,1}$/'; //e.g."1-3" or "6"
	  	 	 if(preg_match($range_pattern, $searchWord, $matches) == 1 ) {
				  $searchMin = $matches[1];
				  $searchMax = ($matches[2])? $matches[2] : $matches[1];
				} else { //show default
					  $searchMin=0;
					  $searchMax=999;
						}
				$_SESSION[$s_link[$p]] ='track='.$track_index.'&amp;intron_min='.$searchMin.'&amp; intron_max='.$searchMax;// for $_GET
				$searchDetail[$p] = " AND a.intron_count>= $searchMin AND a.intron_count<=$searchMax";
			}elseif($fieldWord == 'chr') {  // query for chr alone
				$_SESSION[$s_link[$p]] ='track='.$track_index.'&amp;field=chr&amp;search='.$searchWord;
				$searchDetail[$p] = " AND a.gseg_gi=$searchWord";
			}elseif($fieldWord == 'length_gte'){
				$_SESSION[$s_link[$p]] ='track='.$track_index.'&amp;field=length_gte&amp;search='.$searchWord;
				 $comparator = '>=';
				 $searchDetail[$p] = " AND mlength $comparator $searchWord";
				 
			}else{ //generic searchDetail for the following:
		
		   	if ($fieldWord == 'gi') { 
				$_SESSION[$s_link[$p]] ='field='.$fieldWord.'&amp;search='.$searchWord;
				 $table = 'a.';
				 $comparator = 'LIKE';
				 $searchWord = '\'%'.$searchWord.'%\''; //text string with wild card
 			}elseif($fieldWord == 'gseg_gi') {  // query for gseg (scaffold)
				 $_SESSION[$s_link[$p]] ='track='.$track_index.'&amp;field='.$fieldWord.'&amp;search='.$searchWord;
				 $table = 'a.';
 				 $comparator = '=';
				 $searchWord = '\''.$searchWord.'\''; //text string
			}elseif($fieldWord == 'description') {  // query for description; table b
				 $_SESSION[$s_link[$p]] ='track='.$track_index.'&amp;field='.$fieldWord.'&amp;search='.$searchWord;
				 $table = 'b.';
				 $comparator = 'LIKE';
				 $searchWord = '\'%'.$searchWord.'%\'';// text string with wild card
			}
				$_SESSION[$s_passed[$p]] = $p;
				$searchDetail[$p] = " AND $table$fieldWord $comparator $searchWord"; // build generic searchDetail;
			
	}
//store variables in session
	  if ($fieldWord == 'no filter'){//user wants to clear filter
	  	$searchDetail[$p] = "";
			$_SESSION[$s_passed[$p]] = '';
			$_SESSION[$s_field[$p]] = "";
			//$_SESSION[$s_word[$p]] = "Enter search term/region";
			//$_SESSION[$s_searchword] = "Enter search term/region";

			}else{
			$_SESSION[$s_passed[$p]] = $p;
			$_SESSION[$s_field[$p]] = mysql_real_escape_string($_POST['field']);//Add search field to session
			$_SESSION[$s_word[$p]] = mysql_real_escape_string(str_replace("*", "", trim($_POST[$search])));//add search query word to session
			//$_SESSION[$s_searchword] = $_SESSION[$s_word[$p]];
		}
	}
	else if(isset($_SESSION[$s_passed[1]])) //If session[1] exists, use those values
	{
		$p=1;//re-declare
		$fieldWord = $_SESSION[$s_field[$p]];
		$searchWord = $_SESSION[$s_word[$p]];
		if ($fieldWord == 'no filter'){ //user wants to clear search
	  	$searchDetail[$p] = '';
			$_SESSION[$s_field[$p]] = '';
			$_SESSION[$s_word[$p]] = '';
			$_SESSION[$s_link[$p]] = 'track='.$track_index;
			
		}elseif($fieldWord == 'anything') { //generic search; use all tables; 
			 $_SESSION[$s_link[$p]] ='track='.$track_index.'&amp;'.$fieldWord.'='.$searchWord;
				 $searchWord_str = '\''.$searchWord.'\'';
				 $searchWord_wild = '\'%'.$searchWord.'%\'';
				 $searchDetail[$p] = " AND ((a.gseg_gi = $searchWord_str) OR (a.gi LIKE $searchWord_wild) OR (b.description LIKE  $searchWord_wild))";
		} elseif($fieldWord == 'scaff_from_to') { //parse chr and coords for search; use = comparator; specify table a for forWord; 
		  $searchWord = str_replace(",", "", $searchWord); //get rid of commas
	  	  $range_pattern='/(\S+):\s*([0-9]+)[\.\-]+([0-9]+)$/'; //e.g.1:1000..2000 or 1:1000-2000
	  	  if(preg_match($range_pattern, $searchWord, $matches) == 1 ) {
		  	  $searchChr = $matches[1];
		  	  $searchFrom = $matches[2];
		  	  $searchTo = $matches[3];
		  		} else { //show default
				  $searchChr= 1;
				  $searchFrom=10000;
				  $searchTo=200000;
				}
			$_SESSION[$s_link[$p]] ='track='.$track_index.'&amp;scaff='.$searchScaff.'&amp;l_pos='.$searchFrom.'&amp;r_pos='.$searchTo;
			$searchDetail[$p] = " AND a.gseg_gi='$searchScaff' AND a.l_pos> $searchFrom AND a.r_pos< $searchTo";
		} elseif($fieldWord == 'introns_between') { //parse intron range for search; use = comparator; specify table a for forWord; 
	  	 	 $range_pattern='/(/S+)\s*\-*\s*([0-9]+){0,1}$/'; //e.g."1-3" or "6"
	  	 	 if(preg_match($range_pattern, $searchWord, $matches) == 1 ) {
				  $searchMin = $matches[1];
				  $searchMax = ($matches[2])? $matches[2] : $matches[1];
				} else { //show default
					  $searchMin=1;
					  $searchMax=3;
						}
				$_SESSION[$s_link[$p]] ='track='.$track_index.'&amp;intron_min='.$searchMin.'&amp; intron_max='.$searchMax;// for $_GET
				$searchDetail[$p] = " AND a.intron_count>= $searchMin AND a.intron_count<=$searchMax";
		} elseif($fieldWord == 'gseg_gi') {  // query for chr
			$_SESSION[$s_link[$p]] ='track='.$track_index.'&amp;field='.$fieldWord.'&amp;search='.$searchWord;
			$searchDetail[$p] = " AND a.gseg_gi=$searchWord";
		} elseif ($fieldWord == 'length_gte'){
			$_SESSION[$s_link[$p]] ='track='.$track_index.'&amp;field=length_gte&amp;search='.$searchWord;
			 $comparator = '>=';
			 $searchDetail[$p] = " AND mlength $comparator $searchWord";
		} else { //generic searchDetail for the following:
		
		   if ($fieldWord == 'gi') { //need to specify gi for MySQL
				$_SESSION[$s_link[$p]] ='track='.$track_index.'&amp;field='.$fieldWord.'&amp;search='.$searchWord;
				 $comparator = 'LIKE';
				 $table = 'a.';
				 $searchWord = '\'%'.$searchWord.'%\'';
			}elseif($fieldWord == 'gseg_gi') {  // query for gseg data
				$_SESSION[$s_link[$p]] ='track='.$track_index.'&amp;field='.$fieldWord.'&amp;search='.$searchWord;
				 $comparator = '=';
				 $table = 'a.';
				 $searchWord = '\''.$searchWord.'\''; //text string
			}elseif($fieldWord == 'description') {  // query for description; table b
				$_SESSION[$s_link[$p]] ='track='.$track_index.'&amp;field='.$fieldWord.'&amp;search='.$searchWord;
				 $comparator = 'LIKE';
				 $table = 'b.';
				 $searchWord = '\'%'.$searchWord.'%\'';
			  }
			$_SESSION[$s_passed[$p]] = $p;
			$searchDetail[$p] = " AND $table$fieldWord $comparator $searchWord"; //build generic searchdetail
		}
} else {
$searchDetail[1] = "";//if there is no search then just display the insertion page defaults
$_SESSION[$s_link[1]] ='track='.$track_index;
//$_SESSION[$s_searchword] = "Enter search term/region";

}
//********2.gseg**********//

if (isset($_POST['passed']) && $_POST['passed'] == 2) //gseg search, write to session2
	{
		$p=2;
		$search='search'.$p;
		$fieldWord = 'gseg_gi';
		$searchWord = mysql_real_escape_string(str_replace("*", "", trim($_POST[$search])));
		if ($searchWord == 'no filter'){//user wants to clear filter
	  			$searchDetail[$p] = "";
			$_SESSION[$s_passed[$p]] = '';
			$_SESSION[$s_field[$p]] = '';
			$_SESSION[$s_word[$p]] = '';
			$_SESSION[$s_link[$p]] ='track='.$track_index;

	  	}else{
			$_SESSION[$s_link[$p]] ='track='.$track_index.'&amp;gseg='.$searchWord;// for "get" URL
			$table = 'a.';
			$comparator = '=';
			$searchWord = '\''.$searchWord.'\'';
			$searchDetail[$p] = " AND ${table}${fieldWord} $comparator $searchWord";
			$_SESSION[$s_passed[$p]] = $p;
			$_SESSION[$s_field[$p]] = 'gseg_gi';//Add search field to session
			$_SESSION[$s_word[$p]] = mysql_real_escape_string(str_replace("*", "", trim($_POST[$search])));//add search query word to session
		}
	}
	else if(isset($_SESSION[$s_passed[2]])) //If session[2] exists use those values
	{
		$p=2;
		$gseg_name= $_SESSION[$s_word[$p]];
		$_SESSION[$s_link[$p]] ='gseg='.$gseg_name;
		$fieldWord = 'gseg_gi';
		$searchWord = $_SESSION[$s_word[$p]];
		$table = 'a.';
		$comparator = '=';
		$searchWord = '\''.$searchWord.'\'';
		$searchDetail[$p] = " AND ${table}${fieldWord} $comparator $searchWord";
	}else {
$searchDetail[2] = "";//if there is no filter then just display the page query defaults
$_SESSION[$s_link[2]] ='track='.$track_index;

}
//********3.copy_number*********//

if (isset($_POST['passed']) && $_POST['passed'] == 3) //copy number search, write to session3:
	{
		$p=3;
		$search='search'.$p;
		$fieldWord = $searchCopyNum; //nested query to find copy number -- see core query components
		$searchWord = mysql_real_escape_string(str_replace("*", "", trim($_POST[$search])));
		if ($searchWord == 'no filter'){//user wants to clear filter
	  		$searchDetail[$p] = "";
			$_SESSION[$s_passed[$p]] = '';
			$_SESSION[$s_field[$p]] = '';
			$_SESSION[$s_word[$p]] = '';
			$_SESSION[$s_link[$p]] ='track='.$track_index;			 
	  	}else{
		$_SESSION[$s_link[$p]] ='track='.$track_index.'&amp;copy_number='.$searchWord;//we want to store the lt or gt before parsing
		$greater='/gt_([0-9]+)/';//e.g. gt_5
		$lesser='/lt_([0-9]+)/';//e.g. lt_2
		$equal='/eq_([0-9]+)/';//e.g. eq_2
 		if(preg_match($greater, $searchWord, $match)) {
 			$comparator= '>';
 			$searchWord = $match[1];
   		}elseif(preg_match($lesser, $searchWord, $match)){
  			$comparator = '<';
  			$searchWord = $match[1];
   		}elseif(preg_match($equal, $searchWord, $match)){
  			$comparator = '=';
  			$searchWord = $match[1];
  		}
		$_SESSION[$s_passed[$p]] = $p;
		$_SESSION[$s_field[$p]] = 'copy_num';//Add search field to session
		$_SESSION[$s_word[$p]] = mysql_real_escape_string(str_replace("*", "", trim($_POST[$search])));//add search query word to session
		$searchDetail[$p] = " AND $fieldWord $comparator $searchWord";

		}
	}
	else if(isset($_SESSION[$s_passed[3]])) //If session[3] exists use those values
	{
		$p=3;
		$fieldWord = $searchCopyNum; //nested query to find copy number -- see core query components
		$searchWord = $_SESSION[$s_word[$p]];
  		$_SESSION[$s_link[$p]] ='track='.$track_index.'&amp;copy_number='.$searchWord;
		$greater='/gt_([0-9]+)/';//e.g. gt_5
		$lesser='/lt_([0-9]+)/';//e.g. lt_2
		$equal='/eq_([0-9]+)/';//e.g. eq_2
 		if(preg_match($greater, $searchWord, $match)) {
 			$comparator= '>';
 			$searchWord = $match[1];
   		}elseif(preg_match($lesser, $searchWord, $match)){
  			$comparator = '<';
  			$searchWord = $match[1];
   		}elseif(preg_match($equal, $searchWord, $match)){
  			$comparator = '=';
  			$searchWord = $match[1];
  			}
		$searchDetail[$p] = " AND $fieldWord $comparator $searchWord";
	}else{
$searchDetail[3] = "";//if there is no filter then just display the page query defaults
$_SESSION[$s_link[3]] ='';

}


//********4.similarity*********//

if (isset($_POST['passed']) && $_POST['passed'] == 4) //similarity search, write to session4:
	{
		$p=4;
		$search='search'.$p;
		$fieldWord = 'sim';
		$searchWord = mysql_real_escape_string(str_replace("*", "", trim($_POST[$search])));
		if ($searchWord == 'no filter'){//user wants to clear filter
	  		$searchDetail[$p] = "";
			$_SESSION[$s_passed[$p]] = '';
			$_SESSION[$s_field[$p]] = '';
			$_SESSION[$s_word[$p]] = '';
			$_SESSION[$s_link[$p]] ='track='.$track_index;			 
	  	}else{
	  	$table = 'a.';
		$_SESSION[$s_link[$p]] ='track='.$track_index.'&amp;sim='.$searchWord;//we want to store the lt or gt before parsing
		$greater='/gt(\.[0-9]{2})/';//e.g. gt.75
		$lesser='/lt(\.[0-9]{2})/';//e.g. lt.75
 		if(preg_match($greater, $searchWord, $match)) {
 			$comparator= '>';
 			$searchWord = $match[1];
   		}elseif(preg_match($lesser, $searchWord, $match)){
  			$comparator = '<';
  			$searchWord = $match[1];
  			}
		$_SESSION[$s_passed[$p]] = $p;
		$_SESSION[$s_field[$p]] = 'sim';//Add search field to session
		$_SESSION[$s_word[$p]] = mysql_real_escape_string(str_replace("*", "", trim($_POST[$search])));//add search query word to session
		$searchDetail[$p] = " AND $table$fieldWord $comparator $searchWord";

		}
	}
	else if(isset($_SESSION[$s_passed[4]])) //If session[4] exists use those values
	{
		$p=4;
		$fieldWord = 'sim';
		$searchWord = $_SESSION[$s_word[$p]];
  		$_SESSION[$s_link[$p]] ='track='.$track_index.'&amp;sim='.$searchWord;
		$table = 'a.';
		$greater='/gt(\.[0-9]{2})/';//e.g. gt.75
		$lesser='/lt(\.[0-9]{2})/';//e.g. lt.75
 		if(preg_match($greater, $searchWord, $match)) {
 			$comparator= '>';
 			$searchWord = $match[1];
   		}elseif(preg_match($lesser, $searchWord, $match)){
  			$comparator = '<';
  			$searchWord = $match[1];
  			}
		$searchDetail[$p] = " AND $table$fieldWord $comparator $searchWord";
	}else{
$searchDetail[4] = "";//if there is no filter then just display the page query defaults
$_SESSION[$s_link[4]] ='track='.$track_index;

}
	
//********5.coverage********//

if (isset($_POST['passed']) && $_POST['passed'] == 5) //coverage search, write to session5:
	{
		$p=5;
		$search='search'.$p;
		$fieldWord = 'cov';
		$searchWord = mysql_real_escape_string(str_replace("*", "", trim($_POST[$search])));
		if ($searchWord == 'no filter'){//user wants to clear filter
	  		$searchDetail[$p] = "";
			$_SESSION[$s_passed[$p]] = '';
			$_SESSION[$s_field[$p]] = '';
			$_SESSION[$s_word[$p]] = '';
			$_SESSION[$s_link[$p]] ='track='.$track_index;			 
	  	}else{
	  	$table = 'a.';
		$_SESSION[$s_link[$p]] ='track='.$track_index.'&amp;coverage='.$searchWord;//we want to store the lt or gt before parsing
		$greater='/gt(\.[0-9]{2})/';//e.g. gt.75
		$lesser='/lt(\.[0-9]{2})/';//e.g. lt.75
 		if(preg_match($greater, $searchWord, $match)) {
 			$comparator= '>';
 			$searchWord = $match[1];
   		}elseif(preg_match($lesser, $searchWord, $match)){
  			$comparator = '<';
  			$searchWord = $match[1];
  			}
		$_SESSION[$s_passed[$p]] = $p;
		$_SESSION[$s_field[$p]] = 'cov';//Add search field to session
		$_SESSION[$s_word[$p]] = mysql_real_escape_string(str_replace("*", "", trim($_POST[$search])));//add search query word to session
		$searchDetail[$p] = " AND $table$fieldWord $comparator $searchWord";

		}
	}
	else if(isset($_SESSION[$s_passed[5]])) //If session[5] exists use those values
	{
		$p=5;
		$fieldWord = 'coverage';
		$searchWord = $_SESSION[$s_word[$p]];
  		$_SESSION[$s_link[$p]] ='track='.$track_index.'&amp;coverage='.$searchWord;
		$table = 'a.';
		$greater='/gt(\.[0-9]{2})/';//e.g. gt.75
		$lesser='/lt(\.[0-9]{2})/';//e.g. lt.75
 		if(preg_match($greater, $searchWord, $match)) {
 			$comparator= '>';
 			$searchWord = $match[1];
   		}elseif(preg_match($lesser, $searchWord, $match)){
  			$comparator = '<';
  			$searchWord = $match[1];
  			}
		$searchDetail[$p] = " AND $table$fieldWord $comparator $searchWord";
	}else{
$searchDetail[5] = "";//if there is no filter then just display the page query defaults
$_SESSION[$s_link[5]] ='';

}

//Build query and store query in session:

$searchQuery = $searchCore.$searchDetail[1].$searchDetail[2].$searchDetail[3].$searchDetail[4].$searchDetail[5].$orderBy.$searchLimit;
$searchTotal = $searchCore.$searchDetail[1].$searchDetail[2].$searchDetail[3].$searchDetail[4].$searchDetail[5].$orderBy;
$_SESSION[$s_query] = $searchTotal;//used in csv_DisplayProteins.php!! For this reason, the searchTotal query needs to be IDENTICAL to the searchQuery except for the limits.

//get query results:
$get_proteins = $searchQuery;
$check_get_proteins = mysql_query($get_proteins);
$get_total = $searchTotal;
$check_get_total = mysql_query($get_total);
$entries = mysql_num_rows($check_get_total);
$pages = ceil($entries/$limit);
while ($pages > 0) {
	$page_number = ($pages - ($page - 1));
	/* page number = (32 - (32 - 1)) = 1 */
	if ($_SESSION[$s_page] == $pages) {
		$display_pages = "<option value=\"$pages\" selected=\"selected\">$pages</option>";
	} else {
		$display_pages .= "<option value=\"$pages\">$pages</option>";
	}
	$pages = $pages - 1;
}

//assign column class according to active filters:
$gseg_class = (isset($_SESSION[$s_field[2]]) && $_SESSION[$s_field[2]]=='gseg_gi') ? "selected" : "";
$reg_class  = (isset($_SESSION[$s_field[1]]) && $_SESSION[$s_field[1]]=='chr_from_to') ? "selected" : "";
$mlen_class = (isset($_SESSION[$s_field[1]]) && $_SESSION[$s_field[1]]=='length_gte') ? "selected" : "";
$int_class  = (isset($_SESSION[$s_field[1]]) && $_SESSION[$s_field[1]]=='introns_between') ? "selected" : "";
$desc_class = (isset($_SESSION[$s_field[1]]) && $_SESSION[$s_field[1]]=='description') ? "selected" : "";
$copy_class = (isset($_SESSION[$s_field[3]]) && $_SESSION[$s_field[3]]=='copy_num') ? "selected" : "";
$sim_class  = (isset($_SESSION[$s_field[1]]) && $_SESSION[$s_field[1]]=='sim') ? "selected" : "";
$sim2_class = (isset($_SESSION[$s_field[4]]) && $_SESSION[$s_field[4]]=='sim') ? "selected" : "";
$cov_class  = (isset($_SESSION[$s_field[5]]) && $_SESSION[$s_field[5]]=='cov') ? "selected" : "";
$cov2_class = (isset($_SESSION[$s_field[1]]) && $_SESSION[$s_field[1]]=='cov') ? "selected" : "";

//GDB 	Scaffold/BAC ID 	Splice-Aligned Protein ID 	Start position 	End position 	Description 	Date

$display_block = "<table class=\"row_middle featuretable\" width=\"100%\">

<col width=\"5%\" />
<col class=\"$gseg_class\" width=\"10%\" />
<col width=\"15%\" />
<col width=\"5%\" />
<col class=\"$reg_class\" width=\"5%\" />
<col class=\"$mlen_class\" width=\"5%\" />
<col class=\"$int_class\" width=\"5%\" />
<col class=\"$sim_class $sim2_class\" width=\"3%\" />
<col class=\"$cov_class $cov2_class \" width=\"3%\" />
<col width=\"3%\" />
<col class=\"$copy_class\" width=\"3%\" />
<col class=\"$desc_class\" width=\"40%\" />
<thead>
<tr>

<th title=\"click to view in genome context\" align=\"center\">GDB</th>
<th class=\"$gseg_class\" title=\"genome segment\" align=\"center\">Scaffold ID</th>
<th title=\"click to view protein record\" align=\"center\">Protein ID</th>
<th title=\"strand\" align=\"center\">Strand</th>
<th class=\"$reg_class\" title=\"from/to position on genome\" align=\"center\">From / To</th>
<th class=\"$mlen_class\" title=\"mRNA length\" align=\"center\">mRNA length</th>
<th class=\"$int_class\" title=\"intron count\" align=\"center\">Intron Count</th>
<th class=\"$sim_class $sim2_class\" title=\"similarity score\" align=\"center\">Similarity</th>
<th class=\"$cov_class $cov2_class\" title=\"coverage score\" align=\"center\">Coverage</th>
<th title=\"Click to view GenomeThreader alignment\" align=\"center\">GTH</th>
<th class=\"$copy_class\" title=\"Copy number\" align=\"center\">Copy #</th>
<th class=\"$desc_class\" title=\"protein description\" align=\"center\">Description</th>

</tr></thead><tbody>
";

while ($data_array = mysql_fetch_array($check_get_proteins)) 
{
//pull data from DB to correspond with headers
//	$searchCore ="select a.uid, a.gseg_gi, a.gi, a.l_pos, a.r_pos, a.sim, a.cov, a.mlength, a.G_O, a.pgs, length(b.seq), b.description FROM ".$DBid.".gseg_pep_pgs as a LEFT JOIN ".$DBid.".pep as b ON (a.gi=b.gi) WHERE 1";

	$uid = $data_array['uid'];
	$gseg_gi = $data_array['gseg_gi'];
	$protein_id = $data_array['gi'];
	$protein_id_link = "<span  class=\"\"><a title=\"View record at $DBid (opens a new web browser page/tab)\" target=\"_blank\" href=\"/${DBid}/cgi-bin/findRecord.pl?dbid=0;resid=4;id=$protein_id\">$protein_id</a></span>"; ## broken!
	$l_pos = $data_array['l_pos'];
	$l_pos_pad = ($l_pos - 1000 > 0) ? $l_pos -1000 : 1;
	$r_pos = $data_array['r_pos'];
	$r_pos_pad = $r_pos +1000;
	$mlength = $data_array['mlength'];
	$pgs = $data_array['pgs'];
	$introns=substr_count($pgs, ","); //number of commas = number of introns
	$strand = $data_array['G_O'];
	$description = $data_array['description'];
	$description_trim = str_replace("<", "", (str_replace(">", "", $description)));
	$description_display=substr($description_trim, 0, 75).'...';
	$copy_num = $data_array['copy_num'];
	$copy_num_link = "<span  class=\"\"><a title=\"View all locations for this spliced alignment\" href=\"/XGDB/phplib/DisplayProteins.php?GDB=$DBid&amp;gi=$protein_id\">$copy_num</a></span>";
	$coverage = $data_array['cov'];
	$similarity = $data_array['sim'];
	$gth_link = "<span  class=\"\"><a title=\"View GenomeThreader alignment for $protein_id (opens a new web browser page/tab)\" target=\"_blank\" href=\"/${DBid}/cgi-bin/getGSQ.pl?gsegSRC=${DBid}scaffold&amp;dbid=0&amp;resid=4&amp;pgs_uid=$uid\"><img src=\"/XGDB/images/GTHParam.png\" alt=\"\" /></a></span>";
	$gdb_link="<span  class=\"gdblink xgdb\"><a title=\"View at $DBid (opens a new web browser page/tab)\" target=\"_blank\" href=\"/${DBid}/cgi-bin/${recordPoint}?dbid=0&amp;gseg_gi=$gseg_gi&amp;bac_lpos=$l_pos_pad&amp;bac_rpos=$r_pos_pad\"></a></span>";
	if($coverage<=.9 && $coverage >.8) {
		$cov_color="#B100BF";
		}elseif($coverage<=.8)
		{	
		$cov_color="red";
		}else
		{
		$cov_color="";
		}
	if($similarity<=.9 && $similarity >.8) {
		$sim_color="#B100BF";
		}elseif($similarity<=.8)
		{	
		$sim_color="red";
		}else
		{
		$sim_color="";
		}

	$len = round(($r_pos-$l_pos)/1000, 1);
	
	$display_block .= "<tr>";
	$display_block .= "
	<td>$gdb_link</td>
	<td align=\"center\">
	    $gseg_gi
	</td>
	<td align=\"center\">
	    <a target=\"_blank\" href=\"/$DBid/cgi-bin/findRecord.pl?id=$protein_id\" title=\"View record (opens a new browser window)\">$protein_id</a>
	</td>
	<td align=\"center\">$strand</td>
	<td align=\"center\">$l_pos<br />$r_pos</td>
	<td align=\"center\">$mlength</td>
	<td align=\"center\">$introns</td>
	<td style=\"color:$sim_color\" align=\"center\">$similarity</td>
	<td style=\"color:$cov_color\" align=\"center\">$coverage</td>
	<td align=\"center\">$gth_link</td>
	<td style=\"color:$copy_class\" align=\"center\">$copy_num_link</td>
	<td title=\" $description\" align=\"left\" style=\"cursor:pointer\">$description</td>
	</tr>";


}
//setup drop down for entries per page based on current limit

$display_block .= "</tbody></table>";


//setup drop down for entries per page based on current limit
if ((isset($_SESSION[$s_limit]) && $_SESSION[$s_limit] == 100) || !isset($_SESSION[$s_limit])) {
$display_select .= "
<select name=\"limiter\" size=\"1\">
<option value=\"100\" selected=\"selected\">100</option>
<option value=\"200\">200</option>
<option value=\"500\">500</option>
<option value=\"1000\">1000</option>
<option value=\"5000\">5000</option>
</select>
";
}
if (isset($_SESSION[$s_limit]) && $_SESSION[$s_limit] == 200) {
$display_select .= "
<select name=\"limiter\" size=\"1\">
<option value=\"100\">100</option>
<option value=\"200\" selected=\"selected\">200</option>
<option value=\"500\">500</option>
<option value=\"1000\">1000</option>
<option value=\"5000\">5000</option>
</select>
";
}
if (isset($_SESSION[$s_limit]) && $_SESSION[$s_limit] == 500) {
$display_select .= "
<select name=\"limiter\" size=\"1\">
<option value=\"100\">100</option>
<option value=\"200\">200</option>
<option value=\"500\" selected=\"selected\">500</option>
<option value=\"1000\">1000</option>
<option value=\"5000\">5000</option>
</select>

";
}
if (isset($_SESSION[$s_limit]) && $_SESSION[$s_limit] == 1000) {
$display_select .= "
<select name=\"limiter\" size=\"1\">
<option value=\"100\">100</option>
<option value=\"200\">200</option>
<option value=\"500\">500</option>
<option value=\"1000\" selected=\"selected\">1000</option>
<option value=\"5000\">5000</option>
</select>
";
}
if (isset($_SESSION[$s_limit]) && $_SESSION[$s_limit] == 5000) {
$display_select .= "
<select name=\"limiter\" size=\"1\">
<option value=\"100\">100</option>
<option value=\"200\">200</option>
<option value=\"500\">500</option>
<option value=\"1000\">1000</option>
<option value=\"5000\" selected=\"selected\">5000</option>
</select>

";
}

//build bookmark link (display_link)

$part_a="<a id=\"selfReference\" title=\"right click to copy this link\" href=\"/XGDB/phplib/DisplayProteins.php?GDB=$X";

	$n=5;//number of queries.
	$i=1;
	$part_b = '';
	$part_c = '';
	while($i<=$n){
		if($_SESSION[$s_link[$i]]){
		$part_b='?';
		$part_c .= $_SESSION[$s_link[$i]];
		}
		if($_SESSION[$s_link[$i]]){
			$part_c .='&amp;';
		}
	  $i++;
	  
 }

$part_d = "\">Link to this page</a>";
$display_link = $part_a.$part_b.$part_c.$part_d;

?>
</form><!-- end of GUIform-->
<div id="mainWLS2">
<div id="maincontentscontainer">
<div id="maincontents">
	<table width="1000px">
		<col width="35%" /><col width="60%" /><col width="5%" />
		<tr>
			<td>
				<h1 class="bottommargin1 nowrap">
					<?php echo "Aligned Proteins: <span class=\"largerfont\" style=\"border: 3px solid $selected_color; color: white; background-color: $selected_color\"> &nbsp; $selected_track &nbsp;</span>  " ; ?> &nbsp; <img id="tracks_proteins" title="Click for Aligned Proteins Help" style="margin-bottom:-1px" src="/XGDB/images/help-icon.png" alt="?" class="xgdb-help-button" /><span class="heading"> In order of aligned location.</span>
				</h1>
				<?php //echo $searchTotal ?>
                <?php echo $pep_dropdown; ?>
			</td>
		</tr>
		<tr>
			<td align="left" style="padding-bottom:1.5em">
						<?php 	//build query filter report
						        $n=5;//number of queries.
								$i=1;
								$filter=false;
								$active_filters="";
								$active_search=array();
								$active_word=array();
								while($i<=$n){
								if(isset($_SESSION[$s_field[$i]])){
										$filter=true;
										$active_search[$i]= $_SESSION[$s_field[$i]].",";
										$active_word[$i] = $_SESSION[$s_word[$i]];
									}else{
										$active_search[$i] = "";
										$active_word[$i] = "";
										}
								$active_filters .= $active_search[$i].'span class="attention_text">'.$active_word[$i].'</span>&nbsp;';
								$i++;
									}
							$records = ($entries == 1) ? 'record' : 'records';
							if($filter == true){
							echo "
							<span class=\"normalfont\">
							Filter on; retrieved <!--span>$active_filters</span--> <b>$entries</b> $records | <a href=\"/XGDB/phplib/Display_clear_filters.php?table=${table_core}&amp;dbid=${DBid}&amp;n=${n}&amp;index=${track_index}&amp;redirect=Proteins\">Clear&nbsp;All&nbsp;Filters</a> |</span>
							";
							}else{
							echo "
								<span class=\"normalfont\" >No filters | <b>$entries</b> records </span>
							"; 
							}
						?>
				</td>
				<td align="right" style="padding-bottom:1.5em">
						<span class="normalfont" style="margin-right: 1em"><a href="/XGDB/phplib/csv_DisplayProteins.php?track=<?php echo $track_index; ?>&amp;GDB=<?php echo $X; ?>">Download&nbsp;.csv</a></span>
				</td>
			</tr>
	</table>
		<table id="header_functions" width="950px" border="0">
				<col width="35%" /><col width="45%" /><col width="8%" /><col width="5%" /><col width="5%" /><col width="5%" />
			<tr valign="top">
					<td align="left">
						<fieldset  class="header_functions">
					<h2>Search:<span class="heading"> Enter category, term, click "Go".</span> </h2>
						<form method="post" name="general_search" action="/XGDB/phplib/DisplayProteins.php?GDB=<?php echo $X; ?>">
							<table style="margin:10px 5px 30px 0; width: 100%;">
								<tr>
									<td width="100%" align = "right">
										<span class="<?php active_search(1, isset($_SESSION[$s_passed[1]])?$_SESSION[$s_passed[1]]:""); ?> bold">Category:&nbsp;<img id="tracks_search" title="Click for explanation" src="/XGDB/images/help-icon.png" alt="?" class="xgdb-help-button" /></span>
										<select class="<?php active_search(1, isset($_SESSION[$s_passed[1]])?$_SESSION[$s_passed[1]]:""); ?>" name="field">
													<?php search_dropdown(isset($_SESSION[$s_field[1]])?$_SESSION[$s_field[1]]:""); ?>	
			
										</select><br /><br />
											 <input class="normalfont <?php active_search(1, isset($_SESSION[$s_passed[1]])?$_SESSION[$s_passed[1]]:""); ?>" style="text-align:center" type="text" name="search1" size="24" value="<?php echo isset($_SESSION[$s_word[1]])?$_SESSION[$s_word[1]]:""; ?>" onfocus="this.value=''" />
											 <input type="hidden" name="passed" value="1" />
										    <input type="hidden" name="track" value="<?php echo $track_index; ?>" />
											 <input type="submit" name="submit" value="Go" />
									</td>
								</tr>
							</table>
							</form>
						</fieldset>
				   </td>							
					<td>
					<fieldset class="header_functions">
					
										<script type="text/javascript">
										/* <![CDATA[ */
										
										function formSubmit(name) {
											//alert('hi we got here');
											var objForm = document.forms[name]
											//alert(name);
											objForm.submit();
										}
										/* ]]> */
										</script>
					
					<h2>Filters:<span class="heading"> Multiple search filters are boolean ("AND")</span> </h2>
						<form method="post" name="gseg" action="/XGDB/phplib/DisplayProteins.php?GDB=<?php echo $X; ?>">
							<table style="margin:10px 0 0 0; width: 100%;">
								<tr align="center">
									<td width="40%" align = "right">
										<input type="hidden" name="field2" value="gseg_name" />
								   		<span class="<?php active_search(2, isset($_SESSION[$s_passed[2]])?$_SESSION[$s_passed[2]]:""); ?> bold">Scaffold ID:&nbsp;<img id="tracks_scaffold" title="Click for explanation" src="/XGDB/images/help-icon.png" alt="?" class="xgdb-help-button" /></span>
								   		</td>
								   		<td width="60%" align = "left">
											<select class="<?php active_search(2, isset($_SESSION[$s_passed[2]])?$_SESSION[$s_passed[2]]:""); ?>" onchange="formSubmit('gseg');" name="search2">
										<?php gseg_dropdown(isset($_SESSION[$s_word[2]])?$_SESSION[$s_word[2]]:"", $DBid, $table_core); ?>	
												</select>
										<!-- <input type="submit"  value="Go" /> -->
										<input type="hidden" name="passed" value="2" />
										<input type="hidden" name="track" value="<?php echo $track_index; ?>" />
									</td>
								</tr>
						</table>
						</form>
						<form method="post" name="copy_number" action="/XGDB/phplib/DisplayProteins.php?GDB=<?php echo $X; ?>">
						<table style="margin:0; width: 100%;">
							<tr align="center">
								<td width="40%" align = "right">
								<input type="hidden" name="field3" value="status" />
							   		<span class="<?php active_search(3, isset($_SESSION[$s_passed[3]])?$_SESSION[$s_passed[3]]:""); ?> bold">Copy Number:&nbsp;<img id="tracks_copynum" title="Click for help with copy number" src="/XGDB/images/help-icon.png" alt="?" class="xgdb-help-button" /></span>
							   		</td>
							   		<td width="60%" align = "left">
										<select class="<?php active_search(3, isset($_SESSION[$s_passed[3]])?$_SESSION[$s_passed[3]]:""); ?>" onchange="formSubmit('copy_number');" name="search3">
										<?php copynumber_dropdown(isset($_SESSION[$s_word[3]])?$_SESSION[$s_word[3]]:""); ?>	
										</select>
										<!-- <input type="submit"  value="Go" /> -->
										<input type="hidden" name="passed" value="3" />
										<input type="hidden" name="track" value="<?php echo $track_index; ?>" />
									</td>
								</tr>
							</table>
						</form>
						
						<form method="post" name="similarity" action="/XGDB/phplib/DisplayProteins.php?GDB=<?php echo $X; ?>">
						<table style="margin:0 ; width: 100%;">
							<tr align="center">
								<td width="40%" align = "right">
								<input type="hidden" name="field4" value="similarity" />
							   		<span class="<?php active_search(4, isset($_SESSION[$s_passed[4]])?$_SESSION[$s_passed[4]]:""); ?> bold">Similarity Score:&nbsp;<img id="tracks_similarity" title="Click for explanation" src="/XGDB/images/help-icon.png" alt="?" class="xgdb-help-button" /></span>
							   		</td>
							   		<td width="60%" align = "left">
										<select class="<?php active_search(4, isset($_SESSION[$s_passed[4]])?$_SESSION[$s_passed[4]]:""); ?>" onchange="formSubmit('similarity');" name="search4">
										<?php similarity_dropdown(isset($_SESSION[$s_word[4]])?$_SESSION[$s_word[4]]:""); ?>	
										</select>
										<!-- <input type="submit"  value="Go" /> -->
										<input type="hidden" name="passed" value="4" />
										<input type="hidden" name="track" value="<?php echo $track_index; ?>" />
									</td>
								</tr>
							</table>
						</form>

						<form method="post" name="coverage" action="/XGDB/phplib/DisplayProteins.php?GDB=<?php echo $X; ?>">
							<table style="margin:0 0 10px 0 ; width: 100%;">
							<tr align="center">
								<td width="40%" align = "right">
								<input type="hidden" name="field5" value="coverage" />
							   		<span class="<?php active_search(5, isset($_SESSION[$s_passed[5]])?$_SESSION[$s_passed[5]]:""); ?> bold">Coverage Score:&nbsp;<img id="tracks_coverage" title="Click for explanation" src="/XGDB/images/help-icon.png" alt="?" class="xgdb-help-button" /></span>
							   		</td>
							   		<td width="60%" align = "left">
										<select class="<?php active_search(5, isset($_SESSION[$s_passed[5]])?$_SESSION[$s_passed[5]]:""); ?>" onchange="formSubmit('coverage');" name="search5">
										<?php coverage_dropdown(isset($_SESSION[$s_word[5]])?$_SESSION[$s_word[5]]:""); ?>	
										</select>
										<!-- <input type="submit"  value="Go" /> -->
										<input type="hidden" name="passed" value="5" />
										<input type="hidden" name="track" value="<?php echo $track_index; ?>" />
									</td>
								</tr>
							</table>
						</form>

						</fieldset>
					</td>
				<td colspan="4" align="left">
					<fieldset  class="header_functions">
					<h2>Pages:</h2>
							<table style="margin:5px 0 12px 10px; width: 100%;">
								<tr>
									<td>
									# / Page:<br />		
										<form method="post" action="/XGDB/phplib/DisplayProteins.php?GDB=<?php echo $X; ?>">
											
											<?php
											echo $display_select;
											?>
											
											<input type="submit" value="Submit" name="submit" />
									
										</form>		
									</td>
									<td align="right">
									<br />
										<form method="post" action="/XGDB/phplib/DisplayProteins.php?GDB=<?php echo $X; ?>">
											<input type="hidden" name="page" value="<?php echo $_SESSION[$s_page]-1; ?>" />
											<input class="largerfont" type="submit" value="&lt;" name="submit" />
										</form>
									</td>
									<td align="center">
										<form method="post" action="/XGDB/phplib/DisplayProteins.php?GDB=<?php echo $X; ?>">
										Page:<br />
											<select name="page"  id="page">
												 <?php
												echo $display_pages;
												?>
											</select>
											<input type="submit" value="Go" name="submit" />
										</form>
									</td>
									<td align="left" >
										<br />
										<form method="post" action="/XGDB/phplib/DisplayProteins.php?GDB=<?php echo $X; ?>">
											<input type="hidden" name="page" value="<?php echo $_SESSION[$s_page]+1; ?>" />
											<input class="largerfont" type="submit" value="&gt;" name="submit" accesskey="n" />
										</form>
									</td>
								</tr>
								<tr>
									<td colspan="4">
										<?php if ($entries > 1) {
											if ($limit > $entries){
												$limit = $entries;
												}
											$recordStart = $start+1;
											$recordLimit = $start+$limit;
											if ($recordLimit > $entries){
												$recordLimit = $entries;
												}
													echo "<span class=\"smallerfont\">Showing: <b>$recordStart</b> - <b>$recordLimit</b> out of <b>$entries</b> records</span>";
											}
									?>
									</td>
								</tr>
							</table>
						</fieldset>
					</td>
							
				</tr>
				<tr style="margin-top:1em">
					<td colspan="5">
					
					<span  class="bottommargin1"><?php  echo $display_link ?></span>
					</td>
					<td  colspan="2" align="right" style="margin-right:1em">
					</td>
				</tr>
		</table>
					
<?php 
if($table_core != ""){
echo $display_block;
}else{
echo "<table><tr><td>Please select a track to display</td></tr></table>";
}
?>
		</div>
						  <div style="clear:both; float:right">
							<a href="http://validator.w3.org/check?uri=referer"><img
							  src="http://www.w3.org/Icons/valid-xhtml10" alt="Valid XHTML 1.0 Transitional" height="15" width="44" /></a>
						  </div>						
	</div><!--mainWLS2-->
</div>
<?php include("/xGDBvm/XGDB/phplib/footer.php"); ?>
</div>
</body>
</html>
