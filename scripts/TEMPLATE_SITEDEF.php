<?php
if(empty($SITEDEF_H)){
  $SITEDEF_H = 1;
######################################################################################
##  TEMPLATE for /xGDBvm/data/GDBnnn/conf/SITEDEF.php  Last update: 9 July 2013 #                                                   ##
######################################################################################
#__PSERVER_USER_GDB__#
#__COMMONORGN__#
#__LATINORGN__#
include '/xGDBvm/XGDB/phplib/sitedef.php';
$PageTitle = $pserver_usergdb;
$xGDB = $pserver_usergdb;
$DB_HOST='localhost';
$LATINORGN = $latinorgn;
$sandbox_URL_prefix = "/";
$sandbox_DIR_PATH   = "/xGDBvm/";
$rootPATH = $sandbox_URL_prefix;
$CGIPATHs ="${sandbox_URL_prefix}$pserver_usergdb/cgi-bin";
$CGIPATH  ="${CGIPATHs}/";
$JSPATH   ="${sandbox_URL_prefix}XGDB/javascripts/";
$CSSPATH  ="${sandbox_URL_prefix}XGDB/css/";
$XGDBHTML ="${sandbox_URL_prefix}XGDB/";
$IMAGEDIR ="${XGDBHTML}images/";
$DATADIR = "${sandbox_URL_prefix}/data/$pserver_usergdb/data";

## Tracks (trackname, DSO, table)

## Default track information
## TYPE[index]: track name, table, DSO, color
## IF adding manual tracks, increment [index] and synchronize values with SITEDEF.pl  $DBver

$GENOME[0] = array('track' => "$xGDB Scaffold",
                 'table' => "gseg",
                 'DSO' => "BAC",
                 'color' => "khaki",
                 'display' => 1,
);
$MASK[0] = array('track' => "$xGDB Masked",
                 'table' => "mask",
                 'DSO' => "PROBE",
                 'color' => "coral",
                 'display' => 1,
);
$EST[0] = array('track' => "$xGDB Aligned EST",
                 'table' => "est",
                 'DSO' => "ESTpgs",
                 'color' => "red",
                 'display' => 1,
);
$CDNA[0] = array('track' => "$xGDB Aligned cDNA",
                 'table' => "cdna",
                 'DSO' => "CDNApgs",
                 'color' => "lightblue",
                 'display' => 1,
);
$TSA[0] = array('track' => "$xGDB Aligned TSA",
                 'table' => "put",
                 'DSO' => "CDNApgs",
                 'color' => "firebrick",
                 'display' => 1,
);
$PEP[0] = array('track' => "$xGDB Aligned Protein",
                 'table' => "pep",
                 'DSO' => "PEPpgs",
                 'color' => "black",
                 'display' => 1,
);
$GENE[0] = array('track' => "$xGDB Gene Models (from GFF3)",
                 'table' => "gene",
                 'locus_table' => "locus",
                 'DSO' => "GBKgaeval",
                 'color' => "blue",
                 'display' => 1,
);
$GENE[1] = array('track' => "$xGDB Gene Models (from CpGAT)",
                 'table' => "cpgat_gene",
                 'locus_table' => "cpgat_locus",
                 'DSO' => "GBKgaeval",
                 'color' => "magenta",
                 'display' => 1,
);


}

?>
