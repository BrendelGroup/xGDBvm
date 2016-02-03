
<div class="dialogcontainer">
	<h1>BlastAllGDB</h1>

	<p>This tool uses NCBI Blastall to compare sequences across multiple genomes at PlantGDB.</p>

	
	<p>Query examples and options to select for each:</p>

	<ul class="bullet1">
		<li>
			Find gene CDS translations similar to a protein of interest <span class="italic">(Protein Databases; Protein Dataset(s); blastp)</span>
		</li>
		<li>
			Find gene CDS translations similar to a nucleotide of interest <span class="italic">(Protein Databases; Protein Dataset(s); blastx)</span>
		</li>
		<li>
			Find gene CDS or transcripts similar to a protein of interest <span class="italic">(Transcript Databases; CDS/Transcript Dataset(s); tblastn)</span>
		</li>
		<li>
			Find gene CDS or transcripts similar to a nucleotide of interest <span class="italic">(Transcript Databases; CDS/Transcript Dataset(s); blastn)</span>
		</li>
		<li>
			Find splice-aligned transcripts (EST, cDNA, PUT) similar to a protein of interest <span class="italic">(Transcript Databases; EST - cDNA - PUT Dataset(s); tblastn)</span>
		</li>
		<li>
			Find splice-aligned transcripts (EST, cDNA, PUT) similar to a nuleotide of interest <span class="italic">(Transcript Databases; EST - cDNA - PUT Dataset(s); blastn)</span>
		</li>
		<li>
			Find genome region similar to a protein of interest <span class="italic">(Genome Databases; Genome/BAC Dataset(s); tblastn)</span>
		</li>
	</ul>
	<p><b>Please note</b> that if an EST, cDNA or PUT does NOT have a spliced alignment with the designated genome, it will not be searchable in this BLAST dataset. If you want to BLAST all known transcript data for a species, use <a href="/cgi-bin/blast/PlantGDBblast"> PlantGDB BLAST</a> instead!</p>
	<p><b>*FASTA Datasets </b> are all available for download from PlantGDB's <a class="hidelinkicon" target="_blank" href="http://plantgdb.org/XGDB/phplib/resource.php">Genome Browser Resources</a></p>

</div>
