<div class="dialogcontainer">
	<h2> Input Data File Requirements: </h2>
	
<p><span class='warning'>permissions</span> flag indicates that the Web server does not have permission to read your input file (<span class='tip_style'>To fix this, on shell: <span class='plaintext largerfont'>$ chmod a+r [myfile]</span></span>) - see also <a href="/XGDB/help/create_gdb.php#config_data_permissions">File Permissions </a></p>

<p><span class="checked">Valid</span> Filename Conventions: see table below 
 <span class="heading"> (<span class="alertnotice">~</span> refers to user-specified portion of filename)</span>   (<a target="_blank" href="/XGDB/conf/data.php">Expanded Table</a>)</p>
	<table class="featuretable topmargin1">
						<colgroup>
							<col width ="60%" />
							<col width ="40%" />
						</colgroup>
		<tbody>
            <tr style="text-align: left" class="reverse_1 bold">
                <th>Data type</th>
                <th>Filename Convention</th>
            </tr>
			<tr>
				<td style="text-align:left">
                    <span class="bold"> Genomic sequence</span>
                    <br />
                    <span class="heading">(required, optionally repeat masked (.rm))</span>
                    </td>
				<td><span class="plaintext largerfont">~gdna.fa </span> or <span class="plaintext largerfont">~gdna.rm.fa </span></td>
			</tr>
			<tr style="background-color:#EEE">
				<td rowspan="4" style="text-align:left"><img src="/XGDB/images/transcripts_est.png" alt="?" />  <img src="/XGDB/images/transcripts_put.png" alt="?" /> <img src="/XGDB/images/transcripts_cdna.png" alt="?" /> <img src="/XGDB/images/proteins.png" alt="?" /> <br /><span class="bold">Transcript and/or protein sequence</span> <br /><span class="heading">(for spliced alignment; must include at least one)</span></td>
				<td> <span class="plaintext largerfont">~est.fa </span></td>
			</tr>
			<tr style="background-color:#EEE">
				<td> <span class="plaintext largerfont">~tsa.fa </span></td>
			</tr>
			<tr style="background-color:#EEE">
				<td><span class="plaintext largerfont">~cdna.fa </span></td>
			</tr>
			<tr style="background-color:#EEE">
				<td><span class="plaintext largerfont">~prot.fa </span></td>
			</tr>
			<tr>
				<td rowspan="4" style="text-align:left"><img src="/XGDB/images/transcripts_est_precomp.png" alt="?" /> <img src="/XGDB/images/transcripts_put_precomp.png" alt="?" /> <img src="/XGDB/images/transcripts_cdna_precomp.png" alt="?" /> <img src="/XGDB/images/proteins_precomp.png" alt="?" /> 
				<br /><b>Pre-computed spliced alignments</b><br /><span class="heading">(e.g. offline GeneSeqer/GenomeThreader output files, optional)</span>
				</td>
				<td><span class="plaintext largerfont">~est.gsq </span></td>
			</tr>
			<tr>
				<td> <span class="plaintext largerfont">~tsa.gsq </span></td>
			</tr>
			<tr>
				<td> <span class="plaintext largerfont">~cdna.gsq </span></td>
			</tr>
			<tr>
				<td><span class="plaintext largerfont">~prot.gth</span></td>
			</tr>
			<tr style="background-color:#EEE">
				<td rowspan="4" style="text-align:left"><b><img src="/XGDB/images/genemodels_precomp.png" alt="" /> Pre-computed annotations </b><br /><span class="heading">(e.g. published annotations; optional)</span></td>
				<td> <span class="plaintext largerfont">~annot.gff3</span></td>
			</tr>
			<tr style="background-color:#EEE">
				<td><span class="plaintext largerfont">~annot.mrna.fa</span></td>
			</tr>
			<tr style="background-color:#EEE">
				<td> <span class="plaintext largerfont">~annot.pep.fa</span></td>
			</tr>
			<tr style="background-color:#EEE">
				<td><span class="plaintext largerfont">~annot.desc.txt</span></td>
			</tr>
			<tr>
				<td rowspan="4" style="text-align:left"><img src="/XGDB/images/cpgatmodels_precomp.png" alt=""/> <b>Pre-computed annotations</b><br /><span class="heading">(e.g. from offline CpGAT; optional)</span></td>
				<td> <span class="plaintext largerfont">~cpgat.gff3</span></td>
			</tr>
			<tr>
				<td><span class="plaintext largerfont">~cpgat.mrna.fa</span></td>
			</tr>
			<tr>
				<td> <span class="plaintext largerfont">~cpgat.pep.fa</span></td>
			</tr>
			<tr>
				<td>
				<span class="plaintext largerfont">~cpgat.desc.txt</span></td>
			</tr>
			<tr  style="background-color:#EEE">
				<td>
					<b>Reference Protein Dataset</b> <span class="heading">Required for CpGAT annotation</span>
				</td>
				<td> <span class="plaintext largerfont">~.fa</span></td>
			</tr>
			<tr>
				<td>
					<b>Repeat Mask Dataset</b> <span class="heading">Optional, for GeneSeqer</span>
				</td>
				<td>
				<span class="plaintext largerfont">~.fa</span>
				</td>
			</tr>
		</tbody>
	</table>
	<span class="heading normalfont linkback"> <a class="smallerfont" href="/XGDB/help/create_gdb.php#config_file_names_brief">View this in Help Context</a> (create_gdb.php/config_file_names_brief)</span>
 </div>
