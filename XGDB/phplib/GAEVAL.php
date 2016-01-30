<?php
error_reporting(E_ALL & ~E_NOTICE); //disable undeclared variable error - there are a mess of them! :-(
if (preg_match('/(GDB\d\d\d)/', $_SERVER['HTTP_REFERER'], $matches))
	$X = $matches[1];
if ($_GET['GDB'])
	$X = $_GET['GDB'];
require('/xGDBvm/XGDB/phplib/sitedef.php'); // For list of available GDBs
require('/xGDBvm/data/' . $X .'/conf/GAEVALconf.php'); 

if(empty($SITEDEF_H)) { require('/xGDBvm/data/' . $X . '/conf/SITEDEF.php'); }

# moved from further down below.
if(empty($PARAM_H)){require('/xGDBvm/XGDB/phplib/getPARAM.php');}
require('/xGDBvm/XGDB/phplib/SSI_GDBprep.php');
virtual("${CGIPATH}SSI_GDBgui.pl/TWO_COLUMN_HEADER/" . $SSI_QUERYSTRING);
?>

		<link rel='stylesheet' type='text/css' href='/XGDB/css/GAEVAL.css' />
		<script type="text/javascript" src="<?php echo $JSPATH; ?>GAEVALquery.js"></script>

		<div id="mainWLS">
		<div id="maincontents">

		<h1 class="bottommargin1">GAEVAL analysis of <?php echo $X; ?> transcript annotations  <img id='gaeval_table' title='Search Help' class='xgdb-help-button' src='/XGDB/images/help-icon.png' alt='?' /></h1>

		
<?php 

global $cp_col_order, $cp_sort_ort, $cp_resultCols, $cp_ANNsrc, $PRIMARY_SQL, $cp_resultCols, $cp_ISgroup, $cp_SCSgroup, $cp_BS5group, $cp_BS5op, $cp_BS5val, $cp_BS5group, $cp_BS3group, $cp_BS3op, $cp_BS3val;
global $cp_APIgroup, $cp_APIop, $cp_APIval, $cp_AP5op, $cp_AP5group, $cp_AP5val, $cp_APCgroup, $cp_APCop, $cp_APCval, $cp_AP3group, $cp_AP3op, $cp_AP3val, $cp_APTval, $cp_APTgroup, $cp_APTop;
global $cp_sort_order, $cp_INC_FILTER, $cp_INCTYPES, $gtable, $GAEVAL_DBID;

import_request_variables("gp","cp_");
		
		//require('/Product/' . $X . 'GDB/conf/GAEVALconf.php'); // moved to top of file - dhrasmus

		$SQL_svars = array('uid'                 =>'ann.uid',
				'geneId'              =>'geneId',
				'integrity'           =>'integrity',
				'introns_confirmed'   =>'introns_confirmed',
				'introns_unsupported' =>'introns_unsupported',
				'cds_size'            =>'cds_size',
				'utr5_size'           =>'utr5_size',
				'utr3_size'           =>'utr3_size',
				'exon_coverage'       =>'exon_coverage',
				'bound_5prime'        =>'bound_5prime',
				'bound_3prime'        =>'bound_3prime'
		);
		$SQL_orderCmd = array('bound_5prime_ASC' => "bound_5prime DESC",
				'bound_5prime_DESC'=> "bound_5prime ASC",
				'bound_3prime_ASC' => "bound_3prime DESC",
				'bound_3prime_DESC'=> "bound_3prime ASC",
				'AltSplicing_ASC'  => "CAST(((AS_AltIntron * (1 - AS_AltIntron_doc) * (1 - abs(AS_AltIntron_mindoc)) * (1 - abs(AS_AltIntron_maxdoc))) + (AS_AddIntron * (1 - AS_AddIntron_doc) * (1 - abs(AS_AddIntron_mindoc)) * (1 - abs(AS_AddIntron_maxdoc))) + (AS_ConIntron * (1 - AS_ConIntron_doc) * (1 - abs(AS_ConIntron_mindoc)) * (1 - abs(AS_ConIntron_maxdoc))) - AS_AltAnnIntron) AS SIGNED) DESC",
				'AltSplicing_DESC' => "(GREATEST(0,AS_AltAnnIntron_maxdoc) + GREATEST(0,AS_AltIntron_maxdoc) + GREATEST(0,AS_AddIntron_maxdoc) + GREATEST(0,AS_ConIntron_maxdoc)) DESC,(ABS(LEAST(0,AS_AltAnnIntron_mindoc)) + ABS(LEAST(0,AS_AltIntron_mindoc)) + ABS(LEAST(0,AS_AddIntron_mindoc)) + ABS(LEAST(0,AS_ConIntron_mindoc))) DESC",
				'AltTerm_ASC'      => "(CM_AltCPS * (1 - CM_AltCPS_doc)) DESC",
				'AltTerm_DESC'     => "CM_AltCPS_maxdoc DESC,CM_AltCPS_mindoc ASC",
				'Fission_ASC'      => "(CM_Fission * (1 - CM_Fission_doc)) DESC",
				'Fission_DESC'     => "CM_Fission_maxdoc DESC,CM_Fission_mindoc ASC",
				'Fusion_ASC'       => "(CM_Fusion * (1 - CM_Fusion_doc)) DESC",
				'Fusion_DESC'      => "CM_Fusion_maxdoc DESC,CM_Fusion_mindoc ASC",
				'AmbOlap_ASC'      => "(AE_AmbOverlap * (1 - AE_AmbOverlap_doc)) DESC",
				'AmbOlap_DESC'     => "AE_AmbOverlap_maxdoc DESC,AE_AmbOverlap_mindoc ASC",
		);
		$DEFAULT_COLUMN_ORDER  = array('geneId'              => 1,
				'url'                 => 2,
				'integrity'           => 3,
				'custom_integrity'    => 4,
				'introns_confirmed'   => 5,
				'introns_unsupported' => 6,
				'exon_coverage'       => 7,
				'utr5_size'           => 8,
				'cds_size'            => 9,
				'utr3_size'           =>10,
				'bound_5prime'        =>11,
				'bound_3prime'        =>12,
				'AltSplicing'         =>13,
				'AltTerm'             =>14,
				'Fission'             =>15,
				'Fusion'              =>16,
				'AmbOlap'             =>17,
		);
		$DEFAULT_COLUMN_HEADER = array('geneId'              =>'Annotation',
				'url'                 =>'URLs',
				'integrity'           =>'Standard Integrity',
				'custom_integrity'    =>'Custom Integrity',
				'introns_confirmed'   =>'Introns Confirmed',
				'introns_unsupported' =>'Introns Unsupported',
				'cds_size'            =>'CDS Size',
				'utr5_size'           =>'5`UTR Size',
				'utr3_size'           =>'3`UTR Size',
				'exon_coverage'       =>'%Coverage',
				'bound_5prime'=>"<img alt='Upstream Extension' title='Upstream Extension' src='${IMAGEDIR}${GAEVAL_IMG_Extend5}' />",
				'bound_3prime'=>"<img alt='Downstream Extension' title='Downstream Extension' src='${IMAGEDIR}${GAEVAL_IMG_Extend3}' />",
				'AltSplicing' =>"<img alt='Alternative Splicing' title='Alternative Splicing' src='${IMAGEDIR}${GAEVAL_IMG_AltStr}' />",
				'AltTerm'     =>"<img alt='Alternative Transcriptional Termination' title='Alternative Transcriptional Termination' src='${IMAGEDIR}${GAEVAL_IMG_AltCPS}' />",
				'Fission'     =>"<img alt='Annotation Spliting / Fission' title='Annotation Spliting / Fission' src='${IMAGEDIR}${GAEVAL_IMG_Fission}' />",
				'Fusion'      =>"<img alt='Annotation Merger / Fusion' title='Annotation Merger / Fusion' src='${IMAGEDIR}${GAEVAL_IMG_Fusion}' />",
				'AmbOlap'     =>"<img alt='Erroneous Annotation Overlap' title='Erroneous Annotation Overlap' src='${IMAGEDIR}${GAEVAL_IMG_AmbOlap}' />",
		);
		$COLUMN_DESCRIPTION = array('geneId'              =>'Annotation',
				'url'                 =>'WWW links',
				'integrity'           =>'Standard Integrity',
				'custom_integrity'    =>'Custom Integrity',
				'introns_confirmed'   =>'Introns Confirmed',
				'introns_unsupported' =>'Intons Unsupported',
				'cds_size'            =>'CDS Size',
				'utr5_size'           =>'5`UTR Size',
				'utr3_size'           =>'3`UTR Size',
				'exon_coverage'       =>'%Coverage',
				'bound_5prime'=>"Upstream Boundary Extension<img alt='Upstream Extension' class='colDesc' src='${IMAGEDIR}${GAEVAL_IMG_Extend5}' />",
				'bound_3prime'=>"Downstream Boundary Extension<img alt='Downstream Extension' class='colDesc' src='${IMAGEDIR}${GAEVAL_IMG_Extend3}' />",
				'AltSplicing' =>"Alternative Splicing / Structure<img alt='Alternative Splicing' class='colDesc' src='${IMAGEDIR}${GAEVAL_IMG_AltStr}' />",
				'AltTerm'     =>"Alternative Transcript Termination<img alt='Alternative Transcriptional Termination' class='colDesc' src='${IMAGEDIR}${GAEVAL_IMG_AltCPS}' />",
				'Fission'     =>"Annotation Fission / Spliting<img alt='Annotation Spliting / Fission' class='colDesc' src='${IMAGEDIR}${GAEVAL_IMG_Fission}' />",
				'Fusion'      =>"Annotation Fusion / Merger<img alt='Annotation Merger / Fusion' class='colDesc' src='${IMAGEDIR}${GAEVAL_IMG_Fusion}' />",
				'AmbOlap'     =>"Erroneous Annotation Overlap<img alt='Erroneous Annotation Overlap' class='colDesc' src='${IMAGEDIR}${GAEVAL_IMG_AmbOlap}' />",
		);
		$DEFAULT_INC = array('altsp'  =>'Alternative splicing / structure filter',
				'altcps' =>'Alternative transcript termination (Cleavage / PolyA site) filter',
				'fis'    =>'Split annotation filter',
				'fus'    =>'Merged annotation filter',
				'eolap'  =>'Erroneous annotation overlap filter',
		);
		$FLAG_TYPES = array('No Incongruence',
				"<img alt='Undocumented' src='${IMAGEDIR}${GAEVAL_IMG_PROP_undoc}' />Undocumented",
				"<img alt='Documented Isoforms' src='${IMAGEDIR}${GAEVAL_IMG_PROP_docL}' />Documented Isoforms",
				"<img alt='User Annotations' src='${IMAGEDIR}${GAEVAL_IMG_PROP_docU}'  />User Annotations",
				"<img alt='Undocumented &amp; Documented Isoforms' src='${IMAGEDIR}${GAEVAL_IMG_PROP_undoc_docL}' />Undocumented &amp; Documented Isoforms",
				"<img alt='Undocumented &amp; User Annotations' src='${IMAGEDIR}${GAEVAL_IMG_PROP_undoc_docU}' />Undocumented &amp; User Annotations",
				"<img alt='Isoforms &amp; User Annotations' src='${IMAGEDIR}${GAEVAL_IMG_PROP_docL_docU}' />Isoforms &amp; User Annotations",
				"<img alt='ALL Types' src='${IMAGEDIR}${GAEVAL_IMG_PROP_undoc_docL_docU}' />ALL Types"
		);
		$INC_FLAG_SQL = array('altsp'  => array('(!(AS_AddIntron || AS_AltIntron || AS_ConIntron || AS_AltAnnIntron))',
							'((AS_AddIntron AND !AS_AddIntron_doc)||(AS_AltIntron AND !AS_AltIntron_doc)||(AS_ConIntron AND !AS_ConIntron_doc))',
							'((AS_AddIntron_mindoc < 0)||(AS_AltIntron_mindoc < 0)||(AS_ConIntron_mindoc < 0)||(AS_AltAnnIntron_mindoc < 0))',
							'((AS_AddIntron_maxdoc > 0)||(AS_AltIntron_maxdoc > 0)||(AS_ConIntron_maxdoc > 0)||(AS_AltAnnIntron_maxdoc > 0))'),
					  'altcps' => array('(!CM_AltCPS)',
							'(CM_AltCPS AND !CM_AltCPS_doc)',
							'(CM_AltCPS_mindoc < 0)',
							'(CM_AltCPS_maxdoc > 0)'),
					  'fus'    => array('(!CM_Fusion)',
							'(CM_Fusion AND !CM_Fusion_doc)',
							'(CM_Fusion_mindoc < 0)',
							'(CM_Fusion_maxdoc > 0)'),
					  'fis'    => array('(!CM_Fission)',
							'(CM_Fission AND !CM_Fission_doc)',
							'(CM_Fission_mindoc < 0)',
							'(CM_Fission_maxdoc > 0)'),
					  'eolap'  => array('(!AE_AmbOverlap)',
							'(AE_AmbOverlap AND !AE_AmbOverlap_doc)',
							'(AE_AmbOverlap_mindoc < 0)',
							'(AE_AmbOverlap_maxdoc > 0)')
		);
		
		if($cp_col_order){ eval('$COLUMN_ORDER = array(' . str_replace('\\','',$cp_col_order) . ');');
		}else{ $COLUMN_ORDER = $DEFAULT_COLUMN_ORDER; }
		$displayCols = array_keys($COLUMN_ORDER);
		if($cp_sort_order){ eval('$SORT_ORDER = array(' . str_replace('\\','',$cp_sort_order) . ');');
		}else{ $SORT_ORDER = $DEFAULT_COLUMN_ORDER; }
		if($cp_sort_ort){
			eval('$SORT_ORT = array(' . str_replace('\\','',$cp_sort_ort) . ');');
		}else{
			$SORT_ORT = array('geneId'              =>"ASC",
				'url'                 =>"NONE",
				'integrity'           =>"DESC",
				'custom_integrity'    =>"NONE",
				'introns_confirmed'   =>"DESC",
				'introns_unsupported' =>"ASC",
				'exon_coverage'       =>"DESC",
				'utr5_size'           =>"NONE",
				'cds_size'            =>"NONE",
				'utr3_size'           =>"NONE",
				'bound_5prime'        =>"NONE",
				'bound_3prime'        =>"NONE",
				'AltSplicing'         =>"NONE",
				'AltTerm'             =>"NONE",
				'Fission'             =>"NONE",
				'Fusion'              =>"NONE",
				'AmbOlap'             =>"NONE"
			);
		}
		function by_sort($a,$b){
		  global $SORT_ORDER;
		  global $cp_list;
		
		  switch($cp_list){
		  case 'BOSdoc_AltS':
		  case 'BOSuca_AltS':
		  case 'MWuca_AltS':
			return strcmp($a,'AltSplicing')?strcmp($b,'AltSplicing')?($SORT_ORDER[$a] > $SORT_ORDER[$b])?1:-1:1:-1;
			break;
		  case 'BOSdoc_AltCPS':
		  case 'BOSuca_AltCPS':
		  case 'MWuca_AltCPS':
			return strcmp($a,'AltTerm')?strcmp($b,'AltTerm')?($SORT_ORDER[$a] > $SORT_ORDER[$b])?1:-1:1:-1;
			break;
		  case 'BOSdoc_Fis':
		  case 'BOSuca_Fis':
		  case 'MWuca_Fis':
			return strcmp($a,'Fission')?strcmp($b,'Fission')?($SORT_ORDER[$a] > $SORT_ORDER[$b])?1:-1:1:-1;
			break;
		  case 'BOSdoc_Fus':
		  case 'BOSuca_Fus':
		  case 'MWuca_Fus':
			return strcmp($a,'Fusion')?strcmp($b,'Fusion')?($SORT_ORDER[$a] > $SORT_ORDER[$b])?1:-1:1:-1;
			break;
		  case 'MWuca_AmbOlap':
			return strcmp($a,'AmbOlap')?strcmp($b,'AmbOlap')?($SORT_ORDER[$a] > $SORT_ORDER[$b])?1:-1:1:-1;
			break;
		  default:
			return ($SORT_ORDER[$a] > $SORT_ORDER[$b])?1:-1;
			break;
		  }
		}
		function by_display($a,$b){
			global $COLUMN_ORDER;

			return ($COLUMN_ORDER[$a] > $COLUMN_ORDER[$b]) ? 1 : -1;
		}

		$sortCols = array_keys($SORT_ORT);
		uasort($displayCols,'by_display');
		uasort($sortCols,'by_sort');
		if($cp_resultCols){
			uasort($cp_resultCols,'by_display');
		}elseif($cp_list){
			$cp_resultCols = $DEFAULT_COLUMN_ORDER;
			unset($cp_resultCols['custom_integrity']);
			uasort($cp_resultCols,'by_display');
		}

		if($cp_ANNsrc || $cp_list){
		  mysql_select_db($GAEVAL_DB_NAME);

		if(!$cp_ANNsrc){
			foreach(array_values($GAEVAL_SOURCES) as $src){
				$cp_ANNsrc = $src;
				break;
			}
		}

		$GAEVAL_TBLS = explode(":",$cp_ANNsrc);

		if($cp_list ||($cp_GAEVALsearch == "Retrieve annotations")){
			$SQL_where   = array();
			$SQL_having  = array();
			$SQL_orderby = array();
			
			if($cp_list){
			  if(!$cp_INC_FILTER){ $cp_INC_FILTER = array();}
			  switch ($cp_list){
			  case 'BOSdoc_AltS':
			$cp_INC_FILTER['altsp']  = 'CHECKED';
			$cp_INCTYPES['altsp'][2] = 1;
			break;
			  case 'BOSuca_AltS':
			$cp_INC_FILTER['altsp'] = 'CHECKED';
			$cp_INCTYPES['altsp'][3] = 1;
			$cp_INCTYPES['altsp'][6] = 1;
			break;
			  case 'BOSdoc_AltCPS':
			$cp_INC_FILTER['altcps'] = 'CHECKED';
				$cp_INCTYPES['altcps'][2] = 1;
			break;
			  case 'BOSuca_AltCPS':
			$cp_INC_FILTER['altcps'] = 'CHECKED';
			$cp_INCTYPES['altcps'][3] = 1;
			$cp_INCTYPES['altcps'][6] = 1;
			break;
			  case 'BOSdoc_Fis':
			$cp_INC_FILTER['fis'] = 'CHECKED';
			$cp_INCTYPES['fis'][2] = 1;
			break;
			  case 'BOSuca_Fis':
			$cp_INC_FILTER['fis'] = 'CHECKED';
			$cp_INCTYPES['fis'][3] = 1;
			$cp_INCTYPES['fis'][6] = 1;
			break;
			  case 'BOSdoc_Fus':
			$cp_INC_FILTER['fus'] = 'CHECKED';
			$cp_INCTYPES['fus'][2] = 1;
			break;
			  case 'BOSuca_Fus':
			$cp_INC_FILTER['fus'] = 'CHECKED';
			$cp_INCTYPES['fus'][3] = 1;
				$cp_INCTYPES['fus'][6] = 1;
			  break;
			  case 'BOSfreak_Introns':
			$SQL_orderby[] = "(introns_confirmed + introns_unsupported) DESC";
			$SQL_where[] = "((introns_confirmed + introns_unsupported) > (select (avg(introns_confirmed + introns_unsupported) + (3 * stddev(introns_confirmed + introns_unsupported ))) as x from $GAEVAL_TBLS[1] ))";
			  break;
			  case 'BOSfreak_Length':
			$SQL_orderby[] = "(utr5_size + cds_size + utr3_size) DESC";
			$SQL_where[] = "((utr5_size + cds_size + utr3_size) > (select (avg(utr5_size + cds_size + utr3_size) + (3 * stddev(utr5_size + cds_size + utr3_size))) as x from $GAEVAL_TBLS[1] ))";
			  break;
			  case 'MWuca_AltS':
			$cp_INC_FILTER['altsp']  = 'CHECKED';
			$cp_INCTYPES['altsp'][1] = 1;
			$cp_INCTYPES['altsp'][4] = 1;
			$cp_INCTYPES['altsp'][5] = 1;
			$cp_INCTYPES['altsp'][7] = 1;
			$SORT_ORT['AltSplicing'] = "ASC";
			  break;
			  case 'MWuca_AltCPS':
			$cp_INC_FILTER['altcps']  = 'CHECKED';
			$cp_INCTYPES['altcps'][1] = 1;
			$cp_INCTYPES['altcps'][4] = 1;
			$cp_INCTYPES['altcps'][5] = 1;
			$cp_INCTYPES['altcps'][7] = 1;
			$SORT_ORT['AltTerm'] = "ASC";
			  break;
			  case 'MWuca_Fis':
			$cp_INC_FILTER['fis']  = 'CHECKED';
			$cp_INCTYPES['fis'][1] = 1;
			$cp_INCTYPES['fis'][4] = 1;
			$cp_INCTYPES['fis'][5] = 1;
			$cp_INCTYPES['fis'][7] = 1;
			$SORT_ORT['Fission'] = "ASC";
			  break;
			  case 'MWuca_Fus':
			$cp_INC_FILTER['fus']  = 'CHECKED';
			$cp_INCTYPES['fus'][1] = 1;
			$cp_INCTYPES['fus'][4] = 1;
			$cp_INCTYPES['fus'][5] = 1;
			$cp_INCTYPES['fus'][7] = 1;
			$SORT_ORT['Fusion'] = "ASC";
			  break;
			  case 'MWuca_AmbOlap':
			$cp_INC_FILTER['eolap']  = 'CHECKED';
			$cp_INCTYPES['eolap'][1] = 1;
			$cp_INCTYPES['eolap'][4] = 1;
			$cp_INCTYPES['eolap'][5] = 1;
			$cp_INCTYPES['eolap'][7] = 1;
			$SORT_ORT['AmbOlap'] = "ASC";
			  break;
			  }
		
			  switch ($cp_list){
			  case 'BOSdoc_AltS':
			  case 'BOSuca_AltS':
			$SORT_ORT['AltSplicing'] = "DESC";
			  break;
			  case 'BOSdoc_AltCPS':
			  case 'BOSuca_AltCPS':
			$SORT_ORT['AltTerm'] = "DESC";
			  break;
			  case 'BOSdoc_Fis':
			  case 'BOSuca_Fis':
			$SORT_ORT['Fission'] = "DESC";
			  break;
			  case 'BOSdoc_Fus':
			  case 'BOSuca_Fus':
			$SORT_ORT['Fusion'] = "DESC";
			  break;
			  }
			  if(!$cp_returnLIMIT){
				$cp_returnLIMIT = 100;
			if(!$cp_resultOFFSET){
			  $cp_resultOFFSET = 0;
			}
			  }
			}

			switch ($cp_AIgroup){
			case 1:
			  $SQL_where[] = "(integrity BETWEEN " . min($cp_AIscore1,$cp_AIscore2) . " AND " . max($cp_AIscore1,$cp_AIscore2) . " )";
			break;
			case 2:
			  $SQL_svars['custom_integrity'] = "($cp_AICparam1 * IF((introns_confirmed + introns_unsupported),(introns_confirmed / (introns_confirmed + introns_unsupported)),LEAST(1,(cds_size / 400))) + ($cp_AICparam2 * exon_coverage) + ($cp_AICparam3 * LEAST(1,(utr5_size / 200))) + ($cp_AICparam4 * LEAST(1,(utr3_size / 200)))) as custom_integrity";
			  $SQL_having[] = "(( custom_integrity ) BETWEEN " . min($cp_AICscore1,$cp_AICscore2) . " AND " . max($cp_AICscore1,$cp_AICscore2) . " )";
			  $cp_resultCols['custom_integrity'] = 'custom_integrity';
			break;
			}
			
			switch ($cp_ISgroup){
			case 1:
			  $SQL_where[] = "(((introns_confirmed * 100) / (introns_confirmed + introns_unsupported)) BETWEEN " . min($cp_ISpct1,$cp_ISpct2) . " AND " . max($cp_ISpct1,$cp_ISpct2) . " )";
			break;
			case 2:
			  $SQL_where[] = "((introns_confirmed BETWEEN " . min($cp_ISconf1,$cp_ISconf2) . " AND " . max($cp_ISconf1,$cp_ISconf2) . " )AND(introns_unsupported BETWEEN " . min($cp_ISuns1,$cp_ISuns2) . " AND " . max($cp_ISuns1,$cp_ISuns2) . " ))";
			break;
			}
			
			switch ($cp_SCSgroup){
			case 1:
			  $SQL_where[] = "(exon_coverage BETWEEN " . (min($cp_SCSpct1,$cp_SCSpct2) / 100) . " AND " . (max($cp_SCSpct1,$cp_SCSpct2) / 100) . " )";
			break;
			}
		
			if($cp_BS5group){
			  if($cp_BS5op === 'between'){
			$SQL_where[] = "(bound_5prime BETWEEN " . (max($cp_BS5val['between'][0],$cp_BS5val['between'][1]) * -1) . " AND " . (min($cp_BS5val['between'][0],$cp_BS5val['between'][1]) * -1) . " )";
			  }elseif($cp_BS5op === 'equal'){
			$SQL_where[] = "(bound_5prime = " . ($cp_BS5val['equal'][0] * -1) . " )";
			  }elseif($cp_BS5op === 'greater'){
			$SQL_where[] = "(bound_5prime < " . ($cp_BS5val['greater'][0] * -1) . " )";
			  }elseif($cp_BS5op === 'less'){
			$SQL_where[] = "(bound_5prime > " . ($cp_BS5val['less'][0] * -1) . " )";
			  }
			}
			
			if($cp_BS3group){
			  if($cp_BS3op === 'between'){
			$SQL_where[] = "(bound_5prime BETWEEN " . (max($cp_BS3val['between'][0],$cp_BS3val['between'][1]) * -1) . " AND " . (min($cp_BS3val['between'][0],$cp_BS3val['between'][1]) * -1) . " )";
			  }elseif($cp_BS3op === 'equal'){
			$SQL_where[] = "(bound_5prime = " . ($cp_BS3val['equal'][0] * -1) . " )";
			  }elseif($cp_BS3op === 'greater'){
			$SQL_where[] = "(bound_5prime < " . ($cp_BS3val['greater'][0] * -1) . " )";
			  }elseif($cp_BS3op === 'less'){
			$SQL_where[] = "(bound_5prime > " . ($cp_BS3val['less'][0] * -1) . " )";
			  }
			}
		
			if($cp_APIgroup){
			  if($cp_APIop === 'between'){
			$SQL_where[] = "((introns_confirmed + introns_unsupported) BETWEEN " . min($cp_APIval['between'][0],$cp_APIval['between'][1]) . " AND " . max($cp_APIval['between'][0],$cp_APIval['between'][1]) . " )";
			  }elseif($cp_APIop === 'equal'){
			$SQL_where[] = "((introns_confirmed + introns_unsupported) = " . ($cp_APIval['equal'][0]) . " )";
			  }elseif($cp_APIop === 'greater'){
			$SQL_where[] = "((introns_confirmed + introns_unsupported) > " . ($cp_APIval['greater'][0]) . " )";
			  }elseif($cp_APIop === 'less'){
			$SQL_where[] = "((introns_confirmed + introns_unsupported) < " . ($cp_APIval['less'][0]) . " )";
			  }
			}
		
			if($cp_AP5group){
			  if($cp_AP5op === 'between'){
			$SQL_where[] = "(utr5_size BETWEEN " . min($cp_AP5val['between'][0],$cp_AP5val['between'][1]) . " AND " . max($cp_AP5val['between'][0],$cp_AP5val['between'][1]) . " )";
			  }elseif($cp_AP5op === 'equal'){
			$SQL_where[] = "(utr5_size = " . ($cp_AP5val['equal'][0]) . " )";
			  }elseif($cp_AP5op === 'greater'){
			$SQL_where[] = "(utr5_size > " . ($cp_AP5val['greater'][0]) . " )";
			  }elseif($cp_AP5op === 'less'){
			$SQL_where[] = "(utr5_size < " . ($cp_AP5val['less'][0]) . " )";
			  }
			}
		
			if($cp_APCgroup){
			  if($cp_APCop === 'between'){
			$SQL_where[] = "(cds_size BETWEEN " . min($cp_APCval['between'][0],$cp_APCval['between'][1]) . " AND " . max($cp_APCval['between'][0],$cp_APCval['between'][1]) . " )";
			  }elseif($cp_APCop === 'equal'){
			$SQL_where[] = "(cds_size = " . ($cp_APCval['equal'][0]) . " )";
			  }elseif($cp_APCop === 'greater'){
			$SQL_where[] = "(cds_size > " . ($cp_APCval['greater'][0]) . " )";
			  }elseif($cp_APCop === 'less'){
			$SQL_where[] = "(cds_size < " . ($cp_APCval['less'][0]) . " )";
			  }
			}
		
			if($cp_AP3group){
			  if($cp_AP3op === 'between'){
			$SQL_where[] = "(utr3_size BETWEEN " . min($cp_AP3val['between'][0],$cp_AP3val['between'][1]) . " AND " . max($cp_AP3val['between'][0],$cp_AP3val['between'][1]) . " )";
			  }elseif($cp_AP3op === 'equal'){
			$SQL_where[] = "(utr3_size = " . ($cp_AP3val['equal'][0]) . " )";
			  }elseif($cp_AP3op === 'greater'){
			$SQL_where[] = "(utr3_size > " . ($cp_AP3val['greater'][0]) . " )";
			  }elseif($cp_AP3op === 'less'){
			$SQL_where[] = "(utr3_size < " . ($cp_AP3val['less'][0]) . " )";
			  }
			}
		
			if($cp_APTgroup){
			  if($cp_APTop === 'between'){
			$SQL_where[] = "((utr5_size + cds_size + utr3_size) BETWEEN " . min($cp_APTval['between'][0],$cp_APTval['between'][1]) . " AND " . max($cp_APTval['between'][0],$cp_APTval['between'][1]) . " )";
			  }elseif($cp_APTop === 'equal'){
			$SQL_where[] = "((utr5_size + cds_size + utr3_size) = " . ($cp_APTval['equal'][0]) . " )";
			  }elseif($cp_APTop === 'greater'){
			$SQL_where[] = "((utr5_size + cds_size + utr3_size) > " . ($cp_APTval['greater'][0]) . " )";
			  }elseif($cp_APTop === 'less'){
			$SQL_where[] = "((utr5_size + cds_size + utr3_size) < " . ($cp_APTval['less'][0]) . " )";
			  }
			}


			if($cp_INC_FILTER){
			  foreach(array_keys($cp_INC_FILTER) as $inc){
			$INC_SQL_or = array();
			if($cp_INCTYPES[$inc][0]){
			  $INC_SQL_or[] = $INC_FLAG_SQL[$inc][0];
			}
			if($cp_INCTYPES[$inc][1]){
			  $INC_SQL_or[] = "(" . $INC_FLAG_SQL[$inc][1] . "AND !" . $INC_FLAG_SQL[$inc][2] . "AND !" . $INC_FLAG_SQL[$inc][3] . ")";
			}
			if($cp_INCTYPES[$inc][2]){
			  $INC_SQL_or[] = "(" . $INC_FLAG_SQL[$inc][2] . "AND !" . $INC_FLAG_SQL[$inc][1] . "AND !" . $INC_FLAG_SQL[$inc][3] . ")";
			}
			if($cp_INCTYPES[$inc][3]){
			  $INC_SQL_or[] = "(" . $INC_FLAG_SQL[$inc][3] . "AND !" . $INC_FLAG_SQL[$inc][1] . "AND !" . $INC_FLAG_SQL[$inc][2] . ")";
			}
			if($cp_INCTYPES[$inc][4]){
			  $INC_SQL_or[] = "(" . $INC_FLAG_SQL[$inc][1] . "AND" . $INC_FLAG_SQL[$inc][2] . "AND !" . $INC_FLAG_SQL[$inc][3] . ")";
			}
			if($cp_INCTYPES[$inc][5]){
			  $INC_SQL_or[] = "(" . $INC_FLAG_SQL[$inc][1] . "AND" . $INC_FLAG_SQL[$inc][3] . "AND !" . $INC_FLAG_SQL[$inc][2] . ")";
			}
			if($cp_INCTYPES[$inc][6]){
			  $INC_SQL_or[] = "(" . $INC_FLAG_SQL[$inc][2] . "AND" . $INC_FLAG_SQL[$inc][3] . "AND !" . $INC_FLAG_SQL[$inc][1] . ")";
			}
			if($cp_INCTYPES[$inc][7]){
			  $INC_SQL_or[] = "(" . $INC_FLAG_SQL[$inc][1] . "AND" . $INC_FLAG_SQL[$inc][2] . "AND" . $INC_FLAG_SQL[$inc][3] . ")";
			}
			$SQL_where[] = "(" . implode("||",$INC_SQL_or) . ")";
			  }
			}
		
			$SQL_cmd = "Select SQL_CALC_FOUND_ROWS " . implode(",",$SQL_svars) . ",flag.* FROM $GAEVAL_TBLS[1] as sup JOIN $GAEVAL_TBLS[0] as ann USING (uid) JOIN $GAEVAL_TBLS[3] as flag ON (ann.uid = flag.annUID)";
			if(count($SQL_where)){
			  $SQL_cmd .= " WHERE " . implode("AND",$SQL_where); 
			}
			if(count($SQL_having)){
			  $SQL_cmd .= " HAVING " . implode("AND",$SQL_having);
			}
			
			foreach($sortCols as $col){
			  if(strcmp($SORT_ORT[$col],"NONE")){
			if(array_key_exists("${col}_" . $SORT_ORT[$col],$SQL_orderCmd)){
			  $SQL_orderby[$col] = $SQL_orderCmd["${col}_" . $SORT_ORT[$col]];
			}elseif(array_key_exists($col,$SQL_svars)){
			  $SQL_orderby[$col] = "${col} " . $SORT_ORT[$col];
			}
			  }
			}
			$SQL_cmd .= " ORDER BY " . implode(",",$SQL_orderby);

		}elseif($cp_SQL_cmd){ //Shortcut to highly specified SQL query
			$SQL_cmd = $cp_SQL_cmd;
		}else{
			$SQL_cmd = 0;
		}

		if($SQL_cmd){
			$PRIMARY_SQL = $SQL_cmd;
			
			if($cp_returnLIMIT){
				$SQL_cmd .= " LIMIT ${cp_resultOFFSET},${cp_returnLIMIT} ";
			}

			//DEBUG SQL COMMAND   echo= $SQL_cmd;
			$result = mysql_query($SQL_cmd);
			$pageCNT = mysql_num_rows($result);
			$res2 = mysql_query("SELECT FOUND_ROWS()");
			$rCNT = mysql_fetch_row($res2);
			
			if($cp_returnLIMIT){
			  $PAGE_SELECTION = "<select name='resTOC' id='resTOC' onchange='goto_page(this);'>\n";
			  for($x=0;$x<=($rCNT[0] / $cp_returnLIMIT);$x++){
			if(($x * $cp_returnLIMIT) == $cp_resultOFFSET){
			  $PAGE_SELECTION .= "<option value=\"$x\" selected=\"selected\">Page " . ($x +1) . " Annotations ( " . ($x * $cp_returnLIMIT + 1) . " - " . ($x * $cp_returnLIMIT + $pageCNT) . " ) of $rCNT[0] </option>\n";
			}else{
			  $PAGE_SELECTION .= "<option value=\"$x\">Page " . ($x +1) . " Annotations ( " . ($x * $cp_returnLIMIT + 1) . " - " . ($x * $cp_returnLIMIT + $pageCNT) . " ) of $rCNT[0] </option>\n"; 
			}
			  }
			  $PAGE_SELECTION .= "</select>\n";
			}else{
			  $PAGE_SELECTION = "Annotations ( 1 - $rCNT[0] ) of $rCNT[0]";
			}
			
			$gtable= "<h3 class='GAEVALresultHeader alertnotice'>GAEVAL Search Results: $rCNT[0] gene models --  $PAGE_SELECTION </h3>\n";
		
			$gtable.= "<table id='GAEVALresults'>\n<tr>";
			foreach($displayCols as $col){
				if(array_key_exists($col,$cp_resultCols)){
					$gtable.= "<th>$DEFAULT_COLUMN_HEADER[$col]</th>";
				}
			}
			$gtable.= "</tr>\n";
				$UID ='gsegUID';


			while($row = mysql_fetch_assoc($result)){
			  $gtable.= "<tr>";
			  foreach($displayCols as $col){
			if(array_key_exists($col,$cp_resultCols)){
			  if($col == 'geneId'){
				$gtable.= "<td><a target='_new' href='${CGIPATH}findRecord.pl?id=$row[$col]'>$row[$col]</a></td>";
			  }elseif($col == 'url'){
				$gtable.= "<td><a target='_new' class='world_link' href='${CGIPATH}findRegion.pl?id=$row[geneId]'><img src='${IMAGEDIR}world.gif' alt='context' title='Genome Context Link' class='menubutton' /></a>\n";
				$gtable.= "<a target='_new' href='${CGIPATH}findRecord.pl?id=$row[geneId]'><img src='${IMAGEDIR}text.gif' alt='record' title='Annotation Record Link' class='menubutton' /></a>\n";
				$gtable.= "<a target='_new' href='${CGIPATH}GAEVALreport.pl?dbid=${GAEVAL_DBID}&amp;resid=$GAEVAL_TBLS[4]&amp;$UID=$row[uid]'><img src='${IMAGEDIR}key.gif' alt='gaeval' title='GAEVAL Report Link' class='menubutton' /></a></td>\n";
			  }elseif($col == 'exon_coverage'){
				$gtable.= "<td>" . (int)($row[$col] * 100) . "%</td>";
			  }elseif(($col == 'bound_5prime')||($col == 'bound_3prime')){
				if($row[$col] < 0){
				  $gtable.= "<td>" . ($row[$col] * -1) . "</td>";
				}else{
				  $gtable.= "<td></td>";
				}
			  }elseif($col == 'AltSplicing'){
				if(($row['AS_AddIntron'])||($row['AS_AltIntron'])||($row['AS_ConIntron'])||($row['AS_AltAnnIntron'])){
				  if(($row['AS_AddIntron'] && !$row['AS_AddIntron_doc'])||($row['AS_AltIntron'] && !$row['AS_AltIntron_doc'])||($row['AS_ConIntron'] && !$row['AS_ConIntron_doc'])){
				if(($row['AS_AddIntron'] && ($row['AS_AddIntron_mindoc'] < 0))||($row['AS_AltIntron'] && ($row['AS_AltIntron_mindoc'] < 0))||($row['AS_ConIntron'] && ($row['AS_ConIntron_mindoc'] < 0))){
				  if(($row['AS_AddIntron'] && ($row['AS_AddIntron_maxdoc'] > 0))||($row['AS_AltIntron'] && ($row['AS_AltIntron_maxdoc'] > 0))||($row['AS_ConIntron'] && ($row['AS_ConIntron_maxdoc'] > 0))){
					$gtable.= "<td class='flag'><img src='${IMAGEDIR}${GAEVAL_IMG_PROP_undoc_docL_docU}' alt='?' /></td>";
				  }else{
					$gtable.= "<td class='flag'><img src='${IMAGEDIR}${GAEVAL_IMG_PROP_undoc_docL}' alt='?' /></td>";
				  }
				}elseif(($row['AS_AddIntron'] && ($row['AS_AddIntron_maxdoc'] > 0))||($row['AS_AltIntron'] && ($row['AS_AltIntron_maxdoc'] > 0))||($row['AS_ConIntron'] && ($row['AS_ConIntron_maxdoc'] > 0))){
				  $gtable.= "<td class='flag'><img src='${IMAGEDIR}${GAEVAL_IMG_PROP_undoc_docU}' alt='?' /></td>";
				}else{
				  $gtable.= "<td class='flag'><img src='${IMAGEDIR}${GAEVAL_IMG_PROP_undoc}' alt='?' /></td>";
				}
				  }else{
				if(($row['AS_AddIntron'] && ($row['AS_AddIntron_mindoc'] < 0))||($row['AS_AltIntron'] && ($row['AS_AltIntron_mindoc'] < 0))||($row['AS_ConIntron'] && ($row['AS_ConIntron_mindoc'] < 0))||($row['AS_AltAnnIntron'] && ($row['AS_AltAnnIntron_mindoc'] < 0))){
				  if(($row['AS_AddIntron'] && ($row['AS_AddIntron_maxdoc'] > 0))||($row['AS_AltIntron'] && ($row['AS_AltIntron_maxdoc'] > 0))||($row['AS_ConIntron'] && ($row['AS_ConIntron_maxdoc'] > 0))||($row['AS_AltAnnIntron'] && ($row['AS_AltAnnIntron_maxdoc'] > 0))){
					$gtable.= "<td class='flag'><img src='${IMAGEDIR}${GAEVAL_IMG_PROP_docL_docU}' alt='?' /></td>";
				  }else{
					$gtable.= "<td class='flag'><img src='${IMAGEDIR}${GAEVAL_IMG_PROP_docL}' /></td>";
				  }
				}elseif(($row['AS_AddIntron'] && ($row['AS_AddIntron_maxdoc'] > 0))||($row['AS_AltIntron'] && ($row['AS_AltIntron_maxdoc'] > 0))||($row['AS_ConIntron'] && ($row['AS_ConIntron_maxdoc'] > 0))||($row['AS_AltAnnIntron'] && ($row['AS_AltAnnIntron_maxdoc'] > 0))){
				  $gtable.= "<td class='flag'><img src='${IMAGEDIR}${GAEVAL_IMG_PROP_docU}' alt='?' /></td>";
				}else{
				  $gtable.= "<td class='flag'><img src='${IMAGEDIR}${GAEVAL_IMG_noProp}' alt='?' /></td>";
				}
				  }
				}else{
				  $gtable.= "<td class='flag'><img src='${IMAGEDIR}${GAEVAL_IMG_noProp}' alt='?' /></td>";
				}
			  }elseif($col == 'AltTerm'){
				if($row['CM_AltCPS']){
				  if(!$row['CM_AltCPS_doc']){
				if($row['CM_AltCPS_mindoc'] < 0){
				  if($row['CM_AltCPS_maxdoc'] > 0){
					$gtable.= "<td class='flag'><img src='${IMAGEDIR}${GAEVAL_IMG_PROP_undoc_docL_docU}' alt='?' /></td>";
				  }else{
					$gtable.= "<td class='flag'><img src='${IMAGEDIR}${GAEVAL_IMG_PROP_undoc_docL}' alt='?' /></td>";
				  }
				}elseif($row['CM_AltCPS_maxdoc'] > 0){
				  $gtable.= "<td class='flag'><img src='${IMAGEDIR}${GAEVAL_IMG_PROP_undoc_docU}' alt='?' /></td>";
				}else{
				  $gtable.= "<td class='flag'><img src='${IMAGEDIR}${GAEVAL_IMG_PROP_undoc}' alt='?' /></td>";
				}
				  }else{
				if($row['CM_AltCPS_mindoc'] < 0){
				  if($row['CM_AltCPS_maxdoc'] > 0){
					$gtable.= "<td class='flag'><img src='${IMAGEDIR}${GAEVAL_IMG_PROP_docL_docU}' alt='?' /></td>";
				  }else{
					$gtable.= "<td class='flag'><img src='${IMAGEDIR}${GAEVAL_IMG_PROP_docL}' alt='?' /></td>";
				  }
				}elseif($row['CM_AltCPS_maxdoc'] > 0){
				  $gtable.= "<td class='flag'><img src='${IMAGEDIR}${GAEVAL_IMG_PROP_docU}' alt='?' /></td>";
				}else{
				  $gtable.= "<td class='flag'><img src='${IMAGEDIR}${GAEVAL_IMG_noProp}' alt='?' /></td>";
				}
				  }
				}else{
				  $gtable.= "<td class='flag'><img src='${IMAGEDIR}${GAEVAL_IMG_noProp}' alt='?' /></td>";		
				}
			  }elseif($col == 'Fission'){
				if($row['CM_Fission']){
				  if(!$row['CM_Fission_doc']){
				if($row['CM_Fission_mindoc'] < 0){
				  if($row['CM_Fission_maxdoc'] > 0){
					$gtable.= "<td class='flag'><img src='${IMAGEDIR}${GAEVAL_IMG_PROP_undoc_docL_docU}' alt='?' /></td>";
				  }else{
					$gtable.= "<td class='flag'><img src='${IMAGEDIR}${GAEVAL_IMG_PROP_undoc_docL}' alt='?' /></td>";
				  }
				}elseif($row['CM_Fission_maxdoc'] > 0){
				  $gtable.= "<td class='flag'><img src='${IMAGEDIR}${GAEVAL_IMG_PROP_undoc_docU}' alt='?' /></td>";
				}else{
				  $gtable.= "<td class='flag'><img src='${IMAGEDIR}${GAEVAL_IMG_PROP_undoc}' alt='?' /></td>";
				}
				  }else{
				if($row['CM_Fission_mindoc'] < 0){
				  if($row['CM_Fission_maxdoc'] > 0){
					$gtable.= "<td class='flag'><img src='${IMAGEDIR}${GAEVAL_IMG_PROP_docL_docU}' alt='?' /></td>";
				  }else{
					$gtable.= "<td class='flag'><img src='${IMAGEDIR}${GAEVAL_IMG_PROP_docL}' alt='?' /></td>";
				  }
				}elseif($row['CM_Fission_maxdoc'] > 0){
				  $gtable.= "<td class='flag'><img src='${IMAGEDIR}${GAEVAL_IMG_PROP_docU}' alt='?' /></td>";
				}else{
				  $gtable.= "<td class='flag'><img src='${IMAGEDIR}${GAEVAL_IMG_noProp}' alt='?' /></td>";
				}
				  }
				}else{
				  $gtable.= "<td class='flag'><img src='${IMAGEDIR}${GAEVAL_IMG_noProp}' alt='?' /></td>";		
				}
			  }elseif($col == 'Fusion'){
				if($row['CM_Fusion']){
				  if(!$row['CM_Fusion_doc']){
				if($row['CM_Fusion_mindoc'] < 0){
				  if($row['CM_Fusion_maxdoc'] > 0){
					$gtable.= "<td class='flag'><img src='${IMAGEDIR}${GAEVAL_IMG_PROP_undoc_docL_docU}' alt='?' /></td>";
				  }else{
					$gtable.= "<td class='flag'><img src='${IMAGEDIR}${GAEVAL_IMG_PROP_undoc_docL}' alt='?' /></td>";
				  }
				}elseif($row['CM_Fusion_maxdoc'] > 0){
				  $gtable.= "<td class='flag'><img src='${IMAGEDIR}${GAEVAL_IMG_PROP_undoc_docU}' alt='?' /></td>";
				}else{
				  $gtable.= "<td class='flag'><img src='${IMAGEDIR}${GAEVAL_IMG_PROP_undoc}' alt='?' /></td>";
				}
				  }else{
				if($row['CM_Fusion_mindoc'] < 0){
				  if($row['CM_Fusion_maxdoc'] > 0){
					$gtable.= "<td class='flag'><img src='${IMAGEDIR}${GAEVAL_IMG_PROP_docL_docU}' alt='?' /></td>";
				  }else{
					$gtable.= "<td class='flag'><img src='${IMAGEDIR}${GAEVAL_IMG_PROP_docL}' alt='?' /></td>";
				  }
				}elseif($row['CM_Fusion_maxdoc'] > 0){
				  $gtable.= "<td class='flag'><img src='${IMAGEDIR}${GAEVAL_IMG_PROP_docU}' alt='?' /></td>";
				}else{
				  $gtable.= "<td class='flag'><img src='${IMAGEDIR}${GAEVAL_IMG_noProp}' alt='?' /></td>";
				}
				  }
				}else{
				  $gtable.= "<td class='flag'><img src='${IMAGEDIR}${GAEVAL_IMG_noProp}' alt='?' /></td>";		
				}
			  }elseif($col == 'AmbOlap'){
				if($row['AE_AmbOverlap']){
				  if(!$row['AE_AmbOverlap_doc']){
				if($row['AE_AmbOverlap_mindoc'] < 0){
				  if($row['AE_AmbOverlap_maxdoc'] > 0){
					$gtable.= "<td class='flag'><img src='${IMAGEDIR}${GAEVAL_IMG_PROP_undoc_docL_docU}' alt='?' /></td>";
				  }else{
					$gtable.= "<td class='flag'><img src='${IMAGEDIR}${GAEVAL_IMG_PROP_undoc_docL}' alt='?' /></td>";
				  }
				}elseif($row['AE_AmbOverlap_maxdoc'] > 0){
				  $gtable.= "<td class='flag'><img src='${IMAGEDIR}${GAEVAL_IMG_PROP_undoc_docU}' alt='?' /></td>";
				}else{
				  $gtable.= "<td class='flag'><img src='${IMAGEDIR}${GAEVAL_IMG_PROP_undoc}' alt='?' /></td>";
				}
				  }else{
				if($row['AE_AmbOverlap_mindoc'] < 0){
				  if($row['AE_AmbOverlap_maxdoc'] > 0){
					$gtable.= "<td class='flag'><img src='${IMAGEDIR}${GAEVAL_IMG_PROP_docL_docU}' alt='?' /></td>";
				  }else{
					$gtable.= "<td class='flag'><img src='${IMAGEDIR}${GAEVAL_IMG_PROP_docL}' alt='?' /></td>";
				  }
				}elseif($row['AE_AmbOverlap_maxdoc'] > 0){
				  $gtable.= "<td class='flag'><img src='${IMAGEDIR}${GAEVAL_IMG_PROP_docU}' alt='?' /></td>";
				}else{
				  $gtable.= "<td class='flag'><img src='${IMAGEDIR}${GAEVAL_IMG_noProp}' alt='?' /></td>";
				}
				  }
				}else{
				  $gtable.= "<td class='flag'><img src='${IMAGEDIR}${GAEVAL_IMG_noProp}' alt='?' /></td>";
				}
			  }else{
				$gtable.= "<td>$row[$col]</td>"; 
			  }
			}
			  }
		
			  $gtable.= "</tr>\n";
			}
		
			$gtable.= "<tr>\n";
			foreach($cp_resultCols as $col){ $gtable.= "<th>$DEFAULT_COLUMN_HEADER[$col]</th>"; }
			$gtable.= "</tr>\n";
			$gtable.= "</table>\n";
			
			// TODO: Convert this to lowercase
			// print new inline stylesheet to close the query selection list
		
			mysql_free_result($result);
			mysql_free_result($res2);
		  }
		}

		// Check form values and initialize defaults
		if(!isset($cp_ANNsrc)){
			$src = array_values($GAEVAL_SOURCES);
			$cp_ANNsrc = $src[0];
		}
		if(!isset($cp_returnLIMIT)){ $cp_returnLIMIT = 50; }

		if(!isset($cp_AIgroup)){ $cp_AIgroup = 0; }
		if(!isset($cp_AIscore1)){ $cp_AIscore1 = 0; }
		if(!isset($cp_AIscore2)){ $cp_AIscore2 = 1; }
		if(!isset($cp_AICscore1)){ $cp_AICscore1 = 0; }
		if(!isset($cp_AICscore2)){ $cp_AICscore2 = 1; }
		if(!isset($cp_AICparam1)){ $cp_AICparam1 = 0.60; }
		if(!isset($cp_AICparam2)){ $cp_AICparam2 = 0.30; }
		if(!isset($cp_AICparam3)){ $cp_AICparam3 = 0.05; }
		if(!isset($cp_AICparam4)){ $cp_AICparam4 = 0.05; }
		
		if(!isset($cp_ISpct1)){ $cp_ISpct1 = 0; }
		if(!isset($cp_ISpct2)){ $cp_ISpct2 = 100; }
		if(!isset($cp_ISconf1)){ $cp_ISconf1 = 0; }
		if(!isset($cp_ISconf2)){ $cp_ISconf2 = 1000; }
		if(!isset($cp_ISuns1)){ $cp_ISuns1 = 0; }
		if(!isset($cp_ISuns2)){ $cp_ISuns2 = 1000; }
		
		if(!isset($cp_SCSpct1)){ $cp_SCSpct1 = 0; }
		if(!isset($cp_SCSpct2)){ $cp_SCSpct2 = 100; }

		?>
		<input type='text' name='resultOFFSET' id='resultOFFSET' value='0' style='display:none;' />
		<input type='text' name='SQL_cmd' id='SQL_cmd' value='<?php echo htmlentities($PRIMARY_SQL); ?>' style='display:none;' />
		<ul id='GAEVALquery'>
		<li>
			<img src='<?php echo $IMAGEDIR; ?>GDBmenuArrow2.png' class='menubutton' id='DISPLAYclosed' alt='(Expand)' onclick='openMENU("display_on");' />
			<img src='<?php echo $IMAGEDIR; ?>GDBmenuArrow.png' class='menubutton' id='DISPLAYopen' alt='(Collapse)' onclick='closeMENU("display_on");' />Display Options
			<ul class='DISPLAYgroup' id='DISPLAYoptions'>
                <?php
                $jscript = "var colRow = new Array();\nvar colOrder = new Object();\nvar sortORT = new Object();\nvar sortOrder = new Object();\n";
                $colList = "";
                $sortORTlist = '';
                $x=1;
                foreach($displayCols as $col){
                  $jscript .= "colRow[$x] = '${col}';\n";
                  $jscript .= "colOrder[\"${col}\"] = Number($x);\n";
                  $colList .= "'${col}'=>$x,";
                  $select = ((!count($cp_resultCols))||($cp_resultCols[$col]))?"checked='checked'":"";
                  if((!count($cp_resultCols))&&($col == 'custom_integrity')){ $select = ""; }
                  echo "<li id='row_${x}' class='options'>
                            <table cellspacing='0' cellpadding='0' class='colOrderButtons'>
                                <tr><td>
                                  <a href='javascript:DISup(\"${col}\");'>
                                    <img alt='Move Up' class='buttonIMG' src='${IMAGEDIR}uparrow.gif' />
                                  </a>
                                </td></tr>
                                <tr><td>
                                  <a href='javascript:DISdown(\"${col}\");'>
                                      <img alt='Move Down' class='buttonIMG' src='${IMAGEDIR}downarrow.gif' />
                                  </a>
                                </td></tr>
                            </table>\n";
                  if($SORT_ORT[$col] === 'ASC'){
                    $jscript .= "sortORT[\"${col}\"] = 'ASC';\n";
                    $sortORTlist .= "'${col}'=>'ASC',";
                    echo "<img src='${IMAGEDIR}ascend.png' alt='ASC' title='Sort Ascending' class='menubutton' id='ORT${x}asc' onclick='sortORT[\"${col}\"] = \"DESC\";descend(\"ORT${x}\");' />\n";
                    echo "<img src='${IMAGEDIR}descend.png' alt='DESC' title='Sort Descending' class='menubutton' id='ORT${x}desc' onclick='sortORT[\"${col}\"] = \"NONE\";nosort(\"ORT${x}\");' style='display:none;' />\n";
                    echo "<img src='${IMAGEDIR}noSort.png' alt='NONE' title='Do NOT sort by this column' class='menubutton' id='ORT${x}none' onclick='sortORT[\"${col}\"] = \"ASC\";ascend(\"ORT${x}\");' style='display:none;' />\n";
                  }elseif($SORT_ORT[$col] === 'DESC'){
                    $jscript .= "sortORT[\"${col}\"] = 'DESC';\n";
                    $sortORTlist .= "'${col}'=>'DESC',";
                    echo "<img src='${IMAGEDIR}ascend.png' alt='ASC' title='Sort Ascending' class='menubutton' id='ORT${x}asc' onclick='sortORT[\"${col}\"] = \"DESC\";descend(\"ORT${x}\");' style='display:none;' />\n";
                    echo "<img src='${IMAGEDIR}descend.png' alt='DESC' title='Sort Descending' class='menubutton' id='ORT${x}desc' onclick='sortORT[\"${col}\"] = \"NONE\";nosort(\"ORT${x}\");' />\n";
                    echo "<img src='${IMAGEDIR}noSort.png' alt='NONE' title='Do NOT sort by this column' class='menubutton' id='ORT${x}none' onclick='sortORT[\"${col}\"] = \"ASC\";ascend(\"ORT${x}\");' style='display:none;' />\n";
                  }else{
                    $jscript .= "sortORT[\"${col}\"] = 'NONE';\n";
                    $sortORTlist .= "'${col}'=>'NONE',";
                    echo "<img src='${IMAGEDIR}ascend.png' alt='ASC' title='Sort Ascending' class='menubutton' id='ORT${x}asc' onclick='sortORT[\"${col}\"] = \"DESC\";descend(\"ORT${x}\");' style='display:none;' />\n";
                    echo "<img src='${IMAGEDIR}descend.png' alt='DESC' title='Sort Descending' class='menubutton' id='ORT${x}desc' onclick='sortORT[\"${col}\"] = \"NONE\";nosort(\"ORT${x}\");' style='display:none;' />\n";
                    echo "<img src='${IMAGEDIR}noSort.png' alt='NONE' title='Do NOT sort by this column' class='menubutton' id='ORT${x}none' onclick='sortORT[\"${col}\"] = \"ASC\";ascend(\"ORT${x}\");' />\n";
                  }
        
                echo "<select name='sortOrder_${col}' class='sortOrderSELECT' id='sortOrder_${col}' onchange='changeSortOrder(\"${col}\",this.value);'>\n";
                $so = 1;
                foreach($sortCols as $soCol){
                    if($soCol == $col){
                      echo "<option value=\"$so\" selected=\"selected\">$so</option>\n";
                    }else{
                      echo "<option value=\"$so\">$so</option>\n";
                    }
                    $so++;
                }
                echo "</select>\n";
                echo "<input type='checkbox' name='resultCols[$col]' value='$col' ${select} />$COLUMN_DESCRIPTION[$col]</li>\n";
                  $x++;
                }
                $x--;
                $jscript .= "var colRowCNT = Number(${x});\n";
                $soList = "";
                $so = 1;
                foreach($sortCols as $soCol){
                  $jscript .= "sortOrder[\"${soCol}\"] = Number($so);\n";
                  $soList .= "'${soCol}'=>$so,";
                  $so++;
                }
                ?>
				<li>
					<script type='text/javascript'><?php echo $jscript; ?></script>
					<input class='debug' type='text' id='col_order' name='col_order' value="<?php echo $colList; ?>" />
					<input class='debug' type='text' id='sort_order' name='sort_order' value="<?php echo $soList; ?>" />
					<input class='debug' type='text' id='sort_ort' name='sort_ort' value="<?php echo $sortORTlist; ?>" />
				</li>
				<li>The order of the above items determine their display order (left to right) in the results table</li>
				<li>Fields with an 'X (NO SORT)' will NOT be used to sort results</li>
				<li>Numbers in the drop down menu determine the sort order of the displayed results</li>
				<li>Un-checked fields will not be displayed as columns in the results table</li>
			</ul>
		</li>
		<li>
		<img src='<?php echo $IMAGEDIR; ?>GDBmenuArrow2.png' class='menubutton' id='BOSclosed' alt='Expand' onclick='openMENU("BOS");' />
		<img src='<?php echo $IMAGEDIR; ?>GDBmenuArrow.png' class='menubutton' id='BOSopen' alt='Collapse' onclick='closeMENU("BOS");' />BEST OF SHOW! Annotations
		<ul class='BOSgroup' id='BOSoptions'>
		<li id='BOSuca'>User Annotated Division<ul>
			<li><a href='/XGDB/phplib/GAEVAL.php?list=BOSuca_AltS&amp;GDB=<?php echo $X; ?>'>Alternative Splicing</a></li>
			<li><a href='/XGDB/phplib/GAEVAL.php?list=BOSuca_AltCPS&amp;GDB=<?php echo $X; ?>'>Alternative Transcript Termination</a></li>
			<li><a href='/XGDB/phplib/GAEVAL.php?list=BOSuca_Fis&amp;GDB=<?php echo $X; ?>'>Gene Fission</a></li>
			<li><a href='/XGDB/phplib/GAEVAL.php?list=BOSuca_Fus&amp;GDB=<?php echo $X; ?>'>Gene Fusion</a></li>
		</ul></li>
		<li id='BOSdoc'>Documented Isoform Division<ul>
			<li><a href='/XGDB/phplib/GAEVAL.php?list=BOSdoc_AltS&amp;GDB=<?php echo $X; ?>'>Alternative Splicing</a></li>
			<li><a href='/XGDB/phplib/GAEVAL.php?list=BOSdoc_AltCPS&amp;GDB=<?php echo $X; ?>'>Alternative Transcript Termination</a></li>
			<li><a href='/XGDB/phplib/GAEVAL.php?list=BOSdoc_Fis&amp;GDB=<?php echo $X; ?>'>Gene Fission</a></li>
			<li><a href='/XGDB/phplib/GAEVAL.php?list=BOSdoc_Fus&amp;GDB=<?php echo $X; ?>'>Gene Fusion</a></li>
		</ul></li>
		<li id='BOSfreak'>The Freaks (unusual properties)<ul>
			<li><a href='/XGDB/phplib/GAEVAL.php?list=BOSfreak_Introns&amp;GDB=<?php echo $X; ?>'>Number of Introns</a></li>
			<li><a href='/XGDB/phplib/GAEVAL.php?list=BOSfreak_Length&amp;GDB=<?php echo $X; ?>'>Transcript Length</a></li>
		</ul></li>
		</ul></li>
		
		<li><img src='<?php echo $IMAGEDIR; ?>GDBmenuArrow2.png' class='menubutton' id='MWclosed' alt='(Expand)' onclick='openMENU("MW");' />
		<img src='<?php echo $IMAGEDIR; ?>GDBmenuArrow.png' class='menubutton' id='MWopen' alt='(Collapse)' onclick='closeMENU("MW");' />MOST WANTED! Annotations
		<ul class='MWgroup' id='MWoptions'>
		<li id='MWuca'>Wanted on Suspicion of UNANNOTATED!
			<ul>
				<li><a href='/XGDB/phplib/GAEVAL.php?list=MWuca_AltS&amp;GDB=<?php echo $X; ?>'>Alternative Splicing</a></li>
				<li><a href='/XGDB/phplib/GAEVAL.php?list=MWuca_AltCPS&amp;GDB=<?php echo $X; ?>'>Alternative Transcript Termination</a></li>
				<li><a href='/XGDB/phplib/GAEVAL.php?list=MWuca_Fis&amp;GDB=<?php echo $X; ?>'>Gene Fission</a></li>
				<li><a href='/XGDB/phplib/GAEVAL.php?list=MWuca_Fus&amp;GDB=<?php echo $X; ?>'>Gene Fusion</a></li>
				<li><a href='/XGDB/phplib/GAEVAL.php?list=MWuca_AmbOlap&amp;GDB=<?php echo $X; ?>'>Erroneous Gene Overlap</a></li>
			</ul>
		</li>
		</ul></li>

		<li><img src='<?php echo $IMAGEDIR; ?>GDBmenuArrow2.png' class='menubutton' id='AIclosed' alt='(Expand)' onclick='openMENU("AI");' />
		<img src='<?php echo $IMAGEDIR; ?>GDBmenuArrow.png' class='menubutton' id='AIopen' alt='(Collapse)' onclick='closeMENU("AI");' />Annotation Integrity Filter
		<ul class='AIgroup' id='AIoptions'>
		<li><input type='radio' name='AIgroup' value='0' onchange='AIenable(this.value);' <?php if($cp_AIgroup == 0){ echo "checked='checked'"; } ?> />Do NOT filter by integrity score!</li>
		<li><input type='radio' name='AIgroup' value='1' onchange='AIenable(this.value);' <?php if($cp_AIgroup == 1){ echo "checked='checked'"; } ?> />Select annotations with Integrity Scores
		<p class='AIcustom'>Between
			<input type='text' name='AIscore1' id='AIscore1' value='<?php printf("%.2f",$cp_AIscore1); ?>' size='4' <?php if($cp_AIgroup != 1){ echo "disabled='disabled'"; } ?> /> and 
			<input type='text' name='AIscore2' id='AIscore2' value='<?php printf("%.2f",$cp_AIscore2); ?>' size='4' <?php if($cp_AIgroup != 1){ echo "disabled='disabled'"; } ?> />
		</p></li>
		<li><input type='radio' name='AIgroup' value='2' onchange='AIenable(this.value);' <?php if($cp_AIgroup == 2){ echo "checked='checked'"; } ?> />Select annotations with CUSTOM Integrity Scores
		<p class='AIcustom'>
		Between
			<input type='text' name='AICscore1' id='AICscore1' value='<?php printf("%.2f",$cp_AICscore1); ?>' size='4' <?php if($cp_AIgroup != 2){ echo "disabled='disabled'"; } ?> /> and 
			<input type='text' name='AICscore2' id='AICscore2' value='<?php printf("%.2f",$cp_AICscore2); ?>' size='4' <?php if($cp_AIgroup != 2){ echo "disabled='disabled'"; } ?> /><br />
		CUSTOM Annotation Integrity = (<input type='text' name='AICparam1' id='AICparam1' value='<?php printf("%.2f",$cp_AICparam1); ?>' size='4' <?php if($cp_AIgroup != 2){ echo "disabled='disabled'"; } ?> /> * alpha) +
		(<input type='text' name='AICparam2' id='AICparam2' value='<?php printf("%.2f",$cp_AICparam2); ?>' size='4' <?php if($cp_AIgroup != 2){ echo "disabled='disabled'"; } ?> /> * beta) +
		(<input type='text' name='AICparam3' id='AICparam3' value='<?php printf("%.2f",$cp_AICparam3); ?>' size='4' <?php if($cp_AIgroup != 2){ echo "disabled='disabled'"; } ?> /> * delta) +
		(<input type='text' name='AICparam4' id='AICparam4' value='<?php printf("%.2f",$cp_AICparam4); ?>' size='4' <?php if($cp_AIgroup != 2){ echo "disabled='disabled'"; } ?> /> * gamma)
		</p></li>
		</ul>
		</li>

		<li><img src='<?php echo $IMAGEDIR; ?>GDBmenuArrow2.png' class='menubutton' id='ISclosed' alt='(Expand)' onclick='openMENU("IS");' />
		<img src='<?php echo $IMAGEDIR; ?>GDBmenuArrow.png' class='menubutton' id='ISopen' alt='(Collapse)' onclick='closeMENU("IS");' />Annotation Support Filter (Intron Support)
		<ul class='ISgroup' id='ISoptions'>
		<li><input type='radio' name='ISgroup' value='0' onchange='ISenable(this.value);' <?php if($cp_ISgroup == 0){ echo "checked='checked'"; } ?> />Do NOT filter by intron support!</li>
		<li><input type='radio' name='ISgroup' value='1' onchange='ISenable(this.value);' <?php if($cp_ISgroup == 1){ echo "checked='checked'"; } ?> />Select annotations with a percentage of confirmed introns
		<p class='AIcustom'>Between <input type='text' name='ISpct1' id='ISpct1' value='<?php printf("%3d",$cp_ISpct1); ?>' size='3' <?php if($cp_ISgroup != 1){ echo "disabled='disabled'"; } ?> />% and <input type='text' name='ISpct2' id='ISpct2' value='<?php printf("%3d",$cp_ISpct2); ?>' size='3' <?php if($cp_ISgroup != 1){ echo "disabled='disabled'"; } ?> />%
		</p></li>
		<li><input type='radio' name='ISgroup' value='2' onchange='ISenable(this.value);' <?php if($cp_ISgroup == 2){ echo "checked='checked'"; } ?> />Select annotations with
		<p class='AIcustom'>Between <input type='text' name='ISconf1' id='ISconf1' value='<?php printf("%4d",$cp_ISconf1); ?>' size='4' <?php if($cp_ISgroup != 2){ echo "disabled='disabled'"; } ?> /> and <input type='text' name='ISconf2' id='ISconf2' value='<?php printf("%4d",$cp_ISconf2); ?>' size='4' <?php if($cp_ISgroup != 2){ echo "disabled='disabled'"; } ?> /> introns confirmed<br />
		AND<br />
		Between <input type='text' name='ISuns1' id='ISuns1' value='<?php printf("%4d",$cp_ISuns1); ?>' size='4' <?php if($cp_ISgroup != 2){ echo "disabled='disabled'"; } ?> /> and <input type='text' name='ISuns2' id='ISuns2' value='<?php printf("%4d",$cp_ISuns2); ?>' size='4'<?php if($cp_ISgroup != 2){ echo "disabled='disabled'"; } ?> /> introns unsupported
		</p></li>
		</ul>
		</li>

		<li><img src='<?php echo $IMAGEDIR; ?>GDBmenuArrow2.png' class='menubutton' id='SCSclosed' alt='(Expand)' onclick='openMENU("SCS");' />
		<img src='<?php echo $IMAGEDIR; ?>GDBmenuArrow.png' class='menubutton' id='SCSopen' alt='(Collapse)' onclick='closeMENU("SCS");' />Annotation Support Filter (Sequence Coverage)
		<ul class='SCSgroup' id='SCSoptions'>
		<li><input type='radio' name='SCSgroup' value='0' onchange='SCSenable(this.value);' <?php if($cp_SCSgroup == 0){ echo "checked='checked'"; } ?> />Do NOT filter by sequence coverage!</li>
		<li><input type='radio' name='SCSgroup' value='1' onchange='SCSenable(this.value);' <?php if($cp_SCSgroup == 1){ echo "checked='checked'"; } ?> />Select annotations with a percent sequence coverage
		<p class='AIcustom'>Between <input type='text' name='SCSpct1' id='SCSpct1' value='<?php printf("%3d",$cp_SCSpct1); ?>' size='3' <?php if($cp_SCSgroup != 1){ echo "disabled='disabled'"; } ?> />% and <input type='text' name='SCSpct2' id='SCSpct2' value='<?php printf("%3d",$cp_SCSpct2); ?>' size='3' <?php if($cp_SCSgroup != 1){ echo "disabled='disabled'"; } ?> />%
		</p></li>
		</ul>
		</li>
		
		<li><img src='<?php echo $IMAGEDIR; ?>GDBmenuArrow2.png' class='menubutton' id='BSclosed' alt='(Expand)' onclick='openMENU("BS");' />
		<img src='<?php echo $IMAGEDIR; ?>GDBmenuArrow.png' class='menubutton' id='BSopen' alt='(Collapse)' onclick='closeMENU("BS");' />Annotation Support Filter (Boundary Support)
		<ul class='BSgroup' id='BSoptions'>
		<li><input type='checkbox' name='BS5group' value='<?php if($cp_BS5group){ echo "1"; }else{ echo "0"; } ?>' onchange='BSenable("BS5op",this);' <?php if($cp_BS5group){ echo "checked='checked'"; } ?> />Filter by upstream (5&apos;) boundary support
		<p class='AIcustom'>Select 5&apos; boundaries with supported extensions
		<select name='BS5op' id='BS5op' onchange='BSopSelect("BS5op_",this.value);' <?php if(!$cp_BS5group){ echo "disabled='disabled'"; } ?>>
			<option value='between' <?php if($cp_BS5op === 'between'){ echo "selected='selected'"; } ?>>between</option>
			<option value='equal' <?php if($cp_BS5op === 'equal'){ echo "selected='selected'"; } ?>>equal to</option>
			<option value='greater' <?php if((!$cp_BS5op)||($cp_BS5op === 'greater')){ echo "selected='selected'"; } ?>>greater than</option>
			<option value='less' <?php if($cp_BS5op === 'less'){ echo "selected='selected'"; } ?>>less than</option>
		</select>
		<span id='BS5op_span_between' <?php if(strcmp($cp_BS5op,"between")){ echo "class='unselected'"; }else{ echo "class='selected'"; } ?>>
		<input type='text' name='BS5val[between][0]' id='BS5op_between_0' value='<?php if($cp_BS5val['between'][0]){echo $cp_BS5val['between'][0];}else{ echo "0";} ?>' size='4' <?php if(!$cp_BS5group){ echo "disabled='disabled'"; } ?>/> and 
		<input type='text' name='BS5val[between][1]' id='BS5op_between_1' value='<?php if($cp_BS5val['between'][1]){echo $cp_BS5val['between'][1];}else{ echo "1000";} ?>' size='4' <?php if(!$cp_BS5group){ echo "disabled='disabled'"; } ?>/>
		</span>
		<span id='BS5op_span_equal' <?php if(strcmp($cp_BS5op,"equal")){ echo "class='unselected'"; }else{ echo "class='selected'"; } ?>>
		<input type='text' name='BS5val[equal][0]' id='BS5op_equal' value='<?php if($cp_BS5val['equal'][0]){echo $cp_BS5val['equal'][0];}else{ echo "0";} ?>' size='4' <?php if(!$cp_BS5group){ echo "disabled='disabled'"; } ?>/>
		</span>
		<span id='BS5op_span_greater' <?php if($cp_BS5op && strcmp($cp_BS5op,"greater")){ echo "class='unselected'"; }else{ echo "class='selected'"; } ?>>
		<input type='text' name='BS5val[greater][0]' id='BS5op_greater' value='<?php if($cp_BS5val['greater'][0]){echo $cp_BS5val['greater'][0];}else{ echo "0";} ?>' size='4' <?php if(!$cp_BS5group){ echo "disabled='disabled'"; } ?>/>
		</span>
		<span id='BS5op_span_less' <?php if(strcmp($cp_BS5op,"less")){ echo "class='unselected'"; }else{ echo "class='selected'"; } ?>>
		<input type='text' name='BS5val[less][0]' id='BS5op_less' value='<?php if($cp_BS5val['less'][0]){echo $cp_BS5val['less'][0];}else{ echo "0";} ?>' size='4' <?php if(!$cp_BS5group){ echo "disabled='disabled'"; } ?>/>
		</span>
		nucleotides long.
		</p>
		</li>
		<li><input type='checkbox' name='BS3group' value='<?php if($cp_BS3group){ echo "1"; }else{ echo "0"; } ?>' onchange='BSenable("BS3op",this);' <?php if($cp_BS3group){ echo "checked='checked'"; } ?> />Filter by downstream (3&apos;) boundary support
		<p class='AIcustom'>Select 3&apos; boundaries with supported extensions
		<select name='BS3op' id='BS3op' onchange='BSopSelect("BS3op_",this.value);' <?php if(!$cp_BS3group){ echo "disabled='disabled'"; } ?>>
			<option value='between' <?php if((!$cp_BS3op)||($cp_BS3op === 'between')){ echo "selected='selected'"; } ?>>between</option>
			<option value='equal' <?php if($cp_BS3op === 'equal'){ echo "selected='selected'"; } ?>>equal to</option>
			<option value='greater' <?php if($cp_BS3op === 'greater'){ echo "selected='selected'"; } ?>>greater than</option>
			<option value='less' <?php if($cp_BS3op === 'less'){ echo "selected='selected'"; } ?>>less than</option>
		</select>
		<span id='BS3op_span_between' <?php if($cp_BS3op && strcmp($cp_BS3op,"between")){ echo "class='unselected'"; }else{ echo "class='selected'"; } ?>>
		<input type='text' name='BS3val[between][0]' id='BS3op_between_0' value='<?php if($cp_BS3val['between'][0]){echo $cp_BS3val['between'][0];}else{ echo "0";} ?>' size='4' <?php if(!$cp_BS3group){ echo "disabled='disabled'"; } ?>/> and 
		<input type='text' name='BS3val[between][1]' id='BS3op_between_1' value='<?php if($cp_BS3val['between'][1]){echo $cp_BS3val['between'][1];}else{ echo "1000";} ?>' size='4' <?php if(!$cp_BS3group){ echo "disabled='disabled'"; } ?>/>
		</span>
		<span id='BS3op_span_equal' <?php if(strcmp($cp_BS3op,"equal")){ echo "class='unselected'"; }else{ echo "class='selected'"; } ?>>
		<input type='text' name='BS3val[equal][0]' id='BS3op_equal' value='<?php if($cp_BS3val['equal'][0]){echo $cp_BS3val['equal'][0];}else{ echo "0";} ?>' size='4' <?php if(!$cp_BS3group){ echo "disabled='disabled'"; } ?>/>
		</span>
		<span id='BS3op_span_greater' <?php if(strcmp($cp_BS3op,"greater")){ echo "class='unselected'"; }else{ echo "class='selected'"; } ?>>
		<input type='text' name='BS3val[greater][0]' id='BS3op_greater' value='<?php if($cp_BS3val['greater'][0]){echo $cp_BS3val['greater'][0];}else{ echo "0";} ?>' size='4' <?php if(!$cp_BS3group){ echo "disabled='disabled'"; } ?>/>
		</span>
		<span id='BS3op_span_less' <?php if(strcmp($cp_BS3op,"less")){ echo "class='unselected'"; }else{ echo "class='selected'"; } ?>>
		<input type='text' name='BS3val[less][0]' id='BS3op_less' value='<?php if($cp_BS3val['less'][0]){echo $cp_BS3val['less'][0];}else{ echo "0";} ?>' size='4' <?php if(!$cp_BS3group){ echo "disabled='disabled'"; } ?>/>
		</span>
		nucleotides long.
		</p>
		</li>
		</ul>
		</li>

		<li><img src='<?php echo $IMAGEDIR; ?>GDBmenuArrow2.png' class='menubutton' id='APclosed' alt='(Expand)' onclick='openMENU("AP");' />
		<img src='<?php echo $IMAGEDIR; ?>GDBmenuArrow.png' class='menubutton' id='APopen' alt='(Collapse)' onclick='closeMENU("AP");' />Annotation Property Filter
		<ul class='APgroup' id='APoptions'>
		<li><input type='checkbox' name='APIgroup' value='<?php if($cp_APIgroup){ echo "1"; }else{ echo "0"; } ?>' onchange='BSenable("APIop",this);' <?php if($cp_APIgroup){ echo "checked='checked'"; } ?> />Filter by the number of annotated introns
		<p class='AIcustom'>Select annotations with
		<select name='APIop' id='APIop' onchange='BSopSelect("APIop_",this.value);' <?php if(!$cp_APIgroup){ echo "disabled='disabled'"; } ?>>
			<option value='between' <?php if($cp_APIop === 'between'){ echo "selected='selected'"; } ?>>between</option>
			<option value='equal' <?php if((!$cp_APIop)||($cp_APIop === 'equal')){ echo "selected='selected'"; } ?>>exactly</option>
			<option value='greater' <?php if($cp_APIop === 'greater'){ echo "selected='selected'"; } ?>>greater than</option>
			<option value='less' <?php if($cp_APIop === 'less'){ echo "selected='selected'"; } ?>>less than</option>
		</select>
		<span id='APIop_span_between' <?php if(strcmp($cp_APIop,"between")){ echo "class='unselected'"; }else{ echo "class='selected'"; } ?>>
		<input type='text' name='APIval[between][0]' id='APIop_between_0' value='<?php if($cp_APIval['between'][0]){echo $cp_APIval['between'][0];}else{ echo "0";} ?>' size='4' <?php if(!$cp_APIgroup){ echo "disabled='disabled'"; } ?>/> and 
		<input type='text' name='APIval[between][1]' id='APIop_between_1' value='<?php if($cp_APIval['between'][1]){echo $cp_APIval['between'][1];}else{ echo "1000";} ?>' size='4' <?php if(!$cp_APIgroup){ echo "disabled='disabled'"; } ?>/>
		</span>
		<span id='APIop_span_equal' <?php if($cp_APIop && strcmp($cp_APIop,"equal")){ echo "class='unselected'"; }else{ echo "class='selected'"; } ?>>
		<input type='text' name='APIval[equal][0]' id='APIop_equal' value='<?php if($cp_APIval['equal'][0]){echo $cp_APIval['equal'][0];}else{ echo "0";} ?>' size='4' <?php if(!$cp_APIgroup){ echo "disabled='disabled'"; } ?>/>
		</span>
		<span id='APIop_span_greater' <?php if(strcmp($cp_APIop,"greater")){ echo "class='unselected'"; }else{ echo "class='selected'"; } ?>>
		<input type='text' name='APIval[greater][0]' id='APIop_greater' value='<?php if($cp_APIval['greater'][0]){echo $cp_APIval['greater'][0];}else{ echo "0";} ?>' size='4' <?php if(!$cp_APIgroup){ echo "disabled='disabled'"; } ?>/>
		</span>
		<span id='APIop_span_less' <?php if(strcmp($cp_APIop,"less")){ echo "class='unselected'"; }else{ echo "class='selected'"; } ?>>
		<input type='text' name='APIval[less][0]' id='APIop_less' value='<?php if($cp_APIval['less'][0]){echo $cp_APIval['less'][0];}else{ echo "0";} ?>' size='4' <?php if(!$cp_APIgroup){ echo "disabled='disabled'"; } ?>/>
		</span>
		introns.
		</p>
		</li>

		<li><input type='checkbox' name='AP5group' value='<?php if($cp_AP5group){ echo "1"; }else{ echo "0"; } ?>' onchange='BSenable("AP5op",this);' <?php if($cp_AP5group){ echo "checked='checked'"; } ?> />Filter by the length of the annotated 5&apos;UTR
		<p class='AIcustom'>Select annotations with 5&apos;UTRs
		<select name='AP5op' id='AP5op' onchange='BSopSelect("AP5op_",this.value);' <?php if(!$cp_AP5group){ echo "disabled='disabled'"; } ?>>
			<option value='between' <?php if($cp_AP5op === 'between'){ echo "selected='selected'"; } ?>>between</option>
			<option value='equal' <?php if($cp_AP5op === 'equal'){ echo "selected='selected'"; } ?>>exactly</option>
			<option value='greater' <?php if((!$cp_AP5op)||($cp_AP5op === 'greater')){ echo "selected='selected'"; } ?>>greater than</option>
			<option value='less' <?php if($cp_AP5op === 'less'){ echo "selected='selected'"; } ?>>less than</option>
		</select>
		<span id='AP5op_span_between' <?php if(strcmp($cp_AP5op,"between")){ echo "class='unselected'"; }else{ echo "class='selected'"; } ?>>
		<input type='text' name='AP5val[between][0]' id='AP5op_between_0' value='<?php if($cp_AP5val['between'][0]){echo $cp_AP5val['between'][0];}else{ echo "0";} ?>' size='4' <?php if(!$cp_AP5group){ echo "disabled='disabled'"; } ?>/> and 
		<input type='text' name='AP5val[between][1]' id='AP5op_between_1' value='<?php if($cp_AP5val['between'][1]){echo $cp_AP5val['between'][1];}else{ echo "1000";} ?>' size='4' <?php if(!$cp_AP5group){ echo "disabled='disabled'"; } ?>/>
		</span>
		<span id='AP5op_span_equal' <?php if(strcmp($cp_AP5op,"equal")){ echo "class='unselected'"; }else{ echo "class='selected'"; } ?>>
		<input type='text' name='AP5val[equal][0]' id='AP5op_equal' value='<?php if($cp_AP5val['equal'][0]){echo $cp_AP5val['equal'][0];}else{ echo "0";} ?>' size='4' <?php if(!$cp_AP5group){ echo "disabled='disabled'"; } ?>/>
		</span>
		<span id='AP5op_span_greater' <?php if($cp_AP5op && strcmp($cp_AP5op,"greater")){ echo "class='unselected'"; }else{ echo "class='selected'"; } ?>>
		<input type='text' name='AP5val[greater][0]' id='AP5op_greater' value='<?php if($cp_AP5val['greater'][0]){echo $cp_AP5val['greater'][0];}else{ echo "0";} ?>' size='4' <?php if(!$cp_AP5group){ echo "disabled='disabled'"; } ?>/>
		</span>
		<span id='AP5op_span_less' <?php if(strcmp($cp_AP5op,"less")){ echo "class='unselected'"; }else{ echo "class='selected'"; } ?>>
		<input type='text' name='AP5val[less][0]' id='AP5op_less' value='<?php if($cp_AP5val['less'][0]){echo $cp_AP5val['less'][0];}else{ echo "0";} ?>' size='4' <?php if(!$cp_AP5group){ echo "disabled='disabled'"; } ?>/>
		</span>
		nucleotides long.
		</p>
		</li>
		
		<li><input type='checkbox' name='APCgroup' value='<?php if($cp_APCgroup){ echo "1"; }else{ echo "0"; } ?>' onchange='BSenable("APCop",this);' <?php if($cp_APCgroup){ echo "checked='checked'"; } ?> />Filter by the length of the annotated CDS
		<p class='AIcustom'>Select annotations with CDSs
		<select name='APCop' id='APCop' onchange='BSopSelect("APCop_",this.value);' <?php if(!$cp_APCgroup){ echo "disabled='disabled'"; } ?>>
			<option value='between' <?php if($cp_APCop === 'between'){ echo "selected='selected'"; } ?>>between</option>
			<option value='equal' <?php if($cp_APCop === 'equal'){ echo "selected='selected'"; } ?>>exactly</option>
			<option value='greater' <?php if((!$cp_APCop)||($cp_APCop === 'greater')){ echo "selected='selected'"; } ?>>greater than</option>
			<option value='less' <?php if($cp_APCop === 'less'){ echo "selected='selected'"; } ?>>less than</option>
		</select>
		<span id='APCop_span_between' <?php if(strcmp($cp_APCop,"between")){ echo "class='unselected'"; }else{ echo "class='selected'"; } ?>>
		<input type='text' name='APCval[between][0]' id='APCop_between_0' value='<?php if($cp_APCval['between'][0]){echo $cp_APCval['between'][0];}else{ echo "0";} ?>' size='4' <?php if(!$cp_APCgroup){ echo "disabled='disabled'"; } ?>/> and 
		<input type='text' name='APCval[between][1]' id='APCop_between_1' value='<?php if($cp_APCval['between'][1]){echo $cp_APCval['between'][1];}else{ echo "1000";} ?>' size='4' <?php if(!$cp_APCgroup){ echo "disabled='disabled'"; } ?>/>
		</span>
		<span id='APCop_span_equal' <?php if(strcmp($cp_APCop,"equal")){ echo "class='unselected'"; }else{ echo "class='selected'"; } ?>>
		<input type='text' name='APCval[equal][0]' id='APCop_equal' value='<?php if($cp_APCval['equal'][0]){echo $cp_APCval['equal'][0];}else{ echo "0";} ?>' size='4' <?php if(!$cp_APCgroup){ echo "disabled='disabled'"; } ?>/>
		</span>
		<span id='APCop_span_greater' <?php if($cp_APCop && strcmp($cp_APCop,"greater")){ echo "class='unselected'"; }else{ echo "class='selected'"; } ?>>
		<input type='text' name='APCval[greater][0]' id='APCop_greater' value='<?php if($cp_APCval['greater'][0]){echo $cp_APCval['greater'][0];}else{ echo "0";} ?>' size='4' <?php if(!$cp_APCgroup){ echo "disabled='disabled'"; } ?>/>
		</span>
		<span id='APCop_span_less' <?php if(strcmp($cp_APCop,"less")){ echo "class='unselected'"; }else{ echo "class='selected'"; } ?>>
		<input type='text' name='APCval[less][0]' id='APCop_less' value='<?php if($cp_APCval['less'][0]){echo $cp_APCval['less'][0];}else{ echo "0";} ?>' size='4' <?php if(!$cp_APCgroup){ echo "disabled='disabled'"; } ?>/>
		</span>
		nucleotides long.
		</p>
		</li>
		
		<li><input type='checkbox' name='AP3group' value='<?php if($cp_AP3group){ echo "1"; }else{ echo "0"; } ?>' onchange='BSenable("AP3op",this);' <?php if($cp_AP3group){ echo "checked='checked'"; } ?> />Filter by the length of the annotated 3&apos;UTR
		<p class='AIcustom'>Select annotations with 3&apos;UTRs
		<select name='AP3op' id='AP3op' onchange='BSopSelect("AP3op_",this.value);' <?php if(!$cp_AP3group){ echo "disabled='disabled'"; } ?>>
			<option value='between' <?php if($cp_AP3op === 'between'){ echo "selected='selected'"; } ?>>between</option>
			<option value='equal' <?php if($cp_AP3op === 'equal'){ echo "selected='selected'"; } ?>>exactly</option>
			<option value='greater' <?php if((!$cp_AP3op)||($cp_AP3op === 'greater')){ echo "selected='selected'"; } ?>>greater than</option>
			<option value='less' <?php if($cp_AP3op === 'less'){ echo "selected='selected'"; } ?>>less than</option>
		</select>
		<span id='AP3op_span_between' <?php if(strcmp($cp_AP3op,"between")){ echo "class='unselected'"; }else{ echo "class='selected'"; } ?>>
		<input type='text' name='AP3val[between][0]' id='AP3op_between_0' value='<?php if($cp_AP3val['between'][0]){echo $cp_AP3val['between'][0];}else{ echo "0";} ?>' size='4' <?php if(!$cp_AP3group){ echo "disabled='disabled'"; } ?>/> and 
		<input type='text' name='AP3val[between][1]' id='AP3op_between_1' value='<?php if($cp_AP3val['between'][1]){echo $cp_AP3val['between'][1];}else{ echo "1000";} ?>' size='4' <?php if(!$cp_AP3group){ echo "disabled='disabled'"; } ?>/>
		</span>
		<span id='AP3op_span_equal' <?php if(strcmp($cp_AP3op,"equal")){ echo "class='unselected'"; }else{ echo "class='selected'"; } ?>>
		<input type='text' name='AP3val[equal][0]' id='AP3op_equal' value='<?php if($cp_AP3val['equal'][0]){echo $cp_AP3val['equal'][0];}else{ echo "0";} ?>' size='4' <?php if(!$cp_AP3group){ echo "disabled='disabled'"; } ?>/>
		</span>
		<span id='AP3op_span_greater' <?php if($cp_AP3op && strcmp($cp_AP3op,"greater")){ echo "class='unselected'"; }else{ echo "class='selected'"; } ?>>
		<input type='text' name='AP3val[greater][0]' id='AP3op_greater' value='<?php if($cp_AP3val['greater'][0]){echo $cp_AP3val['greater'][0];}else{ echo "0";} ?>' size='4' <?php if(!$cp_AP3group){ echo "disabled='disabled'"; } ?>/>
		</span>
		<span id='AP3op_span_less' <?php if(strcmp($cp_AP3op,"less")){ echo "class='unselected'"; }else{ echo "class='selected'"; } ?>>
		<input type='text' name='AP3val[less][0]' id='AP3op_less' value='<?php if($cp_AP3val['less'][0]){echo $cp_AP3val['less'][0];}else{ echo "0";} ?>' size='4' <?php if(!$cp_AP3group){ echo "disabled='disabled'"; } ?>/>
		</span>
		nucleotides long.
		</p>
		</li>
		
		<li><input type='checkbox' name='APTgroup' value='<?php if($cp_APTgroup){ echo "1"; }else{ echo "0"; } ?>' onchange='BSenable("APTop",this);' <?php if($cp_APTgroup){ echo "checked='checked'"; } ?> />Filter by the total spliced length of the annotated gene
		<p class='AIcustom'>Select annotations with spliced lengths
		<select name='APTop' id='APTop' onchange='BSopSelect("APTop_",this.value);' <?php if(!$cp_APTgroup){ echo "disabled='disabled'"; } ?>>
		<option value='between' <?php if($cp_APTop === 'between'){ echo "selected='selected'"; } ?>>between</option>
		<option value='equal' <?php if($cp_APTop === 'equal'){ echo "selected='selected'"; } ?>>exactly</option>
		<option value='greater' <?php if((!$cp_APTop)||($cp_APTop === 'greater')){ echo "selected='selected'"; } ?>>greater than</option>
		<option value='less' <?php if($cp_APTop === 'less'){ echo "selected='selected'"; } ?>>less than</option>
		</select>
		<span id='APTop_span_between' <?php if(strcmp($cp_APTop,"between")){ echo "class='unselected'"; }else{ echo "class='selected'"; } ?>>
		<input type='text' name='APTval[between][0]' id='APTop_between_0' value='<?php if($cp_APTval['between'][0]){echo $cp_APTval['between'][0];}else{ echo "0";} ?>' size='4' <?php if(!$cp_APTgroup){ echo "disabled='disabled'"; } ?>/> and 
		<input type='text' name='APTval[between][1]' id='APTop_between_1' value='<?php if($cp_APTval['between'][1]){echo $cp_APTval['between'][1];}else{ echo "1000";} ?>' size='4' <?php if(!$cp_APTgroup){ echo "disabled='disabled'"; } ?>/>
		</span>
		<span id='APTop_span_equal' <?php if(strcmp($cp_APTop,"equal")){ echo "class='unselected'"; }else{ echo "class='selected'"; } ?>>
		<input type='text' name='APTval[equal][0]' id='APTop_equal' value='<?php if($cp_APTval['equal'][0]){echo $cp_APTval['equal'][0];}else{ echo "0";} ?>' size='4' <?php if(!$cp_APTgroup){ echo "disabled='disabled'"; } ?>/>
		</span>
		<span id='APTop_span_greater' <?php if($cp_APTop && strcmp($cp_APTop,"greater")){ echo "class='unselected'"; }else{ echo "class='selected'"; } ?>>
		<input type='text' name='APTval[greater][0]' id='APTop_greater' value='<?php if($cp_APTval['greater'][0]){echo $cp_APTval['greater'][0];}else{ echo "0";} ?>' size='4' <?php if(!$cp_APTgroup){ echo "disabled='disabled'"; } ?>/>
		</span>
		<span id='APTop_span_less' <?php if(strcmp($cp_APTop,"less")){ echo "class='unselected'"; }else{ echo "class='selected'"; } ?>>
		<input type='text' name='APTval[less][0]' id='APTop_less' value='<?php if($cp_APTval['less'][0]){echo $cp_APTval['less'][0];}else{ echo "0";} ?>' size='4' <?php if(!$cp_APTgroup){ echo "disabled='disabled'"; } ?>/>
		</span>
		nucleotides long.
		</p>
		</li>

		</ul>
		</li>

		<li><img src='<?php echo $IMAGEDIR; ?>GDBmenuArrow2.png' class='menubutton' id='INCclosed' alt='(Expand)' onclick='openMENU("INC");' />
			<img src='<?php echo $IMAGEDIR; ?>GDBmenuArrow.png' class='menubutton' id='INCopen' alt='(Collapse)' onclick='closeMENU("INC");' />Annotation Incongruence Filter
			<ul class='INCgroup' id='INCoptions'>
			<?php
				foreach(array_keys($DEFAULT_INC) as $inc){
				if(!$cp_INC_FILTER || !array_key_exists($inc,$cp_INC_FILTER)){
					$cp_INC_FILTER[$inc] = ''; //UNCHECKED
					$LIclass = 'unselected';
				}else{
					$LIclass = 'selected';
				}
				echo "<li id='LI_${inc}' class='${LIclass}'>\n";
				echo "<input type='checkbox' name='INC_FILTER[${inc}]' value='CHECKED' onchange='toggleSELECT(\"LI_${inc}\");' $cp_INC_FILTER[$inc] /> $DEFAULT_INC[$inc] \n";
				echo "<p class='INCoptions'>Show ONLY the following types:</p>\n";
				echo "<table class='INCoptions'><tr>\n";
				for($x=0;$x<count($FLAG_TYPES);$x++){
					if($cp_INCTYPES[$inc]){
					$isChecked = ($cp_INCTYPES[$inc][$x])?"checked='checked'":""; //UNCHECKED
					}else{
					$isChecked = "checked='checked'";
					}
					echo "<td><input type='checkbox' name='INCTYPES[${inc}][${x}]' value='1' ${isChecked} /> $FLAG_TYPES[$x]</td>\n";
					if(($x==1)||($x==3)||($x==5)){ echo "</tr><tr>\n"; }
				}
				echo "</tr></table></li>\n";
				}
				?>
			</ul>
		</li>
		</ul>
		
		<p class="bottommargin2 topmargin2 largerfont">
            <input type='submit' class='largerfont' name='GAEVALsearch' style='background:lightgreen' value="Retrieve annotations" />
                    from annotation source
                <select class='largerfont' name='ANNsrc'>
                    <?php
                    foreach($GAEVAL_SOURCES as $srcID => $src){
                     $GAEVAL_TBLS = explode(":",$src);
                     $bckgd_color= $GAEVAL_TBLS[5]; // last item in GAEVALconf.php array colon-separated string.
                     $select = ($cp_ANNsrc == $src)?"selected='selected'":"";
                        echo "
                        <option style='background:${bckgd_color}; color:white' class='largerfont' value='${src}' $select>
                            ${srcID}
                        </option>
                        ";
                        }
                        ?>
                </select>
                <span class='pageDisplay' >&#91; Show 
                    <select class='pageDisplay' name='returnLIMIT' id='returnLIMIT'>
                        <?php
                        foreach(array(50,100,500,1000,5000) as $val){
                          $select = ($cp_returnLIMIT == $val)?"selected='selected'":"";
                          echo "<option value=\"$val\" $select>${val}</option>";
                        }
                        $select = ($cp_returnLIMIT == 0)?"selected='selected'":"";
                        echo "<option value=\"0\" $select>25</option>";
                        ?>
                </select> results per page &#93;
            </span>
		</p>

        <?php echo $gtable; ?>
		</div>
	</div><!-- end maincontents-->
</div><!-- end mainWLS-->


<?php
#require('SSI_GDBprep.php');
require('/xGDBvm/XGDB/phplib/SSI_GDBprep.php');
virtual("${CGIPATH}SSI_GDBgui.pl/STANDARD_FOOTER/" . $SSI_QUERYSTRING);
?>
