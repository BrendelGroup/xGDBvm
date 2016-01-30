-- MySQL dump 10.13  Distrib 5.1.37, for pc-solaris2.10 (x86_64)
--
-- Host: localhost    Database: yrgate
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
-- Table structure for table `admin_session`
--

DROP TABLE IF EXISTS `admin_session`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `admin_session` (
  `sid` int(10) NOT NULL AUTO_INCREMENT,
  `USERid` text,
  `uid` varchar(20) DEFAULT NULL,
  `checked_out_date` text,
  `geneName` varchar(20) DEFAULT NULL,
  `dbName` varchar(20) DEFAULT NULL,
  `returned` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`sid`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `users` (
  `uid` int(10) NOT NULL AUTO_INCREMENT,
  `user_cgi_session` varchar(32) NOT NULL DEFAULT '',
  `user_name` varchar(50) DEFAULT NULL,
  `pword` blob NOT NULL,
  `pword_new` blob,
  `pword_confirm_key` blob,
  `pword_reset_attempts` smallint(6) DEFAULT NULL,
  `account_type` enum('USER','ADMIN', 'INACTIVE') NOT NULL DEFAULT 'USER',
  `fullname` varchar(50) NOT NULL DEFAULT '',
  `email` varchar(100) DEFAULT NULL,
  `phone` varchar(30) DEFAULT NULL,
  `create_date` varchar(30) DEFAULT NULL, /*added JPD*/
  PRIMARY KEY (`uid`),
  UNIQUE KEY `user_name` (`user_name`),
  UNIQUE KEY `email` (`email`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

DROP TABLE IF EXISTS `projects`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `projects` (
  `uid` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `db_name` varchar(32) DEFAULT NULL,
  `project` varchar(32) DEFAULT NULL,
  `description` varchar(250) NOT NULL DEFAULT '',
  `source` varchar(250) DEFAULT NULL,
  `project_admin` varchar(32) DEFAULT NULL,
  PRIMARY KEY (`uid`),
  UNIQUE KEY `project-db` (`project`,`db_name`),
  KEY `key_db` (`db_name`),
  KEY `key_proj` (`project`),
  KEY `key_desc` (`description`),
  KEY `key_admin` (`project_admin`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;


DROP TABLE IF EXISTS `user_group`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_group` (
  `uid` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `user` varchar(50) NOT NULL DEFAULT '',
  `private_group` varchar(100) DEFAULT NULL,
  `gdb` varchar(10) DEFAULT NULL,
  `status` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`uid`),
  UNIQUE KEY `user-group-gdb` (`user`,`private_group`,`gdb`),
  FULLTEXT KEY `user` (`user`,`private_group`,`gdb`)
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

-- Dump completed on 2011-06-27 10:48:26
