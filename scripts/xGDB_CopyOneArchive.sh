#!/bin/bash
####... called from archive_exec.php via xGDBvm interface########
#### copies Archive GDB data from /xGDBvm/data/ArchiveGDB/ to /xGDBvm/input/archive/
#### overwrites any old archive 
### Updated: 1-26-16 J Duvick to update to new DataStoreDIR path.

VM=$(uname -n|cut -d "." -f 1) # identifies this VM
xGDB=$1
ID=$2
archive_file=$3 # the archive tarball e.g. GDB001-[name-description].tar
DataDIR="/xGDBvm/data"
ArchiveDIR="/xGDBvm/data/ArchiveGDB"
DataStoreDIR="/xGDBvm/input/xgdbvm"
DataStoreArchiveDIR="$DataStoreDIR/archive"
space="  " # for indenting in pipeline log
sline="*************************************************************************************************************************" # 125 col
dline="-------------------------------------------------------------------------------------------------------------------------" # 125 col

### If it doesn't exist, create DataStoreArchiveGDB directory:
if [ ! -d $DataStoreArchiveDIR ] # If DataStoreArchiveGDB does not exist then create it
then
  mkdir $DataStoreArchiveDIR
fi

while read dbpass
	do
	   echo "$dbpass"
	done < /xGDBvm/admin/dbpass
mysqluser='gdbuser';

### Set Status = "Locked" for this GDB

 echo "update xGDB_Log set Status = \"Locked\" where ID=$ID"|mysql -p$dbpass -u $mysqluser Genomes

### Initiate Headers for Log Files

            dateTime1=$(date +%Y-%m-%d\ %k:%M:%S)
            echo "">>$DataDIR/$xGDB/logs/Pipeline_procedure.log
            echo "$sline">>$DataDIR/$xGDB/logs/Pipeline_procedure.log
            echo "* xGDB_CopyOneArchive.sh - Copy Archive GDB to Data Store. $dateTime1">>$DataDIR/$xGDB/logs/Pipeline_procedure.log
            echo "$sline">>$DataDIR/$xGDB/logs/Pipeline_procedure.log
            echo "">>$DataDIR/$xGDB/logs/Pipeline_procedure.log
            
            echo "" >>$ArchiveDIR/ArchiveGDB.log
            echo "$sline" >>$ArchiveDIR/ArchiveGDB.log
            echo "* xGDB_CopyOneArchive.sh - Copy Archive GDB to Data Store. $dateTime1" >>$ArchiveDIR/ArchiveGDB.log
            echo "$sline" >>$ArchiveDIR/ArchiveGDB.log
            echo "" >>$ArchiveDIR/ArchiveGDB.log

### Log start of process

            msg1="Preparing to copy $archive_file to DataStore directory, accessible on the VM through $DataStoreArchiveDIR. $dateTime1" 

            echo "$space$msg1">>$DataDIR/$xGDB/logs/Pipeline_procedure.log            
            echo "$msg1" >>$ArchiveDIR/ArchiveGDB.log


# validate inputs
if echo "$archive_file" | grep -qs '^GDB[0-9][0-9][0-9]-[A-Za-z0-9-]*.tar'  # make sure the archive file name passed from archive_exec.php is standard form, e.g. GDB001-Description-Species.tar
then
    if echo "$ID" | grep -qs '^[0-9]\+$' # make sure the ID passed from archive_exec.php is numeric 
    then
        if [ -d $DataStoreArchiveDIR ] #make sure the path to the file exists for this GDB
        then
            dateTime1=$(date +%Y-%m-%d\ %k:%M:%S)
           msg2= "Copying $archive_file to $DataStoreArchiveDIR using rsync $dateTime1" >>$ArchiveDIR/ArchiveGDB.log
            echo "$msg2" >>$DataDIR/$xGDB/logs/Pipeline_procedure.log
            echo "$msg2" >>$ArchiveDIR/ArchiveGDB.log
            rsync -a $ArchiveDIR/$archive_file  $DataStoreArchiveDIR/$archive_file  # Direct copy of the tarball
            
        ### Update log: Grab DBname and update GDB pipeline log and ArchiveGDB log with name, archive date, etc.
        
	        DBname=$(echo "select DBname from Genomes.xGDB_Log where ID=$ID"|mysql --skip-column-names -p$dbpass -u $mysqluser)
	       	Date=$(echo "select Archive_Date from Genomes.xGDB_Log where ID=$ID"|mysql --skip-column-names -p$dbpass -u $mysqluser)
 
            dateTime3=$(date +%Y-%m-%d\ %k:%M:%S)
            msg3="The file $archive_file (created on $Date) has been copied to $DataStoreArchiveDIR (on the Data Store) $dateTime2" 
        
            echo "$space$msg3" >>$DataDIR/$xGDB/logs/Pipeline_procedure.log
            echo "" >>$DataDIR/$xGDB/logs/Pipeline_procedure.log

            echo "$msg3" >>$ArchiveDIR/ArchiveGDB.log
            echo "" >>$ArchiveDIR/ArchiveGDB.log

        else # something went wrong with the destination archive directory.
            dateTime3=$(date +%Y-%m-%d\ %k:%M:%S)
            msg3="Could not copy archive $archive_file to $DataStoreArchiveDIR. Check to make sure this destination path exists. $dateTime3" 
    
            echo "${space}ERROR: $msg3">>$DataDIR/$xGDB/logs/Pipeline_procedure.log
            echo "ERROR: $msg3">>$DataDIR/$xGDB/logs/Pipeline_error.log
            echo "" >>$DataDIR/$xGDB/logs/Pipeline_procedure.log
            echo "$msg3" >>$ArchiveDIR/ArchiveGDB.log
            echo "" >>$ArchiveDIR/ArchiveGDB.log
        fi
    fi
else # the source file isn't there
            dateTime2=$(date +%Y-%m-%d\ %k:%M:%S)
            msg2="Could not copy archive $archive_file to $DataStoreArchiveDIR. Check to make sure this archive file exists. $dateTime2" 
            echo "${space}ERROR: $msg2">>$DataDIR/$xGDB/logs/Pipeline_procedure.log
            echo "ERROR: $msg2">>$DataDIR/$xGDB/logs/Pipeline_error.log
            echo "$msg2" >>$ArchiveDIR/ArchiveGDB.log
            echo "" >>$ArchiveDIR/ArchiveGDB.log
fi

echo "update xGDB_Log set Status = \"Current\" where ID=$ID"|mysql -p$dbpass -u $mysqluser Genomes

# Final log:
dateTime4=$(date +%Y-%m-%d\ %k:%M:%S)
echo "* END of script: xGDB_CopyOneArchive.sh - Copy Archive GDB to Data Store. $dateTime4">>$DataDIR/$xGDB/logs/Pipeline_procedure.log
echo "$dline">>$DataDIR/$xGDB/logs/Pipeline_procedure.log
echo "">>$DataDIR/$xGDB/logs/Pipeline_procedure.log
