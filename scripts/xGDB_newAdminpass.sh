# This script updates the admin password file .htpass_admin, limiting access to admin  conf and jobs directories
# It is called by adminpass_exec.php when user has entered a new admin password using setup.php.
# last updated: 3/22/15 JPD
# 1. get new password
while getopts "p:" OPTION
do
        case $OPTION in
          p) Adminpass=$OPTARG #  password
          ;;
        esac
done

# 2. create .htaccess (if not already in place) from template - this file references .htpass_admin
# NOTE: apache (or group:xgdb) must have write permssion on these directories!
cp /xGDBvm/admin/dist.htaccess /xGDBvm/admin/.htaccess 
cp /xGDBvm/XGDB/conf/dist.htaccess /xGDBvm/XGDB/conf/.htaccess
cp /xGDBvm/XGDB/jobs/dist.htaccess /xGDBvm/XGDB/jobs/.htaccess #1-26-13 added

# 3. overwrite (or create) /xGDBvm/admin/.htpass_admin with new password (this file is referenced by ALL .htaccess files created in step 2 above)
/usr/bin/htpasswd -c -b /xGDBvm/admin/.htpass_admin admin $Adminpass  # -c for create new; -b for batchwise
	
# 4. record the update status, date/time in the Admin.admin table (using the new password)
mysqluser='gdbuser'
while read dbpass
	do
	   echo "$dbpass"
	done < /xGDBvm/admin/dbpass
	
		dateTime=$(date +%Y-%m-%d\ %k:%M:%S)

touch /xGDBvm/admin/adminpassword  # Add flag.
