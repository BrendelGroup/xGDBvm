<div class="feature" id="benchmarks">

	<h2 class="bottommargin1">HPC Benchmarks</h2>
	
		<table class="featuretable topmargin1">
						<colgroup>
							<col width ="10%" />
							<col width ="10%" />
							<col width ="20%" />
							<col width ="5%" />
							<col width ="5%" />
							<col width ="50%" />
						</colgroup>
		<tbody>
		    <tr style="text-align: center" class="reverse_1">
		        <th>Program</th>
		        <th>System</th>
		        <th>Processor Architecture</th>
		        <th>Min Threads</th>
		        <th>Max Threads</th>
		        <th>HPC strategy</th>
		    </tr>
			<tr>
				<td>
				    <span class="bold">GeneSeqer-5.0u1</span>
				</td>
				<td>
				    <a href="https://www.tacc.utexas.edu/user-services/user-guides/stampede-user-guide">Stampede</a>
				</td>
				<td>
				    two 8-Core Xeon processors (16 threads) per node
				</td>
				<td>
				    8
				</td>
				<td>
				    64
				</td>
				<td>
				    <b>(1)</b> Divide genome fasta file into roughly equal-sized parts according to <b>number of half-nodes</b> assigned (e.g. 1, 2, 3, or 4) <br />
				    <b>(2)</b> Split mRNA according to dataset size (50 MB per subset);<br />
				    <b>(3)</b> Assign a different mRNA subset to each of seven processors per half-node for spliced alignment and create a combined output; <br />
				    <b>(4)</b>Combine each half-node output into single output file, 
				</td>
			</tr>
			<tr>
				<td>
				<span class="bold">gth-lonestar-1.0</span>
				</td>
				<td>
				    <a href="https://www.tacc.utexas.edu/user-services/user-guides/lonestar-user-guide">Lonestar</a>
				</td>
				<td>
				    two 6-Core processors (12 threads) per node
				</td>
				<td>
				    6
				</td>
				<td>
				    36
				</td>
				<td>
				    <b>(1)</b> Divide genome fasta file into roughly equal-sized parts according to <b>standard split size</b> of 10 Mb. 
				    <br /> 
				    <b>(2)</b> Splice-align each genome part using the whole protein dataset. 
				    <br />
				    <b>(3)</b>Combine individual outputs into single output file, <span class="plaintext">GDB00n.prot.gth</span>
				</td>
			</tr>
		</tbody>
	</table>
<p><span class="heading smallerfont linkback"> <a class="smallerfont" href="/XGDB/help/create_gdb.php#jobs_programs">View this in Help Context</a> (create_gdb.php/jobs_programs)</span></p>
	</div>