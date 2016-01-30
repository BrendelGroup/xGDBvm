#!/bin/bash
###### Description: Called by user, this script updates MySQL databases and tables according to the commands included below  ########
###### Its use may be required to update VMs with pre-existing data tables, to add new functionality or fix bugs #######
###### NOTE: The MySQL update may require an .sql file, in which case use the file /xGDBvm/scripts/configure-vm/MySQLupdate.sql  #######
###### Useage: $ sudo /xGDBvm/scripts/configure-vm/MySQLupdate.sh  #######

#########  MySQL credentials ###########

while read dbpass
	do
	   echo "$dbpass"
	done < /xGDBvm/admin/dbpass
mysqluser='gdbuser';


######### ==> Insert (or comment out) specific MySQL command(s) below #########

#mysql -p$dbpass -u $mysqluser Genomes < /xGDBvm/scripts/configure-vm/MySQLupdate.sql  ## currently this adds 3 tables if not exist.

#echo "alter table xGDB_Log add column Process_Type varchar(20) NOT NULL DEFAULT '' after Status" | mysql -p$dbpass -u $mysqluser Genomes

######### ==> Update the description of the purpose of this update #########

#echo "If needed, we added tables 'Datafiles' 'Processes' and 'Validation' to the database 'Genomes' and added 'Process_Type' to xGDB_Log."
