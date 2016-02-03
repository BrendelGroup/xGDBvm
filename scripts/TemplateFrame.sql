-- MySQL dump 10.13  Distrib 5.1.37, for pc-solaris2.10 (x86_64)
--
-- Host: localhost    Database: TmGDB_SFD
-- ------------------------------------------------------
-- Server version	5.1.37

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `cdna`
--

DROP TABLE IF EXISTS `cdna`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `cdna` (
  `gi` varchar(32) NOT NULL DEFAULT '',
  `acc` varchar(32) NOT NULL DEFAULT '',
  `clone` varchar(32) DEFAULT '',
  `locus` varchar(32) DEFAULT NULL,
  `version` tinyint(4) NOT NULL DEFAULT '0',
  `description` text,
  `seq` text NOT NULL,
  PRIMARY KEY (`gi`),
  KEY `cdna_accIND` (`acc`),
  KEY `cdnaINDclone` (`clone`),
  KEY `cdnaINDlocus` (`locus`),
  FULLTEXT KEY `cdnaFTdesc` (`description`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `est`
--

DROP TABLE IF EXISTS `est`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `est` (
  `gi` varchar(32) NOT NULL DEFAULT '',
  `acc` varchar(32) NOT NULL DEFAULT '',
  `clone` varchar(32) DEFAULT NULL,
  `locus` varchar(32) DEFAULT NULL,
  `version` tinyint(4) NOT NULL DEFAULT '0',
  `description` text,
  `seq` text NOT NULL,
  `type` enum('F','T','U') DEFAULT 'U',
  PRIMARY KEY (`gi`),
  KEY `est_accIND` (`acc`),
  KEY `estINDclone` (`clone`),
  KEY `estINDlocus` (`locus`),
  FULLTEXT KEY `estFTdesc` (`description`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gseg`
--

DROP TABLE IF EXISTS `gseg`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gseg` (
  `uid` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `gi` varchar(32) NOT NULL DEFAULT '',
  `acc` varchar(32) NOT NULL DEFAULT '',
  `locus` varchar(32) DEFAULT NULL,
  `version` tinyint(4) NOT NULL DEFAULT '0',
  `description` text,
  `seq` longtext NOT NULL,
  `clone` varchar(32) DEFAULT NULL,
  `chr` tinyint(4) DEFAULT NULL,
  `G_O` enum('+','-') DEFAULT NULL,
  `chr_lpos` bigint(20) DEFAULT NULL,
  `chr_rpos` bigint(20) DEFAULT NULL,
  `olap_lstart` bigint(20) DEFAULT NULL,
  `olap_rstop` bigint(20) DEFAULT NULL,
  PRIMARY KEY (`uid`),
  UNIQUE KEY `gi` (`gi`),
  KEY `gseg_accIND` (`acc`),
  KEY `cloneIND` (`clone`),
  KEY `gseg_chrIND` (`chr`),
  KEY `gseg_chrlposIND` (`chr_lpos`),
  KEY `gseg_chrrposIND` (`chr_rpos`),
  KEY `gsegINDlocus` (`locus`),
  FULLTEXT KEY `gsegFT_Desc` (`description`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gseg_cdna_good_pgs`
--

DROP TABLE IF EXISTS `gseg_cdna_good_pgs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gseg_cdna_good_pgs` (
  `uid` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `gi` varchar(32) NOT NULL DEFAULT '',
  `E_O` enum('+','-','?') NOT NULL DEFAULT '+',
  `sim` float NOT NULL DEFAULT '0',
  `mlength` int(10) unsigned NOT NULL DEFAULT '0',
  `cov` float NOT NULL DEFAULT '0',
  `gseg_gi` varchar(32) NOT NULL DEFAULT '',
  `G_O` enum('+','-','?') NOT NULL DEFAULT '+',
  `l_pos` int(10) unsigned NOT NULL DEFAULT '0',
  `r_pos` int(10) unsigned NOT NULL DEFAULT '0',
  `pgs` text NOT NULL,
  `pgs_lpos` int(10) unsigned NOT NULL DEFAULT '0',
  `pgs_rpos` int(10) unsigned NOT NULL DEFAULT '0',
  `gseg_gaps` blob NOT NULL,
  `pgs_gaps` blob NOT NULL,
  `isCognate` enum('True','False') NOT NULL DEFAULT 'True',
  `alias` varchar(32) DEFAULT NULL,
  `label` varchar(32) DEFAULT NULL,
  `mergeNOTE` text,
  PRIMARY KEY (`uid`),
  KEY `gsegINDX` (`gseg_gi`),
  KEY `giINDX` (`gi`),
  KEY `gcgpINDrpos` (`r_pos`),
  KEY `gcgpINDlpos` (`l_pos`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gseg_cdna_good_pgs_exons`
--

DROP TABLE IF EXISTS `gseg_cdna_good_pgs_exons`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gseg_cdna_good_pgs_exons` (
  `pgs_uid` int(10) unsigned NOT NULL DEFAULT '0',
  `num` int(10) unsigned NOT NULL DEFAULT '0',
  `gseg_start` bigint(20) unsigned NOT NULL DEFAULT '0',
  `gseg_stop` bigint(20) unsigned NOT NULL DEFAULT '0',
  `pgs_start` bigint(20) unsigned NOT NULL DEFAULT '0',
  `pgs_stop` bigint(20) unsigned NOT NULL DEFAULT '0',
  `score` float NOT NULL DEFAULT '0',
  KEY `gcgpeINDpn` (`pgs_uid`,`num`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gseg_cdna_good_pgs_introns`
--

DROP TABLE IF EXISTS `gseg_cdna_good_pgs_introns`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gseg_cdna_good_pgs_introns` (
  `pgs_uid` int(10) unsigned NOT NULL DEFAULT '0',
  `num` int(10) unsigned NOT NULL DEFAULT '0',
  `gseg_start` bigint(20) unsigned NOT NULL DEFAULT '0',
  `gseg_stop` bigint(20) unsigned NOT NULL DEFAULT '0',
  `Dscore` float NOT NULL DEFAULT '0',
  `Dsim` float NOT NULL DEFAULT '-1',
  `Ascore` float NOT NULL DEFAULT '0',
  `Asim` float NOT NULL DEFAULT '-1',
  PRIMARY KEY (`pgs_uid`,`num`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gseg_est_good_pgs`
--

DROP TABLE IF EXISTS `gseg_est_good_pgs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gseg_est_good_pgs` (
  `uid` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `gi` varchar(32) NOT NULL DEFAULT '',
  `E_O` enum('+','-','?') NOT NULL DEFAULT '+',
  `sim` float NOT NULL DEFAULT '0',
  `mlength` int(10) unsigned NOT NULL DEFAULT '0',
  `cov` float NOT NULL DEFAULT '0',
  `gseg_gi` varchar(32) NOT NULL DEFAULT '',
  `G_O` enum('+','-','?') NOT NULL DEFAULT '+',
  `l_pos` int(10) unsigned NOT NULL DEFAULT '0',
  `r_pos` int(10) unsigned NOT NULL DEFAULT '0',
  `pgs` text NOT NULL,
  `pgs_lpos` int(10) unsigned NOT NULL DEFAULT '0',
  `pgs_rpos` int(10) unsigned NOT NULL DEFAULT '0',
  `gseg_gaps` blob NOT NULL,
  `pgs_gaps` blob NOT NULL,
  `isCognate` enum('True','False') NOT NULL DEFAULT 'True',
  `pairUID` varchar(50) NOT NULL DEFAULT '',
  `mergeNOTE` text,
  PRIMARY KEY (`uid`),
  KEY `gpiC` (`gseg_gi`),
  KEY `giIND` (`gi`),
  KEY `gegpINDlpos` (`l_pos`),
  KEY `gegpINDrpos` (`r_pos`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gseg_est_good_pgs_exons`
--

DROP TABLE IF EXISTS `gseg_est_good_pgs_exons`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gseg_est_good_pgs_exons` (
  `pgs_uid` int(10) unsigned NOT NULL DEFAULT '0',
  `num` int(10) unsigned NOT NULL DEFAULT '0',
  `gseg_start` bigint(20) unsigned NOT NULL DEFAULT '0',
  `gseg_stop` bigint(20) unsigned NOT NULL DEFAULT '0',
  `pgs_start` bigint(20) unsigned NOT NULL DEFAULT '0',
  `pgs_stop` bigint(20) unsigned NOT NULL DEFAULT '0',
  `score` float NOT NULL DEFAULT '0',
  KEY `gegpeINDpn` (`pgs_uid`,`num`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gseg_est_good_pgs_introns`
--

DROP TABLE IF EXISTS `gseg_est_good_pgs_introns`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gseg_est_good_pgs_introns` (
  `pgs_uid` int(10) unsigned NOT NULL DEFAULT '0',
  `num` int(10) unsigned NOT NULL DEFAULT '0',
  `gseg_start` bigint(20) unsigned NOT NULL DEFAULT '0',
  `gseg_stop` bigint(20) unsigned NOT NULL DEFAULT '0',
  `Dscore` float NOT NULL DEFAULT '0',
  `Dsim` float NOT NULL DEFAULT '-1',
  `Ascore` float NOT NULL DEFAULT '0',
  `Asim` float NOT NULL DEFAULT '-1',
  PRIMARY KEY (`pgs_uid`,`num`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gseg_gene_annotation`
--

DROP TABLE IF EXISTS `gseg_gene_annotation`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gseg_gene_annotation` (
  `uid` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `gseg_gi` varchar(128) NOT NULL DEFAULT '',
  `geneId` varchar(128) NOT NULL DEFAULT '',
  `strand` enum('f','r') NOT NULL DEFAULT 'f',
  `l_pos` int(10) unsigned NOT NULL DEFAULT '0',
  `r_pos` int(10) unsigned NOT NULL DEFAULT '0',
  `gene_structure` text NOT NULL,
  `description` text,
  `note` text,
  `CDSstart` int(20) unsigned NOT NULL DEFAULT '0',
  `CDSstop` int(20) unsigned NOT NULL DEFAULT '0',
  `transcript_id` varchar(128) NOT NULL DEFAULT '',
  `locus_id` varchar(128) NOT NULL DEFAULT '',
  PRIMARY KEY (`uid`),
  KEY `ind1` (`geneId`),
  KEY `glftIND` (`l_pos`),
  KEY `grgtIND` (`r_pos`),
  KEY `ggaINDggi` (`gseg_gi`),
  FULLTEXT KEY `ggaFT_DescNote` (`description`,`note`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gseg_cpgat_gene_annotation`
--

DROP TABLE IF EXISTS `gseg_cpgat_gene_annotation`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gseg_cpgat_gene_annotation` (
  `uid` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `gseg_gi` varchar(128) NOT NULL DEFAULT '',
  `geneId` varchar(128) NOT NULL DEFAULT '',
  `strand` enum('f','r') NOT NULL DEFAULT 'f',
  `l_pos` int(10) unsigned NOT NULL DEFAULT '0',
  `r_pos` int(10) unsigned NOT NULL DEFAULT '0',
  `gene_structure` text NOT NULL,
  `description` text,
  `note` text,
  `CDSstart` int(20) unsigned NOT NULL DEFAULT '0',
  `CDSstop` int(20) unsigned NOT NULL DEFAULT '0',
  `transcript_id` varchar(128) NOT NULL DEFAULT '',
  `locus_id` varchar(128) NOT NULL DEFAULT '',
  PRIMARY KEY (`uid`),
  KEY `ind1` (`geneId`),
  KEY `glftIND` (`l_pos`),
  KEY `grgtIND` (`r_pos`),
  KEY `ggaINDggi` (`gseg_gi`),
  FULLTEXT KEY `ggaFT_DescNote` (`description`,`note`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gseg_pep_good_pgs`
--

DROP TABLE IF EXISTS `gseg_pep_good_pgs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gseg_pep_good_pgs` (
  `uid` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `gi` varchar(250) DEFAULT NULL,
  `E_O` enum('+','-','?') NOT NULL DEFAULT '+',
  `sim` float NOT NULL DEFAULT '0',
  `mlength` int(10) unsigned NOT NULL DEFAULT '0',
  `cov` float NOT NULL DEFAULT '0',
  `gseg_gi` varchar(32) NOT NULL DEFAULT '',
  `G_O` enum('+','-','?') NOT NULL DEFAULT '+',
  `l_pos` int(10) unsigned NOT NULL DEFAULT '0',
  `r_pos` int(10) unsigned NOT NULL DEFAULT '0',
  `pgs` text NOT NULL,
  `pgs_lpos` int(10) unsigned NOT NULL DEFAULT '0',
  `pgs_rpos` int(10) unsigned NOT NULL DEFAULT '0',
  `gseg_gaps` blob NOT NULL,
  `pgs_gaps` blob NOT NULL,
  `isCognate` enum('True','False') NOT NULL DEFAULT 'True',
  `alias` varchar(32) DEFAULT NULL,
  `label` varchar(32) DEFAULT NULL,
  `mergeNOTE` text,
  PRIMARY KEY (`uid`),
  KEY `gsegINDX` (`gseg_gi`),
  KEY `giINDX` (`gi`),
  KEY `gpepgpINDlpos` (`l_pos`),
  KEY `gpepgpINDrpos` (`r_pos`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gseg_pep_good_pgs_exons`
--

DROP TABLE IF EXISTS `gseg_pep_good_pgs_exons`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gseg_pep_good_pgs_exons` (
  `pgs_uid` int(10) unsigned NOT NULL DEFAULT '0',
  `num` int(10) unsigned NOT NULL DEFAULT '0',
  `gseg_start` bigint(20) unsigned NOT NULL DEFAULT '0',
  `gseg_stop` bigint(20) unsigned NOT NULL DEFAULT '0',
  `pgs_start` bigint(20) unsigned NOT NULL DEFAULT '0',
  `pgs_stop` bigint(20) unsigned NOT NULL DEFAULT '0',
  `score` float NOT NULL DEFAULT '0',
  KEY `gpepgpeINDpn` (`pgs_uid`,`num`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gseg_pep_good_pgs_introns`
--

DROP TABLE IF EXISTS `gseg_pep_good_pgs_introns`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gseg_pep_good_pgs_introns` (
  `pgs_uid` int(10) unsigned NOT NULL DEFAULT '0',
  `num` int(10) unsigned NOT NULL DEFAULT '0',
  `gseg_start` bigint(20) unsigned NOT NULL DEFAULT '0',
  `gseg_stop` bigint(20) unsigned NOT NULL DEFAULT '0',
  `Dscore` float NOT NULL DEFAULT '0',
  `Dsim` float NOT NULL DEFAULT '-1',
  `Ascore` float NOT NULL DEFAULT '0',
  `Asim` float NOT NULL DEFAULT '-1',
  PRIMARY KEY (`pgs_uid`,`num`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gseg_put_good_pgs`
--

DROP TABLE IF EXISTS `gseg_put_good_pgs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gseg_put_good_pgs` (
  `uid` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `gi` varchar(250) DEFAULT NULL,
  `E_O` enum('+','-','?') NOT NULL DEFAULT '+',
  `sim` float NOT NULL DEFAULT '0',
  `mlength` int(10) unsigned NOT NULL DEFAULT '0',
  `cov` float NOT NULL DEFAULT '0',
  `gseg_gi` varchar(32) NOT NULL DEFAULT '',
  `G_O` enum('+','-','?') NOT NULL DEFAULT '+',
  `l_pos` int(10) unsigned NOT NULL DEFAULT '0',
  `r_pos` int(10) unsigned NOT NULL DEFAULT '0',
  `pgs` text NOT NULL,
  `pgs_lpos` int(10) unsigned NOT NULL DEFAULT '0',
  `pgs_rpos` int(10) unsigned NOT NULL DEFAULT '0',
  `gseg_gaps` blob NOT NULL,
  `pgs_gaps` blob NOT NULL,
  `isCognate` enum('True','False') NOT NULL DEFAULT 'True',
  `pairUID` varchar(50) NOT NULL DEFAULT '',
  `mergeNOTE` text,
  PRIMARY KEY (`uid`),
  KEY `gpiC` (`gseg_gi`),
  KEY `giIND` (`gi`),
  KEY `gputgpINDlpos` (`l_pos`),
  KEY `gputgpINDrpos` (`r_pos`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gseg_put_good_pgs_exons`
--

DROP TABLE IF EXISTS `gseg_put_good_pgs_exons`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gseg_put_good_pgs_exons` (
  `pgs_uid` int(10) unsigned NOT NULL DEFAULT '0',
  `num` int(10) unsigned NOT NULL DEFAULT '0',
  `gseg_start` bigint(20) unsigned NOT NULL DEFAULT '0',
  `gseg_stop` bigint(20) unsigned NOT NULL DEFAULT '0',
  `pgs_start` bigint(20) unsigned NOT NULL DEFAULT '0',
  `pgs_stop` bigint(20) unsigned NOT NULL DEFAULT '0',
  `score` float NOT NULL DEFAULT '0',
  KEY `gputgpeINDpn` (`pgs_uid`,`num`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gseg_put_good_pgs_introns`
--

DROP TABLE IF EXISTS `gseg_put_good_pgs_introns`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gseg_put_good_pgs_introns` (
  `pgs_uid` int(10) unsigned NOT NULL DEFAULT '0',
  `num` int(10) unsigned NOT NULL DEFAULT '0',
  `gseg_start` bigint(20) unsigned NOT NULL DEFAULT '0',
  `gseg_stop` bigint(20) unsigned NOT NULL DEFAULT '0',
  `Dscore` float NOT NULL DEFAULT '0',
  `Dsim` float NOT NULL DEFAULT '-1',
  `Ascore` float NOT NULL DEFAULT '0',
  `Asim` float NOT NULL DEFAULT '-1',
  PRIMARY KEY (`pgs_uid`,`num`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `pep`
--

DROP TABLE IF EXISTS `pep`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `pep` (
  `gi` varchar(250) NOT NULL DEFAULT '',
  `acc` varchar(32) NOT NULL DEFAULT '',
  `clone` varchar(32) DEFAULT '',
  `locus` varchar(32) DEFAULT NULL,
  `version` tinyint(4) NOT NULL DEFAULT '0',
  `description` text,
  `seq` text NOT NULL,
  PRIMARY KEY (`gi`),
  KEY `cdna_accIND` (`acc`),
  KEY `pepINDclone` (`clone`),
  KEY `pepINDlocus` (`locus`),
  FULLTEXT KEY `pepFT_Desc` (`description`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `put`
--

DROP TABLE IF EXISTS `put`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `put` (
  `gi` varchar(250) NOT NULL DEFAULT '',
  `acc` varchar(32) NOT NULL DEFAULT '',
  `clone` varchar(32) DEFAULT NULL,
  `locus` varchar(32) DEFAULT NULL,
  `version` tinyint(4) NOT NULL DEFAULT '0',
  `description` text,
  `seq` text NOT NULL,
  `type` enum('F','T','U') DEFAULT 'U',
  PRIMARY KEY (`gi`),
  KEY `est_accIND` (`acc`),
  KEY `putINDclone` (`clone`),
  KEY `putINDlocus` (`locus`),
  FULLTEXT KEY `putFT_Desc` (`description`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `refprot`
--

DROP TABLE IF EXISTS `refprot`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `refprot` (
  `gi` varchar(250) NOT NULL default '',
  `acc` varchar(32) NOT NULL default '',
  `clone` varchar(32) default '',
  `locus` varchar(32) default NULL,
  `version` tinyint(4) NOT NULL default '0',
  `description` text,
  `seq` text NOT NULL,
  PRIMARY KEY  (`gi`),
  FULLTEXT KEY `refprotFT_Desc` (`description`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `sessions`
--

DROP TABLE IF EXISTS `sessions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sessions` (
  `id` varchar(32) NOT NULL DEFAULT '',
  `a_session` text NOT NULL,
  UNIQUE KEY `id` (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `user_gene_annotation`
--

DROP TABLE IF EXISTS `user_gene_annotation`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_gene_annotation` (
  `uid` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `USERid` varchar(50) NOT NULL DEFAULT '',
  `geneId` varchar(100) DEFAULT NULL,
  `chr` varchar(100) DEFAULT NULL,
  `strand` enum('f','r') NOT NULL DEFAULT 'f',
  `l_pos` int(10) unsigned NOT NULL DEFAULT '0',
  `r_pos` int(10) unsigned NOT NULL DEFAULT '0',
  `gene_structure` text NOT NULL,
  `description` text,
  `comment` text,
  `CDSstart` int(20) unsigned DEFAULT NULL,
  `CDSstop` int(20) unsigned DEFAULT NULL,
  `proteinId` text,
  `geneAliases` text,
  `proteinAliases` text,
  `status` varchar(32) NOT NULL DEFAULT 'HOLD',
  `modDate` datetime DEFAULT NULL,
  `evidence` text,
  `underReview` datetime DEFAULT NULL,
  `annotation_type` varchar(20) DEFAULT NULL,
  `mRNAseq` text,
  `proteinseq` text,
  `GSeqEdits` text,
  `organism` varchar(32) DEFAULT NULL,
  `dbName` varchar(45) DEFAULT NULL,
  `dasCookie` text,
  `dbVer` varchar(20) DEFAULT NULL,
  `category` varchar(25) DEFAULT NULL,
  `working_group` varchar(25) DEFAULT NULL,
  `annotation_class` varchar(25) DEFAULT NULL,
  `locusId` varchar(128) DEFAULT NULL,
  `transcriptId` varchar(128) DEFAULT NULL,
  `rangeStart` int(10) unsigned NOT NULL DEFAULT '0',
  `rangeEnd` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `uniq_geneId` (`geneId`),
  KEY `key_locusId` (`locusId`),
  KEY `key_category` (`category`),
  KEY `key_status` (`status`),
  KEY `key_dbname` (`dbName`),
  KEY `key_annoclass` (`annotation_class`),
  KEY `key_transcriptId` (`transcriptId`),
  FULLTEXT KEY `ugaFT_DescComm` (`description`,`comment`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `user_gff_annotation`
--

DROP TABLE IF EXISTS `user_gff_annotation`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_gff_annotation` (
  `uid` int(10) unsigned NOT NULL auto_increment,
  `pid` int(10) unsigned NOT NULL default '0',
  `gseg_gi` varchar(128) NOT NULL DEFAULT '',
  `geneId` varchar(128) NOT NULL default '',
  `strand` enum('f','r') NOT NULL default 'f',
  `l_pos` int(10) unsigned NOT NULL default '0',
  `r_pos` int(10) unsigned NOT NULL default '0',
  `gene_structure` text NOT NULL,
  `description` text,
  `note` text,
  `CDSstart` int(20) unsigned NOT NULL default '0',
  `CDSstop` int(20) unsigned NOT NULL default '0',
  `transcript_id` varchar(128) NOT NULL default '',
  `glyph_style` varchar(32),
  PRIMARY KEY  (`uid`),
  KEY `ind1` (`geneId`),
  KEY `glftIND` (`l_pos`),
  KEY `grgtIND` (`r_pos`),
  FULLTEXT KEY `ggaFT_DescNote` (`description`,`note`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `projects`
--

DROP TABLE IF EXISTS `projects`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `projects` (
  `pid` int(10) unsigned NOT NULL auto_increment,
  `ppass` varchar(32) NOT NULL default '',
  `pname` varchar(32) NOT NULL default 'user GFF',
  PRIMARY KEY  (`pid`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `sessionprojects`
--

DROP TABLE IF EXISTS `sessionprojects`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sessionprojects` (
  `pid` int(10) unsigned NOT NULL default '0',
  `sessid` varchar(32) NOT NULL default '',
  `pname` varchar(32) NOT NULL default 'user GFF',
  UNIQUE KEY `spndx` (`sessid`,`pid`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `segments`
--

DROP TABLE IF EXISTS `segments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `segments` (
  `alias` varchar(32) NOT NULL default '',
  `xID` varchar(100) NOT NULL DEFAULT '',
  `start` int(32) NOT NULL default '1',
  `stop` int(32) NOT NULL default '-1',
  PRIMARY KEY  (`alias`),
  KEY `xid` (`xID`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Table structure for GAEVAL tables (12-19-2012)
--

DROP TABLE IF EXISTS `gseg_gbk_gaeval`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gseg_gbk_gaeval` (
  `uid` int(11) NOT NULL DEFAULT '0',
  `integrity` float unsigned DEFAULT NULL,
  `introns_confirmed` tinyint(3) unsigned NOT NULL DEFAULT '0',
  `introns_unsupported` tinyint(3) unsigned NOT NULL DEFAULT '0',
  `cds_size` int(11) NOT NULL DEFAULT '0',
  `utr5_size` int(11) NOT NULL DEFAULT '0',
  `utr3_size` int(11) NOT NULL DEFAULT '0',
  `bound_5prime` int(11) NOT NULL DEFAULT '0',
  `bound_3prime` int(11) NOT NULL DEFAULT '0',
  `exon_coverage` float unsigned NOT NULL DEFAULT '0',
  `BCBN_introns_confirmed` tinyint(3) unsigned NOT NULL DEFAULT '0',
  `BCBN_introns_unsupported` tinyint(3) unsigned NOT NULL DEFAULT '0',
  `BCBN_bound_5prime` int(11) NOT NULL DEFAULT '0',
  `BCBN_bound_3prime` int(11) NOT NULL DEFAULT '0',
  `BCBN_exon_coverage` float unsigned NOT NULL DEFAULT '0',
  `BCNC_introns_confirmed` tinyint(3) unsigned NOT NULL DEFAULT '0',
  `BCNC_introns_unsupported` tinyint(3) unsigned NOT NULL DEFAULT '0',
  `BCNC_bound_5prime` int(11) NOT NULL DEFAULT '0',
  `BCNC_bound_3prime` int(11) NOT NULL DEFAULT '0',
  `BCNC_exon_coverage` float unsigned NOT NULL DEFAULT '0',
  `BCNN_introns_confirmed` tinyint(3) unsigned NOT NULL DEFAULT '0',
  `BCNN_introns_unsupported` tinyint(3) unsigned NOT NULL DEFAULT '0',
  `BCNN_bound_5prime` int(11) NOT NULL DEFAULT '0',
  `BCNN_bound_3prime` int(11) NOT NULL DEFAULT '0',
  `BCNN_exon_coverage` float unsigned NOT NULL DEFAULT '0',
  UNIQUE KEY `uid` (`uid`),
  KEY `ec1` (`exon_coverage`),
  KEY `ec2` (`BCBN_exon_coverage`),
  KEY `ec3` (`BCNC_exon_coverage`),
  KEY `ec4` (`BCNN_exon_coverage`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

DROP TABLE IF EXISTS `gseg_gbk_gaeval_flags`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gseg_gbk_gaeval_flags` (
  `annUID` int(10) NOT NULL DEFAULT '0',
  `AE_AmbOverlap` int(10) unsigned NOT NULL DEFAULT '0',
  `AE_AmbOverlap_doc` int(10) NOT NULL DEFAULT '0',
  `AE_AmbOverlap_mindoc` int(10) NOT NULL DEFAULT '0',
  `AE_AmbOverlap_maxdoc` int(10) NOT NULL DEFAULT '0',
  `AS_AddIntron` int(10) unsigned NOT NULL DEFAULT '0',
  `AS_AddIntron_doc` int(10) NOT NULL DEFAULT '0',
  `AS_AddIntron_mindoc` int(10) NOT NULL DEFAULT '0',
  `AS_AddIntron_maxdoc` int(10) NOT NULL DEFAULT '0',
  `AS_AltAnnIntron` int(10) unsigned NOT NULL DEFAULT '0',
  `AS_AltAnnIntron_doc` int(10) NOT NULL DEFAULT '0',
  `AS_AltAnnIntron_mindoc` int(10) NOT NULL DEFAULT '0',
  `AS_AltAnnIntron_maxdoc` int(10) NOT NULL DEFAULT '0',
  `AS_AltIntron` int(10) unsigned NOT NULL DEFAULT '0',
  `AS_AltIntron_doc` int(10) NOT NULL DEFAULT '0',
  `AS_AltIntron_mindoc` int(10) NOT NULL DEFAULT '0',
  `AS_AltIntron_maxdoc` int(10) NOT NULL DEFAULT '0',
  `AS_ConIntron` int(10) unsigned NOT NULL DEFAULT '0',
  `AS_ConIntron_doc` int(10) NOT NULL DEFAULT '0',
  `AS_ConIntron_mindoc` int(10) NOT NULL DEFAULT '0',
  `AS_ConIntron_maxdoc` int(10) NOT NULL DEFAULT '0',
  `AS_PseudoIntron` int(10) unsigned NOT NULL DEFAULT '0',
  `AS_PseudoIntron_doc` int(10) NOT NULL DEFAULT '0',
  `AS_PseudoIntron_mindoc` int(10) NOT NULL DEFAULT '0',
  `AS_PseudoIntron_maxdoc` int(10) NOT NULL DEFAULT '0',
  `CM_AltCPS` int(10) unsigned NOT NULL DEFAULT '0',
  `CM_AltCPS_doc` int(10) NOT NULL DEFAULT '0',
  `CM_AltCPS_mindoc` int(10) NOT NULL DEFAULT '0',
  `CM_AltCPS_maxdoc` int(10) NOT NULL DEFAULT '0',
  `CM_Fission` int(10) unsigned NOT NULL DEFAULT '0',
  `CM_Fission_doc` int(10) NOT NULL DEFAULT '0',
  `CM_Fission_mindoc` int(10) NOT NULL DEFAULT '0',
  `CM_Fission_maxdoc` int(10) NOT NULL DEFAULT '0',
  `CM_Fusion` int(10) unsigned NOT NULL DEFAULT '0',
  `CM_Fusion_doc` int(10) NOT NULL DEFAULT '0',
  `CM_Fusion_mindoc` int(10) NOT NULL DEFAULT '0',
  `CM_Fusion_maxdoc` int(10) NOT NULL DEFAULT '0',
  `CM_MainCPS` int(10) unsigned NOT NULL DEFAULT '0',
  `CM_MainCPS_doc` int(10) NOT NULL DEFAULT '0',
  `CM_MainCPS_mindoc` int(10) NOT NULL DEFAULT '0',
  `CM_MainCPS_maxdoc` int(10) NOT NULL DEFAULT '0',
  KEY `auIND` (`annUID`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

DROP TABLE IF EXISTS `gseg_cpgat_gbk_gaeval`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gseg_cpgat_gbk_gaeval` (
  `uid` int(11) NOT NULL DEFAULT '0',
  `integrity` float unsigned DEFAULT NULL,
  `introns_confirmed` tinyint(3) unsigned NOT NULL DEFAULT '0',
  `introns_unsupported` tinyint(3) unsigned NOT NULL DEFAULT '0',
  `cds_size` int(11) NOT NULL DEFAULT '0',
  `utr5_size` int(11) NOT NULL DEFAULT '0',
  `utr3_size` int(11) NOT NULL DEFAULT '0',
  `bound_5prime` int(11) NOT NULL DEFAULT '0',
  `bound_3prime` int(11) NOT NULL DEFAULT '0',
  `exon_coverage` float unsigned NOT NULL DEFAULT '0',
  `BCBN_introns_confirmed` tinyint(3) unsigned NOT NULL DEFAULT '0',
  `BCBN_introns_unsupported` tinyint(3) unsigned NOT NULL DEFAULT '0',
  `BCBN_bound_5prime` int(11) NOT NULL DEFAULT '0',
  `BCBN_bound_3prime` int(11) NOT NULL DEFAULT '0',
  `BCBN_exon_coverage` float unsigned NOT NULL DEFAULT '0',
  `BCNC_introns_confirmed` tinyint(3) unsigned NOT NULL DEFAULT '0',
  `BCNC_introns_unsupported` tinyint(3) unsigned NOT NULL DEFAULT '0',
  `BCNC_bound_5prime` int(11) NOT NULL DEFAULT '0',
  `BCNC_bound_3prime` int(11) NOT NULL DEFAULT '0',
  `BCNC_exon_coverage` float unsigned NOT NULL DEFAULT '0',
  `BCNN_introns_confirmed` tinyint(3) unsigned NOT NULL DEFAULT '0',
  `BCNN_introns_unsupported` tinyint(3) unsigned NOT NULL DEFAULT '0',
  `BCNN_bound_5prime` int(11) NOT NULL DEFAULT '0',
  `BCNN_bound_3prime` int(11) NOT NULL DEFAULT '0',
  `BCNN_exon_coverage` float unsigned NOT NULL DEFAULT '0',
  UNIQUE KEY `uid` (`uid`),
  KEY `ec1` (`exon_coverage`),
  KEY `ec2` (`BCBN_exon_coverage`),
  KEY `ec3` (`BCNC_exon_coverage`),
  KEY `ec4` (`BCNN_exon_coverage`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

DROP TABLE IF EXISTS `gseg_cpgat_gbk_gaeval_flags`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gseg_cpgat_gbk_gaeval_flags` (
  `annUID` int(10) NOT NULL DEFAULT '0',
  `AE_AmbOverlap` int(10) unsigned NOT NULL DEFAULT '0',
  `AE_AmbOverlap_doc` int(10) NOT NULL DEFAULT '0',
  `AE_AmbOverlap_mindoc` int(10) NOT NULL DEFAULT '0',
  `AE_AmbOverlap_maxdoc` int(10) NOT NULL DEFAULT '0',
  `AS_AddIntron` int(10) unsigned NOT NULL DEFAULT '0',
  `AS_AddIntron_doc` int(10) NOT NULL DEFAULT '0',
  `AS_AddIntron_mindoc` int(10) NOT NULL DEFAULT '0',
  `AS_AddIntron_maxdoc` int(10) NOT NULL DEFAULT '0',
  `AS_AltAnnIntron` int(10) unsigned NOT NULL DEFAULT '0',
  `AS_AltAnnIntron_doc` int(10) NOT NULL DEFAULT '0',
  `AS_AltAnnIntron_mindoc` int(10) NOT NULL DEFAULT '0',
  `AS_AltAnnIntron_maxdoc` int(10) NOT NULL DEFAULT '0',
  `AS_AltIntron` int(10) unsigned NOT NULL DEFAULT '0',
  `AS_AltIntron_doc` int(10) NOT NULL DEFAULT '0',
  `AS_AltIntron_mindoc` int(10) NOT NULL DEFAULT '0',
  `AS_AltIntron_maxdoc` int(10) NOT NULL DEFAULT '0',
  `AS_ConIntron` int(10) unsigned NOT NULL DEFAULT '0',
  `AS_ConIntron_doc` int(10) NOT NULL DEFAULT '0',
  `AS_ConIntron_mindoc` int(10) NOT NULL DEFAULT '0',
  `AS_ConIntron_maxdoc` int(10) NOT NULL DEFAULT '0',
  `AS_PseudoIntron` int(10) unsigned NOT NULL DEFAULT '0',
  `AS_PseudoIntron_doc` int(10) NOT NULL DEFAULT '0',
  `AS_PseudoIntron_mindoc` int(10) NOT NULL DEFAULT '0',
  `AS_PseudoIntron_maxdoc` int(10) NOT NULL DEFAULT '0',
  `CM_AltCPS` int(10) unsigned NOT NULL DEFAULT '0',
  `CM_AltCPS_doc` int(10) NOT NULL DEFAULT '0',
  `CM_AltCPS_mindoc` int(10) NOT NULL DEFAULT '0',
  `CM_AltCPS_maxdoc` int(10) NOT NULL DEFAULT '0',
  `CM_Fission` int(10) unsigned NOT NULL DEFAULT '0',
  `CM_Fission_doc` int(10) NOT NULL DEFAULT '0',
  `CM_Fission_mindoc` int(10) NOT NULL DEFAULT '0',
  `CM_Fission_maxdoc` int(10) NOT NULL DEFAULT '0',
  `CM_Fusion` int(10) unsigned NOT NULL DEFAULT '0',
  `CM_Fusion_doc` int(10) NOT NULL DEFAULT '0',
  `CM_Fusion_mindoc` int(10) NOT NULL DEFAULT '0',
  `CM_Fusion_maxdoc` int(10) NOT NULL DEFAULT '0',
  `CM_MainCPS` int(10) unsigned NOT NULL DEFAULT '0',
  `CM_MainCPS_doc` int(10) NOT NULL DEFAULT '0',
  `CM_MainCPS_mindoc` int(10) NOT NULL DEFAULT '0',
  `CM_MainCPS_maxdoc` int(10) NOT NULL DEFAULT '0',
  KEY `auIND` (`annUID`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

DROP TABLE IF EXISTS `test`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `test` (
  `annUID` int(10) NOT NULL DEFAULT '0',
  `AE_AmbOverlap` int(10) unsigned NOT NULL DEFAULT '0',
  `AE_AmbOverlap_doc` int(10) NOT NULL DEFAULT '0',
  `AE_AmbOverlap_mindoc` int(10) NOT NULL DEFAULT '0',
  KEY `auIND` (`annUID`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

CREATE TABLE `mask` (
  `gi` varchar(250) NOT NULL DEFAULT '',
  `acc` varchar(150) DEFAULT NULL,
  `clone` varchar(32) DEFAULT NULL,
  `locus` varchar(32) DEFAULT NULL,
  `version` tinyint(4) DEFAULT NULL,
  `description` text,
  `seq` text NOT NULL,
  PRIMARY KEY (`gi`),
  KEY `maskINDacc` (`acc`),
  FULLTEXT KEY `maskFT_Desc` (`description`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

CREATE TABLE `gseg_mask_good_pgs` (
  `uid` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `gi` varchar(250) DEFAULT NULL,
  `gseg_gi` varchar(250) DEFAULT NULL,
  `E_O` enum('+','-','?') NOT NULL DEFAULT '+',
  `sim` float NOT NULL DEFAULT '0',
  `mlength` int(10) unsigned NOT NULL DEFAULT '0',
  `cov` float NOT NULL DEFAULT '0',
  `chr` int(10) NOT NULL DEFAULT '0',
  `G_O` enum('+','-','?') NOT NULL DEFAULT '+',
  `l_pos` int(10) unsigned NOT NULL DEFAULT '0',
  `r_pos` int(10) unsigned NOT NULL DEFAULT '0',
  `pgs` text NOT NULL,
  `pgs_lpos` int(10) unsigned NOT NULL DEFAULT '0',
  `pgs_rpos` int(10) unsigned NOT NULL DEFAULT '0',
  `gseg_gaps` blob NOT NULL,
  `pgs_gaps` blob NOT NULL,
  `isCognate` enum('True','False') NOT NULL DEFAULT 'True',
  `pairUID` varchar(50) NOT NULL DEFAULT '',
  PRIMARY KEY (`uid`),
  KEY `giIND` (`gi`),
  KEY `maskgpINDgseggi` (`gseg_gi`),
  KEY `maskgpINDlpos` (`l_pos`),
  KEY `maskgpINDrpos` (`r_pos`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;


/*!40101 SET character_set_client = @saved_cs_client */;

/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;
/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2011-06-27 10:49:14
-- Last edit 2011-12-12 JPD
