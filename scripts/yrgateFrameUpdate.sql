DROP TABLE IF EXISTS `user_group`;
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

DROP TABLE IF EXISTS `projects`;
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

