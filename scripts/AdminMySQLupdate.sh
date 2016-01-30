## this script is for updating MySQL database 'Admin' with one new table, and setting MySQL permissions for this JPD 11-6-12. \
## useage: sudo /xGDBvm/scripts/AdminMySQLupdate.sh
while read dbpass
	do
	   echo "$dbpass"
	done < /xGDBvm/admin/dbpass
mysql -u gdbuser -p$dbpass Admin< /xGDBvm/scripts/AdminFrame.sql #add admin table
echo "GRANT ALL ON Admin.admin TO 'gdbuser'@'localhost'"|mysql -p$dbpass -u gdbuser
echo "GRANT SELECT ON Admin.admin TO 'xgdbSELECT'@'localhost'"|mysql -p$dbpass -u gdbuser  ## added 1-14-13 wq