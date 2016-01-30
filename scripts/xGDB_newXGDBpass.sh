# This script updates the xgdb password file .htpass_xgdb, limiting access to /xGDBvm/
# It is called by xgdbpass_exec.php when user has entered a new admin password using setup.php.
# last updated: 3/22/15 JPD

# 1. get new password
while getopts "p:" OPTION
do
        case $OPTION in
          p) XGDBpass=$OPTARG #  password
          ;;
        esac
done

# 2. create .htaccess (if not already in place) - this file references .htpass_admin
# NOTE: apache (or group:xgdb) must have write permission on these directories!
cp /xGDBvm/dist.htaccess /xGDBvm/.htaccess

# 3. overwrite .htpass_admin with new password
/usr/bin/htpasswd -c -b /xGDBvm/.htpass_xgdb user $XGDBpass  # -c for create new; -b for batchwise
	
# 4. record the update status, date/time in the Admin.admin table (using the new password)
mysqluser='gdbuser'
while read dbpass
	do
	   echo "$dbpass"
	done < /xGDBvm/admin/dbpass
	
		dateTime=$(date +%Y-%m-%d\ %k:%M:%S)

touch /xGDBvm/admin/xgdbpassword  # Add flag.
