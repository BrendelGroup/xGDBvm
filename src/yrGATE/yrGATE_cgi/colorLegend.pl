#!/usr/bin/perl

# Access this script on the web by following the "Evidence Plot" link on AnnotationTool.pl

require 'yrGATE_conf.pl';
require 'yrGATE_functions.pl';
require 'das_scripts/dasFunctions.pl';


my $legend;

if ($GV->{das_input}){
    for my $k (keys %DAScolor){
		$legend .= "<div style='background:$DAScolors{$k}:width:100px'>$k</div><br /><br />";
    }
}else{
    for my $k ( @{&{$GV->{evidenceSources}}} ){
		$legend .= "<div style='background:$k->[1];width:100px'>$k->[0]</div><br /><br />";
    }
}

print header();
print "<html>
<head>
<title>yrGATE: Color Legend
</title>
<LINK type='text/css' rel='stylesheet' href='$GV->{HTMLPATH}yrGATE.css'>
</head>
<body>".printTitle("Color Legend",1,0)."
$legend
</body>
</html>
";
