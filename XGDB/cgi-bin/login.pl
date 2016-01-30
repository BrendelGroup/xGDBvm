#!/usr/bin/perl
use CGI ":all";
use GSQDB;

do 'SITEDEF.pl';
do 'getPARAM.pl';

my ($PAGE);
my $msg = "";
my $promptLOG = 0;

my $db = new GSQDB($cgi_paramHR);

if(param('SUBMITlogin') eq 'LOGIN'){
    $rtv = $db->validateLOGIN(param('LOGINname'),param('LOGINpass'));
  if($rtv == -1){
    $msg = "We're sorry. This user ID and password are invalid.<BR>Please try again.";
    $promptLOG = 1;
  }else{
    if(param('LOGINstate')){
      $loginCookie = cookie(-name=>"${SITENAMEshort}_LOGINstate",
			    -value=>[param('LOGINname'),$rtv,param('LOGINstate')],
			    -expires=>'+30d');
    }else{
      $loginCookie = cookie(-name=>"${SITENAMEshort}_LOGINstate",
			    -value=>[param('LOGINname'),$rtv,param('LOGINstate')]);
    }
    if(param('FROM')){
      my $goURL = "${CGIpath}" . param('FROM');
      print(header(-cookie=>[$loginCookie]),
	    start_html(),
	    h1('Login Accepted'),
            "<SCRIPT LANGUAGE=\"JavaScript\">window.opener.submitTo(''); window.location=\"$goURL\";</SCRIPT>",
	    end_html());
      exit 1;
    }else{
      # need to exit the window gracefully
      print(header(-cookie=>[$loginCookie]),
	    start_html(-onLoad=>"window.focus();"),
             "<SCRIPT LANGUAGE=\"JavaScript\"> window.opener.submitTo(''); window.location=\"${CGIPATH}UserHome.pl\";</SCRIPT>",
	    end_html());
      exit 1;
    }
  }
}else{
  $promptLOG = 1;
}

my $fpLINK   = "${CGIPATH}fpass.pl";
my $regLINK = "${CGIPATH}register.pl";
if(param('FROM')){
  $fpLINK  .= "?FROM=" . param('FROM');
  $regLINK .= "?FROM=" . param('FROM');
}

if($promptLOG){
  $PAGE = h1({-align=>'center'},"LOGIN to ${SITENAMEshort}") . hr .
    hidden({name=>'FROM'},param('FROM')) .
    table({-align=>'center'},
	  TR(
	     td({-align=>'center'},
		a({-href=>"$fpLINK"},strong(font({-color=>'#FF0000'},"Forgotten your password?"))) . br() .
		a({-href=>"$fpLINK"},strong(font({-color=>'#FF0000'},"Need to change your contact information?"))) . hr() .
		checkbox({-name=>'LOGINstate',-value=>1,-label=>""}) . a({-href=>"#"},font({-color=>'#FF22FF'}," Maintain Login")) . br() .
		font({-color=>'#FF2200'},$msg) . br() .
		strong('Login: ') . textfield(-name=>'LOGINname',-value=>"") . br() .
		strong('Password: ') . password_field(-name=>'LOGINpass',-value=>"") . br() .
		submit({-name=>'SUBMITlogin',-value=>'LOGIN'}) . "&nbsp;&nbsp;&nbsp;" . reset() . hr())
	    ) .
	  TR(
	     td({-align=>'center'},
		a({-href=>"$regLINK"},strong(font({-color=>'#FF0000'},"New Contributor?")) . " Register HERE!") . br()
	       )
	    )
	 );
}

print header(-cookie=>[$loginCookie]) .
  start_html(-title=>"${SITENAMEshort} User Annotation Submission",
	     -bgcolor=>'#FFFFFF',
             -onLoad=>"window.focus();"
	    ) .
  '<script>function updateaction() { document.LOGINform.action = "login.pl?prent=" + window.opener.name;}</script>',
  '<form name="LOGINform" method="post" onSubmit="updateaction();">'.
  "$PAGE" .
  end_form() .
  end_html();


