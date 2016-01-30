#!/bin/bash
#### Useage: called from restore_exec.php via xGDBvm interface (mainly from /xGDBvm/XGDB/conf/view.php) ########
#### Restores GDB to "Current" status by creating GDBnnn database, updating global tables, and restoring conf, data, and log files under /xGDBvm/data/GDBnnn/
#### The source archive is /xGDBvm/data/ArchiveGDB/GDBnnn-[description-species]-tar where GDBnnn refers to the xGDBsource and is parsed from the first part of the archive filename.
#### This script can load data from a GDBnnn archive whose ID is different from the one being restored, and it renames files and data pointers accordingly.
#### Most recent update: 3-3-2014 J Duvick

# Set variables based on arguments
xGDB=$1 		# e.g. GDB001, refers to the destination GDB
ID=$2 			# e.g. 1, refers to the destination GDB
xGDBsource=$3  # e.g. GDB002; this refers to the archive source GDB (may be identical or different from destination)
				# if the user has configured to restore a GDB other than the like-numbered one, this will have a different value than xGDB.
                # otherwise source_xGDB will have the SAME value as xGDB.
ID_source=$4	# e.g. 2

VM=$(uname -n|cut -d "." -f 1) # identifies this VM

#InputDIR="/xGDBvm/input"
DataDIR="/xGDBvm/data"
ArchiveDIR="$DataDIR/ArchiveGDB"
TmpDIR="/xGDBvm/tmp"

while read dbpass
	do
	   echo "$dbpass"
	done < /xGDBvm/admin/dbpass
mysqluser='gdbuser';

## Update status

 echo "update xGDB_Log set Restore_Date = \"In Progress\" where ID=$ID"|mysql -p$dbpass -u $mysqluser Genomes
 echo "update xGDB_Log set Status = \"Locked\" where ID=$ID"|mysql -p$dbpass -u $mysqluser Genomes

# If the GDB archive source directory exists, proceed.
#if [ -d $ArchiveDIR/$xGDBsource/data ]
# If the GDB archive source tarball exists, proceed.
if [ -s $ArchiveDIR/${xGDBsource}-*.tar ]
then

# If a destination GDBnnn directory already exists, then copy it for safety (it should typically be absent because user will have dropped the GDB)
	if [ -d $DataDIR/$xGDB ];then
		mv $DataDIR/$xGDB $DataDIR/${xGDB}.users
    fi
    mkdir $DataDIR/$xGDB # Create the destination GDBnnn directory
	mkdir $TmpDIR/$xGDB # Create the destination GDBnnn tmp directory
	chmod 777 $TmpDIR/$xGDB

### Update logs 
   dateTime1=$(date +%Y-%m-%d\ %k:%M:%S)
   echo "____________________________" >>$ArchiveDIR/ArchiveGDB.log
   echo "";
   echo "Restoring ${xGDBsource} data to $xGDB $space $dateTime" >>$ArchiveDIR/ArchiveGDB.log
   echo "${space}Restoring ${xGDBsource} data to $xGDB $space $dateTime"  >>$DataDIR/$xGDB/logs/Pipeline_procedure.log

# copy the GDBnnn-[description-species].tar file to destination directory (rename to generic name) and untar. Remove the copy of the tar file from destination directory
	cp -r $ArchiveDIR/${xGDBsource}-*.tar  $DataDIR/$xGDB/${xGDBsource}.tar # 
	cd $DataDIR/$xGDB/
	tar -xvf ${xGDBsource}.tar ## first level of untarring resulting in ${xGDBsource}.tar.bz2 xGDB_Log.txt and 0README
	tar -xjvf ${xGDBsource}.tar.bz2 > tar.txt  ## restores conf data logs directories and ${xGDB}.sql (temp, for mysql)
	rm $DataDIR/$xGDB/${xGDBsource}.tar.bz2 

# Delete the xGDB_Log.txt file, as it is not needed here (it was used to create the Genomes.xGDB_Log entry for this archive restore)
    rm -rf $DataDIR/$xGDB/xGDB_Log.txt # we remove this file - it is no longer needed here.
# Now replace source ID with destination ID in other config files.
	sed -i "s/GDB[0-9][0-9][0-9]/$xGDB/" $DataDIR/$xGDB/conf/SITEDEF.pl # replace source GDB ID with destination GDB ID in the new destination
	sed -i "s/GDB[0-9][0-9][0-9]/$xGDB/" $DataDIR/$xGDB/conf/SITEDEF.php # replace source GDB ID with destination GDB ID
	sed -i "s/GDB[0-9][0-9][0-9]/$xGDB/" $DataDIR/$xGDB/conf/yrGATE_conf.pl # replace source GDB ID with destination GDB ID
	mv $DataDIR/$xGDB/conf/${xGDBsource}_gaeval_conf.pl $DataDIR/$xGDB/conf/${xGDB}_gaeval_conf.pl # rename this conf file
	mv $DataDIR/$xGDB/conf/${xGDBsource}_cpgat_gaeval_conf.pl $DataDIR/$xGDB/conf/${xGDB}_cpgat_gaeval_conf.pl # rename this conf file
	sed -i "s/GDB[0-9][0-9][0-9]/$xGDB/" $DataDIR/$xGDB/conf/${xGDB}_gaeval_conf.pl # replace source GDB ID with destination GDB ID
	sed -i "s/GDB[0-9][0-9][0-9]/$xGDB/" $DataDIR/$xGDB/conf/${xGDB}_cpgat_gaeval_conf.pl # replace source GDB ID with destination GDB ID

# Create the GDBnn MySQL database using the GDBnnn mysqldump file in the source GDB archive (this file is located at the top level in the GDB archive)
# Note that the tables in this database don't have any GDB ID-specific data, so we can load them to any named GDB database.
# Then we remove the mysql dump file.
	echo "create database $xGDB"|mysql -p$dbpass -u $mysqluser
    mysql -p$dbpass -u$mysqluser $xGDB <  $DataDIR/$xGDB/${xGDBsource}.sql
    rm -rf $DataDIR/$xGDB/${xGDBsource}.sql
# Grant privileges
	echo "grant SELECT on $xGDB.* to 'xgdbSELECT'@'localhost' identified by ''"|mysql -p$dbpass -u $mysqluser
	echo "grant All on $xGDB.* to 'gaeval'@'localhost' identified by ''"|mysql -p$dbpass -u $mysqluser
    echo "grant All on $xGDB.user_gene_annotation to 'yrgateUser'@'localhost' identified by ''"|mysql -p$dbpass -u $mysqluser
    echo "grant All on $xGDB.sessions to 'xgdbSELECT'@'localhost' identified by ''"|mysql -p$dbpass -u $mysqluser
	echo "grant All on $xGDB.projects to 'xgdbSELECT'@'localhost' identified by ''"|mysql -p$dbpass -u $mysqluser
    echo "grant All on $xGDB.sessionprojects to 'xgdbSELECT'@'localhost' identified by ''"|mysql -p$dbpass -u $mysqluser
    echo "flush privileges"|mysql -p$dbpass -u $mysqluser 
# Update global database table xGDB_Log with date stamp, status, etc.
	echo "UPDATE xGDB_Log SET Restore_Date = now() WHERE ID=\"$ID\""|mysql -p$dbpass -u $mysqluser Genomes
    echo "UPDATE xGDB_Log SET Create_Date = now() WHERE ID=$ID"|mysql -p$dbpass -u $mysqluser Genomes # Otherwise this would be blank!
	echo "UPDATE xGDB_Log SET Archive_Date = "" WHERE ID=\"$ID\""|mysql -p$dbpass -u $mysqluser Genomes  # Less confusing to the user if we reset this. Otherwise they may think they've re-archived the GDB.
	echo "UPDATE xGDB_Log SET Status = \"Current\" WHERE ID=\"$ID\""|mysql -p$dbpass -u $mysqluser Genomes
    if [ "$ID" -ne "$ID_source" ]
    then
    # rename newly restored data files according to the current GDB ID (thanks to http://stackoverflow.com/questions/602706/batch-renaming-with-bash)

        cd $DataDIR/$xGDB/data/BLAST/; for i in GDB[0-9][0-9][0-9]* ; do mv "$i" "${i/GDB[0-9][0-9][0-9]/$xGDB}" ; done
        cd $DataDIR/$xGDB/data/download/; for i in GDB[0-9][0-9][0-9]* ; do mv "$i" "${i/GDB[0-9][0-9][0-9]/$xGDB}" ; done
        cd $DataDIR/$xGDB/data/GSQ/MRNADIR/; for i in GDB[0-9][0-9][0-9]* ; do mv "$i" "${i/GDB[0-9][0-9][0-9]/$xGDB}" ; done
        cd $DataDIR/$xGDB/data/GSQ/SCFDIR/; for i in GDB[0-9][0-9][0-9]* ; do mv "$i" "${i/GDB[0-9][0-9][0-9]/$xGDB}" ; done
        cd $DataDIR/$xGDB/data/GSQ/PUTDIR/; for i in GDB[0-9][0-9][0-9]* ; do mv "$i" "${i/GDB[0-9][0-9][0-9]/$xGDB}" ; done
        cd $DataDIR/$xGDB/data/GSQ/GSQOUT/; for i in GDB[0-9][0-9][0-9]* ; do mv "$i" "${i/GDB[0-9][0-9][0-9]/$xGDB}" ; done
        cd $DataDIR/$xGDB/data/GTH/SCFDIR/; for i in GDB[0-9][0-9][0-9]* ; do mv "$i" "${i/GDB[0-9][0-9][0-9]/$xGDB}" ; done
        cd $DataDIR/$xGDB/data/GTH/Protein/; for i in GDB[0-9][0-9][0-9]* ; do mv "$i" "${i/GDB[0-9][0-9][0-9]/$xGDB}" ; done
        cd $DataDIR/$xGDB/data/GTH/GTHOUT/; for i in GDB[0-9][0-9][0-9]* ; do mv "$i" "${i/GDB[0-9][0-9][0-9]/$xGDB}" ; done 
        cd $DataDIR/$xGDB/data/XGDB_MYSQL/; for i in GDB[0-9][0-9][0-9]* ; do mv "$i" "${i/GDB[0-9][0-9][0-9]/$xGDB}" ; done
    fi
 
  # Create file containing GDB name and time-date stamp, with DBname as human-readable filename 
  ### IMPORTANT! Do not change format! This file's contents are used in a dropdown list of archives generated by conf_functions.inc.php archive_dir_dropdown)
   dateTime99=$(date +%Y-%m-%d\ %k:%M:%S)
   DBname=$(echo "select DBname from Genomes.xGDB_Log where ID=$ID"|mysql --skip-column-names -p$dbpass -u $mysqluser)
   readable_name=${xGDB}-${DBname//[^a-zA-Z0-9\-]/-} # (convert non-ascii to "-")

  echo "$xGDB $space $DBname $space $dateTime9" >/xGDBvm/data/$xGDB/0README-$readable_name
      
 ### update the ArchiveGDB log with "restore complete"
   echo "${xGDBsource} data restored to $xGDB $space $dateTime99" >>$ArchiveDIR/ArchiveGDB.log
   echo "____________________________" >>$ArchiveDIR/ArchiveGDB.log
   echo "" >>$ArchiveDIR/ArchiveGDB.log

fi

echo "update xGDB_Log set Status = \"Current\" where ID=$ID"|mysql -p$dbpass -u $mysqluser Genomes
