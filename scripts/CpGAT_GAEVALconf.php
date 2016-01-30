<?php
if(empty($SITEDEF_H)){require('SITEDEF.php');} //USE xGDB SITEDEF.php for setup variables

$GAEVAL_DB_NAME = $pserver_usergdb;; //From xGDB SITEDEF.php
$GAEVAL_DB_HOST = $DB_HOST;     //From xGDB SITEDEF.php
$GAEVAL_DB_USER = $DB_USER;     //From xGDB SITEDEF.php
$GAEVAL_DB_PASS = $DB_PASSWORD; //From xGDB SITEDEF.php
// FORMAT FOR GAEVAL_SOURCES =>> 'ANNOTATION_TABLE_NAME:GAEVAL_SUPPORT_TABLE_NAME:GAEVAL_PROPERTIES_TABLE_NAME:GAEVAL_FLAGS_TABLE_NAME:ANNOTATION_RESID'
// ANNOTATION_RESID = array index in SITEDEF.pl of Annotation track! 
$GAEVAL_SOURCES = array('CpGAT Models' => 'gseg_cpgat_gene_annotation:gseg_cpgat_gbk_gaeval:gseg_cpgat_gbk_gaeval_properties:gseg_cpgat_gbk_gaeval_flags:2');

$GAEVAL_IMG_AltStr  = "Flags/AltStr.png";
$GAEVAL_IMG_AltCPS  = "Flags/ATTgene.png";
$GAEVAL_IMG_Fission = "Flags/SplitGene.png";
$GAEVAL_IMG_Fusion  = "Flags/MergeGene.png";
$GAEVAL_IMG_AmbOlap = "Flags/AmbOlap.png";
$GAEVAL_IMG_Extend5 = "Flags/UTR5_add.png";
$GAEVAL_IMG_Extend3 = "Flags/UTR3_add.png";

$GAEVAL_IMG_PROP_undoc_docL_docU = "Flags/xlumark.png";
$GAEVAL_IMG_PROP_undoc_docL      = "Flags/xlmark.png";
$GAEVAL_IMG_PROP_undoc_docU      = "Flags/xumark.png";
$GAEVAL_IMG_PROP_undoc           = "Flags/xmark.png";
$GAEVAL_IMG_PROP_docL_docU       = "Flags/lumark.png";
$GAEVAL_IMG_PROP_docL            = "Flags/lmark.png";
$GAEVAL_IMG_PROP_docU            = "Flags/umark.png";
$GAEVAL_IMG_noProp               = "Flags/null.png";

?>
