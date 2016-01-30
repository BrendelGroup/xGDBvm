## this script is for updating MySQL database 'yrgate' with two new tables, and setting MySQL permissions for these JPD 10-3-12. \
## useage: sudo /xGDBvm/scripts/yrgateMySQLupdate.sh

mysql -pxgdb -u gdbuser yrgate< /xGDBvm/scripts/yrgateFrameUpdate.sql # update with groups and user_group tables
echo "GRANT ALL ON yrgate.user_group TO 'yrgateUser'@'localhost'"|mysql -pxgdb -u gdbuser
echo "GRANT ALL ON yrgate.projects TO 'yrgateUser'@'localhost'"|mysql -pxgdb -u gdbuser
