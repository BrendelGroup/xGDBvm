#!/bin/bash
### Useage: called from archive_exec.php via xGDBvm interface########
### Removes Archive_All timestamp from Genomes.xGDB_Log and delete the /xGDBvm/data/ArchiveAll/directory contents
### Recreates the ArchiveAll.log and logs the deletion.
### Updated: 5-24-2014 J Duvick

VM=$(uname -n|cut -d "." -f 1) # identifies this VM

DataDIR="/xGDBvm/data"
#InputDIR="/xGDBvm/input"
ArchiveDIR="$DataDIR/ArchiveAll"

while read dbpass
	do
	   echo "$dbpass"
	done < /xGDBvm/admin/dbpass
mysqluser='gdbuser';

### Remove Archive All time stamp from Genomes.xGDB_Log table.
	if [ -d $ArchiveDIR ] #if ArchiveGDB directory exists for this GDB
	then
        echo "update xGDB_Log set Archive_All_Date = ''"|mysql -p$dbpass -u $mysqluser Genomes ## Remove timestamp (all records)
    
### Update archives on both "live" and "archived" logfiles
### First grab directory names for the GDBnnn to be deleted:
        cd $ArchiveDIR
        GDBdirs=$(ls -d GDB[0-9][0-9][0-9]) # e.g. "GDB001  GDB002"

### Remove ALL the contents under ArchiveAll directory

        rm -rf $ArchiveDIR/*

### Log the action to the (recreated) ArchiveAll log

        space="  "
        dateTime=$(date +%Y-%m-%d\ %k:%M:%S)
        msg="$space All GDB archives ($GDBdirs) were deleted from $ArchiveDIR - $dateTime on $VM " 
        echo "$msg" >$ArchiveDIR/ArchiveAll.log
	fi
