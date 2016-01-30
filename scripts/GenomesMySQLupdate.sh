## this script is for updating MySQL database 'Genomes' with new column in xGDB_Log table JPD 10-9-12. \
## useage: sudo /xGDBvm/scripts/GenomesMySQLupdate.sh

echo "alter table Genomes.xGDB_Log add column Update_Descriptions varchar(20) DEFAULT '' after Update_Data_GeneModel"|mysql -pxgdb -u gdbuser