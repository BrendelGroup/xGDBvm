<?php
function dbpass()
{
ob_start(); include '/xGDBvm/admin/dbpass'; $dbpass = ob_get_contents();
ob_end_clean ();
$dbpass=preg_replace('/[\x00-\x1F\x7F]/', '', $dbpass); #control characters stripped out.
return $dbpass;
}
?>