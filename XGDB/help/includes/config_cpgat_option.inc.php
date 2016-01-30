
<div class="dialogcontainer">
	<h2 class="bottommargin1">CpGAT Option - Configuration Page </h2>
	<p>Selecting <b>Run CpGAT? Yes</b> under <b>Input Data</b> will produce gene structure models for this genome, based on previously-generated spliced alignment data and/or <i>ab initio</i> genefinder data. Models can be viewed in genome context on a track called "CpGAT_Annotation_mRNA".</p>
	<p>You can run CpGAT as part of the "Create Database" process, or subsequently as a "Database Update" option.</p>
	<p>To run CpGAT with "Create Database":</p>
	<ol class="orderedlist1 indent2">
        <li> Under <b>'Gene Prediction (CpGAT)'</b>, select  <b>'Run CpGAT?' ='Yes'</b>. This tells the pipeline to run CpGAT if the correct inputs are found</li>
        <li> Then complete the other entries under Gene Prediction:
            <ul class="bullet1">
                <li> Designate a <b>Reference Protein Index File and Path</b> that points to a blast index based on a reference dataset (e.g. from UniRef90 viridiplantae)
                    <ul>
                        <li>(if none is designated, CpGAT will use a default index of 'core' eukaryotic proteins)</li>
                    </ul>
                </li>
                <li> Optionally, designate a <b>Repeat Dataset Index File and Path</b> that points to a .fasta file containing a repeat masking dataset (NOT WORKING YET)</li>
                <li> Optionally, select <b>Filter Genes</b> to ONLY load gene models with transcript evidence</li>
                <li> Click to specify each <i>ab initio</i> gene finder species model, or disable by clicking "none"</li>
                <li> Click to specify any other non-default options, e.g. Skip Pasa, Filter Genes.</li>
            </ul>
        </li>
        <li> Click <b>'Save'</b> to save your configuration.</li>
        <li> Make sure all data files with correct filenames are present in designated directories</li>
        <li> Now click <b>'Data Process Options...' &rarr; 'Create Database'</b> to start the process.</li>
        <li> GDB creation/CpGAT annotation may take from less a minute to many hours, depending on genome segment size/number, and number of transcripts/proteins to align.
            <ul class="bullet1">
                <li> You can monitor progress by viewing the <b>CpGAT Log </b>, available from the Config page</li>
            </ul>
        </li>
        
        <li> When complete, view CpGAT annotations in genome context (track name: CpGAT_Annotation_mRNA)
            <ul class="bullet1">
                <li> CpGAT outputs and intermidiate files can be viewed/downloaded by visiting <i>Download Data</i>&rarr;<i>CpGAT</i></li>
            </ul>
        </li>
	</ul>

    <p>For details on CpGAT, visit the <a href="/XGDB/help/cpgat.php">CpGAT help</a> page</p>.
			<span class="heading normalfont linkback"> <a class="smallerfont" href="/XGDB/help/create_gdb.php#config_cpgat_option">View this in Help Context</a> (create_gdb.php/config_cpgat_option)</span>


</div>
