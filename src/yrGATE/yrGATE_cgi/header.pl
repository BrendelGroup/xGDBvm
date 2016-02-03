print <<END_OF_PRINT;
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
	 "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" lang="en-US" xml:lang="en-US">
	<head>
		<meta http-equiv="content-type" content="text/html;charset=utf-8" />
		<title>$PageTitle</title>
		<link rel="StyleSheet" type="text/css" href="/XGDB/css/plantgdb.css" media="screen" />
		<link rel="StyleSheet" type="text/css" href="/XGDB/css/superfish.css" media="screen" />
		<link rel="StyleSheet" type="text/css" href="/XGDB/src/yrGATE/yrGATE.css" media="screen" />

		<!--[if IE 6]>
		<link rel="StyleSheet" type="text/css" href="/XGDB/css/plantgdb_ie6.css" />
		<![endif]-->
		<script type="text/javascript" src="/XGDB/javascripts/jquery.js"></script>
		<script type="text/javascript" src="/XGDB/javascripts/jquery.tablesorter.js"></script>
		<script type="text/javascript" src="/XGDB/javascripts/superfish.js"></script>
		<!--script type="text/javascript" src="/XGDB/javascripts/hoverIntent.js"></script-->
		<script type="text/javascript" src="/XGDB/javascripts/jquery.accordion.js"></script>
		<script type="text/javascript" src="/XGDB/javascripts/jquery.treeview.js"></script><!-- TEST 11-19-08-->
		<script type="text/javascript" src="/XGDB/javascripts/menu.js"></script>
		<script type="text/javascript" src="/XGDB/javascripts/jquery.treeview.cookie.js"></script>
		<script type="text/javascript" src="/XGDB/javascripts/default.js"></script>
		<script type="text/javascript" src="/XGDB/javascripts/plantgdb_ga.js"></script>

		<script type="text/javascript" src="/XGDB/javascripts/default_xgdb.js"></script>
	</head>

	<body>
	<div id="outercontainer">
		<div id="innercontainer">
			<div id="logomenucontainer"><!--Container with same background color as logo and pgdbmenu -->
			<div id="headerwidth"><!--This nested container that allows FF2.0 to handle floated divs with % width-->
			<a name="top"></a>
				<div id="topright">
					<ul id="header">
						<li><a href="/help/">Help</a></li>
						<li id="feedback"><a href="/utility/feedback.php">Feedback</a></li>
						<li id="mailing_list" class="last"><a href="/admin/signup.php">Subscribe</a></li>
					</ul>
						<form name="quickSearch" action="/search/query/TextSearch.php" method="get">
							<ul>
								<li>
									<select name="searchType">
										<option value="google" title="Search PlantGDB using Google">PlantGDB Site Search</option>
										<option value="id" title="Search PlantGDB by Sequence ID">Sequence ID</option>
										<option value="anno" title="Search PlantGDB by Sequence Keyword">Sequence Keyword</option>
									</select>
								</li>
								<li>
									<input style="color:#AAA" type="text" name="searchString" size="11" value="Search" onfocus="this.value=\'\'"/>
									<input type="submit" value="Search"/>
								</li>
							</ul>
						</form>
				</div>
				<div id="pgdblogo">
					<a style="background:none" href= "/"><img alt="PlantGDB" src="/images/PGDBbanner.png" /></a>
				</div>
<div id="topleft">
</div>
<div id="menuwidth"><!-- Modifying this menu? Sync it with our other menus. See the notes in /phplib/pgdbmenu.inc.php (reference copy). - Dan Rasmussen, 2009-07-14. -->
	<div id="pgdbmenu">
		<ul class="sf-menu">
			<li><a style="text-align:center" href="/">Home</a></li>
			<li><a style="text-align:center" href="/search/misc/">Sequence</a>
				<ul>
					<li class="overview"><a href="/search/misc/">-Overview -</a></li>
					<li class="overview"><a href="/download/download.php/">Download</a></li>
					<li><a href="/search/">Search</a>
						<ul style="width:17em">
							<li><a href="/search/">-Overview-</a></li>
							<li><a href="/search/misc/PublicPlantSeq.php">Select Species...</a></li>
							<li><a href="/search/misc/plantlistconstruction.php?mySpecies=Arabidopsis thaliana" class="species">Arabidopsis thaliana</a></li>
							<li><a href="/search/misc/plantlistconstruction.php?mySpecies=Brassica napus" class="species">Brassica napus</a></li>
							<li><a href="/search/misc/plantlistconstruction.php?mySpecies=Brassica oleracea" class="species">Brassica oleracea</a></li>
							<li><a href="/search/misc/plantlistconstruction.php?mySpecies=Glycine max" class="species">Glycine max</a></li>
							<li><a href="/search/misc/plantlistconstruction.php?mySpecies=Gossypium hirsutum" class="species">Gossypium hirsutum</a></li>
							<li><a href="/search/misc/plantlistconstruction.php?mySpecies=Hordeum vulgare" class="species">Hordeum vulgare</a></li>
							<li><a href="/search/misc/plantlistconstruction.php?mySpecies=Medicago truncatula" class="species">Medicago truncatula</a></li>
							<li><a href="/search/misc/plantlistconstruction.php?mySpecies=Oryza sativa" class="species">Oryza sativa</a></li>
							<li><a href="/search/misc/plantlistconstruction.php?mySpecies=Physcomitrella patens" class="species">Physcomitrella patens</a></li>
							<li><a href="/search/misc/plantlistconstruction.php?mySpecies=Sorghum bicolor" class="species">Sorghum bicolor</a></li>
							<li><a href="/search/misc/plantlistconstruction.php?mySpecies=Triticum aestivum" class="species">Triticum aestivum</a></li>
							<li><a href="/search/misc/plantlistconstruction.php?mySpecies=Vitis vinifera" class="species">Vitis vinifera</a></li>
							<li><a href="/search/misc/plantlistconstruction.php?mySpecies=Zea mays" class="species">Zea mays</a></li>
						</ul>
					</li>
					<li><a href="/prj/ESTCluster/">EST Assemb</a>
						<ul style="width:15em">
							<li class="overview"><a href="/prj/ESTCluster/">-Overview -</a></li>
							<li><a href="/prj/ESTCluster/progress.php">Select Species...</a></li>
							<li><a href="/download/download.php?dir=/Sequence/ESTcontig/Arabidopsis_thaliana" class="species">Arabidopsis thaliana</a></li>
							<li><a href="/download/download.php?dir=/Sequence/ESTcontig/Brassica_napus" class="species">Brassica napus</a></li>
							<li><a href="/download/download.php?dir=/Sequence/ESTcontig/Brassica_oleracea" class="species">Brassica oleracea</a></li>
							<li><a href="/download/download.php?dir=/Sequence/ESTcontig/Glycine_max" class="species">Glycine max</a></li>
							<li><a href="/download/download.php?dir=/Sequence/ESTcontig/Gossypium_hirsutum" class="species">Gossypium hirsutum</a></li>
							<li><a href="/download/download.php?dir=/Sequence/ESTcontig/Hordeum_vulgare" class="species">Hordeum vulgare</a></li>
							<li><a href="/download/download.php?dir=/Sequence/ESTcontig/Medicago_truncatula" class="species">Medicago truncatula</a></li>
							<li><a href="/download/download.php?dir=/Sequence/ESTcontig/Oryza_sativa" class="species">Oryza sativa</a></li>
							<li><a href="/download/download.php?dir=/Sequence/ESTcontig/Physcomitrella_patens" class="species">Physcomitrella patens</a></li>
							<li><a href="/download/download.php?dir=/Sequence/ESTcontig/Sorghum_bicolor" class="species">Sorghum bicolor</a></li>
							<li><a href="/download/download.php?dir=/Sequence/ESTcontig/Triticum_aestivum" class="species">Triticum aestivum</a></li>
							<li><a href="/download/download.php?dir=/Sequence/ESTcontig/Vitis_vinifera" class="species">Vitis vinifera</a></li>
							<li><a href="/download/download.php?dir=/Sequence/ESTcontig/Zea_mays" class="species">Zea mays</a></li>
						</ul>
					</li>
					<li><a title="GSS Assembly" href="/prj/GSSAssembly/">GSS Assemb</a></li>
					<li><a href="ftp://ftp.plantgdb.org/">FTP Server</a></li>
				</ul>
			</li>
			<li><a class="current" style="text-align:center" href="/prj/GenomeBrowser/">Genomes</a>
				<ul style="width:21em">
					<li class="overview"><a href="/prj/GenomeBrowser/">-Overview-</a></li>
					<li><a href="/yrGATE/">-Community Annotation-</a></li>
					<li><a href="/prj/GenomeBrowser/das.php?ref=Genomes">-DAS Services-</a></li>
				<li><a href="/AtGDB/">AtGDB<i> - Arabidopsis thaliana</i></a></li><li><a href="/BdGDB/">BdGDB<i> - Brachypodium distachyon</i></a></li><li><a href="/BrGDB/">BrGDB<i> - Brassica rapa</i></a></li><li><a href="/CpGDB/">CpGDB<i> - Carica papaya</i></a></li><li><a href="/GhGDB/">GhGDB<i> - Gossypium hirsutum</i></a></li><li><a href="/GmGDB/">GmGDB<i> - Glycine max</i></a></li><li><a href="/HvGDB/">HvGDB<i> - Hordeum vulgare</i></a></li><li><a href="/LjGDB/">LjGDB<i> - Lotus japonicus</i></a></li><li><a href="/MtGDB/">MtGDB<i> - Medicago truncatula</i></a></li><li><a href="/OsGDB/">OsGDB<i> - Oryza sativa</i></a></li><li><a href="/PpGDB/">PpGDB<i> - Physcomitrella patens</i></a></li><li><a href="/PtGDB/">PtGDB<i> - Populus trichocarpa</i></a></li><li><a href="/SbGDB/">SbGDB<i> - Sorghum bicolor</i></a></li><li><a href="/SlGDB/">SlGDB<i> - Solanum lycopersicum</i></a></li><li><a href="/TaGDB/">TaGDB<i> - Triticum aestivum</i></a></li><li><a href="/VvGDB/">VvGDB<i> - Vitis vinifera</i></a></li><li><a href="/ZmGDB/">ZmGDB<i> - Zea mays</i></a></li></ul>
			</li>
			<li><a style="text-align:center" href="/tool/">Tools</a>
				<ul>
					<li class="overview"><a href="/tool/">-Overview-</a></li>
					<li><a href="http://www.bioextract.org/query/index.jsp">BioExtract</a></li>
					<li><a href="/cgi-bin/blast/PlantGDBblast">BLAST</a></li>
					<li><a href="/prj/GenomeBrowser/das.php?ref=Tools">DAS</a></li>
					<li><a href="/cgi-bin/GeneSeqer/index.cgi">GeneSeqer</a></li>
					<li><a href="/cgi-bin/GenomeThreader/gth.cgi">GenomeThreader</a></li>
					<li><a href="/MuSeqBox/MuSeqBox.php">MuSeqBox</a></li>
					<li><a href="/cgi-bin/vmatch/patternsearch.pl">PatternSearch</a></li>
					<li><a href="/cgi-bin/prj/PLEXdb/ProbeMatch.pl">ProbeMatch</a></li>
					<li><a href="http://www.bioextract.org/genbank/home/index.jsp">TableMaker</a></li>
					<li><a href="/tool/TE_nest/">TE nest</a></li>
					<li><a href="/tool/tracembler/">Tracembler</a></li>
					<li><a href="/prj/yrGATE/">yrGATE</a></li>
				</ul>
			</li>
			<li><a style="text-align:center" href="/prj/">Datasets</a>
				<ul>
					<li class="overview"><a href="/prj/">- Overview -</a></li>
					<li><a href="/prj/AcDsTagging/">Ac/Ds maize</a>
					<ul style="width:12em">
						<li><a href="/prj/AcDsTagging/">Overview</a></li>
						<li><a href="/prj/AcDsTagging/records.php">Browse Insertions</a></li>
						<!--li><a href="/prj/AcDsTagging/lookup.php">Search</a></li-->
						<!--li><a href="/prj/AcDsTagging/ipcr_view.php">IPCR</a></li-->
						<!--li><a href="/prj/AcDsTagging/sequence_view.php">Sequence</a></li-->
						<!--li><a href="/prj/AcDsTagging/placement_view.php">Placement</a></li-->
						<!--li><a href="/prj/AcDsTagging/help.php">Help</a></li-->
					</ul>
					</li>
					<li><a href="/ASIP/">ASIP</a></li>
					<li><a href="/prj/PLEXdb/">PLEXdb</a></li>
					<li><a href="/prj/RescueMuTagging/">RescueMu</a></li>
					<li><a href="/prj/RFLP_FLIS/">RFLP/FLIS</a></li>
					<li><a href="/SRGD/">SRGD</a></li>
					<li><a href="/prj/UniformMuTagging/">UniformMu</a></li>
				</ul>
			</li>
			<li><a style="text-align:center" href="/PGROP/pgrop.php">Outreach</a>
				<ul style="width:23em">
					<li class="overview"><a href="/PGROP/pgrop.php">Plant Genome Outreach Portal (PGROP)</a></li>
					<li><a href="http://www.lawrencelab.org/Outreach/">Outreach to Native Americans</a></li>
				</ul>
			</li>
			<li><a style="text-align:center" href="/site/">Help</a>
				<ul>
					<li><a href="/help/">Help</a>
						<ul style="width:15em">
							<li><a href="/help/anno.php">Community Annotation</a></li>
							<li><a href="/help/xgdb.php">Genome Browsers</a></li>
							<li><a href="/help/tblmk.php">TableMaker</a></li>
						</ul>
					</li>
					<li><a href="/help/">Tutorials</a>
						<ul style="width:15em">
							<li><a href="/tutorial/annotatemodule/">Annotation Tutorial</a></li>
							<li><a href="/tutorial/annotatelesson/">Annotation Lessons</a></li>
							<li><a href="/tutorial/geneseqer.php">GeneSeqer Tutorial</a></li>
						</ul>
					</li>
					<li><a href="/site/">About Us</a></li>
					<li><a href="/site/news.php">News</a></li>
					<li><a title="A brief tour through PlantGDB's resources" href="/site/tour.php">Tour</a></li>
					<li><a href="/site/faq.php">F.A.Q.</a></li>
					<li><a href="/site/sitemap.php">Site Map</a></li>
					<li><a href="/site/publications.php">Publications</a></li>
					<li><a href="/site/links.php">Links</a></li>
					<li><a href="/site/acknowledgments.php">Acknowledgments</a></li>
				</ul>
			</li>
		</ul>
	</div>
</div><!-- end of menuwidth div -->
</div><!--end headerwidth-->

				</div><!--end logomenucontainer-->
				<div id="pagewidth"><!--This nested container allows FF2.0 to handle floated divs with % width-->
				<div id="topshadow"><!--little shadow background image --></div>
END_OF_PRINT
