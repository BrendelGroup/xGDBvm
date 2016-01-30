# This script updates the admin password file .htpass_admin, limiting access to admin and conf directories
# It is called by dbpass_exec.php after user has changed the mysql password for user=gdbuser using setup.php
#
# 1. read the new MySQL password from the temp file new_dbpass (created by dbpass_exec.php)
while read new_dbpass
	do
	   echo "$new_dbpass"
	done < /xGDBvm/admin/new_dbpass


# 2. read the current MySQL password from dbpass
while read dbpass
	do
	   echo "$dbpass"
	done < /xGDBvm/admin/dbpass

# 3. update user/password in MySQL using old MySQL password

mysqluser='gdbuser'

echo "update user set password=PASSWORD('$new_dbpass') where User='gdbuser'" | mysql -p$dbpass -u $mysqluser mysql

echo "flush privileges" | mysql -p$dbpass -u $mysqluser mysql

# 4. overwrite current password file with new password file (all scripts will now reference the new pw)

mv /xGDBvm/admin/new_dbpass /xGDBvm/admin/dbpass

# 5. read the new, current MySQL password so we can use it in step 6 (to do: add error loop in case it is not readable?)

while read dbpass
	do
	   echo "$dbpass"
	done < /xGDBvm/admin/dbpass
	
# 6. record the update status, date/time in the Admin.admin table (using the new password)
	
		dateTime=$(date +%Y-%m-%d\ %k:%M:%S)

echo "insert into admin (dbpass_update, dbpass_update_date) values('Yes', '$dateTime')" | mysql -p$dbpass -u $mysqluser Admin
