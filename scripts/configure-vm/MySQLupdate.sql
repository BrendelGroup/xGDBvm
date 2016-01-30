/*  Table updated 10/3/2014 */

CREATE TABLE IF NOT EXISTS `Datafiles` (
  `uid` int(6) NOT NULL AUTO_INCREMENT,
  `Valid` varchar(1) DEFAULT '',
  `UserFile` varchar(1) DEFAULT '',
  `ValidationTimeStamp` varchar(100) DEFAULT NULL,
  `FileName` varchar(150) DEFAULT '',
  `Path` varchar(150) DEFAULT '',
  `FileStamp` varchar(10000) DEFAULT '',
  `FileSize` int(11) DEFAULT NULL,
  `SeqType` varchar(50) DEFAULT '',
  `SeqTypeCount` int(11) DEFAULT NULL,
  `Format` varchar(50) DEFAULT '',
  `Track` varchar(50) DEFAULT '',
  `EntryCount` int(11) DEFAULT NULL,
  `SizeTotal` int(11) DEFAULT NULL,
  `SizeAverage` int(11) DEFAULT NULL,
  `SizeMedian` int(11) DEFAULT NULL,
  `SizeSmallest` int(11) DEFAULT NULL,
  `SizeLargest` varchar(50) DEFAULT '',
  `Size2` int(11) DEFAULT NULL,
  `Size3` int(11) DEFAULT NULL,
  `Size4` int(11) DEFAULT NULL,
  `Size5` int(11) DEFAULT NULL,
  `Size6` int(11) DEFAULT NULL,
  `Size7` int(11) DEFAULT NULL,
  `Size8` int(11) DEFAULT NULL,
  `Size9` int(11) DEFAULT NULL,
  `Size10` int(11) DEFAULT NULL,
  `Size11` int(11) DEFAULT NULL,
  `Size12` int(11) DEFAULT NULL,
  `Size13` int(11) DEFAULT NULL,
  `Size14` int(11) DEFAULT NULL,
  `Size15` int(11) DEFAULT NULL,
  `Size16` int(11) DEFAULT NULL,
  `Size17` int(11) DEFAULT NULL,
  `Size18` int(11) DEFAULT NULL,
  `Size19` int(11) DEFAULT NULL,
  `Size20` int(11) DEFAULT NULL,
  `Size21` int(11) DEFAULT NULL,
  `Size22` int(11) DEFAULT NULL,
  `Size23` int(11) DEFAULT NULL,
  `Size24` int(11) DEFAULT NULL,
  `HardMaskN` int(11) DEFAULT '0',
  `HardMaskX` int(11) DEFAULT '0',
  `FastaValid` varchar(50) DEFAULT '',
  `DeflineTabs` int(11) DEFAULT '0',
  `FastaValidateMessage` varchar(500) DEFAULT NULL,
  `FastaDefline` varchar(500) DEFAULT '',
  `SampleContents` varchar(500) DEFAULT '',
  `Duplicates` varchar(50) DEFAULT '',
  `Unit` varchar(50) DEFAULT '',
  `Genes` int(11) DEFAULT NULL,
  `Transcripts` int(11) DEFAULT NULL,
  `Entries` int(11) DEFAULT NULL,
  `GSQAlignments` int(11) DEFAULT NULL,
  `GTHAlignments` int(11) DEFAULT NULL,
  PRIMARY KEY (`uid`),
  FULLTEXT KEY `filestamp` (`FileStamp`),
  FULLTEXT KEY `ValidationTimeStamp` (`ValidationTimeStamp`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

CREATE TABLE IF NOT EXISTS `Processes` (
  `ProcessID` int(6) NOT NULL AUTO_INCREMENT,
  `ProcessTimeStamp` varchar(100) NOT NULL DEFAULT '',
  `ParentProcessTimeStamp` varchar(100) NOT NULL DEFAULT '',
  `ValidationTimeStamp` varchar(100) NOT NULL DEFAULT '',
  `GDB` varchar(20) NOT NULL DEFAULT '',
  `ProcessType` varchar(20) NOT NULL DEFAULT '',
  `Outcome` varchar(20) NOT NULL DEFAULT '',
  `Duration` int(9) DEFAULT NULL,
  UNIQUE KEY `ProcessIDIndex` (`ProcessID`),
  FULLTEXT KEY `ProcessTimeStampIndex` (`ProcessTimeStamp`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

CREATE TABLE IF NOT EXISTS `Validation` (
  `uid` int(6) NOT NULL AUTO_INCREMENT,
  `FileStamp` varchar(10000) NOT NULL DEFAULT '',
  `ValidationTimestamp` varchar(100) NOT NULL DEFAULT '',
  UNIQUE KEY `uid` (`uid`),
  FULLTEXT KEY `FileStampIndex` (`FileStamp`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

CREATE TABLE IF NOT EXISTS `apps`;
  `uid` int(6) NOT NULL auto_increment,
  `app_id` varchar(255) NOT NULL default '',
  `program` varchar(255) default '',
  `version` varchar(255) default '',
  `platform` varchar(255) NOT NULL default '',
  `nodes` int(3) default NULL,
  `proc_per_node` int(3) default NULL,
  `date_added`  datetime default NULL,
  `description` varchar(255) NOT NULL default '',
  `developer` varchar(255) NOT NULL default '',
  `is_default` enum('Y', 'N') NOT NULL default 'N',
  `max_job_time` varchar(32) NOT NULL default '12:00:00',
  PRIMARY KEY  (`uid`)
)