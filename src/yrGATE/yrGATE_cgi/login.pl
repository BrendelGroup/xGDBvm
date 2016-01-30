#!/usr/bin/perl

require 'yrGATE_conf.pl';
require 'yrGATE_functions.pl';


my $logoutcookie = logout();

my $message;

if (param('mode') eq "login"){
  my $check = login(param('username'),param('password'),param('persistence'));
  if ($check ne "0"){
      print $check;
      print redirect(-location => "$GV->{cgiPATH}AnnotationAccount.pl?login=1", -cookie => $check);
  }
  $message = "<p>Incorrect username or password, please try again.</p>";
}



# header
&{$GV->{InitFunction}};
my $header = printTitle("Annotator Login",1,1);


# body
my $body = "
<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Transitional//EN\" 
		  \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd\">

<html xmlns=\"http://www.w3.org/1999/xhtml\">
<head>
	<link type=\"text/css\" rel=\"stylesheet\" href=\"$GV->{HTMLPATH}yrGATE.css\" />
	<meta http-equiv=\"Content-type\" content=\"text/html;charset=iso-8859-1\" />
	<!--link type=\"text/css\" rel=\"stylesheet\" href=\"/css/plantgdb.css\"-->
	<title>yrGATE: Annotator Login</title>
</head>
<body class=\"mainT\"><!-- id=\"maincontents\"-->
$header
$message
<form name='loginfrm' method='post' action='$GV->{cgiPATH}login.pl'>
	<table class='userlog'>
		<tr>
			<td>
				<label for='yrgate_user'>user name</label>
			</td>
			<td>
				<input type='text' id='yrgate_user' name='username' />
			</td>
		</tr>
		<tr>
			<td>
				<label for='yrgate_password'>password</label>
			</td>
			<td><input type='password' id='yrgate_password' name='password' /></td>
		</tr>
		<tr>
			<td colspan='2'>Stay logged in until I:
			<select class='loginParam' name='persistence' id='persistence'>
			  <option value='0'>close my browser</option>
			  <option value='+1d'>am inactive for a day</option>
			  <option value='+10y' selected='selected'>click logout</option>
			</select>
			</td>
		</tr>
	</table>
	<input type='submit' value='log in' />
	<input type='hidden' name='mode' value='login' /> ...and go my Annotation Account
</form>

<p><a href='$GV->{CGIPATH}loginReset.pl'>forgot username / password?</a></p>

<p>Don't have an account? <a href='$GV->{CGIPATH}/userRegister.pl'>Sign Up</a></p>

</body>
</html>
";


print header(-cookie=> $logoutcookie);
print $body;
