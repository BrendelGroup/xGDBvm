#!/usr/bin/perl
use CGI ":all";
use DBI;
use LWP::Simple qw(!head);
use DBI;
use PHP::Session;
require "/xGDBvm/src/yrGATE/conf/yrGATE_conf.pl";
use strict vars;
use vars qw(
$dbpass
$line
$DBhost
$GV
$GVportal
$PRM
@modes
$DBH
$zeroPos
$portalvar
$mode
$rootPath
);

# added by jfd july 2013
if (-e "/xGDBvm/admin/https") {
    $rootPath = "https://$ENV{SERVER_NAME}/";
  } else {
    $rootPath = "http://$ENV{SERVER_NAME}/";
}

# added 10-30-12
$dbpass='';
open FILE, "/xGDBvm/admin/dbpass";
while ($line=<FILE>){
$dbpass= $line;
}


####################################################################
# Global Variables
####################################################################
my %attr = (PrintError=>0,RaiseError=>0);

$GV = {
	## url paths
	rootPATH => ${rootPath},
	CGIPATH => "/yrGATE/GDB###/",
	HTMLPATH => "/src/yrGATE/",
	JSPATH => "/src/yrGATE/",
	IMAGEDIR => "/src/yrGATE/images/",
	tempImageWebDir => "/tmp/yrGATE/GDB###",

	## local image directory
	tempImageDir => "/xGDBvm/tmp/GDB###/",

	## general
	formName => 'yrgateFRM',
	dbTitle => "GDB###",
	speciesName => "GDB###",
	CHR_SELECT_BOX => 0,
	CHR_LIST => [""],
	ANNOTATION_TYPES => ["protein coding gene","noncoding gene","snRNA","tRNA","transposon"],


	## functions
	InitFunction => sub{ require '../local_scripts/xgdb_functions.pl';},
	headerExtraFunction => "headerExtra",
	ScaleFunction => "getScale_xgdb",
	ImageMapFunction => "getImageMap_xgdb",
	GenomeSeqFunction => "getGenomeSequence_xgdb",
	EvidenceFunction => "getEvidence_db",
	GenomeContextLinkFunction => "GenomeContextLink_xgdb",


	## community
	login_required => 1,
	SessCookieName => "PlantGDB-phpsessid",
	SessLoginParam => "yrGATElogin",
	session_path => "/xGDBvm/tmp",
	email => 1,
	AdminEmail => "###\@###", # email of administrators, escape @
	emailbin => "/usr/sbin/sendmail",

	getUserIdFunction => getUserId,
	getUserGroupFunction => getUserGroup,
	getAdminOwnershipFunction => getAdminOwnership,
	getWorkingGroupAdminFunction => getWorkingGroupAdmin,

	## user verification database
	LDBH => DBI->connect("DBI:mysql:yrgate:$DBhost",'gdbuser',$dbpass,\%attr), # connection to users, and admin_session table

	## community annotation database
	ADBH => DBI->connect("DBI:mysql:GDB###:$DBhost",'yrgateUser','',\%attr), # connection to annotation database

	## evidence database
	DBH => DBI->connect("DBI:mysql:GDB###:$DBhost",'xgdbSELECT','',\%attr), # connection to evidence database

	## genomes database
	GDBH => DBI->connect("DBI:mysql:Genomes:$DBhost",'xgdbSELECT','',\%attr), # connection to genomes database

	## admin database
	ADMDBH => DBI->connect("DBI:mysql:Admin:$DBhost",'xgdbSELECT','',\%attr), # connection to admin database

	evidenceSources => sub {
		my $arr = [
			["cdna","blue","select '$GV->{dbTitle}','GeneSeqer_cDNA',uid,gi,gseg_start,gseg_stop,score,num,concat(\"$GV->{rootPATH}$GV->{SSIpath}getGSQ.pl?dbid=$GV->{dbid}&resid=5&gsegSRC=$GV->{dbTitle}scaffold&pgs_uid=\",uid) from gseg_cdna_good_pgs as a, gseg_cdna_good_pgs_exons as b where (a.uid=b.pgs_uid)&&(b.gseg_stop <= $PRM->{end})&&(b.gseg_stop>=$PRM->{start})&&(a.gseg_gi = '$PRM->{chr}')"],
			["est","red","select '$GV->{dbTitle}','GeneSeqer_EST',uid,gi,gseg_start,gseg_stop,score,num,concat(\"$GV->{rootPATH}$GV->{SSIpath}getGSQ.pl?dbid=$GV->{dbid}&resid=6&gsegSRC=$GV->{dbTitle}scaffold&pgs_uid=\",uid) from gseg_est_good_pgs as a, gseg_est_good_pgs_exons as b where (a.uid=b.pgs_uid)&&(b.gseg_stop <= $PRM->{end})&&(b.gseg_stop>=$PRM->{start})&&(a.gseg_gi = '$PRM->{chr}')"],
			["put","firebrick","select '$GV->{dbTitle}','GeneSeqer_PUT',uid,gi,gseg_start,gseg_stop,score,num,concat(\"$GV->{rootPATH}$GV->{SSIpath}getGSQ.pl?dbid=$GV->{dbid}&resid=7&gsegSRC=$GV->{dbTitle}scaffold&pgs_uid=\",uid) from gseg_put_good_pgs as a, gseg_put_good_pgs_exons as b where (a.uid=b.pgs_uid)&&(b.gseg_stop <= $PRM->{end})&&(b.gseg_stop>=$PRM->{start})&&(a.gseg_gi = '$PRM->{chr}')"],
			["pep","black","select '$GV->{dbTitle}','GenomeThreader_Protein_homologous',uid,gi,gseg_start,gseg_stop,score,num,concat(\"$GV->{rootPATH}$GV->{SSIpath}getGSQ.pl?dbid=$GV->{dbid}&resid=4&gsegSRC=$GV->{dbTitle}scaffold&pgs_uid=\",uid) from gseg_pep_good_pgs as a, gseg_pep_good_pgs_exons as b where (a.uid=b.pgs_uid)&&(b.gseg_stop <= $PRM->{end})&&(b.gseg_stop>=$PRM->{start})&&(a.gseg_gi = '$PRM->{chr}')"],
	];

		return $arr;
	},
	sampleEntryLink=> "<a href='/yrGATE/GDB###/AnnotationTool.pl?chr=27383&start=79615&end=82973' target='_blank'>Ricinus communis Scaffold 27383 region 79615:82973</a>",

	dasInput => 0,

	## misc
	eTableHeight => "700",
	SSIpath => "GDB###/cgi-bin/",
	dbid =>'0',
	altblastDB => 'GDB###scaffold',
};


# form variable hash PRM
$PRM = {
	imgWidth => (param("imgWidth") ne "") ? param("imgWidth") : 400,
	start => param("start") ? param("start") :"" ,
	end => param("end") ? param("end"): "",
	chr => param('chr') ? param('chr'): "",
	uid => param("uid") ? param("uid") : "",
	id => param("id") ? param("id"): "", # need? is this geneId
	UCAannid => param("UCAannid") ? param("UCAannid") : "", # geneId
	prod => param("UCAprod") ? param("UCAprod"): "",
	cds_start => param('UCAcdsstart') ? param('UCAcdsstart'): "",
	cds_end => param('UCAcdsend') ? param('UCAcdsend'): "",
	geneAlias => param('UCAannalias') ? param('UCAannalias'): "",
	protAlias => param('UCAprotalias') ? param('UCAprotalias') : "",
	info => param('UCAstruct') ? param('UCAstruct'): "",
	desc => param('UCAdesc') ?  param('UCAdesc'): "",
	comment => param('comment') ?  param('comment'): "",
	defSTRAND => param('UCAstrand') ? param('UCAstrand'): "",
	UDEsource => param('UDEsource') ? param('UDEsource'): "",
	Esource => param('Esource') ? param('Esource'): "",
	mode => param('mode') ? param('mode'): "",
	status => param('status') ? param('status') : 'NEW_ANNOTATION_NOT_SAVED', # for purposes of display, not for status field in storage
	emailTXT => param('emailTXT') ? param('emailTXT'): "", # comment on administrated annotations
	editedUID => param('editedUID') ? param('editedUID') : "", # is this unique id or geneid
	modifyState => param('modifyState') ? param('modifyState') : "", # used for first load UCA
	GSeqEdits => param('GSeqEdits') ? param('GSeqEdits') : "",
	annotation_type => param('annotation_type') ? param('annotation_type') : "",
	mRNAseq => param('mRNAseq') ? param('mRNAseq') : "",
	proteinseq => param('protein') ? param('protein') : "",
	dbVer => param('dbVer') ? param('dbVer') : $GV->{dbid}, # Think before copying this line as a template for a new variable. Might be bad idea.
	annotation_class => param('annotation_class') ? param('annotation_class') : "",
	locusId => param('locusId') ? param('locusId') : "",
	transcriptId => param('transcriptId') ? param('transcriptId') : "",
	category => param('category') ? param('category') : "",
	working_group => param('working_group') ? param('working_group') : "",
};

$PRM->{largeImage} = ($PRM->{imgWidth} eq "800") ? 1 : 0;


my %styleHash = (
	light1 => "",
	dark1 => "",
	button => ""
);


# Portal Default Variables
$portalvar = {
    GENEMARK_speciesmodel => "A.thaliana",
    GENSCAN_speciesmodel => "Arabidopsis",
    GeneSeqer_speciesmodel => "Arabidopsis",
};

