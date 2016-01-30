#!/bin/bash
### Useage: called from archive_exec.php via xGDBvm interface########
### Creates an archive of the selected GDB under /xGDBvm/data/ArchiveGDB/ and updates log files including ArchiveGDB.log
### Updated 1-26-16 by J Duvick to correct errors in comments only

VM=$(uname -n|cut -d "." -f 1) # identifies this VM

xGDB=$1
ID=$2
DataDIR="/xGDBvm/data"
ArchiveDIR="$DataDIR/ArchiveGDB"
space="  " # for indenting in pipeline log
dline="-------------------------------------------------------------------------------------------------------------------------" # 125 col
sline="*************************************************************************************************************************" # 125 col

while read dbpass
	do
	   echo "$dbpass"
	done < /xGDBvm/admin/dbpass
mysqluser='gdbuser';

if [ -d $ArchiveDIR ] # If ArchiveGDB exists 
then
	### Indicate "In progress" 
	 echo "update xGDB_Log set Status = \"Locked\" where ID=$ID"|mysql -p$dbpass -u $mysqluser Genomes
	 echo "update xGDB_Log set Archive_Date = \"In Progress\" where ID=$ID"|mysql -p$dbpass -u $mysqluser Genomes

	### Initiate Headers for Log Files

	dateTime1=$(date +%Y-%m-%d\ %k:%M:%S)
	echo "">>$DataDIR/$xGDB/logs/Pipeline_procedure.log
	echo "$sline">>$DataDIR/$xGDB/logs/Pipeline_procedure.log
	echo "* xGDB_ArchiveOneGDB.sh - Create a GDB Archive on Data volume. $dateTime1">>$DataDIR/$xGDB/logs/Pipeline_procedure.log
	echo "$sline">>$DataDIR/$xGDB/logs/Pipeline_procedure.log
	echo "">>$DataDIR/$xGDB/logs/Pipeline_procedure.log

	echo "" >>$ArchiveDIR/ArchiveGDB.log
	echo "$sline" >>$ArchiveDIR/ArchiveGDB.log
	echo "* xGDB_ArchiveOneGDB.sh -  Create a GDB Archive on Data volume. $dateTime1" >>$ArchiveDIR/ArchiveGDB.log
	echo "$sline" >>$ArchiveDIR/ArchiveGDB.log
	echo "" >>$ArchiveDIR/ArchiveGDB.log


	### Get DBname and create GDBidentifier.

	GDBidentifier=$(echo "select DBname from Genomes.xGDB_Log where ID=$ID"|mysql --skip-column-names -p$dbpass -u $mysqluser)
	dateTimeIdentifier=$(date +%Y%m%d-%H%M%S)

	### Create filename that reports DBname and Organism
	GDBidentifier=${xGDB}-${GDBidentifier//[^a-zA-Z0-9\-]/-} # e.g. GDB001-Example-1---4-Scaffold- (convert non-ascii to "-")
	GDBidentifier=${GDBidentifier}-${dateTimeIdentifier} # e.g. 20140404-055435



	### count the number of previous archives with the xGDB ID. There should by AT MOST one, and if so we rename it for later removal. If more than one, we have a problem.
	  file_count=$(ls -l $ArchiveDIR/${xGDB}-*.tar|wc -l) 
	  if [ "$file_count" -eq "1" ] # If ArchiveGDB/GDBnnn-[some-name-whether-same-or-different].tar exists, rename it for later removal
	  then
	  	cd $ArchiveDIR
	    current_archive=$(ls ${xGDB}-*.tar)
	    mv ${current_archive} backup_${current_archive}   # make backup in case archive fails.
	   ## Log this event
        dateTime1=$(date +%Y-%m-%d\ %k:%M:%S)
        msg1="A previous $xGDB archive was found; it was renamed to $ArchiveDIR/backup_${current_archive} before proceeding.  $dateTime1 " 
          echo "${space}${msg1}" >>$DataDIR/$xGDB/logs/Pipeline_procedure.log  
          echo "$msg1$" >>$ArchiveDIR/ArchiveGDB.log
	    
	  fi
	  if [ "$file_count" -le "1" ] # One or zero previous archive exists
	  then
      ### Make temporary subdirectory $xGDB and copy current GDB files to it using Rsync
         ### log this step:
          dateTime2=$(date +%Y-%m-%d\ %k:%M:%S)
          msg2="Creating temp directory and running rsync -a $DataDIR/$xGDB/ $ArchiveDIR/$xGDB  $dateTime2"
          echo "${msg2}" >>$ArchiveDIR/ArchiveGDB.log
          echo "${space}${msg2}" >>$DataDIR/$xGDB/logs/Pipeline_procedure.log
        ### do the work:
	      mkdir $ArchiveDIR/$xGDB # TEMPORARY!
          rsync -a $DataDIR/$xGDB/ $ArchiveDIR/$xGDB  # Direct copy of the GDBnnn directory contents (data/ conf/ logs/ 0README .sql .txt)
          mysqldump -p$dbpass -u$mysqluser $xGDB --max_allowed_packet=1024M >$ArchiveDIR/${xGDB}/${xGDB}.sql # MySQL dump of entire GDBnnn database (IMPORTANT! max_allowed_packet)
          
#??          echo "update xGDB_Log set Restore_From_File = '${GDBidentifier}.tar' where ID=$ID"|mysql -p$dbpass -u $mysqluser Genomes #reset this in case user previously restored from a different GDB
          
        ### Now export the log table to a flat file, to be used when restoring archive to reconstitute this table.
          echo "select * from xGDB_Log where ID=$ID"|mysql -p$dbpass -u$mysqluser Genomes -N >$ArchiveDIR/${xGDB}/xGDB_Log.txt

    ### Log this step to the xGDB pipeline procedure log and its new archive copy, as well as to the ArchiveGDB.log.
          dateTime3=$(date +%Y-%m-%d\ %k:%M:%S)
          path="$ArchiveDIR/$xGDB/"
          count3=$(find $path -type f -print| wc -l)
          msg3="$count3 files from ${DataDIR}/$xGDB copied, using rsync, to temp directory $ArchiveDIR/$xGDB/ $dateTime3" 
          echo "${space}${msg3}" >>$DataDIR/$xGDB/logs/Pipeline_procedure.log  
          echo "${space}${msg3}" >>$ArchiveDIR/${xGDB}/logs/Pipeline_procedure.log
          echo "$msg3" >>$ArchiveDIR/ArchiveGDB.log
        
        ### First, tar/bzip2 the archived data, conf and log directories and sql files, and get a file count
        
           msg4="${space} Now creating .tar archive first stage: tar -pcjf ${xGDB}.tar.bz2 conf data logs  ${xGDB}.sql "
           echo "$msg4" >>$ArchiveDIR/ArchiveGDB.log
           echo "$msg4" >>$DataDIR/$xGDB/logs/Pipeline_procedure.log
           echo "$msg4" >>$ArchiveDIR/${xGDB}/logs/Pipeline_procedure.log

          cd $ArchiveDIR/${xGDB}
          tar -pcjf ${xGDB}.tar.bz2 conf data logs  ${xGDB}.sql  # retain permissions with -p http://www.linfo.org/tar.html
          count2=$(tar -tf ${xGDB}.tar.bz2|wc -l)
          
        ### Next, tar the bzip tarball together with the text files -- we want to be able to retrieve them quickly rather than bury them in a big tarball
           dateTime5=$(date +%Y-%m-%d\ %k:%M:%S)
           msg5="${space} Now creating .tar archive second stage: tar -pcf ${GDBidentifier}.tar  ${xGDB}.tar.bz2 xGDB_Log.txt 0README-${xGDB}* $dateTime5 "
           echo "$msg5" >>$ArchiveDIR/ArchiveGDB.log
           echo "$msg5" >>$DataDIR/$xGDB/logs/Pipeline_procedure.log
           echo "$msg5" >>$ArchiveDIR/${xGDB}/logs/Pipeline_procedure.log
           
          tar -pcf ${GDBidentifier}.tar  ${xGDB}.tar.bz2 xGDB_Log.txt 0README-${xGDB}*  # filename; retain permissions with -p http://www.linfo.org/tar.html
          
        ### move the archive tarball up a level, out of the temporary directory, and remove the temp directory
        
          mv $ArchiveDIR/${xGDB}/${GDBidentifier}.tar $ArchiveDIR/${GDBidentifier}.tar
          rm -rf ${ArchiveDIR}/${xGDB} 
          
        ### if archive (name).tar successfully created
          if [ -s $ArchiveDIR/${GDBidentifier}.tar ] # if we succeeded in creating the archive
          then 
            dateTime6=$(date +%Y-%m-%d\ %k:%M:%S)
            msg6 ="Created $xGDB Archive: $ArchiveDIR/${GDBidentifier}.tar ($count3 files and directories) from $VM $dateTime6"
            echo "$msg6" >>$ArchiveDIR/ArchiveGDB.log
            echo "${space}${msg6}" >>$DataDIR/$xGDB/logs/Pipeline_procedure.log
            
       ### update the logs with "archive complete"
            msg7= "Archive complete for $xGDB from $VM  $dateTime6 "
            echo "$msg7" >>$ArchiveDIR/ArchiveGDB.log
            echo " " >>$ArchiveDIR/ArchiveGDB.log
            echo "$dline" >>$ArchiveDIR/ArchiveGDB.log
            echo "" >>$ArchiveDIR/ArchiveGDB.log
            echo "${space}${msg7}">>$DataDIR/$xGDB/logs/Pipeline_procedure.log  
       ### remove the backup archive file, if any.
            rm   $ArchiveDIR/backup_${current_archive} # removes backup archive directory
       ### Update time stamp for this GDB in MySQL Genomes.xGDB_Log
            echo "update xGDB_Log set Archive_Date = now() where ID=$ID"|mysql -p$dbpass -u $mysqluser Genomes
       ### Update Archive File  for this GDB in MySQL Genomes.xGDB_Log
            echo "update xGDB_Log set Archive_File = '${GDBidentifier}.tar' where ID=$ID"|mysql -p$dbpass -u $mysqluser Genomes #This is the archive file
          else
       ### We couldn't complete the process. Restore the old archive         
	        mv $ArchiveDIR/backup_${current_archive} $ArchiveDIR/${current_archive}
       ### update the ArchiveGDB log with "archive not done"
            dateTime7=$(date +%Y-%m-%d\ %k:%M:%S)
            msg7="ERROR: A new archive could not be created for $xGDB $space $dateTime1 from $VM $dateTime7"
            echo "$msg7" >>$ArchiveDIR/ArchiveGDB.log
            echo "____________________________" >>$ArchiveDIR/ArchiveGDB.log
            echo "" >>$ArchiveDIR/ArchiveGDB.log
            echo "${space}ERROR: $msg7">>$DataDIR/$xGDB/logs/Pipeline_procedure.log 
            echo "ERROR: $msg7">>$DataDIR/$xGDB/logs/Pipeline_error.log 
         fi
      fi
	  if [ "$file_count" -gt "1" ] 
      then
        dateTime8=$(date +%Y-%m-%d\ %k:%M:%S)
        msg8 "More than one previous archive exists for $xGDB. A new archive could not be created. $dateTime8 from $VM"
        echo "$msg8" >>$ArchiveDIR/ArchiveGDB.log
        echo "____________________________" >>$ArchiveDIR/ArchiveGDB.log
        echo "" >>$ArchiveDIR/ArchiveGDB.log
        echo "${space}ERROR: $msg8">>$DataDIR/$xGDB/logs/Pipeline_procedure.log 
        echo "ERROR: $msg8">>$DataDIR/$xGDB/logs/Pipeline_error.log 
      fi

        dateTime9=$(date +%Y-%m-%d\ %k:%M:%S)
		echo "update xGDB_Log set Status = \"Current\" where ID=$ID"|mysql -p$dbpass -u $mysqluser Genomes
		## Final log:
		echo "* END of script: xGDB_ArchiveOneGDB.sh - Create a GDB Archive on Data volume. $dateTime9">>$DataDIR/$xGDB/logs/Pipeline_procedure.log
		echo "$dline">>$DataDIR/$xGDB/logs/Pipeline_procedure.log
		echo "">>$DataDIR/$xGDB/logs/Pipeline_procedure.log
else 
        dateTime1=$(date +%Y-%m-%d\ %k:%M:%S)
        msg1= "ERROR: Could not update ArchiveGDB due to missing directory or permissions"
        echo "${space}ERROR: ${msg1}">>$DataDIR/$xGDB/logs/Pipeline_procedure.log
        echo "ERROR: $msg1">>$DataDIR/$xGDB/logs/Pipeline_error.log 
fi

