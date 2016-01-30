#!/usr/bin/perl
use CGI ":all";
use DBI;
use LWP::Simple qw(!head);
use DBI;
use PHP::Session;
 
use strict vars;
use vars qw(
$GV
$GVportal
$PRM
@modes
$DBH
$zeroPos
$portalvar
);
 
 
####################################################################
# Global Variables
####################################################################
my %attr = (PrintError=>0,RaiseError=>0);
 
$GV = {

                  ## url paths
                  rootPATH => "http://localhost/",
                  CGIPATH => "/yrGATE-cgi/",
                  HTMLPATH => "/yrGATE/",
                  JSPATH => "/yrGATE/",
                  IMAGEDIR => "/yrGATE/images/",
                  tempImageWebDir => "/yrGATE/tmp/",

                  ## local image directory
                  tempImageDir => "/yrGATE/yrGATE_html/tmp/",
    
                  ## general
                  formName => 'yrgateFRM',
                  dbTitle => "das input",
                  specieName => "",
                  CHR_SELECT_BOX => 0,
                  CHR_LIST => [],
                  ANNOTATION_TYPES => ["protein coding gene","noncoding gene","snRNA","tRNA","transposon"],
               
 
                  ## functions
                  InitFunction => "init_das",
                  ScaleFunction => "getScale",
                  ImageMapFunction => "getImageMap",
                  GenomeSeqFunction => "getGenomeSequence_das",
                  EvidenceFunction => "getEvidence_das",
                  GenomeContextLinkFunction => sub{},
 
 
                  ## community
                  login_required => 1,  
                  SessCookieName => "PlantGDB-phpsessid",
                  SessLoginParam => "yrGATElogin",
                  session_path => "/tmp",
                  email => 0,
                  AdminEmail => "admin\@host.com", # email of administrators, escape @
                  emailbin => "/usr/sbin/sendmail", 

                  getUserIdFunction => getUserId,
                  getUserGroupFunction => getUserGroup,
                  getAdminOwnershipFunction => getAdminOwnership,
 
                  ## user verification database
                  LDBH => DBI->connect("DBI:mysql:yrgate:localhost",'yrgateUser','',\%attr), # connection to users, and admin_session table
 
                  ## community annotation database
                  ADBH => DBI->connect("DBI:mysql:yrgate:localhost",'yrgateUser','',\%attr), # connection to annotation database
 
                  ## evidence database
                  #DBH => , # connection to evidence database
                   
                  evidenceSources => sub {
                                          my $arr = [

                                                     ];
                                          return $arr;
                                 },

		  sampleEntryLink=>  "<a href='das_scripts/dasSelect.pl' target='_blank'>DAS input selection page</a>",

                  dasInput => 1,
 
                  ## misc
                  eTableHeight => "420",


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
                defSTRAND => param('UCAstrand') ? param('UCAstrand'): "",
                UDEsource => param('UDEsource') ? param('UDEsource'): "",
                Esource => param('Esource') ? param('Esource'): "",
                mode => param('mode') ? param('mode'): "",
                status => param('status') ? param('status') : 'new annotation - not saved', # for purposes of display, not for status field in storage
                emailTXT => param('emailTXT') ? param('emailTXT'): "", # comment on administrated annotations
                editedUID => param('editedUID') ? param('editedUID') : "", # is this unique id or geneid
                modifyState => param('modifyState') ? param('modifyState') : "", # used for first load UCA
                GSeqEdits => param('GSeqEdits') ? param('GSeqEdits') : "",
                annotation_type => param('annotation_type') ? param('annotation_type') : "",
                mRNAseq => param('mRNAseq') ? param('mRNAseq') : "",
                proteinseq => param('protein') ? param('protein') : ""
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
    GENSCAN_speciesmodel => "Arabidopsis"
};

