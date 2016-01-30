#!/bin/bash
####... called from Recover xGDBvm interface########

#!/bin/bash
#### Useage: restores a data archive from all GDB under /xGDBvm/data/ArchiveAll/ ########
#### Called by archive_exec.php in response to user action via archive.php or viewall.php ########
#### Updated 5-23-2014 J Duvick

VM=$(uname -n|cut -d "." -f 1) # identifies this VM

ROOT='/xGDBvm'
ScriptDIR='/xGDBvm/scripts'
#InputDIR="/xGDBvm/input"
DataDIR="/xGDBvm/data"
TmpDIR="/xGDBvm/tmp"
ArchiveDIR="$DataDIR/ArchiveAll"

while read dbpass
	do
	   echo "$dbpass"
	done < /xGDBvm/admin/dbpass
mysqluser='gdbuser';

if [ -d  $ArchiveDIR ]
then
    mysql -p$dbpass -u$mysqluser Genomes < $ArchiveDIR/Genomes.sql
    mysql -p$dbpass -u$mysqluser Genomes < $ArchiveDIR/yrgate.sql
    
    ### Grab all GDBnnn directory names from /xGDBvm/data/ArchiveAll/ and initiate archive loop
    cd $ArchiveDIR
    GDBdirs=$(ls -d GDB[0-9][0-9][0-9]) # e.g. "GDB001  GDB002"
    for file in $GDBdirs
    do
        xGDB=$file
    ### Restore MySQL databases and permissions ###
        echo "create database $xGDB"|mysql -p$dbpass -u $mysqluser
        echo "grant SELECT on $xGDB.* to 'xgdbSELECT'@'localhost' identified by ''"|mysql -p$dbpass -u $mysqluser
        echo "grant All on $xGDB.* to 'gaeval'@'localhost' identified by ''"|mysql -p$dbpass -u $mysqluser
            echo "grant All on $xGDB.user_gene_annotation to 'yrgateUser'@'localhost' identified by ''"|mysql -p$dbpass -u $mysqluser
            echo "grant All on $xGDB.sessions to 'xgdbSELECT'@'localhost' identified by ''"|mysql -p$dbpass -u $mysqluser
            echo "grant All on $xGDB.projects to 'xgdbSELECT'@'localhost' identified by ''"|mysql -p$dbpass -u $mysqluser
            echo "grant All on $xGDB.sessionprojects to 'xgdbSELECT'@'localhost' identified by ''"|mysql -p$dbpass -u $mysqluser
            echo "flush privileges"|mysql -p$dbpass -u $mysqluser  #INCLUDE COPY OF THIS IN SETUP SCRIPT
    ### Load archived GDBnnn MySQLdump (NOT the one originally stored under /XGDB_MYSQL/ )
        mysql -p$dbpass -u$mysqluser $xGDB <  $ArchiveDIR/$xGDB/${xGDB}.sql
        
    ### Make backup copy of GDBnnn if it exists (it shouldn't) ###
        if [ -d $DataDIR/$xGDB ];then
            mv $DataDIR/$xGDB $DataDIR/$xGDB.users
        fi
    ### Make GDB directory and copy over the archived output data etc. ###
        mkdir $DataDIR/$xGDB
        mkdir $TmpDIR/$xGDB
        chmod 777 $TmpDIR/$xGDB
        cp -r $ArchiveDIR/$xGDB/* $DataDIR/$xGDB/
    done
    echo "update xGDB_Log set Restore_All_Date = now()"|mysql -p$dbpass -u $mysqluser Genomes
fi

    ### Finally, update the ArchiveAll.log one more time
	dateTime99=$(date +%Y-%m-%d\ %k:%M:%S)
	msg99="RestoreAllGDB completed for ${GDBdirs}:"
	echo "$msg99$ dateTime99" >>$ArchiveGDB/ArchiveAll.log