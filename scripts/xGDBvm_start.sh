/sbin/service mysqld start
/sbin/service httpd start
mkdir /xGDBvm/data
mount /dev/sdb /xGDBvm/data
mkdir /xGDBvm/data/tmp
chown apache:xgdb /xGDBvm/INSTANCES
chown apache:xgdb /xGDBvm/src/yrGATE
chmod 775 /xGDBvm/INSTANCES
chmod 775 /xGDBvm/src/yrGATE
chmod -R 777 /xGDBvm/data/tmp
chown -R apache:xgdb /xGDBvm/data
chmod -R 775 /xGDBvm/data
ln -s /xGDBvm/data/tmp /xGDBvm/tmp
