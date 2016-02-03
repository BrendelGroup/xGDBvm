<?php
if (preg_match('/(GDB\d\d\d)/', $_SERVER['HTTP_REFERER'], $matches))
        $X = $matches[1];
if (preg_match('/(GDB\d\d\d)/',$_REQUEST['GDB'], $matches)) ;
        $X = $matches[1];

if(empty($SITEDEF_H)) { require('/xGDBvm/INSTANCES/' . $X .'/conf/SITEDEF.php'); }
#if(empty($SITEDEF_H)){require("SITEDEF.php");}
?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
    "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
   <head>
      	<title></title>
		<script type="text/javascript" src="<?php echo "${JSPATH}TV_infoPlus.js"; ?>"></script>
		<style type="text/css">
			/*<![CDATA[*/
			body {margin:0px; text-align:left;}
			div#stdTOOLS {margin-top:20px; text-align:center;}
			div#exonDESC {margin-top:5px; color:green; display:none; font-size:12px; text-align:left;}
			div#exonDESC h1 {margin:10px 1px 1px 1px; font-size:12px;}
			div#exonDESC p.region {margin-top:1px; text-align:left;}
			div#exonDESC input {margin:1px 2px; text-align:center; font-size:10px;}
			div#exonDESC input.reg {text-align:right;}
			div#intronDESC {margin-top:5px; color:blue; display:none; font-size:12px; text-align:left;}
			div#intronDESC h1 {margin:10px 1px 1px 1px; font-size:12px;}
			div#intronDESC p.region {margin-top:1px; text-align:left;}
			div#intronDESC input {margin:1px 2px; text-align:center; font-size:10px;}
			div#intronDESC input.reg {text-align:right;}
		/*]]>*/
      </style>
   </head>
   <body>

      <form method="post" action="<?php echo "${CGIPATH}showCluster.pl" ?>" enctype="application/x-www-form-urlencoded" name="infoFORM">
         <div id="stdTOOLS">
            <!--input type="button" onclick="setIMGW();" style="width:50px;" value="Optimize Image"></input-->
         </div>
         <div id="exonDESC">
            <h1>
               Exon
            </h1><input name="exNUM" type="text" value="" size=
            "3" /><br />
            <h1>
               Similarity
            </h1><input name="exSim" type="text" value="" size=
            "5" /><br />
            <h1>
               Genomic Region
            </h1>
            <p class="region">
               <input class="reg" name="exgLFT" type="text" value=""
               size="10" />Left<br />
               <input class="reg" name="exgRGT" type="text" value=""
               size="10" />Right
            </p>
            <h1>
               Sequence Region
            </h1>
            <p class="region">
               <input class="reg" name="exeLFT" type="text" value=""
               size="10" />Left<br />
               <input class="reg" name="exeRGT" type="text" value=""
               size="10" />Right
            </p>
         </div>
         <div id="intronDESC">
            <h1>
               Intron
            </h1><input name="inNUM" type="text" value="" size="3" />
            <h1>
               Donor Site
            </h1>
            <p class="region">
               <input name="dSCORE" type="text" value="" size=
               "5" />Score<br />
               <input name="dSim" type="text" value="" size="5" />Sim
            </p>
            <h1>
               Acceptor Site
            </h1>
            <p class="region">
               <input name="acSCORE" type="text" value="" size=
               "5" />Score<br />
               <input name="acSim" type="text" value="" size="5" />Sim
            </p>
            <h1>
               Genomic Region
            </h1>
            <p class="region">
               <input class="reg" name="inLFT" type="text" value=""
               size="10" />Left<br />
               <input class="reg" name="inRGT" type="text" value=""
               size="10" />Right
            </p>
         </div>
      </form>
   </body>
</html>
