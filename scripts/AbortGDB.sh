#!/bin/sh
# This script attempts to kill all processes associated with a GDB pipeline process (xGDB_Procedure.sh) or a validation script (xGDB_ValidateFiles.sh)
# It updates database tables

xGDB=$1;
ID=$2;
while read dbpass
	do
	   echo "$dbpass"
	done < /xGDBvm/admin/dbpass
mysqluser='gdbuser';
### kill master validation script (ADDED 9/23/14 JPD) ###
pgrep xGDB_ValidateFiles | xargs kill -9;
### kill daughter scripts that may have launched before abort command (ADDED 9/23/14 JPD) ###
pgrep xGDB_validatefile | xargs kill -9;
### kill master pipeline script ###
pgrep xGDB_Procedure | xargs kill -9;
### kill any daughter scripts that may have launched before abort command ###
pgrep GeneSeqer | xargs kill -9;
pgrep gth | xargs kill -9;
pgrep augustus | xargs kill -9;
pgrep run_evm | xargs kill -9;
pgrep evidence_modeler | xargs kill -9;
pgrep perl | xargs kill -9 #kills /xGDBvm/src/CpGAT/fct/cpgat.xgdb.pl
### drop GDB database and remove GDB destination directories
echo "drop database $xGDB"|mysql -p$dbpass -u $mysqluser
rm -rf /xGDBvm/data/$xGDB
rm -rf /xGDBvm/tmp/$xGDB
rm -rf /xGDBvm/data/scratch/$xGDB # scratch directory UPDATED 9/23/14
### update global database ###
echo "update xGDB_Log set Status=\"Development\", Process_Type=\"\", Create_Date=\"\", Config_Date = now(), Update_Status=\"\", Update_Date=\"\", Update_History=\"\"  where ID=\"$ID\"" |mysql -p$dbpass -u $mysqluser Genomes

### update Processes database table ###
ProcessTimeStamp=$(echo "select max(ProcessTimeStamp) from Processes where GDB = \"$xGDB\" and Outcome=\"\""|mysql -p$dbpass -u $mysqluser Genomes -N) # most recent process.
if [ $ProcessTimeStamp != "" ] # check whether there is a GDB pipeline running, as opposed to a validation script
then
  echo "UPDATE Processes set Outcome=\"aborted\" where ProcessTimeStamp = \"$ProcessTimeStamp\""|mysql -p$dbpass -u $mysqluser Genomes
fi


