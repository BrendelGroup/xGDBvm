#!/bin/bash
####... called from archive_exec.php via xGDBvm interface########
#### removes Archive GDB data from Genomes.xGDB_Log and delete the /xGDBvm/data/ArchiveGDB/GDBnnn directory
### Updated: 2-25-2014 J Duvick

VM=$(uname -n|cut -d "." -f 1) # identifies this VM

xGDB=$1
ID=$2
archive_file=$3
ROOT='/xGDBvm'
ScriptDIR='/xGDBvm/scripts'
#InputDIR="/xGDBvm/data"
DataDIR="/xGDBvm/data" # Location of the archive directory
ArchiveDIR="$DataDIR/ArchiveGDB"
archive_path="$ArchiveDIR/$archive_file"
space="  "
dline="-------------------------------------------------------------------------------------------------------------------------" # 125 col
sline="*************************************************************************************************************************" # 125 col

while read dbpass
	do
	   echo "$dbpass"
	done < /xGDBvm/admin/dbpass
mysqluser='gdbuser';

### Initiate Headers for Log Files

dateTime1=$(date +%Y-%m-%d\ %k:%M:%S)
echo "">>$DataDIR/$xGDB/logs/Pipeline_procedure.log
echo "$sline">>$DataDIR/$xGDB/logs/Pipeline_procedure.log
echo "* xGDB_DeleteOneArchive.sh - Delete a GDB Archive from Data volume. $dateTime1">>$DataDIR/$xGDB/logs/Pipeline_procedure.log
echo "$sline">>$DataDIR/$xGDB/logs/Pipeline_procedure.log
echo "">>$DataDIR/$xGDB/logs/Pipeline_procedure.log

echo "" >>$ArchiveDIR/ArchiveGDB.log
echo "$sline" >>$ArchiveDIR/ArchiveGDB.log
echo "* xGDB_DeleteOneArchive.sh -  Delete a GDB Archive from Data volume. $dateTime1" >>$ArchiveDIR/ArchiveGDB.log
echo "$sline" >>$ArchiveDIR/ArchiveGDB.log
echo "" >>$ArchiveDIR/ArchiveGDB.log


# validate inputs
if echo "$archive_file" | grep -qs '^GDB[0-9][0-9][0-9]-[A-Za-z0-9-]*.tar'  # make sure the archive file name passed from archive_exec.php is standard form, e.g. GDB001-Description-Species.tar
then
    if echo "$ID" | grep -qs '^[0-9]\+$' # make sure the ID passed from archive_exec.php is numeric 
    then
        if [ -f $archive_path ] #make sure the path to the file exists for this GDB
        then
            echo "$archive_path"
        ### Remove the archive
            rm -rf $ArchiveDIR/$archive_file # with enough safeguards in place we are confident only desired file is being deleted
        ### Grab the archive date before deleting the archive records from Genomes.xGDB_Log 
	        oldDate=$(echo "select Archive_Date from Genomes.xGDB_Log where ID=$ID"|mysql --skip-column-names -p$dbpass -u $mysqluser)
            echo "update xGDB_Log set Archive_Date = '' where ID=$ID"|mysql -p$dbpass -u $mysqluser Genomes #remove date stamp for archive since it is going away
            echo "update xGDB_Log set Restore_From_File = '' where ID=$ID"|mysql -p$dbpass -u $mysqluser Genomes #reset this in case user previously restored from a different GDB
            echo "update xGDB_Log set Archive_File = '' where ID=$ID"|mysql -p$dbpass -u $mysqluser Genomes #reset this to reflect absence of a legitimate archive
        ### Update log: Grab DBname and update GDB pipeline log and ArchiveGDB log with name, archive date, etc.
        
	        DBname=$(echo "select DBname from Genomes.xGDB_Log where ID=$ID"|mysql --skip-column-names -p$dbpass -u $mysqluser)
	        
            dateTime2=$(date +%Y-%m-%d\ %k:%M:%S)
        
            msg2=" Archive for $xGDB ($DBname), archived on $oldDate, has been deleted from $ArchiveDIR/ $dateTime2 on $VM " 
        
            echo "$msg2" >>$DataDIR/$xGDB/logs/Pipeline_procedure.log
            echo "$msg2" >>$ArchiveDIR/ArchiveGDB.log
        else
            space="  "
            dateTime2=$(date +%Y-%m-%d\ %k:%M:%S)
            msg2=" Could not delete $xGDB ($DBname) archive from $ArchiveGDB -- possibly the directory does not exist or the file has been renamed. $dateTime2" 
    
            echo "${space}ERROR: $msg2">>$DataDIR/$xGDB/logs/Pipeline_procedure.log
            echo "$msg2">>$DataDIR/$xGDB/logs/Pipeline_error.log
        fi
    fi
fi

# Final log:
dateTime4=$(date +%Y-%m-%d\ %k:%M:%S)
echo "* END of script: xGDB_DeleteOneArchive.sh - Delete GDB Archive from Data Directory. $dateTime4">>$DataDIR/$xGDB/logs/Pipeline_procedure.log
echo "$dline">>$DataDIR/$xGDB/logs/Pipeline_procedure.log
echo "">>$DataDIR/$xGDB/logs/Pipeline_procedure.log
