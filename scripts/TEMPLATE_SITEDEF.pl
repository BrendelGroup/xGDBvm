#!/usr/bin/perl
# added by jfd july 2013
if (-e "/xGDBvm/admin/https") {
    $rootPath = "https://$ENV{SERVER_NAME}/";
  } else {
    $rootPath = "http://$ENV{SERVER_NAME}/";
}

if( not defined($SITEDEF_H) )
{
  $SITEDEF_H = 1;
  ######################################################################################
  ##  TEMPLATE for /xGDBvm/data/GDBnnn/conf/SITEDEF.pl   Last update: 9 July 2013 #                                                   ##
  ######################################################################################
  #__PSERVER_USER_GDB__#
  #__DBNAME__#
  #__COMMONORGN__#
  #__LATINORGN__#

  $DB_HOST            = "localhost";
  $rootPATH           = ${rootPath};
  $sandbox_URL_prefix = "/";
  $sandbox_DIR_PATH   = "/xGDBvm/";
  
  # Binaries / Programs / Resources
  $BLAST       = "/usr/local/bin/legacy_blast.pl blastall";
  $FASTACMD    = "/usr/local/bin/blastdbcmd";
  
  # Web Paths
  $xGDB;
  $xGDB     = $pserver_usergdb;
  $GDBDIR   = "${sandbox_URL_prefix}data/${xGDB}/";
  $GDBhome  = "${GDBDIR}";
  $PRJPATH  = "";
  $TUTRPATH = "";
  
  $XGDBHTML   = "${sandbox_URL_prefix}XGDB/";
  $IMAGEDIR   = "${XGDBHTML}images/";
  $HTMLSTAT   = "${XGDBHTML}htmlExtra/";
  $GUIPATH    = "${IMAGEDIR}SDSgui/";
  $DOCDIR     = "/help/";
  $JSPATH     = "${sandbox_URL_prefix}XGDB/javascripts/";
  $CSSPATH    = "${sandbox_URL_prefix}XGDB/css/";
  $DIR        = "${sandbox_URL_prefix}tmp/${xGDB}/";
  $CGIPATHs   = "${sandbox_URL_prefix}${xGDB}/cgi-bin";
  $GSQwebpath = "${CGIPATHs}/GeneSeqer/index.cgi?GDBFlag=$pserver_usergdb";
  $GTHwebpath = "${CGIPATHs}/GenomeThreader.pl?GDB=$pserver_usergdb";
  $CGIPATH    = "${CGIPATHs}/";
  $ucaPATH    = "${sandbox_URL_prefix}yrGATE/${xGDB}/";
  
  
  # Absolute Paths
  $HELPDIR      = "${sandbox_DIR_PATH}XGDB/help/";
  $SERVERDIR    = "${sandbox_DIR_PATH}data/${xGDB}/";
  $TMPDIR       = "${sandbox_DIR_PATH}tmp/${xGDB}/";
  $DATADIR      = "/${sandbox_DIR_PATH}/data/${xGDB}/data/BLAST/";
  $CONFDIR      = "${SERVERDIR}conf/";
  $ABS_IMAGEDIR = "${sandbox_DIR_PATH}XGDB/images/";
  
  # Site specfic GUI resources
  $WEBMASTER         = "";
  $COMMONORGN        = $commonorgn;
  $COMMONORGN1       = $commonorgn;
  $COMMONORGN2       = $commonorgn;
  $LATINORGN         = $latinorgn;
  $SITENAME          = "${dbname}";
  $SITENAMEshort     = "$xGDB";
  $TOP_LEFT_LOGO     = "${IMAGEDIR}xGDB_logo.png";
  $defaultStyleSheet = "/XGDB/css/GDBstyle.css";
  
  # Default Database INFO
  $DB_USER      = "xgdbSELECT";
  $DB_PASSWORD  = "";
  # XxGDB Version INFO
  $DBver[0] =
  {
    DB              => "$xGDB",
    DBtag           => "${xGDB}",
    default_gseg_gi => "", 
    defaultL_pos    => "",
    defaultR_pos    => "",
    trackORD        => "0,1,2,3,4,5,6,7,8",
    trackVIS        => "1,1,1,1,1,1,1,1,1,1",
    ucaVIS          => "1,1,1,1,1,1,1,1,1,1",
    ucaORD          => "0,1,2,3,4,5,6,7,8",
    tracks          =>
    [
      {
        track_index     => 0,
        DSOname       => "BAC",
        trackname     => "${xGDB} - Scaffold",
        primaryColor  => "khaki",
        blast_db      => "${xGDB}scaffold",
        isGSEG        => 1,
        chrVIEWABLE   => 0,
        BACVIEWABLE   => 0
      },
      {
        track_index   => 1,
        DSOname       => "UCAann",
        trackname     => "${xGDB} - yrGATE Annotations",
        DB            => "$xGDB",
        DBhost        => "$DB_HOST",
        DBuser        => "yrgateUser",
        DBpass        => "",
        db_table      => "user_gene_annotation",
        yrGATE_dbver  => 0,
        gsegSRC       => "${xGDB}scaffold",
        primaryColor  => "green",
        chrVIEWABLE   => 1,
        BACVIEWABLE   => 1,
        colorHASH     =>
        {
                "Confirm"        => "LightGreen",
                "New Locus"      => "Aquamarine",
                "Delete"         => "Gainsboro",
                "Not Resolved"   => "DarkGray",
                "Extend or Trim" => "LimeGreen",
                "Improve"        => "Green",
                "Variant"        => "GreenYellow",
                NULL             => "grey"
        },
       },
      {
        track_index           => 2,
        DSOname               => "GBKgaeval",
        trackname             => "${xGDB} - Gene Models (from CpGAT)",
        primaryColor          => "fuchsia",
        gsegSRC               => "${xGDB}scaffold",
        db_table              => 'cpgat_gene_annotation',
        blast_db              => "${xGDB}CpGATtranslation",
        blast_db_peptide      => "${xGDB}CpGATtranslation",
        blast_db_nucleotide   => "${xGDB}CpGATtranscription",
        chrVIEWABLE           => 0,
        BACVIEWABLE           => 1,
        GAEVAL_ANN_TBL        => 'gseg_cpgat_gene_annotation',
        GAEVAL_ANNselect      => 'select uid,gene_structure,gseg_gi,l_pos,r_pos FROM gseg_cpgat_gene_annotation ORDER BY gseg_gi,l_pos,r_pos',
        GAEVAL_SUPPORT_TBL    => 'gseg_cpgat_gbk_gaeval',
        GAEVAL_PROPERTIES_TBL => 'gseg_cpgat_gbk_gaeval_properties',
        GAEVAL_FLAGS_TBL      => 'gseg_cpgat_gbk_gaeval_flags',
        GAEVAL_ANN_TABLES     =>
        [
          {
            ANN_TBL   => 'user_gene_annotation',
            ANN_conditional => "&&(dbName = '$xGDB')&&(status = 'ACCEPTED')",
            gsegID_conditional => "gseg_gi = ",
            ANNselect => 'select uid,geneId,gene_structure,l_pos,r_pos,strand from user_gene_annotation',
            dsn       => "DBI:mysql:$xGDB:localhost",
            dbPASS    => '',
            dbUSER    => 'yrgateUser'
          }
        ],
        GAEVAL_ISO_TABLES =>
        [
          {
            ISO_TBL         => 'gseg_cpgat_cdna_gaeval',
            PGS_TBL         => 'gseg_cdna_good_pgs',
            SEQ_TBL         => 'cdna',
            PGSselect       => 'select uid,pgs,gseg_gi,l_pos,r_pos,isCognate FROM gseg_cdna_good_pgs ORDER BY gseg_gi,l_pos,r_pos',
            TPS_conditional => "",
            RESID           => 5
          },
          {
            ISO_TBL         => 'gseg_cpgat_put_gaeval',
            PGS_TBL         => 'gseg_put_good_pgs',
            SEQ_TBL         => 'put',
            PGSselect       => 'select uid,pgs,gseg_gi,l_pos,r_pos,isCognate FROM gseg_put_good_pgs ORDER BY gseg_gi,l_pos,r_pos',
            TPS_conditional => "",
            RESID           => 7
          },
          {
            ISO_TBL         => 'gseg_cpgat_est_gaeval',
            PGS_TBL         => 'gseg_est_good_pgs',
            SEQ_TBL         => 'est',
            PGSselect       => 'select uid,pgs,gseg_gi,l_pos,r_pos,isCognate FROM gseg_est_good_pgs ORDER BY gseg_gi,l_pos,r_pos',
            _HAS_CLONEPAIRS => 1,
            RESID           => 6
          }
        ],
      },
      {
        track_index           => 3,
        DSOname               => "GBKgaeval",
        db_table              => 'gene_annotation',
        trackname             => "${xGDB} - Gene Models (from gff3)",
        blast_db              => "${xGDB}translation",
        blast_db_peptide      => "${xGDB}translation",
        blast_db_nucleotide   => "${xGDB}transcription",
        gsegSRC               => "${xGDB}scaffold",
        primaryColor          => "blue",
        chrVIEWABLE           => 0,
        BACVIEWABLE           => 1,
        GAEVAL_ANN_TBL        => 'gseg_gene_annotation',
        GAEVAL_ANNselect      => 'select uid,gene_structure,gseg_gi,l_pos,r_pos FROM gseg_gene_annotation ORDER BY gseg_gi,l_pos,r_pos',
        GAEVAL_SUPPORT_TBL    => 'gseg_gbk_gaeval',
        GAEVAL_PROPERTIES_TBL => 'gseg_gbk_gaeval_properties',
        GAEVAL_FLAGS_TBL      => 'gseg_gbk_gaeval_flags',
        GAEVAL_ANN_TABLES     =>
        [
          {
            ANN_TBL            => 'user_gene_annotation',
            ANN_conditional    => "&&(dbName = '$xGDB')&&(status = 'ACCEPTED')",
            gsegID_conditional => "gseg_gi = ",
            ANNselect          => 'select uid,geneId,gene_structure,l_pos,r_pos,strand from user_gene_annotation',
            dsn                => "DBI:mysql:$xGDB:localhost",
            dbPASS             => '',
            dbUSER             => 'yrgateUser'
          }
        ],
        GAEVAL_ISO_TABLES =>
        [
          {
            ISO_TBL         => 'gseg_cdna_gaeval',
            PGS_TBL         => 'gseg_cdna_good_pgs',
            SEQ_TBL         => 'cdna',
            PGSselect       => 'select uid,pgs,gseg_gi,l_pos,r_pos,isCognate FROM gseg_cdna_good_pgs ORDER BY gseg_gi,l_pos,r_pos',
            TPS_conditional => "",
            RESID           => 5
          },
          {
            ISO_TBL         => 'gseg_put_gaeval',
            PGS_TBL         => 'gseg_put_good_pgs',
            SEQ_TBL         => 'put',
            PGSselect       => 'select uid,pgs,gseg_gi,l_pos,r_pos,isCognate FROM gseg_put_good_pgs ORDER BY gseg_gi,l_pos,r_pos',
            TPS_conditional => "",
            RESID           => 7
          },
          {
            ISO_TBL         => 'gseg_est_gaeval',
            PGS_TBL         => 'gseg_est_good_pgs',
            SEQ_TBL         => 'est',
            PGSselect       => 'select uid,pgs,gseg_gi,l_pos,r_pos,isCognate FROM gseg_est_good_pgs ORDER BY gseg_gi,l_pos,r_pos',
            _HAS_CLONEPAIRS => 1,
            RESID           => 6
          }
        ],
      },
      {
        track_index    => 4,
        DSOname        => "PEPpgs",
        trackname      => "${xGDB} - Aligned Protein",
        blast_db       => "${xGDB}prot",
        gsegSRC        => "${xGDB}scaffold",
        primaryColor   => "black",
        secondaryColor => "black",
        chrVIEWABLE    => 0,
        BACVIEWABLE    => 1,
        db_table       => 'pep'
      },
      {
        track_index    => 5,
        DSOname        => "CDNApgs",
        trackname      => "${xGDB} - Aligned cDNA",
        blast_db       => "${xGDB}cdna",
        gsegSRC        => "${xGDB}scaffold",
        primaryColor   => "lightblue",
        secondaryColor => "grey",
        chrVIEWABLE    => 0,
        BACVIEWABLE    => 1,
        db_table       => 'cdna'
      },
      {
        track_index    => 6,
        DSOname        => "ESTpgs",
        trackname      => "${xGDB} - Aligned EST",
        blast_db       => "${xGDB}est",
        gsegSRC        => "${xGDB}scaffold",
        primaryColor   => "red",
        secondaryColor => "hotpink",
        LblColor_3i    => "blue",
        LblColor_5i    => "green",
        chrVIEWABLE    => 0,
        BACVIEWABLE    => 1,
        db_table       => 'est'
      },
      {
        track_index    => 7,
        DSOname        => "CDNApgs",
        trackname      => "${xGDB} - Aligned TSA", # PUT -> TSA
        blast_db       => "${xGDB}tsa",
        gsegSRC        => "${xGDB}scaffold",
        primaryColor   => "firebrick",
        secondaryColor => "indianred",
        chrVIEWABLE    => 0,
        BACVIEWABLE    => 1,
        db_table       => 'put'
      },
      {
        track_index    => 8,
        DSOname        => "PROBE",
        trackname      => "${xGDB} - N-Masked Region", # N-masked
        blast_db       => "${xGDB}mask",
        gsegSRC        => "${xGDB}scaffold",
        primaryColor   => "coral",
        secondaryColor => "grey",
        chrVIEWABLE    => 0,
        BACVIEWABLE    => 1,
        db_table       => 'mask'
      },      
    ],
  };

  $transcriptViewQueryNameFrameWidth = 350;
  #MISC info
  $GSEG_SRC="${xGDB}scaffold";
  %BLAST_DB =
  (
    "${xGDB}scaffold"   		 => [ 'nucleotide', "${DATADIR}${xGDB}gdna.fa" ],
    "${xGDB}scaffold_masked"   	 => [ 'nucleotide', "${DATADIR}${xGDB}rm.gdna.fa" ],
    "${xGDB}est"        		 => [ 'nucleotide', "${DATADIR}${xGDB}est.fa" ],
    "${xGDB}cdna"       		 => [ 'nucleotide', "${DATADIR}${xGDB}cdna.fa" ],
    "${xGDB}cds"        		 => [ 'nucleotide', "${DATADIR}${xGDB}cds.fa" ],
    "${xGDB}transcript" 		 => [ 'nucleotide', "${DATADIR}${xGDB}annot.mrna.fa" ],
    "${xGDB}translation"		 => [ 'peptide',    "${DATADIR}${xGDB}annot.pep.fa" ],
    "${xGDB}tsa"        		 => [ 'nucleotide', "${DATADIR}${xGDB}tsa.fa" ],
    "${xGDB}prot"          		 => [ 'peptide',    "${DATADIR}${xGDB}prot.fa" ],
    "${xGDB}mask"          		 => [ 'nucleotide',    "${DATADIR}${xGDB}mask.fa" ],
    "${xGDB}CpGATtranscript"    => [ 'nucleotide',    "${DATADIR}${xGDB}cpgat.mrna.fa" ],
    "${xGDB}CpGATtranslation"    => [ 'peptide',    "${DATADIR}${xGDB}cpgat.pep.fa" ],
    "${xGDB}CpGATrefprot"    => [ 'peptide',    "${DATADIR}${xGDB}cpgat.refprot.fa" ],
    "${xGDB}MaskingLibrary"    => [ 'nucleotide',    "${DATADIR}${xGDB}rmlibrary.fa" ],
  );
  
  %BLAST_DB_DESC =
  (
    "${xGDB}scaffold"    		=> "$commonorgn Genome segments",
    "${xGDB}scaffold_masked"   	=> "$commonorgn Genome segments (masked)",
    "${xGDB}est"         		=> "$commonorgn ESTs ",
    "${xGDB}cdna"        		=> "$commonorgn cDNAs ",
    "${xGDB}cds"         		=> "$commonorgn CDS ",
    "${xGDB}transcript"  		=> "$commonorgn Precomputed transcripts",
    "${xGDB}translation" 		=> "$commonorgn Precomputed translations",
    "${xGDB}tsa"         		=> "$commonorgn Transcript assemblies (TSA) ",
    "${xGDB}prot"            	=> "$commonorgn Related species proteins",
    "${xGDB}mask"            	=> "$commonorgn Genome masked regions",
   "${xGDB}CpGATtranscript"    	=> "$commonorgn CpGAT-computed transcripts",
   "${xGDB}CpGATtranslation"    => "$commonorgn CpGAT-computed translations",
   "${xGDB}CpGATrefprot"    	=> "$commonorgn CpGAT Reference proteins",
   "${xGDB}MaskingLibrary"    	=> "$commonorgn Repeat Mask sequence library",
  );


} ## END OF SITEDEF_H
