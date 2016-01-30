#!/bin/sh
# updated 8-6-13 J Duvick
# useage: Drops GDBnn database table and reverts Genomes.xGDB_Log.Status from to "Development". 

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
if echo "$xGDB" | grep -qs 'GDB[0-9][0-9][0-9]'  # make sure the directory name passed from view.php is standard form
then
    if echo "$ID" | grep -qs '^[0-9]\+$' # make sure the ID passed from view.php is numeric 
    then
        if [ -d $gdb_path ] # make sure the directory exists for this GDB
        then
        
            ProcessTimeStamp=$(echo "select max(ProcessTimeStamp) from Processes where GDB = \"$xGDB\" and (Outcome=\"created\" or Outcome=\"updated\")"|mysql -p$dbpass -u $mysqluser Genomes -N) # most recent process.
            rm -rf /xGDBvm/data/$xGDB
            rm -rf /xGDBvm/tmp/$xGDB
            echo "drop database $xGDB"|mysql -p$dbpass -u $mysqluser
            echo "update Genomes.xGDB_Log set Status=\"Development\", Create_Date=\"\", Config_Date = now(), Update_Status=\"\", Update_Date=\"\", Update_History=\"\" where ID=\"$ID\"" |mysql -p$dbpass -u $mysqluser 
            echo "update Genomes.xGDB_Log set GSQ_Job_EST=\"\", GSQ_Job_EST_Result=\"\",  GSQ_Job_cDNA=\"\", GSQ_Job_cDNA_Result=\"\",  GSQ_Job_PUT=\"\", GSQ_Job_PUT_Result=\"\", GTH_Job=\"\", GTH_Job_Result=\"\"  where ID=\"$ID\"" |mysql -p$dbpass -u $mysqluser 
            echo "update Genomes.xGDB_Log set Restore_Date=\"\" where ID=\"$ID\"" |mysql -p$dbpass -u $mysqluser  # NOTE; Don't touch Archive_Date or Restore_From_File; these are needed to restore archive
            echo "UPDATE Processes set Outcome=\"dropped\" where ProcessTimeStamp = \"$ProcessTimeStamp\""|mysql -p$dbpass -u $mysqluser Genomes
        fi
    fi
fi