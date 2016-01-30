#!/bin/bash
# Desription: Initialization script for iPlant instance of xGDBvm
# Purpose: Create directories under local directory, e.g. /home, that can be used for input/output data in lieu of mounting to external volume/Data Store
# Useage: This script should be run by the system when a new instance is booted up. 
#           Accordingly a copy of this script should be placed at /etc/atmo/post-scripts.d/configure-local.sh
#           sudo /etc/atmo/post-scripts.d/configure-local.sh [run as root -- no arguments required]
#           It can also be run if necessary by the user with 'configure-home' 
# Script create data: 7-25-14

echo ""
echo "________________________________________________________________________________"
echo ""
echo "RUNNING SCRIPT configure-local.sh."
echo "This script sets up directories under /home"
echo ""
echo "________________________________________________________________________________"
echo ""

#1. Assign directories

localDataDir="/home/xgdb-data" #
localInputDir="/home/xgdb-input" #


# 1. /local/xgdb-data directory and subdirectories

if [ ! -e $localDataDir ]
then
  mkdir $localDataDir
chown root:xgdb $localDataDir
chmod 775 $localDataDir
  echo ""
  echo "directory $localDataDir has been created."
  echo "This directory is used for all scratch data, output data, databases, and configuration files if the user does not attach an external volume."
  echo ""
  else
  echo ""
  echo "The directory $localDataDir already exists."
  echo "This directory is used for all scratch data, output data, databases, and configuration files if the user does not attach an external volume."
fi

localTempDir="${localDataDir}/tmp" #
if [ ! -e $localTempDir ]
then
  mkdir $localTempDir
  chown root:xgdb $localTempDir
  chmod 777 $localTempDir
  echo ""
  echo "Local tmp directory $localTempDir has been created."
  echo "This directory is used for web server-cached files for display or computation."
  echo ""
else
  echo ""
  echo "The tmp directory $localTempDir already exists."
  echo "This directory is used for web server-cached files for display or computation."
fi


localScratchDir="${localDataDir}/scratch" #
if [ ! -e $localScratchDir ]
then
  mkdir $localScratchDir
  echo ""
  echo "Local scratch directory $localScratchDir has been created."
  echo "This directory is used transiently for pipeline computations and should be empty when pipeline is complete."
  chown root:xgdb $localScratchDir
  chmod 775 $localScratchDir
  echo ""
  echo "$localScratchDir directory ownership modified."  echo ""
  else
  echo ""
  echo "Local scratch directory $localScratchDir already exists."
  echo "This directory is used transiently for pipeline computations and should be empty when pipeline is complete."
fi


# 2. /local/xgdb-input directory and subdirectories

if [ ! -e $localInputDir ]
then
  mkdir $localInputDir
chown root:users $localInputDir
chmod 775 $localInputDir
  echo ""
  echo "directory $localInputDir has been created."
  echo "This directory is used for all input data if the user does not attach an iPlant Data Store volume."
  echo ""
  else
  echo ""
  echo "directory $localInputDir already exists."
  echo "This directory is used for all input data if the user does not attach an iPlant Data Store volume."
fi

localKeyDir="${localInputDir}/keys"
if [ ! -e $localKeyDir ]
then
  mkdir $localKeyDir
  chown root:users $localKeyDir
  chmod 775 $localKeyDir # (allow user to add files w/o sudo)
  echo ""
  echo "local keys directory $localKeyDir has been created."
  echo "This directory is used to store user's license keys (GenomeThreader, GeneMark, Vmatch) for installation on the VM if Data Store is not mounted."
  echo ""
else
  echo ""
  echo "xGDB keys directory $localKeyDir already exists."
  echo "This directory is used to store user's license keys (GenomeThreader, GeneMark, Vmatch) for installation on the VM if Data Store is not mounted."
fi

localRefprotDir="${localInputDir}/referenceprotein"
if [ ! -e $localRefprotDir ]
then
  mkdir $localRefprotDir
  chown root:users $localRefprotDir
  chmod 775 $localRefprotDir # (allow user to add files w/o sudo)
  echo ""
  echo "input directory $localRefprotDir has been created."
  echo "This directory is used to store reference protein files (fasta formatted) for CpGAT"
else
  echo ""
  echo "input directory $localRefprotDir already exists."
  echo "This directory is used to store reference protein files (fasta formatted) for CpGAT"
fi

localRepmaskDir="${localInputDir}/repeatmask"
if [ ! -e $localRepmaskDir ]
then
  mkdir $localRepmaskDir
  chown root:users $localRepmaskDir
  chmod 775 $localRepmaskDir # (allow user to add files w/o sudo)
  echo ""
  echo "input directory $localRepmaskDir has been created."
  echo "This directory is used to store repeat mask nucleotide files (fasta formatted) "
else
  echo ""
  echo "input directory $localRepmaskDir already exists."
  echo "This directory is used to store repeat mask nucleotide files (fasta formatted) "
fi

# 6. archive/jobs/ NOTE: Destination for remote HPC output. Failsafe although this directory path should be created dynamically when first HPC job is run.
localArchiveDir="${localInputDir}/archive" # 
if [ ! -e $localArchiveDir ]
then
  mkdir $localArchiveDir
  chown root:users $localArchiveDir
  chmod 775 $localArchiveDir # (allow user to add files w/o sudo)
  echo ""
  echo "archive/ directory $localArchiveDir has been created."
  echo ""
else
  echo ""
  echo "archive directory $localArchiveDir already exists."
  echo ""
fi
