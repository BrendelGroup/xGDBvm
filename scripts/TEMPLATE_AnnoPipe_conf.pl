#!/usr/bin/perl
use CGI ":all";
use DBI;

use strict vars;
use vars qw(
$GV
$DBH
$PRM
); 


####################################################################
# Global Variables
####################################################################

my %attr = (PrintError=>0,RaiseError=>0);

$GV = { 
	rootPATH => "https://$ENV{SERVER_NAME}/",
	CGIPATH => "/GDB###/cgi-bin/",
        JSPATH => "/GDB###/javascripts/",
	ResultTMP => "/tmp/GDB###/",
	dbTitle => "GDB###",
	DBH => DBI->connect("DBI:mysql:GDB###:localhost",'xgdbSELECT','',\%attr),# connection to evidence database
	evidenceSources => sub {
				my $arr = [
		["mRNA","select uid,gi,E_O,sim,mlength,cov,gseg_gi,G_O,l_pos,r_pos,pgs,pgs_lpos,pgs_rpos,gseg_gaps,pgs_gaps from gseg_cdna_good_pgs where (r_pos <= $PRM->{end})&&(r_pos>=$PRM->{start})&&(gseg_gi = $PRM->{gseg_gi})"],
			["mRNA","select uid,gi,E_O,sim,mlength,cov,gseg_gi,G_O,l_pos,r_pos,pgs,pgs_lpos,pgs_rpos,gseg_gaps,pgs_gaps from gseg_est_good_pgs where (gseg_gi = $PRM->{gseg_gi})&&(r_pos <= $PRM->{end})&&(r_pos>=$PRM->{start})"],  
			["mRNA","select uid,gi,E_O,sim,mlength,cov,gseg_gi,G_O,l_pos,r_pos,pgs,pgs_lpos,pgs_rpos,gseg_gaps,pgs_gaps from gseg_put_good_pgs where (gseg_gi = $PRM->{gseg_gi})&&(r_pos <= $PRM->{end})&&(r_pos>=$PRM->{start})"],  
			["Protein","select uid,gi,E_O,sim,mlength,cov,gseg_gi,G_O,l_pos,r_pos,pgs,pgs_lpos,pgs_rpos,gseg_gaps,pgs_gaps from gseg_pep_good_pgs where (gseg_gi = $PRM->{gseg_gi})&&(r_pos <= $PRM->{end})&&(r_pos>=$PRM->{start})"],  
	];
	return $arr;
},
};
# form variable hash PRM
$PRM = {
		start => param("start") ? param("start") :"" ,
		end => param("end") ? param("end"): "",
		gseg_gi => param('gseg_gi') ? param('gseg_gi'): "",
	};
