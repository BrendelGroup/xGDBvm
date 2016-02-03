<?php
# see http://stackoverflow.com/questions/14024877/deny-direct-download-of-file-using-php
# see http://php.net/manual/en/function.readfile.php

if(isset($_GET['GDB']) && preg_match('/^(GDB\d\d\d)$/', $_GET['GDB']))
{
$GDB = htmlspecialchars($_GET['GDB']);
    if (isset($_GET['dir']))
    {
       $dir = htmlspecialchars($_GET['dir']);
    }
    else
    {
    $dir="download"; //Default
    }
    $display="F";
    $description="";
    switch ($dir) 
    {
    case "download":
       $root="/xGDBvm/data/$GDB";
       $dir="/data/download";
       $dir_display="download";
       $display="T";
       $description="This directory contains copies of all $GDB <b>input data</b> files (consolidated by input type)";
       $extra="";
    break;
    case "MYSQL":
       $root="/xGDBvm/data/$GDB";
       $dir="/data/XGDB_MYSQL";
       $dir_display="XGDB_MYSQL";
       $display="T";
       $description="This directory contains <b>.sql load files</b> that were used to populate $GDB MySQL tables";
       $extra="";
    break;
    case "GSQOUT":
       $root="/xGDBvm/data/$GDB";
       $dir="/data/GSQ/GSQOUT";
       $dir_display="GSQ/GSQOUT";
       $display="T";
       $description="This directory contain <b>GeneSeqer output files</b> used to populate $GDB transcript tables (e.g. est)";
       $extra="";
    break;
    case "GTHOUT":
       $root="/xGDBvm/data/$GDB";
       $dir="/data/GTH/GTHOUT";
       $dir_display="GTH/GTHOUT";
       $display="T";
       $description="This directory contain <b>GenomeThreader output files</b> used to populate $GDB protein tables (e.g. pep)";
       $extra="";
    break;
    case "CpGAT":
       $root="/xGDBvm/data/$GDB";
       $dir="/data/CpGAT";
       $dir_display="CpGAT";
       $display="T";
       $description="This directory contain <b>CpGAT output files</b> for each scaffold, that were used to create CpGAT annotation dataset";
       $extra="";
    break;
    case "BLAST":
       $root="/xGDBvm/data/$GDB";
       $dir="/data/BLAST";
       $dir_display="BLAST";
       $display="T";
       $description="This directory contains all $GDB <b>input sequence files</b> (~.fa) indexed for BLAST";
       $extra="";
    break;
    case "Archive":
       $root="/xGDBvm/data/";
       $dir="/ArchiveGDB";
       $dir_display="ArchiveGDB";
       $display="T";
       $description="This directory contains archived output data for this GDB in the file format: <span class=\"plaintext\">GDBnnn-~.tar</span>";
       $extra="ArchiveGDB.log $GDB-*.tar";
    break;
    }
    if(empty($SITEDEF_H)) { require('/xGDBvm/data/' . $GDB . '/conf/SITEDEF.php'); }
    if(empty($PARAM_H)){require('/xGDBvm/XGDB/phplib/getPARAM.php');}
    require('/xGDBvm/XGDB/phplib/SSI_GDBprep.php');
    virtual("${CGIPATH}SSI_GDBgui.pl/THREE_COLUMN_HEADER/" . $SSI_QUERYSTRING);
}
else
{
header("Location: /XGDB/genomes.php?error=norequest");
exit;
}

?>

    <div id="mainWLS">
    <div id="maincontents" style="min-height:800px">
    <h1 class="bottommargin1"> Download Output Data <img id='genome_download_data' title='Download output data files. Click ? for details.' class='xgdb-help-button nudge1' src='/XGDB/images/help-icon.png' alt='?' /></h1>
    <p><span class="instruction">Click a <b>directory link</b> to view files (if any), then click file name you want to download.</span></p>
    <div class="bottommargin2" style="width:50%">
    <table id="DirectoryTable" class="featuretable">
    <tr>
        <td class="nowrap">
        /xGDBvm/data/<?php echo $GDB; ?>/data/
        </td>
        <td>
        <a title="Input files for this genome database" href="/XGDB/phplib/download.php?GDB=<?php echo $GDB ?>&amp;dir=download">download</a>
        </td>
        <td>
        <a title="MySQL load files for this genome database" href="/XGDB/phplib/download.php?GDB=<?php echo $GDB ?>&amp;dir=MYSQL">MySQL</a>
        </td>
        <td>
        <a title="GeneSeqer files for this genome database" href="/XGDB/phplib/download.php?GDB=<?php echo $GDB ?>&amp;dir=GSQOUT">GSQOUT</a>
        </td>
        <td>
        <a title="GenomeThreader files for this genome database" href="/XGDB/phplib/download.php?GDB=<?php echo $GDB ?>&amp;dir=GTHOUT">GTHOUT</a>
        </td>
        <td>
        <a title="CpGAT files for this genome database" href="/XGDB/phplib/download.php?GDB=<?php echo $GDB ?>&amp;dir=CpGAT">CpGAT</a>
        </td>
        <td>
        <a title="BLAST files for this genome database" href="/XGDB/phplib/download.php?GDB=<?php echo $GDB ?>&amp;dir=BLAST">BLAST</a>
        </td>
    </tr>
    <tr>
       <td class="nowrap">
        /xGDBvm/data/ArchiveGDB/
       </td>
        <td>
        <a title="archive file for this genome database" href="/XGDB/phplib/download.php?GDB=<?php echo $GDB ?>&amp;dir=Archive">ArchiveGDB</a>
        </td>
    </tr>
    </table>
    </div>
    <div>
        <h2 class="bottommargin1"><span style="border:2px solid yellow"><?php echo "$dir_display"; ?></span>&nbsp; &nbsp;<span class="heading"><?php echo $description; ?></span></h2>


    </div>

    <div>
    <table id="DownloadTable" cellpadding="5px">
    <tr><th align="left">Name</th><th>Last modified date</th><th></th><th>File Size</th><th>File Info</th></tr>
    
    <?php
    if($display=="T") // valid directory
    #/xGDBvm/data/GDB001/data/
    

    {
        $homedir = "${root}${dir}/";
        echo "$homedir\n";
        $list = `cd $homedir; ls -l --time-style=long-iso $extra`; 
        $list = explode( "\n", $list );
        foreach ( $list as $item )
        {
            $pattern = "/\s+/";
            $replacement = " ";
            $item = preg_replace($pattern, $replacement, $item);
            if ( substr( $item, 0, 1 ) == "d" ) // It's a directory so give download.php a directory and see if it's included on the allowed list.
            {	
                $vals = explode( " ", $item );
                $name = "/" . $vals[count($vals)-1];
                $name1 = $vals[count($vals)-1];
                $time = $vals[count($vals)-2];
                $year_month_day = $vals[count($vals)-3];
                $size = $vals[count($vals)-5];
                print "<tr>
                            <td><a href=\"/XGDB/phplib/download.php?GDB=$GDB&amp;dir=$dir/$name1/\">$name</a></td>
                            <td></td>
                            <td></td>
                            <td>directory</td>
                        </tr>";
            }
            else if ( substr( $item, 0, 1 ) == "-" ) // It's a file so we want user to be able to download it using download.exec.php
            {
                $vals = explode( " ", $item );
                $name = $vals[count($vals)-1];
                $time = $vals[count($vals)-2];
                $year_month_day = $vals[count($vals)-3];
                $size = $vals[count($vals)-4];
				$filestamp = "$name:$size:${year_month_day}-$time";
                $unit = 0;
                //0: bytes, 1: kilobytes, 2: megabytes, 3: gigabytes
                while ($size > 1024 && $unit < 4)
                {
                    $size = round($size / 1024,2);
                    $unit++;
                }
               $file_info_icon="<span id=\"${homedir}/${name}\" class=\"validatefile-button\" title=\"$filestamp\"><img class=\"nudge3\" src=\"/XGDB/images/information.png\" /></span>";
                print "<tr>
                            <td><a href=\"/XGDB/phplib/download.exec.php?GDB=$GDB&amp;dir=$dir_display&amp;file=$name\">$name</a></td>
                            <td>${year_month_day} ${time}</td>
                            <td></td>
                            <td>$size";
                if($unit == 0) print " bytes";
                if($unit == 1) print " KB";
                if($unit == 2) print " MB";
                if($unit == 3) print " GB";
                print "		</td>
                <td align=\"center\">$file_info_icon</td>
              </tr>";
            }
        }
}
else
{
print "<p class=\"warning\"> Invalid directory request. </p>";
}
?>
		</table>
</div>
						  <div style="clear:both; float:right">
							<a href="http://validator.w3.org/check?uri=referer"><img
							  src="http://www.w3.org/Icons/valid-xhtml10" alt="Valid XHTML 1.0 Transitional" height="15" width="44" /></a>
						  </div>						
		
		</div><!-- end maincontents -->
		</div><!-- end mainWLS-->
<?php
require('/xGDBvm/XGDB/phplib/SSI_GDBprep.php');
virtual("${CGIPATH}SSI_GDBgui.pl/STANDARD_FOOTER/" . $SSI_QUERYSTRING);
?>
