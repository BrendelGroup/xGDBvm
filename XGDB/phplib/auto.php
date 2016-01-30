<?php
## This script is deprecated for the moment

if (preg_match('|^/xGDBvm|', $_SERVER['SCRIPT_FILENAME'])) {

$ROOT = '.:/xGDBvm/';
$DATA = $ROOT . "data/";

if (strpos($_SERVER['SCRIPT_NAME'], 'GDB') == 3)
	ini_set('include_path', $DATA . substr($_SERVER['SCRIPT_NAME'], 1, 2) . 'GDB/conf:' . $ROOT . 'XGDB/phplib');

if (strpos($_SERVER['SCRIPT_NAME'], 'XGDB') == 1 && preg_match('|(GDB)\d\d\d|', $_SERVER['HTTP_REFERER'], $matches))
	ini_set('include_path', $DATA . $matches[1] . '/conf:' . $ROOT . 'XGDB/phplib');

}
