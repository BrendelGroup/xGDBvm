<h2> Inputs / Outputs </span></h1>

				<table class="featuretable topmargin1 bottommargin1 striped">
				<colgroup align="center">
				<col width="8%;" />
				<col width="10%;" />
				<col width="10%;" />
				<col width="20%;" />
				<col width="10%;" />
				<col width="10%;" />
				<col width="10%;" />
				<col width="10%;" />
				<col width="10%;" />
				<col width="10%;" />
				<col width="15%;" />

				</colgroup>
				<thead>
				<!--tr class="{sorter: false}">
					<th></th>
					<th colspan="3">Species</th>
					<th colspan="3"></th>
					<th colspan="2">Protein Alignments</th>
				</tr-->
					<tr>
						<th align="center" rowspan="2">Input Data Type</th>
						<th align="center" rowspan="2">Format</th>
						<th align="center" rowspan="2">Input Data Filename(s) under <pre class="directory">/xGDBvm/input/xgdbvm/<br />[myData]/</pre> <img id='config_input_dir' title='Input Directory. Click ? for details.' class='help-button nudge1' src='/XGDB/images/help-icon.png' alt='?' /></th>
						<th align="center" rowspan="2">Input For Process(es):</th>
						<th align="center" colspan="6">Output Data Filename(s) under <pre class="directory">/xGDBvm/data/GDB&#35;/data/</pre></th>
						<th align="center" rowspan="2" width="100px"><span class="nowrap white">Output Display</span> Locations</th>
					</tr>
					<tr>					
						<th align="center"><pre class="directory">BLAST/<pre></th>
						<th align="center"><pre class="directory">download/</pre></th>
						<th align="center"><pre class="directory">GSQ/</pre></th>
						<th align="center"><pre class="directory">GTH/</pre></th>
						<th align="center"><pre class="directory">CpGAT/</pre></th>
						<th align="center"><pre class="directory">XGDB_MYSQL/</pre></th>
					</tr>
				</thead>
				<tbody>
				<tr>
					<td align="left" class="gseg" class="Input_Data_Type">Genome Segments</td>
					<td align="center" class="Format"><a href="http://blast.ncbi.nlm.nih.gov/blastcgihelp.shtml">DNA fasta</a></td>
					<td align="center" class="Filename">~gdna.fa</td>
					<td align="left" class="Input_For indent1">Load gseg table; <br /> Spliced alignment (GeneSeqer, GenomeThreader); Blast Index;<br /><a href="XGDB/help/gaeval.php">GAEVAL</a>;<br /> Vmatch; <br />CpGAT gene finders </td>
					<td align="center" class="BLAST">GDB&#35;scaffold</td>
					<td align="center" class="download">~gdna.fa</td>
					<td align="center" class="GENESEQER"><pre class="directory">SCFDIR/</pre>GDB&#35;scaffold</td>
					<td align="center" class="GTH">n/a</td>
					<td align="center" class="CpGAT">~scaf.fas; see <a target="_new" href="/XGDB/help/cpgat.php#cpgat_output_files">CpGAT Output</a></td>
					<td align="center" class="XGDB_MYSQL">GDB&#35;scaffold</td>
					<td align="center" class="Track">GSEG Track:<img src="/XGDB/images/scaff.png" alt=""> </td>
				</tr>
				<tr>
					<td align="left" class="transcript" class="Input_Data_Type"> Transcripts:<br />EST <br />  cDNA <br />  PUT</td>
					<td align="center" class="Format"><a href="http://blast.ncbi.nlm.nih.gov/blastcgihelp.shtml">DNA fasta</a></td>
					<td align="center" class="Filename">~est.fa ~cdna.fa ~tsa.fa</td>
					<td align="left" class="Input_For indent1">Load est table; <br > Spliced-alignment (GeneSeqer); <br />Blast Index; <br />CpGAT (from GSQ output)</td>
					<td align="center" class="BLAST">GDB&#35;[est cdna put] </td>
					<td align="center" class="download">~est.fa<br /><br />gsqest.gsq</td>
					<td align="center" class="GENESEQER"><pre class="directory">MRNADIR/</pre>GDB&#35;est<br /><br /><pre class="directory">GSQOUT/</pre>gsq.GDB&#35;est</td>
					<td align="center" class="GTH">n/a</td>
					<td align="center" class="CpGAT">see <a target="_new" href="/XGDB/help/cpgat.php#cpgat_output_files">CpGAT Output</a></td>
					<td align="center" class="XGDB_MYSQL">GDB&#35;est <br /><br /> gseg_est_good_pgs</td>
					<td align="center" class="Track">EST Track:<img src="/XGDB/images/transcripts_est.png" alt=""> <br />cDNA Track:<img src="/XGDB/images/transcripts_cdna.png" alt=""><br />PUT Track:<img src="/XGDB/images/transcripts_put.png" alt="">; <br /><br />Seq. Record</td>
				</tr>
				<tr>
					<td align="left" class="protein" class="Input_Data_Type"> Related- species Protein</td>
					<td align="center" class="Format"><a href="http://blast.ncbi.nlm.nih.gov/blastcgihelp.shtml">Protein fasta</a></td>
					<td align="center" class="Filename">~prot.fa</td>
					<td align="left" class="Input_For indent1">Load pep table; <br />Spliced-alignment (GenomeThreader);; <br />CpGAT (from GTH output)</td>
					<td align="center" class="BLAST">QUERYpep</td>
					<td align="center" class="download">~prot.fa<br /><br />gth.prot.gth</td>
					<td align="center" class="GENESEQER">n/a</td>
					<td align="center" class="GTH"><pre class="directory">GTHOUT/</pre> gth.GDB&#35;prot<br /><br /><pre class="directory">Protein/</pre>GDB&#35;prot<br /><br /><pre class="directory">SCFDIR/</pre> GDB&#35;scaffold</td>
					<td align="center" class="CpGAT">see <a target="_new" href="/XGDB/help/cpgat.php#cpgat_output_files">CpGAT Output</a></td>
					<td align="center" class="XGDB_MYSQL">gseg_pep_good_pgs</td>
					<td align="center" class="Track">Query-Prot.Track:<img src="/XGDB/images/proteins.png" alt="">; <br /><br />Seq. Record; <br /><br />Aligned Prot. Table</td>
				</tr>
				<tr>
					<td align="left" class="model" class="Input_Data_Type">Precomputed <br /> Gene Models</td>
					<td align="center" class="Format"><a href="http://www.sequenceontology.org/gff3.shtml">GFF3</a></td>
					<td align="center" class="Filename">~annot.gff3</td>
					<td align="left" class="Input_For indent1">load gene annotation table; <br /> <a href="XGDB/help/gaeval.php">GAEVAL</a></td>
					<td align="center" class="BLAST">n/a</td>
					<td align="center" class="download">~annot.gff3</td>
					<td align="center" class="GENESEQER">n/a</td>
					<td align="center" class="GTH">n/a</td>
					<td align="center" class="CpGAT">see <a target="_new" href="/XGDB/help/cpgat.php#cpgat_output_files">CpGAT Output</a></td>
					<td align="center" class="XGDB_MYSQL">gseg_gene_annotation<br /><br />gaevalFlagSQL</td>
					<td align="center" class="Track">Anno. Track:<img src="/XGDB/images/genemodels.png" alt="">; <br/>Annotation Record; <br />Precomp. Loci Table; <br > GAEVAL Table</td>
				</tr>
				<tr>
					<td align="left" class="model" class="Input_Data_Type">Precomputed Model Transcripts</td>
					<td align="center" class="Format"><a href="http://blast.ncbi.nlm.nih.gov/blastcgihelp.shtml">DNA fasta</a></td>
					<td align="center" class="Filename">~annot.mrna.fa</td>
					<td align="left" class="Input_For indent1">BLAST index</td>
					<td align="center" class="BLAST">GDB&#35;transcript</td>
					<td align="center" class="download">~annot.mrna.fa</td>
					<td align="center" class="GENESEQER">n/a</td>
					<td align="center" class="GTH">n/a</td>
					<td align="center" class="CpGAT">see <a target="_new" href="/XGDB/help/cpgat.php#cpgat_output_files">CpGAT Output</a></td>
					<td align="center" class="XGDB_MYSQL">n/a</td>
					<td align="center" class="Track"> Region Download <br /></td>
				</tr>
				<tr>
					<td align="left" class="model" class="Input_Data_Type">Precomputed Model Translations</td>
					<td align="center" class="Format"><a href="http://blast.ncbi.nlm.nih.gov/blastcgihelp.shtml">protein fasta</a></td>
					<td align="center" class="Filename">~annot.pep.fa</td>
					<td align="left" class="Input_For indent1">BLAST index; Load descriptions</td>
					<td align="center" class="BLAST">GDB&#35;pep</td>
					<td align="center" class="download">~annot.pep.fa</td>
					<td align="center" class="GENESEQER">n/a</td>
					<td align="center" class="GTH">n/a</td>
					<td align="center" class="CpGAT">see <a target="_new" href="/XGDB/help/cpgat.php#cpgat_output_files">CpGAT Output</a></td>
					<td align="center" class="XGDB_MYSQL">seg_gene_annotation (description)</td>
					<td align="center" class="Track"> Region Download;<br /> Anno. Record </td>
				</tr>
				<tr>
					<td align="left" class="transcript" class="Input_Data_Type">Precomputed Spliced Alignments (Transcript)</td>
					<td align="center" class="Format">GeneSeqer (EST, CDNA, PUT)</td>
					<td align="center" class="Filename">~est.gsq</td>
					<td align="left" class="Input_For indent1">Load est_good_pgs table; <br >CpGAT Augustus, PASA</td>
					<td align="center" class="BLAST">n/a</td>
					<td align="center" class="download">gsqest.gsq </td>
					<td align="center" class="GENESEQER"><pre class="directory">MRNADIR/</pre>GDB&#35;est<br /><br /><pre class="directory">GSQOUT/</pre>gsq.GDB&#35;est</td>
					<td align="center" class="GTH">n/a</td>
					<td align="center" class="CpGAT">see <a target="_new" href="/XGDB/help/cpgat.php#cpgat_output_files">CpGAT Output</a></td>
					<td align="center" class="XGDB_MYSQL">gseg_est_good_pgs</td>
					<td align="center" class="Track">EST Trk:<img src="/XGDB/images/transcripts_est.png" alt="">;<br />cDNA Trk:<img src="/XGDB/images/transcripts_cdna.png" alt="">;<br />PUT Trk:<img src="/XGDB/images/transcripts_put.png" alt="">;</td>
				</tr>					
				<tr>
					<td align="left" class="protein" class="Input_Data_Type">Precomputed Spliced Alignments (Protein)</td>
					<td align="center" class="Format">GenomeThreader (PEP)</td>
					<td align="center" class="Filename">~prot.gth</td>
					<td align="left" class="Input_For indent1">Load pep_good_pgs table; <br />CpGAT Augustus, PASA</td>
					<td align="center" class="BLAST">n/a</td>
					<td align="center" class="download plaintext">gth.PEPresult</td>
					<td align="center" class="GENESEQER">n/a</td>
					<td align="center" class="GTH"><pre class="directory">GTHOUT/</pre>gth.GDB&#35;prot<br /><br /><pre class="directory">Protein/</pre>GDB&#35;prot<br /><br /><pre class="directory">SCFDIR/</pre>GDB&#35;scaffold</td>
					<td align="center" class="CpGAT">see <a target="_new" href="/XGDB/help/cpgat.php#cpgat_output_files">CpGAT Output</a></td>
					<td align="center" class="XGDB_MYSQL">gseg_pep_good_pgs</td>
					<td align="center" class="Track">Query_Protein Track: <img src="/XGDB/images/proteins.png" alt="">; <br /> Sequence Record; <br /> Aligned Proteins Table </td>
				</tr>				
				<tr>
					<td align="left" class="description" class="Input_Data_Type">Gene Descriptions</td>
					<td align="center" class="Format">tab-delimited</td>
					<td align="center" class="Filename">annot.desc.txt<br />cpgat.desc.txt</td>
					<td align="left" class="Input_For indent1">Load Custom Descriptions (Precomputed)</td>
					<td align="center" class="BLAST">n/a</td>
					<td align="center" class="download">annot.desc.txt<br />cpgat.desc.txt</td>
					<td align="center" class="GENESEQER">n/a</td>
					<td align="center" class="GTH"></td>
					<td align="center" class="CpGAT">see <a target="_new" href="/XGDB/help/cpgat.php#cpgat_output_files">CpGAT Output</a></td>
					<td align="center" class="XGDB_MYSQL">gseg_gene_annotation <br />
					gseg_gene_annotation (Description)</td>
					<td align="center" class="Track"><img src="/XGDB/images/genemodels.png" alt=""> <img src="/XGDB/images/cpgatmodels.png" alt=""></td>
				</tr>
				<tr>
					<td align="left" class="index" class="Input_Data_Type">Reference Protein Blast Index</td>
					<td align="center" class="Format"><a href="http://www.ncbi.nlm.nih.gov/books/NBK1763/">makeblastdb</a></td>
					<td align="center" class="Filename"><pre class="directory">/[myCpGAT]/</pre>~ <br />~.phr<br />~.pin<br />etc.</td>
					<td align="left" class="Input_For indent1">BLAST similarity (CpGAT)</td>
					<td align="center" class="BLAST">n/a</td>
					<td align="center" class="download">n/a</td>
					<td align="center" class="GENESEQER">n/a</td>
					<td align="center" class="GTH">n/a</td>
					<td align="center" class="CpGAT">see <a target="_new" href="/XGDB/help/cpgat.php#cpgat_output_files">CpGAT Output</a></td>
					<td align="center" class="XGDB_MYSQL">gseg_cpgat_gene_annotation</td>
					<td align="center" class="Track">CpGAT_Anno Track:<img src="/XGDB/images/cpgatmodels.png" alt=""> <br />CpGAT Record (Description); <br />CpGAT Loci Table; <br />GAEVAL Table</td>
				</tr>
				<tr>
					<td align="left" class="index" class="Input_Data_Type">Repeat Mask Index</td>
					<td align="center" class="Format"><a href="http://www.vmatch.de/">mkvtree</a></td>
					<td align="center" class="Filename"><pre class="directory">/[myRepeatMask]/ </pre> ~.sti1<br />~.ssp<br />~.sds<br /> etc.</td>
					<td align="left" class="Input_For indent1">Vmatch repeat mask (CpGAT)</td>
					<td align="center" class="BLAST">n/a</td>
					<td align="center" class="download">n/a</td>
					<td align="center" class="GENESEQER">n/a</td>
					<td align="center" class="GTH">n/a</td>
					<td align="center" class="CpGAT">see <a target="_new" href="/XGDB/help/cpgat.php#cpgat_output_files">CpGAT Output</a></td>
					<td align="center" class="XGDB_MYSQL">n/a</td>
					<td align="center" class="Track">n/a</td>
				</tr>
</tbody></table>

