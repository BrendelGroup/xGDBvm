#!/usr/bin/perl

require 'yrGATE_conf.pl';
require 'yrGATE_functions.pl';

my $logoutcookie = logout();

my $message;

if (param('mode') eq "register"){
    my $ret = user_register(param('username'),param('password'),param('fullname'),param('phone'),param('email'));
    if ($ret){
      my $check = login(param('username'),param('password')); 
      if ($check ne "0"){
	  print $check;
          print redirect(-location => "$GV->{cgiPATH}AnnotationAccount.pl", -cookie => $check);
      }
    }
    disconnectDB();
  $message = "<br>That username or email is already registered, or have forgot to enter a required field.  Please try again.<br>";
}


# header
my $header = printTitle("Annotator Registration",1,1);

# body
my $body ="
<html>
<head>
<LINK type='text/css' rel='stylesheet' href='$GV->{HTMLPATH}yrGATE.css'>
<title>yrGATE: Annotator Registration</title>

</head>
<body class=mainT>
$header
$message
<form id='loginfrm' name='loginfrm' method='post'>
	<label for='yrgate_username'>user name</label><input class='fieldpadd' type='text' name='username' title='This is the name you will log in with.'><br /><br />
	<label for='yrgate_password'>password</label><input class='fieldpadd' type='password' name='password'><br /><br />
	<label for='yrgate_email'>email</label><input class='fieldpadd' type='text' name='email'><br /><br />
	<label for='yrgate_fullname'>name</label><input class='fieldpadd' type='text' name='fullname' title='Your full name.'><br /><br />
	<label for='yrgate_phone'>phone</label><input class='fieldpadd' type='text' name='phone'> (not required) <br /><br />

	<input type='submit' value='sign up'>
	<input type='hidden' name='mode' value='register'>
</form>
".printFooter()."
</body>
</html>
";


print header(-cookie=>$logoutcookie);
print $body;
