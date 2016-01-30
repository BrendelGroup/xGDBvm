#!/usr/bin/perl
use CGI ":all";
use GSQDB;

do 'SITEDEF.pl';
do 'getPARAM.pl';

my ($PAGE);
my $db = new GSQDB();
my ($phone,$msg,$rtv) = ("","",0);
my $promptLOG = 0;

if(param('SUBMITregister') eq 'REGISTER'){
  $phone = param('phone') if(param('phone'));
  if((!param('LOGINname'))||
     (!param('LOGINpass'))||
     (!param('email'))||
     (!param('fullname'))){
    $msg = "We're sorry. All required fields must be completed to process your registration.";
    $promptLOG = 1;
  }else{
    $rtv = $db->registerUSER(param('LOGINname'),param('LOGINpass'),param('email'),$phone,param('fullname'));
    if($rtv == 0){
      $msg = "We're sorry. This user ID has already been reserved.<BR>Please choose another ID.";
      $promptLOG = 1;
    }elsif($rtv == -1){	
      $msg = "This email address is already in use be another user.<BR> Please contact the <A href='${WEBMASTER}'>${SITENAMEshort} administration</A> to resolve this matter";
      $promptLOG = 1;
    }else{
     # Registration Successful
     ## Create Cookie
     $loginCookie = cookie(-name=>"${SITENAMEshort}_LOGINstate",-value=>[param('LOGINname'),param('fullname'),0]);
     ##
      my $goURL = "${CGIpath}";
      if(param('FROM')){
        $goURL .= param('FROM');
	print(header(-cookie=>[$loginCookie]),
	      start_html(),
	      h1('Login Accepted'),
	      "<SCRIPT LANGUAGE=\"JavaScript\">window.location=\"$goURL\";</SCRIPT>",
	      end_html());
	exit 1;
      }else{
        $goURL .= 'UserHome.pl';
	print(header(-cookie=>[$loginCookie]),
	      start_html(),
	      h1('Registration Successfull'),
              "<SCRIPT LANGUAGE=\"JavaScript\">window.location=\"$goURL\";</SCRIPT>",
	      end_html());
	exit 1;
      }

    }
  }
}else{
  $promptLOG = 1;
}

if($promptLOG){
  $PAGE = h1({-align=>'center'},"REGISTER with ${SITENAMEshort}") . hr .
    hidden({name=>'FROM'},param('FROM')) .
    table({-align=>'center'},
	  TR(
	     td({-align=>'center'},
		font({-color=>'#FF2200'},$msg) . br() .
		strong('*Login: ') . textfield(-name=>'LOGINname',-value=>"",-maxlength=>50) . br() .
		strong('*Password: ') . password_field(-name=>'LOGINpass',-value=>"",-maxlength=>25) . br() . hr()
	       )
	    ) .
	   TR(
	     td({-align=>'center'},
		font({color=>'#FF2200'},"Fields marked with * are required.") . br() .
		strong('*Fullname: ') . textfield(-name=>'fullname',-value=>"",-maxlength=>32) . br() .
		strong('*email: ') . textfield(-name=>'email',-value=>"",-maxlength=>32) . br() .
		strong('phone: ') . textfield(-name=>'phone',-value=>"",-maxlength=>32) . br() . hr().
		submit({-name=>'SUBMITregister',-value=>'REGISTER'}) . "&nbsp;&nbsp;&nbsp;" . reset()
	       )
	    )
	 );
}



print header() .
  start_html(-title=>"${SITENAMEshort} User Login / Registration",
	     -bgcolor=>'#FFFFFF') .
  start_form(-name=>'LRform') .
  "$PAGE" .
  end_form() .
  end_html();
