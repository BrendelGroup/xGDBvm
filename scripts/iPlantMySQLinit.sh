#!/bin/bash
# Description: Final configuration script for an iPlant instance of xGDBvm
# Purpose: Create xGDBvm default directories, configure the MySQL database and permissions under, add secure flag
# Useage: Run this script on a new xGDBvm instance as a last step BEFORE creating any GDB in the xGDBvm GUI!
#         Type the command 'configure-vm' at the shell prompt, or
#         /xGDBvm/scripts/iPlantMySQLinit.sh [run as root -- no arguments required]
#         Also run this script AFTER attaching a new volume at /xGDBvm/data or resuming a suspended VM
#         (NOTE: the volume must have a filesystem configured)
# Latest update: 1/26/16

echo ""
echo "________________________________________________________________________________"
echo ""
echo "RUNNING SCRIPT iPlantMySQLinit.sh."
echo "This script sets up the environment and permissions for an xGDBvm instance at iPlant"
echo "NOTE: It's a good idea to ALWAYS re-run this script any time you attach and mount a different volume "
echo ""
echo "________________________________________________________________________________"
echo ""

########### DEFAULT PATHS ##########

##### I INPUTS #####
inputMountPoint="/home/xgdb-input" # either mounted or unmounted
inputTopLevel="xgdbvm/"  # trailing slash
inputPath="${inputMountPoint}/${inputTopLevel}"  # Either under the user's Data Store root or locally on this VM
inputLink="/xGDBvm/input"

##### II. OUTPUTS (DATA) #####
dataRoot="" # Currently we don't insert a root directory here.
dataMountPoint="/home/xgdb-data"  #Either an attached volume mounted at /home/xgdb-data, or /home/xgdb-data/ on this VM
dataLink="/xGDBvm/data"
tmpDirData="${dataMountPoint}/tmp" # see part II.1 below
tmpLink="/xGDBvm/tmp" # symbolic link
scratchDir="${dataMountPoint}/scratch" # see part II.2 below
scratchLink="/xGDBvm/scratch"  # symbolic link
archiveDir="${dataMountPoint}/ArchiveGDB" # see part II.3 below
archiveAllDir="${dataMountPoint}/ArchiveAll" # see part II.4 below

##### III. OTHER INPUT DIRS #####
keyDir="${inputPath}keys/" # see part III.2 below
gth_lic_vm="/xGDBvm/admin/gth.lic"  # Currently we keep a copy here and can update it in svn if needed
vmatch_lic_vm="/xGDBvm/admin/vmatch.lic" # Currently we keep a copy here and can update it in svn if needed
gth_lic_user="${keyDir}gth.lic"
vmatch_lic_user="${keyDir}vmatch.lic"
refprotDir="${inputPath}referenceprotein" # see part II.3 below
repmaskDir="${inputPath}repeatmask" # see part II.3 below
archiveDir="${inputPath}archive" # 
tmpDir="${inputPath}/tmp"

##### IV. MySQL ######
mysqlDir="${dataMountPoint}/mysql" # see part IV
dbpass='xgdb'
mysqluser='gdbuser'
mysqlGenomes="$mysqlDir/Genomes"
mysqlAdmin="$mysqlDir/Admin"
mysqlyrGATE="$mysqlDir/yrGATE"
mysqlGAEVAL="$mysqlDir/GAEVAL"


########### II. Configure Attached Volume ###########

# 1. tmp directory may need to be created if the user has mounted a "new" volume at ${dataMountPoint}

if [ ! -e $tmpDirData ]
then
  mkdir $tmpDirData

  echo "$tmpDirData directory has been created."
  echo " - This directory is used for web server-cached files for display or computation."
  echo ""
  chown -R root:xgdb $tmpDirData
  chmod -R 777 $tmpDirData
  echo "$tmpDirData directory permissions modified."
  echo ""
else
  echo ""
  echo "xGDB tmp directory $tmpDirData already exists."
  echo " - This directory is used for web server-cached files for display or computation."
fi

if [ ! -L $tmpLink ]
then
  ln -s $tmpDirData $tmpLink
  echo ""
  echo "A symbolic link to $tmpDirData has been created at /xGDBvm/tmp."
  echo ""
else
  echo "A symbolic link to $tmpDirData is already present at /xGDBvm/tmp."
fi

# 2. scratch directory may need to be created if the user has mounted a "new" volume at ${dataMountPoint}

if [ ! -e $scratchDir ]
then
  mkdir $scratchDir
  echo ""
  echo "$scratchDir directory has been created."
  echo " - This directory is used transiently for pipeline computations and should be empty when pipeline is complete."
  chmod -R 775 $scratchDir
  echo ""
  echo "$scratchDir directory permissions modified.";
  echo ""
else
  echo ""
  echo "xGDB scratch directory $scratchDir already exists."
  echo " - This directory is used transiently for pipeline computations and should be empty when pipeline is complete."
fi
  chown -R root:xgdb $scratchDir # this line is outside loop because sometimes permissions get reset to user on external volume
  echo ""
  echo "permissions for scratch directory $scratchDir have been updated to root:xgdb "
  echo ""

if [ ! -L $scratchLink ]
then
  ln -s $scratchDir $scratchLink
  echo ""
  echo "A symbolic link to $scratchDir has been created at /xGDBvm/scratch."
  echo ""
else
  echo "A symbolic link to $scratchDir is already present at /xGDBvm/scratch."
fi

# 3. ArchiveGDB directory may need to be created if the user has mounted a "new" volume at ${dataPath}; or permission reset

if [ ! -e $archiveDir ]
then
  mkdir $archiveDir
  echo ""
  echo "$archiveDir directory has been created."
  echo " - This directory is used for archived copies of genome databases (GDB)"
  chmod -R 775 $archiveDir
  echo ""
  echo "$archiveDir directory permissions modified.";
  echo ""
  else
  echo ""
  echo "$archiveDir directory already exists."
  echo " - This directory is used for archived copies of genome databases (GDB)"
fi
  chown -R root:xgdb $archiveDir # this line is outside loop because sometimes permissions get reset to user on external volume
  echo ""
  echo "permissions for scratch directory $archiveDir have been updated to root:xgdb "
  echo ""

# 4. ArchiveAll directory may need to be created if the user has mounted a "new" volume at ${dataMountPoint}; or permission reset

if [ ! -e $archiveAllDir ]
then
  mkdir $archiveAllDir
  echo ""
  echo "$archiveAllDir directory has been created."
  echo " - This directory is used for archived copies of ALL genome databases (GDB)"
  chmod -R 775 $archiveAllDir
  echo ""
  echo "$archiveAllDir directory permissions modified.";
  echo ""
  else
  echo ""
  echo "$archiveAllDir directory already exists."
  echo " - This directory is used for archived copies of ALL genome databases (GDB)"
fi
  chown -R root:xgdb $archiveAllDir # this line is outside loop because sometimes permissions get reset to user on external volume
  echo ""
  echo "permissions for scratch directory $archiveAllDir have been updated to root:xgdb "
  echo ""



########### III. Configure Data Store (input data) ###########

# 1. Data Store root directory for xGDBvm (inputPath) may need to be created if the user is mounting their Data Store at ${inputPath} for the first time, or if a new VM is being configured and no Data Store is being mounted.

if [ ! -e $inputPath ] # This is the xgdbvm directory, typically under the user's iPlant Data Store root
then
  mkdir $inputPath

  echo "$inputPath directory has been created."
  echo " - This is the root level directory for your input data (whether on a mounted Data Store or on the VM)."
  echo ""
  chown -R root:xgdb $inputPath  # if no Data Store is attached, we need permissions as Apache
  chmod -R 775 $inputPath
  echo "$tmpDirData directory permissions modified."
  echo ""
else
  echo ""
  echo "xGDB tmp directory $tmpDirData already exists."
  echo " - This directory is used for web server-cached files for display or computation."
fi
# 2. /keys/ directory may need to be created if the user has mounted iPlant Data Store for the first time at /xGDBvm/input
#    This step also copies the latest GenomeThreader and Vmatch licenses (available on 1 year schedule) to the /keys/ directory 

if [ ! -e $keyDir ]
then
  mkdir $keyDir
  echo ""
  echo "$keyDir directory has been created."
  echo ""
else
  echo ""
  echo "$keyDir directory already exists."
fi
echo " - This directory is used to store user's license keys (GenomeThreader, GeneMark, Vmatch) for installation on the VM."

if [ ! -e $gth_lic_user ]
	then
	  cp  $gth_lic_vm $gth_lic_user
	if [ -e $gth_lic_user ]
	then
	  echo ""
	  echo "gth.lic file has been copied to your Data Store in the directory ${keyDir}."
	  echo " - This license is required to run GenomeThreader locally or on HPC."
	  echo " - This license is valid for 1 year from issue for any noncommercial use on xGDBvm-iPlant"
	else
	  echo ""
	  echo "ERROR: gth.lic file is missing from /xGDBvm/admin/ and was NOT copied to your Data Store at ${keyDir}."
	  echo " - You may need to obtain your own GenomeThreader license and copy it to ${inputPath}/keys/"
	fi
else
  echo ""
  echo "gth.lic file is already present in your Data Store in the directory ${keyDir}."
  echo " - This license is required to run GenomeThreader locally or on HPC."
  echo " - This license is valid for 1 year from issue for any noncommercial use on xGDBvm-iPlant"

fi

if [ ! -e $vmatch_lic_user ]
	then
	  cp  $vmatch_lic_vm $vmatch_lic_user
	if [ -e $vmatch_lic_user ]
	then
	  echo ""
	  echo "vmatch.lic file has been copied to your Data Store in the directory ${keyDir}."
	  echo " - This license is required to run Vmatch locally or on HPC."
	  echo " - This license is valid for 1 year from issue for any noncommercial use on xGDBvm-iPlant"
	else
	  echo ""
	  echo "ERROR: vmatch.lic file is missing from /xGDBvm/admin/ and was NOT copied to your Data Store at ${keyDir}."
	  echo " - You may need to obtain your own Vmatch license and copy it to ${inputPath}/keys/"
	fi
else
  echo ""
  echo "vmatch.lic file is already present in your Data Store in the directory ${keyDir}."
  echo " - This license is required to run Vmatch locally or on HPC."
  echo " - This license is valid for 1 year from issue for any noncommercial use on xGDBvm-iPlant"

fi


# 3. /referenceprotein/, /repeatmask/ directories may need to be created if the user has mounted iPlant Data Store for the first time at /xGDBvm/input

if [ ! -e $refprotDir ]
then
  mkdir $refprotDir
  echo ""
  echo "$refprotDir directory has been created."
else
  echo ""
  echo "$refprotDir directory already exists."
fi
echo " - This directory is used to store reference protein files (fasta formatted) for CpGAT"

if [ ! -e $repmaskDir ]
then
  mkdir $repmaskDir
  echo ""
  echo "$repmaskDir directory has been created."
else
  echo ""
  echo "$repmaskDir directory already exists."
fi
echo " - This directory is used to store repeat mask nucleotide files (fasta formatted) "

# 4. archive/jobs/ NOTE: Destination for GDB archives.
if [ ! -e $archiveDir ]
then
  mkdir $archiveDir
  echo ""
  echo "$archiveDir directory has been created."
else
  echo ""
  echo "$archiveDir directory already exists."
fi
echo " - This directory is used for output of HPC (high performance compute) jobs"

if [ ! -e $tmpDir ]
then
  mkdir $tmpDir
  echo ""
  echo "$tmpDir directory has been created."
else
  echo ""
  echo "$tmpDir directory already exists."
fi
echo " - This directory is used for temporary caching of HPC (high performance compute) job inputs"

############## IV. MySQL Databases #################

echo ""
echo "########## Create MySQL database structure for output data ############"
echo ""

# 1. MySQL databases. These are copied from their default location to ${dataMountPoint}/mysql if not already exist (using Genomes as a test)
if [ ! -e $mysqlDir ] # this indicates no mysql data exists in the mysql destination directory so it must be created by copying the "default" data over
then
  cp -r /var/lib/mysql $dataMountPoint # creates a ${dataMountPoint}/mysql directory containing all default mysql databases. We will create others below.
  echo "mysql database directory has been copied to new location: $mysqlDir."
  echo ""
  echo "Note:   $mysqlDir should be specified as the mysql data directory 'datadir' in /etc/my.cnf."
  echo "  Current setting is: "
  echo ""
  egrep "datadir" /etc/my.cnf
  echo ""
  echo "(If different from what you specified in this script, then please edit the /etc/my.cnf file.)"
  echo ""
else
  echo "MySQL databases already exist at $mysqlDir."
  echo " - No changes to MySQL database directory."
fi
  chown -R mysql:mysql $mysqlDir # this line is outside loop because sometimes permissions get reset to user on external volume
  echo ""
  echo "Permissions for database directory $mysqlDir have been updated to mysql:mysql "
  echo ""

sudo /sbin/service mysqld restart

# 2. Setting up the xGDB databases (if they don't already exist):



echo "GRANT ALL PRIVILEGES ON *.* TO 'gdbuser'@'localhost' identified by '$dbpass' WITH GRANT OPTION" | mysql -u root
if [ ! -e $mysqlGenomes ]
then
   echo "CREATE DATABASE Genomes" | mysql -p$dbpass -u $mysqluser
   mysql -p$dbpass -u $mysqluser Genomes < /xGDBvm/scripts/GenomesFrame.sql
   echo "GRANT SELECT ON Genomes.* TO 'xgdbSELECT'@'localhost'" | mysql -p$dbpass -u $mysqluser
   echo "flush privileges" | mysql -p$dbpass -u $mysqluser
fi
if [ ! -e $mysqlyrGATE ]
then
   echo "CREATE DATABASE IF NOT EXISTS yrgate"  | mysql -p$dbpass -u $mysqluser
   mysql -p$dbpass -u $mysqluser yrgate  < /xGDBvm/scripts/yrgateFrame.sql
   echo "GRANT ALL ON yrgate.*    TO 'yrgateUser'@'localhost'" | mysql -p$dbpass -u $mysqluser
   echo "flush privileges" | mysql -p$dbpass -u $mysqluser
fi
if [ ! -e $mysqlAdmin ]
then
   echo "CREATE DATABASE IF NOT EXISTS Admin"   | mysql -p$dbpass -u $mysqluser
   mysql -p$dbpass -u $mysqluser Admin   < /xGDBvm/scripts/AdminFrame.sql
   echo "GRANT ALL ON Admin.admin TO 'gdbuser'@'localhost'"    | mysql -p$dbpass -u $mysqluser
   echo "GRANT SELECT ON Admin.* TO 'xgdbSELECT'@'localhost'" | mysql -p$dbpass -u $mysqluser
   echo "flush privileges" | mysql -p$dbpass -u $mysqluser
 
   
# 3. Insert default remote processing variables (do this only if we just created Admin). TODO: Add a script to update these even if Admin exists.

    dateTime=$(date +%Y-%m-%d\ %k:%M:%S)
    auth_url='https://agave.iplantc.org'
    api_version='v2'
    
    echo "insert into Admin.admin (auth_update, auth_url, api_version) values ('$dateTime', '$auth_url', '$api_version')"| mysql -p$dbpass -u $mysqluser
    echo "API configured for base URL $auth_url / version $api_version"

    echo "INSERT INTO Admin.apps (app_id, program, version, platform, nodes, proc_per_node, memory_per_node, date_added, description, developer, is_default, max_job_time) values ('geneseqer-small-stampede-5.0.0u2', 'GeneSeqer-MPI', '5.0', 'Stampede', 1, 16, 2, now(), 'For example jobs', 'vaughn', 'N', '00:10:00')"| mysql -p$dbpass -u $mysqluser
    echo "INSERT INTO Admin.apps (app_id, program, version, platform, nodes, proc_per_node, memory_per_node, date_added, description, developer, is_default, max_job_time) values ('geneseqer-medium-stampede-5.0.0u2', 'GeneSeqer-MPI', '5.0', 'Stampede', 4, 16, 2, now(), 'For medium to large jobs', 'vaughn', 'Y', '00:10:00')"| mysql -p$dbpass -u $mysqluser
    echo "INSERT INTO Admin.apps (app_id, program, version, platform, nodes, proc_per_node, memory_per_node, date_added, description, developer, is_default, max_job_time) values ('geneseqer-large-stampede-5.0.0u2', 'GeneSeqer-MPI', '5.0', 'Stampede', 8, 16, 2, now(), 'For large jobs', 'vaughn', 'N', '00:10:00')"| mysql -p$dbpass -u $mysqluser
    echo "INSERT INTO Admin.apps (app_id, program, version, platform, nodes, proc_per_node, memory_per_node, date_added, description, developer, is_default, max_job_time) values ('genomethreader-stampede-1.6.5u1', 'GenomeThreader', '1.6.5', 'Stampede', 1, 16, 2, now(), 'Works for wide range of genome sizes', 'vaughn', 'Y', '00:10:00')"| mysql -p$dbpass -u $mysqluser
    echo "INSERT INTO Admin.apps (app_id, program, version, platform, nodes, proc_per_node, memory_per_node, date_added, description, developer, is_default, max_job_time) values ('genomethreader-lonestar4-1.6.5u1', 'GenomeThreader', '1.6.5','Lonestar', 1, 12, 2, now(), 'Works for wide range of genome sizes; platform deprecated soon', 'vaughn', 'N', '00:10:00')"| mysql -p$dbpass -u $mysqluser
    echo "Apps configured for GenomeThreader and GeneSeqer-MPI apps"

  echo ""
  echo "HPC API settings and app IDs were loaded to the database. To view them online visit Manage -> Remote Jobs "
  echo ""

fi

if [ ! -e $mysqlGAEVAL ]
then
   echo "CREATE DATABASE IF NOT EXISTS GAEVAL"   | mysql -p$dbpass -u $mysqluser
   mysql -p$dbpass -u $mysqluser < /xGDBvm/scripts/gaeval_setup.sql # 11. GAEVAL table for dynamic assignment of GAEVAL scores in yrGATE
fi

# 4. Run additional update script to update any tables:

/xGDBvm/scripts/configure-vm/MySQLupdate.sh
echo "MySQL update script run."

# Report path configuration and End of script

########### I. Global Paths ###########

echo ""
echo "##############  Top level directory on Data Store (for input data) ##############"
echo ""
echo "              /iplant/[username]/${inputTopLevel}/"
echo ""

echo "    #####  Path to access this directory on your VM shell #####"
echo ""
echo "              $inputPath or symlink $inputLink"
echo ""
echo ""
echo "##############  Top level directory on Mounted Volume (for output data) ##############"
echo ""
echo "             $dataMountPoint"
echo ""
echo "    #####  Path to access this directory on your VM shell #####"
echo ""
echo "             $dataMountPoint or symlink $dataLink"
echo ""

echo ""
echo "End of 'configure-vm' script. You should now be ready to access your VM online."
echo ""
echo "NOTE: ALWAYS use 'unmount-volume' and 'unmount-datastore' before rebooting or terminating this VM."
echo ""



