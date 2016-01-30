-- MySQL dump 10.13  Distrib 5.1.37, for pc-solaris2.10 (x86_64)
--
-- Host: sundisk1    Database: RcGDB179
-- ------------------------------------------------------
-- Server version	4.1.22-standard-log

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
-- Table structure for table `gseg_locus_annotation`
--

DROP TABLE IF EXISTS `gseg_locus_annotation`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gseg_locus_annotation` (
  `uid` int(10) unsigned NOT NULL auto_increment,
  `gseg_gi` varchar(128) NOT NULL default '',
  `locus_id` varchar(128) NOT NULL default '',
  `strand` enum('f','r') NOT NULL default 'f',
  `l_pos` int(10) unsigned NOT NULL default '0',
  `r_pos` int(10) unsigned NOT NULL default '0',
  `cds_status` varchar(32) default NULL,
  `genetic_locus` varchar(16) default NULL,
  `genetic_locus_desc` varchar(255) default NULL,
  `description` text,
  `transcript_ids` varchar(512) NOT NULL,
  `transcript_count` int(2) unsigned NOT NULL default '0',
  `intron_count` int(3) unsigned default NULL,
  `coverage` float unsigned default NULL,
  `integrity` float unsigned default NULL,
  `note` varchar(255) NOT NULL default '',
  PRIMARY KEY  (`uid`),
  KEY `gsegLAlocIND` (`locus_id`),
  KEY `gsegLAgsegIND` (`gseg_gi`),
  KEY `gsegLAlftIND` (`l_pos`),
  KEY `gsegLArgtIND` (`r_pos`),
  KEY `gsegLAnteIND` (`note`),
  KEY `gsegLAgenlocIND` (`genetic_locus`),
  KEY `gsegLAgldesIND` (`genetic_locus_desc`),
  KEY `gsegLAcovIND` (`coverage`),
  KEY `gsegLAintIND` (`integrity`),
  FULLTEXT KEY `cgaFT_Desc` (`description`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gdb_projects`
--

DROP TABLE IF EXISTS `gdb_projects`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gdb_projects` (
  `uid` int(10) unsigned NOT NULL auto_increment,
  `locus_id` varchar(32) default NULL,
  `project_uid` int(10) unsigned default NULL,
  `project_name` varchar(32) default NULL,
  `db_version` tinyint(2) NOT NULL default '0',
  PRIMARY KEY  (`uid`),
  KEY `key_locusid` (`locus_id`),
  KEY `key_projuid` (`project_uid`),
  KEY `key_projname` (`project_name`),
  KEY `key_dbver` (`db_version`)
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

-- Dump completed on 2011-07-13 14:32:32
