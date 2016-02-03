<?php
# This script defines xGDBvm global variables

# Global paths
$URL_prefix          = "/";
$MAIN_DIR_PATH       = "/xGDBvm/";                            # Web root
$MOUNT_DIR           = "/home/";                              # top level directory for setting external mount points for volume and DataStore

# Mount points configured on the VM 
$DATA_MOUNT_PATH     = "${MOUNT_DIR}xgdb-data/";              # absolute local path for data output
$INPUT_MOUNT_PATH    = "${MOUNT_DIR}xgdb-input/";             # absolute local path for input
$DATA_LINK_PATH      = "${MAIN_DIR_PATH}data/";               # symlink to $DATA_MOUNT_PATH under the Web root, for convenience, e.g. /xGDBvm/data
$INPUT_LINK_PATH     = "${MAIN_DIR_PATH}input/";              # symlink to $INPUT_MOUNT_PATH under the Web root, for convenience, e.g. /xGDBvm/input

# Local Directory Paths: Data I/O (updated 1-28-16)
$XGDB_DATADIR_MOUNT  = $DATA_LINK_PATH;                       # e.g. the symlinked data path, /xGDBvm/data
$DATA_TOPDIR         = "";                                    # Currently we define no top level directory for data ouptuts (1-28-16)
$XGDB_DATADIR        = "${XGDB_DATADIR_MOUNT}${DATA_TOPDIR}"; # as currently configured they are the same, e.g. /xGDBvm/data (1-28-16)

$XGDB_INPUTDIR_MOUNT = $INPUT_LINK_PATH;                      # e.g. the symlinked input path to the mount point of the user's Data Store  /xGDBvm/input
$INPUT_TOPDIR        = "xgdbvm/";                             # Include trailing slash; no leading slash. Top level directory under the user's home directory that contains input directories (1-28-16)
$XGDB_INPUTDIR	     = "${INPUT_LINK_PATH}${INPUT_TOPDIR}";   #  e.g. /xGDBvm/input/xgdbvm/, the symlinked path to input directories 

# Local Directory Paths: Other
$XGDB_CGIDIR         = "${MAIN_DIR_PATH}XGDB/cgi-bin/";       #conf-UNIQ#
$XGDB_TMPDIR         = "${XGDB_DATADIR}tmp/";
$XGDB_ARCHDIR        = "${XGDB_DATADIR}ArchiveGDB/";
$XGDB_ARCHALLDIR     = "${XGDB_DATADIR}ArchiveAllGDB/";

# Web URLs
$SERVER              = $_SERVER['HTTP_HOST'];                 #conf#
$XGDB_WEBROOTURL = "/";                                       #conf-UNIQ#
$XGDB_WEBCGIURL  = "${URL_prefix}XGDB/cgi-bin/";              #conf-UNIQ#
$XGDB_WEBPHPURL  = "${URL_prefix}XGDB/phplib/";               #conf-UNIQ#
$XGDB_IMAGEURL   = "/XGDB/images";
$XGDB_DATAURL   = "/data/";

$XGDB_HEADER = "header.php";
$XGDB_FOOTER = "footer.php";

# Binaries / Programs / Resources

$BLAST_INSDIR = "/usr/local/bin/";
$BLASTALL = "${BLAST_INSDIR}blastall";  #conf#
$FORMATDB = "${BLAST_INSDIR}formatdb";  #conf#
$FASTACMD = "${BLAST_INSDIR}fastacmd";  #conf#
$VMATCH   = "/usr/local/bin/vmatch";    #conf#
$KEY_SOURCE_DIR="${XGDB_INPUTDIR}keys/";
$GENEMARK_KEY_DIR="/usr/local/src/GENEMARK/genemark_hmm_euk.linux_64/";
$GENEMARK_KEY=".gm_key";
$GENOMETHREADER_KEY_DIR="/usr/local/bin/";
$GENOMETHREADER_KEY="gth.lic";
$VMATCH_KEY_DIR="/usr/local/bin/";
$VMATCH_KEY="vmatch.lic";
$EMBOSS = "/usr/local/src/EMBOSS/EMBOSS-6.5.7/emboss"; # 1-20-16 J Duvick

$TIMEZONE = "US/Arizona";

# Dynamic Attached Volume INFO (iPlant only)
$EXT_MOUNT_DIR="";
if(file_exists("/xGDBvm/admin/iplant")) 
{
    include_once('/xGDBvm/XGDB/phplib/devloc.inc.php'); #reads device location from /xGDBvm/admin/devloc
    $EXT_MOUNT_DIR=devloc();
}
 # Debug: $EXT_MOUNT_DIR="/dev/vdc";
 
# Database INFO
$DB_HOST     = "localhost";              #conf#
$DB_USER     = "xgdbSELECT";        #conf#
$DB_PASSWORD = "";                 #conf#
include_once('/xGDBvm/XGDB/phplib/db.inc.php'); #reads MySQL password from /xGDBvm/admin/dbpass
$dbpass=dbpass();
$db = mysql_connect($DB_HOST, 'gdbuser', $dbpass);
if(!$db)
{
        echo "Error: Could not connect to database!";
        exit;
}
mysql_select_db("Genomes");
$xGDB = array();
$query = "SELECT DBname,Organism,ID from xGDB_Log where Status='Current' order by ID";
$result = mysql_query($query);
                        $numRows = mysql_num_rows($result);
                        while($row = mysql_fetch_row($result)){
					$xGDB[$row[0]]="GDB".substr(("00".$row[2]),-3);#calculated from unique ID                        }
					
                        }
                        
$config = array();
$conf_query = "SELECT DBname,Organism,ID, Status from xGDB_Log order by ID";
$conf_result = mysql_query($conf_query);
                        $conf_numRows = mysql_num_rows($conf_result);
                        while($row = mysql_fetch_row($conf_result)){
					$config[$row[0]]="GDB".substr(("00".$row[2]),-3);#calculated from unique ID                        }
                        }

# Standard Track Colors; see also TEMPLATE_SITEDEF.php where these colors are use or overridden by user config.

$EST_COLOR="red";
$CDNA_COLOR="lightblue";
$TSA_COLOR="firebrick";
$PROT_COLOR="black";
$GENE_COLOR="blue";
$CpGAT_COLOR="lime";




