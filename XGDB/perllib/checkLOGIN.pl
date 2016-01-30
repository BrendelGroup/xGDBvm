## grab form parameters and saved cookies
use CGI ":all";
use PHP::Session;

$GV->{SessCookieName} = "PlantGDB-phpsessid" if(!defined($GV->{SessCookieName}));
$GV->{SessLoginParam} = "yrGATElogin" if(!defined($GV->{SessLoginParam}));
$GV->{session_path} = "/xGDBvm/tmp" if(!defined($GV->{session_path}));

($cgi_paramHR->{USERid},$cgi_paramHR->{USERsession},$cgi_paramHR->{AUTHsession}) = getUserId();

# copied from UCA/fuctions.pl and modified to include 'USERsessionCGI'
sub getUserId{
  my @sessionCookie = cookie($GV->{SessCookieName}); # reads session id from cookie and accesses php session variables
  my $id = $sessionCookie[0];
  if (defined($id) && ($id ne "")){
    my $session = PHP::Session->new($id, { create => 1, save_path => $GV->{session_path} });
    if ($session->is_registered($GV->{SessLoginParam})){ 
      ## This checks existence of yrGATElogin session attribute.
      ## If set then this is an authenticated users session.
      my $USERid = $session->get($GV->{SessLoginParam});
      my $USERsession = $session->get('USERsessionCGI');
      return ($USERid, $USERsession,$id);
    }else{
      $session->destroy;
      return ("",undef,undef);
    }
  }
  return ('SSIpassthrough',undef,undef) if(param('XGDBpassthrough'));
  return ("",undef,undef);
}
