#!/usr/bin/perl
require 'yrGATE_conf.pl';
require 'dasFunctions.pl';

%colors = dasColors();
$page = "";
for my $k (keys %colors){
  $page .= "<font color='$colors{$k}'>$k<\/font><br>";
}

print header();
print "<html><body>$page<\/body><\/html>";
