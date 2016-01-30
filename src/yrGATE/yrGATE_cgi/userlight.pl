#!/usr/bin/perl

##### SDS ########
## This script is meant to provide an extremely lightweight AJAX accessible mechanism for authenticating and registering users.
## The script will return a single word result status.
##
## inputs parameters: mode, username, password, persistence, email, fullname, phone
## output result status: SUCCESS, BADUSER, BADPASS, BADEMAIL, BADNAME, DUPUSER
##################
 
require 'yrGATE_conf.pl';
require 'yrGATE_functions.pl';

if (param('mode') eq "logout"){
  print header(-cookie => logout()) . "SUCCESS";
}elsif (param('mode') eq "login"){
  my $check = login(param('username'),param('password'),param('persistence')); 
  if ($check ne "0"){
    print header(-cookie => $check) . "SUCCESS";
  }else{
    print header() . "BADPASS";  ## Currently not distinguishing between BADUSER and BADPASS
  }
}elsif(param('mode') eq "register"){
  if(!defined(param('username')) || (param('username') eq "")){
    print header() . "BADUSER";
    exit;
  }
  if(!defined(param('password')) || (param('password') eq "")){
    print header() . "BADPASS";
    exit;
  }
  if(!defined(param('email')) || (param('email') eq "")){
    print header() . "BADEMAIL";
    exit;
  }
  if(!defined(param('fullname')) || (param('fullname') eq "")){
    print header() . "BADNAME";
    exit;
  }
  my $check = user_register(param('username'),param('password'),param('fullname'),param('phone'),param('email'));
  if(!$check){
    print header() . "DUPUSER";
    exit;
  }
  print header(-cookie => login(param('username'),param('password'),param('persistence'))) . "SUCCESS";
}elsif(param('mode') eq "loginForm"){
  ## provided as an ajax loadable form 
  my $message = "<p>Incorrect username or password, please try again.</p>" if(param('retry'));

  print header();
  print <<END_OF_FORM;
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
        <link type="text/css" rel="stylesheet" href="$GV->{HTMLPATH}yrGATE.css" />
	<meta http-equiv="Content-type" content="text/html;charset=iso-8859-1" />
	<title>yrGATE: Annotator Login</title>
</head>
<body class="mainT">
$message
<table class="userlog">
  <tr><td>user name</td><td><input type='text' name='username' id='username' class='loginFormInput'></td></tr>
  <tr><td>password</td><td><input type='password' name='password' id='password' class='loginFormInput'></td></tr>
  <tr><td><a href='$GV->{CGIPATH}loginReset.pl'>Forgot username/password</a></td></tr>
  <tr><td colspan='2'>Stay logged in until I:
    <select class='loginParam' name='persistence' id='persistence'>
      <option value='0'>close my browser</option>
      <option value='+1d'>am inactive for a day</option>
      <option value='+10y' selected='selected'>click logout</option>
    </select>
  </td></tr>
</table>
</body>
</html>
END_OF_FORM

}elsif(param('mode') eq "registerForm"){
  my $message = "<br>That username or email is already registered, or you have forgotten to enter a required field.  Please try again.<br>" if(param('retry'));

  print header();
  print <<END_OF_FORM;
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-t
ransitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
        <link type="text/css" rel="stylesheet" href="$GV->{HTMLPATH}yrGATE.css" />
        <meta http-equiv="Content-type" content="text/html;charset=iso-8859-1" />
	<title>yrGATE: Annotator Registration</title>
</head>
<body class=mainT>
$message
user name <input class='fieldpadd registerFormInput' type=text name='username' id='username'><br /><br />
password <input class='fieldpadd registerFormInput' type=password name='password' id='password'><br /><br />
email <input class='fieldpadd registerFormInput' type=text name='email' id='email'><br /><br />
name <input class='fieldpadd registerFormInput' type=text name='fullname' id='fullname'><br /><br />
phone <input class='fieldpadd registerFormInput' type=text name='phone' id='phone'> (not required) <br>
</body>
</html>
END_OF_FORM

}
