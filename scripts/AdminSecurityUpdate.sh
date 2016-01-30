## this script is for updating htaccess files to limit entry 11-8-12. \
## purpose: user can direct password protection of admin/conf directories; entire xGDBvm website; or change MySQL password for user 'gdbuser'
## useage: sudo /xGDBvm/scripts/AdminSecurityUpdate.sh

## Assign directory ownership to Apache (NOT reflexive -R) so scripts can copy or create .htaccess files from template dist.htaccess here.
chown apache:xgdb /xGDBvm
chown apache:xgdb /xGDBvm/admin/
chown apache:xgdb /xGDBvm/XGDB/conf/

## Change permissions on /xGDBvm/admin/dbpass so that Apache can write mysql password to it.
chmod 664  /xGDBvm/admin/dbpass
chown apache:xgdb  /xGDBvm/admin/dbpass


