#!/bin/bash
#### Useage: creates a data archive from all GDB under /xGDBvm/input/ArchiveAll/ ########
#### Called by archive_exec.php ########
#### Updated 5-24-14 J Duvick

VM=$(uname -n|cut -d "." -f 1) # identifies this VM. For some reason it doesn't work if there are spaces before/after the pipe.

ROOT='/xGDBvm'
ScriptDIR='/xGDBvm/scripts'
DataDIR="/xGDBvm/data";
#InputDIR="/xGDBvm/input";
ArchiveAllDIR="$DataDIR/ArchiveAll" # unique to this VM, since more than one VM may have archives here
while read dbpass
	do
	   echo "$dbpass"
	done < /xGDBvm/admin/dbpass
mysqluser='gdbuser';

### Create ArchiveAll directory if it doesn't exist
mkdir $ArchiveAllDIR

### Time Stamp Genomes.xGDB_Log table (for all rows -- all GDB)
echo "update xGDB_Log set Archive_All_Date = now() where Status !='Development'"|mysql -p$dbpass -u $mysqluser Genomes # NOTE includes Current and Locked GDB

### Dump the GLOBAL MySQL tables to ArchiveAll
mysqldump --no-defaults -p$dbpass -u$mysqluser Genomes >$ArchiveAllDIR/Genomes.sql
mysqldump --no-defaults -p$dbpass -u$mysqluser yrgate >$ArchiveAllDIR/yrgate.sql

### Grab all GDBnnn directory names from /xGDBvm/data and initiate archive loop
cd $DataDIR
GDBdirs=$(ls -d GDB[0-9][0-9][0-9]) # e.g. "GDB001  GDB002" separated by space/tab
for file in $GDBdirs
do
	if [ -d $DataDIR/$file ]
	then
        echo "${DataDIR}/${file}"
    ### Create GDBnnn archive directory if it doesn't exist
        xGDB=$file
        mkdir $ArchiveAllDIR/$xGDB 
    ### Copy all to GDBnnn archive ###
	    cp -r $DataDIR/${xGDB} $ArchiveAllDIR/ # Direct copy of the GDBnnn directory and its contents (i.e. data/ conf/ logs/) -OVERWRITES OLD ONE
    ### Replace existing MySQLdump with current MySQL dump (which may include yrGATE annotations, etc, dynamically created)
        mysqldump --no-defaults -p$dbpass -u$mysqluser $xGDB >$ArchiveAllDIR/${xGDB}/XGDB_MYSQL/${xGDB}.sql
    ### Update both "live" and "archived" logfiles and the archive all log.
        space="  "
        dateTime1=$(date +%Y-%m-%d\ %k:%M:%S)

	### Update ArchiveAll log with DBname information
	    echo "Archive Complete for $xGDB $space $DBname $space $dateTime1 from $VM " >>$ArchiveAllDIR/ArchiveAll.log
    
        msg=" files copied to   " 
        path="$ArchiveAllDIR/$xGDB/"
        count=$(find $path -type f -print| wc -l)
        echo "$space-$count$msg$path$space$dateTime" >>$DataDIR/$xGDB/logs/Pipeline_procedure.log
        echo "$space-$count$msg$path$space$dateTime" >>$ArchiveAllDIR/$xGDB/logs/Pipeline_procedure.log # Update the log in both places!
        echo "$count$msg$path$space$dateTime" >>$ArchiveAllDIR/ArchiveAll.log

    ### Create 0README with GDB ID and name (http://stackoverflow.com/questions/8770267/bash-shell-script-to-grab-a-substring) 
         x=$xGDB
         y=${x%GDB} # right strip GDB
         z=${y#*0} # left strip zeros
         ID=$z # leaves integer ID
	fi
done
    ### Finally, update the ArchiveAll log one more time
	dateTime99=$(date +%Y-%m-%d\ %k:%M:%S)
	msg99="- Archive(s) updated under ${ArchiveAllDIR}/ for the following GDB: ${GDBdirs}:"
	echo "_______________________________"
	echo "$msg99$dateTime99" >>$ArchiveAllDIR/ArchiveAll.log
