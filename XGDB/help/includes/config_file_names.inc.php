<div class="dialogcontainer"  id="filename_requirements" >
	<h2> Filename requirements: </h2>
	<p><a href="/XGDB/conf/data.php">View as web page</a>; <span class="normalfont">See also: <a href="/XGDB/conf/input_output.php">Inputs - Outputs</a></span></p>
		<span class="heading"> (<span class="alertnotice">~</span> refers to user-specified portion of filename)</span> 
	<table class="featuretable topmargin1">
		<tbody>
		    <tr style="text-align: center" class="reverse_1">
		        <th>Data type</th>
		        <th>Filename</th>
		        <th>Description</th>
		        <th>File format</th>
		        <th>FASTA header Examples, Notes</th>
		    </tr>
			<tr>
				<td style="text-align:center" rowspan="2">
				<span class="bold"> Genomic sequence</span><br />
				<span class="heading">(at least one required)</span>
				</td>
				<td><span class="plaintext largerfont">~gdna.fa </span></td>
				<td>Genome sequence files (chromosomes, BACs, or scaffolds)</td>
				<td rowspan="2">FASTA</td>
				<td rowspan="2"><span class="plaintext largerfont">&#62;gi|527290389|gb|KE504633.1| Elaeis oleifera genomic scaffold o8_sc00001</span><br /><span class="plaintext largerfont">&#62;Scaffold_1</span><br /><span class="plaintext largerfont">&#62;Chr1</span></td>
			</tr>
			<tr>
				<td><span class="plaintext largerfont">~gdna.rm.fa </span></td>
				<td>Hard-masked ('N') genome sequence, will be used for GeneSeqer spliced alignments ONLY</td>
			</tr>
			<tr style="background-color:#EEE">
				<td rowspan="4" style="text-align:center"><img src="/XGDB/images/transcripts_est.png" alt="?" />  <img src="/XGDB/images/transcripts_put.png" alt="?" /> <img src="/XGDB/images/transcripts_cdna.png" alt="?" /> <img src="/XGDB/images/proteins.png" alt="?" /> <br /><span class="bold">Transcript and/or protein sequence</span> <br /><span class="heading">(for spliced alignment; must include at least one)</span></td>
				<td> <span class="plaintext largerfont">~est.fa </span></td>
				<td>EST sequence file(s)</td>
				<td rowspan="4">FASTA</td>
				<td><span class="plaintext largerfont">&#62;gi|111142763|gb|EE256410.1|EE256410 Castor</span><br /><span class="plaintext largerfont">&#62;EE256410.1</span></td>
			</tr>
			<tr style="background-color:#EEE">
                <td> <span class="plaintext largerfont">~tsa.fa </span></td>
                <td>Transcript assembly sequence files</td><td><span class="plaintext largerfont">&#62;PUT-163a-Ricinus_communis-8201</span></td></tr>
                <tr style="background-color:#EEE"><td> <span class="plaintext largerfont">~cdna.fa </span></td>
                <td>cDNA sequence file(s)</td>
                <td><span class="plaintext largerfont">&#62;gi|94449065|gb|DQ473580.1| Tic40 mRNA</span><br /><span class="plaintext largerfont">&#62;DQ473580.1</span>
                </td>
            </tr>
            <tr style="background-color:#EEE">
                <td><span class="plaintext largerfont">~prot.fa </span></td>
                <td>Predicted protein sequences from related species</td>
                <td><span class="plaintext largerfont">&#62;Medtr4g033160.1 Cupin</span></td>
			</tr>
			<tr>
				<td rowspan="4" style="text-align:center"><img src="/XGDB/images/transcripts_est_precomp.png" alt="?" /> <img src="/XGDB/images/transcripts_put_precomp.png" alt="?" /> <img src="/XGDB/images/transcripts_cdna_precomp.png" alt="?" /> <img src="/XGDB/images/proteins_precomp.png" alt="?" /> <br /><b>Pre-computed spliced alignments</b><br /><span class="heading">(e.g. offline GeneSeqer/GenomeThreader output files, optional)</span></td>
				<td><span class="plaintext largerfont">~est.gsq </span></td>
				<td>EST spliced alignments (GeneSeqer)</td>
				<td>GeneSeqer </td>
				<td rowspan="4">
				1) You <b>must include</b> the corresponding fasta sequence files	 (<span class="plaintext largerfont">~est.fa, ~cdna.fa</span>, etc.) for each output file.<br />
				2) Make sure sequence IDs in the output file match respective data types:
					<ul class="bullet1">
						<li>
						    Transcript/protein IDs in your output file <b>must match</b> the IDs in the corresponding FASTA files (<span class="plaintext largerfont">~est.fa, ~cdna.fa</span>, etc.).
						</li>
						<li>
							The Genome Segment IDs in your output file <b>must match</b> the IDs in your genome FASTA files (<span class="plaintext largerfont">~gdna.fa</span>)
						</li>
						<li>
								<a title='Look for the MATCH line in your GeneSeqer output file, and check IDs' class='image-button' id='GSQ_id_match:604:240'>
									See an example:<br /> <img title='GeneSeqer IDs' class='image-button' src='/XGDB/help/images/GSQ_id_match.thumb.png' alt='?' />
								</a>
						</li>
					</ul>
				</td>
			</tr>
			<tr>
			    <td> <span class="plaintext largerfont">~tsa.gsq </span></td><td>transcript assembly spliced alignments (GeneSeqer)</td><td>GeneSeqer output </td>
			</tr>
			<tr>
			    <td> <span class="plaintext largerfont">~cdna.gsq </span></td><td>cDNA spliced alignments (GeneSeqer)</td><td>GeneSeqer output</td>
			</tr>
			<tr>
			    <td><span class="plaintext largerfont">~prot.gth</span></td><td>Related species protein spliced alignments (GenomeThreader)</td><td>GenomeThreader output</td>
			</tr>
			<tr style="background-color:#EEE">
				<td rowspan="4" style="text-align:center"><b><img src="/XGDB/images/genemodels_precomp.png" alt="?" /> Pre-computed annotations </b><br /><span class="heading">(e.g. published annotations; optional)</span></td>
				<td> <span class="plaintext largerfont">~annot.gff3</span></td>
				<td>gene models</td>
				<td>GFF3 Format</td>
				<td> IDs in the GFF3 table <b>must match</b> ID's found in corresponding FASTA files (<span class="plaintext largerfont">~gdna.fa,~mrna.fa</span>)</td>
			</tr>
			<tr style="background-color:#EEE">
				<td><span class="plaintext largerfont">~annot.mrna.fa</span></td>
				<td>gene model mRNA transcripts</td>
				<td rowspan="2" >FASTA</td>
				<td>See note above; <br /> Example:<span class="plaintext largerfont"> &#62;28153.m000272</span></td>
			</tr>
			<tr style="background-color:#EEE">
				<td> <span class="plaintext largerfont">~annot.pep.fa</span></td>
				<td>gene model peptide translations</td>
				<td>Optional; used primarily for BLAST index.</td>
			</tr>
			<tr style="background-color:#EEE">
				<td><span class="plaintext largerfont">~annot.desc.txt</span></td>
				<td>gene model descriptions</td><td>Tab delimited</td>
				<td>IDs <b>must match</b> those of the corresponding FASTA files (<span class="plaintext largerfont">~annot.mrna.fa</span>)</td>
			</tr>
			<tr>
				<td rowspan="4" style="text-align:center"><img src="/XGDB/images/cpgatmodels_precomp.png" alt='?' /> <b>Pre-computed annotations</b><br /><span class="heading">(e.g. from offline CpGAT; optional)</span></td>
				<td> <span class="plaintext largerfont">~cpgat.gff3</span></td>
				<td>gene models</td>
				<td>GFF3 Format</td>
				<td>IDs <b>must match</b> those of the corresponding FASTA files (<span class="plaintext largerfont">	~gdna.fa, cpgat.mrna.fa</span></td>
			</tr>
			<tr>
				<td><span class="plaintext largerfont">~cpgat.mrna.fa</span></td>
				<td>gene model mRNA transcripts</td>
				<td rowspan="2" >FASTA</td>
				<td>See note above; <br /> Example:<span class="plaintext largerfont"> &#62;28153.m000272</span></td>
			</tr>
			<tr>
				<td> <span class="plaintext largerfont">~cpgat.pep.fa</span></td>
				<td>gene model peptide translations</td>
				<td>Optional; used primarily for BLAST index.</td>
			</tr>
			<tr>
			    <td><span class="plaintext largerfont">~cpgat.desc.txt</span></td>
			    <td>gene model descriptions</td>
			    <td>Tab delimited</td><td>IDs <b>must match</b> those of the corresponding FASTA files (<span class="plaintext largerfont">~cpgat.mrna.fa)</span></td>
			</tr>
			<tr style="background-color:#EEE">
				<td style="text-align:center">
				    <b>Reference Protein Dataset </b><br /><span class="heading">(required for optional CpGAT annotation)</span>
				</td>
				<td>
					<span class="plaintext largerfont">~.fa</span>
				</td>
				<td>
					A well-curated <a href="/XGDB/help/cpgat.php#config_cpgat_refprotein"> Reference Protein Library</a> (fasta-formatted), used for validating gene predictions in <a href="/XGDB/help/cpgat.php\">CpGAT</a>
				</td>
				<td>
					FASTA
				</td>
				<td>
					Place file in <span class="plaintext largerfont">/xGDBvm/input/referenceprotein/</span> directory select it from the appropriate dropdown. This dataset will be BLAST-indexed by the pipeline using <span class="plaintext">makblastdb</span>.
				</td>
			</tr>
			<tr>
				<td style="text-align:center"> <b>Repeat Mask Dataset </b>
				<br /><span class="heading">(optional, for GeneSeqer)</span></td>
				<td>
					<span class="plaintext largerfont">~.fa</span>
				</td>
				<td>
					A Repeat Sequence Library (fasta-formatted) to be used when the <a href="/XGDB/help/create_gdb.php#config_repmask_option">Repeat Masking</a> option for GeneSeqer is selected, or for <i>ab initio</i> gene prediction in <a href="/XGDB/help/cpgat.php\">CpGAT</a>.
				</td>
				<td>
					FASTA
				</td>
				<td>
					Place file in <span class="plaintext largerfont">/xGDBvm/input/repeatmask/</span> directory and select it from the appropriate dropdown. This dataset will be indexed by the pipeline using <span class="plaintext">makevtree/vmatch</span>.
				</td>
			</tr>
		</tbody>
	</table>
	<!--p><sup>1</sup> If running CpGAT gene annotation, short read assemblies need to be EST data type rather than TSA, as CpGAT is not configured to use TSA data type.</p-->
	<span class="heading normalfont linkback"> <a class="smallerfont" href="/XGDB/help/create_gdb.php#config_file_names">View this in Help Context</a> (create_gdb.php/config_file_names)</span>
 </div>
