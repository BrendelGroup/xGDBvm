# This script removes the xgdb password file .htpass_xgdb, allowing access to /xGDBvm/
# It is called by xgdbpass_exec.php when user has requested remove password using setup.php.
# last updated: 3/22/15 JPD 
# 1. remove .htaccess (if not already in place) - this file references .htpass_admin
rm /xGDBvm/.htaccess

# 2. remove .htpass_xgdb  (removes password hash; this file will be recreated if user again selects xgdb password)
rm /xGDBvm/.htpass_xgdb

# 3. record the update status, date/time in the Admin.admin table (using the new password)
mysqluser='gdbuser'
while read dbpass
	do
	   echo "$dbpass"
	done < /xGDBvm/admin/dbpass
	
		dateTime=$(date +%Y-%m-%d\ %k:%M:%S)

# 4. Remove password flag
rm /xGDBvm/admin/xgdbpassword
