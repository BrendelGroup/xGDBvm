<?php
#error_reporting( error_reporting() & ~E_NOTICE );
session_start();
if (preg_match('/(GDB\d\d\d)/', $_SERVER['HTTP_REFERER'], $matches))
        $X = $matches[1];
if (preg_match('/(GDB\d\d\d)/',$_REQUEST['GDB'], $matches)) ;
        $X = $matches[1];

if(empty($SITEDEF_H)) { require('/xGDBvm/data/' . $X .'/conf/SITEDEF.php'); }
if(empty($PARAM_H)){require('/xGDBvm/XGDB/phplib/getPARAM.php');}
require_once('/xGDBvm/XGDB/phplib/SSI_GDBprep.php');
virtual("${CGIPATH}SSI_GDBgui.pl/STANDARD_HEADER/$SSI_QUERYSTRING");
require_once('/xGDBvm/XGDB/phplib/DisplayLoci_functions.inc.php');
?>
<?php
$pgdbmenu = "Genomes";
$DBid = $X;
$leftmenu = "AllGenes";
$PageTitle = "All".$DBid.  " Genes";

// Global parameters

global $status_class, $display_pages, $annoId, $active_filters, $entries, $display_message;

// First create 'track' session ID that stores which track is in use,  or else use current session variable. Session ID must be distinct from DisplayProteins.php and DisplayTranscripts.php

     $s_track = $DBid."locus-track"; // build unique identifier (session variable)

    if(isset($_GET['track'])) // track is an integer corresponding to GENE array index in SITEDEF.php e.g. GENE[0]
    {
        $track_index=intval($_GET['track']);

    	$_SESSION[$s_track] = $track_index;
    }
        else if (isset($_POST['track']))
    {
        $track_index=intval($_POST['track']);
        
    	$_SESSION[$s_track] = $track_index;
    }
       else if (isset($_SESSION[$s_track]))
    {
        $track_index=intval($_SESSION[$s_track]);
    }  
       else if (!isset($_SESSION[$s_track]))
    {
        $track_index="0";
    	$_SESSION[$s_track] = "0";// default to the first track (index 0)
    }

// get track table, track name, etc. from SITEDEF.php based on posted value 

$index=intval($track_index); 
$table_core=$GENE[$index]['locus_table'];
$selected_track=$GENE[$index]['track'];
$selected_color=$GENE[$index]['color'];

//Now create session and other variables that retain query results upon page reload and are unique to the track (table), if more than one.
//This prevents session ID collisions when more than one track is being queried in a single browser session.

$sessID=$table_core.$DBid; // a unique ID root for session variables, to include source table (e.g. 'gene' or 'cpgat_gene')  GDBid ($X), e.g. 'geneGDB007',

//$s_track = $sessID."track";
$s_limit = $sessID."limit";
$s_page = $sessID."page";
$s_query = $sessID."query";

$s_passed = array(); //which post (1, 2, etc)
$s_field = array(); //the query field
$s_word = array(); //the query item
$s_link = array(); //link builder
$n=5;//number of simultaneous query sessions-- adjust this to match query count if this script is modified
$i=1;
while($i<=$n) //create unique session array names
  { 
	$s_passed[$i]=$sessID."passed".$i;
	$s_field[$i]=$sessID."field".$i;
	$s_word[$i]=$sessID."word".$i;
	$s_link[$i]=$sessID."link".$i;
	$_SESSION[$s_passed[$i]] =(isset($_SESSION[$s_passed[$i]]))?$_SESSION[$s_passed[$i]]:""; //sets variable
  $i++;
  }
$searchDetail=array();//building blocks for query



//Dropdown - choose annotation track
if(count($GENE)>1)
{
   $num="";
   $gene_dropdown="<form method=\"post\" name=\"select_track\" action=\"/XGDB/phplib/DisplayLoci.php?GDB=$X\">";
   $gene_dropdown.="<label class=\"normalfont\"><span class=\"highlight\">Select a different Gene Model Dataset (if any):</span> </label>";
   $gene_dropdown.="<select name=\"track\" size=\"1\"  onchange=\"formSubmit('select_track')\">";
   $gene_dropdown .= "<option value=\"\">- Gene Model Datasets -</option>\n\n";
  foreach ($GENE as $index=>$track)
   {
   $table_select=$track['locus_table'];
   $track_select=$track['track'];
   $color_select=$track['color'];
   $display_select=$track['display'];
   $display=($display_select==0)?0:1; //default on
   $num=$index;
   if($display !=0)
      {
      $gene_dropdown .= "<option style=\"color:white; background-color:$color_select\" value=\"$num\">$track_select</option>\n\n";
      }   
   }
   $gene_dropdown.="</select></form><br />";
}


// Paging: If a page limit is posted and the posted value does not equal the session value, then update the session variable
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
		$limit = intval($_SESSION[$s_limit]);
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
		$page = intval($_SESSION[$s_page]);
		$start = (($page * $limit) - ($limit - 0));	
	}
	$_SESSION[$s_page] = $page;


//MySQL query variables

	$recordPoint='getGSEG_Region.pl';
    $DBtable="gseg_".$table_core."_annotation";
    include_once('/xGDBvm/XGDB/phplib/db.inc.php');
	$idname='gseg_gi';
    $dbpass=dbpass();
    $link = mysql_pconnect("localhost", "gdbuser", $dbpass) or die(mysql_error());
    $dbh = mysql_select_db("$DBid", $link); //

	$l_posName='bac_lpos';
	$r_posName='bac_rpos';


//Core query components

	$searchCore ="select group_concat(distinct c.project_name) as project, group_concat(b.USERid) as users, a.locus_id, a.".$idname.", a.l_pos, a.r_pos, a.strand, a.transcript_ids, a.transcript_count, a.coverage, a.intron_count, a.integrity, a.description, a.genetic_locus, a.genetic_locus_desc, b.uid, group_concat(b.geneId) as annoIds, count(distinct b.geneId) as count,  b.proteinId, group_concat(b.GSeqEdits) as gseqedits, group_concat(b.annotation_class) as anno_class, min(b.status), if(group_concat(b.status) LIKE '%ACCEPTED%', 'ACCEPTED', if(group_concat(b.status) LIKE '%SUBMITTED%', 'PENDING','')) as status FROM $DBid.".$DBtable." as a LEFT JOIN $DBid.user_gene_annotation as b ON (a.locus_id=b.locusId AND b.dbName='$DBid') left join $DBid.gdb_projects as c on (c.locus_id=a.locus_id) WHERE 1";
	
	$orderBy=" order by a.".$idname.", a.l_pos";
	
	$groupBy=" group by a.locus_id";
	
 	$searchLimit = " limit $start, $limit";

//************ GET functions - generic search case and special cases ***********//

//GET function: search field and searchword (search1)
if(isset($_GET['field']) && isset($_GET['search']))
{
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
$gseg=mysql_real_escape_string($_GET['$idname']);
$l_pos=mysql_real_escape_string($_GET['l_pos']);
$r_pos=mysql_real_escape_string($_GET['r_pos']);
$rangeGet=$gseg.':'.$l_pos.'..'.$r_pos;
$gsegGet='scaff_from_to';

		$_SESSION[$s_passed[1]] = 1;
		$_SESSION[$s_field[1]] = $gsegGet; //Add search field to session
		$_SESSION[$s_word[1]] = $rangeGet; //add search query word to session
		$_SESSION[$s_link[1]] ='track='.$track_index.'&amp;$gsegGet=$rangeGet';
}

//GET function: id: (special case for search1; parse to remove any transcript identifier)
if(isset($_GET['id'])){
$id=mysql_real_escape_string($_GET['id']);
$locus_id=preg_replace('/(\S_FG)T([0-9]+)/', '${1}${2}', $id); //replace FGT FG etc
$locus_id=preg_replace('/_T[0-9]+/', '', $locus_id); //remove T001 etc
		$_SESSION[$s_passed[1]] = 1;
		$_SESSION[$s_field[1]] = 'locus_id'; //Add search field to session
		$_SESSION[$s_word[1]] = $locus_id; //add search query word to session

}


//GET function: project (search2)
if(isset($_GET['project'])){
$proj_name=mysql_real_escape_string($_GET['project']);
$proj_name_actual=preg_replace('/_/', ' ', $proj_name);
if($proj_name !='no_filter'){
		$_SESSION[$s_passed[2]] = 2;
		$_SESSION[$s_field[2]] = 'project_name'; //Add search field to session2
		$_SESSION[$s_word[2]] = $proj_name_actual; //add search query word to session2
		}else{
		$_SESSION[$s_field[2]] = $_SESSION[$s_passed[2]] = $_SESSION[$s_word[2]] = "";
	}
}

//GET function: status
if(isset($_GET['status'])){
$status=mysql_real_escape_string($_GET['status']);
if($status !='no_filter'){
		$_SESSION[$s_passed[3]] = 3;
		$_SESSION[$s_field[3]] = 'status'; //Add search field to session
		$_SESSION[$s_word[3]] = $status; //add search query word to session
		}else{
		$_SESSION[$s_field[3]] = $_SESSION[$s_passed[3]] = $_SESSION[$s_word[3]] = "";
	}
}

//GET function: integrity
if(isset($_GET['integrity'])){
$integrity=mysql_real_escape_string($_GET['integrity']);
if($integrity !='no_filter'){
		$_SESSION[$s_passed[4]] = 4;
		$_SESSION[$s_field[4]] = 'integrity'; //Add search field to session
		$_SESSION[$s_word[4]] = $integrity; //add search query word to session
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

$post_passed=isset($_POST['passed'])?$_POST['passed']:"";
if ($post_passed == 1 || $post_passed == 10) //If search initiated, build query based on posted values. [1 or 10: Under development to have 2 distinct search queries]
	{ 
		$p= ($_POST['passed'] == 1) ? 1 : 10;// 10 is under development
		$search='search'.$p;
		$searchWord = mysql_real_escape_string(str_replace("*", "", trim($_POST[$search]))); 
		$searchWord = str_replace(",", "", $searchWord); //get rid of commas
		$fieldWord = mysql_real_escape_string($_POST['field']);

		if($fieldWord == 'anything') { //generic search; use all tables; 
				 $searchWord_str = '\''.$searchWord.'\'';
				 $searchWord_wild = '\'%'.$searchWord.'%\'';
				 $searchDetail[$p] = " AND ((a.locus_id = $searchWord_str) OR (a.transcript_ids LIKE $searchWord_wild) OR (a.description LIKE  $searchWord_wild))";


		  }elseif ($fieldWord == 'scaff_from_to') { //parse chr and coords for search; use = comparator; specify table a for forWord; 
	  	 	 $range_pattern='/(\S+):\s*([0-9]+)[\.\-]+([0-9]+)$/'; //e.g.1:1000..2000 or 1:1000-2000
	  	 	 if(preg_match($range_pattern, $searchWord, $matches) == 1 ) {
				  $searchScaff = $matches[1];
				  $searchFrom = $matches[2];
				  $searchTo = $matches[3];
				} else { //show default
					  $searchScaff= 1;
					  $searchFrom=10000;
					  $searchTo=200000;
						}
				$_SESSION[$s_link[$p]] ='track='.$track_index.'&amp;chr='.$searchScaff.'&amp;l_pos='.$searchFrom.'&amp;r_pos='.$searchTo;
				$searchDetail[$p] = " AND a.".$idname."='$searchScaff' AND a.l_pos> $searchFrom AND a.r_pos< $searchTo";
		    }elseif ($fieldWord == 'introns_between') { //parse chr and coords for search; use = comparator; specify table a for forWord; 
	  	 	 $range_pattern='/([0-9]+)\s*\-*\s*([0-9]+){0,1}$/'; //e.g."1-3" or "6"
#works	  	 $range_pattern='/([0-9]+)\s*\-\s*([0-9]+)$/'; //e.g.1-3
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
				$searchDetail[$p] = " AND a.".$idname."=$searchWord";
			}elseif($fieldWord == 'distance_lte'){
				$_SESSION[$s_link[$p]] ='track='.$track_index.'&amp;field=distance_lte&amp;search='.$searchWord;
				 $table = 'd.';
				 $comparator = '<=';
				 $searchDetail[$p] = " AND ${table}distance $comparator $searchWord";
			}elseif($fieldWord == 'length_gte'){
				$_SESSION[$s_link[$p]] ='track='.$track_index.'&amp;field=length_gte&amp;search='.$searchWord;
				 $table = 'a.';
				 $comparator = '>=';
				 $searchDetail[$p] = " AND ((${table}r_pos - ${table}l_pos)/1000) $comparator $searchWord";
			}elseif($fieldWord == 'transcript_count_gte'){
				$_SESSION[$s_link[$p]] ='track='.$track_index.'&amp;field=transcript_count_gte&amp;search='.$searchWord;
				 $table = 'a.';
				 $comparator = '>=';
				 $searchDetail[$p] = " AND ${table}transcript_count $comparator $searchWord";				 
			}else{
		
		   	if ($fieldWord == 'geneId'|| $fieldWord == 'proteinId'|| $fieldWord == 'annotation_class' || $fieldWord == 'GSeqEdits') { //query for yrgate data; specify table b
				$_SESSION[$s_link[$p]] ='track='.$track_index.'&amp;field='.$fieldWord.'&amp;search='.$searchWord;
//				 $_SESSION[$s_searchword] = $searchWord;
				 $table = 'b.';
				 $comparator = 'LIKE';
				 $searchWord = '\'%'.$searchWord.'%\'';
 			}elseif($fieldWord == 'project_name') {  // query for project data; specify table c
				 $_SESSION[$s_link[$p]] ='track='.$track_index.'&amp;field='.$fieldWord.'&amp;search='.$searchWord;
 				 $table = 'c.';
 				 $comparator = 'LIKE';
 				 $searchWord = '\'%'.$searchWord.'%\'';
 				 $proj_name=preg_replace('/ /', '_', $fieldWord);//parse for URL
			}else { //default search type; specify table a
				 $_SESSION[$s_link[$p]] ='track='.$track_index.'&amp;field='.$fieldWord.'&amp;search='.$searchWord;
				 $table = 'a.';
				 $comparator = 'LIKE';
				 $searchWord = '\'%'.$searchWord.'%\'';
		  }
			$_SESSION[$s_passed[$p]] = $p;
			$searchDetail[$p] = " AND $table$fieldWord $comparator $searchWord";
			
	}
//store variables in session
	  if ($fieldWord == 'no filter'){//user wants to clear filter
	  	$searchDetail[$p] = "";
			$_SESSION[$s_passed[$p]] = '';
			$_SESSION[$s_field[$p]] = "";
			$_SESSION[$s_word[$p]] = "Enter search term/region-test";
			//$_SESSION[$s_searchword] = "Enter search term/region";

			}else{
			$_SESSION[$s_passed[$p]] = $p;
			$_SESSION[$s_field[$p]] = mysql_real_escape_string($_POST['field']);//Add search field to session
			$_SESSION[$s_word[$p]] = mysql_real_escape_string(str_replace("*", "", trim($_POST[$search])));//add search query word to session
			//$_SESSION[$s_searchword] = $_SESSION[$s_word[$p]];
		}
	}
	else if($_SESSION[$s_passed[1]]!="") //If session[1] exists, use those values
	{
		$p=1;//re-declare
		$fieldWord = $_SESSION[$s_field[$p]];
		$searchWord = $_SESSION[$s_word[$p]];
		if ($fieldWord == 'no filter'){ //user wants to clear search
	  	$searchDetail[$p] = '';
			$_SESSION[$s_field[$p]] = '';
			$_SESSION[$s_word[$p]] = '';
			$_SESSION[$s_link[$p]] = 'track='.$track_index;
			
		} elseif($fieldWord == 'anything') { //generic search; use all tables;
			 $_SESSION[$s_link[$p]] = 'track='.$track_index.'&amp;'.$fieldWord.'='.$searchWord;
				 $searchWord_str = '\''.$searchWord.'\'';
				 $searchWord_wild = '\'%'.$searchWord.'%\'';
				 $searchDetail[$p] = " AND ((a.locus_id = $searchWord_str) OR (a.transcript_ids LIKE $searchWord_wild) OR (a.description LIKE  $searchWord_wild))";
			
		} elseif($fieldWord == 'scaff_from_to') { //parse chr and coords for search; use = comparator; specify table a for forWord; 
		  $searchWord = str_replace(",", "", $searchWord); //get rid of commas
	  	  $range_pattern='/(\S+):\s*([0-9]+)[\.\-]+([0-9]+)$/'; //e.g.scaff_1:1000..2000 or 1:1000-2000
	  	  if(preg_match($range_pattern, $searchWord, $matches) == 1 ) {
		  	  $searchScaff = $matches[1];
		  	  $searchFrom = $matches[2];
		  	  $searchTo = $matches[3];
		  		} else { //show default
				  $searchScaff= 1;
				  $searchFrom=10000;
				  $searchTo=200000;
				}
			$_SESSION[$s_link[$p]] ='track='.$track_index.'&amp;chr='.$searchScaff.'&amp;l_pos='.$searchFrom.'&amp;r_pos='.$searchTo;
			$searchDetail[$p] = " AND a.".$idname."='$searchScaff' AND a.l_pos> $searchFrom AND a.r_pos< $searchTo";
		} elseif($fieldWord == 'introns_between') { //parse intron range for search; use = comparator; specify table a for forWord; 
	  	 	 $range_pattern='/([0-9]+)\s*\-*\s*([0-9]+){0,1}$/'; //e.g."1-3" or "6"
	  	 	 if(preg_match($range_pattern, $searchWord, $matches) == 1 ) {
				  $searchMin = $matches[1];
				  $searchMax = ($matches[2])? $matches[2] : $matches[1];
				} else { //show default
					  $searchMin=1;
					  $searchMax=3;
						}
				$_SESSION[$s_link[$p]] ='track='.$track_index.'&amp;intron_min='.$searchMin.'&amp; intron_max='.$searchMax;// for $_GET
				$searchDetail[$p] = " AND a.intron_count>= $searchMin AND a.intron_count<=$searchMax";
		} elseif($fieldWord == 'chr') {  // query for chr
			$_SESSION[$s_link[$p]] ='track='.$track_index.'&amp;field='.$fieldWord.'&amp;search='.$searchWord;
			$searchDetail[$p] = " AND a.".$idname."=$searchWord";
		}elseif($fieldWord == 'distance_lte'){
				 $table = 'd.';
				 $comparator = '<=';
				 $searchDetail[$p] = " AND ${table}distance $comparator $searchWord";			
		} elseif ($fieldWord == 'length_gte'){
			$_SESSION[$s_link[$p]] ='track='.$track_index.'&amp;field=length_gte&amp;search='.$searchWord;
	   		 $table = 'a.';
			 $comparator = '>=';
			 $searchDetail[$p] = " AND ((${table}r_pos - ${table}l_pos)/1000) $comparator $searchWord";
		}elseif($fieldWord == 'transcript_count_gte'){
			$_SESSION[$s_link[$p]] ='track='.$track_index.'&amp;transcript=length_gte&amp;search='.$searchWord;
				 $table = 'a.';
				 $comparator = '>=';
				 $searchDetail[$p] = " AND ${table}	transcript_count $comparator $searchWord";
		} else {
		
	   if ($fieldWord == 'geneId' || $fieldWord == 'proteinId') { //query for yrgate data; specify table b
			 $_SESSION[$s_link[$p]] ='track='.$track_index.'&amp;'.$fieldWord.'='.$searchWord;
			 $table = 'b.';
			 $comparator = 'LIKE';
			 $searchWord = '\'%'.$searchWord.'%\'';
			 $searchDetail[$p] = " AND ${table}${fieldWord}	 $comparator $searchWord";
		}elseif($fieldWord == 'project_name') {  // query for project data; specify table c
			 $proj_name=preg_replace('/ /', '_', $fieldWord);
			 $_SESSION[$s_link[$p]] ='track='.$track_index.'&amp;project='.$proj_name;
				$_SESSION[$s_link[$p]] ='track='.$track_index.'&amp;field='.$fieldWord.'&amp;search='.$searchWord;
  			 $table = 'c.';
 			 $comparator = 'LIKE';
			 $searchWord = '\'%'.$searchWord.'%\'';
		} else { //default search type; specify table a
			$_SESSION[$s_link[$p]] ='track='.$track_index.'&amp;field='.$fieldWord.'&amp;search='.$searchWord;
	   		 $table = 'a.';
			 $comparator = 'LIKE';
			 $searchWord = '\'%'.$searchWord.'%\'';
		  }
	$_SESSION[$s_passed[$p]] = $p;
	$searchDetail[$p] = " AND $table$fieldWord $comparator $searchWord"; //build searchdetail
	}
} else {
$searchDetail[1] = "";//if there is no search then just display the insertion page defaults
$_SESSION[$s_link[1]] ='track='.$track_index;
//$_SESSION[$s_searchword[1]] = "Enter search term/region-searchword";
//$_SESSION[$s_searchword] = "Enter search term/region";

}
//********2.project**********//

if (isset($_POST['passed']) && $_POST['passed'] == 2) //project search, write to session2
	{
		$p=2;
		$search='search'.$p;
		$fieldWord = 'project_name';
		$searchWord = mysql_real_escape_string(str_replace("*", "", trim($_POST[$search])));
		if ($searchWord == 'no filter'){//user wants to clear filter
	  			$searchDetail[$p] = "";
			$_SESSION[$s_passed[$p]] = '';
			$_SESSION[$s_field[$p]] = '';
			$_SESSION[$s_word[$p]] = '';
			$_SESSION[$s_link[$p]] ='track='.$track_index;
			}
		elseif($searchWord == 'no project') //special case - want loci not assoc. w/project
			{
			$searchDetail[$p]=" AND a.locus_id not in (select e.locus_id from $DBtable as e join gdb_projects as f on e.locus_id=f.locus_id)";
	  		$_SESSION[$s_passed[$p]] = $p;
			$_SESSION[$s_field[$p]] = 'project_name';//Add search field to session
			$_SESSION[$s_word[$p]] = 'no project';//add search query word to session
			$_SESSION[$s_link[$p]] ='track='.$track_index.'&amp;project=no_project';// for URL
	  	}else{
			$proj_name=preg_replace('/ /', '_', $searchWord);
			$_SESSION[$s_link[$p]] ='track='.$track_index.'&amp;project='.$proj_name;// for URL
			$table = 'c.';
			$comparator = '=';
			$searchWord = '\''.$searchWord.'\'';
			$searchDetail[$p] = " AND ${table}${fieldWord} $comparator $searchWord";
			$_SESSION[$s_passed[$p]] = $p;
			$_SESSION[$s_field[$p]] = 'project_name';//Add search field to session
			$_SESSION[$s_word[$p]] = mysql_real_escape_string(str_replace("*", "", trim($_POST[$search])));//add search query word to session
		}
	}
	else if($_SESSION[$s_passed[2]]!="") //If session[2] exists use those values
	{
		$p=2;
		$proj_name=preg_replace('/ /', '_', $_SESSION[$s_word[$p]]);
		$_SESSION[$s_link[$p]] ='track='.$track_index.'&amp;project='.$proj_name;
	if($_SESSION[$s_word[$p]] == 'no project')//special case - want loci not assoc. w/project
		{
			$searchDetail[$p]=" AND a.locus_id not in (select e.locus_id from $DBtable as e join gdb_projects as f on e.locus_id=f.locus_id)";
	}else{
		$fieldWord = 'project_name';
		$searchWord = $_SESSION[$s_word[$p]];
		$table = 'c.';
		$comparator = '=';
		$searchWord = '\''.$searchWord.'\'';
		$searchDetail[$p] = " AND ${table}${fieldWord} $comparator $searchWord";
		}
	}
//********3.status*********//

if (isset($_POST['passed']) && $_POST['passed'] == 3) //status search, write to session3:
	{
		$p=3;
		$search='search'.$p;
		$fieldWord = 'status';
		$searchWord = mysql_real_escape_string(str_replace("*", "", trim($_POST[$search])));
		if ($searchWord == 'no filter'){//user wants to clear filter
	  		$searchDetail[$p] = "";
			$_SESSION[$s_passed[$p]] = '';
			$_SESSION[$s_field[$p]] = '';
			$_SESSION[$s_word[$p]] = '';
			$_SESSION[$s_link[$p]] ='track='.$track_index;			 
	  	}else{
		$_SESSION[$s_link[$p]] ='track='.$track_index.'&amp;status='.$searchWord;
	  	$table = 'b.';
		$comparator = 'LIKE';
		
				if($searchWord == "accepted"){
					$searchDetail[$p] = " HAVING group_concat(${table}${fieldWord}) $comparator '%ACCEPTED%'";
				}elseif($searchWord == "pending"){
				    $searchDetail[$p] = " HAVING group_concat(${table}${fieldWord}) $comparator '%SUBMITTED%'";
				}elseif($searchWord == "all"){
					$searchDetail[$p] = " HAVING (group_concat(${table}${fieldWord}) $comparator '%ACCEPTED%' OR group_concat(${table}${fieldWord}) $comparator '%SUBMITTED%')";
				}elseif($searchWord == "none"){
					$searchDetail[$p] = "";
					$searchDetail[6] = "AND b.status IS NULL";
			}
		$_SESSION[$s_passed[$p]] = $p;
		$_SESSION[$s_field[$p]] = 'status';//Add search field to session
		$_SESSION[$s_word[$p]] = mysql_real_escape_string(str_replace("*", "", trim($_POST[$search])));//add search query word to session
		}
	}
	else if($_SESSION[$s_passed[3]]!="") //If session[3] exists use those values
	{
		$p=3;
		$fieldWord = 'status';
		$searchWord = $_SESSION[$s_word[$p]];
		$_SESSION[$s_link[$p]] ='track='.$track_index.'&amp;'.$fieldWord.'='.$searchWord;
		$table = 'b.';
		$comparator = 'LIKE';

				if($searchWord == "accepted"){
							 $searchDetail[$p] = " HAVING group_concat(${table}${fieldWord}) $comparator '%ACCEPTED%'";
				}elseif($searchWord == "pending"){
							 $searchDetail[$p] = " HAVING group_concat(${table}${fieldWord}) $comparator '%SUBMITTED%'";
				}elseif($searchWord == "all"){
							 $searchDetail[$p] = " HAVING (group_concat(${table}${fieldWord}) $comparator '%ACCEPTED%' OR group_concat(${table}${fieldWord}) $comparator '%SUBMITTED%')";
				}elseif($searchWord == "none"){
					$searchDetail[$p] = "";
					$searchDetail[6] = "AND b.status IS NULL";
			}

	}

//********4.integrity*********//

if (isset($_POST['passed']) && $_POST['passed'] == 4) //integrity search, write to session4:
	{
		$p=4;
		$search='search'.$p;
		$fieldWord = 'integrity';
		$searchWord = mysql_real_escape_string(str_replace("*", "", trim($_POST[$search])));
		if ($searchWord == 'no filter'){//user wants to clear filter
	  		$searchDetail[$p] = "";
			$_SESSION[$s_passed[$p]] = '';
			$_SESSION[$s_field[$p]] = '';
			$_SESSION[$s_word[$p]] = '';
			$_SESSION[$s_link[$p]] ='track='.$track_index;			 
	  	}else{
	  	$table = 'a.';
		$_SESSION[$s_link[$p]] ='track='.$track_index.'&amp;integrity='.$searchWord;//we want to store the lt or gt before parsing
		$greater='/gt(\.[0-9]{2})/';//e.g. gt.75
		$lesser='/lt(\.[0-9]{2})/';//e.g. lt.75
 		if(preg_match($greater, $searchWord, $match)) 
 		{
 			$comparator= '>';
 			$searchWord = $match[1];
   		}elseif(preg_match($lesser, $searchWord, $match))
   		{
  			$comparator = '<';
  			$searchWord = $match[1];
  		}
  		else
  		{
  		    $comparator = "";
  		    $searchWord = "";
  		}
		$_SESSION[$s_passed[$p]] = $p;
		$_SESSION[$s_field[$p]] = 'integrity';//Add search field to session
		$_SESSION[$s_word[$p]] = mysql_real_escape_string(str_replace("*", "", trim($_POST[$search])));//add search query word to session
		$searchDetail[$p] = " AND $table$fieldWord $comparator $searchWord";

		}
	}
	else if($_SESSION[$s_passed[4]]!="") //If session[4] exists use those values
	{
		$p=4;
		$fieldWord = 'integrity';
		$searchWord = $_SESSION[$s_word[$p]];
  		$_SESSION[$s_link[$p]] ='track='.$track_index.'&amp;integrity='.$searchWord;
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
	}
//********5.coverage********//

if (isset($_POST['passed']) && $_POST['passed'] == 5) //coverage search, write to session5:
	{
		$p=5;
		$search='search'.$p;
		$fieldWord = 'coverage';
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
		$equal='/eq([0-9]{1})/';//e.g. eq0 or eq1
 		if(preg_match($greater, $searchWord, $match))
 		{
 			$comparator= '>';
 			$searchWord = $match[1];
   		}
   		elseif(preg_match($lesser, $searchWord, $match))
   		{
  			$comparator = '<';
  			$searchWord = $match[1];
  		}
   		elseif(preg_match($equal, $searchWord, $match))
   		{
  			$comparator = '=';
  			$searchWord = $match[1];
  		}
  		else
  		{
  		$comparator="";
  		$searchWord="";
  		}
  		
		$_SESSION[$s_passed[$p]] = $p;
		$_SESSION[$s_field[$p]] = 'coverage';//Add search field to session
		$_SESSION[$s_word[$p]] = mysql_real_escape_string(str_replace("*", "", trim($_POST[$search])));//add search query word to session
		$searchDetail[$p] = " AND $table$fieldWord $comparator $searchWord";

		}
	}
	else if($_SESSION[$s_passed[5]]!="") //If session[5] exists use those values
	{
		$p=5;
		$fieldWord = 'coverage';
		$searchWord = $_SESSION[$s_word[$p]];
  		$_SESSION[$s_link[$p]] ='track='.$track_index.'&amp;coverage='.$searchWord;
		$table = 'a.';
		$greater='/gt(\.[0-9]{2})/';//e.g. gt.75
		$lesser='/lt(\.[0-9]{2})/';//e.g. lt.75
		$equal='/eq([0-9]{1})/';//e.g. eq0 or eq1
 		if(preg_match($greater, $searchWord, $match))
 		{
 			$comparator= '>';
 			$searchWord = $match[1];
   		}
   		elseif(preg_match($lesser, $searchWord, $match))
   		{
  			$comparator = '<';
  			$searchWord = $match[1];
   		}
   		elseif(preg_match($equal, $searchWord, $match))
   		{
  			$comparator = '=';
  			$searchWord = $match[1];
  		}
  		else
  		{
  		    $comparator="";
  		    $searchWord="";
  		}
	    $searchDetail[$p] = " AND $table$fieldWord $comparator $searchWord";
	}
//Build query and store query in session:

$searchDetail_1=isset($searchDetail[1])?$searchDetail[1]:"";
$searchDetail_2=isset($searchDetail[2])?$searchDetail[2]:"";
$searchDetail_3=isset($searchDetail[3])?$searchDetail[3]:"";
$searchDetail_4=isset($searchDetail[4])?$searchDetail[4]:"";
$searchDetail_5=isset($searchDetail[5])?$searchDetail[5]:"";
$searchDetail_6=isset($searchDetail[6])?$searchDetail[6]:"";

$searchQuery = $searchCore.$searchDetail_1.$searchDetail_2.$searchDetail_4.$searchDetail_5.$searchDetail_6.$groupBy.$searchDetail_3.$orderBy.$searchLimit;
$searchTotal = $searchCore.$searchDetail_1.$searchDetail_2.$searchDetail_4.$searchDetail_5.$searchDetail_6.$groupBy.$searchDetail_3.$orderBy;
$_SESSION[$s_query] = $searchTotal;//used in csv_DisplayLoci.php!! For this reason, the searchTotal query needs to be IDENTICAL to the searchQuery except for the limits.

//get query results:
$get_loci = $searchQuery;


if($check_get_loci = mysql_query($get_loci)){ //only display if data exists.
	$display_message="";
	$get_total = $searchTotal; //MySQL
	$check_get_total = mysql_query($get_total);
	$entries = mysql_num_rows($check_get_total);
	$pages = ceil($entries/$limit);
	while ($pages > 0) {
		$page_number = ($pages - ($page - 1));
		/* page number = (32 - (32 - 1)) = 1 */
		if ($_SESSION[$s_page] == $pages) {
			$display_pages .= "<option value=\"$pages\" selected=\"selected\">$pages</option>";
		} else {
			$display_pages .= "<option value=\"$pages\">$pages</option>";
		}
		$pages = $pages - 1;
	}
	
	//assign column class (selected or '') according to active filters (for column highlighting):
	$loc = (isset($_SESSION[$s_field[1]]) && $_SESSION[$s_field[1]] =='locus_id') ? "selected" : "not_selected";
	$gsegment = (isset($_SESSION[$s_field[1]]) && $_SESSION[$s_field[1]] =='gseg_gi') ? "selected" : "not_selected";
	$reg = (isset($_SESSION[$s_field[1]]) && $_SESSION[$s_field[1]] =='scaff_from_to') ? "selected" : "not_selected";
	$tran = (isset($_SESSION[$s_field[1]]) && $_SESSION[$s_field[1]] =='transcript_count_gte') ? "selected" : "not_selected";
	$len = (isset($_SESSION[$s_field[1]]) && $_SESSION[$s_field[1]] =='length_gte') ? "selected" : "not_selected";
	$int = (isset($_SESSION[$s_field[1]]) && $_SESSION[$s_field[1]] =='introns_between') ? "selected" : "not_selected";
	$desc = (isset($_SESSION[$s_field[1]]) && $_SESSION[$s_field[1]] =='description') ? "selected" : "not_selected";
	$prot = (isset($_SESSION[$s_field[1]]) && $_SESSION[$s_field[1]] =='proteinId') ? "selected" : "not_selected";
	$genloc = (isset($_SESSION[$s_field[1]]) && $_SESSION[$s_field[1]] =='genetic_locus' || (isset($_SESSION[$s_field[1]]) && $_SESSION[$s_field[1]] =='genetic_locus_desc')) ? "selected" : "not_selected";
	$integ = (isset($_SESSION[$s_field[1]]) && $_SESSION[$s_field[1]] =='max_integrity') ? "selected" : "not_selected";
	$proj2 = (isset($_SESSION[$s_field[1]]) && $_SESSION[$s_field[1]] =='project_name') ? "selected" : "not_selected";
	$dist = (isset($_SESSION[$s_field[1]]) && $_SESSION[$s_field[1]] =='distance_lte') ? "selected" : "not_selected";
	$proj = (isset($_SESSION[$s_field[2]]) && $_SESSION[$s_field[2]] =='project_name') ? "selected" : "not_selected";
	$stat = (isset($_SESSION[$s_field[3]]) && $_SESSION[$s_field[3]] =='status') ? "selected" : "not_selected";
	$integ = (isset($_SESSION[$s_field[4]]) && $_SESSION[$s_field[4]] =='integrity' ) ? "selected" : "not_selected";
	$cov = (isset($_SESSION[$s_field[5]]) && $_SESSION[$s_field[5]] =='coverage') ? "selected" : "not_selected";
	$cov2 = (isset($_SESSION[$s_field[1]]) && $_SESSION[$s_field[1]] =='coverage') ? "selected" : "not_selected";
	$integ2 = (isset($_SESSION[$s_field[1]]) && $_SESSION[$s_field[1]] =='integrity' ) ? "selected" : "not_selected";
	
	$display_block = "<table id=\"locus_table\" class=\"row_middle featuretable highlight\" width=\"100%\">
	<col class=\"$loc\" width=\"8%\" />
	<col width=\"3%\" />
	<col class=\"$tran\" width=\"3%\" />
	<col class=\"$gsegment $reg\" width=\"5%\" />
	<col class=\"$reg\" width=\"5%\" />
	<col class=\"$len\" width=\"3%\" />
	<col class=\"$int\" width=\"3%\" />
	<col width=\"3%\" />
	<col class=\"$desc\" width=\"20%\" />
	<col class=\"$proj $proj2\" width=\"5%\" />
	<col class=\"$cov $cov2\" width=\"3%\" />
	<col class=\"$integ $integ2\" width=\"3%\" />
	<col width=\"3%\" />
	<col width=\"3%\" />
	<col class=\"$prot\" width=\"3%\" />
	<col class=\"$stat\" width=\"3%\" />
	<col width=\"3%\" />
	<thead>
	<tr>
	<th colspan=\"9\" align=\"center\" class=\"th1 whitefont\">
	Gene Models <span class=\"italic grayfont\"> - grouped by locus -</span>
	</th>
	<th rowspan=\"2\" class=\"$proj $proj2 th2\"  title=\"yrGATE Project Name\" align=\"center\">Project</th>
	<th align=\"center\" colspan=\"2\" class=\"th3 whitefont\">
	GAEVAL
	</th>
	<th colspan=\"5\" align=\"center\" class=\"th4 whitefont\">
	yrGATE Annotations
	</th>
	</tr>
	<tr>
	<th class=\"$loc th1\" title=\"Locus ID (click to sort)\" align=\"center\">Locus ID <br /><span class=\"heading\"></span></th>
	<th class=\"th1 whitefont\" title=\"View at genome database\" align=\"center\">Gen<br />ome<br />view</th>
	<th class=\"$tran th1\" title=\"number of transcripts at this locus (click to sort)\" align=\"center\">#<br />Tran-<br />scripts <br /><span class=\"grayfont smallerfont\"> (click to view)</span></th>
	<th class=\"$gsegment $reg th1\" title=\"scaffold or chromosome (click to sort)\" align=\"center\">Scaffold ID</th>
	<th class=\"$reg th1\" title=\"left coordinate\" align=\"center\">Region</th>
	<th class=\"$len th1\" title=\"length of gene\" align=\"center\">Span<br />(kb)</th>
	<th class=\"$int th1\" title=\"maximum intron count\" align=\"center\">Max<br />Intron<br />Count</th>
	<th class=\"th1 whitefont\" title=\"strand of gene\" align=\"center\">Str</th>
	<th class=\"$desc th1\" title=\"Description\" align=\"center\">Description(s) <br /> <span class=\"grayfont smallerfont\"> (hover for complete descriptions)</span></th>
	<th class=\"th3 $cov $cov2\"  title=\"Average fractional coverage of models at this locus by transcript alignments\" align=\"center\">Cov<br />er<br />age<br /><img style=\"margin-top:0.5em\" id=\"tracks_loci_coverage\" title=\"Click for explanation\" src=\"/XGDB/images/help-icon.png\" alt=\"?\" class=\"xgdb-help-button\" /></th>
	<th class=\"$integ $integ2 th3\"  title=\"Average Integrity of models at this locus vs. transcript alignments\" align=\"center\">Inte<br />gri<br />ty<br /><img style=\"margin-top:0.5em\" id=\"tracks_loci_integrity\" title=\"Click for explanation\" src=\"/XGDB/images/help-icon.png\" alt=\"?\" class=\"xgdb-help-button\" /></th>
	<th class=\"th4 whitefont\" title=\"Number of yrGATE annotations (grey if not curated)\" align=\"center\">yrGATE<br />Anno<br />Count</th>
	<th class=\"th4 whitefont\" title=\"yrGATE annotation class(es) (hover to view details)\" align=\"center\">yrGATE<br />Anno<br />Class<br /><img style=\"margin-top:0.5em\" id=\"loci_yrgate_annoclass\" title=\"Click for explanation\" src=\"/XGDB/images/help-icon.png\" alt=\"?\" class=\"xgdb-help-button\" /></th>
	<th class=\"$prot th4\"  title=\"yrGATE Putative Gene Product\" align=\"center\">yrGATE Gene Product</th>
	<th class=\"$stat th4\"  title=\"$annoId (click to view)\" align=\"center\">Anno<br /> Status<span class=\"grayfont smallerfont\"><br />(click to view)</span></th>
	<th class=\"th4 whitefont\" title=\"Annotate this locus using yrGATE tool (login required)\" align=\"center\">Annotate it!</th>
	</tr></thead><tbody>
	";
	
	while ($data_array = mysql_fetch_array($check_get_loci)) 
	{
	
	//pull data from DB to correspond with headers
		$locus_id = $data_array['locus_id'];
		$gseg = $data_array[$idname];
		$l_pos = $data_array['l_pos'];
		$l_pos_pad = ($l_pos - 1000 > 0) ? $l_pos -1000 : 1;
		$r_pos = $data_array['r_pos'];
		$r_pos_pad = $r_pos +1000;
		$introns=$data_array['intron_count'];
		$strand = $data_array['strand'];
		$transcript_ids = $data_array['transcript_ids'];
		$transcript_count = $data_array['transcript_count'];
		$annoIds = $data_array['annoIds'];
		$description = $data_array['description'];
		$description_trim = str_replace("<", "", (str_replace(">", "", $description)));
		$cutoff=300;
		$description_display=substr($description_trim, 0, $cutoff);
		$description_display.=(strlen($description)>$cutoff)?"...":"";
		$description_hover=(strlen($description)>$cutoff)?$description:"";
		$genetic_locus = $data_array['genetic_locus'];
		$genetic_locus_desc = $data_array['genetic_locus_desc'];
		$coverage = $data_array['coverage'];//GAEVAL
		$integrity = $data_array['integrity'];//GAEVAL
		if($coverage<=.75 && $coverage >.5) {
			$cov_color="#B100BF";
			}elseif($coverage<=.50)
			{	
			$cov_color="red";
			}else
			{
			$cov_color="";
			}
		if($integrity<=.75 && $integrity >.5 && $coverage >= $integrity) {
			$int_color="#B100BF";
			}elseif($integrity<=.50 && $coverage >= $integrity)
			{	
			$int_color="red";
			}else
			{
			$int_color="";
			}
	
		$project = $data_array['project'];
		$users = $data_array['users'];
		$uid = $data_array['uid'];
		$count = $data_array['count'];
		$proteinId = $data_array['proteinId'];
		$edits = $data_array['gseqedits'];
		$anno_class = $data_array['anno_class']; //used for icon
		$status = $data_array['status'];
		//match locus_id type and parse new form for search using search.pl:
		$len = round(($r_pos-$l_pos)/1000, 1);
		
		if($count > 0){ //don't display zeroes.
			$count_display=$count;
		} else {
			$count_display="";
		}
		if($status){ //Decide whether and how to display yrGATE data columns (count, proteinId, ygate_display), depending on status as defined in the initial mysql query logic. 
		if($status == "ACCEPTED"){
			$status_class="accepted";
			$yrgate_display="<span  class=\"commcent\"><a title=\"Annotations at this locus: $annoIds (click to view)\" target=\"_blank\" href=\"/yrGATE/${DBid}/CommunityCentral.pl?search_field=locus&amp;search_term=$locus_id&amp;db_ver=0\"></a></span>";
		} elseif($status == "PENDING") {
			$status_class="not_accepted";
			$yrgate_display="<span class='not_accepted smallerfont'>pending</span>";
		}
		} else{ //no status. Don't display any yrGATE data at this locus.
		$yrgate_status="";
		$yrgate_display="";
		$count_display="";
		$proteinId="";
		}
		
		
	$imgs = assign_icon_class($anno_class, $status, $edits);//build yrGATE status icons depending on status; see DisplayLoci_functions.inc.php
	
#	$this_user= $cpHR->{USERid}; not the way to get user; find something else
#	$imgs .= check_user($users, $this_user);//add user icon if owned
	$transcripts_parsed=str_replace(",", " |||", $transcript_ids); // parsing for search.php batch
	$transcripts_link="/${DBid}/cgi-bin/search.pl?idSUB=Search&amp;BatchText=${transcripts_parsed}&amp;SeqOnly=OFF&amp;track1=ON&amp;track2=ON&amp;track3=ON&amp;track4=ON&amp;track5=ON&amp;track6=ON&amp;track7=ON&amp;overlapSEQ=OFF";
	$transcripts_display="<a href=\"$transcripts_link\" style=\"cursor:pointer\" title=\"Transcript(s) at this locus: $transcript_ids\">&nbsp;&nbsp;${transcript_count}&nbsp;&nbsp;</a>";
		
		$display_block .= "<tr>";
		$display_block .= "
		<td class=\"bold\" align=\"center\">$locus_id</td>
		<td>
		    <span  class=\"gdblink xgdb\">
		        <a title=\"View at $DBid (opens a new web browser page/tab)\" target=\"_blank\" href=\"/${DBid}/cgi-bin/${recordPoint}?dbid=0&amp;$idname=$gseg&amp;$l_posName=$l_pos_pad&amp;$r_posName=$r_pos_pad\">
		        </a>
		    </span>
		</td>
		<td align=\"center\">
		    $transcripts_display
		</td>
		<td align=\"center\">
		    $gseg
		</td>
		<td align=\"center\">
		    $l_pos<br />$r_pos
		</td>
		<td align=\"center\">
		    $len
		</td>
		<td align=\"center\">$introns</td>
		<td align=\"center\">$strand</td>
		<td title=\" $description_hover\" class=\"smallerfont\" align=\"left\" style=\"cursor:pointer\">$description_display</td>
		<td title=\"Structural Annotation Project\" align=\"center\">$project</td>
		<td style=\"color:$cov_color\" align=\"center\">$coverage</td>
		<td style=\"color:$int_color\" align=\"center\">$integrity</td>
		<td title=\"Number of  yrGATE Annotations (grey if anno not curated)\" align=\"center\" class=\"$status_class\">$count_display</td>
		<td align=\"center\">$imgs</td>
		<td title=\"Putative Protein Product (grey if anno not curated)\" class=\"$status_class\" align=\"center\">$proteinId</td>
		<td align=\"center\" title=\"Annotations at this locus (click to view)\">$yrgate_display</td>
		<td align=\"center\" title=\"Click to annotate using yrGATE\"><span class=\"gdblink annot\"><a style=\"cursor:pointer\" onclick = \"doAnnotation_generic('1','chr','$gseg','$l_pos_pad', '$r_pos_pad')\" title = \"Open yrGATE tool for gene structure annotation\"></a></span></td>
		</tr>";
	
	
	}
	//setup drop down for entries per page based on current limit
	
	$display_block .= "</tbody></table>";
} //end if

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

$part_a="<a id=\"selfReference\" title=\"right click to copy this link\" href=\"/XGDB/phplib/DisplayLoci.php?GDB=$X";

	$n=5;//number of queries.
	$i=1;
	$part_b = '';
	$part_c = '';
	while($i<=$n){
		if(isset($_SESSION[$s_link[$i]])){
		$part_b='?';
		$part_c .= isset($_SESSION[$s_link[$i]])?$_SESSION[$s_link[$i]]:"";
		}
		if(isset($_SESSION[$s_link[$i]])){
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
<div id="maincontents" class="<?php echo $display; ?>">

	<table width="1000px">
		<col width="35%" /><col width="60%" /><col width="5%" />
		<tr>
		<td colspan="3">
		<h1 class="bottommargin1 nowrap">
	<?php echo "Gene Models: <span class=\"largerfont\" style=\"border: 3px solid $selected_color; color: white; background-color: $selected_color\">&nbsp; $selected_track &nbsp;</span> "; ?> &nbsp; &nbsp; <img id="tracks_loci" title="Click for Gene Prediction Table Help" style="margin-bottom:-1px" src="/XGDB/images/help-icon.png" alt="?" class="xgdb-help-button" /><span class="heading"> Displayed by locus, in serial order on the genome.</span>
        </h1>
        <!--?php $session_query=$_SESSION[$s_query]; echo $session_query ?-->
        <?php if($index>0){echo $gene_dropdown;} //don't display if only one dataset ?>
        <?php //echo $searchTotal ?>
		</td>
		</tr>
		<tr>
		<td align="left" style="padding-bottom:1.5em">
						<?php 	$n=5;//number of queries.
								$i=1;
								$filter=false;
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
							Filter is on; retrieved <b>$entries</b> $records | <a href=\"/XGDB/phplib/Display_clear_filters.php?table=${table_core}&dbid=${DBid}&n=${n}&index=${track_index}&redirect=Loci\">Clear&nbsp;All&nbsp;Filters</a> |</span>
							";
							}else{
							echo "
								<span class=\"normalfont\" >No filters | <b>$entries</b> records </span>
							"; 
							}
						?>
					</td>

			<td align="right" style="padding-bottom:1.5em">
						<span class="normalfont" style="margin-right: 1em"><a href="/XGDB/phplib/csv_DisplayLoci.php?track=<?php echo $track_index; ?>&amp;GDB=<?php echo $X; ?>">Download&nbsp;.csv</a></span>
					</td>
		</tr>
	</table>
		<table id="header_functions" width="950px" border="0">
				<col width="35%" /><col width="45%" /><col width="8%" /><col width="5%" /><col width="5%" /><col width="5%" />
				<tr valign="top">
					<td align="left">
						<fieldset class="header_functions">
						<h2>Search:<span class="heading"> Enter category, term, click "Go".</span> </h2>
							<form method="post" action="/XGDB/phplib/DisplayLoci.php?GDB=<?php echo $X; ?>">
							<table style="margin:10px 5px 30px 0; width: 100%;">
								<tr>
									<td width="100%" align = "right">
										<span   class="<?php active_search(1, isset($_SESSION[$s_passed[1]])?$_SESSION[$s_passed[1]]:""); ?> bold">Category&nbsp;<img id="tracks_loci_search" title="Click for explanation" src="/XGDB/images/help-icon.png" alt="?" class="xgdb-help-button" /></span>
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
											//alert('hi we go there');
											var objForm = document.forms[name]
											//alert(name);
											objForm.submit();
										}
										/* ]]> */
										</script>
					
					<h2>Filters:<span class="heading"> Multiple search filters are boolean ("AND")</span> </h2>
						<form method="post" name="project" action="/XGDB/phplib/DisplayLoci.php?GDB=<?php echo $X; ?>">
							<table style="margin:10px 0 0 0; width: 100%;">
								<tr align="center">
									<td width="40%" align = "right">
										<input type="hidden" name="field2" value="project_name" />
								   		<span class="<?php active_search(2, isset($_SESSION[$s_passed[2]])?$_SESSION[$s_passed[2]]:""); ?> bold">Project:&nbsp;<img id="tracks_loci_projects" title="Click for explanation" src="/XGDB/images/help-icon.png" alt="?" class="xgdb-help-button" /></span>
								   		</td>
								   		<td width="60%" align = "left">
											<select class="<?php active_search(2, isset($_SESSION[$s_passed[2]])?$_SESSION[$s_passed[2]]:""); ?>" onchange="formSubmit('project');" name="search2">
										<?php project_dropdown(isset($_SESSION[$s_word[2]])?$_SESSION[$s_word[2]]:"", $DBid, $table_core); ?>	
												</select>
										<input type="hidden" name="passed" value="2" />
										<input type="hidden" name="track" value="<?php echo $track_index; ?>" />
										<span class="smallerfont"><br /><a href="/XGDB/phplib/DisplayProjects.php?source=<?php echo $track_index; ?>&amp;GDB=<?php echo $X; ?>">[view project information page]</a></span>
									</td>
								</tr>
						</table>
						</form>

						
											<form method="post" name="coverage" action="/XGDB/phplib/DisplayLoci.php?GDB=<?php echo $X; ?>">
						<table style="margin:10px 0 0 0 ; width: 100%;">
							<tr align="center">
								<td width="40%" align = "right">
								<input type="hidden" name="field5" value="coverage" />
							   		<span class="<?php active_search(5, isset($_SESSION[$s_passed[5]])?$_SESSION[$s_passed[5]]:""); ?> bold">Coverage Score:&nbsp;<img id="tracks_loci_coverage_score" title="Click for explanation" src="/XGDB/images/help-icon.png" alt="?" class="xgdb-help-button" /></span>
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
						
						<form method="post" name="integrity" action="/XGDB/phplib/DisplayLoci.php?GDB=<?php echo $X; ?>">
						<table style="margin:0 ; width: 100%;">
							<tr align="center">
								<td width="40%" align = "right">
								<input type="hidden" name="field4" value="integrity" />
							   		<span class="<?php active_search(4, isset($_SESSION[$s_passed[4]])?$_SESSION[$s_passed[4]]:""); ?> bold">Integrity Score:&nbsp;<img id="tracks_loci_integrity_score" title="Click for explanation" src="/XGDB/images/help-icon.png" alt="?" class="xgdb-help-button" /></span>
							   		</td>
							   		<td width="60%" align = "left">
										<select class="<?php active_search(4, isset($_SESSION[$s_passed[4]])?$_SESSION[$s_passed[4]]:""); ?>" onchange="formSubmit('integrity');" name="search4">
										<?php integrity_dropdown(isset($_SESSION[$s_word[4]])?$_SESSION[$s_word[4]]:""); ?>	
										</select>
										<!-- <input type="submit"  value="Go" /> -->
										<input type="hidden" name="passed" value="4" />
										<input type="hidden" name="track" value="<?php echo $track_index; ?>" />
									</td>
								</tr>
							</table>
						</form>
						<form method="post" name="yrgate" action="/XGDB/phplib/DisplayLoci.php?GDB=<?php echo $X; ?>">
						<table style="margin: 0; width: 100%;">
							<tr align="center">
								<td width="40%" align = "right">
								<input type="hidden" name="field3" value="status" />
							   		<span class="<?php active_search(3, isset($_SESSION[$s_passed[3]])?$_SESSION[$s_passed[3]]:""); ?> bold">yrGATE Status:&nbsp;<img id="tracks_loci_yrgate_status" title="Click for explanation" src="/XGDB/images/help-icon.png" alt="?" class="xgdb-help-button" /></span>
							   		</td>
							   		<td width="60%" align = "left">
										<select class="<?php active_search(3, isset($_SESSION[$s_passed[3]])?$_SESSION[$s_passed[3]]:""); ?>" onchange="formSubmit('yrgate');" name="search3">
										<?php status_dropdown(isset($_SESSION[$s_word[3]])?$_SESSION[$s_word[3]]:""); ?>	
										</select>
										<!-- <input type="submit"  value="Go" /> -->
										<input type="hidden" name="passed" value="3" />
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
											<form method="post" action="/XGDB/phplib/DisplayLoci.php?GDB=<?php echo $X; ?>">
												
												<?php
												echo $display_select;
												?>
												
												<input type="submit" value="Submit" name="submit" />
										
											</form>		
										</td>
										<td align="right">
										<br />
											<form method="post" action="/XGDB/phplib/DisplayLoci.php?source=GDB=<?php echo $X; ?>">
												<input type="hidden" name="page" value="<?php echo isset($_SESSION[$s_page])?$_SESSION[$s_page]-1:1; ?>" />
												<input type="submit" class="largerfont bold" value="&lt;" name="submit" />
											</form>
										</td>
										<td align="center">
											<form method="post" action="/XGDB/phplib/DisplayLoci.php?GDB=<?php echo $X; ?>">
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
											<form method="post" action="/XGDB/phplib/DisplayLoci.php?GDB=<?php echo $X; ?>">
												<input type="hidden" name="page" value="<?php echo isset($_SESSION[$s_page])?$_SESSION[$s_page]+1:1; ?>" />
												<input type="submit" class="largerfont bold" value="&gt;" name="submit" accesskey="n" />
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
					

					<span  class="bottommargin1"><?php echo $display_link ?></span>
					</td>
					<td  colspan="2" align="right" style="margin-right:1em">
					</td>
					</tr>
		</table>
<?php echo $display_message; ?>			
<?php echo $display_block; ?>

	</div><!--mainWLS2-->
						  <div style="clear:both; float:right">
							<a href="http://validator.w3.org/check?uri=referer"><img
							  src="http://www.w3.org/Icons/valid-xhtml10" alt="Valid XHTML 1.0 Transitional" height="15" width="44" /></a>
						  </div>						
		</div>
</div>
<?php include("/xGDBvm/XGDB/phplib/footer.php"); ?>
</div>
</body>
</html>
