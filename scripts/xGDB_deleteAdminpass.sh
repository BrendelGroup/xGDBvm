# This script removes the admin password file .htpass_xgdb, allowing access to /xGDBvm/admin and /xGDBvm/XGDB/conf
# It is called by adminpass_exec.php when user has requested remove password using setup.php.
# updated: 3-22-15 JPD

# 1. remove .htaccess (if not already in place) - this file references .htpass_admin (NOTE: Add command here for ANY new directory you want to configure for password protetion via the Admin pw)
rm /xGDBvm/admin/.htaccess
rm /xGDBvm/XGDB/conf/.htaccess
rm /xGDBvm/XGDB/jobs/.htaccess

# 2. remove .htpass_admin (removes password hash from the "master" password file; this file will be recreated if user again selects admin password)

rm /xGDBvm/admin/.htpass_admin

# 3. record the update status, date/time in the Admin.admin table (using the new password)
mysqluser='gdbuser'
while read dbpass
	do
	   echo "$dbpass"
	done < /xGDBvm/admin/dbpass
	
		dateTime=$(date +%Y-%m-%d\ %k:%M:%S)

# 4. Remove password flag
rm /xGDBvm/admin/adminpassword
