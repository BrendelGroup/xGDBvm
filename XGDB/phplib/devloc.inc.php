<?php
function devloc()
{
$devloc="/dev/vdc"; # default 
ob_start(); include '/xGDBvm/admin/devloc'; $devloc = ob_get_contents();
ob_end_clean ();
$devloc=preg_replace('/[\x00-\x1F\x7F]/', '', $devloc); #control characters stripped out.
return $devloc;
}
?>