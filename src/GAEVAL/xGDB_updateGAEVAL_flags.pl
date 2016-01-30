#!/usr/bin/perl

use Getopt::Long qw/:config no_ignore_case bundling/;

## need to add some default/initial values for options here

GetOptions("C|configuration=s"  => \$configFile,
    "D|database=s"          => \$database,
    "H|host=s"      => \$host,
    "U|dbuser=s"        => \$dbUSER,
    "P|dbpassword=s"    => \$dbPASS,
    "annotation_table"  => \$annTable,
    "flag_table=s"      => \$flagTable,
    "prop_table=s"      => \$propTable,
    "outDIR=s"  => \$outpath,
    "outFILE=s" => \$outfile
      );
if(defined($configFile)&&(-r $configFile)){
  do $configFile;
  ($tmp,$tmp,$database,$host) = split(':',$argHR->{dsn});
  $annTable  = $argHR->{GAEVAL_ANN_TBL};
  $flagTable = $argHR->{GAEVAL_FLAGS_TBL};
  $propTable = $argHR->{GAEVAL_PROPERTIES_TBL};
}

my $cmd = <<END_OF_CMD;
drop table if exists $flagTable;
CREATE TABLE $flagTable (
  `annUID` int(10) NOT NULL default '0',
  `AE_AmbOverlap` int(10) unsigned NOT NULL default '0',
  `AE_AmbOverlap_doc` int(10) NOT NULL default '0',
  `AE_AmbOverlap_mindoc` int(10) NOT NULL default '0',
  `AE_AmbOverlap_maxdoc` int(10) NOT NULL default '0',
  `AS_AddIntron` int(10) unsigned NOT NULL default '0',
  `AS_AddIntron_doc` int(10) NOT NULL default '0',
  `AS_AddIntron_mindoc` int(10) NOT NULL default '0',
  `AS_AddIntron_maxdoc` int(10) NOT NULL default '0',
  `AS_AltAnnIntron` int(10) unsigned NOT NULL default '0',
  `AS_AltAnnIntron_doc` int(10) NOT NULL default '0',
  `AS_AltAnnIntron_mindoc` int(10) NOT NULL default '0',
  `AS_AltAnnIntron_maxdoc` int(10) NOT NULL default '0',
  `AS_AltIntron` int(10) unsigned NOT NULL default '0',
  `AS_AltIntron_doc` int(10) NOT NULL default '0',
  `AS_AltIntron_mindoc` int(10) NOT NULL default '0',
  `AS_AltIntron_maxdoc` int(10) NOT NULL default '0',
  `AS_ConIntron` int(10) unsigned NOT NULL default '0',
  `AS_ConIntron_doc` int(10) NOT NULL default '0',
  `AS_ConIntron_mindoc` int(10) NOT NULL default '0',
  `AS_ConIntron_maxdoc` int(10) NOT NULL default '0',
  `AS_PseudoIntron` int(10) unsigned NOT NULL default '0',
  `AS_PseudoIntron_doc` int(10) NOT NULL default '0',
  `AS_PseudoIntron_mindoc` int(10) NOT NULL default '0',
  `AS_PseudoIntron_maxdoc` int(10) NOT NULL default '0',
  `CM_AltCPS` int(10) unsigned NOT NULL default '0',
  `CM_AltCPS_doc` int(10) NOT NULL default '0',
  `CM_AltCPS_mindoc` int(10) NOT NULL default '0',
  `CM_AltCPS_maxdoc` int(10) NOT NULL default '0',
  `CM_Fission` int(10) unsigned NOT NULL default '0',
  `CM_Fission_doc` int(10) NOT NULL default '0',
  `CM_Fission_mindoc` int(10) NOT NULL default '0',
  `CM_Fission_maxdoc` int(10) NOT NULL default '0',
  `CM_Fusion` int(10) unsigned NOT NULL default '0',
  `CM_Fusion_doc` int(10) NOT NULL default '0',
  `CM_Fusion_mindoc` int(10) NOT NULL default '0',
  `CM_Fusion_maxdoc` int(10) NOT NULL default '0',
  `CM_MainCPS` int(10) unsigned NOT NULL default '0',
  `CM_MainCPS_doc` int(10) NOT NULL default '0',
  `CM_MainCPS_mindoc` int(10) NOT NULL default '0',
  `CM_MainCPS_maxdoc` int(10) NOT NULL default '0',
  KEY `auIND` (`annUID`)
);
insert into $flagTable (annUID) select uid as annUID from $annTable;
create temporary table gaeval_tmp select annUID, count(*) as flag, min(abs(documented)) as doc, min(documented) as mindoc, max(documented) as maxdoc from $propTable where property = 'AE_AmbOverlap' group by annUID;
update $flagTable as t1 JOIN gaeval_tmp as t2 USING(annUID) SET t1.AE_AmbOverlap = t2.flag, t1.AE_AmbOverlap_doc = t2.doc, t1.AE_AmbOverlap_mindoc = t2.mindoc, t1.AE_AmbOverlap_maxdoc = t2.maxdoc;
drop temporary table gaeval_tmp;
create temporary table gaeval_tmp select annUID, count(*) as flag, min(abs(documented)) as doc, min(documented) as mindoc, max(documented) as maxdoc from $propTable where property = 'AS_AddIntron' group by annUID;
update $flagTable as t1 JOIN gaeval_tmp as t2 USING(annUID) SET t1.AS_AddIntron = t2.flag, t1.AS_AddIntron_doc = t2.doc, t1.AS_AddIntron_mindoc = t2.mindoc, t1.AS_AddIntron_maxdoc = t2.maxdoc;
drop temporary table gaeval_tmp;
create temporary table gaeval_tmp select annUID, count(*) as flag, min(abs(documented)) as doc, min(documented) as mindoc, max(documented) as maxdoc from $propTable where property = 'AS_AltAnnIntron' group by annUID;
update $flagTable as t1 JOIN gaeval_tmp as t2 USING(annUID) SET t1.AS_AltAnnIntron = t2.flag, t1.AS_AltAnnIntron_doc = t2.doc, t1.AS_AltAnnIntron_mindoc = t2.mindoc, t1.AS_AltAnnIntron_maxdoc = t2.maxdoc;
drop temporary table gaeval_tmp;
create temporary table gaeval_tmp select annUID, count(*) as flag, min(abs(documented)) as doc, min(documented) as mindoc, max(documented) as maxdoc from $propTable where property = 'AS_AltIntron' group by annUID;
update $flagTable as t1 JOIN gaeval_tmp as t2 USING(annUID) SET t1.AS_AltIntron = t2.flag, t1.AS_AltIntron_doc = t2.doc, t1.AS_AltIntron_mindoc = t2.mindoc, t1.AS_AltIntron_maxdoc = t2.maxdoc;
drop temporary table gaeval_tmp;
create temporary table gaeval_tmp select annUID, count(*) as flag, min(abs(documented)) as doc, min(documented) as mindoc, max(documented) as maxdoc from $propTable where property = 'AS_ConIntron' group by annUID;
update $flagTable as t1 JOIN gaeval_tmp as t2 USING(annUID) SET t1.AS_ConIntron = t2.flag, t1.AS_ConIntron_doc = t2.doc, t1.AS_ConIntron_mindoc = t2.mindoc, t1.AS_ConIntron_maxdoc = t2.maxdoc;
drop temporary table gaeval_tmp;
create temporary table gaeval_tmp select annUID, count(*) as flag, min(abs(documented)) as doc, min(documented) as mindoc, max(documented) as maxdoc from $propTable where property = 'AS_PseudoIntron' group by annUID;
update $flagTable as t1 JOIN gaeval_tmp as t2 USING(annUID) SET t1.AS_PseudoIntron = t2.flag, t1.AS_PseudoIntron_doc = t2.doc, t1.AS_PseudoIntron_mindoc = t2.mindoc, t1.AS_PseudoIntron_maxdoc = t2.maxdoc;
drop temporary table gaeval_tmp;
create temporary table gaeval_tmp select annUID, count(*) as flag, min(abs(documented)) as doc, min(documented) as mindoc, max(documented) as maxdoc from $propTable where property = 'CM_AltCPS' group by annUID;
update $flagTable as t1 JOIN gaeval_tmp as t2 USING(annUID) SET t1.CM_AltCPS = t2.flag, t1.CM_AltCPS_doc = t2.doc, t1.CM_AltCPS_mindoc = t2.mindoc, t1.CM_AltCPS_maxdoc = t2.maxdoc;
drop temporary table gaeval_tmp;
create temporary table gaeval_tmp select annUID, count(*) as flag, min(abs(documented)) as doc, min(documented) as mindoc, max(documented) as maxdoc from $propTable where property = 'CM_Fission' group by annUID;
update $flagTable as t1 JOIN gaeval_tmp as t2 USING(annUID) SET t1.CM_Fission = t2.flag, t1.CM_Fission_doc = t2.doc, t1.CM_Fission_mindoc = t2.mindoc, t1.CM_Fission_maxdoc = t2.maxdoc;
drop temporary table gaeval_tmp;
create temporary table gaeval_tmp select annUID, count(*) as flag, min(abs(documented)) as doc, min(documented) as mindoc, max(documented) as maxdoc from $propTable where property = 'CM_Fusion' group by annUID;
update $flagTable as t1 JOIN gaeval_tmp as t2 USING(annUID) SET t1.CM_Fusion = t2.flag, t1.CM_Fusion_doc = t2.doc, t1.CM_Fusion_mindoc = t2.mindoc, t1.CM_Fusion_maxdoc = t2.maxdoc;
drop temporary table gaeval_tmp;
create temporary table gaeval_tmp select annUID, count(*) as flag, min(abs(documented)) as doc, min(documented) as mindoc, max(documented) as maxdoc from $propTable where property = 'CM_MainCPS' group by annUID;
update $flagTable as t1 JOIN gaeval_tmp as t2 USING(annUID) SET t1.CM_MainCPS = t2.flag, t1.CM_MainCPS_doc = t2.doc, t1.CM_MainCPS_mindoc = t2.mindoc, t1.CM_MainCPS_maxdoc = t2.maxdoc;

END_OF_CMD

open(CMDF,">${outpath}${outfile}");
print CMDF $cmd;
close(CMDF);

