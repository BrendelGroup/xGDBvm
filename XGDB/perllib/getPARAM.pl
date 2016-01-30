## grab form parameters and saved cookies
use CGI ":all";
use CGI::Session;
use DBI;

do 'SITEDEF.pl';

#### SESSION DEFAULTS
my %defaultParams = (	
			wsize   => 3,
			fontSize=> 1,
			dbid    => $#DBver,
			seqUID  => 6,
			sMETHOD => "Quick",
			trackORDER   => $DBver[$#DBver]->{trackORD},
			trackVISIBLE => $DBver[$#DBver]->{trackVIS},
              	    );

my $BlastIndexDIR= "/DATA/PlantGDB/Index/Blast/";
my %PEP_DB =(
                        ATpep =>["TAIR9","${BlastIndexDIR}ATpep"],
                        OSpep =>["RiceTAIR6","${BlastIndexDIR}OSpep"]
        );

$defaultParams{dbid} = param(dbid) if param(dbid);

## I HATE KLUDGES (BAC/CHR browser issue)
if(exists($DBver[$defaultParams{dbid}]->{defaultChr})){
  $defaultParams{altCONTEXT} = 'chr';
  $defaultParams{chr}   = $DBver[$defaultParams{dbid}]->{defaultChr};
  $defaultParams{l_pos} = $DBver[$defaultParams{dbid}]->{defaultL_pos};
  $defaultParams{r_pos} = $DBver[$defaultParams{dbid}]->{defaultR_pos};
}elsif(exists($DBver[$defaultParams{dbid}]->{default_gseg_gi})){
  $defaultParams{altCONTEXT} = 'BAC';
  $defaultParams{gseg_gi}  = $DBver[$defaultParams{dbid}]->{default_gseg_gi};
  $defaultParams{l_pos} = $defaultParams{bac_lpos} = $DBver[$defaultParams{dbid}]->{defaultL_pos};
  $defaultParams{r_pos} = $defaultParams{bac_rpos} = $DBver[$defaultParams{dbid}]->{defaultR_pos};
}
#####

$cgi_paramHR = {%defaultParams} if(! defined($cgi_paramHR));

do 'checkLOGIN.pl';    ## Check for logged-in Users >> return user session ID with cgi_paramHR->{'USERsession'}

#### RETREIVE SAVED SESSION
my $CookieNAME = "xGDB-cgisessid"; 
my $cgiSID     = $cgi_paramHR->{'USERsession'} || CGI::cookie($CookieNAME) || CGI::param($CookieNAME) || undef;

return 1 if(param('NO_SESSION')); ## Shortcut to default params for first time PHP page access

my $USERid_from_login = $cgi_paramHR->{'USERid'};
my $AUTHsession_from_login = $cgi_paramHR->{'AUTHsession'};

my $sessionHOST  = (exists( $DBver[$cgi_paramHR->{dbid}]->{SESSIONhost} ))?$DBver[$cgi_paramHR->{dbid}]->{SESSIONhost} :(exists($DBver[$cgi_paramHR->{dbid}]->{DBhost}))?$DBver[$cgi_paramHR->{dbid}]->{DBhost}:$DB_HOST;
my $sessionUSER  = (exists( $DBver[$cgi_paramHR->{dbid}]->{SESSIONuser} ))?$DBver[$cgi_paramHR->{dbid}]->{SESSIONuser} :(exists($DBver[$cgi_paramHR->{dbid}]->{DBuser}))?$DBver[$cgi_paramHR->{dbid}]->{DBuser}:$DB_USER;
my $sessionPASS  = (exists( $DBver[$cgi_paramHR->{dbid}]->{SESSIONpass} ))?$DBver[$cgi_paramHR->{dbid}]->{SESSIONpass} :(exists($DBver[$cgi_paramHR->{dbid}]->{DBpass}))?$DBver[$cgi_paramHR->{dbid}]->{DBpass}:$DB_PASSWORD;
my $sessionDB  = (exists( $DBver[$cgi_paramHR->{dbid}]->{SESSIONdb} ))?$DBver[$cgi_paramHR->{dbid}]->{SESSIONdb} : $DBver[$cgi_paramHR->{dbid}]->{DB};
my $sDBH     = DBI->connect("DBI:mysql:${sessionDB}:${sessionHOST}",$sessionUSER,$sessionPASS,{RaiseError=> 1});
my $session  = new CGI::Session("dr:MySQL;id:xgdb_md5",$cgiSID,{Handle => $sDBH});

#### INFLATE SAVED SESSION
$cgi_paramHR = $session->param("cgi_paramHR") if(defined($cgiSID));
$cgi_paramHR = {%defaultParams} if(!defined($cgi_paramHR)); ## If session doesn't contain cgi_paramHR reset to default
$cgi_paramHR->{'AUTHsession'} = $AUTHsession_from_login if(defined($AUTHsession_from_login));

#### PRECHECK FOR DEVELOPER DEBUG FLAG
$cgi_paramHR->{DEBUG} = param('DEBUG') if(param('DEBUG'));

#### VALIDATE USERid FROM LOGIN
if(($USERid_from_login eq '')&&($cgi_paramHR->{USERid} ne '')){
  ## This takes care of the rare occasion that a session id from a logged off account remains in the browser CGIsession cookie
  $cgiSID = CGI::cookie($CookieNAME) || CGI::param($CookieNAME) || undef;
  $session = new CGI::Session("dr:MySQL;id:xgdb_md5",$cgiSID,{Handle => $sDBH});
  $cgi_paramHR = {%defaultParams}; #### RESTORE SESSION DEFAULTS

  #### RECHECK FOR DEVELOPER DEBUG FLAG
  $cgi_paramHR->{DEBUG} = param('DEBUG') if(param('DEBUG'));

  if(exists($cgi_paramHR->{DEBUG}) && $cgi_paramHR->{DEBUG}){
    if(!defined($cgiSID)){
      print STDERR "[getParam.pl] USER SESSION CLOSED! New Anonymous session created ID:" . $session->id() . "\n";
    }else{
      print STDERR "[getParam.pl] USER SESSION CLOSED! Guess session re-established ID:" . $session->id() . "\n";
    }
  }

}elsif(($USERid_from_login ne '')&&($cgi_paramHR->{USERid} eq '')){
  $cgi_paramHR = {%defaultParams}; #### RESTORE SESSION DEFAULTS
  $cgi_paramHR->{USERid} = $USERid_from_login;
}elsif(($USERid_from_login eq 'SSIpassthrough')&&($cgi_paramHR->{USERid} ne '')){
  $USERid_from_login = $cgi_paramHR->{USERid};
}  

if(exists($cgi_paramHR->{DEBUG}) && $cgi_paramHR->{DEBUG}){
  if(!defined($cgiSID)){
    print STDERR "[getParam.pl] NEW SESSION CREATED ID:" . $session->id() . "\n";
  }else{
    print STDERR "[getParam.pl] SESSION LOADED USER:$USERid_from_login ID:" . $session->id() . "\n";
  }
}


#### INCORPORATE POST/GET PARAMETERS

## >>KLUDGE<< Need to clean up logic for l_pos / bac_lpos (JOINT GSEG/CHR BROWSER ISSUE)
$cgi_paramHR->{bac_lpos} = param('l_pos') if(param('l_pos'));
$cgi_paramHR->{bac_rpos} = param('r_pos') if(param('r_pos'));
##
## >>KLUDGE<< Forcing the cleanout of session stored values used by the search routines
## instead we should be limiting the session storage to specific key parameters
delete($cgi_paramHR->{searchSTR}) if(exists($cgi_paramHR->{searchSTR}));
delete($cgi_paramHR->{gi}) if(exists($cgi_paramHR->{gi}));
delete($cgi_paramHR->{acc}) if(exists($cgi_paramHR->{acc}));
delete($cgi_paramHR->{id}) if(exists($cgi_paramHR->{id}));
##

my $arg = "";
foreach $arg (CGI::param()){
  my $value = CGI::param($arg);
  next if(length($value) > 100);
  $cgi_paramHR->{$arg} = $value if(!ref($value) || (ref($value) eq 'ARRAY') || (ref($value) eq 'HASH'));
}

## Check for login update (This logic will update the current genomic region into the users session instead of moving the user to the last viewed region while logged in)
if(exists($cgi_paramHR->{LOGINUPDATE}) && ($cgi_paramHR->{LOGINUPDATE} eq 'COORDONLY')){ 
  ## value 'COORDONLY' is being used to signify a request to update the users state with current/annonymous region coordinates only
  ## Retrieve current annonymous session
  ##<DEGUG>##print STDERR "[getParam.pl] LOGINUPDATE:COORDONLY request\n";

  my $cgiSID = CGI::cookie($CookieNAME) || CGI::param($CookieNAME) || undef;
  if(defined($cgiSID)){
    my $Asess = new CGI::Session("dr:MySQL;id:xgdb_md5",$cgiSID,{Handle => $sDBH});
    my $Acgi_paramHR = $Asess->param("cgi_paramHR");
    if(defined($Acgi_paramHR)){
      $cgi_paramHR->{chr} = $Acgi_paramHR->{chr} if(exists($Acgi_paramHR->{chr}));
      $cgi_paramHR->{gi}  = $Acgi_paramHR->{gi} if(exists($Acgi_paramHR->{gi}));
      $cgi_paramHR->{gseg_gi} = Acgi_paramHR->{gseg_gi} if(exists($Acgi_paramHR->{gseg_gi}));
      $cgi_paramHR->{gseg_acc} = Acgi_paramHR->{gseg_acc} if(exists($Acgi_paramHR->{gseg_acc})); # JPD 4-8-11 test
      $cgi_paramHR->{l_pos} = $Acgi_paramHR->{l_pos} if(exists($Acgi_paramHR->{l_pos}));
      $cgi_paramHR->{r_pos} = $Acgi_paramHR->{r_pos} if(exists($Acgi_paramHR->{r_pos}));
      $cgi_paramHR->{bac_lpos} = $Acgi_paramHR->{bac_lpos} if(exists($Acgi_paramHR->{bac_lpos}));
      $cgi_paramHR->{bac_rpos} = $Acgi_paramHR->{bac_rpos} if(exists($Acgi_paramHR->{bac_rpos}));
      $cgi_paramHR->{imgW} = $Acgi_paramHR->{imgW} if(exists($Acgi_paramHR->{imgW}));
    }
  }
  delete($cgi_paramHR->{LOGINUPDATE});
}

## verify state value ranges
  $cgi_paramHR->{dbid} = $#DBver if($cgi_paramHR->{dbid} > $#DBver);
  $cgi_paramHR->{chr} = 1 if(exists($cgi_paramHR->{chr}) && ($cgi_paramHR->{chr} > ($#{$DBver[$cgi_paramHR->{dbid}]->{chrSIZE}} + 1)));
  $cgi_paramHR->{l_pos} = 1 if($cgi_paramHR->{l_pos} < 1);
  $cgi_paramHR->{r_pos} = $DBver[$cgi_paramHR->{dbid}]->{chrSIZE}->[$cgi_paramHR->{chr} - 1] if($cgi_paramHR->{r_pos} > $DBver[$cgi_paramHR->{dbid}]->{chrSIZE}->[$cgi_paramHR->{chr} - 1]); 

## force integer coords
  $cgi_paramHR->{bac_lpos} = int($cgi_paramHR->{bac_lpos});
  $cgi_paramHR->{bac_rpos} =  int($cgi_paramHR->{bac_rpos});
  $cgi_paramHR->{l_pos} =  int($cgi_paramHR->{l_pos});
  $cgi_paramHR->{r_pos} =  int($cgi_paramHR->{r_pos});

## >>KLUDGE<< Need to clean up logic for l_pos / bac_lpos (JOINT GSEG/CHR BROWSER ISSUE)
if(exists($cgi_paramHR->{gseg_gi})){
$cgi_paramHR->{l_pos} = $cgi_paramHR->{bac_lpos} if(exists($cgi_paramHR->{bac_lpos}));
$cgi_paramHR->{r_pos} = $cgi_paramHR->{bac_rpos} if(exists($cgi_paramHR->{bac_rpos}));
}
## >>END_OF_KLUDGE<<

$cgi_paramHR->{"blastDB"} = ($cgi_paramHR->{"altCONTEXT"} eq "BAC") ? $GSEG_SRC : "GENOME";

#### Append user defined tracks ####
if(exists($cgi_paramHR->{frozen_user_tracks})){
  eval($cgi_paramHR->{frozen_user_tracks});
}
## Validate trackORDER/VISIBILE
my @tmpORD = split(',',$cgi_paramHR->{trackORDER});
my @tmpVIS = split(',',$cgi_paramHR->{trackVISIBLE});
my @preORD = split(',',$DBver[$cgi_paramHR->{dbid}]->{trackORD});
my $ctcnt = scalar(@tmpORD);
my $ptcnt = scalar(@preORD);
my $dtcnt = defined($user_tracks) ? scalar(@$user_tracks) : 0;
#### The following is meant to handle track inconsistencies caused by updating SITEDEF.pl to alter the predefined tracks
####   Dynamic track changes initiated by the user should each individually update the trackORDER/VISIBLE session parameters.
if(exists($cgi_paramHR->{DEBUG}) && $cgi_paramHR->{DEBUG}){
  print STDERR "[getParam.pl] trackOrder => (" . $cgi_paramHR->{trackORDER} . ") [ctcnt = $ctcnt]\n";
  print STDERR "[getParam.pl] trackVISIBLE => (" . $cgi_paramHR->{trackVISIBLE} . ")\n";
  print STDERR "[getParam.pl] preset trackORD => (" . $DBver[$cgi_paramHR->{dbid}]->{trackORD} . ") [ptcnt = $ptcnt]\n";
  print STDERR "[getParam.pl] dynamic track count = $dtcnt \n";
}

if($ctcnt < ($ptcnt + $dtcnt)){
  my $tresid = $ptcnt - 1;
  my $newTracks = ($ptcnt + $dtcnt - $ctcnt);
  my @newORD = ($tmpORD[0]);
  push(@newORD,$tresid .. ($tresid + $newTracks - 1));
  for(my $idx=1; $idx < $ctcnt; $idx++){
    $tmpORD[$idx] += $newTracks if($tmpORD[$idx] >= $tresid);
    push(@newORD,$tmpORD[$idx]);
  }
  for(my $idx=($ptcnt + $dtcnt - 1); $idx >= ($tresid + $newTracks); $idx--){
    $tmpVIS[$idx] = $tmp[$idx - $newTracks];
  }
  for(my $idx=$tresid; $idx < ($tresid + $newTracks); $idx++){
    $tmpVIS[$idx] = '1';
  }
  $cgi_paramHR->{trackORDER} = join(',',@newORD);
  $cgi_paramHR->{trackVISIBLE} = join(',',@tmpVIS);

print STDERR ">>>>[getParam.pl] trackORDER =>" . join(',',@newORD) . "\n";
print STDERR ">>>>[getParam.pl] trackVISIBLE => " . join(',',@tmpVIS) . "\n";

}elsif($ctcnt > ($ptcnt + $dtcnt)){
  my @newORD=();
  for(my $idx=0;$idx<=$#tmpORD;$idx++){
    next if($tmpORD[$idx] >= ($ptcnt + $dtcnt));
    push(@newORD,$tmpORD[$idx]);
  }
  $cgi_paramHR->{trackORDER} = join(',',@newORD);
  $cgi_paramHR->{trackVISIBLE} = join(',',@tmpVIS[0..$#newORD]);
}  
##

#DEFUNCT#$cgi_paramHR->{customORDER} = (defined(CGI::param('customORDER')))? param('customORDER'):$cgi_paramHR->{trackORDER};
#DEFUNCT#$cgi_paramHR->{customVISIBLE} = (defined(CGI::param('customVISIBLE')))? param('customVISIBLE'):$cgi_paramHR->{trackVISIBLE};

$seqUID = CGI::unescape(CGI::param('seqUID')) if defined(CGI::param('seqUID')); ###########<<<<<<<<<<<
$sSTR   = CGI::unescape(CGI::param('searchSTR')) if defined(CGI::param('searchSTR'));############<<<<<<<<<<

## wsize parameter MOD
if(($cgi_paramHR->{r_pos} - $cgi_paramHR->{l_pos}) > 99999){
  $cgi_paramHR->{wsize}=7;
}elsif(($cgi_paramHR->{r_pos} - $cgi_paramHR->{l_pos}) > 49999){
  $cgi_paramHR->{wsize}=6;
}elsif(($cgi_paramHR->{r_pos} - $cgi_paramHR->{l_pos}) > 19999){
  $cgi_paramHR->{wsize}=5;
}elsif(($cgi_paramHR->{r_pos} - $cgi_paramHR->{l_pos}) > 9999){
  $cgi_paramHR->{wsize}=4;
}elsif(($cgi_paramHR->{r_pos} - $cgi_paramHR->{l_pos}) > 4999){
  $cgi_paramHR->{wsize}=3;
}elsif(($cgi_paramHR->{r_pos} - $cgi_paramHR->{l_pos}) > 1999){
  $cgi_paramHR->{wsize}=2;
}elsif(($cgi_paramHR->{r_pos} - $cgi_paramHR->{l_pos}) > 999){
  $cgi_paramHR->{wsize}=1;
}else{
  $cgi_paramHR->{wsize}=0;
}


$sCookie = ($USERid_from_login eq '')?CGI::cookie(-name=>$CookieNAME,-expires=>'+10y',-value=>$session->id()):'';
$cgi_paramHR->{USERsession} = $session->id();

#### UPDATE SESSION STATE STORE
$session->param("cgi_paramHR",$cgi_paramHR);
