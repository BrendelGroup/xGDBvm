## this TEMPORARY script is for updating MySQL database 'Admin' JPD 1-25-13. \
## useage: sudo /xGDBvm/scripts/CompResUpdate.sh
while read dbpass
	do
	   echo "$dbpass"
	done < /xGDBvm/admin/dbpass
echo "alter table Admin.admin add column `auth_url` varchar(255) NOT NULL DEFAULT ''"|mysql -p$dbpass -u gdbuser
echo "alter table Admin.admin add column `auth_url_date` varchar(32) NOT NULL DEFAULT ''"|mysql -p$dbpass -u gdbuser
echo "alter table Admin.admin add column `job_url` varchar(255) NOT NULL DEFAULT ''"|mysql -p$dbpass -u gdbuser
echo "alter table Admin.admin add column `job_url_date` varchar(32) NOT NULL DEFAULT ''"|mysql -p$dbpass -u gdbuser
echo "alter table Genomes.xGDB_Log add column `GTH_CompResources` varchar(20) DEFAULT '' after `CompResources`"|mysql -p$dbpass -u gdbuser
echo "alter table  Genomes.xGDB_Log change column `CompResources`  `GSQ_CompResources` varchar(20) DEFAULT ''"|mysql -p$dbpass -u gdbuser