#!/usr/bin/perl
use CGI ":all";
use CGI::Session;
use DBI;


do 'SITEDEF.pl';
do 'getPARAM.pl';


my $cgiSID     = $cgi_paramHR->{'USERsession'} || CGI::cookie($CookieNAME) || CGI::param($CookieNAME) || undef;
my $sessionHOST  = (exists( $DBver[$cgi_paramHR->{dbid}]->{SESSIONhost} ))?$DBver[$cgi_paramHR->{dbid}]->{SESSIONhost} :(exists($DBver[$cgi_paramHR->{dbid}]->{DBhost}))?$DBver[$cgi_paramHR->{dbid}]->{DBhost}:$DB_HOST;
my $sessionUSER  = (exists( $DBver[$cgi_paramHR->{dbid}]->{SESSIONuser} ))?$DBver[$cgi_paramHR->{dbid}]->{SESSIONuser} :(exists($DBver[$cgi_paramHR->{dbid}]->{DBuser}))?$DBver[$cgi_paramHR->{dbid}]->{DBuser}:$DB_USER;
my $sessionPASS  = (exists( $DBver[$cgi_paramHR->{dbid}]->{SESSIONpass} ))?$DBver[$cgi_paramHR->{dbid}]->{SESSIONpass} :(exists($DBver[$cgi_paramHR->{dbid}]->{DBpass}))?$DBver[$cgi_paramHR->{dbid}]->{DBpass}:$DB_PASSWORD;
my $sessionDB  = (exists( $DBver[$cgi_paramHR->{dbid}]->{SESSIONdb} ))?$DBver[$cgi_paramHR->{dbid}]->{SESSIONdb} : $DBver[$cgi_paramHR->{dbid}]->{DB};
my $sDBH     = DBI->connect("DBI:mysql:${sessionDB}:${sessionHOST}",$sessionUSER,$sessionPASS,{RaiseError=> 1});
my $session  = new CGI::Session("dr:MySQL;id:xgdb_md5",$cgiSID,{Handle => $sDBH});


if(defined(param('track-reorder'))){
  $cgi_paramHR->{trackORDER} = param('track-reorder');
}

if(defined(param('track-delete')) && exists($cgi_paramHR->{frozen_user_tracks})){
  eval($cgi_paramHR->{frozen_user_tracks});
  my $ndx = param('track-delete') - scalar(@{$DBver[$cgi_paramHR->{dbid}]->{tracks}});
  if($ndx == 0){
    shift(@$user_tracks);
  }elsif($ndx == $#$user_tracks){
    delete($user_tracks->[$ndx]);
  }else{
    $user_tracks = [@{$user_tracks}[0..($ndx - 1)],@{$user_tracks}[($ndx + 1)..$#$user_tracks]];
  }
  if(scalar(@$user_tracks)){
    $cgi_paramHR->{frozen_user_tracks} = Data::Dumper->Dump([$user_tracks],["user_tracks"]);
  }else{
    delete($cgi_paramHR->{frozen_user_tracks});
  }
  my @tmpORD = split(',',$cgi_paramHR->{trackORDER});
  for($ndx=0;$ndx<=$#tmpORD;$ndx++){
    delete($tmpORD[$ndx]) if($tmpORD[$ndx] == param('track-delete'));
    $tmpORD[$ndx]-- if($tmpORD[$ndx] > param('track-delete'));
  }
  $cgi_paramHR->{trackORDER} = join(',',@tmpORD);
  $cgi_paramHR->{trackORDER} =~ s/,,+/,/g;
  my @tmpVIS = split(',',$cgi_paramHR->{trackVISIBLE});
  delete($tmpVIS[param('track-delete')]);
  $cgi_paramHR->{trackVISIBILE} = join(',',@tmpVIS);
}

if(defined(param('track-selectedImageOption'))){
  if(!exists($cgi_paramHR->{trackPREFS})){$cgi_paramHR->{trackPREFS} = [];}
  if(!exists($cgi_paramHR->{trackPREFS}->[param('track_resid')])){ $cgi_paramHR->{trackPREFS}->[param('track_resid')] = {}; }
  $cgi_paramHR->{trackPREFS}->[param('track_resid')]->{selectedImageOption} = param('track-selectedImageOption');
}

if(defined(param('track-toggled'))){
  if(!exists($cgi_paramHR->{trackPREFS})){$cgi_paramHR->{trackPREFS} = [];}
  if(!exists($cgi_paramHR->{trackPREFS}->[param('track_resid')])){ $cgi_paramHR->{trackPREFS}->[param('track_resid')] = {}; }
  $cgi_paramHR->{trackPREFS}->[param('track_resid')]->{toggled} = param('track-toggled');
}

#### UPDATE SESSION STATE STORE 
#### (Data::Dumper inherited from getParam.pl)

$session->param("cgi_paramHR",$cgi_paramHR);

print header(-cookie=>$sCookie);
