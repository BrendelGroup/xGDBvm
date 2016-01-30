<?php
if (preg_match('/(GDB\d\d\d)/', $_SERVER['HTTP_REFERER'], $matches))
        $X = $matches[1];
if (preg_match('/(GDB\d\d\d)/',$_REQUEST['GDB'], $matches)) ;
        $X = $matches[1];

if(empty($SITEDEF_H)) { require('/xGDBvm/INSTANCES/' . $X .'/conf/SITEDEF.php'); }
#if(empty($SITEDEF_H)){require('SITEDEF.php');}
?>
<html>
	<head>
		<title></title>
		<script type="text/javascript" src="<?php echo "/xGDBvm/XGDB/javascripts/TV_info.js"; ?>"></script>
		<style>
			body { text-align:left; }		
			td { padding:1px; vertical-align:top; text-align:center; font:bold 10px Courier,serif; }
			td#info input { margin:1px 2px; text-align:center; font:normal 10px Courier,serif; }
			td#desc { padding-right:10px; width:100%;}
			#seqDesc{ height:65px; width:100%; margin:1px 2px; font:normal 12px Courier,serif; }
		</style>
	</head>
<body>

<form method="post" action="<?php echo "${CGIPATH}showCluster.pl"; ?>" enctype="application/x-www-form-urlencoded" name="infoFORM">
<table>
   <tr>
      <td id='info'>
         <nobr>ID<input name="seqName" type="text" value="" size="30" /></nobr><br />
         <nobr>
				<input name="regLFT" type="text" value="" size="10" />--
				<input name="regRGT" type="text" value="" size="10" /></nobr><br />
         <nobr>Sim<input name="seqSim" type="text" value="" size="5" /><input name="seqCov" type="text" value="" size="5" />Cov</nobr>
      </td>
      <td id='desc'>
         <textarea id='seqDesc' noscroll="">
*** Use scroll bar at bottom of page to navigate ***
</textarea>
      </td>
   </tr>
</table>
</form>
</body></html>
