DROP TABLE IF EXISTS `admin`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `admin` (
  `uid` int(6) NOT NULL AUTO_INCREMENT,
  `admin_email_date` varchar(32) NOT NULL DEFAULT '',
  `admin_email` varchar(255) NOT NULL DEFAULT '',
  `auth_url` varchar(255) NOT NULL DEFAULT '',
  `api_version` varchar(32) NOT NULL default '',
  `auth_update` varchar(32) NOT NULL DEFAULT '',
  PRIMARY KEY (`uid`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
SET character_set_client = @saved_cs_client;

DROP TABLE IF EXISTS `jobs`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `jobs` (
  `uid` int(6) NOT NULL auto_increment,
  `nonce` varchar(255) NOT NULL default '',
  `job_id` varchar(255) NOT NULL default '',
  `job_name` varchar(255) NOT NULL default '',
  `status` varchar(255) NOT NULL default '',
  `db_id` int(6) default NULL,
  `job_type` varchar(255) NOT NULL default '',
  `program` varchar(255) NOT NULL default '',
  `softwareName` varchar(255) NOT NULL default '',
  `job_URL` varchar(500) NOT NULL default '',
  `HPC_name` varchar(255) NOT NULL default '',
  `user` varchar(255) NOT NULL default '',
  `admin_email` varchar(255) NOT NULL default '',
  `seq_type` varchar(32) NOT NULL default '',
  `genome_file_size` varchar(32) NOT NULL default '',
  `genome_segments` varchar(32) NOT NULL default '',
  `split_count` int(6) default NULL,
  `input_file_size` varchar(32) NOT NULL default '',
  `parameters` varchar(255) NOT NULL default '',
  `requested_time` varchar(32) NOT NULL default '',
  `processors` varchar(32) NOT NULL default '',
  `memory` varchar(32) NOT NULL default '',
  `comments` text,
  `posted_data` text,
  `server_response` text,
  `job_submitted_time` datetime default NULL,
  `job_start_time` datetime default NULL,
  `last_updated` datetime default NULL,
  `job_end_time` datetime default NULL,
  `process_complete_time` datetime default NULL,
  `outcome` varchar(255) NOT NULL default '',
  `output_copied` varchar(255) NOT NULL default '',
  `error` varchar(255) NOT NULL default '',
  PRIMARY KEY  (`uid`),
  UNIQUE KEY `unique_job_id` (`job_id`),
  KEY `key_job_type` (`job_type`),
  KEY `key_user` (`user`),
  FULLTEXT KEY `Comments` (`comments`)
)ENGINE=MyISAM DEFAULT CHARSET=latin1;
SET character_set_client = @saved_cs_client;

DROP TABLE IF EXISTS `apps`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `apps` (
  `uid` int(6) NOT NULL auto_increment,
  `app_id` varchar(255) NOT NULL default '',
  `program` varchar(255) default '',
  `version` varchar(255) default '',
  `platform` varchar(255) NOT NULL default '',
  `nodes` int(3) default NULL,
  `proc_per_node` int(3) default NULL,
  `memory_per_node` int(3) default 2,
  `date_added`  datetime default NULL,
  `description` varchar(255) NOT NULL default '',
  `developer` varchar(255) NOT NULL default '',
  `is_default` enum('Y', 'N') NOT NULL default 'N',
  `max_job_time` varchar(32) NOT NULL default '12:00:00',
  PRIMARY KEY  (`uid`)
)ENGINE=MyISAM DEFAULT CHARSET=latin1;
SET character_set_client = @saved_cs_client;