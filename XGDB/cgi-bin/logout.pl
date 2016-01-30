#!/usr/bin/perl
use CGI ":all";
use GSQDB;

do 'SITEDEF.pl';
do 'getPARAM.pl';


my $loginCookie = cookie(-name=>"${SITENAMEshort}_LOGINstate",
			  -value=>[param('LOGINname'),param('LOGINstate')],
			  -expires=>'now');

print(header(-cookie=>[$loginCookie]),
      start_html(-onLoad=>"window.focus();"),
      h1("User: $cgi_paramHR->{USERid} succesfully logged out!"),
      "<SCRIPT LANGUAGE=\"JavaScript\">window.opener.submitTo(''); window.location='${CGIpath}login.pl';</SCRIPT>",
      end_html());
exit 1;
