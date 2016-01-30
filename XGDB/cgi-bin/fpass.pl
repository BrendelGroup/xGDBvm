#!/usr/bin/perl
use CGI ":all";
use GSQDB;

do 'SITEDEF.pl';
do 'getPARAM.pl';


my ($PAGE);
my $db = new GSQDB();
my ($login,$msg,$rtv) = ("","",0);
my $prompt = 0;

if(param('SUBMITretrieve') eq 'Retrieve Login'){
  if($login = param('LOGINid')){
    if(!($rtv = $db->retrieveUser(0,$login))){
      $msg = "No registered user was associated with the LOGIN $login";
    }
  }elsif($email = param('LOGINemail')){
    if(!($rtv = $db->retrieveUser(1,$email))){
      $msg = "No registered user was associated with the email address $email";
    }
  }else{
    $msg = "A valid login id or registered email address is required to lookup your password";
  }
  if($rtv){
   $PAGE = "Your request has been received and processed.<BR>A message has been sent via email containing your login information.";
   if(param('FROM')){
      my $goURL = "${CGIpath}" . param('FROM');
      print(header(-cookie=>[$loginCookie]),
	    start_html(),
	    h3($PAGE),
	   "<SCRIPT LANGUAGE=\"JavaScript\">setTimeout('window.location=\"$goURL\";',2500);</SCRIPT>",
	    end_html());
      exit 1;
    }else{
      # need to exit the window gracefully
      print(header(-cookie=>[$loginCookie]),
	    start_html(),
	    h3($PAGE),
	    "<SCRIPT LANGUAGE=\"JavaScript\">setTimeout('window.location=\"${CGIpath}login.pl\";',2500);</SCRIPT>",
	    end_html());
      exit 1;
    }
  }else{
    $prompt = 1;
  }
}elsif(param('SUBMITedit') eq 'Submit Changes'){
  if(param('LOGINname') && param('LOGINpass')){
    if($db->validateLOGIN(param('LOGINname'),param('LOGINpass'))>=0){
      $fullname = (param('fullname'))?param('fullname'):0;
      $email    = (param('email'))?param('email'):0;
      $phone    = (param('phone'))?param('phone'):0;
      $npass    = (param('newpass'))?param('newpass'):0;
      if($fullname || $email || $phone || $npass){
	$rtv = $db->updateUSER(param('LOGINname'),$npass,$email,$phone,$fullname);
	if($rtv > 0){
	  my $loginCookie = cookie(-name=>"${SITENAMEshort}_LOGINstate",
			    -path=>$CGIPATHs,
			    -value=>[param('LOGINname'),param('LOGINstate')]);
	  $PAGE = h3('User information updated succesfully.');
# need to exit the window gracefully
	  print(header(-cookie=>[$loginCookie]),
		start_html(),
		h1($PAGE),
		"<SCRIPT LANGUAGE=\"JavaScript\">setTimeout('window.location=\"${CGIpath}UserHome.pl\";',2500);</SCRIPT>",
		end_html());
	  exit 1;

	}elsif($rtv == 0){
	  $msg2 = "The email address <B>$email</B> is already in use be another user.<BR> Please contact the <A href='${WEBMASTER}'>${SITENAMEshort} administration</A> to resolve this matter";
	  $prompt = 1;
	}
      }else{
	$msg2 = "No information was provided to update this user record";
	$prompt = 1;
      }
    }else{
      $msg2 = "The Login and Password provided are not a valid combination.<BR>Please provided a valid login.";
      $prompt = 1;
    }
  }else{
    $msg2 = "A Login and Password must be provided to edit your user record.";
    $prompt = 1;
  }
}else{
  $prompt = 1;
}

if($prompt){
  $PAGE = h1({-align=>'center'},'Retrieve / Edit Login') . hr .
    hidden({name=>'FROM'},param('FROM')) .
      table({-align=>'center'},
	  TR(
	     td({-align=>'center'},
		font({-color=>'#0022FF'},'Retrieve forgotten login information:') . br() .
		font({-color=>'#FF2200'},$msg) . br() .
		strong('Login: ') . textfield(-name=>'LOGINid',-value=>"") . br() .
		b('-OR-') . br() .
		strong('Email: ') . textfield(-name=>'LOGINemail',-value=>"") . br() .
		submit({-name=>'SUBMITretrieve',-value=>'Retrieve Login'}) . hr()
	       )
	    ) .
	   TR(
	     td({-align=>'center'},
		font({-color=>'#0022FF'},'Edit contributor information:') . br() .
		font({-color=>'#FF2200'},$msg2) . br() .
		strong('Fullname: ') . textfield(-name=>'fullname',-value=>"") . br() .
		strong('Email: ') . textfield(-name=>'email',-value=>"") . br() .
		strong('Phone: ') . textfield(-name=>'phone',-value=>"") . br() .
		strong('New Password: ') . password_field(-name=>'newpass',-value=>"") . br() .
		strong('**Login: ') . textfield(-name=>'LOGINname',-value=>"") . br() .
		strong('**Password: ') . password_field(-name=>'LOGINpass',-value=>"") . br() .
		submit({-name=>'SUBMITedit',-value=>'Submit Changes'})
	       )
	    )
	 );
}



print header() .
  start_html(-title=>"${SITENAMEshort} User Login / Registration Retrieval",
	     -bgcolor=>'#FFFFFF') .
  start_form(-name=>'LRform') .
  $PAGE .
  end_form() .
  end_html();
