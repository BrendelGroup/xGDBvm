#!/usr/bin/perl

use CGI::Cookie;

require 'yrGATE_conf.pl';
require 'yrGATE_functions.pl';

my $cookie = logout(); ### sds - modified this line to use the logout function from yrGATE_functions ###
print redirect(-location=>"$GV->{CGIPATH}CommunityCentral.pl?logout=1", -cookie=>$cookie);
