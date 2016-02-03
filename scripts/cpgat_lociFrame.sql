-- MySQL dump 10.11
--
-- Host: localhost    Database: GDB001
-- ------------------------------------------------------
-- Server version	5.0.77

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
-- Table structure for table `gseg_cpgat_locus_annotation`
--

DROP TABLE IF EXISTS `gseg_cpgat_locus_annotation`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `gseg_cpgat_locus_annotation` (
  `uid` int(10) unsigned NOT NULL auto_increment,
  `gseg_gi` varchar(32) NOT NULL default '',
  `locus_id` varchar(32) NOT NULL default '',
  `strand` enum('f','r') NOT NULL default 'f',
  `l_pos` int(10) unsigned NOT NULL default '0',
  `r_pos` int(10) unsigned NOT NULL default '0',
  `transcript_ids` varchar(512) NOT NULL,
  `cds_status` varchar(32) default NULL,
  `genetic_locus` varchar(16) default NULL,
  `genetic_locus_desc` varchar(128) default NULL,
  `description` text,
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
SET character_set_client = @saved_cs_client;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2012-01-06 15:12:00
