
<div class="dialogcontainer">
	<h2 class="bottommargin1">Relax UniRef (CpGAT)</h2>
	<p> If this flag is set to True (T), CpGAT will include gene models even if they have no support from the reference protein dataset</p>
	<p> In this case, the longest ORF <span class="plaintext">(length >= MinESTPepLen && ORF ratio >=ORFLenRatio) </span> with no homologous 
			support will be considered as full CDS from spliced alignment. default = T</p>
	<p>Which option to choose?</p>
	<ul class="bullet1 indent2">
        <li> If are comfortable including preditions with no support from your Reference Protein dataset (that may not be full length), select <i>Yes</i> (default). </li>
        <li> If you want ONLY apparently full-length gene predictions based on RefProt support, you may want to select <i>No</i>, to eliminate partials.</li>
	</ul>

			<span class="heading normalfont linkback"> <a class="smallerfont" href="/XGDB/help/create_gdb.php#config_cpgat_options_relaxuniref">View this in Help Context</a> (create_gdb.php/config_cpgat_options_relaxuniref)</span>


</div>
