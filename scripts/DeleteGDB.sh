#!/bin/sh
# This script called by archive.php removes ALL output data for a single GDB including MySQL databases, output data, archive, and tmp directory. It also resets the auto-increment of xGDB_Log
# USE WITH CAUTION and make sure the user is adequately warned of the consequences.
# updated 5-20-14 J Duvick

xGDB=$1;
ID=$2;
data_path="/xGDBvm/data/";
gdb_path="${data_path}${xGDB}";
while read dbpass
	do
	   echo "$dbpass"
	done < /xGDBvm/admin/dbpass
mysqluser='gdbuser';


# Validate inputs
if echo "$xGDB" | grep -qs 'GDB[0-9][0-9][0-9]'  # make sure the directory name passed from archive.php is standard form
then
    if echo "$ID" | grep -qs '^[0-9]\+$' # make sure the ID passed from view.php is numeric 
    then
		status=$(echo "select Status from Genomes.xGDB_Log where ID=$ID"|mysql -p$dbpass -u $mysqluser -N) ## Development or Current
		archive_file=$(echo "select Archive_File from Genomes.xGDB_Log where ID=$ID"|mysql -p$dbpass -u $mysqluser -N) ## Unique archive file, e.g. GDB003-Example-4---CpGAT-Option-20140520-125326.tar
		last_id=$(echo "select max(ID) from Genomes.xGDB_Log"|mysql -p$dbpass -u $mysqluser -N) # Only allow last GDB to be deleted
        if [ "$last_id" -eq "$ID" ]  # make sure the ID passed from archive.php matches the last ID
        then
			if [ -d $gdb_path ] # this applies only if Status=Current; but we make sure the directory exists for this GDB
			then
            ProcessTimeStamp=$(echo "select max(ProcessTimeStamp) from Processes where GDB = \"$xGDB\" and (Outcome=\"created\" or Outcome=\"updated\")"|mysql -p$dbpass -u $mysqluser Genomes -N) # most recent process.
		  # Remove GDB directory and contents, clean out Genome database tables, reset auto-increment, and drop GDB database
				rm -rf /xGDBvm/data/$xGDB
				rm -rf /xGDBvm/tmp/$xGDB
			fi
		  # Now remove this record from xGDB_Log
			echo "DELETE FROM Genomes.xGDB_Log WHERE ID=$ID" |mysql -p$dbpass -u $mysqluser
			echo "ALTER TABLE Genomes.xGDB_Log AUTO_INCREMENT = $ID" |mysql -p$dbpass -u $mysqluser
			echo "DROP DATABASE IF EXISTS $xGDB"|mysql -p$dbpass -u $mysqluser
			
            echo "UPDATE Processes set Outcome=\"deleted\" where ProcessTimeStamp = \"$ProcessTimeStamp\""|mysql -p$dbpass -u $mysqluser Genomes
		  # Remove archive file, if it exists (applies to both Current and Development GDB)
			if [ -f /xGDBvm/data/ArchiveGDB/$archive_file ]
			then
			  rm -rf /xGDBvm/data/ArchiveGDB/$archive_file 
			fi            
		fi
    fi
fi
