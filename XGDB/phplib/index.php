<?php 
$get_GDB=$_GET['GDB'];
$pattern="/^GDB\d\d\d$/";
if(preg_match($pattern, $get_GDB)) # correct GDB format
{
    $gdb_dir =`ls -d /xGDBvm/data/$get_GDB`; # list directory
    $dir_match = "/.*\/GDB\d\d\d$/"; 
    if(preg_match($dir_match, $gdb_dir)) # GDB data directory exists
    {
        $GDB=$get_GDB;
        if(empty($SITEDEF_H)){require("/xGDBvm/data/$GDB/conf/SITEDEF.php");}
        if(empty($PARAM_H)){require('getPARAM.php');}
        require('SSI_GDBprep.php');
        
        virtual("${CGIPATH}SSI_GDBgui.pl/THREE_COLUMN_HEADER/" . $SSI_QUERYSTRING);
        include_once('/xGDBvm/XGDB/phplib/db.inc.php'); #reads MySQL password from /xGDBvm/admin/dbpass
        include_once('/xGDBvm/XGDB/conf/conf_functions.inc.php'); #some functions are used here
        
        require('Scaff.home.inc.php'); # GDB Home Page information
        require('SSI_GDBprep.php');
        virtual("${CGIPATH}SSI_GDBgui.pl/STANDARD_FOOTER/" . $SSI_QUERYSTRING);
    }
    else
    {
    header("Location: /XGDB/genomes.php?error=outofrange");
    exit;
    }
}   
else
{
header("Location: /XGDB/genomes.php?error=norequest");
exit;
}
?>
