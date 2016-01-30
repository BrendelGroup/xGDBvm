#!/usr/bin/perl

require 'yrGATE_conf.pl';
require 'yrGATE_functions.pl';


# Login Reset: Planning
#
# Rules:
#   Safe
#   Don't annoy users!
#     Don't reset password without user consent. Require password validation first. We'll provide them with a 
#     "You can safely ignore this email" email, ala Paypal (?).
#
# Process:
#   1) User provides email address and desired new password
#   2) User receives email with validation code. It contains a validation URL.
#   3) User goes to validation URL
#   4) System replaces user's previous password with password they provided in step 1).
#   5) Necessary? User receives password reset success email.
#

my $logoutcookie = logout();

# header
&{$GV->{InitFunction}};

#<link type='text/css' rel='stylesheet' href=\"$GV->{HTMLPATH}yrGATE.css\" />
my $body = "";

if (param('mode') eq "reset_password"){ # Step 1

  my $check = PasswordNotify(param('email'),param('new_password'));
  $header = printTitle("Password Reset",1,1);
  $PageTitle="yrGATE: Reset Password";
  $body .= "$header";
  if (!$check){
     $body .= "<p>If the email address you submitted is in our database, you will soon receive an email containing instructions.</p>";
  }
$body .= "
<p>An email has been sent to you with a confirmation key. Use that key to <a href='$GV->{CGIPATH}loginReset.pl?mode=confirm_reset&amp;email=" . param('email') . "'>confirm your password change request</a> or return to <a href='$GV->{cgiPATH}login.pl'>yrGATE Login page</a>
</p>
";
} elsif (param('mode') eq "confirm_reset") { # Step 2
  if (param('email') ne "" && param('confirm_key') ne "") {
    my $check = PasswordConfirm(param('email'),param('confirm_key'));

    if ($check){
       $body .= "<p>Success! Your password has been updated. <a href='$GV->{CGIPATH}login.pl'>On to yrGATE!</a></p>";
    } else {
       $body .= "<p>Invalid request or failure resetting password. <a href='/utility/feedback.php'>Contact us</a> if you need help. Or, <a href='$GV->{CGIPATH}login.pl'>return to yrGATE!</a></p>";
    }
  } else {

  $header = printTitle("Confirm Password Reset",1,1);
  $PageTitle="yrGATE: Confirm Password Reset";
  $body .= "$header
<p>An email has been sent to you with a confirmation key. Enter it here to confirm your new password.</p>
<form name='loginfrm' method='post' action='$GV->{CGIPATH}loginReset.pl'>
	<table class='userlog'>
		<tr>
			<td>
				<label for='yrgate_email' class='bold'>email address</label>
			</td>
			<td>
				<input id='yrgate_email' name='email' value='" . param('email') . "'/>
			</td>
		</tr>
		<tr>
			<td>
				<label for='yrgate_email_confirmation' class='bold'>confirmation key</label>
			</td>
			<td>
				<input id='yrgate_email_confirmation' name='confirm_key' value='" . param('confirm_key') . "' />
			</td>
		</tr>
	</table>
	<input type='submit' value='Confirm Password Reset' />
	<input type='hidden' name='mode' value='confirm_reset' />
</form>
";
  }
} else {
  $header = printTitle("Password Reset",1,1);
  $PageTitle="yrGATE: Reset Password";
  $body .= "$header";
$body .= "

<!--h3>Forgot Password?</h3>
<p>You are on PlantGDB's yrGATE \"Forgot Password\" page. If you have a yrGATE account and know your password, please <a href='$GV->{CGIPATH}login.pl' title='log in to yrGATE'>log in</a>. Otherwise, <a href='$GV->{CGIPATH}userRegister.pl'>register for a yrGATE account</a>.</p>

<h3>Reset Your Password</h3 -->
<h3>To change your PlantGDB yrGATE password, please supply the following information:</h3>
<ul class=\"bullet1\">
  <li>The email address you used to sign up for yrGATE.</li>
  <li>The NEW password you would like to use. (See also: <a href='http://netforbeginners.about.com/od/lockdownyourpc/tp/5steps_strong_password.htm'>5 Steps to a Good Password</a>)</li>
</ul>
<form name='loginfrm' method='post' action='$GV->{CGIPATH}loginReset.pl'>
	<table class='userlog' style='margin-left: 20px'>
		<tr>
			<td>
				<label for='yrgate_email' class='bold'>email address</label>
			</td>
			<td>
				<input id='yrgate_email' name='email' value=''/>
			</td>
		</tr>
		<tr>
			<td>
				<label for='yrgate_email' class='bold'>new password</label>
			</td>
			<td>
				<input type='password' id='yrgate_new_password' name='new_password' />
			</td>
		</tr>
	</table>
	<h3 class='bottommargin1 topmargin1'>Next, click 'Reset Password' to send a confirmation link to the email address you supplied above.</h3>

	<input type='submit' value='Reset Password' />
	<input type='hidden' name='mode' value='reset_password' />
</form>
<p><a href='$GV->{CGIPATH}login.pl'>Login page</a></p>";
}

if ($ENV{'SERVER_NAME'} =~ m/zone/) { # Serve up XML on zones for better development practices.
	print header(-type=>'application/xhtml+xml', -charset=>'utf-8');
} else { # Serve normally (HTML) elsewhere.
	print header();
}

$PageTitle="yrGATE: Password Reset";
do '/Product/yrGATE/yrGATE_cgi/header.pl';

print "
<div id='leftcolumncontainer'></div>
<div id='maincontentscontainer' class='twocolumn mainT'>
    <div id='maincontents'>
	$body
    </div>
</div></div>
</div></div>
</body>
</html>";
