<?php
    $PageTitle = 'About';
    $pgdbmenu = 'Help';
    $submenu = 'About';
    $leftmenu='About';
    $global_DB= 'Genomes';
    include("sitedef.php");
    include($XGDB_HEADER);
?>
        <div id="leftcolumncontainer">
            <div class="minicolumnleft">
                <?php include_once("/xGDBvm/XGDB/phplib/leftmenu.inc.php"); ?>
            </div>
        </div>

        <div id="maincontentscontainer" class="twocolumn">
        <div id="maincontentsfull">
        
            <h1 class="topmargin1 bottommargin1">About xGDBvm</h1>

                <p> xGDBvm was developed as part of <a title="view NSF grant page"  href="http://128.150.4.107/awardsearch/showAward.do?AwardNumber=1126267">NSF-funded project IOS-1126267</a>, 'IPGA: Characterization, Modeling, Prediction, and Visualization of the Plant Transcriptome.' (Volker Brendel, P.I.)</p>

                <p>xGDBvm is currently available for use as a virtual server at <a href="https://atmo.iplantcollaborative.org/application/">iPlant/CyVerse Atmosphere</a> (registration required; some software licenses may be required).</p>
                
                <p>A public repository is maintained on <a href="http://brendelgroup.github.io/xGDBvm/">GitHub</a> and a  <a href="http://goblinx.soic.indiana.edu/wiki/doku.php">wiki</a> is available.</p>

                <p>An instance of xGDBvm displaying annotated genomes, including <i>Polistes dominula</i>, can be found <a href=""https://goblinx.soic.indiana.edu">here</a>.</p>

<h2 class="topmargin2 bottommargin1">See Also</h2>
                
                     <ul class="menulist topmargin2 bottommargin2">
                        <li><a href="/XGDB/help/acknowledgments.php">Acknowledgments</a></li>
                        <li><a href="http://brendelgroup.org/">Brendel Group</a></li>
                        <li id="nsf" class="last"><a href="http://www.nsf.gov/" title="National Science Foundation">NSF</a></li>
                    </ul>       
            </div><!--end maincontentsfull-->
            </div><!--end maincontentscontainer-->
        <?php include($XGDB_FOOTER); ?>
        </div><!--end pagewidth-->
    </div><!--end innercontainer-->
</div><!--end outercontainer-->
</body>
</html>
