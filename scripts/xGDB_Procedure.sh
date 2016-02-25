#!/bin/bash
#############################################################################################################################
#############################  xGDBvm pipeline shell script, called from xGDBvm web interface ###############################
#############################################################################################################################
#
# Naming conventions of data sets under $dataPath: *est.fa, *pep.fa,*gdna.fa, *annot.gff3, etc.
# Note that data type "tsa" or Transcript Sequence Assembly is also referred to (esp. in MySQL tables) under the abbreviation "put" or "PUT" (putative unique transcript), a legacy name for TSA
# Pre-requisite: xGDBvm image, xGDB databases initiated: ./iPlantMySQLini.sh
# 'getopt' arguments ([]=optional) include: -i createInformation [-e editPaths], -g GSQ parameters, -t GTH parameters, -c GFF type [deprecated] [-r repeatMask], [-a CpGAT parameters] [-m GSQ_CompResParameter]  [-n GTH_CompResParameter]
# Pipeline is 'Create' mode unless update parameters are present, then it is run in 'Update' mode
# Script functions for 'Create' mode are FirstPart(), RunCpGAT() [optional] and LastPart().
# This script is arbitrarily broken into Steps 1 to 12 and U1-U15 (Update) for convenience in logging progress, and each step/substep is time stamped and logged to /xGDBvm/data/GDBnnn/logs/Pipeline_procedure.log
# Time stamped log entries follow this convention where ~ is prefix string: Step 1 ~100 (initial)..~101... ~199 (final); Step 2 ~200 ... ~299 etc.
# CpGAT option is run if CpGAT parameters are present. In this case a different logfile, CpGAT_Procedure.log will be updated for each gDNA segment annotated.
# In 'Update' mode, script functions available (not all will be used) are addGFF(), addGSEG(), addEST(), addCDNA(), addTSA(), addProtein(), replaceGFF(), replaceEST(), replaceCDNA(), repaceTSA(), repaceProtein()
# RunCpGAT() function is also optionally called by 'Update' mode, if CpGAT parameters are present and proper data flags are present. In this case CpGAT_Procedure.log is updated.

#############################################################################################################################
#########################  FirstPart function: Steps 1 to 13 and (optionally, CpGAT) 14-16 #########################
#############################################################################################################################
FirstPart() {
   
   ################################################################################################################
   # Step 1. Set up GDB directories under /xGDBvm/data/GDBnnn and /xGDBvm/data/scratch/GDBnnn and copy templates  #
   ################################################################################################################
   
   dateTime100=$(date +%Y-%m-%d\ %k:%M:%S)
   
   # Get most recent ValidationTimeStamp corresponding to this input data path, and update Processes
   
   ValidationTimeStamp=$(echo "select max(ValidationTimeStamp) from Datafiles where Path=\"$dataPath\" and ValidationTimeStamp LIKE \"${xGDB}%\""|mysql -p$dbpass -u $mysqluser Genomes -N) # most recent validation for this GDB and data path.
   ProcessTimeStamp=$dateTime100 ## this is used as unique key in Genomes.Processes
   ##### Insert Processes record   #####
       echo "insert into Processes (ProcessTimeStamp, ValidationTimestamp, GDB, ProcessType) values (\"$ProcessTimeStamp\", \"$ValidationTimeStamp\", \"$xGDB\", \"create\")"|mysql -p$dbpass -u $mysqluser Genomes
   ##### 
   mkdir $WorkDIR #  /xGDBvm/data/GDBnnn/ - path to the final destination directory for conf data and log files for each GDB
   mkdir $WorkDIR/logs/ #  /xGDBvm/data/GDBnnn/conf - path to the final destination directory for configuration files for each GDB
   touch $WorkDIR/logs/Pipeline_procedure.log
   touch $WorkDIR/logs/Pipeline_error.log
   touch $WorkDIR/logs/CpGAT_procedure.log #To be used if CpGAT is run either in 'Create' or 'Update' mode.
   nbproc=`cat /proc/cpuinfo | grep processor | wc -l`
   echo  "$sline">>$WorkDIR/logs/Pipeline_procedure.log
   echo  "* xGDB_Procedure.sh - Create GDB">>$WorkDIR/logs/Pipeline_procedure.log
   echo  "$sline">>$WorkDIR/logs/Pipeline_procedure.log
   echo  "">>$WorkDIR/logs/Pipeline_procedure.log
   startTime=$(date +%Y-%m-%d\ %k:%M:%S)
   startTimeSec=$(date +"%s") # in seconds; to calculation Duration
   echo  "Database Name = $DBname">>$WorkDIR/logs/Pipeline_procedure.log
   echo -e "Create $xGDB, initiated \c" >>$WorkDIR/logs/Pipeline_procedure.log && echo "$startTime">>$WorkDIR/logs/Pipeline_procedure.log
   echo "${space}Pipeline parameters: $BaseInfo ">>$WorkDIR/logs/Pipeline_procedure.log
   echo "${space}GeneSeqer (GSQ) parameters: $GSQparameter ">>$WorkDIR/logs/Pipeline_procedure.log
   echo "${space}GenomeThreader (GTH) parameters: $GTHparameter ">>$WorkDIR/logs/Pipeline_procedure.log
   echo "${space}CpGAT parameters: $CpGATparameter ">>$WorkDIR/logs/Pipeline_procedure.log
   echo "${space}Repeat Mask parameters: $RepeatMaskparameter ">>$WorkDIR/logs/Pipeline_procedure.log
   echo "${space}Compute Resources (GSQ): $GSQ_CompResParameter ">>$WorkDIR/logs/Pipeline_procedure.log
   echo "${space}Compute Resources (GTH): $GTH_CompResParameter ">>$WorkDIR/logs/Pipeline_procedure.log   
   echo "${space}Number of processors on VM: $nbproc ">>$WorkDIR/logs/Pipeline_procedure.log   
   echo  "">>$WorkDIR/logs/Pipeline_procedure.log
   echo "$dline" >>$WorkDIR/logs/Pipeline_procedure.log
   echo -e "| Step 1 : Create $xGDB directories and copy templates, initiated \c" >>$WorkDIR/logs/Pipeline_procedure.log && echo "$dateTime100">>$WorkDIR/logs/Pipeline_procedure.log
   echo "$dline" >>$WorkDIR/logs/Pipeline_procedure.log
   
   mkdir $WorkDIR/conf #destination directory for config files
   mkdir $tmpWorkDIR # /xGDBvm/data/scratch/GDBnnn/ - scratch directory, removed at end of pipeline.
   if [ -d $tmpWorkDIR ]
   then
      echo "${space}Created Scratch Directory, $tmpWorkDIR/ (\$tmpWorkDIR, temporary space for computation)" >>$WorkDIR/logs/Pipeline_procedure.log
   else
      error102="${space}ERROR: Unable to create Scratch Directory, $tmpWorkDIR/ (\$tmpWorkDIR, temporary space for computation) (1.02)"
      echo "$error102">>$WorkDIR/logs/Pipeline_procedure.log;        echo "$error102">>$WorkDIR/logs/Pipeline_error.log;
   fi
   mkdir $tmpWorkDIR/data
   mkdir $tmpWorkDIR/data/download
   mkdir $tmpWorkDIR/data/BLAST
   mkdir $tmpWorkDIR/data/GSQ
   mkdir $tmpWorkDIR/data/XGDB_MYSQL
   mkdir $tmpWorkDIR/data/GSQ/MRNADIR
   mkdir $tmpWorkDIR/data/GSQ/PUTDIR
   mkdir $tmpWorkDIR/data/GSQ/SCFDIR
   mkdir $tmpWorkDIR/data/GSQ/GSQOUT
   mkdir $tmpWorkDIR/data/GTH
   mkdir $tmpWorkDIR/data/GTH/GTHOUT
   mkdir $tmpWorkDIR/data/GTH/Protein
   mkdir $tmpWorkDIR/data/GTH/SCFDIR
   # - on Remote storage mounted at /xGDBvm/data/ (if present)
   mkdir $WorkDIR # /xGDBvm/data/GDBnnn/ - destination for output data
   if [ -d $WorkDIR ]
   then
      echo "${space}Created Data Directory, $WorkDIR/ (\$WorkDIR, final destination for output data)" >>$WorkDIR/logs/Pipeline_procedure.log
   else
      error103="${space}ERROR: Unable to create Data Directory, $WorkDIR/ (\$WorkDIR, final destination for output data) (1.03)"
      echo "$error103">>$WorkDIR/logs/Pipeline_procedure.log;        echo "$error103">>$WorkDIR/logs/Pipeline_error.log
   fi
   mkdir /xGDBvm/tmp/$xGDB #symlink to /xGDBvm/data/tmp/$xGDB which is the temp directory for apache-created images and cached files;
   chmod 777 /xGDBvm/tmp/$xGDB
   chmod +t /xGDBvm/tmp/$xGDB
   
   # this step deprecated?
   #    cd $WorkDIR;
   
   # copy MySQL template to working directory
   cp $ScriptDIR/TemplateFrame.sql $tmpWorkDIR/data/XGDB_MYSQL/${xGDB}TemplateFrame.sql
   
   dateTime199=$(date +%Y-%m-%d\ %k:%M:%S)
   msg199="* Step 1 completed "
   echo "$space$msg199$dateTime199" >>$WorkDIR/logs/Pipeline_procedure.log
   
   
   ########################################################################
   # Step 2. Concatenate and copy files to Blast and Download directories #
   ########################################################################
   
   # concatenate all input data files by type and copy to appropriate location in working directory
   # concatenate fasta to BLAST working directory (index it later)
   
   dateTime200=$(date +%Y-%m-%d\ %k:%M:%S)
   echo "$dline" >>$WorkDIR/logs/Pipeline_procedure.log
   echo "| Step 2: Concatenate input files and copy to Scratch Directory $tmpWorkDIR - $dateTime200" >>$WorkDIR/logs/Pipeline_procedure.log
   echo "$dline" >>$WorkDIR/logs/Pipeline_procedure.log
   
   inputpath2005=$dataPath
   msg2005="Input directory is: "
   echo "$space$msg2005$inputpath2005" >>$WorkDIR/logs/Pipeline_procedure.log
   
   echo "(a) Fasta Sequence Files (for spliced alignment) validated for defline type" >>$WorkDIR/logs/Pipeline_procedure.log

 for type in est cdna tsa prot gdna gdna.rm annot.pep annot.cds annot.mrna cpgat.pep cpgat.cds cpgat.mrna ##### Generalize get input data #####
   
   ##### for type in est # NOTE: for debug (est only) #####
   
   ## (2.0) DO TRANSCRIPT-TYPE (Assign variables according to transcript type (minus .fa suffix), and destination, and proceed with processing)
   do
      if [ $type == "est" ]; then
         step="01"; name="EST"; type_count="est_count"
      fi
      if [ $type == "cdna" ]; then
         step="02"; name="cDNA"; type_count="cdna_count"
      fi
      if [ $type == "tsa" ]; then
         step="03"; name="TSA"; type_count="tsa_count"
      fi
      if [ $type == "prot" ]; then
         step="04"; name="related-species protein"; type_count="prot_count"
      fi
      if [ $type == "gdna" ]; then
         step="05"; name="genomic DNA"; type_count="gdna_count"
      fi
      if [ $type == "gdna.rm" ]; then
         step="05"; name="masked genomic DNA"; type_count="gdnarm_count"
      fi
      if [ $type == "annot.pep" ]; then
         step="06"; name="annotation ORF translation"; type_count="annotpep_count"
      fi
      if [ $type == "annot.cds" ]; then
         step="07"; name="annotation ORF cds"; type_count="annotcds_count"
      fi
      if [ $type == "annot.mrna" ]; then
         step="08"; name="annotation ORF transcript"; type_count="annotmrna_count"
      fi
      if [ $type == "cpgat.pep" ]; then
        step="09"; name="CpGAT ORF translation"; type_count="cpgatpep_count"
      fi
      if [ $type == "cpgat.cds" ]; then
        step="10"; name="CpGAT ORF cds"; type_count="cpgatcds_count"
      fi
      if [ $type == "cpgat.mrna" ]; then
        step="11"; name="CpGAT ORF transcript"; type_count="cpgatmrna_count"
      fi
      input_dir=$dataPath
      download_destination=$tmpWorkDIR/data/download/${xGDB}${type}.fa
      blast_destination=$tmpWorkDIR/data/BLAST/${xGDB}${type}.fa
      
   if ls -1 $dataPath/*${type}.fa >/dev/null 2>&1
   then
      fcount=$(ls $dataPath/*${type}.fa|wc -l)
      echo "- $name sequence  (~${type}.fa; file count=$fcount)"  >>$WorkDIR/logs/Pipeline_procedure.log
         cat $dataPath/*${type}.fa >$tmpWorkDIR/data/download/${xGDB}${type}.fa #  cat all files to download directory
         ## validate input fasta deflines, detect duplicate entries, and write results to procedure and error logs (no file conversion!).
         $ScriptDIR/fasta-validate.pl  --logfile=$WorkDIR/logs/Pipeline_procedure.log --errorfile=$WorkDIR/logs/Pipeline_error.log $tmpWorkDIR/data/download/${xGDB}${type}.fa --step=2.${step}5
         count1=$(grep -c "^>" $tmpWorkDIR/data/download/${xGDB}${type}.fa)
      count2=$(grep -c "^>" $tmpWorkDIR/data/download/${xGDB}${type}.fa)
      if [ "$count1" -eq "$count2" ]
      then
         msg="${space}${count2} $name sequences copied from $input_dir to $download_destination (2.${step})"
         echo "$msg" >>$WorkDIR/logs/Pipeline_procedure.log
      else
         msg="WARNING: ${space}${count2} $name sequences copied to $download_destination but initial count was $count1 sequences (2.${step})"
         echo "$msg" >>$WorkDIR/logs/Pipeline_procedure.log
         echo "$msg" >>$WorkDIR/logs/Pipeline_error.log
      fi
      ## 2.10 Now copy the file to the BLAST temp directory for indexing
      cp $tmpWorkDIR/data/download/${xGDB}${type}.fa $tmpWorkDIR/data/BLAST/${xGDB}${type}.fa
      msg_blast="${space}${count2} $name sequences copied from $download_destination to $blast_destination (2.${step}5)"
      echo "$msg_blast"  >>$WorkDIR/logs/Pipeline_procedure.log

      declare $type_count=$count2 # The value of this variable variable (e.g. est_count, etc) is used later for sanity check on parsing and upload
      eval \${type_count}=${count2} # force evaluation
#debug only     echo "${space}$est_count, $cdna_count, $tsa_count, $prot_count, $gdna_count, $gdnarm_count, $annotpep_count, $annotmrna_count, $annotcds_count, $cpgatpep_count, $cpgatmrna_count, $cpgatcds_count" >>$WorkDIR/logs/Pipeline_procedure.log
   else
      echo "- $name sequence"  >>$WorkDIR/logs/Pipeline_procedure.log
      msg="${space}No $name sequences (~${type}.fa) were found in Input Directory (2.${step})"
      echo "$msg" >>$WorkDIR/logs/Pipeline_procedure.log
      declare $type_count="0"
      eval \${type_count}="0"
#debug only      echo "${space}$est_count, $cdna_count, $tsa_count, $prot_count, $gdna_count,  $gdnarm_count, $annotpep_count, $annotmrna_count, $annotcds_count, $cpgatpep_count, $cpgatmrna_count, $cpgatcds_count" >>$WorkDIR/logs/Pipeline_procedure.log
   fi

   done

   echo "(b) Gene Annotation Files (pre-computed)" >>$WorkDIR/logs/Pipeline_procedure.log

   dateTime221=$(date +%Y-%m-%d\ %k:%M:%S)
   # concatenate gff to download working directory
   if ls -1 $dataPath/*annot.gff3 >/dev/null 2>&1
   then
      echo "- Precomputed gene models as gff3 (~annot.gff3)"  >>$WorkDIR/logs/Pipeline_procedure.log
      msg221=" gene models were copied to $tmpWorkDIR/data/download/${xGDB}annot.gff3 (2.21) "
      cat $dataPath/*annot.gff3  >$tmpWorkDIR/data/download/${xGDB}annot.gff3
      count221=$(grep -c -P "\tmRNA\t" $tmpWorkDIR/data/download/${xGDB}annot.gff3) #this may not always be an accurate count!
      echo "${space}${count221}${msg221}${dateTime221}" >>$WorkDIR/logs/Pipeline_procedure.log
      anno_count=$count221
   else
      echo "${space}No annotated gene models (~annot.gff3) were found in Input Directory (2.21) $dateTime221" >>$WorkDIR/logs/Pipeline_procedure.log
      count221=0
      anno_count=0
   fi
   
   # concatenate gff3 description to download working directory
   
   if ls -1 $dataPath/*annot.desc.txt >/dev/null 2>&1
   then
      echo "- Gene model descriptions as text (~annot.desc.txt) "  >>$WorkDIR/logs/Pipeline_procedure.log
      msg222=" gene model descriptions were copied from $input_dir to $download_destination (2.22)"
      cat $dataPath/*annot.desc.txt  >$tmpWorkDIR/data/download/${xGDB}annot.desc.txt
      count222=$(grep -c -P "^.+\t.+$" $tmpWorkDIR/data/download/${xGDB}annot.desc.txt) #tab-delimited file with 2 columns
      echo "$space$count222$msg222" >>$WorkDIR/logs/Pipeline_procedure.log
      annodesc_count=$count222
   else
      echo "${space}No gene description file ~annot.desc.txt was found in Input Directory (2.22)" >>$WorkDIR/logs/Pipeline_procedure.log
      annodesc_count=0
   fi

   echo "(c) CpGAT Gene Annotation Files (pre-computed)" >>$WorkDIR/logs/Pipeline_procedure.log

   # CpGAT precomputed output already exists? Then copy it to download directory, where it will be picked up in step 7 (parse and load GFF)
   # Also grab any desc.txt files and copy to download, and cat together any pep.fa and mrna.fa and copy to BLAST page.
   if ls -1 $dataPath/*cpgat.gff3 >/dev/null 2>&1
   then
      echo "- CpGAT gene models as gff3 (~cpgat.gff3) "  >>$WorkDIR/logs/Pipeline_procedure.log
      cat $dataPath/*cpgat.gff3 > ${tmpWorkDIR}/data/download/${xGDB}cpgat.gff3
      dateTime223=$(date +%Y-%m-%d\ %k:%M:%S)
      count223=$(grep -c -P "\tmRNA\t" ${tmpWorkDIR}/data/download/${xGDB}cpgat.gff3) #this may not always be an accurate count!
      msg223=" CpGAT gene models were copied to ${tmpWorkDIR}/data/download/${xGDB}cpgat.gff3"
      echo "${space}${count223}${msg223}${dateTime223} (2.23)">>$WorkDIR/logs/Pipeline_procedure.log
      cpgatanno_count=$count223
   else
      cpgatanno_count=0;
      echo "${space}No CpGAT gene models (~cpgat.gff3) were found in Input Directory (2.23)" >>$WorkDIR/logs/Pipeline_procedure.log
   fi

      if ls -1 $dataPath/*cpgat.desc.txt >/dev/null 2>&1
      then
      echo "- CpGAT gene model descriptions as text (~cpgat.desc.txt) "  >>$WorkDIR/logs/Pipeline_procedure.log
         cat dataPath/*cpgat.desc.txt > ${WorkDIR}/data/download/${xGDB}cpgat.desc.txt     #tab-delimited file with 2 columns
         count224=$(grep -c "^>" ${WorkDIR}/data/download/${xGDB}cpgat.desc.txt)
         dateTime224=$(date +%Y-%m-%d\ %k:%M:%S)
         msg224=" CpGAT gene model descriptions were copied to ${WorkDIR}/data/download/${xGDB}cpgat.desc.txt"
         echo "$space$count224$msg224$dateTime224 (2.24) ">>$WorkDIR/logs/Pipeline_procedure.log
         cpgatdesc_count=$count224
      else
         msg224="No CpGAT gene model descriptions ~cpgat.desc.txt were found in Input Directory (2.24)"
         echo "$space$msg224$dateTime224 (2.24) ">>$WorkDIR/logs/Pipeline_procedure.log
      fi

   ## Precomputed spliced-alignments
   
   echo "(d) Precomputed spliced alignment files (GeneSeqer, GenomeThreader)" >>$WorkDIR/logs/Pipeline_procedure.log
   # 2.51 concatenate precomputed geneseqer output to download directory
   msg251=" EST spliced alignments copied to ${tmpWorkDIR}/data/download/${xGDB}est.gsq  (2.51)"
   
   if ls -1 $dataPath/*est.gsq >/dev/null 2>&1; then
   cat $dataPath/*est.gsq >$tmpWorkDIR/data/download/${xGDB}est.gsq 
   count251=$(grep -c "MATCH" $tmpWorkDIR/data/download/${xGDB}est.gsq)
   echo "$space$count251$msg251" >>$WorkDIR/logs/Pipeline_procedure.log
   fi

   if ls -1 $dataPath/*cdna.gsq >/dev/null 2>&1; then
   msg252=" precomputed cDNA spliced alignments copied to ${tmpWorkDIR}/data/download/${xGDB}cdna.gsq (2.52)"
   cat $dataPath/*cdna.gsq >$tmpWorkDIR/data/download/${xGDB}cdna.gsq
   count252=$(grep -c "MATCH" $tmpWorkDIR/data/download/${xGDB}cdna.gsq)
   echo "$space$count252$msg252" >>$WorkDIR/logs/Pipeline_procedure.log
   fi
   
   if ls -1 $dataPath/*tsa.gsq >/dev/null 2>&1; then
   msg253=" precomputed TSA spliced alignments copied to ${tmpWorkDIR}/data/download/${xGDB}tsa.gsq (2.53)"
   cat $dataPath/*tsa.gsq >$tmpWorkDIR/data/download/${xGDB}tsa.gsq 
   count253=$(grep -c "MATCH" $tmpWorkDIR/data/download/${xGDB}tsa.gsq )
   echo "$space$count253$msg253" >>$WorkDIR/logs/Pipeline_procedure.log
   fi
   
   #2.54 concatenate precomputed genomethreader output to download directory
   if ls -1 $dataPath/*prot.gth >/dev/null 2>&1; then
   msg254=" precomputed protein spliced alignments copied to ${tmpWorkDIR}/data/download/${xGDB}prot.gth(2.54)"
   cat $dataPath/*prot.gth >$tmpWorkDIR/data/download/${xGDB}prot.gth
   count254=$(grep -c "MATCH" $tmpWorkDIR/data/download/${xGDB}prot.gth)
   echo "$space$count254$msg254" >>$WorkDIR/logs/Pipeline_procedure.log
   fi
   
   ########## Get total input file count #############
   echo "- Input Data transfer complete." >>$WorkDIR/logs/Pipeline_procedure.log   
   count260=$(ls $tmpWorkDIR/data/download/|wc -l)
   echo "${space}${count260} input files are in $tmpWorkDIR/data/download/ (2.60)" >>$WorkDIR/logs/Pipeline_procedure.log
   
   dateTime299=$(date +%Y-%m-%d\ %k:%M:%S)
   msg299="* Step 2 completed "
   echo "$space$msg299$dateTime299" >>$WorkDIR/logs/Pipeline_procedure.log
   
   #End of Step 2
   #################################################################################################
   # Step 3. Copy files again to GeneSeqer, GenomeThreader working directories; Repeat Mask genome #
   #################################################################################################
   
   dateTime300=$(date +%Y-%m-%d\ %k:%M:%S)
   echo "$dline" >>$WorkDIR/logs/Pipeline_procedure.log
   msg300="| Step 3: Copy input fasta files to working directories for spliced alignment. Repeat Mask if requested.  "
   echo "$msg300$dateTime300" >>$WorkDIR/logs/Pipeline_procedure.log
   echo "$dline" >>$WorkDIR/logs/Pipeline_procedure.log

   # Part A. transcript/protein sequence   
   cp $tmpWorkDIR/data/download/${xGDB}est.fa $tmpWorkDIR/data/GSQ/MRNADIR/${xGDB}est.fa
   cp $tmpWorkDIR/data/download/${xGDB}cdna.fa $tmpWorkDIR/data/GSQ/MRNADIR/${xGDB}cdna.fa
   count301=$(ls $tmpWorkDIR/data/GSQ/MRNADIR/|wc -l)
   msg301=" query files copied to GeneSeqer EST/cDNA directory, $tmpWorkDIR/data/GSQ/MRNADIR/ (3.01) "
   echo "$space$count301$msg301" >>$WorkDIR/logs/Pipeline_procedure.log
   cp $tmpWorkDIR/data/download/${xGDB}tsa.fa $tmpWorkDIR/data/GSQ/PUTDIR/${xGDB}tsa.fa
   count302=$(ls $tmpWorkDIR/data/GSQ/PUTDIR/|wc -l)
   msg302=" query files copied to GeneSeqer TSA directory $tmpWorkDIR/data/GSQ/PUTDIR/ (3.02)"
   echo "$space$count302$msg302" >>$WorkDIR/logs/Pipeline_procedure.log
   cp $tmpWorkDIR/data/download/${xGDB}prot.fa $tmpWorkDIR/data/GTH/Protein/${xGDB}prot.fa
   count303=$(ls $tmpWorkDIR/data/GTH/Protein/|wc -l)
   msg303=" protein files copied to GenomeThreader protein directory, $tmpWorkDIR/data/GTH/Protein/ (3.03)"
   echo "$space$count303$msg303" >>$WorkDIR/logs/Pipeline_procedure.log

   # Part B. Genome Sequence for GSQ: Repeat Mask if requested or use ~gdna.rm.fa if present; in either cases set a 'mask' track flag. Otherwise just load unmasked genome.
   if [ -n "$RepeatMaskparameter" ]
      # 3.30 Repeat Mask requested for GeneSeqer (parameter is set), so log the parameters, run Vmatch on scaffold in BLAST directory copy output (~gdna.rm.fa) to 3 locations: GSQ/SCFDIR/  ,  /data/download/ , and /data/BLAST/
      # First check for Vmatch license.
    then
      if ls -1 /usr/local/bin/vmatch.lic >/dev/null 2>&1
      then
         dateTime330=$(date +%Y-%m-%d\ %k:%M:%S)
         msg330="- Repeat mask of genome sequence initiated (user selected Repeat Mask=Yes): "
         echo "$msg330$dateTime330 (3.30)" >>$WorkDIR/logs/Pipeline_procedure.log
         echo "${space}Repeat Mask file path is $RepeatMaskparameter">>$WorkDIR/logs/Pipeline_procedure.log
         echo "- Repeat Mask file path is $RepeatMaskparameter">$tmpWorkDIR/data/GSQ/GSQOUT/RepeatMaskparameterLog.txt
        # Copy the repeatmask file to scratch directory
         cp $RepeatMaskparameter $tmpWorkDIR/data/GSQ/SCFDIR/ # the filepath to user-supplied Repeat Mask file
         RepeatMaskFile=$(echo $RepeatMaskparameter |awk -F/ '{print $NF}') # just the filename
         ### Make index using mkvtree! ###
         cd $tmpWorkDIR/data/GSQ/SCFDIR/
         /usr/local/bin/mkvtree -db $tmpWorkDIR/data/GSQ/SCFDIR/$RepeatMaskFile -dna -pl -allout
         
         if ls -1 ${tmpWorkDIR}/data/GSQ/SCFDIR/${RepeatMaskFile}.prj  >/dev/null 2>&1 # one of the makevtree index files
         then
           dateTime332=$(date +%Y-%m-%d\ %k:%M:%S)
           msg332="- mkvtree index of repeat mask file sequence $RepeatMaskFile completed. Now Vmatch will mask the genome.  "
           echo "$msg332$dateTime332 (3.32)" >>$WorkDIR/logs/Pipeline_procedure.log
           ### Run Vmatch! ###
           /usr/local/bin/vmatch -q $tmpWorkDIR/data/BLAST/${xGDB}gdna.fa -qmaskmatch N -d -p -l 100 -exdrop 4 -identity 80 $tmpWorkDIR/data/GSQ/SCFDIR/$RepeatMaskFile | grep -v '#' > $tmpWorkDIR/data/GSQ/SCFDIR/${xGDB}gdna.fa  # We don't add the 'rm' suffix here.
           dateTime335=$(date +%Y-%m-%d\ %k:%M:%S)
           msg335="- Vmatch repeat mask of genome sequence completed  "
           echo "$msg335$dateTime335 (3.35)" >>$WorkDIR/logs/Pipeline_procedure.log
 
			mask_count_after=$(grep -v ">" $tmpWorkDIR/data/GSQ/SCFDIR/${xGDB}gdna.fa | grep -o "N" | wc -w) # this is the masked version
			mask_count_before=$(grep -v ">" $tmpWorkDIR/data/BLAST/${xGDB}gdna.fa | grep -o "N" | wc -w)
            
            mask_count=`expr $mask_count_after - $mask_count_before`
            dateTime340=$(date +%Y-%m-%d\ %k:%M:%S)
            count340=$(ls $tmpWorkDIR/data/GSQ/SCFDIR/${xGDB}gdna.fa|wc -l)
            msg340="${count340} Repeat Masked genome file with $mask_count newly masked residues saved to GSQ working dir $tmpWorkDIR/data/GSQ/SCFDIR/: "
            echo "${space}${msg340}${dateTime340} (3.40)" >>$WorkDIR/logs/Pipeline_procedure.log
            MaskFlag="Repeat"
            cp $tmpWorkDIR/data/GSQ/SCFDIR/${xGDB}gdna.fa  $tmpWorkDIR/data/download/${xGDB}gdna.rm.fa # we explicitly flag this as repeat masked with 'rm' suffix.
            cp $tmpWorkDIR/data/GSQ/SCFDIR/${xGDB}gdna.fa  $tmpWorkDIR/data/BLAST/${xGDB}gdna.rm.fa # we explicitly flag this as repeat masked with 'rm' suffix.
            dateTime345=$(date +%Y-%m-%d\ %k:%M:%S)
            count345=$(ls $tmpWorkDIR/data/download/${xGDB}gdna.rm.fa|wc -l)
            msg345="${count345} Repeat Masked genome file copied to $tmpWorkDIR/data/download/ and $tmpWorkDIR/data/BLAST/ "
            echo "${space}${msg345}${dateTime345} (3.45)" >>$WorkDIR/logs/Pipeline_procedure.log
            # Finally copy the repeat mask fasta file to BLAST directory
            cp $tmpWorkDIR/data/GSQ/SCFDIR/$RepeatMaskFile  $tmpWorkDIR/data/BLAST/${xGDB}rmlibrary.fa
            cp $tmpWorkDIR/data/GSQ/SCFDIR/$RepeatMaskFile  $tmpWorkDIR/data/download/${xGDB}rmlibrary.fa
            dateTime348=$(date +%Y-%m-%d\ %k:%M:%S)
            if ls -1 $tmpWorkDIR/data/BLAST/${xGDB}rmlibrary.fa  >/dev/null 2>&1 # our repeat mask index copied to BLAST
            then
              msg348="${space}Repeat mask file $RepeatMaskFile copied to BLAST and download directories as ${xGDB}rmlibrary.fa  "
              echo "$msg348$dateTime348 (3.48)" >>$WorkDIR/logs/Pipeline_procedure.log
            else
              error348="ERROR: Repeat mask file $RepeatMaskFile could not be copied to BLAST or download directory (3.48)"
              echo "$error348">>$WorkDIR/logs/Pipeline_procedure.log; echo "$error330">>$WorkDIR/logs/Pipeline_error.log
              MaskFlag="None"
            fi
         else
            error335="ERROR: A mkvtree index could not be created. Perhaps something wrong with input file (make sure no 'x') or you have insufficient memory (3.35) "
            echo "$error335">>$WorkDIR/logs/Pipeline_procedure.log; echo "$error335">>$WorkDIR/logs/Pipeline_error.log
            MaskFlag="None"
         fi
      else
        dateTime330=$(date +%Y-%m-%d\ %k:%M:%S)
         error330="ERROR: Vmatch license missing from /usr/local/bin/vmatch.lic so repeat masking could not be done (3.30)"
         echo "$error330">>$WorkDIR/logs/Pipeline_procedure.log; echo "$error330">>$WorkDIR/logs/Pipeline_error.log
      fi
   elif ls -1 $tmpWorkDIR/data/download/${xGDB}gdna.rm.fa >/dev/null 2>&1
   # 3.50 User provided a repeat mask dataset (which has already been copied to /data/download/ , and /data/BLAST/). Now copy to GSQ/SCFDIR/ 
   then
      cp $tmpWorkDIR/data/BLAST/${xGDB}gdna.rm.fa $tmpWorkDIR/data/GSQ/SCFDIR/${xGDB}gdna.fa
      dateTime350=$(date +%Y-%m-%d\ %k:%M:%S)
      count350=$(ls $tmpWorkDIR/data/GSQ/SCFDIR/${xGDB}gdna.fa|wc -l)
      msg350=" genome sequence (repeat masked) copied to GSQ scaffold directory, $tmpWorkDIR/data/GSQ/SCFDIR/ "
      echo "$space$count350$msg350$dateTime350 (3.50)" >>$WorkDIR/logs/Pipeline_procedure.log
      MaskFlag="Repeat" 
   else
      # 3.60 No Repeat Mask requested, no ~gdna.rm.fa, no 'N's.
      N_count=$(grep -v ">" $tmpWorkDIR/data/download/${xGDB}gdna.fa | grep -o "[N]" | wc -w)
      if [ "$N_count" -gt "0" ]
      then
      # 3.55 No repeat mask, but N 'unknown' bases are present, so later we will parse them for N-Mask track using just the single GSEG file, ~gdna.fa 
      # for the moment we just copy the genome file to Geneseqer SCFDIR
         dateTime355=$(date +%Y-%m-%d\ %k:%M:%S)
         cp $tmpWorkDIR/data/download/${xGDB}gdna.fa $tmpWorkDIR/data/GSQ/SCFDIR/
         count355=$N_count
         msg355a="No repeat masking requested or indicated in filename, but $count355 N-residues are present in the genome; we will create an N-mask track to display them"
         echo "$space$msg355a $dateTime355 (3.55)" >>$WorkDIR/logs/Pipeline_procedure.log
         msg355b="Genome sequence (not repeat masked) copied to GSQ scaffold directory, $tmpWorkDIR/data/GSQ/SCFDIR/"
         echo "$space$msg355b $dateTime355 (3.55)" >>$WorkDIR/logs/Pipeline_procedure.log
      MaskFlag="Nmasked"
      
      else
      # 3.60 No Repeat Mask requested, no ~gdna.rm.fa, no 'N's so just grab scaffold ~gdna.fa from BLAST directory and place in GeneSeqer SCFDIR (working directory).
         echo "RepeatMaskparameter set is zero and N count is $N_count" >$tmpWorkDIR/data/GSQ/GSQOUT/RepeatMaskparameterLog.txt
         echo "${space} RepeatMaskparameter set is zero and N count is $N_count">>$WorkDIR/logs/Pipeline_procedure.log
         cp $tmpWorkDIR/data/BLAST/${xGDB}gdna.fa $tmpWorkDIR/data/GSQ/SCFDIR/
         dateTime360=$(date +%Y-%m-%d\ %k:%M:%S)
         count360=$(ls $tmpWorkDIR/data/GSQ/SCFDIR/${xGDB}gdna.fa|wc -l)
         msg360=" genome sequence (not masked) copied to GSQ scaffold directory, $tmpWorkDIR/data/GSQ/SCFDIR/ "
         echo "$space$count360$msg360$dateTime360 (3.60)" >>$WorkDIR/logs/Pipeline_procedure.log
         MaskFlag="None"
      fi
   fi # end genome sequence
     
   # Part C. Genome sequence for GenomeThreader: We use non-masked genome sequence  TODO: provide option for using repeat masked sequence
   cp $tmpWorkDIR/data/BLAST/${xGDB}gdna.fa $tmpWorkDIR/data/GTH/SCFDIR/${xGDB}gdna.fa
   dateTime350=$(date +%Y-%m-%d\ %k:%M:%S)
   count350=$(ls $tmpWorkDIR/data/GTH/SCFDIR/|wc -l)
   msg350=" genome sequence copied to GTH working dir $tmpWorkDIR/data/GTH/SCFDIR/: "
   echo "$space$count350$msg350$dateTime350 (3.50)" >>$WorkDIR/logs/Pipeline_procedure.log

   dateTime399=$(date +%Y-%m-%d\ %k:%M:%S)
   msg399="* Step 3 completed: "
   echo "$space$msg399$dateTime399">>$WorkDIR/logs/Pipeline_procedure.log
   #End of Step 3 #
   ###########################################################################
   # Step 4. Create blast index for all input data in BLAST working directory #
   ###########################################################################
   
   dateTime400=$(date +%Y-%m-%d\ %k:%M:%S)
   echo "$dline" >>$WorkDIR/logs/Pipeline_procedure.log
   msg400="| Step 4: Create BLAST indices for all sequence files in temp BLAST directory. "
   echo "$msg400$dateTime400">>$WorkDIR/logs/Pipeline_procedure.log
   echo "$dline" >>$WorkDIR/logs/Pipeline_procedure.log
   
   $ScriptDIR/formatdb.pl $tmpWorkDIR/data/BLAST/
   
   dateTime450=$(date +%Y-%m-%d\ %k:%M:%S)
   count450a=$(find $tmpWorkDIR/data/BLAST/*.nhr -type f | wc -l) #nucleotide indexes
   count450b=$(find $tmpWorkDIR/data/BLAST/*.phr -type f | wc -l) #protein indexes
   msg450="${space}$count450a nucl. index and $count450b prot. index created in $tmpWorkDIR/data/BLAST/ "
   echo "$msg450$dateTime450 (4.50)">>$WorkDIR/logs/Pipeline_procedure.log
   
   dateTime499=$(date +%Y-%m-%d\ %k:%M:%S)
   msg499="* Step 4 completed: "
   echo "$space$msg499$dateTime499">>$WorkDIR/logs/Pipeline_procedure.log
   
   ###########################################################
   #Step 5. Set up MySQL database and tables for the new GDB #
   ###########################################################
   dateTime500=$(date +%Y-%m-%d\ %k:%M:%S)
   echo "$dline" >>$WorkDIR/logs/Pipeline_procedure.log
   msg500="| Step 5: Set up MySQL database and tables for $xGDB. "
   echo "$msg500$dateTime500">>$WorkDIR/logs/Pipeline_procedure.log
   echo "$dline" >>$WorkDIR/logs/Pipeline_procedure.log
   echo "create database $xGDB"|mysql -p$dbpass -u $mysqluser # create GDB database
   
   ## Report error in create database if any
   error501=$(echo "use $xGDB"|mysql -p$dbpass -u $mysqluser $xGDB)
   if [ "$error501" == "" ]
   then
      msg501="$xGDB database successfully created"
   else
      msg501=$error501
   fi
   echo "$space$msg501">>$WorkDIR/logs/Pipeline_procedure.log
   
   mysql -p$dbpass -u $mysqluser $xGDB< $tmpWorkDIR/data/XGDB_MYSQL/${xGDB}TemplateFrame.sql # create GDB tables from working directory template
   echo "grant SELECT on $xGDB.* to 'xgdbSELECT'@'localhost' identified by ''"|mysql -p$dbpass -u $mysqluser
   echo "grant All on $xGDB.* to 'gaeval'@'localhost' identified by ''"|mysql -p$dbpass -u $mysqluser
   echo "grant All on $xGDB.user_gene_annotation to 'yrgateUser'@'localhost' identified by ''"|mysql -p$dbpass -u $mysqluser
   echo "grant All on $xGDB.sessions to 'xgdbSELECT'@'localhost' identified by ''"|mysql -p$dbpass -u $mysqluser
   echo "grant All on $xGDB.segments to 'xgdbSELECT'@'localhost' identified by ''"|mysql -p$dbpass -u $mysqluser
   echo "grant All on $xGDB.projects to 'xgdbSELECT'@'localhost' identified by ''"|mysql -p$dbpass -u $mysqluser
   echo "grant All on $xGDB.sessionprojects to 'xgdbSELECT'@'localhost' identified by ''"|mysql -p$dbpass -u $mysqluser
   echo "grant All on $xGDB.user_gff_annotation to 'xgdbSELECT'@'localhost' identified by ''"|mysql -p$dbpass -u $mysqluser
   echo "flush privileges"|mysql -p$dbpass -u $mysqluser  #INCLUDE COPY OF THIS IN SETUP SCRIPT
   
   dateTime599=$(date +%Y-%m-%d\ %k:%M:%S)
   msg599="* Step 5 completed: "
   echo "$space$msg599$dateTime599">>$WorkDIR/logs/Pipeline_procedure.log
   #####################################################
   # Step 6. Parse sequence files for upload to MySQL  #
   #####################################################
   dateTime600=$(date +%Y-%m-%d\ %k:%M:%S)
   echo "$dline" >>$WorkDIR/logs/Pipeline_procedure.log
   msg600="| Step 6: Parse sequence files and upload to MySQL. "
   echo "$msg600$dateTime600">>$WorkDIR/logs/Pipeline_procedure.log
   echo "$dline" >>$WorkDIR/logs/Pipeline_procedure.log
   
   # Parse concatenated sequence files and create .sql (insert) files in working directory
   # Load MySQL tables using .sql (insert) files. Make sure scaffold table allows max packed size.
   
   $ScriptDIR/xGDBload_SeqFromFasta.pl est $tmpWorkDIR/data/download/${xGDB}est.fa >$tmpWorkDIR/data/XGDB_MYSQL/${xGDB}est.sql
   mysql -p$dbpass -u $mysqluser $xGDB < $tmpWorkDIR/data/XGDB_MYSQL/${xGDB}est.sql
   count601=$(echo "select count(*) from est"|mysql -p$dbpass -u $mysqluser $xGDB -N)
   msg601=" EST sequences were loaded to '$xGDB.est' table"
   echo "$space${count601}${msg601}" >>$WorkDIR/logs/Pipeline_procedure.log
   if [ "$est_count" -gt "0" ] #
   then
      if [ "$count601" -eq "$est_count" ] # initial fasta count
      then
         msg6015=" EST IDs appear to have been parsed correctly (6.015)"
         echo "$space${msg6015}" >>$WorkDIR/logs/Pipeline_procedure.log
      else
         error6015="WARNING: Only $count601 EST sequences were loaded to $xGDB est table but input file had $est_count records (6.015) "
         echo "$error6015">>$WorkDIR/logs/Pipeline_procedure.log; echo "$error6015">>$WorkDIR/logs/Pipeline_error.log
      fi
   fi
   $ScriptDIR/xGDBload_SeqFromFasta.pl cdna $tmpWorkDIR/data/download/${xGDB}cdna.fa >$tmpWorkDIR/data/XGDB_MYSQL/${xGDB}cdna.sql
   mysql -p$dbpass -u $mysqluser $xGDB < $tmpWorkDIR/data/XGDB_MYSQL/${xGDB}cdna.sql
   
   msg602=" cDNA sequences were loaded to '$xGDB.cdna' table"
   count602=$(echo "select count(*) from cdna"|mysql -p$dbpass -u $mysqluser $xGDB -N)
   echo "$space$count602$msg602" >>$WorkDIR/logs/Pipeline_procedure.log
   if [ "$cdna_count" -gt "0" ] #
   then
      if [ "$count602" -eq "$cdna_count" ] # initial fasta count
      then
         msg6025=" cDNA IDs appear to have been parsed correctly (6.025)"
         echo "$space${msg6025}" >>$WorkDIR/logs/Pipeline_procedure.log
      else
         error6025="WARNING: Only $count602 cDNA sequences were loaded to $xGDB cdna table but input file had $cdna_count records (6.025) "
         echo "$error6025">>$WorkDIR/logs/Pipeline_procedure.log; echo "$error6025">>$WorkDIR/logs/Pipeline_error.log
      fi
   fi
   $ScriptDIR/xGDBload_SeqFromFasta.pl put $tmpWorkDIR/data/download/${xGDB}tsa.fa >$tmpWorkDIR/data/XGDB_MYSQL/${xGDB}tsa.sql
   mysql -p$dbpass -u $mysqluser $xGDB < $tmpWorkDIR/data/XGDB_MYSQL/${xGDB}tsa.sql
   msg603=" TSA sequences were loaded to '$xGDB.put' (tsa) table"
   count603=$(echo "select count(*) from put"|mysql -p$dbpass -u $mysqluser $xGDB -N)
   echo "$space$count603$msg603" >>$WorkDIR/logs/Pipeline_procedure.log
   if [ "$tsa_count" -gt "0" ] #
   then
      if [ "$count603" -eq "$tsa_count" ] # initial fasta count
      then
         msg6035=" TSA IDs appear to have been parsed correctly (6.035)"
         echo "$space${msg6035}" >>$WorkDIR/logs/Pipeline_procedure.log
      else
         error6035="WARNING: Only $count603 TSA sequences were loaded to $xGDB 'put' (tsa) table but input file had $tsa_count records (6.035) "
         echo "$error6035">>$WorkDIR/logs/Pipeline_procedure.log; echo "$error6035">>$WorkDIR/logs/Pipeline_error.log
      fi
   fi
   $ScriptDIR/xGDBload_SeqFromFasta.pl pep $tmpWorkDIR/data/download/${xGDB}prot.fa >$tmpWorkDIR/data/XGDB_MYSQL/${xGDB}prot.sql
   mysql -p$dbpass -u $mysqluser $xGDB < $tmpWorkDIR/data/XGDB_MYSQL/${xGDB}prot.sql
   
   msg604=" Protein sequences were loaded to '$xGDB.pep' (related species protein) table"
   count604=$(echo "select count(*) from pep"|mysql -p$dbpass -u $mysqluser $xGDB -N)
   echo "$space$count604$msg604" >>$WorkDIR/logs/Pipeline_procedure.log
   if [ "$pep_count" -gt "0" ] #
   then
      if [ "$count604" -eq "$prot_count" ] # initial fasta count
      then
         msg6045=" Protein IDs appear to have been parsed correctly (6.045)"
         echo "$space${msg6045}" >>$WorkDIR/logs/Pipeline_procedure.log
      else
         error6045="WARNING: $count604 protein sequences were loaded to $xGDB pep table but input file had $prot_count records (6.045) "
         echo "$error6045">>$WorkDIR/logs/Pipeline_procedure.log; echo "$error6045">>$WorkDIR/logs/Pipeline_error.log
      fi
   fi
   $ScriptDIR/xGDBload_SeqFromFasta.pl gseg $tmpWorkDIR/data/BLAST/${xGDB}gdna.fa >$tmpWorkDIR/data/XGDB_MYSQL/${xGDB}gdna.sql
   mysql --max_allowed_packet=2048M -p$dbpass -u $mysqluser $xGDB < $tmpWorkDIR/data/XGDB_MYSQL/${xGDB}gdna.sql
   count605=$(echo "select count(*) from gseg"|mysql -p$dbpass -u $mysqluser $xGDB -N)
   msg605="$count605 genome sequences were loaded to '$xGDB.gseg' table"
   echo "$space$msg605" >>$WorkDIR/logs/Pipeline_procedure.log
   if [ "$count605" -eq "$gdna_count" ] # initial fasta count
   then
      msg6055=" Scaffold (gdna) IDs appear to have been parsed correctly (6.055)"
      echo "$space${msg6055}" >>$WorkDIR/logs/Pipeline_procedure.log
   else
      error6055="WARNING: A total of $count605 genome sequences were loaded to $xGDB gseg table but aggregate genome inputs had $gdna_count records (6.055) "
      echo "$error6055">>$WorkDIR/logs/Pipeline_procedure.log; echo "$error6055">>$WorkDIR/logs/Pipeline_error.log
   fi
   
   
   # Segments table (required for user_add_track)
   echo "insert into segments(alias,xID,stop) select gi,gi,length(seq) from gseg"|mysql -p$dbpass -u $mysqluser $xGDB
   count606=$(echo "select count(*) from segments"|mysql -p$dbpass -u $mysqluser $xGDB -N)
   dateTime606=$(date +%Y-%m-%d\ %k:%M:%S)
   msg606="$count606 segments were loaded to '$xGDB.segments' table $dateTime606 (6.06)"
   echo "$space$msg606" >>$WorkDIR/logs/Pipeline_procedure.log
   
   # (optional) Parse Repeat Mask regions from the (unmasked) fasta file
   
   if [[ "$MaskFlag" == "Repeat" || "$MaskFlag" == "Nmasked"  ]] # From Step 3
   then
      if [ "$MaskFlag" == "Repeat" ]
      then
         maskfile="$tmpWorkDIR/data/BLAST/${xGDB}gdna.rm.fa"
         rawfile="$tmpWorkDIR/data/BLAST/${xGDB}gdna.fa"
      elif [ "$MaskFlag" == "Nmasked" ] # From Step 3
      then
         maskfile="$tmpWorkDIR/data/BLAST/${xGDB}gdna.fa" # use same file for both
         rawfile="$tmpWorkDIR/data/BLAST/${xGDB}gdna.fa"
      fi
   dateTime630=$(date +%Y-%m-%d\ %k:%M:%S)
      msg630="The genome contains N-Masked bases. Now parsing N-mask regions for display in genome browser. $dateTime630 (6.30)"
      echo "$space$msg630" >>$WorkDIR/logs/Pipeline_procedure.log
      $ScriptDIR/parseGsegMask.pl $rawfile $maskfile $tmpWorkDIR/data/XGDB_MYSQL/${xGDB}mask.sql $tmpWorkDIR/data/download/${xGDB}mask.fa N
      # Note we source from BLAST directory because the script will use the ${xGDB}gdna.fa BLAST index. The outputs are ~mask.sql and ~mask.fa (masked regions) respectively
      # Copy output fasta to BLAST dir and create BLAST index
      cp $tmpWorkDIR/data/download/${xGDB}mask.fa $tmpWorkDIR/data/BLAST/${xGDB}mask.fa
      mask_index_count=$(grep -c "^>" $tmpWorkDIR/data/BLAST/${xGDB}mask.fa)
      dateTime640=$(date +%Y-%m-%d\ %k:%M:%S)
      
      if [ $mask_index_count -gt 0 ]
      then
         msg640=" $mask_index_count masked regions were indexed for BLAST $dateTime640 (6.40)"
         echo "${space}${msg640}" >>$WorkDIR/logs/Pipeline_procedure.log
         /usr/local/bin/makeblastdb -in $tmpWorkDIR/data/BLAST/${xGDB}mask.fa -dbtype nucl -parse_seqids -out $tmpWorkDIR/data/BLAST/${xGDB}mask.fa # Since Step 4 is already completed.
         #load mask sequences to mysql and verify, log.
         mysql --max_allowed_packet=2048M -p$dbpass -u $mysqluser $xGDB < $tmpWorkDIR/data/XGDB_MYSQL/${xGDB}mask.sql # This inserts into both 'mask' and 'gseg_mask_good_pgs' tables 
         count650a=$(echo "select count(*) from mask"|mysql -p$dbpass -u $mysqluser $xGDB -N)
         count650b=$(echo "select count(*) from gseg_mask_good_pgs"|mysql -p$dbpass -u $mysqluser $xGDB -N)
         dateTime650=$(date +%Y-%m-%d\ %k:%M:%S)
         if [ "$count650a" -eq "$mask_index_count" ] # masked seq count
         then
            msg650=" $count650a records were loaded to 'mask' table and $count650b records were loaded to 'gseg_mask_good_pgs' table $dateTime650 (6.50)"
            echo "${space}${msg650}" >>$WorkDIR/logs/Pipeline_procedure.log
         else
            error650="WARNING: Only $count650a mask sequences were loaded to $xGDB 'mask' table but fasta file had $mask_index_count records (6.50) "
            echo "$error650">>$WorkDIR/logs/Pipeline_procedure.log; echo "$error650">>$WorkDIR/logs/Pipeline_error.log
         fi
       else
            error640="WARNING: No masked regions were parsed from $maskfile because output file $tmpWorkDIR/data/BLAST/${xGDB}mask.fa is empty (6.40) "
            echo "$error640">>$WorkDIR/logs/Pipeline_procedure.log; echo "$error640">>$WorkDIR/logs/Pipeline_error.log
       fi

    else
       msg640="No N-masked residues and no ~gdna.rm.fa file provided. (6.40) "
       echo "$space$msg640">>$WorkDIR/logs/Pipeline_procedure.log; 
    fi

   dateTime699=$(date +%Y-%m-%d\ %k:%M:%S)
   msg699="* Step 6 completed: "
   echo "$space$msg699$dateTime699">>$WorkDIR/logs/Pipeline_procedure.log
   #End of Step 6
   #####################################################################
   # Step 7. Parse and load GFF, CpGAT GFF, Gene Descriptions (if any) #
   ##################################################################### 
   dateTime700=$(date +%Y-%m-%d\ %k:%M:%S)
   msg700="| Step 7: Parse and load precomputed gene model/CpGAT model GFF3 and Descriptions (if any). "
   echo "$dline" >>$WorkDIR/logs/Pipeline_procedure.log
   echo "$msg700$dateTime700">>$WorkDIR/logs/Pipeline_procedure.log
   echo "$dline" >>$WorkDIR/logs/Pipeline_procedure.log
   
   # 7.01 Parse precomputed GFF files , create .sql (insert) file in working directory, and load MySQL
   if [ -s $tmpWorkDIR/data/download/${xGDB}annot.gff3  ] # from step 2
   then
      $ScriptDIR/GFF_to_XGDB_Standard.pl -t gseg_gene_annotation $tmpWorkDIR/data/download/${xGDB}annot.gff3 >$tmpWorkDIR/data/XGDB_MYSQL/${xGDB}gene_annotation.sql # 
      mysql -p$dbpass -u $mysqluser $xGDB < $tmpWorkDIR/data/XGDB_MYSQL/${xGDB}gene_annotation.sql
      count701=$(echo "select count(*) from gseg_gene_annotation"|mysql -p$dbpass -u $mysqluser -N $xGDB)
   
      # Check if number loaded equals number counted in GFF
      if [ "$anno_count" -eq "$count701" ]
      then
         msg701=" GFF gene models were loaded to $xGDB gseg_gene_annotation table (7.01)"
         echo "$space$count701$msg701" >>$WorkDIR/logs/Pipeline_procedure.log
      else
         error701="WARNING: $count701 gene models were loaded to $xGDB gseg_gene_annotation table but GFF table had $anno_count mRNAs (7.01) "
         echo "$error701">>$WorkDIR/logs/Pipeline_procedure.log; echo "$error701">>$WorkDIR/logs/Pipeline_error.log
      fi
   else
         msg701="No GFF gene models were found (7.01)"
         echo "$space$count701$msg701" >>$WorkDIR/logs/Pipeline_procedure.log
   fi
   
   # 7.02 Parse precomputed CpGAT GFF files create .sql (insert) file in working directory, and load MySQL
   if [ -s $tmpWorkDIR/data/download/*cpgat.gff3  ] # from Step 2
   then
      $ScriptDIR/GFF_to_XGDB_Standard.pl -t gseg_cpgat_gene_annotation $tmpWorkDIR/data/download/${xGDB}cpgat.gff3 >$tmpWorkDIR/data/XGDB_MYSQL/${xGDB}cpgat_gene_annotation.sql # added  3-5-13
      mysql -p$dbpass -u $mysqluser $xGDB < $tmpWorkDIR/data/XGDB_MYSQL/${xGDB}cpgat_gene_annotation.sql
      count702=$(echo "select count(*) from gseg_cpgat_gene_annotation"|mysql -p$dbpass -u $mysqluser -N $xGDB)
   
      if [ "$cpgatanno_count" -eq "$count702" ]
      then
         msg702=" CpGAT GFF gene models were loaded to $xGDB gseg_cpgat_gene_annotation table (7.015)"
         echo "$space$count702$msg702" >>$WorkDIR/logs/Pipeline_procedure.log
      else
         error702="WARNING: $count702 CpGAT gene models were loaded to $xGDB gseg_gene_annotation table but CpGAT GFF table had $cpgatanno_count mRNAs (7.02) "
         echo "$error702">>$WorkDIR/logs/Pipeline_procedure.log; echo "$error702">>$WorkDIR/logs/Pipeline_error.log
      fi
   else
         msg702="No CpGAT GFF gene models were found (7.02)"
         echo "$space$count702$msg702" >>$WorkDIR/logs/Pipeline_procedure.log
   fi
   
   # 7.03 Parse and load (concatenated) description file , if present, to gseg_gene_annotation #
   if [ -s $tmpWorkDIR/data/download/${xGDB}annot.desc.txt ] # from Step 2
   then
      $ScriptDIR/ParseAndUploadDes.pl $tmpWorkDIR/data/download/${xGDB}annot.desc.txt $xGDB gseg_gene_annotation
      count703=$(grep -c -P "^.+\t.+$" $tmpWorkDIR/data/download/${xGDB}annot.desc.txt) #tab-delimited file with 2 columns
      msg703=" gene model descriptions found and loaded to $xGDB gseg_gene_annotation table (7.03)"
      echo "$space$count703$msg703" >>$WorkDIR/logs/Pipeline_procedure.log
      
   else
      msg703="No gene model descriptions found (7.03)"
      echo "$space$msg703" >>$WorkDIR/logs/Pipeline_procedure.log
   fi
   
   # 7.04 Parse and load (concatenated) CpGAT description file , if present, to gseg_cpgat_gene_annotation #
   if [ -s $tmpWorkDIR/data/download/${xGDB}cpgat.desc.txt ] # from Step 2
   then
      $ScriptDIR/ParseAndUploadDes.pl $tmpWorkDIR/data/download/${xGDB}cpgat.desc.txt $xGDB gseg_cpgat_gene_annotation
      count704=$(grep -c -P "^.+\t.+$" $tmpWorkDIR/data/download/${xGDB}cpgat.desc.txt) #tab-delimited file with 2 columns
      msg704=" (precomputed) CpGAT gene model descriptions found and loaded to $xGDB gseg_gene_annotation table (7.04)"
      echo "$space$count704$msg704" >>$WorkDIR/logs/Pipeline_procedure.log
      
   else
      msg704="No CpGAT gene model descriptions found (7.04)"
      echo "$space$msg704" >>$WorkDIR/logs/Pipeline_procedure.log
   fi
   
   dateTime799=$(date +%Y-%m-%d\ %k:%M:%S)
   msg799="* Step 7 completed "
   echo "$space$msg799$dateTime799">>$WorkDIR/logs/Pipeline_procedure.log
   #End of Step 7 #
   
   
   ####################################################################
   # Step 8a, b, c d. GeneSeqer and GenomeThreader spliced alignments #
   ####################################################################
   
   # Cycle through all transcript types in series (est, cdna, tsa, prot)
   # 1. If present, copy user-provided (pre-computed) transcript GeneSeqer/GenomeThreader output files to scratch directory
   # 2. Else no user-provided GeneSeqer/GenomeThreader output files, check Remote Processing flag. If present, initiate Remote process and copy output to scratch directory.
   # 3. Else no Remote Processing, initiates SplitMakeArrayGSQ.pl locally (parses input, makes index, initiates GeneSeqer), or GenomeThreader locally, deposit output in scratch directory
   # 4. Check for GSQ/GTH output in scratch directory and report result.
   # NOTE: Parsing and uploading occur later after all data types are processed.
   
   #######################################################################################################################################
   # Key loops/nodes: IF/THEN/ELSE/FI, FOR/DO/DONE, WHILE/DO/DONE are named and numbered (8.0) through (8.9) to help in tracing logic #
   #######################################################################################################################################
   
   dateTime800=$(date +%Y-%m-%d\ %k:%M:%S)
   echo "$dline" >>$WorkDIR/logs/Pipeline_procedure.log
   msg800="| Step 8: GeneSeqer/GenomeThreader spliced alignment of transcripts to genome - "
   echo "$msg800$dateTime800">>$WorkDIR/logs/Pipeline_procedure.log
   echo "$dline" >>$WorkDIR/logs/Pipeline_procedure.log
   
   ########## The BIG LOOP for each transcript/protein type (it reaches all the way to the end of Step 8) ##########
   
   for trn in est cdna tsa prot ##### protein included! #####
   
   ##### for trn in est # NOTE: for debug (est only) #####
   
   ## (8.0) DO TRANSCRIPT-TYPE (Assign variables according to transcript type, and proceed with processing)
   do
      if [ $trn == "est" ]; then
         TRN="EST"; tRN="EST"; DIR="MRNADIR"; step="8a"
         Job="GSQ_Job_EST"; Result="GSQ_Job_EST_Result"
         trn_count=$est_count ## from step 2; if est_count=0 we skip
      fi
      if [ $trn == "cdna" ]; then
         TRN="CDNA"; tRN="cDNA"; DIR="MRNADIR"; step="8b"
         Job="GSQ_Job_cDNA"; Result="GSQ_Job_cDNA_Result"
         trn_count=$cdna_count ## from step 2; if cdna_count=0 we skip
      fi
      if [ $trn == "tsa" ]; then
         TRN="TSA"; tRN="TSA"; DIR="PUTDIR"; step="8c"
         Job="GSQ_Job_TSA"; Result="GSQ_Job_TSA_Result"
         trn_count=$tsa_count ## from step 2; if tsa_count=0 we skip

      fi
      if [ $trn == "prot" ]; then
         TRN="PROT"; tRN="PROT"; DIR="Protein"; step="8d"
         Job="GTH_Job"; Result="GTH_Job_Result"
         trn_count=$prot_count ## from step 2; if prot_count=0 we skip
      fi
      if [ $trn == "prot" ]; then
         PRG="GTH"
         prg="gth"
         Prg_HPC="GenomeThreader"
         extra_dir="" # added 12-10-13 
         PRGparameter=$GTHparameter
         PRG_CompResParameter=$GTH_CompResParameter
         PRG_CompResources=$GTH_CompResources
         PRG_username=$GTH_username # username
         PRG_refresh_token=$GTH_refresh_token # "token string
         prg_server=$gth_server #e.g. IP address
       else
         PRG="GSQ"
         prg="gsq"
         Prg_HPC="GeneSeqer-MPI"
         #extra_dir="GSQOUTPUT/" # added 12-10-13 - extra directory level for GSQ output
         extra_dir=""  # 1-30-16
         PRGparameter=$GSQparameter
         PRG_CompResParameter=$GSQ_CompResParameter
         PRG_CompResources=$GSQ_CompResources
         PRG_username=$GSQ_username # username
         PRG_refresh_token=$GSQ_refresh_token # "token string
         prg_server=$gsq_server #e.g. IP address
         
        ## Determine if fasta headers are illegally-formatted (GeneSeqer accepts only GenBank or Simple format)
        
         illegal_1=$(grep -c "^>[a-z][a-z][a-z]|" $tmpWorkDIR/data/${PRG}/${DIR}/${xGDB}${trn}.fa) # e.g. >lcl| >gnl|
         illegal_2=$(grep -c "^>sp|" $tmpWorkDIR/data/${PRG}/${DIR}/${xGDB}${trn}.fa) # e.g. >sp|

         dateTime801=$(date +%Y-%m-%d\ %k:%M:%S)
         if [[ "$illegal_1" -gt "0" || "$illegal_2" -gt "0" ]] ## invalid formatted headers found
         then
             error801="WARNING: some or all $tRN fasta headers are incompatible with GeneSeqer (8.01)"
             echo "$error801">>$WorkDIR/logs/Pipeline_procedure.log; echo "$error801">>$WorkDIR/logs/Pipeline_error.log
         else
             msg801="All $tRN fasta headers appear to be compatible with GeneSeqer (8.01)"
             echo "$msge801">>$WorkDIR/logs/Pipeline_procedure.log;
         fi
      fi  
      echo "${space}${dline}" >>$WorkDIR/logs/Pipeline_procedure.log
      echo "${space}| Step $step: $tRN transcripts ">>$WorkDIR/logs/Pipeline_procedure.log
      echo "${space}${dline}" >>$WorkDIR/logs/Pipeline_procedure.log
      
      
      ################## A. Pre-computed Data? #####################
      ## (8.1) IF PRECOMPUTED DATA (Does precomputed ${PRG} output already exist, deposited by user?)
      

      dateTime805=$(date +%Y-%m-%d\ %k:%M:%S)
      msg805="Checking for the presence of precomputed ${tRN} spliced alignments "
 
      echo "${space}${msg805}${dateTime805} (8.05)">>$WorkDIR/logs/Pipeline_procedure.log
      
      if [ -s $tmpWorkDIR/data/download/${xGDB}${trn}.${prg} ] # ${xGDB}est.gsq  etc.
      then
          echo "${space}Precomputed ${trn} are present at $tmpWorkDIR/data/download/${xGDB}${trn}.${prg}. Skipping $PRG and parsing ${prg} output instead (8.07)" >>$WorkDIR/logs/Pipeline_procedure.log
      else
          echo "${space}Precomputed ${trn} not found at $tmpWorkDIR/data/download/${xGDB}${trn}.${prg}. Proceed to $PRG local or remote processing (8.07)" >>$WorkDIR/logs/Pipeline_procedure.log
      fi
      
      if [ -s $tmpWorkDIR/data/download/${xGDB}${trn}.${prg} ] # ${xGDB}est.gsq  etc.

      then  ## THEN PRECOMPUTED option: Copy to from download scratch directory (rename also) and skip B and C.
         
         cp $tmpWorkDIR/data/download/${xGDB}${trn}.${prg} $tmpWorkDIR/data/${PRG}/${PRG}OUT/${xGDB}${trn}.${prg}
         dateTime810=$(date +%Y-%m-%d\ %k:%M:%S)
         msg810="Precomputed ${tRN} spliced alignments copied to $PRG output directory (scratch) ${PRG}/${PRG}OUT/${xGDB}${trn}.${prg}: "
         echo "${space}${msg810}${dateTime810} (8.10)">>$WorkDIR/logs/Pipeline_procedure.log
         
      else  ## ELSE PRECOMPUTED option: Else, process remote or local input data (if any)
         ## (8.1) ELSE PRECOMPUTED DATA (No precomputed data -next check processor local vs remote)
         
         ################## Remote Compute Flag? ###################
         
         ## (8.2) IF REMOTE (if REMOTE parameter is set and transcript data exist -- otherwise skip to local processing)
         if [[ $PRG_CompResources == "Remote"  && "$trn_count" -gt 0 ]]
         
         then ## THEN REMOTE option
            
            ##################### 8.2 Send transcript to Remote compute resource #####################
            
            
            echo "${space}##################### $tRN Spliced Alignment to Genome (REMOTE Processing Option) ######################## " >>$WorkDIR/logs/Pipeline_procedure.log
            
            dateTime820=$(date +%Y-%m-%d\ %k:%M:%S)
            msg820="Input ${tRN} sequences will be splice-aligned using Remote Compute resources "
            echo "${space}${msg820}${dateTime820} (8.20)">>$WorkDIR/logs/Pipeline_procedure.log
            echo "- ${PRG} parameter set is $PRGparameter " >>$WorkDIR/logs/Pipeline_procedure.log
            
            ## Make new directories on user's mounted DataStore for remote computing to use:
            
            mkdir $RemoteDIR ## temporary directory for remote HPC to grab/deposit data; defined as "/xGDBvm/input/xgdbvm/tmp/${xGDB}_hpc"
            mkdir $RemoteDIR/SCFDIR/ # same file if GSQ or GTH
            mkdir $RemoteDIR/${DIR}/ # MRNADIR CDNADIR PUTDIR or Protein
            # mkdir $RemoteDIR/${PRG}OUT/ # GSQOUT or GTHOUT Not used. Output goes to the standard username/archive/jobs/ directory
            
            echo "${space}Created a temporary input/output directory for ${tRN} and gdna on Data Store $RemoteDIR/, now copying data over: ">>$WorkDIR/logs/Pipeline_procedure.log
            
            # First we sort genome segements by size (descending) on the scratch disk:
            # For this we need to know whether the FASTA headers are ncbi (GeneBank) formatted:
            gdna_ncbi_count=$(head -1 $tmpWorkDIR/data/${PRG}/SCFDIR/${xGDB}gdna.fa | grep -c -P "^>gi\|\d+")  # does the first line have a match to ncbi pattern?
            if [ "$gdna_ncbi_count" -eq "1" ]
            then
               input_format="-sformat1 ncbi" # Required in order to preserve the ncbi (GenBank) -formatted headers
               output_format="-osformat2 ncbi" # Required in order to preserve the ncbi (GenBank) -formatted headers 
               echo "- The gdna file has NCBI formatted headers; count= $gdna_ncbi_count " >>$WorkDIR/logs/Pipeline_procedure.log
            else
               input_format="" # non-GenBank-formatted
               output_format="" # non-GenBank-formatted
               echo "- The gdna file has simple formatted headers; sequences will be size-sorted and outputted in the same format using EMBOSS sizeseq " >>$WorkDIR/logs/Pipeline_procedure.log
            fi
            # NOTE this step requires correct permissions and sufficient disk space at /usr/local/src/EMBOSS/EMBOSS-6.3.1/emboss/ for temp file write/read.  
            /usr/local/src/EMBOSS/EMBOSS-6.3.1/emboss/sizeseq -descending -sequences $tmpWorkDIR/data/${PRG}/SCFDIR/${xGDB}gdna.fa $input_format -outseq $tmpWorkDIR/data/${PRG}/SCFDIR/${xGDB}gdna.fa $output_format
            
            dateTime821=$(date +%Y-%m-%d\ %k:%M:%S)
            gdna_sorted_count=$(grep -c "^>" $tmpWorkDIR/data/${PRG}/SCFDIR/${xGDB}gdna.fa)
            if [ "$gdna_sorted_count" -eq "$gdna_count" ]  # from step 3
            then
               echo "${space}${gdna_sorted_count} sequences (${xGDB}gdna.fa) are now sorted by size (descending) - $dateTime821 (8.21)">>$WorkDIR/logs/Pipeline_procedure.log
            else
              error821="WARNING: Only ${gdna_sorted_count} out of ${gdna_count} sequences from ${xGDB}gdna.fa are present in the output. The sorting process may have failed or aborted due to disk space limits. $dateTime821 (8.21)"
            echo "${space}${error821}" >>$WorkDIR/logs/Pipeline_procedure.log; echo "$error821">>$WorkDIR/logs/Pipeline_error.log
            fi
            
            ### Now we copy genome sequence from GSQ or GTH SCFDIR to temporary directory for remote HPC (NOTE: this file has already been sorted by fasta size (descending) in step 8.21
            cp $tmpWorkDIR/data/${PRG}/SCFDIR/${xGDB}gdna.fa $RemoteDIR/SCFDIR/  # it could be repeat-masked for GSQ
            dateTime822=$(date +%Y-%m-%d\ %k:%M:%S)

			if ls -1 $RemoteDIR/SCFDIR/${xGDB}gdna.fa  >/dev/null 2>&1 # successful copy
            then
              echo "${space}Genome sequence file (${xGDB}gdna.fa) copied to $RemoteDIR/SCFDIR/ for HPC - $dateTime821 (8.22) ">>$WorkDIR/logs/Pipeline_procedure.log
            else
              error822="ERROR: Genome sequence file (${xGDB}gdna.fa) was not copied to $RemoteDIR/SCFDIR/ for HPC(8.21)"
              echo "$error822">>$WorkDIR/logs/Pipeline_procedure.log; echo "$error822">>$WorkDIR/logs/Pipeline_error.log
            fi

            ### Copy Transcript sequence to temporary directory 
#            cp $tmpWorkDIR/data/BLAST/${xGDB}${trn}.fa $RemoteDIR/${DIR}/ 
#            cp $tmpWorkDIR/data/download/${xGDB}${trn}.fa $RemoteDIR/${DIR}/ # this .fa has been validated for header

            cp $tmpWorkDIR/data/${PRG}/${DIR}/${xGDB}${trn}.fa $RemoteDIR/${DIR}/ # best option?
            
            dateTime825=$(date +%Y-%m-%d\ %k:%M:%S)

			if ls -1 $RemoteDIR/${DIR}/${xGDB}${trn}.fa  >/dev/null 2>&1 # successful copy
            then
              echo "${space}${tRN} sequence file (${xGDB}${trn}.fa) copied to $RemoteDIR/${DIR}/ for HPC - $dateTime825 (8.25)">>$WorkDIR/logs/Pipeline_procedure.log
            else
              error825="ERROR: ${tRN} sequence file (${xGDB}${trn}.fa) was not copied to $RemoteDIR/${DIR}/ for HPC (8.25)"
              echo "$error825">>$WorkDIR/logs/Pipeline_procedure.log; echo "$error825">>$WorkDIR/logs/Pipeline_error.log
            fi
            
            if [ "$PRG" == "GSQ" ]
            then
               
               ### Determine if transcript data are GenBank -formatted (d) or custom (D) - required in order to submit ${PRG} remote job
               gb_format_count=$(grep "^>gi|" $tmpWorkDIR/data/download/${xGDB}${trn}.fa | wc -l)
               if [ "$gb_format_count" -gt "0" ]
               then
                  fasta_header_type="d"
                  echo "${space}GenBank fasta headers detected, so ${PRG} 'dbest' = ${fasta_header_type} (8.23)">>$WorkDIR/logs/Pipeline_procedure.log
               else
                  fasta_header_type="D"
                  echo "${space}NO GenBank fasta headers detected, so ${PRG} 'dbest' = ${fasta_header_type} (8.23)">>$WorkDIR/logs/Pipeline_procedure.log
               fi
            else
            fasta_header_type="P" # Dummy value for GenomeThreader
            fi
            
            ############# AUTHENTICATE:  If authentication variables are in place, launch remote job via gsq_remote.php script ( with parameters ) ###########
            
            ## 8.3 If user is authenticated (username and refresh token are parsed from the ${PRG}_CompResParameter parameter string "-m" and must be present to proceed) then proceed, else log error
            
            if [[ $PRG_username != "" && $PRG_refresh_token != "" ]]
            
            then # THEN USER-AUTH option: User is authorized -- proceed! Otherwise go to ELSE USER-AUTH option and print error.
               
               # DEBUG ONLY echo "${space}Username $PRG_username and Authorization Token $PRG_refresh_token were found">>$WorkDIR/logs/Pipeline_procedure.log
               echo "${space}Username $PRG_username and Authorization Refresh Token were found">>$WorkDIR/logs/Pipeline_procedure.log ## don't display token on live site
               
               
            ############# SUBMIT JOB: Now launch php script that will submit remote job and query remote server for job ID and status (these are saved to Genomes.xGDB_Log):

               ### First purge e.g. "GSQ_EST_Job" ($Job) and "GSQ_Job_EST_Result" ($Result) table entries so no leftover value can found there:
               
               echo "update Genomes.xGDB_Log set $Job = \"\", $Result=\"\" where ID=$Id"|mysql -p$dbpass -u $mysqluser Genomes

               dateTime830=$(date +%Y-%m-%d\ %k:%M:%S)
               echo "${space}Launching ${prg}_remote.php script to initiate Remote Job $dateTime830  (8.30)">>$WorkDIR/logs/Pipeline_procedure.log
               
               php $ScriptDIR/${prg}_remote.php $Id $PRG_username $prg_server ${trn} $fasta_header_type ## launches script that submits remote job using curl, and updates Genomes.xGDB_Log with status. $Id $username $gsq_server (e.g. 128.196.1.13) $trn $type (hard-coded for now) 
               
               echo "${space}Issued command php $ScriptDIR/${prg}_remote.php $Id $PRG_username [refresh_token] $prg_server ${trn} $fasta_header_type">>$WorkDIR/logs/Pipeline_procedure.log

            #############  POLL FOR JOB STATUS (empty field vs 'PENDING' vs 'error') & JOB ID: 10 minute loop with i=5 sec ###########

               ## 8.35 While loop: At intervals, query for job status and job ID in MySQL table Genomes.xGDB_Log. Based on status value, determine whether to break out of loop early.
               dateTime835=$(date +%Y-%m-%d\ %k:%M:%S)
               msg835="Waiting for confirmation of job submission to HPC "
               echo "${space}$msg835 $dateTime835 (8.35) " >>$WorkDIR/logs/Pipeline_procedure.log
               end="120" # 120 seconds x 5 second sleep = 10 minutes. This should be plenty of time for job submission, could adjust down.
               
               ## (8.4) WHILE DO JOB-ID-RETURNED (Polling for job id in xGDB_Log
               while [[ $i -le $end ]]
               
               do
                  sleep 5
                  
                  ((i = i + 1))
                  ## Get job id and job status, if any
                  job_id=$(echo "select $Job from Genomes.xGDB_Log where ID=$Id "|mysql -p$dbpass -u $mysqluser -N) 
                  job_dir="job-${job_id}" ## Unique directory under archive/jobs containing output files, e.g. job-0001424449412643-5056a550b8-0001-007
                  job_status=$(echo "select $Result from Genomes.xGDB_Log where ID=$Id "|mysql -p$dbpass -u $mysqluser -N) ## e.g. if error, Invalid username/password combination. This will have been updated by webhook.php.
                  
                  # (debug status=error)        $job_status="error"
                  
                  if [ "$job_status" == "error" ] # IF SUBMIT-ERROR option: there was a problem! Remote HPC has failed. Exit wait loop.
                  then #
                     dateTime842=$(date +%Y-%m-%d\ %k:%M:%S)
                     error842="${space}ERROR: Job submit failed - $dateTime842 (8.42)"
                     echo "$error842">>$WorkDIR/logs/Pipeline_procedure.log; echo "$error842">>$WorkDIR/logs/Pipeline_error.log
                     break # exit due to SUBMIT-ERROR
                  fi # END IF SUBMIT-ERROR

                  if [ ! -z "$job_status" ] # SUBMIT-SUCCESS option: Not empty: The field has been updated to PENDING or QUEUED or PROCESSING_INPUTS or even RUNNING, ; job submission apparently succeeded!
                  then #
                     dateTime845=$(date +%Y-%m-%d\ %k:%M:%S)
                     echo "${space}Job submitted successfully (job_status='$job_status'). Job ID: $job_id $space - $dateTime845 (8.45)">>$WorkDIR/logs/Pipeline_procedure.log
                     break   # exit due to SUBMIT-SUCCESS
                     
                  fi # END SUBMIT-SUCCESS
                  if [ $i -eq $end ] #IF SUBMIT-TIMEDOUT
                  then
                     job_status="TIMEDOUT" # This will be final value if no "break"
                     dateTime846=$(date +%Y-%m-%d\ %k:%M:%S)
                     echo "${space}ERROR: Timed out waiting for job to submit!! - $dateTime846 (8.46)">>$WorkDIR/logs/Pipeline_procedure.log
                  fi # END SUBMIT-TIMEDOUT
                  
               done
               ## (8.4) DONE JOB-ID-RETURNED ('break' or 'done' goes to here; now test whether job submission is success or failure)
               
               echo "${space}Out of SUBMIT loop; job_status=$job_status">>$WorkDIR/logs/Pipeline_procedure.log
               
            ############# "Is my job RUNNING yet?" loop: Poll for job_status='RUNNING' or beyond (Query xGDB_Log every 5 seconds for up to 12 hours) ###########
            
               ## (8.5) if job_status='PENDING' (success) or beyond, then poll for 'running', else log error 
               
               if [[ "$job_status" == "PENDING" || "$job_status" == "SUBMITTED" || "$job_status" ==  "PENDING" || "$job_status" ==  "SUBMITTING" || "$job_status" ==  "PROCESSING_INPUTS" || "$job_status" ==  "STAGED" || "$job_status" ==  "STAGING_JOB" || "$job_status" ==  "STAGING_INPUTS" || "$job_status" ==  "QUEUED" ]]
               
               then # Contitue to query 'job_status' as we track the job through the system
                  
                  echo "${space}########## Remote $PRG Job Has Been Submitted ########## ">>$WorkDIR/logs/Pipeline_procedure.log
                  
                  # 8.50 First, we poll for job_status= 'RUNNING' using a do loop with hard-coded max, then start the job limit timer and poll for job_status= 'FINISHED'

                  k=0
                  last="39600" ##  Don't wait forever for queue to change; assign end time (12 h) in seconds.
                  echo "${space}The job is entering the job queue, but processing (job_status='RUNNING') has not yet started; ">>$WorkDIR/logs/Pipeline_procedure.log
                  echo "${space}So now we monitor job_status (once per 5 seconds, up to $last seconds); ">>$WorkDIR/logs/Pipeline_procedure.log
                  echo "${space}When job_status changes to either 'RUNNING','FAILED','STOPPED', or 'FINISHED' the wait loop will terminate.">>$WorkDIR/logs/Pipeline_procedure.log
                  dateTime850=$(date +%Y-%m-%d\ %k:%M:%S)
                  msg850="job_status is '$job_status - " # should be 'PENDING' here.
                  echo "${space}${msg850}${dateTime850} (8.50) " >>$WorkDIR/logs/Pipeline_procedure.log ## This message will NOT be replaced by sed. It displays initial status.
                  echo "- Checking at 5 second intervals for job_status change;" >>$WorkDIR/logs/Pipeline_procedure.log
                  echo "${space}job_status is now '$job_status' - $dateTime850 (8.50)" >>$WorkDIR/logs/Pipeline_procedure.log ## This message text WILL be replaced at intervals using 'sed' command below  (as long as text matches)

                  ## (8.55) poll up to 12h for job_status = 'running' or 'archiving_finished' (success), or 'failed' 'killed' 'stopped' 'paused' 'archiving_failed' (failure)
                  while [[ $k -le $last ]]  #
                  
                  do
                     
                     sleep 5
                     
                     ((k = k + 5))
                     
                     # swap out previous sleep log entry for new one each sleep cycle using 'sed'
                     dateTime855=$(date +%Y-%m-%d\ %k:%M:%S)
                     sed -i -e "s/^.*job_status is now .*$/${space}job_status is now '$job_status'; still waiting at $dateTime855 (elapsed = $k second) (8.55)/" $WorkDIR/logs/Pipeline_procedure.log
                     
                     ### run php script to check & update status (it will update jobs database) and then check Genomes.xGDB_Log database for status change:
                     ### queue status options from HPC (when made lower case) include: submitting, staging_job, processing_inputs, queued, running, failed, stopped (by user), archiving_finished.
                     ### If status indicates compute step has not started, continue looping.
                     ### Exit loop when status indicates compute step has started (running, failed, stopped, archiving_finished).
                     ### NOT NEEDED. DEPRECATE THIS SCRIPT 2/25/15 (Webhook.php does it all.) php $ScriptDIR/remote_job_status.php $job_id $PRG_username $PRG_refresh_token $Id $Result ## launches script that queries remote job status & updates Genomes.xGDB_Log. Arguments= job_id username refresh_token database_id data_type
                     job_status=$(echo "select $Result from Genomes.xGDB_Log where ID=$Id "|mysql -p$dbpass -u $mysqluser -N) ## GSQ_Job_Result or GTH_Job_Result, returns status=STAGING_JOB, RUNNING, etc.
                     
                     # job_status="running" ###### DEBUG ONLY #######
                     
                     if [[ "$job_status" == "RUNNING" || "$job_status" == "FAILED" || "$job_status" == "KILLED"  || "$job_status" == "STOPPED" || "$job_status" == "PAUSED" || "$job_status" == "FINISHED" ]] # Which means status is no longer submitting, processing_inputs, queued. Added 'FINISHED' to the choices since sometimes a failed job skips to this status 2-18-16 
                     
                     then
                        dateTime856=$(date +%Y-%m-%d\ %k:%M:%S)
                        echo "${space}Exiting the 'Is my job RUNNING yet?' loop with job status='$job_status' (elapsed $k sec) - $dateTime856 (8.56)">>$WorkDIR/logs/Pipeline_procedure.log
                        break # Exit out of the job_status loop!           
                     fi
                     if [ $k -eq $last ] #End of the road --job_status TIMED OUT
                     then
                        job_status="timedout" # This will be final value if no "break"
                        
                        error857="${space}ERROR: Timed out in the 'Is my job RUNNING yet?' loop !! (elapsed $k sec) (8.57)"
                        echo "$error857">>$WorkDIR/logs/Pipeline_procedure.log; echo "$error857">>$WorkDIR/logs/Pipeline_error.log
                     fi # END QUEUE-TIMED OUT
                 done ## (8.55) END poll up to 12h for job_status='RUNNING'
        
                  # We are out of the job_status loop, meaning the job_status is either: 1) RUNNING or 2) STOPPED/FAILED/KILLED or 3) we ran out of time.
 
             ############# Poll for job_status='FINISHED' (Query xGDB_Log every 5 seconds for up to Total Job Time Requested) ###########
                 
                  ## 8.6 "Is my job FINISHED?" loop: If job_status = 'RUNNING' or even some later stage on the way to 'FINISHED' (as opposed to 'STOPPED' or 'timedout') then poll for job_status 'FINISHED'
                  
                  if [[ "$job_status" == "RUNNING"  || "$job_status" == "CLEANING_UP" || "$job_status" == "ARCHIVING" || "$job_status" == "ARCHIVING_FINISHED" || "$job_status" == "FINISHED" ]]  ## for very small jobs, it may already have already passed by RUNNING before we start monitoring!
                  
                  then # 8.61 The HPC job is running, or is already in the process of moving data to archive.
                     echo "${space}######### Remote $PRG Job Now Processing #########">>$WorkDIR/logs/Pipeline_procedure.log
                     dateTime861=$(date +%Y-%m-%d\ %k:%M:%S)
                     msg861="job_status is now '$job_status' - "
                     echo "${space}${msg861}${dateTime861} (8.61) ">>$WorkDIR/logs/Pipeline_procedure.log
                     
                     ### 8.62 Get max job time for this job and convert to seconds
                     max_job_time=$(echo "SELECT max_job_time FROM Admin.apps WHERE program ='$Prg_HPC' AND is_default ='Y' "|mysql -p$dbpass -u $mysqluser -N Admin) # The maximum time expected for this job to be RUNNING (set by user)
                     max_job_sec=$(echo "SELECT TIME_TO_SEC(max_job_time) FROM Admin.apps WHERE program = '$Prg_HPC' AND is_default ='Y' "|mysql -p$dbpass -u $mysqluser -N Admin) # convert to seconds 

                     dateTime862=$(date +%Y-%m-%d\ %k:%M:%S)
                     msg862="We retrieved the max job time set for $Prg_HPC: $max_job_time ($max_job_time min or $max_job_sec sec) "
                     echo "${space}${msg862}${dateTime862} (8.62) ">>$WorkDIR/logs/Pipeline_procedure.log

                     ### 8.65 Use this value for wait time (plus cushion)

                     max_job_min=$(( $max_job_sec/60 ))
                     extra_sec=1200 ## allow extra 20 minutes as a cushion
                     extra_min=$(( $extra_sec/60 ))
                     wait_sec=$(( $max_job_sec + $extra_sec ))
                     wait_min=$(( $wait_sec/60 ))
                     
                     j=0 ; END=$wait_sec  ##  Assign END to the max_job_time
                     
                     
                     dateTime865=$(date +%Y-%m-%d\ %k:%M:%S)
                     msg865="Waiting for output from HPC-${prg} ($trn) at $ArchiveDIR/$job_dir/${extra_dir}${xGDB}${trn}.${prg} " # we are using the default HPC output directory (Data Store) 'archive/jobs'
                     echo "${space}$msg865 - $dateTime865 (8.65) " >>$WorkDIR/logs/Pipeline_procedure.log
                     echo "${space}So we wait up to $wait_min min (incl. cushion of $extra_min min)" >>$WorkDIR/logs/Pipeline_procedure.log
                     echo "- Checking at 5 second intervals for output from HPC-${prg} ($trn) " >>$WorkDIR/logs/Pipeline_procedure.log
                     echo "${space}Still waiting for output from HPC-${prg} ($trn) - $dateTime865 (8.65)" >>$WorkDIR/logs/Pipeline_procedure.log # DON'T CHANGE THIS TEXT WITHOUT CHANGING 'sed' COMMAND BELOW! 
                     
                     ## 8.7 Poll for job_status='FINISHED' (Start the loop)
                     while [[ $j -le $END ]]  # thanks to http://stackoverflow.com/questions/169511/how-do-i-iterate-over-a-range-of-numbers-in-bash
                     do
                        
                        sleep 5
                        
                        ((j = j + 5))
                        
                        # swap out previous sleep log entry for new one each sleep cycle using 'sed'
                        dateTime870=$(date +%Y-%m-%d\ %k:%M:%S)
                        elapsed=$(( $j/60 )) # in minutes
                        sed -i -e "s/^.*Still waiting for output from HPC-${prg} ($trn).*$/${space}Still waiting for output from HPC-${prg} ($trn) $dateTime870 ($elapsed min) (8.70)/" $WorkDIR/logs/Pipeline_procedure.log

                     ## 8.75 If job_status =FINISHED (success) then copy outputs (if any) to scratch dir. and break out of loop. If not, stay in loop 

                        # DEPRECATED php $ScriptDIR/remote_job_status.php $job_id $PRG_username $PRG_refresh_token $Id $Result ## launches script that queries remote job status & updates Genomes.xGDB_Log. Arguments= job_id username refresh_token database_id data_type
                        job_status=$(echo "select $Result from Genomes.xGDB_Log where ID=$Id "|mysql -p$dbpass -u $mysqluser -N) # returns STATUS
                     
          		        if [[ "$job_status" == "FINISHED" ]]  ##  8.75 If job_status =archiving_finished 
                        
                        then  ## We are going to check for output file, and if present, cat it to tmpWorkDIR, count the output number, log it, and then break out of the j loop (8.75)
                         ## (8.8) IF JOB-OUTPUT-EXISTS (if output file present under /data/archive/jobs/ )
                         
                         
                         ## Specify paths for output data from HPC:
                         
                         hpc_archive_path=$ArchiveDIR/$job_dir/${extra_dir}${xGDB}${trn}.${prg}
                           #  We set archive=true during job submission, so job output goes to /iplant/user/archive/jobs/ (on Data Store) by default. 1-30-16 NOTE extra_dir should be "" (empty)
                         hpc_download_path=$tmpWorkDIR/data/download/${xGDB}${trn}.${prg}        #  This script will copy data to the download directory on the user's mounted volume
                         hpc_OUT_path=$tmpWorkDIR/data/${PRG}/${PRG}OUT/${xGDB}${trn}.${prg}  #  The script also copies the output data to a location where it will be used to load MySQL database
                         
                         
                           if [ -s $hpc_archive_path ] ## IF OUTPUT EXISTS IN ARCHIVE - (if HPC returned an output file to archive -- this is not always the case)
                        
                           then
                           
                               # 8.81 The Remote process finished with output!! Hurray! Log this.
                           
                               dateTime881=$(date +%Y-%m-%d\ %k:%M:%S)
                               echo "${space}$tRN remote job is complete; HPC-${prg} output detected at $hpc_archive_path - $dateTime881 (8.81)">>$WorkDIR/logs/Pipeline_procedure.log
                           
                               echo "${space}######### Remote Job Results Returned ############">>$WorkDIR/logs/Pipeline_procedure.log
                           
                               # First copy Remote GeneSeqer output to download directory (for archive)
                           
                               cat $hpc_archive_path >$hpc_download_path # e.g. GDB001prot.gth
                           
                               # 8.82 Now copy Remote GeneSeqer output to ${PRG}OUT directory where it will be picked up and parsed.
                           
                               cat $hpc_archive_path >$hpc_OUT_path
                               
                           		# Count the output
                               dateTime882=$(date +%Y-%m-%d\ %k:%M:%S)
                               count882=$(grep -c "MATCH" $hpc_OUT_path)
                           
                               if [ "$count882" -ge "1" ] # IF DATA EXISTS: If more than 0 alignments;
                               then
                                  ## DEPRECATE THIS??? 3-18-15 echo "Update Admin.jobs set status =\"archiving_finished\", job_end_time=\"$dateTime882\" where job_id = \"${job_id}\" "|mysql -p$dbpass -u $mysqluser # just in case the status loop didn't catch this status and update the database already.
                                  msg882="$count882 Remotely-Computed ${tRN} spliced alignments found at $hpc_archive_path "
                                  echo "${space}${msg882}${dateTime882} (8.82)" >>$WorkDIR/logs/Pipeline_procedure.log
                                  echo "${space}Output file copied to download and $PRG output directories on scratch disk" >>$WorkDIR/logs/Pipeline_procedure.log
                              
                               else ## output is empty;
                                  echo "Update Admin.jobs set status =\"EMPTY\", job_end_time=\"$dateTime882\" where job_id = \"${job_id}\" "|mysql -p$dbpass -u $mysqluser
                                  msg882="ERROR: HPC-${prg} output file $hpc_archive_path exists but the number of spliced alignments returned was zero. Check your input data to see what might be the problem. "
                                  echo "${space}${msg882}${dateTime882} (8.82)" >>$WorkDIR/logs/Pipeline_procedure.log
                               fi
                               
                            else ## (8.75) No output file, even though HPC job status is ARCHIVING_FINISHED or ARCHIVING_FAILED
                                dateTime875=$(date +%Y-%m-%d\ %k:%M:%S)
                                echo "Update Admin.jobs set status =\"NO_OUTPUT\", job_end_time=\"$dateTime875\" where job_id = \"${job_id}\" "|mysql -p$dbpass -u $mysqluser
                                error875="ERROR: HPC-${prg} output file at not found at $hpc_archive_path . The segment may be too small or there was a problem with the sequence format  - $dateTime875 (8.75)"
                                echo "${space}${error875}" >>$WorkDIR/logs/Pipeline_procedure.log; echo "$error875">>$WorkDIR/logs/Pipeline_error.log

                            fi  ## (8.8) END IF JOB-OUTPUT-EXISTS
                            
                        break ## We leave the loop now due to job_status='archiving_finished'!
                        
                        fi # (8.75) END IF job_status='archiving_finished' 
                        
                        ##  IF we get past here, it must mean job_status IS NOT 'archiving_finished' - so we are still in the polling loop
                        
                        if [ "$j" -eq "$END" ] ## (8.85) If job_status='TIMEDOUT' (webhook.php writes this to xGDB_Log if we time out) then log this as an error before we leave the loop
                        then
                           job_status="TIMEDOUT" # This will be final value if no "break"
                       	   dateTime885=$(date +%Y-%m-%d\ %k:%M:%S)
                           error885="${space}ERROR:  xGDBvm timed out at $elapsed min waiting for $tRN job to finish ${dateTime885} (8.85) "
                           echo "${space}${error885}" >>$WorkDIR/logs/Pipeline_procedure.log;echo "$error885" >>$WorkDIR/logs/Pipeline_error.log;
                           echo "update Admin.jobs set status = \"TIMEDOUT\" where job_id=\"$job_id\""|mysql -p$dbpass -u $mysqluser
                           echo "update Admin.jobs set job_end_time = \"$dateTime890\" where job_id=\"$job_id\""|mysql -p$dbpass -u $mysqluser
                           echo "update Genomes.xGDB_Log set $Result = \"TIMEDOUT\" where ID=$Id"|mysql -p$dbpass -u $mysqluser
                    	fi ## (8.85) END IF job_status=timedout  (the 'while' loop will now end as it's reached the counter limit)
                     done
                     
                     ## 8.7 Done with polling for job_status='FINISHED' -- if we got here, we either broke out (success) or timed out (failure) so go to the 8.6 END IF statement
                     
                  else  ## 8.6 If job_status NOT 'RUNNING' and not 'CLEANING_UP' and not 'ARCHIVING' and not 'ARCHIVING_FINISHED' and not 'FINISHED' (success)-- it must have been STOPPED, FAILED, ARCHIVING_FAILED,  timed out - so log that status and go to the 8.6 END IF statement
                        dateTime863=$(date +%Y-%m-%d\ %k:%M:%S)
                     if [[ "$job_status" == "STOPPED" || "$job_status" == "KILLED" || "$job_status" == "FAILED" || "$job_status" == "ARCHIVING_FAILED" ]]  ## Fatal to success. 2-3-2016 Note the API is not consistent, and some jobs that return 'FAILED' status may continue to run, thus making the logic here incorrect.
                     then
                     	error863="${space}ERROR: $tRN remote job status is $job_status; no output data - $dateTime863 (8.63)" 	
                     	echo "${space}${error863}">>$WorkDIR/logs/Pipeline_procedure.log;echo "${space}${error863}" >>$WorkDIR/logs/Pipeline_error.log
                        echo "update Admin.jobs set job_end_time = \"$dateTime863\" where job_id=\"$job_id\""|mysql -p$dbpass -u $mysqluser
                        echo "update Genomes.xGDB_Log set $Result = \"$job_status\"  where ID=$Id"|mysql -p$dbpass -u $mysqluser
                     fi ## END IF JOB-STOPPED
                     
                  fi ## 8.6 END If job_status = 'running' or 'archiving_finished' -- we either have output, or ran over time, or job stopped or failed. Go to 8.91

                  dateTime865=$(date +%Y-%m-%d\ %k:%M:%S)
                  echo "${space}End of $tRN remote compute job run - $dateTime865 (8.65)" >>$WorkDIR/logs/Pipeline_procedure.log
                  
               else  ## (8.50) If status not 'PENDING' when we left the loop, error! Job did not initiate in allotted time, or returned an error status

                  if [ "$job_status" == "timedout" ] # (5) IF JOB-ID-TIMEOUT option:
                  then
                     dateTime858=$(date +%Y-%m-%d\ %k:%M:%S)
                     error858="${space}ERROR: No Job ID was retrieved in 10 minutes - skipping Remote Compute:  - $dateTime858 (8.58)"
                     echo "$error858">>$WorkDIR/logs/Pipeline_procedure.log; echo "$error858">>$WorkDIR/logs/Pipeline_error.log
                  else
                     dateTime859=$(date +%Y-%m-%d\ %k:%M:%S)
                     error857="${space}ERROR: job submit status blank or returned an error- $dateTime859 (8.59)"
                     echo "$error859">>$WorkDIR/logs/Pipeline_procedure.log; echo "$error859">>$WorkDIR/logs/Pipeline_error.log
                  fi # END IF JOB-ID-TIMEOUT

               fi  ## (8.5) END If status ='PENDING' 

            else  ## 8.3  If user is NOT authenticated (An ERROR exists; auth refresh token / username not found. No remote job sent. Report error.)
       
               dateTime836=$(date +%Y-%m-%d\ %k:%M:%S)
               error836="${space}ERROR: Auth refresh token / username not found. - $dateTime836 (8.36)"
               echo "$error836">>$WorkDIR/logs/Pipeline_procedure.log; echo "$error836">>$WorkDIR/logs/Pipeline_error.log
               
            fi  ##  8.3 END If user is authenticated (Either remote data was processed, or an error exists. In any case, move on to end of REMOTE option)
            
   ############# End of job_status Polling and Logging - either we have output data or we don't ##################

            # 8.91 FINALLY, remove the temporary directory since we've (hopefully) already copied its contents to destination files
            dateTime891=$(date +%Y-%m-%d\ %k:%M:%S)
            if [ -d $RemoteDIR ]
            then
           	   #rm -rf $RemoteDIR  # commment out when debugging
               echo "${space}Removed temp directory for remote input (${RemoteDIR})- ${dateTime891}  (8.91)" >>$WorkDIR/logs/Pipeline_procedure.log
            else
               echo "${space}ERROR: The temp directory for remote input (${RemoteDIR}) is missing. Could not remove it.- ${dateTime891}  (8.91)" >>$WorkDIR/logs/Pipeline_procedure.log
            fi
            echo "${space}########## End of $tRN Remote Job Process ########## ">>$WorkDIR/logs/Pipeline_procedure.log
         else
            ## (8.2) ELSE REMOTE (NO Remote parameter present. Process any data locally)
            
            #############################  END of remote compute resource section #################################
            
            ############################# Run GeneSeqer or GenomeThreader locally #################################
            
            ## (8.25) IF-TRANSCRIPT-LOCAL
            if [ "$trn_count" -gt 0 ] # IF LOCAL-TRANSCRIPT-RAW-DATA
            then
               
               echo "${space}##################### $tRN Spliced Alignment to Genome (LOCAL Processing) ######################## " >>$WorkDIR/logs/Pipeline_procedure.log
                
               if [ "$PRG" == "GSQ" ]
               then
                  # GSQ: Start INTERNAL Spliced Alignment Process using SplitMakeArray${PRG}.pl with "Internal" flag (splits transcript file into 70Mb chunks, creates index, and then launches GeneSeqer on local processors)
                  dateTime825=$(date +%Y-%m-%d\ %k:%M:%S)
                  msg825="${tRN} spliced-alignment to genome initiated locally using /xGDBvm/scripts/SplitMakeArrayGSQ.pl: "
                  echo "$space$msg825$dateTime825 (8.25)">>$WorkDIR/logs/Pipeline_procedure.log
                  echo " - ${PRG} parameter set is $PRGparameter " >>$WorkDIR/logs/Pipeline_procedure.log       
                  /xGDBvm/scripts/SplitMakeArrayGSQ.pl $tmpWorkDIR/data/GSQ/${DIR}/${xGDB}${trn}.fa 70 $tmpWorkDIR/data/GSQ/SCFDIR/${xGDB}gdna.fa "$GSQparameter"
               fi
               if [ "$PRG" == "GTH" ]
               then
                  # GTH: Start INTERNAL Spliced Alignment Process using GenomeThreader with "Internal" flag
                  dateTime825=$(date +%Y-%m-%d\ %k:%M:%S)
                  msg825="${tRN} spliced-alignment to genome initiated locally using GenomeThreader: "
                  echo "$space$msg825$dateTime825 (8.25)">>$WorkDIR/logs/Pipeline_procedure.log
                  echo " - ${PRG} parameter set is $PRGparameter " >>$WorkDIR/logs/Pipeline_procedure.log       
                  if (( $nbproc > 1 ))
                  then
                     mkdir $tmpWorkDIR/data/GTH/GTHOUT/SPLIT
                     cd $tmpWorkDIR/data/GTH/SCFDIR
                     /usr/local/bin/fastasplit.pl -i ${xGDB}gdna.fa -n $nbproc -o $tmpWorkDIR/data/GTH/GTHOUT/SPLIT
                     cd $tmpWorkDIR/data/GTH/GTHOUT/SPLIT
                     i=0
                     for g in *; do
                       ((i++)); mkdir TMP$i; mv $g TMP$i; cd TMP$i; cp $tmpWorkDIR/data/GTH/Protein/${xGDB}prot.fa ./;
                       /usr/local/bin/gth -genomic $g -protein ${xGDB}prot.fa $GTHparameter -o gthout$i &
                       cd ..
                     done
                     wait
                     cat TMP*/gthout* > $tmpWorkDIR/data/GTH/GTHOUT/${xGDB}prot.gth
                     cd $tmpWorkDIR
                  else
                     /usr/local/bin/gth -genomic $tmpWorkDIR/data/GTH/SCFDIR/${xGDB}gdna.fa -protein $tmpWorkDIR/data/GTH/Protein/${xGDB}prot.fa $GTHparameter -o $tmpWorkDIR/data/GTH/GTHOUT/${xGDB}prot.gth
                  fi
               fi
               ## (8.25) ELSE IF-TRANSCRIPT-LOCAL
            else
               dateTime825=$(date +%Y-%m-%d\ %k:%M:%S)
               msg825="No ${tRN} input data found, skipping spliced alignment step for this data type. "
               echo "$space$msg825$dateTime825 (8.25)">>$WorkDIR/logs/Pipeline_procedure.log
            fi # END ELSE LOCAL-TRANSCRIPT-RAW-DATA
         fi
         ## (8.25) END IF-TRANSCRIPT-LOCAL
         ## (8.2) END ELSE REMOTE option (local or remote processing has occured, or errored out)
         
         ## 8.95 Check for output from Transcript spliced alignment (local or remote) and report:

        if [ "$trn_count" -gt 0 ] # IF input data exists for this type
        then 
           dateTime895=$(date +%Y-%m-%d\ %k:%M:%S)
           
           OUT_path=$tmpWorkDIR/data/${PRG}/${PRG}OUT/${xGDB}${trn}.${prg}  # same for HPC or local.  UPDATED 2-17-16, was using hpc_OUT_path, not consistently defined.
           
           if [ -s $OUT_path ] # Transcript or protein spliced aligmnent output (MUST be a single file) exists for this job (HPC or local).
           then
               count895=$(grep -c "MATCH" $OUT_path)
               msg895=" ${tRN} spliced alignments completed and sent to ${PRG} output directory $OUT_path "
               echo "$space$count895$msg895$dateTime895 (8.95)">>$WorkDIR/logs/Pipeline_procedure.log
            else
               error895="ERROR: $PRG ${tRN} spliced alignment output is empty or missing $dateTime895 (8.95) "
               echo "${error895}">>$WorkDIR/logs/Pipeline_error.log
               echo "${space}${error895}">>$WorkDIR/logs/Pipeline_procedure.log
            fi
         fi
    fi
      ## (8.1) END ELSE IF-PRECOMPUTED (either precomputed or de novo data was processed)
      
   done
   ## (8.0) DONE TRANSCRIPT-TYPE (go to top of loop to process the next transcript type, or exit loop)
   
   #End of Step 8
   
   dateTime899=$(date +%Y-%m-%d\ %k:%M:%S)
   msg899="* Step 8 completed "
   echo "$space$msg899$dateTime899">>$WorkDIR/logs/Pipeline_procedure.log

 
   ##########################################################
   # Step 9. Parse GeneSeqer/GenomeThreader output to .sql #
   ##########################################################
   #Parse GeneSeqer output in working directory (from run-time or pre-computed source), create .sql (insert) files in working directory
   
   dateTime900=$(date +%Y-%m-%d\ %k:%M:%S)
   msg900="| Step 9: Parse GSQ/GTH output to .sql load files "
   echo "$dline" >>$WorkDIR/logs/Pipeline_procedure.log
   echo "$msg900$dateTime900">>$WorkDIR/logs/Pipeline_procedure.log
   echo "$dline" >>$WorkDIR/logs/Pipeline_procedure.log
   
   if [ -s $tmpWorkDIR/data/GSQ/GSQOUT/${xGDB}est.gsq ] # not empty
   then
      $ScriptDIR/xGDBload_PgsFromGSQ.pl -t 'gseg_est_good_pgs' $tmpWorkDIR/data/GSQ/GSQOUT/${xGDB}est.gsq >$tmpWorkDIR/data/XGDB_MYSQL/${xGDB}gseg_est_good_pgs.sql
      dateTime901=$(date +%Y-%m-%d\ %k:%M:%S)
      if [ -s $tmpWorkDIR/data/XGDB_MYSQL/${xGDB}gseg_est_good_pgs.sql ]
      then
         msg901="${space}All EST spliced alignments were parsed. $dateTime901 (9.01) "
         echo "$msg901">>$WorkDIR/logs/Pipeline_procedure.log
      else
         error901="${space}ERROR: no EST spliced alignments were parsed from $tmpWorkDIR/data/GSQ/GSQOUT/${xGDB}est.gsq; $dateTime901 (9.01). "
         echo "$error901">>$WorkDIR/logs/Pipeline_procedure.log; echo "$error901">>$WorkDIR/logs/Pipeline_error.log
      fi
   fi
   
## further work needed to incorporate error checking in the sections below ##

   if [ -s $tmpWorkDIR/data/GSQ/GSQOUT/${xGDB}cdna.gsq ] # not empty
   then
      $ScriptDIR/xGDBload_PgsFromGSQ.pl -t 'gseg_cdna_good_pgs' $tmpWorkDIR/data/GSQ/GSQOUT/${xGDB}cdna.gsq >$tmpWorkDIR/data/XGDB_MYSQL/${xGDB}gseg_cdna_good_pgs.sql
      dateTime902=$(date +%Y-%m-%d\ %k:%M:%S)
      if [ -s $tmpWorkDIR/data/XGDB_MYSQL/${xGDB}gseg_cdna_good_pgs.sql ]
      then
         msg902="${space}All cDNA spliced alignments were parsed. $dateTime902 (9.02) "
         echo "$msg902">>$WorkDIR/logs/Pipeline_procedure.log
      else
         error902="${space}ERROR: no cDNA spliced alignments were parsed from $tmpWorkDIR/data/GSQ/GSQOUT/${xGDB}cdna.gsq; $dateTime902 (9.02). "
         echo "$error902">>$WorkDIR/logs/Pipeline_procedure.log; echo "$error902">>$WorkDIR/logs/Pipeline_error.log
      fi
   fi

   if [ -s $tmpWorkDIR/data/GSQ/GSQOUT/${xGDB}tsa.gsq ] # not empty
   then
      $ScriptDIR/xGDBload_PgsFromGSQ.pl -t 'gseg_put_good_pgs' $tmpWorkDIR/data/GSQ/GSQOUT/${xGDB}tsa.gsq >$tmpWorkDIR/data/XGDB_MYSQL/${xGDB}gseg_put_good_pgs.sql
      dateTime903=$(date +%Y-%m-%d\ %k:%M:%S)
      if [ -s $tmpWorkDIR/data/XGDB_MYSQL/${xGDB}gseg_put_good_pgs.sql ]
      then
         msg903="${space}All TSA spliced alignments were parsed. $dateTime903 (9.03) "
         echo "$msg903">>$WorkDIR/logs/Pipeline_procedure.log
      else
         error903="${space}ERROR: no TSA spliced alignments were parsed from $tmpWorkDIR/data/GSQ/GSQOUT/${xGDB}tsa.gsq; $dateTime903 (9.03). "
         echo "$error903">>$WorkDIR/logs/Pipeline_procedure.log; echo "$error903">>$WorkDIR/logs/Pipeline_error.log
      fi
   fi

   # Parse GenomeThreader output in working directory (from run-time or pre-computed source), create .sql (insert) files in working directory

   if [ -s $tmpWorkDIR/data/GTH/GTHOUT/${xGDB}prot.gth ] # not empty
   then
      $ScriptDIR/xGDBload_PgsFromGTH.pl -t 'gseg_pep_good_pgs' $tmpWorkDIR/data/GTH/GTHOUT/${xGDB}prot.gth >$tmpWorkDIR/data/XGDB_MYSQL/${xGDB}gseg_pep_good_pgs.sql
      dateTime904=$(date +%Y-%m-%d\ %k:%M:%S)
      if [ -s $tmpWorkDIR/data/XGDB_MYSQL/${xGDB}gseg_pep_good_pgs.sql ]
      then
         msg904="${space}All Protein spliced alignments were parsed. $dateTime904 (9.04) "
         echo "$msg904">>$WorkDIR/logs/Pipeline_procedure.log
      else
         error904="${space}ERROR: no Protein spliced alignments were parsed from $tmpWorkDIR/data/GTH/GTHOUT/${xGDB}prot.gth $dateTime904 (9.04). "
         echo "$error904">>$WorkDIR/logs/Pipeline_procedure.log; echo "$error902">>$WorkDIR/logs/Pipeline_error.log
      fi
   fi

      dateTime999=$(date +%Y-%m-%d\ %k:%M:%S)
      msg999="* Step 9 completed "
      echo "$space$msg999$dateTime999">>$WorkDIR/logs/Pipeline_procedure.log
   
   # End step 9
   #######################################
   # Step 10. Load MySQL good_pgs tables #
   #######################################
   dateTime1000=$(date +%Y-%m-%d\ %k:%M:%S)
   msg1000="| Step 10: Load GSQ/GTH output to MySQL. "
   echo "$dline" >>$WorkDIR/logs/Pipeline_procedure.log
   echo "$msg1000$dateTime1000">>$WorkDIR/logs/Pipeline_procedure.log
   echo "$dline" >>$WorkDIR/logs/Pipeline_procedure.log
   
   if [ -s $tmpWorkDIR/data/XGDB_MYSQL/${xGDB}gseg_est_good_pgs.sql ]
   then
      mysql -p$dbpass -u $mysqluser $xGDB < $tmpWorkDIR/data/XGDB_MYSQL/${xGDB}gseg_est_good_pgs.sql
      count1001=$(echo "select count(*) from gseg_est_good_pgs"|mysql -p$dbpass -u $mysqluser $xGDB -N)
      gi_match1001=$(echo "select count(*) from gseg_est_good_pgs as a where a.gi in (select b.gi from est as b)"|mysql -p$dbpass -u $mysqluser $xGDB -N) ## Make sure gi's match
      gseg_match1001=$(echo "select count(*) from gseg_est_good_pgs where gseg_gi in (select gi from gseg)"|mysql -p$dbpass -u $mysqluser $xGDB -N) ## Make sure gseg_gi's match
      dateTime1001=$(date +%Y-%m-%d\ %k:%M:%S)

      if [[ "$count1001" -eq "$gi_match1001" && "$count1001" -eq "$gseg_match1001" ]]
      then
         msg1001="$count1001 EST spliced alignments loaded to MySQL table $xGDB.gseg_est_good_pgs. "
         echo "${space}${msg1001}${dateTime1001} (10.01)">>$WorkDIR/logs/Pipeline_procedure.log
      else
         msg1001="$count1001 est spliced alignments loaded to MySQL table $xGDB.gseg_est_good_pgs, but there was an ID mismatch with est table ($gi_match1001 matches) or gseg table ($gseg_match1001 matches). "
         error1001="ERROR: ${msg1001}${dateTime1001} (10.01)"
         echo "$error1001">>$WorkDIR/logs/Pipeline_procedure.log; echo "$error1001">>$WorkDIR/logs/Pipeline_error.log
      fi
      SPLICEALIGN="T"   # flag for CpGAT
   else
      dateTime1001=$(date +%Y-%m-%d\ %k:%M:%S)
      msg1001="No EST spliced alignments to load. ">>$WorkDIR/logs/Pipeline_procedure.log
      echo "$space$msg1001$dateTime1001 (10.01)">>$WorkDIR/logs/Pipeline_procedure.log
   fi
   
   #### Load MySQL table, count entries and check ID match with sequence tables (est/cdna/put/pep, gseg)###
      # NOTE: this section is begging to be compacted using a for.. in.. do..  loop
   if [ -s $tmpWorkDIR/data/XGDB_MYSQL/${xGDB}gseg_cdna_good_pgs.sql ]
   then
      mysql -p$dbpass -u $mysqluser $xGDB < $tmpWorkDIR/data/XGDB_MYSQL/${xGDB}gseg_cdna_good_pgs.sql
      count1002=$(echo "select count(*) from gseg_cdna_good_pgs"|mysql -p$dbpass -u $mysqluser $xGDB -N)
      gi_match1002=$(echo "select count(*) from gseg_cdna_good_pgs as a where a.gi in (select b.gi from cdna as b)"|mysql -p$dbpass -u $mysqluser $xGDB -N) ## Make sure gi's match
      gseg_match1002=$(echo "select count(*) from gseg_cdna_good_pgs where gseg_gi in (select gi from gseg)"|mysql -p$dbpass -u $mysqluser $xGDB -N) ## Make sure gseg_gi's match
      dateTime1002=$(date +%Y-%m-%d\ %k:%M:%S)

      if [[ "$count1002" -eq "$gi_match1002" && "$count1002" -eq "$gseg_match1002" ]]
      then
         msg1002="$count1002 cDNA spliced alignments loaded to MySQL table $xGDB.gseg_cdna_good_pgs. "
         echo "${space}${msg1002}${dateTime1002} (10.02)">>$WorkDIR/logs/Pipeline_procedure.log
      else
         msg1002="$count1002 cdna spliced alignments loaded to MySQL table $xGDB.gseg_cdna_good_pgs, but there was an ID mismatch with cdna table ($gi_match1002 matches) or gseg table ($gseg_match1002 matches). "
         error1002="ERROR: ${msg1002}${dateTime1002} (10.02)"
         echo "$error1002">>$WorkDIR/logs/Pipeline_procedure.log; echo "$error1002">>$WorkDIR/logs/Pipeline_error.log
      fi
      SPLICEALIGN="T"   # flag for CpGAT
   else
      dateTime1002=$(date +%Y-%m-%d\ %k:%M:%S)
      msg1002="No cDNA spliced alignments to load. ">>$WorkDIR/logs/Pipeline_procedure.log
      echo "$space$msg1002$dateTime1002 (10.02)">>$WorkDIR/logs/Pipeline_procedure.log
   fi
   
   if [ -s $tmpWorkDIR/data/XGDB_MYSQL/${xGDB}gseg_put_good_pgs.sql ]
   then
      mysql -p$dbpass -u $mysqluser $xGDB < $tmpWorkDIR/data/XGDB_MYSQL/${xGDB}gseg_put_good_pgs.sql
      count1003=$(echo "select count(*) from gseg_put_good_pgs"|mysql -p$dbpass -u $mysqluser $xGDB -N)
      gi_match1003=$(echo "select count(*) from gseg_put_good_pgs as a where a.gi in (select b.gi from put as b)"|mysql -p$dbpass -u $mysqluser $xGDB -N) ## Make sure gi's match
      gseg_match1003=$(echo "select count(*) from gseg_put_good_pgs where gseg_gi in (select gi from gseg)"|mysql -p$dbpass -u $mysqluser $xGDB -N) ## Make sure gseg_gi's match
      dateTime1003=$(date +%Y-%m-%d\ %k:%M:%S)

      if [[ "$count1003" -eq "$gi_match1003" && "$count1003" -eq "$gseg_match1003" ]]
      then
         msg1003="$count1003 protein spliced alignments loaded to MySQL table $xGDB.gseg_put_good_pgs. "
         echo "${space}${msg1003}${dateTime1003} (10.03)">>$WorkDIR/logs/Pipeline_procedure.log
      else
         msg1003="$count1003 TSA spliced alignments loaded to MySQL table $xGDB.gseg_put_good_pgs, but there was an ID mismatch with put (TSA) table ($gi_match1003 matches) or gseg table ($gseg_match1003 matches). "
         error1003="ERROR: ${msg1003}${dateTime1003} (10.03)"
         echo "$error1003">>$WorkDIR/logs/Pipeline_procedure.log; echo "$error1003">>$WorkDIR/logs/Pipeline_error.log
      fi
      SPLICEALIGN="T"   # flag for CpGAT
   else
      dateTime1003=$(date +%Y-%m-%d\ %k:%M:%S)
      msg1003="No TSA spliced alignments to load. ">>$WorkDIR/logs/Pipeline_procedure.log
      echo "$space$msg1003$dateTime1003 (10.03)">>$WorkDIR/logs/Pipeline_procedure.log
   fi

   if [ -s $tmpWorkDIR/data/XGDB_MYSQL/${xGDB}gseg_pep_good_pgs.sql ]
   then
      mysql -p$dbpass -u $mysqluser $xGDB < $tmpWorkDIR/data/XGDB_MYSQL/${xGDB}gseg_pep_good_pgs.sql
      count1004=$(echo "select count(*) from gseg_pep_good_pgs"|mysql -p$dbpass -u $mysqluser $xGDB -N)
      gi_match1004=$(echo "select count(*) from gseg_pep_good_pgs as a where a.gi in (select b.gi from pep as b)"|mysql -p$dbpass -u $mysqluser $xGDB -N) ## Make sure gi's match
      gseg_match1004=$(echo "select count(*) from gseg_pep_good_pgs where gseg_gi in (select gi from gseg)"|mysql -p$dbpass -u $mysqluser $xGDB -N) ## Make sure gseg_gi's match
      dateTime1004=$(date +%Y-%m-%d\ %k:%M:%S)

      if [[ "$count1004" -eq "$gi_match1004" && "$count1004" -eq "$gseg_match1004" ]]
      then
         msg1004="$count1004 protein spliced alignments loaded to MySQL table $xGDB.gseg_pep_good_pgs. "
         echo "${space}${msg1004}${dateTime1004} (10.04)">>$WorkDIR/logs/Pipeline_procedure.log
      else
         msg1004="$count1004 pep spliced alignments loaded to MySQL table $xGDB.gseg_pep_good_pgs, but there was an ID mismatch with pep table ($gi_match1004 matches) or gseg table ($gseg_match1004 matches). "
         error1004="ERROR: ${msg1004}${dateTime1004} (10.04)"
         echo "$error1004">>$WorkDIR/logs/Pipeline_procedure.log; echo "$error1004">>$WorkDIR/logs/Pipeline_error.log
      fi
      SPLICEALIGN="T"   # flag for CpGAT
   else
      dateTime1004=$(date +%Y-%m-%d\ %k:%M:%S)
      msg1004="No Protein spliced alignments to load. ">>$WorkDIR/logs/Pipeline_procedure.log
      echo "$space$msg1004$dateTime1004 (10.04)">>$WorkDIR/logs/Pipeline_procedure.log
   fi
   
   dateTime1099=$(date +%Y-%m-%d\ %k:%M:%S)
   msg1099="* Step 10 completed "
   echo "$space$msg1099$dateTime1099">>$WorkDIR/logs/Pipeline_procedure.log
   
   #End of Step 10
   #########################################################
   # Step 11. Cognates, Clonepairs  (if metadata present   #
   #########################################################
   dateTime1100=$(date +%Y-%m-%d\ %k:%M:%S)
   msg1100="| Step 11: Calculating Cognates, Clonepairs (if metadata present) "
   echo "$dline" >>$WorkDIR/logs/Pipeline_procedure.log
   echo "$msg1100$dateTime1100">>$WorkDIR/logs/Pipeline_procedure.log
   echo "$dline" >>$WorkDIR/logs/Pipeline_procedure.log
   
   cdna_count=$(echo "select count(*) from gseg_cdna_good_pgs"|mysql -p$dbpass -u $mysqluser $xGDB -N)
   est_count=$(echo "select count(*) from gseg_est_good_pgs"|mysql -p$dbpass -u $mysqluser $xGDB -N)
   
   if [[ "$cdna_count" -ge "1"  || "$est_count" -ge "1" ]]  ## There is cDNA or EST transcript alignment data; otherwise skip
   then
      
      # Mark cdna/est Cognate, set est 5' 3', set est ClonePairs
      $ScriptDIR/xGDB_markCognate.pl -T 'gseg_cdna_good_pgs' -P $dbpass -U $mysqluser -D $xGDB
      $ScriptDIR/xGDB_markCognate.pl -T 'gseg_est_good_pgs' -P $dbpass -U $mysqluser -D $xGDB
      $ScriptDIR/xGDB_markESTprimality.sh "-p$dbpass -u $mysqluser $xGDB"
      $ScriptDIR/xGDB_markClonePairs.pl -T 'est' -D $xGDB -P $dbpass -U $mysqluser --loadDB 1
      
      dateTime1199=$(date +%Y-%m-%d\ %k:%M:%S)
      msg1199="* Step 11 completed. "
      echo "$space$msg1199$dateTime1199">>$WorkDIR/logs/Pipeline_procedure.log
      
   else
      
      dateTime1199=$(date +%Y-%m-%d\ %k:%M:%S)
      msg1199="* Step 11 skipped. No EST or cDNA data from which to calculate clonepairs. "
      echo "$space$msg1199$dateTime1199">>$WorkDIR/logs/Pipeline_procedure.log
   fi
   
   ###########################################################################
   #  Step 12. Configure GDB and move output files to /xGDBvm/data/GDBnnn    #
   ###########################################################################
   dateTime1200=$(date +%Y-%m-%d\ %k:%M:%S)
   msg1200="| Step 12: Set up GDB config files and move output data (except CpGAT) to destination directory. "
   echo "$dline" >>$WorkDIR/logs/Pipeline_procedure.log
   echo "$msg1200$dateTime1200">>$WorkDIR/logs/Pipeline_procedure.log
   echo "$dline" >>$WorkDIR/logs/Pipeline_procedure.log
   
   dateTime1201=$(date +%Y-%m-%d\ %k:%M:%S)
   msg1201="Create config files and home page. "
   echo "$space$msg1201$dateTime1201">>$WorkDIR/logs/Pipeline_procedure.log
   
   
   # Run script that creates configuration files for this GDB (SITEDEF.pl, SITEDEF.pl, yrGATE_conf.pl, GAEVALconf.pl, GDBnnn_gaeval_conf.pl)
   $ScriptDIR/configure -s "$xGDB" -c "$xGDB" -d "$DBname";
   
   # Make home page for this GDB  DEPRECATED; home page now under /xGDBvm/XGDB/phplib/index.php
#   cp $ScriptDIR/index.php ${WorkDIR}/
   
   dateTime1202=$(date +%Y-%m-%d\ %k:%M:%S)
   msg1202="Moving output files from scratch directory to ${WorkDIR}/data/ "
   echo "$space$msg1202$dateTime1202">>$WorkDIR/logs/Pipeline_procedure.log
   
   # Move everything in (local) working directory to (attached storage) data directory.
   mv $tmpWorkDIR/data ${WorkDIR}/data
   
   
   dateTime1299=$(date +%Y-%m-%d\ %k:%M:%S)
   msg1299="* Step 12 completed. "
   echo "$space$msg1299$dateTime1299">>$WorkDIR/logs/Pipeline_procedure.log
   #End of Step 12
   # End of FirstPart()
}

################################################################################################################################
###########################################   RunCpGAT function (Steps 13 to 15) ###############################################
################################################################################################################################

RunCpGAT(){
   
   ###########################################################################################################################################################
   # Step 13. Run CpGAT scripts using previously-computed GDBxxx spliced-alignments plus ab initio genefinder data                                           #
   ###########################################################################################################################################################
   # NOTE: if ~cpgat.gff3 (precomputed) file was included in Input Dir, these data will already have been parsed and loaded in Step 7. We can skip this step.

   nbproc=`cat /proc/cpuinfo | grep processor | wc -l`

   if [ -z "$CpGATparameter" ] # No CpGAT parameter set or parameter string is empty; user did not request CpGAT
   then
      # 13.01 just create a CpGAT directory and put an empty file in it, jump to Step 15
      mkdir $tmpWorkDIR/data/CpGAT
      chmod 777 $tmpWorkDIR/data/CpGAT
      dateTime1300=$(date +%Y-%m-%d\ %k:%M:%S)
      msg1300="| Step 13: CpGAT not required so skipping to next step (CpGAT GAEVAL). "
      echo "$dline" >>$WorkDIR/logs/Pipeline_procedure.log
      echo "$msg1300$dateTime1300">>$WorkDIR/logs/Pipeline_procedure.log
      echo "$dline" >>$WorkDIR/logs/Pipeline_procedure.log
      # Note we are also logging to a CpGAT_procedure log!!!
      echo "$msg1300$dateTime1300">>$WorkDIR/logs/CpGAT_procedure.log
      
 
   else  # CpGAT parameters exist
      # Initiate CpGAT log file entry - create or update mode
      dateTime1300=$(date +%Y-%m-%d\ %k:%M:%S)
      msg1300="| Step 13: Run CpGAT. CpGAT parameters exist and/or user has requested CpGAT "
      echo "$dline" >>$WorkDIR/logs/Pipeline_procedure.log
      echo "$msg1300$dateTime1300">>$WorkDIR/logs/Pipeline_procedure.log
      echo "$dline" >>$WorkDIR/logs/Pipeline_procedure.log

      if [ "$SPLICEALIGN" == "T" ] # if spliced alignment data (est, cdna, tsa, prot) exist (Create mode) or have been updated (Update mode), or GSEQ is updated (Update mode) or CpGAT only is requested (Update mode)
      then
         echo "CpGAT gene prediction ($mode mode) $dateTime1300 - see also Pipeline_procedure.log. ">>$WorkDIR/logs/CpGAT_procedure.log
         echo "_____________________________________________________________________________">>$WorkDIR/logs/CpGAT_procedure.log
         echo "$msg1300$dateTime1300">>$WorkDIR/logs/CpGAT_procedure.log
         echo "${space}CpGAT parameters are $CpGATparameter ">>$WorkDIR/logs/CpGAT_procedure.log
         echo "${space}SPLICEALIGN parameter is '$SPLICEALIGN' ">>$WorkDIR/logs/CpGAT_procedure.log
         # 13.02 create a (local) working directory and scaffold subdirectory for CpGAT (note: this is created even if CpGAT is not run)
         mkdir $tmpWorkDIR/data/
         mkdir $tmpWorkDIR/data/CpGAT
         chmod 777 $tmpWorkDIR/data/CpGAT
         mkdir $tmpWorkDIR/data/CpGAT/SCFDIR
         
         dateTime1302=$(date +%Y-%m-%d\ %k:%M:%S)
         msg1302="Created CpGAT directory and subdirectory for output by genome segment. "
         echo "$space$msg1302$dateTime1302 (13.02)">>$WorkDIR/logs/Pipeline_procedure.log
         echo "$space$msg1302$dateTime1302 (13.02)">>$WorkDIR/logs/CpGAT_procedure.log
   
         # Since CpGAT can only run on one scaffold at a time, parse out individual scaffolds as FASTA files and place in CpGAT scaffold working directory.
         
         # 13.03 Use scaffold(s) found either in GTH working scaffold directory (placed there under Update subroutine 'addGSEG'), or in data download directory.
         
         dateTime1303=$(date +%Y-%m-%d\ %k:%M:%S)
         msg1303="Genome segments are being parsed out and individually loaded to CpGAT working directory. "
         echo "$space$msg1303$dateTime1303 (13.03)">>$WorkDIR/logs/Pipeline_procedure.log
         
         # Split out genome fasta sequences into individual files
         if [ -s $WorkDIR/data/GTH/SCFDIR/${xGDB}gdna.fa ] # user wants to update - addGSEG has run.??? FIXME does this really work
         then
            $ScriptDIR/FastaSplit.pl $WorkDIR/data/GTH/SCFDIR/${xGDB}gdna.fa $tmpWorkDIR/data/CpGAT/SCFDIR
         else
            $ScriptDIR/FastaSplit.pl $WorkDIR/data/download/${xGDB}gdna.fa $tmpWorkDIR/data/CpGAT/SCFDIR
         fi
         count1304=$(ls $tmpWorkDIR/data/CpGAT/SCFDIR/|wc -l)
         dateTime1304=$(date +%Y-%m-%d\ %k:%M:%S)
         msg1304=" genome segments parsed and copied to CpGAT working directory as individual fasta files. "
         echo "$space$count1304$msg1304$dateTime1304 (13.04)">>$WorkDIR/logs/Pipeline_procedure.log
         
         # 13.05 record CpGAT parameters to logfile and CpGAT parameter file
         msg1305="- CpGAT parameter set is $CpGATparameter. "
         echo "$space$msg1305 (13.05)">>$WorkDIR/logs/Pipeline_procedure.log
         echo "- CpGATparameter set is $CpGATparameter" >$tmpWorkDIR/data/CpGAT/CpGATparameter.txt
         echo "${space}Gene model filter option is $CpGATfilter " >>$WorkDIR/logs/Pipeline_procedure.log
         # 13.06 Verify and count entries in $RefProtDBInput (in its original input location, not as specified in CpGATparameter string)
         dateTime1306=$(date +%Y-%m-%d\ %k:%M:%S)
         RefProtDBInput=$(echo "select CpGAT_ReferenceProt_File from xGDB_Log where ID=\"$Id\""|mysql -p$dbpass -u $mysqluser -N Genomes)
         RefProtDBFile=$(echo $RefProtDBInput |awk -F/ '{print $NF}') # just the filename
         
         if [ ! -s $RefProtDBInput ] # If input path not present
         then
            msg1306=" ERROR: Reference Protein FASTA file could not be found "
            echo "$space$msg1306$dateTime1306 (13.06)">>$WorkDIR/logs/Pipeline_error.log
            echo "$space$msg1306$dateTime1306 (13.06)">>$WorkDIR/logs/CpGAT_procedure.log
            echo "$space$msg1306$dateTime1306 (13.06)">>$WorkDIR/logs/Pipeline_procedure.log
         else  # Make blast directory, copy the file (and any index) to its scratch location and count entries
            mkdir $tmpWorkDIR/data/CpGAT/BLASTDIR
            msg1306="Copying Reference Protein Dataset $RefProtDBFile to scratch directory "
            echo "$space$msg1306$dateTime1306 (13.06)">>$WorkDIR/logs/Pipeline_procedure.log
            cp $RefProtDBInput  $tmpWorkDIR/data/CpGAT/BLASTDIR       
            cp $RefProtDBInput.*  $tmpWorkDIR/data/CpGAT/BLASTDIR
            dateTime1307=$(date +%Y-%m-%d\ %k:%M:%S)
            count1307=$(grep -c "^>" $tmpWorkDIR/data/CpGAT/BLASTDIR/$RefProtDBFile)
            msg1307="$count1307 entries in $RefProtDBFile are being used as a reference protein dataset. "
            refprot_count=$count1307 # we will use this later when we load this dataset to MySQL
         fi
         echo "$space$msg1307$dateTime1307 (13.07)">>$WorkDIR/logs/CpGAT_procedure.log
         echo "$space$msg1307$dateTime1307 (13.07)">>$WorkDIR/logs/Pipeline_procedure.log
         
         # 13.071 If no index files are present, go ahead and index RefProt for BLAST NOT YET TESTED 1-15-13
         
         if [ ! -s ${tmpWorkDIR}/data/CpGAT/BLASTDIR/${RefProtDBFile}.pin ]
         then
            dateTime13071=$(date +%Y-%m-%d\ %k:%M:%S)
            msg13071="$space- Reference Protein dataset ${RefProtDBFile} is being indexed for Blast on scratch disk (13.071)"
            echo "$space$msg13071$dateTime13071 (13.071)" >>$WorkDIR/logs/Pipeline_procedure.log
            
            /usr/local/bin/makeblastdb -in ${tmpWorkDIR}/data/CpGAT/BLASTDIR/${RefProtDBFile} -dbtype prot -parse_seqids -out ${tmpWorkDIR}/data/CpGAT/BLASTDIR/${RefProtDBFile}
            dateTime13072=$(date +%Y-%m-%d\ %k:%M:%S)
            if [ -s ${tmpWorkDIR}/data/CpGAT/BLASTDIR/${RefProtDBFile}.pin ]
            then
               msg13072="Reference Protein dataset ${RefProtDBFile} is now indexed for Blast. Now proceeding with CpGAT "
            else
               msg13072="ERROR: Reference Protein dataset ${RefProtDBFile} could not be indexed for Blast  "
               echo "$space$msg13072$dateTime13072 (13.072)" >>$WorkDIR/logs/Pipeline_error.log  # Log ERROR
            fi
         else
            msg13072="Reference Protein dataset ${RefProtDBFile} index has been found. Proceeding with CpGAT  "
         fi
         
         echo "$space$msg13072$dateTime13072 (13.072)" >>$WorkDIR/logs/Pipeline_procedure.log  # Log Message
         
         # 13.075 It's loop time!
         
         dateTime13075=$(date +%Y-%m-%d\ %k:%M:%S)
         msg13075="Running CpGAT on each genome segment using its spliced alignment data. " # IMPORTANT!! DON'T CHANGE THE TEXT "Running CpGAT on" UNLESS YOU UPDATE 'sed' TEXT below!!!! this line will be replaced below in loop
         echo "$space$msg13075$dateTime13075 (13.075)">>$WorkDIR/logs/Pipeline_procedure.log
         
         echo "$space-See CpGAT_procedure.log for detailed information on each segment annotated." >>$WorkDIR/logs/Pipeline_procedure.log
         
         gdna_total=$(ls $tmpWorkDIR/data/CpGAT/SCFDIR/|wc -l) # total scaffolds
         scaffold_count=0
         
         for file in $tmpWorkDIR/data/CpGAT/SCFDIR/*
         do
            if [ -s $file ]
            then
               gseg_gi_tmp=$(echo $file |awk -F/ '{print $NF}')           # e.g. AmTr_v1.0_scaffold00001.fsa which is the scaffold fasta file name
               gseg_gi=$(echo $gseg_gi_tmp |awk -F.fsa '{print $(NF-1)}') # e.g. chop the .fsa extension leaving AmTr_v1.0_scaffold00001 which is the scaffold ID
               
               # 13.08 Grab transcripts already aligned to each scaffold and create a tabular list of alignment data for each, based on "good_pgs" table data.
               echo "select * from gseg_est_good_pgs where gseg_gi=\"$gseg_gi\"" | mysql -p$dbpass -u $mysqluser $xGDB -N >$tmpWorkDIR/data/CpGAT/${gseg_gi}.mRNAgth.tab
               echo "select * from gseg_cdna_good_pgs where gseg_gi=\"$gseg_gi\"" | mysql -p$dbpass -u $mysqluser $xGDB -N >>$tmpWorkDIR/data/CpGAT/${gseg_gi}.mRNAgth.tab
               echo "select * from gseg_put_good_pgs where gseg_gi=\"$gseg_gi\"" | mysql -p$dbpass -u $mysqluser $xGDB -N >>$tmpWorkDIR/data/CpGAT/${gseg_gi}.mRNAgth.tab
               echo "select * from gseg_pep_good_pgs where gseg_gi=\"$gseg_gi\"" | mysql -p$dbpass -u $mysqluser $xGDB -N >$tmpWorkDIR/data/CpGAT/${gseg_gi}.protgth.tab
               
               dateTime1308=$(date +%Y-%m-%d\ %k:%M:%S)
               count1308=$(echo "SELECT concat(\"  \", count(*)) as \"- $gseg_gi gene predictions :\"  FROM (SELECT uid from gseg_est_good_pgs where gseg_gi=\"$gseg_gi\"  UNION ALL SELECT uid FROM gseg_cdna_good_pgs where gseg_gi=\"$gseg_gi\" UNION ALL SELECT uid FROM gseg_put_good_pgs where gseg_gi=\"$gseg_gi\" UNION ALL SELECT uid FROM gseg_pep_good_pgs where gseg_gi=\"$gseg_gi\") as total "|mysql -p$dbpass -u $mysqluser $xGDB)
               count1308est=$(echo "SELECT count(*) from gseg_est_good_pgs where gseg_gi=\"$gseg_gi\""|mysql -p$dbpass -u $mysqluser $xGDB -N)
               count1308cdna=$(echo "SELECT count(*) from gseg_cdna_good_pgs where gseg_gi=\"$gseg_gi\""|mysql -p$dbpass -u $mysqluser $xGDB -N)
               count1308tsa=$(echo "SELECT count(*) from gseg_put_good_pgs where gseg_gi=\"$gseg_gi\""|mysql -p$dbpass -u $mysqluser $xGDB -N)
               count1308prot=$(echo "SELECT count(*) from gseg_pep_good_pgs where gseg_gi=\"$gseg_gi\""|mysql -p$dbpass -u $mysqluser $xGDB -N)
               msg1308=" spliced alignment records ($count1308est EST, $count1308cdna cDNA, $count1308tsa TSA, $count1308prot Protein) were loaded for "
               echo "$count1308$msg1308$gseg_gi$space$dateTime1308 (13.08)" >>$WorkDIR/logs/CpGAT_procedure.log
               
               # Run CpGAT on this GSEG. This is a version of CpGAT that uses prior GeneSeqer and GenomeThreader data as input. #
               
               scaffold_count=`expr $scaffold_count + 1`
               
               dateTime1309=$(date +%Y-%m-%d\ %k:%M:%S)
               msg1309="Running CpGAT on $gseg_gi  (segment $scaffold_count out of $gdna_total total).  "
               echo "$space$msg1309$dateTime1309 (13.09)" >>$WorkDIR/logs/CpGAT_procedure.log
               
               # swap out previous segment log entry for new one each loop cycle (starting with 1307 on cycle 1)
               
               sed -i -e "s/^.*Running CpGAT on.*$/$space$msg1309$dateTime1309/" $WorkDIR/logs/Pipeline_procedure.log
               
               # Now run the CpGAT-xGDB script ($nbproc simultaneous runs in the background):

               cntmnbp=`expr $scaffold_count % $nbproc`
               (mkdir $tmpWorkDIR/data/CpGAT/TMP$cntmnbp; \
                cut -f2 $tmpWorkDIR/data/CpGAT/${gseg_gi}.mRNAgth.tab >$tmpWorkDIR/data/CpGAT/TMP$cntmnbp/${gseg_gi}_v_mRNAs.list; \
                cut -f2 $tmpWorkDIR/data/CpGAT/${gseg_gi}.protgth.tab >$tmpWorkDIR/data/CpGAT/TMP$cntmnbp/${gseg_gi}_v_Peps.list; \
                /xGDBvm/src/CpGAT/fct/cpgat.xgdb.pl -o $tmpWorkDIR/data/CpGAT/TMP$cntmnbp -i $file -trans $tmpWorkDIR/data/CpGAT/${gseg_gi}.mRNAgth.tab -prot $tmpWorkDIR/data/CpGAT/${gseg_gi}.protgth.tab $CpGATparameter -config_file /xGDBvm/src/CpGAT/CpGAT.conf >& $tmpWorkDIR/data/CpGAT/${gseg_gi}.err; \
                echo "... done with background cpgat job at $(date +%Y-%m-%d\ %k:%M:%S)"; \
               ) &
               if (( $scaffold_count % $nbproc == 0  ||  $scaffold_count == $gdna_total ))
               then
                  wait
                  \mv $tmpWorkDIR/data/CpGAT/TMP*/* $tmpWorkDIR/data/CpGAT/
                  \rm -rf $tmpWorkDIR/data/CpGAT/TMP*
               fi
            fi
         done
# For the record ...
         for file in $tmpWorkDIR/data/CpGAT/SCFDIR/*
         do
            if [ -s $file ]
            then
               gseg_gi_tmp=$(echo $file |awk -F/ '{print $NF}')
               gseg_gi=$(echo $gseg_gi_tmp |awk -F.fsa '{print $(NF-1)}')
               count1310=$(grep -c -P "\tmRNA\t" $tmpWorkDIR/data/CpGAT/${gseg_gi}.${CpGATfilter}.gff3)
               msg1310=" gene predictions (${CpGATfilter}) were computed for $gseg_gi. "
               echo "$space$count1310$msg1310 (13.10)" >> $WorkDIR/logs/CpGAT_procedure.log
            fi
         done
               
         dateTime1311=$(date +%Y-%m-%d\ %k:%M:%S)
         msg1311="** CpGAT completed for $scaffold_count out of $gdna_total segments ** "
         echo "$space$msg1311 at $dateTime1311 (13.11)" >> $WorkDIR/logs/CpGAT_procedure.log
         
         # 13.12 Create concatenated output gff3 file, place in working directory. Make a copy of the gff3 file in the data download directory (as cpgat.gff3).
         cat $tmpWorkDIR/data/CpGAT/*.${CpGATfilter}.gff3 >$tmpWorkDIR/data/CpGAT/${xGDB}all.${CpGATfilter}.gff3
         cp $tmpWorkDIR/data/CpGAT/${xGDB}all.${CpGATfilter}.gff3 $WorkDIR/data/download/${xGDB}cpgat.gff3
         
         dateTime1312=$(date +%Y-%m-%d\ %k:%M:%S)
         count1312=$(grep -c -P "\tmRNA\t" $WorkDIR/data/download/${xGDB}cpgat.gff3)
         msg1312=" CpGAT gene predictions from ${xGDB}all.${CpGATfilter}.gff3 copied to $WorkDIR/data/download/${xGDB}cpgat.gff3. "
         echo "$space$count1312$msg1312$dateTime1312 (13.12)" >>$WorkDIR/logs/Pipeline_procedure.log
         
         # 13.13 Create concatenated ~filtered.pep or ~unfiltered.pep file from all scaffolds, place in working BLAST directory (as cpgat.pep.fa). Index for BLAST and make a copy of the file in the data download directory.
         cat $tmpWorkDIR/data/CpGAT/*.${CpGATfilter}.pep >$WorkDIR/data/BLAST/${xGDB}cpgat.pep.fa
         /usr/local/bin/makeblastdb -in $WorkDIR/data/BLAST/${xGDB}cpgat.pep.fa -dbtype prot -parse_seqids -out $WorkDIR/data/BLAST/${xGDB}cpgat.pep.fa
         cp $WorkDIR/data/BLAST/${xGDB}cpgat.pep.fa $WorkDIR/data/download/${xGDB}cpgat.pep.fa # New 1/13/13
         
         dateTime1313=$(date +%Y-%m-%d\ %k:%M:%S)
         count1313=$(grep -c "^>" ${WorkDIR}/data/download/${xGDB}cpgat.pep.fa)
         msg1313=" CpGAT peptides (fasta) copied to download as ${xGDB}cpgat.pep.fa and BLAST directory (indexed as ${xGDB}cpgat.pep.fa) "
         echo "$space$count1313$msg1313$dateTime1313 (13.13)" >>$WorkDIR/logs/Pipeline_procedure.log
         
         # 13.135 Create concatenated ~filtered.trans or ~unfiltered.trans file from all scaffolds, place in working BLAST directory (as cpgat.mrna.fa). Index for BLAST and make a copy of the file in the data download directory.
         cat $tmpWorkDIR/data/CpGAT/*.${CpGATfilter}.trans >$WorkDIR/data/BLAST/${xGDB}cpgat.mrna.fa
         /usr/local/bin/makeblastdb -in $WorkDIR/data/BLAST/${xGDB}cpgat.mrna.fa -dbtype nucl -parse_seqids -out $WorkDIR/data/BLAST/${xGDB}cpgat.mrna.fa
         cp $WorkDIR/data/BLAST/${xGDB}cpgat.mrna.fa $WorkDIR/data/download/${xGDB}cpgat.mrna.fa #
         
         dateTime13135=$(date +%Y-%m-%d\ %k:%M:%S)
         count13135=$(grep -c "^>" ${WorkDIR}/data/download/${xGDB}cpgat.mrna.fa)
         msg13135=" total CpGAT predicted transcript sequences (fasta) copied to download directory (as ${xGDB}cpgat.mrna.fa) and BLAST directory (indexed as cpgat.mrna.fa) "
         echo "$space$count13135$msg13135$dateTime13135 (13.135)" >>$WorkDIR/logs/Pipeline_procedure.log

         # 13.138 Copy Reference Protein fasta to BLAST directory (with standardized name) and re-index
         dateTime13138=$(date +%Y-%m-%d\ %k:%M:%S)
         cp $tmpWorkDIR/data/CpGAT/BLASTDIR/${RefProtDBFile} $WorkDIR/data/BLAST/${xGDB}cpgat.refprot.fa
         /usr/local/bin/makeblastdb -in $WorkDIR/data/BLAST/${xGDB}cpgat.refprot.fa -dbtype prot -parse_seqids -out $WorkDIR/data/BLAST/${xGDB}cpgat.refprot.fa
         msg13138=" Reference Protein file copied to BLAST directory (as ${xGDB}cpgat.refprot.fa) and indexed for blast"
         echo "$space$msg13138$dateTime13138 (13.138)" >>$WorkDIR/logs/Pipeline_procedure.log

            
         ###  Jump to here if precomputed CpGAT data exists, or arrive here naturally from step 13.13
   
         # 13.14 CpGAT is completed or precomputed data exists. Now parse the output gff3 and create a MySQL Load script.
         dateTime1314=$(date +%Y-%m-%d\ %k:%M:%S)
         msg1314="Parsing CpGAT gff3 table for MySQL. "
         echo "$space$msg1314$dateTime1314 (13.14)" >>$WorkDIR/logs/Pipeline_procedure.log
         
         $ScriptDIR/GFF_to_XGDB_Standard.pl -t gseg_cpgat_gene_annotation $tmpWorkDIR/data/CpGAT/${xGDB}all.${CpGATfilter}.gff3 >${WorkDIR}/data/XGDB_MYSQL/${xGDB}cpgat_gene_annotation.sql
         
         file1315=$(ls -m ${WorkDIR}/data/XGDB_MYSQL/${xGDB}cpgat_gene_annotation.sql)
         
         
         # 13.15 Load CpGAT gene predictions to MySQL (gseg_cpgat_gene_annotation).
         count1315=$(grep -c "INSERT" ${WorkDIR}/data/XGDB_MYSQL/${xGDB}cpgat_gene_annotation.sql) # This step counts ""
         
         dateTime1315=$(date +%Y-%m-%d\ %k:%M:%S)
         msg1315="Loading total of $count1315 CpGAT gene predictions from file $file1315 to MySQL. "
         echo "$space$msg1315$dateTime1315 (13.15)" >>$WorkDIR/logs/Pipeline_procedure.log
         
         mysql -p$dbpass -u $mysqluser $xGDB < ${WorkDIR}/data/XGDB_MYSQL/${xGDB}cpgat_gene_annotation.sql
         
         # 13.16 Finished loading to gseg_cpgat_gene_annotation.
         count1316=$(echo "select concat(\"  \", count(*)) as \"- CpGAT gene model upload:\" from gseg_cpgat_gene_annotation"|mysql -p$dbpass -u $mysqluser $xGDB)
         dateTime1316=$(date +%Y-%m-%d\ %k:%M:%S)
         msg1316=" total CpGAT gene predictions are now in gseg_cpgat_gene_annotation. "
         echo "$space$count1316$msg1316$dateTime1316 (13.16)" >>$WorkDIR/logs/Pipeline_procedure.log

         # 13.20 parse Reference Protein dataset (from BLAST dir) to MySQL (1/21/14)
         
         if [ -s $WorkDIR/data/BLAST/${xGDB}cpgat.refprot.fa ] # only do this if there is a reference protein dataset
         then
            dateTime1320=$(date +%Y-%m-%d\ %k:%M:%S)
            msg1320=" Reference Protein sequences are being loaded to MySQL '${xGDB}.refprot' (reference protein) table "
            echo "$space$count1320$msg1320" >>$WorkDIR/logs/Pipeline_procedure.log
            
            $ScriptDIR/xGDBload_SeqFromFasta.pl refprot $WorkDIR/data/BLAST/${xGDB}cpgat.refprot.fa >$WorkDIR/data/XGDB_MYSQL/${xGDB}cpgat.refprot.sql
            mysql -p$dbpass -u $mysqluser $xGDB < $WorkDIR/data/XGDB_MYSQL/${xGDB}cpgat.refprot.sql
   
            count1325=$(echo "select count(*) from refprot"|mysql -p$dbpass -u $mysqluser $xGDB -N)
            dateTime1325=$(date +%Y-%m-%d\ %k:%M:%S)
            msg1325=" Reference Protein sequences were loaded to MySQL '${xGDB}.refprot' (reference protein) table "
            echo "${space}${count1325}${msg1325}${dateTime1325}" >>$WorkDIR/logs/Pipeline_procedure.log
            if [[ "$count1325" -eq "$refprot_count" ]] # initial fasta count at the top of the CpGAT loop
            then
               msg1328=" Reference Protein IDs appear to have been parsed correctly. Now appending best hit descriptions to 'gseg_cpgat_gene_annotation' table"
               echo "${space}${msg1328} (13.28)" >>$WorkDIR/logs/Pipeline_procedure.log
            else
               error1328="WARNING: $count1325 protein sequences were loaded to ${xGDB}.refprot table but input file had $refprot_count records (13.28) "
               echo "$error1328">>$WorkDIR/logs/Pipeline_procedure.log; echo "$error1328">>$WorkDIR/logs/Pipeline_error.log
            fi
         
         # 13.30 update gseg_cpgat_gene_annotation descriptions with UniProt best hit descriptions where ID match (1/21/14)
         
            echo "update gseg_cpgat_gene_annotation as a set a.description =concat(a.description, \"; best_hit_description=\", (select b.description from refprot as b where a.description like concat(\"%\", b.gi,\"%\")))"|mysql -p$dbpass -u $mysqluser $xGDB
            dateTime1330=$(date +%Y-%m-%d\ %k:%M:%S)
            msg1330="Best_hit_description has been appended to 'gseg_cpgat_gene_annotation' table. "
            echo "${space}${msg1330}${dateTime1330} (13.30)" >>$WorkDIR/logs/Pipeline_procedure.log
         fi # end if reference protein dataset
                  
      else
         
         dateTime1390=$(date +%Y-%m-%d\ %k:%M:%S)
         msg1390="| Step 13: CpGAT. No transcript or protein spliced aligments loaded or updated. Skipping CpGAT. "
         echo "$dline" >>$WorkDIR/logs/Pipeline_procedure.log
         echo "$msg1390$dateTime1390">>$WorkDIR/logs/Pipeline_procedure.log
         echo "$dline" >>$WorkDIR/logs/Pipeline_procedure.log
         echo "$space$msg1390$dateTime1390" >>$WorkDIR/logs/Pipeline_procedure.log
         
      fi # end if $TRANSCRIPT
   fi # end if $CpGATparameter
   
    # end CpGAT data processing loop
     
     dateTime1399=$(date +%Y-%m-%d\ %k:%M:%S)
     msg1399="* Step 13 (CpGAT) completed. "
     echo "$space$msg1399$dateTime1399" >>$WorkDIR/logs/Pipeline_procedure.log

   #jump here if CpGATparameter= ''
   
   ################################################################
   # Step 14. Move CpGAT data (if any) to output directory        #
   ################################################################
   
   dateTime1400=$(date +%Y-%m-%d\ %k:%M:%S)
   
   if [[ -z $CpGATparameter ]] # no CpGAT parameters, i.e. not requested
   then
      msg1400="| Step 14:  No CpGAT output data. Moving (empty) CpGAT directory to output directory; removing scratch directory.  "
      echo "$dline" >>$WorkDIR/logs/Pipeline_procedure.log
      echo "$msg1400$dateTime1400" >>$WorkDIR/logs/Pipeline_procedure.log
      echo "$dline" >>$WorkDIR/logs/Pipeline_procedure.log
      
   else
      
      # 14.01 move CpGAT data back to output GDB directory (whether empty or full) and remove the scratch GDB directory.
      
      dateTime1401=$(date +%Y-%m-%d\ %k:%M:%S)
      msg1401="| Step 14: Moving CpGAT output data to output directory; removing scratch directory. "
      echo "$dline" >>$WorkDIR/logs/Pipeline_procedure.log
      echo "$msg1401$dateTime1401 (14.01)" >>$WorkDIR/logs/Pipeline_procedure.log
      echo "$dline" >>$WorkDIR/logs/Pipeline_procedure.log
      
   fi
   #jump here if no CpGAT parameters (CpGAT skipped)

   mv $tmpWorkDIR/data/CpGAT ${WorkDIR}/data/CpGAT
   
   # 14.02  All CpGAT data (if any) moved. Now remove the scratch directory under /xGDBvm/data/scratch/.
   
   rm -rf $tmpWorkDIR
   
   dateTime1402=$(date +%Y-%m-%d\ %k:%M:%S)
   msg1402=" Moved CpGAT data to output directory and removed $tmpWorkDIR."
   echo "$space$msg1402$dateTime1402 (14.02)" >>$WorkDIR/logs/Pipeline_procedure.log
   
   # 14.99 CpGAT complete
   dateTime1499=$(date +%Y-%m-%d\ %k:%M:%S)
   msg1499="* Step 14 completed. "
   echo "$space$msg1499$dateTime1499" >>$WorkDIR/logs/Pipeline_procedure.log
   
   
   ############################################################################################################
   # Step 15. Run GAEVAL analysis of CpGAT gene models, updat gseg_cpgat_locus_annotation#
   ############################################################################################################
   # NOTE This step applies in Create or Update mode, but is bypassed unless correct data elements are present
   # In Create Mode, CpGAT-GAEVAL is run if 1) CpGAT models have been created or uploaded AND transcript data exist.
   # In Update Mode, CpGAT-GAEVAL is run if 1) CpGAT models exist and transcript data has been updated; or 2) CpGAT models have been updated and transcript data exist

      msg1500="| Step 15: CpGAT models: GAEVAL gene evaluation and locus table. "
      echo "$dline" >>$WorkDIR/logs/Pipeline_procedure.log
      echo "$msg1500$dateTime1500" >>$WorkDIR/logs/Pipeline_procedure.log
      echo "$dline" >>$WorkDIR/logs/Pipeline_procedure.log
    
   ########### Determine actions based on MySQL data status (the only thing that matters!) ############
   
   ### A. Create Mode
   #### 1) TRANSCRIPT?
   for transcript in est cdna put
   do
     count=$(echo "select count(*) from gseg_${transcript}_good_pgs"|mysql -p$dbpass -u $mysqluser -N $xGDB)
     if [ "$count" -gt "0" ]  # Any transcript spliced alignments?
     then 
        TRANSCRIPT='T'  # any transcript can trigger 'T'
     fi
   done

   #### 2) CpGENEMODEL (CpGAT)?
   count=$(echo "select count(*) from gseg_cpgat_gene_annotation"|mysql -p$dbpass -u $mysqluser -N $xGDB)
   if [ "$count" -gt "0" ]
   then 
      CpGENEMODEL='T'
   fi 
   
   #### 3) Determine if GAEVAL should be run ('Run' if both TRANSCRIPT and CpGENEMODEL ='T')
   if [ "$mode" == "Create" ]
   then
      if [[ "$TRANSCRIPT" == "T" && "$CpGENEMODEL" == "T" ]]
      then
         CpGAEVALaction="Run";
      fi
    fi

   ### B) Update  mode:
   #### 1) If Update mode: determine if GAEVAL should be run ('$U_GAEVAL_CpGAT'is set by Update OPTargs)
   if [[ "$mode" == "Update" && "$U_GAEVAL_CpGAT" == "T" ]]
   then
      CpGAEVALaction="Run";
   fi

   echo "${space} CpGENEMODEL = $CpGENEMODEL; CpGAEVALaction = $CpGAEVALaction (15.00)" >>$WorkDIR/logs/Pipeline_procedure.log

   dateTime15005=$(date +%Y-%m-%d\ %k:%M:%S)

   if [ "$CpGAEVALaction" == "Run" ] # Run CpGAT-GAEVAL.
   then
      msg15005="Running GAEVAL gene evaluation and locus table for CpGAT gene models (if any). "
      echo "$space$msg15005$dateTime15005 (15.005)" >>$WorkDIR/logs/Pipeline_procedure.log
      
      # 15.01 Run GAEVAL analysis for CpGAT models and load MySQL tables
      
      cp $ScriptDIR/GAEVALconf.php ${WorkDIR}/conf/
      cd /xGDBvm/src/GAEVAL
      ./xGAEVAL.pl --noreport --configuration="${WorkDIR}/conf/${xGDB}_cpgat_gaeval_conf.pl"
      
      count1501a=$(echo "select concat(\"  \", count(*)) as \"- cpgat model GAEVAL Upload: \" from gseg_cpgat_gbk_gaeval"|mysql -p$dbpass -u $mysqluser $xGDB)
      count1501b=$(echo "select concat(\"  \", count(*)) as \"- est GAEVAL Upload: \" from gseg_cpgat_est_gaeval"|mysql -p$dbpass -u $mysqluser $xGDB)
      count1501c=$(echo "select concat(\"  \", count(*)) as \"- cdna GAEVAL Upload: \" from gseg_cpgat_cdna_gaeval"|mysql -p$dbpass -u $mysqluser $xGDB)
      count1501d=$(echo "select concat(\"  \", count(*)) as \"- tsa GAEVAL Upload: \" from gseg_cpgat_put_gaeval"|mysql -p$dbpass -u $mysqluser $xGDB)
      count1501e=$(echo "select concat(\"  \", count(*)) as \"- GAEVAL properties Upload: \" from gseg_cpgat_gbk_gaeval_properties"|mysql -p$dbpass -u $mysqluser $xGDB)
      
      msg1501a=" GAEVAL records were loaded to '$xGDB.gseg_cpgat_gaeval' table"
      echo "$count1501a$msg1501a (15.01a)" >>$WorkDIR/logs/Pipeline_procedure.log
      msg1501b=" GAEVAL records were loaded to '$xGDB.gseg_cpgat_est_gaeval' table"
      echo "$count1501b$msg1501b (15.01b)" >>$WorkDIR/logs/Pipeline_procedure.log
      msg1501c=" GAEVAL records were loaded to '$xGDB.gseg_cpgat_cdna_gaeval' table"
      echo "$count1501c$msg1501c (15.01c)" >>$WorkDIR/logs/Pipeline_procedure.log
      msg1501d=" GAEVAL records were loaded to '$xGDB.gseg_cpgat_put_gaeval' table"
      echo "$count1501c$msg1501d (15.01d)" >>$WorkDIR/logs/Pipeline_procedure.log
      msg1501e=" GAEVAL records were loaded to '$xGDB.gseg_cpgat_gbk_gaeval_properties' table"
      echo "$count1501e$msg1501e (15.01e)" >>$WorkDIR/logs/Pipeline_procedure.log
      
      # 15.02   Calculate GAEVAL flags
      
      ./xGDB_updateGAEVAL_flags.pl --configuration="${WorkDIR}/conf/${xGDB}_cpgat_gaeval_conf.pl" --outDIR="${WorkDIR}/data/XGDB_MYSQL/" --outFILE="CpGAT${xGDB}gaevalFlagSQL" 
      mysql -p$dbpass -u $mysqluser $xGDB<${WorkDIR}/data/XGDB_MYSQL/CpGAT${xGDB}gaevalFlagSQL
      
      dateTime1502=$(date +%Y-%m-%d\ %k:%M:%S)
      count1502=$(echo "select concat(\"  \", count(*)) as \"- GAEVAL Flags Upload: \" from gseg_cpgat_gbk_gaeval_flags"|mysql -p$dbpass -u $mysqluser $xGDB)
      msg1502=" GAEVAL flags uploaded to gseg_cpgat_gbk_gaeval_flags"
      echo "$count1502$msg1502$dateTime1502(15.02)" >>$WorkDIR/logs/Pipeline_procedure.log

      # 15.03 Load segment to CpGAT locus table
      dateTime1503=$(date +%Y-%m-%d\ %k:%M:%S)
      msg1503="Calculating CpGAT locus data (if any) and loading to MySQL. "
      echo "$space$msg1503$dateTime1503 (15.03)" >>$WorkDIR/logs/Pipeline_procedure.log
      
     # moved the locus insert query

    else
      msg15005="Skipping GAEVAL evaluation and locus table for CpGAT models. "
      echo "$space$msg15005$dateTime15005" >>$WorkDIR/logs/Pipeline_procedure.log
   fi

   #skip to here if no CpGAT-GAEVAL

 # 15.09 Load segment to CpGAT locus table
  cp $ScriptDIR/cpgat_lociFrame.sql ${WorkDIR}/data/XGDB_MYSQL/${xGDB}cpgat_lociFrame.sql
  mysql -p$dbpass -u $mysqluser $xGDB< ${WorkDIR}/data/XGDB_MYSQL/${xGDB}cpgat_lociFrame.sql
  echo "insert into gseg_cpgat_locus_annotation(gseg_gi,locus_id,strand,l_pos,r_pos,description, transcript_ids, transcript_count,coverage,integrity,intron_count) select gseg_gi,locus_id,strand,min(l_pos),max(r_pos), group_concat(description order by geneId asc), group_concat(geneId order by geneId asc), count(geneId),round(avg(exon_coverage),2),round(avg(b.integrity),2),max(introns_confirmed+introns_unsupported) from gseg_cpgat_gene_annotation as a left join gseg_cpgat_gbk_gaeval as b on a.uid=b.uid group by locus_id" |mysql -p$dbpass -u $mysqluser $xGDB

  count1509=$(echo "select concat(\"  \", count(*)) as \"- Locus Upload: \" from gseg_cpgat_locus_annotation"|mysql -p$dbpass -u $mysqluser $xGDB)
  msg1509=" loci were loaded to '$xGDB.gseg_cpgat_locus_annotation' table "
  echo "$count1509$msg1509(15.09)" >>$WorkDIR/logs/Pipeline_procedure.log


   dateTime1599=$(date +%Y-%m-%d\ %k:%M:%S)
   msg1599="* Step 15 completed. Next step is GAEVAL"
   echo "$space$msg1599$dateTime1599" >>$WorkDIR/logs/Pipeline_procedure.log
}



# end runCpGAT() function

##########################################################################################################################
################ LastPart function (Step 16, 17) - GAEVAL vs precomputed models, update global database tables  ##############
##########################################################################################################################

LastPart(){
   
   ########################################################################################################
   # Step 16. Run GAEVAL analysis vs. precomp. models, update gseg_locus_annotation table   #
   ########################################################################################################
   # NOTE This step applies in Create or Update mode, but GAEVAL portion is bypassed unless correct data elements are present

   dateTime1600=$(date +%Y-%m-%d\ %k:%M:%S)
   msg1600="| Step 16: Run GAEVAL analysis for pre-computed gene models; update xGDB_Log "
   echo "$dline" >>$WorkDIR/logs/Pipeline_procedure.log
   echo "$msg1600$dateTime1600" >>$WorkDIR/logs/Pipeline_procedure.log
   echo "$dline" >>$WorkDIR/logs/Pipeline_procedure.log
   
   ########### Determine GAEVAL actions based on MySQL data status and/or what's been updated (the only thing that matters!) ############
   ### A) Create mode:
   #### 1) TRANSCRIPT present?
   if [ "$mode" == "Create" ]
   then
      for transcript in est cdna put # Any transcript spliced alignments?
      do
        count=$(echo "select count(*) from gseg_${transcript}_good_pgs"|mysql -p$dbpass -u $mysqluser -N $xGDB)
   # debug     echo "$transcript count=${count} (16.00)" >>$WorkDIR/logs/Pipeline_procedure.log
        if [ "$count" -gt "0" ]
        then 
           TRANSCRIPT='T'  # default is 'F'; any one transcript can trigger 'T'
     # debug     echo "${space}There are $count ${transcript} spliced alignments in gseg_${transcript}_good_pgs (16.00)" >>$WorkDIR/logs/Pipeline_procedure.log
        fi
      done

      #### 2) GENEMODEL (Pre-computed) present?
      count=$(echo "select count(*) from gseg_gene_annotation"|mysql -p$dbpass -u $mysqluser -N $xGDB)
      if [ "$count" -gt "0" ]
      then 
         GENEMODEL='T'
      fi
      #### 3) Determine if GAEVAL should be run ('Run' if both TRANSCRIPT and GENEMODEL ='T')
      if [ "$mode" == "Create" ]
      then
         if [[ "$TRANSCRIPT" == "T" && "$GENEMODEL" == "T" ]]
         then
            GAEVALaction="Run";
         fi
       fi
      echo "${space} GAEVALaction =$GAEVALaction (16.00)" >>$WorkDIR/logs/Pipeline_procedure.log
   fi

   ### B) Update  mode:
   #### 1) If Update mode: determine if GAEVAL should be run ('$U_GAEVAL' has already been set by Update OPTargs)
   if [[ "$mode" == "Update" && "$U_GAEVAL" == "T" ]]
   then
      GAEVALaction="Run";
   fi
   ### Now, GAEVAL:
   if [ "$GAEVALaction" == "Run" ] ## We've passed all the tests
   then
      cdna_count=$(echo "select count(*) from gseg_cdna_good_pgs"|mysql -p$dbpass -u $mysqluser $xGDB -N)
      est_count=$(echo "select count(*) from gseg_est_good_pgs"|mysql -p$dbpass -u $mysqluser $xGDB -N)
      tsa_count=$(echo "select count(*) from gseg_put_good_pgs"|mysql -p$dbpass -u $mysqluser $xGDB -N)
      anno_count=$(echo "select count(*) from gseg_gene_annotation"|mysql -p$dbpass -u $mysqluser $xGDB -N)
      cpgat_count=$(echo "select count(*) from gseg_cpgat_gene_annotation"|mysql -p$dbpass -u $mysqluser $xGDB -N)
      dateTime1600=$(date +%Y-%m-%d\ %k:%M:%S)
      echo "${space}Running GAEVAL analysis of the precomputed gene model dataset just updated $dateTime1600 (16.00)." >>$WorkDIR/logs/Pipeline_procedure.log
      echo "${space}${anno_count} precomputed gene models are being evaluated against ${cdna_count} cDNA, ${est_count} EST and ${tsa_count} TSA spliced alignments." >>$WorkDIR/logs/Pipeline_procedure.log
      if [ "$anno_count" -ge "1" ]
      then
         if [[ "$cdna_count" -ge "1"  || "$est_count" -ge "1" || "$tsa_count" -ge "1" ]]  ## There are gene models and transcript alignment data that can be used for GAEVAL. Otherwise skip this time-consuming step if unnecessary
         then

         # 16.01 GAEVAL analysis for precomputed gene models.
         
            cp $ScriptDIR/GAEVALconf.php ${WorkDIR}/conf/
            cd /xGDBvm/src/GAEVAL
            ./xGAEVAL.pl --noreport --configuration="${WorkDIR}/conf/${xGDB}_gaeval_conf.pl"

            count1601a=$(echo "select concat(\"  \", count(*)) as \"- gene model GAEVAL Upload: \" from gseg_gbk_gaeval"|mysql -p$dbpass -u $mysqluser $xGDB)
            count1601b=$(echo "select concat(\"  \", count(*)) as \"- est GAEVAL Upload: \" from gseg_est_gaeval"|mysql -p$dbpass -u $mysqluser $xGDB)
            count1601c=$(echo "select concat(\"  \", count(*)) as \"- cdna GAEVAL Upload: \" from gseg_cdna_gaeval"|mysql -p$dbpass -u $mysqluser $xGDB)
            count1601d=$(echo "select concat(\"  \", count(*)) as \"- tsa GAEVAL Upload: \" from gseg_put_gaeval"|mysql -p$dbpass -u $mysqluser $xGDB)
            count1601e=$(echo "select concat(\"  \", count(*)) as \"- GAEVAL properties Upload: \" from gseg_gbk_gaeval_properties"|mysql -p$dbpass -u $mysqluser $xGDB)
         
            msg1601a=" GAEVAL records were loaded to '$xGDB.gseg_gbk_gaeval' table"
            echo "$count1601a$msg1601a (16.01a)" >>$WorkDIR/logs/Pipeline_procedure.log
            msg1601b=" GAEVAL records were loaded to '$xGDB.gseg_est_gaeval' table"
            echo "$count1601b$msg1601b (16.01b)" >>$WorkDIR/logs/Pipeline_procedure.log
            msg1601c=" GAEVAL records were loaded to '$xGDB.gseg_cdna_gaeval' table"
            echo "$count1601c$msg1601c (16.01c)" >>$WorkDIR/logs/Pipeline_procedure.log
            msg1601d=" GAEVAL records were loaded to '$xGDB.gseg_put_gaeval' table"
            echo "$count1601d$msg1601d (16.01d)" >>$WorkDIR/logs/Pipeline_procedure.log
            msg1601e=" GAEVAL records were loaded to '$xGDB.gseg_gbk_gaeval_properties' table"
            echo "$count1601e$msg1601e (16.01e)" >>$WorkDIR/logs/Pipeline_procedure.log
         
            # 16.02 Update GAEVAL flags
         
            ./xGDB_updateGAEVAL_flags.pl --configuration="${WorkDIR}/conf/${xGDB}_gaeval_conf.pl" --outDIR="${WorkDIR}/data/XGDB_MYSQL/" --outFILE="${xGDB}gaevalFlagSQL"
            #$ScriptDIR/formatdb.pl ${WorkDIR}/data/BLAST/
         
            mysql -p$dbpass -u $mysqluser $xGDB<${WorkDIR}/data/XGDB_MYSQL/${xGDB}gaevalFlagSQL
         
            dateTime1602=$(date +%Y-%m-%d\ %k:%M:%S)
            count1602=$(echo "select concat(\"  \", count(*)) as \"- GAEVAL Flags Upload: \" from gseg_gbk_gaeval_flags"|mysql -p$dbpass -u $mysqluser $xGDB)
            msg1602=" GAEVAL flags uploaded to gseg_gbk_gaeval_flags"
            echo "$count1602$msg1602$dateTime1602(16.02)" >>$WorkDIR/logs/Pipeline_procedure.log
         
         
            ## End GAEVAL analysis phase
         
            ## moved locus upload from here      
         
         else
         
            dateTime1601=$(date +%Y-%m-%d\ %k:%M:%S)
            msg1601="| Step 16: Skipping GAEVAL analysis - no EST cDNA or TSA aligment data exist (16.01) "
            echo "$msg1601$dateTime1601" >>$WorkDIR/logs/Pipeline_procedure.log
         fi
      else
        dateTime1601=$(date +%Y-%m-%d\ %k:%M:%S)
        msg1601="| Step 16: Skipping GAEVAL analysis - no pre-computed gene model data (from gff3) exist (16.01) "
        echo "$msg1601$dateTime1601" >>$WorkDIR/logs/Pipeline_procedure.log
      fi
   else
      dateTime1601=$(date +%Y-%m-%d\ %k:%M:%S)
      msg1601="| Step 16: Skipping GAEVAL analysis - current data don't require GAEVAL analysis (16.01) "
      echo "$msg1601$dateTime1601" >>$WorkDIR/logs/Pipeline_procedure.log
   fi


   # 16.03 Locus table query and upload
 
    dateTime1603=$(date +%Y-%m-%d\ %k:%M:%S)
    msg1603="Calculate and load precompute locus data (with GAEVAL scores averaged per locus) to MySQL table gseg_locus_annotation. "
    echo "$space$msg1603$dateTime1603 (16.03)" >>$WorkDIR/logs/Pipeline_procedure.log
 
    cp $ScriptDIR/lociFrame.sql ${WorkDIR}/data/XGDB_MYSQL/${xGDB}lociFrame.sql
    mysql -p$dbpass -u $mysqluser $xGDB< ${WorkDIR}/data/XGDB_MYSQL/${xGDB}lociFrame.sql
    echo "insert into gseg_locus_annotation(gseg_gi,locus_id,strand,l_pos,r_pos,description, transcript_ids, transcript_count,coverage,integrity,intron_count) select gseg_gi,locus_id,strand,min(l_pos),max(r_pos), group_concat(description order by geneId asc), group_concat(geneId order by geneId asc ), count(geneId),round(avg(exon_coverage),2),round(avg(b.integrity),2),max(introns_confirmed+introns_unsupported) from gseg_gene_annotation as a left join gseg_gbk_gaeval as b on a.uid=b.uid group by locus_id" |mysql -p$dbpass -u $mysqluser $xGDB
 
    dateTime1603=$(date +%Y-%m-%d\ %k:%M:%S)
    count1603=$(echo "select concat(\"  \", count(*)) as \"- Locus Upload: \" from gseg_locus_annotation"|mysql -p$dbpass -u $mysqluser $xGDB)
    msg1603=" loci were loaded to '$xGDB.gseg_locus_annotation' table "
    echo "${count1603}${msg1603}${dateTime1603} (16.03)" >>$WorkDIR/logs/Pipeline_procedure.log

   
   # 16.05 Update time stamps
      # Create file containing GDB name and time-date stamp, with DBname as human-readable filename 
      ### IMPORTANT! Do not change format! This file's contents are used in a dropdown list of archives generated by conf_functions.inc.php archive_dir_dropdown)
      DBname=$(echo "select DBname from Genomes.xGDB_Log where ID=$Id"|mysql --skip-column-names -p$dbpass -u $mysqluser)
      readable_name=${xGDB}-${DBname//[^a-zA-Z0-9\-]/-} # (convert non-ascii to "-")
      echo "$xGDB $space $DBname $space $dateTime1607" >/xGDBvm/data/$xGDB/0README-$readable_name

      # If create mode, add date / time stamp to xGDB_Log table;
      
      if [ "$mode" == "Create" ]; then
         echo "update xGDB_Log set Create_Date = now() where ID=\"$Id\""|mysql -p$dbpass -u $mysqluser Genomes
         
         dateTime1608=$(date +%Y-%m-%d\ %k:%M:%S)
         msg1608="Create_Date time stamped "
         echo "$space$msg1608$dateTime1608 (16.08)" >>$WorkDIR/logs/Pipeline_procedure.log
      fi
      
      # If update mode, add date / time stamp and history date/time stamp for end of pipeline;
      
      if [ "$mode" == "Update" ]; then
         
         # Reset update status and update actions to ""
         echo "update xGDB_Log set Update_Status='', Update_Data_EST='', Update_Data_cDNA='', Update_Data_TrAssembly='',Update_Data_Protein='',Update_Data_GSEG='',Update_Data_GeneModel='', Update_Data_CpGATModel='', Update_Data_CpGAT='', Update_Descriptions='' where ID=\"$Id\""|mysql -p$dbpass -u $mysqluser Genomes
         
         dateTime1609=$(date +%Y-%m-%d\ %k:%M:%S)
         msg1609="Update status reset; update actions reset. (16.09) "
         echo "$space$msg1609$dateTime1609" >>$WorkDIR/logs/Pipeline_procedure.log
         
         # Update "Update History"
         echo "update xGDB_Log set Update_History=concat(Update_History, \" Date: \", now(), \"; \") where ID=\"$Id\""|mysql -p$dbpass -u $mysqluser Genomes
         echo "update xGDB_Log set Update_Date = now() where ID=\"$Id\""|mysql -p$dbpass -u $mysqluser Genomes
      fi
      
      echo "update xGDB_Log set Update_History=concat(Update_History, \" -end- \") where ID=\"$Id\""|mysql -p$dbpass -u $mysqluser Genomes

   if [ -d ${WorkDIR} ] # The /xGDBvm/data/GDB00n/ directory exists.
   then
      msg1610="Output directory is present at ${WorkDIR} (16.10) "
      echo "$msg1610">>$WorkDIR/logs/Pipeline_procedure.log
   else
      error1610="ERROR: Could not create output directory  ${WorkDIR} (16.10) "
      echo "$error1610">>$WorkDIR/logs/Pipeline_procedure.log; echo "$error1610">>$WorkDIR/logs/Pipeline_error.log
      ##### NOTE: Should we add a 'Broken' status indicator to data model?
   fi



  # 16.50 Update to Current status and update Processes database!   
   echo "update xGDB_Log set Status=\"Current\", Process_Type=\"\" where ID=\"$Id\""|mysql -p$dbpass -u $mysqluser Genomes
   dateTime1650=$(date +%Y-%m-%d\ %k:%M:%S)
   msg1650="Genomes table xGDB_Log 'Status' set to Current. "
   echo "$space$msg1650$dateTime1650 (16.50)" >>$WorkDIR/logs/Pipeline_procedure.log
     
   dateTime1699=$(date +%Y-%m-%d\ %k:%M:%S)
   msg1699="* Step 16 completed. "
   echo "$space$msg1699$dateTime1699" >>$WorkDIR/logs/Pipeline_procedure.log
   
   	endTime=$(date +%Y-%m-%d\ %k:%M:%S)
	endTimeSec=$(date +"%s")
    diff=$(($endTimeSec-$startTimeSec)) #
	minutes=$(($diff / 60))
	seconds=$(($diff % 60)) # modulo

   
   if [ "$mode" == "Update" ]
   then
   echo "UPDATE Processes set Outcome=\"updated\", Duration=$diff  where ProcessTimeStamp = \"$ProcessTimeStamp\""|mysql -p$dbpass -u $mysqluser Genomes
   else
   echo "UPDATE Processes set Outcome=\"created\", Duration=$diff where ProcessTimeStamp = \"$ProcessTimeStamp\""|mysql -p$dbpass -u $mysqluser Genomes
   fi
   
}

#############################################################################################################################
############################ END OF LastPart() AND END OF 'Create' Mode Functions (Steps 1-17) ##############################
#############################################################################################################################

#############################################################################################################################
#####################  'Update' Mode Functions (Steps U1-U) for optional UPDATE of an existing GDB   #######################
#############################################################################################################################

### NOTE: logs for these steps are appended to Pipeline_procedure.log ###

### 'Update' code starts below where mode is set to 'Update'

########################################################################################################
# Step U1a. Append GFF3 precomputed gene models (or replace, if coming from replaceGFF)                #
########################################################################################################
## TO DO: Append descr.txt

addGFF () {

   dateTimeU1a00=$(date +%Y-%m-%d\ %k:%M:%S)
   msgU1a00="| Step U1a: Add GFF3 precomputed gene models. "
   echo "$dline" >>$WorkDIR/logs/Pipeline_procedure.log
   echo "$msgU1a00$dateTimeU1a00" >>$WorkDIR/logs/Pipeline_procedure.log
   echo "$dline" >>$WorkDIR/logs/Pipeline_procedure.log

   if ls -1 $newDataPath/*annot.gff3 >/dev/null 2>&1
   then
      dateTimeU1a01=$(date +%Y-%m-%d\ %k:%M:%S)
      countU1a01=$(grep -c -P "\tmRNA\t" $newDataPath/*annot.gff3) #this may not always be an accurate count!
      filesU1a01= $(ls -m $newDataPath/*annot.gff3)
      msgU1a01=" precomputed gene models are present in $newDataPath $filesU1a01"
      echo "${space}${countU1a01}${msgU1a01}${space}${dateTimeU1b01} (U1a.01)" >>$WorkDIR/logs/Pipeline_procedure.log
     
      # U1a.015 Combine new and old (if any) gff3 files as new in download, and rename to standard filename
      cat $newDataPath/*annot.gff3  >${WorkDIR}/data/download/${xGDB}new_annot.gff3
#      mv ${WorkDIR}/data/download/${xGDB}new_annot.gff3 ${WorkDIR}/data/download/${xGDB}annot.gff3
   
       dateTimeU1a015=$(date +%Y-%m-%d\ %k:%M:%S)
       countU1a015=$(grep -c -P "\tmRNA\t" ${WorkDIR}/data/download/${xGDB}new_annot.gff3) #this may not always be an accurate count!
       msgU1a015=" new precomputed gene models copied to working directory as ${xGDB}new_annot.gff3 "
       echo "$space$countU1a015$msgU1a015$dateTimeU1a015 (U1a.015)" >>$WorkDIR/logs/Pipeline_procedure.log
   
      $ScriptDIR/GFF_to_XGDB_Standard.pl -t gseg_gene_annotation ${WorkDIR}/data/download/${xGDB}new_annot.gff3 >${WorkDIR}/data/XGDB_MYSQL/new_${xGDB}gene_annotation.sql
      
      # Load new annotations to MySQL table (insert current table)
      mysql -p$dbpass -u $mysqluser $xGDB < ${WorkDIR}/data/XGDB_MYSQL/new_${xGDB}gene_annotation.sql
      
      dateTimeU102=$(date +%Y-%m-%d\ %k:%M:%S)
      countU102=$(grep -P "$" ${WorkDIR}/data/XGDB_MYSQL/new_${xGDB}gene_annotation.sql  |wc -l) #we do this rather than try to count before and after records in the gseg_gene_annotation table.
      msgU102=" new gff gene models were loaded to MySQL table gseg_gene_annotation. "
      echo "$space$countU102$msgU102$dateTimeU102" >>$WorkDIR/logs/Pipeline_procedure.log


      # Now reconcile new + old gff (if any) into a single file:
      
      cat ${WorkDIR}/data/download/${xGDB}annot.gff3 ${WorkDIR}/data/download/${xGDB}new_annot.gff3 >${WorkDIR}/data/download/${xGDB}combined_annot.gff3
      mv ${WorkDIR}/data/download/${xGDB}combined_annot.gff3 ${WorkDIR}/data/download/${xGDB}annot.gff3

      # Now reconcile new + old sql (if any) into a single file:
      
      cat ${WorkDIR}/data/XGDB_MYSQL/${xGDB}gene_annotation.sql ${WorkDIR}/data/XGDB_MYSQL/new_${xGDB}gene_annotation.sql >${WorkDIR}/data/XGDB_MYSQL/${xGDB}combined_gene_annotation.sql
      mv ${WorkDIR}/data/XGDB_MYSQL/${xGDB}combined_gene_annotation.sql ${WorkDIR}/data/XGDB_MYSQL/${xGDB}gene_annotation.sql

      dateTimeU1a025=$(date +%Y-%m-%d\ %k:%M:%S)
      countU1a025=$(grep -P "$" ${WorkDIR}/data/XGDB_MYSQL/${xGDB}gene_annotation.sql  |wc -l) #we do this rather than try to count before and after records
      msgU1a025=" total gff gene models are in MySQL table gseg_gene_annotation. "
      echo "${space}${countU1a025}${msgU1a025}${dateTimeU1a025} (U1a.025)" >>$WorkDIR/logs/Pipeline_procedure.log


      #U1a.03 If there are also precomputed translations for this annotation, append them with existing,  and BLAST index them (on the destination directory, not scratch!).
      if ls -1 $newDataPath/*annot.pep.fa >/dev/null 2>&1
      then
         countU1a03a=$(grep -c "^>" ${newDataPath}/*annot.pep.fa) # first count original dataset
         cat ${newDataPath}/*annot.pep.fa $WorkDIR/data/download/${xGDB}annot.pep.fa > $WorkDIR/data/download/new_${xGDB}annot.pep.fa
         mv $WorkDIR/data/download/new_${xGDB}annot.pep.fa $WorkDIR/data/download/${xGDB}annot.pep.fa
         cat $WorkDIR/data/download/${xGDB}annot.pep.fa > $WorkDIR/data/BLAST/${xGDB}annot.pep.fa
         /usr/local/bin/makeblastdb -in $WorkDIR/data/BLAST/${xGDB}annot.pep.fa -dbtype prot -parse_seqids -out $WorkDIR/data/BLAST/${xGDB}annot.pep.fa
         
         dateTimeU1a03=$(date +%Y-%m-%d\ %k:%M:%S)
         countU1a03b=$(grep -c "^>" ${WorkDIR}/data/BLAST/${xGDB}annot.pep.fa)
         msgU1a03="$countU1a03a precomputed translations (~annot.pep.fa) added to existing to BLAST dataset and re-indexed (total of $countU1a03b) "
         echo "${space}${msgU1a03}${dateTimeU1a03} (U1a.03)">>$WorkDIR/logs/Pipeline_procedure.log
         
      else
         dateTimeU1a03=$(date +%Y-%m-%d\ %k:%M:%S)
         msgU1a03="No new precomputed translations (~annot.pep.fa) were found. "
         echo "${space}${msgU1a03}${dateTimeU1a03} (U1a.03)">>$WorkDIR/logs/Pipeline_procedure.log
      fi


      #U1a.04 If there are also precomputed transcripts for this annotation, append to download, BLAST fasta files and index them (on the destination directory, not scratch!).
      if ls -1 $newDataPath/*annot.mrna.fa >/dev/null 2>&1
      then
         countU1a04a=$(grep -c "^>" ${newDataPath}/*annot.mrna.fa) # first count original dataset
         cat $newDataPath/*annot.mrna.fa ${WorkDIR}/data/download/${xGDB}annot.mrna.fa > $WorkDIR/data/download/new_${xGDB}annot.mrna.fa
         mv $WorkDIR/data/download/new_${xGDB}annot.mrna.fa $WorkDIR/data/download/${xGDB}annot.mrna.fa
         cat  ${WorkDIR}/data/download/${xGDB}annot.mrna.fa > $WorkDIR/data/BLAST/${xGDB}annot.mrna.fa
         /usr/local/bin/makeblastdb -in $WorkDIR/data/BLAST/${xGDB}annot.mrna.fa -dbtype nucl -parse_seqids -out $WorkDIR/data/BLAST/${xGDB}annot.mrna.fa
         
         dateTimeU1a04=$(date +%Y-%m-%d\ %k:%M:%S)
         countU1a04b=$(grep -c "^>" ${WorkDIR}/data/BLAST/${xGDB}annot.mrna.fa)
         msgU1a04="$countU1a04a precomputed transcripts (~annot.mrna.fa) added to existing BLAST dataset and re-indexed (total of $countU1a04b)"
         echo "${space}${msgU1a04}${dateTimeU1a04} (U1a.04)">>$WorkDIR/logs/Pipeline_procedure.log
         
      else
         dateTimeU1a04=$(date +%Y-%m-%d\ %k:%M:%S)
         msgU1a04="No precomputed  output transcripts (fasta) were found. "
         echo "${space}${msgU1a04}${dateTimeU1a04} (U1B.04)">>$WorkDIR/logs/Pipeline_procedure.log
      fi
      
      dateTimeU1a99=$(date +%Y-%m-%d\ %k:%M:%S)
      msgU1a99="* Step U1a completed.  If no other update actions, next is Step 14 (runCpGAT)"
      echo "$space$msgU1a99$dateTimeU1a99" >>$WorkDIR/logs/Pipeline_procedure.log

   else # No input GFF3 data found in Update directory (error)
      
      echo "ERROR: No valid ~annot.gff3 file detected in Update Directory: $newDataPath (U1a.01)" >>$WorkDIR/logs/Pipeline_procedure.log
      echo "ERROR: No valid ~annot.gff3 file detected in Update Directory: $newDataPath (U1a.01)" >>$WorkDIR/logs/Pipeline_error.log
      dateTimeU1a99=$(date +%Y-%m-%d\ %k:%M:%S)
      msgU1a99="* Step U1a completed but update was unsuccessful."
      echo "$space$msgU1a99$dateTimeU1a99" >>$WorkDIR/logs/Pipeline_procedure.log
      
   fi  # End of addGFF
   
}

########################################################################################################
# Step U1b. Append CpGAT-GFF3 precomputed gene models (or replace, if coming from replaceCpGATGFF)     #
########################################################################################################
# This step carries out all steps required to parse and load user-provided CpGAT GFF3 to MySQL, as well as index any cpgat.pep.fa or cpgat.mrna.fa
# Once this function has run, CpGAT itself should be bypassed altogether.

addCpGATGFF () {
   
   dateTimeU1b00=$(date +%Y-%m-%d\ %k:%M:%S)
   msgU1b00="| Step U1b: Add CpGAT precomputed gene models (~cpgat.gff3). "
   echo "$dline" >>$WorkDIR/logs/Pipeline_procedure.log
   echo "$msgU1b00$dateTimeU1b00" >>$WorkDIR/logs/Pipeline_procedure.log
   echo "$dline" >>$WorkDIR/logs/Pipeline_procedure.log
   
   # Assign CpGAT parameter as '' since we won't need CpGAT
   CpGATparameter=''
   
   if ls -1 $newDataPath/*cpgat.gff3 >/dev/null 2>&1
   then
      dateTimeU1b01=$(date +%Y-%m-%d\ %k:%M:%S)
      countU1b01=$(grep -c -P "\tmRNA\t" $newDataPath/*cpgat.gff3) #this may not always be an accurate count!
      filesU1b01= $(ls -m $newDataPath/*cpgat.gff3)
      msgU1b01=" precomputed CpGAT gene models are present in $newDataPath $filesU1b01"
      echo "$space$countU1b01$msgU1b01$space$dateTimeU1b01 (U1b.01)" >>$WorkDIR/logs/Pipeline_procedure.log
      
      # Combine new cpgat-gff3 files as new in download
      cat $newDataPath/*cpgat.gff3 >${WorkDIR}/data/download/${xGDB}new_cpgat.gff3
 
      dateTimeU1b015=$(date +%Y-%m-%d\ %k:%M:%S)
      countU1b015=$(grep -c -P "\tmRNA\t" ${WorkDIR}/data/download/${xGDB}new_cpgat.gff3) #this may not always be an accurate count!
      msgU1b015=" new CpGAT gene models have been copied as ${xGDB}new_cpgat.gff3 to working directory"
      echo "$space$countU1b015$msgU1b015$dateTimeU1b015 (Ub.015)" >>$WorkDIR/logs/Pipeline_procedure.log

      # Parse for MySQL upload and load
      $ScriptDIR/GFF_to_XGDB_Standard.pl -t gseg_cpgat_gene_annotation ${WorkDIR}/data/download/${xGDB}new_cpgat.gff3 >${WorkDIR}/data/XGDB_MYSQL/new_${xGDB}cpgat_gene_annotation.sql
       
      mysql -p$dbpass -u $mysqluser $xGDB < ${WorkDIR}/data/XGDB_MYSQL/new_${xGDB}cpgat_gene_annotation.sql # load the data to MySQL

      dateTimeU1b02=$(date +%Y-%m-%d\ %k:%M:%S)
      countU1b02=$(grep -P "$" ${WorkDIR}/data/XGDB_MYSQL/new_${xGDB}cpgat_gene_annotation.sql  |wc -l) #we do this rather than try to count before and after records in the gseg_gene_annotation table.
      msgU1b02=" new CpGAT gff gene models were loaded to MySQL table gseg_cpgat_gene_annotation. "
      echo "$space$countU1b02$msgU1b02$dateTimeU1b02 (U1b.02)" >>$WorkDIR/logs/Pipeline_procedure.log

      # Now reconcile new + old gff (if any) into a single file:
      
      cat ${WorkDIR}/data/download/${xGDB}cpgat.gff3 ${WorkDIR}/data/download/${xGDB}new_cpgat.gff3 >${WorkDIR}/data/download/${xGDB}combined_cpgat.gff3
      mv ${WorkDIR}/data/download/${xGDB}combined_cpgat.gff3 ${WorkDIR}/data/download/${xGDB}cpgat.gff3

      # Now reconcile new + old sql (if any) into a single file:
      
      cat ${WorkDIR}/data/XGDB_MYSQL/${xGDB}cpgat_gene_annotation.sql ${WorkDIR}/data/XGDB_MYSQL/new_${xGDB}cpgat_gene_annotation.sql >${WorkDIR}/data/XGDB_MYSQL/${xGDB}combined_cpgat_gene_annotation.sql
      mv ${WorkDIR}/data/XGDB_MYSQL/${xGDB}combined_cpgat_gene_annotation.sql ${WorkDIR}/data/XGDB_MYSQL/${xGDB}cpgat_gene_annotation.sql

      dateTimeU1b025=$(date +%Y-%m-%d\ %k:%M:%S)
      countU1b025=$(grep -P "$" ${WorkDIR}/data/XGDB_MYSQL/${xGDB}cpgat_gene_annotation.sql  |wc -l) #we do this rather than try to count before and after records
      msgU1b025=" total CpGAT gff gene models are in MySQL table gseg_cpgat_gene_annotation. "
      echo "$space$countU1b025$msgU1b025$dateTimeU1b025 (U1b.025)" >>$WorkDIR/logs/Pipeline_procedure.log


      #U1b.03 If there are also precomputed translations for this annotation, cat them with existing,  and BLAST index them (on the destination directory, not scratch!).
      if ls -1 $newDataPath/*cpgat.pep.fa >/dev/null 2>&1
      then
         countU1b03a=$(grep -c "^>" ${newDataPath}/*cpgat.pep.fa) # first count original dataset
         cat ${newDataPath}/*cpgat.pep.fa $WorkDIR/data/download/${xGDB}cpgat.pep.fa > $WorkDIR/data/download/new_${xGDB}cpgat.pep.fa
         mv $WorkDIR/data/download/new_${xGDB}cpgat.pep.fa $WorkDIR/data/download/${xGDB}cpgat.pep.fa
         cat $WorkDIR/data/download/${xGDB}cpgat.pep.fa > $WorkDIR/data/BLAST/${xGDB}cpgat.pep.fa
         /usr/local/bin/makeblastdb -in $WorkDIR/data/BLAST/${xGDB}cpgat.pep.fa -dbtype prot -parse_seqids -out $WorkDIR/data/BLAST/${xGDB}cpgat.pep.fa
         
         dateTimeU1b03=$(date +%Y-%m-%d\ %k:%M:%S)
         countU1b03b=$(grep -c "^>" ${WorkDIR}/data/BLAST/${xGDB}cpgat.pep.fa)
         msgU1b03="$countU1b03a precomputed CpGAT output translations (~cpgat.pep.fa)  added to existing BLAST dataset and re-indexed (total of $countU1b03b)"
         echo "${space}${msgU1b03}${dateTimeU1b03} (U1b.03)">>$WorkDIR/logs/Pipeline_procedure.log
         
      else
         dateTimeU1b03=$(date +%Y-%m-%d\ %k:%M:%S)
         msgU1b03="No precomputed CpGAT output translations(~cpgat.pep.fa) were found. "
         echo "$space$msgU1b03$dateTimeU1b03 (U1b.03)">>$WorkDIR/logs/Pipeline_procedure.log
      fi
      
      #U1b.04 If there are also precomputed transcripts for this annotation, append them to download & BLAST fasta files, and BLAST index them (on the destination directory, not scratch!).
      if ls -1 $newDataPath/*cpgat.mrna.fa >/dev/null 2>&1
      then
         countU1b04a=$(grep -c "^>" ${newDataPath}/*cpgat.mrna.fa) # first count original dataset
         cat $newDataPath/*cpgat.mrna.fa ${WorkDIR}/data/download/${xGDB}cpgat.mrna.fa > $WorkDIR/data/download/new_${xGDB}cpgat.mrna.fa
         mv $WorkDIR/data/download/new_${xGDB}cpgat.mrna.fa $WorkDIR/data/download/${xGDB}cpgat.mrna.fa
         cat  ${WorkDIR}/data/download/${xGDB}cpgat.mrna.fa > $WorkDIR/data/BLAST/${xGDB}cpgat.mrna.fa
         /usr/local/bin/makeblastdb -in $WorkDIR/data/BLAST/${xGDB}cpgat.mrna.fa -dbtype nucl -parse_seqids -out $WorkDIR/data/BLAST/${xGDB}cpgat.mrna.fa
         
         dateTimeU1b04=$(date +%Y-%m-%d\ %k:%M:%S)
         countU1b04=$(grep -c "^>" ${WorkDIR}/data/BLAST/${xGDB}cpgat.mrna.fa)
         msgU1b04=" precomputed CpGAT output transcripts (~cpgat.mrna.fa) copied to BLAST directory and indexed "
         echo "$space$countU1b04$msgU1b04$dateTimeU1b04 (U1b.04)">>$WorkDIR/logs/Pipeline_procedure.log
         
      else
         dateTimeU1b04=$(date +%Y-%m-%d\ %k:%M:%S)
         msgU1b04="No precomputed CpGAT output transcripts (~cpgat.mrna.fa) were found. "
         echo "$space$msgU1b04$dateTimeU1b04 (U1B.04)">>$WorkDIR/logs/Pipeline_procedure.log
      fi
      
      dateTimeU1b99=$(date +%Y-%m-%d\ %k:%M:%S)
      msgU1b99="* Step U1b completed."
      echo "$space$msgU1b99$dateTimeU1b99" >>$WorkDIR/logs/Pipeline_procedure.log
      
   else # No input CpGAT GFF3 data found in Update directory (error)
      
      echo "ERROR: No valid ~cpgat.gff3 file detected in Update Directory: $newDataPath (U1b.01)" >>$WorkDIR/logs/Pipeline_procedure.log
      echo "ERROR: No valid ~cpgat.gff3 file detected in Update Directory: $newDataPath (U1b.01)" >>$WorkDIR/logs/Pipeline_error.log
      dateTimeU1b99=$(date +%Y-%m-%d\ %k:%M:%S)
      msgU1b99="* Step U1b completed but no input CpGAT data will be processed in Step 14 (runCpGAT)"
      echo "$space$msgU1b99$dateTimeU1b99" >>$WorkDIR/logs/Pipeline_procedure.log
      
   fi  # End of addCpGATGFF
   
   
   
}

############################################################################################################################
# Step U2. Add new genome segments, splice-align existing transcript/protein to them, and (optionally) run CpGAT on them   #
############################################################################################################################
# (if transcript sequence are added/replaced in this update, they will be dealt with LATER using all genome segments)
# FIXME: This step is carried out under /xGDBvm/data, NOT under /xGDBvm/data/scratch/ -- we should bring this over to the scratch disk.

addGSEG () {
   
   #U2.01 Upload new genome segments and add to previous set
   dateTimeU200=$(date +%Y-%m-%d\ %k:%M:%S)
   msgU200="| Step U2: Add genome segments. "
   echo "$dline" >>$WorkDIR/logs/Pipeline_procedure.log
   echo "$msgU200$dateTimeU200" >>$WorkDIR/logs/Pipeline_procedure.log
   echo "$dline" >>$WorkDIR/logs/Pipeline_procedure.log
   
   #FIXME still need to add loop for repeat masking.
   
   # concatenate new genome fasta file(s) together and copy to /xGDBvm/data/GDBnnn/data/download/new_GDBnnngdna.fa (for the moment, separate from the "original" scaffold sequences)
   cat $newDataPath/*gdna.fa >${WorkDIR}/data/download/new_${xGDB}gdna.fa # This is just the new sequence; use for spliced alignment.
   # count number of new gdna sequences
   countU201a=$(grep -c "^>" ${WorkDIR}/data/download/new_${xGDB}gdna.fa)
   # Now cat together old and new scaffolds and replace existing scaffold fasta in the downloads directory:
   cat ${WorkDIR}/data/download/new_${xGDB}gdna.fa ${WorkDIR}/data/download/${xGDB}gdna.fa >${WorkDIR}/data/download/temp_${xGDB}gdna.fa
   mv ${WorkDIR}/data/download/temp_${xGDB}gdna.fa ${WorkDIR}/data/download/${xGDB}gdna.fa
   dateTimeU201=$(date +%Y-%m-%d\ %k:%M:%S)
   countU201b=$(grep -c "^>" ${WorkDIR}/data/download/${xGDB}gdna.fa)
   echo "$space$countU201a new genome sequences were added to ${WorkDIR}/data/download/${xGDB}gdna.fa for a total of $countU201b (U2.01) $dateTimeU201" >>$WorkDIR/logs/Pipeline_procedure.log
  
   #add new genome sequences to old sequences in the /xGDBvm/data/GDBnnn/data/BLAST directory and re-index.
   dateTimeU2015=$(date +%Y-%m-%d\ %k:%M:%S)
   msgU2015="The new genome sequence file(s) are being copied to ${WorkDIR}/data/BLAST/${xGDB}gdna.fa and re-indexed for BLAST"
   echo "${space}${msgU2015} (U2.015) $dateTimeU201" >>$WorkDIR/logs/Pipeline_procedure.log
   
   # Now cat together old and new scaffolds and replace existing scaffold fasta in the downloads directory:
   cat $newDataPath/*gdna.fa ${WorkDIR}/data/BLAST/${xGDB}gdna.fa >${WorkDIR}/data/BLAST/temp_${xGDB}gdna.fa
   mv ${WorkDIR}/data/BLAST/temp_${xGDB}gdna.fa ${WorkDIR}/data/BLAST/${xGDB}gdna.fa

   # Index for BLAST
   /usr/local/bin/makeblastdb -in ${WorkDIR}/data/BLAST/${xGDB}gdna.fa -dbtype nucl -parse_seqids -out ${WorkDIR}/data/BLAST/${xGDB}gdna.fa

   dateTimeU202=$(date +%Y-%m-%d\ %k:%M:%S)
   countU202=$(grep -c "^>" ${WorkDIR}/data/BLAST/${xGDB}gdna.fa)
   msgU202=" (total) genome sequences have been indexed for BLAST in ${WorkDIR}/data/BLAST/${xGDB}gdna.fa  . "
   echo "$space$countU202$msgU202$dateTimeU202 (U2.02)">>$WorkDIR/logs/Pipeline_procedure.log
   
   ## U2.03 The new Scaffold sequences are parsed and loaded to the existing MySQL gseg table (insert into...)
   
   $ScriptDIR/xGDBload_SeqFromFasta.pl gseg ${WorkDIR}/data/download/new_${xGDB}gdna.fa >${WorkDIR}/data/XGDB_MYSQL/new_${xGDB}gdna.sql
   mysql -p$dbpass -u $mysqluser $xGDB < ${WorkDIR}/data/XGDB_MYSQL/new_${xGDB}gdna.sql
   
   dateTimeU203=$(date +%Y-%m-%d\ %k:%M:%S)
   countU203=$(echo "select concat(\"  \", count(*)) as \"- New Genome Sequence Uploaded to MySQL:\" from gseg"|mysql -p$dbpass -u $mysqluser $xGDB)
   msgU203=" genome sequences are currently in the updated '$xGDB.gseg' table. "
   echo "$countU203$msgU203$dateTimeU203 (U2.03)" >>$WorkDIR/logs/Pipeline_procedure.log
   
   ## U2.04 Remove old GeneSeqer and GenomThreader output. FIXME - this may not be correct, it should be concatenating these to the new output, not removing them?.
   rm -rf ${WorkDIR}/data/GSQ/GSQOUT/*.gsq
   rm -rf ${WorkDIR}/data/GTH/GTHOUT/*.gth
   
   ## rename  existing files
   
   for file in ${WorkDIR}/data/GSQ/GSQOUT/*.gsq ; do mv $file old_$file ; done
   for file in ${WorkDIR}/data/GSQ/GTHOUT/*.gth ; do mv $file old_$file ; done
   
   msgU204="- Starting GeneSeqer/GenomeThreader spliced alignment of current transcripts to new genome segments. Old GSQ, GTH output files renamed."
   echo "$msgU204 (U2.04)" >>$WorkDIR/logs/Pipeline_procedure.log
   
   if [[ -z $RepeatMaskparameter ]]
   ##   U2.05a No repeat masking requested. Copy new genome sequence to working directory (NOT scratch directory)
   then
      cp ${WorkDIR}/data/download/new_${xGDB}gdna.fa $WorkDIR/data/GSQ/SCFDIR/new_${xGDB}gdna.fa
      
      dateTimeU205=$(date +%Y-%m-%d\ %k:%M:%S)
      countU205=$(ls $WorkDIR/data/GSQ/SCFDIR/|wc -l)
      msgU205=" new genome sequences copied to GSQ working dir $WorkDIR/data/GSQ/SCFDIR/new_${xGDB}gdna.fa "
      echo "$space$countU205$msgU205$dateTimeU205 (U2.05a)">>$WorkDIR/logs/Pipeline_procedure.log
      ## U2.05b Repeat masking requested. Run vmatch and deposit output file to working directory (NOT scratch directory)
   else
      /usr/local/bin/vmatch -q ${WorkDIR}/data/download/new_${xGDB}gdna.fa -qmaskmatch X -d -p -l 100 -exdrop 4 -identity 80 $RepeatMaskparameter | grep -v '#' > $WorkDIR/data/GSQ/SCFDIR/new_${xGDB}gdna.fa
      dateTimeU205=$(date +%Y-%m-%d\ %k:%M:%S)
      countU205=$(ls $WorkDIR/data/GSQ/SCFDIR/|wc -l)
      msgU205=" new Repeat Masked genome sequence copied to GSQ working dir $WorkDIR/data/GSQ/SCFDIR/new_${xGDB}gdna.fa "
      echo "$space$countU205$msgU205$dateTimeU205 (U2.05b)" >>$WorkDIR/logs/Pipeline_procedure.log
   fi
   ## U2.06 Run GeneSeqer vs EST using JUST the new scaffolds and EXISTING EST (i.e. not including any EST added later during this update cycle)
   
   countU206a=$(grep -c "^>" ${WorkDIR}/data/GSQ/MRNADIR/${xGDB}est.fa)
   countU206b=$(grep -c "^>" ${WorkDIR}/data/GSQ/SCFDIR/new_${xGDB}gdna.fa)
   dateTimeU206=$(date +%Y-%m-%d\ %k:%M:%S)
   
   echo "- EST Spliced Alignment: $countU206a EST sequences are being splice-aligned to $countU206b new genome sequences (U2.06)" >>$WorkDIR/logs/Pipeline_procedure.log
   echo "${space} GSQ parameter set is $GSQparameter (U2.06)" >>$WorkDIR/logs/Pipeline_procedure.log
   
   /xGDBvm/scripts/SplitMakeArrayGSQ.pl ${WorkDIR}/data/GSQ/MRNADIR/${xGDB}est.fa 70 ${WorkDIR}/data/GSQ/SCFDIR/new_${xGDB}gdna.fa "$GSQparameter"
   
   #U2.07 EST GeneSeqer results with new scaffolds
   dateTimeU207=$(date +%Y-%m-%d\ %k:%M:%S)
   countU207=$(grep -c "MATCH"  ${WorkDIR}/data/GSQ/GSQOUT/${xGDB}est.gsq)
   msgU207=" EST spliced alignments completed and sent to GSQ output directory $WorkDIR/data/GSQ/GSQOUT/${xGDB}est.gsq:  "
   echo "$space$countU207$msgU207$dateTimeU207 (U2.07)">>$WorkDIR/logs/Pipeline_procedure.log
   
   ## U2.08 Run GeneSeqer vs cDNA using JUST the new scaffolds and EXISTING cDNA (i.e. not including any cDNA added later during this update cycle)
   countU208a=$(grep -c "^>" ${WorkDIR}/data/GSQ/MRNADIR/${xGDB}cdna.fa)
   countU208b=$(grep -c "^>" ${WorkDIR}/data/GSQ/SCFDIR/new_${xGDB}gdna.fa)
   dateTimeU208=$(date +%Y-%m-%d\ %k:%M:%S)
   
   echo "- cDNA Spliced Alignment: $countU208a cDNA sequences are being splice-aligned to $countU208b new genome sequences (U2.08)" >>$WorkDIR/logs/Pipeline_procedure.log
   echo "${space}GSQ parameter set is $GSQparameter (U2.08)" >>$WorkDIR/logs/Pipeline_procedure.log
   
   /xGDBvm/scripts/SplitMakeArrayGSQ.pl ${WorkDIR}/data/GSQ/MRNADIR/${xGDB}cdna.fa 70 ${WorkDIR}/data/GSQ/SCFDIR/new_${xGDB}gdna.fa "$GSQparameter"
   
   #U2.09 cDNA GeneSeqer results with new scaffolds
   
   dateTimeU209=$(date +%Y-%m-%d\ %k:%M:%S)
   countU209=$(grep -c "MATCH"  ${WorkDIR}/data/GSQ/GSQOUT/${xGDB}cdna.gsq)
   msgU209=" cDNA spliced alignments completed and sent to GSQ output directory $WorkDIR/data/GSQ/GSQOUT/${xGDB}cdna.gsq "
   echo "$space$countU209$msgU209$dateTimeU209 (U2.09)">>$WorkDIR/logs/Pipeline_procedure.log
   
   ## U2.10 Run GeneSeqer vs TSA using JUST the new scaffolds and EXISTING TSA (i.e. not including any TSA added later during this update cycle)
   countU210a=$(grep -c "^>" ${WorkDIR}/data/GSQ/PUTDIR/${xGDB}tsa.fa)
   countU210b=$(grep -c "^>" ${WorkDIR}/data/GSQ/SCFDIR/new_${xGDB}gdna.fa)
   dateTimeU210=$(date +%Y-%m-%d\ %k:%M:%S)
   
   echo "- TSA Spliced Alignment: $countU210a TSA sequences are being splice-aligned to $countU210b new genome sequences (U2.08)" >>$WorkDIR/logs/Pipeline_procedure.log
   echo "${space}GSQ parameter set is $GSQparameter (U2.10)" >>$WorkDIR/logs/Pipeline_procedure.log
   
   /xGDBvm/scripts/SplitMakeArrayGSQ.pl ${WorkDIR}/data/GSQ/PUTDIR/${xGDB}tsa.fa 70 ${WorkDIR}/data/GSQ/SCFDIR/new_${xGDB}gdna.fa "$GSQparameter"
   
   #U2.11 TSA GeneSeqer results with new scaffolds
   
   dateTimeU211=$(date +%Y-%m-%d\ %k:%M:%S)
   countU211=$(grep -c "MATCH"  ${WorkDIR}/data/GSQ/GSQOUT/${xGDB}tsa.gsq)
   msgU211=" TSA (PUT) spliced alignments completed and sent to GSQ output directory $WorkDIR/data/GSQ/GSQOUT/${xGDB}tsa.gsq "
   echo "$space$countU211$msgU211$dateTimeU211 (U2.11)">>$WorkDIR/logs/Pipeline_procedure.log
   
   # U2.12 Run GenomeThreader vs protein using JUST the new scaffolds and EXISTING protein (i.e. not including any proteins added later during this update cycle)
   countU212a=$(grep -c "^>" ${WorkDIR}/data/GTH/Protein/${xGDB}prot.fa)
   countU212b=$(grep -c "^>" ${WorkDIR}/data/GSQ/SCFDIR/new_${xGDB}gdna.fa)
   dateTimeU212=$(date +%Y-%m-%d\ %k:%M:%S)
   
   echo "- Protein Spliced Alignment: $countU212a protein sequences are being splice-aligned to $countU212b new genome sequences (U2.12)" >>$WorkDIR/logs/Pipeline_procedure.log
   echo "$space- GTH parameter set is $GTHparameter (U2.12)" >>$WorkDIR/logs/Pipeline_procedure.log
   
   if (( $nbproc > 1 ))
   then
      mkdir ${WorkDIR}/data/GTH/GTHOUT/SPLIT
      cd ${WorkDIR}/data/download
      /usr/local/bin/fastasplit.pl -i new_${xGDB}gdna.fa -n $nbproc -o ${WorkDIR}/data/GTH/GTHOUT/SPLIT
      cd ${WorkDIR}/data/GTH/GTHOUT/SPLIT
      i=0
      for g in *; do
        ((i++)); mkdir TMP$i; mv $g TMP$i; cd TMP$i; cp ${WorkDIR}/data/GTH/Protein/${xGDB}prot.fa ./;
        /usr/local/bin/gth -genomic $g -protein ${xGDB}prot.fa $GTHparameter -o gthout$i &
        cd ..
      done
      wait
      cat TMP*/gthout* > ${WorkDIR}/data/GTH/GTHOUT/${xGDB}prot.gth
      cd ${WorkDIR}
   else
      /usr/local/bin/gth -genomic ${WorkDIR}/data/download/new_${xGDB}gdna.fa -protein ${WorkDIR}/data/GTH/Protein/${xGDB}prot.fa $GTHparameter -o ${WorkDIR}/data/GTH/GTHOUT/${xGDB}prot.gth
   fi

   #U2.13 Protein GenomeThreader results with new scaffolds
   dateTimeU213=$(date +%Y-%m-%d\ %k:%M:%S)
   countU213=$(grep -c "MATCH"  ${WorkDIR}/data/GTH/GTHOUT/${xGDB}prot.gth)
   msgU213=" protein spliced alignments to new genome sequence completed and sent to GTH output directory $WorkDIR/data/GTH/GTHOUT/${xGDB}prot.gth "
   echo "$space$countU213$msgU213$dateTimeU213 (U2.13)">>$WorkDIR/logs/Pipeline_procedure.log
   
   $ScriptDIR/xGDBload_PgsFromGSQ.pl -t 'gseg_est_good_pgs' ${WorkDIR}/data/GSQ/GSQOUT/${xGDB}est.gsq >${WorkDIR}/data/XGDB_MYSQL/new_${xGDB}gseg_est_good_pgs.sql
   $ScriptDIR/xGDBload_PgsFromGSQ.pl -t 'gseg_cdna_good_pgs' ${WorkDIR}/data/GSQ/GSQOUT/${xGDB}cdna.gsq >${WorkDIR}/data/XGDB_MYSQL/new_${xGDB}gseg_cdna_good_pgs.sql
   $ScriptDIR/xGDBload_PgsFromGSQ.pl -t 'gseg_put_good_pgs' ${WorkDIR}/data/GSQ/GSQOUT/${xGDB}tsa.gsq >${WorkDIR}/data/XGDB_MYSQL/new_${xGDB}gseg_put_good_pgs.sql
   $ScriptDIR/xGDBload_PgsFromGTH.pl -t 'gseg_pep_good_pgs' ${WorkDIR}/data/GTH/GTHOUT/${xGDB}prot.gth >${WorkDIR}/data/XGDB_MYSQL/new_${xGDB}gseg_pep_good_pgs.sql
   
   dateTimeU214=$(date +%Y-%m-%d\ %k:%M:%S)
   msgU214=" all spliced alignments parsed to new.sql files under ${WorkDIR}/data/XGDB_MYSQL/ "
   echo "$space$countU214$msgU214$dateTimeU214 (U2.14)">>$WorkDIR/logs/Pipeline_procedure.log
   
   mysql -p$dbpass -u $mysqluser $xGDB < ${WorkDIR}/data/XGDB_MYSQL/new_${xGDB}gseg_est_good_pgs.sql
   mysql -p$dbpass -u $mysqluser $xGDB < ${WorkDIR}/data/XGDB_MYSQL/new_${xGDB}gseg_cdna_good_pgs.sql
   mysql -p$dbpass -u $mysqluser $xGDB < ${WorkDIR}/data/XGDB_MYSQL/new_${xGDB}gseg_put_good_pgs.sql
   mysql -p$dbpass -u $mysqluser $xGDB < ${WorkDIR}/data/XGDB_MYSQL/new_${xGDB}gseg_pep_good_pgs.sql
   
   dateTimeU215=$(date +%Y-%m-%d\ %k:%M:%S)
   countU215=$(grep -c "MATCH"  ${WorkDIR}/data/GTH/GTHOUT/${xGDB}prot.gth)
   msgU215=" updating spliced alignment MySQL tables with data from new genome segments "
   echo "$space$msgU215$dateTimeU215 (U2.15)">>$WorkDIR/logs/Pipeline_procedure.log
   
   $ScriptDIR/xGDB_markCognate.pl -T 'gseg_cdna_good_pgs' -P $dbpass -U $mysqluser -D $xGDB
   $ScriptDIR/xGDB_markCognate.pl -T 'gseg_est_good_pgs' -P $dbpass -U $mysqluser -D $xGDB
   
   dateTimeU216=$(date +%Y-%m-%d\ %k:%M:%S)
   msgU216=" cognate EST and cDNA sequences are marked. "
   echo "$space$msgU216$dateTimeU216 (U2.16)">>$WorkDIR/logs/Pipeline_procedure.log
   
   dateTimeU299=$(date +%Y-%m-%d\ %k:%M:%S)
   msgU299="* Step U2 Completed. "
   echo "$space$msgU299$dateTimeU299 ">>$WorkDIR/logs/Pipeline_procedure.log
   SPLICEALIGN="T" # flag for CpGAT  #FIXME add mysql queries to be sure data were added above!!

}

##############################################################
# Step U3. Add EST sequences  /spliced alignments #
##############################################################

## Note - if the user has selected "Replace EST" (Step U9), the current step (U3) is called next, after the tables have been dropped and download fasta & BLAST index removed.

addEST () {
   
   
   dateTimeU300=$(date +%Y-%m-%d\ %k:%M:%S)
   msgU300="| Step U3: Add EST sequences. "
   echo "$dline" >>$WorkDIR/logs/Pipeline_procedure.log
   echo "$msgU300$dateTimeU300" >>$WorkDIR/logs/Pipeline_procedure.log
   echo "$dline" >>$WorkDIR/logs/Pipeline_procedure.log
   
   mkdir $tmpWorkDIR
   mkdir $tmpWorkDIR/data
   mkdir $tmpWorkDIR/data/GSQ
   mkdir $tmpWorkDIR/data/GSQ/MRNADIR
   mkdir $tmpWorkDIR/data/GSQ/GSQOUT
   mkdir $tmpWorkDIR/data/GSQ/SCFDIR
   mkdir $tmpWorkDIR/data/download
   mkdir $tmpWorkDIR/data/XGDB_MYSQL
   
   ## U3.01a concatenate and copy update update EST sequences to tmp download directory as "new"
   cat $newDataPath/*est.fa >${tmpWorkDIR}/data/download/new_${xGDB}est.fa
   ## U3.01b concatenate and copy update update EST sequences,  cat together with existing EST in (non-scratch) BLAST directory as "new"
   cat $newDataPath/*est.fa ${WorkDIR}/data/BLAST/${xGDB}est.fa >${WorkDIR}/data/BLAST/new_${xGDB}est.fa
   
   countU301=$(grep -c "^>" ${tmpWorkDIR}/data/download/new_${xGDB}est.fa)
   echo "$space$countU301 new EST sequences are being added (U3.01)" >>$WorkDIR/logs/Pipeline_procedure.log
   
   dateTimeU301=$(date +%Y-%m-%d\ %k:%M:%S)
   filecountU301=$(ls $newDataPath/*est.fa*|wc -l)
   msgU301=" fasta file(s) containing EST sequences copied to scratch directoriers (BLAST and download) as new_${xGDB}est"
   echo "$space$filecountU301$msgU301 $dateTimeU301 (U3.01)" >>$WorkDIR/logs/Pipeline_procedure.log
   
   ## U3.02 rename newGDBnnnest to GDBnnnest in BLAST directory (this is a combo of new and old sequences) and make blast index (this is all done on the destination disk)
   mv ${WorkDIR}/data/BLAST/new_${xGDB}est.fa ${WorkDIR}/data/BLAST/${xGDB}est.fa
   /usr/local/bin/makeblastdb -in ${WorkDIR}/data/BLAST/${xGDB}est.fa -dbtype nucl -parse_seqids -out ${WorkDIR}/data/BLAST/${xGDB}est.fa
   
   ## U3.03 Load new est sequences to MySQL (if this table already populated, the new data will be appended)
   ## First parse EST sequence data to .sql load file
   
   echo "${space}Parsing EST sequence records to ${tmpWorkDIR}/data/XGDB_MYSQL/new_${xGDB}est.sql (U3.031)">>$WorkDIR/logs/Pipeline_procedure.log
   
   $ScriptDIR/xGDBload_SeqFromFasta.pl est ${tmpWorkDIR}/data/download/new_${xGDB}est.fa >${tmpWorkDIR}/data/XGDB_MYSQL/new_${xGDB}est.sql
   
   ## Now go ahead and upload the new data to MySQL (it will append existing data if not ReplaceEST ):
   mysql -p$dbpass -u $mysqluser $xGDB < ${tmpWorkDIR}/data/XGDB_MYSQL/new_${xGDB}est.sql
   
   countU303=$(echo "select concat(\"  \", count(*)) as \"- EST Upload:\" from est"|mysql -p$dbpass -u $mysqluser $xGDB)
   msgU303=" EST sequences are now stored in $xGDB est table (U3.033)"
   echo "$space$countU303$msgU303" >>$WorkDIR/logs/Pipeline_procedure.log
   
   ## U3.04 Copy the new EST sequence to GSQ mRNA directory for spliced alignment.
   echo "${space}Copying new EST sequence to (tmp) /GSQ/MNRNADIR/ (U3.04)">>$WorkDIR/logs/Pipeline_procedure.log
   
   cp ${tmpWorkDIR}/data/download/new_${xGDB}est.fa $tmpWorkDIR/data/GSQ/MRNADIR/${xGDB}est.fa
   
   ## U3.05 concatenate and copy scaffold sequence to (tmp) GSQ scaffold directory
   
   # If repeat mask genome exists, use that one.
   if ls -1 ${WorkDIR}/data/BLAST/${xGDB}gdna.rm.fa >/dev/null 2>&1
   then
      cp ${WorkDIR}/data/BLAST/${xGDB}gdna.rm.fa $tmpWorkDIR/data/GSQ/SCFDIR/${xGDB}gdna.fa
      echo "${space}Copied repeat masked genome to $tmpWorkDIR/data/GSQ/SCFDIR/${xGDB}gdna.fa (U3.05)">>$WorkDIR/logs/Pipeline_procedure.log
   else
      cp ${WorkDIR}/data/BLAST/${xGDB}gdna.fa $tmpWorkDIR/data/GSQ/SCFDIR/${xGDB}gdna.fa
      echo "${space}Copied (unmasked) genome to $tmpWorkDIR/data/GSQ/SCFDIR/${xGDB}gdna.fa (U3.05)">>$WorkDIR/logs/Pipeline_procedure.log
   fi
      
   ## U3.06 If precomputed GSQ outputs are present in user's Update Data Directory, copy to appropriate (tmp) working directory and skip GSQ spliced alignment.
   
   # EST precomputed output already exists? Then copy it to (tmp) GSQOUT directory and place a copy in (final) download directory (as NEW)
   if ls -1 $newDataPath/*est.gsq >/dev/null 2>&1
   then
      
      echo "${space}GSQ pre-computed output exists. Copying to scratch directory for parsing (U3.061)">>$WorkDIR/logs/Pipeline_procedure.log
      
      cat $newDataPath/*est.gsq >$WorkDIR/data/download/new_${xGDB}est.gsq
      
      cat $newDataPath/*est.gsq >$tmpWorkDIR/data/GSQ/GSQOUT/${xGDB}est.gsq
      
      dateTimeU3062=$(date +%Y-%m-%d\ %k:%M:%S)
      countU3062=$(grep -c "MATCH" $tmpWorkDIR/data/GSQ/GSQOUT/${xGDB}est.gsq)
      msgU3062=" precomputed EST spliced alignments copied to GSQ output directory $tmpWorkDIR/data/GSQ/GSQOUT/${xGDB}est.gsq: "
      echo "$space$countU3062$msgU3062$dateTimeU3062 (U3.062)">>$WorkDIR/logs/Pipeline_procedure.log
      echo "${space}Skipping GeneSeqer spliced alignment, jumping to U3.08">>$WorkDIR/logs/Pipeline_procedure.log
   else
      
      ## If no user-provided GeneSeqer output files, initiates SplitMakeArrayGSQ.pl (parses input, makes index, initiates GeneSeqer), deposits output in working directory
      
      ## U3.07 Split and run GeneSeqer on scratch directory
      
      countU307=$(echo "select concat(\"  \", count(*)) as \"- EST Upload:\" from est"|mysql -p$dbpass -u $mysqluser $xGDB)
      msgU307=" ESTs are being splice-aligned to genomic sequence using GeneSeqer"
      echo "$space$countU307$msgU307$dateTimeU307 (U3.07)">>$WorkDIR/logs/Pipeline_procedure.log
      echo "${space}GSQ parameter set is $GSQparameter (U3.07)" >>$WorkDIR/logs/Pipeline_procedure.log
      
      /xGDBvm/scripts/SplitMakeArrayGSQ.pl $tmpWorkDIR/data/GSQ/MRNADIR/${xGDB}est.fa 70 $tmpWorkDIR/data/GSQ/SCFDIR/${xGDB}gdna.fa "$GSQparameter" $GSQ_CompResources  # Output will be sent to $tmpWorkDIR/data/GSQ/GSQOUT/${xGDB}est.gsq
      
      countU3075=$(grep -c "MATCH" $tmpWorkDIR/data/GSQ/GSQOUT/${xGDB}est.gsq)
      msgU3075=" EST spliced alignments (not filtered for quality) completed and sent to GSQ output directory $tmpWorkDIR/data/GSQ/GSQOUT/${xGDB}est.gsq "
      echo "$space$countU3075$msgU3075$dateTimeU3075 (U3.075)">>$WorkDIR/logs/Pipeline_procedure.log
      
      ## End of if loop for precomputed alignments
   fi
   ## U3.08 Parse and load GeneSeqer results to MySQL
   
   ## XXXXtest first copy the GeneSeqer output file from scratch directory over to Working GSQOUT directory (4-24-13 trying to debug; for some reason sql upload was failing)
   
   ###test  cp $tmpWorkDIR/data/GSQ/GSQOUT/${xGDB}est.gsq ${WorkDIR}/data/GSQ/GSQOUT/${xGDB}est.gsq
   
   ## Now create .sql load file
   
   dateTimeU308=$(date +%Y-%m-%d\ %k:%M:%S)
   msgU308="Parsing GSQ output to MySQL load file (using quality threshold) ${tmpWorkDIR}/data/XGDB_MYSQL/newE_${xGDB}gseg_est_good_pgs.sql"
   echo "${space}$msgU308$dateTimeU308 (U3.08)" >>$WorkDIR/logs/Pipeline_procedure.log
   
   $ScriptDIR/xGDBload_PgsFromGSQ.pl -t gseg_est_good_pgs ${tmpWorkDIR}/data/GSQ/GSQOUT/${xGDB}est.gsq >${tmpWorkDIR}/data/XGDB_MYSQL/newE_${xGDB}gseg_est_good_pgs.sql
   
   ## Flag if file is empty. 
   if [ -s ${tmpWorkDIR}/data/XGDB_MYSQL/new_${xGDB}est.sql ]
   then
      echo "${space}NOTE: Output at ${WorkDIR}/data/XGDB_MYSQL/new_${xGDB}est.sql is empty (U5.032) ">>$WorkDIR/logs/Pipeline_procedure.log 
   fi
   
   ## Now go ahead and upload the data to MySQL:
   mysql -p$dbpass -u $mysqluser $xGDB < ${tmpWorkDIR}/data/XGDB_MYSQL/newE_${xGDB}gseg_est_good_pgs.sql
   
   dateTimeU3085=$(date +%Y-%m-%d\ %k:%M:%S)
   countU3085a=$(grep -c "gseg_est_good_pgs " $tmpWorkDIR/data/XGDB_MYSQL/newE_${xGDB}gseg_est_good_pgs.sql) # Counts New or Updated records inserted into this table (trailing space important!)
   countU3085b=$(echo "select count(*) from gseg_est_good_pgs"|mysql -p$dbpass -u $mysqluser $xGDB) # Total records after update
   msgU3085=" new EST alignments are now in $xGDB gseg_est_good_pgs table "
   echo "${space}${countU3085a} new EST alignments were loaded into $xGDB gseg_est_good_pgs (out of $countU3085b total). $dateTimeU3085 (U3.085)" >>$WorkDIR/logs/Pipeline_procedure.log
   SPLICEALIGN="T" # flag for CpGAT  FIXME add test to be sure sequences were added.

   
   ## U3.09 Mark cognates and clonepairs
   $ScriptDIR/xGDB_markCognate.pl -T 'gseg_est_good_pgs' -P $dbpass -U $mysqluser -D $xGDB
   $ScriptDIR/xGDB_markESTprimality.sh "-p$dbpass -u $mysqluser $xGDB"
   $ScriptDIR/xGDB_markClonePairs.pl -T 'est' -D $xGDB -P $dbpass -U $mysqluser --loadDB 1
   echo "${space}Clonepairs and cognates are marked and loaded to MySQL (U3.09)" >>$WorkDIR/logs/Pipeline_procedure.log
   
   ## U3.10 Move data from scratch to output directory, and clean up (remove scratch directory)
   
   mv ${tmpWorkDIR}/data/XGDB_MYSQL/newE_${xGDB}gseg_est_good_pgs.sql ${WorkDIR}/data/XGDB_MYSQL/newE_${xGDB}gseg_est_good_pgs.sql
   mv ${tmpWorkDIR}/data/download/new_${xGDB}est.fa ${WorkDIR}/data/download/new_${xGDB}est.fa
   mv ${tmpWorkDIR}/data/GSQ/GSQOUT/${xGDB}est.gsq ${WorkDIR}/data/GSQ/GSQOUT/newE_${xGDB}est.gsq
   mv ${tmpWorkDIR}/data/GSQ/MRNADIR ${WorkDIR}/data/GSQ/MRNADIR/NEW_EST   #If updating not replacing, old EST and index will still be preserved.
   
   rm -rf $tmpWorkDIR/data
   
   echo "${space}Temp directory removed (U3.01)" >>$WorkDIR/logs/Pipeline_procedure.log
   
   dateTimeU399=$(date +%Y-%m-%d\ %k:%M:%S)
   msgU399="* Step U3 completed. "
   echo "$space$msgU399$dateTimeU399" >>$WorkDIR/logs/Pipeline_procedure.log
}

##############################################################
# Step U4: add cDNA sequences /spliced alignments #
##############################################################

## Note - if the user has selected "Replace cDNA" (Step U10), the current step (U4) is called next, after the tables have been dropped and BLAST index removed.

addCDNA () {
   
   
   dateTimeU400=$(date +%Y-%m-%d\ %k:%M:%S)
   msgU400="| Step U4: Add cDNA sequences. "
   echo "$dline" >>$WorkDIR/logs/Pipeline_procedure.log
   echo "$msgU400$dateTimeU400" >>$WorkDIR/logs/Pipeline_procedure.log
   echo "$dline" >>$WorkDIR/logs/Pipeline_procedure.log
   
   mkdir $tmpWorkDIR
   mkdir $tmpWorkDIR/data
   mkdir $tmpWorkDIR/data/GSQ
   mkdir $tmpWorkDIR/data/GSQ/MRNADIR
   mkdir $tmpWorkDIR/data/GSQ/GSQOUT
   mkdir $tmpWorkDIR/data/GSQ/SCFDIR
   mkdir $tmpWorkDIR/data/download
   mkdir $tmpWorkDIR/data/XGDB_MYSQL
   
   ## U4.01a concatenate and copy update update cDNA sequences to tmp download directory as "new"
   cat $newDataPath/*cdna.fa >${tmpWorkDIR}/data/download/new_${xGDB}cdna.fa
   ## U4.01b concatenate and copy update update cDNA sequences,  cat together with existing cDNA in (non-tmp) BLAST directory as "new"
   cat $newDataPath/*cdna.fa ${WorkDIR}/data/BLAST/${xGDB}cdna.fa >${WorkDIR}/data/BLAST/new_${xGDB}cdna.fa
   
   countU401=$(grep -c "^>" ${tmpWorkDIR}/data/download/new_${xGDB}cdna.fa)
   echo "$space$countU401 new cDNA sequences are being added (U4.01)" >>$WorkDIR/logs/Pipeline_procedure.log
   
   dateTimeU401=$(date +%Y-%m-%d\ %k:%M:%S)
   filecountU401=$(ls $newDataPath/*cdna.fa*|wc -l)
   msgU401=" fasta file(s) containing cDNA sequences copied to scratch directories (BLAST and download) as new_${xGDB}cdna.fa "
   echo "$space$filecountU401$msgU401 $dateTimeU401 (U4.01)" >>$WorkDIR/logs/Pipeline_procedure.log
   
   ## U4.02 rename newGDBnnncdna to GDBnnncdna in BLAST directory (this is a combo of new and old sequences) and make blast index (this is all done on the destination disk)
   mv ${WorkDIR}/data/BLAST/new_${xGDB}cdna.fa ${WorkDIR}/data/BLAST/${xGDB}cdna.fa
   /usr/local/bin/makeblastdb -in ${WorkDIR}/data/BLAST/${xGDB}cdna.fa -dbtype nucl -parse_seqids -out ${WorkDIR}/data/BLAST/${xGDB}cdna.fa
   
   ## U4.03 Load new cdna sequences to MySQL (if this table already populated, the new data will be appended)
   ## First parse cDNA sequence data to .sql load file
   
   echo "${space}Parsing cDNA sequence records to ${tmpWorkDIR}/data/XGDB_MYSQL/new_${xGDB}cdna.sql (U4.031)">>$WorkDIR/logs/Pipeline_procedure.log
   
   $ScriptDIR/xGDBload_SeqFromFasta.pl cdna ${tmpWorkDIR}/data/download/new_${xGDB}cdna.fa >${tmpWorkDIR}/data/XGDB_MYSQL/new_${xGDB}cdna.sql
   
   ## Now go ahead and upload the data to MySQL:
   mysql -p$dbpass -u $mysqluser $xGDB < ${tmpWorkDIR}/data/XGDB_MYSQL/new_${xGDB}cdna.sql
   
   countU403=$(echo "select concat(\"  \", count(*)) as \"- cDNA Upload:\" from cdna"|mysql -p$dbpass -u $mysqluser $xGDB)
   msgU403=" cDNA sequences were loaded to $xGDB cdna table (U4.033)"
   echo "$space$countU403$msgU403" >>$WorkDIR/logs/Pipeline_procedure.log
   
   ## U4.04 Copy the new cDNA sequence to GSQ mRNA directory for spliced alignment.
   echo "${space}Copying new cDNA sequence to (tmp) /GSQ/MNRNADIR/ (U4.04)">>$WorkDIR/logs/Pipeline_procedure.log
   
   cp ${tmpWorkDIR}/data/download/new_${xGDB}cdna.fa $tmpWorkDIR/data/GSQ/MRNADIR/${xGDB}cdna.fa
   
   ## U4.05 concatenate and copy scaffold sequence to (tmp) GSQ scaffold directory
   
   # If repeat mask genome exists, use that one.
   if ls -1 ${WorkDIR}/data/BLAST/${xGDB}gdna.rm.fa >/dev/null 2>&1
   then
      cp ${WorkDIR}/data/BLAST/${xGDB}gdna.rm.fa $tmpWorkDIR/data/GSQ/SCFDIR/${xGDB}gdna.fa
      echo "${space}Copied repeat masked genome to $tmpWorkDIR/data/GSQ/SCFDIR/${xGDB}gdna.fa (U4.05)">>$WorkDIR/logs/Pipeline_procedure.log
   else
      cp ${WorkDIR}/data/BLAST/${xGDB}gdna.fa $tmpWorkDIR/data/GSQ/SCFDIR/${xGDB}gdna.fa
      echo "${space}Copied (unmasked) genome to $tmpWorkDIR/data/GSQ/SCFDIR/${xGDB}gdna.fa (U4.05)">>$WorkDIR/logs/Pipeline_procedure.log
   fi
      
   ## U4.06 If precomputed GSQ outputs are present in user's Update Data Directory, copy to appropriate (tmp) working directory and skip GSQ spliced alignment.
   
   # cDNA precomputed output already exists? Then copy it to (tmp) GSQOUT directory and place a copy in (final) download directory (as NEW)
   if ls -1 $newDataPath/*cdna.gsq >/dev/null 2>&1
   then
      
      echo "${space}GSQ pre-computed output exists. Copying to scratch directory for parsing (U4.061)">>$WorkDIR/logs/Pipeline_procedure.log
      
      cat $newDataPath/*cdna.gsq >$WorkDIR/data/download/new_${xGDB}cdna.gsq
      
      cat $newDataPath/*cdna.gsq >$tmpWorkDIR/data/GSQ/GSQOUT/${xGDB}cdna.gsq
      
      dateTimeU4062=$(date +%Y-%m-%d\ %k:%M:%S)
      countU4062=$(grep -c "MATCH" $tmpWorkDIR/data/GSQ/GSQOUT/${xGDB}cdna.gsq)
      msgU4062=" precomputed cDNA spliced alignments copied to GSQ output directory $tmpWorkDIR/data/GSQ/GSQOUT/${xGDB}cdna.gsq: "
      echo "$space$countU4062$msgU4062$dateTimeU4062 (U4.062)">>$WorkDIR/logs/Pipeline_procedure.log
      echo "${space}Skipping GeneSeqer spliced alignment, jumping to U4.08">>$WorkDIR/logs/Pipeline_procedure.log
   else
      
      ## If no user-provided GeneSeqer output files, initiates SplitMakeArrayGSQ.pl (parses input, makes index, initiates GeneSeqer), deposits output in working directory
      
      ## U4.07 Split and run GeneSeqer on scratch directory
      
      countU407=$(echo "select concat(\"  \", count(*)) as \"- cDNA Upload:\" from cdna"|mysql -p$dbpass -u $mysqluser $xGDB)
      msgU407=" cDNAs are being splice-aligned to genomic sequence using GeneSeqer"
      echo "$space$countU407$msgU407$dateTimeU407 (U4.07)">>$WorkDIR/logs/Pipeline_procedure.log
      echo "${space}GSQ parameter set is $GSQparameter (U4.07)" >>$WorkDIR/logs/Pipeline_procedure.log
      
      /xGDBvm/scripts/SplitMakeArrayGSQ.pl $tmpWorkDIR/data/GSQ/MRNADIR/${xGDB}cdna.fa 70 $tmpWorkDIR/data/GSQ/SCFDIR/${xGDB}gdna.fa "$GSQparameter" $GSQ_CompResources  # Output will be sent to $tmpWorkDIR/data/GSQ/GSQOUT/${xGDB}cdna.gsq
      
      countU4075=$(grep -c "MATCH" $tmpWorkDIR/data/GSQ/GSQOUT/${xGDB}cdna.gsq)
      msgU4075=" cDNA spliced alignments (not filtered for quality) completed and sent to GSQ output directory $tmpWorkDIR/data/GSQ/GSQOUT/${xGDB}cdna.gsq "
      echo "$space$countU4075$msgU4075$dateTimeU4075 (U4.075)">>$WorkDIR/logs/Pipeline_procedure.log
      
      ## End of if loop for precomputed alignments
   fi
   ## U4.08 Parse and load GeneSeqer results to MySQL
   
   ## XXXXtest first copy the GeneSeqer output file from scratch directory over to Working GSQOUT directory (4-24-13 trying to debug; for some reason sql upload was failing)
   
   ###test  cp $tmpWorkDIR/data/GSQ/GSQOUT/${xGDB}cdna.gsq ${WorkDIR}/data/GSQ/GSQOUT/${xGDB}cdna.gsq
   
   ## Now create .sql load file
   
   dateTimeU408=$(date +%Y-%m-%d\ %k:%M:%S)
   msgU408="Parsing GSQ output to MySQL load file (using quality threshold) ${tmpWorkDIR}/data/XGDB_MYSQL/newC_${xGDB}gseg_cdna_good_pgs.sql"
   echo "${space}$msgU408$dateTimeU408 (U4.08)" >>$WorkDIR/logs/Pipeline_procedure.log
   
   $ScriptDIR/xGDBload_PgsFromGSQ.pl -t gseg_cdna_good_pgs ${tmpWorkDIR}/data/GSQ/GSQOUT/${xGDB}cdna.gsq >${tmpWorkDIR}/data/XGDB_MYSQL/newC_${xGDB}gseg_cdna_good_pgs.sql


   ## Flag if file is empty. 
   if [ -s ${tmpWorkDIR}/data/XGDB_MYSQL/new_${xGDB}cdna.sql ]
   then
      echo "${space}NOTE: Output at ${WorkDIR}/data/XGDB_MYSQL/new_${xGDB}cdna.sql is empty (U5.032) ">>$WorkDIR/logs/Pipeline_procedure.log 
   fi
   ## Now go ahead and upload the data to MySQL:
   mysql -p$dbpass -u $mysqluser $xGDB < ${tmpWorkDIR}/data/XGDB_MYSQL/newC_${xGDB}gseg_cdna_good_pgs.sql
   
   dateTimeU4085=$(date +%Y-%m-%d\ %k:%M:%S)
   countU4085a=$(grep -c "gseg_cdna_good_pgs " $tmpWorkDIR/data/XGDB_MYSQL/newC_${xGDB}gseg_cdna_good_pgs.sql) # Counts New or Updated records inserted into this table (trailing space important!)
   countU4085b=$(echo "select count(*) from gseg_cdna_good_pgs"|mysql -p$dbpass -u $mysqluser -N $xGDB)  # Total records in this table after update
   msgU4085=" new cDNA alignments are now in $xGDB gseg_cdna_good_pgs table "
   echo "${space}${countU4085a} new cDNA alignments were loaded into $xGDB gseg_cdna_good_pgs (out of $countU4085b total). $dateTimeU4085 (U4.085)" >>$WorkDIR/logs/Pipeline_procedure.log
   SPLICEALIGN="T" # flag for CpGAT

   ## U4.09 Mark cognates
   $ScriptDIR/xGDB_markCognate.pl -T 'gseg_cdna_good_pgs' -P $dbpass -U $mysqluser -D $xGDB
   echo "${space}Cognates are marked and loaded to MySQL (U4.09)" >>$WorkDIR/logs/Pipeline_procedure.log
   
   ## U4.10 Move data from scratch to output directory, and clean up (remove scratch directory)
   
   mv ${tmpWorkDIR}/data/XGDB_MYSQL/newC_${xGDB}gseg_cdna_good_pgs.sql ${WorkDIR}/data/XGDB_MYSQL/newC_${xGDB}gseg_cdna_good_pgs.sql
   mv ${tmpWorkDIR}/data/download/new_${xGDB}cdna.fa ${WorkDIR}/data/download/new_${xGDB}cdna.fa
   mv ${tmpWorkDIR}/data/GSQ/GSQOUT/${xGDB}cdna.gsq ${WorkDIR}/data/GSQ/GSQOUT/newC_${xGDB}cdna.gsq
   mv ${tmpWorkDIR}/data/GSQ/MRNADIR ${WorkDIR}/data/GSQ/MRNADIR/NEW_CDNA   #If updating not replacing, old cDNA and index will still be preserved.
   
   rm -rf $tmpWorkDIR/data
   
   echo "${space}Temp directory removed (U4.01)" >>$WorkDIR/logs/Pipeline_procedure.log
   
   dateTimeU499=$(date +%Y-%m-%d\ %k:%M:%S)
   msgU499="* Step U4 completed. "
   echo "$space$msgU499$dateTimeU499" >>$WorkDIR/logs/Pipeline_procedure.log
}

##############################################################
# Step U5. Add TSA sequences  /spliced alignments            #
##############################################################

## Note - if the user has selected "Rplace TSA" (Step U11), the current step (U5) is called next, after the tables have been dropped and BLAST index removed.

addTSA () {
   
   
   dateTimeU500=$(date +%Y-%m-%d\ %k:%M:%S)
   msgU500="| Step U5: Add TSA sequences. "
   echo "$dline" >>$WorkDIR/logs/Pipeline_procedure.log
   echo "$msgU500$dateTimeU500" >>$WorkDIR/logs/Pipeline_procedure.log
   echo "$dline" >>$WorkDIR/logs/Pipeline_procedure.log
   
   mkdir $tmpWorkDIR
   mkdir $tmpWorkDIR/data
   mkdir $tmpWorkDIR/data/GSQ
   mkdir $tmpWorkDIR/data/GSQ/PUTDIR
   mkdir $tmpWorkDIR/data/GSQ/GSQOUT
   mkdir $tmpWorkDIR/data/GSQ/SCFDIR
   mkdir $tmpWorkDIR/data/download
   mkdir $tmpWorkDIR/data/XGDB_MYSQL
   
   ## U5.01a concatenate and copy update update TSA sequences to tmp download directory as "new"
   cat $newDataPath/*tsa.fa >${tmpWorkDIR}/data/download/new_${xGDB}tsa.fa
   ## U5.01b concatenate and copy update update TSA sequences,  cat together with existing TSA in (non-tmp) BLAST directory as "new"
   cat $newDataPath/*tsa.fa ${WorkDIR}/data/BLAST/${xGDB}tsa.fa >${WorkDIR}/data/BLAST/new_${xGDB}tsa.fa
   
   countU501=$(grep -c "^>" ${tmpWorkDIR}/data/download/new_${xGDB}tsa)
   echo "$space$countU501 new TSA sequences are being added (U5.01)" >>$WorkDIR/logs/Pipeline_procedure.log
   
   dateTimeU501=$(date +%Y-%m-%d\ %k:%M:%S)
   filecountU501=$(ls $newDataPath/*tsa.fa*|wc -l)
   msgU501=" fasta file(s) containing TSA sequences copied to scratch directories (BLAST and download) as  ${tmpWorkDIR}/data/BLAST/new_${xGDB}tsa"
   echo "$space$filecountU501$msgU501 $dateTimeU501 (U5.01)" >>$WorkDIR/logs/Pipeline_procedure.log
   
   ## U5.02 rename newGDBnnncdna to GDBnnncdna in BLAST directory (this is a combo of new and old sequences) and make blast index (this is all done on the destination disk)
   mv ${WorkDIR}/data/BLAST/new_${xGDB}tsa.fa ${WorkDIR}/data/BLAST/${xGDB}tsa.fa
   /usr/local/bin/makeblastdb -in ${WorkDIR}/data/BLAST/${xGDB}tsa.fa -dbtype nucl -parse_seqids -out ${WorkDIR}/data/BLAST/${xGDB}tsa.fa
   
   ## U5.03 Load new tsa sequences to MySQL (if this table already populated, the new data will be appended)
   ## First parse TSA sequence data to .sql load file
   
   echo "${space}Parsing TSA sequence records to ${tmpWorkDIR}/data/XGDB_MYSQL/new_${xGDB}tsa.sql (U5.031)">>$WorkDIR/logs/Pipeline_procedure.log
   
   $ScriptDIR/xGDBload_SeqFromFasta.pl tsa ${tmpWorkDIR}/data/download/new_${xGDB}tsa.fa >${tmpWorkDIR}/data/XGDB_MYSQL/new_${xGDB}tsa.sql
   
   ## Flag if file is empty. 
   if [ -s ${tmpWorkDIR}/data/XGDB_MYSQL/new_${xGDB}tsa.sql ]
   then
      echo "${space}NOTE: Output at ${WorkDIR}/data/XGDB_MYSQL/new_${xGDB}tsa.sql is empty (U5.032) ">>$WorkDIR/logs/Pipeline_procedure.log 
   fi
   
   ## Now go ahead and upload the data to MySQL:
   mysql -p$dbpass -u $mysqluser $xGDB < ${tmpWorkDIR}/data/XGDB_MYSQL/new_${xGDB}tsa.sql
   
   countU503=$(echo "select concat(\"  \", count(*)) as \"- TSA Upload:\" from tsa"|mysql -p$dbpass -u $mysqluser $xGDB)
   msgU503=" TSA sequences were loaded to $xGDB put table (U5.033)"
   echo "$space$countU503$msgU503" >>$WorkDIR/logs/Pipeline_procedure.log
   
   ## U5.04 Copy the new TSA sequence to GSQ mRNA directory for spliced alignment.
   echo "${space}Copying new TSA sequence to (tmp) /GSQ/PUTDIR/ (U5.04)">>$WorkDIR/logs/Pipeline_procedure.log
   
   cp ${tmpWorkDIR}/data/download/new_${xGDB}tsa.fa $tmpWorkDIR/data/GSQ/PUTDIR/${xGDB}tsa.fa
   
   ## U5.05 concatenate and copy scaffold sequence to (tmp) GSQ scaffold directory   
   
   # If repeat mask genome exists, use that one.
   if ls -1 ${WorkDIR}/data/BLAST/${xGDB}gdna.rm.fa >/dev/null 2>&1
   then
      cp ${WorkDIR}/data/BLAST/${xGDB}gdna.rm.fa $tmpWorkDIR/data/GSQ/SCFDIR/${xGDB}gdna.fa
      echo "${space}Copied repeat masked genome to $tmpWorkDIR/data/GSQ/SCFDIR/${xGDB}gdna.fa (U5.05)">>$WorkDIR/logs/Pipeline_procedure.log
   else
      cp ${WorkDIR}/data/BLAST/${xGDB}gdna.fa $tmpWorkDIR/data/GSQ/SCFDIR/${xGDB}gdna.fa
      echo "${space}Copied (unmasked) genome to $tmpWorkDIR/data/GSQ/SCFDIR/${xGDB}gdna.fa (U5.05)">>$WorkDIR/logs/Pipeline_procedure.log
   fi
   
   ## U5.06 If precomputed GSQ outputs are present in user's Update Data Directory, copy to appropriate (tmp) working directory and skip GSQ spliced alignment.
   
   # TSA precomputed output already exists? Then copy it to (tmp) GSQOUT directory and place a copy in (final) download directory (as NEW)
   if ls -1 $newDataPath/*tsa.gsq >/dev/null 2>&1
   then
      
      echo "${space}GSQ pre-computed output exists. Copying to scratch directory for parsing (U5.061)">>$WorkDIR/logs/Pipeline_procedure.log
      
      cat $newDataPath/*tsa.gsq >$WorkDIR/data/download/new_${xGDB}tsa.gsq
      
      cat $newDataPath/*tsa.gsq >$tmpWorkDIR/data/GSQ/GSQOUT/${xGDB}tsa.gsq
      
      dateTimeU5062=$(date +%Y-%m-%d\ %k:%M:%S)
      countU5062=$(grep -c "MATCH" $tmpWorkDIR/data/GSQ/GSQOUT/${xGDB}tsa.gsq)
      msgU5062=" precomputed TSA spliced alignments copied to GSQ output directory $tmpWorkDIR/data/GSQ/GSQOUT/${xGDB}tsa.gsq: "
      echo "$space$countU5062$msgU5062$dateTimeU5062 (U5.062)">>$WorkDIR/logs/Pipeline_procedure.log
      echo "${space}Skipping GeneSeqer spliced alignment, jumping to U5.08">>$WorkDIR/logs/Pipeline_procedure.log
   else
      
      ## If no user-provided GeneSeqer output files, initiates SplitMakeArrayGSQ.pl (parses input, makes index, initiates GeneSeqer), deposits output in working directory
      
      ## U5.07 Split and run GeneSeqer on scratch directory
      
      countU507=$(echo "select concat(\"  \", count(*)) as \"- TSA Upload:\" from tsa"|mysql -p$dbpass -u $mysqluser $xGDB)
      msgU507=" TSAs are being splice-aligned to genomic sequence using GeneSeqer"
      echo "$space$countU507$msgU507$dateTimeU507 (U5.07)">>$WorkDIR/logs/Pipeline_procedure.log
      echo "${space}GSQ parameter set is $GSQparameter (U5.07)" >>$WorkDIR/logs/Pipeline_procedure.log
      
      /xGDBvm/scripts/SplitMakeArrayGSQ.pl $tmpWorkDIR/data/GSQ/PUTDIR/${xGDB}tsa.fa 70 $tmpWorkDIR/data/GSQ/SCFDIR/${xGDB}gdna.fa "$GSQparameter" $GSQ_CompResources  # Output will be sent to $tmpWorkDIR/data/GSQ/GSQOUT/${xGDB}tsa.gsq
      
      countU5075=$(grep -c "MATCH" $tmpWorkDIR/data/GSQ/GSQOUT/${xGDB}tsa.gsq)
      msgU5075=" TSA spliced alignments (not filtered for quality) completed and sent to GSQ output directory $tmpWorkDIR/data/GSQ/GSQOUT/${xGDB}tsa.gsq "
      echo "$space$countU5075$msgU5075$dateTimeU5075 (U5.075)">>$WorkDIR/logs/Pipeline_procedure.log
      
      ## End of if loop for precomputed alignments
   fi
   ## U5.08 Parse and load GeneSeqer results to MySQL
   
   ## XXXXtest first copy the GeneSeqer output file from scratch directory over to Working GSQOUT directory (4-24-13 trying to debug; for some reason sql upload was failing)
   
   ###test  cp $tmpWorkDIR/data/GSQ/GSQOUT/${xGDB}tsa.gsq ${WorkDIR}/data/GSQ/GSQOUT/${xGDB}tsa.gsq
   
   ## Now create .sql load file
   
   dateTimeU508=$(date +%Y-%m-%d\ %k:%M:%S)
   msgU508="Parsing GSQ output to MySQL load file (using quality threshold) ${tmpWorkDIR}/data/XGDB_MYSQL/newT_${xGDB}gseg_put_good_pgs.sql"
   echo "${space}$msgU508$dateTimeU508 (U5.08)" >>$WorkDIR/logs/Pipeline_procedure.log
   
   $ScriptDIR/xGDBload_PgsFromGSQ.pl -t gseg_put_good_pgs ${tmpWorkDIR}/data/GSQ/GSQOUT/${xGDB}tsa.gsq >${tmpWorkDIR}/data/XGDB_MYSQL/newT_${xGDB}gseg_put_good_pgs.sql
   
   ## Added 4/24/13: the mysql load step below was failing to execute with large datasets so I'm testing a wait loop.
   
   while [ ! -s ${tmpWorkDIR}/data/XGDB_MYSQL/newT_${xGDB}gseg_put_good_pgs.sql ] ;
   do
      echo "${space}Waiting for output at ${tmpWorkDIR}/data/XGDB_MYSQL/newT_${xGDB}gseg_put_good_pgs.sql (U5.082)">>$WorkDIR/logs/Pipeline_procedure.log
      sleep 10
      
   done
   ## Now go ahead and upload the data to MySQL:
   mysql -p$dbpass -u $mysqluser $xGDB < ${tmpWorkDIR}/data/XGDB_MYSQL/newT_${xGDB}gseg_put_good_pgs.sql
   
   dateTimeU5085=$(date +%Y-%m-%d\ %k:%M:%S)
   countU5085a=$(grep -c "gseg_put_good_pgs " $tmpWorkDIR/data/XGDB_MYSQL/newT_${xGDB}gseg_put_good_pgs.sql) # Counts New or Updated records inserted into this table (trailing space important!)
   countU5085b=$(echo "select count(*) from gseg_put_good_pgs"|mysql -p$dbpass -u $mysqluser -N $xGDB) # Total after update
   msgU5085=" new TSA alignments are now in $xGDB gseg_put_good_pgs table "
   echo "${space}${countU5085a} new TSA alignments were loaded into $xGDB gseg_put_good_pgs (out of $countU5085b total). $dateTimeU5085 (U5.085)" >>$WorkDIR/logs/Pipeline_procedure.log
   SPLICEALIGN="T" # flag for CpGAT
   
   ## U5.09 Mark cognates (Not applicable to TSA)
   
   ## U5.10 Move data from scratch to output directory, and clean up (remove scratch directory)
   
   mv ${tmpWorkDIR}/data/XGDB_MYSQL/newT_${xGDB}gseg_put_good_pgs.sql ${WorkDIR}/data/XGDB_MYSQL/newT_${xGDB}gseg_put_good_pgs.sql
   mv ${tmpWorkDIR}/data/download/new_${xGDB}tsa.fa ${WorkDIR}/data/download/new_${xGDB}tsa.fa
   mv ${tmpWorkDIR}/data/GSQ/GSQOUT/${xGDB}tsa.gsq ${WorkDIR}/data/GSQ/GSQOUT/newT_${xGDB}tsa.gsq
   mv ${tmpWorkDIR}/data/GSQ/PUTDIR ${WorkDIR}/data/GSQ/PUTDIR/NEW_TSA   #If updating not replacing, old TSA and index will still be preserved.
   
   rm -rf $tmpWorkDIR/data
   
   echo "${space}Temp directory removed (U5.01)" >>$WorkDIR/logs/Pipeline_procedure.log
   
   dateTimeU599=$(date +%Y-%m-%d\ %k:%M:%S)
   msgU599="* Step U5 completed. "
   echo "$space$msgU599$dateTimeU599" >>$WorkDIR/logs/Pipeline_procedure.log
}
############################################################################################################
# Step U6: add reference protein sequences and splice-align them to genome (or load spliced-alignment data)#
############################################################################################################
## ONLY splice-align new proteins, but include any new gdna added during this update
## NOTE: If ReplacePROTEIN (U8) was selected, this script went there first and deleted existing set, then came here.
addPROTEIN () {
   
   nbproc=`cat /proc/cpuinfo | grep processor | wc -l`
   dateTimeU600=$(date +%Y-%m-%d\ %k:%M:%S)
   msgU600="| Step U6: Add NEW protein sequences. "
   echo "$dline" >>$WorkDIR/logs/Pipeline_procedure.log
   echo "$msgU600$dateTimeU600" >>$WorkDIR/logs/Pipeline_procedure.log
   echo "$dline" >>$WorkDIR/logs/Pipeline_procedure.log
   
   ## U6.01 Make directories under scratch directory at /xGDBvm/data/scratch/GDBnnn/
   
   mkdir $tmpWorkDIR
   mkdir $tmpWorkDIR/data
   mkdir $tmpWorkDIR/data/GTH
   mkdir $tmpWorkDIR/data/GTH/Protein
   mkdir $tmpWorkDIR/data/GTH/GTHOUT
   mkdir $tmpWorkDIR/data/GTH/SCFDIR
   protdirU601=$(ls $tmpWorkDIR)
   echo "${space}GTH working directories created under $protdirU601  (U6.01)" >>$WorkDIR/logs/Pipeline_procedure.log
   
   ## U6.02 Copy genome sequence from /xGDBvm/data/GDBnnn/data/BLAST/ to scratch GTH scaffold directory (NOTE this INCLUDES any newly-added genome scaffolds from Step 19-U.
   cp ${WorkDIR}/data/BLAST/${xGDB}gdna.fa $tmpWorkDIR/data/GTH/SCFDIR/
   dateTimeU602=$(date +%Y-%m-%d\ %k:%M:%S)
   #        countU602=$(grep -c "^>" ${WorkDIR}/data/BLAST/${xGDB}gdna.fa)
   countU602=$(grep -c "^>" $tmpWorkDIR/data/GTH/SCFDIR/${xGDB}gdna.fa) #test if dest exists
   echo "$space$countU602 total genome sequences (old +any NEW) copied to GTH working scaffold directory $tmpWorkDIR/data/GTH/SCFDIR/ $dateTimeU602 (U6.02)" >>$WorkDIR/logs/Pipeline_procedure.log
   
   ## U6.03 Concatenate new protein files and copy output to scratch GTH protein directory (NEW only), FIXME doesn't work.
   
   cat $newDataPath/*prot.fa >$tmpWorkDIR/data/GTH/Protein/${xGDB}prot.fa
   
   dateTimeU603=$(date +%Y-%m-%d\ %k:%M:%S)
   countU603=$(grep -c "^>" $tmpWorkDIR/data/GTH/Protein/${xGDB}prot.fa)
   echo "$space$countU603 new protein sequences copied to GTH working Protein directory $tmpWorkDIR/data/GTH/Protein/${xGDB}prot.fa) $dateTimeU603 (U6.03)" >>$WorkDIR/logs/Pipeline_procedure.log
   
   ## U6.04 Concatenate new protein files and copy to existing download directory (as NEW, alongside OLD, if not deleted)
   
   cat $newDataPath/*prot.fa >${WorkDIR}/data/download/new_${xGDB}prot.fa
   
   dateTimeU604=$(date +%Y-%m-%d\ %k:%M:%S)
   countU604=$(grep -c "^>" ${WorkDIR}/data/download/new_${xGDB}prot.fa)
   echo "$space$countU604 new protein sequences copied to download directory ${WorkDIR}/data/download/new_${xGDB}prot.fa as a separate file $dateTimeU604 (U6.04)" >>$WorkDIR/logs/Pipeline_procedure.log
   
   
   ## U6.05 BLAST copy: Concatenate new protein files TOGETHER with existing proteins (if any) in BLAST directory, and create a new_${xGDB}prot.fa file; then rename this to ${xGDB}prot.fa and index for BLAST
   
   cat $newDataPath/*prot.fa ${WorkDIR}/data/BLAST/${xGDB}prot.fa >${WorkDIR}/data/BLAST/new_${xGDB}prot.fa
   mv ${WorkDIR}/data/BLAST/new_${xGDB}prot.fa ${WorkDIR}/data/BLAST/${xGDB}prot.fa
   /usr/local/bin/makeblastdb -in ${WorkDIR}/data/BLAST/${xGDB}prot.fa -dbtype prot -parse_seqids -out ${WorkDIR}/data/BLAST/${xGDB}prot.fa
   
   dateTimeU605=$(date +%Y-%m-%d\ %k:%M:%S)
   countU605=$(grep -c "^>" ${WorkDIR}/data/BLAST/${xGDB}prot.fa)
   msgU605=" total protein sequences are now indexed for BLAST in ${WorkDIR}/data/BLAST/ "
   echo "$space$countU605$msgU605$dateTimeU605 (U6.05)" >>$WorkDIR/logs/Pipeline_procedure.log
   
   ## U6.06 Load combined ${xGDB}prot.fa sequence to MySQL table
   $ScriptDIR/xGDBload_SeqFromFasta.pl pep $tmpWorkDIR/data/GTH/Protein/${xGDB}prot.fa >${WorkDIR}/data/XGDB_MYSQL/new_${xGDB}prot.sql
   mysql -p$dbpass -u $mysqluser $xGDB < ${WorkDIR}/data/XGDB_MYSQL/new_${xGDB}prot.sql
   
   dateTimeU606=$(date +%Y-%m-%d\ %k:%M:%S)
   countU606=$(echo "select concat(\"  \", count(*)) as \"- New Protein Sequence Uploaded to MySQL:\" from pep"|mysql -p$dbpass -u $mysqluser $xGDB)
   msgU606=" total protein sequences are now in updated '$xGDB.pep' table. "
   echo "$countU606$msgU606$dateTimeU606 (U6.06)" >>$WorkDIR/logs/Pipeline_procedure.log
   
   ## Pre-computed Data? ##
        
   ## (U6.065) IF PRECOMPUTED DATA (Does precomputed GTH output already exist, deposited by user?)
   if ls -1 $newDataPath/*prot.gth >/dev/null 2>&1 # if precomputed spliced alignment input file(s)
   then
      echo "${space}Precomputed GTH spliced-alignment file detected, therefore we will bypass GenomeThreader">>$WorkDIR/logs/Pipeline_procedure.log
      ## We have PRECOMPUTED gth data- Concatenate new gth files TOGETHER with (any) existing gth in download, and create a new_${xGDB}prot.fa file; then rename this to ${xGDB}prot.fa
      cat $newDataPath/*prot.gth ${WorkDIR}/data/download/${xGDB}prot.gth >${WorkDIR}/data/download/new_${xGDB}prot.gth
      mv ${WorkDIR}/data/download/new_${xGDB}prot.gth ${WorkDIR}/data/download/${xGDB}prot.gth
      ## Copy the new gth file to scratch GTH directory where it will be grabbed for parsing
      cp $WorkDIR/data/download/${xGDB}prot.gth $tmpWorkDIR/data/GTH/GTHOUT/${xGDB}prot.gth
      dateTimeU6065=$(date +%Y-%m-%d\ %k:%M:%S)
      if [ -s $tmpWorkDIR/data/GTH/GTHOUT/${xGDB}prot.gth ]
      then
         msgU6065="Precomputed protein spliced alignment file copied to GTH scratch directory $tmpWorkDIR/data/GTH/GTHOUT/${xGDB}prot.gth: "
      else
         msgU6065="ERROR: Precomputed protein spliced alignment not found at $tmpWorkDIR/data/GTH/GTHOUT/${xGDB}prot.gth: "
      fi
      echo "${space}${msgU6065}${dateTimeU6065} (U6.065)">>$WorkDIR/logs/Pipeline_procedure.log
      ## Now go to parse and load (6.085)
   else  ## If no precomputed data exist, process input protein data using GenomeThreader 
   
       ## U6.07 GenomeThreader
       dateTimeU607=$(date +%Y-%m-%d\ %k:%M:%S)
       countU607a=$(grep -c "^>" $tmpWorkDIR/data/GTH/SCFDIR/${xGDB}gdna.fa)
       countU607b=$(grep -c "^>" $tmpWorkDIR/data/GTH/Protein/${xGDB}prot.fa)
       echo "- GenomeThreader initiated with $nbproc processors, $countU607a gdna segments, and $countU607b proteins $dateTimeU607 (U6.07)" >>$WorkDIR/logs/Pipeline_procedure.log
       
       if (( $nbproc > 1 ))
       then
          mkdir $tmpWorkDIR/data/GTH/GTHOUT/SPLIT
          cd $tmpWorkDIR/data/GTH/SCFDIR
          /usr/local/bin/fastasplit.pl -i ${xGDB}gdna.fa -n $nbproc -o $tmpWorkDIR/data/GTH/GTHOUT/SPLIT
          cd $tmpWorkDIR/data/GTH/GTHOUT/SPLIT
          i=0
          for g in *; do
            ((i++)); mkdir TMP$i; mv $g TMP$i; cd TMP$i; cp $tmpWorkDIR/data/GTH/Protein/${xGDB}prot.fa ./;
            /usr/local/bin/gth -genomic $g -protein ${xGDB}prot.fa $GTHparameter -o gthout$i &
            cd ..
          done
          wait
          cat TMP*/gthout* > $tmpWorkDIR/data/GTH/GTHOUT/${xGDB}prot.gth
          cd $tmpWorkDIR
       else
          /usr/local/bin/gth -genomic $tmpWorkDIR/data/GTH/SCFDIR/${xGDB}gdna.fa -protein $tmpWorkDIR/data/GTH/Protein/${xGDB}prot.fa $GTHparameter -o $tmpWorkDIR/data/GTH/GTHOUT/${xGDB}prot.gth
       fi
       
       ## U6.08 GenomeThreader Output
       if [ -s $tmpWorkDIR/data/GTH/GTHOUT/${xGDB}prot.gth ]
       then
          countU608=$(grep -c "MATCH" $tmpWorkDIR/data/GTH/GTHOUT/${xGDB}prot.gth)
          msgU608=" protein spliced alignments completed and sent to GTH output directory $tmpWorkDIR/data/GTH/GTHOUT/${xGDB}prot.gth "
          echo "$space$countU608$msgU608$dateTimeU608 (U6.08a)">>$WorkDIR/logs/Pipeline_procedure.log
       else
          msgU608="GenomeThreader protein spliced alignment output is empty at $tmpWorkDIR/data/GTH/GTHOUT/${xGDB}prot.gth"
          echo "$space$msgU608$dateTimeU608 (U6.08b)" >> $WorkDIR/logs/Pipeline_procedure.log
       fi # End GTH loop
   fi  # End Precompute loop
   
   ## U6.085 Parse and load the gth output data (precomputed or pipeline-derived) to MySQL

   dateTimeU6085=$(date +%Y-%m-%d\ %k:%M:%S)
   if [ -s $tmpWorkDIR/data/GTH/GTHOUT/${xGDB}prot.gth ]
   then
      msgU6085="Protein spliced alignment output is being parsed. "
      $ScriptDIR/xGDBload_PgsFromGTH.pl -t 'gseg_pep_good_pgs' $tmpWorkDIR/data/GTH/GTHOUT/${xGDB}prot.gth >$tmpWorkDIR/data/GTH/newP_${xGDB}gseg_pep_good_pgs.sql
      echo "$space$msgU6085$dateTimeU6085 (U6.085)">>$WorkDIR/logs/Pipeline_procedure.log
   else
      msgU6085="ERROR: No new protein spliced alignments are available for parsing. "
      echo "$space$msgU6085$dateTimeU6085 (U6.085)">>$WorkDIR/logs/Pipeline_procedure.log
      echo "$space$msgU6085$dateTimeU6085 (U6.085)">>$WorkDIR/logs/Pipeline_error.log
   fi

   echo "$space$msgU6085$dateTimeU6085 (U6.085)">>$WorkDIR/logs/Pipeline_procedure.log

   dateTimeU609=$(date +%Y-%m-%d\ %k:%M:%S)
   if [ -s $tmpWorkDIR/data/GTH/newP_${xGDB}gseg_pep_good_pgs.sql ]
   then
      msgU609="All new protein spliced alignments were parsed. "
   else
      msgU609="ERROR: No new protein spliced alignments were parsed. "
      echo "$space$msgU609$dateTimeU609 (U6.09)">>$WorkDIR/logs/Pipeline_error.log
   fi
   echo "$space$msgU609$dateTimeU609 (U6.09)">>$WorkDIR/logs/Pipeline_procedure.log
 
   dateTimeU610=$(date +%Y-%m-%d\ %k:%M:%S)
    if [ -s $tmpWorkDIR/data/GTH/newP_${xGDB}gseg_pep_good_pgs.sql ]
   then
      mysql -p$dbpass -u $mysqluser $xGDB < $tmpWorkDIR/data/GTH/newP_${xGDB}gseg_pep_good_pgs.sql
      countU610=$(echo "select concat(\"  \", count(*)) as \"- Protein Alignment Upload:\" from gseg_pep_good_pgs"|mysql -p$dbpass -u $mysqluser $xGDB)
      dateTimeU610=$(date +%Y-%m-%d\ %k:%M:%S)
      msgU610=" Protein spliced alignments are loaded in MySQL table $xGDB.gseg_pep_good_pgs. "
      echo "$countU610$msgU610$dateTimeU610 (U6.10)">>$WorkDIR/logs/Pipeline_procedure.log
      SPLICEALIGN="T" # flag for CpGAT
   mv $tmpWorkDIR/data/GTH/newP_${xGDB}gseg_pep_good_pgs.sql {WorkDIR}/data/XGDB_MYSQL/${xGDB}newP_gseg_pep_good_pgs.sql
   fi

   ## We are done here. Remove scratch directory.
   rm -rf $tmpWorkDIR/data

   dateTimeU699=$(date +%Y-%m-%d\ %k:%M:%S)
   msgU699="* Step U6 completed. "
   echo "$space$msgU699$dateTimeU699" >>$WorkDIR/logs/Pipeline_procedure.log
}


#################################################################
# Step U7a, b. Replace precomputed gene models (GFF3) or CpGAT GFF3 #
#################################################################

ReplaceGFF () {

   dateTimeU700=$(date +%Y-%m-%d\ %k:%M:%S)
   msgU700="| Step U7a: Update GDB: replace GFF3 precomputed gene models. gseg_gene_annotation table truncated. "
   echo "$dline" >>$WorkDIR/logs/Pipeline_procedure.log
   echo "$msgU700$dateTimeU700" >>$WorkDIR/logs/Pipeline_procedure.log
   echo "$dline" >>$WorkDIR/logs/Pipeline_procedure.log
   
   echo "delete from gseg_gene_annotation" |mysql -p$dbpass -u $mysqluser $xGDB

   rm -rf ${WorkDIR}/data/download/${xGDB}annot.gff3
   rm -rf ${WorkDIR}/data/download/${xGDB}annot.pep.fa
   rm -rf ${WorkDIR}/data/download/${xGDB}annot.mrna.fa

   dateTimeU799=$(date +%Y-%m-%d\ %k:%M:%S)
   msgU799="* Step U7 completed. "
   echo "$space$msgU799$dateTimeU799" >>$WorkDIR/logs/Pipeline_procedure.log
}

## script now goes to addGFF() Step U1a


ReplaceCpGATGFF () {
   
## All we are doing here is deleting the old MySQL data, gff file, and supporting fasta.
   dateTimeU7b00=$(date +%Y-%m-%d\ %k:%M:%S)
   msgU7b00="| Step U7b: Update GDB: replace (or new) CpGAT precomputed gene models. cpgat_gene_annotation table truncated. "
   echo "$msgU7b00$dateTimeU7b00" >>$WorkDIR/logs/Pipeline_procedure.log
   
   echo "delete from cpgat_gene_annotation" |mysql -p$dbpass -u $mysqluser $xGDB
   
   rm -rf ${WorkDIR}/data/download/${xGDB}cpgat.gff3
   rm -rf ${WorkDIR}/data/download/${xGDB}cpgat.pep.fa
   rm -rf ${WorkDIR}/data/download/${xGDB}cpgat.mrna.fa

   
   dateTimeU7b99=$(date +%Y-%m-%d\ %k:%M:%S)
   msgU7b99="* Step U7b completed. "
   echo "$space$msgU7b99$dateTimeU7b99" >>$WorkDIR/logs/Pipeline_procedure.log
}

## script now goes to addCpGATGFF() Step U1b

#################################################################################
# Step U8: Replace related-species protein sequences/spliced alignments         #
#################################################################################

ReplacePROTEIN () {
   
# All we are doing here is deleting all previous sequence files and database data.
   
   rm -rf ${WorkDIR}/data/BLAST/${xGDB}prot*  # user wants to replace these
   rm -rf ${WorkDIR}/data/download/${xGDB}prot.gth # user wants to replace these
   
   ## Placeholder for remove spliced alignment file !!!!
   
   echo "delete from pep" |mysql -p$dbpass -u $mysqluser $xGDB
   echo "delete from gseg_pep_good_pgs" |mysql -p$dbpass -u $mysqluser $xGDB
   echo "delete from gseg_pep_good_pgs_exons" |mysql -p$dbpass -u $mysqluser $xGDB
   echo "delete from gseg_pep_good_pgs_introns" |mysql -p$dbpass -u $mysqluser $xGDB
   
   dateTimeU800=$(date +%Y-%m-%d\ %k:%M:%S)
   msgU800="| Step U8: Update GDB: replace related-species proteins: All pep tables truncated. "
   echo "$dline" >>$WorkDIR/logs/Pipeline_procedure.log
   echo "$msgU800$dateTimeU800" >>$WorkDIR/logs/Pipeline_procedure.log
   echo "$dline" >>$WorkDIR/logs/Pipeline_procedure.log
   dateTimeU899=$(date +%Y-%m-%d\ %k:%M:%S)
   msgU899="* Step U8 completed. "
   echo "$space$msgU899$dateTimeU899" >>$WorkDIR/logs/Pipeline_procedure.log
   
   
   ## script now goes to addProtein() -Step U6
   
}

################################################################################
# Step U9: Replace EST sequences/spliced alignments   #
################################################################################


ReplaceEST () {
   
   rm -rf ${WorkDIR}/data/BLAST/${xGDB}est.fa ${WorkDIR}/data/BLAST/${xGDB}est*
   rm -rf ${WorkDIR}/data/download/${xGDB}est.gsq
   rm -rf ${WorkDIR}/data/GSQ/MRNADIR/${xGDB}est.fa ${WorkDIR}/data/GSQ/MRNADIR/${xGDB}est*  # remove all GeneSeqer output files; these will be replaced in step U3
   echo "delete from est" |mysql -p$dbpass -u $mysqluser $xGDB
   echo "delete from gseg_est_good_pgs" |mysql -p$dbpass -u $mysqluser $xGDB
   echo "delete from gseg_est_good_pgs_exons" |mysql -p$dbpass -u $mysqluser $xGDB
   echo "delete from gseg_est_good_pgs_introns" |mysql -p$dbpass -u $mysqluser $xGDB
   
   dateTimeU900=$(date +%Y-%m-%d\ %k:%M:%S)
   msgU900="| Step U9: Replace EST sequences. All est tables truncated, download data, MRNADIR contents and BLAST index removed. "
   echo "$dline" >>$WorkDIR/logs/Pipeline_procedure.log
   echo "$msgU900$dateTimeU900" >>$WorkDIR/logs/Pipeline_procedure.log
   echo "$dline" >>$WorkDIR/logs/Pipeline_procedure.log
   
   dateTimeU999=$(date +%Y-%m-%d\ %k:%M:%S)
   msgU999="* Step U9 completed. Script now goes to Step U3 (Add EST)"
   echo "$space$msgU999$dateTimeU999" >>$WorkDIR/logs/Pipeline_procedure.log
   
}

## script now goes to AddEST() (Step U3)


###################################################################
# Step U10: Replace cDNA sequences/spliced alignments   #
###################################################################

ReplaceCDNA () {
   
   rm -rf ${WorkDIR}/data/BLAST/${xGDB}cdna.fa ${WorkDIR}/data/BLAST/${xGDB}cdna*
   rm -rf ${WorkDIR}/data/GSQ/MRNADIR/${xGDB}cdna.fa ${WorkDIR}/data/GSQ/MRNADIR/${xGDB}cdna*  # remove all GeneSeqer output files; these will be replaced in step U4
   rm -rf ${WorkDIR}/data/download/${xGDB}cdna.gsq
   echo "delete from cdna" |mysql -p$dbpass -u $mysqluser $xGDB
   echo "delete from gseg_cdna_good_pgs" |mysql -p$dbpass -u $mysqluser $xGDB
   echo "delete from gseg_cdna_good_pgs_exons" |mysql -p$dbpass -u $mysqluser $xGDB
   echo "delete from gseg_cdna_good_pgs_introns" |mysql -p$dbpass -u $mysqluser $xGDB
   
   dateTimeU1000=$(date +%Y-%m-%d\ %k:%M:%S)
   msgU1000="| Step U10: Update GDB: replace cDNA sequences. All cdna tables truncated, download data, MRNADIR contents and BLAST index removed "
   echo "$dline" >>$WorkDIR/logs/Pipeline_procedure.log
   echo "$msgU1000$dateTimeU1000" >>$WorkDIR/logs/Pipeline_procedure.log
   echo "$dline" >>$WorkDIR/logs/Pipeline_procedure.log
   
   dateTimeU1099=$(date +%Y-%m-%d\ %k:%M:%S)
   msgU1099="* Step U10 completed. "
   echo "$space$msgU1099$dateTimeU1099" >>$WorkDIR/logs/Pipeline_procedure.log
   
   
}

## script now goes to AddCDNA()

###################################################################
# Step U11: Replace TSA sequences/spliced alignments   #
###################################################################

ReplaceTSA () {
   
   rm -rf ${WorkDIR}/data/BLAST/${xGDB}tsa.fa ${WorkDIR}/data/BLAST/${xGDB}tsa*
   rm -rf ${WorkDIR}/data/GSQ/PUTDIR/${xGDB}tsa.fa ${WorkDIR}/data/GSQ/PUTDIR/${xGDB}tsa*  # remove all GeneSeqer TSA (PUT) output files; these will be replaced in step U5
   rm -rf ${WorkDIR}/data/download/${xGDB}tsa.gsq
   echo "delete from put" |mysql -p$dbpass -u $mysqluser $xGDB
   echo "delete from gseg_put_good_pgs" |mysql -p$dbpass -u $mysqluser $xGDB
   echo "delete from gseg_put_good_pgs_exons" |mysql -p$dbpass -u $mysqluser $xGDB
   echo "delete from gseg_put_good_pgs_introns" |mysql -p$dbpass -u $mysqluser $xGDB
   
   dateTimeU1100=$(date +%Y-%m-%d\ %k:%M:%S)
   msgU1100="| Step U11: Update GDB: replace TSA (a.k.a. PUT) sequences. All put tables truncated. "
   echo "$dline" >>$WorkDIR/logs/Pipeline_procedure.log
   echo "$msgU1100$dateTimeU1100" >>$WorkDIR/logs/Pipeline_procedure.log
   echo "$dline" >>$WorkDIR/logs/Pipeline_procedure.log
   
   dateTimeU1199=$(date +%Y-%m-%d\ %k:%M:%S)
   msgU1199="* Step U11 completed. "
   echo "$space$msgU1199$dateTimeU1199" >>$WorkDIR/logs/Pipeline_procedure.log
   
   ## on return, the script now goes to AddTSA()
}

##############################################################
# Step U12. Replace descriptions - precomputed models       #
##############################################################
# Here we don't need to create a scratch directory. We just replace the old file and copy new file to download directory and parse/load data.

ReplaceDESCP () {
   
   
   
   dateTimeU1200=$(date +%Y-%m-%d\ %k:%M:%S)
   msgU1200="| Step U12: Replace gene descriptions: Precomputed Models "
   echo "$dline" >>$WorkDIR/logs/Pipeline_procedure.log
   echo "$msgU1200$dateTimeU1200" >>$WorkDIR/logs/Pipeline_procedure.log
   echo "$dline" >>$WorkDIR/logs/Pipeline_procedure.log
   
   ## U12.01a If new file exists, remove old Description file.
   
   if ls -1 $newDataPath/*annot.desc.txt >/dev/null 2>&1
   then
      
      rm -rf ${WorkDIR}/data/download/${xGDB}annot.desc.txt
      
      msgU1201="Removing old gene description file (if any) from download directory (${WorkDIR}/data/download/${xGDB}annot.desc.txt) (U12.01"
      echo "$space$msgU1201" >>$WorkDIR/logs/Pipeline_procedure.log
      
      ## U12.02 Concatenate new description file(s) and copy output to download page
      
      filesU1202=$(ls -m $newDataPath/*annot.desc.txt)
      
      cat $newDataPath/*annot.desc.txt  > ${WorkDIR}/data/download/${xGDB}annot.desc.txt
      
      if [ -s $WorkDIR/data/download/${xGDB}annot.desc.txt ]
      then
         
         dateTimeU1202=$(date +%Y-%m-%d\ %k:%M:%S)
         msgU1202="Gene model descriptions from $filesU1202 are being loaded to gseg_gene_annotation table (U12.02) "
         echo "$space$msgU1202$dateTimeU1202" >>$WorkDIR/logs/Pipeline_procedure.log
         
         # U12.03 Parse and load (concatenated) description file #
         
         $ScriptDIR/ParseAndUploadDes.pl $WorkDIR/data/download/${xGDB}annot.desc.txt $xGDB gseg_gene_annotation
         
         dateTimeU1203=$(date +%Y-%m-%d\ %k:%M:%S)
         countU1203=$(grep -c -P "^.+\t.+$" $WorkDIR/data/download/${xGDB}annot.desc.txt) #tab-delimited file with 2 columns
         msgU1203=" gene model descriptions found and loaded to $xGDB gseg_gene_annotation table (U12.03) "
         echo "$space$countU1203$msgU1203$dateTimeU1203 " >>$WorkDIR/logs/Pipeline_procedure.log
      fi
      
   else
      ## U12.01b If no new file exists, do nothing.
      msgU1201="No updated Description file found. Nothing deleted or loaded. Please check file name and path."
      echo "$space$msgU1201" >>$WorkDIR/logs/Pipeline_procedure.log
   fi
   echo "$space* Step U12 completed." >>$WorkDIR/logs/Pipeline_procedure.log
}

########################################################
# Step U13. Replace descriptions - CpGAT models       #
########################################################
# Here we don't need to create a scratch directory. We just copy new file to download directory and parse/load data.
#
ReplaceDESCC () {
   
   dateTimeU1300=$(date +%Y-%m-%d\ %k:%M:%S)
   msgU1300="| Step U13: Add or replace gene descriptions: CpGAT models "
   echo "$dline" >>$WorkDIR/logs/Pipeline_procedure.log
   echo "$msgU1300$dateTimeU1300" >>$WorkDIR/logs/Pipeline_procedure.log
   echo "$dline" >>$WorkDIR/logs/Pipeline_procedure.log
   
   ## U13.01 Check presence of description file. Note there is no "old" file to delete, as CpGAT process does not create one.
   
   if ls -1 $newDataPath/*cpgat.desc.txt >/dev/null 2>&1
   then
      
      ## U13.02 Concatenate new description file(s) and copy output to download page.
      
      filesU1302=$(ls -m $newDataPath/*cpgat.desc.txt)
      
      cat $newDataPath/*cpgat.desc.txt  > ${WorkDIR}/data/download/${xGDB}cpgat.desc.txt
      
      if [ -s $WorkDIR/data/download/${xGDB}cpgat.desc.txt ]
      then
         dateTimeU1302=$(date +%Y-%m-%d\ %k:%M:%S)
         msgU1302="Gene model descriptions from $filesU1302 are being loaded to gseg_cpgat_gene_annotation table (U13.02) "
         echo "$space$msgU1302$dateTimeU1302" >>$WorkDIR/logs/Pipeline_procedure.log
         
         # U13.03 Parse and load (concatenated) description file, if present  #
         
         $ScriptDIR/ParseAndUploadDes.pl $WorkDIR/data/download/${xGDB}cpgat.desc.txt $xGDB gseg_cpgat_gene_annotation
         
         dateTimeU1303=$(date +%Y-%m-%d\ %k:%M:%S)
         countU1303=$(grep -c -P "^.+\t.+$" $WorkDIR/data/download/${xGDB}annot.desc.txt) #tab-delimited file with 2 columns
         msgU1303=" gene model descriptions found and loaded to $xGDB gseg_cpgat_gene_annotation table (U13.03) "
         echo "$space$countU1303$msgU1303$dateTimeU1303" >>$WorkDIR/logs/Pipeline_procedure.log
      fi
      
   else
      ## U13.01b If no new file exists, do nothing.
      msgU1301="No updated Description file found. Nothing deleted or loaded. Please check file name and path."
      echo "$space$countU1301$msgU1301" >>$WorkDIR/logs/Pipeline_procedure.log
      
   fi
   
   echo "$space* Step U13 completed." >>$WorkDIR/logs/Pipeline_procedure.log
}


##########################################################
#  Add to Update history  (MySQL)             #
##########################################################

AddToHistory () {
   echo "update xGDB_Log set Update_History=concat(Update_History, \" $x\") where ID=\"$Id\""|mysql -p$dbpass -u $mysqluser Genomes
}

###########################################################################################################################
############################################ END OF 'Update' Mode functions  ##############################################
###########################################################################################################################


###########################################################################################################################
################################# Get options (base info, edit/update info, parameters) : #################################
###########################################################################################################################

BaseInfo=
EditInfo=

while getopts "d:i:e:g:t:c:a:f:r:m:n:" OPTION
do
   case $OPTION in
      d) DBname=$OPTARG # Database name
      ;;
      i) BaseInfo=$OPTARG #  "$DBid $id $input_path" (example: "GDB001 1 /xGDBvm/data/myData/")
      ;;
      e) EditInfo=$OPTARG # "$update_path [update action(s)]" (example: "/xGDBvm/data/myData//UpdateData/ estR CpGATR")
      ;;
      g) GSQparameter=$OPTARG # "wsize minqHSP minqHSPc mdrop Species (example: -x 30 -y 45 -z 60 -m 999999999 -s Arabidopsis")
      ;;
      t) GTHparameter=$OPTARG
      ;;
      c) GFFtype=$OPTARG
      ;;
      a) CpGATparameter=$OPTARG
      ;;
      f) CpGATfilter=$OPTARG
      ;;
      r) RepeatMaskparameter=$OPTARG
      ;;
      m) GSQ_CompResParameter=$OPTARG # Compute resources either "Remote username refresh_token" or no opts passed
      ;;
      n) GTH_CompResParameter=$OPTARG # Compute resources either "Remote username refresh_token" or no opts passed
      ;;
      
   esac
done


echo "$BaseInfo $EditInfo"
if [[ -z $BaseInfo ]] # if no base information is passed.
then
   echo "usage: $0 -i BaseInfomation [-e editInformation -c]"
   exit 1
fi

###########################################################################################################################
################################################### Define Script Variables ###############################################
###########################################################################################################################

######################################### parse from arguments sent by Create.php #########################################

#####################################
#### base (create GDB) variables ####
#####################################
set -- "$BaseInfo"
IFS=" "; declare -a baseArr=($*)
xGDB="${baseArr[0]}"
Id="${baseArr[1]}"
dataPath="${baseArr[2]}"


#################################
#### edit (update) variables ####
#################################
set -- "$EditInfo"
IFS=" "; declare -a editArr=($*)
newDataPath="${editArr[0]}"
echo "$newDataPath llllllll"

#####################################
#### compute resources variables ####
####################################
set -- "$GSQ_CompResParameter"
IFS=" "; declare -a gsqArr=($*)
GSQ_CompResources="${gsqArr[0]}" # "remote"
GSQ_username="${gsqArr[1]}" # username
GSQ_refresh_token="${gsqArr[2]}" # refresh token string
gsq_server="${gsqArr[3]}" # "the VM server URL e.g. 1298.196.1.13


#####################################
#### compute resources variables ####
####################################
set -- "$GTH_CompResParameter"
IFS=" "; declare -a gthArr=($*)
GTH_CompResources="${gthArr[0]}"
GTH_username="${gthArr[1]}"
GTH_refresh_token="${gthArr[2]}"
gth_server="${gthArr[3]}" # the VM server URL e.g. 1298.196.1.13

###################################################  Set Defaults  #####################################################

######################################
######## pipeline variables    #######
######################################

mode=''  # 'Create' or 'Update' pipeline mode, determined by absence/presence of $WorkDIR at start of this script.

### GAEVAL Test Summary: Run GAEVAL or CpGAT_GAEVAL IF BOTH genemodel AND transcript data are either loaded (Create mode) OR updated (Update mode) ###
# DATA Tests  (Create Mode and Update Mode) We want to be sure relevant data are loaded. This is done with a MySQL query and if statement, e.g.
#  [example] count=$(echo "select count(*) from gseg_gene_annotation"|mysql -p$dbpass -u $mysqluser -N $xGDB); if [ "count" -gt "0" ] then VAR='T'; fi

SPLICEALIGN='F' # (for CpGAT); True if spliced alignment data (est, put, cdna, prot) are loaded.
TRANSCRIPT='F' # (for GAEVAL); True if >0 mRNA spliced alignment data loaded in 'gseg_xxx_good_pgs' table (xxx = est, cdna, put)
GENEMODEL='F'  # (for GAEVAL); True if >0 genemodel data loaded (gseg_gene_annotation) 
CpGENEMODEL='F'  # (for GAEVAL) True if >0 CpGAT genemodel data loaded (gseg_cpgat_gene_annotation)

# DATA Tests (Update Mode only) # We want to find out if relevant data are updated. These are set within the Update subroutine.
U_TRANSCRIPT='F' # (for GAEVAL); True if mRNA spliced alignment data updated in 'gseg_xxx_good_pgs' table (xxx = est, cdna, put)
U_GENEMODEL='F'  # (for GAEVAL); True if genemodel data updated (gseg_gene_annotation) 
U_CpGENEMODEL='F'  # (for GAEVAL); True if CpGAT genemodel data updated (gseg_cpgat_gene_annotation) 

### GAEVAL actions: Computed from the above. Assign defaults.
GAEVALaction='Skip' # (for GAEVAL, gene track 1) = 'Run' if both TRANSCRIPT and GENEMODEL ='T';  Update mode) = 'Run' if both (TRANSCRIPT and GENEMODEL ='T') AND (U_TRANSCRIPT OR U_GENEMODEL ='T')
CpGAEVALaction='Skip' # (for CpGAT-GAEVAL, gene track 2) ='Run' if both TRANSCRIPT and CpGENEMODEL ='T'; Update mode) = 'Run' if both (TRANSCRIPT and CpGENEMODEL ='T') AND (U_TRANSCRIPT OR U_CpGENEMODEL ='T')

##################################
######## Style variables #########
##################################
dline="-------------------------------------------------------------------------------------------------------------------------" # 125 col
sline="*************************************************************************************************************************" # 125 col
space="  " #for logfile output styling

#################################
######### absolute paths ########
#################################

ROOT='/xGDBvm'
ScriptDIR='/xGDBvm/scripts'
BINdir='/usr/local/bin'
export BSSMDIR="/usr/local/bin/bssm";
export GTHDATADIR="/usr/local/bin/gthdata";
WorkDIR="/xGDBvm/data/$xGDB"; # on attached storage; final destination for GDB configuration files
tmpWorkDIR="/xGDBvm/data/scratch/$xGDB"  # temporary (scratch) destination for data data files
GeneSeqer='/usr/local/bin/GeneSeqer';
GenomeThreader='/usr/local/bin/gth';
formatdb='/usr/local/bin/formatdb';
MakeArray='/usr/local/bin/MakeArray';
RemoteDIR="/xGDBvm/input/xgdbvm/tmp/${xGDB}_hpc"; # updated 1-26-16 J Duvick to add /xgdbvm/tmp to path
ArchiveDIR="/xGDBvm/input/archive/jobs"; #default location for output data from TACC. These directories are created by the system.

###################
### MySQL Login ###
###################

while read dbpass
do
   echo "$dbpass"
done < /xGDBvm/admin/dbpass
mysqluser='gdbuser'; 

#############################################################################################################################
##################################      Execute subroutines based on command line arguments  ################################
#############################################################################################################################

#############################################################################################################################
########## If this is a new GDB, set 'Create' mode and do FirstPart (Steps 1-13), RunCpGAT (14-16), LastPart (17) ###########
#############################################################################################################################

if [ ! -d $WorkDIR ]; then #this is a new GDB
   #echo "'Create GDB' only loop"
   mode='Create'
#   GAEVALflag='T' DEPRECATED

   FirstPart  ########## DO FIRST PART -- SEE TOP OF SCRIPT ################
   
   ###################################################################################################
   ############# If editing (updating) existing GDB, set 'Update' mode do Update functions ###########
   ###################################################################################################
   
else #### Update existing GDB based on options arguments (each one calls a separate function).
   mode='Update'
   echo "update xGDB_Log set Update_History=concat(Update_History, \"Input: $newDataPath \", \"Action: \") where ID=\"$Id\""|mysql -p$dbpass -u $mysqluser Genomes #first part of Update_History
   # Add update header information to the logfile
   startTime=$(date +%Y-%m-%d\ %k:%M:%S)
   startTimeSec=$(date +"%s")
   echo "">>$WorkDIR/logs/Pipeline_procedure.log
   echo  "$sline">>$WorkDIR/logs/Pipeline_procedure.log
   echo  "* xGDB_Procedure.sh - Update GDB">>$WorkDIR/logs/Pipeline_procedure.log
   echo  "$sline">>$WorkDIR/logs/Pipeline_procedure.log
   echo -e "Update $xGDB, initiated \c" >>$WorkDIR/logs/Pipeline_procedure.log && echo "$startTime">>$WorkDIR/logs/Pipeline_procedure.log
   
   #### Get ValidationTimeStamp and update Processes;
   ProcessTimeStamp="$startTime"
   ValidationTimeStamp=$(echo "select max(ValidationTimeStamp) from Datafiles where Path=\"$newDataPath\" and ValidationTimeStamp LIKE \"${xGDB}%\""|mysql -p$dbpass -u $mysqluser Genomes -N) # most recent validation for this GDB and data path. OK
   ParentProcessTimeStamp=$(echo "select max(ProcessTimeStamp) from Processes where GDB=\"$xGDB\""|mysql -p$dbpass -u $mysqluser Genomes -N) # most recent validation for this GDB and data path.

   ##### Insert into Processes table #####
   echo "insert into Processes (ProcessTimeStamp, ParentProcessTimeStamp, ValidationTimestamp, GDB, ProcessType) values (\"$ProcessTimeStamp\", \"$ParentProcessTimeStamp\", \"$ValidationTimeStamp\", \"$xGDB\", \"update\")"|mysql -p$dbpass -u $mysqluser Genomes
   
   # Add update directory information to the logfile
   
   updatepath=$newDataPath
   echo "${space}Update parameters are $EditInfo" >>$WorkDIR/logs/Pipeline_procedure.log
   
   # Parse options arguments and call update functions. NOTE there is no gsegR option--- in that case, user should just create a new GDB.
   
   editArr=$EditInfo # parameters passed from user action
   for x in $editArr
   do
      echo "$x"
      case "$x" in
         gffA)     ### Append (or replace) precomputed (GFF3) models. Prerequisite: Update directory should contain '~annot.gff3' file(s)
            echo "${space}gffA) Add precomputed (GFF3) models. Requires $newDataPath/~annot.gff3 - Step U1a" >>$WorkDIR/logs/Pipeline_procedure.log
            addGFF # Goes to step U1-a
            AddToHistory # this appends 'gffA' to Update_History
            U_GAEVAL="T" 
         ;;
         cpgffA)   ### Append (or replace) CpGAT precomputed (GFF3) models. Prerequisite: Update directory should contain '~cpgat.gff3' file(s)
            echo "${space}cpgffA) Add precomputed CpGAT (GFF3) models. Requires $newDataPath/~cpgat.gff3 - Step U1b">>$WorkDIR/logs/Pipeline_procedure.log
            addCpGATGFF  # Goes to step U1-b.
            AddToHistory
            CpGATparameter='Precomputed' # 
            U_GAEVAL_CpGAT="T" # CpGAT models were updated so we want to run GAEVAL-CpGAT.
         ;;
         gsegA)
            echo "${space}gsegA) gseg edit only loop">>$WorkDIR/logs/Pipeline_procedure.log
            addGSEG
            AddToHistory
            U_GAEVAL="T" # because new spliced alignments and/or genes will be added, due to the new genome segments
         ;;
         estA)
            echo "${space}estA) Calling addEST. We want to append est spliced alignments">>$WorkDIR/logs/Pipeline_procedure.log
            addEST
            AddToHistory
            U_GAEVAL="T"
            U_GAEVAL_CpGAT="T"
         ;;
         cdnaA)
            echo "${space}cdnaA) Calling addCDNA. We want to append cdna spliced alignments" >>$WorkDIR/logs/Pipeline_procedure.log
            addCDNA
            AddToHistory
            U_GAEVAL="T"
            U_GAEVAL_CpGAT="T"
         ;;
         putA) # aka "TSA"
            echo "${space}putA) Calling addTSA. We want to append put (tsa) spliced alignments">>$WorkDIR/logs/Pipeline_procedure.log
            addTSA
            AddToHistory
            U_GAEVAL="T"
            U_GAEVAL_CpGAT="T" # CpGAT models so re-run GAEVAL
         ;;
         pepA)
            echo "${space}pepA) Calling addProtein. We want to append protein spliced alignments" >>$WorkDIR/logs/Pipeline_procedure.log
            addPROTEIN
            AddToHistory
            # NO GAEVAL
         ;;
         gffR)
            echo "${space}gffR) Calling ReplaceGFF. We want to replace GFF gene models - Step U7a">>$WorkDIR/logs/Pipeline_procedure.log
            ReplaceGFF
            addGFF
            AddToHistory
            U_GAEVAL="T"
         ;;
         cpgffR)
            echo "${space}cpgffR) Calling 'ReplaceCpGATGFF' and then 'addCpGATGFF'. We want to replace CpGAT gene models" >>$WorkDIR/logs/Pipeline_procedure.log
            ReplaceCpGATGFF
            addCpGATGFF
            AddToHistory
            U_GAEVAL_CpGAT="T" # CpGAT models so re-run GAEVAL
         ;;
         estR)
            echo "${space}estR) Calling 'ReplaceEST' and then 'addEST'. We want to replace EST spliced alignments" >>$WorkDIR/logs/Pipeline_procedure.log
            ReplaceEST
            addEST
            AddToHistory
            # (GAEVAL set by addEST)
         ;;
         cdnaR)
            echo "${space}cdnaR) Calling 'ReplaceCDNA' and then 'addCDNA'. We want to remote cDNA spliced alignments" >>$WorkDIR/logs/Pipeline_procedure.log
            ReplaceCDNA
            addCDNA
            AddToHistory
            # (GAEVAL set by addCDNA)
         ;;
         putR) # aka TSA
            echo "${space}putR) Calling 'replace TSA' and then 'addTSA'. We want to replace TSA spliced alignments" >>$WorkDIR/logs/Pipeline_procedure.log
            ReplaceTSA
            addTSA
            AddToHistory
            # (GAEVAL set by addTSA)
         ;;
         pepR)
            echo "${space}pepR) Calling 'ReplacePROTEIN' and then 'addPROTEIN'. We want to replace Prot spliced alignments " >>$WorkDIR/logs/Pipeline_procedure.log
            ReplacePROTEIN
            addPROTEIN
            AddToHistory
            # (GAEVAL set by addPROTEIN)
         ;;
         descP)
            echo "${space}descP) Calling 'ReplaceDESCP'. We want to replace Precomputed Gene Model Descriptions " >>$WorkDIR/logs/Pipeline_procedure.log
            ReplaceDESCP
            AddToHistory
            # (GAEVAL set by ReplaceDESCP)
         ;;
         descC)
            echo "${space}descC) Calling 'ReplaceDESCC'. We want to replace CpGAT Gene Model Descriptions" >>$WorkDIR/logs/Pipeline_procedure.log
            ReplaceDESCC
            AddToHistory
            # (GAEVAL set by ReplaceDESCC)
         ;;
         #####################################################################
         # Step U-14. Append CpGAT data: (prepare for adding new CpGAT data) #
         #####################################################################
         # FIXME - not sure this is handling new scaffolds correctly!
         cpgatA) #CpGAT Append is only allowed when adding new scaffold(s) (gsegA). Get new scaffold(s) and archive old CpGAT data. CpGAT will run after this loop.
            # TODO: Move this to subroutine, e.g. 'addCPGA'
            dateTimeU1400=$(date +%Y-%m-%d\ %k:%M:%S)
            msgU1400="| Step U-14: cpgatA) Prepare to append CpGAT annotations (if new gdna added). "
            echo "$dline" >>$WorkDIR/logs/Pipeline_procedure.log
            echo "$msgU1400$dateTimeU1400" >>$WorkDIR/logs/Pipeline_procedure.log
            echo "$dline" >>$WorkDIR/logs/Pipeline_procedure.log
            
            cp ${WorkDIR}/data/download/new_${xGDB}gdna.fa ${WorkDIR}/data/GTH/SCFDIR/${xGDB}gdna.fa #copy new scaffold(s) to GTH working directory
            countU1401=$(ls ${WorkDIR}/data/GTH/SCFDIR/${xGDB}gdna.fa|wc -l)
            msgU1401=" genome segment file (new and old sequences together) moved to GTH working directory (U14.01) "
            echo "$space$countU1401$msgU1401" >>$WorkDIR/logs/Pipeline_procedure.log
            
            mv ${WorkDIR}/data/CpGAT ${WorkDIR}/data/LastRun_CpGAT #Move the previous CpGAT output to an archive.
            
            dateTimeU1402=$(date +%Y-%m-%d\ %k:%M:%S)
            msgU1402="Previous CpGAT output moved to archive ${WorkDIR}/data/LastRun_CpGAT:  "
            echo "$space$msgU1402$dateTimeU1402 (U14.02)" >>$WorkDIR/logs/Pipeline_procedure.log
            
            mv ${WorkDIR}/data/XGDB_MYSQL/${xGDB}cpgat_gene_annotation.sql ${WorkDIR}/data/XGDB_MYSQL/old_${xGDB}cpgat_gene_annotation.sql #Move the previous CpGAT .sql to an archive.

            dateTimeU1499=$(date +%Y-%m-%d\ %k:%M:%S)
            msgU1499="* Step U-14 completed. CpGAT (Step 14) runs after this step. "
            echo "$space$msgU1499$dateTimeU1499" >>$WorkDIR/logs/Pipeline_procedure.log
            
            AddToHistory
            
            U_GAEVAL_CpGAT="T" # We are going to generate CpGAT models so we will re-run GAEVAL
         ;;
         
         ####################################################################################
         # Step U-15. Replace CpGAT data; re-run CpGAT on existing or updated data          #
         ####################################################################################
         
         cpgatR)
            # TODO: Move this to subroutine, e.g. ReplaceCpGAT
            # Replace CpGAT annotation. Get scaffold(s) and archive old CpGAT data. CpGAT will run after this loop.
            
            dateTimeU1500=$(date +%Y-%m-%d\ %k:%M:%S)
            msgU1500="| Step U-15: cpgatR) Replace CpGAT annotations. Archive CpGAT output and re-run CpGAT"
            echo "$dline" >>$WorkDIR/logs/Pipeline_procedure.log
            echo "$msgU1500$dateTimeU1500" >>$WorkDIR/logs/Pipeline_procedure.log
            echo "$dline" >>$WorkDIR/logs/Pipeline_procedure.log
            
            # First we need to create tmp working directory since we can't assume it exists from other steps:
            mkdir $tmpWorkDIR # /xGDBvm/data/scratch/data/GDBnnn/ - scratch directory, removed at end of pipeline.
            mkdir $tmpWorkDIR/data # subdirectory for all scratch data under GDBnnn
            
            dateTimeU1501=$(date +%Y-%m-%d\ %k:%M:%S)
            msgU1501="Created tmp working directory $tmpWorkDIR/data if not already exists"
            echo "$space$msgU1501$dateTimeU1501 (U15.01)">>$WorkDIR/logs/Pipeline_procedure.log
            
            # Copy scaffolds to GTH working directory (where we will retrieve them later) and move any old CpGAT run to an archive
            dateTimeU15025=$(date +%Y-%m-%d\ %k:%M:%S)
            msgU15025="Copying existing scaffolds to GTH working directory, moving prev. CpGAT output (if any) to archive file"
            echo "$space$msgU15025$dateTimeU15025 (U15.025)">>$WorkDIR/logs/Pipeline_procedure.log
            
            cp ${WorkDIR}/data/BLAST/${xGDB}gdna.fa ${WorkDIR}/data/GTH/SCFDIR/${xGDB}gdna.fa #copy existing scaffold(s) to GTH working directory
            mv ${WorkDIR}/data/CpGAT ${WorkDIR}/data/LastRun_CpGAT  #Move the previous CpGAT output to an archive.
            mv ${WorkDIR}/data/XGDB_MYSQL/${xGDB}cpgat_gene_annotation.sql ${WorkDIR}/data/XGDB_MYSQL/old_${xGDB}cpgat_gene_annotation.sql #Move the previous CpGAT .sql to an archive.
            mv ${WorkDIR}/data/download/${xGDB}cpgat.gff3 ${WorkDIR}/data/download/${xGDB}old_cpgat.gff3 #Move the previous CpGAT gff3 to an archive.
            # Remove old cpgat MySQL data
            echo "delete from gseg_cpgat_gene_annotation"|mysql -p$dbpass -u $mysqluser $xGDB
            
            dateTimeU1502=$(date +%Y-%m-%d\ %k:%M:%S)
            msgU1502="Deleted old records from CpGAT annotation table gseg_cpgat_gene_annotation "
            echo "$space$msgU1502$dateTimeU1502 (U15.02)">>$WorkDIR/logs/Pipeline_procedure.log

			### The user may be requesting JUST CpGAT based on pre-existing spliced alignments, so we set SPLICEALIGN ="T".

			SPLICEALIGN="T" 

            U_GAEVAL_CpGAT="T" # We are going to generate CpGAT models so we will re-run GAEVAL

            dateTimeU1599=$(date +%Y-%m-%d\ %k:%M:%S)
            msgU1599="* Step U15 completed. CpGAT (Step 13-15) runs after this step. "
            echo "$space$msgU1599$dateTimeU1599" >>$WorkDIR/logs/Pipeline_procedure.log
            
            AddToHistory
            
         ;;
      esac
   done
fi

RunCpGAT # Run CpGAT pipeline scripts (Step 14-16) - if the user has not selected CpGAT (no CpGAT parameters), it will terminate early in step 14.

LastPart # Run GAEVAL analysis and update global MySQL data.

dateTime9999=$(date +%Y-%m-%d\ %k:%M:%S)
msg9999="* End of xGDBvm '$mode' pipeline,"
echo "$sline" >>$WorkDIR/logs/Pipeline_procedure.log
echo "$msg9999 done at $dateTime9999 ($minutes min $seconds sec)" >>$WorkDIR/logs/Pipeline_procedure.log
echo "$sline" >>$WorkDIR/logs/Pipeline_procedure.log
echo ""
