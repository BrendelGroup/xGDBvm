#!/bin/bash
#### Useage: called by user this script validates all correctly-named files in the target directory by iteratively launching xGDB_validatefiles.php ########
#### The results are stored in MySQL database table Genomes.Datafiles, using a filestamp as unique key.
#### WE get the filepath from input argument. All script actions take place with reference to that filepath.
#### 
#### Most recent update: 1-26-16 J Duvick to update comments only

#### Defaults #####
space="  "
ValidationDIR="/xGDBvm/data/scratch/"; # on attached storage; final destination for GDB configuration files

###############################################################
# Step 1. Get arguments for GDB and file validation target(s) #
###############################################################

while getopts "i:x:n:p:m:u:" OPTION
do
   case $OPTION in
      i) ID=$OPTARG # e.g. 1, refers to the GDB
      ;;   
      x) xGDB=$OPTARG # e.g. GDB001, refers to the GDB
      ;;
      n) InputDir="$OPTARG" # e.g. /xGDBvm/input/xgdbvm/MyDir/
      ;;
      p) RefProtFile="$OPTARG"   # Path to reference protein file (optional)
      ;;
      m) RepeatMaskFile="$OPTARG" # Path to repeat mask library (optional)
      ;;
      u) UpdateDir="$OPTARG" 
      ;;
   esac
done

###############################################################
# Step 2.Open database and set status to 'Locked'             #
###############################################################

while read dbpass
	do
	   echo "$dbpass"
	done < /xGDBvm/admin/dbpass
mysqluser='gdbuser';

## Set status to 'Locked'

 echo "update xGDB_Log set Status = \"Locked\", Process_Type = \"validate\" where ID=$ID"|mysql -p$dbpass -u $mysqluser Genomes

#############################################################################
# Step 3. If correct arguments present to identify GDB                      #
#############################################################################

if [[ -n "$ID" && -n "$xGDB" ]] 
then

##################################################################################
# Step 4. Create ValidationTimeStamp  (requires GDB) and new validation log file #
##################################################################################
	startTime=$(date +%Y-%m-%d\ %k:%M:%S) # formatted for ValidationTimeStamp
	startTimeSec=$(date +"%s") # in seconds; used to calculate duration (see step 9)

	ValidationTimeStamp="${xGDB}-${startTime}" # allows all events from this script run to be grouped
	echo  "Validation Underway, Time Stamp: $ValidationTimeStamp">$ValidationDIR/Validation.log # NEW FILE (overwrites old one)
	echo "">>$ValidationDIR/Validation.log


####################################################################################################################################################################################################
###### Steps 5-8. For each target directory (specified in getopts) and each possible filetype and format (e.g. gdna.fa), list all matching files and validate each one by launching php script #####
####################################################################################################################################################################################################

################
# 5a. InputDir #
################
	if [ -n "$InputDir" ]
	then
	#	    echo  "InputDir is: $InputDir">>$ValidationDIR/Validation.log

		if [ -d  $InputDir ]
		then  # Loop through file types and list each file, loop through files and validate each one by passing the filepath and filestamp to xGDB_validatefiles.php (along with a timestamp unique to this thread)
	#	       echo  "InputDir exists: $InputDir">>$ValidationDIR/Validation.log
		   cd $InputDir # necessary to get filestamp without path info
		   f=0
		   for filetype in est.fa cdna.fa tsa.fa prot.fa gdna.fa gdna.rm.fa est.gsq cdna.gsq tsa.gsq prot.gth annot.gff3 cpgat.gff3 annot.mrna.fa cpgat.mrna.fa annot.pep.fa cpgat.pep.fa annot.desc.txt cpgat.desc.txt
		   do
				cd $InputDir # necessary to get filestamp without path info
				InputFiles=$(ls -1 *$filetype | tr "\n" " " ) # e.g. list two or more of the same type of file, such as MySeq1.est.fa MySeq2.est.fa (and replace line feed with space)
				n=0
				for filename in $InputFiles
				do
					 ((f = f + 1)) # executed step count
					 ((n = n + 1)) # filetype count
				
				   InputPath="${InputDir}${filename}" # e.g. /xGDBvm/input/xgdbvm/MyDir/Myfile_est.fa
			   
	#	               echo  "For filetype $filetype and filename $filename: listing InputPath $InputPath">>$ValidationDIR/Validation.log				   
			   
				   FileStamp=$(ls -l --time-style=long-iso $filename|awk -F ' ' '{print $8 ":" $5 ":" $6 "-" $7}' )   # -rw-r--r--. 1 jduvick root 418605 2014-07-22 17:59 Ex1.gdna.fa; we want $name:$size:${year_month_day}-$time (7:4:5:6) e.g. Ex1.gdna.fa:418605:2014-07-22-17:59

	#	               echo  "FileStamp is: $FileStamp">>$ValidationDIR/Validation.log

				   echo "${f}. Evaluating input file ${InputPath} .... ">>$ValidationDIR/Validation.log

				   php /xGDBvm/XGDB/phplib/xGDB_validatefile.php "${ValidationTimeStamp}" "${InputPath}" "${FileStamp}" "T" "${n}" "T" # use argv[] to capture variables in the php script.
			   
				   entrycount=$(echo "SELECT EntryCount FROM Datafiles WHERE Path=\"$InputDir\" AND FileStamp=\"$FileStamp\""|mysql -p$dbpass -u $mysqluser Genomes -N)
			  
				   valid=$(echo "SELECT Valid FROM Datafiles WHERE Path=\"$InputDir\" AND FileStamp=\"$FileStamp\""|mysql -p$dbpass -u $mysqluser Genomes -N)

				   echo "${space} - File type $filetype (${n}): Valid='$valid' for $entrycount entries in ${InputPath} ">>$ValidationDIR/Validation.log
			   
				   echo "">>$ValidationDIR/Validation.log
			   
				done
			
		   done
		fi # More to come:
	
###########################
# 5b. InputDir Multi-file #
###########################
### check multiple fasta files catted together for each file type.###
			((f = f + 1)) # executed step count
			echo "${f}. Checking for multiple files of same type in ${InputPath} .... ">>$ValidationDIR/Validation.log
			echo "">>$ValidationDIR/Validation.log
			for seqtype in est cdna tsa prot gdna gdna.rm annot.mrna cpgat.mrna annot.pep cpgat.pep
			do
			  echo " - Checking multiple files: $seqtype ">>$ValidationDIR/Validation.log
			   count=$(echo "SELECT count(*) FROM Datafiles WHERE ValidationTimeStamp=\"${ValidationTimeStamp}\" AND UserFile=\"T\" AND SeqType=\"$seqtype\" AND Path=\"$InputDir\" AND Format=\"fa\" GROUP BY SeqType HAVING COUNT(SeqType)>1"|mysql -p$dbpass -u $mysqluser Genomes -N) # Query for multiple files of a type
			   if [[ "$count" -gt 1 ]]  # Multiple files exist from the above analysis, e.g. Ex4-2.est.fa,Ex4.est.fa
			   then
				  files=$(echo "SELECT GROUP_CONCAT(FileName SEPARATOR \" \") FROM Datafiles WHERE ValidationTimeStamp=\"${ValidationTimeStamp}\" AND UserFile=\"T\" AND SeqType=\"$seqtype\" AND Path=\"$InputDir\" AND Format=\"fa\" GROUP BY SeqType HAVING COUNT(SeqType)>1"|mysql -p$dbpass -u $mysqluser Genomes -N)
				  # e.g. Ex4-2.est.fa,Ex4.est.fa
				  # if we don't already have filestamps for all files, go ahead and validate:
				  FileStamp_CATTED=$(echo "SELECT GROUP_CONCAT(FileStamp SEPARATOR \"_\") FROM Datafiles WHERE ValidationTimeStamp=\"${ValidationTimeStamp}\" AND UserFile=\"T\" AND SeqType=\"$seqtype\" AND Path=\"$InputDir\" AND Format=\"fa\" GROUP BY SeqType HAVING COUNT(SeqType)>1 Order by FileStamp"|mysql -p$dbpass -u $mysqluser Genomes -N) 
				  # e.g. Ex4-2.est.fa:125365:2014-09-17-15:19_Ex4.est.fa:125365:2014-01-03-14:48
				  echo " - - Found $count files $seqtype: $files filestamp: $FileStamp_CATTED ">>$ValidationDIR/Validation.log
				  count_catted=$(echo "SELECT COUNT(*) FROM Datafiles WHERE UserFile=\"F\" AND Path=\"$InputDir\" AND FileStamp=\"$FileStamp_CATTED\""|mysql -p$dbpass -u $mysqluser Genomes -N)
				  echo " - - There are $count_catted records that validate this group of files ">>$ValidationDIR/Validation.log
				  if [ "$count_catted" -eq "0" ] # This combination of catted files has not been analyzed previously
				  then
					 ((f = f + 1)) # executed step count
					  echo " - - So we will go ahead and validate them as a catted aggregate file">>$ValidationDIR/Validation.log
					  catted_files="CATTED_FILES.${seqtype}.fa" # the temporary destination file, e.g. CATTED_FILES.est.fa
					  TempDir="/xGDBvm/data/scratch/"
					  TempFilePath="${TempDir}${catted_files}"
					  truncate $TempFilePath --size=0  # starting empty
					  c=0
					  for eachfile in $files
					  do
						 cat ${InputDir}/${eachfile} >> $TempFilePath # combine each contents
						 cd $TempDir
						 echo " - - We did cat >> ${InputDir}/${eachfile} $TempFilePath ">>$ValidationDIR/Validation.log
					  ((c = c + 1)) # file count
					  done

					  echo " - - ${c} catted $seqtype files in path ${TempFilePath} sent for aggregate validation  ">>$ValidationDIR/Validation.log
					  php /xGDBvm/XGDB/phplib/xGDB_validatefile.php "${ValidationTimeStamp}" "${TempFilePath}" "${FileStamp_CATTED}" "T" "$count" "F" # The last argument distinguishes a catted file from a REGULAR file
					  entrycount=$(echo "SELECT EntryCount FROM Datafiles WHERE UserFile=\"F\" AND Path=\"$TempDir\" AND FileStamp=\"$FileStamp_CATTED\""|mysql -p$dbpass -u $mysqluser Genomes -N)
					  valid=$(echo "SELECT Valid FROM Datafiles WHERE UserFile=\"F\" AND Path=\"$TempDir\" AND FileStamp=\"$FileStamp_CATTED\""|mysql -p$dbpass -u $mysqluser Genomes -N) 
					  echo "${space} - File type $seqtype (${c}): Valid='$valid' for $entrycount entries in ${InputPath} ">>$ValidationDIR/Validation.log
					  echo "">>$ValidationDIR/Validation.log
				 else
				 echo " - - So there is no need to evaluate them again. ">>$ValidationDIR/Validation.log
				 fi
			 fi
		done
	fi # End inputdir
	echo "">>$ValidationDIR/Validation.log

###################
# 6. RefProtFile #
###################

	if [ -n "$RefProtFile" ]
	then
	#	    echo  "RefProtFile is: $RefProtFile">>$ValidationDIR/Validation.log

		if [ -f  $RefProtFile ]
		then  # Loop through file types and list each file, loop through files and validate each one by passing the filepath and filestamp to xGDB_validatefiles.php (along with a timestamp unique to this thread)

	#	       echo  "RefProtFile exists: $RefProtFile">>$ValidationDIR/Validation.log

		   ((f = f + 1)) # executed step count

	##### Parse directory and file, and derive unique filestamp: ######

		   FilePath=$RefProtFile # e.g. /xGDBvm/data/referenceprotein/myRefProt.fa

		   File=$(echo "$FilePath" | awk -F / '{print $NF}') # e.g.  myRefProt.fa echo "/xGDBvm/examples/referenceprotein/cegma_core.fa" | awk -F "/" "{ print $NF }
	   
		   DirectoryPath=$(echo "$FilePath" | sed "s/$File//") # e.g. /xGDBvm/data/referenceprotein/
	   
		   cd $DirectoryPath
	   
		   FileStamp=$(ls -l --time-style=long-iso $File|awk -F ' ' '{print $8 ":" $5 ":" $6 "-" $7}' )   # -rw-r--r--. 1 jduvick root 418605 2014-07-22 17:59 Ex1.gdna.fa; we want $name:$size:${year_month_day}-$time (7:4:5:6) e.g. MyRefProt.fa:418605:2014-07-22-17:59

		   echo "${f}. Evaluating reference protein file ${FilePath} .... ">>$ValidationDIR/Validation.log

		   php /xGDBvm/XGDB/phplib/xGDB_validatefile.php "${ValidationTimeStamp}" "${FilePath}" "${FileStamp}" "T" "1" "T"# use argv[] to capture variables in the php script.

		   entrycount=$(echo "SELECT EntryCount FROM Datafiles WHERE Path=\"$DirectoryPath\" AND FileStamp=\"$FileStamp\""|mysql -p$dbpass -u $mysqluser Genomes -N)
	  
		   valid=$(echo "SELECT Valid FROM Datafiles WHERE Path=\"$DirectoryPath\" AND FileStamp=\"$FileStamp\""|mysql -p$dbpass -u $mysqluser Genomes -N)

		   echo "${space} - Reference Proteins File: Valid='$valid' for $entrycount entries in ${FilePath} ">>$ValidationDIR/Validation.log
		   echo "">>$ValidationDIR/Validation.log

		fi
	fi # End  refprot

######################
# 7. RepeatMaskFile #
######################

	if [ -n "$RepeatMaskFile" ]
	then
	#	    echo  "RepeatMaskFile is: $RepeatMaskFile">>$ValidationDIR/Validation.log

		if [ -f  $RepeatMaskFile ]
		then  # Loop through file types and list each file, loop through files and validate each one by passing the filepath and filestamp to xGDB_validatefiles.php (along with a timestamp unique to this thread)

	#	       echo  "RepeatMaskFile exists: $RepeatMaskFile">>$ValidationDIR/Validation.log

		   ((f = f + 1)) # executed step count

	##### Parse directory and file, and derive unique filestamp: ######

		   FilePath=$RepeatMaskFile # e.g. /xGDBvm/data/referenceprotein/myRepeatMaskFile.fa

		   File=$(echo "$FilePath" | awk -F / '{print $NF}') # e.g..  myRepeatMaskFile.fa
	   
		   DirectoryPath=$(echo "$FilePath" | sed "s/$File//") # e.g. /xGDBvm/data/repeatmask/
	   
		   cd $DirectoryPath
	   
		   FileStamp=$(ls -l --time-style=long-iso $File|awk -F ' ' '{print $8 ":" $5 ":" $6 "-" $7}' )   # -rw-r--r--. 1 jduvick root 418605 2014-07-22 17:59 Ex1.gdna.fa; we want $name:$size:${year_month_day}-$time (7:4:5:6) e.g. MyRefProt.fa:418605:2014-07-22-17:59

		   echo "${f}. Evaluating Repeat Mask file ${FilePath} .... ">>$ValidationDIR/Validation.log

		   php /xGDBvm/XGDB/phplib/xGDB_validatefile.php "${ValidationTimeStamp}" "${FilePath}" "${FileStamp}" "T" "1" "T" # use argv[] to capture variables in the php script.

		   entrycount=$(echo "SELECT EntryCount FROM Datafiles WHERE Path=\"$DirectoryPath\" AND FileStamp=\"$FileStamp\""|mysql -p$dbpass -u $mysqluser Genomes -N)
	  
		   valid=$(echo "SELECT Valid FROM Datafiles WHERE Path=\"$DirectoryPath\" AND FileStamp=\"$FileStamp\""|mysql -p$dbpass -u $mysqluser Genomes -N)

		   echo "${space} - Repeat Mask File: Valid='$valid' for $entrycount entries in ${FilePath} ">>$ValidationDIR/Validation.log
		   echo "">>$ValidationDIR/Validation.log
	   
		fi
	fi # End repeatmask


#################
# 8a. UpdateDir #
#################
	if [ -n "$UpdateDir" ]
	then
		echo  "UpdateDir is: $UpdateDir">>$ValidationDIR/Validation.log

		if [ -d  $UpdateDir ]
		then  # Loop through file types and list each file, loop through files and validate each one by passing the filepath and filestamp to xGDB_validatefiles.php (along with a timestamp unique to this thread)
		   echo  "UpdateDir exists: $UpdateDir">>$ValidationDIR/Validation.log
		   cd $UpdateDir # necessary to get filestamp without path info
		   for filetype in est.fa cdna.fa tsa.fa prot.fa gdna.fa gdna.rm.fa est.gsq cdna.gsq tsa.gsq prot.gth annot.gff3 cpgat.gff3 annot.mrna.fa cpgat.mrna.fa annot.pep.fa cpgat.pep.fa annot.desc.txt cpgat.desc.txt
		   do
				cd $UpdateDir # necessary to get filestamp without path info
				UpdateFiles=$(ls -1 *$filetype | tr "\n" " " ) # e.g. list two or more of the same type of file, such as MySeq1.est.fa MySeq2.est.fa (and replace line feed with space)
				n=0
				for filename in $UpdateFiles
				do
					 ((n = n + 1))
					 ((f = f + 1))
				
				   UpdatePath="${UpdateDir}/${filename}" # e.g. /xGDBvm/input/xgdbvm/MyDir/Updates/Myfile_est.fa
			   
	#	               echo  "For filetype $filetype and filename $filename: listing UpdatePath $UpdatePath">>$ValidationDIR/Validation.log				   
			   
				   FileStamp=$(ls -l --time-style=long-iso $filename|awk -F ' ' '{print $8 ":" $5 ":" $6 "-" $7}' )   # -rw-r--r--. 1 jduvick root 418605 2014-07-22 17:59 Ex1.gdna.fa; we want $name:$size:${year_month_day}-$time (7:4:5:6) e.g. Ex1.gdna.fa:418605:2014-07-22-17:59

	#	               echo  "FileStamp is: $FileStamp">>$ValidationDIR/Validation.log

				   echo "${f}. Evaluating Update Directory file ${UpdatePath} .... ">>$ValidationDIR/Validation.log
			   
				   php /xGDBvm/XGDB/phplib/xGDB_validatefile.php "${ValidationTimeStamp}" "${UpdatePath}" "${FileStamp}" "T" "${n}" "T" # use argv[] to capture variables in the php script.

				   entrycount=$(echo "SELECT EntryCount FROM Datafiles WHERE Path=\"$UpdatePath\" AND FileStamp=\"$FileStamp\""|mysql -p$dbpass -u $mysqluser Genomes -N)
			  
				   valid=$(echo "SELECT Valid FROM Datafiles WHERE Path=\"$UpdatePath\" AND FileStamp=\"$FileStamp\""|mysql -p$dbpass -u $mysqluser Genomes -N)

				   echo "${space} - File type $filetype (${n}): Valid='$valid' for $entrycount entries in ${UpdatePath} ">>$ValidationDIR/Validation.log
				   echo "">>$ValidationDIR/Validation.log

				done
		   done

		fi # But wait... there's more:

###########################
# 8b. UpdateDir Multi-file #
###########################
	### check multiple fasta files catted together for each file type.###
			for seqtype in est cdna tsa prot gdna gdna.rm annot.mrna cpgat.mrna annot.pep cpgat.pep # all fasta types
			do
			  echo "Update Directory: Checking multiple files $seqtype ">>$ValidationDIR/Validation.log
			   count=$(echo "SELECT count(*) FROM Datafiles WHERE ValidationTimeStamp=\"${ValidationTimeStamp}\" AND UserFile=\"T\" AND SeqType=\"$seqtype\" AND Path=\"$UpdateDir\" AND Format=\"fa\" GROUP BY SeqType HAVING COUNT(SeqType)>1"|mysql -p$dbpass -u $mysqluser Genomes -N) # Query for multiple files of a type
			   if [ "$count" -gt 1 ]  # Multiple files exist from the above analysis, e.g. Ex4-2.est.fa,Ex4.est.fa
			   then
				  files=$(echo "SELECT GROUP_CONCAT(FileName SEPARATOR \" \") FROM Datafiles WHERE ValidationTimeStamp=\"${ValidationTimeStamp}\" AND UserFile=\"T\" AND SeqType=\"$seqtype\" AND Path=\"$UpdateDir\" AND Format=\"fa\" GROUP BY SeqType HAVING COUNT(SeqType)>1"|mysql -p$dbpass -u $mysqluser Genomes -N)
				  # e.g. Ex4-2.est.fa,Ex4.est.fa
				  # if we don't already have filestamps for all files, go ahead and validate:
				  FileStamp_CATTED=$(echo "SELECT GROUP_CONCAT(FileStamp SEPARATOR \"_\") FROM Datafiles WHERE ValidationTimeStamp=\"${ValidationTimeStamp}\" AND UserFile=\"T\" AND SeqType=\"$seqtype\" AND Path=\"$UpdateDir\" AND Format=\"fa\" GROUP BY SeqType HAVING COUNT(SeqType)>1 Order by FileStamp"|mysql -p$dbpass -u $mysqluser Genomes -N) 
				  # e.g. Ex4-2.est.fa:125365:2014-09-17-15:19_Ex4.est.fa:125365:2014-01-03-14:48
				  echo "Found $count files $seqtype: $files filestamp: $FileStamp_CATTED ">>$ValidationDIR/Validation.log
				  count_catted=$(echo "SELECT COUNT(*) FROM Datafiles WHERE UserFile=\"F\"  AND Path=\"$UpdateDir\" AND FileStamp=\"$FileStamp_CATTED\""|mysql -p$dbpass -u $mysqluser Genomes -N)
				  echo "There are $count_catted records that validate this group of files ">>$ValidationDIR/Validation.log
				  if [ "$count_catted" -eq "0" ] # This combination of catted files has not been analyzed previously
				  then
					  echo "So we will go ahead and validate them as a catted aggregate file">>$ValidationDIR/Validation.log
					  catted_files="CATTED_FILES.${seqtype}.fa" # the temporary destination file, e.g. CATTED_FILES.est.fa
					  TempDir="/xGDBvm/data/scratch/"
					  TempFilePath="${TempDir}${catted_files}"
					  truncate $TempFilePath --size=0  # starting empty
					  for eachfile in $files
					  do
						 cat ${UpdateDir}/${eachfile} >> $TempFilePath # combine each contents
						 cd $TempDir
						 echo "We did cat >> ${UpdateDir}/${eachfile} $TempFilePath ">>$ValidationDIR/Validation.log
					  done

					  echo "Catted files $seqtype in path ${TempFilePath}: ${FileStamp} sent for validation  ">>$ValidationDIR/Validation.log
					  php /xGDBvm/XGDB/phplib/xGDB_validatefile.php "${ValidationTimeStamp}" "${TempFilePath}" "${FileStamp_CATTED}" "T" "$count" "F" # The last argument distinguishes a catted file from a REGULAR file
				 else
				 echo "So there is no need to evaluate them again. ">>$ValidationDIR/Validation.log
				 fi
			 fi
		done
	fi  # End UpdateDir

###############################################################################################
# Step 9. Determine Valid Status, insert Processes record.                               #
###############################################################################################


	invalid_count=$(echo "SELECT COUNT(*) FROM Datafiles WHERE ValidationTimeStamp=\"$ValidationTimeStamp\" AND Valid=\"F\""|mysql -p$dbpass -u $mysqluser Genomes -N)
	valid_count=$(echo "SELECT COUNT(*) FROM Datafiles WHERE ValidationTimeStamp=\"$ValidationTimeStamp\" AND Valid=\"T\""|mysql -p$dbpass -u $mysqluser Genomes -N)
	if [[ "$valid_count" -gt 0 ]] # some valid files
	then
	   if [[ "$invalid_count" -gt 0 ]] # ... and some invalid files
	   then
		  overall_status="not valid"
	   else
		  overall_status="valid"
	   fi
	else # no valid files
	   if [[ "$invalid_count" -gt 0 ]] # ... and some invalid files
	   then
		  overall_status="not valid"
	   else                            # ... and no invalid files either
		  overall_status="unknown"
	   fi
	fi
	endTime=$(date +%Y-%m-%d\ %k:%M:%S)
	endTimeSec=$(date +"%s")
	diff=$(($endTimeSec-$startTimeSec)) # from Step 4
	minutes=$(($diff / 60))
	seconds=$(($diff % 60)) # modulo

	echo "INSERT INTO Processes (ProcessTimeStamp, ValidationTimeStamp, GDB, ProcessType, Outcome, Duration) VALUES (\"$startTime\",\"$ValidationTimeStamp\",\"$xGDB\",\"validation\",\"$overall_status\",$diff)"|mysql -p$dbpass -u $mysqluser Genomes

###############################################################################################
# Step 10. Update status from 'Locked', end of script                                         #
###############################################################################################

	if [ -n "$UpdateDir" ] # Outcome determines how we set Status
	then
	   echo "update xGDB_Log set Status = \"Current\", Process_Type = \"\" where ID=$ID"|mysql -p$dbpass -u $mysqluser Genomes
	   else
	   echo "update xGDB_Log set Status = \"Development\", Process_Type = \"\" where ID=$ID"|mysql -p$dbpass -u $mysqluser Genomes
	fi
    echo "End of process for Validation Time Stamp: $ValidationTimeStamp, done at $endTime ($minutes min $seconds sec)">>$ValidationDIR/Validation.log #
 
###############################################################################################
# Step 3b (from above). else if no valid arguments                                                              #
###############################################################################################
else # from Step 3 (If Valid Arguments)
	failedTime=$(date +%Y-%m-%d\ %k:%M:%S)
    echo "Could not run validation; Missing arguments. $dateTime">$ValidationDIR/Validation.log # New file
	echo "INSERT INTO Processes (ProcessTimeStamp, ProcessType, Outcome) VALUES (\"$failedTime\",\"validation\",\"failed to run\")"|mysql -p$dbpass -u $mysqluser Genomes
fi # End If Valid Arguments

###############################################################################################
# Step 11. End of script                                         #
###############################################################################################

echo "">>$ValidationDIR/Validation.log
echo "-------------------------------------------------------------------------------------------------------------">>$ValidationDIR/Validation.log
echo "">>$ValidationDIR/Validation.log

